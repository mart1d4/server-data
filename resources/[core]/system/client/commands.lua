RegisterCommand('tp', function(source, args)
    if args[1] == nil then
        System.Game.TeleportWaypoint(PlayerPedId())
    elseif args[1] ~= nil and args[2] ~= nil and args[3] ~= nil then
        local vector4 = vector4(tonumber(args[1]), tonumber(args[2]), tonumber(args[3]), tonumber(args[4]) or 0.0)
        System.Game.Teleport(PlayerPedId(), vector4)
    end
end, false)

RegisterCommand('conceal', function(source, args)
    local ped = PlayerPedId()

    NetworkConcealEntity(ped, true, true)
end, false)

RegisterCommand('unconceal', function(source, args)
    local ped = PlayerPedId()

    NetworkConcealEntity(ped, false, false)
end, false)
