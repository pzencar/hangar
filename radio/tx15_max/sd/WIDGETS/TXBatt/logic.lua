-- The widget table will be returned to the main script.
local wgt = {
    options = nil,
    zone = nil,
    counter = 0,
    text_color = 0,
    isDataAvailable = 0,
    vMax = 0,
    vMin = 99,
    vTotalLive = 0,
    vPercent = 0,
    cellCount = 1,
    cell_detected = false,
    vCellLive = 0,
    mainValue = 0,
    secondaryValue = 0,
    source_name = "",
}

-- Data gathered from commercial lipo sensors
local percent_list_lipo = {
    {3.000,  0},
    {3.093,  1}, {3.196,  2}, {3.301,  3}, {3.401,  4}, {3.477,  5}, {3.544,  6}, {3.601,  7}, {3.637,  8}, {3.664,  9}, {3.679, 10},
    {3.683, 11}, {3.689, 12}, {3.692, 13}, {3.705, 14}, {3.710, 15}, {3.713, 16}, {3.715, 17}, {3.720, 18}, {3.731, 19}, {3.735, 20},
    {3.744, 21}, {3.753, 22}, {3.756, 23}, {3.758, 24}, {3.762, 25}, {3.767, 26}, {3.774, 27}, {3.780, 28}, {3.783, 29}, {3.786, 30},
    {3.789, 31}, {3.794, 32}, {3.797, 33}, {3.800, 34}, {3.802, 35}, {3.805, 36}, {3.808, 37}, {3.811, 38}, {3.815, 39}, {3.818, 40},
    {3.822, 41}, {3.825, 42}, {3.829, 43}, {3.833, 44}, {3.836, 45}, {3.840, 46}, {3.843, 47}, {3.847, 48}, {3.850, 49}, {3.854, 50},
    {3.857, 51}, {3.860, 52}, {3.863, 53}, {3.866, 54}, {3.870, 55}, {3.874, 56}, {3.879, 57}, {3.888, 58}, {3.893, 59}, {3.897, 60},
    {3.902, 61}, {3.906, 62}, {3.911, 63}, {3.918, 64}, {3.923, 65}, {3.928, 66}, {3.939, 67}, {3.943, 68}, {3.949, 69}, {3.955, 70},
    {3.961, 71}, {3.968, 72}, {3.974, 73}, {3.981, 74}, {3.987, 75}, {3.994, 76}, {4.001, 77}, {4.007, 78}, {4.014, 79}, {4.021, 80},
    {4.029, 81}, {4.036, 82}, {4.044, 83}, {4.052, 84}, {4.062, 85}, {4.074, 86}, {4.085, 87}, {4.095, 88}, {4.105, 89}, {4.111, 90},
    {4.116, 91}, {4.120, 92}, {4.125, 93}, {4.129, 94}, {4.135, 95}, {4.145, 96}, {4.176, 97}, {4.179, 98}, {4.193, 99}, {4.200,100},
}

local percent_list_hv = {
    {3.000,  0},
    {3.093,  1}, {3.196,  2}, {3.301,  3}, {3.401,  4}, {3.477,  5}, {3.544,  6}, {3.601,  7}, {3.637,  8}, {3.664,  9}, {3.679, 10},
    {3.683, 11}, {3.689, 12}, {3.692, 13}, {3.705, 14}, {3.710, 15}, {3.713, 16}, {3.715, 17}, {3.720, 18}, {3.731, 19}, {3.735, 20},
    {3.744, 21}, {3.753, 22}, {3.756, 23}, {3.758, 24}, {3.762, 25}, {3.767, 26}, {3.774, 27}, {3.780, 28}, {3.783, 29}, {3.786, 30},
    {3.789, 31}, {3.794, 32}, {3.797, 33}, {3.800, 34}, {3.802, 35}, {3.805, 36}, {3.808, 37}, {3.811, 38}, {3.815, 39}, {3.828, 40},
    {3.832, 41}, {3.836, 42}, {3.841, 43}, {3.846, 44}, {3.850, 45}, {3.855, 46}, {3.859, 47}, {3.864, 48}, {3.868, 49}, {3.873, 50},
    {3.877, 51}, {3.881, 52}, {3.885, 53}, {3.890, 54}, {3.895, 55}, {3.900, 56}, {3.907, 57}, {3.917, 58}, {3.924, 59}, {3.929, 60},
    {3.936, 61}, {3.942, 62}, {3.949, 63}, {3.957, 64}, {3.964, 65}, {3.971, 66}, {3.984, 67}, {3.990, 68}, {3.998, 69}, {4.006, 70},
    {4.015, 71}, {4.024, 72}, {4.032, 73}, {4.042, 74}, {4.050, 75}, {4.060, 76}, {4.069, 77}, {4.078, 78}, {4.088, 79}, {4.098, 80},
    {4.109, 81}, {4.119, 82}, {4.130, 83}, {4.141, 84}, {4.154, 85}, {4.169, 86}, {4.184, 87}, {4.197, 88}, {4.211, 89}, {4.220, 90},
    {4.229, 91}, {4.237, 92}, {4.246, 93}, {4.254, 94}, {4.264, 95}, {4.278, 96}, {4.302, 97}, {4.320, 98}, {4.339, 99}, {4.350,100},
}


