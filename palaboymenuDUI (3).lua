
local ALLSTAR = {}
local DUI = nil
local PALABOY_DUI_URL = "https://palaboyproject-dui.pages.dev"

local ActiveMenu = {}
local CurrentMenu = ActiveMenu
local CurrentCategories = nil
local CurrentCategoryIndex = 1
local MenuStack = {}
local MenuLabelStack = {}
local HoveredIndex = 1
local IsVisible = false
local LastUIState = nil
local MenuOpenable = false
local MenuKey = nil
local MenuKeybinds = {}
local CurrentKeyboardInput = nil
local ShiftHolding = false
local CPlayers = {}

local NewThreadNs = 1
local AsThreadNs = 2
local currentEndpoint = nil
local Unloaded = false
local specificResource = nil
local Username = "user/key"
local ExpDate = ""

local FreecamEnabled = false
local LastWeaponFired = nil
local CurrentWeaponIndex = 1
local CurrentVehicleIndex = 1
local CurrentMapDestroyerIndex = 1
local CurrentSpawnObjectIndex = 1
local FreecamWeaponList = { "WEAPON_APPISTOL", "WEAPON_PISTOL", "WEAPON_SMG", "WEAPON_ASSAULTRIFLE", "WEAPON_RPG", "WEAPON_PERMKILL", "WEAPON_AIRSTRIKE_ROCKET" }
local FreecamVehicleList = { "Adder", "Zentorno", "Comet", "Banshee", "Trash", "Dump" }
local FreecamMapDestroyerList = { "City", "Docks", "Playa Vista", "Mountain", "Pink Cage", "Vespucci", "Mega Mall", "Platform", "Big Ring", "Tube", "Dessert", "Goal", "Big Statue 2", "House" }
local FreecamSpawnObjectList = { "Big Tires", "Dome", "Black Surface", "Spinning Object", "Arena Fire", "Landmine", "Big Wheels", "Cnt Arena", "Arena Skull", "Arena Bomb", "Waste Rims" }
local FreecamOptions = { "Default", "Teleport", "Shoot Weapon", "Shoot Vehicle", "Map Destroyer", "Spawn Object", "Helicopter Attack" }
local FreecamHoveredIndex = 1
local fgawjFmaDjdALaO = false
local fovEnabled = false
local fovShow = false
local fovRadius = 100

local selectedVehicle = nil
local isVehicleFlying = false
local Control_Vehicle_Thread = nil
local Control_Vehicle = false
local isSpectatorListVisible = false

local MappedKeys = {
    [0x08]="Backspace", [0x0D]="Enter", [0x20]="Space",
    [0x21]="PageUp", [0x22]="PageDown", [0x23]="End", [0x24]="Home",
    [0x25]="ArrowLeft", [0x26]="ArrowUp", [0x27]="ArrowRight", [0x28]="ArrowDown",
    [0x2D]="Insert", [0x2E]="Delete",
    [0x30]="0", [0x31]="1", [0x32]="2", [0x33]="3", [0x34]="4",
    [0x35]="5", [0x36]="6", [0x37]="7", [0x38]="8", [0x39]="9",
    [0x41]="A", [0x42]="B", [0x43]="C", [0x44]="D", [0x45]="E",
    [0x46]="F", [0x47]="G", [0x48]="H", [0x49]="I", [0x4A]="J",
    [0x4B]="K", [0x4C]="L", [0x4D]="M", [0x4E]="N", [0x4F]="O",
    [0x50]="P", [0x51]="Q", [0x52]="R", [0x53]="S", [0x54]="T",
    [0x55]="U", [0x56]="V", [0x57]="W", [0x58]="X", [0x59]="Y", [0x5A]="Z",
    [0x70]="F1", [0x71]="F2", [0x72]="F3", [0x73]="F4",
    [0x74]="F5", [0x75]="F6", [0x76]="F7", [0x77]="F8",
    [0x78]="F9", [0x79]="F10", [0x7A]="F11", [0x7B]="F12",
    [27]="Escape", [192]="`", [189]="-", [187]="=", [9]="Tab",
    [219]="[", [221]="]", [220]="\\", [20]="CapsLock",
    [186]=";", [222]="'", [16]="Shift", [17]="Control",
    [188]=",", [190]=".", [191]="/", [38]="ArrowUp", [40]="ArrowDown",
    [37]="ArrowLeft", [39]="ArrowRight", [33]="PageUp", [34]="PageDown",
    [35]="End", [36]="Home", [46]="Delete"
}

local VK_TO_FIVEM = {
    [27]=322,[112]=288,[113]=289,[114]=170,[115]=167,[116]=166,[117]=167,
    [118]=168,[119]=169,[120]=56,[121]=57,[122]=344,[123]=345,[192]=243,
    [49]=157,[50]=158,[51]=160,[52]=164,[53]=165,[54]=159,[55]=161,[56]=162,
    [57]=163,[48]=82,[189]=84,[187]=83,[8]=177,[9]=37,[81]=44,[87]=32,
    [69]=46,[82]=45,[84]=245,[89]=246,[85]=303,[73]=74,[79]=199,[80]=7,
    [219]=39,[221]=40,[220]=36,[20]=137,[65]=34,[83]=33,[68]=30,[70]=49,
    [71]=47,[72]=74,[74]=311,[75]=311,[76]=7,[186]=81,[222]=82,[13]=18,
    [16]=21,[90]=20,[88]=73,[67]=26,[86]=0,[66]=29,[78]=249,[77]=244,
    [188]=82,[190]=81,[191]=83,[17]=36,[46]=178,[33]=10,[34]=11,[35]=213,
    [36]=213,[38]=27,[40]=173,[37]=174,[39]=175
}

local WeaponList = {
    ["weapon_unarmed"]={label="Unarmed",hash=GetHashKey("weapon_unarmed")},
    ["weapon_knife"]={label="Knife",hash=GetHashKey("weapon_knife")},
    ["weapon_dagger"]={label="Dagger",hash=GetHashKey("weapon_dagger")},
    ["weapon_bat"]={label="Baseball Bat",hash=GetHashKey("weapon_bat")},
    ["weapon_bottle"]={label="Broken Bottle",hash=GetHashKey("weapon_bottle")},
    ["weapon_crowbar"]={label="Crowbar",hash=GetHashKey("weapon_crowbar")},
    ["weapon_golfclub"]={label="Golf Club",hash=GetHashKey("weapon_golfclub")},
    ["weapon_hammer"]={label="Hammer",hash=GetHashKey("weapon_hammer")},
    ["weapon_hatchet"]={label="Hatchet",hash=GetHashKey("weapon_hatchet")},
    ["weapon_machete"]={label="Machete",hash=GetHashKey("weapon_machete")},
    ["weapon_switchblade"]={label="Switchblade",hash=GetHashKey("weapon_switchblade")},
    ["weapon_nightstick"]={label="Nightstick",hash=GetHashKey("weapon_nightstick")},
    ["weapon_wrench"]={label="Wrench",hash=GetHashKey("weapon_wrench")},
    ["weapon_pistol"]={label="Pistol",hash=GetHashKey("weapon_pistol")},
    ["weapon_pistol_mk2"]={label="Pistol Mk II",hash=GetHashKey("weapon_pistol_mk2")},
    ["weapon_combatpistol"]={label="Combat Pistol",hash=GetHashKey("weapon_combatpistol")},
    ["weapon_appistol"]={label="AP Pistol",hash=GetHashKey("weapon_appistol")},
    ["weapon_stungun"]={label="Taser",hash=GetHashKey("weapon_stungun")},
    ["weapon_pistol50"]={label="Pistol .50",hash=GetHashKey("weapon_pistol50")},
    ["weapon_snspistol"]={label="SNS Pistol",hash=GetHashKey("weapon_snspistol")},
    ["weapon_heavypistol"]={label="Heavy Pistol",hash=GetHashKey("weapon_heavypistol")},
    ["weapon_vintagepistol"]={label="Vintage Pistol",hash=GetHashKey("weapon_vintagepistol")},
    ["weapon_flaregun"]={label="Flare Gun",hash=GetHashKey("weapon_flaregun")},
    ["weapon_microsmg"]={label="Micro SMG",hash=GetHashKey("weapon_microsmg")},
    ["weapon_smg"]={label="SMG",hash=GetHashKey("weapon_smg")},
    ["weapon_smg_mk2"]={label="SMG Mk II",hash=GetHashKey("weapon_smg_mk2")},
    ["weapon_assaultsmg"]={label="Assault SMG",hash=GetHashKey("weapon_assaultsmg")},
    ["weapon_machinepistol"]={label="Machine Pistol",hash=GetHashKey("weapon_machinepistol")},
    ["weapon_minismg"]={label="Mini SMG",hash=GetHashKey("weapon_minismg")},
    ["weapon_combatpdw"]={label="Combat PDW",hash=GetHashKey("weapon_combatpdw")},
    ["weapon_assaultrifle"]={label="Assault Rifle",hash=GetHashKey("weapon_assaultrifle")},
    ["weapon_assaultrifle_mk2"]={label="Assault Rifle Mk II",hash=GetHashKey("weapon_assaultrifle_mk2")},
    ["weapon_carbinerifle"]={label="Carbine Rifle",hash=GetHashKey("weapon_carbinerifle")},
    ["weapon_carbinerifle_mk2"]={label="Carbine Rifle Mk II",hash=GetHashKey("weapon_carbinerifle_mk2")},
    ["weapon_advancedrifle"]={label="Advanced Rifle",hash=GetHashKey("weapon_advancedrifle")},
    ["weapon_specialcarbine"]={label="Special Carbine",hash=GetHashKey("weapon_specialcarbine")},
    ["weapon_bullpuprifle"]={label="Bullpup Rifle",hash=GetHashKey("weapon_bullpuprifle")},
    ["weapon_bullpuprifle_mk2"]={label="Bullpup Rifle Mk II",hash=GetHashKey("weapon_bullpuprifle_mk2")},
    ["weapon_compactrifle"]={label="Compact Rifle",hash=GetHashKey("weapon_compactrifle")},
    ["weapon_marksmanrifle"]={label="Marksman Rifle",hash=GetHashKey("weapon_marksmanrifle")},
    ["weapon_pumpshotgun"]={label="Pump Shotgun",hash=GetHashKey("weapon_pumpshotgun")},
    ["weapon_pumpshotgun_mk2"]={label="Pump Shotgun Mk II",hash=GetHashKey("weapon_pumpshotgun_mk2")},
    ["weapon_sawnoffshotgun"]={label="Sawed-Off Shotgun",hash=GetHashKey("weapon_sawnoffshotgun")},
    ["weapon_assaultshotgun"]={label="Assault Shotgun",hash=GetHashKey("weapon_assaultshotgun")},
    ["weapon_bullpupshotgun"]={label="Bullpup Shotgun",hash=GetHashKey("weapon_bullpupshotgun")},
    ["weapon_heavyshotgun"]={label="Heavy Shotgun",hash=GetHashKey("weapon_heavyshotgun")},
    ["weapon_autoshotgun"]={label="Auto Shotgun",hash=GetHashKey("weapon_autoshotgun")},
    ["weapon_sniperrifle"]={label="Sniper Rifle",hash=GetHashKey("weapon_sniperrifle")},
    ["weapon_heavysniper"]={label="Heavy Sniper",hash=GetHashKey("weapon_heavysniper")},
    ["weapon_heavysniper_mk2"]={label="Heavy Sniper Mk II",hash=GetHashKey("weapon_heavysniper_mk2")},
    ["weapon_marksmanrifle_mk2"]={label="Marksman Rifle Mk II",hash=GetHashKey("weapon_marksmanrifle_mk2")},
    ["weapon_grenade"]={label="Grenade",hash=GetHashKey("weapon_grenade")},
    ["weapon_stickybomb"]={label="Sticky Bomb",hash=GetHashKey("weapon_stickybomb")},
    ["weapon_molotov"]={label="Molotov Cocktail",hash=GetHashKey("weapon_molotov")},
    ["weapon_pipebomb"]={label="Pipe Bomb",hash=GetHashKey("weapon_pipebomb")},
    ["weapon_proxmine"]={label="Proximity Mine",hash=GetHashKey("weapon_proxmine")},
    ["weapon_rpg"]={label="RPG",hash=GetHashKey("weapon_rpg")},
    ["weapon_grenadelauncher"]={label="Grenade Launcher",hash=GetHashKey("weapon_grenadelauncher")},
    ["weapon_hominglauncher"]={label="Homing Launcher",hash=GetHashKey("weapon_hominglauncher")},
    ["weapon_minigun"]={label="Minigun",hash=GetHashKey("weapon_minigun")},
    ["weapon_railgun"]={label="Railgun",hash=GetHashKey("weapon_railgun")},
    ["weapon_ball"]={label="Baseball",hash=GetHashKey("weapon_ball")},
    ["weapon_smokegrenade"]={label="Smoke Grenade",hash=GetHashKey("weapon_smokegrenade")},
    ["weapon_flare"]={label="Flare",hash=GetHashKey("weapon_flare")},
    ["weapon_petrolcan"]={label="Jerry Can",hash=GetHashKey("weapon_petrolcan")},
    ["weapon_bzgas"]={label="BZ Gas",hash=GetHashKey("weapon_bzgas")}
}

local WeaponsLabels = {
    [GetHashKey('weapon_unarmed')]='Fists',[GetHashKey('weapon_knife')]='Knife',
    [GetHashKey('weapon_nightstick')]='Nightstick',[GetHashKey('weapon_hammer')]='Hammer',
    [GetHashKey('weapon_bat')]='Baseball Bat',[GetHashKey('weapon_golfclub')]='Golf Club',
    [GetHashKey('weapon_crowbar')]='Crowbar',[GetHashKey('weapon_pistol')]='Pistol',
    [GetHashKey('weapon_pistol_mk2')]='Pistol Mk II',[GetHashKey('weapon_combatpistol')]='Combat Pistol',
    [GetHashKey('weapon_appistol')]='AP Pistol',[GetHashKey('weapon_pistol50')]='Pistol .50',
    [GetHashKey('weapon_snspistol')]='SNS Pistol',[GetHashKey('weapon_heavypistol')]='Heavy Pistol',
    [GetHashKey('weapon_microsmg')]='Micro SMG',[GetHashKey('weapon_smg')]='SMG',
    [GetHashKey('weapon_assaultsmg')]='Assault SMG',[GetHashKey('weapon_assaultrifle')]='Assault Rifle',
    [GetHashKey('weapon_carbinerifle')]='Carbine Rifle',[GetHashKey('weapon_advancedrifle')]='Advanced Rifle',
    [GetHashKey('weapon_specialcarbine')]='Special Carbine',[GetHashKey('weapon_bullpuprifle')]='Bullpup Rifle',
    [GetHashKey('weapon_pumpshotgun')]='Pump Shotgun',[GetHashKey('weapon_sawnoffshotgun')]='Sawed-Off Shotgun',
    [GetHashKey('weapon_assaultshotgun')]='Assault Shotgun',[GetHashKey('weapon_bullpupshotgun')]='Bullpup Shotgun',
    [GetHashKey('weapon_heavyshotgun')]='Heavy Shotgun',[GetHashKey('weapon_autoshotgun')]='Auto Shotgun',
    [GetHashKey('weapon_sniperrifle')]='Sniper Rifle',[GetHashKey('weapon_heavysniper')]='Heavy Sniper',
    [GetHashKey('weapon_grenadelauncher')]='Grenade Launcher',[GetHashKey('weapon_rpg')]='RPG',
    [GetHashKey('weapon_minigun')]='Minigun',[GetHashKey('weapon_grenade')]='Grenade',
    [GetHashKey('weapon_stickybomb')]='Sticky Bomb',[GetHashKey('weapon_smokegrenade')]='Smoke Grenade',
    [GetHashKey('weapon_bzgas')]='BZ Gas',[GetHashKey('weapon_molotov')]='Molotov Cocktail',
    [GetHashKey('weapon_fireextinguisher')]='Fire Extinguisher',[GetHashKey('weapon_petrolcan')]='Jerry Can',
    [GetHashKey('weapon_ball')]='Baseball',[GetHashKey('weapon_bottle')]='Broken Bottle',
    [GetHashKey('weapon_gusenberg')]='Gusenberg Sweeper',[GetHashKey('weapon_dagger')]='Dagger',
    [GetHashKey('weapon_vintagepistol')]='Vintage Pistol',[GetHashKey('weapon_firework')]='Firework Launcher',
    [GetHashKey('weapon_musket')]='Musket',[GetHashKey('weapon_marksmanrifle')]='Marksman Rifle',
    [GetHashKey('weapon_hominglauncher')]='Homing Launcher',[GetHashKey('weapon_proxmine')]='Proximity Mines',
    [GetHashKey('weapon_snowball')]='Snowball',[GetHashKey('weapon_flaregun')]='Flare Gun',
    [GetHashKey('weapon_handcuffs')]='Handcuffs',[GetHashKey('weapon_combatpdw')]='Combat PDW',
    [GetHashKey('weapon_marksmanpistol')]='Marksman Pistol',[GetHashKey('weapon_knuckle')]='Knuckle Dusters',
    [GetHashKey('weapon_hatchet')]='Hatchet',[GetHashKey('weapon_railgun')]='Railgun',
    [GetHashKey('weapon_machinepistol')]='Machine Pistol',[GetHashKey('weapon_switchblade')]='Switchblade',
    [GetHashKey('weapon_revolver')]='Heavy Revolver',[GetHashKey('weapon_heavyrifle')]='Heavy Rifle',
    [GetHashKey('weapon_dbshotgun')]='Double Barrel Shotgun',[GetHashKey('weapon_compactrifle')]='Compact Rifle',
    [GetHashKey('weapon_battleaxe')]='Battle Axe',[GetHashKey('weapon_compactlauncher')]='Compact Grenade Launcher',
    [GetHashKey('weapon_minismg')]='Mini SMG',[GetHashKey('weapon_pipebomb')]='Pipe Bomb',
    [GetHashKey('weapon_poolcue')]='Pool Cue',[GetHashKey('weapon_wrench')]='Wrench',
    [GetHashKey('weapon_bread')]='Piece of Bread',[GetHashKey('weapon_stone_hatchet')]='Stone Hatchet',
    [GetHashKey('weapon_machete')]='Machete',[GetHashKey('weapon_flashlight')]='Flashlight'
}

local InjectionType = GetResourceState("WaveShield") == "started" and "Raw" or "Default"
local Injection = InjectionType == "Raw" and MachoInjectResourceRaw or MachoInjectResource

local targetRes =
    (GetResourceState("lunar_fishing") == "started" and "lunar_fishing") or
    (GetResourceState("jg-advancedgarages") == "started" and "jg-advancedgarages") or
    (GetResourceState("jg-dealerships") == "started" and "jg-dealerships") or
    (GetResourceState("cd_garage") == "started" and "cd_garage") or
    (GetResourceState("cfx-bg-garages") == "started" and "cfx-bg-garages") or
    (GetResourceState("es_extended") == "started" and "es_extended") or "any"

local targetSafeRes =
    (GetResourceState("es_extended") == "started" and "es_extended") or
    (GetResourceState("ox_lib") == "started" and "ox_lib") or "any"

local IsDetections = GetResourceState("seph") == 'started' or GetResourceState("sxph_idsystem") == 'started'

function ALLSTAR:Debug(color, text) end

function ALLSTAR:SendMessage(data)
    if not DUI or not data or type(data) ~= "table" then return end
    MachoSendDuiMessage(DUI, json.encode(data))
end

function ALLSTAR:Notify(type, title, desc, duration)
    self:SendMessage({ action="showNotification", type=type, title=title, desc=desc, duration=duration })
end

function ALLSTAR:NotifyFunctionAction(option, state)
    if not option or option.notify == false then return end
    local label = tostring(option.notifyLabel or option.label or "FUNCTION"):upper()
    local message

    if state ~= nil then
        message = label .. (state and " ENABLED" or " DISABLED")
    else
        message = label .. " TRIGGERED"
    end

    self:Notify(state == false and "info" or "success", "PALABOY", message, 3000)
end

