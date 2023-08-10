local vehicles, vehiclesIds = {}, {}

local function GeneratePlate()
    local plate = 'WCC '

    for i = 1, 4 do
        plate = plate .. string.char(math.random(65, 90))
    end

    local result = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ?', {
        plate
    })

    if result[1] then
        return GeneratePlate()
    end

    return plate
end

AddEventHandler('onResourceStop', function()
    for i = 1, #vehiclesIds do
        local vehicle = NetworkGetEntityFromNetworkId(vehiclesIds[i])

        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    -- Fetch vehicles from database
    local vehicleStock = MySQL.query.await('SELECT * FROM vehicles')
    TriggerClientEvent('cardealership:updateVehicles', -1, vehicleStock or {})

    -- Spawn display vehicles
    for i = 1, #Config.DisplayVehicles do
        local model = Config.DisplayVehicles[i].model
        local coords = Config.DisplayVehicles[i].pos

        vehicles[i] = CreateVehicleServerSetter(
            GetHashKey(model),
            'automobile',
            coords.x,
            coords.y,
            coords.z,
            Config.DisplayVehicles[i].heading
        )

        SetEntityDistanceCullingRadius(vehicles[i], 10000.0)
        vehiclesIds[i] = NetworkGetNetworkIdFromEntity(vehicles[i])
        while not DoesEntityExist(vehicles[i]) do Wait(50) end
    end

    Wait(100)
    TriggerClientEvent('cardealership:spawnVehicles', -1, vehiclesIds)
end)

RegisterServerEvent('system:playerLoaded', function(playerId)
    TriggerClientEvent('cardealership:spawnVehicles', playerId, vehiclesIds)
end)

RegisterServerEvent('cardealership:deleteVehicle', function(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)

    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)

        for i = 1, #vehiclesIds do
            if vehiclesIds[i] == netId then
                vehiclesIds[i] = nil
                break
            end
        end
    end
end)

RegisterServerEvent('cardealership:spawnVehicle', function(vehicle)
    local model = vehicle.model
    local coords = Config.DisplayVehicles[4].pos

    local vehicle = CreateVehicleServerSetter(
        GetHashKey(model),
        'automobile',
        coords.x,
        coords.y,
        coords.z,
        Config.DisplayVehicles[4].heading
    )

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    vehiclesIds[4] = netId

    while not DoesEntityExist(vehicle) do Wait(50) end

    TriggerClientEvent('cardealership:spawnNetVehicle', -1, netId, vehicle)
end)

RegisterServerEvent('cardealership:fetchVehicles', function()
    local playerId = source
    local vehicleStock = MySQL.query.await('SELECT * FROM vehicles')

    TriggerClientEvent('cardealership:updateVehicles', playerId, vehicleStock or {})
end)

RegisterServerEvent('cardealership:buyVehicle', function(vehicle, color, type)
    local playerId = source
    local xPlayer = System.GetPlayerFromId(playerId)

    local plate = GeneratePlate()

    local vehicleData = {
        plate = plate,
        vehicle = vehicle.id,
        name = vehicle.name,
        brand = vehicle.brand,
        model = vehicle.model,
        sellPrice = vehicle.price,
        mods = vehicle.mods or {},
        inventory = {},
        props = {
            dirtLevel = 0.0,
            customPrimaryColor = color.primary,
            customSecondaryColor = color.secondary
        },
        mileage = 0.0,
        owner = xPlayer.identifier,
        garage = 'cardealership',
        position = Config.VehicleExitPos.pos,
        heading = Config.VehicleExitPos.heading,
        state = {
            active = true,
            assuranced = false,
            impounded = false,
            locked = true,
            parked = false,
            parkingName = nil,
        },
        purchased = os.time(),
        updated = os.time()
    }

    MySQL.query(
        'INSERT INTO owned_vehicles (plate, vehicle, mileage, owner) VALUES (@plate, @vehicle, @mileage, @owner)',
        {
            ['@plate'] = vehicleData.plate,
            ['@vehicle'] = vehicleData.vehicle,
            ['@mileage'] = vehicleData.mileage,
            ['@owner'] = vehicleData.owner,
        })

    xPlayer.addVehicle(vehicleData, true)
    xPlayer.removeAccountMoney(type, vehicle.price)
    TriggerClientEvent('cardealership:vehicleBought', playerId)
end)

RegisterServerEvent('cardealership:sellVehicle', function(vehicle, price)
    local playerId = source
    local xPlayer = System.GetPlayerFromId(playerId)

    xPlayer.removeVehicle(vehicle.plate)
    xPlayer.addAccountMoney('Bank', price)

    MySQL.query('DELETE FROM owned_vehicles WHERE plate = ?', {
        vehicle.plate
    })

    local activeVehicle = Player(playerId).state.activeVehicleNet

    if activeVehicle then
        local netVehicle = NetworkGetEntityFromNetworkId(activeVehicle)

        while not DoesEntityExist(netVehicle) do
            Wait(50)
        end

        DeleteEntity(netVehicle)
    end

    Player(playerId).state:set('activeVehicle', nil, true)
    Player(playerId).state:set('activeVehicleNet', nil, true)
end)
