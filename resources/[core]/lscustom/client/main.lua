local alreadyEntered = false
local inMenu = false
local isTooltipActive = false
local lastZone

-- Create Los Santos Customs Blips
CreateThread(function()
	for _, zone in pairs(Config.Zones) do
		local blip = AddBlipForCoord(zone)

		SetBlipSprite(blip, 72)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.8)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Los Santos Customs')
		EndTextCommandSetBlipName(blip)
	end
end)

-- Draw Markers & Marker Actions
CreateThread(function()
	while true do
		Wait(0)

		local playerCoords = GetEntityCoords(PlayerPedId())
		local isInMarker, letSleep, currentZone, tooltip = false, true, nil, nil

		for _, zone in pairs(Config.Zones) do
			local distance = #(playerCoords - zone)

			if distance < Config.DrawDistance then
				letSleep = false

				if IsPedInAnyVehicle(PlayerPedId(), false) then
					DrawMarker(
						1, zone - vector3(0.0, 0.0, 1.0),
						0.0, 0.0, 0.0,
						0.0, 0.0, 0.0,
						5.0, 5.0, 0.75,
						Config.MarkerColor.r,
						Config.MarkerColor.g,
						Config.MarkerColor.b,
						100, false, true, 2,
						false, nil, nil, false
					)
				end

				if distance < 5 then
					if IsPedInAnyVehicle(PlayerPedId(), false) then
						isInMarker, currentZone = true, zone
					end
				end
			end
		end

		if (isInMarker and not alreadyEntered) or (lastZone ~= currentZone) then
			alreadyEntered = true
			lastZone = currentZone
			ShowTooltip(true, 'Press ~INPUT_FRONTEND_RDOWN~ to modify your vehicle', 191)
		end

		if (not isInMarker and alreadyEntered) then
			alreadyEntered = false
			ShowTooltip(false)
		end

		if letSleep then
			Wait(500)
		end
	end
end)

function ShowTooltip(show, tooltip, key)
    isTooltipActive = show

    CreateThread(function()
        while isTooltipActive and not inMenu do
            SetTextComponentFormat("STRING")
            AddTextComponentString(tooltip)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)

            if IsControlJustReleased(0, key) then
                if inMenu then
                    ShowMenu(false)
					DisplayRadar(true)

					local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

					SetVehicleDoorsLocked(vehicle, 0)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					SetEntityInvincible(vehicle, false)
					FreezeEntityPosition(vehicle, false)
                else
                    ShowMenu(true)
					DisplayRadar(false)

					local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

					SetEntityCoords(vehicle, Config.VehicleDisplayPos.xyz, false, false, false, false)
					SetEntityHeading(vehicle, Config.VehicleDisplayPos.w)
					SetVehicleOnGroundProperly(vehicle)
					SetVehicleDoorsLocked(vehicle, 4)
					SetVehicleDoorsLockedForAllPlayers(vehicle, true)
					SetEntityInvincible(vehicle, true)
					FreezeEntityPosition(vehicle, true)
                end
            end

            Wait(0)
        end
    end)
end

function ShowMenu(show)
	inMenu = show

	if show then
		SendNUIMessage({
			action = 'LSCustom',
			data = json.encode({
				show = true,
				props = System.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId())),
			})
		})
	else
		SendNUIMessage({
			action = 'LSCustom',
			data = json.encode({
				show = false,
			})
		})
	end
end
