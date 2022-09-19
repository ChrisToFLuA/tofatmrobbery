local nextrobATM = 0
local mincops = OptionsATM.mincops
local inventory = OptionsATM.inventory
local item = OptionsATM.item
local RobberyCooldown = OptionsATM.RobberyCooldown

lib.versionCheck('ChrisToFLuA/tofatmrobbery')

local function SetnextrobATM()
    nextrobATM = GetGameTimer() + RobberyCooldown
end

RegisterServerEvent('tofatm:onrobatm')
AddEventHandler('tofatm:onrobatm', function(coordP, act, coordatm)
    local xPlayer = ESX.GetPlayerFromId(source)
	if inventory == 'oxinventory' then
		card = exports.ox_inventory:GetItem(source, item, nil, false)
	elseif inventory == 'default' then
		card = xPlayer.getInventoryItem(item)
	end
	local copsOnline = ESX.GetExtendedPlayers('job', 'police')
    if #copsOnline >= mincops then
        if nextrobATM ~= 0 then
            if GetGameTimer() < nextrobATM then
                TriggerClientEvent('tofatm:msgnottimer', xPlayer.source)
            end
            if GetGameTimer() > nextrobATM then
				if card and card.count > 0 then
                	SetnextrobATM()
                	TriggerClientEvent('tofatm:robstateatm', xPlayer.source)
					Citizen.Wait(300)
					TriggerClientEvent('tofatm:actionsatm', xPlayer.source, act, coordatm)
                	Citizen.Wait(500)
                	for j=1, #copsOnline, 1 do
                    	local xPlayerx = copsOnline[j]
                    	TriggerClientEvent('tofatm:msgpolice', xPlayerx.source, coordP)
                	end
					if act == 'hack' then
						if inventory == 'oxinventory' then
							exports.ox_inventory:RemoveItem(xPlayer.source, item, 1)
						elseif inventory == 'default' then
							xPlayer.removeInventoryItem(item, 1)
						end
					end
				else
					TriggerClientEvent('tofatm:msgnocard', xPlayer.source)
				end
            end
        end
        if nextrobATM == 0 then
			if card and card.count > 0 then
            	TriggerClientEvent('tofatm:robstateatm', xPlayer.source)
            	SetnextrobATM()
				Citizen.Wait(300)
				TriggerClientEvent('tofatm:actionsatm', xPlayer.source, act, coordatm)
            	Citizen.Wait(500)
            	for j=1, #copsOnline, 1 do
                	local xPlayerx = copsOnline[j]
                	TriggerClientEvent('tofatm:msgpolice', xPlayerx.source, coordP)
            	end
				if act == 'hack' then
					if inventory == 'oxinventory' then
						exports.ox_inventory:RemoveItem(xPlayer.source, item, 1)
					elseif inventory == 'default' then
						xPlayer.removeInventoryItem(item, 1)
					end
				end
			else
				TriggerClientEvent('tofatm:msgnocard', xPlayer.source)
			end
        end
    else
        TriggerClientEvent('tofatm:msgnocops', xPlayer.source)
    end
end)

RegisterNetEvent('tofatm:lootmoney_s')
AddEventHandler('tofatm:lootmoney_s', function()
    local xPlayer = ESX.GetPlayerFromId(source)
	local stolemoney = math.random(8215, 12125)
	xPlayer.addAccountMoney('black_money', stolemoney)
	TriggerClientEvent('tofatm:msglootmoney', xPlayer.source, stolemoney)
end)

RegisterNetEvent('tofatm:tracking_s')
AddEventHandler('tofatm:tracking_s', function(coordsPt)
    trackingP(coordsPt)
end)