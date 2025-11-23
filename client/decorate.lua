
local FocusKeybind, Editing = nil, { Prop = nil }

local function RemoveEdit()
    if Editing.Prop then
        DeleteEntity(Editing.Prop)
    end

    Editing = { Prop = nil }
end

RegisterNUICallback('StartDecorating', function(_, cb)
    if not cache.inHouse then cb(false) return end

    FocusKeybind:disable(false)

    cb(true)
end)

RegisterNUICallback('StopDecorating', function(_, cb)
    FocusKeybind:disable(true)
    SetNuiFocus(false, false)
    RemoveEdit()
    cb({})
end)

RegisterNUICallback('PlaceFurniture', function(Data, cb)
    local PlayerPed = cache.ped

    RemoveEdit()

    local ModelHash = GetHashKey(Data.Model)

    lib.requestModel(ModelHash)

    local StartOffset = GetEntityCoords(PlayerPed) + GetEntityForwardVector(PlayerPed) * 2

    Editing['Prop'] = CreateObject(ModelHash, StartOffset, false, false, false)
    
    local GizmoData = exports['object_gizmo']:useGizmo(Editing['Prop'])

    cb({})
end)

local function ToggleFocus()
    local Focus = not IsNuiFocused()

    SetNuiFocus(Focus, Focus)
end

CreateThread(function()
    FocusKeybind = lib.addKeybind({
        name = 'togglefocus',
        description = 'Press LAlt to Toggle Focus While Decorating',
        defaultKey = 'LMENU',
        disabled = true,
        onPressed = ToggleFocus,
    })
end)