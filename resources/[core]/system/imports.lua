System = exports.system:getSharedObject()

if not IsDuplicityVersion() then
    RegisterNetEvent('system:playerLoaded', function(xPlayer)
        System.PlayerData = xPlayer
        System.PlayerLoaded = true
    end)

    RegisterNetEvent('system:playerDropped', function()
        System.PlayerData = {}
        System.PlayerLoaded = false
    end)
end
