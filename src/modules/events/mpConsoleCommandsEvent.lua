--- ${title}

---@author ${author}
---@version r_version_r
---@date 29/12/2020

MpConsoleCommandsEvent = {}
MpConsoleCommandsEvent.paUncoverField = 1
MpConsoleCommandsEvent.paUncoverAll = 2
MpConsoleCommandsEvent.paReduceCoverState = 3
MpConsoleCommandsEvent.paReduceCoverStateAll = 4

local MpConsoleCommandsEvent_mt = Class(MpConsoleCommandsEvent, Event)

InitEventClass(MpConsoleCommandsEvent, "MpConsoleCommandsEvent")

function MpConsoleCommandsEvent:emptyNew()
    local e = Event:new(MpConsoleCommandsEvent_mt)
    return e
end

function MpConsoleCommandsEvent:new(command, param)
    local e = MpConsoleCommandsEvent:emptyNew()
    e.command = command
    e.param = param or 0
    return e
end

function MpConsoleCommandsEvent:writeStream(streamId, _)
    streamWriteInt32(streamId, self.command)
    streamWriteInt32(streamId, self.param)
end

function MpConsoleCommandsEvent:readStream(streamId, connection)
    self.command = streamReadInt32(streamId)
    self.param = streamReadInt32(streamId)
    self:run(connection)
end

---@param connection any
function MpConsoleCommandsEvent:run(connection)
    if not connection:getIsServer() then
        if self.command == MpConsoleCommandsEvent.paUncoverField then
            MpConsoleCommandsModule:uncoverField(self.param)
        end
        if self.command == MpConsoleCommandsEvent.paUncoverAll then
            MpConsoleCommandsModule:uncoverAll()
        end
        if self.command == MpConsoleCommandsEvent.paReduceCoverState then
            MpConsoleCommandsModule:reduceCoverStateField(self.param)
        end
        if self.command == MpConsoleCommandsEvent.paReduceCoverStateAll then
            MpConsoleCommandsModule:reduceCoverStateAll()
        end
    end
end

function MpConsoleCommandsEvent.sendEvent(command, param)
    g_client:getServerConnection():sendEvent(MpConsoleCommandsEvent:new(command, param))
end
