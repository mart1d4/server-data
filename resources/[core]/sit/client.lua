local debugProps, sitting, lastPos, currentSitCoords, currentScenario = {}
local disableControls = false
local currentObj = nil

CreateThread(function()
	while true do
		local wait = 1000
		local playerPed = PlayerPedId()

		if sitting and not IsPedUsingScenario(playerPed, currentScenario) then
			wakeup()
		end

		Wait(wait)
	end
end)

RegisterCommand('Sit', function()
	if sitting then
		wakeup()
	else
		local object, distance = GetNearChair()

		if distance and distance < 1.4 then
			local hash = GetEntityModel(object)

			for k, v in pairs(Config.Sitable) do
				if joaat(k) == hash then
					sit(object, k, v)
					break
				end
			end
		end
	end
end, false)

function GetNearChair()
	local object, distance
	local coords = GetEntityCoords(PlayerPedId())

	for i = 1, #Config.Interactables do
		object = GetClosestObjectOfType(coords, 3.0, joaat(Config.Interactables[i]), false, false, false)
		distance = #(coords - GetEntityCoords(object))

		if distance < 1.6 then
			return object, distance
		end
	end

	return nil, nil
end

function wakeup()
	local playerPed = PlayerPedId()
	local pos = GetEntityCoords(PlayerPedId())

	TaskStartScenarioAtPosition(playerPed, currentScenario, 0.0, 0.0, 0.0, 180.0, 2, true, false)
	while IsPedUsingScenario(PlayerPedId(), currentScenario) do
		Wait(100)
	end
	ClearPedTasks(playerPed)

	FreezeEntityPosition(playerPed, false)
	FreezeEntityPosition(currentObj, false)

	TriggerServerEvent('sit:leavePlace', currentSitCoords)
	currentSitCoords, currentScenario = nil, nil
	sitting = false
	disableControls = false
end

function sit(object, modelName, data)
	-- Fix for sit on chairs behind walls
	if not HasEntityClearLosToEntity(PlayerPedId(), object, 17) then
		return
	end
	disableControls = true
	currentObj = object
	FreezeEntityPosition(object, true)

	PlaceObjectOnGroundProperly(object)
	local pos = GetEntityCoords(object)
	local playerPos = GetEntityCoords(PlayerPedId())
	local objectCoords = pos.x .. pos.y .. pos.z

	TriggerServerEvent('sit:getPlace', objectCoords)

	RegisterNetEvent('sit:isPlaceTaken', function(occupied)
		if occupied then
			print('Seat taken')
		else
			local playerPed = PlayerPedId()
			lastPos, currentSitCoords = GetEntityCoords(playerPed), objectCoords

			TriggerServerEvent('sit:takePlace', objectCoords)
			
			currentScenario = data.scenario
			TaskStartScenarioAtPosition(playerPed, currentScenario, pos.x, pos.y, pos.z + (playerPos.z - pos.z)/2, GetEntityHeading(object) + 180.0, 0, true, false)

			Wait(2500)
			if GetEntitySpeed(PlayerPedId()) > 0 then
				ClearPedTasks(PlayerPedId())
				TaskStartScenarioAtPosition(playerPed, currentScenario, pos.x, pos.y, pos.z + (playerPos.z - pos.z)/2, GetEntityHeading(object) + 180.0, 0, true, true)
			end

			sitting = true
		end
	end)
end