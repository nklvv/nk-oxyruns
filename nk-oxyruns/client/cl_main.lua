local QBCore = exports['qb-core']:GetCoreObject()

local inOxy = false
local dropOffCount = 0
local hasDropOff = false
local oxyPed
local madeDeal = false
local dropOffBlip
local runs = Config.RunAmount
local onCooldown = false

local peds = {
	'a_m_y_mexthug_01',
	'a_f_o_soucent_01',
	'a_f_o_soucent_02',
	'a_f_y_eastsa_01',
	'a_f_y_eastsa_02',
	'a_f_y_eastsa_03',
	'a_f_y_soucent_01',
	'a_f_y_soucent_02',
	'a_f_y_soucent_03',
	'a_m_m_afriamer_01',
	'a_m_m_eastsa_01',
	'a_m_m_eastsa_02',
	'a_m_m_mexcntry_01',
	'a_m_m_mexlabor_01',
	'a_m_m_socenlat_01',
	'a_m_m_soucent_01',
	'a_m_m_soucent_02',
	'a_m_m_soucent_03',
	'a_m_m_soucent_04',
	'a_m_m_stlat_02',
	'a_m_o_soucent_01',
	'a_m_o_soucent_02',
	'a_m_o_soucent_03',
	'a_m_y_eastsa_01',
	'a_m_y_eastsa_02',
	'a_m_y_latino_01',
	'a_m_y_mexthug_01',
	'a_m_y_soucent_01',
	'a_m_y_soucent_02',
	'a_m_y_soucent_03',
	'a_m_y_soucent_04',
	'a_m_y_stbla_01',
	'a_m_y_stbla_02',
	'a_m_y_stlat_01',
}

Citizen.CreateThread(function()
    local model = 'a_m_m_indian_01'
    RequestModel(model)
    while not HasModelLoaded(model) do
      Wait(0)
    end
    print(Config.StartLocation)
    entity = CreatePed(0, model, Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z - 1, Config.StartLocation.w, false, false)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    SetBlockingOfNonTemporaryEvents(entity, true)

    exports.ox_target:addLocalEntity(entity,  
    {
        {
            name = 'oxyruns-npc',
            event = "nk-oxyruns:startrun",
            icon = "fas fa-pills",
            label = "Start Oxy Run ($1000)",
            distance = 1.5, 
        }
    })
end)

