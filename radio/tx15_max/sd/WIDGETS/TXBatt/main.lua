local app_name = "TXBatt"
local app_ver = "1.6"

local _options = {
    {"batt_type"         , CHOICE, 1 , {"LiPo", "LiPo-HV (high voltage)", "Li-Ion", "LifePO4"} },
    {"isTotalVoltage"    , BOOL  , 0      },
    {"color"             , COLOR , YELLOW },
}

local function translate(name)
    local translations = {
        batt_type="Battery Type",
        isTotalVoltage="Show Total Voltage",
        color = "Text Color",
    }
    return translations[name]
end

local function create(zone, options)
    -- imports
    local wgt   = loadScript("/WIDGETS/" .. app_name .. "/logic.lua", "btd")()
    wgt.tools   = loadScript("/WIDGETS/" .. app_name .. "/lib_widget_tools.lua", "btd")(app_name, true)
    loadScript("/WIDGETS/" .. app_name .. "/ui_lvgl", "btd")(wgt)
    wgt.zone = zone
    wgt.options = options
    return wgt
end

-- This function allow updates when you change widgets settings
local function update(wgt, options)
    wgt.options = options

    wgt.batt_height = wgt.zone.h
    wgt.batt_width = wgt.zone.w

    local ver, radio, maj, minor, rev, osname = getVersion()
    local nVer = maj*1000000 + minor*1000 + rev
    --wgt.log("version: %s, %s %s %s %s", string.format("%d.%03d.%03d", maj, minor, rev), nVer<2011000, nVer>2011000, nVer>=2011000, nVer>=2011000)
    wgt.is_valid_ver = (nVer>=2011000)
    if wgt.is_valid_ver==false then
        local lytIvalidVer = {
            {
                type=LVGL_DEF.type.LABEL, x=0, y=0, font=0,
                text="!! this widget \nis supported only \non ver 2.11 and above",
                color=RED
            }
        }
        lvgl.build(lytIvalidVer)
        return
    end

    -- wgt.update_logic(wgt, options)
    wgt.update_ui()
end

local function background(wgt)
    wgt.background()
end

local function refresh(wgt, event, touchState)
    wgt.background()

    -- debugChangeSize(wgt)

    wgt.refresh(event, touchState)
end

return {
    name = app_name,
    options = _options,
    create = create,
    update = update,
    background = background,
    refresh = refresh,
    translate=translate,
    useLvgl=true
}
