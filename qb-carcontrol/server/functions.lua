function GetCarMedia(vehicle) 
    local carMedia = nil

    for _,v in ipairs(CarMedias) do
        if v.vehicle == vehicle then 
            carMedia = v
            break
        end
    end

    if carMedia then 
        if carMedia.pausedAt then 
            carMedia.startedAt = os.time() - (carMedia.pausedAt - carMedia.startedAt)
            carMedia.pausedAt = nil
        end
    end

    return carMedia
end

function GetPlayersInCar(vehicle)
    local peds = {}

    for i = -1, 6, 1 do 
        local ped = GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(source), false), i)

        if ped ~= 0 then 
            table.insert(peds, ped)
        end
    end

    local players = {}
    for _, playerId in ipairs(GetPlayers()) do 
        for ped in ipairs(peds) do
            if tostring(ped) == tostring(playerId) then 
                table.insert(players, playerId)
                break
            end
        end
    end

    return players
end