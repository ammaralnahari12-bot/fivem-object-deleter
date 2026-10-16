-- Object Deleter client
-- Scans nearby objects and deletes those that match configured models.
-- Commands:
--   /delobjs [radius]  - deletes all matching objects within radius (default from config)
--   /delobj            - deletes the nearest matching object within default radius
-- Optional: enable auto-scan in config.lua

local modelHashes = {}

-- Convert model names in Config.models to hashes, and include numeric hashes directly.
Citizen.CreateThread(function()
    for _, v in ipairs(Config.models) do
        if type(v) == "string" then
            modelHashes[GetHashKey(v)] = true
        elseif type(v) == "number" then
            modelHashes[v] = true
        end
    end
end)

-- Enumerator for objects (efficient-ish)
local function EnumerateObjects()
    return coroutine.wrap(function()
        local handle, obj = FindFirstObject()
        local success
        repeat
            coroutine.yield(obj)
            success, obj = FindNextObject(handle)
        until not success
        EndFindObject(handle)
    end)
end

local function notify(text)
    -- Chat message if chat resource available, otherwise fallback to simple notification
    if GetResourceState('chat') == 'started' then
        TriggerEvent('chat:addMessage', { args = { '^1[ObjDeleter]^0', text } })
    else
        SetNotificationTextEntry('STRING')
        AddTextComponentString('[ObjDeleter] '..text)
        DrawNotification(false, false)
    end
end

local function requestControl(entity, timeout)
    timeout = timeout or 1000
    if not DoesEntityExist(entity) then return false end
    NetworkRequestControlOfEntity(entity)
    local t = 0
    while not NetworkHasControlOfEntity(entity) and t < timeout do
        NetworkRequestControlOfEntity(entity)
        t = t + 1
        Citizen.Wait(1)
    end
    return NetworkHasControlOfEntity(entity)
end

local function safeDeleteEntity(entity)
    if not DoesEntityExist(entity) then return false end
    -- Try to request control then delete
    pcall(function()
        SetEntityAsMissionEntity(entity, true, true)
    end)
    requestControl(entity, 500)
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
        DeleteObject(entity)
        SetEntityAsNoLongerNeeded(entity)
    end
    return not DoesEntityExist(entity)
end

-- Delete all matching objects within radius around player's coords
local function deleteMatchingInRadius(radius)
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)
    local deleted = 0
    for obj in EnumerateObjects() do
        if DoesEntityExist(obj) then
            local m = GetEntityModel(obj)
            local ox, oy, oz = table.unpack(GetEntityCoords(obj))
            local dist = #(vector3(ox,oy,oz) - pcoords)
            if dist <= radius and modelHashes[m] then
                if safeDeleteEntity(obj) then
                    deleted = deleted + 1
                end
            end
        end
    end
    return deleted
end

-- Find & delete nearest matching object within radius
local function deleteNearestMatching(radius)
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)
    local best = nil
    local bestDist = radius + 0.1
    for obj in EnumerateObjects() do
        if DoesEntityExist(obj) then
            local m = GetEntityModel(obj)
            if modelHashes[m] then
                local ox, oy, oz = table.unpack(GetEntityCoords(obj))
                local dist = #(vector3(ox,oy,oz) - pcoords)
                if dist < bestDist then
                    bestDist = dist
                    best = obj
                end
            end
        end
    end
    if best then
        if safeDeleteEntity(best) then
            return true, bestDist
        end
    end
    return false, nil
end

RegisterCommand('delobjs', function(source, args, raw)
    local radius = tonumber(args[1]) or Config.defaultRadius
    local deleted = deleteMatchingInRadius(radius)
    notify(string.format('Deleted %d matching object(s) within %.1fm', deleted, radius))
end, false)

RegisterCommand('delobj', function(source, args, raw)
    local radius = tonumber(args[1]) or Config.defaultRadius
    local ok, dist = deleteNearestMatching(radius)
    if ok then
        notify(string.format('Deleted nearest matching object (%.1fm away)', dist))
    else
        notify('No matching object found within radius.')
    end
end, false)

-- Optional auto-scan (client-side)
Citizen.CreateThread(function()
    while true do
        if Config.autoScan and next(modelHashes) ~= nil then
            local deleted = deleteMatchingInRadius(Config.defaultRadius)
            if deleted > 0 then
                notify('Auto-scan deleted '..deleted..' object(s).')
            end
            Citizen.Wait(Config.autoScanInterval)
        else
            Citizen.Wait(2000)
        end
    end
end)
