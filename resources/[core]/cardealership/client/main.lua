local alreadyEntered = false
local inMenu = false
local isTooltipActive = false
local tooltipType = 'default'
local lastZone
local currentDisplayVehicle = {}
local vehicleStock = {}
local chosenVehicle = {}

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end

	TriggerServerEvent("cardealership:fetchVehicles")
end)

RegisterNetEvent('system:playerLoaded', function()
	TriggerServerEvent("cardealership:fetchVehicles")
end)

RegisterNetEvent('cardealership:updateVehicles', function(vehicles)
	vehicleStock = vehicles
	chosenVehicle = vehicles[1]
end)

-- Create Car Dealership Blip
CreateThread(function()
	local blip = AddBlipForCoord(Config.Blip.Pos)

	SetBlipSprite(blip, Config.Blip.Sprite)
	SetBlipDisplay(blip, Config.Blip.Display)
	SetBlipScale(blip, Config.Blip.Scale)
	SetBlipAsShortRange(blip, Config.Blip.ShortRange)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(Config.Blip.Name)
	EndTextCommandSetBlipName(blip)
end)

function LoadVehicle(index, netId)
	CreateThread(function()
		while not NetworkDoesEntityExistWithNetworkId(netId) do
			Wait(200)
		end

		local vehicle = NetworkGetEntityFromNetworkId(netId)

		if index == 4 then
			currentDisplayVehicle = {
				vehicle = vehicle,
				netId = netId,
			}
		end

		SetVehicleLivery(vehicle, 0)
		SetVehicleNumberPlateText(vehicle, 'DISPLAY')
		SetVehicleRadioEnabled(vehicle, false)
		SetEntityInvincible(vehicle, true)
		SetVehicleDirtLevel(vehicle, 0.0)
		SetVehicleOnGroundProperly(vehicle)
		FreezeEntityPosition(vehicle, true)
		SetNetworkIdCanMigrate(netId, true)
		NetworkRegisterEntityAsNetworked(vehicle)
	end)
end

RegisterNetEvent('cardealership:spawnVehicles', function(netIdTable)
	for i = 1, #netIdTable do
		LoadVehicle(i, netIdTable[i])
	end
end)

-- Draw Markers & Marker Actions
CreateThread(function()
	while true do
		Wait(0)

		local playerCoords = GetEntityCoords(PlayerPedId())
		local isInMarker, letSleep, currentZone, tooltip = false, true, nil, nil
		local inVehicle = GetVehiclePedIsIn(PlayerPedId(), false)

		for name, zone in pairs(Config.Zones) do
			local distance = #(playerCoords - zone.pos)

			if distance < Config.DrawDistance then
				letSleep = false

				if not zone.onVehicle or IsPedInAnyVehicle(PlayerPedId(), false) then
					DrawMarker(
						zone.type,
						zone.pos,
						0.0, 0.0, 0.0,
						0.0, 0.0, 0.0,
						zone.size.x,
						zone.size.y,
						zone.size.z,
						Config.MarkerColor.r,
						Config.MarkerColor.g,
						Config.MarkerColor.b,
						100, false, true, 2,
						false, nil, nil, false
					)
				end

				if distance < zone.size.x then
					if not zone.onVehicle or IsPedInAnyVehicle(PlayerPedId(), false) then
						isInMarker, currentZone, tooltip, menuType = true, name, zone.tooltip, zone.menuType
					end
				end
			end
		end

		if (isInMarker and not alreadyEntered) or (lastZone ~= currentZone) then
			alreadyEntered = true
			lastZone = currentZone
			ShowTooltip(true, tooltip, 38, menuType)
		end

		if inVehicle == currentDisplayVehicle.vehicle then
			tooltipType = 'car'
			ShowTooltip(true, 'Press  ~INPUT_FRONTEND_RDOWN~  to buy the vehicle', 191, 'BuyVehicle')
		end

		if (not isInMarker and alreadyEntered) or (inVehicle ~= currentDisplayVehicle.vehicle and tooltipType == 'car') then
			alreadyEntered = false
			tooltipType = 'default'
			ShowTooltip(false)
		end

		if letSleep then
			Wait(500)
		end
	end
end)

