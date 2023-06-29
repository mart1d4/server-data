local function freezePlayer(id, freeze)
    local player = id
    SetPlayerControl(player, not freeze, false)

    local ped = GetPlayerPed(player)

    if not freeze then
        if not IsEntityVisible(ped) then
            SetEntityVisible(ped, true)
        end

        if not IsPedInAnyVehicle(ped) then
            SetEntityCollision(ped, true)
        end

        FreezeEntityPosition(ped, false)
        SetPlayerInvincible(player, false)
    else
        if IsEntityVisible(ped) then
            SetEntityVisible(ped, false)
        end

        SetEntityCollision(ped, false)
        FreezeEntityPosition(ped, true)
        SetPlayerInvincible(player, true)

        if not IsPedFatallyInjured(ped) then
            ClearPedTasksImmediately(ped)
        end
    end
end

local spawnLock = false

function spawnPlayer(spawn, cb)
    if spawnLock then
        return
    end

    spawnLock = true

    CreateThread(function()
        if not spawn.skipFade then
            DoScreenFadeOut(500)

            while not IsScreenFadedOut() do
                Wait(0)
            end
        end

        freezePlayer(PlayerId(), true)

        if spawn.model then
            RequestModel(spawn.model)

            while not HasModelLoaded(spawn.model) do
                RequestModel(spawn.model)
                Wait(0)
            end

            SetPlayerModel(PlayerId(), spawn.model)
            SetModelAsNoLongerNeeded(spawn.model)
        end

        RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)

        local ped = PlayerPedId()

        SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)
        NetworkResurrectLocalPlayer(spawn.x, spawn.y, spawn.z, spawn.heading, true, true, false)

        ClearPedTasksImmediately(ped)
        ClearPlayerWantedLevel(PlayerId())

        local time = GetGameTimer()

        while (not HasCollisionLoadedAroundEntity(ped) and (GetGameTimer() - time) < 5000) do
            Wait(0)
        end
        
        ShutdownLoadingScreen()

        if IsScreenFadedOut() then
            DoScreenFadeIn(500)

            while not IsScreenFadedIn() do
                Wait(0)
            end
        end

        SetEntityVisible(PlayerPedId(), true, 0)
        freezePlayer(PlayerId(), false)
        spawnLock = false

        if cb then
            cb()
        end

        TriggerEvent('playerSpawned', spawn)
    end)
end

exports('spawnPlayer', spawnPlayer)
