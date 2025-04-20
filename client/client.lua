--------------------------------------------------------------------------------
-- SECTION 1: INITIALIZATION OF TRANSLATIONS
--------------------------------------------------------------------------------
    local Translations = {}
    local currentLocale = Config.Locale or 'fr'
    function LoadTranslations(locale)
        local file = LoadResourceFile(GetCurrentResourceName(), ('locales/%s.json'):format(locale))
        if file then
            Translations = json.decode(file)
        else
            print(('[^1ERREUR^7] Fichier de traduction introuvable: locales/%s.json'):format(locale))
            file = LoadResourceFile(GetCurrentResourceName(), 'locales/en.json')
            if file then Translations = json.decode(file) end
        end
    end
    function _U(key, data)
        local keys = {}
        for k in string.gmatch(key, "[^.]+") do
            table.insert(keys, k)
        end
    
        local translation = Translations
        for _, k in ipairs(keys) do
            translation = translation[k]
            if not translation then break end
        end
    
        if translation then
            if type(translation) == 'string' and data then
                return translation:gsub('%%{(.-)}', data)
            end
            return translation or ('[MISSING TRANSLATION: %s]'):format(key)
        end
        return ('[MISSING TRANSLATION: %s]'):format(key)
    end
    
    LoadTranslations(currentLocale)
    
    --------------------------------------------------------------------------------
    -- SECTION 2: GLOBAL VARIABLES
    --------------------------------------------------------------------------------
    local bottleCount = 0
    local currentEffects = {}
    local isHangover = false
    local inTransition = false
    local lastThreshold = 0
    local currentBottle = nil
    local isDrinking = false
    local sipsLeft = 0
    local bottleProp = nil
    local isHoldingBottle = false
    local drunkDrivingActive = false
    local lastVehicleCheck = 0
    
    --------------------------------------------------------------------------------
    -- SECTION 3: UTILITY FUNCTIONS
    --------------------------------------------------------------------------------
    local function showNotification(message)
        SetNotificationTextEntry("STRING")
        AddTextComponentString(message)
        DrawNotification(false, true)
    end
    
    --------------------------------------------------------------------------------
    -- SECTION 4: BOTTLE MANAGEMENT
    --------------------------------------------------------------------------------
     local function attachBottle()
        if not currentBottle then return end
        
        local playerPed = PlayerPedId()
        local model = Config.BottleModels[currentBottle] or Config.BottleModels['default']
        model = type(model) == 'string' and GetHashKey(model) or model
    
        if not IsModelValid(model) then
            print("[ERREUR] Modèle d'alcool invalide:", model)
            return
        end
    
        RequestModel(model)
        local timeout = 0
        while not HasModelLoaded(model) and timeout < 50 do
            Wait(10)
            timeout = timeout + 1
        end
    
        if not HasModelLoaded(model) then
            print("[ERREUR] Impossible de charger le modèle:", model)
            return
        end
    
        if bottleProp then
            DeleteObject(bottleProp)
        end
    
        bottleProp = CreateObject(model, 0, 0, 0, true, true, true)
        AttachEntityToEntity(
            bottleProp,
            playerPed,
            GetPedBoneIndex(playerPed, 60309),
            Config.BottlePosition.pos.x,
            Config.BottlePosition.pos.y,
            Config.BottlePosition.pos.z,
            Config.BottlePosition.rot.x,
            Config.BottlePosition.rot.y,
            Config.BottlePosition.rot.z,
            true, true, false, true, 1, true
        )
        isHoldingBottle = true
    end
    local function removeBottle()
        if bottleProp then
            DeleteObject(bottleProp)
            bottleProp = nil
        end
        isHoldingBottle = false
    end
    local function stopDrinking()
        if isHoldingBottle then
            removeBottle()
            currentBottle = nil
            sipsLeft = 0
            showNotification(_U('drinking.stop'))
        end
        ClearPedTasks(PlayerPedId())
        
        if bottleCount == 0 and drunkDrivingActive then
            AnimpostfxStop("DrugsDrivingIn")
            drunkDrivingActive = false
        end
    end
    
    --------------------------------------------------------------------------------
    -- SECTION 5: MANAGEMENT OF ALCOHOLIC EFFECTS
    --------------------------------------------------------------------------------
    local function manageEffects()
        local ped = PlayerPedId()
        
        if bottleCount >= Config.Effects.screenEffect.minBottles and not currentEffects.screen then
            AnimpostfxPlay(Config.Effects.screenEffect.name, 0, true)
            currentEffects.screen = true
        elseif bottleCount < Config.Effects.screenEffect.minBottles and currentEffects.screen then
            AnimpostfxStop(Config.Effects.screenEffect.name)
            currentEffects.screen = false
        end
        
        local currentWalk = nil
        for i = #Config.Effects.levels, 1, -1 do
            if bottleCount >= Config.Effects.levels[i].bottle then
                currentWalk = Config.Effects.levels[i].walk
                break
            end
        end
        
        if currentWalk then
            if not currentEffects.walk or currentEffects.walk ~= currentWalk then
                if currentEffects.walk then
                    ResetPedMovementClipset(ped, 0.0)
                end
                RequestAnimSet(currentWalk)
                while not HasAnimSetLoaded(currentWalk) do
                    Wait(100)
                end
                SetPedMovementClipset(ped, currentWalk, true)
                currentEffects.walk = currentWalk
            end
        elseif currentEffects.walk then
            ResetPedMovementClipset(ped, 0.0)
            currentEffects.walk = nil
        end
    end
    local function showLevelNotification()
        for i = #Config.Effects.levels, 1, -1 do
            if bottleCount >= Config.Effects.levels[i].bottle and (lastThreshold == nil or lastThreshold < Config.Effects.levels[i].bottle) then
                showNotification(_U(Config.Effects.levels[i].label))
                lastThreshold = Config.Effects.levels[i].bottle
                break
            end
        end
    end
    local function resetEffects()
        local ped = PlayerPedId()
        
        if currentEffects.walk then
            ResetPedMovementClipset(ped, 0.0)
            currentEffects.walk = nil
        end
        
        if currentEffects.screen then
            AnimpostfxStop(Config.Effects.screenEffect.name)
            currentEffects.screen = nil
        end
    
        if drunkDrivingActive then
            AnimpostfxStop("DrugsDrivingIn")
            drunkDrivingActive = false
        end
        
        ResetPedWeaponMovementClipset(ped)
        ResetPedStrafeClipset(ped)
    end
    
    --------------------------------------------------------------------------------
    -- SECTION 6: HANGOVER
    --------------------------------------------------------------------------------
    local function applyLightDizziness()
        local ped = PlayerPedId()
        AnimpostfxPlay("Dont_tazeme_bro", 30000, true)
        
        RequestAnimSet("move_m@drunk@slightlydrunk")
        while not HasAnimSetLoaded("move_m@drunk@slightlydrunk") do
            Wait(100)
        end
        SetPedMovementClipset(ped, "move_m@drunk@slightlydrunk", 0.5)
    end
    local function startHangover()
        local ped = PlayerPedId()
        isHangover = true
        
        RequestAnimSet(Config.Effects.Hangover.walk)
        while not HasAnimSetLoaded(Config.Effects.Hangover.walk) do
            Wait(100)
        end
        
        if not IsPedInAnyVehicle(ped, false) then
            SetPedMovementClipset(ped, Config.Effects.Hangover.walk, true)
        end
        
        Citizen.CreateThread(function()
            while isHangover and not inTransition do
                Wait(Config.Effects.Hangover.stumbleInterval)
                
                if not IsPedInAnyVehicle(ped, false) and math.random() < Config.Effects.Hangover.stumbleChance then
                    SetPedToRagdoll(ped, 5000, 5000, 0, true, true, false)
                    showNotification(_U('effects.stumble'))
                end
            end
        end)
        
        Citizen.SetTimeout(60000, function()
            if not isHangover then return end
            inTransition = true
            applyLightDizziness()
        end)
        
        Citizen.SetTimeout(120000, function()
            if not isHangover then return end
            
            AnimpostfxStopAll()
            ResetPedMovementClipset(ped, 0.0)
            ResetPedWeaponMovementClipset(ped)
            ResetPedStrafeClipset(ped)
            
            isHangover = false
            inTransition = false
            bottleCount = 0
            lastThreshold = 0
            currentEffects = {}
            showNotification(_U('effects.recovery'))
        end)
    end
    local function knockout(duration)
        local ped = PlayerPedId()
    
        if IsPedInAnyVehicle(ped, false) then
            showNotification(_U('effects.drunk_driving'))
            return
        end
        
        SetPedToRagdoll(ped, duration, duration, 0, true, true, false)
        showNotification(_U('effects.knockout'))
        
        Citizen.Wait(duration)
        
        startHangover()
    end
    local function checkDrunkLevel()
        manageEffects()
        showLevelNotification()
        
        if bottleCount >= 3 then
            knockout(30000)
        end
    end
    
    --------------------------------------------------------------------------------
    -- SECTION 7: ALCOHOL CONSUMPTION
    --------------------------------------------------------------------------------
    local function drinkSip()
        if not currentBottle or isDrinking or sipsLeft <= 0 then return end
    
        isDrinking = true
    
        RequestAnimDict("mp_player_intdrink")
        while not HasAnimDictLoaded("mp_player_intdrink") do
            Wait(10)
        end
    
        if not bottleProp then
            attachBottle()
            Wait(300)
        end
    
        TaskPlayAnim(PlayerPedId(), "mp_player_intdrink", "loop_bottle", 1.0, -1.0, 2000, 0, 1, true, true, true)
        Wait(2000)
    
        sipsLeft = sipsLeft - 1
    
        -- Hydratation (ESX/QBCore/Standalone)
        if Config.ThirstPerSip and Config.ThirstPerSip > 0 then
            if GetResourceState('esx_status') == 'started' then
                TriggerEvent('esx_status:add', 'thirst', Config.ThirstPerSip)
            elseif GetResourceState('ox_status') == 'started' then
                exports['ox_status']:add('thirst', Config.ThirstPerSip / 1000)
            end
        end
