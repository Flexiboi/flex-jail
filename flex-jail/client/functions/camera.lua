local CurrentCam = nil

function OpenCam(coords)
    DoScreenFadeOut(800)
    Wait(2000)
    CurrentCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    RenderScriptCams(true, 1, 1,  true,  true)
    SetFocusArea(coords)
    processCamera(coords)
end

function processCamera(coords)
    SetCamCoord(CurrentCam, coords.x,coords.y,coords.z - 1.5)
	SetCamFov(CurrentCam, 90.0)
    SetCamRot(CurrentCam, 0.0, 0.0, coords.w, 2)
    local CamRot = GetCamRot(CurrentCam,2)
    FreezeEntityPosition(PlayerPedId(),true)
    DoScreenFadeIn(800)
    while CurrentCam ~= nil do 
        Wait(0)
        local instructions = CreateInstuctionScaleform("instructional_buttons")
        DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)
        SetTimecycleModifier("scanline_cam_cheap")
        SetTimecycleModifierStrength(2.0)
        DisplayRadar(false)
        local getCameraRot = GetCamRot(CurrentCam,2)
        if IsControlJustReleased(0,177) then
            RenderScriptCams(false, 1, 1,  true,  true)
            DestroyCam(CurrentCam)
            CurrentCam = nil
            ClearTimecycleModifier("scanline_cam_cheap")
            SetFocusEntity(GetPlayerPed(PlayerId()))
            DisplayRadar(true)
            FreezeEntityPosition(PlayerPedId(),false)
            StopTabletAnimation()
        end
        if IsControlPressed(1, 172) then
            if getCameraRot.x <= 0.0 then
                SetCamRot(CurrentCam, getCameraRot.x + 0.7, 0.0, getCameraRot.z, 2)
            end
        end
        if IsControlPressed(1, 173) then
            if getCameraRot.x >= -30.0 then
                SetCamRot(CurrentCam, getCameraRot.x - 0.7, 0.0, getCameraRot.z, 2)
            end
        end
        if IsControlPressed(1, 174) then
            if getCameraRot.z < CamRot.z+10 then
                SetCamRot(CurrentCam, getCameraRot.x, 0.0, getCameraRot.z + 0.7, 2)
            end
        end
        if IsControlPressed(1, 175) then
            if getCameraRot.z > CamRot.z-10 then
                SetCamRot(CurrentCam, getCameraRot.x, 0.0, getCameraRot.z - 0.7, 2)
            end
        end
    end
end

function CloseCam(time)
    DestroyCam(CurrentCam, 0)
    RenderScriptCams(false, 1, time,  true,  true)
    CurrentCam = 0
    ClearTimecycleModifier("scanline_cam_cheap")
    SetFocusEntity(GetPlayerPed(PlayerId()))
    DisplayRadar(true)
    FreezeEntityPosition(GetPlayerPed(PlayerId()), false)
    SetFocusEntity(GetPlayerPed(PlayerId()))
end

function CreateInstuctionScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    InstructionButton(GetControlInstructionalButton(1, 173, true))
    InstructionButtonMessage(Lang:t('cctv.down'))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    InstructionButton(GetControlInstructionalButton(1, 172, true))
    InstructionButtonMessage(Lang:t('cctv.up'))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    InstructionButton(GetControlInstructionalButton(1, 175, true))
    InstructionButtonMessage(Lang:t('cctv.right'))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    InstructionButton(GetControlInstructionalButton(1, 174, true))
    InstructionButtonMessage(Lang:t('cctv.left'))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    InstructionButton(GetControlInstructionalButton(1, 177, true))
    InstructionButtonMessage(Lang:t('cctv.esc'))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

function InstructionButton(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function InstructionButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end