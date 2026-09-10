-- Octo Totem Timers - OctoWoW / Vanilla 1.12

local ADDON_PREFIX = "|cff33ff99Octo Totems:|r "
local ICON_SIZE = 34
local SIDE_ICON_SIZE = 26
local ICON_GAP = 5
local UPDATE_INTERVAL = 0.10
local slots = {}
local elapsed = 0
local display
local scanTip
local events
local initialized = false
local hookedCastSpell
local hookedCastSpellByName
local hookedUseAction
local shieldMaxCharges = {
    ["Water Shield"] = 3,
    ["Lightning Shield"] = 3,
    ["Earth Shield"] = 6
}
local EMPTY_SHIELD_TEXTURE = "Interface\\Icons\\Spell_Nature_LightningShield"
local shieldTextures = {
    ["Lightning Shield"] = "Interface\\Icons\\Spell_Nature_LightningShield",
    ["Water Shield"] = "Interface\\Icons\\Ability_Shaman_WaterShield",
    ["Earth Shield"] = "Interface\\Icons\\Spell_Nature_SkinofEarth"
}

-- Element order matches Blizzard's later TotemFrame: Fire, Earth, Water, Air.
local ELEMENTS = { "Fire", "Earth", "Water", "Air" }
local DISPLAY_ORDER = { 2, 3, 1, 4 }
local ELEMENT_COLORS = {
    { 0.55, 0.10, 0.05 },
    { 0.46, 0.24, 0.07 },
    { 0.05, 0.25, 0.55 },
    { 0.58, 0.61, 0.64 }
}
local EMPTY_TOTEM_TEXTURES = {
    "Interface\\Icons\\Spell_Fire_SearingTotem",
    "Interface\\Icons\\Spell_Nature_StrengthOfEarthTotem02",
    "Interface\\Icons\\Spell_Nature_ManaRegenTotem",
    "Interface\\Icons\\Spell_Nature_Windfury"
}
local WEAPON_ENCHANTS = {
    { "Rockbiter", "Rockbiter Weapon", "Interface\\Icons\\Spell_Nature_RockBiter" },
    { "Flametongue", "Flametongue Weapon", "Interface\\Icons\\Spell_Fire_FlameTounge" },
    { "Frostbrand", "Frostbrand Weapon", "Interface\\Icons\\Spell_Frost_FrostBrand" },
    { "Windfury", "Windfury Weapon", "Interface\\Icons\\Spell_Nature_Cyclone" }
}

-- Fallback durations are used only when a spell/action tooltip cannot be scanned.
local TOTEMS = {
    ["Searing Totem"] = { 1, 30 }, ["Fire Nova Totem"] = { 1, 5 },
    ["Magma Totem"] = { 1, 20 }, ["Flametongue Totem"] = { 1, 120 },
    ["Frost Resistance Totem"] = { 1, 120 },

    ["Stoneskin Totem"] = { 2, 120 }, ["Earthbind Totem"] = { 2, 45 },
    ["Stoneclaw Totem"] = { 2, 15 }, ["Strength of Earth Totem"] = { 2, 120 },
    ["Tremor Totem"] = { 2, 120 },

    ["Healing Stream Totem"] = { 3, 60 }, ["Mana Spring Totem"] = { 3, 60 },
    ["Disease Cleansing Totem"] = { 3, 120 }, ["Poison Cleansing Totem"] = { 3, 120 },
    ["Fire Resistance Totem"] = { 3, 120 }, ["Mana Tide Totem"] = { 3, 12 },

    ["Grounding Totem"] = { 4, 45 }, ["Windfury Totem"] = { 4, 120 },
    ["Grace of Air Totem"] = { 4, 120 }, ["Nature Resistance Totem"] = { 4, 120 },
    ["Windwall Totem"] = { 4, 120 }, ["Tranquil Air Totem"] = { 4, 120 },
    ["Sentry Totem"] = { 4, 300 }
}

local function Chat(message)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(ADDON_PREFIX .. message) end
end