---------------------------------------------------------------------------------------------------------

    -- QB CORE VERSION

    -- if Config.ThirstPerSip and Config.ThirstPerSip > 0 then
    --     if GetResourceState('qb-core') == 'started' then
    --         TriggerServerEvent('consumables:server:addThirst', Config.ThirstPerSip)
    --         -- Alternative si vous utilisez QB-Status
    --         -- TriggerServerEvent('qb-status:server:addThirst', Config.ThirstPerSip)
    --     end
    --     print("[Alcool] Soif ajoutée: "..Config.ThirstPerSip)
    -- end

---------------------------------------------------------------------------------------------------------
    
        if sipsLeft <= 0 then
            bottleCount = bottleCount + 1
            showNotification(_U('drinking.finish', { count = bottleCount }))
            
            TriggerServerEvent('aliano_alcohol_effect:removeItem', currentBottle)
            
            DeleteObject(bottleProp)
            bottleProp = nil
            currentBottle = nil
            checkDrunkLevel()
        else
            showNotification(_U('drinking.sip', { remaining = sipsLeft }))
        end
    
        isDrinking = false
    end
    
    --------------------------------------------------------------------------------
    -- SECTION 8: MAIN THREADS
    --------------------------------------------------------------------------------
    -- Controls
    Citizen.CreateThread(function()
        while true do
            Wait(0)
            if currentBottle then
                if sipsLeft > 0 and IsControlJustPressed(0, 38) and not isDrinking then
                    drinkSip()
                end
                
                if IsControlJustPressed(0, 73) then
                    stopDrinking()
                end
                
                if sipsLeft > 0 then
                    BeginTextCommandDisplayHelp("STRING")
                    AddTextComponentString(_U('drinking.help'))
                    EndTextCommandDisplayHelp(0, false, true, -1)
                end
            end
        end
    end)
    
    -- Blood alcohol reduction thread
    Citizen.CreateThread(function()
        while true do
            Wait(Config.Effects.reduction.time)
            if bottleCount > 0 and not isHangover then
                bottleCount = bottleCount - Config.Effects.reduction.rate
                if bottleCount < 0 then bottleCount = 0 end
                checkDrunkLevel()
            end
        end
    end)
    
    --------------------------------------------------------------------------------
    -- SECTION 9: EVENTS
    --------------------------------------------------------------------------------

    RegisterNetEvent('aliano_alcohol_effect:startDrinking', function(data)
        local itemName = data and data.name or data
        if not itemName then return end
        
        for _, alcoholItem in ipairs(Config.AlcoholItems) do
            if itemName == alcoholItem then
                if currentBottle then
                    stopDrinking()
                end
                
                currentBottle = itemName
                sipsLeft = Config.SipsPerBottle
                attachBottle()
                showNotification(_U('drinking.start'))
                break
            end
        end
    end)
    
    -- Inventory compatibility
    AddEventHandler('ox_inventory:usedItem', function(item)
        TriggerEvent('aliano_alcohol_effect:startDrinking', item)
    end)
    
    -- death & respawn managment
    AddEventHandler('esx:onPlayerDeath', function()
        stopDrinking()
    end)
    
    AddEventHandler('playerSpawned', function()
        stopDrinking()
    end)
    
    --------------------------------------------------------------------------------
    -- SECTION 10: CONTROLS
    --------------------------------------------------------------------------------
    -- Reset effects (admin only)
    RegisterCommand('resetalcoholeffects', function()
        bottleCount = 0
        lastThreshold = 0
        isHangover = false
        stopDrinking()
        resetEffects()
        AnimpostfxStopAll()
        showNotification(_U('commands.reset'))
    end, false)
    
    -- Alcohol rate
    RegisterCommand('alcoholstatus', function()
        showNotification(_U('commands.status', { count = bottleCount }))
        if currentBottle then
            showNotification(_U('commands.current', { bottle = currentBottle, remaining = sipsLeft }))
        end
    end, false)
    
    --------------------------------------------------------------------------------
    -- SECTION 11: DRUNK DRIVING
    --------------------------------------------------------------------------------
    local function applyDrunkDrivingEffects()
        if not Config.DrunkDriving.enabled or bottleCount < Config.DrunkDriving.minBottles then
            if drunkDrivingActive then
                AnimpostfxStop("DrugsDrivingIn")
                drunkDrivingActive = false
            end
            return
        end
    
        local playerPed = PlayerPedId()
        if not IsPedInAnyVehicle(playerPed, false) then return end
    
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if not DoesEntityExist(vehicle) or GetPedInVehicleSeat(vehicle, -1) ~= playerPed then return end
    
        local effectLevel = math.min(math.floor(bottleCount / 2) + 1, 3)
        local effects = Config.DrunkDriving.effects[effectLevel]
    
        if effects.blurEffect then
            if not drunkDrivingActive then
                AnimpostfxPlay("DrugsDrivingIn", 0, true)
                drunkDrivingActive = true
            end
        else
            if drunkDrivingActive then
                AnimpostfxStop("DrugsDrivingIn")
                drunkDrivingActive = false
            end
        end
    
        if GetEntitySpeed(vehicle) > 5 then
            local steering = (math.random() - 0.5) * effects.steeringBias
            SetVehicleSteerBias(vehicle, steering)
        end
    
        if IsControlPressed(0, Config.DrunkDriving.controls.accelerate) then
            if math.random() < 0.1 then
                local speed = GetEntitySpeed(vehicle)
                local variation = speed * (math.random() * effects.speedVariation * 2 - effects.speedVariation)
                SetVehicleForwardSpeed(vehicle, speed + variation)
            end
        end
    
        if math.random() < effects.brakeChance then
            if not IsControlPressed(0, Config.DrunkDriving.controls.brake) then
                SetVehicleBrake(vehicle, true)
                SetVehicleForwardSpeed(vehicle, GetEntitySpeed(vehicle) * 0.7)
                Citizen.Wait(300)
                SetVehicleBrake(vehicle, false)
            end
        end
    
        if effects.randomHonking and math.random() < 0.02 then
            StartVehicleHorn(vehicle, 1000, "NORMAL", false)
        end
    end
    
    -- Drunk driving thread
    Citizen.CreateThread(function()
        while true do
            local waitTime = 100
            if bottleCount >= Config.DrunkDriving.minBottles and IsPedInAnyVehicle(PlayerPedId()) then
                waitTime = 0
                applyDrunkDrivingEffects()
            end
            Wait(waitTime)
        end
    end)
    
    --------------------------------------------------------------------------------
    -- SECTION 12: PERFORMANCE (DEBUG) 
    --------------------------------------------------------------------------------
    -- RegisterCommand('perf', function()
    --     print(collectgarbage("count").." KB mem | "..GetFrameTime().."ms/frame")
    -- end)