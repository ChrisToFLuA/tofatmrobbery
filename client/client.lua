local robstateatm = false
local hacked = false
local norob = true
local atm1 = {}
local atm2 = {}
local checkatm = false
local alarm = false
local alarmsound = GetSoundId()
scansound = GetSoundId()
local delaynotify = OptionsATM.delaynotify
local delayblip = OptionsATM.delayblip
local RobberyCooldown = OptionsATM.RobberyCooldown
local hacktime = OptionsATM.hacktime
local stealtime = OptionsATM.stealtime
local track = OptionsATM.tracking
local tracktimer = OptionsATM.trackingtime
local interval = OptionsATM.trackinginterval

lib.locale()							-- start ox_lib locale translations

DeleteObject(props)						-- delete props if script is restarting for example

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
	Citizen.Wait(1000)
	initrobatm()
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

--------------------------------------------------------------------------
------------------------------- dispatchatm ---------------------------------
--------------------------------------------------------------------------
RegisterNetEvent('tofatm:dispatchatm')
AddEventHandler('tofatm:dispatchatm', function(act, coordatm)
    local coord = GetEntityCoords(PlayerPedId(), true)
    local zonesnorob1 = {name = 'sandyshore', coordZ = vector3(1270.46, 3359.40, 46.89), radiusZ = 800.0,}
    local zonesnorob2 = {name = 'paleto', coordZ = vector3(852.12, 6505.71, 22.15), radiusZ = 1300.0,}
    local zonesnorob3 = {name = 'chumach', coordZ = vector3(-3129.04, 765.09, 10.43), radiusZ = 500.0,}
    local zonesnorob4 = {name = 'tataviam', coordZ = vector3(2545.14, 339.03, 108.46), radiusZ = 800.0,}
    local distatm1 = #(coordatm - zonesnorob1.coordZ)
    local distatm2 = #(coordatm - zonesnorob2.coordZ)
    local distatm3 = #(coordatm - zonesnorob3.coordZ)
    local distatm4 = #(coordatm - zonesnorob4.coordZ)
    if distatm1 > zonesnorob1.radiusZ and distatm2 > zonesnorob2.radiusZ and distatm3 > zonesnorob3.radiusZ and distatm4 > zonesnorob4.radiusZ then
        norob = false
    end
    if distatm1 < zonesnorob1.radiusZ or distatm2 < zonesnorob2.radiusZ or distatm3 < zonesnorob3.radiusZ or distatm4 < zonesnorob4.radiusZ then
        TriggerEvent('tofatm:msgnorob')
        norob = true
    end
    if not robstateatm and not norob then  
        TriggerServerEvent('tofatm:onrobatm', coord, act, coordatm)
    end
    if robstateatm and not norob then
        TriggerEvent('tofatm:actionsatm', act, coordatm)
    end 
end)

--------------------------------------------------------------------------
-------------------------- State robstateatm -----------------------------
--------------------------------------------------------------------------
RegisterNetEvent('tofatm:robstateatm')
AddEventHandler('tofatm:robstateatm', function()
	robstateatm = true
    Citizen.Wait(RobberyCooldown)
    robstateatm = false
	hacked = false
	stole = false
    checkatm = false
end)

--------------------------------------------------------------------------
------------------------------- actionsatm -------------------------------
--------------------------------------------------------------------------
RegisterNetEvent('tofatm:actionsatm')
AddEventHandler('tofatm:actionsatm', function(act, coordatm)
    TriggerEvent('tofatm:checkatm', act, coordatm)
    Citizen.Wait(500)
    if act == 'hack' and hacked then
		TriggerEvent('tofatm:msgalreadyhack')
    elseif act == 'hack' and not hacked then
		hackanimation(coordatm)
        hacked = true
        TriggerEvent('tofatm:alarm', coordatm)
	end
    if act == 'steal' and not hacked then
		TriggerEvent('tofatm:msghackfirst')
	elseif act == 'steal' and stole then
		TriggerEvent('tofatm:msgalreadystole')
    elseif act == 'steal' and not stole and checkatm then
        stole = true
        stealanimation()
		TriggerServerEvent('tofatm:lootmoney_s')
	end
end)

--------------------------------------------------------------------------
------------------------------- alarm -------------------------------
--------------------------------------------------------------------------
RegisterNetEvent('tofatm:alarm')
AddEventHandler('tofatm:alarm', function(coordatm)
    PlaySoundFromCoord(alarmsound, "VEHICLES_HORNS_AMBULANCE_WARNING", coordatm.x, coordatm.y, coordatm.z, '', true, 1, false ) 
    Citizen.Wait(60000)
    StopSound(alarmsound)
end)

--------------------------------------------------------------------------
------------------------------- checkatm ---------------------------------
--------------------------------------------------------------------------
RegisterNetEvent('tofatm:checkatm')
AddEventHandler('tofatm:checkatm', function(act, coordatm)
    if act == 'hack' and hacked then return end
    if act == 'hack' and not hacked then atm1 = coordatm end
    if act == 'steal' and stole then return end
    if act == 'steal' and not stole and not hacked then return end
    if act == 'steal' and  not stole and hacked then 
        atm2 = coordatm
        if atm1 == atm2 then
            checkatm = true
        else
            checkatm = false
            TriggerEvent('tofatm:msgnoglitch')
        end
    end
end)

