local spawnedPeds, netIdTable = {}, {}
local playerData = {}

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    for i = 1, #Config.Peds do
        local model = Config.Peds[i].Model
        local coords = Config.Peds[i].Position
        spawnedPeds[i] = CreatePed(0, model, coords.x, coords.y, coords.z, coords.w, true, true)
        netIdTable[i] = NetworkGetNetworkIdFromEntity(spawnedPeds[i])
        while not DoesEntityExist(spawnedPeds[i]) do Wait(50) end
    end

    Wait(100)
    TriggerClientEvent('banking:spawnPeds', -1, netIdTable)
end)

AddEventHandler('onResourceStop', function(resourceName)
    for i = 1, #spawnedPeds do
        DeleteEntity(spawnedPeds[i])
        spawnedPeds[i] = nil
    end
end)

AddEventHandler('system:playerLoaded', function(playerId)
    TriggerClientEvent('banking:spawnPeds', playerId, netIdTable)
end)

RegisterServerEvent("banking:fetchData", function(isATM)
    local xPlayer = System.GetPlayerFromId(source)

    playerData = {
        name = xPlayer.name,
        cash = xPlayer.getAccountMoney('Cash'),
        bank = xPlayer.getAccountMoney('Bank'),
        cardNumber = xPlayer.banking.cardNumber,
        expiration = xPlayer.banking.cardExpiration,
        pincode = xPlayer.banking.cardPincode,
        transactions = xPlayer.banking.transactionHistory,
    }

    TriggerClientEvent('banking:fetchData', source, playerData, isATM)
end)

RegisterServerEvent("banking:withdraw", function(amount, message)
    local xPlayer = System.GetPlayerFromId(source)

    if xPlayer.getAccountMoney('Bank') >= amount then
        local transaction = {
            type = 'withdraw',
            amount = amount,
            message = message or '',
            time = os.time() * 1000,
        }

        xPlayer.removeAccountMoney('Bank', amount)
        xPlayer.addAccountMoney('Cash', amount)
        xPlayer.addBankingTransaction(transaction)

        table.insert(playerData.transactions, transaction)
        playerData.cash = xPlayer.getAccountMoney('Cash')
        playerData.bank = xPlayer.getAccountMoney('Bank')

        TriggerClientEvent('banking:updateData', source, playerData)
        TriggerClientEvent('banking:sendValidation', source, {
            type = 'withdraw',
            message = 'Successfully withdrew $' .. amount .. ' from your bank account.',
        })
    else
        TriggerClientEvent('banking:sendError', source, {
            type = 'withdraw',
            message = 'Something went wrong',
        })
    end
end)

RegisterServerEvent("banking:deposit", function(amount, message)
    local xPlayer = System.GetPlayerFromId(source)

    if xPlayer.getAccountMoney('Cash') >= amount then
        local transaction = {
            type = 'deposit',
            amount = amount,
            message = message or '',
            time = os.time() * 1000,
        }

        xPlayer.removeAccountMoney('Cash', amount)
        xPlayer.addAccountMoney('Bank', amount)
        xPlayer.addBankingTransaction(transaction)

        table.insert(playerData.transactions, transaction)
        playerData.cash = xPlayer.getAccountMoney('Cash')
        playerData.bank = xPlayer.getAccountMoney('Bank')

        TriggerClientEvent('banking:updateData', source, playerData)
        TriggerClientEvent('banking:sendValidation', source, {
            type = 'deposit',
            message = 'Successfully deposited $' .. amount .. ' into your bank account.',
        })
    else
        TriggerClientEvent('banking:sendError', source, {
            type = 'deposit',
            message = 'Something went wrong',
        })
    end
end)

RegisterServerEvent("banking:transfer", function(amount, playerId, message)
    local xPlayer = System.GetPlayerFromId(source)

    if xPlayer.getAccountMoney('Bank') >= amount and xPlayer.identifier ~= playerId then
        local targetPlayer = System.GetPlayerFromIdentifier(playerId)

        if targetPlayer then
            local transaction = {
                type = 'transfer',
                amount = amount,
                message = message or '',
                time = os.time() * 1000,
                target = targetPlayer.name,
            }

            xPlayer.removeAccountMoney('Bank', amount)
            targetPlayer.addAccountMoney('Bank', amount)
            xPlayer.addBankingTransaction(transaction)

            table.insert(playerData.transactions, transaction)
            playerData.cash = xPlayer.getAccountMoney('Cash')
            playerData.bank = xPlayer.getAccountMoney('Bank')

            TriggerClientEvent('banking:updateData', source, playerData)
            TriggerClientEvent('banking:sendValidation', source, {
                type = 'transfer',
                message = 'Successfully transferred $' .. amount .. ' to ' .. targetPlayer.name .. '.',
            })
        else
            TriggerClientEvent('banking:sendError', source, {
                type = 'transfer',
                message = 'Player not found.',
            })
        end
    else
        TriggerClientEvent('banking:sendError', source, {
            type = 'transfer',
            message = 'Something went wrong',
        })
    end
end)

RegisterServerEvent("banking:pincode", function(pincode)
    local playerId = source
    local xPlayer = System.GetPlayerFromId(playerId)

    if string.len(pincode) == 4 then
        xPlayer.setBanking('cardPincode', pincode)
        playerData.pincode = pincode

        MySQL.update.await(
            'UPDATE users SET banking = ? WHERE id = ?',
            {
                json.encode(xPlayer.banking),
                xPlayer.identifier
            }
        )

        TriggerClientEvent('banking:updateData', playerId, playerData)
        xPlayer.triggerEvent(
            'system:notify',
            playerId,
            'Bank',
            'Account Security',
            'Successfully changed your pincode to ' .. pincode .. '.',
            'CHAR_BANK_MAZE',
            2
        )
        TriggerClientEvent('banking:sendValidation', playerId, {
            type = 'pincode',
            message = 'Successfully changed your pincode to ' .. pincode .. '.',
        })
    else
        TriggerClientEvent('banking:sendError', playerId, {
            type = 'pincode',
            message = 'Something went wrong',
        })
    end
end)
