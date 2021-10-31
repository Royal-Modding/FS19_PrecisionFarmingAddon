--- ${title}

---@author ${author}
---@version r_version_r
---@date 29/12/2020

InitRoyalMod(Utils.getFilename("rmod/", g_currentModDirectory))

---@class PrecisionFarmingAddon : RoyalMod
PrecisionFarmingAddon = RoyalMod.new(r_debug_r, false)
PrecisionFarmingAddon.precisionFarmingMod = nil
PrecisionFarmingAddon.precisionFarming = nil
PrecisionFarmingAddon.precisionFarmingName = "FS19_precisionFarming"
PrecisionFarmingAddon.modules = {
    {
        name = "farmlandResetCommand",
        filename = "farmlandResetCommandModule",
        object = "FarmlandResetCommandModule"
    },
    {
        name = "mpConsoleCommands",
        filename = "mpConsoleCommandsModule",
        object = "MpConsoleCommandsModule"
    },
    {
        name = "geologist",
        filename = "geologistModule",
        object = "GeologistModule",
        requiredVersion = "1.0.2.1"
    }
}

function PrecisionFarmingAddon:initialize()
    -- check precision farming
    local found = false

    if g_modIsLoaded[self.precisionFarmingName] then
        self.precisionFarmingMod = g_modManager:getModByName(self.precisionFarmingName)
        if self.precisionFarmingMod ~= nil then
            self.precisionFarmingName = self.precisionFarmingMod.modName
            self.precisionFarming = self.gameEnv[self.precisionFarmingName]
            if self.precisionFarming ~= nil and self.precisionFarming.g_precisionFarming ~= nil then
                g_precisionFarming = self.precisionFarming.g_precisionFarming
                found = true
            end
        end
    end

    if found then
        self.initialized = true
        local modulesDirectory = Utils.getFilename("modules/", self.directory)
        for _, m in pairs(self.modules) do
            if m.requiredVersion == nil or m.requiredVersion == self.precisionFarmingMod.version then
                source(string.format("%s%s.lua", modulesDirectory, m.filename))
                if self.modEnv[m.object] ~= nil then
                    m.object = self.modEnv[m.object]
---@diagnostic disable-next-line: undefined-field
                    if m.object.load ~= nil then
                        g_logManager:devInfo("[%s] Initializing module '%s'.", self.name, m.name)
---@diagnostic disable-next-line: undefined-field
                        m.object:load(m.name, self, modulesDirectory)
                        g_logManager:devInfo("[%s] Module '%s' initialized.", self.name, m.name)
                    else
                        g_logManager:devError("[%s] Can't find 'load' method of module '%s'.", self.name, m.name)
                    end
                else
                    g_logManager:devError("[%s] Can't find the module '%s' object (%s).", self.name, m.name, m.object)
                end
            else
                g_logManager:devError("[%s] Can't initialize module '%s', %s version is %s instead of %s.", self.name, m.name, self.precisionFarmingName, self.precisionFarmingMod.version, m.requiredVersion)
            end
        end
    else
        g_logManager:error("[%s] Can't find %s, this mod / dlc is required to allow %s to work.", self.name, self.precisionFarmingName, self.name)
    end
end

function PrecisionFarmingAddon:onValidateVehicleTypes(vehicleTypeManager, addSpecialization, addSpecializationBySpecialization, addSpecializationByVehicleType, addSpecializationByFunction)
end

function PrecisionFarmingAddon:onLoadHelpLine()
    return self.directory .. "gui/helpLine.xml"
end
