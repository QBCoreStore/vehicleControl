TwoNa = exports["2na_core"]:getSharedObject()
ShowingMenu = false
ParkCam = nil

RegisterNetEvent("2na_carcontrol:Client:ShowMenu")
AddEventHandler("2na_carcontrol:Client:ShowMenu", function() 
    local vehicle = GetPedVehicleData(PlayerPedId())

    if vehicle then 
        TwoNa.TriggerServerCallback("2na_carcontrol:Server:GetMileage", { plate = GetVehicleNumberPlateText(vehicle.vehicle) }, function(mileage) 
            vehicle.mileage = mileage

            SetNuiFocus(true, true)

            SendNUIMessage({
                action = "show",
                vehicle = vehicle
            })

            ShowingMenu = true
        end)
    end
end)

RegisterNetEvent("2na_carcontrol:Client:HideMenu")
AddEventHandler("2na_carcontrol:Client:HideMenu", function() 
    SendNUIMessage({
        action = "hide",
    })

    SetNuiFocus(false, false)

    ShowingMenu = false
end)

RegisterNetEvent("2na_carcontrol:Client:ControlCarMedia")
AddEventHandler("2na_carcontrol:Client:ControlCarMedia", function(payload) 
    SendNUIMessage(payload)
end)

RegisterNetEvent("2na_carcontrol:Client:ShowParkCam")
AddEventHandler("2na_carcontrol:Client:ShowParkCam", function() 
    if ParkCam then 
        DisableParkCam()
    else
        EnableParkCam()
    end

    TriggerEvent("2na_carcontrol:Client:HideMenu")
end)

