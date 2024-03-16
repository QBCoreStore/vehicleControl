function IsCarIgnored(vehicle) 
    local plate = GetVehicleNumberPlateText(vehicle)
    local isIgnored = false

    for _,v in ipairs(Config.IgnoredPlates) do 
        if v == plate then 
            isIgnored = true
            break
        end
    end

    return isIgnored
end