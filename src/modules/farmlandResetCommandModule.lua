--- ${title}

---@author ${author}
---@version r_version_r
---@date 29/12/2020

FarmlandResetCommandModule = {}

function FarmlandResetCommandModule:load(moduleName, mod, baseDirectory)
    self.moduleName = moduleName
    self.mod = mod
    self.baseDirectory = baseDirectory
    source(Utils.getFilename("events/resetFarmlandConsoleCommandEvent.lua", self.baseDirectory))
    addConsoleCommand("paResetFarmland", "Reset farmland data", "debugResetFarmland", self)
end

function FarmlandResetCommandModule:debugResetFarmland(farmlandIndex)
    if farmlandIndex ~= nil and farmlandIndex ~= "" then
        farmlandIndex = tonumber(farmlandIndex)
        if farmlandIndex ~= nil and type(farmlandIndex) == "number" then
            if g_farmlandManager.farmlands[farmlandIndex] ~= nil then
                ResetFarmlandConsoleCommandEvent.sendEvent(farmlandIndex)
            else
                g_logManager:error("The (farmland) parameter must be a valid farmland index")
            end
        else
            g_logManager:error("The (farmland) parameter must be a number")
        end
    else
        g_logManager:warning("Usage paResetFarmland (farmland)")
    end
end
