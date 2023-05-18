
ESX = nil 

TriggerEvent(Config.InitESX, function(obj) ESX = obj end)

local playerInJail = {}


AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)

    MySQL.Async.fetchAll('SELECT jail_time FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] and result[1].jail_time > 0 then
            TriggerEvent("nJail:JailPlayer:deco", xPlayer.source, result[1].jail_time)
        end
    end)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
    playerInJail[playerId] = nil
end)

ESX.RegisterServerCallback("nJail:checkPlayerRank", function(source, cb)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

    for k,v in pairs(Config.allowedRank) do
        if xPlayer.getGroup() == v then
            print(v)
            cb(true)
        end
    end

    cb(false)
end)

ESX.RegisterServerCallback("nJail:getNbJailPlayer", function(source, cb)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

    for k,v in pairs(Config.allowedRank) do
        if xPlayer.getGroup() == v then
            MySQL.Async.fetchAll('SELECT * FROM users WHERE jail_time > 0', {}, function(result)
                cb(#result)
            end)
        end
    end
end)

ESX.RegisterServerCallback("nJail:getPlayerInJail", function(source, cb)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

    for k,v in pairs(Config.allowedRank) do
        if xPlayer.getGroup() == v then
            MySQL.Async.fetchAll('SELECT * FROM users WHERE jail_time > 0', {}, function(result)
                cb(result)
            end)
        end
    end
end)

ESX.RegisterServerCallback("nJail:getRank", function(source, cb)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

    cb(xPlayer.getGroup())
end)

RegisterNetEvent('nJail:JailPlayer:deco')
AddEventHandler('nJail:JailPlayer:deco', function(playerId, jailTime)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        if not playerInJail[playerId] then
            MySQL.Async.execute('UPDATE users SET jail_time = @jail_time WHERE identifier = @identifier', {
                ['@identifier'] = xPlayer.identifier,
                ['@jail_time'] = jailTime
            }, function(rowsChanged)
                TriggerClientEvent('nJail:jailPlayer:return', xPlayer.source, jailTime, "", playerId)
                playerInJail[playerId] = {timeRemaining = jailTime, identifier = xPlayer.identifier }
            end)
        end
    end
end)

RegisterNetEvent("nJail:JailPlayer")
AddEventHandler("nJail:JailPlayer", function(id, time, reason)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(id)

    for k,v in pairs(Config.allowedRank) do
        if xPlayer.getGroup() == v then
            if xTarget == nil then
                return TriggerClientEvent("esx:showNotification", source, "~r~Ce joueur n'éxiste pas !")
            end

            if not playerInJail[id] then
                MySQL.Async.execute('UPDATE users SET jail_ref = @jail_ref WHERE identifier = @identifier', {
					['@identifier'] = xTarget.identifier,
					['@jail_ref'] = time
				}, function(rowsChanged)
				end)
                MySQL.Async.execute('UPDATE users SET jail_reason = @jail_reason WHERE identifier = @identifier', {
					['@identifier'] = xTarget.identifier,
					['@jail_reason'] = reason
				}, function(rowsChanged)
				end)
                MySQL.Async.execute('UPDATE users SET jail_time = @jail_time WHERE identifier = @identifier', {
					['@identifier'] = xTarget.identifier,
					['@jail_time'] = time
				}, function(rowsChanged)
					TriggerClientEvent('nJail:jailPlayer:return', xTarget.source, time, reason, id)
					playerInJail[id] = {timeRemaining = time, identifier = xTarget.identifier }
                    TriggerClientEvent("esx:showNotification", id, "Vous avez été jail !")
				end)
            else
                TriggerClientEvent("esx:showNotification", source, "~r~Ce joueur est déjà en jail !")
            end
        end
    end

    local w = {{ ["author"] = { ["name"] = "🪐 nJail", ["icon_url"] = "https://cdn.discordapp.com/attachments/963432340812603444/1078967482028662814/logo.png" }, ["color"] = "10038562", ["title"] = Title, ["description"] = "**Nouveau joueur mis en jail**\n\n```Joueur : "..xTarget.getName().."\nTemps de jail : "..time.." secondes\nRaison : "..reason.."```\nMis en jail par ``"..xPlayer.getName().."`` à ``"..os.date("%X").."``", ["footer"] = { ["text"] = "🪐 "..os.date("%d/%m/%Y"), ["icon_url"] = nil}, } }
    PerformHttpRequest(Config.LogsLink, function(err, text, headers) end, 'POST', json.encode({username = "nJail", embeds = w, avatar_url = "https://cdn.discordapp.com/attachments/963432340812603444/1078967482028662814/logo.png"}), { ['Content-Type'] = 'application/json'})

end)

RegisterNetEvent("nJail:ChangeReason")
AddEventHandler("nJail:ChangeReason", function(id, reason)
    local xPlayer = ESX.GetPlayerFromId(source)
    print(id, reason)
    for k,v in pairs(Config.allowedRank) do
        if xPlayer.getGroup() == v then
            MySQL.Async.execute('UPDATE users SET jail_reason = @jail_reason WHERE identifier = @identifier', {
                ['@identifier'] = id,
                ['@jail_reason'] = reason
            }, function(rowsChanged)
                TriggerClientEvent("esx:showNotification", id, "Votre raison de jail a été changé !")
            end)
        end
    end

end)
    

RegisterNetEvent("nJail:updateTime")
AddEventHandler("nJail:updateTime", function(time)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

    MySQL.Async.execute('UPDATE users SET jail_time = @jail_time WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier,
        ['@jail_time'] = time
    }, function(rowsChanged)
    end)
end)

