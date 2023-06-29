local mapBlips = {
    {
        title = "Shop",
        colour = nil,
        id = 52,
        x = -53.57,
        y = -1757.12,
        z = 29.44
    },
    {
        title = "Gas Station",
        colour = 6,
        scale = 0.7,
        id = 361,
        x = 1210.1439,
        y = -1404.1623,
        z = 34.8800
    },
    {
        title = "Gas Station",
        colour = 6,
        scale = 0.7,
        id = 361,
        x = -721.4851,
        y = -934.1684,
        z = 18.4037
    },
    {
        title = "Gas Station",
        colour = 6,
        scale = 0.7,
        id = 361,
        x = 264.8051,
        y = 2604.9873,
        z = 45
    },
    {
        title = "Gas Station",
        colour = 6,
        scale = 0.7,
        id = 361,
        x = -2094.4538,
        y = -320.7802,
        z = 12.4150
    },
    {
        title = "Gas Station",
        colour = 6,
        scale = 0.7,
        id = 361,
        x = 267.3716,
        y = -1262.8397,
        z = 28.6416
    },
    {
        title = "Gas Station",
        colour = 6,
        scale = 0.7,
        id = 361,
        x = -525.4511,
        y = -1213.1049,
        z = 17.5724
    },
    {
        title = "Gas Station",
        colour = 6,
        scale = 0.7,
        id = 361,
        x = -321.2990,
        y = -1472.6135,
        z = 29.9369
    },
    {
        title = "Gas Station",
        colour = 6,
        scale = 0.7,
        id = 361,
        x = 1179.7440,
        y = -328.0976,
        z = 68.5616
    },
    {
        title = "Police Station",
        colour = 38,
        id = 60,
        x = 431.8916,
        y = -981.3518,
        z = 30.7107
    },
    {
        title = "Deal Spot",
        colour = 2,
        id = 140,
        x = -1174.1138,
        y = -1573.8072,
        z = 4.3728
    },
}

-- Map Blips
CreateThread(function()
    for _, info in pairs(mapBlips) do
        newBlip = AddBlipForCoord(info.x, info.y, info.z)
        SetBlipSprite(newBlip, info.id)
        SetBlipDisplay(newBlip, 4)
        SetBlipScale(newBlip, info.scale or 1.0)

        if info.colour then
            SetBlipColour(newBlip, info.colour)
        end

        SetBlipAsShortRange(newBlip, true)
	    BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(info.title)
        EndTextCommandSetBlipName(newBlip)
    end
end)

-- Player Blips
CreateThread(function()
	local blips = {}
	local currentPlayer = PlayerId()
	local players = GetActivePlayers()

	for _, player in ipairs(players) do
		if player ~= currentPlayer and NetworkIsPlayerActive(player) then
			local playerPed = GetPlayerPed(player)
			local newBlip = AddBlipForEntity(playerPed)

			SetBlipSprite(newBlip, 1)
			SetBlipNameToPlayerName(newBlip, player)
			SetBlipAsShortRange(newBlip, true)
			SetBlipCategory(newBlip, 7)
			SetBlipDisplay(newBlip, 2)
			SetBlipScale(newBlip, 0.85)
			SetBlipRotation(newBlip, GetEntityHeading(playerPed))

			blips[player] = {
				blip = newBlip,
				model = GetEntityModel(playerPed)
			}
		end
	end

	while true do
		players = GetActivePlayers()

		for _, player in ipairs(players) do
			local playerPed = GetPlayerPed(player)

			if player ~= currentPlayer and NetworkIsPlayerActive(player) then
				if blips[player] ~= nil and blips[player]?.model == GetEntityModel(playerPed) then
					-- Do nothing
				else
					if blips[player] ~= nil then
						RemoveBlip(blips[player].blip)
					end

					local newBlip = AddBlipForEntity(playerPed)

					SetBlipSprite(newBlip, 1)
					SetBlipNameToPlayerName(newBlip, player)
					SetBlipAsShortRange(newBlip, true)
					SetBlipCategory(newBlip, 7)
					SetBlipDisplay(newBlip, 2)
					SetBlipScale(newBlip, 0.85)
					SetBlipRotation(newBlip, GetEntityHeading(playerPed))

					blips[player] = {
						blip = newBlip,
						model = GetEntityModel(playerPed)
					}
				end
			end
		end

		for player, object in pairs(blips) do
			if not NetworkIsPlayerActive(player) then
				RemoveBlip(object.blip)
				blips[player] = nil
			end
		end

		Wait(500)
	end
end)