local CreateDropOffPed = function(coords)
	if oxyPed ~= nil then return end
	local model = peds[math.random(#peds)]
	local hash = GetHashKey(model)

    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
	oxyPed = CreatePed(5, hash, coords.x, coords.y, coords.z-1, coords.w, true, true)
	while not DoesEntityExist(oxyPed) do Wait(10) end
	ClearPedTasks(oxyPed)
    ClearPedSecondaryTask(oxyPed)
    TaskSetBlockingOfNonTemporaryEvents(oxyPed, true)
    SetPedFleeAttributes(oxyPed, 0, 0)
    SetPedCombatAttributes(oxyPed, 17, 1)
    SetPedSeeingRange(oxyPed, 0.0)
    SetPedHearingRange(oxyPed, 0.0)
    SetPedAlertness(oxyPed, 0)
    SetPedKeepTask(oxyPed, true)
	FreezeEntityPosition(oxyPed, true)
	Wait(2500) -- QB target sometimes dosnt load it straight away and fucks it up, so I just wait a bit.
    exports.ox_target:addLocalEntity(oxyPed, {
        {
			event = "nk-oxyruns:client:DeliverOxy",
			icon = 'fas fa-capsules',
			label = 'Make Deal',
			items = 'package',
        }
    })
end

local CreateDropOffBlip = function(coords)
	dropOffBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(dropOffBlip, 51)
    SetBlipScale(dropOffBlip, 1.0)
    SetBlipAsShortRange(dropOffBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Deliver")
    EndTextCommandSetBlipName(dropOffBlip)
end

local DeleteOxyped = function()
	FreezeEntityPosition(oxyPed, false)
	SetPedKeepTask(oxyPed, false)
	TaskSetBlockingOfNonTemporaryEvents(oxyPed, false)
	ClearPedTasks(oxyPed)
	TaskWanderStandard(oxyPed, 10.0, 10)
	SetPedAsNoLongerNeeded(oxyPed)
	Wait(20000)
	DeletePed(oxyPed)
	oxyPed = nil
end

local GetCourse = function()
    onCooldown = true
    local randomLoc = Config.Locations[math.random(#Config.Locations)]
    dropOffCount += 1
    CreateDropOffBlip(randomLoc)
    CreateDropOffPed(randomLoc)
end

RegisterNetEvent('nk-oxyruns:startrun', function()
    if inOxy then
		exports['erp_notifications']:SendAlert('error', 'Вече правиш окси рън!', 6000)
    else
        if QBCore.Functions.GetPlayerData().money.cash >= Config.StartOxyPayment then
            inOxy = true
            runs = Config.RunAmount
            TriggerServerEvent('nk-oxyruns:server:giveItems', runs)
			exports['erp_notifications']:SendAlert('inform', 'Изчакай докато шефчето ти намери курс!', 6000)
            Wait(math.random(10, 20) * 1000)
			exports['erp_notifications']:SendAlert('success', 'Локацията ти е маркирана на GPS-а.', 6000)
            hasDropOff = true
            GetCourse()
        else
			exports['erp_notifications']:SendAlert('error', 'Трябва да имаш минимум $'..Config.StartOxyPayment..' в себе си!', 6000)
        end
    end
end)

RegisterNetEvent('nk-oxyruns:client:DeliverOxy', function()
	if madeDeal then return end
	local ped = PlayerPedId()
	if not IsPedOnFoot(ped) then return end
	if #(GetEntityCoords(ped) - GetEntityCoords(oxyPed)) < 5.0 then

		madeDeal = true
		exports['qb-target']:RemoveTargetEntity(oxyPed)
		TriggerServerEvent('nk-oxyruns:server:RemoveItem')

		-- if math.random(100) <= Config.CallCopsChance then
		-- 	TriggerEvent("erp-dispatch:oxy-runs")
		-- end

		TaskTurnPedToFaceEntity(oxyPed, ped, 1.0)
		TaskTurnPedToFaceEntity(ped, oxyPed, 1.0)
		Wait(1500)
		PlayAmbientSpeech1(oxyPed, "Generic_Hi", "Speech_Params_Force")
		Wait(1000)

		RequestAnimDict("mp_safehouselost@")
    	while not HasAnimDictLoaded("mp_safehouselost@") do Wait(10) end
    	TaskPlayAnim(ped, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
		Wait(800)
		
		PlayAmbientSpeech1(oxyPed, "Chat_State", "Speech_Params_Force")
		Wait(500)
		RequestAnimDict("mp_safehouselost@")
		while not HasAnimDictLoaded("mp_safehouselost@") do Wait(10) end
		TaskPlayAnim(oxyPed, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
		Wait(3000)

		RemoveBlip(dropOffBlip)
		dropOffBlip = nil

		QBCore.Functions.TriggerCallback('nk-oxyruns:server:Reward', function() end, madeDeal)
		
		Wait(2000)
        print(dropOffCount)
		if dropOffCount == runs then
			exports['erp_notifications']:SendAlert('success', 'Завършихте с доставките си!', 12000)
			inOxy = false
			dropOffCount = 0
            DeleteOxyped()
		    hasDropOff = false
		    madeDeal = false
            onCooldown = false
		else
			exports['erp_notifications']:SendAlert('success', 'Скоро ще ви бъде изпратена следващата локация!', 12000)
            DeleteOxyped()
		    hasDropOff = false
		    madeDeal = false
            onCooldown = false
            Wait(math.random(10, 20) * 1000)
			exports['erp_notifications']:SendAlert('success', 'Скоро ще ви бъде изпратена следващата локация!', 12000)
            GetCourse()
		end
	end
end)

RegisterCommand('endcourse', function()
    inOxy = false
    RemoveBlip(dropOffBlip)
    dropOffBlip = nil
    hasDropOff = false
    DeleteOxyped()
    onCooldown = false
end)
