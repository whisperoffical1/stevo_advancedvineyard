if not lib.checkDependency('stevo_lib', '1.7.2') then error('stevo_lib 1.7.2 required for stevo_advancedvineyard') end
lib.locale()
local config = require('config')
local stevo_lib = exports['stevo_lib']:import()
local progress = config.progressCircle and lib.progressCircle or lib.progressBar
local blips = {}
local grapeVines = {}
local lastPicked = false
local processingEntity = 0

local function createBlip(blip)
    if not blip then return end
    local createdBlip = AddBlipForCoord(blip.coords.x, blip.coords.y, blip.coords.z)
    SetBlipSprite(createdBlip, blip.sprite or 1)
    SetBlipDisplay(createdBlip, blip.display or 4)
    SetBlipScale(createdBlip, blip.scale or 1.0)
    SetBlipColour(createdBlip, blip.colour or 1)
    SetBlipAsShortRange(createdBlip, blip.shortRange or false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(blip.name)
    EndTextCommandSetBlipName(createdBlip)
    return createdBlip
end


local function deleteBlips()
    if not blips then return end
    for i = 1, #blips do
        local blip = blips[i]
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}
end

local function pickGrape(i)


    if lastPicked and grapeVines[i] >= config.grapePicking.pickLimit and lastPicked == i then 
        stevo_lib.Notify(locale('notify.pickLimit'), 'error', 3000)
        return
    end

    if lastPicked and lastPicked ~= i then 
        grapeVines[lastPicked] = 0
    end
    
    if config.grapePicking.skillCheck then 
        Wait(500)
        if not lib.skillCheck(config.grapePicking.skillCheck) then 
            return stevo_lib.Notify(locale('notify.failedSkill'), 'error', 3000)
        end
    end

    grapeVines[i] = grapeVines[i] +1
    lastPicked = i

    if progress({
        duration = config.grapePicking.pickDuration * 1000,
        position = 'bottom',
        label = locale('progress.pickingGrape'),
        useWhileDead = false,
        canCancel = false,
        anim = {
            dict = config.grapePicking.animDict,
            clip = config.grapePicking.animClip,
            scenario = config.grapePicking.scenario
        },
        disable = { move = true, car = true, mouse = false, combat = true, },
    }) then    
        local pickedFruit = lib.callback.await('stevo_advancedvineyard:grapePicked', false)
        if pickedFruit then 
            stevo_lib.Notify(locale('notify.pickedGrape'), 'success', 3000)
        end
        if config.interaction == 'textui' then
            lib.showTextUI(locale("textui.pickGrapes"))
        end
    end

end

local function getPercentageDone(currentTime, startTime, finishTime)
    local totalDuration = finishTime - startTime
    local elapsed = currentTime - startTime
    local percentage = 0

    if totalDuration <= 0 then
        percentage = 100
    elseif currentTime >= finishTime then
        percentage = 100
    elseif currentTime <= startTime then
        percentage = 0
    else
        percentage = (elapsed / totalDuration) * 100
    end
    if percentage < 0 then
        percentage = 0
    elseif percentage > 100 then
        percentage = 100
    end

    return math.floor(percentage)
end


