System = {}

-- Players
System.Players = {}
System.PlayersByIdentifier = {}

-- Misc Data
System.Jobs = {}
System.Items = {}

-- Database
System.DatabaseConnected = false

-- Save Players Every 20 Minutes
local function StartDBSync()
    CreateThread(function()
        while true do
            Wait(20 * 60 * 1000)
            System.SavePlayers()
        end
    end)
end


-- Pay Players Every 30 Minutes
local function StartPayCheck()
    CreateThread(function()
        while true do
            Wait(30 * 60 * 1000)

            for player, xPlayer in pairs(System.Players) do
                local job = xPlayer.job.name
                local salary = xPlayer.job.salary

                if job == nil or salary == nil then
                    job = 'Unemployed'
                    salary = 600
                end

                if salary > 0 then
                    xPlayer.addAccountMoney('Bank', salary)
                    xPlayer.triggerEvent(
                        'system:notify',
                        player,
                        'Bank',
                        job == 'Unemployed' and 'Welfare Check' or 'Paycheck',
                        'Received ' .. job == 'Unemployed' and 'Help' or 'Salary' .. ': $' .. salary,
                        'CHAR_BANK_MAZE',
                        9
                    )
                end
            end
        end
    end)
end


MySQL.ready(function()
    System.DatabaseConnected = true

    local items = MySQL.query.await('SELECT * FROM items')
    for _, item in ipairs(items) do
        System.Items[item.name] = {
            weight = item.weight,
            foodIntake = item.food_intake or nil,
            waterIntake = item.water_intake or nil,
            sellPrice = item.sell_price,
            rarity = item.rarity,
            canRemove = item.can_remove,
        }
    end

    local jobGrades = MySQL.query.await('SELECT * FROM job_grades')
    for _, grade in ipairs(jobGrades) do
        if not System.Jobs[grade.job_name] then
            -- Job isn't listed yet, add it
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
            -- Job is already listed, add grade
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
            grades = {
                ['0'] = {
                    name = 'Unemployed',
                    grade = 0,
                    salary = 200,
                    skinMale = {},
                    skinFemale = {},
                }
            }
        }
    end

    print('[^2INFO^7] System initialized!')

    StartDBSync()
    StartPayCheck()
end)

exports('getSharedObject', function()
    return System
end)
