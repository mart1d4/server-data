System = {}
System.Players = {}
System.Jobs = {}
System.Items = {}
System.DatabaseConnected = false
System.playersByIdentifier = {}

exports('getSharedObject', function()
    return System
end)

local function StartDBSync()
    CreateThread(function()
        while true do
            Wait(10 * 60 * 1000)
            System.SavePlayers()
        end
    end)
end

local function StartPayCheck()
    CreateThread(function()
        while true do
            Wait(Config.PaycheckInterval)

            for player, xPlayer in pairs(System.Players) do
                local job = xPlayer.job.name
                local salary = xPlayer.job.salary

                if salary > 0 then
                    if job == 'Unemployed' then
                        xPlayer.addAccountMoney('bank', salary, "Welfare Check")
                        xPlayer.triggerEvent(
                            'system:notify',
                            player,
                            'Bank',
                            'Welfare Check',
                            'Received Help: $' .. salary,
                            'CHAR_BANK_MAZE',
                            9
                        )
                    else
                        xPlayer.addAccountMoney('bank', salary, "Paycheck")
                        xPlayer.triggerEvent(
                            'system:notify',
                            player,
                            'Bank',
                            'Paycheck',
                            'Received Salary: $' .. salary,
                            'CHAR_BANK_MAZE',
                            9
                        )
                    end
                end
            end
        end
    end)
end

MySQL.ready(function()
    System.DatabaseConnected = true

    local items = MySQL.query.await('SELECT * FROM items')
    for k, item in ipairs(items) do
        System.Items[item.name] = {
            name = item.name,
            weight = item.weight,
            sellPrice = item.sellPrice,
            rarity = item.rarity,
            canRemove = item.canRemove
        }
    end
  
    local jobGrades = MySQL.query.await('SELECT * FROM job_grades')
    for _, grade in ipairs(jobGrades) do
        if not System.Jobs[grade.job_name] then
            System.Jobs[grade.job_name] = {
                name = grade.job_name,
                grades = {
                    [tostring(grade.grade)] = {
                        name = grade.name,
                        grade = grade.grade,
                        salary = grade.salary,
                        skinMale = json.decode(grade.skin_male) or {},
                        skinFemale = json.decode(grade.skin_female) or {},
                    }
                }
            }
        else
            System.Jobs[grade.job_name].grades[tostring(grade.grade)] = {
                name = grade.name,
                grade = grade.grade,
                salary = grade.salary,
                skinMale = json.decode(grade.skin_male) or {},
                skinFemale = json.decode(grade.skin_female) or {},
            }
        end
    end
    
    -- If no jobs in database
    if not jobGrades then
        System.Jobs['Unemployed'] = {
            name = 'Unemployed',
            grades = { ['0'] = {
                name = 'Unemployed',
                grade = 0,
                salary = 200,
                skinMale = {},
                skinFemale = {},
            }}
        }
    end

    print('[^2CORE^7] System initialized!')

    StartDBSync()
    StartPayCheck()
end)
