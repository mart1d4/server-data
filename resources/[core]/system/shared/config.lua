Config = {}

Config.Accounts = {
	bank = {
		label = 'Bank',
		round = true,
	},
	cash = {
		label = 'Cash',
		round = true,
	},
	dirty = {
		label = 'Dirty',
		round = true,
	}
}

Config.DefaultSpawnCoords   	  = { x = -54.4953, y = -786.1072, z = 44.2351, heading = 0.0, model = `messi` }
Config.IdentitySpawnCoords        = { x = 618.0328, y = 916.2574, z = 241.9951, heading = 319.8580 }
Config.DeathSpawnCoords 		  = { x = 278.6898, y = -585.9687, z = 43.3135, heading = 66.0426 }

Config.StartingAccountMoney       = { bank = 5000, cash = 75, dirty = 0 }
Config.PaycheckInterval           = 10 * 60000
Config.MaxWeight            	  = 24
Config.EnableWantedLevel    	  = false
Config.EnablePVP                  = false

Config.DistanceGive 			  = 4.0

Config.DisableHealthRegeneration  = false
Config.DisableVehicleRewards      = false
Config.DisableNPCDrops            = false
Config.DisableDispatchServices	  = false
Config.DisableScenarios			  = false
Config.DisableWeaponWheel         = false
Config.DisableAimAssist           = false
Config.DisableVehicleSeatShuff	  = false

Config.CustomPlates = 'WCC AA11' -- [WC] = West Coast, [AAA111] = 3 Random Letters and 3 Random Numbers

Config.RemoveHudComponents = {
	[1]  = true,  -- Wanted stars
	[2]  = false, -- Weapon icon
	[3]  = true,  -- Cash
	[4]  = true,  -- Multiplayer Cash
	[5]  = false, -- Multiplayer message
	[6]  = true,  -- Vehicle name
	[7]  = true,  -- Area name
	[8]  = true,  -- Vehicle class
	[9]  = true,  -- Street name
	[10] = false, -- Help text
	[11] = false, -- Floating help text 1
	[12] = false, -- Floating help text 2
	[13] = true,  -- Cash change
	[14] = false, -- Reticle
	[15] = false, -- Subtitle text
	[16] = false, -- Radio stations
	[17] = false, -- Saving game
	[18] = false, -- Game stream
	[19] = false, -- Weapon wheel
	[20] = false, -- Weapon wheel stats
	[21] = false, -- HUD components
	[22] = false, -- HUD Weapons
}
