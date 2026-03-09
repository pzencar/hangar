local function execute(chunk)
    if chunk then
        local script = chunk()
        if type(script) == "table" and script.run then
            script.run()
        end
    end
end

local function prearm_on()
    model.setGlobalVariable(4, 0, 100)
end

local function prearm_off()
    model.setGlobalVariable(4, 0, -100)
end

local rf_on_chunk = loadfile("/SCRIPTS/FUNCTIONS/rfon.lua")
local rf_off_chunk = loadfile("/SCRIPTS/FUNCTIONS/rfoff.lua")
local rgb_purple_chunk = loadfile("/SCRIPTS/RGBLED/purple.lua")
local rgb_green_chunk = loadfile("/SCRIPTS/RGBLED/green.lua")
local rgb_orange_chunk = loadfile("/SCRIPTS/RGBLED/orange.lua")
local rgb_red_chunk = loadfile("/SCRIPTS/RGBLED/red.lua")
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
    RED     = 4,
    OFF     = 5,
}

local MainState = {
    UNKNOWN               = 0,
    IDLE                  = 1,
    RF_OFF                = 2,
    PREARMED              = 3,
    ARMED                 = 4,
    DISARMED_WITH_PREARM = 5,
}

local RFMapping = {
    [MainState.UNKNOWN]               = RFState.UNKNOWN,
    [MainState.IDLE]                  = RFState.ON,
    [MainState.RF_OFF]                = RFState.OFF,
    [MainState.PREARMED]              = RFState.ON,
    [MainState.ARMED]                 = RFState.ON,
    [MainState.DISARMED_WITH_PREARM] = RFState.ON,
}

local LEDMapping = {
    [MainState.UNKNOWN]               = LEDState.UNKNOWN,
    [MainState.IDLE]                  = LEDState.PURPLE,
    [MainState.RF_OFF]                = LEDState.OFF,
    [MainState.PREARMED]              = LEDState.ORANGE,
    [MainState.ARMED]                 = LEDState.GREEN,
    [MainState.DISARMED_WITH_PREARM] = LEDState.RED,
}

local MainLabels = {
    [MainState.UNKNOWN] = 'UNKNOWN',
    [MainState.IDLE]  = 'IDLE',
    [MainState.RF_OFF]  = 'RF_OFF',
    [MainState.PREARMED]  = 'PREARMED',
    [MainState.ARMED]  = 'ARMED',
    [MainState.DISARMED_WITH_PREARM]  = 'DISARMED_WITH_PREARM'
}

local LEDLabels = {
    [LEDState.UNKNOWN] = 'UNKNOWN',
    [LEDState.GREEN]  = 'GREEN',
    [LEDState.PURPLE]  = 'PURPLE',
    [LEDState.ORANGE]  = 'ORANGE',
    [LEDState.RED]  = 'RED',
    [LEDState.OFF]  = 'OFF'
}

local LEDActions = {
    [LEDState.UNKNOWN] = rgb_purple_chunk,
    [LEDState.GREEN]  = rgb_green_chunk,
    [LEDState.PURPLE]  = rgb_purple_chunk,
    [LEDState.ORANGE]  = rgb_orange_chunk,
    [LEDState.RED]  = rgb_red_chunk,
    [LEDState.OFF]  = rgb_off_chunk
}


local last_sw_arm = false
local last_sw_rf_off = false
local last_sw_prearm = false

local last_main_state = MainState.UNKNOWN
local last_rf_state = RFState.UNKNOWN
local last_led_state = LEDState.UNKNOWN

local function run(event)
    -- Read switches
    local sw_rf_off = getValue('sb') == 1024
    local sw_arm = getValue('se') == -1024
    local sw_prearm = getValue('sf') == 1024

    -- Initialize local vars
    local edge_sw_rf_off = 0
    local edge_sw_arm = 0
    local edge_sw_prearm = 0
    local main_state = last_main_state
    local rf_state = last_rf_state
    local led_state = last_led_state

    -- Edge Detection
    if sw_rf_off ~= last_sw_rf_off then
        edge_sw_rf_off = (sw_rf_off == true) and 1 or -1
        last_sw_rf_off = sw_rf_off
    end

    if sw_arm ~= last_sw_arm then
        edge_sw_arm = (sw_arm == true) and 1 or -1
        last_sw_arm = sw_arm
    end

    if sw_prearm ~= last_sw_prearm then
        edge_sw_prearm = (sw_prearm == true) and 1 or -1
        last_sw_prearm = sw_prearm
    end

    if last_rf_state == RFState.UNKNOWN or last_led_state == LEDState.UNKNOWN or last_main_state == MainState.UNKNOWN then
        -- Absolute init
        if not sw_rf_off then
            main_state = MainState.IDLE
        else
            main_state = MainState.RF_OFF
        end

        last_main_state = main_state
        led_state = LEDMapping[main_state]
        last_led_state = led_state
        rf_state = RFMapping[main_state]
        last_rf_state = rf_state

        if rf_state == RFState.ON then execute(rf_on_chunk) else execute(rf_off_chunk) end
        execute(LEDActions[led_state])
        
        print('INIT: Main State: ', MainLabels[main_state])
        print('INIT: RF State: ', (rf_state == RFState.ON and 'ON' or 'OFF'))
        print('INIT: LED State: ', LEDLabels[led_state])
    else
        -- Main state machine
        if main_state == MainState.IDLE then
            if edge_sw_prearm > 0 then
                prearm_on()
                main_state = MainState.PREARMED
            elseif edge_sw_rf_off > 0 then
                main_state = MainState.RF_OFF
            end
        elseif main_state == MainState.RF_OFF then
            if edge_sw_rf_off < 0 then
                main_state = MainState.IDLE
            end
        elseif main_state == MainState.PREARMED then
            if edge_sw_prearm < 0 then
                main_state = MainState.IDLE
                prearm_off()
            elseif edge_sw_arm > 0 then
                main_state = MainState.ARMED
            end
        elseif main_state == MainState.ARMED then
            if edge_sw_arm < 0 then
                main_state = MainState.DISARMED_WITH_PREARM
            end
        elseif main_state == MainState.DISARMED_WITH_PREARM then
            if edge_sw_prearm > 0 then
                main_state = MainState.PREARMED
            elseif edge_sw_arm > 0 then
                main_state = MainState.ARMED
            end
        end

        -- Update states if needed
        if main_state ~= last_main_state then
            print('Main State Change: ', MainLabels[main_state])
            rf_state = RFMapping[main_state]
            led_state = LEDMapping[main_state]
            last_main_state = main_state

        end

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
end

return { run=run }