
local Keybinds, Editing = {}, { Prop = nil, Cursor = false, Mode = 'translate', Relative = false, Snap = { Active = false, Angle = 15.0, GridSize = 0.5 } }

local dataview = lib.load('open.dataview')

local function makeEntityMatrix(entity)
    local f, r, u, a = GetEntityMatrix(entity)
    local view = dataview.ArrayBuffer(60)

    view:SetFloat32(0, r[1])
        :SetFloat32(4, r[2])
        :SetFloat32(8, r[3])
        :SetFloat32(12, 0)
        :SetFloat32(16, f[1])
        :SetFloat32(20, f[2])
        :SetFloat32(24, f[3])
        :SetFloat32(28, 0)
        :SetFloat32(32, u[1])
        :SetFloat32(36, u[2])
        :SetFloat32(40, u[3])
        :SetFloat32(44, 0)
        :SetFloat32(48, a[1])
        :SetFloat32(52, a[2])
        :SetFloat32(56, a[3])
        :SetFloat32(60, 1)

    return view
end

local function applyEntityMatrix(entity, view)
    local x1, y1, z1 = view:GetFloat32(16), view:GetFloat32(20), view:GetFloat32(24)
    local x2, y2, z2 = view:GetFloat32(0), view:GetFloat32(4), view:GetFloat32(8)
    local x3, y3, z3 = view:GetFloat32(32), view:GetFloat32(36), view:GetFloat32(40)
    local tx, ty, tz = view:GetFloat32(48), view:GetFloat32(52), view:GetFloat32(56)

    SetEntityMatrix(entity,
        x1, y1, z1,
        x2, y2, z2,
        x3, y3, z3,
        tx, ty, tz
    )
end

local function gizmoLoop()
    if not Editing['Prop'] then return LeaveCursorMode() end

    EnterCursorMode()
    Editing['Cursor'] = true

    SetCursorLocation(0.5, 0.5)

    SetEntityDrawOutline(Editing['Prop'], true)
    SetEntityDrawOutlineColor(Editing['Prop'], 255, 255, 0, 255)

    while Editing['Prop'] and DoesEntityExist(Editing['Prop']) do
        DisableControlAction(0, 24, true)  -- lmb
        DisableControlAction(0, 25, true)  -- rmb
        DisableControlAction(0, 140, true) -- r
        DisablePlayerFiring(cache.playerId, true)

        SetEntityCollision(Editing['Prop'], false, true)

        local matrixBuffer = makeEntityMatrix(Editing['Prop'])
        local changed = DrawGizmo(matrixBuffer:Buffer(), 'Editor2', Citizen.ReturnResultAnyway())

        if changed then
            applyEntityMatrix(Editing['Prop'], matrixBuffer)

            if Editing['Snap'].Active then
                local Pos = GetEntityCoords(Editing['Prop'])
                local GridSize = Editing['Snap'].GridSize
                local SnappedX = (math.floor((Pos.x / GridSize) + 0.5)) * GridSize
                local SnappedY = (math.floor((Pos.y / GridSize) + 0.5)) * GridSize
                local SnappedZ = (math.floor((Pos.z / GridSize) + 0.5)) * GridSize
                SetEntityCoordsNoOffset(Editing['Prop'], SnappedX, SnappedY, SnappedZ, true, true, true)

                local Rot = GetEntityRotation(Editing['Prop'], 2)
                local SnapAngle = Editing['Snap'].Angle
                local SnappedRotX = (math.floor((Rot.x / SnapAngle) + 0.5)) * SnapAngle
                local snappedRotY = (math.floor((Rot.y / SnapAngle) + 0.5)) * SnapAngle
                local snappedRotZ = (math.floor((Rot.z / SnapAngle) + 0.5)) * SnapAngle
                SetEntityRotation(Editing['Prop'], SnappedRotX, snappedRotY, snappedRotZ, 2, true)
            end
        end

        Wait(0)
    end

    if DoesEntityExist(Editing['Prop']) then SetEntityDrawOutline(Editing['Prop'], false) end
end

local function textUILoop()
    CreateThread(function()
        while Editing['Prop'] do
            Wait(100)
            lib.showTextUI(
                ('Current Mode: %s | %s  \n'):format(Editing['Mode'], (Editing['Relative'] and 'Relative') or 'World') ..
                '[RMB]     - ' .. (Editing['Cursor'] and "Disable" or "Enable") .. ' Cursor  \n' ..
                '[W]     - Translate Mode  \n' ..
                '[R]     - Rotate Mode  \n' ..
                '[Q]     - Relative/World  \n' ..
                '[LALT]  - Snap To Ground  \n' ..
                '[ENTER] - Done Editing  \n'
            )
        end
        lib.hideTextUI()
    end)