-- from: https://electric-scooter.guide/guides/electric-scooter-battery-voltage-chart/
local percent_list_lion = {
    { 2.800,  0 + 5 }, { 2.840,  1 + 5 }, { 2.880,  2 + 5 }, { 2.920,  3 + 5 }, { 2.960,  4 + 5 },
    { 3.000,  5 + 5 }, { 3.040,  6 + 5 }, { 3.080,  7 + 5 }, { 3.096,  8 + 5 }, { 3.112,  9 + 5 },
    { 3.128, 10 + 5 }, { 3.144, 11 + 5 }, { 3.160, 12 + 5 }, { 3.176, 13 + 5 }, { 3.192, 14 + 5 },
    { 3.208, 15 + 5 }, { 3.224, 16 + 5 }, { 3.240, 17 + 5 }, { 3.256, 18 + 5 }, { 3.272, 19 + 5 },
    { 3.288, 20 + 5 }, { 3.304, 21 + 5 }, { 3.320, 22 + 5 }, { 3.336, 23 + 5 }, { 3.352, 24 + 5 },
    { 3.368, 25 + 5 }, { 3.384, 26 + 5 }, { 3.400, 27 + 5 }, { 3.416, 28 + 5 }, { 3.432, 29 + 5 },
    { 3.448, 30 + 5 }, { 3.464, 31 + 5 }, { 3.480, 32 + 5 }, { 3.496, 33 + 5 }, { 3.504, 34 + 5 },
    { 3.512, 35 + 5 }, { 3.520, 36 + 5 }, { 3.528, 37 + 5 }, { 3.536, 38 + 5 }, { 3.544, 39 + 5 },
    { 3.552, 40 + 5 }, { 3.560, 41 + 5 }, { 3.568, 42 + 5 }, { 3.576, 43 + 5 }, { 3.584, 44 + 5 },
    { 3.592, 45 + 5 }, { 3.600, 46 + 5 }, { 3.608, 47 + 5 }, { 3.616, 48 + 5 }, { 3.624, 49 + 5 },
    { 3.632, 50 + 5 }, { 3.640, 51 + 5 }, { 3.648, 52 + 5 }, { 3.656, 53 + 5 }, { 3.664, 54 + 5 },
    { 3.672, 55 + 5 }, { 3.680, 56 + 5 }, { 3.688, 57 + 5 }, { 3.696, 58 + 5 }, { 3.704, 59 + 5 },
    { 3.712, 60 + 5 }, { 3.720, 61 + 5 }, { 3.728, 62 + 5 }, { 3.736, 63 + 5 }, { 3.744, 64 + 5 },
    { 3.752, 65 + 5 }, { 3.760, 66 + 5 }, { 3.768, 67 + 5 }, { 3.776, 68 + 5 }, { 3.784, 69 + 5 },
    { 3.792, 70 + 5 }, { 3.800, 71 + 5 }, { 3.810, 72 + 5 }, { 3.820, 73 + 5 }, { 3.830, 74 + 5 },
    { 3.840, 75 + 5 }, { 3.850, 76 + 5 }, { 3.860, 77 + 5 }, { 3.870, 78 + 5 }, { 3.880, 79 + 5 },
    { 3.890, 80 + 5 }, { 3.900, 81 + 5 }, { 3.910, 82 + 5 }, { 3.920, 83 + 5 }, { 3.930, 84 + 5 },
    { 3.940, 85 + 5 }, { 3.950, 86 + 5 }, { 3.960, 87 + 5 }, { 3.970, 88 + 5 }, { 3.980, 89 + 5 },
    { 3.990, 90 + 5 }, { 4.000, 91 + 5 }, { 4.010, 92 + 5 }, { 4.030, 93 + 5 }, { 4.050, 94 + 5 },
    { 4.070, 95 + 5 }, { 4.090, 96 + 5 }, { 4.10, 100 + 5 }, { 4.15 ,100 + 5 }, { 4.20, 100},
}

