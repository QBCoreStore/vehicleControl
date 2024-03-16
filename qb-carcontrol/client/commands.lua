RegisterKeyMapping('+carmenu', 'Shows car menu', 'KEYBOARD', Config.MenuKey)
RegisterCommand("+carmenu", function(source, args, rawCommand) 
    if ShowingMenu then 
        TriggerEvent("2na_carcontrol:Client:HideMenu")
    else
        TriggerEvent("2na_carcontrol:Client:ShowMenu")
    end
end)

function GetClosestVehicle(c,dist)
	local closest = 0
	for k,v in pairs(GetGamePool('CVehicle')) do
		local dis = #(GetEntityCoords(v) - c)
		if dis < dist 
		    or dist == -1 then
			closest = v
			dist = dis
		end
	end
	return closest, dist
end

SetVehicleControl = function(vehicle,data)
	local state = GetVehicleStates(vehicle,data)
	if state == false then
		QBCore.Functions.Notify("Cannot change seat!", "error")
	end
	if data.type == 'seat' then
		return SetPedIntoVehicle(PlayerPedId(),vehicle,data.index)
	end
end
GetVehicleStates = function(vehicle,data)
	if data.type == 'seat' then
		return IsVehicleSeatFree(vehicle,data.index)
	end
end

RegisterNUICallback('nuicb', function(data, cb)
	local closestvehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 10.0)
	SetEntityControlable(closestvehicle)
	SetVehicleModKit(closestvehicle,0)
	if data.msg == 'neon' then
		for i = 0, 3 do
			SetVehicleNeonLightEnabled(closestvehicle,i,true)
		end
		SetVehicleNeonLightsColour(closestvehicle, data.val.r,data.val.g,data.val.b)
	end
	if data.msg == 'neonstyle' then
		NeonCustom(data.val)
	end
	if data.msg == 'toggleneon' then
		for i = 0, 3 do
			SetVehicleNeonLightEnabled(closestvehicle, i, not IsVehicleNeonLightEnabled(closestvehicle,i))
		end
	end
    if data.msg == 'carcontrol' then
		SetVehicleControl(closestvehicle,data)
	end
end)


local currentype = {}
local type = nil
NeonCustom = function(type)
	local closestvehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 10.0)
	local plate = string.gsub(GetVehicleNumberPlateText(closestvehicle), '^%s*(.-)%s*$', '%1'):upper()
	currentype[plate] = type
	if type == 'neon1' then
		CreateThread(function()
			local r,g,b = GetVehicleNeonLightsColour(closestvehicle)
			while currentype[plate] == type do
				--SetVehicleNeonLightsColour(closestvehicle,255,255,255)
				for i = 0, 3 do
					SetVehicleNeonLightEnabled(closestvehicle, i, true)
				end
				Citizen.Wait(222)
				for i = 0, 3 do
					SetVehicleNeonLightEnabled(closestvehicle, i, false)
				end
				Citizen.Wait(222)
			end
			SetVehicleNeonLightsColour(closestvehicle,r,g,b)
			return
		end)
	elseif type == 'neon2' then
		CreateThread(function()
			local r,g,b = GetVehicleNeonLightsColour(closestvehicle)
			while currentype[plate] == type do
				--SetVehicleNeonLightsColour(closestvehicle,255,255,255)
				rand = math.random(1,4) - 1
				math.randomseed(GetGameTimer())
				for i = 0, 3 do
					SetVehicleNeonLightEnabled(closestvehicle, i, math.random(1,100) < 50)
				end
				for i = rand, rand do
					SetVehicleNeonLightEnabled(closestvehicle, i, math.random(1,100) < 50)
				end
				Citizen.Wait(55)
				for i = rand, rand do
					SetVehicleNeonLightEnabled(closestvehicle, i, math.random(1,100) < 50)
				end
				Citizen.Wait(55)
				for i = rand, rand do
					SetVehicleNeonLightEnabled(closestvehicle, i, math.random(1,100) < 50)
				end
				Citizen.Wait(55)
				for i = rand, rand do
					SetVehicleNeonLightEnabled(closestvehicle, i, math.random(1,100) < 50)
				end
				Citizen.Wait(155)
				SetVehicleNeonLightsColour(closestvehicle,r,g,b)
			end
			return
		end)
	elseif type == 'random' then
		CreateThread(function()
			local r,g,b = GetVehicleNeonLightsColour(closestvehicle)
			while currentype[plate] == type do
				math.randomseed(GetGameTimer())
				SetVehicleNeonLightsColour(closestvehicle,math.random(1,255),math.random(1,255),math.random(1,255))
				for i = 0, 3 do
					SetVehicleNeonLightEnabled(closestvehicle, i, math.random(1,100) < 50)
				end
				Citizen.Wait(222)
				for i = 0, 3 do
					SetVehicleNeonLightEnabled(closestvehicle, i, math.random(1,100) < 50)
				end
				Citizen.Wait(222)
			end
			SetVehicleNeonLightsColour(closestvehicle,r,g,b)
			return
		end)
	else
		for i = 0, 3 do
			SetVehicleNeonLightEnabled(closestvehicle, i, true)
		end
	end
end

SetEntityControlable = function(entity) -- server based entities. incase you are not the owner. server entities are a little complicated
    local netid = NetworkGetNetworkIdFromEntity(entity)
    SetNetworkIdExistsOnAllMachines(netid,true)
    SetEntityAsMissionEntity(entity,true,true)
    NetworkRequestControlOfEntity(entity)
    local attempt = 0
    while not NetworkHasControlOfEntity(entity) and attempt < 2000 and DoesEntityExist(entity) do
        NetworkRequestControlOfEntity(entity)
        Citizen.Wait(0)
        attempt = attempt + 1
    end
end

-- havadurumu

Citizen.CreateThread(function()
	while true do
		local ped = PlayerPedId();
		local veh = GetVehiclePedIsIn(ped, false);
		local coords = GetEntityCoords(ped);
		local zone = GetNameOfZone(coords.x, coords.y, coords.z);
		local var1, var2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
        local hash1 = GetStreetNameFromHashKey(var1);
		local hash2 = GetStreetNameFromHashKey(var2);
		local heading = GetEntityHeading(PlayerPedId());
        SendNUIMessage({
          type = 'open2',
          direction = heading,
          streetName = hash1,
          streetName2 = hash2..' '..GetLabelText(zone);
        })
		if Config.OptimizationMode == "ultralow" then 
			Citizen.Wait(2500); 
		elseif Config.OptimizationMode == "low" then 
			Citizen.Wait(2000); 
		elseif Config.OptimizationMode == "medium" then 
			Citizen.Wait(1500); 
		elseif Config.OptimizationMode == "fast" then 
			Citizen.Wait(1000); 
		end
	end
end)