
local FocusKeybind = nil

RegisterNUICallback('StartDecorating', function(_, cb)
    if not cache.inHouse then cb(false) return end

    FocusKeybind:disable(false)

    cb(true)
end)

RegisterNUICallback('StopDecorating', function(_, cb)
    FocusKeybind:disable(true)
    SetNuiFocus(false, false)
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