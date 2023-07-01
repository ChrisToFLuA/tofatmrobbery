------------------------------------- ** configurable Options ** ----------------------------------------
OptionsATM = {}
OptionsATM.inventory = 'oxinventory'					-- configure here the invenotry use (oxinventory | default)
OptionsATM.props = 	921401054					        -- model props
OptionsATM.delaynotify = math.random(20000, 35000)	    -- delay in ms for the cops notify appears for them
OptionsATM.delayblip = 60000							-- delay in ms for the cops blip
OptionsATM.hacktime = 30000							-- time in ms to hack the atm
OptionsATM.stealtime = 30000							-- time in ms to steal money in the atm
OptionsATM.RobberyCooldown = 1800000                   -- configure the cooldown in ms between 2 atmrobbery  
OptionsATM.mincops = 0                                 -- configure the minimum count of police to start the robbery
OptionsATM.tracking = true                             -- configure if the player is tracking at the end of the robbery
OptionsATM.trackingtime = 60000                        -- configure in ms how much time the player in tracking
OptionsATM.trackinginterval = 6000                     -- configure in ms the interval between 2 blips
OptionsATM.item = 'card_hack'                          -- configure item needed to hack the atm

------------------------------------** end configurable Options **---------------------------------------

--------------------------------------------------------------------------------------------------------
------------------------------------- ** DON'T MODIFY CODE BELOW ** ------------------------------------
--------------------------------------------------------------------------------------------------------

local props = OptionsATM.props
local hacktimer = OptionsATM.hacktime
local stealtimer = OptionsATM.stealtime

----------------------------- ** init function ** ---------------------------
function initrobatm()
    Citizen.CreateThread(function()
        -- you can modify / add jobs here --
        local jobs = {
            {name = 'police'},          -- LSPD in service
            {name = 'offpolice'},       -- LSPD out of service
            {name = 'ambulance'},       -- EMS in service
            {name = 'offambulance'},    -- EMS out of service
        }
        
        -- Add a variable to track if the player's job matches any job name
        local isJobMatch = false
        
        for a = 1, #jobs, 1 do
            local jobsname = jobs[a].name
            if ESX.PlayerData.job.name == jobsname then
                isJobMatch = true
                break -- Exit the loop if a match is found
            end
        end
        
        -- Check if the player's job doesn't match any job name
        if not isJobMatch then
            exports.ox_target:addModel({-1364697528, 506770882, -870868698, -1126237515}, {
                label = locale('hack_atm'),
                icon = "fas fa-credit-card",
                distance = 1.5,
                onSelect = function(data)
                    local act = 'hack'
                    local coordatm = GetEntityCoords(data.entity)
                    TriggerEvent('pdl_atmrob:dispatchatm', act, coordatm)
                end,
            })
            exports.ox_target:addModel({-1364697528, 506770882, -870868698, -1126237515}, {
                label = locale('steal_money'),
                icon = "fas fa-sack-dollar",
                distance = 1.5,
                onSelect = function(data)
                    local act = 'steal'
                    local coordatm = GetEntityCoords(data.entity)
                    TriggerEvent('pdl_atmrob:dispatchatm', act, coordatm)
                end,
            })
        end
    end)
end
------------------- ** tracking function ** --------------------
function trackingP(coordPt)
    local copsOnline = ESX.GetExtendedPlayers('job', 'police')
    for k=1, #copsOnline, 1 do
        local xPlayerx = copsOnline[k]
        TriggerClientEvent('tofatm:bliptracking', xPlayerx.source, coordPt)
    end
end

------------------- ** steal animation ** --------------------
function stealanimation()
    FreezeEntityPosition(ped, true)
    loaddict('anim@heists@prison_heistig1_p1_guard_checks_bus')
    Citizen.Wait(500)
    TriggerEvent('tofatm:progresssteal')
    playerAnim(PlayerPedId(), 'anim@heists@prison_heistig1_p1_guard_checks_bus', 'loop')
    Citizen.Wait(stealtimer)
end
------------------- ** hack animation ** --------------------
function hackanimation(coordatm)
    loadmodel('p_ld_id_card_01')
    local ped = PlayerPedId()
    local pedco = GetEntityCoords(PlayerPedId())
    IdProp = CreateObject(GetHashKey('p_ld_id_card_01'), pedco, 1, 1, 0)
    local boneIndex = GetPedBoneIndex(PlayerPedId(), 28422)
    AttachEntityToEntity(IdProp, ped, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, 'PROP_HUMAN_ATM', 0, true)
    Citizen.Wait(1500)
    DetachEntity(IdProp, false, false)
    DeleteEntity(IdProp)
    Wait(6000)
    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(ped, true)
    loaddict('amb@world_human_tourist_map@male@base')
    local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
	local boneIndex = GetPedBoneIndex(PlayerPedId(), 28422)
	prop = CreateObject(props, x, y, z, true, true, true)
	AttachEntityToEntity(prop, PlayerPedId(), boneIndex, 0.0, -0.03, 0.0, 20.0, -90.0, 0.0, true, true, false, true, 1, true)
    Citizen.Wait(500)
    PlaySoundFromEntity(scansound, 'SCAN', prop, 'EPSILONISM_04_SOUNDSET', true, 0)
    TriggerEvent('tofatm:progresshack')
    playerAnim(PlayerPedId(), 'amb@world_human_tourist_map@male@base', 'base')
    Citizen.Wait(hacktimer)
    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(ped, false)
    DeleteObject(prop)
    StopSound(scansound)
end
------------------- ** loadmodel ** --------------------
function loadmodel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(10)
    end
end
------------------- ** loadanimdict ** --------------------
function loaddict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end
------------------- ** playanim ** --------------------
function playerAnim(ped, animDictionary, animationName)
    if (DoesEntityExist(ped) and not IsEntityDead(ped)) then
        loaddict(animDictionary)
        TaskPlayAnim(ped, animDictionary, animationName, 1.0, -1.0, -1, 1, 1, true, true, true)
    end
end
------------------- ** round ** --------------------
function round(n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end