local function processWine()

    local wineProcess, time = lib.callback.await('stevo_advancedvineyard:getWineProcess', false)
    local menuOptions = {}

    if not wineProcess then 
        menuOptions = {
            {
                title = locale("menu.processWine"),
                description = locale("menu.processWineDescription"),
                icon = 'wine-bottle',
                arrow = true,
                onSelect = function()
                    local startProcess = lib.callback.await('stevo_advancedvineyard:startWineProcess', false)

                    if not startProcess then 
                        stevo_lib.Notify(locale("notify.notEnoughGrapes"), 'error', 3000)
                        if config.interaction == 'textui' then
                            lib.showTextUI(locale("textui.processGrapes"))
                        end
                    end

                    if startProcess then 
                        stevo_lib.Notify(locale("notify.startedProcessing"), 'success', 3000)
                        processWine()
                    end
                end
            },
        }
    else 
        local percentageDone = getPercentageDone(time, wineProcess.data.startTime, wineProcess.data.finishTime)
        local totalBottles = wineProcess.data.redBottles + wineProcess.data.whiteBottles
        menuOptions = {
            {
                title = locale("menu.processInfo"),
                description = (locale("menu.processInfoDescription")):format(wineProcess.data.redBottles, wineProcess.data.whiteBottles),
                icon = 'wine-bottle',
            },  
            {
                title = locale("menu.processProgress"),
                description = (locale("menu.processingProgressDescription")):format(percentageDone),
                icon = 'spinner',
                colorScheme = 
                    percentageDone < 10 and 'red' or
                    percentageDone < 25 and 'orange' or
                    percentageDone < 40 and 'yellow' or
                    percentageDone < 55 and 'lime' or
                    percentageDone < 70 and 'green' or
                    percentageDone < 85 and 'teal' or
                    'blue',
                progress = percentageDone,
            }
        }

        if percentageDone == 100 then 
            table.insert(menuOptions, {
            title = locale("menu.bottleWine"),
            description = locale("menu.bottleWineDescription", totalBottles),
            icon = 'wine-bottle',
            arrow = true,
            onSelect = function()
                local bottleWine = lib.callback.await('stevo_advancedvineyard:bottleWine', false)

                if not bottleWine then 
                    stevo_lib.Notify(locale("notify.notEnoughBottles", totalBottles), 'error', 5000)

                    return lib.showContext('stevo_advancedvineyard_processing')
                end

                
                if progress({
                    duration = config.grapeProcessing.bottleDuration * totalBottles * 1000,
                    position = 'bottom',
                    label = locale('progress.bottlingWine'),
                    useWhileDead = false,
                    canCancel = false,
                    anim = {
                        dict = config.grapeProcessing.animDict,
                        clip = config.grapeProcessing.animClip
                    },
                    disable = { move = true, car = true, mouse = false, combat = true, },
                }) then    
                    if config.interaction == 'textui' then
                        lib.showTextUI(locale("textui.processGrapes"))
                    end
                    stevo_lib.Notify(locale("notify.bottledWine"), 'success', 5000)
                    TriggerServerEvent('stevo_advancedvineyard:bottledWine')
                end


            end})
        end

       
    end

    lib.registerContext({
        id = 'stevo_advancedvineyard_processing',
        title = locale("menu.processingTitle"),
        options = menuOptions,
        onExit = function()
            if config.interaction == 'textui' then
                lib.showTextUI(locale("textui.processGrapes"))
            end
        end
    })
    lib.showContext('stevo_advancedvineyard_processing')
end

local function wineBoss()

    
    local buyerOptions = {
        {
            title = locale("menu.sellWine"),
            description = locale("menu.sellWineDescription", config.wineBoss.buyItems['redwinebottle'].sale, config.wineBoss.buyItems['whitewinebottle'].sale),
            icon = 'wine-bottle',
            arrow = true,
            onSelect = function()
                local sellWine, profit, wineSold  = lib.callback.await('stevo_advancedvineyard:sellWine', false)
                if sellWine then 
                    stevo_lib.Notify((locale('notify.soldWine'):format(wineSold, profit)), 'success', 3000)
                else 
                    stevo_lib.Notify(locale("notify.noWine"), 'error', 3000)
                end
                if config.interaction == 'textui' then
                    lib.showTextUI(locale("textui.wineBoss")) 
                end
            end
        },
        {
            title = (locale("menu.buyWineBottles")):format(config.wineBoss.emptyBottleCost),
            icon = 'wine-bottle',
            arrow = true,
            onSelect = function()
                local input = lib.inputDialog(locale("input.sellWine"), {
                    {type = 'number', label = locale("input.wineAmount"), icon = 'hashtag'},

                })
                
                if not input[1] then 
                    if config.interaction == 'textui' then
                        lib.showTextUI(locale("textui.wineBoss")) 
                    end
                    return 
                end

                local buyWineBottles = lib.callback.await('stevo_advancedvineyard:buyEmptyBottles', false, input[1])

                if buyWineBottles then 
                    stevo_lib.Notify((locale('notify.boughtBottles'):format(buyWineBottles)), 'success', 3000)
                else 
                    stevo_lib.Notify(locale("notify.notEnoughMoney"), 'error', 3000)
                end
            end
        }
    }

    lib.registerContext({
        id = 'stevo_vineyard_buyer',
        title = locale('menu.buyerTitle'),
        onExit = function()
            if config.interaction == 'textui' then
                lib.showTextUI(locale("textui.wineBoss")) 
            end
        end,
        options = buyerOptions
    })
    lib.showContext('stevo_vineyard_buyer')
end




