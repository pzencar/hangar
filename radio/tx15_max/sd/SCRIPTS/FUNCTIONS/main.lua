local function execute(chunk)
    if chunk then
        local script = chunk()
        if type(script) == "table" and script.run then
            script.run()
        end
    end
end

local rf_on_chunk = loadfile("/SCRIPTS/FUNCTIONS/rfon.lua")
local rf_off_chunk = loadfile("/SCRIPTS/FUNCTIONS/rfoff.lua")
local rgb_purple_chunk = loadfile("/SCRIPTS/RGBLED/purple.lua")
local rgb_green_chunk = loadfile("/SCRIPTS/RGBLED/green.lua")
local rgb_orange_chunk = loadfile("/SCRIPTS/RGBLED/orange.lua")
local rgb_off_chunk = loadfile("/SCRIPTS/RGBLED/off.lua")

local RFState = {
    UNKNOWN = 0,
    ON   = 1,
    OFF  = 2,
}

local LEDState = {
    UNKNOWN = 0,
    GREEN   = 1,
    PURPLE  = 2,
    ORANGE  = 3,
    OFF     = 4,
}

local LEDLabels = {
    [LEDState.UNKNOWN] = 'UNKNOWN',
    [LEDState.GREEN]  = 'GREEN',
    [LEDState.PURPLE]  = 'PURPLE',
    [LEDState.ORANGE]  = 'ORANGE',
    [LEDState.OFF]  = 'OFF'
}

local LEDActions = {
    [LEDState.UNKNOWN] = rgb_purple_chunk,
    [LEDState.GREEN]  = rgb_green_chunk,
    [LEDState.PURPLE]  = rgb_purple_chunk,
    [LEDState.ORANGE]  = rgb_orange_chunk,
    [LEDState.OFF]  = rgb_off_chunk
}

local lastSE = false
local lastSB = false
local lastSF = false

local last_rf_state = RFState.UNKNOWN
local last_led_state = LEDState.UNKNOWN

local armed = false
local rf_off_block = false

local function run(event)
    -- Absolute init
    if last_rf_state == RFState.UNKNOWN or last_led_state == LEDState.UNKNOWN then
        execute(rf_on_chunk)
        execute(rgb_purple_chunk)
        last_rf_state = RFState.ON
        last_led_state = LEDState.PURPLE
    end

    -- Read switches
    local SB = getValue('sb') == 1024
    local SE = getValue('se') == -1024
    local SF = getValue('sf') == 1024

    -- Initialize local vars
    local eSB = 0
    local eSE = 0
    local eSF = 0
    local rf_state = last_rf_state
    local led_state = last_led_state

    -- Edge Detection
    if SB ~= lastSB then
        eSB = (SB == true) and 1 or -1
        lastSB = SB
    end

    if SE ~= lastSE then
        eSE = (SE == true) and 1 or -1
        lastSE = SE
    end

    if SF ~= lastSF then
        eSF = (SF == true) and 1 or -1
        lastSF = SF
    end

    -- prearm
    local prearm_active = SF
    -- model.setGlobalVariable(1, 0, prearm_active and 100 or 0) -- Adjusted index to match your pattern

    -- arm
    if not armed and prearm_active and eSE > 0 then
        armed = true
    elseif armed and eSE < 0 then
        armed = false
    end
    -- model.setGlobalVariable(2, 0, armed and 100 or 0)

    -- rf_off_block
    if not rf_off_block and armed and SB then
        rf_off_block = true
    elseif rf_off_block and not armed and eSB == -1 then
        rf_off_block = false
    elseif rf_off_block and armed and eSB == -1 then
        rf_off_block = false
    end
    -- model.setGlobalVariable(3, 0, rf_off_block and 100 or 0)

    -- rf_state
    if armed then
        rf_state = RFState.ON
    else
        if SB then
            if rf_off_block then
                rf_state = RFState.ON
            elseif not prearm_active then
                rf_state = RFState.OFF
            else
                rf_state = RFState.ON
            end
        else
            rf_state = RFState.ON
        end
    end
    -- model.setGlobalVariable(4, 0, (rf_state == RFState.OFF) and 100 or 0)

    -- led_state
    if armed then
        led_state = LEDState.GREEN
    elseif prearm_active then
        led_state = LEDState.ORANGE
    elseif rf_state == RFState.ON then
        led_state = LEDState.PURPLE
    else
        led_state = LEDState.OFF
    end
    -- model.setGlobalVariable(5, 0, (led_state == LEDState.GREEN) and 100 or 0)
    -- model.setGlobalVariable(6, 0, (led_state == LEDState.PURPLE) and 100 or 0)
    -- model.setGlobalVariable(7, 0, (led_state == LEDState.ORANGE) and 100 or 0)
    -- model.setGlobalVariable(8, 0, (led_state == LEDState.OFF) and 100 or 0)

    -- write rf_state if needed
    if rf_state ~= last_rf_state then
        print('RF State Change: ', (rf_state == RFState.ON and 'ON' or 'OFF'))
        if rf_state == RFState.ON then execute(rf_on_chunk) else execute(rf_off_chunk) end
        last_rf_state = rf_state
    end

    -- write led_state if needed
    if led_state ~= last_led_state then
        print('LED State Change: ', LEDLabels[led_state])
        execute(LEDActions[led_state])
        last_led_state = led_state
    end
end

return { run=run }