SetMapName('West Coast City')
SetGameType('Free Roam')

-- Base event when player clicks on 'Connect' button
AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
    deferrals.defer() -- Make the connection pending

    local playerId = source
    local identifier = System.GetIdentifier(playerId)

    if not System.DatabaseConnected then
        return deferrals.done(('[System] Connection to the database could not be established.'))
    end
    
    if identifier then
        if System.GetPlayerFromIdentifier(identifier) then
            return deferrals.done('[System] There was an error loading your character.\nError: same identifier ingame')
        else
            return deferrals.done()
        end
    else
        return deferrals.done('[System] There was an error loading your character.\nError: no identifier')
    end
end)

RegisterNetEvent('system:onPlayerJoined', function()
    local playerId = source

    if not System.Players[playerId] then
        onPlayerJoined(playerId)
    end

    -- Set culling distance
    local player = GetPlayerPed(playerId)
    if player then
        SetEntityDistanceCullingRadius(player, 10000.0)
    end
end)

function onPlayerJoined(playerId)
    local identifier = System.GetIdentifier(playerId)

    if identifier then
        if System.GetPlayerFromIdentifier(identifier) then
            DropPlayer(playerId, 'There was an error loading your character.\nError: same identifier ingame')
        else
            local result = MySQL.scalar.await('SELECT 1 FROM users WHERE id = ?', { identifier })
            if result then
                loadSystemPlayer(identifier, playerId, false)
            else
                createSystemPlayer(identifier, playerId)
            end
        end
    else
        DropPlayer(playerId, 'There was an error loading your character.\nError: no identifier')
    end
end

function createSystemPlayer(identifier, playerId)
    local accounts = {}
    local banking = {
        cardNumber = System.GetRandomCardNumber(),
        cardExpiration = System.GetRandomCardExpiration(),
        cardPin = nil,
        transactionHistory = {}
    }

    for name, account in pairs(Config.Accounts) do
        accounts[name] = {
            label = account.label,
            balance = Config.StartingAccountMoney[name] or 0
        }
    end

    local defaultGroup = "User"
    if System.IsPlayerAdmin(playerId) then
        defaultGroup = "Admin"
    end

    print(('[^2INFO^0] Player ^5%s^0 Has been created in the database.'):format(playerId))

    MySQL.prepare(
        'INSERT INTO `users` SET `id` = ?, `group` = ?, `position` = ?, `accounts` = ?, `banking` = ?',
        {
            identifier,
            defaultGroup,
            json.encode(Config.DefaultSpawnCoords),
            json.encode(accounts),
            json.encode(banking)
        },
        function()
            loadSystemPlayer(identifier, playerId, true)
        end
    )
end

function loadSystemPlayer(identifier, playerId, isNew)
    local result = MySQL.prepare.await(
        'SELECT * FROM users WHERE id = ?',
        { identifier }
    )

    if not result then
        return DropPlayer(playerId, 'There was an error loading your character.\nError: no database result')
    end

    local userData = {
        name = GetPlayerName(playerId),
        accounts = {},
        banking = {},
        inventory = {},
        loadout = {},
        vehicles = {},
        identity = {},
        carryWeight = 0,
        job = {},
    }

    local job, grade = result.job, tostring(result.job_grade)

    -- Accounts
    if result.accounts and result.accounts ~= '' then
        userData.accounts = json.decode(result.accounts)
    else
        for name, account in pairs(Config.Accounts) do
            if not userData.accounts[name] then
                userData.accounts[name] = {
                    label = account.label,
                    balance = Config.StartingAccountMoney[name] or 0
                }
            end
        end
    end

    -- Banking
    if result.banking and result.banking ~= '' then
        userData.banking = json.decode(result.banking)
    else
        userData.banking = {
            cardNumber = System.GetRandomCardNumber(),
            cardExpiration = System.GetRandomCardExpiration(),
            cardPincode = nil,
            transactionHistory = {}
        }
    end

    -- Job
    jobObject, gradeObject = System.Jobs[job], System.Jobs[job].grades[grade]
    print(json.encode(jobObject) .. ' ' .. json.encode(gradeObject))

    userData.job = {
        name = job,
        grade = gradeObject.grade,
        gradeName = gradeObject.name,
        salary = gradeObject.salary,
        skinMale = gradeObject.skinMale,
        skinFemale = gradeObject.skinFemale
    }

    -- Inventory
    if result.inventory and result.inventory ~= '' then
        userData.inventory = json.decode(result.inventory)
    else
        for name, item in pairs(System.Items) do
            if item.count > 0 then
                userData.carryWeight = userData.carryWeight + (item.weight * item.count)
            end
    
            userData.inventory[name] = item
        end
    end

    -- Vehicles
    if result.vehicles and result.vehicles ~= '' then
        userData.vehicles = json.decode(result.vehicles)
    else
        userData.vehicles = {}
    end

    -- Properties
    if result.properties and result.properties ~= '' then
        userData.properties = json.decode(result.properties)
    else
        userData.properties = {}
    end

    -- Group
    userData.group = result.group or 'User'

    -- Identity
    if result.identity and result.identity ~= '' then
        userData.identity = json.decode(result.identity)
        userData.name = ('%s %s'):format(userData.identity.firstName, userData.identity.lastName)
    end

    -- Position
    userData.position = json.decode(result.position) or Config.DefaultSpawnCoords

    -- Loadout
    if result.loadout and result.loadout ~= '' then
        userData.loadout = json.decode(result.loadout)
    else
        userData.loadout = {}
    end

    local xPlayer = CreatePlayer(
        playerId,
        identifier,
        userData.name,
        userData.group,
        userData.position,
        userData.accounts,
        userData.banking,
        userData.inventory,
        userData.loadout,
        userData.identity,
        userData.vehicles,
        userData.properties,
        userData.carryWeight,
        userData.job
    )

    System.Players[playerId] = xPlayer
    System.playersByIdentifier[identifier] = xPlayer

    if result.identity and result.identity ~= '' then
        TriggerEvent('system:playerLoaded', playerId, xPlayer, isNew)
        xPlayer.triggerEvent('system:playerLoaded', playerId, xPlayer, isNew)
    else
        TriggerEvent('system:createIdentity', playerId, xPlayer, isNew)
        xPlayer.triggerEvent('system:createIdentity', playerId, xPlayer, isNew)
    end

    xPlayer.updateCoords()
    print(('[^2INFO^0] Player ^5"%s"^0 has connected to the server. ID: ^5%s^7'):format(xPlayer.name, playerId))