local percent_list_life_po4 = {
    {2.500,  0},
    {2.509,  1}, {2.518,  2}, {2.527,  3}, {2.536,  4}, {2.545,  5}, {2.554,  6}, {2.563,  7}, {2.572,  8}, {2.581,  9}, {2.590, 10},
    {2.599, 11}, {2.608, 12}, {2.617, 13}, {2.626, 14}, {2.635, 15}, {2.644, 16}, {2.653, 17}, {2.662, 18}, {2.671, 19}, {2.680, 20},
    {2.689, 21}, {2.698, 22}, {2.707, 23}, {2.716, 24}, {2.725, 25}, {2.734, 26}, {2.743, 27}, {2.752, 28}, {2.761, 29}, {2.770, 30},
    {2.779, 31}, {2.788, 32}, {2.797, 33}, {2.806, 34}, {2.815, 35}, {2.824, 36}, {2.833, 37}, {2.842, 38}, {2.851, 39}, {2.860, 40},
    {2.869, 41}, {2.878, 42}, {2.887, 43}, {2.896, 44}, {2.905, 45}, {2.914, 46}, {2.923, 47}, {2.932, 48}, {2.941, 49}, {2.950, 50},
    {2.959, 51}, {2.968, 52}, {2.977, 53}, {2.986, 54}, {2.995, 55}, {3.004, 56}, {3.013, 57}, {3.022, 58}, {3.031, 59}, {3.040, 60},
    {3.049, 61}, {3.058, 62}, {3.067, 63}, {3.076, 64}, {3.085, 65}, {3.094, 66}, {3.103, 67}, {3.112, 68}, {3.121, 69}, {3.130, 70},
    {3.139, 71}, {3.148, 72}, {3.157, 73}, {3.166, 74}, {3.175, 75}, {3.184, 76}, {3.193, 77}, {3.202, 78}, {3.211, 79}, {3.220, 80},
    {3.229, 81}, {3.238, 82}, {3.247, 83}, {3.256, 84}, {3.265, 85}, {3.274, 86}, {3.283, 87}, {3.292, 88}, {3.301, 89}, {3.310, 90},
    {3.319, 91}, {3.328, 92}, {3.337, 93}, {3.346, 94}, {3.355, 95}, {3.364, 96}, {3.373, 97}, {3.382, 98}, {3.391, 99}, {3.400,100},
}

--- This function return the percentage remaining in a single Lipo cel
function wgt.getCellPercent(cellValue)
    if cellValue == nil then
        return 0
    end

    local _percentList = percent_list_lipo
    if wgt.options.batt_type == 1 then
        _percentList = percent_list_lipo
    elseif wgt.options.batt_type == 2 then
        _percentList = percent_list_hv
    elseif wgt.options.batt_type == 3 then
        _percentList = percent_list_lion
    elseif wgt.options.batt_type == 4 then
        _percentList = percent_list_life_po4
    end

    -- if voltage too low, return 0%
    if cellValue <= _percentList[1][1] then
        return 0
    end

    -- if voltage too high, return 100%
    if cellValue >= _percentList[#_percentList][1] then
        return 100
    end

    -- binary search
    local l = 1
    local u = #_percentList
    while true do
        local n = (u + l) // 2
        if cellValue >= _percentList[n][1] and cellValue <= _percentList[n+1][1] then
            -- return closest value
            if cellValue < (_percentList[n][1] + _percentList[n + 1][1]) / 2 then
                return _percentList[n][2]
            else
                return _percentList[n+1][2]
            end
        end
        if cellValue < _percentList[n][1] then
            u = n
        else
            l = n
        end
    end

    return 0
end

--- This function returns a table with cels values
function wgt.calculateBatteryData()
    local v = getValue("tx-voltage")

    if type(v) == "table" and #v > 0 then
        -- multi cell values using FLVSS liPo Voltage Sensor
        local sum = 0

        for i = 1, #v do
            sum = sum + v[i]
        end

        wgt.vTotalLive = sum
        wgt.vCellLive = sum / #v
    elseif v ~= nil and v >= 1 then
        wgt.vTotalLive = v
        wgt.vCellLive = wgt.vTotalLive / 2
    else
        -- no telemetry available
        wgt.isDataAvailable = false
        return
    end

    wgt.vPercent = wgt.getCellPercent(wgt.vCellLive)

    -- mainValue
    if wgt.options.isTotalVoltage == 0 then
        wgt.mainValue = wgt.vCellLive
    elseif wgt.options.isTotalVoltage == 1 then
        wgt.mainValue = wgt.vTotalLive
    else
        wgt.mainValue = "-1"
    end

    wgt.isDataAvailable = true
end

-- color for battery
-- This function returns green at 100%, red bellow 30% and graduate in between
function wgt.getPercentColor(percent)
    if percent < 30 then
        return lcd.RGB(0xff, 0, 0)
    else
        g = math.floor(0xdf * percent / 100)
        r = 0xdf - g
        return lcd.RGB(r, g, 0)
    end
end

-- color for cell
-- This function returns green at gvalue, red at rvalue and graduate in between
function wgt.getRangeColor(value, green_value, red_value)
    local range = math.abs(green_value - red_value)
    if range == 0 then
        return lcd.RGB(0, 0xdf, 0)
    end
    if value == nil then
        return lcd.RGB(0, 0xdf, 0)
    end

    if green_value > red_value then
        if value > green_value then
            return lcd.RGB(0, 0xdf, 0)
        end
        if value < red_value then
            return lcd.RGB(0xdf, 0, 0)
        end
        g = math.floor(0xdf * (value - red_value) / range)
        r = 0xdf - g
        return lcd.RGB(r, g, 0)
    else
        if value > green_value then
            return lcd.RGB(0, 0xdf, 0)
        end
        if value < red_value then
            return lcd.RGB(0xdf, 0, 0)
        end
        r = math.floor(0xdf * (value - green_value) / range)
        g = 0xdf - r
        return lcd.RGB(r, g, 0)
    end
end

function wgt.background()
    wgt.calculateBatteryData()
end

return wgt
