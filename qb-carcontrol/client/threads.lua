local PedInCar = false
Citizen.CreateThread(function()
    while true do
        if GetVehiclePedIsIn(PlayerPedId(), false) == 0 then 
            if PedInCar then 
                PedInCar = false

                TriggerEvent("2na_carcontrol:Client:HideMenu")
                
                SendNUIMessage({
                    action = "stopMusic"
                })  
            end  
        else
            if not PedInCar then 
                PedInCar = true

                TwoNa.TriggerServerCallback("2na_carcontrol:Server:GetCarMedia", {}, function(carMedia)
                    if carMedia then 
                        carMedia.action = "playMusic"
                        TriggerEvent("2na_carcontrol:Client:ControlCarMedia", carMedia)
                    end
                end)
            end
        end

        Citizen.Wait(1)
    end
end)

Citizen.CreateThread(function() 
    while true do 
        if IsCamActive(ParkCam) and GetVehiclePedIsIn(PlayerPedId(), false) == 0 then 
            DisableParkCam()
        elseif IsCamActive(ParkCam) and GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then
            local vehicleRotation = GetEntityRotation(GetVehiclePedIsIn(PlayerPedId(), false))

            SetCamRot(ParkCam, vehicleRotation.x - 80.0, vehicleRotation.y, vehicleRotation.z, 2)

            SetTextFont(0)
            SetTextProportional(1)
            SetTextScale(0.0, 0.4)
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString("~g~Park camera enabled~w~ - Watch out!")
            DrawText(0.41, 0.95)
        end

        Citizen.Wait(1)
    end 
end)

if Config.EnableMileageSystem then 
    Citizen.CreateThread(function() 
        while true do 
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

            if vehicle and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and IsVehicleOnAllWheels(vehicle) and not IsCarIgnored(vehicle) then
                local plate = GetVehicleNumberPlateText(vehicle)

                local currentCoords = GetEntityCoords(vehicle)
                Citizen.Wait(1000)
                local updatedCoords = GetEntityCoords(vehicle)

                local traveled = #(updatedCoords - currentCoords) / 100

                if traveled > 0 then 
                    TriggerServerEvent("2na_carcontrol:Server:AddMileage", plate, traveled)
                end
            end

            Citizen.Wait(Config.MileageUpdateInterval)
        end
    end)
end