function ALLSTAR:GetMenuPath()
    if not MenuLabelStack or #MenuLabelStack == 0 then
        return "Main Menu"
    end
    local path = {}
    for i = 1, #MenuLabelStack do
        path[#path+1] = tostring(MenuLabelStack[i])
    end
    return table.concat(path, " > ")
end

function ALLSTAR:IsShiftHeld() return ShiftHolding end

function ALLSTAR:UpdateElements(elements)
    if not elements or type(elements) ~= "table" then return end
    local payload = {
        action = "updateElements", elements = elements,
        index = math.max(0, HoveredIndex - 1), path = self:GetMenuPath()
    }
    if CurrentCategories and type(CurrentCategories) == "table" and #CurrentCategories > 0 then
        local categoryNames = {}
        for i, category in ipairs(CurrentCategories) do
            categoryNames[i] = type(category) == "table" and tostring(category.label or "") or tostring(category)
        end
        payload.categories = categoryNames
        payload.categoryIndex = math.max(0, (CurrentCategoryIndex or 1) - 1)
    else
        payload.categories = {}
        payload.categoryIndex = 0
    end
    self:SendMessage(payload)
end

function ALLSTAR:Initialize()
    DUI = MachoCreateDui(PALABOY_DUI_URL)
    if not DUI then return false end
    MachoShowDui(DUI)
    self:SendMessage({ action="showUI", visible=false, elements={}, index=0, path="Main Menu", categories={}, categoryIndex=0 })
    return true
end

function ALLSTAR:ShowUI()
    IsVisible = true
    if LastUIState then
        CurrentMenu = LastUIState.currentMenu
        HoveredIndex = LastUIState.hoveredIndex
        MenuStack = LastUIState.menuStack
        MenuLabelStack = LastUIState.menuLabelStack
        CurrentCategories = LastUIState.currentCategories
        CurrentCategoryIndex = LastUIState.currentCategoryIndex
        LastUIState = nil
    else
        CurrentMenu = ActiveMenu
        HoveredIndex = 1
        MenuStack = {}
        MenuLabelStack = {}
        CurrentCategories = nil
        CurrentCategoryIndex = 1
    end

    local names = {}
    if CurrentCategories and #CurrentCategories > 0 then
        for i, category in ipairs(CurrentCategories) do names[i] = category.label end
    end

    self:SendMessage({
        action = "showUI", visible = true,
        elements = CurrentMenu, index = math.max(0, HoveredIndex - 1),
        path = self:GetMenuPath(), username = Username, expiration = ExpDate,
        categories = names,
        categoryIndex = (CurrentCategories and #CurrentCategories > 0) and (CurrentCategoryIndex - 1) or 0
    })
end

function ALLSTAR:HideUI(keepState)
    if keepState then
        LastUIState = {
            currentMenu = CurrentMenu, hoveredIndex = HoveredIndex,
            menuStack = MenuStack, menuLabelStack = MenuLabelStack,
            currentCategories = CurrentCategories,
            currentCategoryIndex = CurrentCategoryIndex
        }
    else
        LastUIState = nil
    end
    IsVisible = false
    self:SendMessage({ action = "showUI", visible = false, index = 0 })
end

MachoOnKeyDown(function(vk)
    if vk == 0x10 or vk == 0xA0 or vk == 0xA1 then ShiftHolding = true end
end)
MachoOnKeyUp(function(vk)
    if vk == 0x10 or vk == 0xA0 or vk == 0xA1 then ShiftHolding = false end
end)

local function KeyboardInput(Title, Value, OnConfirm, InputType)
    if CurrentKeyboardInput then return end
    CurrentKeyboardInput = {
        title = Title, buffer = Value or "", maxLength = 32,
        onConfirm = OnConfirm, type = InputType or "typeable",
        closeable = InputType == "keybind" and false or true, active = true
    }
    ALLSTAR:SendMessage({ action="updateKeyboard", visible=true, title=Title, value=CurrentKeyboardInput.buffer })

    if GetResourceState("rryban_secure") == "started" then
    elseif GetResourceState("Eminence") == "started" then
    elseif GetResourceState("AegisX") == "started" then
    elseif GetResourceState("cfx-praryo-kernel") == "started" then
    elseif GetResourceState("amari-utils") == "started" then
    elseif GetResourceState("VynxAC") == "started" then
    else
        MachoInjectResourceRaw("monitor", [[ SetNuiFocus(true, false) sendMenuMessage('setDebugMode') ]])
    end

    Wait(250)
    ALLSTAR:HideUI(true)
    MenuOpenable = false
end

local function StartKeyCapture(title, onConfirm)
    KeyboardInput(title, "", onConfirm, "keybind")
end

local function FinishKeyCapture()
    ALLSTAR:SendMessage({ action = "updateKeyboard", visible = false })
    CurrentKeyboardInput = nil
    MenuOpenable = true
end

local function RestoreNuiFocus()
    if GetResourceState("rryban_secure") == "started" then
    elseif GetResourceState("Eminence") == "started" then
    elseif GetResourceState("AegisX") == "started" then
    elseif GetResourceState("cfx-praryo-kernel") == "started" then
    elseif GetResourceState("amari-utils") == "started" then
    elseif GetResourceState("VynxAC") == "started" then
    else
        MachoInjectResourceRaw("monitor", [[ SetNuiFocus(false, false) sendMenuMessage('setGameName') ]])
    end
end

MachoOnKeyDown(function(vk)
    if not CurrentKeyboardInput or not CurrentKeyboardInput.active then return end
    if vk == 0x0D then
        CurrentKeyboardInput.active = false
        ALLSTAR:SendMessage({ action = "updateKeyboard", visible = false })
        local value = (CurrentKeyboardInput.type == "keybind") and CurrentKeyboardInput.chosenVK or CurrentKeyboardInput.buffer
        local cb = CurrentKeyboardInput.onConfirm
        RestoreNuiFocus()
        CurrentKeyboardInput = nil
        MenuOpenable = true
        if cb then cb(value) end
        return
    elseif vk == 0x08 then
        if CurrentKeyboardInput.type == "typeable" then
            CurrentKeyboardInput.buffer = CurrentKeyboardInput.buffer:sub(1, -2)
        else
            CurrentKeyboardInput.buffer = ""
            CurrentKeyboardInput.chosenVK = nil
        end
    elseif vk == 0x1B then
        if not CurrentKeyboardInput.closeable then return end
        RestoreNuiFocus()
        CurrentKeyboardInput.active = false
        ALLSTAR:SendMessage({ action = "updateKeyboard", visible = false })
        CurrentKeyboardInput = nil
        MenuOpenable = true
        return
    else
        if CurrentKeyboardInput.type == "keybind" then
            local keyName = MappedKeys[vk]
            if keyName then
                CurrentKeyboardInput.buffer = keyName
                CurrentKeyboardInput.chosenVK = vk
            end
        elseif CurrentKeyboardInput.type == "typeable" then
            local AllowedChars = {
                [0x30]="0",[0x31]="1",[0x32]="2",[0x33]="3",[0x34]="4",
                [0x35]="5",[0x36]="6",[0x37]="7",[0x38]="8",[0x39]="9",
                [0x41]="A",[0x42]="B",[0x43]="C",[0x44]="D",[0x45]="E",
                [0x46]="F",[0x47]="G",[0x48]="H",[0x49]="I",[0x4A]="J",
                [0x4B]="K",[0x4C]="L",[0x4D]="M",[0x4E]="N",[0x4F]="O",
                [0x50]="P",[0x51]="Q",[0x52]="R",[0x53]="S",[0x54]="T",
                [0x55]="U",[0x56]="V",[0x57]="W",[0x58]="X",[0x59]="Y",
                [0x5A]="Z",[0xBD]="-",[0xBB]="=",[0xBC]=",",[0xBE]=".",
                [0xBA]=";",[0xDE]="'",[0xBF]="/",[0xC0]="`",[0x20]=" "
            }
            local char = AllowedChars[vk]
            if char and #CurrentKeyboardInput.buffer < CurrentKeyboardInput.maxLength then
                if ALLSTAR:IsShiftHeld() then
                    if char:match("%a") then char = char:upper()
                    elseif char == "-" then char = "_" end
                else
                    if char:match("%a") then char = char:lower() end
                end
                CurrentKeyboardInput.buffer = CurrentKeyboardInput.buffer .. char
            end
        end
    end
    if CurrentKeyboardInput then
        ALLSTAR:SendMessage({
            action = "updateKeyboard", visible = true,
            title = CurrentKeyboardInput.title, value = CurrentKeyboardInput.buffer
        })
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if CurrentKeyboardInput ~= nil then
            if GetResourceState("rryban_secure") == "started" then
            elseif GetResourceState("Eminence") == "started" then
            elseif GetResourceState("AegisX") == "started" then
            elseif GetResourceState("cfx-praryo-kernel") == "started" then
            elseif GetResourceState("amari-utils") == "started" then
            elseif GetResourceState("VynxAC") == "started" then
            else
                MachoInjectResourceRaw("monitor", [[ SetNuiFocus(true, false) sendMenuMessage('setDebugMode') ]])
            end
            SetPauseMenuActive(false)
            for i = 0, 357 do
                if i < 0x30 or i > 0x5A then DisableControlAction(0, i, true) end
            end
        else
            Wait(500)
        end
    end
end)

local setHooks = {}
local hookedNatives = {}
local safeLoadedScripts = {}

local function CreateHook(hookType, cb) setHooks[hookType] = cb end

local function HookNative(setHash, callback)
    hookedNatives[#hookedNatives+1] = MachoHookNative(setHash, function(...)
        if GetCurrentResourceName() == 'lb-phone' or GetCurrentResourceName() == 'illenium-appearance' then return true end
        return callback(...)
    end)
end

HookNative(0x68EDDA28A5976D07, function() return false, false end)
HookNative(0xA571D46727E2B718, function(padIndex)
    if padIndex == 0 then return false, false end
    return true
end)
HookNative(0x1CEA6BFDF248E5D9, function(padIndex, control)
    if control == 1 or control == 2 then return false, true end
    return true
end)
HookNative(0xB15162CB5826E9E8, function() return false, true end)
HookNative(0xD9D2CFFF49FAB35F, function() return false, true end)
HookNative(0x036F97C908C2B52C, function() return false, true end)
HookNative(0xF5F1E89A970B7796, function() return false, true end)
HookNative(0xCA9D2AA3E326D720, function() return false, true end)
HookNative(0x19CAFA3C87F7C2FF, function() return false, 3 end)

HookNative(0x0C515FAB3FF9EA92, function(propType, data)
    if menuInjected and propType and data then
        if propType == 'SetClient_LoadedSafeFuncs' then
            safeLoadedScripts[data] = true
        elseif propType == 'ALLSTAR.Hook' then
            data = json.decode(data)
            if data and data.HookData then
                local setHook = setHooks[data.HookData.HookType]
                if setHook then
                    CreateThread(function() setHook(table.unpack(data.HookData.SetArgs)) end)
                end
            end
        end
    end
    return true
end)

local stoppedResources = {}
local MainAPI = {}
MainAPI.StopResource = function(resource) stoppedResources[resource] = true MachoResourceStop(resource) end
MainAPI.StartResource = function(resource) stoppedResources[resource] = nil MachoResourceStart(resource) end
MainAPI.ResourceLoop = function(resource, pattern, w1, w2)
    CreateThread(function()
        while true do
            if pattern == "stop" then MachoResourceStop(resource) Wait(w1)
            elseif pattern == "stop_start" then MachoResourceStop(resource) Wait(w1) MachoResourceStart(resource) Wait(w2)
            else MachoResourceStart(resource) Wait(w1) MachoResourceStop(resource) Wait(w2) end
        end
    end)
end

local function executeCode(resource, code)
    local IsRyban = GetResourceState("rryban_secure") == "started"
    if IsRyban then
        local setCode = [[
            local ALLSTAR = {}
            ALLSTAR.SafeRunNative = function(setFunc, ...) return setFunc(...) end
        ]] .. code
        MachoInjectResourceScriptOverride(1, resource, setCode, '@citizen:/scripting/lua/scheduler.lua', 1, 999)
        return
    end

    local prelude = [[
        local ALLSTAR = {}
        ALLSTAR.RunId = 'RUN_ID'
        ALLSTAR.StringFind = string.find
        ALLSTAR.StringChar = string.char
        ALLSTAR.StringLower = string.lower
        ALLSTAR.TableUnpack = table.unpack
        ALLSTAR.EXT_FUNCREF = 10
        ALLSTAR.PackValueExt = function(tag, data)
            local len = #data
            if len == 1 then return ALLSTAR.StringChar(0xD4, tag)..data
            elseif len == 2 then return ALLSTAR.StringChar(0xD5, tag)..data
            elseif len == 4 then return ALLSTAR.StringChar(0xD6, tag)..data
            elseif len == 8 then return ALLSTAR.StringChar(0xD7, tag)..data
            elseif len == 16 then return ALLSTAR.StringChar(0xD8, tag)..data
            elseif len <= 255 then return ALLSTAR.StringChar(0xC7, len, tag)..data
            elseif len <= 65535 then return ALLSTAR.StringChar(0xC8, math.floor(len / 256), len % 256, tag)..data end
        end
        ALLSTAR.PackValue = function(val)
            local t = val ~= nil and type(val)
            if val == nil then return ALLSTAR.StringChar(0xC0)
            elseif t == 'boolean' then return ALLSTAR.StringChar(val and 0xC3 or 0xC2)
            elseif t == 'number' then
                if val % 1 == 0 then
                    if val >= 0 and val <= 127 then return ALLSTAR.StringChar(val)
                    elseif val < 0 and val >= -32 then return ALLSTAR.StringChar(0x100 + val)
                    elseif val >= 0 and val <= 0xFF then return ALLSTAR.StringChar(0xCC, val)
                    elseif val >= 0 and val <= 0xFFFF then return ALLSTAR.StringChar(0xCD, math.floor(val/256), val%256)
                    elseif val >= -128 and val < 0 then return ALLSTAR.StringChar(0xD0, 0x100 + val)
                    elseif val >= -32768 and val < 0 then
                        local v = 0x10000 + val
                        return ALLSTAR.StringChar(0xD1, math.floor(v/256), v%256)
                    end
                end
                return ALLSTAR.StringChar(0xCB) .. string.pack('>d', val)
            elseif t == 'string' then
                local len = #val
                if len <= 31 then return ALLSTAR.StringChar(0xA0 + len) .. val
                elseif len <= 255 then return ALLSTAR.StringChar(0xD9, len) .. val
                elseif len <= 65535 then return ALLSTAR.StringChar(0xDA, math.floor(len/256), len%256) .. val end
            elseif t == 'function' then
                local ref = Citizen.GetFunctionReference(val)
                if ref then return ALLSTAR.PackValueExt(ALLSTAR.EXT_FUNCREF, ref) end
            elseif t == 'table' then
                local cfxRef = rawget(val, '__cfx_functionReference')
                if cfxRef then
                    local ref = Citizen.GetFunctionReference(val)
                    if ref then return ALLSTAR.PackValueExt(ALLSTAR.EXT_FUNCREF, ref) end
                end
                local n = #val
                local header
                if n <= 15 then header = ALLSTAR.StringChar(0x90 + n)
                elseif n <= 65535 then header = ALLSTAR.StringChar(0xDC, math.floor(n/256), n%256) end
                local parts = { header }
                for i = 1, n do parts[#parts+1] = ALLSTAR.PackValue(val[i]) end
                return table.concat(parts)
            end
        end
        ALLSTAR.RawSafeRunNative = function(native, ...)
            local funcRef = msgpack.unpack(ALLSTAR.PackValue(native))
            return funcRef(...)
        end
        ALLSTAR.SetSafeStateBag = function(bag, key, value, synced)
            if value == nil then return end
            local payload = ALLSTAR.PackValue(value)
            if payload == nil then return end
            ALLSTAR.RawSafeRunNative(SetStateBagValue, bag, key, payload, #payload, synced)
        end
        ALLSTAR.SetSafeLocalState = function(key, value, synced)
            return ALLSTAR.SetSafeStateBag('player:'..GetPlayerServerId(PlayerId()), key, value, synced or false)
        end
        ALLSTAR.CachedSafeFuncs = {}
        ALLSTAR.GetSafeFunc = function(func)
            local safeFunc = ALLSTAR.CachedSafeFuncs[func]
            if safeFunc then return safeFunc end
            local serverId = GetPlayerServerId(PlayerId())
            local bag = 'player:'..serverId
            local key = '__cfx_stateBag::'..ALLSTAR.RunId..'::'..math.random(999999)..'::'..GetGameTimer()
            ALLSTAR.SetSafeStateBag(bag, key, func, false)
            safeFunc = Player(serverId).state[key]
            ALLSTAR.CachedSafeFuncs[func] = safeFunc
            return safeFunc
        end
        ALLSTAR.SafeRunNative = function(setNative, ...)
            local safeFunc = ALLSTAR.GetSafeFunc(setNative)
            return safeFunc(...)
        end
        ALLSTAR.SafeCall = function(cb, ...)
            local callArgs = {...}
            local createThread = ALLSTAR.GetSafeFunc(Citizen.CreateThreadNow)
            local safeCb = ALLSTAR.GetSafeFunc(cb)
            createThread(function() safeCb(ALLSTAR.TableUnpack(callArgs)) end)
        end
        ALLSTAR.DeleteTrackedThread = function(threadName)
            if _G.SetClient_TrackedSafeThreads then
                local cb = _G.SetClient_TrackedSafeThreads[threadName]
                if cb then cb() end
            end
        end
        ALLSTAR.DeleteAllTrackedThreads = function()
            if _G.SetClient_TrackedSafeThreads then
                local list = {}
                for _, cb in pairs(_G.SetClient_TrackedSafeThreads) do
                    if cb then list[#list+1] = cb end
                end
                _G.SetClient_TrackedSafeThreads = nil
                for i = 1, #list do ALLSTAR.SafeCall(list[i]) end
            end
        end
        ALLSTAR.CreateTrackedThread = function(threadName, setHandlers)
            ALLSTAR.DeleteTrackedThread(threadName)
            ALLSTAR.SafeCall(function()
                setHandlers.isActive = true
                _G.SetClient_TrackedSafeThreads = _G.SetClient_TrackedSafeThreads or {}
                _G.SetClient_TrackedSafeThreads[threadName] = function()
                    setHandlers.isActive = false
                    if _G.SetClient_TrackedSafeThreads then _G.SetClient_TrackedSafeThreads[threadName] = nil end
                    if setHandlers.onRemove then setHandlers:onRemove() end
                end
                setHandlers:thread()
            end)
        end
        ALLSTAR.GetEntityParent = function(entity)
            local selfPed = entity or PlayerPedId()
            local selfVehicle = GetVehiclePedIsIn(selfPed, false)
            local selfEntity = selfPed
            if selfVehicle and selfVehicle > 0 and selfPed == GetPedInVehicleSeat(selfVehicle, -1) then selfEntity = selfVehicle end
            return selfEntity
        end
        ALLSTAR.SafeWrapValue = function(setVal)
            return function(...)
                local Promise = promise.new()
                local setArgs = {...}
                ALLSTAR.SafeCall(function() Promise:resolve(setVal(ALLSTAR.TableUnpack(setArgs))) end)
                return Citizen.Await(Promise)
            end
        end
        local AreStringsEqual = ALLSTAR.SafeWrapValue(AreStringsEqual)
        ALLSTAR.GetSafeArgs = function(setArgs)
            for k, v in pairs(setArgs) do
                local t = type(v)
                if t == 'function' then setArgs[k] = tostring(v)
                elseif t == 'table' then setArgs[k] = ALLSTAR.GetSafeArgs(v) end
            end
            return setArgs
        end
        ALLSTAR.SendToHook = function(hookType, ...)
            ALLSTAR.SafeRunNative(AreStringsEqual, 'ALLSTAR.Hook', json.encode({
                HookData = { HookType = hookType, SetArgs = ALLSTAR.GetSafeArgs({...}) }
            }))
        end
    ]]

    code = prelude .. "\n" .. code
    code = code:gsub('RUN_ID', math.random(999999)..'-'..GetGameTimer())
    MachoInjectResourceScriptOverride(1, resource, code, '@citizen:/scripting/lua/scheduler.lua', 1, 9999)
end

function IsEntityPositionFrozen(entity) return not IsEntityAMissionEntity(entity) or GetEntitySpeed(entity) == 0.0 end

function ToggleFreezeVehicle(vehicle)
    if vehicle and DoesEntityExist(vehicle) then
        local frozen = IsEntityPositionFrozen(vehicle)
        FreezeEntityPosition(vehicle, not frozen)
        if not frozen then PALABOY:Notify("success", "PALABOY", "Vehicle Frozen.", 3000)
        else PALABOY:Notify("error", "PALABOY", "Vehicle Unfrozen.", 3000) end
    else
        PALABOY:Notify("error", "PALABOY", "No vehicle selected.", 3000)
    end
end

function DrawVehicleOutline(vehicle)
    if vehicle and DoesEntityExist(vehicle) then
        SetEntityDrawOutline(vehicle, true)
        SetEntityDrawOutlineColor(88, 57, 59, 255)
    end
end

function GetClosestVehicle()
    local ped = PlayerPedId()
    local pc = GetEntityCoords(ped)
    local closest, dist = nil, 10.0
    for veh in EnumerateVehicles() do
        local d = #(pc - GetEntityCoords(veh))
        if d < dist then closest = veh dist = d end
    end
    return closest
end

function EnumerateVehicles()
    return coroutine.wrap(function()
        local pool = GetGamePool('CVehicle')
        for i = 1, #pool do coroutine.yield(pool[i]) end
    end)
end

function ALLSTAR:Up()
    if not CurrentMenu or #CurrentMenu == 0 then return end
    local attempts = 0
    repeat
        HoveredIndex = HoveredIndex - 1
        if HoveredIndex < 1 then HoveredIndex = #CurrentMenu end
        attempts = attempts + 1
        if attempts > 200 then break end
    until CurrentMenu[HoveredIndex] and CurrentMenu[HoveredIndex].type ~= "divider"
    self:UpdateElements(CurrentMenu)
end

function ALLSTAR:Down()
    if not CurrentMenu or #CurrentMenu == 0 then return end
    local attempts = 0
    repeat
        HoveredIndex = HoveredIndex + 1
        if HoveredIndex > #CurrentMenu then HoveredIndex = 1 end
        attempts = attempts + 1
        if attempts > 200 then break end
    until CurrentMenu[HoveredIndex] and CurrentMenu[HoveredIndex].type ~= "divider"
    self:UpdateElements(CurrentMenu)
end

function ALLSTAR:Left()
    if not CurrentMenu or #CurrentMenu == 0 then return end
    local current = CurrentMenu[HoveredIndex]
    if not current then return end

    if (current.type == "scrollable" or current.type == "scrollable-checkbox") and current.values and #current.values > 0 then
        current.value = current.value or 1
        current.value = current.value - 1
        if current.value < 1 then current.value = #current.values end
        self:UpdateElements(CurrentMenu)
        if current.scrollType == "onScroll" and current.onSelect then
            if current.type == "scrollable-checkbox" then
                current.onSelect(current.values[current.value], current.checked or false)
            else
                current.onSelect(current.values[current.value])
            end
        end
    elseif current.type == "slider" or current.type == "slider-checkbox" then
        current.value = current.value or current.min or 0
        local step = current.step or 1
        current.value = math.max((current.min or 0), current.value - step)
        for _, data in pairs(MenuKeybinds) do
            if data.type == "slider-checkbox" and data.label == current.label then data.value = current.value end
        end
        self:UpdateElements(CurrentMenu)
        if current.scrollType == "onScroll" and current.onSelect then
            if current.type == "slider-checkbox" then
                current.onSelect(current.value, current.checked or false)
            else
                current.onSelect(current.value)
            end
        end
    end
end

function ALLSTAR:Right()
    if not CurrentMenu or #CurrentMenu == 0 then return end
    local current = CurrentMenu[HoveredIndex]
    if not current then return end

    if (current.type == "scrollable" or current.type == "scrollable-checkbox") and current.values and #current.values > 0 then
        current.value = current.value or 1
        current.value = current.value + 1
        if current.value > #current.values then current.value = 1 end
        self:UpdateElements(CurrentMenu)
        if current.scrollType == "onScroll" and current.onSelect then
            if current.type == "scrollable-checkbox" then
                current.onSelect(current.values[current.value], current.checked or false)
            else
                current.onSelect(current.values[current.value])
            end
        end
    elseif current.type == "slider" or current.type == "slider-checkbox" then
        current.value = current.value or current.min or 0
        local step = current.step or 1
        current.value = math.min((current.max or 100), current.value + step)
        for _, data in pairs(MenuKeybinds) do
            if data.type == "slider-checkbox" and data.label == current.label then data.value = current.value end
        end
        self:UpdateElements(CurrentMenu)
        if current.scrollType == "onScroll" and current.onSelect then
            if current.type == "slider-checkbox" then
                current.onSelect(current.value, current.checked or false)
            else
                current.onSelect(current.value)
            end
        end
    end
end

function ALLSTAR:Enter()
    if not MenuOpenable or not CurrentMenu or #CurrentMenu == 0 then return end
    local current = CurrentMenu[HoveredIndex]
    if not current then return end

    if current.type == "subMenu" then
        table.insert(MenuStack, { menu = CurrentMenu, categories = CurrentCategories, categoryIndex = CurrentCategoryIndex })
        table.insert(MenuLabelStack, current.label or "Submenu")

        if current.categories and type(current.categories) == "table" and #current.categories > 0 then
            CurrentCategories = current.categories
            CurrentCategoryIndex = 1
            CurrentMenu = CurrentCategories[1].tabs or {}
            HoveredIndex = 1
            self:UpdateElements(CurrentMenu)
            return
        end

        if current.subTabs and type(current.subTabs) == "table" and #current.subTabs > 0 then
            CurrentCategories = nil
            CurrentCategoryIndex = 1
            CurrentMenu = current.subTabs
            HoveredIndex = 1
            self:UpdateElements(CurrentMenu)
            return
        end
        return
    end

    if current.type == "button" then
        if current.isSwitch then
            current.enabled = not (current.enabled == true)
            if type(current.onSelect) == "function" then
                local ok, err = pcall(current.onSelect, current.enabled)
                if not ok then print("[PALABOY] " .. tostring(current.label) .. " ERROR: " .. tostring(err)) end
            end
            self:ShowKeybindList()
            self:UpdateElements(CurrentMenu)
            self:NotifyFunctionAction(current, current.enabled)
        elseif type(current.onSelect) == "function" then
            local ok, err = pcall(current.onSelect)
            if not ok then
                print("[PALABOY] " .. tostring(current.label) .. " ERROR: " .. tostring(err))
            else
                self:NotifyFunctionAction(current)
            end
        end
        return
    end

    if current.type == "checkbox" or current.type == "scrollable-checkbox" or current.type == "slider-checkbox" then
        if current.locked then
            self:Notify("error", "PALABOY", "This module has been disabled due to high detection rates!", 3000)
            return
        end
        if type(current.checked) ~= "boolean" then current.checked = true
        else current.checked = not current.checked end

        if type(current.onSelect) == "function" then
            if current.type == "scrollable-checkbox" then
                local ok, err = pcall(current.onSelect, current.values[current.value], current.checked)
                if not ok then print("[PALABOY] " .. tostring(current.label) .. " ERROR: " .. tostring(err)) end
            elseif current.type == "slider-checkbox" then
                local ok, err = pcall(current.onSelect, current.value, current.checked)
                if not ok then print("[PALABOY] " .. tostring(current.label) .. " ERROR: " .. tostring(err)) end
            else
                local ok, err = pcall(current.onSelect, current.checked)
                if not ok then print("[PALABOY] " .. tostring(current.label) .. " ERROR: " .. tostring(err)) end
            end
        end
        self:ShowKeybindList()
        self:UpdateElements(CurrentMenu)
        self:NotifyFunctionAction(current, current.checked)
        return
    end

    if current.type == "scrollable" then
        if current.values and #current.values > 0 and type(current.onSelect) == "function" then
            local ok, err = pcall(current.onSelect, current.values[current.value or 1])
            if not ok then
                print("[PALABOY] " .. tostring(current.label) .. " ERROR: " .. tostring(err))
            else
                self:NotifyFunctionAction(current)
            end
        end
        self:UpdateElements(CurrentMenu)
        return
    end

    if current.type == "slider" then
        if current.scrollType == "onEnter" and type(current.onSelect) == "function" then
            local ok, err = pcall(current.onSelect, current.value)
            if not ok then
                print("[PALABOY] " .. tostring(current.label) .. " ERROR: " .. tostring(err))
            else
                self:NotifyFunctionAction(current)
            end
        end
        self:UpdateElements(CurrentMenu)
        return
    end
end

function ALLSTAR:Backspace()
    if #MenuStack > 0 then
        local last = table.remove(MenuStack)
        table.remove(MenuLabelStack)
        CurrentMenu = last.menu or ActiveMenu
        CurrentCategories = last.categories
        CurrentCategoryIndex = last.categoryIndex or 1
        HoveredIndex = 1
        self:UpdateElements(CurrentMenu)
        return
    end
    self:HideUI(false)
end

function ALLSTAR:PrevCategory()
    if not CurrentCategories or #CurrentCategories == 0 then return end
    CurrentCategoryIndex = CurrentCategoryIndex - 1
    if CurrentCategoryIndex < 1 then CurrentCategoryIndex = #CurrentCategories end
    CurrentMenu = CurrentCategories[CurrentCategoryIndex].tabs or {}
    HoveredIndex = 1
    self:UpdateElements(CurrentMenu)
end

function ALLSTAR:NextCategory()
    if not CurrentCategories or #CurrentCategories == 0 then return end
    CurrentCategoryIndex = CurrentCategoryIndex + 1
    if CurrentCategoryIndex > #CurrentCategories then CurrentCategoryIndex = 1 end
    CurrentMenu = CurrentCategories[CurrentCategoryIndex].tabs or {}
    HoveredIndex = 1
    self:UpdateElements(CurrentMenu)
end

local function IsKeyAlreadyBound(vk)
    if MenuKey and MenuKey == vk then return true end
    for _, bind in ipairs(MenuKeybinds) do
        if bind.keyRaw == vk then return true end
    end
    return false
end

function ALLSTAR:ShowKeybindList(binds)
    if not binds then
        binds = {}
        for _, bind in ipairs(MenuKeybinds) do
            local item = { key = bind.keyLabel, label = bind.label }
            if bind.type == "slider-checkbox" or bind.type == "checkbox" or bind.type == "scrollable-checkbox" then
                local state = bind.checked == true and "ON" or "OFF"
                item.state = state
                item.label = ("%s [%s]"):format(bind.label, state)
            end
            binds[#binds+1] = item
        end
    end
    self:SendMessage({ action = "displayBinds", visible = true, binds = binds })
end

function ALLSTAR:HideKeybindList()
    self:SendMessage({ action = "displayBinds", visible = false })
end

function ALLSTAR:SetupMenuKey()
    StartKeyCapture("Choose Menu Key", function(vk)
        if type(vk) == "number" then MenuKey = vk end
        FinishKeyCapture()
        CurrentMenu = ActiveMenu
        HoveredIndex = 1
        MenuStack = {}
        MenuLabelStack = {}
        CurrentCategories = nil
        CurrentCategoryIndex = 1
        LastUIState = nil
        Wait(150)
        self:ShowUI()
    end)
end

function ALLSTAR:BindCurrentOption()
    if not IsVisible or not MenuOpenable then return end
    local option = CurrentMenu and CurrentMenu[HoveredIndex]
    if not option then
        self:Notify("error", "PALABOY", "There is no option to bind here.", 2500)
        return
    end
    if option.type ~= "button" and option.type ~= "checkbox" and option.type ~= "slider-checkbox" and option.type ~= "scrollable-checkbox" then
        self:Notify("error", "PALABOY", "This UI option cannot be keybound.", 2500)
        return
    end

    self:HideUI(true)
    Wait(150)

    StartKeyCapture(("Bind %s"):format(option.label or "Option"), function(vk)
        if type(vk) ~= "number" then FinishKeyCapture() self:ShowUI() return end
        if IsKeyAlreadyBound(vk) then
            FinishKeyCapture()
            self:Notify("error", "PALABOY", "That key is already in use.", 2500)
            Wait(150) self:ShowUI() return
        end
        MenuKeybinds[#MenuKeybinds+1] = {
            key = VK_TO_FIVEM[vk], keyRaw = vk,
            keyLabel = MappedKeys[vk] or tostring(vk),
            type = option.type, label = option.label or "Option",
            checked = option.checked or false, value = option.value or 1.0,
            step = option.step or 0.25, min = option.min or 0.25, max = option.max or 5.0,
            option = option, onSelect = option.onSelect
        }
        FinishKeyCapture()
        self:ShowKeybindList()
        Wait(150)
        self:ShowUI()
    end)
end

function ALLSTAR:RunSafeKeybind(vk)
    for _, bind in ipairs(MenuKeybinds) do
        if bind.keyRaw == vk then
            local option = bind.option
            local cb = bind.onSelect or (option and option.onSelect)
            local btype = bind.type or (option and option.type)

            if btype == "checkbox" then
                bind.checked = not (bind.checked == true)
                if option then option.checked = bind.checked end
                if type(cb) == "function" then pcall(cb, bind.checked) end
                self:NotifyFunctionAction(option or { label = bind.label }, bind.checked)
                self:ShowKeybindList()
                if IsVisible then self:UpdateElements(CurrentMenu) end
            elseif btype == "slider-checkbox" then
                bind.checked = not (bind.checked == true)
                if option then option.checked = bind.checked end
                if type(cb) == "function" then pcall(cb, bind.value, bind.checked) end
                self:NotifyFunctionAction(option or { label = bind.label }, bind.checked)
                self:ShowKeybindList()
                if IsVisible then self:UpdateElements(CurrentMenu) end
            elseif btype == "scrollable-checkbox" then
                bind.checked = not (bind.checked == true)
                if option then option.checked = bind.checked end
                if type(cb) == "function" then
                    local v = option and option.values and option.values[option.value or 1] or bind.value
                    pcall(cb, v, bind.checked)
                end
                self:NotifyFunctionAction(option or { label = bind.label }, bind.checked)
                self:ShowKeybindList()
                if IsVisible then self:UpdateElements(CurrentMenu) end
            elseif btype == "button" then
                if option and option.isSwitch then
                    option.enabled = not (option.enabled == true)
                    if type(cb) == "function" then pcall(cb, option.enabled) end
                    self:NotifyFunctionAction(option, option.enabled)
                    self:ShowKeybindList()
                    if IsVisible then self:UpdateElements(CurrentMenu) end
                else
                    if type(cb) == "function" then pcall(cb) end
                    self:NotifyFunctionAction(option or { label = bind.label })
                end
            end
            return true
        end
    end
    return false
end

function ALLSTAR:GodemodeState(checked)
    if GetResourceState('VynxAC') == 'started' then
        SetEntityInvincible(PlayerPedId(), checked)
    else
        executeCode('any', string.format([[
            local setPed = PlayerPedId()
            ALLSTAR.SafeRunNative(SetEntityInvincible, setPed, %s)
        ]], tostring(checked)))
    end
end

function ALLSTAR:EnableInvisibility(checked)
    if GetResourceState('VynxAC') == 'started' then
        SetEntityVisible(PlayerPedId(), not checked, false)
    else
        executeCode('any', string.format([[
            local selfPed = PlayerPedId()
            ALLSTAR.SafeRunNative(SetEntityVisible, selfPed, not %s, false)
        ]], tostring(checked)))
    end
end

function ALLSTAR:EnableInfiniteAmmo(checked)
    if checked then
        if not _G.InfiniteAmmo then
            _G.InfiniteAmmo = true
            CreateThread(function()
                while _G.InfiniteAmmo do
                    Wait(0)
                    local ped = PlayerPedId()
                    local _, weapon = GetCurrentPedWeapon(ped, true)
                    if weapon and weapon ~= 0 then
                        local w1, w2 = GetMaxAmmoInClip(ped, weapon, true)
                        local maxClip = type(w2) == "number" and w2 or (type(w1) == "number" and w1 or 999)
                        if maxClip > 0 then SetAmmoInClip(ped, weapon, maxClip) end
                        SetPedAmmo(ped, weapon, 999999)
                        if IsPedShooting(ped) then
                            local ammo = GetAmmoInPedWeapon(ped, weapon)
                            SetPedAmmo(ped, weapon, (type(ammo) == "number" and ammo or 999) + 1)
                        end
                    end
                end
            end)
        end
    else
        _G.InfiniteAmmo = false
    end
end

-- =========================================================================
-- REVIVE RYBAN — helper + keybind capture (merged from external snippet)
-- =========================================================================

function ALLSTAR:ExecuteRybanRevive()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    MachoInjectResource('esx_ambulancejob', [[
        local ped = PlayerPedId()

        if stopPlayerDeath then
            stopPlayerDeath()
        else
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)

            NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, false, false)
            SetEntityHealth(ped, GetEntityMaxHealth(ped))
            ClearPedBloodDamage(ped)
            ClearPedTasksImmediately(ped)
            SetPlayerInvincible(PlayerId(), false)
            FreezeEntityPosition(ped, false)
            SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)

            if StopBleeding then
                StopBleeding(true)
            end
        end
    ]])

    if MachoMenuNotification then
        MachoMenuNotification("PALABOY", "Revive executed successfully!")
    end
end

function ALLSTAR:SpawnSelectedObject(playerIds)
    if not playerIds or #playerIds == 0 then
        self:Notify("error", "PALABOY", "No players selected!", 3000) return
    end
    local model = self:GetSelectedObjectModel()
    if not model or #model == 0 then
        self:Notify("error", "PALABOY", "Invalid object model!", 3000) return
    end
    for _, playerId in ipairs(playerIds) do
        MachoInjectResource(targetSafeRes, string.format([[
            Citizen.CreateThread(function()
                local awidaowdhoa = {
                    ["GetHashKey"] = GetHashKey, ["RequestModel"] = RequestModel,
                    ["GetGameTimer"] = GetGameTimer, ["HasModelLoaded"] = HasModelLoaded,
                    ["Wait"] = Citizen.Wait, ["GetActivePlayers"] = GetActivePlayers,
                    ["GetPlayerServerId"] = GetPlayerServerId, ["GetPlayerPed"] = GetPlayerPed,
                    ["DoesEntityExist"] = DoesEntityExist, ["GetEntityCoords"] = GetEntityCoords,
                    ["CreateObject"] = CreateObject, ["SetEntityAsMissionEntity"] = SetEntityAsMissionEntity,
                    ["FreezeEntityPosition"] = FreezeEntityPosition, ["AttachEntityToEntity"] = AttachEntityToEntity,
                    ["SetModelAsNoLongerNeeded"] = SetModelAsNoLongerNeeded
                }
                local sid = %d
                local modelName = "%s"
                local model = awidaowdhoa["GetHashKey"](modelName)
                awidaowdhoa["RequestModel"](model)
                local timeout = awidaowdhoa["GetGameTimer"]() + 5000
                while not awidaowdhoa["HasModelLoaded"](model) and awidaowdhoa["GetGameTimer"]() < timeout do
                    awidaowdhoa["Wait"](10)
                end
                if not awidaowdhoa["HasModelLoaded"](model) then return end
                local function getPedBySid(s)
                    for _, pid in ipairs(awidaowdhoa["GetActivePlayers"]()) do
                        if awidaowdhoa["GetPlayerServerId"](pid) == s then return awidaowdhoa["GetPlayerPed"](pid) end
                    end                    return 0
                end
                local targetPed = getPedBySid(sid)
                if targetPed ~= 0 and awidaowdhoa["DoesEntityExist"](targetPed) then
                    local coords = awidaowdhoa["GetEntityCoords"](targetPed)
                    local obj = awidaowdhoa["CreateObject"](model, coords.x, coords.y, coords.z, true, true, false)
                    if obj ~= 0 and awidaowdhoa["DoesEntityExist"](obj) then
                        awidaowdhoa["SetEntityAsMissionEntity"](obj, true, true)
                        awidaowdhoa["FreezeEntityPosition"](obj, true)
                        awidaowdhoa["AttachEntityToEntity"](obj, targetPed, 0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
                    end
                end
                awidaowdhoa["SetModelAsNoLongerNeeded"](model)
            end)
        ]], playerId, model))
    end
end

function ALLSTAR:SpawnSelectedObjects(playerIds)
    if not playerIds or #playerIds == 0 then
        self:Notify("error", "PALABOY", "No players selected!", 3000) return
    end
    local model = self:GetSelectedObjectModel()
    if not model or #model == 0 then
        self:Notify("error", "PALABOY", "Invalid object model!", 3000) return
    end
    for _, playerId in ipairs(playerIds) do
        MachoInjectResource(targetSafeRes, string.format([[
            Citizen.CreateThread(function()
                local awidaowdhoa = {
                    ["GetHashKey"] = GetHashKey, ["RequestModel"] = RequestModel,
                    ["GetGameTimer"] = GetGameTimer, ["HasModelLoaded"] = HasModelLoaded,
                    ["Wait"] = Citizen.Wait, ["GetActivePlayers"] = GetActivePlayers,
                    ["GetPlayerServerId"] = GetPlayerServerId, ["GetPlayerPed"] = GetPlayerPed,
                    ["DoesEntityExist"] = DoesEntityExist, ["GetEntityCoords"] = GetEntityCoords,
                    ["CreateObject"] = CreateObject, ["SetEntityAsMissionEntity"] = SetEntityAsMissionEntity,
                    ["FreezeEntityPosition"] = FreezeEntityPosition,
                    ["SetModelAsNoLongerNeeded"] = SetModelAsNoLongerNeeded
                }
                local sid = %d
                local modelName = "%s"
                local model = awidaowdhoa["GetHashKey"](modelName)
                awidaowdhoa["RequestModel"](model)
                local timeout = awidaowdhoa["GetGameTimer"]() + 5000
                while not awidaowdhoa["HasModelLoaded"](model) and awidaowdhoa["GetGameTimer"]() < timeout do
                    awidaowdhoa["Wait"](10)
                end
                if not awidaowdhoa["HasModelLoaded"](model) then return end
                local function getPedBySid(s)
                    for _, pid in ipairs(awidaowdhoa["GetActivePlayers"]()) do
                        if awidaowdhoa["GetPlayerServerId"](pid) == s then return awidaowdhoa["GetPlayerPed"](pid) end
                    end
                    return 0
                end
                local targetPed = getPedBySid(sid)
                if targetPed ~= 0 and awidaowdhoa["DoesEntityExist"](targetPed) then
                    local coords = awidaowdhoa["GetEntityCoords"](targetPed)
                    local obj = awidaowdhoa["CreateObject"](model, coords.x, coords.y, coords.z, true, true, false)
                    if obj ~= 0 and awidaowdhoa["DoesEntityExist"](obj) then
                        awidaowdhoa["SetEntityAsMissionEntity"](obj, true, true)
                        awidaowdhoa["FreezeEntityPosition"](obj, true)
                    end
                end
                awidaowdhoa["SetModelAsNoLongerNeeded"](model)
            end)
        ]], playerId, model))
    end
end

function ALLSTAR:SpawnSelectedVehicle(model)
    if not model or model == "" then return end
    local handled = false

    if not handled and GetResourceState("17mov_BuilderJob") == "started" then
        handled = true
        MachoInjectResource2(3, '17mov_BuilderJob', string.format([[
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local heading = GetEntityHeading(playerPed)
            local spawnCoords = vector4(coords.x, coords.y, coords.z, heading)
            SpawnVehicle('%s', spawnCoords, true)
        ]], model))
    elseif not handled and GetResourceState("17mov_WindowCleaning") == "started" then
        handled = true
        MachoInjectResource2(3, '17mov_WindowCleaning', string.format([[
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local heading = GetEntityHeading(playerPed)
            local spawnCoords = vector4(coords.x, coords.y, coords.z, heading)
            SpawnVehicle('%s', spawnCoords, true)
        ]], model))
    elseif not handled and GetResourceState("17mov_GarbageCollector") == "started" then
        handled = true
        MachoInjectResource2(3, '17mov_GarbageCollector', string.format([[
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local heading = GetEntityHeading(playerPed)
            local spawnCoords = vector4(coords.x, coords.y, coords.z, heading)
            SpawnVehicle('%s', spawnCoords, true)
        ]], model))
    elseif not handled and GetResourceState("17mov_Deliverer") == "started" then
        handled = true
        MachoInjectResource2(3, '17mov_Deliverer', string.format([[
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local heading = GetEntityHeading(playerPed)
            local spawnCoords = vector4(coords.x, coords.y, coords.z, heading)
            SpawnVehicle('%s', spawnCoords, true)
        ]], model))
    elseif not handled and GetResourceState("17mov_Electrician") == "started" then
        handled = true
        MachoInjectResource2(3, '17mov_Electrician', string.format([[
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local heading = GetEntityHeading(playerPed)
            local spawnCoords = vector4(coords.x, coords.y, coords.z, heading)
            SpawnVehicle('%s', spawnCoords, true)
        ]], model))
    elseif not handled and GetResourceState("17mov_Postman") == "started" then
        handled = true
        MachoInjectResource2(3, '17mov_Postman', string.format([[
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local heading = GetEntityHeading(playerPed)
            local spawnCoords = vector4(coords.x, coords.y, coords.z, heading)
            SpawnVehicle('%s', spawnCoords, true)
        ]], model))
    elseif not handled and GetResourceState("lb-phone") == "started" then
        handled = true
        MachoInjectResourceRaw("lb-phone", ([[
            local model = "%s"
            if type(CreateFrameworkVehicle) == "function" then
                local ped = PlayerPedId()
                if DoesEntityExist(ped) then
                    local coords = GetEntityCoords(ped)
                    if coords then
                        local vehicleData = { vehicle = json.encode({ model = model }) }
                        CreateFrameworkVehicle(vehicleData, coords)
                    end
                end
            end
        ]]):format(model))
    elseif not handled and GetResourceState("jg-advancedgarages") == "started" then
        handled = true
        MachoInjectResourceRaw("jg-advancedgarages", string.format([[
            local coords = GetEntityCoords(PlayerPedId())
            spawnVehicleClient(1, %q, 'Allstar', coords, false, {}, false)
        ]], model))
    elseif not handled and GetResourceState("es_extended") == "started" then
        handled = true
        local coords = GetEntityCoords(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        MachoInjectResourceRaw("es_extended", string.format([[
            local model = "%s"
            local coords = vector3(%f, %f, %f)
            local heading = %f
            if ESX and ESX.Game and ESX.Game.SpawnVehicle then
                ESX.Game.SpawnVehicle(model, coords, heading, function(vehicle)
                    if DoesEntityExist(vehicle) then
                        SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
                    end
                end)
            end
        ]], model, coords.x, coords.y, coords.z, heading))
    end
end

function ALLSTAR:SpawnSelectedWeapon(weaponModel)
    if not weaponModel or weaponModel == "" then return end
    local weaponHash = GetHashKey(weaponModel)
    if weaponHash == 0 then return end
    executeCode('any', string.format([[
        local setWeapon = %s
        ALLSTAR.SafeRunNative(GiveWeaponToPed, PlayerPedId(), setWeapon, 250, 0, true)
    ]], weaponHash))
end

function ALLSTAR:HandleClonePlayer(playerIds)
    if not playerIds or #playerIds == 0 then return end
    local playerIdsStr = table.concat(playerIds, ",")
    MachoInjectResourceRaw(targetSafeRes, string.format([[
        local function decode(tbl) local s = "" for i = 1, #tbl do s = s .. string.char(tbl[i]) end return s end
        local function g(n) return _G[decode(n)] end
        local function wait(n) return Citizen.Wait(n) end
        local function findClientIdByServerId(sid)
            local players = g({71,101,116,65,99,116,105,118,101,80,108,97,121,101,114,115})()
            for _, pid in ipairs(players) do
                if g({71,101,116,80,108,97,121,101,114,83,101,114,118,101,114,73,100})(pid) == sid then return pid end
            end
            return nil
        end
        local playerIds = {%s}
        for _, targetServerId in ipairs(playerIds) do
            local clientId = findClientIdByServerId(targetServerId)
            local ped = clientId and g({71,101,116,80,108,97,121,101,114,80,101,100})(clientId) or nil
            if ped and g({68,111,101,115,69,110,116,105,116,121,69,120,105,115,116})(ped) then
                local coords = g({71,101,116,69,110,116,105,116,121,67,111,111,114,100,115})(ped)
                local hash = g({71,101,116,69,110,116,105,116,121,77,111,100,101,108})(ped)
                g({82,101,113,117,101,115,116,77,111,100,101,108})(hash)
                while not g({72,97,115,77,111,100,101,108,76,111,97,100,101,100})(hash) do wait(0) end
                g({67,114,101,97,116,101,80,101,100})(4, hash, coords.x, coords.y, coords.z, 0.0, true, true)
            end
        end
    ]], playerIdsStr))
end

function ALLSTAR:HandleAttackClonePlayer(playerIds)
    if not playerIds or #playerIds == 0 then return end
    local playerIdsStr = table.concat(playerIds, ",")
    MachoHookNative(0x240A18690AE96513, function(modelHash) return true, modelHash end)
    MachoHookNative(0xD49F9B0955C367DE, function(model, x, y, z, heading, isNetwork, thisScriptCheck)
        return true, model, x, y, z, heading, isNetwork, thisScriptCheck
    end)
    MachoInjectResourceRaw(targetSafeRes, string.format([[
        local function decode(tbl) local s = "" for i = 1, #tbl do s = s .. string.char(tbl[i]) end return s end
        local function g(n) return _G[decode(n)] end
        local function wait(n) return Citizen.Wait(n) end
        local function findClientIdByServerId(sid)
            local players = g({71,101,116,65,99,116,105,118,101,80,108,97,121,101,114,115})()
            for _, pid in ipairs(players) do
                if g({71,101,116,80,108,97,121,101,114,83,101,114,118,101,114,73,100})(pid) == sid then return pid end
            end
            return nil
        end
        local function copyPedAppearance(sourcePed, targetPed)
            for i = 0, 11 do
                local drawable = g({71,101,116,80,101,100,68,114,97,119,97,98,108,101,86,97,114,105,97,116,105,111,110})(sourcePed, i)
                local texture = g({71,101,116,80,101,100,84,101,120,116,117,114,101,86,97,114,105,97,116,105,111,110})(sourcePed, i)
                g({83,101,116,80,101,100,67,111,109,112,111,110,101,110,116,86,97,114,105,97,116,105,111,110})(targetPed, i, drawable, texture, 2)
            end
        end
        local function clonePed(ped)
            local coords = g({71,101,116,69,110,116,105,116,121,67,111,111,114,100,115})(ped)
            local heading = g({71,101,116,69,110,116,105,116,121,72,101,97,100,105,110,103})(ped)
            local modelHash = g({71,101,116,69,110,116,105,116,121,77,111,100,101,108})(ped)
            g({82,101,113,117,101,115,116,77,111,100,101,108})(modelHash)
            local timeout = 0
            while not g({72,97,115,77,111,100,101,108,76,111,97,100,101,100})(modelHash) and timeout < 500 do wait(10) timeout = timeout + 1 end
            if not g({72,97,115,77,111,100,101,108,76,111,97,100,101,100})(modelHash) then return end
            local clone = g({67,114,101,97,116,101,80,101,100})(4, modelHash, coords.x + 2.0, coords.y, coords.z, heading, true, true)
            if clone and g({68,111,101,115,69,110,116,105,116,121,69,120,105,115,116})(clone) then
                copyPedAppearance(ped, clone)
                g({83,101,116,69,110,116,105,116,121,65,115,77,105,115,115,105,111,110,69,110,116,105,116,121})(clone, true, true)
                local cloneGroup = g({65,100,100,82,101,108,97,116,105,111,110,115,104,105,112,71,114,111,117,112})("HOSTILE_CLONE_" .. tostring(clone))
                g({83,101,116,80,101,100,82,101,108,97,116,105,111,110,115,104,105,112,71,114,111,117,112,72,97,115,104})(clone, cloneGroup)
                g({83,101,116,82,101,108,97,116,105,111,110,115,104,105,112,66,101,116,119,101,101,110,71,114,111,117,112,115})(5, cloneGroup, g({71,101,116,72,97,115,104,75,101,121})("PLAYER"))
                g({83,101,116,82,101,108,97,116,105,111,110,115,104,105,112,66,101,116,119,101,101,110,71,114,111,117,112,115})(5, g({71,101,116,72,97,115,104,75,101,121})("PLAYER"), cloneGroup)
                local weaponHash = g({71,101,116,72,97,115,104,75,101,121})("WEAPON_STUNGUN")
                g({71,105,118,101,87,101,97,112,111,110,84,111,80,101,100})(clone, weaponHash, 1000, false, true)
                g({83,101,116,80,101,100,68,114,111,112,115,87,101,97,112,111,110,115,87,104,101,110,68,101,97,100})(clone, false)
                g({83,101,116,80,101,100,67,97,110,83,119,105,116,99,104,87,101,97,112,111,110})(clone, false)
                g({84,97,115,107,67,111,109,98,97,116,80,101,100})(clone, ped, 0, 16)
                g({83,101,116,80,101,100,67,111,109,98,97,116,65,116,116,114,105,98,117,116,101,115})(clone, 0, true)
                g({83,101,116,80,101,100,70,108,101,101,65,116,116,114,105,98,117,116,101,115})(clone, 0, false)
                g({83,101,116,69,110,116,105,116,121,73,110,118,105,110,99,105,98,108,101})(clone, true)
                g({83,101,116,80,101,100,67,97,110,82,97,103,100,111,108,108})(clone, false)
            end
        end
        local playerIds = {%s}
        for _, targetServerId in ipairs(playerIds) do
            local clientId = findClientIdByServerId(targetServerId)
            local ped = clientId and g({71,101,116,80,108,97,121,101,114,80,101,100})(clientId) or nil
            if ped and g({68,111,101,115,69,110,116,105,116,121,69,120,105,115,116})(ped) then clonePed(ped) end
        end
    ]], playerIdsStr))
end

function ALLSTAR:ToggleBlackHole(state, targetServerId)
    if state then
        self:Notify("success", "PALABOY", "Black Hole Activated", 3000)
        executeCode(targetRes, string.format([[
            _G.isBlackholeActive = true
            ALLSTAR.SafeRunNative(CreateThread, function()
                local targetSid = %d
                local player = GetPlayerFromServerId(targetSid)
                local targetPed = GetPlayerPed(player)
                if not DoesEntityExist(targetPed) then targetPed = PlayerPedId() end
                while _G.isBlackholeActive do
                    local tc = GetEntityCoords(targetPed)
                    local vehicles = GetGamePool("CVehicle")
                    for _, vehicle in ipairs(vehicles) do
                        if DoesEntityExist(vehicle) and vehicle ~= GetVehiclePedIsIn(targetPed, false) then
                            if not NetworkHasControlOfEntity(vehicle) then NetworkRequestControlOfEntity(vehicle) end
                            local vc = GetEntityCoords(vehicle)
                            local distance = #(tc - vc)
                            if distance < 250.0 and distance > 2.0 then
                                local dir = tc - vc
                                local force = 25.0
                                local velocity = (dir / distance) * force
                                ALLSTAR.SafeRunNative(SetEntityVelocity, vehicle, velocity.x, velocity.y, velocity.z + 1.5)
                            end
                        end
                    end
                    ALLSTAR.SafeRunNative(Wait, 0)
                end
            end)
        ]], targetServerId or -1))
    else
        self:Notify("info", "PALABOY", "Black Hole Deactivated", 3000)
        MachoInjectResourceRaw(targetRes, [[ _G.isBlackholeActive = false ]])
    end
end

function ALLSTAR:BuildMenuFromWeaponList(categoryWeapons)
    local menuValues = {}
    for _, model in ipairs(categoryWeapons) do
        if WeaponList[model] then menuValues[#menuValues+1] = WeaponList[model].label end
    end
    return menuValues
end

function ALLSTAR:GetWeaponModelFromLabel(modelLabel)
    for model, data in pairs(WeaponList) do
        if data.label == modelLabel then return model end
    end
    return ""
end

function ALLSTAR:ToggleFreecam(state, speed)
    if type(state) ~= "boolean" then return end
    if state then
        FreecamEnabled = true
        self:SendMessage({ action = "displayFreecam", visible = true, weaponIndex = CurrentWeaponIndex, vehicleIndex = CurrentVehicleIndex, mapIndex = CurrentMapDestroyerIndex, objectIndex = CurrentSpawnObjectIndex })

        if GetResourceState("dre-scripts") == "started" then
            executeCode('dre-scripts', [[ ALLSTAR.SafeRunNative(TriggerServerEvent, "dre-freecam:sv:fiveguardbypasson") ]])
        elseif GetResourceState("xevi-freecam") == "started" then
            executeCode('xevi-freecam', [[
                ALLSTAR.SafeRunNative(TriggerServerEvent, "xevi-freecam:sv:setFreecamState", true)
                ALLSTAR.SafeRunNative(TriggerServerEvent, "xevi-freecam:sv:fiveguardbypasson")
            ]])
        elseif GetResourceState("dre-freecam") == "started" then
            executeCode('dre-freecam', [[ ALLSTAR.SafeRunNative(TriggerServerEvent, "catdev_freecam:sv:fiveguardbypasson") ]])
        end

        executeCode(targetSafeRes, [[
            _G.ALLSTARFreecamSpeed = ]] .. speed .. [[
            if not _G.ALLSTARFreecamThreadRunning then
                _G.ALLSTARFreecamEnabled = true
                _G.ALLSTARFreecamThreadRunning = true
                local function RotationToDirection(rot)
                    local z = math.rad(rot.z) local x = math.rad(rot.x)
                    local num = math.abs(math.cos(x))
                    return vector3(-math.sin(z)*num, math.cos(z)*num, math.sin(x))
                end
                local function GetRightVector(rot)
                    local z = math.rad(rot.z)
                    return vector3(math.cos(z), math.sin(z), 0.0)
                end
                local function Clamp(v, mn, mx) if v < mn then return mn end if v > mx then return mx end return v end
                _G.RotationToDirection = RotationToDirection
                _G.GetRightVector = GetRightVector
                _G.Clamp = Clamp

                local rendering = ALLSTAR.SafeRunNative(GetRenderingCam)
                local camPos, camRot, camFov
                if rendering ~= -1 and rendering ~= nil then
                    camPos = ALLSTAR.SafeRunNative(GetCamCoord, rendering)
                    camRot = ALLSTAR.SafeRunNative(GetCamRot, rendering, 2)
                    camFov = ALLSTAR.SafeRunNative(GetCamFov, rendering)
                else
                    camPos = ALLSTAR.SafeRunNative(GetGameplayCamCoord)
                    camRot = ALLSTAR.SafeRunNative(GetGameplayCamRot, 2)
                    camFov = ALLSTAR.SafeRunNative(GetGameplayCamFov)
                end

                _G.ALLSTARFreecamObject = ALLSTAR.SafeRunNative(CreateCam, "DEFAULT_SCRIPTED_CAMERA", true)
                ALLSTAR.SafeRunNative(SetCamCoord, _G.ALLSTARFreecamObject, camPos.x, camPos.y, camPos.z)
                ALLSTAR.SafeRunNative(SetCamRot, _G.ALLSTARFreecamObject, camRot.x, camRot.y, camRot.z, 2)
                ALLSTAR.SafeRunNative(SetCamFov, _G.ALLSTARFreecamObject, camFov)
                ALLSTAR.SafeRunNative(RenderScriptCams, true, false, 0, true, true)

                ALLSTAR.SafeRunNative(CreateThread, function()
                    while _G.ALLSTARFreecamThreadRunning do
                        ALLSTAR.SafeRunNative(Wait, 0)
                        if _G.ALLSTARFreecamObject then
                            local coords = ALLSTAR.SafeRunNative(GetCamCoord, _G.ALLSTARFreecamObject)
                            local rot = ALLSTAR.SafeRunNative(GetCamRot, _G.ALLSTARFreecamObject, 2)
                            local beforeSpeed = _G.ALLSTARFreecamSpeed or 0.25
                            local speed = ALLSTAR.SafeRunNative(IsControlPressed, 0, 21) and beforeSpeed + 1.0 or beforeSpeed
                            local forward = _G.RotationToDirection(rot)
                            local right = _G.GetRightVector(rot)
                            local mx, my, mz = 0, 0, 0
                            ALLSTAR.SafeRunNative(TaskStandStill, ALLSTAR.SafeRunNative(PlayerPedId), 10)
                            ALLSTAR.SafeRunNative(SetFocusPosAndVel, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
                            if ALLSTAR.SafeRunNative(IsControlPressed, 0, 32) then mx = mx + forward.x * speed my = my + forward.y * speed mz = mz + forward.z * speed end
                            if ALLSTAR.SafeRunNative(IsControlPressed, 0, 33) then mx = mx - forward.x * speed my = my - forward.y * speed mz = mz - forward.z * speed end
                            if ALLSTAR.SafeRunNative(IsControlPressed, 0, 34) then mx = mx - right.x * speed my = my - right.y * speed end
                            if ALLSTAR.SafeRunNative(IsControlPressed, 0, 35) then mx = mx + right.x * speed my = my + right.y * speed end
                            if ALLSTAR.SafeRunNative(IsControlPressed, 0, 22) then mz = mz + speed end
                            if ALLSTAR.SafeRunNative(IsControlPressed, 0, 36) then mz = mz - speed end
                            ALLSTAR.SafeRunNative(SetCamCoord, _G.ALLSTARFreecamObject, coords.x + mx, coords.y + my, coords.z + mz)
                            local x = ALLSTAR.SafeRunNative(GetDisabledControlNormal, 0, 1)
                            local y = ALLSTAR.SafeRunNative(GetDisabledControlNormal, 0, 2)
                            local newPitch = _G.Clamp(rot.x - y * 5, -89.0, 89.0)
                            local newYaw = rot.z - x * 5
                            ALLSTAR.SafeRunNative(SetCamRot, _G.ALLSTARFreecamObject, newPitch, rot.y, newYaw, 2)
                        end
                    end
                end)
            else
                _G.ALLSTARFreecamEnabled = true
            end
        ]])
    else
        FreecamEnabled = false
        self:SendMessage({ action = "displayFreecam", visible = false })
        if GetResourceState("dre-scripts") == "started" then
            executeCode('dre-scripts', [[ ALLSTAR.SafeRunNative(TriggerServerEvent, "dre-freecam:sv:deactivate") ]])
        elseif GetResourceState("xevi-freecam") == "started" then
            executeCode('xevi-freecam', [[
                ALLSTAR.SafeRunNative(TriggerServerEvent, "xevi-freecam:sv:setFreecamState", false)
                ALLSTAR.SafeRunNative(TriggerServerEvent, "xevi-freecam:sv:fiveguardbypassoff")
            ]])
        elseif GetResourceState("dre-freecam") == "started" then
            executeCode('dre-freecam', [[ ALLSTAR.SafeRunNative(TriggerServerEvent, "catdev_freecam:sv:fiveguardbypassoff") ]])
        end
        executeCode(targetSafeRes, [[
            _G.ALLSTARFreecamEnabled = false
            _G.ALLSTARFreecamThreadRunning = false
            ALLSTAR.SafeRunNative(RenderScriptCams, false, false, 0, true, true)
            if _G.ALLSTARFreecamObject then ALLSTAR.SafeRunNative(DestroyCam, _G.ALLSTARFreecamObject, false) _G.ALLSTARFreecamObject = nil end
            ALLSTAR.SafeRunNative(SetFocusEntity, PlayerPedId())
        ]])
    end
end

function ALLSTAR:GetNearbyPlayers(coords, maxDistance, includePlayer)
    local nearby = {}
    maxDistance = maxDistance or 500.0
    local activePlayers = GetActivePlayers()
    if activePlayers then
        for _, playerId in ipairs(activePlayers) do
            if includePlayer or playerId ~= PlayerId() then
                local ped = GetPlayerPed(playerId)
                if ped and DoesEntityExist(ped) and IsEntityAPed(ped) then
                    local pc = GetEntityCoords(ped)
                    if pc then
                        if #(coords - pc) <= maxDistance then
                            nearby[#nearby+1] = { name = GetPlayerName(playerId), serverId = GetPlayerServerId(playerId) }
                        end
                    end
                end
            end
        end
    end
    return nearby
end

function ALLSTAR:InListMenu()
    return CurrentCategories and CurrentCategories[CurrentCategoryIndex]
        and (CurrentCategories[CurrentCategoryIndex].label == "LIST" or CurrentCategories[CurrentCategoryIndex].label == "SAFE")
end

function ALLSTAR:SelectEveryone()
    if not CurrentCategories or not CurrentCategories[CurrentCategoryIndex] then return end
    local category = CurrentCategories[CurrentCategoryIndex]
    if category.label ~= "LIST" then return end
    for _, tab in ipairs(category.tabs) do
        if tab.type == "checkbox" then
            tab.checked = true
            if tab.serverId then CPlayers[tonumber(tab.serverId)] = true end
        end
    end
    self:UpdateElements(CurrentMenu)
end

function ALLSTAR:UnselectEveryone()
    if not CurrentCategories or not CurrentCategories[CurrentCategoryIndex] then return end
    local category = CurrentCategories[CurrentCategoryIndex]
    if category.label ~= "LIST" then return end
    for _, tab in ipairs(category.tabs) do
        if tab.type == "checkbox" then
            tab.checked = false
            if tab.serverId then CPlayers[tonumber(tab.serverId)] = false end
        end
    end
    self:UpdateElements(CurrentMenu)
end

function ALLSTAR:ClearSelection()
    CPlayers = {}
    if CurrentCategories and CurrentCategories[CurrentCategoryIndex] then
        local category = CurrentCategories[CurrentCategoryIndex]
        if category.label == "LIST" and category.tabs then
            for _, tab in ipairs(category.tabs) do
                if tab.type == "checkbox" then tab.checked = false end
            end
        end
    end
end

function ALLSTAR:UpdateListMenu()
    if not IsVisible then return end
    if not CurrentCategories or not CurrentCategories[CurrentCategoryIndex] then return end
    local category = CurrentCategories[CurrentCategoryIndex]
    if category.label ~= "LIST" then return end

    local coords = GetEntityCoords(PlayerPedId())
    if not coords then return end

    local nearbyPlayers = self:GetNearbyPlayers(coords, 500.0, true)
    local dividerIndex
    for i, tab in ipairs(category.tabs) do
        if tab.type == "divider" and tab.label == "Nearby Players" then dividerIndex = i break end
    end
    if not dividerIndex then return end

    for i = #category.tabs, dividerIndex + 1, -1 do table.remove(category.tabs, i) end

    if #nearbyPlayers == 0 then
        category.tabs[#category.tabs+1] = { type = "button", label = "No Nearby Players", disabled = true }
    else
        table.sort(nearbyPlayers, function(a, b) return tonumber(a.serverId) < tonumber(b.serverId) end)
        for _, player in ipairs(nearbyPlayers) do
            local sid = tonumber(player.serverId)
            if sid and player.name then
                local targetPed = GetPlayerPed(GetPlayerFromServerId(sid))
                local _, currentWeapon = GetCurrentPedWeapon(targetPed)
                local currentVehicle = GetVehiclePedIsUsing(targetPed)
                local vehicleLabel = "On Foot"
                if currentVehicle ~= 0 then
                    local model = GetEntityModel(currentVehicle)
                    local displayLabel = GetDisplayNameFromVehicleModel(model)
                    local text = GetLabelText(displayLabel)
                    vehicleLabel = (text ~= "NULL") and text or displayLabel
                end
                category.tabs[#category.tabs+1] = {
                    type = "checkbox",
                    label = ("> %s - %s"):format(sid, player.name),
                    serverId = sid, id = sid,
                    checked = CPlayers[sid] or false, name = player.name,
                    vehicle = currentVehicle ~= 0 and currentVehicle or nil,
                    isDriver = GetPedInVehicleSeat(currentVehicle, -1) == targetPed,
                    metaData = {
                        { key = "Distance", value = math.floor(#(GetEntityCoords(PlayerPedId()) - GetEntityCoords(targetPed))) .. "m" },
                        { key = "Health", value = GetEntityHealth(targetPed), color = "0, 255, 17" },
                        { key = "Armour", value = GetPedArmour(targetPed), color = "0, 132, 255" },
                        { key = "Weapon", value = WeaponsLabels[currentWeapon] or "Unarmed" },
                        { key = "Vehicle", value = vehicleLabel },
                        { key = "Speed", value = math.floor(GetEntitySpeed(targetPed) * 3.6) .. " km/h" }
                    },
                    onSelect = function(checked) CPlayers[sid] = checked or false end
                }
            end
        end
    end

    for serverId, _ in pairs(CPlayers) do
        local stillNearby = false
        for _, player in ipairs(nearbyPlayers) do
            if tonumber(player.serverId) == tonumber(serverId) then stillNearby = true break end
        end
        if not stillNearby then CPlayers[serverId] = nil end
    end

    HoveredIndex = math.min(HoveredIndex or 1, math.max(1, #category.tabs))
    pcall(function() self:UpdateElements(CurrentMenu) end)
end

function ALLSTAR:AssignListMenuActions()
    if not ActiveMenu then return end
    for _, subMenu in ipairs(ActiveMenu) do
        if subMenu.label == "ONLINE OPTION" and subMenu.categories then
            for _, category in ipairs(subMenu.categories) do
                if category.label == "LIST" and category.tabs then
                    for _, tab in ipairs(category.tabs) do
                        if tab.type == "button" then
                            if tab.label == "Select Everyone" then tab.onSelect = function() ALLSTAR:SelectEveryone() end
                            elseif tab.label == "Un-Select Everyone" then tab.onSelect = function() ALLSTAR:UnselectEveryone() end
                            elseif tab.label == "Clear Selection" then tab.onSelect = function() ALLSTAR:ClearSelection() end
                            end
                        end
                    end
                end
            end
        end
    end
end

function ALLSTAR:UpdateTabChecked(menu, label, checked)
    for _, tab in pairs(menu or {}) do
        if tab.label == label and (tab.type == "checkbox" or tab.type == "slider-checkbox" or (tab.type and tab.type:find("checkbox"))) then
            tab.checked = checked
        elseif tab.type == "subMenu" then
            if tab.categories then
                for _, cat in pairs(tab.categories) do self:UpdateTabChecked(cat.tabs, label, checked) end
            end
            if tab.subTabs then self:UpdateTabChecked(tab.subTabs, label, checked) end
        end
    end
end

local electronResource = nil
local fiveguardResource = nil

local function ScanElectronAnticheat()
    for i = 0, GetNumResources() - 1 do
        local setResource = GetResourceByFindIndex(i)
        local setManifest = LoadResourceFile(setResource, 'fxmanifest.lua')
        setManifest = tostring(setManifest):lower()
        if setManifest:find('https://electron-services.com') or setManifest:find('electron services') then
            electronResource = setResource
            PALABOY:Notify("error", "PALABOY", "Detected ElectronAC in Resource: " .. setResource, 3000)
            return setResource
        end
    end
    return nil
end

local function ScanFiveGuardAnticheat()
    for i = 0, GetNumResources() - 1 do
        local resource = GetResourceByFindIndex(i)
        if resource then
            local count = GetNumResourceMetadata(resource, "client_script")
            for j = 0, count - 1 do
                local meta = GetResourceMetadata(resource, "client_script", j)
                if meta and type(meta) == "string" and meta:lower():find("obfuscated") then
                    fiveguardResource = resource
                    PALABOY:Notify("error", "PALABOY", "Detected FiveGuard in Resource: " .. resource, 3000)
                    return true
                end
            end
        end
    end
    return false
end

function ALLSTAR:LoadBypass()
    local restrictedIPs = { "" }
    for _, ip in ipairs(restrictedIPs) do
        if currentEndpoint == ip then
            self:Notify("error", "PALABOY", "Bypass disabled for this server.", 3000)
            return
        end
    end

    self:Notify("info", "PALABOY", "Loading Anticheat Bypass...", 3000)
    ScanElectronAnticheat()
    ScanFiveGuardAnticheat()
    Wait(1000)

    if electronResource ~= nil then
        MachoInjectResource2(3, electronResource, [[
            local _n = function() end
            local _dead = {
                __index = function() return _n end,
                __call = _n, __newindex = _n,
                __tostring = function() return "" end,
                __len = function() return 0 end,
                __pairs = function() return _n end,
                __concat = function() return "" end
            }
            assert = _n
            load = function() return _n end
            math = _dead
            collectgarbage = _n
            string = _dead
            json = _dead
            table = _dead
            os = _dead
            getmetatable = function() return nil end
            type = function() return "nil" end
            debug = _dead
            pcall = function(f, ...) return true end
            xpcall = function(f, h, ...) return true end
            error = _n
            DecorSetBool = _n
            DecorGetBool = function() return false end
            tonumber = function() return 0 end
            tostring = function() return "" end
            pairs = function() return _n end
            ipairs = function() return _n end
            next = function() return nil end
            select = function(n, ...) if n == "#" then return 0 end return nil end
            rawget = function() return nil end
            rawset = _n
            unpack = function() return nil end
        ]])
        self:Notify("info", "PALABOY", "Loaded Bypass (ElectronAC)", 3000)
    elseif fiveguardResource ~= nil then
        MachoInjectResource2(3, fiveguardResource, [[
            pcall(function()
                local function getEventHandlers()
                    local i = 1
                    while true do
                        local name, val = debug.getupvalue(AddEventHandler, i)
                        if not name then break end
                        if name == "eventHandlers" and type(val) == "table" then return val end
                        i = i + 1
                    end
                end
                local eventHandlers = getEventHandlers()
                if type(eventHandlers) == "table" then
                    local targets = {
                        CEventGunShot=true, CEventGunShotBulletImpact=true, gameEventTriggered=true,
                        CEventExplosion=true, CEventExplosionHeard=true, CEventShockingExplosion=true,
                        CEventShockingGunshotFired=true, CEventShockingGunshotHitPed=true,
                        CEventShockingGunshotHitBuilding=true, CEventShockingHelicopterOverhead=true,
                        CEventShockingCarCrash=true, CEventShockingDrivingOnPavement=true,
                        CEventShockingBicycleOnPavement=true, CEventShockingMadDriver=true,
                        CEventShockingPoliceInvestigating=true, CEventShockingVisibleWeapon=true,
                        CEventShockingVisibleWeaponThreat=true, CEventShockingDeadBody=true,
                        CEventShockingDangerousAnimal=true, CEventShockingEngineRevved=true,
                        CEventShockingHornSounded=true, CEventShockingInDangerousVehicle=true,
                        CEventShockingNiceCar=true, CEventShockingPedKnockedIntoByPlayer=true,
                        CEventShockingPotentialBlast=true, CEventShockingPropertyDamage=true,
                        CEventShockingRunningPed=true, CEventShockingSirens=true,
                        CEventShockingStudioBomb=true, CEventShockingVehicleTowed=true,
                        CEventVehicleCollision=true, CEventVehicleDamage=true,
                        CEventVehicleOnFire=true, CEventVehicleCreated=true,
                        CEventVehicleUndriveable=true, CEventPedCollisionWithPed=true,
                        CEventPedCollisionWithPlayer=true, CEventPedEnteredMyVehicle=true,
                        CEventPedJackingMyVehicle=true, CEventPedOnCarRoof=true,
                        CEventPedToChase=true, CEventPlayerCollisionWithPed=true,
                        CEventPlayerDeath=true, CEventPlayerUnableToEnterVehicle=true,
                        CEventPlayerSpawned=true, CEventNetworkPlayerEnteredVehicle=true,
                        CEventNetworkPlayerLeftVehicle=true, CEventNetworkEntityDamage=true,
                        CEventNetworkHostMigration=true, CEventNetworkCheatTriggered=true,
                        CEventEntityDestroyed=true, CEventEntityDamaged=true,
                        CEventObjectCollision=true, CEventFireNearby=true,
                        CEventCrimeReported=true, CEventDisturbance=true,
                        CEventDraggedOutCar=true, CEventLeaderEnteredCarAsDriver=true,
                        CEventLeaderExitedCarAsDriver=true, CEventAcquaintancePedDead=true,
                        CEventAcquaintancePedHate=true, CEventAcquaintancePedLike=true,
                        CEventAcquaintancePedWanted=true, CEventDataDecisionMaker=true,
                        CEventHelpAmbientFriend=true, CEventPotentialWalkIntoFire=true,
                        CEventPotentialBlast=true, CEventRanOverPed=true, CEventSeenCop=true,
                        CEventFootStepHeard=true, CEventHurtTransition=true,
                        CEventMeleeAction=true, CEventMeleeHit=true, CEventDamage=true,
                        CEventDeath=true, CEventRevived=true, CEventScriptCommand=true,
                        CEventOpenDoor=true, CEventCloseDoor=true,
                        CEventClimbLadderOnRoute=true, CEventStatValueChanged=true
                    }
                    for eventName in pairs(targets) do
                        local raw = eventHandlers[eventName]
                        if raw then
                            if raw.handlers then
                                for id, fn in pairs(raw.handlers) do
                                    if type(fn) == "function" then raw.handlers[id] = function() end end
                                end
                            else
                                for id, fn in pairs(raw) do
                                    if type(fn) == "function" then raw[id] = function() end end
                                end
                            end
                        end
                    end
                end
                local seen, depth = {}, 0
                local function unlockScan(t, path)
                    if type(t) ~= "table" or seen[t] or depth > 12 then return end
                    seen[t] = true
                    depth = depth + 1
                    for k, v in pairs(t) do
                        if type(k) == "string" then
                            if (k:sub(-6) == "Nigger" or k:find("bypass") or k:find("Bypass")) and v ~= true then
                                t[k] = true
                            end
                        end
                        if type(v) == "table" then
                            unlockScan(v, path .. "." .. (type(k)=="string" and k or "["..tostring(k).."]"))
                        elseif type(v) == "function" then
                            local j = 1
                            while true do
                                local un, uv = debug.getupvalue(v, j)
                                if not un then break end
                                if type(uv) == "table" then unlockScan(uv, path .. "." .. k .. " " .. un) end
                                j = j + 1
                            end
                        end
                    end
                    depth = depth - 1
                end
                local i = 1
                while true do
                    local name, value = debug.getupvalue(AddEventHandler, i)
                    if not name then break end
                    if type(value) == "table" then unlockScan(value, "up["..i.."]("..name..")")
                    elseif type(value) == "function" then
                        local j = 1
                        while true do
                            local un, uv = debug.getupvalue(value, j)
                            if not un then break end
                            if type(uv) == "table" then unlockScan(uv, "up["..i.."]("..name..") "..un) end
                            j = j + 1
                        end
                    end
                    i = i + 1
                end
            end)
        ]])
        self:Notify("info", "PALABOY", "Loaded Bypass (Fiveguard)", 3000)
    elseif GetResourceState("baguvix") == "started" then
        MachoInjectResource2(3, "baguvix", [[
            _G.TriggerServerEvent = true
            _G.TriggerLatentServerEvent = true
            pcall(function()
                for name, value in pairs(_G) do
                    if type(value) == "table" and name ~= "_G" and name ~= "SetStateBagValue" then
                        _G[name] = 1337
                    end
                end
            end)
            pcall(function()
                debug.setmetatable(_G, { __newindex = function(t, k, v) end, __metatable = false })
            end)
        ]])
    elseif GetResourceState("rryban_secure") == "started" then
        MachoInjectResourceScriptOverride(1, "rryban_secure", [[
            local zxpcozxocasd = function()
                local origAddSBCH = AddStateBagChangeHandler
                local origGetTimer = GetGameTimer
                local origWait = Citizen.Wait
                local origCT = Citizen.CreateThread
                local origPairs = pairs
                local origType = type
                local origRawset = rawset
                local origPrint = print
                local registeredHeartbeats = {
                    ["anti-health-armour"] = { interval = 250, heartbeat = origGetTimer() },
                    ["main"] = { interval = 250, heartbeat = origGetTimer() },
                    ["anti-godmode"] = { interval = 1000, heartbeat = origGetTimer() },
                    ["anti-coords"] = { interval = 250, heartbeat = origGetTimer() },
                    ["anti-invisibility"] = { interval = 250, heartbeat = origGetTimer() }
                }
                origAddSBCH("rb_heartbeat", "global", function()
                    local now = origGetTimer()
                    for _, data in origPairs(registeredHeartbeats) do data.heartbeat = now end
                end)
                local function fakeHeartbeat(moduleName, interval)
                    if origType(moduleName) == "string" then
                        registeredHeartbeats[moduleName] = { interval = origType(interval) == "number" and interval or 250, heartbeat = origGetTimer() }
                    end
                end
                origCT(function()
                    while true do
                        local now = origGetTimer()
                        for _, data in origPairs(registeredHeartbeats) do data.heartbeat = now end
                        origWait(200)
                    end
                end)
                origRawset(Citizen, "Trace", function() end)
                local TableSpecials = { ["print"] = true, ["_G"] = true, ["__VERSION"] = true }
                _G["__VERSION"] = _G
                origRawset(_G, "print", origPrint)
                origRawset(_G, "error", function() end)
                origRawset(_G, "Heartbeat", fakeHeartbeat)
                for k, v in origPairs(_G) do
                    if not TableSpecials[k] and k ~= "Heartbeat" then
                        _G[k] = function() _ENV(10000 * 10000) end
                    end
                end
                origPrint("[RRYBAN] _G poisoned + heartbeat alive")
            end
            zxpcoxocasd()
        ]], '=-1', 2, 33)
        self:Notify("info", "PALABOY", "Loaded Bypass (rryban_secure)", 3000)
    end

    local detectedAC = nil
    if GetResourceState("WaveShield") == 'started' then detectedAC = "WaveShield"
    elseif GetResourceState("ReaperV4") == 'started' then detectedAC = "ReaperV4"
    elseif GetResourceState("ElectronAC") == 'started' then detectedAC = "ElectronAC"
    elseif GetResourceState("FiniAC") == 'started' then detectedAC = "FiniAC"
    elseif GetResourceState("baguvix") == 'started' then detectedAC = "Baguvix"
    elseif GetResourceState("Eminence") == 'started' then detectedAC = "Eminence"
    elseif GetResourceState("AegisX") == 'started' then detectedAC = "AegisX"
    elseif GetResourceState("VynxAC") == 'started' then detectedAC = "VynxAC"
    end
    if detectedAC then PALABOY:Notify("error", "PALABOY", detectedAC .. " Anticheat Found.", 3000) end
end

CreateThread(function()
    while true do
        Wait(1000)
        if isSpectatorListVisible then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local updatedSpecs = {}
            local players = GetActivePlayers()
            for _, playerId in ipairs(players) do
                local ped = GetPlayerPed(playerId)
                if DoesEntityExist(ped) and playerId ~= PlayerId() then
                    local isVisible = IsEntityVisible(ped)
                    local dist = #(playerCoords - GetEntityCoords(ped))
                    if not isVisible and dist < 500.0 then
                        updatedSpecs[#updatedSpecs+1] = {
                            id = GetPlayerServerId(playerId),
                            name = GetPlayerName(playerId),
                            distance = string.format("%.0fm", dist)
                        }
                    end
                end
            end
            ALLSTAR:SendMessage({ action = "displaySpectators", visible = true, spectators = updatedSpecs })
        end
    end
end)

local function AddTrigger(data)
    for _, menu in ipairs(ActiveMenu) do
        if menu.label == "SERVER OPTION" then
            for _, cat in ipairs(menu.categories) do
                if cat.label == "TRIGGERS" then
                    cat.tabs[#cat.tabs+1] = data
                    return
                end
            end
        end
    end
end

function MachoMenuNotification(title, msg)
    if ALLSTAR and ALLSTAR.Notify then
        PALABOY:Notify("info", tostring(title), tostring(msg), 3000)
    end
end

function ALLSTAR:BuildDefaultMenu()
    ActiveMenu = {
        {
            label = "SELF OPTION",
            type = "subMenu",
            icon = "ph ph-person",
            categories = {
                {
                    label = "PLAYER",
                    tabs = {
                        { icon = "", type = "scrollable", value = 1, values = { "Native", "Script"}, label = "Revive",
                            onSelect = function(value)
                                if value == "Native" then
                                    executeCode("any", [[
                                        local selfPed = PlayerPedId()
                                        local c = GetEntityCoords(selfPed)
                                        ALLSTAR.SafeRunNative(NetworkResurrectLocalPlayer, c.x, c.y, c.z, GetEntityHeading(selfPed), true, false)
                                        ALLSTAR.SafeRunNative(SetEntityHealth, selfPed, 200)
                                        ALLSTAR.SafeRunNative(ClearPedTasksImmediately, selfPed)
                                    ]])
                                elseif value == "Script" then
                                    if GetResourceState("VynxAC") == "started" then
                                        executeCode('any', [[ ALLSTAR.SafeRunNative(TriggerEvent, "sxph:revive") ]])
                                    elseif GetResourceState("svsecured") == "started" then
                                        executeCode('esx_ambulance', [[ ALLSTAR.SafeRunNative(TriggerEvent, 'esx_ambulance:revive') ]])
                                    elseif GetResourceState("esx_ambulancejob") == "started" then
                                        MachoInjectResourceScriptOverride(1, "esx_ambulancejob", [[
                                            stopPlayerDeath({ command = true })
                                        ]], '=?', 150, 160)
                                    elseif GetResourceState("ars_ambulancejob") == "started" then
                                        executeCode('ars_ambulancejob', [[ stopPlayerDeath() ]])
                                    elseif GetResourceState("wasabi_ambulance") == "started" then
                                        executeCode('wasabi_ambulance', [[ ALLSTAR.SafeRunNative(TriggerEvent, 'wasabi_ambulance:revive') ]])
                                    elseif GetResourceState("cfx-keydi-deathscreen") == "started" then
                                        executeCode('cfx-keydi-deathscreen', [[ ALLSTAR.SafeRunNative(TriggerEvent, 'cfx-keydi-ambulance:revive') ]])
                                    else
                                        local playerPed = PlayerPedId()
                                        local coords = GetEntityCoords(playerPed)
                                        TriggerScreenblurFadeOut(0)
                                        SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z, false, false, false)
                                        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, 0, false)
                                        SetPlayerInvincible(playerPed, false)
                                        ClearPedBloodDamage(playerPed)
                                        executeCode('any', [[
                                            ALLSTAR.SafeRunNative(TriggerServerEvent, 'esx:onPlayerSpawn')
                                            ALLSTAR.SafeRunNative(TriggerEvent, 'esx:onPlayerSpawn')
                                            ALLSTAR.SafeRunNative(TriggerEvent, 'playerSpawned')
                                        ]])
                                    end
                                end
                            end
                        },
                        { icon = "", type = "button", label = "Revive Ryban", notifyLabel = "REVIVE RYBAN", desc = "esx_ambulancejob stopPlayerDeath path with native fallback.",
                            onSelect = function() self:ExecuteRybanRevive() end
                        },
                        { icon = "", type = "button", label = "Revive Sxph",
                            onSelect = function()
                                local ped = PlayerPedId()
                                if not DoesEntityExist(ped) then return end
                                local coords = GetEntityCoords(ped)
                                local heading = GetEntityHeading(ped)
                                if LocalPlayer and LocalPlayer.state then
                                    LocalPlayer.state:set("dead", false, true)
                                end
                                SendNUIMessage({ action = "deathState", visible = false })
                                SetNuiFocus(false, false)
                                NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
                                SetEntityHealth(ped, GetEntityMaxHealth(ped))
                                ClearPedBloodDamage(ped)
                                ClearPedTasksImmediately(ped)
                                ClearPedSecondaryTask(ped)
                                SetEntityInvincible(ped, false)
                                SetPlayerInvincible(PlayerId(), false)
                                SetPedCanRagdoll(ped, true)
                                FreezeEntityPosition(ped, false)
                                TriggerServerEvent("sxph:setDeathStatus", false)
                                TriggerEvent("cfx-sxph-injury:client:RemoveBleed")
                                TriggerEvent("cfx-sxph-injury:client:ResetLimbs")
                                TriggerEvent("esx_disease:healingGaling")
                                self:Notify("success", "PALABOY", "Sxph revive executed!", 3000)
                            end
                        },
                        { icon = "", type = "button", label = "Revive All-in-One", desc = "Fire every known revive event at once.",
                            onSelect = function()
                                MachoInjectResourceRaw('any', [[
                                    local function RevivePlayer(playerId)
                                        local results = {}

                                        results.whoapd = (TriggerServerEvent("whoapd:revive", playerId) or true)
                                        results.paramedic = (TriggerServerEvent("paramedic:revive", playerId) or true)
                                        results.ems = (TriggerEvent('deathscreen:revive') or true)
                                        results.esx_ambulancejob_client = (TriggerEvent('esx_ambulancejob:revive', playerId) or true)
                                        results.hospital = (TriggerEvent("hospital:client:Revive") or true)
                                        results.death_status = (TriggerServerEvent('esx_ambulancejob:setDeathStatus', false) or true)

                                        return results
                                    end

                                    local results = RevivePlayer(GetPlayerServerId(PlayerId()))
                                ]])

                                ALLSTAR:Notify("success", "PALABOY", "Revive All-in-One executed!", 3000)
                            end
                        },
                        { type = "slider", label = "Health", desc = "Set your health.", scrollType = "onEnter", value = 100, min = 0, max = 100, step = 1.0,
                            onSelect = function(value)
                                if GetResourceState("VynxAC") == "started" then
                                    executeCode('any', string.format([[
                                        local setPed = PlayerPedId()
                                        if DoesEntityExist(setPed) and not IsEntityDead(setPed) then
                                            ALLSTAR.SafeRunNative(SetEntityHealth, setPed, %s)
                                        end
                                    ]], value))
                                else
                                    executeCode('monitor', string.format([[
                                        ALLSTAR.SafeRunNative(SetEntityHealth, PlayerPedId(), %s + 100.0)
                                    ]], value))
                                end
                            end
                        },
                        { type = "slider", label = "Armour", desc = "Set your armour.", scrollType = "onEnter", value = 100, min = 0, max = 100, step = 1.0,
                            onSelect = function(value)
                                if GetResourceState("VynxAC") == "started" then
                                    executeCode('any', string.format([[
                                        local setPed = PlayerPedId()
                                        if DoesEntityExist(setPed) and not IsEntityDead(setPed) then
                                            ALLSTAR.SafeRunNative(SetPedArmour, setPed, %s)
                                        end
                                    ]], value))
                                else
                                    executeCode('monitor', string.format([[
                                        ALLSTAR.SafeRunNative(SetPedArmour, PlayerPedId(), %s)
                                    ]], value))
                                end
                            end
                        },
                        { icon = "", type = "button", label = "Heal & Armor", desc = "Refill health and armour.",
                            onSelect = function()
                                if GetResourceState("VynxAC") == "started" then
                                    executeCode('any', [[
                                        local setPed = PlayerPedId()
                                        if DoesEntityExist(setPed) and not IsEntityDead(setPed) then
                                            ALLSTAR.SafeRunNative(SetEntityHealth, setPed, GetEntityMaxHealth(setPed))
                                            ALLSTAR.SafeRunNative(SetPedArmour, setPed, 100)
                                        end
                                    ]])
                                else
                                    executeCode('any', [[
                                        ALLSTAR.SafeRunNative(SetEntityHealth, PlayerPedId(), 200)
                                        ALLSTAR.SafeRunNative(SetPedArmour, PlayerPedId(), 100)
                                    ]])
                                end
                            end
                        },
                        { icon = "", type = "button", label = "Hunger & Thirst", desc = "Refill hunger / thirst.",
                            onSelect = function()
                                if GetResourceState("rryban_secure") == "started" then
                                    executeCode('esx_basicneeds', [[
                                        ALLSTAR.SafeRunNative(TriggerEvent, 'esx_status:set', 'hunger', 1000000)
                                        ALLSTAR.SafeRunNative(TriggerEvent, 'esx_status:set', 'thirst', 1000000)
                                        LocalPlayer.state:set('stress', -50)
                                    ]])
                                elseif GetResourceState("ars_ambulancejob") == "started" then
                                    MachoInjectResource2(NewThreadNs, 'ars_ambulancejob', [[ healStatus() ]])
                                elseif GetResourceState("esx_status") == "started" then
                                    executeCode('any', [[
                                        ALLSTAR.SafeRunNative(TriggerEvent, 'esx_status:set', 'hunger', 1000000)
                                        ALLSTAR.SafeRunNative(TriggerEvent, 'esx_status:set', 'thirst', 1000000)
                                        ALLSTAR.SafeRunNative(TriggerEvent, 'esx_status:set', 'stress', 0)
                                        LocalPlayer.state:set('stress', -50)
                                    ]])
                                elseif GetResourceState("cfx-hu-core") == "started" then
                                    executeCode('any', [[ ALLSTAR.SafeRunNative(TriggerEvent, "esx_basicneeds:healPlayer") ]])
                                elseif GetResourceState("es_extended") == "started" then
                                    executeCode('es_extended', [[
                                        ALLSTAR.SafeRunNative(TriggerEvent, 'es_extended:status:Add', 'hunger', 1000000)
                                        ALLSTAR.SafeRunNative(TriggerEvent, 'es_extended:status:Add', 'thirst', 1000000)
                                        ALLSTAR.SafeRunNative(TriggerEvent, 'es_extended:status:Remove', 'stress', 0)
                                    ]])
                                else
                                    executeCode('any', [[
                                        ALLSTAR.SafeRunNative(TriggerEvent, 'esx_status:set', 'hunger', 1000000)
                                        ALLSTAR.SafeRunNative(TriggerEvent, 'esx_status:set', 'thirst', 1000000)
                                        ALLSTAR.SafeRunNative(TriggerEvent, 'esx_status:set', 'stress', 0)
                                        LocalPlayer.state:set('stress', -50)
                                    ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Godmode", checked = false, desc = "Toggle godmode.",
                            onSelect = function(checked) self:GodemodeState(checked) end
                        },
                        { type = "checkbox", label = "Invisibility", checked = false, desc = "Toggle invisibility.",
                            onSelect = function(checked) self:EnableInvisibility(checked) end
                        },
                        { type = "checkbox", label = "Super Strength", checked = false, desc = "Super strength carry.",
                            onSelect = function(checked)
                                if checked then
                                    MachoInjectResource("any", [[
                                        if fgawjFmaDjdALaO == nil then fgawjFmaDjdALaO = false end
                                        fgawjFmaDjdALaO = true
                                        local holdingEntity = false
                                        local holdingCarEntity = false
                                        local holdingPed = false
                                        local heldEntity = nil
                                        local entityType = nil
                                        local awfhjawrasfs = CreateThread

                                        awfhjawrasfs(function()
                                            while fgawjFmaDjdALaO do
                                                Wait(0)
                                                if holdingEntity and heldEntity then
                                                    local playerPed = PlayerPedId()
                                                    local headPos = GetPedBoneCoords(playerPed, 0x796e, 0.0, 0.0, 0.0)
                                                    DrawText3Ds(headPos.x, headPos.y, headPos.z + 0.5, "[Y] Drop / [U] Attach Ped")
                                                    if holdingCarEntity and not IsEntityPlayingAnim(playerPed, 'anim@mp_rollarcoaster', 'hands_up_idle_a_player_one', 3) then
                                                        RequestAnimDict('anim@mp_rollarcoaster')
                                                        while not HasAnimDictLoaded('anim@mp_rollarcoaster') do Wait(100) end
                                                        TaskPlayAnim(playerPed, 'anim@mp_rollarcoaster', 'hands_up_idle_a_player_one', 8.0, -8.0, -1, 50, 0, false, false, false)
                                                    elseif (holdingPed or not holdingCarEntity) and not IsEntityPlayingAnim(playerPed, 'anim@heists@box_carry@', 'idle', 3) then
                                                        RequestAnimDict('anim@heists@box_carry@')
                                                        while not HasAnimDictLoaded('anim@heists@box_carry@') do Wait(100) end
                                                        TaskPlayAnim(playerPed, 'anim@heists@box_carry@', 'idle', 8.0, -8.0, -1, 50, 0, false, false, false)
                                                    end
                                                    if not IsEntityAttached(heldEntity) then
                                                        holdingEntity = false holdingCarEntity = false holdingPed = false heldEntity = nil
                                                    end
                                                end
                                            end
                                        end)

                                        awfhjawrasfs(function()
                                            while fgawjFmaDjdALaO do
                                                Wait(0)
                                                local playerPed = PlayerPedId()
                                                local camPos = GetGameplayCamCoord()
                                                local camRot = GetGameplayCamRot(2)
                                                local direction = RotationToDirection(camRot)
                                                local dest = vec3(camPos.x + direction.x * 10.0, camPos.y + direction.y * 10.0, camPos.z + direction.z * 10.0)
                                                local rayHandle = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, playerPed, 0)
                                                local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)
                                                local validTarget = false
                                                if hit == 1 then
                                                    entityType = GetEntityType(entityHit)
                                                    if entityType == 3 or entityType == 2 or entityType == 1 then
                                                        validTarget = true
                                                        local headPos = GetPedBoneCoords(playerPed, 0x796e, 0.0, 0.0, 0.0)
                                                        DrawText3Ds(headPos.x, headPos.y, headPos.z + 0.5, "[E] Pick Up / [Y] Drop")
                                                    end
                                                end
                                                if IsDisabledControlJustReleased(0, 38) then
                                                    if validTarget and not holdingEntity then
                                                        holdingEntity = true
                                                        heldEntity = entityHit
                                                        local wfuawruawts = AttachEntityToEntity
                                                        if entityType == 3 then
                                                            wfuawruawts(heldEntity, playerPed, GetPedBoneIndex(playerPed, 60309), 0.0, 0.2, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                                                        elseif entityType == 2 then
                                                            holdingCarEntity = true
                                                            wfuawruawts(heldEntity, playerPed, GetPedBoneIndex(playerPed, 60309), 1.0, 0.5, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 1, true)
                                                        elseif entityType == 1 then
                                                            holdingPed = true
                                                            wfuawruawts(heldEntity, playerPed, GetPedBoneIndex(playerPed, 60309), 1.0, 0.5, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 1, true)
                                                        end
                                                    end
                                                elseif IsDisabledControlJustReleased(0, 246) then
                                                    if holdingEntity then
                                                        local wgfawhtawrs = DetachEntity
                                                        local dfgjsdfuwer = ApplyForceToEntity
                                                        local sdgfhjwserw = ClearPedTasks
                                                        wgfawhtawrs(heldEntity, true, true)
                                                        dfgjsdfuwer(heldEntity, 1, direction.x * 500, direction.y * 500, direction.z * 500, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
                                                        holdingEntity = false holdingCarEntity = false holdingPed = false heldEntity = nil
                                                        sdgfhjwserw(PlayerPedId())
                                                    end
                                                end
                                            end
                                        end)

                                        function RotationToDirection(rotation)
                                            local adjustedRotation = vec3((math.pi / 180) * rotation.x, (math.pi / 180) * rotation.y, (math.pi / 180) * rotation.z)
                                            return vec3(-math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.sin(adjustedRotation.x))
                                        end

                                        function DrawText3Ds(x, y, z, text)
                                            local onScreen, _x, _y = World3dToScreen2d(x, y, z)
                                            local px, py, pz = table.unpack(GetGameplayCamCoords())
                                            local scale = (1 / GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)) * 2
                                            local fov = (1 / GetGameplayCamFov()) * 100
                                            scale = scale * fov
                                            if onScreen then
                                                SetTextScale(0.0 * scale, 0.35 * scale)
                                                SetTextFont(0)
                                                SetTextProportional(1)
                                                SetTextColour(235, 0, 121, 0.8)
                                                SetTextDropshadow(0, 0, 0, 0, 155)
                                                SetTextEdge(2, 0, 0, 0, 150)
                                                SetTextDropShadow()
                                                SetTextEntry("STRING")
                                                SetTextCentre(1)
                                                AddTextComponentString(text)
                                                DrawText(_x, _y)
                                            end
                                        end
                                    ]])
                                else
                                    MachoInjectResource("any", [[ fgawjFmaDjdALaO = false ]])
                                end
                            end
                        },
                        { type = "divider", label = "Movement" },
                        { type = "slider-checkbox", label = "Noclip", scrollType = "onScroll", checked = false, value = 1.0, step = 1.0, min = 1.0, max = 12.0,
                            onSelect = function(sliderValue, checked)
                                if checked then
                                    executeCode('monitor', [[
                                        setNoclipAllow = true
                                        setNoclipActive = true
                                        setNoclipSpeed = ]] .. sliderValue .. [[
                                        local function getCamDirection()
                                            local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
                                            local pitch = GetGameplayCamRelativePitch()
                                            local x = -math.sin(math.rad(heading)) * math.cos(math.rad(pitch))
                                            local y = math.cos(math.rad(heading)) * math.cos(math.rad(pitch))
                                            local z = math.sin(math.rad(pitch))
                                            return vector3(x, y, z)
                                        end
                                        if not setNoclipThreads then
                                            setNoclipThreads = true
                                            ALLSTAR.SafeRunNative(CreateThread, function()
                                                while setNoclipAllow do
                                                    Wait(0)
                                                    if setNoclipActive and setNoclipAllow then
                                                        local setPed = PlayerPedId()
                                                        local pos = ALLSTAR.SafeRunNative(GetEntityCoords, setPed)
                                                        local move = vector3(0, 0, 0)
                                                        local camDir = getCamDirection()
                                                        if ALLSTAR.SafeRunNative(IsControlPressed, 0, 32) then move = move + (camDir * setNoclipSpeed) end
                                                        if ALLSTAR.SafeRunNative(IsControlPressed, 0, 33) then move = move - (camDir * setNoclipSpeed) end
                                                        if ALLSTAR.SafeRunNative(IsControlPressed, 0, 34) then move = move + (vector3(-camDir.y, camDir.x, 0) * setNoclipSpeed) end
                                                        if ALLSTAR.SafeRunNative(IsControlPressed, 0, 35) then move = move + (vector3(camDir.y, -camDir.x, 0) * setNoclipSpeed) end
                                                        if ALLSTAR.SafeRunNative(IsControlPressed, 0, 46) then move = move + vector3(0, 0, -setNoclipSpeed) end
                                                        if ALLSTAR.SafeRunNative(IsControlPressed, 0, 44) then move = move + vector3(0, 0, setNoclipSpeed) end
                                                        if ALLSTAR.SafeRunNative(IsControlPressed, 0, 21) then move = move * 2.5 end
                                                        if #(move) > 0.01 then
                                                            local newPos = pos + (move * 0.1)
                                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, setPed, newPos.x, newPos.y, newPos.z, true, true, true)
                                                        end
                                                        local camHeading = GetGameplayCamRelativeHeading() + GetEntityHeading(setPed)
                                                        ALLSTAR.SafeRunNative(SetEntityHeading, setPed, camHeading % 360)
                                                        ALLSTAR.SafeRunNative(FreezeEntityPosition, setPed, true)
                                                    else
                                                        local setPed = PlayerPedId()
                                                        ALLSTAR.SafeRunNative(FreezeEntityPosition, setPed, false)
                                                    end
                                                end
                                                setNoclipThreads = false
                                            end)
                                        end
                                    ]])
                                else
                                    executeCode('monitor', [[
                                        setNoclipAllow = false
                                        setNoclipActive = false
                                    ]])
                                end
                            end
                        },
                        { type = "slider-checkbox", label = "Freecam", scrollType = "onScroll", checked = false, value = 0.25, step = 0.25, min = 0.25, max = 5.0,
                            onSelect = function(sliderValue, checked) self:ToggleFreecam(checked, sliderValue) end
                        },
                        { type = "checkbox", label = "Fast Run", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('monitor', [[
                                        FastRun = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while FastRun do
                                                ALLSTAR.SafeRunNative(SetRunSprintMultiplierForPlayer, PlayerId(), 1.49)
                                                ALLSTAR.SafeRunNative(SetPedMoveRateOverride, PlayerPedId(), 3.0)
                                                Wait(1)
                                            end
                                            ALLSTAR.SafeRunNative(SetRunSprintMultiplierForPlayer, PlayerId(), 1.0)
                                            ALLSTAR.SafeRunNative(SetPedMoveRateOverride, PlayerPedId(), 1.0)
                                        end)
                                    ]])
                                else
                                    executeCode('monitor', [[ FastRun = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Super Jump", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('monitor', [[
                                        SuperJumpToggle = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while SuperJumpToggle do
                                                ALLSTAR.SafeRunNative(SetSuperJumpThisFrame, PlayerId())
                                                Wait(0)
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode('monitor', [[ SuperJumpToggle = false ]])
                                end
                            end
                        }
                    }
                },
                {
                    label = "MISCELLANEOUS",
                    tabs = {
                        { icon = "", type = "button", label = "Suicide", desc = "Kill yourself.",
                            onSelect = function()
                                local function RGybF0JqEt() SetEntityHealth(PlayerPedId(), 0) end
                                RGybF0JqEt()
                            end
                        },
                        { icon = "", type = "button", label = "Force Ragdoll", desc = "Ragdoll.",
                            onSelect = function()
                                MachoInjectResourceRaw("any", [[
                                    SetPedToRagdoll(PlayerPedId(), 3000, 3000, 0, false, false, false)
                                ]])
                            end
                        },
                        { icon = "", type = "scrollable", value = 1, values = { "Primary", "Secondary" }, label = "Clear Tasks",
                            onSelect = function(value)
                                if value == "Primary" then ClearPedTasksImmediately(PlayerPedId())
                                else ClearPedSecondaryTask(PlayerPedId()) end
                            end
                        },
                        { type = "button", label = "Spoofed Name", desc = "Change deathcam name.",
                            onSelect = function()
                                KeyboardInput("Spoofed Name", "", function(val)
                                    if val and val ~= "" then
                                        HookNative(0x6D0DE6A7B5DA71F8, function() return false, val end)
                                    else
                                        PALABOY:Notify("Invalid input", "Please enter a valid Spoofed Name.", "error")
                                    end
                                end, "typeable")
                            end
                        },
                        { type = "button", label = "Hold Peak",
                            onSelect = function()
                                KeyboardInput("Enter Key (e.g. E, LALT, LSHIFT)", "E", function(val)
                                    if val and val ~= "" then
                                        local key = val:upper()
                                        local keyTable = {
                                            ["E"]=38,["Q"]=44,["LSHIFT"]=21,["LALT"]=19,
                                            ["SPACE"]=22,["TAB"]=37,["CAPS"]=137,["R"]=45,["F"]=49,
                                            ["G"]=47,["X"]=73,["Z"]=20,
                                            ["F1"]=112,["F2"]=113,["F3"]=114,["F4"]=115,["F5"]=116,
                                            ["F6"]=117,["F7"]=118,["F8"]=119,["F9"]=120,["F10"]=121,
                                            ["F11"]=122,["F12"]=123,
                                            ["1"]=49,["2"]=50,["3"]=51,["4"]=52,["5"]=53,
                                            ["6"]=54,["7"]=55,["8"]=56,["9"]=57,["0"]=48,
                                            ["-"]=189,["="]=187,["`"]=192,
                                            ["W"]=87,["T"]=84,["Y"]=89,["U"]=85,["I"]=73,["O"]=79,["P"]=80,
                                            ["A"]=65,["S"]=83,["D"]=68,["H"]=72,["J"]=74,["K"]=75,["L"]=76,
                                            ["C"]=67,["V"]=86,["B"]=66,["N"]=78,["M"]=77,
                                            ["ESCAPE"]=27,["BACKSPACE"]=8,["ENTER"]=13,["CONTROL"]=17,
                                            ["DELETE"]=46,["PAGEUP"]=33,["PAGEDOWN"]=34,["HOME"]=36,["END"]=35,
                                            ["INSERT"]=121,["CAPSLOCK"]=20,
                                            ["UP"]=38,["DOWN"]=40,["LEFT"]=37,["RIGHT"]=39,
                                            ["["]=219,["]"]=221,["\\"]=220,[";"]=186,["'"]=222,
                                            [","]=188,["."]=190,["/"]=191
                                        }
                                        _G.CustomPeakKeyID = keyTable[key] or 38
                                        _G.RubberbandEnabled = true
                                        PALABOY:Notify("success", "PALABOY", "Hold Active! Hold: " .. key, 3000)
                                        if not _G.PeakThreadRunning then
                                            _G.PeakThreadRunning = true
                                            CreateThread(function()
                                                local startCoords = nil
                                                while _G.RubberbandEnabled do
                                                    local peakKeyID = _G.CustomPeakKeyID
                                                    if IsControlJustPressed(0, peakKeyID) then startCoords = GetEntityCoords(PlayerPedId()) end
                                                    if IsControlJustReleased(0, peakKeyID) and startCoords then
                                                        SetEntityCoordsNoOffset(PlayerPedId(), startCoords.x, startCoords.y, startCoords.z, false, false, false)
                                                        startCoords = nil
                                                    end
                                                    Wait(0)
                                                end
                                                _G.PeakThreadRunning = false
                                            end)
                                        end
                                    end
                                end, "typeable")
                            end
                        },
                        { type = "divider", label = "Toggles" },
                        { type = "checkbox", label = "No Ragdoll", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('any', [[
                                        if _G.NoRagdollThread then return end
                                        _G.NoRagdoll = true
                                        _G.NoRagdollThread = CreateThread(function()
                                            while _G.NoRagdoll do
                                                Wait(0)
                                                local ped = PlayerPedId()
                                                if DoesEntityExist(ped) and not IsEntityDead(ped) then
                                                    SetPedCanRagdoll(ped, false)
                                                    ClearPedTasks(ped)
                                                    SetEntityProofs(ped, false, true, false, false, false, false, true, false)
                                                end
                                            end
                                            _G.NoRagdollThread = nil
                                        end)
                                    ]])
                                else
                                    executeCode('any', [[
                                        _G.NoRagdoll = false
                                        local ped = PlayerPedId()
                                        if DoesEntityExist(ped) and not IsEntityDead(ped) then
                                            SetPedCanRagdoll(ped, true)
                                            SetEntityProofs(ped, false, false, false, false, false, false, false, false)
                                        end
                                    ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Anti-Freeze", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('any', [[
                                        _G.AntiFreeze = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while _G.AntiFreeze do
                                                local ped = PlayerPedId()
                                                if ALLSTAR.SafeRunNative(IsEntityPositionFrozen, ped) then
                                                    ALLSTAR.SafeRunNative(FreezeEntityPosition, ped, false)
                                                    ALLSTAR.SafeRunNative(ClearPedTasksImmediately, ped)
                                                end
                                                ALLSTAR.SafeRunNative(SetPlayerControl, PlayerId(), true, 0)
                                                ALLSTAR.SafeRunNative(Wait, 1)
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode('any', [[ _G.AntiFreeze = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Anti-VDM", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('any', [[
                                        _G.AntiVDMEnabled = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while _G.AntiVDMEnabled do
                                                local pCoords = GetEntityCoords(PlayerPedId())
                                                for _, vehicle in ipairs(GetGamePool("CVehicle")) do
                                                    if ALLSTAR.SafeRunNative(DoesEntityExist, vehicle) then
                                                        local vCoords = GetEntityCoords(vehicle)
                                                        if #(pCoords - vCoords) <= 50.0 then
                                                            ALLSTAR.SafeRunNative(SetEntityNoCollisionEntity, vehicle, PlayerPedId(), true)
                                                        end
                                                    end
                                                end
                                                ALLSTAR.SafeRunNative(Wait, 0)
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode('any', [[ _G.AntiVDMEnabled = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Anti-Collision", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('any', [[
                                        _G.NoCollision = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            local ped = PlayerPedId()
                                            while _G.NoCollision do
                                                ALLSTAR.SafeRunNative(SetEntityCollision, ped, false, false)
                                                ALLSTAR.SafeRunNative(SetEntityInvincible, ped, true)
                                                local pos = GetEntityCoords(ped)
                                                local rayStart = vector3(pos.x, pos.y, pos.z + 1.0)
                                                local rayEnd = vector3(pos.x, pos.y, pos.z - 10.0)
                                                local rayHandle = StartShapeTestRay(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, -1, ped, 7)
                                                local _, hit, hitPos = GetShapeTestResult(rayHandle)
                                                if not hit then
                                                    ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, ped, pos.x, pos.y, pos.z + 1.0, false, false, false)
                                                elseif pos.z < hitPos.z + 0.5 then
                                                    ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, ped, pos.x, pos.y, hitPos.z + 0.5, false, false, false)
                                                end
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                            end
                                            ALLSTAR.SafeRunNative(SetEntityCollision, ped, true, true)
                                            ALLSTAR.SafeRunNative(SetEntityInvincible, ped, false)
                                        end)
                                    ]])
                                else
                                    executeCode('any', [[ _G.NoCollision = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Anti-Drag", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('any', [[
                                        if AntiDrag == nil then AntiDrag = false end
                                        AntiDrag = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while AntiDrag do
                                                local ped = PlayerPedId()
                                                if ALLSTAR.SafeRunNative(IsEntityAttached, ped) then
                                                    ALLSTAR.SafeRunNative(DetachEntity, ped, true, false)
                                                end
                                                ALLSTAR.SafeRunNative(ClearPedSecondaryTask, ped)
                                                ALLSTAR.SafeRunNative(SetEnableHandcuffs, ped, false)
                                                ALLSTAR.SafeRunNative(FreezeEntityPosition, ped, false)
                                                ALLSTAR.SafeRunNative(Wait, 200)
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode('any', [[ AntiDrag = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Anti-Attach", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('any', [[
                                        _G.AntiAttach = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while _G.AntiAttach do
                                                ALLSTAR.SafeRunNative(Wait, 350)
                                                local ped = PlayerPedId()
                                                if DoesEntityExist(ped) then
                                                    if ALLSTAR.SafeRunNative(IsEntityAttachedToAnyObject, ped) or ALLSTAR.SafeRunNative(IsEntityAttachedToAnyVehicle, ped) or ALLSTAR.SafeRunNative(IsEntityAttachedToAnyPed, ped) then
                                                        ALLSTAR.SafeRunNative(DetachEntity, ped, true, false)
                                                    end
                                                end
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode('any', [[ _G.AntiAttach = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Passive Mode", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('any', [[
                                        _G.PassiveModeActive = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while _G.PassiveModeActive do
                                                ALLSTAR.SafeRunNative(SetPedConfigFlag, PlayerPedId(), 423, true)
                                                Wait(1000)
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode('any', [[
                                        _G.PassiveModeActive = false
                                        ALLSTAR.SafeRunNative(SetPedConfigFlag, PlayerPedId(), 423, false)
                                    ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Friendly Fire", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('any', [[
                                        local playerPed = PlayerPedId()
                                        ALLSTAR.SafeRunNative(NetworkSetFriendlyFireOption, true)
                                        ALLSTAR.SafeRunNative(SetCanAttackFriendly, playerPed, true, true)
                                        ALLSTAR.SafeRunNative(DisablePlayerFiring, playerPed, false)
                                        EnableAllControlActions(0)
                                        EnableAllControlActions(1)
                                        for _, playerId in ipairs(GetActivePlayers()) do
                                            local targetPed = GetPlayerPed(playerId)
                                            if targetPed ~= playerPed then
                                                ALLSTAR.SafeRunNative(SetPedConfigFlag, targetPed, 2, false)
                                                ALLSTAR.SafeRunNative(SetPedConfigFlag, targetPed, 423, false)
                                                ALLSTAR.SafeRunNative(SetPedConfigFlag, targetPed, 425, false)
                                                ALLSTAR.SafeRunNative(SetEntityInvincible, targetPed, false)
                                            end
                                        end
                                    ]])
                                else
                                    executeCode('any', [[
                                        local playerPed = PlayerPedId()
                                        ALLSTAR.SafeRunNative(NetworkSetFriendlyFireOption, false)
                                        ALLSTAR.SafeRunNative(SetCanAttackFriendly, playerPed, false, false)
                                    ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Infinite Stamina", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('monitor', [[
                                        infiniteStamina = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while infiniteStamina do
                                                ALLSTAR.SafeRunNative(ResetPlayerStamina, PlayerId())
                                                Wait(30)
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode('monitor', [[ infiniteStamina = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Super Punch", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('monitor', [[
                                        superPunch = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while superPunch do
                                                ALLSTAR.SafeRunNative(SetWeaponDamageModifier, GetHashKey('WEAPON_UNARMED'), 500.0)
                                                ALLSTAR.SafeRunNative(Wait, 0)
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode('monitor', [[ superPunch = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Fast Punch", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('monitor', [[
                                        _G.FastPunchEnabled = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while _G.FastPunchEnabled do
                                                Wait(750)
                                                local ped = PlayerPedId()
                                                if IsPedOnFoot(ped) and not IsPedInAnyVehicle(ped, false) and GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_UNARMED") then
                                                    if IsControlPressed(0, 24) or IsControlPressed(0, 257) then
                                                        Wait(750)
                                                        ClearPedTasksImmediately(ped)
                                                    end
                                                end
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode('monitor', [[ _G.FastPunchEnabled = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Auto Teleport To Waypoint", checked = false,
                            onSelect = function(checked)
                                _G.AutoTeleport = checked
                                if checked then
                                    CreateThread(function()
                                        while _G.AutoTeleport do
                                            if IsWaypointActive() then
                                                executeCode('monitor', [[ ALLSTAR.SafeRunNative(TriggerEvent, 'txcl:tpToWaypoint') ]])
                                                while IsWaypointActive() and _G.AutoTeleport do Wait(1000) end
                                            end
                                            Wait(500)
                                        end
                                    end)
                                end
                            end
                        },
                        { type = "checkbox", label = "Solo Session", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    MachoInjectResource2(AsThreadNs, 'any', [[
                                        if _G.AllstarSoloSessionThread then return end
                                        _G.AllstarSoloSessionThread = true
                                        NetworkStartSoloTutorialSession()
                                        _G.AllstarSoloSessionThread = CreateThread(function()
                                            while _G.AllstarSoloSessionThread do Wait(1000) end
                                            NetworkEndTutorialSession()
                                            _G.AllstarSoloSessionThread = nil
                                        end)
                                    ]])
                                else
                                    MachoInjectResource2(AsThreadNs, 'any', [[
                                        _G.AllstarSoloSessionThread = false
                                    ]])
                                end
                            end
                        },
                        { type = "divider", label = "txAdmin Options" },
                        { type = "checkbox", label = "txAdmin Player IDs", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    MachoInjectResource2(AsThreadNs, 'monitor', [[
                                        menuIsAccessible = true
                                        toggleShowPlayerIDs(true, true)
                                    ]])
                                else
                                    MachoInjectResource2(AsThreadNs, 'monitor', [[
                                        menuIsAccessible = true
                                        toggleShowPlayerIDs(false, true)
                                    ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "txAdmin Noclip", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('monitor', [[ ALLSTAR.SafeRunNative(TriggerEvent, "txcl:setPlayerMode", "noclip", true) ]])
                                else
                                    executeCode('monitor', [[ ALLSTAR.SafeRunNative(TriggerEvent, "txcl:setPlayerMode", "none", true) ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "txAdmin Godmode", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('monitor', [[ ALLSTAR.SafeRunNative(TriggerEvent, "txcl:setPlayerMode", "godmode", true) ]])
                                else
                                    executeCode('monitor', [[ ALLSTAR.SafeRunNative(TriggerEvent, "txcl:setPlayerMode", "none", true) ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "txAdmin SuperJump", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode('monitor', [[ ALLSTAR.SafeRunNative(TriggerEvent, "txcl:setPlayerMode", "superjump", true) ]])
                                else
                                    executeCode('monitor', [[ ALLSTAR.SafeRunNative(TriggerEvent, "txcl:setPlayerMode", "none", true) ]])
                                end
                            end
                        },
                        { icon = "", type = "button", label = "txAdmin Heal",
                            onSelect = function()
                                executeCode('monitor', [[ ALLSTAR.SafeRunNative(TriggerEvent, 'txcl:heal', -1) ]])
                            end
                        },
                        { label = 'txAdmin Teleport To Waypoint', type = 'button',
                            onSelect = function()
                                executeCode('monitor', [[ ALLSTAR.SafeRunNative(TriggerEvent, 'txcl:tpToWaypoint') ]])
                            end
                        },
                        { label = 'txAdmin Fix Vehicle', type = 'button',
                            onSelect = function()
                                executeCode('monitor', [[ ALLSTAR.SafeRunNative(TriggerEvent, 'txcl:vehicle:fix') ]])
                            end
                        }
                    }
                },
                {
                    label = "WARDROBE",
                    tabs = {
                        { icon = "", type = "scrollable", value = 1, values = { "Random" }, label = "Outfit", desc = "Apply a preset outfit",
                            onSelect = function(value)
                                if value == "Random" then
                                    executeCode("any", [[
                                        local ped = PlayerPedId()
                                        local function PqLoMzNkXjWvRu(component, exclude)
                                            local total = GetNumberOfPedDrawableVariations(ped, component)
                                            if total <= 1 then return 0 end
                                            local choice = exclude
                                            while choice == exclude do choice = math.random(0, total - 1) end
                                            return choice
                                        end
                                        SetPedComponentVariation(ped, 11, PqLoMzNkXjWvRu(11, 15), 0, 2)
                                        SetPedComponentVariation(ped, 6, PqLoMzNkXjWvRu(6, 15), 0, 2)
                                        SetPedComponentVariation(ped, 8, 15, 0, 2)
                                        SetPedComponentVariation(ped, 3, 0, 0, 2)
                                        SetPedComponentVariation(ped, 4, math.random(0, GetNumberOfPedDrawableVariations(ped, 4) - 1), 0, 2)
                                        local face = math.random(0, 45)
                                        local skin = math.random(0, 45)
                                        SetPedHeadBlendData(ped, face, skin, 0, face, skin, 0, 1.0, 1.0, 0.0, false)
                                        local hairMax = GetNumberOfPedDrawableVariations(ped, 2)
                                        SetPedComponentVariation(ped, 2, hairMax > 1 and math.random(0, hairMax - 1) or 0, 0, 2)
                                        SetPedHairColor(ped, 0, 0)
                                        local brows = GetNumHeadOverlayValues(2)
                                        SetPedHeadOverlay(ped, 2, brows > 1 and math.random(0, brows - 1) or 0, 1.0)
                                        SetPedHeadOverlayColor(ped, 2, 1, 0, 0)
                                        ClearPedProp(ped, 0)
                                        ClearPedProp(ped, 1)
                                    ]])
                                end
                            end
                        },
                        { type = "divider", label = "Ped Options" },
                        { type = "scrollable", label = "Freemode", scrollType = "onEnter", value = 1, values = { "Freemode Male", "Freemode Female" },
                            onSelect = function(value)
                                MachoInjectResourceRaw("any", ([[
                                    local selected = "%s"
                                    local pedModel = nil
                                    if selected == "Freemode Male" then pedModel = "mp_m_freemode_01"
                                    elseif selected == "Freemode Female" then pedModel = "mp_f_freemode_01" end
                                    if pedModel then
                                        local modelHash = GetHashKey(pedModel)
                                        RequestModel(modelHash)
                                        while not HasModelLoaded(modelHash) do Wait(0) end
                                        SetPlayerModel(PlayerId(), modelHash)
                                        SetModelAsNoLongerNeeded(modelHash)
                                        local playerPed = PlayerPedId()
                                        SetPedDefaultComponentVariation(playerPed)
                                        SetPedRandomComponentVariation(playerPed, true)
                                        SetPedRandomProps(playerPed)
                                        SetEntityInvincible(playerPed, false)
                                        ClearPedTasksImmediately(playerPed)
                                    end
                                ]]):format(value))
                            end
                        },
                        { icon = "", type = "button", label = "Clothing Menu V2", desc = "Open the illenium-appearance clothing editor",
                            onSelect = function()
                                if GetResourceState("illenium-appearance") ~= "started" then
                                    self:Notify("error", "PALABOY", "illenium-appearance is not running", 3500)
                                    return                                end
                                MachoInjectResource("illenium-appearance", [[
                                    local ok, err = pcall(function()
                                        if type(GetDefaultConfig) ~= "function" or type(OpenShop) ~= "function" then
                                            return
                                        end
                                        local config = GetDefaultConfig()
                                        config.components   = true
                                        config.props        = true
                                        config.ped          = true
                                        config.headBlend    = true
                                        config.faceFeatures = true
                                        config.headOverlays = true
                                        local useTattoos = true
                                        if rawget(_G, "Config") and type(Config) == "table"
                                            and Config.RCoreTattoosCompatibility ~= nil then
                                            useTattoos = not Config.RCoreTattoosCompatibility
                                        end
                                        config.tattoos = useTattoos
                                        OpenShop(config, true, "clothing")
                                    end)
                                    if not ok then
                                        print("[PALABOY] Clothing Menu V2 inject error: " .. tostring(err))
                                    end
                                ]])
                                self:Notify("success", "PALABOY", "Opening Clothing Menu V2", 2500)
                            end
                        },
                        { type = "divider", label = "Illenium Appearance" },
                        { icon = "", type = "scrollable", value = 1, values = { "Clothing Menu", "Save Outfit", "Reload Skin", "Barber Shop", "Tattoo Shop"}, label = "Appearance",
                            onSelect = function(value)
                                if value == "Clothing Menu" then
                                    if GetResourceState("ars_ambulancejob") == "started" then
                                        MachoInjectResource2(NewThreadNs, 'ars_ambulancejob', [[ openWardrobe() ]])
                                    elseif GetResourceState("cfx-praryo-groups") == "started" then
                                        executeCode('cfx-praryo-groups', [[ ALLSTAR.SafeRunNative(TriggerEvent, 'illenium-appearance:client:openOutfitMenuPraryo') ]])
                                    elseif GetResourceState("cfx-xfx-basicneeds") == "started" then
                                        executeCode('cfx-xfx-basicneeds', [[ ALLSTAR.SafeRunNative(TriggerEvent, 'illenium-appearance:client:xYy:openClothingShopMenu') ]])
                                    else
                                        executeCode('any', [[ ALLSTAR.SafeRunNative(TriggerEvent, 'illenium-appearance:client:openClothingShop', true) ]])
                                    end
                                elseif value == "Save Outfit" then
                                    executeCode('any', [[ ALLSTAR.SafeRunNative(TriggerEvent, 'illenium-appearance:client:saveOutfit') ]])
                                elseif value == "Reload Skin" then
                                    executeCode('any', [[ ALLSTAR.SafeRunNative(TriggerEvent, 'illenium-appearance:client:reloadSkin') ]])
                                elseif value == "Barber Shop" then
                                    executeCode('any', [[ ALLSTAR.SafeRunNative(TriggerEvent, 'illenium-appearance:client:OpenBarberShop', true) ]])
                                elseif value == "Tattoo Shop" then
                                    executeCode('any', [[ ALLSTAR.SafeRunNative(TriggerEvent, 'illenium-appearance:client:OpenTattooShop', true) ]])
                                end
                            end
                        }
                    }
                }
            }
        },
        {
            icon = "ph ph-user",
            label = "ONLINE OPTION",
            type = "subMenu",
            categories = {
                {
                    label = "LIST",
                    tabs = {
                        { type = "button", label = "Select Everyone" },
                        { type = "button", label = "Un-Select Everyone" },
                        { type = "button", label = "Clear Selection" },
                        { type = "divider", label = "Nearby Players" }
                    }
                },
                {
                    label = "SAFE",
                    tabs = {
                        { icon = "", type = "scrollable", value = 1, values = {"Player", "Vehicle"}, label = "Teleport", desc = 'Teleport to selected player',
                            onSelect = function(value)
                                local targetPlayers = {}
                                for serverId, checked in pairs(CPlayers) do
                                    if checked then targetPlayers[#targetPlayers + 1] = serverId end
                                end
                                if #targetPlayers == 0 then
                                    self:Notify("error", "PALABOY", "You must select a player to do this!", 3000)
                                    return
                                end
                                if value == "Player" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        local player = GetPlayerFromServerId(playerId)
                                        if player == -1 or not DoesEntityExist(GetPlayerPed(player)) then
                                            self:Notify("error", "PALABOY", "Teleport error (ERR:1)", 3000)
                                            CPlayers[playerId] = nil
                                            ALLSTAR:UpdateListMenu()
                                            return
                                        end
                                        executeCode('any', string.format([[
                                            local targetID = %d
                                            local targetPed = GetPlayerPed(GetPlayerFromServerId(targetID))
                                            local myPed = PlayerPedId()
                                            if DoesEntityExist(targetPed) then
                                                local coords = GetEntityCoords(targetPed)
                                                ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, coords.x, coords.y, coords.z, false, false, false)
                                            end
                                        ]], playerId))
                                        self:Notify("success", "PALABOY", ("Teleported to %s - [%s]!"):format(GetPlayerName(GetPlayerFromServerId(playerId)), playerId), 3000)
                                    end
                                elseif value == "Vehicle" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        local player = GetPlayerFromServerId(playerId)
                                        if player == -1 or not DoesEntityExist(GetPlayerPed(player)) then
                                            self:Notify("error", "PALABOY", "Teleport error (ERR:1)", 3000)
                                            CPlayers[playerId] = nil
                                            ALLSTAR:UpdateListMenu()
                                            return
                                        end
                                        local veh = GetVehiclePedIsIn(GetPlayerPed(player), 0)
                                        if IsVehicleSeatFree(veh, 0) then SetPedIntoVehicle(PlayerPedId(), veh, 0)
                                        elseif IsVehicleSeatFree(veh, 1) then SetPedIntoVehicle(PlayerPedId(), veh, 1)
                                        elseif IsVehicleSeatFree(veh, 2) then SetPedIntoVehicle(PlayerPedId(), veh, 2)
                                        elseif IsVehicleSeatFree(veh, 3) then SetPedIntoVehicle(PlayerPedId(), veh, 3)
                                        else self:Notify("error", "PALABOY", "No free seats in vehicle", 3000) end
                                    end
                                end
                            end
                        },
                        { type = "button", label = "Steal Outfit",
                            onSelect = function()
                                local targetPlayers = {}
                                for serverId, checked in pairs(CPlayers) do
                                    if checked then targetPlayers[#targetPlayers + 1] = serverId end
                                end
                                if #targetPlayers == 0 then
                                    self:Notify("error", "PALABOY", "You must select a player to do this!", 3000)
                                    return
                                end
                                local targetServerId = targetPlayers[1]
                                local function _b(str) local t = {} for i = 1, #str do t[i] = string.byte(str, i) end return t end
                                local function _d(tbl) local s = "" for i = 1, #tbl do s = s .. string.char(tbl[i]) end return s end
                                local function _g(n) return _G[_d(n)] end
                                local function findClientIdByServerId(sid)
                                    for _, pid in ipairs(_g(_b("GetActivePlayers"))()) do
                                        if _g(_b("GetPlayerServerId"))(pid) == sid then return pid end
                                    end
                                    return -1
                                end
                                local clientId = findClientIdByServerId(targetServerId)
                                if clientId ~= -1 then
                                    local targetPed = _g(_b("GetPlayerPed"))(clientId)
                                    local myPed = _g(_b("PlayerPedId"))()
                                    if _g(_b("DoesEntityExist"))(targetPed) and _g(_b("DoesEntityExist"))(myPed) then
                                        _g(_b("SetPedComponentVariation"))(myPed, 1, _g(_b("GetPedDrawableVariation"))(targetPed, 1), _g(_b("GetPedTextureVariation"))(targetPed, 1), 0)
                                        _g(_b("SetPedComponentVariation"))(myPed, 3, _g(_b("GetPedDrawableVariation"))(targetPed, 3), _g(_b("GetPedTextureVariation"))(targetPed, 3), 0)
                                        _g(_b("SetPedComponentVariation"))(myPed, 4, _g(_b("GetPedDrawableVariation"))(targetPed, 4), _g(_b("GetPedTextureVariation"))(targetPed, 4), 0)
                                        _g(_b("SetPedComponentVariation"))(myPed, 6, _g(_b("GetPedDrawableVariation"))(targetPed, 6), _g(_b("GetPedTextureVariation"))(targetPed, 6), 0)
                                        _g(_b("SetPedComponentVariation"))(myPed, 8, _g(_b("GetPedDrawableVariation"))(targetPed, 8), _g(_b("GetPedTextureVariation"))(targetPed, 8), 0)
                                        _g(_b("SetPedComponentVariation"))(myPed, 9, _g(_b("GetPedDrawableVariation"))(targetPed, 9), _g(_b("GetPedTextureVariation"))(targetPed, 9), 0)
                                        _g(_b("SetPedComponentVariation"))(myPed, 10, _g(_b("GetPedDrawableVariation"))(targetPed, 10), _g(_b("GetPedTextureVariation"))(targetPed, 10), 0)
                                        _g(_b("SetPedComponentVariation"))(myPed, 11, _g(_b("GetPedDrawableVariation"))(targetPed, 11), _g(_b("GetPedTextureVariation"))(targetPed, 11), 0)
                                        _g(_b("SetPedPropIndex"))(myPed, 0, _g(_b("GetPedPropIndex"))(targetPed, 0), _g(_b("GetPedPropTextureIndex"))(targetPed, 0), true)
                                        _g(_b("SetPedPropIndex"))(myPed, 1, _g(_b("GetPedPropIndex"))(targetPed, 1), _g(_b("GetPedPropTextureIndex"))(targetPed, 1), true)
                                        _g(_b("SetPedPropIndex"))(myPed, 2, _g(_b("GetPedPropIndex"))(targetPed, 2), _g(_b("GetPedPropTextureIndex"))(targetPed, 2), true)
                                    end
                                end
                                self:Notify("success", "PALABOY", "Copied clothing!", 5000)
                            end
                        },
                        { icon = "", type = "scrollable", value = 1, values = {"Method 1", "Method 2"}, label = "Kill Player",
                            onSelect = function(value)
                                local targetPlayers = {}
                                for serverId, checked in pairs(CPlayers) do
                                    if checked then targetPlayers[#targetPlayers + 1] = serverId end
                                end
                                if #targetPlayers == 0 then
                                    self:Notify("error", "PALABOY", "You must select a player to do this!", 3000)
                                    return
                                end
                                if value == "Method 1" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode("any", string.format([[
                                            ALLSTAR.SafeRunNative(CreateThread, function()
                                                local weaponName = 'vehicle_weapon_subcar_mg'
                                                local ammoAmount = 999
                                                local targetSid = %d
                                                local weapon = GetHashKey(weaponName)
                                                RequestWeaponAsset(weapon, 31, 26)
                                                while not HasWeaponAssetLoaded(weapon) do Wait(0) end
                                                local selfPed = PlayerPedId()
                                                ALLSTAR.SafeRunNative(GiveDelayedWeaponToPed, selfPed, weapon, ammoAmount, true)
                                                ALLSTAR.SafeRunNative(SetPedAmmo, selfPed, weapon, ammoAmount)
                                                local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSid))
                                                if DoesEntityExist(targetPed) and not IsPedDeadOrDying(targetPed, true) then
                                                    local targetCoords = GetEntityCoords(targetPed)
                                                    local fromCoords = targetCoords + vec3(0.0, 0.0, 0.1)
                                                    ALLSTAR.SafeRunNative(ShootSingleBulletBetweenCoords, fromCoords.x, fromCoords.y, fromCoords.z, targetCoords.x, targetCoords.y, targetCoords.z, 999999, true, weapon, selfPed, true, false, 999999.0)
                                                    ALLSTAR.SafeRunNative(SetPedUsingActionMode, selfPed, true, -1, 1)
                                                    ALLSTAR.SafeRunNative(SetPedCurrentWeaponVisible, selfPed, false, false, true, true)
                                                end
                                                ALLSTAR.SafeRunNative(SetPedUsingActionMode, selfPed, false, -1, 'DEFAULT_ACTION')
                                                ALLSTAR.SafeRunNative(RemoveWeaponFromPed, selfPed, weapon)
                                                ALLSTAR.SafeRunNative(SetCurrentPedWeapon, selfPed, 'weapon_unarmed', true)
                                            end)
                                        ]], playerId))
                                    end
                                elseif value == "Method 2" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode("any", string.format([[
                                            local weaponName = 'weapon_appistol'
                                            local ammoAmount = 999
                                            local targetSid = %d
                                            ALLSTAR.SafeRunNative(CreateThread, function()
                                                local weapon = GetHashKey(weaponName)
                                                RequestWeaponAsset(weapon, 31, 26)
                                                while not HasWeaponAssetLoaded(weapon) do Wait(0) end
                                                local selfPed = PlayerPedId()
                                                ALLSTAR.SafeRunNative(GiveDelayedWeaponToPed, selfPed, weapon, ammoAmount, true)
                                                ALLSTAR.SafeRunNative(SetPedAmmo, selfPed, weapon, ammoAmount)
                                                local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSid))
                                                if DoesEntityExist(targetPed) and not IsPedDeadOrDying(targetPed, true) then
                                                    local targetCoords = GetEntityCoords(targetPed)
                                                    local fromCoords = targetCoords + vec3(0.0, 0.0, 0.1)
                                                    ALLSTAR.SafeRunNative(ShootSingleBulletBetweenCoords, fromCoords.x, fromCoords.y, fromCoords.z, targetCoords.x, targetCoords.y, targetCoords.z, 999999, true, weapon, selfPed, true, false, 999999.0)
                                                    ALLSTAR.SafeRunNative(SetPedUsingActionMode, selfPed, true, -1, 1)
                                                    ALLSTAR.SafeRunNative(SetPedCurrentWeaponVisible, selfPed, false, false, true, true)
                                                end
                                                ALLSTAR.SafeRunNative(SetPedUsingActionMode, selfPed, false, -1, 'DEFAULT_ACTION')
                                                ALLSTAR.SafeRunNative(RemoveWeaponFromPed, selfPed, weapon)
                                                ALLSTAR.SafeRunNative(SetCurrentPedWeapon, selfPed, 'weapon_unarmed', true)
                                            end)
                                        ]], playerId))
                                    end
                                end
                            end
                        },
                        { type = "button", label = "Ragdoll Player",
                            onSelect = function()
                                local targetPlayers = {}
                                for serverId, checked in pairs(CPlayers) do
                                    if checked then targetPlayers[#targetPlayers + 1] = serverId end
                                end
                                if #targetPlayers == 0 then
                                    self:Notify("error", "PALABOY", "You must select a player to do this!", 3000)
                                    return
                                end
                                local targetID = tonumber(targetPlayers[1])
                                executeCode("any", string.format([[
                                    local targetSid = %d
                                    local weapon = 'weapon_snowball'
                                    ALLSTAR.SafeRunNative(CreateThread, function()
                                        RequestWeaponAsset(weapon, 31, 26)
                                        while not HasWeaponAssetLoaded(weapon) do Wait(0) end
                                        local selfPed = PlayerPedId()
                                        local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSid))
                                        if DoesEntityExist(targetPed) and not IsPedDeadOrDying(targetPed, true) then
                                            local boneTarget = GetPedBoneCoords(targetPed, 31086, 0.0, 0.0, 0.0)
                                            local fromCoords = boneTarget + vec3(0.0, 0.0, 0.1)
                                            local forward = GetEntityForwardVector(targetPed)
                                            ALLSTAR.SafeRunNative(ShootSingleBulletBetweenCoords, fromCoords.x, fromCoords.y, fromCoords.z, boneTarget.x, boneTarget.y, boneTarget.z, 0, true, weapon, selfPed, false, true, 0.0)
                                            ALLSTAR.SafeRunNative(SetPedUsingActionMode, selfPed, true, -1, 1)
                                            ALLSTAR.SafeRunNative(SetPedCurrentWeaponVisible, selfPed, false, false, true, true)
                                            ALLSTAR.SafeRunNative(SetPedCanRagdoll, targetPed, true)
                                            ALLSTAR.SafeRunNative(SetPedToRagdoll, targetPed, 3000, 3000, 0, true, true, false)
                                            ALLSTAR.SafeRunNative(ApplyForceToEntity, targetPed, 1, -forward.x * 5.0, -forward.y * 5.0, 0.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
                                        end
                                        ALLSTAR.SafeRunNative(SetPedUsingActionMode, selfPed, false, -1, 'DEFAULT_ACTION')
                                        ALLSTAR.SafeRunNative(RemoveWeaponFromPed, selfPed, weapon)
                                        ALLSTAR.SafeRunNative(SetCurrentPedWeapon, selfPed, 'weapon_unarmed', true)
                                    end)
                                ]], targetID))
                                self:Notify("success", "PALABOY", "Ragdolled ID: " .. targetID, 3000)
                            end
                        },
                        { icon = "", type = "scrollable", value = 1, values = { "Method 1", "Method 2", "Method 3", "Method 4" }, label = "Launch Player", desc = 'This will attempt to launch the player into the sky',
                            onSelect = function(value)
                                local targetPlayers = {}
                                for serverId, checked in pairs(CPlayers) do
                                    if checked then
                                        targetPlayers[#targetPlayers + 1] = serverId
                                    end
                                end
                                if #targetPlayers == 0 then
                                    self:Notify("error", "PALABOY", "You must select a player to do this!", 3000)
                                    return
                                end
                                if value == "Method 1" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode(targetRes, [[
                                            ALLSTAR.SafeRunNative(CreateThread, function()
                                                local targetId = tonumber(]] .. playerId .. [[)
                                                local targetPlayer = GetPlayerFromServerId(targetId)
                                                if targetPlayer == -1 then return end
                                                local ped = GetPlayerPed(targetPlayer)
                                                if not ALLSTAR.SafeRunNative(DoesEntityExist, ped) then return end

                                                local model = joaat("bmx")
                                                ALLSTAR.SafeRunNative(RequestModel, model)
                                                while not ALLSTAR.SafeRunNative(HasModelLoaded, model) do ALLSTAR.SafeRunNative(Wait, 0) end
                                                local coords = GetEntityCoords(ped)
                                                local obj = ALLSTAR.SafeRunNative(CreateObject, model, coords.x, coords.y, coords.z - 5.0, true, true, false)
                                                if not ALLSTAR.SafeRunNative(DoesEntityExist, obj) then return end
                                                ALLSTAR.SafeRunNative(SetEntityVisible, obj, false, false)
                                                ALLSTAR.SafeRunNative(SetEntityInvincible, obj, true)
                                                ALLSTAR.SafeRunNative(FreezeEntityPosition, obj, false)
                                                ALLSTAR.SafeRunNative(AttachEntityToEntityPhysically,
                                                    obj,
                                                    ped,
                                                    -1e38,
                                                    1e26,
                                                    0,
                                                    1e38,
                                                    -1e38,
                                                    800990.0,
                                                    19980.0,
                                                    1e26,
                                                    99999.0,
                                                    true,
                                                    true,
                                                    false,
                                                    false,
                                                    0
                                                )

                                                for i = 1, 20 do
                                                    if ALLSTAR.SafeRunNative(DoesEntityExist, obj) then
                                                        ALLSTAR.SafeRunNative(SetEntityVelocity, obj, 0.0, 0.0, 500.0 + (i * 50.0))
                                                        ALLSTAR.SafeRunNative(Wait, 10)
                                                    end
                                                end

                                                ALLSTAR.SafeRunNative(Wait, 100)
                                                ALLSTAR.SafeRunNative(DeleteEntity, obj)
                                                ALLSTAR.SafeRunNative(SetModelAsNoLongerNeeded, model)
                                            end)
                                        ]])
                                    end
                                    self:Notify("success", "PALABOY", "Launching Target...", 3000)
                                elseif value == "Method 2" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode(targetRes, [[
                                            ALLSTAR.SafeRunNative(CreateThread, function()
                                                local targetId = tonumber(]] .. playerId .. [[)
                                                local targetPlayer = GetPlayerFromServerId(targetId)
                                                if targetPlayer == -1 then return end
                                                local me = GetPlayerPed(targetPlayer)
                                                if not ALLSTAR.SafeRunNative(DoesEntityExist, me) then return end

                                                local models = {joaat("adder"), joaat("bmx"), joaat("adder")}
                                                for _, m in ipairs(models) do
                                                    ALLSTAR.SafeRunNative(RequestModel, m)
                                                    while not ALLSTAR.SafeRunNative(HasModelLoaded, m) do ALLSTAR.SafeRunNative(Wait, 0) end
                                                end

                                                local function spawnAndYeet(modelName, forceZ, offsetMult)
                                                    local coords = GetEntityCoords(ped)
                                                    local obj = ALLSTAR.SafeRunNative(CreateObject, modelName, coords.x, coords.y, coords.z - 10.0, true, true, false)
                                                    if not ALLSTAR.SafeRunNative(DoesEntityExist, obj) then return end
                                                    ALLSTAR.SafeRunNative(SetEntityVisible, obj, false, false)
                                                    ALLSTAR.SafeRunNative(SetEntityInvincible, obj, true)
                                                    ALLSTAR.SafeRunNative(FreezeEntityPosition, obj, false)

                                                    ALLSTAR.SafeRunNative(AttachEntityToEntityPhysically,
                                                        obj, me, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                                                        9999999.0, 9999999.0, 9999999.0, 25.0, 106.0, 900.0,
                                                        true, true, true, false, 0
                                                    )

                                                    for i = 1, 1500 do
                                                        if ALLSTAR.SafeRunNative(DoesEntityExist, obj) and ALLSTAR.SafeRunNative(DoesEntityExist, me) then
                                                            ALLSTAR.SafeRunNative(SetEntityCollision, me, false, false)
                                                            ALLSTAR.SafeRunNative(SetEntityVelocity, obj, 0.0, 0.0, 99999.0)
                                                            ALLSTAR.SafeRunNative(SetEntityVelocity, me, 0.0, 0.0, 99999.0)

                                                            local cur = GetEntityCoords(me)
                                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, me, cur.x, cur.y, cur.z + (500.0 * offsetMult), false, false, false)
                                                            ALLSTAR.SafeRunNative(Wait, 0)
                                                        end
                                                    end
                                                    ALLSTAR.SafeRunNative(DeleteEntity, obj)
                                                end

                                                spawnAndYeet(models[1], 50000000.0, 100)
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                                spawnAndYeet(models[2], 80000000.0, 150)
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                                spawnAndYeet(models[3], 999990999.0, 200)

                                                ALLSTAR.SafeRunNative(SetEntityCollision, me, true, true)
                                                for _, m in ipairs(models) do
                                                    ALLSTAR.SafeRunNative(SetModelAsNoLongerNeeded, m)
                                                end
                                            end)
                                        ]])
                                    end
                                    self:Notify("success", "PALABOY", "Launch V2 Engaged", 3000)
                                elseif value == "Method 3" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        if IsDetections then
                                            self:Notify("info", "PALABOY", "Security detected Method disabled.", 3000)
                                        else
                                            executeCode(targetSafeRes, string.format([[
                                                local targetSid = %d
                                                local function GetPlayerFromServerId(serverId)
                                                    for _, player in ipairs(GetActivePlayers()) do
                                                        if GetPlayerServerId(player) == serverId then
                                                            return player
                                                        end
                                                    end
                                                    return nil
                                                end

                                                ALLSTAR.SafeRunNative(CreateThread, function()
                                                    local clientId = GetPlayerFromServerId(targetSid)
                                                    if not clientId then return end

                                                    local selected_ped = GetPlayerPed(clientId)
                                                    if not selected_ped or not IsEntityAPed(selected_ped) or selected_ped == PlayerPedId() then
                                                        return
                                                    end

                                                    local d = GetEntityCoords(PlayerPedId())
                                                    local selected_coords = GetEntityCoords(selected_ped)
                                                    local nearestVehicle = GetClosestVehicle(selected_coords.x, selected_coords.y, selected_coords.z, 100.0, 0, 71)

                                                    if not DoesEntityExist(nearestVehicle) then return end
                                                    ALLSTAR.SafeRunNative(Wait, 1000)
                                                    ALLSTAR.SafeRunNative(SetPedIntoVehicle, PlayerPedId(), nearestVehicle, -1)

                                                    local timer = GetGameTimer() + 1300
                                                    while (not ALLSTAR.SafeRunNative(NetworkHasControlOfEntity, nearestVehicle)) and GetGameTimer() < timer do
                                                        ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, nearestVehicle)
                                                        ALLSTAR.SafeRunNative(Wait, 1)
                                                    end

                                                    ALLSTAR.SafeRunNative(AttachEntityToEntityPhysically,
                                                        nearestVehicle,
                                                        selected_ped,
                                                        -1e38,
                                                        1e26,
                                                        0,
                                                        1e38,
                                                        -1e38,
                                                        800990.0,
                                                        19980.0,
                                                        1e26,
                                                        99999.0,
                                                        true,
                                                        true,
                                                        false,
                                                        false,
                                                        0
                                                    )

                                                    ALLSTAR.SafeRunNative(ClearPedTasks, PlayerPedId())
                                                    ALLSTAR.SafeRunNative(SetEntityVisible, PlayerPedId(), true, true)
                                                    ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, PlayerPedId(), d.x, d.y, d.z, true, true, false)
                                                    ALLSTAR.SafeRunNative(Wait, 1)
                                                end)
                                            ]], playerId))
                                        end
                                    end
                                    self:Notify("success", "PALABOY", "Launch V3 Engaged", 3000)
                                elseif value == "Method 4" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        if IsDetections then
                                            self:Notify("info", "PALABOY", "Security detected Method disabled.", 3000)
                                        else
                                            MachoInjectResourceRaw(targetSafeRes, string.format([[
                                                local function SafeWrap(fn)
                                                    return function(...) return fn(...) end
                                                end

                                                local SafeThread = SafeWrap(CreateThread)
                                                local SafeWait = SafeWrap(Citizen.Wait)
                                                local SafePlayerPedId = SafeWrap(PlayerPedId)
                                                local SafeDoesEntityExist = SafeWrap(DoesEntityExist)
                                                local SafeGetEntityCoords = SafeWrap(GetEntityCoords)
                                                local SafeSetEntityVisible = SafeWrap(SetEntityVisible)
                                                local SafeSetEntityInvincible = SafeWrap(SetEntityInvincible)
                                                local SafeSetEntityCollision = SafeWrap(SetEntityCollision)
                                                local SafeAttachEntityToEntityPhysically = SafeWrap(AttachEntityToEntityPhysically)
                                                local SafeDetachEntity = SafeWrap(DetachEntity)
                                                local SafeDeleteEntity = SafeWrap(DeleteEntity)
                                                local SafeSetEntityCoords = SafeWrap(SetEntityCoords)
                                                local SafeGetHashKey = SafeWrap(GetHashKey)
                                                local SafeRequestModel = SafeWrap(RequestModel)
                                                local SafeHasModelLoaded = SafeWrap(HasModelLoaded)
                                                local SafeCVehicle = SafeWrap(CreateVehicle)

                                                local function loadVehicleModel(model)
                                                    local modelHash = SafeGetHashKey(model)
                                                    SafeRequestModel(modelHash)
                                                    while not SafeHasModelLoaded(modelHash) do
                                                        SafeWait(0)
                                                    end
                                                    return modelHash
                                                end

                                                SafeThread(function()
                                                    local playerPed = SafePlayerPedId()
                                                    local playerCoords = SafeGetEntityCoords(playerPed)
                                                    local targetId = %d
                                                    local targetPlayer = GetPlayerFromServerId(targetId)
                                                    if targetPlayer == -1 then return end
                                                    local targetPed = GetPlayerPed(targetPlayer)
                                                    if not SafeDoesEntityExist(targetPed) then return end

                                                    local vehModel = "bmx"
                                                    local vehHash = loadVehicleModel(vehModel)

                                                    local ghostVeh = SafeCVehicle(vehHash, playerCoords.x, playerCoords.y, playerCoords.z - 5.0, 0.0, true, false)
                                                    if not SafeDoesEntityExist(ghostVeh) then return end

                                                    SafeSetEntityVisible(ghostVeh, false, 0)
                                                    SafeSetEntityInvincible(ghostVeh, true)
                                                    SafeSetEntityCollision(ghostVeh, false, false)

                                                    local _, groundZ = GetGroundZFor_3dCoord(playerCoords.x, playerCoords.y, playerCoords.z, 0)
                                                    local skyHeight = (groundZ or playerCoords.z) + 1500.0

                                                    SafeSetEntityCoords(ghostVeh, playerCoords.x, playerCoords.y, skyHeight, false, false, false, false)

                                                    SafeAttachEntityToEntityPhysically(
                                                        ghostVeh,
                                                        targetPed,
                                                        0, 0, 0,
                                                        0.0, 0.0, 0.0,
                                                        0.0, 0.0, 300.0,
                                                        true, true, true, false, 0
                                                    )

                                                    SafeWait(500)

                                                    SafeDetachEntity(ghostVeh, true, true)
                                                    SafeDeleteEntity(ghostVeh)

                                                    SafeSetEntityCoords(targetPed, playerCoords.x, playerCoords.y, skyHeight + 50.0, false, false, false, false)
                                                end)
                                            ]], playerId))
                                        end
                                    end
                                    self:Notify("success", "PALABOY", "Launch V4 Engaged", 3000)
                                end
                            end
                        },
                        { icon = "", type = "scrollable", value = 1, values = { "Air", "Chiliad", "Vinewood", "Maze Bank", "Death", "Agency Bunker", "Record A Bunker", "Meth Bunker", "After Hours Bunker", "Tunnel Bunker", "Waypoint", "Bring Target" }, label = "Bring Player", desc = 'This will attempt to bring player into specific location.',
                            onSelect = function(value)
                                local targetPlayers = {}
                                for serverId, checked in pairs(CPlayers) do
                                    if checked then
                                        targetPlayers[#targetPlayers + 1] = serverId
                                    end
                                end
                                if #targetPlayers == 0 then
                                    self:Notify("error", "PALABOY", "You must select a player to do this!", 3000)
                                    return
                                end
                                if value == "Air" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode(targetSafeRes, string.format([[
                                            local targetId = %d
                                            local cmd = "carry"
                                            local myPed = PlayerPedId()
                                            local originalCoords = GetEntityCoords(myPed)

                                            local targetIdx = GetPlayerFromServerId(targetId)
                                            if targetIdx == -1 then return end
                                            local targetPed = GetPlayerPed(targetIdx)

                                            if not ALLSTAR.SafeRunNative(DoesEntityExist, targetPed) then return end

                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityAlpha, myPed, 0, false)

                                            local currentPos = GetEntityCoords(targetPed)
                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, currentPos.x, currentPos.y, currentPos.z - 1.3, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 50)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            local highZ = currentPos.z + 700.0
                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, currentPos.x, currentPos.y, highZ, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                            local timeout = 0
                                            while not ALLSTAR.SafeRunNative(NetworkHasControlOfEntity, targetPed) and timeout < 30 do
                                                ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                                timeout = timeout + 1
                                            end

                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, true)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(DetachEntity, targetPed, true, true)
                                            ALLSTAR.SafeRunNative(DetachEntity, myPed, true, true)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, targetPed)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 300)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, true, false)
                                            ALLSTAR.SafeRunNative(ResetEntityAlpha, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 200)
                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, false)
                                        ]], playerId))
                                    end
                                    self:Notify("success", "PALABOY", "Successfully bring the player into Air.", 3000)
                                elseif value == "Chiliad" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode(targetSafeRes, string.format([[
                                            local targetId = %d
                                            local cmd = "carry"
                                            local myPed = PlayerPedId()
                                            local originalCoords = GetEntityCoords(myPed)
                                            local destX, destY, destZ = 450.0, 5580.0, 800.0

                                            local targetIdx = GetPlayerFromServerId(targetId)
                                            if targetIdx == -1 then return end
                                            local targetPed = GetPlayerPed(targetIdx)

                                            if not ALLSTAR.SafeRunNative(DoesEntityExist, targetPed) then return end

                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityAlpha, myPed, 0, false)

                                            local currentPos = GetEntityCoords(targetPed)
                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, currentPos.x, currentPos.y, currentPos.z - 1.3, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 50)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, destX, destY, destZ, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                            local timeout = 0
                                            while not ALLSTAR.SafeRunNative(NetworkHasControlOfEntity, targetPed) and timeout < 30 do
                                                ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                                timeout = timeout + 1
                                            end

                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, true)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(DetachEntity, targetPed, true, true)
                                            ALLSTAR.SafeRunNative(DetachEntity, myPed, true, true)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, targetPed)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 300)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, true, false)
                                            ALLSTAR.SafeRunNative(ResetEntityAlpha, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 200)
                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, false)
                                        ]], playerId))
                                    end
                                    self:Notify("success", "PALABOY", "Successfully bring the player into Chiliad.", 3000)
                                elseif value == "Vinewood" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode(targetSafeRes, string.format([[
                                            local targetId = %d
                                            local cmd = "carry"
                                            local myPed = PlayerPedId()
                                            local originalCoords = GetEntityCoords(myPed)
                                            local destX, destY, destZ = 742.40, 1271.51, 383.17

                                            local targetIdx = GetPlayerFromServerId(targetId)
                                            if targetIdx == -1 then return end
                                            local targetPed = GetPlayerPed(targetIdx)

                                            if not ALLSTAR.SafeRunNative(DoesEntityExist, targetPed) then return end

                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityAlpha, myPed, 0, false)

                                            local currentPos = GetEntityCoords(targetPed)
                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, currentPos.x, currentPos.y, currentPos.z - 1.3, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 50)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, destX, destY, destZ, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                            local timeout = 0
                                            while not ALLSTAR.SafeRunNative(NetworkHasControlOfEntity, targetPed) and timeout < 30 do
                                                ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                                timeout = timeout + 1
                                            end

                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, true)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(DetachEntity, targetPed, true, true)
                                            ALLSTAR.SafeRunNative(DetachEntity, myPed, true, true)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, targetPed)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 300)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, true, false)
                                            ALLSTAR.SafeRunNative(ResetEntityAlpha, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 200)
                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, false)
                                        ]], playerId))
                                    end
                                    self:Notify("success", "PALABOY", "Successfully bring the player into Vinewood.", 3000)
                                elseif value == "Maze Bank" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode(targetSafeRes, string.format([[
                                            local targetId = %d
                                            local cmd = "carry"
                                            local myPed = PlayerPedId()
                                            local originalCoords = GetEntityCoords(myPed)
                                            local destX, destY, destZ = -75.28, -818.84, 326.17

                                            local targetIdx = GetPlayerFromServerId(targetId)
                                            if targetIdx == -1 then return end
                                            local targetPed = GetPlayerPed(targetIdx)

                                            if not ALLSTAR.SafeRunNative(DoesEntityExist, targetPed) then return end

                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityAlpha, myPed, 0, false)

                                            local currentPos = GetEntityCoords(targetPed)
                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, currentPos.x, currentPos.y, currentPos.z - 1.3, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 50)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, destX, destY, destZ, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                            local timeout = 0
                                            while not ALLSTAR.SafeRunNative(NetworkHasControlOfEntity, targetPed) and timeout < 30 do
                                                ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                                timeout = timeout + 1
                                            end

                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, true)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(DetachEntity, targetPed, true, true)
                                            ALLSTAR.SafeRunNative(DetachEntity, myPed, true, true)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, targetPed)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 300)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, true, false)
                                            ALLSTAR.SafeRunNative(ResetEntityAlpha, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 200)
                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, false)
                                        ]], playerId))
                                    end
                                    self:Notify("success", "PALABOY", "Successfully bring the player into Maze Bank.", 3000)
                                elseif value == "Death" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode("any", string.format([[
                                            local targetId = %d
                                            local cmd = "carry"
                                            local myPed = PlayerPedId()
                                            local originalCoords = GetEntityCoords(myPed)
                                            local destX, destY, destZ = -75.28, -818.84, 326.17

                                            local targetIdx = GetPlayerFromServerId(targetId)
                                            if targetIdx == -1 then return end
                                            local targetPed = GetPlayerPed(targetIdx)

                                            if not ALLSTAR.SafeRunNative(DoesEntityExist, targetPed) then return end

                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityAlpha, myPed, 0, false)

                                            local currentPos = GetEntityCoords(targetPed)
                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, currentPos.x, currentPos.y, currentPos.z - 1.3, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 50)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, currentPos.x, currentPos.y,  2500.0, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                            local timeout = 0
                                            while not ALLSTAR.SafeRunNative(NetworkHasControlOfEntity, targetPed) and timeout < 30 do
                                                ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                                timeout = timeout + 1
                                            end

                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, true)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(DetachEntity, targetPed, true, true)
                                            ALLSTAR.SafeRunNative(DetachEntity, myPed, true, true)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, targetPed)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 300)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, true, false)
                                            ALLSTAR.SafeRunNative(ResetEntityAlpha, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 200)
                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, false)
                                        ]], playerId))
                                    end
                                    self:Notify("success", "PALABOY", "Successfully bring the player into Death.", 3000)
                                elseif value == "Agency Bunker" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode("any", string.format([[
                                            local targetId = %d
                                            local cmd = "carry"
                                            local myPed = PlayerPedId()
                                            local originalCoords = GetEntityCoords(myPed)
                                            local destX, destY, destZ = -1111.999, -76.620, -91.379

                                            local targetIdx = GetPlayerFromServerId(targetId)
                                            if targetIdx == -1 then return end
                                            local targetPed = GetPlayerPed(targetIdx)

                                            if not ALLSTAR.SafeRunNative(DoesEntityExist, targetPed) then return end

                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityAlpha, myPed, 0, false)

                                            local currentPos = GetEntityCoords(targetPed)
                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, currentPos.x, currentPos.y, currentPos.z - 1.3, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 50)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, destX, destY, destZ, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                            local timeout = 0
                                            while not ALLSTAR.SafeRunNative(NetworkHasControlOfEntity, targetPed) and timeout < 30 do
                                                ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                                timeout = timeout + 1
                                            end

                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, true)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(DetachEntity, targetPed, true, true)
                                            ALLSTAR.SafeRunNative(DetachEntity, myPed, true, true)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, targetPed)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 300)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, true, false)
                                            ALLSTAR.SafeRunNative(ResetEntityAlpha, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 200)
                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, false)
                                        ]], playerId))
                                    end
                                    self:Notify("success", "PALABOY", "Successfully bring the player into Agency Bunker.", 3000)
                                elseif value == "Record A Bunker" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode("any", string.format([[
                                            local targetId = %d
                                            local cmd = "carry"
                                            local myPed = PlayerPedId()
                                            local originalCoords = GetEntityCoords(myPed)
                                            local destX, destY, destZ = -1010.791, -64.487, -100.403

                                            local targetIdx = GetPlayerFromServerId(targetId)
                                            if targetIdx == -1 then return end
                                            local targetPed = GetPlayerPed(targetIdx)

                                            if not ALLSTAR.SafeRunNative(DoesEntityExist, targetPed) then return end

                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityAlpha, myPed, 0, false)

                                            local currentPos = GetEntityCoords(targetPed)
                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, currentPos.x, currentPos.y, currentPos.z - 1.3, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 50)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, destX, destY, destZ, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                            local timeout = 0
                                            while not ALLSTAR.SafeRunNative(NetworkHasControlOfEntity, targetPed) and timeout < 30 do
                                                ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                                timeout = timeout + 1
                                            end

                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, true)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(DetachEntity, targetPed, true, true)
                                            ALLSTAR.SafeRunNative(DetachEntity, myPed, true, true)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, targetPed)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 300)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, true, false)
                                            ALLSTAR.SafeRunNative(ResetEntityAlpha, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 200)
                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, false)
                                        ]], playerId))
                                    end
                                    self:Notify("success", "PALABOY", "Successfully bring the player into Record A Bunker.", 3000)
                                elseif value == "Meth Bunker" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode("any", string.format([[
                                            local targetId = %d
                                            local cmd = "carry"
                                            local myPed = PlayerPedId()
                                            local originalCoords = GetEntityCoords(myPed)
                                            local destX, destY, destZ = 1009.630, -3197.849, -38.996

                                            local targetIdx = GetPlayerFromServerId(targetId)
                                            if targetIdx == -1 then return end
                                            local targetPed = GetPlayerPed(targetIdx)

                                            if not ALLSTAR.SafeRunNative(DoesEntityExist, targetPed) then return end

                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityAlpha, myPed, 0, false)

                                            local currentPos = GetEntityCoords(targetPed)
                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, currentPos.x, currentPos.y, currentPos.z - 1.3, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 50)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, destX, destY, destZ, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                            local timeout = 0
                                            while not ALLSTAR.SafeRunNative(NetworkHasControlOfEntity, targetPed) and timeout < 30 do
                                                ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                                timeout = timeout + 1
                                            end

                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, true)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(DetachEntity, targetPed, true, true)
                                            ALLSTAR.SafeRunNative(DetachEntity, myPed, true, true)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, targetPed)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 300)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, true, false)
                                            ALLSTAR.SafeRunNative(ResetEntityAlpha, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 200)
                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, false)
                                        ]], playerId))
                                    end
                                    self:Notify("success", "PALABOY", "Successfully bring the player into Meth Bunker.", 3000)
                                elseif value == "After Hours Bunker" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode("any", string.format([[
                                            local targetId = %d
                                            local cmd = "carry"
                                            local myPed = PlayerPedId()
                                            local originalCoords = GetEntityCoords(myPed)
                                            local destX, destY, destZ = -1604.664, -3012.583, -78.000

                                            local targetIdx = GetPlayerFromServerId(targetId)
                                            if targetIdx == -1 then return end
                                            local targetPed = GetPlayerPed(targetIdx)

                                            if not ALLSTAR.SafeRunNative(DoesEntityExist, targetPed) then return end

                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityAlpha, myPed, 0, false)

                                            local currentPos = GetEntityCoords(targetPed)
                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, currentPos.x, currentPos.y, currentPos.z - 1.3, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 50)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, destX, destY, destZ, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                            local timeout = 0
                                            while not ALLSTAR.SafeRunNative(NetworkHasControlOfEntity, targetPed) and timeout < 30 do
                                                ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                                timeout = timeout + 1
                                            end

                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, true)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(DetachEntity, targetPed, true, true)
                                            ALLSTAR.SafeRunNative(DetachEntity, myPed, true, true)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, targetPed)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 300)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, true, false)
                                            ALLSTAR.SafeRunNative(ResetEntityAlpha, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 200)
                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, false)
                                        ]], playerId))
                                    end
                                    self:Notify("success", "PALABOY", "Successfully bring the player into After Hours Bunker.", 3000)
                                elseif value == "Tunnel Bunker" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode("any", string.format([[
                                            local targetId = %d
                                            local cmd = "carry"
                                            local myPed = PlayerPedId()
                                            local originalCoords = GetEntityCoords(myPed)
                                            local destX, destY, destZ = 1256.11, 4796.48, -39.05

                                            local targetIdx = GetPlayerFromServerId(targetId)
                                            if targetIdx == -1 then return end
                                            local targetPed = GetPlayerPed(targetIdx)

                                            if not ALLSTAR.SafeRunNative(DoesEntityExist, targetPed) then return end

                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityAlpha, myPed, 0, false)

                                            local currentPos = GetEntityCoords(targetPed)
                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, currentPos.x, currentPos.y, currentPos.z - 1.3, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 50)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, destX, destY, destZ, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                            local timeout = 0
                                            while not ALLSTAR.SafeRunNative(NetworkHasControlOfEntity, targetPed) and timeout < 30 do
                                                ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                                timeout = timeout + 1
                                            end

                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, true)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(DetachEntity, targetPed, true, true)
                                            ALLSTAR.SafeRunNative(DetachEntity, myPed, true, true)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, targetPed)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 300)

                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, true, false)
                                            ALLSTAR.SafeRunNative(ResetEntityAlpha, myPed)

                                            ALLSTAR.SafeRunNative(Wait, 200)
                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, false)
                                        ]], playerId))
                                    end
                                    self:Notify("success", "PALABOY", "Successfully bring the player into Tunnel Bunker.", 3000)
                                elseif value == "Waypoint" then
                                    if not IsWaypointActive() then
                                        self:Notify("error", "PALABOY", "You must set a waypoint on the map first!", 3000)
                                        return
                                    end
                                    local waypointBlip = GetFirstBlipInfoId(8)
                                    local waypointCoords = GetBlipInfoIdCoord(waypointBlip)
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode(targetSafeRes, string.format([[
                                            local myPed = PlayerPedId()
                                            local sid = %d
                                            local player = GetPlayerFromServerId(sid)
                                            local targetPed = GetPlayerPed(player)

                                            if DoesEntityExist(targetPed) then
                                                local originalCoords = GetEntityCoords(myPed)
                                                local destX, destY = %f, %f
                                                local targetCoords = GetEntityCoords(targetPed)
                                                local foundGround, groundZ = GetGroundZFor_3dCoord(destX, destY, 800.0, 0)
                                                if not foundGround then groundZ = 0.0 end

                                                ALLSTAR.SafeRunNative(ClearPedTasksImmediately, myPed)
                                                ALLSTAR.SafeRunNative(SetEntityVisible, myPed, false, false)
                                                ALLSTAR.SafeRunNative(SetEntityCollision, myPed, false, false)
                                                ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, targetCoords.x, targetCoords.y, targetCoords.z, false, false, false)
                                                ALLSTAR.SafeRunNative(Wait, 250)
                                                ALLSTAR.SafeRunNative(ExecuteCommand, "carry")
                                                ALLSTAR.SafeRunNative(Wait, 250)
                                                ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, destX, destY, groundZ + 2.0, false, false, false)
                                                ALLSTAR.SafeRunNative(Wait, 250)
                                                ALLSTAR.SafeRunNative(ExecuteCommand, "carry")
                                                ALLSTAR.SafeRunNative(Wait, 250)
                                                ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
                                                ALLSTAR.SafeRunNative(SetEntityCollision, myPed, true, true)
                                                ALLSTAR.SafeRunNative(SetEntityVisible, myPed, true, false)
                                            end
                                        ]], playerId, waypointCoords.x, waypointCoords.y))
                                    end
                                    self:Notify("success", "PALABOY", "Sent players to your Waypoint!", 3000)
                                elseif value == "Bring Target" then
                                    for _, playerId in ipairs(targetPlayers) do
                                        executeCode(targetSafeRes, string.format([[
                                            local targetId = %d
                                            local cmd = "carry"
                                            local myPed = PlayerPedId()
                                            local originalCoords = GetEntityCoords(myPed)

                                            local targetIdx = GetPlayerFromServerId(targetId)
                                            if targetIdx == -1 then return end
                                            local targetPed = GetPlayerPed(targetIdx)

                                            if not ALLSTAR.SafeRunNative(DoesEntityExist, targetPed) then return end

                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityAlpha, myPed, 0, false)

                                            local currentPos = GetEntityCoords(targetPed)
                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, currentPos.x, currentPos.y, currentPos.z - 1.3, false, false, false)
                                            ALLSTAR.SafeRunNative(Wait, 50)

                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(Wait, 100)

                                            ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                            local timeout = 0
                                            while not ALLSTAR.SafeRunNative(NetworkHasControlOfEntity, targetPed) and timeout < 30 do
                                                ALLSTAR.SafeRunNative(NetworkRequestControlOfEntity, targetPed)
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                                timeout = timeout + 1
                                            end

                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, true)
                                            ALLSTAR.SafeRunNative(Wait, 300)
                                            ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, myPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
                                            ALLSTAR.SafeRunNative(SetEntityVisible, myPed, true, false)
                                            ALLSTAR.SafeRunNative(ResetEntityAlpha, myPed)
                                            ALLSTAR.SafeRunNative(Wait, 200)
                                            ALLSTAR.SafeRunNative(ExecuteCommand, cmd)
                                            ALLSTAR.SafeRunNative(DetachEntity, targetPed, true, true)
                                            ALLSTAR.SafeRunNative(DetachEntity, myPed, true, true)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, targetPed)
                                            ALLSTAR.SafeRunNative(ClearPedTasksImmediately, myPed)
                                            ALLSTAR.SafeRunNative(Wait, 200)
                                            ALLSTAR.SafeRunNative(FreezeEntityPosition, targetPed, false)
                                        ]], playerId))
                                    end
                                    self:Notify("success", "PALABOY", "Successfully bring the target to you.", 3000)
                                end
                            end
                        },
                        { type = "scrollable", label = "Kill Player NPC", scrollType = "onEnter", value = 1, values = {"Pistol", "Pistol.50", "Sniper Rifle"},
                            onSelect = function(value)
                                local targetPlayers = {}
                                for serverId, isSelected in pairs(CPlayers) do
                                    if isSelected then targetPlayers[#targetPlayers + 1] = serverId end
                                end
                                if #targetPlayers == 0 then
                                    self:Notify("error", "PALABOY", "You must select a player to do this!", 3000)
                                    return
                                end
                                local weaponMap = {
                                    ["Pistol"] = "weapon_pistol",
                                    ["Pistol.50"] = "weapon_pistol50",
                                    ["Sniper Rifle"] = "weapon_sniperrifle"
                                }
                                local weaponHash = weaponMap[value]
                                local targetID = tonumber(targetPlayers[1])
                                MachoInjectResource(targetSafeRes, ([[
                                    local targetPed = GetPlayerPed(GetPlayerFromServerId(%d))
                                    local npcModel = "mp_m_freemode_01"
                                    local theWeapon = "%s"
                                    local coords = GetEntityCoords(targetPed)

                                    RequestModel(npcModel)
                                    while not HasModelLoaded(npcModel) do
                                        Wait(0)
                                    end

                                    local npcPed = CreatePed(4, GetHashKey(npcModel), coords.x + 10, coords.y, coords.z, 0.0, true, true)

                                    if DoesEntityExist(npcPed) then
                                        SetPedCanRagdoll(npcPed, false)
                                        FreezeEntityPosition(npcPed, true)
                                        GiveWeaponToPed(npcPed, GetHashKey(theWeapon), 250, false, true)
                                        SetWeaponDamageModifier(GetHashKey(theWeapon), 1000.0)
                                        SetPedCombatAttributes(npcPed, 5, true)
                                        SetPedCombatRange(npcPed, 2)
                                        SetPedCombatMovement(npcPed, 3)
                                        TaskCombatPed(npcPed, playerPed, 0, 16)
                                        local headBone = GetPedBoneIndex(targetPed, 31086)
                                        local targetCoords = GetPedBoneCoords(targetPed, headBone, 0.0, 0.0, 0.0)
                                        TaskShootAtCoord(npcPed, targetCoords.x, targetCoords.y, targetCoords.z, 1000, GetHashKey("FIRING_PATTERN_SINGLE_SHOT"))
                                        Wait(1000)
                                        DeleteEntity(npcPed)
                                    end

                                    SetModelAsNoLongerNeeded(GetHashKey(npcModel))
                                ]]):format(targetID, weaponHash))
                                self:Notify("success", "PALABOY", "Successfully Kill Player NPC", 3000)
                            end
                        },
                        { type = "divider", label = "Toggles" },
                        { type = "checkbox", label = "Spectate Player", checked = false,
                            onSelect = function(checked)
                                local targetPlayers = {}
                                for serverId, isSelected in pairs(CPlayers) do
                                    if isSelected then targetPlayers[#targetPlayers + 1] = serverId end
                                end
                                if #targetPlayers == 0 then
                                    self:Notify("error", "PALABOY", "You must select a player to do this!", 3000)
                                    return
                                end
                                local targetID = tonumber(targetPlayers[1])
                                if checked then
                                    executeCode('any', string.format([[
                                        _G.__SpectateRunning = true
                                        local tgtPed = GetPlayerPed(GetPlayerFromServerId(%d))
                                        local cam = ALLSTAR.SafeRunNative(CreateCam, "DEFAULT_SCRIPTED_CAMERA", true)
                                        _G.__SpectateCam = cam
                                        ALLSTAR.SafeRunNative(SetCamActive, cam, true)
                                        ALLSTAR.SafeRunNative(RenderScriptCams, true, false, 0, true, false)
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            local distanceBehind = 3.0
                                            local baseHeight = 1.0
                                            while _G.__SpectateRunning and tgtPed and DoesEntityExist(tgtPed) do
                                                Wait(1)
                                                local coords = GetEntityCoords(tgtPed)
                                                ALLSTAR.SafeRunNative(RequestAdditionalCollisionAtCoord, coords.x, coords.y, coords.z)
                                                ALLSTAR.SafeRunNative(SetFocusPosAndVel, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
                                                local camRot = ALLSTAR.SafeRunNative(GetGameplayCamRot, 0)
                                                local pitch = -math.rad(camRot.x)
                                                local heading = math.rad(camRot.z)
                                                local offsetX = -math.sin(heading) * math.cos(pitch) * distanceBehind
                                                local offsetY = math.cos(heading) * math.cos(pitch) * distanceBehind
                                                local offsetZ = math.sin(pitch) * distanceBehind
                                                ALLSTAR.SafeRunNative(SetCamCoord, cam, coords.x + offsetX, coords.y + offsetY, coords.z + baseHeight + offsetZ)
                                                ALLSTAR.SafeRunNative(PointCamAtEntity, cam, tgtPed, 0.0, 0.0, 0.8, true)
                                                tgtPed = GetPlayerPed(GetPlayerFromServerId(%d))
                                            end
                                            ClearFocus()
                                            ALLSTAR.SafeRunNative(RenderScriptCams, false, false, 0, true, false)
                                            ALLSTAR.SafeRunNative(DestroyCam, cam, false)
                                            _G.__SpectateCam = nil
                                        end)
                                    ]], targetID, targetID))
                                else
                                    executeCode('any', [[
                                        _G.__SpectateRunning = false
                                        if _G.__SpectateCam then
                                            ClearFocus()
                                            ALLSTAR.SafeRunNative(RenderScriptCams, false, false, 0, true, false)
                                            ALLSTAR.SafeRunNative(DestroyCam, _G.__SpectateCam, false)
                                            _G.__SpectateCam = nil
                                        end
                                    ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Black Hole", checked = false, desc = 'Attracts all nearby vehicles to the selected player.',
                            onSelect = function(checked)
                                local targetPlayer = nil
                                for serverId, isChecked in pairs(CPlayers) do
                                    if isChecked then targetPlayer = serverId break end
                                end
                                if checked and not targetPlayer then
                                    self:Notify("error", "PALABOY", "You must select a player to do this!", 3000)
                                    return false
                                end
                                self:ToggleBlackHole(checked, targetPlayer)
                            end
                        },

                    }
                },

                {
                    label = "RISKY",
                    tabs = {
                        { type = "button", label = "Clone Player",
                            onSelect = function()
                                local targetPlayers = {}
                                for serverId, checked in pairs(CPlayers) do
                                    if checked then targetPlayers[#targetPlayers + 1] = serverId end
                                end
                                if #targetPlayers == 0 then
                                    self:Notify("error", "PALABOY", "You must select a player to do this!", 3000)
                                    return
                                end
                                self:HandleClonePlayer(targetPlayers)
                                self:Notify("success", "PALABOY", "Cloned Player", 5000)
                            end
                        },
                        { type = "button", label = "Attack Clone Player",
                            onSelect = function()
                                local targetPlayers = {}
                                for serverId, checked in pairs(CPlayers) do
                                    if checked then targetPlayers[#targetPlayers + 1] = serverId end
                                end
                                if #targetPlayers == 0 then
                                    self:Notify("error", "PALABOY", "You must select a player to do this!", 3000)
                                    return
                                end
                                self:HandleAttackClonePlayer(targetPlayers)
                                self:Notify("success", "PALABOY", "Cloned Player", 5000)
                            end
                        }
                    }
                },
                {
                    label = "VEHICLE",
                    tabs = {
                        { icon = "", type = "scrollable", value = 1, values = { "Kick From Vehicle", "Bring Vehicle", "Freeze Vehicle", "Destroy Vehicle", "Delete Vehicle", "Steal Vehicle", "Remove Vehicle Tires" }, label = "Vehicle Troll",
                            onSelect = function(value)
                                local targetPlayer = nil
                                for serverId, checked in pairs(CPlayers) do
                                    if checked then targetPlayer = serverId break end
                                end
                                if not targetPlayer then
                                    self:Notify("error", "PALABOY", "You must select a player to do this!", 3000)
                                    return
                                end
                                local player = GetPlayerFromServerId(targetPlayer)
                                if player == -1 then
                                    self:Notify("error", "PALABOY", "Kick error (ERR:1)", 3000)
                                    CPlayers[targetPlayer] = nil
                                    ALLSTAR:UpdateListMenu()
                                    return
                                end
                                if not DoesEntityExist(GetVehiclePedIsUsing(GetPlayerPed(player))) then
                                    self:Notify("error", "PALABOY", "Kick error (ERR:2)", 3000)
                                    return
                                end
                                if value == "Kick From Vehicle" then
                                    executeCode(targetRes, string.format([[
                                        local playerId = GetPlayerFromServerId(%d)
                                        if playerId and playerId ~= -1 then
                                            local targetPed = GetPlayerPed(playerId)
                                            if DoesEntityExist(targetPed) then
                                                local vehicle = GetVehiclePedIsIn(targetPed, false)
                                                if vehicle and vehicle > 0 then
                                                    local selfPed = PlayerPedId()
                                                    local selfData = { coords = GetEntityCoords(selfPed), heading = GetEntityHeading(selfPed) }
                                                    ALLSTAR.SafeRunNative(TaskWarpPedIntoVehicle, selfPed, vehicle, -1)
                                                    Wait(50)
                                                    ALLSTAR.SafeRunNative(ClearPedTasksImmediately, selfPed)
                                                    ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, selfPed, selfData.coords.x, selfData.coords.y, selfData.coords.z, false, false, true)
                                                    ALLSTAR.SafeRunNative(SetEntityHeading, selfPed, selfData.heading)
                                                end
                                            end
                                        end
                                    ]], targetPlayer))
                                    CPlayers[targetPlayer] = true
                                    self:UpdateListMenu()
                                elseif value == "Freeze Vehicle" then
                                    executeCode(targetRes, string.format([[
                                        local playerId = GetPlayerFromServerId(%d)
                                        if playerId and playerId ~= -1 then
                                            local targetPed = GetPlayerPed(playerId)
                                            local vehicle = GetVehiclePedIsIn(targetPed, false)
                                            if vehicle and vehicle > 0 then
                                                ALLSTAR.SafeRunNative(FreezeEntityPosition, vehicle, true)
                                            end
                                        end
                                    ]], targetPlayer))
                                    CPlayers[targetPlayer] = true
                                    self:UpdateListMenu()
                                elseif value == "Destroy Vehicle" then
                                    executeCode(targetRes, string.format([[
                                        local playerId = GetPlayerFromServerId(%d)
                                        if playerId and playerId ~= -1 then
                                            local targetPed = GetPlayerPed(playerId)
                                            local vehicle = GetVehiclePedIsIn(targetPed, false)
                                            if vehicle and vehicle > 0 then
                                                ALLSTAR.SafeRunNative(SetVehicleEngineHealth, vehicle, -4000)
                                                ALLSTAR.SafeRunNative(SetVehicleBodyHealth, vehicle, -4000)
                                            end
                                        end
                                    ]], targetPlayer))
                                    CPlayers[targetPlayer] = true
                                    self:UpdateListMenu()
                                elseif value == "Delete Vehicle" then
                                    executeCode(targetRes, string.format([[
                                        local playerId = GetPlayerFromServerId(%d)
                                        if playerId and playerId ~= -1 then
                                            local targetPed = GetPlayerPed(playerId)
                                            local vehicle = GetVehiclePedIsIn(targetPed, false)
                                            if vehicle and vehicle > 0 then
                                                ALLSTAR.SafeRunNative(DeleteEntity, vehicle)
                                            end
                                        end
                                    ]], targetPlayer))
                                    CPlayers[targetPlayer] = true
                                    self:UpdateListMenu()
                                elseif value == "Steal Vehicle" then
                                    executeCode(targetRes, string.format([[
                                        local playerId = GetPlayerFromServerId(%d)
                                        if playerId and playerId ~= -1 then
                                            local targetPed = GetPlayerPed(playerId)
                                            local vehicle = GetVehiclePedIsIn(targetPed, false)
                                            if vehicle and vehicle > 0 then
                                                ALLSTAR.SafeRunNative(TaskWarpPedIntoVehicle, PlayerPedId(), vehicle, -1)
                                            end
                                        end
                                    ]], targetPlayer))
                                    CPlayers[targetPlayer] = true
                                    self:UpdateListMenu()
                                elseif value == "Remove Vehicle Tires" then
                                    executeCode(targetRes, string.format([[
                                        local playerId = GetPlayerFromServerId(%d)
                                        if playerId and playerId ~= -1 then
                                            local targetPed = GetPlayerPed(playerId)
                                            local vehicle = GetVehiclePedIsIn(targetPed, false)
                                            if vehicle and vehicle > 0 then
                                                for i = 0, 7 do
                                                    ALLSTAR.SafeRunNative(BreakOffVehicleWheel, vehicle, i, true, false, false, false)
                                                end
                                            end
                                        end
                                    ]], targetPlayer))
                                    CPlayers[targetPlayer] = true
                                    self:UpdateListMenu()
                                end
                            end
                        },
                        { type = "button", label = "Vehicle Ram",
                            onSelect = function()
                                local targetPlayer = nil
                                for serverId, checked in pairs(CPlayers) do
                                    if checked then targetPlayer = serverId break end
                                end
                                if targetPlayer then
                                    MachoInjectResource(targetRes, string.format([[
                                        local playerId = GetPlayerFromServerId(%d)
                                        if playerId and playerId ~= -1 then
                                            local targetPed = GetPlayerPed(playerId)
                                            if DoesEntityExist(targetPed) then
                                                local targetCoords = GetEntityCoords(targetPed)
                                                local model = GetHashKey("sultan")
                                                RequestModel(model)
                                                while not HasModelLoaded(model) do Wait(0) end
                                                local spawnCoords = GetOffsetFromEntityInWorldCoords(targetPed, 0.0, -15.0, 0.0)
                                                local veh = CreateVehicle(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false)
                                                SetEntityVisible(veh, true, true)
                                                SetVehicleEngineOn(veh, true, true, false)
                                                SetVehicleForwardSpeed(veh, 0.0)
                                                local heading = GetHeadingFromVector_2d(targetCoords.x - spawnCoords.x, targetCoords.y - spawnCoords.y)
                                                SetEntityHeading(veh, heading)
                                                Wait(200)
                                                SetVehicleForwardSpeed(veh, 80.0)
                                                SetVehicleEnginePowerMultiplier(veh, 100.0)
                                                SetVehicleEngineTorqueMultiplier(veh, 3.0)
                                                Wait(2000)
                                                DeleteEntity(veh)
                                            end
                                        end
                                    ]], targetPlayer))
                                    self:Notify("success", "PALABOY", ("Vehicle ram launched at %s!"):format(GetPlayerName(GetPlayerFromServerId(targetPlayer))), 3000)
                                else
                                    self:Notify("error", "PALABOY", "You must select a player to do this!", 3000)
                                end
                            end
                        }
                    }
                }
            }
        },
        {
            icon = "ph-bold ph-rocket-launch",
            label = "WEAPON OPTION",
            type = "subMenu",
            categories = {
                {
                    label = "SPAWNER",
                    tabs = {
                        { type = "button", label = "Give Weapon",
                            onSelect = function()
                                KeyboardInput("Weapon Name", "WEAPON_", function(val)
                                    if val and val ~= "" then self:SpawnSelectedWeapon(val) end
                                end, "typeable")
                            end
                        },
                        { type = "button", label = "Clear Weapons",
                            onSelect = function()
                                executeCode('any', [[
                                    local selfPed = PlayerPedId()
                                    ALLSTAR.SafeRunNative(RemoveAllPedWeapons, selfPed, true)
                                    ALLSTAR.SafeRunNative(GiveWeaponToPed, selfPed, 'weapon_unarmed', false, true)
                                ]])
                            end
                        },
                        { type = "divider", label = "All Weapons" },
                        { type = "scrollable", label = "Melee", scrollType = "onEnter", value = 1, values = self:BuildMenuFromWeaponList({ "weapon_unarmed","weapon_knife","weapon_dagger","weapon_bat","weapon_bottle","weapon_crowbar","weapon_golfclub","weapon_hammer","weapon_hatchet","weapon_machete","weapon_switchblade","weapon_nightstick","weapon_wrench" }),
                            onSelect = function(value) self:SpawnSelectedWeapon(self:GetWeaponModelFromLabel(value)) end
                        },
                        { type = "scrollable", label = "Handguns", scrollType = "onEnter", value = 1, values = self:BuildMenuFromWeaponList({ "weapon_pistol","weapon_pistol_mk2","weapon_combatpistol","weapon_appistol","weapon_stungun","weapon_pistol50","weapon_snspistol","weapon_heavypistol","weapon_vintagepistol","weapon_flaregun" }),
                            onSelect = function(value) self:SpawnSelectedWeapon(self:GetWeaponModelFromLabel(value)) end
                        },
                        { type = "scrollable", label = "SMGs", scrollType = "onEnter", value = 1, values = self:BuildMenuFromWeaponList({ "weapon_microsmg","weapon_smg","weapon_smg_mk2","weapon_assaultsmg","weapon_machinepistol","weapon_minismg","weapon_combatpdw" }),
                            onSelect = function(value) self:SpawnSelectedWeapon(self:GetWeaponModelFromLabel(value)) end
                        },
                        { type = "scrollable", label = "Rifles", scrollType = "onEnter", value = 1, values = self:BuildMenuFromWeaponList({ "weapon_assaultrifle","weapon_assaultrifle_mk2","weapon_carbinerifle","weapon_carbinerifle_mk2","weapon_advancedrifle","weapon_specialcarbine","weapon_bullpuprifle","weapon_bullpuprifle_mk2","weapon_compactrifle","weapon_marksmanrifle" }),
                            onSelect = function(value) self:SpawnSelectedWeapon(self:GetWeaponModelFromLabel(value)) end
                        },
                        { type = "scrollable", label = "Shotguns", scrollType = "onEnter", value = 1, values = self:BuildMenuFromWeaponList({ "weapon_pumpshotgun","weapon_pumpshotgun_mk2","weapon_sawnoffshotgun","weapon_assaultshotgun","weapon_bullpupshotgun","weapon_heavyshotgun","weapon_autoshotgun" }),
                            onSelect = function(value) self:SpawnSelectedWeapon(self:GetWeaponModelFromLabel(value)) end
                        },
                        { type = "scrollable", label = "Snipers", scrollType = "onEnter", value = 1, values = self:BuildMenuFromWeaponList({ "weapon_sniperrifle","weapon_heavysniper","weapon_heavysniper_mk2","weapon_marksmanrifle_mk2" }),
                            onSelect = function(value) self:SpawnSelectedWeapon(self:GetWeaponModelFromLabel(value)) end
                        },
                        { type = "scrollable", label = "Explosives", scrollType = "onEnter", value = 1, values = self:BuildMenuFromWeaponList({ "weapon_grenade","weapon_stickybomb","weapon_molotov","weapon_pipebomb","weapon_proxmine","weapon_rpg","weapon_grenadelauncher","weapon_hominglauncher","weapon_minigun","weapon_railgun" }),
                            onSelect = function(value) self:SpawnSelectedWeapon(self:GetWeaponModelFromLabel(value)) end
                        }
                    }
                },
                {
                    label = "COMBAT",
                    tabs = {
                        { type = "scrollable", label = "Attachments", value = 1, values = { "Suppressor", "Magazine", "Flashlight", "Scopes", "Grip" },
                            onSelect = function(value)
                                if value == "Suppressor" then
                                    MachoInjectResourceRaw("ox_inventory", [[
                                        local ped = PlayerPedId()
                                        local w = GetSelectedPedWeapon(ped)
                                        local comps = {0x65EA7EBB,0x837445AA,0xA73D4664,0xC304849A,0xE608B35E,0xC6654D78,0x448892A,0x3CC6BD52}
                                        for _, c in ipairs(comps) do if DoesWeaponTakeWeaponComponent(w, c) then GiveWeaponComponentToPed(ped, w, c) end end
                                    ]])
                                elseif value == "Magazine" then
                                    MachoInjectResourceRaw("ox_inventory", [[
                                        local ped = PlayerPedId()
                                        local w = GetSelectedPedWeapon(ped)
                                        local comps = {0xED265A1C,0xD67B4F2D,0x249A17D5,0xD9D3AC92,0x7B0033B3,0x64F9C62B,0xCE8C0772,0x5ED6C128,0x33BA12E8,0x81786CA9,0x10E6BA2B,0x350966FB,0xBB46E417,0x937ED0B7,0xB9835B2E,0xB92C6979,0x334A5203,0x82158B86,0xB16A3CD}
                                        for _, c in ipairs(comps) do if DoesWeaponTakeWeaponComponent(w, c) then GiveWeaponComponentToPed(ped, w, c) end end
                                    ]])
                                elseif value == "Flashlight" then
                                    MachoInjectResourceRaw("ox_inventory", [[
                                        local ped = PlayerPedId()
                                        local w = GetSelectedPedWeapon(ped)
                                        local comps = {0x7BC4CD10,0x43FD5F0E,0xC7AE6C97,0xA196D98C}
                                        for _, c in ipairs(comps) do if DoesWeaponTakeWeaponComponent(w, c) then GiveWeaponComponentToPed(ped, w, c) end end
                                    ]])
                                elseif value == "Scopes" then
                                    MachoInjectResourceRaw("ox_inventory", [[
                                        local ped = PlayerPedId()
                                        local w = GetSelectedPedWeapon(ped)
                                        local comps = {0xC2CC3929,0x9D2FBA71,0xA27457FC,0x5F333923,0xC16479C7,0x3CC6BD52,0x1621AD14,0x435976C4}
                                        for _, c in ipairs(comps) do if DoesWeaponTakeWeaponComponent(w, c) then GiveWeaponComponentToPed(ped, w, c) end end
                                    ]])
                                elseif value == "Grip" then
                                    MachoInjectResourceRaw("ox_inventory", [[
                                        local ped = PlayerPedId()
                                        local w = GetSelectedPedWeapon(ped)
                                        local comps = {0xC7086851,0xE5264706}
                                        for _, c in ipairs(comps) do if DoesWeaponTakeWeaponComponent(w, c) then GiveWeaponComponentToPed(ped, w, c) end end
                                    ]])
                                end
                            end
                        },
                        { type = "slider", label = "Refill Ammo", desc = "Ammo refill into current weapon.", scrollType = "onEnter", value = 1, min = 1, max = 300, step = 1.0,
                            onSelect = function(value)
                                MachoInjectResourceRaw("ox_inventory", [[
                                    local ped = PlayerPedId()
                                    local found, w = GetCurrentPedWeapon(ped, true)
                                    if found and w ~= GetHashKey("WEAPON_UNARMED") then
                                        SetPedAmmo(ped, w, ]] .. math.floor(value) .. [[)
                                    end
                                ]])
                            end
                        },
                        { type = "checkbox", label = "Infinite Ammo", checked = false,
                            onSelect = function(checked) if checked then self:EnableInfiniteAmmo(checked) end end
                        },
                        { type = "checkbox", label = "Anti-Headshot", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    MachoInjectResourceRaw('any', [[
                                        local bp = setmetatable({}, { __index = function(_, k)
                                            local v = _G[k]
                                            return type(v) == "function" and function(...) return v(...) end or v
                                        end })
                                        _G.AntiHeadshot = true
                                        CreateThread(function()
                                            local lastHealth = bp.GetEntityHealth(bp.PlayerPedId())
                                            while _G.AntiHeadshot do
                                                local ped = bp.PlayerPedId()
                                                bp.SetPedSuffersCriticalHits(ped, false)
                                                local health = bp.GetEntityHealth(ped)
                                                local _, bone = bp.GetPedLastDamageBone(ped)
                                                if bone == 31086 and health < lastHealth then
                                                    bp.SetEntityHealth(ped, lastHealth)
                                                    bp.ClearPedLastDamageBone(ped)
                                                else
                                                    lastHealth = health
                                                end
                                                Wait(0)
                                            end
                                        end)
                                    ]])
                                else
                                    MachoInjectResourceRaw('any', [[
                                        _G.AntiHeadshot = false
                                        SetPedSuffersCriticalHits(PlayerPedId(), true)
                                    ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Ignore Max Range", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    MachoInjectResourceRaw(targetRes, [[
                                        _G.IgnoreMaxActive = true
                                        Citizen.CreateThread(function()
                                            while _G.IgnoreMaxActive do
                                                Wait(0)
                                                SetPedResetFlag(PlayerPedId(), 95, GetMaxRangeOfCurrentPedWeapon(PlayerPedId()) < 250.0)
                                            end
                                        end)
                                    ]])
                                else
                                    MachoInjectResourceRaw(targetRes, [[ _G.IgnoreMaxActive = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "No Recoil", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    MachoInjectResourceRaw(targetRes, [[
                                        _G.NoRecoilActive = true
                                        Citizen.CreateThread(function()
                                            while _G.NoRecoilActive do
                                                Wait(0)
                                                local cam = GetRenderingCam()
                                                StopGameplayCamShaking(true)
                                                StopCamShaking(cam, true)
                                                ShakeGameplayCam = function() return 1 end
                                            end
                                        end)
                                    ]])
                                else
                                    MachoInjectResourceRaw(targetRes, [[ _G.NoRecoilActive = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "No Aim Blocking", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode(targetRes, [[
                                        _G.NoAimActive = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while _G.NoAimActive do
                                                ALLSTAR.SafeRunNative(SetWeaponsNoAimBlocking, true)
                                                Wait(1000)
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode(targetRes, [[
                                        _G.NoAimActive = false
                                        ALLSTAR.SafeRunNative(SetWeaponsNoAimBlocking, false)
                                    ]])
                                end
                            end
                        }
                    }
                }
            }
        },
        {
            icon = "ph ph-car",
            label = "VEHICLE OPTION",
            type = "subMenu",
            categories = {
                {
                    label = "SPAWNER",
                    tabs = {
                        { type = "button", label = "Scan Vehicle Addon's",
                            onSelect = function()
                                MachoInjectResourceRaw(targetSafeRes, [[
                                    Citizen.CreateThread(function()
                                        Citizen.Wait(500)
                                        local vehicleNames = {}
                                        local foundVehicles = 0
                                        local targetFiles = {'vehicles.meta','carvariations.meta','handling.meta','vehiclelayouts.meta'}
                                        for i = 0, GetNumResources() - 1 do
                                            local resourceName = GetResourceByFindIndex(i)
                                            if resourceName and GetResourceState(resourceName) == 'started' then
                                                for _, targetFile in ipairs(targetFiles) do
                                                    local fileContent = LoadResourceFile(resourceName, targetFile)
                                                    if fileContent then
                                                        for modelName in fileContent:gmatch('<modelName>([^<]+)</modelName>') do
                                                            vehicleNames[modelName:lower()] = true
                                                            foundVehicles = foundVehicles + 1
                                                        end
                                                        for modelName in fileContent:gmatch('<handlingName>([^<]+)</handlingName>') do
                                                            vehicleNames[modelName:lower()] = true
                                                            foundVehicles = foundVehicles + 1
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        print('^2=== CUSTOM VEHICLES ===^0')
                                        if next(vehicleNames) then
                                            local sorted = {}
                                            for name in pairs(vehicleNames) do sorted[#sorted+1] = name end
                                            table.sort(sorted)
                                            print(string.format('^3Found: %d^0', #sorted))
                                            for _, name in ipairs(sorted) do print(string.format('^7    %s^0', name)) end
                                        else
                                            print('^1    None found^0')
                                        end
                                    end)
                                ]])
                            end
                        },
                        { type = "button", label = "Addon",
                            onSelect = function()
                                KeyboardInput("Addon Vehicle", "", function(val)
                                    if val and val ~= "" then self:SpawnSelectedVehicle(val) end
                                end, "typeable")
                            end
                        },
                        { type = "scrollable", label = "Sedans", scrollType = "onEnter", value = 1, values = { "asea","asterope","cog55","cog552","cognoscenti","cognoscenti2","deity","emperor","emperor2","emperor3","fugitive","glendale","glendale2","ingot","intruder","limo2","premier","primo","primo2","regina","schafter2","schafter5","schafter6","stafford","stanier","stratum","stretch","superd","surge","tailgater","tailgater2","warrener","warrener2","washington" },
                            onSelect = function(selected) self:SpawnSelectedVehicle(selected) end
                        },
                        { type = "scrollable", label = "SUVs", scrollType = "onEnter", value = 1, values = { "astron","baller","baller2","baller3","baller4","baller5","baller6","baller7","baller8","bjxl","cavalcade","cavalcade2","cavalcade3","contender","dubsta","dubsta2","fq2","granger","granger2","gresley","habanero","huntley","iwagen","jubilee","landstalker","landstalker2","mesa","mesa2","novak","patriot","patriot2","radi","rebla","rocoto","seminole","seminole2","serrano","squaddie","toros","xls","xls2" },
                            onSelect = function(selected) self:SpawnSelectedVehicle(selected) end
                        },
                        { type = "scrollable", label = "Coupes", scrollType = "onEnter", value = 1, values = { "cogcabrio","exemplar","f620","felon","felon2","jackal","oracle","oracle2","previon","sentinel","sentinel2","windsor","windsor2","zion","zion2" },
                            onSelect = function(selected) self:SpawnSelectedVehicle(selected) end
                        },
                        { type = "scrollable", label = "Muscles", scrollType = "onEnter", value = 1, values = { "blade","brigham","broadway","buccaneer","buccaneer2","buffalo4","chino","chino2","clique","clique2","coquette3","deviant","dominator","dominator2","dominator3","dominator4","dominator5","dominator6","dominator7","dominator8","dominator9","dukes","dukes2","dukes3","ellie","eudora","faction","faction2","faction3","gauntlet","gauntlet2","gauntlet3","gauntlet4","gauntlet5","greenwood","hermes","hotknife","hustler","impaler","impaler2","impaler3","impaler4","impaler6","imperator","lurcher","manana2","moonbeam","moonbeam2","nightshade","peyote2","phoenix","picador","ratloader","ratloader2","ruiner","ruiner2","ruiner3","sabregt","sabregt2","slamvan","slamvan2","slamvan3","slamvan4","slamvan5","slamvan6","stalion","stalion2","tahoma","tampa","tampa3","tulip","tulip2","vamos","vigero","vigero2","vigero3","virgo","virgo2","virgo3","voodoo","voodoo2","yosemite","yosemite2" },
                            onSelect = function(selected) self:SpawnSelectedVehicle(selected) end
                        },
                        { type = "scrollable", label = "Sports Classic", scrollType = "onEnter", value = 1, values = { "ardent","btype","btype2","btype3","casco","cheburek","cheetah2","coquette2","deluxo","dynasty","fagaloa","feltzer3","gt500","infernus2","jb700","jb7002","mamba","manana","michelli","monroe","nebula","peyote","peyote3","pigalle","rapidgt3","retinue","retinue2","savestra","stinger","stingergt","stromberg","swinger","toreador","torero","tornado","tornado2","tornado3","tornado4","tornado5","tornado6","turismo2","viseris","z190","zion3","ztype" },
                            onSelect = function(selected) self:SpawnSelectedVehicle(selected) end
                        },
                        { type = "scrollable", label = "Sports", value = 1, values = { "alpha","banshee","bestiagts","blista2","blista3","buffalo","buffalo2","buffalo3","calico","carbonizzare","comet2","comet3","comet4","comet5","comet6","coquette","coquette4","corsita","coureur","cypher","drafter","elegy","elegy2","euros","everon2","feltzer2","flashgt","furoregt","fusilade","futo","futo2","gauntlet6","gb200","growler","hotring","imorgon","issi7","italigto","italirsx","jester","jester2","jester3","jester4","jugular","khamelion","komoda","kuruma","kuruma2","locust","lynx","massacro","massacro2","neo","neon","ninef","ninef2","omnis","omnisegt","paragon","paragon2","pariah","penumbra","penumbra2","r300","raiden","rapidgt","rapidgt2","rapidgt4","raptor","remus","revolter","rt3000","ruston","schafter3","schafter4","schlagen","schwarzer","sentinel3","sentinel4","seven70","sm722","specter","specter2","streiter","sugoi","sultan","sultan2","sultan3","surano","tampa2","tenf","tenf2","tropos","vectre","verlierer2","veto","veto2","vstr","zr350","zr380" },
                            onSelect = function(selected) self:SpawnSelectedVehicle(selected) end
                        },
                        { type = "scrollable", label = "Super", scrollType = "onEnter", value = 1, values = { "adder","autarch","banshee2","bullet","champion","cheetah","cyclone","deveste","emerus","entity2","entity3","entityxf","fmj","furia","gp1","ignus","infernus","italigtb","italigtb2","krieger","le7b","lm87","nero","nero2","osiris","penetrator","pfister811","prototipo","reaper","s80","sc1","scramjet","sheava","sultanrs","suzume","t20","taipan","tempesta","tezeract","thrax","tigon","torero2","turismo3","turismor","tyrant","tyrus","vacca","vagner","vigilante","virtue","visione","voltic","voltic2","xa21","zeno","zentorno","zorrusso" },
                            onSelect = function(selected) self:SpawnSelectedVehicle(selected) end
                        },
                        { type = "scrollable", label = "Motorcycles", scrollType = "onEnter", value = 1, values = { "akuma","avarus","bagger","bati","bati2","bf400","carbonrs","chimera","cliffhanger","daemon","daemon2","deathbike","defiler","diablous","diablous2","double","enduro","esskey","faggio","faggio2","faggio3","fcr","fcr2","gargoyle","hakuchou","hakuchou2","hexer","innovation","lectro","manchez","manchez2","manchez3","nemesis","nightblade","oppressor","oppressor2","pcj","powersurge","ratbike","reever","rrocket","ruffian","sanchez","sanchez2","sanctus","shinobi","shotaro","sovereign","stryder","thrust","vader","vindicator","vortex","wolfsbane","zombiea","zombieb" },
                            onSelect = function(selected) self:SpawnSelectedVehicle(selected) end
                        },
                        { type = "scrollable", label = "Off-Road", scrollType = "onEnter", value = 1, values = { "bfinjection","bifta","blazer","blazer2","blazer3","blazer4","blazer5","bodhi2","brawler","bruiser","brutus","caracara","caracara2","dloader","draugur","dubsta3","dune","dune2","dune3","dune4","dune5","freecrawler","hellion","insurgent","insurgent2","insurgent3","kalahari","kamacho","marshall","menacer","mesa3","monster","monster3","monster4","monster5","nightshark","outlaw","patriot3","rancherxl","rancherxl2","ratel","rcbandito","rebel","rebel2","riata","sandking","sandking2","technical","technical2","technical3","trophytruck","trophytruck2","vagrant","verus","winky","yosemite3","zhaba" },
                            onSelect = function(selected) self:SpawnSelectedVehicle(selected) end
                        },
                        { type = "scrollable", label = "Industrial", scrollType = "onEnter", value = 1, values = { "bulldozer","cutter","dump","flatbed","flatbed2","guardian","handler","mixer","mixer2","rubble","tiptruck","tiptruck2" },
                            onSelect = function(selected) self:SpawnSelectedVehicle(selected) end
                        },
                        { type = "scrollable", label = "Utility", scrollType = "onEnter", value = 1, values = { "airtug","caddy","caddy2","caddy3","forklift","mower","ripley","sadler","sadler2","scrap","slamtruck","towtruck","towtruck2","towtruck3","tractor","tractor2","tractor3" },
                            onSelect = function(selected) self:SpawnSelectedVehicle(selected) end
                        },
                        { type = "scrollable", label = "Vans", scrollType = "onEnter", value = 1, values = { "bison","bison2","bison3","bobcatxl","boxville","boxville2","boxville3","boxville4","boxville5","burrito","burrito2","burrito3","burrito4","camper","gburrito","gburrito2","journey","journey2","minivan","minivan2","paradise","pony","pony2","rumpo","rumpo2","rumpo3","speedo","speedo2","surfer","surfer2","surfer3","taco","youga","youga2","youga3" },
                            onSelect = function(selected) self:SpawnSelectedVehicle(selected) end
                        }
                    }
                },
                {
                    label = "CUSTOMIZATION",
                    tabs = {
                        { type = "button", label = "Max All Tuning",
                            onSelect = function()
                                if GetResourceState("jg-mechanic") == "started" then
                                    executeCode('jg-mechanic', [[
                                        local ped = PlayerPedId()
                                        local veh = GetVehiclePedIsUsing(ped)
                                        if veh and veh ~= 0 then
                                            ALLSTAR.SafeRunNative(SetVehicleModKit, veh, 0)
                                            ALLSTAR.SafeRunNative(SetVehicleWheelType, veh, 7)
                                            for i = 0, 16 do
                                                local max = GetNumVehicleMods(veh, i)
                                                if max and max > 0 then ALLSTAR.SafeRunNative(SetVehicleMod, veh, i, max - 1, false) end
                                            end
                                            for i = 17, 22 do ToggleVehicleMod(veh, i, true) end
                                            ALLSTAR.SafeRunNative(SetVehicleMod, veh, 23, 1, false)
                                            ALLSTAR.SafeRunNative(SetVehicleMod, veh, 24, 1, false)
                                            for _, mod in ipairs({ 25, 27, 28, 30, 33, 34, 35 }) do
                                                local max = GetNumVehicleMods(veh, mod)
                                                if max and max > 0 then ALLSTAR.SafeRunNative(SetVehicleMod, veh, mod, max - 1, false) end
                                            end
                                            local max38 = GetNumVehicleMods(veh, 38)
                                            if max38 and max38 > 0 then ALLSTAR.SafeRunNative(SetVehicleMod, veh, 38, max38 - 1, true) end
                                            ALLSTAR.SafeRunNative(SetVehicleWindowTint, veh, 1)
                                            ALLSTAR.SafeRunNative(SetVehicleTyresCanBurst, veh, false)
                                            local currentProps = exports['jg-mechanic']:getVehicleProperties(veh)
                                            exports['jg-mechanic']:setVehicleProperties(veh, currentProps)
                                        end
                                    ]])
                                else
                                    executeCode('any', [[
                                        local ped = PlayerPedId()
                                        local veh = GetVehiclePedIsUsing(ped)
                                        if veh and veh ~= 0 then
                                            ALLSTAR.SafeRunNative(SetVehicleModKit, veh, 0)
                                            ALLSTAR.SafeRunNative(SetVehicleWheelType, veh, 7)
                                            for i = 0, 16 do
                                                local max = GetNumVehicleMods(veh, i)
                                                if max and max > 0 then ALLSTAR.SafeRunNative(SetVehicleMod, veh, i, max - 1, false) end
                                            end
                                            for i = 17, 22 do ToggleVehicleMod(veh, i, true) end
                                            ALLSTAR.SafeRunNative(SetVehicleMod, veh, 23, 1, false)
                                            ALLSTAR.SafeRunNative(SetVehicleMod, veh, 24, 1, false)
                                            for _, mod in ipairs({ 25, 27, 28, 30, 33, 34, 35 }) do
                                                local max = GetNumVehicleMods(veh, mod)
                                                if max and max > 0 then ALLSTAR.SafeRunNative(SetVehicleMod, veh, mod, max - 1, false) end
                                            end
                                            local max38 = GetNumVehicleMods(veh, 38)
                                            if max38 and max38 > 0 then ALLSTAR.SafeRunNative(SetVehicleMod, veh, 38, max38 - 1, true) end
                                            ALLSTAR.SafeRunNative(SetVehicleWindowTint, veh, 1)
                                            ALLSTAR.SafeRunNative(SetVehicleTyresCanBurst, veh, false)
                                        end
                                    ]])
                                end
                            end
                        },
                        { type = "button", label = "Set License Plate",
                            onSelect = function()
                                KeyboardInput("Set License Plate", "", function(val)
                                    if val and val ~= "" then
                                        local injected = string.format([[
                                            local ped = PlayerPedId()
                                            local veh = GetVehiclePedIsUsing(ped)
                                            if veh and veh ~= 0 then
                                                local originalPlate = GetVehicleNumberPlateText(veh)
                                                MachoHookNative(0x7CE1CCB9B293020E, function(vehicle)
                                                    if vehicle == veh then return false, originalPlate end
                                                    return true, GetVehicleNumberPlateText(vehicle)
                                                end)
                                                SetVehicleNumberPlateText(veh, "%s")
                                            end
                                        ]], val)
                                        executeCode("any", injected)
                                    else
                                        PALABOY:Notify("Invalid input", "Please enter a valid license plate.", "error")
                                    end
                                end, "typeable")
                            end
                        },
                        { type = "button", label = "Repair Vehicle",
                            onSelect = function()
                                if GetResourceState("jg-mechanic") == "started" then
                                    executeCode("jg-mechanic", [[
                                        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                        if not vehicle then return end
                                        Framework.Client.RepairVehicle(vehicle)
                                    ]])
                                else
                                    executeCode("any", [[
                                        local ped = PlayerPedId()
                                        local vehicle = GetVehiclePedIsIn(ped, false)
                                        if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
                                            SetVehicleFixed(vehicle)
                                            SetVehicleDeformationFixed(vehicle)
                                            SetVehicleUndriveable(vehicle, false)
                                            SetVehicleEngineOn(vehicle, true, true, true)
                                            SetVehicleEngineHealth(vehicle, 1000.0)
                                            SetVehicleBodyHealth(vehicle, 1000.0)
                                            SetVehiclePetrolTankHealth(vehicle, 1000.0)
                                            SetVehicleFuelLevel(vehicle, 100.0)
                                        end
                                    ]])
                                end
                            end
                        },
                        { type = "button", label = "Clean Vehicle",
                            onSelect = function()
                                executeCode('any', [[
                                    local veh = GetVehiclePedIsUsing(PlayerPedId())
                                    if veh and veh ~= 0 then SetVehicleDirtLevel(veh, 0.0) end
                                ]])
                            end
                        },
                        { type = "button", label = "Delete Vehicle",
                            onSelect = function()
                                executeCode('any', [[
                                    local veh = GetVehiclePedIsUsing(PlayerPedId())
                                    if veh and veh ~= 0 then DeleteVehicle(veh) end
                                ]])
                            end
                        },
                        { type = "button", label = "Lock Closest Vehicle",
                            onSelect = function()
                                executeCode('any', [[
                                    local ped = PlayerPedId()
                                    local pos = GetEntityCoords(ped)
                                    local veh = GetClosestVehicle(pos.x, pos.y, pos.z, 5.0, 0, 70)
                                    if veh and DoesEntityExist(veh) then
                                        for i = 1, 2 do
                                            SetVehicleDoorsLockedForAllPlayers(veh, true)
                                            Wait(1)
                                        end
                                    end
                                ]])
                            end
                        },
                        { type = "button", label = "Unlock Closest Vehicle",
                            onSelect = function()
                                executeCode('any', [[
                                    local ped = PlayerPedId()
                                    local pos = GetEntityCoords(ped)
                                    local veh = GetClosestVehicle(pos.x, pos.y, pos.z, 5.0, 0, 70)
                                    if veh and DoesEntityExist(veh) then
                                        for i = 1, 2 do
                                            SetVehicleDoorsLockedForAllPlayers(veh, false)
                                            Wait(1)
                                        end
                                    end
                                ]])
                            end
                        },
                        { type = "button", label = "Teleport into Closest Vehicle",
                            onSelect = function()
                                PALABOY:Notify("success", "PALABOY", "Teleported into Vehicle", 3000)
                                MachoInjectResourceRaw("any", [[
                                    local coords = GetEntityCoords(PlayerPedId())
                                    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 15.0, 0, 70)
                                    if DoesEntityExist(vehicle) and not IsPedInAnyVehicle(PlayerPedId(), false) then
                                        if GetPedInVehicleSeat(vehicle, -1) == 0 then
                                            SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
                                        else
                                            SetPedIntoVehicle(PlayerPedId(), vehicle, 0)
                                        end
                                    end
                                ]])
                            end
                        },
                        { type = "button", label = "Remove All Doors",
                            onSelect = function()
                                MachoInjectResourceRaw("any", [[
                                    local playerPed = PlayerPedId()
                                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                                    if vehicle == 0 then return end
                                    for i = 0, 3 do SetVehicleDoorBroken(vehicle, i, false) end
                                    SetVehicleDoorOpen(vehicle, 5, false, false)
                                ]])
                            end
                        },
                        { type = "divider", label = "Toggles" },
                        { type = "checkbox", label = "Force Engine On", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode("any", [[
                                        _G.ForceEngineOnActive = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while _G.ForceEngineOnActive do
                                                local selfPed = PlayerPedId()
                                                local vehicle = GetVehiclePedIsIn(selfPed, false)
                                                if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == selfPed then
                                                    ALLSTAR.SafeRunNative(SetVehicleEngineOn, vehicle, true, true, true)
                                                    ALLSTAR.SafeRunNative(SetVehicleUndriveable, vehicle, false)
                                                    ALLSTAR.SafeRunNative(SetVehicleNeedsToBeHotwired, vehicle, false)
                                                end
                                                Wait(0)
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode("any", [[ _G.ForceEngineOnActive = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Disable Locks", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode("any", [[
                                        _G.DisableLocksActive = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while _G.DisableLocksActive do
                                                if IsControlPressed(0, 23) or IsDisabledControlPressed(0, 23) then
                                                    local selfPlayer = PlayerId()
                                                    local vehicles = GetGamePool('CVehicle')
                                                    for i = 1, #vehicles do
                                                        local entity = vehicles[i]
                                                        ALLSTAR.SafeRunNative(SetEntityAsMissionEntity, entity, true, true)
                                                        ALLSTAR.SafeRunNative(SetVehicleDoorsLocked, entity, 1)
                                                        ALLSTAR.SafeRunNative(SetVehicleDoorsLockedForPlayer, entity, selfPlayer, false)
                                                        ALLSTAR.SafeRunNative(SetVehicleDoorsLockedForAllPlayers, entity, false)
                                                        ALLSTAR.SafeRunNative(SetVehicleNeedsToBeHotwired, entity, false)
                                                        ALLSTAR.SafeRunNative(SetVehicleCanBeUsedByFleeingPeds, entity, true)
                                                        ALLSTAR.SafeRunNative(SetVehicleUndriveable, entity, false)
                                                        Wait(10)
                                                    end
                                                end
                                                Wait(100)
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode("any", [[ _G.DisableLocksActive = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Hard Braking", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode("any", [[
                                        _G.HardBrakingActive = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while _G.HardBrakingActive do
                                                if IsControlJustPressed(0, 31) then
                                                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                                    if vehicle and vehicle > 0 and DoesEntityExist(vehicle) then
                                                        ALLSTAR.SafeRunNative(SetEntityVelocity, vehicle, 0.0, 0.0, 0.0)
                                                    end
                                                end
                                                Wait(0)
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode("any", [[ _G.HardBrakingActive = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "No Fall Off", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode("any", [[
                                        _G.NoFallOffActive = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while _G.NoFallOffActive do
                                                ALLSTAR.SafeRunNative(SetPedCanBeKnockedOffVehicle, PlayerPedId(), 1)
                                                Wait(1000)
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode("any", [[
                                        _G.NoFallOffActive = false
                                        ALLSTAR.SafeRunNative(SetPedCanBeKnockedOffVehicle, PlayerPedId(), 0)
                                    ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Vehicle Fly", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    PALABOY:Notify("success", "PALABOY", "Press [Y] Select vehicle. [G] Fly. [L] Freeze.", 3000)
                                    Control_Vehicle = true
                                    Control_Vehicle_Thread = CreateThread(function()
                                        while Control_Vehicle do
                                            Wait(0)
                                            if IsControlJustPressed(0, 182) then ToggleFreezeVehicle(selectedVehicle) end
                                            if IsControlJustPressed(0, 246) then
                                                if selectedVehicle and DoesEntityExist(selectedVehicle) then SetEntityDrawOutline(selectedVehicle, false) end
                                                selectedVehicle = GetClosestVehicle()
                                                if selectedVehicle then PALABOY:Notify("success", "PALABOY", "Selected Vehicle!", 3000) end
                                            end
                                            if selectedVehicle and DoesEntityExist(selectedVehicle) then
                                                DrawVehicleOutline(selectedVehicle)
                                                if IsControlPressed(0, 47) then
                                                    if not isVehicleFlying then isVehicleFlying = true SetEntityHasGravity(selectedVehicle, false) end
                                                    local camRot = GetGameplayCamRot(2)
                                                    local propSpeed = 50.0
                                                    local dirX = -math.sin(math.rad(camRot.z)) * math.cos(math.rad(camRot.x))
                                                    local dirY = math.cos(math.rad(camRot.z)) * math.cos(math.rad(camRot.x))
                                                    local dirZ = math.sin(math.rad(camRot.x))
                                                    SetEntityVelocity(selectedVehicle, dirX * propSpeed, dirY * propSpeed, dirZ * propSpeed)
                                                else
                                                    if isVehicleFlying then isVehicleFlying = false SetEntityHasGravity(selectedVehicle, true) end
                                                end
                                            end
                                        end
                                    end)
                                else
                                    PALABOY:Notify("error", "PALABOY", "Vehicle fly disabled.", 3000)
                                    Control_Vehicle = false
                                    if Control_Vehicle_Thread then
                                        TerminateThread(Control_Vehicle_Thread)
                                        Control_Vehicle_Thread = nil
                                    end
                                end
                            end
                        },
                        { type = "checkbox", label = "Boost Vehicle", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode("any", [[
                                        _G.superSpeedBoostEnabled = true
                                        if not _G.superSpeedBoostThread then
                                            _G.superSpeedBoostThread = CreateThread(function()
                                                while _G.superSpeedBoostEnabled do
                                                    local ped = PlayerPedId()
                                                    if IsControlPressed(0, 209) and IsPedInAnyVehicle(ped, false) then
                                                        local veh = GetVehiclePedIsIn(ped, false)
                                                        if veh and veh ~= 0 then SetVehicleForwardSpeed(veh, 100.0) end
                                                    end
                                                    Wait(0)
                                                end
                                            end)
                                        end
                                    ]])
                                else
                                    executeCode("any", [[ _G.superSpeedBoostEnabled = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Unlimited Fuel", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode("any", [[
                                        _G.UnlimitedFuelActive = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while _G.UnlimitedFuelActive do
                                                local ped = PlayerPedId()
                                                if IsPedInAnyVehicle(ped, false) then
                                                    local veh = GetVehiclePedIsIn(ped, false)
                                                    if DoesEntityExist(veh) then
                                                        ALLSTAR.SafeRunNative(SetVehicleFuelLevel, veh, 100.0)
                                                    end
                                                end
                                                Wait(100)
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode("any", [[ _G.UnlimitedFuelActive = false ]])
                                end
                            end
                        },
                        { type = "divider", label = "Vehicle Tricks" },
                        { icon = "", type = "scrollable", value = 1, values = { "Kick Flip", "Back Flip", "Jump", "Flip" }, label = "Vehicle Stunts", desc = "Applies physics stunts",
                            onSelect = function(value)
                                if value == "Kick Flip" then
                                    MachoInjectResource("any", [[
                                        local playerVeh = GetVehiclePedIsIn(PlayerPedId(), true)
                                        if DoesEntityExist(playerVeh) then
                                            ApplyForceToEntity(playerVeh, 1, 0.0, 0.0, 10.0, 90.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
                                        end
                                    ]])
                                elseif value == "Back Flip" then
                                    MachoInjectResource("any", [[
                                        local playerVeh = GetVehiclePedIsIn(PlayerPedId(), true)
                                        if DoesEntityExist(playerVeh) then
                                            ApplyForceToEntity(playerVeh, 1, 0.0, 0.0, 15.0, 0.0, 60.0, 0.0, 0, 0, 1, 1, 0, 0)
                                        end
                                    ]])
                                elseif value == "Jump" then
                                    MachoInjectResource("any", [[
                                        local playerVeh = GetVehiclePedIsIn(PlayerPedId(), true)
                                        if DoesEntityExist(playerVeh) then
                                            ApplyForceToEntity(playerVeh, 1, 0.0, 0.0, 15.0, 0.0, 0.0, 00.0, 0, 1, 0, 1, 0, 0)
                                        end
                                    ]])
                                elseif value == "Flip" then
                                    MachoInjectResourceRaw("any", [[
                                        local function vXmYLT9pq2()
                                            local a = PlayerPedId
                                            local b = GetVehiclePedIsIn
                                            local c = GetEntityHeading
                                            local d = SetEntityRotation
                                            local ped = a()
                                            local veh = b(ped, false)
                                            if veh and veh ~= 0 then
                                                d(veh, 0.0, 0.0, c(veh))
                                            end
                                        end
                                        vXmYLT9pq2()
                                    ]])
                                end
                            end
                        },
                    }
                },
                {
                    label = "Addon's",
                    tabs = {
                        { type = "subMenu", label = "Tuning",
                            subTabs = {
                                {
                                    type = "button",
                                    label = "Ceramic Brakes",
                                    desc = "This will add Ceramic Brakes to you're vehicle.",
                                    onSelect = function()
                                        if GetResourceState("jg-mechanic") == "started" then
                                            executeCode('jg-mechanic', [[
                                                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                                if vehicle and DoesEntityExist(vehicle) then
                                                    local plate = GetVehicleNumberPlateText(vehicle)
                                                    local netId = NetworkGetNetworkIdFromEntity(vehicle)
                                                    local currentState = Entity(vehicle).state.tuningConfig or {}
                                                    currentState["brakes"] = 1

                                                    local statebagEventId = "jg-mechanic:server:set-vehicle-statebag:" .. math.random(10000, 99999)
                                                    ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:set-vehicle-statebag', "jg-mechanic", statebagEventId, netId, "tuningConfig", currentState)
                                                    ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:set-vehicle-statebag", "jg-mechanic", statebagEventId)

                                                    local upgrades = {
                                                        {type = "brakes", option = 1},
                                                    }

                                                    for _, upgrade in ipairs(upgrades) do
                                                        local saveEventId = "jg-mechanic:server:pay-for-tune:" .. math.random(10000, 99999)
                                                        ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:pay-for-tune', "jg-mechanic", saveEventId, upgrade.type, upgrade.option, 0, plate)
                                                        ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:pay-for-tune", "jg-mechanic", saveEventId)
                                                    end
                                                end
                                            ]])
                                        else
                                            self:Notify("info", "PALABOY", "No found script.", 3000)
                                        end
                                    end
                                },
                                {
                                    type = "button",
                                    label = "Drift Tuning",
                                    desc = "This will add Drift Tuning to you're vehicle.",
                                    onSelect = function()
                                        if GetResourceState("jg-mechanic") == "started" then
                                            executeCode('jg-mechanic', [[
                                                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                                if vehicle and DoesEntityExist(vehicle) then
                                                    local plate = GetVehicleNumberPlateText(vehicle)
                                                    local netId = NetworkGetNetworkIdFromEntity(vehicle)
                                                    local currentState = Entity(vehicle).state.tuningConfig or {}
                                                    currentState["driftTuning"] = 1

                                                    local statebagEventId = "jg-mechanic:server:set-vehicle-statebag:" .. math.random(10000, 99999)
                                                    ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:set-vehicle-statebag', "jg-mechanic", statebagEventId, netId, "tuningConfig", currentState)
                                                    ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:set-vehicle-statebag", "jg-mechanic", statebagEventId)

                                                    local upgrades = {
                                                        {type = "driftTuning", option = 1}
                                                    }

                                                    for _, upgrade in ipairs(upgrades) do
                                                        local saveEventId = "jg-mechanic:server:pay-for-tune:" .. math.random(10000, 99999)
                                                        ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:pay-for-tune', "jg-mechanic", saveEventId, upgrade.type, upgrade.option, 0, plate)
                                                        ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:pay-for-tune", "jg-mechanic", saveEventId)
                                                    end
                                                end
                                            ]])
                                        else
                                            self:Notify("info", "PALABOY", "No found script.", 3000)
                                        end
                                    end
                                },
                                { icon = "", type = "scrollable", value = 1, values = { "AWD", "RWD", "FWD" }, label = "Drivetrains", desc = "This will add Drivetrains to you're vehicle.",
                                    onSelect = function(value)
                                        local driveOption = 1
                                        if value == "RWD" then driveOption = 2
                                        elseif value == "FWD" then driveOption = 3 end

                                        if GetResourceState("jg-mechanic") == "started" then
                                            executeCode('jg-mechanic', string.format([[
                                                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                                if vehicle and DoesEntityExist(vehicle) then
                                                    local plate = GetVehicleNumberPlateText(vehicle)
                                                    local netId = NetworkGetNetworkIdFromEntity(vehicle)
                                                    local currentState = Entity(vehicle).state.tuningConfig or {}
                                                    currentState["drivetrains"] = %d

                                                    local statebagEventId = "jg-mechanic:server:set-vehicle-statebag:" .. math.random(10000, 99999)
                                                    ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:set-vehicle-statebag', "jg-mechanic", statebagEventId, netId, "tuningConfig", currentState)
                                                    ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:set-vehicle-statebag", "jg-mechanic", statebagEventId)

                                                    local upgrades = {
                                                        {type = "drivetrains", option = %d}
                                                    }

                                                    for _, upgrade in ipairs(upgrades) do
                                                        local saveEventId = "jg-mechanic:server:pay-for-tune:" .. math.random(10000, 99999)
                                                        ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:pay-for-tune', "jg-mechanic", saveEventId, upgrade.type, upgrade.option, 0, plate)
                                                        ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:pay-for-tune", "jg-mechanic", saveEventId)
                                                    end
                                                end
                                            ]], driveOption, driveOption))
                                        else
                                            self:Notify("info", "PALABOY", "No found script.", 3000)
                                        end
                                    end
                                },
                                { icon = "", type = "scrollable", value = 1, values = { "I4 Turbo 2.5L", "V6 3.3L", "V8 6.5L", "V12 6.0L" }, label = "Engine Swaps", desc = "This will add Engine Swaps to you're vehicle.",
                                    onSelect = function(value)
                                        local swapOption = 1
                                        if value == "V6 3.3L" then swapOption = 2
                                        elseif value == "V8 6.5L" then swapOption = 3
                                        elseif value == "V12 6.0L" then swapOption = 4 end

                                        if GetResourceState("jg-mechanic") == "started" then
                                            executeCode('jg-mechanic', string.format([[
                                                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                                if vehicle and DoesEntityExist(vehicle) then
                                                    local plate = GetVehicleNumberPlateText(vehicle)
                                                    local netId = NetworkGetNetworkIdFromEntity(vehicle)
                                                    local currentState = Entity(vehicle).state.tuningConfig or {}
                                                    currentState["engineSwaps"] = %d

                                                    local statebagEventId = "jg-mechanic:server:set-vehicle-statebag:" .. math.random(10000, 99999)
                                                    ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:set-vehicle-statebag', "jg-mechanic", statebagEventId, netId, "tuningConfig", currentState)
                                                    ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:set-vehicle-statebag", "jg-mechanic", statebagEventId)

                                                    local upgrades = {
                                                        {type = "engineSwaps", option = %d}
                                                    }

                                                    for _, upgrade in ipairs(upgrades) do
                                                        local saveEventId = "jg-mechanic:server:pay-for-tune:" .. math.random(10000, 99999)
                                                        ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:pay-for-tune', "jg-mechanic", saveEventId, upgrade.type, upgrade.option, 0, plate)
                                                        ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:pay-for-tune", "jg-mechanic", saveEventId)
                                                    end
                                                end
                                            ]], swapOption, swapOption))
                                        else
                                            self:Notify("info", "PALABOY", "No found script.", 3000)
                                        end
                                    end
                                },
                                {
                                    type = "button",
                                    label = "Turbocharging",
                                    desc = "This will add Turbocharging to you're vehicle.",
                                    onSelect = function()
                                        if GetResourceState("jg-mechanic") == "started" then
                                            executeCode('jg-mechanic', [[
                                                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                                if vehicle and DoesEntityExist(vehicle) then
                                                    local plate = GetVehicleNumberPlateText(vehicle)
                                                    local netId = NetworkGetNetworkIdFromEntity(vehicle)
                                                    local currentState = Entity(vehicle).state.tuningConfig or {}
                                                    currentState["turbocharging"] = true

                                                    local statebagEventId = "jg-mechanic:server:set-vehicle-statebag:" .. math.random(10000, 99999)
                                                    ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:set-vehicle-statebag', "jg-mechanic", statebagEventId, netId, "tuningConfig", currentState)
                                                    ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:set-vehicle-statebag", "jg-mechanic", statebagEventId)

                                                    local upgrades = {
                                                        {type = "turbocharging", option = 1},
                                                    }

                                                    for _, upgrade in ipairs(upgrades) do
                                                        local saveEventId = "jg-mechanic:server:pay-for-tune:" .. math.random(10000, 99999)
                                                        ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:pay-for-tune', "jg-mechanic", saveEventId, upgrade.type, upgrade.option, 0, plate)
                                                        ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:pay-for-tune", "jg-mechanic", saveEventId)
                                                    end
                                                end
                                            ]])
                                        else
                                            self:Notify("info", "PALABOY", "No found script.", 3000)
                                        end
                                    end
                                },
                                { icon = "", type = "scrollable", value = 1, values = { "Slicks", "Semi-slicks", "Offroad" }, label = "Tyres", desc = "This will add tyres to you're vehicle.",
                                    onSelect = function(value)
                                        local tyreOption = 1
                                        if value == "Semi-slicks" then tyreOption = 2
                                        elseif value == "Offroad" then tyreOption = 3 end

                                        if GetResourceState("jg-mechanic") == "started" then
                                            executeCode('jg-mechanic', string.format([[
                                                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                                if vehicle and DoesEntityExist(vehicle) then
                                                    local plate = GetVehicleNumberPlateText(vehicle)
                                                    local netId = NetworkGetNetworkIdFromEntity(vehicle)
                                                    local currentState = Entity(vehicle).state.tuningConfig or {}
                                                    currentState["tyres"] = %d

                                                    local statebagEventId = "jg-mechanic:server:set-vehicle-statebag:" .. math.random(10000, 99999)
                                                    ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:set-vehicle-statebag', "jg-mechanic", statebagEventId, netId, "tuningConfig", currentState)
                                                    ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:set-vehicle-statebag', "jg-mechanic", statebagEventId)

                                                    local upgrades = {
                                                        {type = "tyres", option = %d}
                                                    }

                                                    for _, upgrade in ipairs(upgrades) do
                                                        local saveEventId = "jg-mechanic:server:pay-for-tune:" .. math.random(10000, 99999)
                                                        ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:pay-for-tune', "jg-mechanic", saveEventId, upgrade.type, upgrade.option, 0, plate)
                                                        ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:pay-for-tune", "jg-mechanic", saveEventId)
                                                    end
                                                end
                                            ]], tyreOption, tyreOption))
                                        else
                                            self:Notify("info", "PALABOY", "No found script.", 3000)
                                        end
                                    end
                                }
                            }
                        },
                        {
                            type = "button",
                            label = "Pms",
                            desc = "This will repair all PMS to you're vehicle.",
                            onSelect = function()
                                if GetResourceState("jg-mechanic") == "started" then
                                    executeCode('jg-mechanic', [[
                                        local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                        if currentVehicle and currentVehicle ~= 0 then
                                            local plate = GetVehicleNumberPlateText(currentVehicle)
                                            if plate then
                                                plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")
                                            end

                                            local perfectServicingData = {
                                                suspension = 100, tyres = 100, brakePads = 100, engineOil = 100,
                                                clutch = 100, airFilter = 100, sparkPlugs = 100, evMotor = 100,
                                                evBattery = 100, evCoolant = 100
                                            }

                                            local networkId = NetworkGetNetworkIdFromEntity(currentVehicle)
                                            local stateBagName = string.format("entity:%s", networkId)

                                            ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:set-vehicle-statebag', "jg-mechanic", "jg-mechanic:server:set-vehicle-statebag:34179", networkId, "servicingData", perfectServicingData)
                                            ALLSTAR.SafeRunNative(TriggerServerEvent, 'jg-vehiclemileage:server:updateVehicleMileage', plate, 1)
                                        end
                                    ]])
                                else
                                    self:Notify("info", "PALABOY", "No found script.", 3000)
                                end
                            end
                        },
                        {
                            type = "button",
                            label = "V12",
                            desc = "This will add V12 to you're vehicle.",
                            onSelect = function()
                                if GetResourceState("jg-mechanic") == "started" then
                                    executeCode('jg-mechanic', [[
                                        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                                        if vehicle and DoesEntityExist(vehicle) then
                                            local plate = GetVehicleNumberPlateText(vehicle)
                                            local netId = NetworkGetNetworkIdFromEntity(vehicle)
                                            local currentState = Entity(vehicle).state.tuningConfig or {}
                                            currentState["engineSwaps"] = 4
                                            currentState["brakes"] = 1
                                            currentState["drivetrains"] = 1
                                            currentState["tyres"] = 1
                                            currentState["turbocharging"] = true

                                            local statebagEventId = "jg-mechanic:server:set-vehicle-statebag:" .. math.random(10000, 99999)
                                            ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:set-vehicle-statebag', "jg-mechanic", statebagEventId, netId, "tuningConfig", currentState)
                                            ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:set-vehicle-statebag", "jg-mechanic", statebagEventId)

                                            local upgrades = {
                                                {type = "engineSwaps", option = 4},
                                                {type = "brakes", option = 1},
                                                {type = "drivetrains", option = 1},
                                                {type = "tyres", option = 1},
                                                {type = "turbocharging", option = 1}
                                            }

                                            for _, upgrade in ipairs(upgrades) do
                                                local saveEventId = "jg-mechanic:server:pay-for-tune:" .. math.random(10000, 99999)
                                                ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:pay-for-tune', "jg-mechanic", saveEventId, upgrade.type, upgrade.option, 0, plate)
                                                ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:pay-for-tune", "jg-mechanic", saveEventId)
                                            end
                                        end
                                    ]])
                                else
                                    self:Notify("info", "PALABOY", "No found script.", 3000)
                                end
                            end
                        },
                        { type = "slider", label = "Nitro", desc = "This will add nitro to you're vehicle.", scrollType = "onEnter", value = 1, min = 0, max = 3, step = 1.0,
                            onSelect = function(value)
                                if GetResourceState("jg-mechanic") == "started" then
                                    executeCode('jg-mechanic', string.format([[
                                        local ped = PlayerPedId()
                                        local vehicle = GetVehiclePedIsIn(ped, false)
                                        local nitroAmount = %s

                                        if vehicle and vehicle ~= 0 then
                                            ALLSTAR.SafeRunNative(TriggerServerEvent, '__ox_cb_jg-mechanic:server:install-new-bottle', "jg-mechanic", "jg-mechanic:server:install-new-bottle:11050")
                                            ALLSTAR.SafeRunNative(TriggerServerEvent, 'ox_lib:validateCallback', "jg-mechanic:server:install-new-bottle", "jg-mechanic", "jg-mechanic:server:install-new-bottle:11050")

                                            local nitrousProps = {
                                                nitrousInstalledBottles = nitroAmount,
                                                nitrousFilledBottles = nitroAmount,
                                                nitrousCapacity = 10.0
                                            }

                                            exports['jg-mechanic']:setVehicleProperties(vehicle, nitrousProps, true)
                                        end
                                    ]], value))
                                else
                                    self:Notify("info", "PALABOY", "No found script.", 3000)
                                end
                            end
                        },
                    }
                },
            }
        },
        {
            icon = 'ph-map-pin',
            label = "TELEPORT OPTION",
            type = "subMenu",
            categories = {
                {
                    label = "TELEPORT",
                    tabs = {
                        { type = "button", label = "Teleport to Waypoint",
                            onSelect = function()
                                executeCode('any', [[
                                    local function getSafeGroundZ(x, y, fallbackZ)
                                        local foundGround, groundZ = false, fallbackZ
                                        for height = 0.0, 1000.0, 25.0 do
                                            foundGround, groundZ = GetGroundZFor_3dCoord(x, y, height, false)
                                            if foundGround then return groundZ + 1.0 end
                                        end
                                        return fallbackZ + 1.0
                                    end
                                    local blip = GetFirstBlipInfoId(8)
                                    if not DoesBlipExist(blip) then return end
                                    local coords = GetBlipInfoIdCoord(blip)
                                    local ped = PlayerPedId()
                                    if not DoesEntityExist(ped) then return end
                                    local safeZ = getSafeGroundZ(coords.x, coords.y, coords.z)
                                    local entityToCheck = ped
                                    if IsPedInAnyVehicle(ped, false) then entityToCheck = GetVehiclePedIsIn(ped, false) end
                                    ALLSTAR.SafeRunNative(RequestCollisionAtCoord, coords.x, coords.y, safeZ)
                                    ALLSTAR.SafeRunNative(FreezeEntityPosition, entityToCheck, true)
                                    ALLSTAR.SafeRunNative(SetPedCoordsKeepVehicle, ped, coords.x, coords.y, safeZ)
                                    local startTime = GetGameTimer()
                                    while (GetGameTimer() - startTime) < 5000 do
                                        ALLSTAR.SafeRunNative(RequestCollisionAtCoord, coords.x, coords.y, safeZ)
                                        if HasCollisionLoadedAroundEntity(entityToCheck) then break end
                                        ALLSTAR.SafeRunNative(Wait, 50)
                                    end
                                    ALLSTAR.SafeRunNative(FreezeEntityPosition, entityToCheck, false)
                                ]])
                            end
                        },
                        { type = "button", label = "Teleport to Grove",
                            onSelect = function()
                                executeCode('any', [[
                                    local targetX, targetY, targetZ = 100.0, -1940.0, 20.3
                                    local function getSafeGroundZ(x, y, fz)
                                        local fg, gz = false, fz
                                        for h = 0.0, 1000.0, 25.0 do
                                            fg, gz = GetGroundZFor_3dCoord(x, y, h, false)
                                            if fg then return gz + 1.0 end
                                        end
                                        return fz + 1.0
                                    end
                                    local ped = PlayerPedId()
                                    if not DoesEntityExist(ped) then return end
                                    local ent = ped
                                    if IsPedInAnyVehicle(ped, false) then ent = GetVehiclePedIsIn(ped, false) end
                                    local safeZ = getSafeGroundZ(targetX, targetY, targetZ)
                                    ALLSTAR.SafeRunNative(RequestCollisionAtCoord, targetX, targetY, safeZ)
                                    ALLSTAR.SafeRunNative(FreezeEntityPosition, ent, true)
                                    ALLSTAR.SafeRunNative(SetEntityCoords, ent, targetX, targetY, safeZ, false, false, false, true)
                                    local st = GetGameTimer()
                                    while (GetGameTimer() - st) < 5000 do
                                        ALLSTAR.SafeRunNative(RequestCollisionAtCoord, targetX, targetY, safeZ)
                                        if HasCollisionLoadedAroundEntity(ent) then break end
                                        ALLSTAR.SafeRunNative(Wait, 50)
                                    end
                                    ALLSTAR.SafeRunNative(FreezeEntityPosition, ent, false)
                                ]])
                            end
                        },
                        { type = "button", label = "Teleport to Legion Square",
                            onSelect = function()
                                executeCode('any', [[
                                    local targetX, targetY, targetZ = 224.17, -869.13, 30.49
                                    local ped = PlayerPedId()
                                    if not DoesEntityExist(ped) then return end
                                    local ent = ped
                                    if IsPedInAnyVehicle(ped, false) then ent = GetVehiclePedIsIn(ped, false) end
                                    ALLSTAR.SafeRunNative(RequestCollisionAtCoord, targetX, targetY, targetZ)
                                    ALLSTAR.SafeRunNative(FreezeEntityPosition, ent, true)
                                    ALLSTAR.SafeRunNative(SetEntityCoords, ent, targetX, targetY, targetZ, false, false, false, true)
                                    ALLSTAR.SafeRunNative(Wait, 2000)
                                    ALLSTAR.SafeRunNative(FreezeEntityPosition, ent, false)
                                ]])
                            end
                        },
                        { type = "button", label = "Teleport to Mount Chilliad",
                            onSelect = function()
                                executeCode('any', [[
                                    local ped = PlayerPedId()
                                    local ent = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or ped
                                    ALLSTAR.SafeRunNative(SetEntityCoords, ent, 501.64, 5604.94, 797.90, false, false, false, true)
                                ]])
                            end
                        },
                        { type = "button", label = "Teleport to Paleto Bay",
                            onSelect = function()
                                executeCode('any', [[
                                    local ped = PlayerPedId()
                                    local ent = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or ped
                                    ALLSTAR.SafeRunNative(SetEntityCoords, ent, 108.62, 6612.87, 32.00, false, false, false, true)
                                ]])
                            end
                        }
                    }
                }
            }
        },
        {
            icon = "ph ph-globe",
            label = "SERVER OPTION",
            type = "subMenu",
            categories = {
                {
                    label = "TRIGGERS",
                    tabs = {
                        { type = "button", label = "Triggers Finder (F8)",
                            onSelect = function()
                                MachoInjectResourceRaw(targetSafeRes, [[
                                    local allEvents = {}
                                    local eventCount = 0
                                    for i = 0, GetNumResources() - 1 do
                                        local resourceName = GetResourceByFindIndex(i)
                                        if resourceName and GetResourceState(resourceName) == "started" then
                                            local numClientScripts = GetNumResourceMetadata(resourceName, 'client_script')
                                            if numClientScripts and numClientScripts > 0 then
                                                for j = 0, numClientScripts - 1 do
                                                    local scriptPath = GetResourceMetadata(resourceName, 'client_script', j)
                                                    if scriptPath then
                                                        local ok, content = pcall(function() return LoadResourceFile(resourceName, scriptPath) end)
                                                        if ok and content then
                                                            for eventName in content:gmatch('TriggerServerEvent%s*%(%s*["\']([^"\']+)["\']') do
                                                                if not allEvents[eventName] then
                                                                    allEvents[eventName] = { resource = resourceName }
                                                                    eventCount = eventCount + 1
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    if eventCount == 0 then
                                        print("^1[TRIGGERS FINDER] No TriggerServerEvent found!")
                                    else
                                        print("^2[FOUND] " .. eventCount .. " TriggerServerEvent:")
                                        for name, _ in pairs(allEvents) do
                                            print(string.format('^5TriggerServerEvent("%s")^0', name))
                                        end
                                    end
                                    _G._FoundServerEvents = allEvents
                                ]])
                            end
                        },
                        { type = "divider", label = "Server Exploit" }
                    }
                },
                {
                    label = "DESTROYER",
                    tabs = {
                        { type = "checkbox", label = "Bypass Safezones", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode(targetRes, [[
                                        _G.BypassSafezoneActive = true
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            while _G.BypassSafezoneActive do
                                                ALLSTAR.SafeRunNative(Wait, 0)
                                                ALLSTAR.SafeRunNative(NetworkSetFriendlyFireOption, true)
                                                ALLSTAR.SafeRunNative(SetCanAttackFriendly, PlayerPedId(), true, true)
                                                ALLSTAR.SafeRunNative(DisablePlayerFiring, PlayerPedId(), false)
                                                ALLSTAR.SafeRunNative(EnableAllControlActions, 0)
                                                ALLSTAR.SafeRunNative(EnableAllControlActions, 1)
                                            end
                                        end)
                                    ]])
                                else
                                    executeCode(targetRes, [[ _G.BypassSafezoneActive = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Kill Everyone", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    executeCode("any", [[
                                        _G.KillEveryoneLoop = true
                                        local weaponName = 'WEAPON_APPISTOL'
                                        local ammoAmount = 999
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            local weapon = GetHashKey(weaponName)
                                            RequestWeaponAsset(weapon, 31, 26)
                                            while not HasWeaponAssetLoaded(weapon) and _G.KillEveryoneLoop do ALLSTAR.SafeRunNative(Wait, 0) end
                                            while _G.KillEveryoneLoop do
                                                local selfPed = PlayerPedId()
                                                local selfCoords = GetEntityCoords(selfPed)
                                                ALLSTAR.SafeRunNative(GiveDelayedWeaponToPed, selfPed, weapon, ammoAmount, true)
                                                ALLSTAR.SafeRunNative(SetPedAmmo, selfPed, weapon, ammoAmount)
                                                for _, playerId in ipairs(GetActivePlayers()) do
                                                    local targetPed = GetPlayerPed(playerId)
                                                    if targetPed ~= selfPed and DoesEntityExist(targetPed) and not IsPedDeadOrDying(targetPed, true) then
                                                        local tc = GetEntityCoords(targetPed)
                                                        if #(selfCoords - tc) < 350.0 then
                                                            local fromCoords = tc + vector3(math.random(-2, 2), math.random(-2, 2), math.random(1, 2))
                                                            ALLSTAR.SafeRunNative(ShootSingleBulletBetweenCoords, fromCoords.x, fromCoords.y, fromCoords.z, tc.x, tc.y, tc.z + 0.2, 999999, true, weapon, selfPed, true, false, 999999.0)
                                                        end
                                                    end
                                                end
                                                ALLSTAR.SafeRunNative(Wait, 0)
                                            end
                                            local ped = PlayerPedId()
                                            ALLSTAR.SafeRunNative(SetPedUsingActionMode, ped, false, -1, 'DEFAULT_ACTION')
                                            ALLSTAR.SafeRunNative(RemoveWeaponFromPed, ped, weapon)
                                            ALLSTAR.SafeRunNative(SetCurrentPedWeapon, ped, 'weapon_unarmed', true)
                                        end)
                                    ]])
                                else
                                    executeCode("any", [[ _G.KillEveryoneLoop = false ]])
                                end
                            end
                        },
                        { type = "scrollable", label = "Spawn Falling Vehicles", scrollType = "onEnter", value = 1, values = { "1 Car", "3 Cars", "5 Cars", "10 Cars", "Rain of Cars (20)" },
                            onSelect = function(value)
                                local count = 1
                                if value == "3 Cars" then count = 3
                                elseif value == "5 Cars" then count = 5
                                elseif value == "10 Cars" then count = 10
                                elseif value == "Rain of Cars (20)" then count = 20 end
                                MachoInjectResourceRaw(targetRes, string.format([[
                                    local count = %d
                                    local pc = GetEntityCoords(PlayerPedId())
                                    local vehicles = {"adder","zentorno","t20","infernus","cheetah","turismor","entity2","osiris","pfister811","vagner","nero"}
                                    for i = 1, count do
                                        local vehicleName = vehicles[math.random(1, #vehicles)]
                                        local modelHash = GetHashKey(vehicleName)
                                        RequestModel(modelHash)
                                        while not HasModelLoaded(modelHash) do Wait(10) end
                                        local ox = math.random(-20, 20)
                                        local oy = math.random(-20, 20)
                                        local h = math.random(50, 100)
                                        local sc = vector3(pc.x + ox, pc.y + oy, pc.z + h)
                                        local veh = CreateVehicle(modelHash, sc.x, sc.y, sc.z, math.random(0, 360), true, true)
                                        SetModelAsNoLongerNeeded(modelHash)
                                        NetworkRegisterEntityAsNetworked(veh)
                                        local netId = NetworkGetNetworkIdFromEntity(veh)
                                        SetNetworkIdCanMigrate(netId, true)
                                        SetNetworkIdExistsOnAllMachines(netId, true)
                                        SetEntityAsMissionEntity(veh, true, true)
                                        Wait(100)
                                    end
                                ]], count))
                            end
                        },
                        { type = "checkbox", label = "Mass Explosion", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    MachoInjectResourceRaw(targetRes, [[
                                        _G.MassExplosionActive = true
                                        Citizen.CreateThread(function()
                                            while _G.MassExplosionActive do
                                                for _, playerId in ipairs(GetActivePlayers()) do
                                                    local targetPed = GetPlayerPed(playerId)
                                                    local modelHash = GetHashKey("vestra")
                                                    RequestModel(modelHash)
                                                    local startWait = GetGameTimer()
                                                    while not HasModelLoaded(modelHash) do
                                                        Citizen.Wait(10)
                                                        if GetGameTimer() - startWait > 5000 then return end
                                                    end
                                                    local headCoords = GetPedBoneCoords(targetPed, 31086, 0.0, 0.0, 0.3)
                                                    local sc = vector3(headCoords.x, headCoords.y, headCoords.z + 10.0)
                                                    local veh = CreateVehicle(modelHash, sc.x, sc.y, sc.z, 0.0, true, false)
                                                    if veh ~= 0 then
                                                        SetEntityVisible(veh, false, 0)
                                                        SetEntityInvincible(veh, false)
                                                        SetEntityAsMissionEntity(veh, true, true)
                                                        SetEntityVelocity(veh, 0.0, 0.0, -10.0)
                                                        Citizen.CreateThread(function()
                                                            while true do
                                                                Citizen.Wait(100)
                                                                if IsEntityOnGround(veh) then
                                                                    AddExplosion(GetEntityCoords(veh).x, GetEntityCoords(veh).y, GetEntityCoords(veh).z, 2, 10.0, true, false, 1.0)
                                                                    DeleteEntity(veh)
                                                                    break
                                                                end
                                                            end
                                                        end)
                                                    end
                                                    SetModelAsNoLongerNeeded(modelHash)
                                                end
                                                Citizen.Wait(100)
                                            end
                                        end)
                                    ]])
                                else
                                    MachoInjectResourceRaw(targetRes, [[ _G.MassExplosionActive = false ]])
                                end
                            end
                        },
                        { type = "checkbox", label = "Limb Players Around You", checked = false,
                            onSelect = function(checked)
                                if checked then
                                    self:Notify("success", "PALABOY", "Limb Players Around You Enabled.", 3000)
                                    MachoInjectResource2(AsThreadNs, targetSafeRes, [[
                                        local function setBypass(setFunc, ...)
                                            local stateName = math.random(999999, 999999999)..GetCurrentResourceName()..GetGameTimer()
                                            LocalPlayer.state:set(stateName, setFunc, false)
                                            return LocalPlayer.state[stateName](...)
                                        end
                                        _G.isLimbActive = true
                                        local function thread(fn)
                                            setBypass(CreateThread, fn)
                                        end
                                        thread(function()
                                            while _G.isLimbActive do
                                                local ped = setBypass(PlayerPedId)
                                                setBypass(SetEntityVisible, ped, false, false)
                                                setBypass(FreezeEntityPosition, ped, true)
                                                setBypass(TaskStartScenarioInPlace, ped, "WORLD_HUMAN_WELDING", 0, false)
                                                setBypass(Wait, 10)
                                                setBypass(ClearPedTasks, ped)
                                                setBypass(TaskStartScenarioInPlace, ped, "WORLD_HUMAN_WELDING", 0, true)
                                            end
                                            local ped = setBypass(PlayerPedId)
                                            setBypass(FreezeEntityPosition, ped, false)
                                            setBypass(ClearPedTasks, ped)
                                            setBypass(ClearPedTasksImmediately, ped)
                                            setBypass(SetEntityVisible, ped, true, true)
                                        end)
                                    ]])
                                else
                                    self:Notify("error", "PALABOY", "Limb Players Around You Disabled.", 3000)
                                    MachoInjectResource2(AsThreadNs, targetSafeRes, [[
                                        _G.isLimbActive = false
                                        local function setBypass(setFunc, ...)
                                            local stateName = math.random(999999, 999999999)..GetCurrentResourceName()..GetGameTimer()
                                            LocalPlayer.state:set(stateName, setFunc, false)
                                            return LocalPlayer.state[stateName](...)
                                        end
                                        local ped = setBypass(PlayerPedId)
                                        setBypass(FreezeEntityPosition, ped, false)
                                        setBypass(ClearPedTasks, ped)
                                        setBypass(ClearPedTasksImmediately, ped)
                                        setBypass(SetEntityVisible, ped, true, true)
                                    ]])
                                end
                            end
                        }
                    }
                }
            }
        },
        {
            icon = 'ph-gear-six',
            label = "SETTINGS",
            type = "subMenu",
            categories = {
                {
                    label = "INTERFACE",
                    tabs = {
                        { icon = "", type = "button", label = "Menu Keybinds",
                            onSelect = function()
                                KeyboardInput("Choose Menu Key", "", function(val)
                                    for vk, name in pairs(MappedKeys) do
                                        if name:lower() == val:lower() then
                                            MenuKey = vk
                                            Wait(250)
                                            ALLSTAR:ShowUI()
                                            return
                                        end
                                    end
                                end, "keybind")
                            end
                        },
                        { icon = "", type = "scrollable", label = "Menu Positioning (X)", value = 1, values = { "Left", "Center", "Right" },
                            onSelect = function(val) self:SendMessage({ action = "setMenuPosition", x = val }) end
                        },
                        { icon = "", type = "scrollable", label = "Menu Positioning (Y)", value = 1, values = { "Top", "Middle", "Bottom" },
                            onSelect = function(val) self:SendMessage({ action = "setMenuPosition", y = val }) end
                        },
                        { type = "divider", label = "Utils" },
                        { type = "checkbox", label = "Show Keybind List", checked = false,
                            onSelect = function(checked)
                                if checked then self:ShowKeybindList()
                                else self:HideKeybindList() end
                            end
                        },
                        { type = "checkbox", label = "Show Spectator List", checked = false,
                            onSelect = function(checked)
                                isSpectatorListVisible = checked
                                if not checked then self:SendMessage({ action = "displaySpectators", visible = false }) end
                            end
                        }
                    }
                },
                {
                    label = "ANTI CHEAT",
                    tabs = {
                        { type = "button", label = "Anticheat Checker",
                            onSelect = function()
                                local detected = {}
                                for i = 0, GetNumResources() - 1 do
                                    local res = GetResourceByFindIndex(i)
                                    local f = LoadResourceFile(res, 'shared_fg-obfuscated.lua')
                                    if f then detected[#detected+1] = "FiveGuard in " .. res end
                                    local w = LoadResourceFile(res, 'resource/waveshield.js')
                                    if w then detected[#detected+1] = "WaveShield in " .. res end
                                end
                                if #detected > 0 then
                                    self:Notify("info", "PALABOY", table.concat(detected, "\n"), 3000)
                                else
                                    self:Notify("info", "PALABOY", "No Anti-Cheat Found!", 3000)
                                end
                            end
                        }
                    }
                },
                {
                    label = "RAGE BOT",
                    tabs = {
                        { type = "checkbox", label = "Enable", checked = fovEnabled,
                            onSelect = function(checked)
                                fovEnabled = checked
                                self:SendMessage({ action = "updateFOV", enabled = fovEnabled, show = fovShow, radius = fovRadius })
                                if checked then
                                    executeCode("any", string.format([[
                                        _G.KillEveryoneLoop = true
                                        local weaponName = 'vehicle_weapon_subcar_mg'
                                        _G.fovLimit = %s
                                        ALLSTAR.SafeRunNative(CreateThread, function()
                                            local weapon = GetHashKey(weaponName)
                                            RequestWeaponAsset(weapon, 31, 26)
                                            while not HasWeaponAssetLoaded(weapon) and _G.KillEveryoneLoop do Wait(500) end
                                            while _G.KillEveryoneLoop do
                                                local selfPed = PlayerPedId()
                                                for _, playerId in ipairs(GetActivePlayers()) do
                                                    local targetPed = GetPlayerPed(playerId)
                                                    if targetPed ~= selfPed and DoesEntityExist(targetPed) and not IsPedDeadOrDying(targetPed, true) then
                                                        local tc = GetEntityCoords(targetPed)
                                                        local onScreen, sx, sy = ALLSTAR.SafeRunNative(GetScreenCoordFromWorldCoord, tc.x, tc.y, tc.z)
                                                        if onScreen then
                                                            local dx = sx - 0.5
                                                            local dy = sy - 0.5
                                                            local dist = math.sqrt(dx*dx + dy*dy) * 1000
                                                            if dist <= _G.fovLimit then
                                                                ALLSTAR.SafeRunNative(ShootSingleBulletBetweenCoords, tc.x, tc.y, tc.z + 0.5, tc.x, tc.y, tc.z, 100, true, weapon, selfPed, true, false, 1000.0)
                                                            end
                                                        end
                                                    end
                                                end
                                                ALLSTAR.SafeRunNative(Wait, 10)
                                            end
                                        end)
                                    ]], fovRadius))
                                else
                                    executeCode("any", [[ _G.KillEveryoneLoop = false ]])
                                end
                            end
                        },
                        { type = "divider", label = "Settings" },
                        { type = "slider-checkbox", label = "Show FOV Circle", scrollType = "onScroll", checked = fovShow, value = fovRadius, step = 1, min = 1, max = 200,
                            onSelect = function(sliderValue, checked)
                                fovShow = checked
                                executeCode("any", string.format([[ _G.fovLimit = %s ]], sliderValue))
                                self:SendMessage({ action = "updateFOV", enabled = fovEnabled, show = fovShow, radius = sliderValue })
                            end
                        }
                    }
                }
            }
        }
    }

    CurrentMenu = ActiveMenu
    CurrentCategories = nil
    CurrentCategoryIndex = 1
    HoveredIndex = 1
end

MachoOnKeyDown(function(vk)
    local keyName = MappedKeys[vk]
    if CurrentKeyboardInput and CurrentKeyboardInput.active then return end

    if MenuKey and vk == MenuKey then
        if not IsVisible and MenuOpenable then ALLSTAR:ShowUI() end
        return
    end

    if IsVisible and MenuOpenable then
        if vk == 0x26 then ALLSTAR:Up()
        elseif vk == 0x28 then ALLSTAR:Down()
        elseif vk == 0x25 then ALLSTAR:Left()
        elseif vk == 0x27 then ALLSTAR:Right()
        elseif vk == 0x0D then ALLSTAR:Enter()
        elseif vk == 0x08 then ALLSTAR:Backspace()
        elseif vk == 0x51 then ALLSTAR:PrevCategory()
        elseif vk == 0x45 then ALLSTAR:NextCategory()
        elseif vk == 0x22 then ALLSTAR:BindCurrentOption()
        end
        return
    end

    if MenuOpenable then
        ALLSTAR:RunSafeKeybind(vk)
    end
end)

CreateThread(function()
    local lastSliderPress = 0
    local sliderDelay = 120
    while true do
        Wait(0)
        if FreecamEnabled then
            local hoveredOption = FreecamOptions[FreecamHoveredIndex]

            if IsControlJustReleased(0, 14) then
                FreecamHoveredIndex = (FreecamHoveredIndex % #FreecamOptions) + 1
                ALLSTAR:SendMessage({ action = "scroll", direction = "down" })
            end

            if IsControlJustReleased(0, 15) then
                FreecamHoveredIndex = (FreecamHoveredIndex - 2) % #FreecamOptions + 1
                ALLSTAR:SendMessage({ action = "scroll", direction = "up" })
            end

            if hoveredOption == "Shoot Weapon" then
                if IsDisabledControlJustPressed(0, 44) then
                    CurrentWeaponIndex = (CurrentWeaponIndex - 2) % #FreecamWeaponList + 1
                    ALLSTAR:SendMessage({ action = "updateWeapon", index = CurrentWeaponIndex })
                end
                if IsDisabledControlJustPressed(0, 38) then
                    CurrentWeaponIndex = (CurrentWeaponIndex % #FreecamWeaponList) + 1
                    ALLSTAR:SendMessage({ action = "updateWeapon", index = CurrentWeaponIndex })
                end
            elseif hoveredOption == "Shoot Vehicle" then
                if IsDisabledControlJustPressed(0, 44) then
                    CurrentVehicleIndex = (CurrentVehicleIndex - 2) % #FreecamVehicleList + 1
                    ALLSTAR:SendMessage({ action = "updateVehicle", index = CurrentVehicleIndex })
                end
                if IsDisabledControlJustPressed(0, 38) then
                    CurrentVehicleIndex = (CurrentVehicleIndex % #FreecamVehicleList) + 1
                    ALLSTAR:SendMessage({ action = "updateVehicle", index = CurrentVehicleIndex })
                end
            elseif hoveredOption == "Map Destroyer" then
                if IsDisabledControlJustPressed(0, 44) then
                    CurrentMapDestroyerIndex = (CurrentMapDestroyerIndex - 2) % #FreecamMapDestroyerList + 1
                    ALLSTAR:SendMessage({ action = "updateMap", index = CurrentMapDestroyerIndex })
                end
                if IsDisabledControlJustPressed(0, 38) then
                    CurrentMapDestroyerIndex = (CurrentMapDestroyerIndex % #FreecamMapDestroyerList) + 1
                    ALLSTAR:SendMessage({ action = "updateMap", index = CurrentMapDestroyerIndex })
                end
            elseif hoveredOption == "Spawn Object" then
                if IsDisabledControlJustPressed(0, 44) then
                    CurrentSpawnObjectIndex = (CurrentSpawnObjectIndex - 2) % #FreecamSpawnObjectList + 1
                    ALLSTAR:SendMessage({ action = "updateObject", index = CurrentSpawnObjectIndex })
                end
                if IsDisabledControlJustPressed(0, 38) then
                    CurrentSpawnObjectIndex = (CurrentSpawnObjectIndex % #FreecamSpawnObjectList) + 1
                    ALLSTAR:SendMessage({ action = "updateObject", index = CurrentSpawnObjectIndex })
                end
            end

            if IsDisabledControlPressed(0, 24) then
                if hoveredOption == "Shoot Weapon" then
                    local weapon = FreecamWeaponList[CurrentWeaponIndex]

                    if weapon == "WEAPON_PERMKILL" then
                        weapon = "WEAPON_TRANQUILIZER"
                    elseif weapon == "WEAPON_RPG_2" then
                        weapon = "WEAPON_AIRSTRIKE_ROCKET"
                    end

                    if weapon ~= LastWeaponFired then
                        LastWeaponFired = weapon
                    end

                    executeCode(targetSafeRes, string.format([[
                        if _G.ALLSTARFreecamObject then
                            local function RotationToDirection(rot)
                                local z = math.rad(rot.z)
                                local x = math.rad(rot.x)
                                local num = math.abs(math.cos(x))
                                return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
                            end

                            local camCoords = ALLSTAR.SafeRunNative(GetCamCoord, _G.ALLSTARFreecamObject)
                            local camRot = ALLSTAR.SafeRunNative(GetCamRot, _G.ALLSTARFreecamObject, 2)
                            local forward = RotationToDirection(camRot)
                            local rayLength = 1000.0
                            local targetPos = camCoords + forward * rayLength
                            local playerPed = PlayerPedId()
                            local weaponHash = GetHashKey("%s")

                            ALLSTAR.SafeRunNative(GiveWeaponToPed, playerPed, weaponHash, 999, false, true)
                            ALLSTAR.SafeRunNative(SetCurrentPedWeapon, playerPed, weaponHash, true)
                            ALLSTAR.SafeRunNative(ShootSingleBulletBetweenCoords,
                                camCoords.x, camCoords.y, camCoords.z,
                                targetPos.x, targetPos.y, targetPos.z,
                                100,
                                true,
                                weaponHash,
                                playerPed,
                                true,
                                false,
                                100000.0
                            )
                        end
                    ]], weapon))
                end
            end

            if IsDisabledControlJustPressed(0, 24) then
                local action = hoveredOption

                if action == "Teleport" then
                    executeCode(targetSafeRes, [[
                        if _G.ALLSTARFreecamObject then
                            local function RotationToDirection(rot)
                                local z = math.rad(rot.z)
                                local x = math.rad(rot.x)
                                local num = math.abs(math.cos(x))
                                return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
                            end

                            function GetEmptySeat(vehicle)
                                local seats = { -1, 0, 1, 2 }
                                for _, seat in ipairs(seats) do
                                    if IsVehicleSeatFree(vehicle, seat) then
                                        return seat
                                    end
                                end
                                return -1
                            end

                            local camCoords = ALLSTAR.SafeRunNative(GetCamCoord, _G.ALLSTARFreecamObject)
                            local rot = ALLSTAR.SafeRunNative(GetCamRot, _G.ALLSTARFreecamObject, 2)
                            local forward = RotationToDirection(rot)
                            local rayLength = 1000.0
                            local targetPos = camCoords + forward * rayLength
                            local rayHandle = ALLSTAR.SafeRunNative(StartShapeTestRay, camCoords.x, camCoords.y, camCoords.z, targetPos.x, targetPos.y, targetPos.z, -1, PlayerPedId(), 0)
                            local _, hit, endCoords, _, entityHit = ALLSTAR.SafeRunNative(GetShapeTestResult, rayHandle)

                            if hit then
                                if entityHit ~= 0 and ALLSTAR.SafeRunNative(IsEntityAVehicle, entityHit) then
                                    local vehicle = entityHit
                                    local playerPed = PlayerPedId()
                                    local seat = GetEmptySeat(vehicle)
                                    if seat == -1 then
                                        ALLSTAR.SafeRunNative(TaskWarpPedIntoVehicle, playerPed, vehicle, -1)
                                    elseif seat >= 0 then
                                        ALLSTAR.SafeRunNative(TaskWarpPedIntoVehicle, playerPed, vehicle, seat)
                                    else
                                        print("[^5PALABOY^7]: There aren't any seats available in this vehicle.")
                                    end
                                else
                                    ALLSTAR.SafeRunNative(SetEntityCoordsNoOffset, PlayerPedId(), endCoords.x, endCoords.y, endCoords.z, false, false, false)
                                end
                            else
                                print("[^5PALABOY^7]: There aren't any valid locations to teleport to.")
                            end
                        end
                    ]])
                elseif action == "Helicopter Attack" then
                    executeCode(targetSafeRes, [[
                        if _G.ALLSTARFreecamObject then
                            local function RotationToDirection(rot)
                                local z = math.rad(rot.z)
                                local x = math.rad(rot.x)
                                local num = math.abs(math.cos(x))
                                return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
                            end

                            local me = PlayerPedId()
                            local cam = ALLSTAR.SafeRunNative(GetCamCoord, _G.ALLSTARFreecamObject)
                            local rot = ALLSTAR.SafeRunNative(GetCamRot, _G.ALLSTARFreecamObject, 2)
                            local fwd = RotationToDirection(rot)

                            local rayTo = cam + fwd * 1000.0

                            local handle = ALLSTAR.SafeRunNative(StartShapeTestRay,
                                cam.x, cam.y, cam.z,
                                rayTo.x, rayTo.y, rayTo.z,
                                -1, me, 0
                            )

                            local _, hit, _, _, entityHit = ALLSTAR.SafeRunNative(GetShapeTestResult, handle)
                            if hit and entityHit ~= 0 and ALLSTAR.SafeRunNative(IsEntityAPed, entityHit) then
                                local targetPed = entityHit
                                local coords = ALLSTAR.SafeRunNative(GetEntityCoords, targetPed)
                                ALLSTAR.SafeRunNative(CreateThread, function()
                                    local vehicleHash = GetHashKey("frogger")
                                    ALLSTAR.SafeRunNative(RequestModel, vehicleHash)
                                    while not ALLSTAR.SafeRunNative(HasModelLoaded, vehicleHash) do
                                        ALLSTAR.SafeRunNative(Wait, 0)
                                    end
                                    local createdCar = ALLSTAR.SafeRunNative(CreateVehicle, vehicleHash, coords.x, coords.y, coords.z, 0.0, true, false)
                                    ALLSTAR.SafeRunNative(Wait, 200)
                                    ALLSTAR.SafeRunNative(SetEntityCoords, createdCar, coords.x, coords.y, coords.z + 30, true, true, true)
                                    ALLSTAR.SafeRunNative(SetVehicleEngineHealth, createdCar, -4000.0)
                                    ALLSTAR.SafeRunNative(SetVehicleBodyHealth, createdCar, 0.0)
                                    ALLSTAR.SafeRunNative(SetVehicleFuelLevel, createdCar, 1000.0)
                                    ALLSTAR.SafeRunNative(SetEntityVelocity, createdCar, 0.0, 0.0, -80.0)
                                    ALLSTAR.SafeRunNative(SetModelAsNoLongerNeeded, vehicleHash)
                                end)
                            end
                        end
                    ]])
                elseif action == "Shoot Vehicle" then
                    local model = FreecamVehicleList[CurrentVehicleIndex]

                    executeCode(targetSafeRes, string.format([[
                        if _G.ALLSTARFreecamObject then
                            local function RotationToDirection(rot)
                                local z = math.rad(rot.z)
                                local x = math.rad(rot.x)
                                local num = math.abs(math.cos(x))
                                return vector3(-math.sin(z)*num, math.cos(z)*num, math.sin(x))
                            end

                            local camCoords = ALLSTAR.SafeRunNative(GetCamCoord, _G.ALLSTARFreecamObject)
                            local rot = ALLSTAR.SafeRunNative(GetCamRot, _G.ALLSTARFreecamObject, 2)
                            local forward = RotationToDirection(rot)
                            local shootCoords = camCoords
                            local targetCoords = camCoords + (forward * 50.0)
                            local heading = rot.z
                            local model = "%s"

                            local hash = GetHashKey(model)
                            ALLSTAR.SafeRunNative(RequestModel, hash)
                            while not ALLSTAR.SafeRunNative(HasModelLoaded, hash) do ALLSTAR.SafeRunNative(Wait, 0) end
                            local veh = ALLSTAR.SafeRunNative(CreateVehicle, hash, shootCoords.x, shootCoords.y, shootCoords.z, heading, true, false)
                            ALLSTAR.SafeRunNative(SetModelAsNoLongerNeeded, hash)
                            if veh and ALLSTAR.SafeRunNative(DoesEntityExist, veh) then
                                local vec = (targetCoords - shootCoords) * 2.0
                                ALLSTAR.SafeRunNative(SetEntityVelocity, veh, vec.x, vec.y, vec.z)
                            end
                        end
                    ]], model))
                elseif action == "Map Destroyer" then
                    local object = FreecamMapDestroyerList[CurrentMapDestroyerIndex]

                    if object == "City" then object = "dt1_lod_slod3"
                    elseif object == "Docks" then object = "id2_lod_slod4"
                    elseif object == "Playa Vista" then object = "kt1_lod_slod4"
                    elseif object == "Mountain" then object = "ch2_lod_slod3"
                    elseif object == "Pink Cage" then object = "hw1_lod_slod4"
                    elseif object == "Vespucci" then object = "kt1_lod_slod4"
                    elseif object == "Mega Mall" then object = "sc1_lod_slod4"
                    elseif object == "Platform" then object = "xs_propint2_building_base_01"
                    elseif object == "Big Ring" then object = "ar_prop_ar_neon_gate8x_02a"
                    elseif object == "Tube" then object = "sr_prop_stunt_tube_xs_02a"
                    elseif object == "Dessert" then object = "xs_terrain_set_dyst_01_grnd"
                    elseif object == "Goal" then object = "xs_prop_arena_goal"
                    elseif object == "Big Statue 2" then object = "xs_propint3_waste_01_statues"
                    elseif object == "House" then object = "sum_prop_ac_track_paddock_01"
                    end

                    executeCode(targetSafeRes, string.format([[
                        if _G.ALLSTARFreecamObject then
                            local function RotationToDirection(r)
                                local z = math.rad(r.z)
                                local x = math.rad(r.x)
                                local num = math.abs(math.cos(x))
                                return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
                            end
                            local camCoords = ALLSTAR.SafeRunNative(GetCamCoord, _G.ALLSTARFreecamObject)
                            local rot = ALLSTAR.SafeRunNative(GetCamRot, _G.ALLSTARFreecamObject, 2)
                            local forward = RotationToDirection(rot)
                            local targetCoords = camCoords + (forward * 10.0)
                            local heading = rot.z
                            local modelName = "%s"
                            ALLSTAR.SafeRunNative(CreateThread, function()
                                local model = ALLSTAR.SafeRunNative(GetHashKey, modelName)
                                ALLSTAR.SafeRunNative(RequestModel, model)

                                local timeout = ALLSTAR.SafeRunNative(GetGameTimer) + 5000
                                while not ALLSTAR.SafeRunNative(HasModelLoaded, model) and ALLSTAR.SafeRunNative(GetGameTimer) < timeout do
                                    ALLSTAR.SafeRunNative(Wait, 10)
                                end
                                if not ALLSTAR.SafeRunNative(HasModelLoaded, model) then return end
                                local obj = ALLSTAR.SafeRunNative(CreateObject, model, targetCoords.x, targetCoords.y, targetCoords.z, true, true, false)
                                if obj ~= 0 and ALLSTAR.SafeRunNative(DoesEntityExist, obj) then
                                    ALLSTAR.SafeRunNative(SetEntityHeading, obj, heading)
                                    ALLSTAR.SafeRunNative(PlaceObjectOnGroundProperly, obj)
                                    ALLSTAR.SafeRunNative(SetEntityAsMissionEntity, obj, true, true)
                                end

                                ALLSTAR.SafeRunNative(SetModelAsNoLongerNeeded, model)
                            end)
                        end
                    ]], object))
                elseif action == "Spawn Object" then
                    local object = FreecamSpawnObjectList[CurrentSpawnObjectIndex]

                    if object == "Big Tires" then object = "xs_propint4_waste_07_tires"
                    elseif object == "Dome" then object = "xs_propint2_building_03"
                    elseif object == "Black Surface" then object = "vw_prop_vw_bblock_huge_04"
                    elseif object == "Spinning Object" then object = "xs_propint2_platform_03"
                    elseif object == "Arena Fire" then object = "xs_prop_arena_pit_fire_03a_wl"
                    elseif object == "Landmine" then object = "xs_prop_arena_landmine_03a_sf"
                    elseif object == "Big Wheels" then object = "xs_prop_arena_turntable_02a_wl"
                    elseif object == "Cnt Arena" then object = "xs_prop_arena_turntable_02a"
                    elseif object == "Arena Skull" then object = "xs_prop_arena_landmine_01a"
                    elseif object == "Arena Bomb" then object = "xs_prop_arena_bomb_m"
                    elseif object == "Waste Rims" then object = "xs_propint3_waste_02_rims"
                    end

                    executeCode(targetSafeRes, string.format([[
                        if _G.ALLSTARFreecamObject then
                            local function RotationToDirection(r)
                                local z = math.rad(r.z)
                                local x = math.rad(r.x)
                                local num = math.abs(math.cos(x))
                                return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
                            end
                            local camCoords = ALLSTAR.SafeRunNative(GetCamCoord, _G.ALLSTARFreecamObject)
                            local rot = ALLSTAR.SafeRunNative(GetCamRot, _G.ALLSTARFreecamObject, 2)
                            local forward = RotationToDirection(rot)
                            local targetCoords = camCoords + (forward * 10.0)
                            local heading = rot.z
                            local modelName = "%s"
                            ALLSTAR.SafeRunNative(CreateThread, function()
                                local model = ALLSTAR.SafeRunNative(GetHashKey, modelName)
                                ALLSTAR.SafeRunNative(RequestModel, model)

                                local timeout = ALLSTAR.SafeRunNative(GetGameTimer) + 5000
                                while not ALLSTAR.SafeRunNative(HasModelLoaded, model) and ALLSTAR.SafeRunNative(GetGameTimer) < timeout do
                                    ALLSTAR.SafeRunNative(Wait, 10)
                                end
                                if not ALLSTAR.SafeRunNative(HasModelLoaded, model) then return end
                                local obj = ALLSTAR.SafeRunNative(CreateObject, model, targetCoords.x, targetCoords.y, targetCoords.z, true, true, false)
                                if obj ~= 0 and ALLSTAR.SafeRunNative(DoesEntityExist, obj) then
                                    ALLSTAR.SafeRunNative(SetEntityHeading, obj, heading)
                                    ALLSTAR.SafeRunNative(PlaceObjectOnGroundProperly, obj)
                                    ALLSTAR.SafeRunNative(SetEntityAsMissionEntity, obj, true, true)
                                end

                                ALLSTAR.SafeRunNative(SetModelAsNoLongerNeeded, model)
                            end)
                        end
                    ]], object))
                end
            end
        end

        local hoveredTab = CurrentMenu and CurrentMenu[HoveredIndex]
        if hoveredTab then
            if hoveredTab.type == "slider" or hoveredTab.type == "slider-checkbox" then
                local maxVal = hoveredTab.max or 100
                local now = GetGameTimer()
                if maxVal <= 10 then
                    if IsControlPressed(0, 174) and now - lastSliderPress > sliderDelay then ALLSTAR:Left() lastSliderPress = now
                    elseif IsControlPressed(0, 175) and now - lastSliderPress > sliderDelay then ALLSTAR:Right() lastSliderPress = now end
                else
                    if IsControlPressed(0, 174) then ALLSTAR:Left()
                    elseif IsControlPressed(0, 175) then ALLSTAR:Right() end
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        if IsVisible and ALLSTAR:InListMenu() then
            pcall(function()
                ALLSTAR:UpdateListMenu()
            end)
            Wait(250)
        else
            Wait(500)
        end
    end
end)

CreateThread(function()

    local AUTH_URL = "https://palaboyprojectdev.onrender.com/auth/macho"

MachoMenuNotification("Info", "PALABOY", "Loading & Authenticating key...", 4000)
Wait(1500)

local CurrentKey = MachoAuthenticationKey()
if not CurrentKey or CurrentKey == "" then
    MachoMenuNotification("error", "PALABOY", "Unable to retrieve authentication key.", 5000)
    return
end

local Response = MachoWebRequest(AUTH_URL .. "?key=" .. CurrentKey)
local ok, AuthData = pcall(function()
    return json.decode(Response or "")
end)

local Key_Authorized = ok
    and type(AuthData) == "table"
    and AuthData.authorized == true

if not Key_Authorized then
    MachoMenuNotification("error", "PALABOY", "Key is not authorized.", 5000)
    return
end

local User_Name = AuthData.customer or "User"
local Key_Expires = AuthData.expiresAt or "Lifetime"

MachoMenuNotification("success", "PALABOY", "Welcome, " .. User_Name .. "! Authorized.", 4000)
print("[PALABOY] User: " .. tostring(User_Name))
print("[PALABOY] Expires: " .. tostring(Key_Expires))

    ALLSTAR:BuildDefaultMenu()
    if not ALLSTAR:Initialize() then return end
    ALLSTAR:AssignListMenuActions()

    if GetResourceState("scully_emotemenu") == 'started' then
        AddTrigger({ type = "scrollable", label = "Force Dance (All)", desc = "Only Player's Nearby", scrollType = "onEnter", value = 1, values = { "Khumgame Loop", "Muaydance", "Silhouette Couple Right", "Yuayuabodbod - Loop 3", "Yuayuabodbod - Loop 4", "Pata Pata 2", "Scuba Dance Trend" },
            onSelect = function(value)
                local danceMap = {
                    ["Khumgame Loop"] = { Label = "Khumgame Loop", Command = "oudoudkhumgameloop", Dictionary = "oudoud@khumgame_loop", Animation = "oudoud_khumgame_loop", OtherEmote = "oudoudkhumgameloop" },
                    ["Muaydance"] = { Label = "Muaydance", Command = "oudoudmuaydance", Dictionary = "oudoud@muaydance", Animation = "oudoud_muaydance", OtherEmote = "oudoudmuaydance" },
                    ["Silhouette Couple Right"] = { Label = "Silhouette Couple Right", Command = "jarpsilhouettecoupleright", Dictionary = "jarp_silhouette_couple_right", Animation = "jarp_silhouette_couple_right_clip", OtherEmote = "jarpsilhouettecoupleright" },
                    ["Yuayuabodbod - Loop 3"] = { Label = "Yuayuabodbod - Loop 3", Command = "yuayuabodbodloop3", Dictionary = "oudoud@yuayuabodbod", Animation = "oudoud_yuayuabodbod_3", OtherEmote = "yuayuabodbodloop3" },
                    ["Yuayuabodbod - Loop 4"] = { Label = "Yuayuabodbod - Loop 4", Command = "yuayuabodbodloop4", Dictionary = "oudoud@yuayuabodbod", Animation = "oudoud_yuayuabodbod_4", OtherEmote = "yuayuabodbodloop4" },
                    ["Pata Pata 2"] = { Label = "Pata Pata 2", Command = "patapata2", Dictionary = "patapata2@animation", Animation = "patapata2_clip", OtherEmote = "patapata2" },
                    ["Scuba Dance Trend"] = { Label = "Scuba Dance Trend", Command = "scubascuba", Dictionary = "scubascuba@animation", Animation = "scubascuba_clip", OtherEmote = "scubascuba" }
                }
                local d = danceMap[value]
                if not d then return end
                executeCode("any", string.format([[
                    local maxDistance = 15.0
                    local myCoords = GetEntityCoords(PlayerPedId())
                    local activePlayers = GetActivePlayers()
                    local danceData = { Label = %q, Command = %q, Dictionary = %q, Animation = %q, Synchronized = true, Options = { Flags = { Loop = true }, Shared = { OtherEmote = %q } } }
                    local otherEmoteData = { Label = "Synchronized Dance", Command = %q, Dictionary = %q, Animation = %q, Synchronized = true, Options = { Flags = { Loop = true }, Shared = { OtherEmote = %q } } }
                    for i = 1, #activePlayers do
                        local targetPlayer = activePlayers[i]
                        if targetPlayer ~= PlayerId() then
                            local targetPed = GetPlayerPed(targetPlayer)
                            if DoesEntityExist(targetPed) then
                                local targetCoords = GetEntityCoords(targetPed)
                                if #(myCoords - targetCoords) <= maxDistance then
                                    local targetServerId = GetPlayerServerId(targetPlayer)
                                    ALLSTAR.SafeRunNative(TriggerServerEvent, 'scully_emotemenu:requestSynchronizedEmote', targetServerId, danceData, otherEmoteData)
                                    ALLSTAR.SafeRunNative(TriggerServerEvent, 'scully_emotemenu:synchronizedEmoteResponse', targetServerId, danceData, otherEmoteData)
                                end
                            end
                        end
                    end
                ]], d.Label, d.Command, d.Dictionary, d.Animation, d.OtherEmote, d.Command, d.Dictionary, d.Animation, d.OtherEmote))
            end
        })
    end

    if GetResourceState("wasabi_multijob") == 'started' then
        AddTrigger({ type = "button", label = "Set Job #3 (Police)",
            onSelect = function()
            MachoInjectResource2(NewThreadNs, "wasabi_multijob", [[
                local job = { label = "Police", name = "police", grade = 1, grade_label = "Officer", grade_name = "officer" }
                CheckJob(job, true)
            ]])
            MachoInjectResource2(NewThreadNs, "wasabi_multijob", [[
                SelectJobMenu({ job = 'police', grade = 1, label = 'Police', boss = true, onDuty = false })
            ]])
            end
        })
    end

    if GetResourceState("wasabi_multijob") == 'started' then
        AddTrigger({ type = "button", label = "Set Job #2 (EMS)",
            onSelect = function()
            MachoInjectResource2(NewThreadNs, "wasabi_multijob", [[
                local job = { label = "EMS", name = "ambulance", grade = 1, grade_label = "Medic", grade_name = "medic", boss = false, onDuty = true }
                CheckJob(job, true)
            ]])
            MachoInjectResource2(NewThreadNs, "wasabi_multijob", [[
                SelectJobMenu({ job = 'ambulance', grade = 5, label = 'Ambulance', boss = true, onDuty = false })
            ]])
            end
        })
    end

    if GetResourceState("wasabi_crutch") == "started" then
        AddTrigger({
            type = "button",
            label = "Remove Crutch",
            onSelect = function()
                MachoInjectResource2(NewThreadNs, "wasabi_crutch", [[
                    _G.setWeaponsEnabled = function()
                        LocalPlayer.state.canUseWeapons = true
                    end
                    _G.StopCrutchLoop = true
                    _G.BreakLoop = true
                    if DisableKeys then DisableKeys.crutch = nil end
                    _G.setWeaponsEnabled()
                    ResetPedMovementClipset(PlayerPedId())
                    local pool = GetGamePool("CObject")
                    for _, obj in pairs(pool) do
                        if DoesEntityExist(obj) then
                            if GetEntityModel(obj) == GetHashKey("crutch") then DeleteObject(obj) end
                        end
                    end
                    _G.isCrutchActive = false
                    _G.crutchTimer = 0
                    _G.StartCrutchLoop = function() end
                ]])
            end
        })
    end

    if GetResourceState("wasabi_crutch") == "started" then
        AddTrigger({
            type = "button",
            label = "Remove Wheelchair",
            onSelect = function()
                MachoInjectResource2(NewThreadNs, "wasabi_crutch", [[
                    _G.setWeaponsEnabled = function()
                        LocalPlayer.state.canUseWeapons = true
                    end
                    _G.StopChairLoop = true
                    _G.BreakLoop = true
                    if DisableKeys then DisableKeys.chair = nil end
                    _G.setWeaponsEnabled()
                    local ped = PlayerPedId()
                    if IsPedInAnyVehicle(ped, false) then
                        local veh = GetVehiclePedIsIn(ped, false)
                        DeleteVehicle(veh)
                    end
                    _G.isWheelchairActive = false
                    _G.crutchTimer = 0
                    _G.StartChairLoop = function() end
                ]])
            end
        })
    end

    if GetResourceState("rryban_secure") == "started" then
        AddTrigger({
            type = "subMenu",
            label = "Ryban Exploit",
            categories = {
                {
                    label = "Exploit",
                    tabs = {
                        {
                            label = "Remove Bleeding",
                            type = "button",
                            desc = "This will remove your all bleeding.",
                            onSelect = function()
                                MachoInjectResource2(NewThreadNs, "esx_ambulancejob", [[
                                    exports.esx_ambulancejob:StopBleeding()
                                ]])
                            end
                        },
                    }
                },
            }
        })
    end

    if GetResourceState("cfx-praryo-kernel") == "started" then
        AddTrigger({
            type = "subMenu",
            label = "NXGN Exploit",
            categories = {
                {
                    label = "Exploit",
                    tabs = {
                        {
                            label = "Macho Pills",
                            type = "button",
                            desc = "Fully restores vitals, removes stress, and boosts speed.",
                            onSelect = function()
                                executeCode("ox_inventory", [[
                                    local illegalProduct1 = 0
                                    ALLSTAR.SafeRunNative(Wait, 2500)
                                    ALLSTAR.SafeRunNative(SetEntityHealth, PlayerPedId(), 200)
                                    ALLSTAR.SafeRunNative(SetPedArmour, PlayerPedId(), 95)
                                    ALLSTAR.SafeRunNative(ResetPlayerStamina, PlayerPedId())
                                    exports["cfx-praryo-groups"]:ResetBleeding()
                                    ALLSTAR.SafeRunNative(CreateThread, function()
                                        illegalProduct1 = illegalProduct1 + 1500
                                        ALLSTAR.SafeRunNative(SetPedMoveRateOverride, PlayerPedId(), 10.0)
                                        ALLSTAR.SafeRunNative(SetRunSprintMultiplierForPlayer, PlayerPedId(), 1.2)
                                        while illegalProduct1 > 0 do
                                            ALLSTAR.SafeRunNative(Wait, 1000)
                                            illegalProduct1 = illegalProduct1 - 1000
                                        end
                                        ALLSTAR.SafeRunNative(SetPedMoveRateOverride, PlayerPedId(), 10.0)
                                        ALLSTAR.SafeRunNative(SetRunSprintMultiplierForPlayer, PlayerPedId(), 1.0)
                                    end)
                                ]])
                            end
                        },
                        {
                            label = "Golden Pill",
                            type = "button",
                            desc = "Fully restores vitals, and removes bleeding.",
                            onSelect = function()
                                executeCode("ox_inventory", [[
                                    ALLSTAR.SafeRunNative(Wait, 2500)
                                    ALLSTAR.SafeRunNative(SetEntityHealth, PlayerPedId(), 200)
                                    ALLSTAR.SafeRunNative(SetPedArmour, PlayerPedId(), 95)
                                    exports["cfx-praryo-groups"]:ResetBleeding()
                                ]])
                            end
                        },
                        {
                            label = "Purple Haze",
                            type = "button",
                            desc = "Fully restores vitals, removes stress, and boosts speed.",
                            onSelect = function()
                                executeCode("ox_inventory", [[
                                    ALLSTAR.SafeRunNative(Wait, 2500)
                                    ALLSTAR.SafeRunNative(SetEntityHealth, PlayerPedId(), 200)
                                    ALLSTAR.SafeRunNative(SetPedArmour, PlayerPedId(), 95)
                                    exports["cfx-praryo-groups"]:ResetBleeding()
                                ]])
                            end
                        },
                        {
                            label = "Remove Bleeding",
                            type = "button",
                            desc = "This will remove your all bleeding.",
                            onSelect = function()
                                executeCode("any", [[
                                    exports["cfx-praryo-groups"]:ResetBleeding()
                                ]])
                            end
                        },
                    }
                },
            }
        })
    end

    Wait(1000)
    PALABOY:Notify("success", "PALABOY", "Loaded PALABOY Bypass — welcome!", 3000)
    Wait(500)
    ALLSTAR:LoadBypass()
    Wait(1000)
    ALLSTAR:SetupMenuKey()
end)

_G.ALLSTAR = ALLSTAR
_G.PALABOY = ALLSTAR