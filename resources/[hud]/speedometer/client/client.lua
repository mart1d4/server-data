RegisterNetEvent('speedometer:enteredVehicle')
RegisterNetEvent('speedometer:leftVehicle')

local inVehicle, vehicleType, isDriver, playerPos = false, nil, false, nil
local currentMileage = 0

local values = {
    show = false,
    defaultIndicators = {}
}

local function driverCheckThread()
    CreateThread(function()
        while inVehicle do
            playerPos = GetEntityCoords(PlayerPedId()).xy
            Wait(1000)
        end
    end)
end

local function slowInfoThread(currentVehicle)
    CreateThread(function()
        local oldPos = nil

        while inVehicle and DoesEntityExist(currentVehicle) do
            local engineHealth = math.floor(GetVehicleEngineHealth(currentVehicle))
            local _, lowBeam, highBeam = GetVehicleLightsState(currentVehicle)
            local lightState = false
            local indicator = GetVehicleIndicatorLights(currentVehicle)
            local indicatorLeft, indicatorRight = false, false
            local doorLockStatus = false
            local tempDoorLockStatus = GetVehicleDoorLockStatus(currentVehicle)

            -- Make sure engine health not going to minus
            if engineHealth < 0 then
                engineHealth = 0
            end

            if engineHealth > 1000 then
                engineHealth = 1000
            end

            -- Set light state
            if lowBeam == 1 or highBeam == 1 then
                lightState = true
            end

            -- Set indicator state
            if indicator == 1 or indicator == 3 then
                indicatorLeft = true
            end
            if indicator == 2 or indicator == 3 then
                indicatorRight = true
            end

            -- Set lock state
            if tempDoorLockStatus == 2 or tempDoorLockStatus == 3 then
                doorLockStatus = true
            end

            local vehState = Entity(currentVehicle).state
            if vehState.mileage == nil or not type(vehState.mileage) == 'number' then
                vehState:set('mileage', math.random(10000, 230000), true)
            end
            currentMileage = vehState.mileage

            if IsVehicleOnAllWheels(currentVehicle) then
                if oldPos then
                    local distance = #(oldPos - playerPos)
                    if distance >= 10 then
                        vehState:set('mileage', System.Math.Round((vehState.mileage + distance / 1000), 2), true)
                        oldPos = playerPos
                    end
                else
                    oldPos = playerPos
                end
            end

            values.fuel = {
                level = 100,
                maxLevel = 100
            }
            values.mileage = currentMileage
            values.damage = engineHealth
            values.vehType = vehicleType
            values.driver = isDriver
            values.defaultIndicators.tempomat = cruiseControlStatus
            values.defaultIndicators.door = doorLockStatus
            values.defaultIndicators.light = lightState
            values.defaultIndicators.leftIndex = indicatorLeft
            values.defaultIndicators.rightIndex = indicatorRight

            Wait(200)
        end
    end)
end

local function fastInfoThread(currentVehicle)
    CreateThread(function()
        while inVehicle do
            local currentSpeed = GetEntitySpeed(currentVehicle)
            local engineRunning = GetIsVehicleEngineRunning(currentVehicle)
            local rpm

            if vehicleType == 'LAND' then
                rpm = engineRunning and (GetVehicleCurrentRpm(currentVehicle)) or 0
            else
                rpm = 0
            end

            values.speed = math.floor(currentSpeed * 3.6)
            values.rpm = rpm
            values.defaultIndicators.engine = engineRunning

            if IsPauseMenuActive() then
                values.show = false
            else
                values.show = true
            end

            SendNUIMessage({
                action = 'Speedometer',
                data = json.encode(values)
            })

            Wait(50)
        end
    end)
end

local function activateVehicleHud(currentVehicle)
    values.show = true
    slowInfoThread(currentVehicle)
    fastInfoThread(currentVehicle)
end

AddEventHandler('speedometer:enteredVehicle', function(currentVehicle, currentPlate, currentVehicleName, netId)
    local vehicleClass = GetVehicleClass(currentVehicle)
    if vehicleClass == 13 then
        return
    end

    inVehicle = true
    vehicleType = vehicleClass == 15 or vehicleClass == 16 and 'AIR' or 'LAND'

    driverCheckThread(currentVehicle)
    activateVehicleHud(currentVehicle)
end)

AddEventHandler('speedometer:leftVehicle', function(currentVehicle, currentPlate, currentVehicleName, netId)
    inVehicle = false
    vehicleType = nil
    values = {
        show = false,
        defaultIndicators = {}
    }

    SendNUIMessage({
        action = 'Speedometer',
        data = json.encode({ show = false })
    })

    currentMileage = 0
end)