RegisterNetEvent("nJail:unJail")
AddEventHandler("nJail:unJail", function(id, use_pannel)
    local _src = source
    local xPlayer = ESX.GetPlayerFromIdentifier(id) or ESX.GetPlayerFromId(id)

    if xPlayer then
        MySQL.Async.execute('UPDATE users SET jail_time = @jail_time WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier,
            ['@jail_time'] = 0
        }, function(rowsChanged)
        end)
        MySQL.Async.execute('UPDATE users SET jail_ref = @jail_ref WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier,
            ['@jail_ref'] = 0
        }, function(rowsChanged)
        end)
        MySQL.Async.execute('UPDATE users SET jail_reason = @jail_reason WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier,
            ['@jail_reason'] = nil
        }, function(rowsChanged)
        end)
    else
        MySQL.Async.execute('UPDATE users SET jail_time = @jail_time WHERE identifier = @identifier', {
            ['@identifier'] = id,
            ['@jail_time'] = 0
        }, function(rowsChanged)
        end)
        MySQL.Async.execute('UPDATE users SET jail_ref = @jail_ref WHERE identifier = @identifier', {
            ['@identifier'] = id,
            ['@jail_ref'] = 0
        }, function(rowsChanged)
        end)
        MySQL.Async.execute('UPDATE users SET jail_reason = @jail_reason WHERE identifier = @identifier', {
            ['@identifier'] = id,
            ['@jail_reason'] = nil
        }, function(rowsChanged)
        end)
    end
    playerInJail[id] = nil
    TriggerClientEvent("esx:showNotification", _src, "Vous avez été unjail !")
    local w = {{ ["author"] = { ["name"] = "🪐 nJail", ["icon_url"] = "https://cdn.discordapp.com/attachments/963432340812603444/1078967482028662814/logo.png" }, ["color"] = "10038562", ["title"] = Title, ["description"] = "``"..xPlayer.getName().."`` a fini de purger sa peine.", ["footer"] = { ["text"] = "🪐 "..os.date("%d/%m/%Y"), ["icon_url"] = nil}, } }
    PerformHttpRequest(Config.LogsLink, function(err, text, headers) end, 'POST', json.encode({username = "nJail", embeds = w, avatar_url = "https://cdn.discordapp.com/attachments/963432340812603444/1078967482028662814/logo.png"}), { ['Content-Type'] = 'application/json'})
end)