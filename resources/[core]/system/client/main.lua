CreateThread(function()
	while true do
		Wait(100)

		if NetworkIsPlayerActive(PlayerId()) then
			TriggerServerEvent('system:onPlayerJoined')
			TriggerEvent('system:onPlayerJoined')
			break
		end
	end
end)

AddEventHandler('system:onPlayerJoined', function()
	while not System.PlayerData do
		Wait(100)
	end

	-- Disable Wanted Level
	if Config.DisableWantedLevel then
		ClearPlayerWantedLevel(PlayerId())
		SetMaxWantedLevel(0)
	end

	-- Disable PVP
	if Config.DisablePVP then
		SetCanAttackFriendly(System.PlayerData.ped, true, false)
		NetworkSetFriendlyFireOption(true)
	end

	-- Remove Hud Compmonents
	for i = 1, #(Config.RemoveHudComponents) do
		if Config.RemoveHudComponents[i] then
			SetHudComponentPosition(i, 999999.0, 999999.0)
		end
	end

	-- Disable Seat Shuffling
	if Config.DisableSeatShuffle then
		AddEventHandler('system:enteredVehicle', function(vehicle, plate, seat)
			if seat == 0 then
				SetPedIntoVehicle(System.PlayerData.ped, vehicle, 0)
				SetPedConfigFlag(System.PlayerData.ped, 184, true)
			end
		end)
	end

	CreateThread(function()
		while true do
			InvalidateIdleCam()
			InvalidateVehicleIdleCam()

			Wait(1000)
		end
	end)

	CreateThread(function()
		while true do
			if Config.DisableAimAssist then
				if IsPedArmed(System.PlayerData.ped, 4) then
					SetPlayerLockonRangeOverride(PlayerId(), 2.0)
				end
			end

			if Config.DisableVehicleRewards then
				DisablePlayerVehicleRewards(PlayerId())
			end

			Wait(0)
		end
	end)

	CreateThread(function()
		local densityConfig = {
			pedFrequency = 1.0,
			trafficFrequency = 1.0,
		}

		-- Custom pause menu title
		AddTextEntry('FE_THDR_GTAO', "West Coast Dreamin")

		-- Fix custom map zoom levels
		SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0)
		SetMapZoomDataLevel(1, 1.60, 0.9, 0.08, 0.0, 0.0)
		SetMapZoomDataLevel(2, 8.60, 0.9, 0.08, 0.0, 0.0)
		SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0)
		SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0)

		-- Removes health/armour display #1
		local minimap = RequestScaleformMovie("minimap")
		SetRadarBigmapEnabled(true, false)
		Wait(0)
		SetRadarBigmapEnabled(false, false)

		while true do
			Wait(0)

			-- Removes health/armour display #2
			BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
			ScaleformMovieMethodAddParamInt(3)
			EndScaleformMovieMethod()

			-- Updates ped density
			SetPedDensityMultiplierThisFrame(densityConfig.pedFrequency)
			SetScenarioPedDensityMultiplierThisFrame(densityConfig.pedFrequency, densityConfig.pedFrequency)

			-- Updates traffic density
			SetRandomVehicleDensityMultiplierThisFrame(densityConfig.trafficFrequency)
			SetParkedVehicleDensityMultiplierThisFrame(densityConfig.trafficFrequency)
			SetVehicleDensityMultiplierThisFrame(densityConfig.trafficFrequency)
		end
	end)

	-- Disable Dispatch Services
	if Config.DisableDispatch then
		for i = 1, 15 do
			EnableDispatchService(i, false)
		end
	end

	SetDefaultVehicleNumberPlateTextPattern(-1, Config.CustomPlates)
end)

RegisterNetEvent('system:createIdentity', function(playerId, xPlayer, isNew)
	local coords = Config.IdentitySpawnCoords
	SetTimecycleModifier("hud_def_blur")
	DisplayRadar(false)

	exports.spawn:spawnPlayer({
		x = coords.x,
		y = coords.y,
		z = coords.z + 0.05,
		heading = coords.heading,
		model = 'a_f_m_beach_01',
		skipFade = false
	}, function()
		SetEntityVisible(PlayerPedId(), false, 0)

		SendNUIMessage({
			action = "Identity",
			data = json.encode({ show = true })
		})
		SetNuiFocus(true, true)

		RegisterNUICallback('SendIdentityData', function(data)
			ClearTimecycleModifier()
			DisplayRadar(true)

			SendNUIMessage({
				action = "Identity",
				data = json.encode({ show = false })
			})
			SetNuiFocus(false, false)

			TriggerServerEvent('system:identityCreated', data)
			TriggerEvent('system:identityCreated', data)
			TriggerEvent('system:playerLoaded', playerId, xPlayer, isNew)
		end)
	end)
end)

RegisterNetEvent('system:playerLoaded', function(playerId, xPlayer, isNew)
	System.PlayerData = xPlayer

	exports.spawn:spawnPlayer({
		x = System.PlayerData.position.x,
		y = System.PlayerData.position.y,
		z = System.PlayerData.position.z + 0.05,
		heading = System.PlayerData.position.heading,
		model = 'messi',
		skipFade = false
	}, function()
		TriggerServerEvent('system:onPlayerSpawn')
		TriggerEvent('system:onPlayerSpawn')

		-- if isNew then
		-- 	TriggerEvent('skinchanger:loadDefaultModel', skin.sex == 0)
		-- elseif skin then
		-- 	TriggerEvent('skinchanger:loadSkin', skin)
		-- end

		System.SpawnActiveVehicle()

		ShutdownLoadingScreen()
		ShutdownLoadingScreenNui()
	end)

	System.PlayerLoaded = true
end)

AddEventHandler('system:onPlayerSpawn', function()
	System.SetPlayerData('ped', PlayerPedId())
	System.SetPlayerData('dead', false)
end)

AddEventHandler('baseevents:onPlayerDied', function()
	Wait(5000)
	exports.spawn:spawnPlayer(Config.DeathSpawnCoords, function()
		System.SetPlayerData('dead', false)
	end)
end)
AddEventHandler('baseevents:onPlayerDied', function()
	onDeathEffect()
end)

AddEventHandler('baseevents:onPlayerKilled', function()
	Wait(5000)
	exports.spawn:spawnPlayer(Config.DeathSpawnCoords, function()
		System.SetPlayerData('dead', false)
	end)
end)
AddEventHandler('baseevents:onPlayerKilled', function()
	onDeathEffect()
end)

AddEventHandler('baseevents:onPlayerWasted', function()
	Wait(5000)
	exports.spawn:spawnPlayer(Config.DeathSpawnCoords, function()
		System.SetPlayerData('dead', false)
	end)
end)
AddEventHandler('baseevents:onPlayerWasted', function()
	onDeathEffect()
end)

function onDeathEffect()
	System.SetPlayerData('dead', true)

	StartScreenEffect("DeathFailOut", 0, 0)
	PlaySoundFrontend(-1, "Bed", "WastedSounds", 1)
	ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)

	local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
	if HasScaleformMovieLoaded(scaleform) then
		Wait(0)
	end

	PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
	BeginTextComponent("STRING")
	AddTextComponentString("~r~wasted")
	EndTextComponent()
	PopScaleformMovieFunctionVoid()

	Wait(500)

	PlaySoundFrontend(-1, "TextHit", "WastedSounds", 1)

	while IsEntityDead(PlayerPedId()) do
		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
		Wait(0)
	end

	StopScreenEffect("DeathFailOut")
end