local function CleanSpellName(name)
    if not name then return nil end
    name = string.gsub(name, "%s*%([Rr]ank%s+[^%)]*%)%s*$", "")
    return name
end

local function FormatTime(seconds)
    if seconds >= 60 then
        return string.format("%d:%02d", math.floor(seconds / 60), math.floor(math.mod(seconds, 60)))
    end
    if seconds >= 10 then return tostring(math.ceil(seconds)) end
    return string.format("%.1f", math.max(0, seconds))
end

local function ReadDurationFromTooltip()
    local index = 2
    while index <= 12 do
        local line = getglobal("OctoTotemScanTooltipTextLeft" .. index)
        local text = line and line:GetText()
        if text then
            local _, _, amount = string.find(text, "[Ll]asts?%s+(%d+)%s+[Ss]ec")
            if amount then return tonumber(amount) end
            _, _, amount = string.find(text, "[Ll]asts?%s+(%d+)%s+[Mm]in")
            if amount then return tonumber(amount) * 60 end
            _, _, amount = string.find(text, "for%s+(%d+)%s+[Ss]ec")
            if amount then return tonumber(amount) end
            _, _, amount = string.find(text, "for%s+(%d+)%s+[Mm]in")
            if amount then return tonumber(amount) * 60 end
        end
        index = index + 1
    end
    return nil
end

local function ReadChargesFromTooltip()
    local index = 2
    while index <= 12 do
        local left = getglobal("OctoTotemScanTooltipTextLeft" .. index)
        local right = getglobal("OctoTotemScanTooltipTextRight" .. index)
        local text = (left and left:GetText()) or ""
        local rightText = (right and right:GetText()) or ""
        local _, _, amount = string.find(text, "(%d+)%s+[Cc]harges?")
        if not amount then _, _, amount = string.find(rightText, "(%d+)%s+[Cc]harges?") end
        if amount then return tonumber(amount) end
        index = index + 1
    end
    return nil
end

local function RefreshShieldTextures()
    local spellIndex = 1
    while true do
        local spellName = GetSpellName(spellIndex, BOOKTYPE_SPELL)
        if not spellName then break end
        if shieldMaxCharges[spellName] then
            local texture = GetSpellTexture(spellIndex, BOOKTYPE_SPELL)
            if texture then shieldTextures[spellName] = texture end
        end
        spellIndex = spellIndex + 1
    end
end

local function ShieldNameFromTexture(texture)
    if not texture then return nil end
    local lowered = string.lower(texture)
    local name, shieldTexture
    for name, shieldTexture in pairs(shieldTextures) do
        if shieldTexture and lowered == string.lower(shieldTexture) then return name end
    end
    return nil
end

local function FindActiveShield()
    if not scanTip then return nil end
    local index = 1
    while index <= 32 do
        local texture, applications = UnitBuff("player", index)
        if not texture then break end
        scanTip:ClearLines()
        scanTip:SetUnitBuff("player", index)
        local tooltipTitle = OctoTotemScanTooltipTextLeft1 and OctoTotemScanTooltipTextLeft1:GetText()
        local title = ShieldNameFromTexture(texture) or CleanSpellName(tooltipTitle)
        if shieldMaxCharges[title] then
            local charges = tonumber(applications)
            if not charges or charges <= 0 then charges = ReadChargesFromTooltip() or 0 end
            return title, texture, charges, index
        end
        index = index + 1
    end
    return nil
end

