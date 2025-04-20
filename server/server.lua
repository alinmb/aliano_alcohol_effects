local function _U(key, data)
    if not Locales or not Locales[Config.Locale or 'fr'] then
        print(('^1[TRAD] Locales manquantes pour %s'):format(Config.Locale or 'fr'))
        return key
    end

    local msg = Locales[Config.Locale or 'fr'][key] or ('[MISSING:%s]'):format(key)
    
    if data then
        for k, v in pairs(data) do
            msg = msg:gsub('%%{'..k..'}', tostring(v))
        end
    end
    
    return msg
end

RegisterNetEvent('alcohol:adminReset')
AddEventHandler('alcohol:adminReset', function(targetId)
    local xPlayer = GetPlayerIdentifiers(source)[1]
    local target = GetPlayerIdentifiers(targetId)[1]

    if xPlayer == 'admin' then
        TriggerClientEvent('alcohol:clientReset', targetId)
        TriggerClientEvent('showNotification', source, _U('admin_reset', {id = targetId}))
    else
        TriggerClientEvent('showNotification', source, _U('admin_denied'))
    end
end)

RegisterNetEvent('aliano_alcohol_effect:removeItem')
AddEventHandler('aliano_alcohol_effect:removeItem', function(item)
    local src = source
    exports.ox_inventory:RemoveItem(src, item, 1)
end)