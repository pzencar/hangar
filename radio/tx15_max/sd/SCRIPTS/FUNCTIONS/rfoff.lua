local function run()
    local module = model.getModule(0)

    if module then
        module.firstChannel = 0
        module.subType = 0
        module.modelId = 0
        module.Type = 0
        module.channelsCount = 8
        model.setModule(0, module)
    end
end

return { run=run }
