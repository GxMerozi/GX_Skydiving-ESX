ESX               = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('gamax_skydive:addpara')
AddEventHandler('gamax_skydive:addpara', function()
	local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  
  if xPlayer.getMoney() >= Config.priceforparachute then  
    xPlayer.addWeapon('gadget_parachute', 1)
    xPlayer.removeMoney(Config.priceforparachute)
  else
    xPlayer.showNotification("You Don't have money!")
  end 

end)

RegisterServerEvent('gamax_skydive:server:spawned')
AddEventHandler('gamax_skydive:server:spawned', function(value, plate)
  TriggerClientEvent('gamax_skydive:client:spawned', -1, value, plate)
  print(value)
end)