--------------------------------------------------------------------------
------------------------------- tracking ---------------------------------
--------------------------------------------------------------------------
RegisterNetEvent('tofatm:tracking_c')
AddEventHandler('tofatm:tracking_c', function()
    while true do
        if GetGameTimer() <= trackingtimer then
            local coordsPt = GetEntityCoords(PlayerPedId())
            TriggerServerEvent('tofatm:tracking_s', coordsPt)
            Citizen.Wait(interval)    
        else
            RemoveBlip(BlipT)
            break
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('tofatm:bliptracking')
AddEventHandler('tofatm:bliptracking', function(coordsPt)
    if BlipT then
        SetBlipCoords(BlipT, coordsPt.x, coordsPt.y, coordsPt.z)
    else
    BlipT = AddBlipForCoord(coordsPt.x,coordsPt.y,coordsPt.z)
    SetBlipSprite(BlipT,  1)
    SetBlipColour(BlipT,  1)
    SetBlipAlpha(BlipT,  250)
    SetBlipDisplay(BlipT, 4)
    SetBlipScale(BlipT, 0.6)
    SetBlipFlashes(BlipT, true)
    SetBlipAsShortRange(BlipT,  true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Robber tracking')
    EndTextCommandSetBlipName(BlipT)
    end
end)

--------------------------------------------------------------------------
-------------------------- progress hack ---------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('tofatm:progresshack')
AddEventHandler('tofatm:progresshack', function()
    ------------------**notification**----------------------
    lib.progressCircle({
        duration = hacktime,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
        },
    })
    ------------------**fin notification**-----------------
    TriggerEvent('tofatm:msghacksuccess')
end)

--------------------------------------------------------------------------
-------------------------- progress steal --------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('tofatm:progresssteal')
AddEventHandler('tofatm:progresssteal', function()
    ------------------**notification**----------------------
    lib.progressCircle({
        duration = stealtime,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
        },
    })
    ------------------**fin notification**-----------------
    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    PlaySound(-1, 'ROBBERY_MONEY_TOTAL', 'HUD_FRONTEND_CUSTOM_SOUNDSET', 0, 0, 1)
    TriggerEvent('tofatm:msgstealsuccess')
    if track then
        trackingtimer = GetGameTimer() + tracktimer
        TriggerEvent('tofatm:tracking_c')    
    end
end)

--------------------------------------------------------------------------
-------------------------- msg noglitch--------------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('tofatm:msgnoglitch')
AddEventHandler('tofatm:msgnoglitch', function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('no_glitch'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(10000)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg norob--------------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('tofatm:msgnorob')
AddEventHandler('tofatm:msgnorob', function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('no_robhere'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(10000)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg nocard--------------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('tofatm:msgnocard')
AddEventHandler('tofatm:msgnocard', function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('no_card'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg hackfirst ---------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('tofatm:msghackfirst')
AddEventHandler('tofatm:msghackfirst', function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('hack_first'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg alreadyhack -------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('tofatm:msgalreadyhack')
AddEventHandler('tofatm:msgalreadyhack', function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('already_hack'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg alreadystole -------------------------------
--------------------------------------------------------------------------

RegisterNetEvent('tofatm:msgalreadystole')
AddEventHandler('tofatm:msgalreadystole', function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('already_stole'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg steal--------------------------------------
--------------------------------------------------------------------------

RegisterNetEvent("tofatm:msglootmoney_c")
AddEventHandler("tofatm:msglootmoney_c", function(count)
    ------------------**notification**----------------------
    lib.showTextUI(locale('stole')..count..' $', {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg hacksuccess -------------------------------
--------------------------------------------------------------------------

RegisterNetEvent("tofatm:msghacksuccess")
AddEventHandler("tofatm:msghacksuccess", function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('hack_success'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

--------------------------------------------------------------------------
-------------------------- msg stealsuccess -------------------------------
--------------------------------------------------------------------------

RegisterNetEvent("tofatm:msgstealsuccess")
AddEventHandler("tofatm:msgstealsuccess", function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('steal_success'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

-------------------------------------------------------------------------
------------------------ msg timer --------------------------------------
-------------------------------------------------------------------------

RegisterNetEvent("toffleeca:msgnottimer")
AddEventHandler("toffleeca:msgnottimer", function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('robbing_inprogress'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(5000)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

-------------------------------------------------------------------------
------------------------ msg nbcops -------------------------------------
-------------------------------------------------------------------------

RegisterNetEvent("toffleeca:msgnocops")
AddEventHandler("toffleeca:msgnocops", function()
    ------------------**notification**----------------------
    lib.showTextUI(locale('no_cops') {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(5000)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

-------------------------------------------------------------------------
------------------------- msg LSPD --------------------------------------
-------------------------------------------------------------------------

RegisterNetEvent("tofatm:msgpolice")
AddEventHandler("tofatm:msgpolice", function(coordsP)
    ------------------**notification**----------------------
    lib.showTextUI(locale('alarm_notify'), {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = 'red',
            color = 'white'
        }
    })
    Citizen.Wait(30000)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
	Citizen.Wait(delaynotify)
    TriggerEvent('tofatm:blipPolice', coordsP)
end)

-------------------------------------------------------------------------
------------------------ blip LSPD --------------------------------------
-------------------------------------------------------------------------

RegisterNetEvent('tofatm:blipPolice')
AddEventHandler('tofatm:blipPolice', function(coordsP)
    Blip = AddBlipForCoord(coordsP.x,coordsP.y,coordsP.z)
    SetBlipSprite(Blip,  500)
    SetBlipColour(Blip,  1)
    SetBlipAlpha(Blip,  250)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, 1.2)
    SetBlipFlashes(Blip, true)
    SetBlipAsShortRange(Blip,  true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('ATM Robbery')
    EndTextCommandSetBlipName(Blip)
    Wait(delayblip)
    RemoveBlip(Blip)
end)

-------------------------- Command dev ------------------------------------

RegisterCommand('robatm', function(source, args, rawCommand)
    initrobatm()
end)