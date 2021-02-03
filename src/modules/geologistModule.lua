--- ${title}

---@author ${author}
---@version r_version_r
---@date 27/01/2021

GeologistModule = {}

function GeologistModule:load(moduleName, mod, baseDirectory)
    self.moduleName = moduleName
    self.mod = mod
    self.baseDirectory = baseDirectory
    source(Utils.getFilename("events/geologistAnalysisEvent.lua", self.baseDirectory))
    if g_precisionFarming.yieldMap ~= nil then
        if g_precisionFarming.yieldMap.getIsResetButtonActive ~= nil then
            self.originalGetIsResetButtonActive = g_precisionFarming.yieldMap.getIsResetButtonActive
            g_precisionFarming.yieldMap.getIsResetButtonActive = self.getIsResetButtonActive
        end
        if g_precisionFarming.yieldMap.onValueMapSelectionChanged ~= nil then
            self.originalOnValueMapSelectionChanged = g_precisionFarming.yieldMap.onValueMapSelectionChanged
            g_precisionFarming.yieldMap.onValueMapSelectionChanged = self.onValueMapSelectionChanged
        end
        if g_precisionFarming.yieldMap.updateResetButton ~= nil then
            self.originalUpdateResetButton = g_precisionFarming.yieldMap.updateResetButton
            g_precisionFarming.yieldMap.updateResetButton = self.updateResetButton
        end
        if g_precisionFarming.yieldMap.onClickButtonResetYield ~= nil then
            self.originalOnClickButtonResetYield = g_precisionFarming.yieldMap.onClickButtonResetYield
            g_precisionFarming.yieldMap.onClickButtonResetYield = self.onClickButtonResetYield
        end
    else
        g_logManager:devError("[%s] Cant't find 'yieldMap' instance in g_precisionFarming", self.mod.name)
    end
    self.soilMapSelected = false
    self.iconX, self.iconY = nil, nil
    self.samplePerHectare = 10
    self.basePrice = {1000, 2000, 4000}
    self.pricePerHectare = {250, 500, 750}
    self.moneyChangeType = MoneyType.getMoneyType("other", "info_pfa_geologistSoilAnalysis")
end

function GeologistModule.getIsResetButtonActive(yieldMap)
    local self = GeologistModule
    return self.originalGetIsResetButtonActive(yieldMap) or self:getIsGeologistButtonActive(yieldMap)
end

function GeologistModule.onValueMapSelectionChanged(yieldMap, valueMap)
    local self = GeologistModule
    self.soilMapSelected = valueMap == g_precisionFarming.soilMap
    self.originalOnValueMapSelectionChanged(yieldMap, valueMap)
end

function GeologistModule.updateResetButton(yieldMap)
    local self = GeologistModule
    self.originalUpdateResetButton(yieldMap)
    local mapFrame = yieldMap.mapFrame
    if self:getIsGeologistButtonActive(yieldMap) then
        local text = g_i18n:getText("ui_pfa_geologistAdditionalField")
        if yieldMap.selectedField ~= nil and yieldMap.selectedField ~= 0 then
            text = string.format(g_i18n:getText("ui_pfa_geologist"), yieldMap.selectedField)
        end
        mapFrame.resetYieldButton:setText(text)
        -- save original icon size
        if self.iconX == nil or self.iconY == nil then
            self.iconX, self.iconY = mapFrame.resetYieldButton:getIconSize()
        end
        mapFrame.resetYieldButton:setIconSize(0, 0)
    else
        if self.iconX ~= nil and self.iconY ~= nil then
            mapFrame.resetYieldButton:setIconSize(self.iconX, self.iconY)
        end
    end
end

function GeologistModule.onClickButtonResetYield(yieldMap)
    local self = GeologistModule
    if self:getIsGeologistButtonActive(yieldMap) then
        local farmlandId = yieldMap.selectedFarmland
        if farmlandId ~= nil then
            local farmland = g_farmlandManager:getFarmlandById(farmlandId)
            if farmland ~= nil then
                local totalFieldArea = farmland.totalFieldArea
                local neededSamples = math.ceil(totalFieldArea * self.samplePerHectare)
                local economicDifficulty = g_currentMission.missionInfo.economicDifficulty
                local basePriceToPay = math.ceil(self.basePrice[economicDifficulty])
                local pricePerHectareToPay = math.ceil(totalFieldArea * self.pricePerHectare[economicDifficulty])
                self.farmlandToAnalyseId = farmlandId
                g_gui:showYesNoDialog(
                    {
                        text = g_i18n:getText("pfa_geologistDialogText"):format(
                            g_i18n:formatMoney(basePriceToPay),
                            g_i18n:formatMoney(pricePerHectareToPay),
                            g_i18n:formatMoney(neededSamples * g_precisionFarming.soilMap.pricePerSample[economicDifficulty])
                        ),
                        title = g_i18n:getText("pfa_geologistDialogTitle"),
                        callback = self.analyseFarmlandDialogCallback,
                        target = self,
                        yesText = g_i18n:getText("pfa_geologistDialogYesButton")
                    }
                )
            end
        end
        return true
    else
        return self.originalOnClickButtonResetYield(yieldMap)
    end
end

function GeologistModule:getIsGeologistButtonActive(yieldMap)
    return (yieldMap.selectedFarmland ~= nil and yieldMap.selectedFieldArea ~= nil and yieldMap.selectedFieldArea > 0) and self.soilMapSelected and yieldMap.selectedField ~= nil and yieldMap.selectedField ~= 0
end

function GeologistModule:getFarmlandFields(farmlandId)
    local fields = {}
    local allFields = g_fieldManager:getFields()
    if allFields ~= nil then
        for _, field in pairs(allFields) do
            if field.farmland ~= nil then
                if field.farmland.id == farmlandId then
                    table.insert(fields, field)
                end
            end
        end
    end
    return fields
end

function GeologistModule:analyseFarmland(farmlandId)
    local farmland = g_farmlandManager:getFarmlandById(farmlandId)
    local totalFieldArea = farmland.totalFieldArea
    local fields = self:getFarmlandFields(farmlandId)
    local farmId = g_farmlandManager:getFarmlandOwner(farmlandId)
    local neededSamples = math.ceil(totalFieldArea * self.samplePerHectare)
    for _, field in ipairs(fields) do
        if field.fieldDimensions ~= nil then
            local numDimensions = getNumOfChildren(field.fieldDimensions)
            for i = 1, numDimensions do
                local startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ = g_precisionFarming.soilMap:getCoordsFromFieldDimensions(field.fieldDimensions, i - 1)
                g_precisionFarming.soilMap:analyseArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, nil, farmId)
            end
        end
    end
    local economicDifficulty = g_currentMission.missionInfo.economicDifficulty
    local basePriceToPay = math.ceil(self.basePrice[economicDifficulty])
    local pricePerHectareToPay = math.ceil(totalFieldArea * self.pricePerHectare[economicDifficulty])
    g_currentMission:addMoney(-(basePriceToPay + pricePerHectareToPay), farmId, self.moneyChangeType, true, true)
    g_precisionFarming.farmlandStatistics:updateStatistic(farmlandId, "numSoilSamples", neededSamples)
    g_precisionFarming.soilMap:analyseSoilSamples(farmId, neededSamples)
    g_precisionFarming:updatePrecisionFarmingOverlays()
end

function GeologistModule:analyseFarmlandDialogCallback(yes)
    if yes then
        GeologistAnalysisEvent.sendEvent(self.farmlandToAnalyseId)
    end
end