local function FindSpellTexture(name)
    local i = 1
    while true do
        local spellName = GetSpellName(i, BOOKTYPE_SPELL)
        if not spellName then break end
        if spellName == name then return GetSpellTexture(i, BOOKTYPE_SPELL) end
        i = i + 1
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function FindWeaponEnchant()
    if not scanTip or not GetWeaponEnchantInfo then return nil end
    local hasMainHand, _, _, hasOffHand = GetWeaponEnchantInfo()
    local inventorySlot
    if hasMainHand then inventorySlot = 16 elseif hasOffHand then inventorySlot = 17 else return nil end

    scanTip:ClearLines()
    scanTip:SetInventoryItem("player", inventorySlot)
    local lineIndex = 2
    while lineIndex <= 12 do
        local line = getglobal("OctoTotemScanTooltipTextLeft" .. lineIndex)
        local text = line and line:GetText()
        if text then
            local enchantIndex
            for enchantIndex = 1, 4 do
                local enchant = WEAPON_ENCHANTS[enchantIndex]
                if string.find(text, enchant[1]) then
                    local texture = FindSpellTexture(enchant[2])
                    if texture == "Interface\\Icons\\INV_Misc_QuestionMark" then texture = enchant[3] end
                    return enchant[2], texture, inventorySlot
                end
            end
        end
        lineIndex = lineIndex + 1
    end
    return "Weapon Enchant", GetInventoryItemTexture("player", inventorySlot), inventorySlot
end

local function QueueTotem(name, duration, texture)
    name = CleanSpellName(name)
    if name == "Totemic Recall" or name == "Totemic Call" or name == "Recall Totems" then
        local slot
        for slot = 1, 4 do slots[slot] = nil end
        return
    end
    local data = name and TOTEMS[name]
    if not data then return end
    local now = GetTime()
    slots[data[1]] = {
        name = name,
        duration = duration or data[2],
        texture = texture or FindSpellTexture(name),
        startTime = now,
        expires = now + (duration or data[2])
    }
end

local function ScanSpell(spellIndex, bookType)
    if not scanTip or not spellIndex then return end
    scanTip:ClearLines()
    scanTip:SetSpell(spellIndex, bookType or BOOKTYPE_SPELL)
    local title = OctoTotemScanTooltipTextLeft1 and OctoTotemScanTooltipTextLeft1:GetText()
    QueueTotem(title, ReadDurationFromTooltip(), GetSpellTexture(spellIndex, bookType or BOOKTYPE_SPELL))
end

local function ScanAction(actionSlot)
    if not scanTip or not actionSlot then return end
    scanTip:ClearLines()
    scanTip:SetAction(actionSlot)
    local title = OctoTotemScanTooltipTextLeft1 and OctoTotemScanTooltipTextLeft1:GetText()
    QueueTotem(title, ReadDurationFromTooltip(), GetActionTexture(actionSlot))
end

local function EnsureCastingHooks()
    if CastSpell ~= hookedCastSpell then
        local original = CastSpell
        hookedCastSpell = function(spellIndex, bookType)
            ScanSpell(spellIndex, bookType)
            original(spellIndex, bookType)
        end
        CastSpell = hookedCastSpell
    end

    if CastSpellByName ~= hookedCastSpellByName then
        local original = CastSpellByName
        hookedCastSpellByName = function(spellName, onSelf)
            QueueTotem(spellName)
            original(spellName, onSelf)
        end
        CastSpellByName = hookedCastSpellByName
    end

    if UseAction ~= hookedUseAction then
        local original = UseAction
        hookedUseAction = function(actionSlot, checkCursor, onSelf)
            ScanAction(actionSlot)
            original(actionSlot, checkCursor, onSelf)
        end
        UseAction = hookedUseAction
    end
end