local function initPoints()

    createBlip(config.grapePicking.blip)

    if config.interaction == 'textui' then
        
        for i = 1, #config.grapePicking.points do
            local point = config.grapePicking.points[i]
            local fruitProp = 0

            grapeVines[i] = 0
            
            lib.points.new({
                coords = point,
                distance = config.grapePicking.viewDistance,
                debug = true,
                onEnter = function()
                    lib.showTextUI(locale("textui.pickGrapes")) 
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                nearby = function(self)
                    local marker = config.grapePicking.marker
                    if marker then
                        DrawMarker(marker.type, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, marker.color.r, marker.color.g, marker.color.b, marker.color.a, false, true, 2, false, nil, nil, false)
                        lib.showTextUI(locale("textui.pickGrapes"))
                    end
                    if self.currentDistance < config.grapePicking.interactDistance and IsControlJustPressed(0, 38) then
                        lib.hideTextUI()
                        pickGrape(i)                  
                    end
                end,
            })
            
        end
    else          
        for i = 1, #config.grapePicking.points do
            local point = config.grapePicking.points[i]

            grapeVines[i] = 0

            
            local options = {
                options = {
                    {
                        name = 'pick_grapes',
                        type = "client",
                        action = function() 
                            pickGrape(i)
                        end,
                        icon =  config.grapePicking.targetIcon,
                        label = config.grapePicking.targetLabel,
                    }
                },
                distance = config.grapePicking.interactDistance,
                rotation = 45
            }
            stevo_lib.target.AddBoxZone('stevograpepicking'..i, point, vec3(3, 3, 3), options)  
        end 


    end

    createBlip(config.grapeProcessing.blip)

    if config.interaction == 'textui' then
        lib.points.new({
            coords = config.grapeProcessing.point,
            distance = config.grapeProcessing.viewDistance,
            debug = true,
            onEnter = function()
                lib.showTextUI(locale("textui.processGrapes")) 
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            nearby = function(self)
                if self.currentDistance < config.grapeProcessing.interactDistance and IsControlJustPressed(0, 38) then
                    processWine()
                    lib.hideTextUI()             
                end
            end,
        })
    else 
        local options = {
            options = {
                {
                    name = 'pick_grapes',
                    type = "client",
                    action = function() 
                        processWine()
                    end,
                    icon =  config.grapeProcessing.targetIcon,
                    label = config.grapeProcessing.targetLabel,
                }
            },
            distance = config.grapeProcessing.interactDistance,
            rotation = 45
        }
        stevo_lib.target.AddBoxZone('stevograpeProcessing', config.grapeProcessing.point, vec3(3, 3, 3), options)  
    end

    lib.requestModel(config.grapeProcessing.entity.model)
    processingEntity = CreateObject(config.grapeProcessing.entity.model, config.grapeProcessing.entity.coords.x, config.grapeProcessing.entity.coords.y, config.grapeProcessing.entity.coords.z, false, true, false)
    SetEntityHeading(processingEntity, config.grapeProcessing.entity.coords.w)


    local pedModel = config.wineBoss.ped.model
    local pedCoords =  config.wineBoss.ped.coords
    lib.requestModel(pedModel)

    local boss = CreatePed(28, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.w, false, false)

    while not DoesEntityExist(boss) do Wait(50) end

    FreezeEntityPosition(boss, true)
    SetEntityInvincible(boss, true)
SetBlockingOfNonTemporaryEvents(boss, true)
    TaskStartScenarioInPlace(boss, 'WORLD_HUMAN_CLIPBOARD', 0.0, true)
    SetModelAsNoLongerNeeded(pedModel)

    local vanModel = config.wineBoss.van.model 
    local vanCoords = config.wineBoss.van.coords
    lib.requestModel(vanModel)

    local van = CreateVehicle(vanModel, vanCoords.x, vanCoords.y, vanCoords.z, vanCoords.w, false, false)

    while not DoesEntityExist(van) do Wait(50) end

    FreezeEntityPosition(van, true)
    SetModelAsNoLongerNeeded(pedModel)
    SetVehicleDoorOpen(van, 5, false, false)
    SetVehicleDoorsLocked(van, 2)
    
    if config.interaction == 'textui' then
        lib.points.new({
            coords = pedCoords.xyz,
            distance = config.wineBoss.viewDistance,
            debug = true,
            onEnter = function()
                lib.showTextUI(locale("textui.wineBoss")) 
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            nearby = function(self)
                if self.currentDistance < config.wineBoss.interactDistance and IsControlJustPressed(0, 38) then
                    wineBoss()
                    lib.hideTextUI()             
                end
            end,
        })
    else 
        local options = {
            options = {
                {
                    name = 'trickortreat',
                    type = "client",
                    action = function() 
                        local soldCandy, profit, candySold = lib.callback.await('stevo_trickortreat:sellCandy', false)

                        if soldCandy then 
                            stevo_lib.Notify(locale('notify.soldCandy', candySold, profit), 'success', 5000)
                        else 
                            stevo_lib.Notify(locale('notify.noCandy'), 'error', 3000)
                        end
                    end,
                    icon =  'fas fa-handshake',
                    label = locale("target.wineBoss"),
                }
            },
            distance = config.wineBoss.interactDistance,
            rotation = 45
        }
        stevo_lib.target.AddBoxZone('stevovineyardwineBoss', pedCoords.xyz, vec3(3, 3, 3),  options) 
    end


    createBlip(config.wineBoss.blip)
end


RegisterNetEvent('stevo_lib:playerLoaded', function()
    initPoints()
end)


AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end

    initPoints()
end)


AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end

    deleteBlips()

    if DoesEntityExist(processingEntity) then 
        DeleteEntity(processingEntity)
    end

end)
