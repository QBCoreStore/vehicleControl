TwoNa = exports["2na_core"]:getSharedObject()
CarMedias = {}

TwoNa.RegisterServerCallback("2na_carcontrol:Server:GetMileage", function(source, payload, cb) 
    if Config.EnableMileageSystem then 
        local carMileageResult = TwoNa.MySQL.Sync.Fetch("SELECT * FROM carmileages WHERE plate = @plate", { ["@plate"] = payload.plate })

        if #carMileageResult > 0 then 
            cb(carMileageResult[1].mileage)
        else
            cb(nil)
        end
    else
        cb(nil)
    end
end)

TwoNa.RegisterServerCallback("2na_carcontrol:Server:GetCarMedia", function(source, payload, cb) 
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)
    local carMedia = GetCarMedia(vehicle)

    cb(carMedia)
end)

RegisterServerEvent("2na_carcontrol:Server:ControlCarMedia")
AddEventHandler("2na_carcontrol:Server:ControlCarMedia", function(payload)
    local source = source
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)

    if vehicle then
        local carMedia = GetCarMedia(vehicle)

        if not carMedia then 
            carMedia = {
                vehicle = vehicle,
                startedAt = nil,
                musicLink = nil,
                playerState = nil
            }
            table.insert(CarMedias, carMedia)
        end

        if payload.action == "playMusic" then
            carMedia = {
                vehicle = vehicle,
                startedAt = os.time(),
                musicLink = payload.musicLink,
                playerState = "playing"
            }
        elseif payload.action == "pauseMusic" then
            carMedia.pausedAt = os.time()
            carMedia.playerState = "paused"
        elseif payload.action == "resumeMusic" then
            carMedia.playerState = "playing"
        elseif payload.action == "endMusic" then
            carMedia.playerState = "idle"
            carMedia.musicLink = nil
            carMedia.startedAt = nil
        end


        payload.playerState = carMedia.playerState
        for k,v in ipairs(CarMedias) do 
            if v.vehicle == vehicle then 
                CarMedias[k] = carMedia
            end
        end

        -- local players = GetPlayersInCar(vehicle)

        -- for _, player in ipairs(players) do 
        --     print(player,payload )
        --     TriggerClientEvent("2na_carcontrol:Client:ControlCarMedia", player, payload)
        -- end
        TriggerClientEvent("2na_carcontrol:Client:ControlCarMedia", source, payload)

        
    end

end)

RegisterServerEvent("2na_carcontrol:Server:ToggleVehicleLock")
AddEventHandler("2na_carcontrol:Server:ToggleVehicleLock", function() 
    local source = source
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)

    if vehicle then 
        if GetPedInVehicleSeat(vehicle, -1) == GetPlayerPed(source) then 
            local lockStatus = GetVehicleDoorLockStatus(vehicle)
            local newLockStatus = nil

            if lockStatus == 4 then 
                newLockStatus = 0
            else
                newLockStatus = 4
            end

            SetVehicleDoorsLocked(vehicle, newLockStatus) 
        end
    end
end)

if Config.EnableMileageSystem then
    RegisterServerEvent("2na_carcontrol:Server:AddMileage")
    AddEventHandler("2na_carcontrol:Server:AddMileage", function(plate, traveled) 
        local source = source
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)

        if vehicle and GetPedInVehicleSeat(vehicle, -1) == GetPlayerPed(source) and not IsCarIgnored(vehicle) and GetVehicleNumberPlateText(vehicle) == plate then 
            local carOldMileage = TwoNa.MySQL.Sync.Fetch("SELECT * FROM carmileages WHERE plate = @plate", { ["@plate"] = plate })

            if #carOldMileage > 0 then 
                TwoNa.MySQL.Sync.Execute("UPDATE carmileages SET mileage = @mileage WHERE plate = @plate", { ["@plate"] = plate, ["@mileage"] = carOldMileage[1].mileage + traveled })
            else
                TwoNa.MySQL.Sync.Execute("INSERT INTO carmileages (plate, mileage) VALUES (@plate, @mileage)", { ["@plate"] = plate, ["@mileage"] = traveled })
            end
        end
    end)
end


