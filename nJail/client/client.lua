ESX = nil 

TriggerEvent(Config.InitESX, function(obj) ESX = obj end)

local JailTime = 0
local JailReason = "Aucune"
local InJail = false
local UnJail = false
RegisterCommand(Config.jailCMD, function(source, args)
    ESX.TriggerServerCallback("nJail:checkPlayerRank", function(isAllowed)
        if isAllowed then
            SendNUIMessage({
                action = "openJailMenu",
            }) 
            SetNuiFocus(true, true)
        else
            ESX.ShowNotification("~r~Vous n'avez pas les permissions de faire cela !")
        end
    end)
end)

RegisterNUICallback("JailPlayer", function(data)
    TriggerServerEvent("nJail:JailPlayer", tonumber(data.id), tonumber(data.time), data.reason)
end)

RegisterNUICallback("close", function(data)
    SetNuiFocus(false, false)
    local playerInJailList = nil
end)

RegisterNUICallback("Unjail", function(data)
    SetNuiFocus(false, false)
    local playerInJailList = nil
    jailTime = 0
    InJail = false
    UnJail = true
    SendNUIMessage({
        action = "UnJail",
    }) 
    TriggerServerEvent("nJail:unJail", data.id, true)
end)

RegisterNUICallback("ChangeReason", function(data)
    TriggerServerEvent("nJail:ChangeReason", data.id, data.reason)
end)

RegisterNetEvent("nJail:jailPlayer:return")
AddEventHandler("nJail:jailPlayer:return", function(time, reason, id)
    print("Joueur remis en jail Client")
    FirstJailTime = time
    jailTime = time
    JailReason = reason
    local playerPed = PlayerPedId()
    SetNuiFocus(false, false)
    SetPedArmour(playerPed, 0)
    SetEntityCoords(playerPed, Config.JailPos)

    InJail = true
    UnJail = false

    CreateThread(function()
        while InJail do
            Wait(1000)

            local pourcentage = Get_percentage(jailTime, FirstJailTime)
            if jailTime > 0 then
                jailTime = jailTime - 1

                SendNUIMessage({
                    action = "JailInfo",
                    id = id,
                    time = jailTime.." SECONDES",
                    reason = JailReason,
                    pourcentage = pourcentage
                }) 
                TriggerServerEvent("nJail:updateTime", jailTime)
            else
                InJail = false
                UnJail = true
                SendNUIMessage({
                    action = "UnJail",
                }) 
                TriggerServerEvent("nJail:unJail", id, false)
            end
    
            if #(GetEntityCoords(PlayerPedId()) - Config.JailPos) > 15 then
                SetEntityCoords(PlayerPedId(), Config.JailPos)
            end
                
            DisableControlAction(2, 37, true) -- Select Weapon
            DisableControlAction(0, 25, true) -- Input Aim
            DisableControlAction(0, 24, true) -- Input Attack
            DisableControlAction(0, 257, true) -- Disable melee
            DisableControlAction(0, 140, true) -- Disable melee
            DisableControlAction(0, 142, true) -- Disable melee
            DisableControlAction(0, 143, true) -- Disable melee
        end

        SetEntityCoords(PlayerPedId(), Config.UnjailPos)
    end)
end)

function Get_percentage(duration, FirstJailTime)
    local percentage = (duration - FirstJailTime) / (0 - FirstJailTime) * 100
    return percentage
end

local nbJail = 0
local playerRank = ""
local playerInJailList = {}

RegisterCommand(Config.jailPannel, function(source, args)
    ESX.TriggerServerCallback("nJail:checkPlayerRank", function(isAdmin)
        if isAdmin then
            ESX.TriggerServerCallback("nJail:getNbJailPlayer", function(result)
                nbJail = result
            end)
            ESX.TriggerServerCallback("nJail:getRank", function(result) 
               playerRank = result 
            end)
            ESX.TriggerServerCallback("nJail:getPlayerInJail", function(result)
                playerInJailList = result
            end)
            Wait(200)
            SendNUIMessage({
                action = "openJailPannel",
                nbJail = nbJail,
                rank = playerRank,
                playerInJailList = playerInJailList,
            }) 
            SetNuiFocus(true, true)
        end
    end)
end)