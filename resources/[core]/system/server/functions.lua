function System.SavePlayer(xPlayer, cb)
    local parameters <const> = {
        xPlayer.group,
        json.encode(xPlayer.position),
        json.encode(xPlayer.accounts),
        json.encode(xPlayer.banking),
        xPlayer.job.name,
        xPlayer.job.grade,
        json.encode(xPlayer.inventory),
        json.encode(xPlayer.loadout),
        json.encode(xPlayer.vehicles),
        json.encode(xPlayer.properties),
        xPlayer.identifier
    }

    MySQL.prepare(
        'UPDATE users SET `group` = ?, `position` = ?, `accounts` = ?, `banking` = ?, `job` = ?, `job_grade` = ?, `inventory` = ?, `loadout` = ?, `vehicles` = ?, `properties` = ? WHERE `id` = ?',
        parameters,
        function(affectedRows)
            if affectedRows == 1 then
                print(('[^2INFO^7] Saved player ^5"%s^7"'):format(xPlayer.name))
                TriggerEvent('system:playerSaved', xPlayer.playerId, xPlayer)
            end
        end
    )

    if cb then
        cb()
    end
end

function System.SavePlayers(cb)
    local xPlayers <const> = System.Players

    if not next(xPlayers) then
        return
    end

    local startTime <const> = os.time()
    local parameters = {}

    for _, xPlayer in pairs(System.Players) do
        parameters[#parameters + 1] = {
            xPlayer.group,
            json.encode(xPlayer.position),
            json.encode(xPlayer.accounts),
            json.encode(xPlayer.banking),
            xPlayer.job.name,
            xPlayer.job.grade,
            json.encode(xPlayer.inventory),
            json.encode(xPlayer.loadout),
            json.encode(xPlayer.vehicles),
            json.encode(xPlayer.properties),
            xPlayer.identifier
        }
    end

    MySQL.prepare(
        'UPDATE `users` SET `group` = ?, `position` = ?, `accounts` = ?, `banking` = ?, `job` = ?, `job_grade` = ?, `inventory` = ?, `loadout` = ?, `vehicles` = ?, `properties` = ? WHERE `id` = ?',
        parameters,
        function(results)
            if not results then
                return
            end

            print(('[^2INFO^7] Saved ^5%s^7 %s over ^5%s^7 ms'):format(
                #parameters,
                #parameters > 1 and 'players' or 'player',
                System.Math.Round((os.time() - startTime) / 1000000, 2)
            ))
        end
    )

    if cb then
        cb()
    end
end

function System.GetPlayerFromId(source)
    return System.Players[tonumber(source)]
end

function System.GetPlayerFromIdentifier(identifier)
    return System.PlayersByIdentifier[identifier]
end

function System.GetIdentifier(playerId)
    for _, v in ipairs(GetPlayerIdentifiers(playerId)) do
        if string.match(v, 'license:') then
            local identifier = string.gsub(v, 'license:', '')
            return identifier
        end
    end
end

function System.IsPlayerAdmin(playerId)
    if IsPlayerAceAllowed(playerId, 'command') or GetConvar('sv_lan', '') == 'true' then
        return true
    end

    local xPlayer = System.Players[playerId]

    if xPlayer?.group == 'Admin' then
        return true
    end

    return false
end

function System.GetRandomCardNumber()
    local cardNumber = ''

    for i = 1, 16 do
        cardNumber = cardNumber .. math.random(0, 9)

        if i % 4 == 0 and i ~= 16 then
            cardNumber = cardNumber .. ' '
        end
    end

    return cardNumber
end

function System.GetRandomCardExpiration()
    local month = math.random(1, 12)
    local year = math.random(2024, 2030)

    return ('%02d/%d'):format(month, year)
end