end

local function useGizmo(entity)
    textUILoop()
    gizmoLoop()

    return {
        handle = entity,
        position = GetEntityCoords(entity),
        rotation = GetEntityRotation(entity)
    }
end

local function ToggleKeybinds(Toggle)
    for i = 1, #Keybinds do
        local Keybind = Keybinds[i]
        Keybind:disable(Toggle)
    end
end

local function RemoveEdit()
    local TempData = Editing
    Editing = { Prop = nil, Cursor = false, Mode = 'translate', Relative = false, Snap = { Active = false, Angle = 15.0, GridSize = 0.5 } }

    if TempData['Prop'] then
        DeleteEntity(TempData['Prop'])
    end
    
    if TempData['Cursor'] then LeaveCursorMode() end
end

RegisterNUICallback('StartDecorating', function(_, cb)
    if not cache.inHouse then cb(false) return end

    ToggleKeybinds(false)

    cb(true)
end)

RegisterNUICallback('StopDecorating', function(_, cb)
    SetNuiFocus(false, false)
    RemoveEdit()
    ToggleKeybinds(true)
    cb({})
end)

RegisterNUICallback('PlaceFurniture', function(Data, cb)
    local PlayerPed = cache.ped

    RemoveEdit()

    SetNuiFocus(false, false)

    local ModelHash = GetHashKey(Data.Model)

    lib.requestModel(ModelHash)

    local StartOffset = GetEntityCoords(PlayerPed) + GetEntityForwardVector(PlayerPed) * 2

    Editing['Prop'] = CreateObject(ModelHash, StartOffset.x, StartOffset.y, StartOffset.z, false, false, false)

    SetModelAsNoLongerNeeded(ModelHash)
    
    local GizmoData = useGizmo(Editing['Prop'])

    RemoveEdit()

    cb({})
end)

local function ToggleFocus()
    if Editing['Prop'] then
        if Editing['Cursor'] then
            LeaveCursorMode()
        else
            EnterCursorMode()
            SetCursorLocation(0.5, 0.5)
        end
        Editing['Cursor'] = not Editing['Cursor']
    else
        local Focus = not IsNuiFocused()

        SetNuiFocus(Focus, Focus)
    end
end

RegisterNUICallback('ToggleFocus', function(_, cb)
    ToggleFocus()

    cb({})
end)

CreateThread(function()
    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateFocus',
        description = 'Press Right MouseButton to Toggle Focus While Decorating',
        defaultMapper = 'MOUSE_BUTTON',
        defaultKey = 'MOUSE_RIGHT',
        disabled = true,
        onPressed = ToggleFocus,
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateRotation',
        description = 'Sets mode for the gizmo to rotation',
        defaultKey = 'R',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            Editing['Mode'] = 'Rotate'
            ExecuteCommand('+gizmoRotation')
        end,
        onReleased = function (self)
            ExecuteCommand('-gizmoRotation')
        end
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateSnap',
        description = 'Hold to snap decoration object',
        defaultKey = 'LSHIFT',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            Editing['Snap'].Active = true
        end,
        onReleased = function (self)
            if not Editing['Prop'] then return end
            Editing['Snap'].Active = false
        end
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateSelect',
        description = 'Selects the currently highlighted gizmo',
        defaultMapper = 'MOUSE_BUTTON',
        defaultKey = 'MOUSE_LEFT',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            ExecuteCommand('+gizmoSelect')
        end,
        onReleased = function (self)
            ExecuteCommand('-gizmoSelect')
        end
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateTranslation',
        description = 'Sets mode of the gizmo to translation',
        defaultKey = 'W',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            Editing['Mode'] = 'Translate'
            ExecuteCommand('+gizmoTranslation')
        end,
        onReleased = function (self)
            ExecuteCommand('-gizmoTranslation')
        end
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateLocal',
        description = 'toggle gizmo to be local to the entity instead of world',
        defaultKey = 'Q',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            Editing['Relative'] = not Editing['Relative']
            ExecuteCommand('+gizmoLocal')
        end,
        onReleased = function (self)
            ExecuteCommand('-gizmoLocal')
        end
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateClose',
        description = 'close gizmo',
        defaultKey = 'RETURN',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            RemoveEdit()
        end,
    })

    Keybinds[#Keybinds + 1] = lib.addKeybind({
        name = 'decorateSnapToGround',
        description = 'snap current gizmo object to floor/surface',
        defaultKey = 'LMENU',
        disabled = true,
        onPressed = function(self)
            if not Editing['Prop'] then return end
            PlaceObjectOnGroundProperly_2(Editing['Prop'])
        end,
    })
end)