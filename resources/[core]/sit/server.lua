local seatsTaken = {}

RegisterServerEvent('sit:takePlace', function(objectCoords)
	seatsTaken[objectCoords] = true
end)

RegisterServerEvent('sit:leavePlace', function(objectCoords)
	if seatsTaken[objectCoords] then
		seatsTaken[objectCoords] = nil
	end
end)

RegisterServerEvent('sit:getPlace', function(objectCoords)
	TriggerClientEvent('sit:isPlaceTaken', source, seatsTaken[objectCoords])
end)