local function CreateDisplay()
    display = CreateFrame("Frame", "OctoTotemTimersFrame", UIParent)
    display:SetWidth(4 * ICON_SIZE + 3 * ICON_GAP + 16)
    display:SetHeight(ICON_SIZE + 40)
    display:SetPoint("CENTER", UIParent, "CENTER", 0, -150)
    display:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    display:SetBackdropColor(0, 0, 0, 0.82)
    display:SetBackdropBorderColor(0.30, 0.27, 0.22, 1)
    display:SetMovable(true)
    display:EnableMouse(true)
    display:RegisterForDrag("LeftButton")
    display:SetScript("OnDragStart", function()
        if not OctoTotemTimersDB.locked then this:StartMoving() end
    end)
    display:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
        local point, _, relativePoint, x, y = this:GetPoint()
        OctoTotemTimersDB.point = point
        OctoTotemTimersDB.relativePoint = relativePoint
        OctoTotemTimersDB.x = x
        OctoTotemTimersDB.y = y
    end)

    display.icons = {}
    local position
    for position = 1, 4 do
        local slot = DISPLAY_ORDER[position]
        local button = CreateFrame("Button", "OctoTotemTimer" .. slot, display)
        button:SetWidth(ICON_SIZE)
        button:SetHeight(ICON_SIZE)
        button:SetPoint("TOPLEFT", display, "TOPLEFT", 8 + (position - 1) * (ICON_SIZE + ICON_GAP), -22)
        button:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 10,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        button:SetBackdropColor(0.08, 0.07, 0.06, 1)
        button:SetBackdropBorderColor(0.56, 0.44, 0.28, 1)
        button.icon = button:CreateTexture(nil, "ARTWORK")
        button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4)
        button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 4)
        button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        button.time = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        button.time:SetPoint("TOP", button, "BOTTOM", 0, -1)
        button.time:SetTextColor(1, 0.82, 0)
        button.element = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        button.element:SetPoint("BOTTOM", button, "TOP", 0, 3)
        button.element:SetText(ELEMENTS[slot])
        button.element:SetTextColor(0.95, 0.90, 0.75)
        button.warning = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        button.warning:SetPoint("CENTER", button, "CENTER", 0, 0)
        button.warning:SetText("!")
        button.warning:SetTextColor(1, 0.05, 0.05)
        button.warning:Hide()
        button:SetScript("OnEnter", function()
            local data = slots[this.slot]
            if not data then return end
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetText(data.name)
            GameTooltip:AddLine(ELEMENTS[this.slot] .. " totem", 1, 1, 1)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        button.slot = slot
        button:Hide()
        display.icons[slot] = button
    end

    local shield = CreateFrame("Button", "OctoTotemShield", display)
    shield:SetWidth(SIDE_ICON_SIZE)
    shield:SetHeight(SIDE_ICON_SIZE)
    shield:SetPoint("BOTTOM", display, "TOPLEFT", 8 + ICON_SIZE / 2, 7)
    shield:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 9,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    shield:SetBackdropColor(0.08, 0.07, 0.06, 1)
    shield:SetBackdropBorderColor(0.50, 0.44, 0.34, 1)
    shield.icon = shield:CreateTexture(nil, "ARTWORK")
    shield.icon:SetPoint("TOPLEFT", shield, "TOPLEFT", 3, -3)
    shield.icon:SetPoint("BOTTOMRIGHT", shield, "BOTTOMRIGHT", -3, 3)
    shield.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    shield.count = shield:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge")
    shield.count:SetPoint("LEFT", shield, "RIGHT", 4, 0)
    shield.count:SetTextColor(1, 0.82, 0)
    shield.count:SetShadowColor(0, 0, 0, 1)
    shield.count:SetShadowOffset(1, -1)
    shield.warning = shield:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    shield.warning:SetPoint("CENTER", shield, "CENTER", 0, 0)
    shield.warning:SetText("!")
    shield.warning:SetTextColor(1, 0.05, 0.05)
    shield.warning:SetShadowColor(0, 0, 0, 1)
    shield.warning:SetShadowOffset(1, -1)
    shield.warning:Hide()
    shield:SetScript("OnEnter", function()
        if not this.buffIndex then return end
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetUnitBuff("player", this.buffIndex)
    end)
    shield:SetScript("OnLeave", function() GameTooltip:Hide() end)
    shield:Hide()
    display.shield = shield

    local weapon = CreateFrame("Button", "OctoTotemWeaponEnchant", display)
    weapon:SetWidth(SIDE_ICON_SIZE)
    weapon:SetHeight(SIDE_ICON_SIZE)
    weapon:SetPoint("BOTTOM", display, "TOPLEFT", 8 + 3 * (ICON_SIZE + ICON_GAP) + ICON_SIZE / 2, 7)
    weapon:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 9,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    weapon:SetBackdropColor(0.08, 0.07, 0.06, 1)
    weapon:SetBackdropBorderColor(0.50, 0.44, 0.34, 1)
    weapon.icon = weapon:CreateTexture(nil, "ARTWORK")
    weapon.icon:SetPoint("TOPLEFT", weapon, "TOPLEFT", 3, -3)
    weapon.icon:SetPoint("BOTTOMRIGHT", weapon, "BOTTOMRIGHT", -3, 3)
    weapon.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    weapon:SetScript("OnEnter", function()
        if not this.inventorySlot then return end
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetInventoryItem("player", this.inventorySlot)
    end)
    weapon:SetScript("OnLeave", function() GameTooltip:Hide() end)
    weapon:Hide()
    display.weapon = weapon

    display:ClearAllPoints()
    display:SetPoint(OctoTotemTimersDB.point or "CENTER", UIParent,
        OctoTotemTimersDB.relativePoint or "CENTER", OctoTotemTimersDB.x or 0, OctoTotemTimersDB.y or -150)
end

local function UpdateShield()
    if not display or not display.shield then return false end
    local name, texture, charges, buffIndex = FindActiveShield()
    if not name then
        display.shield.buffIndex = nil
        display.shield.icon:SetTexture(EMPTY_SHIELD_TEXTURE)
        display.shield.icon:SetVertexColor(0.35, 0.35, 0.35)
        display.shield.icon:SetAlpha(0.65)
        display.shield.count:SetText("")
        display.shield.warning:Show()
        display.shield:Show()
        return true
    end
    if charges > shieldMaxCharges[name] then shieldMaxCharges[name] = charges end
    local maximum = shieldMaxCharges[name]
    display.shield.icon:SetTexture(texture)
    display.shield.icon:SetVertexColor(1, 1, 1)
    display.shield.icon:SetAlpha(1)
    display.shield.count:SetText(tostring(charges))
    if charges >= maximum then
        display.shield.count:SetTextColor(0.20, 1, 0.20)
    elseif charges > 1 then
        display.shield.count:SetTextColor(1, 0.82, 0)
    else
        display.shield.count:SetTextColor(1, 0.10, 0.10)
    end
    display.shield.warning:Hide()
    display.shield.buffIndex = buffIndex
    display.shield:Show()
    return true
end

local function UpdateWeaponEnchant()
    if not display or not display.weapon then return false end
    local name, texture, inventorySlot = FindWeaponEnchant()
    if not name then
        display.weapon.inventorySlot = nil
        display.weapon:Hide()
        return false
    end
    display.weapon.icon:SetTexture(texture)
    display.weapon.inventorySlot = inventorySlot
    display.weapon:Show()
    return true
end

local function UpdateFromNativeAPI()
    if not GetTotemInfo then return false end
    local i
    for i = 1, 4 do
        local haveTotem, name, startTime, duration, texture = GetTotemInfo(i)
        if haveTotem and duration and duration > 0 then
            slots[i] = { name = name, startTime = startTime, duration = duration,
                expires = startTime + duration, texture = texture }
        else
            slots[i] = nil
        end
    end
    return true
end

local function UpdateDisplay()
    if not display then return end
    if OctoTotemTimersDB.hidden then
        display:Hide()
        return
    end
    UpdateFromNativeAPI()
    local shieldActive = UpdateShield()
    local weaponEnchantActive = UpdateWeaponEnchant()
    local now = GetTime()
    local active = 0
    local i
    for i = 1, 4 do
        local data = slots[i]
        local button = display.icons[i]
        if data and data.expires > now then
            active = active + 1
            button:SetAlpha(1)
            button.warning:Hide()
            button.icon:SetTexture(data.texture)
            button.icon:SetVertexColor(1, 1, 1)
            button.icon:SetAlpha(1)
            button.time:SetText(FormatTime(data.expires - now))
            button:Show()
        else
            slots[i] = nil
            if OctoTotemTimersDB.alwaysShow then
                button:SetAlpha(1)
                button.icon:SetTexture(EMPTY_TOTEM_TEXTURES[i])
                button.icon:SetVertexColor(
                    0.45 + ELEMENT_COLORS[i][1] * 0.35,
                    0.45 + ELEMENT_COLORS[i][2] * 0.35,
                    0.45 + ELEMENT_COLORS[i][3] * 0.35)
                button.icon:SetAlpha(0.82)
                button.time:SetText("--")
                if UnitAffectingCombat("player") then button.warning:Show() else button.warning:Hide() end
                button:Show()
            else
                button:SetAlpha(1)
                button.warning:Hide()
                button:Hide()
            end
        end
    end
    if active > 0 or shieldActive or weaponEnchantActive or OctoTotemTimersDB.alwaysShow then display:Show() else display:Hide() end
end

local function InitializeAddon()
    if initialized then return true end
    local _, class = UnitClass("player")
    if not class then return false end
    if class ~= "SHAMAN" then
        events:UnregisterAllEvents()
        return false
    end

    OctoTotemTimersDB = OctoTotemTimersDB or {}
    if OctoTotemTimersDB.alwaysShow == nil then OctoTotemTimersDB.alwaysShow = true end
    scanTip = CreateFrame("GameTooltip", "OctoTotemScanTooltip", UIParent, "GameTooltipTemplate")
    scanTip:SetOwner(UIParent, "ANCHOR_NONE")
    RefreshShieldTextures()
    CreateDisplay()
    EnsureCastingHooks()
    initialized = true
    Chat("loaded. Empty elemental slots are shown; use /octototems for commands.")
    return true
end

events = CreateFrame("Frame")
events:RegisterEvent("VARIABLES_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("SPELLCAST_STOP")
events:RegisterEvent("SPELLCAST_FAILED")
events:RegisterEvent("SPELLCAST_INTERRUPTED")
events:RegisterEvent("PLAYER_TOTEM_UPDATE")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("UNIT_AURA")
events:RegisterEvent("UNIT_INVENTORY_CHANGED")
events:RegisterEvent("SPELLS_CHANGED")
events:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        OctoTotemTimersDB = OctoTotemTimersDB or {}
    elseif event == "PLAYER_ENTERING_WORLD" then
        InitializeAddon()
    elseif event == "SPELLS_CHANGED" then
        RefreshShieldTextures()
    end
    UpdateDisplay()
end)
events:SetScript("OnUpdate", function()
    if not initialized then return end
    elapsed = elapsed + arg1
    if elapsed >= UPDATE_INTERVAL then
        elapsed = 0
        EnsureCastingHooks()
        UpdateDisplay()
    end
end)

SLASH_OCTOTOTEMS1 = "/octototems"
SLASH_OCTOTOTEMS2 = "/ototems"
SlashCmdList["OCTOTOTEMS"] = function(message)
    message = string.lower(message or "")
    if message == "lock" then
        OctoTotemTimersDB.locked = true
        Chat("display locked.")
    elseif message == "unlock" then
        OctoTotemTimersDB.locked = false
        Chat("display unlocked; drag it with the left mouse button.")
    elseif message == "show" then
        OctoTotemTimersDB.hidden = false
        OctoTotemTimersDB.alwaysShow = true
        UpdateDisplay()
        Chat("display shown.")
    elseif message == "hide" then
        OctoTotemTimersDB.hidden = true
        UpdateDisplay()
        Chat("display hidden completely; use /octototems show to restore it.")
    elseif message == "reset" then
        OctoTotemTimersDB.point, OctoTotemTimersDB.relativePoint = "CENTER", "CENTER"
        OctoTotemTimersDB.x, OctoTotemTimersDB.y = 0, -150
        if display then display:ClearAllPoints(); display:SetPoint("CENTER", UIParent, "CENTER", 0, -150) end
        Chat("position reset.")
    else
        Chat("/octototems lock | unlock | show | hide | reset")
    end
end
