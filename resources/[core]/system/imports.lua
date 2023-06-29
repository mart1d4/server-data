System = exports.system:getSharedObject()

if not IsDuplicityVersion() then
    RegisterNetEvent('system:playerLoaded', function(xPlayer)
        System.PlayerData = xPlayer
        System.PlayerLoaded = true
    end)

    RegisterNetEvent('system:onPlayerLogout', function()
        System.PlayerLoaded = false
        System.PlayerData = {}
    end)
end
