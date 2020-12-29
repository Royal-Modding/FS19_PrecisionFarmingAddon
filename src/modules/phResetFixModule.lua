--
-- ${title}
--
-- @author ${author}
-- @version ${version}
-- @date 29/12/2020

PhResetFixModule = {}

function PhResetFixModule:load(moduleName, mod, baseDirectory)
    self.moduleName = moduleName
    self.mod = mod
    self.baseDirectory = baseDirectory
    --DebugUtil.printTableRecursively(g_precisionFarming, nil, nil, 1)
    if g_precisionFarming.pHMap ~= nil and g_precisionFarming.pHMap.setInitialState ~= nil then
        self.originalSetInitialState = g_precisionFarming.pHMap.setInitialState
        g_precisionFarming.pHMap.setInitialState = self.setInitialState
    else
        g_logManager:devError("[%s] Cant't find 'pHMap' instance in g_precisionFarming", self.mod.name)
    end
end

function PhResetFixModule.setInitialState(phMap, soilBitVector, soilTypeFirstChannel, soilTypeNumChannels, coverChannel, farmlandMask)
    local self = PhResetFixModule
    --print(string.format("PhResetFixModule.setInitialState(%s, %s, %s, %s, %s, %s)", phMap, soilBitVector, soilTypeFirstChannel, soilTypeNumChannels, coverChannel, farmlandMask))
    self.originalSetInitialState(phMap, soilBitVector, soilTypeFirstChannel, soilTypeNumChannels, coverChannel, nil, farmlandMask)
end
