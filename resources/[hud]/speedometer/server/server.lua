RegisterServerEvent('baseevents:enteredVehicle')
RegisterServerEvent('baseevents:leftVehicle')

AddEventHandler('baseevents:enteredVehicle', function(currentVehicle, currentSeat, currentVehicleName, netId)
    local playerId = source
    TriggerClientEvent('speedometer:enteredVehicle', playerId, currentVehicle, currentVehicleName, netId)
end)

AddEventHandler('baseevents:leftVehicle', function(currentVehicle, currentSeat, currentVehicleName, netId)
    local playerId = source
    TriggerClientEvent('speedometer:leftVehicle', playerId, currentVehicle, currentVehicleName, netId)
end)
