local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('nk-oxyruns:server:giveItems', function(amount)
    local Player = QBCore.Functions.GetPlayer(source)
    -- exports['qb-inventory']:AddItem(Player.PlayerData.source, 'oxy', amount, true)
    Player.Functions.AddItem('package', amount)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['package'], 'add', amount)
    Player.Functions.RemoveMoney("cash", Config.StartOxyPayment)
end)

RegisterNetEvent('nk-oxyruns:server:RemoveItem', function() 
    local Player = QBCore.Functions.GetPlayer(source)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['package'], 'remove', 1)
    Player.Functions.RemoveItem('package', 1) 
end)

QBCore.Functions.CreateCallback('nk-oxyruns:server:Reward', function(source, cb, madeDeal)
    local Player = QBCore.Functions.GetPlayer(source)

    if madeDeal then
        Player.Functions.AddMoney("cash", math.random(200, 300))
        if math.random(1,100) <= Config.OxyChance then
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['oxy'], 'add', 1)
            Player.Functions.AddItem('oxy', 1)
        end
        if math.random(1,100) <= Config.RareLoot then
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['weapon_pistol'], 'add', 1)
            Player.Functions.AddItem('weapon_pistol', 1)
        end
    end
end)

-- AddEventHandler('onResourceStop', function(resourceName)
--     if resourceName == GetCurrentResourceName() then
--         isFishing = false
--         canFish = false
--     end
-- end)