function ShowTooltip(show, tooltip, key, menuType)
	isTooltipActive = show

	CreateThread(function()
		while isTooltipActive and not inMenu do
			SetTextComponentFormat("STRING")
			AddTextComponentString(tooltip)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlJustReleased(0, key) then
				if inMenu then
					ShowMenu(false)
				else
					ShowMenu(true, menuType)
				end
			end

			Wait(0)
		end
	end)
end

function ShowMenu(show, menuType)
	inMenu = show

	local pedVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	local isOwned = IsVehicleOwnedByPlayer(pedVehicle)

	DisplayRadar(not show)
	alreadyEntered = false

	if show then
		SendNUIMessage({
			action = "CarDealership",
			data = json.encode({
				show = show,
				menuType = menuType,
				vehicles = vehicleStock,
				vehicle = chosenVehicle,
				isOwned = isOwned,
				cash = System.GetPlayerData().accounts.Cash,
				bank = System.GetPlayerData().accounts.Bank,
			})
		})
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = "Speedometer",
			data = json.encode({
				show = false,
			})
		})
	else
		SendNUIMessage({
			action = "CarDealership",
			data = json.encode({
				show = show,
			})
		})
		SetNuiFocus(false)

		if menuType == 'BuyVehicle' then
			SendNUIMessage({
				action = "Speedometer",
				data = json.encode({
					show = true,
				})
			})
		end
	end
end

function IsVehicleOwnedByPlayer(vehicle)
	if not DoesEntityExist(vehicle) then
		return false
	end

	local plate = GetVehicleNumberPlateText(vehicle)
	local vehicles = System.GetPlayerData().vehicles

	for i = 1, #vehicles do
		if vehicles[i].plate == plate then
			return vehicles[i]
		end
	end

	return false
end

RegisterNUICallback('CloseMenu', function()
	ShowMenu(false)
end)

RegisterNUICallback('ShowVehicle', function(vehicle)
	-- Store vehicle data
	chosenVehicle = vehicle

	-- Delete old vehicle
	TriggerServerEvent('cardealership:deleteVehicle', currentDisplayVehicle.netId)

	-- Spawn new vehicle
	TriggerServerEvent('cardealership:spawnVehicle', vehicle)
end)

RegisterNetEvent('cardealership:spawnNetVehicle', function(netId, vehicle)
	while not NetworkDoesEntityExistWithNetworkId(netId) do
		Wait(200)
	end

	local vehicle = NetworkGetEntityFromNetworkId(netId)

	currentDisplayVehicle = {
		vehicle = vehicle,
		netId = netId,
	}

	SetVehicleLivery(vehicle, 0)
	SetVehicleNumberPlateText(vehicle, 'DISPLAY')
	SetVehicleRadioEnabled(vehicle, false)
	SetEntityInvincible(vehicle, true)
	SetVehicleDirtLevel(vehicle, 0.0)
	SetVehicleOnGroundProperly(vehicle)
	FreezeEntityPosition(vehicle, true)
	NetworkRegisterEntityAsNetworked(vehicle)
	SetNetworkIdCanMigrate(netId, true)
end)

RegisterNUICallback('BuyVehicle', function(data)
	data.vehicle.price = tonumber(data.vehicle.price)

	if data.type == 'cash' then
		if System.GetPlayerData().accounts.Cash >= data.vehicle.price then
			TriggerServerEvent('cardealership:buyVehicle', data.vehicle, data.color, 'Cash')
		end
	elseif data.type == 'bank' then
		if System.GetPlayerData().accounts.Bank >= data.vehicle.price then
			TriggerServerEvent('cardealership:buyVehicle', data.vehicle, data.color, 'Bank')
		end
	end
end)

RegisterNetEvent('cardealership:vehicleBought', function()
	ShowMenu(false)
	ShowTooltip(false)

	System.SpawnActiveVehicle(true)
end)

RegisterNUICallback('SellVehicle', function(data)
	local coords = Config.Blip.Pos
	ShowMenu(false)

	exports.spawn:spawnPlayer({
		x = coords.x,
		y = coords.y,
		z = coords.z,
		heading = 177.8681,
	}, function()
		TriggerServerEvent('cardealership:sellVehicle', data.vehicle, data.price)
	end)
end)
