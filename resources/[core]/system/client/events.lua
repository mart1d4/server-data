RegisterNetEvent('system:notify', function(source, player, subject, message, content, icon, flash)
    AddTextEntry('SystemNotification', message)
    BeginTextCommandThefeedPost('SystemNotification')
    EndTextCommandThefeedPostMessagetext(content, content, false, icon, player, subject)
    EndTextCommandThefeedPostTicker(flash or false, true)
end)

RegisterNetEvent('system:helpText', function(playerId, message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(true, false)
end)

RegisterNetEvent('system:setAccountMoney', function(account)
    local accounts = System.PlayerData.accounts
    
	for i = 1, #(accounts) do
		if accounts[i].label == account.label then
			accounts[i] = account
			break
		end
	end

	System.SetPlayerData('accounts', accounts)
end)

RegisterNetEvent('system:setVehicles', function(vehicles)
    System.SetPlayerData('vehicles', vehicles)
end)
