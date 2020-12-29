--
-- ${title}
--
-- @author ${author}
-- @version ${version}
-- @date 29/12/2020

MpConsoleCommandsModule = {}

function MpConsoleCommandsModule:load(moduleName, mod, baseDirectory)
    self.moduleName = moduleName
    self.mod = mod
    self.baseDirectory = baseDirectory
    source(Utils.getFilename("events/mpConsoleCommandsEvent.lua", self.baseDirectory))
    if g_precisionFarming.soilMap ~= nil then
        -- "overwrite" debugUncoverField
        if g_precisionFarming.soilMap.debugUncoverField ~= nil then
            self.originalDebugUncoverField = g_precisionFarming.soilMap.debugUncoverField
            g_precisionFarming.soilMap.debugUncoverField = self.debugUncoverField
        else
            g_logManager:devError("[%s] Cant't find 'soilMap.debugUncoverField' in g_precisionFarming", self.mod.name)
        end

        -- "overwrite" debugUncoverAll
        if g_precisionFarming.soilMap.debugUncoverAll ~= nil then
            self.originalDebugUncoverAll = g_precisionFarming.soilMap.debugUncoverAll
            g_precisionFarming.soilMap.debugUncoverAll = self.debugUncoverAll
        else
            g_logManager:devError("[%s] Cant't find 'soilMap.debugUncoverAll' in g_precisionFarming", self.mod.name)
        end

        -- "overwrite" debugReduceCoverStateField
        if g_precisionFarming.soilMap.debugReduceCoverStateField ~= nil then
            self.originalDebugReduceCoverStateField = g_precisionFarming.soilMap.debugReduceCoverStateField
            g_precisionFarming.soilMap.debugReduceCoverStateField = self.debugReduceCoverStateField
        else
            g_logManager:devError("[%s] Cant't find 'soilMap.debugReduceCoverStateField' in g_precisionFarming", self.mod.name)
        end

        -- "overwrite" debugReduceCoverStateAll
        if g_precisionFarming.soilMap.debugReduceCoverStateAll ~= nil then
            self.originalDebugReduceCoverStateAll = g_precisionFarming.soilMap.debugReduceCoverStateAll
            g_precisionFarming.soilMap.debugReduceCoverStateAll = self.debugReduceCoverStateAll
        else
            g_logManager:devError("[%s] Cant't find 'soilMap.debugReduceCoverStateAll' in g_precisionFarming", self.mod.name)
        end
    else
        g_logManager:devError("[%s] Cant't find 'soilMap' instance in g_precisionFarming", self.mod.name)
    end
end

function MpConsoleCommandsModule.debugUncoverField(soilMap, fieldIndex)
    if fieldIndex ~= nil and fieldIndex ~= "" then
        fieldIndex = tonumber(fieldIndex)
        if fieldIndex ~= nil and type(fieldIndex) == "number" then
            local field = g_fieldManager:getFieldByIndex(fieldIndex)
            if field ~= nil and field.fieldDimensions ~= nil then
                MpConsoleCommandsEvent.sendEvent(MpConsoleCommandsEvent.paUncoverField, fieldIndex)
            else
                g_logManager:error("The (field) parameter must be a valid field index")
            end
        else
            g_logManager:error("The (field) parameter must be a number")
        end
    else
        g_logManager:warning("Usage paUncoverField (field)")
    end
end

function MpConsoleCommandsModule:uncoverField(fieldIndex)
    self.originalDebugUncoverField(g_precisionFarming.soilMap, fieldIndex)
end

function MpConsoleCommandsModule:debugUncoverAll()
    MpConsoleCommandsEvent.sendEvent(MpConsoleCommandsEvent.paUncoverAll)
end

function MpConsoleCommandsModule:uncoverAll()
    for i = 1, #g_fieldManager.fields do
        self:uncoverField(i)
    end
end

function MpConsoleCommandsModule.debugReduceCoverStateField(soilMap, fieldIndex)
    if fieldIndex ~= nil and fieldIndex ~= "" then
        fieldIndex = tonumber(fieldIndex)
        if fieldIndex ~= nil and type(fieldIndex) == "number" then
            local field = g_fieldManager:getFieldByIndex(fieldIndex)
            if field ~= nil and field.fieldDimensions ~= nil then
                MpConsoleCommandsEvent.sendEvent(MpConsoleCommandsEvent.paReduceCoverState, fieldIndex)
            else
                g_logManager:error("The (field) parameter must be a valid field index")
            end
        else
            g_logManager:error("The (field) parameter must be a number")
        end
    else
        g_logManager:warning("Usage paReduceCoverState (field)")
    end
end

function MpConsoleCommandsModule:reduceCoverStateField(fieldIndex)
    self.originalDebugReduceCoverStateField(g_precisionFarming.soilMap, fieldIndex)
end

function MpConsoleCommandsModule:debugReduceCoverStateAll()
    MpConsoleCommandsEvent.sendEvent(MpConsoleCommandsEvent.paReduceCoverStateAll)
end

function MpConsoleCommandsModule:reduceCoverStateAll()
    for i = 1, #g_fieldManager.fields do
        self:reduceCoverStateField(i)
    end
end
