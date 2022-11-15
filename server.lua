local ESX = exports.ocean_core:getSharedObject()
local jobCount = {}

local function addJob(job)
    jobCount[job.name] = (jobCount[job.name] or 0) + 1
    GlobalState[job.name] = jobCount[job.name]
end

local function playerLoaded(_, xPlayer)
    local data = {
        name = xPlayer.job.name,
        onDuty = xPlayer.job.onDuty == nil or xPlayer.job.onDuty,
    }
    ESX.Players[xPlayer.source] = data

    if data.onDuty then addJob(data) end
end

for i = 1, #ESX.Players do
    playerLoaded(_, ESX.Players[i])
end

AddEventHandler('esx:playerLoaded', playerLoaded)

local function removeJob(job)
    jobCount[job.name] = (jobCount[job.name] or 1) - 1
    GlobalState[job.name] = jobCount[job.name]
end

AddEventHandler('esx:setJob', function(playerId, job)
    local data = {
        name = job.name,
        onDuty = job.onDuty == nil or job.onDuty,
    }
    local lastJob = ESX.Players[playerId]
    ESX.Players[playerId] = data
    if job.name ~= lastJob.name then
        if data.onDuty then addJob(data) end
        if lastJob.onDuty then removeJob(lastJob) end
    end
end)

AddEventHandler('esx:playerDropped', function(playerId)
    local lastJob = ESX.Players[playerId]
    ESX.Players[playerId] = nil
    if lastJob.onDuty then removeJob(lastJob) end
end)

exports('getMembers', function(filter)
    local type = type(filter)
    local response = {}
    if type == 'string' then
        for playerId, job in pairs(ESX.Players) do
            if job.name == filter and job.onDuty then
                response[playerId] = job
            end
        end
    elseif type == 'table' then
        for playerId, job in pairs(ESX.Players) do
            local match = filter[job.name]

            if match == true and job.onDuty then
                response[playerId] = job
            elseif match == false then
                response[playerId] = job
            end
        end
    end
    return response
end)