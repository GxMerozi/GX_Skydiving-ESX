ESX = nil
Citizen.CreateThread(function(spawnPoint)
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local purchase = false 
local playerIdx = GetPlayerFromServerId(source)
local caller = GetPlayerPed(playerIdx)
local globalveh = nil
local hyo23 = false 
local banamera = false


local passenger = false
local syncHeli = 0

function CreatePlane(spawnPoint, target)
	if passenger then return; end
	modelHash = GetHashKey(Config.spawnedheli)
	pilotModel = GetHashKey(Config.pilot)
	
	RequestModel(modelHash)
	while not HasModelLoaded(modelHash) do
	Citizen.Wait(0)
	end
	
	RequestModel(pilotModel)
	while not HasModelLoaded(pilotModel) do
	Citizen.Wait(0)
	end
	
	if HasModelLoaded(modelHash) and HasModelLoaded(pilotModel) then
		--ClearAreaOfEverything(v.coords.x, v.coords.y, v.coords.z, 10, false, false, false, false, false)
		if DoesEntityExist(globalveh) then
			--ESX.Game.DeleteVehicle(globalveh)
		end
		
		--AirPlane = CreateVehicle(modelHash, -1581.38, -569.09, 116.33, 109.50, false, false)
		ESX.Game.SpawnVehicle(modelHash, vector3(spawnPoint.x,spawnPoint.y,spawnPoint.z),250.0, function(AirPlane)
			--SetVehicleOnGroundProperly(AirPlane)
			SetVehicleEngineOn(AirPlane, true, true, true)
			SetEntityProofs(AirPlane, true, true, true, true, true, true, true, false)
			pilot = CreatePedInsideVehicle(AirPlane, 6, pilotModel, -1, true, false)
			SetEntityAsMissionEntity(AirPlane, true, true)
			SetVehicleHasBeenOwnedByPlayer(AirPlane, true)
			SetBlockingOfNonTemporaryEvents(pilot, true)
			ready = true
			SetVehicleUndriveable(AirPlane, true)
			TaskWarpPedIntoVehicle(caller, AirPlane, 0)
			globalveh = AirPlane
			TriggerServerEvent('gamax_skydive:server:spawned', true , GetVehicleNumberPlateText(AirPlane))
			SetVehicleDoorsLockedForAllPlayers(AirPlane, true)
			SetPedCanBeDraggedOut(pilot, false)

			Citizen.Wait(1000*Config.timetotakeoff)
			TriggerServerEvent('gamax_skydive:server:spawned', false , 0)

			TaskVehicleDriveToCoord(pilot, AirPlane, target.x, target.y, target.z, 17.0, 0, modelHash, 2883621, 1, true)
			SetPedKeepTask(pilot, true)
			enroute = true
			while enroute do
				Citizen.Wait(10)
				distanceToTarget = GetDistanceBetweenCoords(target.x, target.y, target.z, GetEntityCoords(AirPlane).x, GetEntityCoords(AirPlane).y, GetEntityCoords(AirPlane).z, true)
				--print(distanceToTarget)
				if distanceToTarget < 10 then
					hyo23 = true
					ESX.Game.DeleteVehicle(AirPlane)
					DeleteEntity(pilot)
					SetEntityAsNoLongerNeeded(pilot)
					SetEntityAsNoLongerNeeded(AirPlane)
					SetPedKeepTask(pilot, false)
					wait(5000)
					DeletePed(pilot)
					ready = false
					ESX.Game.DeleteVehicle(AirPlane)
					banamera = false
					break
				end
			end

		end)
	end
end



function menu_main(spawnPoint, target)
	ESX.UI.Menu.CloseAll()
	local elems = {
        {label = 'buy a parashute', value = 'buy'},
        {label = 'requist a trip', value = 'request'}
    }
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gmx_parashute',{
        title    = 'parashute',
        align = 'center',
        elements = elems
    },
    function(data, menu)
    if data.current.value == 'request' then
		CreatePlane(spawnPoint, target)
		menu.close()
	elseif data.current.value == 'buy' then	
		
		TriggerServerEvent('gamax_skydive:addpara')
		menu.close()
	end
	end,
	function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent('gamax_skydive:client:spawned')
AddEventHandler('gamax_skydive:client:spawned', function(value, heli)
	passenger = value
	syncHeli = heli
end)



Citizen.CreateThread(function()
    while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)

		for k,v in pairs(Config.SkyDive) do
			if (GetDistanceBetweenCoords(coords, v.coords.x, v.coords.y, v.coords.z, true) < 5) then
				--DrawMarker(30, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 50, 50, 204, 100, false, true, 3, true, false, false, false)
				DrawText3Ds(v.coords.x, v.coords.y, v.coords.z, tostring("Press ~b~[E] ~w~to Open the menu"))
				if (IsControlJustReleased(1, 51)) and (GetDistanceBetweenCoords(coords, v.coords.x, v.coords.y, v.coords.z, true) < 5) then
					menu_main(v.spawn,v.target)
				end
			end
		end
       
	end
end)

Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1)
		local ply = PlayerPedId()
		local plyCoords = GetEntityCoords(ply)
		local helio = ESX.Game.GetClosestVehicle(plyCoords, Config.spawnedheli2)
		local vehCoords = GetEntityCoords(helio)
		if Config.shareyourtrip then
			for k,v in pairs(Config.SkyDive) do
				if (GetDistanceBetweenCoords(plyCoords, v.spawn.x, v.spawn.y, v.spawn.z, true) < 5) and GetDistanceBetweenCoords( vehCoords, plyCoords) < 5 then
					SetTextComponentFormat("STRING");
					AddTextComponentString("Press ~INPUT_CONTEXT~ to join your friend!");
					DisplayHelpTextFromStringLabel(0, false, true, -1);  
					if IsControlJustPressed(1, 51) then
						SetPedIntoVehicle(ply, helio, math.random(2,3))
					end
				end
			end
		end
	end
end)




function DrawText3Ds(x,y,z, text)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)
  local p = GetGameplayCamCoords()
  local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
  local scale = (1 / distance) * 2
  local fov = (1 / GetGameplayCamFov()) * 100
  local scale = scale * fov
  if onScreen then
    SetTextScale(0.30, 0.30)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0120, factor, 0.026, 41, 11, 41, 68)
  end
end

Citizen.CreateThread(function()
	if Config.showblips then
	  for k,v in ipairs(Config.SkyDive)do
		local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
		SetBlipSprite(blip, 572)
		SetBlipScale(blip, 1.1)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(tostring(Config.blipname ))
		EndTextCommandSetBlipName(blip)
	  end
  end
end)

