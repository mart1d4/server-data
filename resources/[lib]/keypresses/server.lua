RegisterServerEvent('pv:syncIndicator', function(indicator)
	local playerId = source
	TriggerClientEvent('pv:syncIndicator', -1, playerId, indicator)
end)
