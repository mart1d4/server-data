local playerLoaded = false
local isMenuActive = false
local isTooltipActive = false
local activeBlips, bankPoints, atmPoints, markerPoints = {}, {}, {}, {}

RegisterNetEvent('system:playerLoaded', function()
    CreateBlips()

    local data = {
        ped = PlayerPedId(),
        coord = GetEntityCoords(PlayerPedId())
    }

    playerLoaded = true

    CreateThread(function ()
        while playerLoaded do
            data.ped = PlayerPedId()
            data.coord = GetEntityCoords(data.ped)
            bankPoints, atmPoints, markerPoints = {}, {}, {}

            if IsPedOnFoot(data.ped) and not isMenuActive then
                for i = 1, #Config.AtmModels do
                    local atm = GetClosestObjectOfType(data.coord.x, data.coord.y, data.coord.z, 0.7, Config.AtmModels[i], false, false, false)
                    if atm ~= 0 then
                        atmPoints[#atmPoints+1] = GetEntityCoords(atm)
                    end
                end

                for i = 1, #Config.Banks do
                    local bankDistance = #(data.coord - Config.Banks[i].Position.xyz)

                    if bankDistance <= 0.7 then
                        bankPoints[#bankPoints+1] = Config.Banks[i].Position.xyz
                    end

                    if Config.ShowMarker and bankDistance <= (Config.DrawMarker or 10) then
                        markerPoints[#markerPoints+1] = Config.Banks[i].Position.xyz
                    end
                end
            end

            if next(bankPoints) and not isTooltipActive and not isMenuActive then
                ShowTooltip(true, false)
            end

            if next(atmPoints) and not isTooltipActive and not isMenuActive then
                ShowTooltip(true, true)
            end

            if ((not next(bankPoints) and not next(atmPoints)) or isMenuActive) and isTooltipActive then
                ShowTooltip(false, false)
            end

            Wait(1000)
        end
    end)

    CreateThread(function()
        local wait = 1000
        while playerLoaded do
            if next(markerPoints) then
                for i = 1, #markerPoints do
                    DrawMarker(
                        20,
                        markerPoints[i].x,
                        markerPoints[i].y,
                        markerPoints[i].z,
                        0.0, 0.0, 0.0, 0.0,
                        0.0, 0.0, 0.3, 0.2,
                        0.2, 187, 255, 0,
                        255, false, true, 2,
                        false, nil, nil, false
                    )
                end
                wait = 0
            end
            Wait(wait)
        end
    end)
end)

function ShowTooltip(show, atm)
    isTooltipActive = show

    CreateThread(function()
        while isTooltipActive do
            SetTextComponentFormat("STRING")
            AddTextComponentString("Press ~INPUT_PICKUP~ to access the bank.")
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)

            if IsControlJustReleased(0, 38) then
                if isMenuActive then
                    ShowMenu(false)
                else
                    ShowMenu(true, atm)
                end
            end

            Wait(0)
        end
    end)
end

function CreateBlips()
    local tmpActiveBlips = {}

    for i = 1, #Config.Banks do
        local position = Config.Banks[i].Position
        local bInfo = Config.Banks[i].Blip
        local blip = AddBlipForCoord(position.x, position.y, position.z)

        SetBlipSprite(blip, bInfo.Sprite)
        SetBlipScale(blip, bInfo.Scale)
        SetBlipColour(blip, bInfo.Color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(bInfo.Label)
        EndTextCommandSetBlipName(blip)

        tmpActiveBlips[#tmpActiveBlips + 1] = blip
    end

    activeBlips = tmpActiveBlips
end

function ShowMenu(show, isATM)
    isMenuActive = show
    ClearPedTasks(PlayerPedId())
    DisplayRadar(not show)

    if not show then
        ClearTimecycleModifier()

        SendNUIMessage({
            action = 'Banking',
            data = json.encode({ show = false })
        })
        SetNuiFocus(false, false)
        
        return
    end

    -- Get player's banking data before opening the menu
    TriggerServerEvent('banking:getPlayerData')
    RegisterNetEvent('banking:usePlayerData', function(data)
        SetTimecycleModifier("hud_def_blur")

        SendNUIMessage({
            action = 'Banking',
            data = json.encode({
                show = true,
                isATM = isATM,
                accounts = {
                    cash = data.cash,
                    bank = data.bank,
                },
                card = {
                    bankName =  'Bank of Los Santos',
                    cardNumber = data.cardNumber,
                    cardExpiration = data.expiration,
                    cardHolder = data.name,
                    pincode = data.pincode,
                },
                transactionsData = data.transactionHistory
            })
        })

        SetNuiFocus(true, true)
    end)
end

RegisterNUICallback('CloseMenu', function()
    ShowMenu(false)
end)

RegisterNUICallback('Withdraw', function(data)
    TriggerServerEvent('banking:withdraw', tonumber(data.amount), data.message)
end)

RegisterNUICallback('Deposit', function(data)
    TriggerServerEvent('banking:deposit', tonumber(data.amount), data.message)
end)

RegisterNUICallback('Transfer', function(data)
    TriggerServerEvent('banking:transfer', tonumber(data.amount), data.playerId, data.message)
end)

RegisterNUICallback('Pincode', function(data)
    TriggerServerEvent('banking:pincode', data.pincode)
end)

function LoadNpc(index, netID)
    CreateThread(function()
        while not NetworkDoesEntityExistWithNetworkId(netID) do
            Wait(200)
        end

        local npc = NetworkGetEntityFromNetworkId(netID)
        TaskStartScenarioInPlace(npc, Config.Peds[index].Scenario, 0, true)
        SetEntityProofs(npc, true, true, true, true, true, true, true, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        FreezeEntityPosition(npc, true)
        SetPedCanRagdollFromPlayerImpact(npc, false)
        SetPedCanRagdoll(npc, false)
        SetEntityAsMissionEntity(npc, true, true)
        SetEntityDynamic(npc, false)
    end)
end

RegisterNetEvent('banking:spawnPeds', function(netIdTable)
    for i = 1, #netIdTable do
        LoadNpc(i, netIdTable[i])
    end
end)

RegisterNetEvent('banking:updateData', function(data)
    SendNUIMessage({
        action = 'BankingUpdate',
        data = json.encode({
            accounts = {
                cash = data.cash,
                bank = data.bank,
            },
            card = {
                bankName =  'Bank of Los Santos',
                cardNumber = data.cardNumber,
                cardExpiration = data.expiration,
                cardHolder = data.name,
                pincode = data.pincode,
            },
            transactionsData = data.transactionHistory
        })
    })
end)

RegisterNetEvent('banking:sendError', function(errorObject)
    SendNUIMessage({
        action = 'BankingError',
        error = json.encode(errorObject)
    })
end)

RegisterNetEvent('banking:sendValidation', function(validationObject)
    SendNUIMessage({
        action = 'BankingValidation',
        error = json.encode(validationObject)
    })
end)
