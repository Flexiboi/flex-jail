local isActive = false
local cannotplace = false

local function RotationToDirection(rotation)
    local adjustedRotation =
    {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction =
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination =
    {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x
        , destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

function RayCast(distance, instructions)
    isActive = true
    while isActive do
        lib.hideTextUI()

        if cannotplace then
            lib.showTextUI(instructions, {
                position = 'left-center',
                style = {
                    backgroundColor = "#992e3a"
                }
            })
        else
            lib.showTextUI(instructions, {
                position = 'left-center',
            })
        end
        local plyCoords = GetEntityCoords(PlayerPedId())
        local hit, coords, entity = RayCastGamePlayCamera(distance)

        local minDimension, maxDimension = GetModelDimensions(model) -- this native calculates the dimensions of the vehicle so we can find the bottom of the tires 
        _, gz1 = GetGroundZFor_3dCoord(coords.x + minDimension.x, coords.y + minDimension.y, coords.z + 0.5, true)
        _, gz2 = GetGroundZFor_3dCoord(coords.x - minDimension.x, coords.y - minDimension.y, coords.z + 0.5, true)
        _, gz3 = GetGroundZFor_3dCoord(coords.x + maxDimension.x, coords.y + maxDimension.y, coords.z + 0.5, true)
        _, gz4 = GetGroundZFor_3dCoord(coords.x - maxDimension.x, coords.y - maxDimension.y, coords.z + 0.5, true)

        local levcheck = {
            [1] = gz1,
            [2] = gz2,
            [3] = gz3,
            [4] = gz4,
        }

        for k, v in pairs(levcheck) do
            local check = coords.z - v
            if check > 0.3 or check < -0.3 then cannotplace = true else cannotplace = false end
        end

        if coords.x ~= 0.0 and coords.y ~= 0.0 then
            -- Draws line to targeted position
            if cannotplace then
                DrawLine(plyCoords.x, plyCoords.y, plyCoords.z, coords.x, coords.y, coords.z, 255, 0, 0, 100)
                DrawSphere(coords.x, coords.y, coords.z,0.1,255,0,0,0.5)
            else
                DrawLine(plyCoords.x, plyCoords.y, plyCoords.z, coords.x, coords.y, coords.z, 0, 255, 0, 100)
                DrawSphere(coords.x, coords.y, coords.z,0.1,0,255,0,0.5)
            end
        end
        if IsControlJustPressed(0,38) then
            lib.hideTextUI()
            if not cannotplace then
                isActive = false
                TaskTurnPedToFaceCoord(PlayerPedId(), coords.x, coords.y, coords.z, 1000) 
                return vec3(coords.x, coords.y, coords.z)
            else
                cannotplace = false
            end
        elseif IsControlJustPressed(0,202) then
            isActive = false
            cannotplace = false
            lib.hideTextUI()
            return false
        end
        Wait(0)
    end
end