end

RegisterNetEvent('system:identityCreated', function(identity)
    local playerId = source
    local xPlayer = System.GetPlayerFromId(playerId)

    if xPlayer then
        xPlayer.identity = identity
        xPlayer.name = ('%s %s'):format(identity.firstName, identity.lastName)

        MySQL.update.await(
            'UPDATE users SET identity = ? WHERE id = ?',
            {
                json.encode(identity),
                xPlayer.identifier
            }
        )
    end
end)

RegisterNetEvent('system:updateVehicleState', function(plate, netId)
    local playerId = source
    local xPlayer = System.GetPlayerFromId(playerId)

    if xPlayer then
        CreateThread(function()
            local netVehicle = NetworkGetEntityFromNetworkId(netId)
            local activeVehicle = Player(playerId).state.activeVehicleNet
            local vehicles = xPlayer.vehicles
            local vehicleIndex = nil

            for i = 1, #vehicles, 1 do
                if vehicles[i].plate == plate then
                    vehicleIndex = i
                    break
                end
            end

            if not vehicleIndex then
                return
            end

            while DoesEntityExist(netVehicle) and activeVehicle == netId do
                local coords = GetEntityCoords(netVehicle)
                local heading = GetEntityHeading(netVehicle)
                local mileage = Entity(netVehicle).state.mileage
                local dirtLevel = GetVehicleDirtLevel(netVehicle)
                local engineHealth = GetVehicleEngineHealth(netVehicle)

                if vehicleIndex then
                    vehicles[vehicleIndex].position = coords
                    vehicles[vehicleIndex].heading = heading
                    vehicles[vehicleIndex].mileage = mileage
                    
                    vehicles[vehicleIndex].props.dirtLevel = dirtLevel
                    vehicles[vehicleIndex].props.engineHealth = engineHealth
                end

                xPlayer.setVehicles(vehicles)
                activeVehicle = Player(playerId).state.activeVehicleNet

                Wait(300)
            end
        end)
    end
end)

RegisterNetEvent('system:createNetVehicle', function(vehicle, makeActive, enterVehicle)
    local playerId = source
    local coords = type(vehicle.position) ~= 'vector3' and vector3(vehicle.position.x, vehicle.position.y, vehicle.position.z) or vehicle.position

    local netVehicle = CreateVehicleServerSetter(
        GetHashKey(vehicle.model),
        'automobile',
        coords,
        vehicle.heading
    )

    SetEntityDistanceCullingRadius(netVehicle, 10000.0)
    local netId = NetworkGetNetworkIdFromEntity(netVehicle)

    if makeActive then
        local activeVehicle = Player(playerId).state.activeVehicleNet

        if activeVehicle then
            local entity = NetworkGetEntityFromNetworkId(activeVehicle)

            while not DoesEntityExist(entity) do
                Wait(50)
            end

            DeleteEntity(entity)
        end

        Player(playerId).state:set('activeVehicle', vehicle.plate, true)
        Player(playerId).state:set('activeVehicleNet', netId, true)
    end

    while not DoesEntityExist(netVehicle) do Wait(50) end

    Wait(100)
    TriggerClientEvent('system:vehicleCreated', playerId, netId, vehicle, enterVehicle)
end)

-- Base event when player leaves the server
AddEventHandler('playerDropped', function(reason)
    local playerId = source
    local xPlayer = System.GetPlayerFromId(playerId)

    if xPlayer then
        TriggerEvent('system:playerDropped', playerId, reason)
        TriggerClientEvent('system:playerDropped', playerId, reason)

        System.playersByIdentifier[xPlayer.identifier] = nil
        System.SavePlayer(xPlayer, function()
            System.Players[playerId] = nil
        end)

        if Player(playerId).state.activeVehicleNet then
            -- Delete vehicle
            local vehicle = NetworkGetEntityFromNetworkId(Player(playerId).state.activeVehicleNet)
            if DoesEntityExist(vehicle) then
                DeleteEntity(vehicle)
            end
        end
    end
end)

AddEventHandler('system:playerLogout', function(playerId)
    local xPlayer = System.GetPlayerFromId(playerId)

    if xPlayer then
        TriggerEvent('system:playerDropped', playerId)

        System.playersByIdentifier[xPlayer.identifier] = nil
        System.SavePlayer(xPlayer, function()
            System.Players[playerId] = nil
        end)
    end

    TriggerClientEvent("system:onPlayerLogout", playerId)
end)

-- Base txAdin event when server has scheduled restart
AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == 60 then
        CreateThread(function()
            Wait(50000)
            System.SavePlayers()
        end)
    end
end)

-- Base txAdin event when server is shutting down
AddEventHandler('txAdmin:events:serverShuttingDown', function()
    System.SavePlayers()
end)
