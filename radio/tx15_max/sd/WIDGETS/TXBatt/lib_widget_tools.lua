local app_name, useLvgl = ...

local M = {}
M.app_name = app_name

local getTime = getTime
local lcd = lcd

-- better font names
local FONT_38 = XXLSIZE -- 38px
local FONT_16 = DBLSIZE -- 16px
local FONT_12 = MIDSIZE -- 12px
local FONT_8 = 0 -- Default 8px
local FONT_6 = SMLSIZE -- 6px

-- better font size names
M.FONT_SIZES = {
    FONT_6  = SMLSIZE, -- 6px
    FONT_8  = 0,       -- Default 8px
    FONT_12 = MIDSIZE, -- 12px
    FONT_16 = DBLSIZE, -- 16px
    FONT_38 = XXLSIZE, -- 38px
}
M.FONT_LIST = {
    FONT_6,
    FONT_8,
    FONT_12,
    FONT_16,
    FONT_38,
}

-- const's
local UNIT_ID_TO_STRING = {
    "V", "A", "mA", "kts", "m/s", "f/s", "km/h", "mph", "m", "f",
    "°C", "°F", "%", "mAh", "W", "mW", "dB", "rpm", "g", "°",
    "rad", "ml", "fOz", "ml/m", "Hz", "mS", "uS", "km"
}

