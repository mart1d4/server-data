local isOpen = false

CreateThread(function()
    local MKey = 244 -- M key
    local EscapeKey = 322 -- Escape key

    while true do
        Wait(0)
        
        if IsControlJustPressed(1, MKey) then
            if not isOpen then
                SendNUIMessage({
                    action = "Menu",
                    data = json.encode({ show = true })
                })
                SetNuiFocus(true, true)
            end

            isOpen = not isOpen
        end
    end
end)

RegisterNUICallback('CloseMenu', function(data)
    isOpen = not isOpen

    SendNUIMessage({
        action = "Menu",
        data = json.encode({ show = false })
    })
    SetNuiFocus(false, false)
end)

RegisterNUICallback('SpawnVehicle', function(data)
    exports.vehicles:spawnVehicle(data)
end)

RegisterNUICallback('ModifyVehicle', function(data)
    exports.vehicles:modifyVehicle(data)
end)

RegisterNUICallback('ModifyPlayer', function(data)
    exports.player:modifyPlayer(data)
end)

RegisterNUICallback('Teleport', function(data)
    if data.waypoint then
        ExecuteCommand('tp')
    else
        ExecuteCommand('tp', data.x, data.y, data.z)
    end
end)
