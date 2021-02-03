--- ${title}

---@author ${author}
---@version r_version_r
---@date 29/12/2020

ResetFarmlandConsoleCommandEvent = {}
local ResetFarmlandConsoleCommandEvent_mt = Class(ResetFarmlandConsoleCommandEvent, Event)

InitEventClass(ResetFarmlandConsoleCommandEvent, "ResetFarmlandConsoleCommandEvent")

function ResetFarmlandConsoleCommandEvent:emptyNew()
    local e = Event:new(ResetFarmlandConsoleCommandEvent_mt)
    return e
end

function ResetFarmlandConsoleCommandEvent:new(farmlandIndex)
    local e = ResetFarmlandConsoleCommandEvent:emptyNew()
    e.farmlandIndex = farmlandIndex
    return e
end

function ResetFarmlandConsoleCommandEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, self.farmlandIndex)
end

function ResetFarmlandConsoleCommandEvent:readStream(streamId, connection)
    self.farmlandIndex = streamReadInt32(streamId)
    self:run(connection)
end

function ResetFarmlandConsoleCommandEvent:run(connection)
    g_precisionFarming.soilMap:onFarmlandStateChanged(self.farmlandIndex, FarmlandManager.NO_OWNER_FARM_ID)
end

function ResetFarmlandConsoleCommandEvent.sendEvent(farmlandIndex)
    g_client:getServerConnection():sendEvent(ResetFarmlandConsoleCommandEvent:new(farmlandIndex))
end
