RegisterCommand('getcoord', function(source, args)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local x = playerCoords.x
    local y = playerCoords.y
    local z = playerCoords.z
    local heading = GetEntityHeading(playerPed)

    print('Coordinates: ' .. x .. ', ' .. y .. ', ' .. z .. ', ' .. heading)
end, false)

RegisterCommand('spawn', function(source, args)
    local vehicleName = args[1]

    if vehicleName == nil then
        print('You must specify a vehicle name')
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local x = playerCoords.x
    local y = playerCoords.y
    local z = playerCoords.z

    local vehicleHash = GetHashKey(vehicleName)
    if not IsModelInCdimage(vehicleHash) or not IsModelAVehicle(vehicleHash) then
        print('Invalid vehicle name')
    end

    RequestModel(vehicleHash)

    while not HasModelLoaded(vehicleHash) do
        Wait(0)
    end

    local vehicle = CreateVehicle(vehicleHash, x, y, z, GetEntityHeading(playerPed), true, false)
    SetEntityInvincible(vehicle, false)
    SetVehicleDirtLevel(vehicle, 0)
    SetVehicleOnGroundProperly(vehicle)

    SetPedIntoVehicle(playerPed, vehicle, -1)
    SetEntityAsNoLongerNeeded(vehicle)
end, false)

RegisterCommand('ped', function(source, args)
    local pedName = args[1]

    if pedName == nil then
        print('You must specify a ped name')
        return
    end

    if not IsModelInCdimage(pedName) or not IsModelAHuman(pedName) then
        print('Invalid ped name')
    end

    RequestModel(pedName)
    while not HasModelLoaded(pedName) do
        Wait(0)
    end

    SetPlayerModel(PlayerId(), pedName)
    SetModelAsNoLongerNeeded(pedName)
end, false)
