QBCore = exports['qb-core']:GetCoreObject()

RegisterNUICallback("exitMenu", function(data, cb) 
    TriggerEvent("2na_carcontrol:Client:HideMenu")
end)
RegisterNUICallback("closeui", function(data, cb) 
    TriggerEvent("2na_carcontrol:Client:HideMenu")
end)
RegisterNUICallback("toggleInteriorLight", function() 
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local lightState = not IsVehicleInteriorLightOn(vehicle)

    SetVehicleInteriorlight(vehicle, lightState)
end)

RegisterNUICallback("toggleHeadLight", function() 
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local _, ligthsOn, highBeamsOn = GetVehicleLightsState(vehicle)
    local lightState = nil

    if ligthsOn == 1 or highBeamsOn == 1 then
        SetVehicleLights(vehicle, 1)
    else
        SetVehicleLights(vehicle, 3)
    end
end)

RegisterNUICallback("toggleEngine", function() 
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local engineState = not GetIsVehicleEngineRunning(vehicle)

    SetVehicleEngineOn(vehicle, engineState, false, true)
end)

RegisterNUICallback("toggleNeonLight", function() 
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local neonUpgrade = GetVehicleMod(vehicle, 22)

    if neonUpgrade ~= -1 then 
        for i = 0, 3, 1 do
            local neonState = IsVehicleNeonLightEnabled(vehicle, i)

            if neonState == 1 then 
                SetVehicleNeonLightEnabled(vehicle, i, false)
            else
                SetVehicleNeonLightEnabled(vehicle, i, true)
            end
        end
    end
end)

RegisterNUICallback("toggleDoor", function(index) 
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local angleRatio = GetVehicleDoorAngleRatio(vehicle, index)

    if GetVehicleDoorAngleRatio(vehicle, index) > 0.1 then 
        SetVehicleDoorShut(vehicle, index, false)
        Wait(500)
        local angleRatio2 = GetVehicleDoorAngleRatio(vehicle, index)

        if angleRatio == angleRatio2 then
            if index == 5 then
                QBCore.Functions.Notify("The car does not have a trunk!", "error")
            elseif index == 4 then
                QBCore.Functions.Notify("The car does not have a hood!", "error")
            elseif index == 0 or index == 1 or index == 2 or index == 3 then
                QBCore.Functions.Notify("The car does not have a door!", "error")
            end
        end
    else
        SetVehicleDoorOpen(vehicle, index, false, false)
        Wait(500)
        local angleRatio2 = GetVehicleDoorAngleRatio(vehicle, index)

        if angleRatio == angleRatio2 then
            if index == 5 then
                QBCore.Functions.Notify("The car does not have a trunk!", "error")
            elseif index == 4 then
                QBCore.Functions.Notify("The car does not have a hood!", "error")
            elseif index == 0 or index == 1 or index == 2 or index == 3 then
                QBCore.Functions.Notify("The car does not have a door!", "error")
            end
        end
    end
end)

RegisterNUICallback("lockCar", function() 
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    if vehicle then 
        if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then 
            TriggerServerEvent("2na_carcontrol:Server:ToggleVehicleLock")     
        end
    end
end)

RegisterNUICallback("controlMusic", function(data)
    TriggerServerEvent("2na_carcontrol:Server:ControlCarMedia", data)
end)

RegisterNUICallback("showParkCam", function() 
    TriggerEvent("2na_carcontrol:Client:ShowParkCam")
end)