function M.unitIdToString(unitId)
    if unitId == nil then
        return ""
    end
    -- UNIT_RAW
    if unitId == "0" then
        return ""
    end


    if (unitId > 0 and unitId <= #UNIT_ID_TO_STRING) then
        local txtUnit = UNIT_ID_TO_STRING[unitId]
        return txtUnit
    end

    --return "-#-"
    return ""
end

---------------------------------------------------------------------------------------------------
-- workaround for bug in getFiledInfo()  -- ???? why?
function M.cleanInvalidCharFromGetFiledInfo(sourceName)
     if string.byte(string.sub(sourceName, 1, 1)) > 127 then
        sourceName = string.sub(sourceName, 2, -1)
    end
    if string.byte(string.sub(sourceName, 1, 1)) > 127 then
        sourceName = string.sub(sourceName, 2, -1)
    end
    return sourceName
end

-- workaround for bug in getSourceName()
function M.getSourceNameCleaned(source)
    local sourceName = getSourceName(source)
    if (sourceName == nil) then
        return "N/A"
    end
    local sourceName = M.cleanInvalidCharFromGetFiledInfo(sourceName)
    return sourceName
end

------------------------------------------------------------------------------------------------------

function M.getFontSizeRelative(orgFontSize, delta)
    for i = 1, #M.FONT_LIST do
        if M.FONT_LIST[i] == orgFontSize then
            local newIndex = i + delta
            newIndex = math.min(newIndex, #M.FONT_LIST)
            newIndex = math.max(newIndex, 1)
            return M.FONT_LIST[newIndex]
        end
    end
    return orgFontSize
end

function M.getFontIndex(fontSize, defaultFontSize)
    for i = 1, #M.FONT_LIST do
        if M.FONT_LIST[i] == fontSize then
            return i
        end
    end
    return defaultFontSize
end

function M.lcdSizeTextFixed(txt, font_size)
    local ts_w, ts_h = lcd.sizeText(txt, font_size)

    local v_offset = 0
    if font_size == FONT_38 then
        if (useLvgl==true) then
            v_offset = -7
            ts_h = 61
            return ts_w-3, ts_h+v_offset-14, v_offset
            -- return ts_w-3, ts_h +2*v_offset-14, v_offset
        else
            v_offset = -14
            ts_h = 61
        end
    elseif font_size == FONT_16 then
        v_offset = -8
        ts_h = 30
    elseif font_size == FONT_12 then
        v_offset = -6
        ts_h = 23
    elseif font_size == FONT_8 then
        v_offset = -4
        ts_h = 16
    elseif font_size == FONT_6 then
        v_offset = -4
        ts_h = 13
    end
    -- return ts_w, ts_h +2*v_offset, v_offset
    return ts_w, ts_h+v_offset, v_offset
end

function M.getFontSize(wgt, txt, max_w, max_h, max_font_size)
    local maxFontIndex = M.getFontIndex(max_font_size, nil)

    if M.getFontIndex(FONT_38, nil) <= maxFontIndex then
        local w, h, v_offset = M.lcdSizeTextFixed(txt, FONT_38)
        if w <= max_w and h <= max_h then
            return FONT_38, w, h, v_offset
        else
        end
    end


    w, h, v_offset = M.lcdSizeTextFixed(txt, FONT_16)
    if w <= max_w and h <= max_h then
        return FONT_16, w, h, v_offset
    end

    w, h, v_offset = M.lcdSizeTextFixed(txt, FONT_12)
    if w <= max_w and h <= max_h then
        return FONT_12, w, h, v_offset
    end

    w, h, v_offset = M.lcdSizeTextFixed(txt, FONT_8)
    if w <= max_w and h <= max_h then
        return FONT_8, w, h, v_offset
    end

    w, h, v_offset = M.lcdSizeTextFixed(txt, FONT_6)
    return FONT_6, w, h, v_offset
end

------------------------------------------------------------------------------------------------------
function M.drawText(x, y, text, font_size, text_color, bg_color)
    local ts_w, ts_h, v_offset = M.lcdSizeTextFixed(text, font_size)
    lcd.drawRectangle(x, y, ts_w, ts_h, BLUE)
    lcd.drawText(x, y + v_offset, text, font_size + text_color)
    return ts_w, ts_h, v_offset
end

function M.drawBadgedText(txt, txtX, txtY, font_size, text_color, bg_color)
    local ts_w, ts_h, v_offset = M.lcdSizeTextFixed(txt, font_size)
    local v_space = 2
    local bdg_h = v_space + ts_h + v_space
    local r = bdg_h / 2
    lcd.drawFilledCircle(txtX , txtY + r, r, bg_color)
    lcd.drawFilledCircle(txtX + ts_w , txtY + r, r, bg_color)
    lcd.drawFilledRectangle(txtX, txtY , ts_w, bdg_h, bg_color)

    lcd.drawText(txtX, txtY + v_offset + v_space, txt, font_size + text_color)

    --lcd.drawRectangle(txtX, txtY , ts_w, bdg_h, RED) -- dbg
end

function M.drawBadgedTextCenter(txt, txtX, txtY, font_size, text_color, bg_color)
    local ts_w, ts_h, v_offset = M.lcdSizeTextFixed(txt, font_size)
    local r = ts_h / 2
    local x = txtX - ts_w/2
    local y = txtY - ts_h/2
    lcd.drawFilledCircle(x + r * 0.3, y + r, r, bg_color)
    lcd.drawFilledCircle(x - r * 0.3 + ts_w , y + r, r, bg_color)
    lcd.drawFilledRectangle(x, y, ts_w, ts_h, bg_color)

    lcd.drawText(x, y + v_offset, txt, font_size + text_color)

    -- dbg
    --lcd.drawRectangle(x, y , ts_w, ts_h, RED) -- dbg
    --lcd.drawLine(txtX-30, txtY, txtX+30, txtY, SOLID, RED) -- dbg
    --lcd.drawLine(txtX, txtY-20, txtX, txtY+20, SOLID, RED) -- dbg
end

------------------------------------------------------------------------------------------------------
-- usage:
--log("bbb----------------------------------------------------------")
--wgt.tools.heap_dump(wgt, 0, 60)
--log("ccc----------------------------------------------------------")
function M.heap_dump(tbl, indent, max_dept)
    local spaces = string.rep("  ", indent)
    if max_dept == 0 then
        return
    end
    max_dept = max_dept -1
    indent = indent or 0

    for key, value in pairs(tbl) do
        if key ~= "_G" then
            if type(value) == "table" then
                M.heap_dump(value, indent + 1, max_dept)
            else
            end
        end
    end
end
------------------------------------------------------------------------------------------------------

return M
