--- ${title}

---@author ${author}
---@version r_version_r
---@date 29/01/2021

GeologistAnalysisEvent = {}
local GeologistAnalysisEvent_mt = Class(GeologistAnalysisEvent, Event)

InitEventClass(GeologistAnalysisEvent, "GeologistAnalysisEvent")

function GeologistAnalysisEvent:emptyNew()
    local e = Event:new(GeologistAnalysisEvent_mt)
    return e
end

function GeologistAnalysisEvent:new(farmlandId)
    local e = GeologistAnalysisEvent:emptyNew()
    e.farmlandId = farmlandId
    return e
end

function GeologistAnalysisEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, self.farmlandId)
end

function GeologistAnalysisEvent:readStream(streamId, connection)
    self.farmlandId = streamReadInt32(streamId)
    self:run(connection)
end

function GeologistAnalysisEvent:run(connection)
    GeologistModule:analyseFarmland(self.farmlandId)
end

function GeologistAnalysisEvent.sendEvent(farmlandId)
    g_client:getServerConnection():sendEvent(GeologistAnalysisEvent:new(farmlandId))
end
