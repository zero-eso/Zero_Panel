ZeroPanel = ZeroPanel or {}
ZERO_PANEL = ZeroPanel

local ZeroPanel = ZeroPanel

ZeroPanel.name = "Zero_Panel"
ZeroPanel.displayName = "ZERO PANEL"
ZeroPanel.savedVarName = "ZeroPanelSavedVars"
ZeroPanel.panelId = "ZeroPanelOptions"

local VERSION_INFO = {
    major = 0,
    minor = 2,
    patch = 9,
    prerelease = nil,
}

local function GetVersionNumberPart(value)
    local numericValue = math.floor(tonumber(value) or 0)
    if numericValue < 0 then
        return 0
    end
    return numericValue
end

local function GetSemanticVersion(versionInfo)
    local major = GetVersionNumberPart(versionInfo and versionInfo.major)
    local minor = GetVersionNumberPart(versionInfo and versionInfo.minor)
    local patch = GetVersionNumberPart(versionInfo and versionInfo.patch)
    local versionText = string.format("%d.%d.%d", major, minor, patch)
    local prerelease = type(versionInfo) == "table" and tostring(versionInfo.prerelease or "") or ""

    if prerelease ~= "" then
        versionText = string.format("%s-%s", versionText, prerelease)
    end

    return versionText
end

local function GetAddOnVersionNumber(versionInfo)
    local major = GetVersionNumberPart(versionInfo and versionInfo.major)
    local minor = GetVersionNumberPart(versionInfo and versionInfo.minor)
    local patch = GetVersionNumberPart(versionInfo and versionInfo.patch)

    return (major * 1000000) + (minor * 1000) + patch
end

local function GetAddOnVersionString(versionInfo)
    return string.format("%07d", GetAddOnVersionNumber(versionInfo))
end

ZeroPanel.versionInfo = VERSION_INFO
ZeroPanel.version = GetSemanticVersion(VERSION_INFO)
ZeroPanel.addOnVersion = GetAddOnVersionNumber(VERSION_INFO)
ZeroPanel.addOnVersionString = GetAddOnVersionString(VERSION_INFO)
ZeroPanel.versionDisplay = string.format("%s (%s)", ZeroPanel.version, ZeroPanel.addOnVersionString)

local ZERO_BRAND_PURPLE_HEX = "A259FF"
local ZERO_BRAND_WHITE_HEX = "FFFFFF"
local CONTROL_NAME_PREFIX = "ZeroPanelStandalone"

local function GetBrandedZeroAddonName(nameRemainder)
    if not nameRemainder or nameRemainder == "" then
        return string.format("|c%sZERO|r", ZERO_BRAND_PURPLE_HEX)
    end

    return string.format("|c%sZERO|r |c%s%s|r", ZERO_BRAND_PURPLE_HEX, ZERO_BRAND_WHITE_HEX, nameRemainder)
end

local function GetBrandedZeroAddonTag(nameRemainder)
    return string.format("|c%s[|r%s|c%s]|r", ZERO_BRAND_WHITE_HEX, GetBrandedZeroAddonName(nameRemainder), ZERO_BRAND_WHITE_HEX)
end

local ZERO_PANEL_NAME = GetBrandedZeroAddonName("Panel")
local ZERO_PANEL_TAG = GetBrandedZeroAddonTag("PANEL")
local ZERO_PANEL_SETTINGS_NAME = "Zero Panel"
local ZERO_PANEL_GITHUB_URL = "https://github.com/zero-eso/Zero_Panel"
local ZERO_PANEL_GITHUB_ISSUES_URL = ZERO_PANEL_GITHUB_URL .. "/issues"

local DEFAULTS = {
    enabled = true,
    showOnlyWhenReticleHidden = true,
    showInHudUI = false,
    locked = true,
    maxVisibleButtons = 24,
    edge = "left",
    layoutDirection = "vertical",
    buttonsPerLine = 1,
    offsetX = 12,
    offsetY = 220,
    buttonSize = 34,
    spacing = 4,
    padding = 6,
    backgroundAlpha = 72,
    buttons = {
        settings = true,
        reloadui = true,
        cycle_group_role = true,
        toggle_group_difficulty = true,
        dismiss_combat_pets = true,
        summon_banker = true,
        summon_trader = true,
        summon_smuggler = true,
        summon_armorer = true,
        summon_ragpicker = true,
        summon_ally = true,
    },
    collectibleChoices = {
        summon_banker = 0,
        summon_trader = 0,
        summon_smuggler = 0,
        summon_armorer = 0,
        summon_ragpicker = 0,
        summon_ally = -1,
    },
    customButtons = {},
    customSeparators = {},
    nextCustomButtonId = 1,
    nextCustomSeparatorId = 1,
    order = {
        101,
        102,
        103,
        104,
        105,
        106,
        107,
        108,
        109,
        110,
        111,
    },
}

local COLOR_READY = {0.92, 0.88, 0.78, 1}
local COLOR_ACTIVE = {1.00, 0.82, 0.36, 1}
local COLOR_DISABLED = {0.36, 0.37, 0.42, 1}
local BORDER_LOCKED = {0, 0, 0, 0}
local BORDER_UNLOCKED = {0.44, 0.16, 0.16, 1}
local DIVIDER_COLOR = {0.50, 0.20, 0.20, 0.78}
local DIVIDER_LAYOUT_HEIGHT = 8
local DIVIDER_LINE_HEIGHT = 2
local DEFAULT_COLLECTIBLE_CHOICE = 0
local RANDOM_COLLECTIBLE_CHOICE = -1
local ORDER_ENTRY_FIXED_HEX = "A7AFBF"
local ORDER_ENTRY_REMOVABLE_HEX = "E2C56A"
local ORDER_ENTRY_STATUS_HEX = "7E8593"
local ORDER_HELP_DELETE_HEX = "D97878"

local ROLE_ORDER = {
    LFG_ROLE_TANK,
    LFG_ROLE_HEAL,
    LFG_ROLE_DPS,
}

local ROLE_ICONS = {
    [LFG_ROLE_TANK] = "/esoui/art/tutorial/gamepad/gp_lfg_tank.dds",
    [LFG_ROLE_HEAL] = "/esoui/art/tutorial/gamepad/gp_lfg_healer.dds",
    [LFG_ROLE_DPS] = "/esoui/art/tutorial/gamepad/gp_lfg_dps.dds",
}

local VETERAN_ICONS = {
    [true] = "/esoui/art/lfg/gamepad/lfg_menuicon_veteranldungeon.dds",
    [false] = "/esoui/art/lfg/gamepad/lfg_menuicon_normaldungeon.dds",
}

local SUMMONABLE_ACTION_ORDER = {
    "summon_banker",
    "summon_trader",
    "summon_smuggler",
    "summon_armorer",
    "summon_ragpicker",
    "summon_ally",
}

local SUMMONABLES = {
    summon_banker = {
        ids = {267, 397, 6376, 8994, 9743, 11097, 12413, 13517},
        categoryType = COLLECTIBLE_CATEGORY_TYPE_ASSISTANT,
        buttonTooltip = "Summon Banker Assistant.",
        randomTooltip = "Summon Random Banker Assistant.",
        tooltipPrefix = "Summon Banker Assistant",
        choiceLabel = "Choose Banker Assistant",
        defaultChoiceLabel = "Auto First Available",
        randomChoiceLabel = "Random",
        emptyText = "No unlocked banker assistants are available.",
        randomChoice = true,
    },
    summon_trader = {
        ids = {301, 396, 6378, 8995, 9744, 11059, 12414, 13066},
        categoryType = COLLECTIBLE_CATEGORY_TYPE_ASSISTANT,
        buttonTooltip = "Summon Merchant Assistant.",
        randomTooltip = "Summon Random Merchant Assistant.",
        tooltipPrefix = "Summon Merchant Assistant",
        choiceLabel = "Choose Merchant Assistant",
        defaultChoiceLabel = "Auto First Available",
        randomChoiceLabel = "Random",
        emptyText = "No unlocked merchant assistants are available.",
        randomChoice = true,
    },
    summon_smuggler = {
        ids = {300},
        categoryType = COLLECTIBLE_CATEGORY_TYPE_ASSISTANT,
        buttonTooltip = "Summon Smuggler Assistant.",
        randomTooltip = "Summon Random Smuggler Assistant.",
        tooltipPrefix = "Summon Smuggler Assistant",
        choiceLabel = "Choose Smuggler Assistant",
        defaultChoiceLabel = "Auto First Available",
        randomChoiceLabel = "Random",
        emptyText = "No unlocked smuggler assistants are available.",
        randomChoice = true,
    },
    summon_armorer = {
        ids = {9745, 10618, 11876, 13518},
        categoryType = COLLECTIBLE_CATEGORY_TYPE_ASSISTANT,
        buttonTooltip = "Summon Armory Assistant.",
        randomTooltip = "Summon Random Armory Assistant.",
        tooltipPrefix = "Summon Armory Assistant",
        choiceLabel = "Choose Armory Assistant",
        defaultChoiceLabel = "Auto First Available",
        randomChoiceLabel = "Random",
        emptyText = "No unlocked armory assistants are available.",
        randomChoice = true,
    },
    summon_ragpicker = {
        ids = {10184, 10617, 11877, 13063},
        categoryType = COLLECTIBLE_CATEGORY_TYPE_ASSISTANT,
        buttonTooltip = "Summon Deconstruction Assistant.",
        randomTooltip = "Summon Random Deconstruction Assistant.",
        tooltipPrefix = "Summon Deconstruction Assistant",
        choiceLabel = "Choose Deconstruction Assistant",
        defaultChoiceLabel = "Auto First Available",
        randomChoiceLabel = "Random",
        emptyText = "No unlocked deconstruction assistants are available.",
        randomChoice = true,
    },
    summon_ally = {
        ids = {9245, 9353, 9911, 9912, 11113, 11114, 12172, 12173},
        categoryType = COLLECTIBLE_CATEGORY_TYPE_COMPANION,
        buttonTooltip = "Summon Ally.",
        randomTooltip = "Summon Random Ally.",
        tooltipPrefix = "Summon Ally",
        choiceLabel = "Choose Ally to Summon",
        defaultChoiceLabel = "Random",
        defaultChoiceValue = RANDOM_COLLECTIBLE_CHOICE,
        emptyText = "No unlocked allies are available.",
        randomChoice = true,
    },
}

local PET_BUFF_IDS = {
    [23304] = true,
    [23316] = true,
    [23319] = true,
    [24613] = true,
    [24636] = true,
    [24639] = true,
    [85982] = true,
    [85986] = true,
    [85990] = true,
}

local BUTTON_DEFINITIONS = {
    {
        id = "settings",
        uniqueKey = 101,
        name = "Open Settings",
        group = "utility",
        icon = "/esoui/art/guild/gamepad/gp_guild_menuicon_customization.dds",
        tooltip = function(self)
            return string.format("Open %s Settings.", self.displayName)
        end,
        click = function(self)
            self:OpenSettings()
        end,
    },
    {
        id = "reloadui",
        uniqueKey = 102,
        name = "Reload UI",
        group = "utility",
        icon = "/esoui/art/mounts/ridingskill_ready.dds",
        tooltip = function()
            return "Reload the UI."
        end,
        click = function()
            ReloadUI()
        end,
    },
    {
        id = "cycle_group_role",
        uniqueKey = 103,
        name = "Cycle Group Role",
        group = "utility",
        icon = function()
            return ROLE_ICONS[GetSelectedLFGRole()] or ROLE_ICONS[LFG_ROLE_DPS]
        end,
        tooltip = function()
            local roleName = ZeroPanel:GetRoleName(GetSelectedLFGRole())
            if not CanUpdateSelectedLFGRole() then
                return string.format("Current Role: %s. Role Changes Are Unavailable Here.", roleName)
            end
            return string.format("Cycle Group Role. Current Role: %s.", roleName)
        end,
        isActive = function()
            return CanUpdateSelectedLFGRole()
        end,
        isUsable = function()
            return CanUpdateSelectedLFGRole()
        end,
        click = function(self)
            self:CycleGroupRole()
        end,
    },
    {
        id = "toggle_group_difficulty",
        uniqueKey = 104,
        name = "Toggle Dungeon Difficulty",
        group = "utility",
        icon = function()
            return VETERAN_ICONS[ZeroPanel:IsVeteranDungeonDifficulty()]
        end,
        tooltip = function()
            local difficultyName = ZeroPanel:GetDungeonDifficultyName()
            if not CanPlayerChangeGroupDifficulty() then
                return string.format("Current Difficulty: %s. Changes Are Unavailable Here.", difficultyName)
            end
            return string.format("Toggle Dungeon Difficulty. Current: %s.", difficultyName)
        end,
        isActive = function()
            return ZeroPanel:IsVeteranDungeonDifficulty()
        end,
        isUsable = function()
            return CanPlayerChangeGroupDifficulty()
        end,
        click = function(self)
            self:ToggleGroupDifficulty()
        end,
    },
    {
        id = "dismiss_combat_pets",
        uniqueKey = 105,
        name = "Dismiss Combat Pets",
        group = "utility",
        icon = "/esoui/art/treeicons/gamepad/gp_store_indexicon_vanitypets.dds",
        tooltip = function()
            return "Dismiss Active Combat Pets."
        end,
        isUsable = function()
            return ZeroPanel:HasDismissablePet()
        end,
        click = function(self)
            self:DismissCombatPets()
        end,
    },
    {
        id = "summon_banker",
        uniqueKey = 106,
        name = "Summon Banker",
        group = "assistants",
        collectibleActionId = "summon_banker",
        hideWhenUnavailable = true,
        icon = "/esoui/art/icons/mapkey/mapkey_bank.dds",
        tooltip = function(self)
            return self:GetSummonTooltip("summon_banker")
        end,
        isUsable = function()
            return ZeroPanel:GetSelectedCollectibleId("summon_banker") ~= nil
        end,
        click = function(self)
            self:UseConfiguredCollectible("summon_banker")
        end,
    },
    {
        id = "summon_trader",
        uniqueKey = 107,
        name = "Summon Merchant",
        group = "assistants",
        collectibleActionId = "summon_trader",
        hideWhenUnavailable = true,
        icon = "/esoui/art/mail/gamepad/gp_mailmenu_attachitem.dds",
        tooltip = function(self)
            return self:GetSummonTooltip("summon_trader")
        end,
        isUsable = function()
            return ZeroPanel:GetSelectedCollectibleId("summon_trader") ~= nil
        end,
        click = function(self)
            self:UseConfiguredCollectible("summon_trader")
        end,
    },
    {
        id = "summon_smuggler",
        uniqueKey = 108,
        name = "Summon Smuggler",
        group = "assistants",
        collectibleActionId = "summon_smuggler",
        hideWhenUnavailable = true,
        icon = "/esoui/art/icons/mapkey/mapkey_fence.dds",
        tooltip = function(self)
            return self:GetSummonTooltip("summon_smuggler")
        end,
        isUsable = function()
            return ZeroPanel:GetSelectedCollectibleId("summon_smuggler") ~= nil
        end,
        click = function(self)
            self:UseConfiguredCollectible("summon_smuggler")
        end,
    },
    {
        id = "summon_armorer",
        uniqueKey = 109,
        name = "Summon Armorer",
        group = "assistants",
        collectibleActionId = "summon_armorer",
        hideWhenUnavailable = true,
        icon = "/esoui/art/treeicons/gamepad/gp_collectionicon_weapona+armor.dds",
        tooltip = function(self)
            return self:GetSummonTooltip("summon_armorer")
        end,
        isUsable = function()
            return ZeroPanel:GetSelectedCollectibleId("summon_armorer") ~= nil
        end,
        click = function(self)
            self:UseConfiguredCollectible("summon_armorer")
        end,
    },
    {
        id = "summon_ragpicker",
        uniqueKey = 110,
        name = "Summon Ragpicker",
        group = "assistants",
        collectibleActionId = "summon_ragpicker",
        hideWhenUnavailable = true,
        icon = "/esoui/art/crafting/gamepad/gp_crafting_menuicon_deconstruct.dds",
        tooltip = function(self)
            return self:GetSummonTooltip("summon_ragpicker")
        end,
        isUsable = function()
            return ZeroPanel:GetSelectedCollectibleId("summon_ragpicker") ~= nil
        end,
        click = function(self)
            self:UseConfiguredCollectible("summon_ragpicker")
        end,
    },
    {
        id = "summon_ally",
        uniqueKey = 111,
        name = "Summon Ally",
        group = "allies",
        collectibleActionId = "summon_ally",
        hideWhenUnavailable = true,
        icon = "/esoui/art/inventory/inventory_tabicon_companion_up.dds",
        tooltip = function(self)
            return self:GetSummonTooltip("summon_ally")
        end,
        isUsable = function()
            return ZeroPanel:GetSelectedCollectibleId("summon_ally") ~= nil
        end,
        click = function(self)
            self:UseConfiguredCollectible("summon_ally")
        end,
    },
}

local DEFAULT_LAYOUT_ORDER = {
    "button:101",
    "button:102",
    "button:103",
    "button:104",
    "button:105",
    "separator:utility_assistants",
    "button:106",
    "button:107",
    "button:108",
    "button:109",
    "button:110",
    "separator:assistants_allies",
    "button:111",
}

local DEFAULT_SEPARATOR_DEFINITIONS = {
    {
        key = "separator:utility_assistants",
        orderUniqueKey = 1001,
        name = "Separator: Utility / Assistants",
        tooltip = "Separates the utility buttons from the assistant buttons.",
    },
    {
        key = "separator:assistants_allies",
        orderUniqueKey = 1002,
        name = "Separator: Assistants / Allies",
        tooltip = "Separates the assistant buttons from the ally buttons.",
    },
}

local CUSTOM_BUTTON_ORDER_KEY_BASE = 300000
local CUSTOM_SEPARATOR_ORDER_KEY_BASE = 400000

local CUSTOM_BUTTON_ACTIONS = {
    command = {
        name = "Custom Command",
        icon = "/esoui/art/tutorial/chat-notifications_up.dds",
    },
    open_settings = {
        name = "Open Zero Panel Settings",
        icon = "/esoui/art/guild/gamepad/gp_guild_menuicon_customization.dds",
        tooltip = "Open Zero Panel Settings.",
    },
    reload_ui = {
        name = "Reload UI",
        icon = "/esoui/art/mounts/ridingskill_ready.dds",
        tooltip = "Reload UI.",
    },
    cycle_group_role = {
        name = "Cycle Group Role",
        icon = function()
            return ROLE_ICONS[GetSelectedLFGRole()] or ROLE_ICONS[LFG_ROLE_DPS]
        end,
    },
    toggle_group_difficulty = {
        name = "Toggle Dungeon Difficulty",
        icon = function()
            return VETERAN_ICONS[ZeroPanel:IsVeteranDungeonDifficulty()]
        end,
    },
    dismiss_combat_pets = {
        name = "Dismiss Active Combat Pets",
        icon = "/esoui/art/treeicons/gamepad/gp_store_indexicon_vanitypets.dds",
        tooltip = "Dismiss Active Combat Pets.",
    },
    summon_banker = {
        name = "Summon Banker Assistant",
        icon = "/esoui/art/icons/mapkey/mapkey_bank.dds",
    },
    summon_trader = {
        name = "Summon Merchant Assistant",
        icon = "/esoui/art/mail/gamepad/gp_mailmenu_attachitem.dds",
    },
    summon_smuggler = {
        name = "Summon Smuggler Assistant",
        icon = "/esoui/art/icons/mapkey/mapkey_fence.dds",
    },
    summon_armorer = {
        name = "Summon Armory Assistant",
        icon = "/esoui/art/treeicons/gamepad/gp_collectionicon_weapona+armor.dds",
    },
    summon_ragpicker = {
        name = "Summon Deconstruction Assistant",
        icon = "/esoui/art/crafting/gamepad/gp_crafting_menuicon_deconstruct.dds",
    },
    summon_ally = {
        name = "Summon Ally",
        icon = "/esoui/art/inventory/inventory_tabicon_companion_up.dds",
    },
}

local CUSTOM_BUTTON_ACTION_CHOICES = {
    {"Custom Command", "command"},
    {"Open Zero Panel Settings", "open_settings"},
    {"Reload UI", "reload_ui"},
    {"Cycle Group Role", "cycle_group_role"},
    {"Toggle Dungeon Difficulty", "toggle_group_difficulty"},
    {"Dismiss Active Combat Pets", "dismiss_combat_pets"},
    {"Summon Banker Assistant", "summon_banker"},
    {"Summon Merchant Assistant", "summon_trader"},
    {"Summon Smuggler Assistant", "summon_smuggler"},
    {"Summon Armory Assistant", "summon_armorer"},
    {"Summon Deconstruction Assistant", "summon_ragpicker"},
    {"Summon Ally", "summon_ally"},
}

local CUSTOM_BUTTON_ACTION_NAMES = {}
local CUSTOM_BUTTON_ACTION_VALUES = {}
for _, entry in ipairs(CUSTOM_BUTTON_ACTION_CHOICES) do
    CUSTOM_BUTTON_ACTION_NAMES[#CUSTOM_BUTTON_ACTION_NAMES + 1] = entry[1]
    CUSTOM_BUTTON_ACTION_VALUES[#CUSTOM_BUTTON_ACTION_VALUES + 1] = entry[2]
end

local CUSTOM_BUTTON_PRESETS = {
    {
        id = "open_settings",
        name = "Open Zero Panel Settings",
        tooltip = "Create a button that opens Zero Panel settings.",
        actionType = "open_settings",
    },
    {
        id = "reload_ui",
        name = "Reload UI",
        tooltip = "Create a button that reloads the UI.",
        actionType = "reload_ui",
    },
    {
        id = "cycle_group_role",
        name = "Cycle Group Role",
        tooltip = "Create a button that cycles tank, healer, and damage roles.",
        actionType = "cycle_group_role",
    },
    {
        id = "toggle_group_difficulty",
        name = "Toggle Dungeon Difficulty",
        tooltip = "Create a button that toggles normal and veteran dungeon difficulty.",
        actionType = "toggle_group_difficulty",
    },
    {
        id = "dismiss_combat_pets",
        name = "Dismiss Active Combat Pets",
        tooltip = "Create a button that dismisses active combat pets.",
        actionType = "dismiss_combat_pets",
    },
    {
        id = "summon_banker",
        name = "Summon Banker Assistant",
        tooltip = "Create a button that summons your selected banker assistant.",
        actionType = "summon_banker",
    },
    {
        id = "summon_trader",
        name = "Summon Merchant Assistant",
        tooltip = "Create a button that summons your selected merchant assistant.",
        actionType = "summon_trader",
    },
    {
        id = "summon_smuggler",
        name = "Summon Smuggler Assistant",
        tooltip = "Create a button that summons your selected smuggler assistant.",
        actionType = "summon_smuggler",
    },
    {
        id = "summon_armorer",
        name = "Summon Armory Assistant",
        tooltip = "Create a button that summons your selected armory assistant.",
        actionType = "summon_armorer",
    },
    {
        id = "summon_ragpicker",
        name = "Summon Deconstruction Assistant",
        tooltip = "Create a button that summons your selected deconstruction assistant.",
        actionType = "summon_ragpicker",
    },
    {
        id = "summon_ally",
        name = "Summon Ally",
        tooltip = "Create a button that summons your selected ally.",
        actionType = "summon_ally",
    },
    {
        id = "toggle_compass",
        name = "Toggle Compass",
        tooltip = "Create a button that toggles the world compass.",
        actionType = "command",
        icon = "/esoui/art/icons/ability_rogue_062.dds",
        command = "/script ZO_CompassFrame:SetHidden(not ZO_CompassFrame:IsHidden())",
    },
    {
        id = "jump_to_leader",
        name = "Jump To Group Leader",
        tooltip = "Create a button that uses the jump-to-leader slash command.",
        actionType = "command",
        icon = "/esoui/art/tutorial/gamepad/gp_playermenu_icon_store.dds",
        command = "/jumptoleader",
    },
    {
        id = "whisper_target",
        name = "Whisper Current Target",
        tooltip = "Create a button that opens a whisper to your current target.",
        actionType = "command",
        icon = "/esoui/art/tutorial/chat-notifications_up.dds",
        command = "/script zo_callLater(function() local name = GetUnitDisplayName('reticleover') if name and name ~= '' then StartChatInput('/w '..name..' ') else d('No target') end end, 100)",
    },
}

local CUSTOM_BUTTON_PRESET_NAMES = {}
local CUSTOM_BUTTON_PRESET_VALUES = {}
local CUSTOM_BUTTON_PRESET_TOOLTIPS = {}
for _, entry in ipairs(CUSTOM_BUTTON_PRESETS) do
    CUSTOM_BUTTON_PRESET_NAMES[#CUSTOM_BUTTON_PRESET_NAMES + 1] = entry.name
    CUSTOM_BUTTON_PRESET_VALUES[#CUSTOM_BUTTON_PRESET_VALUES + 1] = entry.id
    CUSTOM_BUTTON_PRESET_TOOLTIPS[#CUSTOM_BUTTON_PRESET_TOOLTIPS + 1] = entry.tooltip
end

local COLLECTIBLE_BROWSER_STATUS_KEYS = {
    "all",
    "unlocked",
    "locked",
    "active",
}

local COLLECTIBLE_BROWSER_STATUS_NAMES = {
    "All Collectibles",
    "Unlocked Only",
    "Locked Only",
    "Active Only",
}

local COLLECTIBLE_BROWSER_CATEGORY_GLOBAL_NAMES = {
    "COLLECTIBLE_CATEGORY_TYPE_ASSISTANT",
    "COLLECTIBLE_CATEGORY_TYPE_COMPANION",
    "COLLECTIBLE_CATEGORY_TYPE_COSTUME",
    "COLLECTIBLE_CATEGORY_TYPE_EMOTE",
    "COLLECTIBLE_CATEGORY_TYPE_HAT",
    "COLLECTIBLE_CATEGORY_TYPE_HAIR",
    "COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS",
    "COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY",
    "COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING",
    "COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING",
    "COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY",
    "COLLECTIBLE_CATEGORY_TYPE_SKIN",
    "COLLECTIBLE_CATEGORY_TYPE_POLYMORPH",
    "COLLECTIBLE_CATEGORY_TYPE_PERSONALITY",
    "COLLECTIBLE_CATEGORY_TYPE_ABILITY_SKIN",
    "COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE",
    "COLLECTIBLE_CATEGORY_TYPE_MEMENTO",
    "COLLECTIBLE_CATEGORY_TYPE_MOUNT",
    "COLLECTIBLE_CATEGORY_TYPE_VANITY_PET",
    "COLLECTIBLE_CATEGORY_TYPE_TRIBUTE_PATRON",
    "COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE",
    "COLLECTIBLE_CATEGORY_TYPE_HOUSE",
    "COLLECTIBLE_CATEGORY_TYPE_HOUSE_BANK",
    "COLLECTIBLE_CATEGORY_TYPE_FURNITURE",
    "COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT",
    "COLLECTIBLE_CATEGORY_TYPE_DLC",
    "COLLECTIBLE_CATEGORY_TYPE_CHAPTER",
    "COLLECTIBLE_CATEGORY_TYPE_ACCOUNT_SERVICE",
    "COLLECTIBLE_CATEGORY_TYPE_ACCOUNT_UPGRADE",
}

local POPUP_BROWSER_PAGE_SIZE_VALUES = {4, 6, 8}
local POPUP_BROWSER_PAGE_SIZE_ENTRIES = {
    { label = "4 per page", value = 4 },
    { label = "6 per page", value = 6 },
    { label = "8 per page", value = 8 },
}
local POPUP_BROWSER_MAX_ROWS = POPUP_BROWSER_PAGE_SIZE_VALUES[#POPUP_BROWSER_PAGE_SIZE_VALUES]
local POPUP_BROWSER_ROW_HEIGHT = 36
local POPUP_BROWSER_ROW_GAP = 4

local COMMAND_FRIENDLY_TITLES = {
    ["/reloadui"] = "Reload UI.",
    ["/rl"] = "Reload UI.",
    ["/zp"] = "Open Zero Panel Settings.",
    ["/zb"] = "Open Zero Bar Settings.",
    ["/jumptoleader"] = "Jump To Group Leader.",
}

local COMMAND_ICON_OVERRIDES = {
    ["/reloadui"] = "/esoui/art/mounts/ridingskill_ready.dds",
    ["/rl"] = "/esoui/art/mounts/ridingskill_ready.dds",
    ["/zp"] = "/esoui/art/guild/gamepad/gp_guild_menuicon_customization.dds",
    ["/zb"] = "/esoui/art/guild/gamepad/gp_guild_menuicon_customization.dds",
    ["/jumptoleader"] = "/esoui/art/tutorial/gamepad/gp_playermenu_icon_store.dds",
}

local SLASH_COMMAND_HELP_ENTRIES = {
    {
        command = "/zp",
        description = "Open Zero Panel settings.",
    },
    {
        command = "/zp unlock",
        description = "Unlock the panel so it can be dragged to a new screen-edge position.",
    },
    {
        command = "/zp lock",
        description = "Lock the panel in place after you finish moving it.",
    },
    {
        command = "/zp reset",
        description = "Reset the panel position back to the default anchor.",
    },
}

local function TrimText(value)
    value = tostring(value or "")
    return value:match("^%s*(.-)%s*$")
end

local function NormalizeBrowserText(value)
    return string.lower(TrimText(value))
end

local function AddUniqueValue(list, seen, value)
    if value ~= nil and not seen[value] then
        seen[value] = true
        list[#list + 1] = value
    end
end

local function GetDefaultButtonLayoutKey(uniqueKey)
    return string.format("button:%s", tostring(uniqueKey))
end

local function GetCustomButtonLayoutKey(customButtonId)
    return string.format("custom_button:%s", tostring(customButtonId))
end

local function GetCustomSeparatorLayoutKey(customSeparatorId)
    return string.format("custom_separator:%s", tostring(customSeparatorId))
end

local function GetCustomButtonOrderUniqueKey(customButtonId)
    return CUSTOM_BUTTON_ORDER_KEY_BASE + tonumber(customButtonId or 0)
end

local function GetCustomSeparatorOrderUniqueKey(customSeparatorId)
    return CUSTOM_SEPARATOR_ORDER_KEY_BASE + tonumber(customSeparatorId or 0)
end

local function GetSortedNumericKeys(values)
    local keys = {}

    for key in pairs(values or {}) do
        if type(key) == "number" then
            keys[#keys + 1] = key
        end
    end

    table.sort(keys)
    return keys
end

local function GetCustomButtonPresetById(presetId)
    for _, preset in ipairs(CUSTOM_BUTTON_PRESETS) do
        if preset.id == presetId then
            return preset
        end
    end

    return nil
end

local function ClampNumber(value, minValue, maxValue)
    value = tonumber(value) or minValue
    if maxValue < minValue then
        return minValue
    end
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

local function GetClampedWindowOffsets(control, xOffset, yOffset)
    if not control then
        return tonumber(xOffset) or 0, tonumber(yOffset) or 0
    end

    local guiWidth = GuiRoot:GetWidth() or 0
    local guiHeight = GuiRoot:GetHeight() or 0
    local maxX = math.max(0, guiWidth - (control:GetWidth() or 0))
    local maxY = math.max(0, guiHeight - (control:GetHeight() or 0))

    return ClampNumber(xOffset, 0, maxX), ClampNumber(yOffset, 0, maxY)
end

local function ResetTopLevelAnchor(control, relativePoint)
    local point = relativePoint == "right" and TOPRIGHT or TOPLEFT
    local x = control:GetLeft() or 0
    local y = control:GetTop() or 0

    if relativePoint == "right" then
        x = (GuiRoot:GetWidth() - (control:GetRight() or (x + control:GetWidth())))
    end

    x, y = GetClampedWindowOffsets(control, x, y)

    control:ClearAnchors()
    control:SetAnchor(point, GuiRoot, point, relativePoint == "right" and -x or x, y)
end

function ZeroPanel:Print(message)
    d(string.format("%s %s", ZERO_PANEL_TAG, tostring(message)))
end

function ZeroPanel:GetRoleName(role)
    if role == LFG_ROLE_TANK then
        return "Tank"
    elseif role == LFG_ROLE_HEAL then
        return "Healer"
    elseif role == LFG_ROLE_DPS then
        return "Damage"
    end
    return "Unknown"
end

function ZeroPanel:GetCollectibleName(collectibleId)
    return zo_strformat("<<1>>", GetCollectibleName(collectibleId))
end

function ZeroPanel:GetCollectibleBrowserState()
    self.collectibleBrowserState = self.collectibleBrowserState or {
        category = "all",
        status = "unlocked",
        filter = "",
        selectedCollectibleId = 0,
        pageSize = 6,
        pageIndex = 1,
    }

    self.collectibleBrowserState.pageSize = tonumber(self.collectibleBrowserState.pageSize) or 6
    self.collectibleBrowserState.pageIndex = tonumber(self.collectibleBrowserState.pageIndex) or 1

    return self.collectibleBrowserState
end

function ZeroPanel:BuildCollectibleBrowserMeta()
    if self.collectibleBrowserMeta then
        return self.collectibleBrowserMeta
    end

    local meta = {
        categoryChoices = {"All Collectibles"},
        categoryValues = {"all"},
        entriesByCategory = {
            all = {},
        },
    }

    for _, globalName in ipairs(COLLECTIBLE_BROWSER_CATEGORY_GLOBAL_NAMES) do
        local categoryType = _G[globalName]
        if categoryType and (not COLLECTIBLE_CATEGORY_TYPE_INVALID or categoryType ~= COLLECTIBLE_CATEGORY_TYPE_INVALID) then
            local totalCollectibles = GetTotalCollectiblesByCategoryType(categoryType)
            if totalCollectibles and totalCollectibles > 0 then
                local categoryName = GetString("SI_COLLECTIBLECATEGORYTYPE", categoryType)
                if categoryName == nil or categoryName == "" then
                    categoryName = globalName:gsub("^COLLECTIBLE_CATEGORY_TYPE_", "")
                end

                local entries = {}
                for collectibleIndex = 1, totalCollectibles do
                    local collectibleId = GetCollectibleIdFromType(categoryType, collectibleIndex)
                    if collectibleId and collectibleId > 0 then
                        local collectibleName, _, collectibleIcon, _, isUnlocked, _, isActive = GetCollectibleInfo(collectibleId)
                        if collectibleName and collectibleName ~= "" then
                            local displayName = self:GetCollectibleName(collectibleId)
                            local entry = {
                                id = collectibleId,
                                name = displayName,
                                icon = collectibleIcon,
                                unlocked = isUnlocked,
                                active = isActive,
                                categoryType = categoryType,
                                categoryName = categoryName,
                                filterText = NormalizeBrowserText(string.format("%s %s %s", displayName, collectibleId, categoryName)),
                            }
                            entries[#entries + 1] = entry
                            meta.entriesByCategory.all[#meta.entriesByCategory.all + 1] = entry
                        end
                    end
                end

                if #entries > 0 then
                    table.sort(entries, function(left, right)
                        return left.name < right.name
                    end)
                    meta.entriesByCategory[categoryType] = entries
                    meta.categoryChoices[#meta.categoryChoices + 1] = string.format("%s (%d)", categoryName, #entries)
                    meta.categoryValues[#meta.categoryValues + 1] = categoryType
                end
            end
        end
    end

    table.sort(meta.entriesByCategory.all, function(left, right)
        return left.name < right.name
    end)
    meta.categoryChoices[1] = string.format("All Collectibles (%d)", #meta.entriesByCategory.all)
    self.collectibleBrowserMeta = meta
    return meta
end

function ZeroPanel:DoesCollectibleBrowserEntryMatchStatus(entry, statusKey)
    if statusKey == "unlocked" then
        return entry.unlocked
    elseif statusKey == "locked" then
        return not entry.unlocked
    elseif statusKey == "active" then
        return entry.active
    end

    return true
end

function ZeroPanel:GetCollectibleBrowserEntries()
    local meta = self:BuildCollectibleBrowserMeta()
    local state = self:GetCollectibleBrowserState()
    local entries = meta.entriesByCategory[state.category] or meta.entriesByCategory.all or {}
    local filteredEntries = {}
    local filterText = NormalizeBrowserText(state.filter)

    for _, entry in ipairs(entries) do
        local _, _, _, _, isUnlocked, _, isActive = GetCollectibleInfo(entry.id)
        entry.unlocked = isUnlocked
        entry.active = isActive
        if self:DoesCollectibleBrowserEntryMatchStatus(entry, state.status) then
            if filterText == "" or string.find(entry.filterText, filterText, 1, true) then
                filteredEntries[#filteredEntries + 1] = entry
            end
        end
    end

    return filteredEntries
end

function ZeroPanel:GetCollectibleBrowserChoiceEntries()
    local choices = {}
    local values = {}
    local entries = self:GetCollectibleBrowserEntries()

    for index, entry in ipairs(entries) do
        local statusText = entry.active and "Active" or (entry.unlocked and "Unlocked" or "Locked")
        choices[index] = string.format("%s (#%d, %s)", entry.name, entry.id, statusText)
        values[index] = entry.id
    end

    return choices, values
end

function ZeroPanel:UpdateDropdownReference(referenceName, choices, choiceValues, selectedValue)
    local control = referenceName and _G[referenceName]
    if not control or type(control.UpdateChoices) ~= "function" then
        return
    end

    control.data.choices = choices
    control.data.choicesValues = choiceValues
    control:UpdateChoices(choices, choiceValues)

    if selectedValue ~= nil and control.choices and control.choices[selectedValue] ~= nil then
        control.dropdown:SetSelectedItem(control.choices[selectedValue])
    else
        control:UpdateValue()
    end
end

function ZeroPanel:RequestSettingsRefresh()
    if not LibAddonMenu2 or not LibAddonMenu2.util or type(LibAddonMenu2.util.RequestRefreshIfNeeded) ~= "function" then
        return
    end

    local refreshControl = _G.ZeroPanelDeleteLayoutEntryButton or _G.ZeroPanelCustomButtonSelector or _G.ZeroPanelCustomSeparatorSelector or self.addonPanel
    if refreshControl then
        LibAddonMenu2.util.RequestRefreshIfNeeded(refreshControl)
    end
end

function ZeroPanel:RefreshCollectibleBrowserControls()
    local state = self:GetCollectibleBrowserState()
    local choices, values = self:GetCollectibleBrowserChoiceEntries()

    if #values == 0 then
        choices = {"No collectibles match the current filter."}
        values = {0}
        state.selectedCollectibleId = 0
    else
        local hasSelectedValue = false
        for _, collectibleId in ipairs(values) do
            if collectibleId == state.selectedCollectibleId then
                hasSelectedValue = true
                break
            end
        end
        if not hasSelectedValue then
            state.selectedCollectibleId = values[1]
        end
    end

    self:UpdateDropdownReference("ZeroPanelCollectibleSelector", choices, values)
    self:RefreshCollectibleBrowserPopup()
end

local function GetTextureBrowserDisplayName(displayName, texturePath)
    local resolvedDisplayName = TrimText(displayName)
    if resolvedDisplayName ~= "" then
        return resolvedDisplayName
    end

    local fileName = tostring(texturePath or ""):match("([^/\\]+)%.dds$")
    if fileName and fileName ~= "" then
        fileName = fileName:gsub("[_+]", " ")
        return fileName
    end

    return "Texture"
end

local function AddTextureBrowserEntry(entries, seenPaths, texturePath, displayName, sourceName)
    local resolvedTexturePath = TrimText(texturePath)
    if resolvedTexturePath == "" or seenPaths[resolvedTexturePath] then
        return
    end

    local resolvedName = GetTextureBrowserDisplayName(displayName, resolvedTexturePath)
    local resolvedSource = TrimText(sourceName)
    entries[#entries + 1] = {
        path = resolvedTexturePath,
        name = resolvedName,
        source = resolvedSource ~= "" and resolvedSource or "Texture",
        filterText = NormalizeBrowserText(string.format("%s %s %s", resolvedName, resolvedTexturePath, resolvedSource)),
    }
    seenPaths[resolvedTexturePath] = true
end

local function CreatePopupLabel(name, parent, font, text)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font or "ZoFontWinH4")
    label:SetText(text or "")
    label:SetColor(0.96, 0.93, 0.84, 1)
    return label
end

local function CreatePopupBackdropEditBox(name, parent, width, height, maxChars)
    local backdrop = WINDOW_MANAGER:CreateControlFromVirtual(name .. "Backdrop", parent, "ZO_EditBackdrop")
    backdrop:SetDimensions(width, height)

    local editbox = WINDOW_MANAGER:CreateControlFromVirtual(name .. "Edit", backdrop, "ZO_DefaultEditForBackdrop")
    editbox:SetAnchor(TOPLEFT, backdrop, TOPLEFT, 2, 2)
    editbox:SetAnchor(BOTTOMRIGHT, backdrop, BOTTOMRIGHT, -2, -2)
    editbox:SetTextType(TEXT_TYPE_ALL)
    editbox:SetMaxInputChars(maxChars or 300)
    editbox:SetHandler("OnEscape", function(control)
        control:LoseFocus()
    end)

    return backdrop, editbox
end

local function CreatePopupComboBox(name, parent, width, height)
    local combobox = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_ScrollableComboBox")
    combobox:SetDimensions(width, height or 28)

    local dropdown = ZO_ComboBox_ObjectFromContainer(combobox)
    dropdown:SetSortsItems(false)
    dropdown.m_containerWidth = width

    return combobox, dropdown
end

local function ConfigurePopupComboBoxOverlay(dropdown, scrollBarInsetX)
    if not dropdown then
        return
    end

    local dropdownObject = dropdown.m_dropdownObject
    local dropdownControl = dropdownObject and dropdownObject.control
    if dropdownControl then
        dropdownControl:SetDrawLayer(DL_OVERLAY)
        dropdownControl:SetDrawTier(DT_HIGH)
        dropdownControl:SetDrawLevel(10)
    end

    local scrollBar = (dropdownObject and dropdownObject.scrollControl and dropdownObject.scrollControl.scrollbar)
        or (dropdownObject and dropdownObject.scrollbar)
    if scrollBar then
        local insetX = tonumber(scrollBarInsetX) or 0
        scrollBar:ClearAnchors()
        scrollBar:SetAnchor(TOPRIGHT, dropdownControl or scrollBar:GetParent(), TOPRIGHT, -insetX, 0)
        scrollBar:SetAnchor(BOTTOMRIGHT, dropdownControl or scrollBar:GetParent(), BOTTOMRIGHT, -insetX, 0)
    end
end

local function ClampPopupBrowserValue(value, minimumValue, maximumValue)
    local resolvedValue = tonumber(value) or minimumValue
    if resolvedValue < minimumValue then
        return minimumValue
    end
    if resolvedValue > maximumValue then
        return maximumValue
    end
    return resolvedValue
end

local function ResolvePopupBrowserPageSize(pageSize)
    local resolvedPageSize = tonumber(pageSize) or 6
    for _, allowedPageSize in ipairs(POPUP_BROWSER_PAGE_SIZE_VALUES) do
        if allowedPageSize == resolvedPageSize then
            return resolvedPageSize
        end
    end

    return POPUP_BROWSER_PAGE_SIZE_VALUES[2]
end

local function GetPopupBrowserPageCount(entryCount, pageSize)
    local resolvedPageSize = math.max(1, tonumber(pageSize) or 1)
    return math.max(1, math.ceil(math.max(0, tonumber(entryCount) or 0) / resolvedPageSize))
end

local function GetPopupBrowserPageForIndex(entryIndex, pageSize)
    local resolvedPageSize = math.max(1, tonumber(pageSize) or 1)
    if tonumber(entryIndex) == nil or entryIndex <= 0 then
        return 1
    end

    return math.floor((entryIndex - 1) / resolvedPageSize) + 1
end

local function FindPopupBrowserEntryIndex(entries, predicate)
    if type(predicate) ~= "function" then
        return 0
    end

    for entryIndex, entry in ipairs(entries or {}) do
        if predicate(entry) then
            return entryIndex
        end
    end

    return 0
end

local function RefreshPopupResultRowAppearance(row)
    if not row then
        return
    end

    if row.isSelected then
        row.backdrop:SetCenterColor(0.26, 0.22, 0.09, 0.96)
        row.backdrop:SetEdgeColor(0.79, 0.67, 0.28, 1)
        row.primaryLabel:SetColor(0.99, 0.95, 0.82, 1)
        row.secondaryLabel:SetColor(0.96, 0.88, 0.66, 1)
    elseif row.isHovered then
        row.backdrop:SetCenterColor(0.15, 0.16, 0.20, 0.96)
        row.backdrop:SetEdgeColor(0.46, 0.46, 0.50, 1)
        row.primaryLabel:SetColor(0.97, 0.94, 0.86, 1)
        row.secondaryLabel:SetColor(0.82, 0.82, 0.86, 1)
    else
        row.backdrop:SetCenterColor(0.09, 0.10, 0.13, 0.94)
        row.backdrop:SetEdgeColor(0.24, 0.24, 0.28, 1)
        row.primaryLabel:SetColor(0.94, 0.92, 0.86, 1)
        row.secondaryLabel:SetColor(0.72, 0.72, 0.76, 1)
    end
end

local function CreatePopupResultsList(name, parent, width)
    local totalHeight = 12 + (POPUP_BROWSER_MAX_ROWS * POPUP_BROWSER_ROW_HEIGHT) + ((POPUP_BROWSER_MAX_ROWS - 1) * POPUP_BROWSER_ROW_GAP)
    local list = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
    list:SetDimensions(width, totalHeight)
    list:SetMouseEnabled(true)

    list.backdrop = WINDOW_MANAGER:CreateControl(name .. "Backdrop", list, CT_BACKDROP)
    list.backdrop:SetAnchorFill()
    list.backdrop:SetCenterColor(0.06, 0.07, 0.10, 0.98)
    list.backdrop:SetEdgeColor(0.32, 0.30, 0.24, 1)
    list.backdrop:SetMouseEnabled(true)

    list.rows = {}
    local previousRow
    for rowIndex = 1, POPUP_BROWSER_MAX_ROWS do
        local row = WINDOW_MANAGER:CreateControl(name .. "Row" .. rowIndex, list, CT_BUTTON)
        row:SetDimensions(width - 12, POPUP_BROWSER_ROW_HEIGHT)
        row:SetMouseEnabled(true)
        if previousRow then
            row:SetAnchor(TOPLEFT, previousRow, BOTTOMLEFT, 0, POPUP_BROWSER_ROW_GAP)
        else
            row:SetAnchor(TOPLEFT, list, TOPLEFT, 6, 6)
        end

        row.backdrop = WINDOW_MANAGER:CreateControl(name .. "Row" .. rowIndex .. "Backdrop", row, CT_BACKDROP)
        row.backdrop:SetAnchorFill()
        row.backdrop:SetMouseEnabled(false)

        row.iconBackdrop = WINDOW_MANAGER:CreateControl(name .. "Row" .. rowIndex .. "IconBackdrop", row, CT_BACKDROP)
        row.iconBackdrop:SetDimensions(28, 28)
        row.iconBackdrop:SetAnchor(LEFT, row, LEFT, 6, 0)
        row.iconBackdrop:SetCenterColor(0.02, 0.03, 0.04, 0.98)
        row.iconBackdrop:SetEdgeColor(0.24, 0.24, 0.28, 1)
        row.iconBackdrop:SetMouseEnabled(false)

        row.icon = WINDOW_MANAGER:CreateControl(name .. "Row" .. rowIndex .. "Icon", row.iconBackdrop, CT_TEXTURE)
        row.icon:SetAnchorFill()
        row.icon:SetMouseEnabled(false)

        row.primaryLabel = CreatePopupLabel(name .. "Row" .. rowIndex .. "PrimaryLabel", row, "ZoFontGame", "")
        row.primaryLabel:SetAnchor(TOPLEFT, row.iconBackdrop, TOPRIGHT, 10, 3)
        row.primaryLabel:SetWidth(width - 74)
        row.primaryLabel:SetMouseEnabled(false)

        row.secondaryLabel = CreatePopupLabel(name .. "Row" .. rowIndex .. "SecondaryLabel", row, "ZoFontGameSmall", "")
        row.secondaryLabel:SetAnchor(TOPLEFT, row.primaryLabel, BOTTOMLEFT, 0, 0)
        row.secondaryLabel:SetWidth(width - 74)
        row.secondaryLabel:SetMouseEnabled(false)

        row:SetHandler("OnClicked", function(control)
            if control.data ~= nil and list.onSelect then
                list.onSelect(control.data)
            end
        end)
        row:SetHandler("OnMouseEnter", function(control)
            control.isHovered = true
            RefreshPopupResultRowAppearance(control)
        end)
        row:SetHandler("OnMouseExit", function(control)
            control.isHovered = false
            RefreshPopupResultRowAppearance(control)
        end)

        list.rows[rowIndex] = row
        previousRow = row
    end

    list.emptyLabel = CreatePopupLabel(name .. "EmptyLabel", list, "ZoFontGame", "")
    list.emptyLabel:SetAnchor(CENTER, list, CENTER, 0, 0)
    list.emptyLabel:SetWidth(width - 24)
    list.emptyLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local function HandleMouseWheel(_, delta)
        if delta == 0 or not list.onPageDelta then
            return
        end
        list.onPageDelta(delta < 0 and 1 or -1)
    end

    list:SetHandler("OnMouseWheel", HandleMouseWheel)
    list.backdrop:SetHandler("OnMouseWheel", HandleMouseWheel)

    return list
end

local function CreatePopupButton(name, parent, text, width, height)
    local button = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_DefaultButton")
    button:SetDimensions(width, height or 28)
    button:SetText(text)
    button:SetClickSound("Click")
    return button
end

function ZeroPanel:CreatePopupWindow(windowName, titleText, width, height)
    local window = WINDOW_MANAGER:CreateTopLevelWindow(windowName)
    window:SetDimensions(width, height)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)

    window.backdrop = WINDOW_MANAGER:CreateControl(windowName .. "Backdrop", window, CT_BACKDROP)
    window.backdrop:SetAnchorFill()
    window.backdrop:SetCenterColor(0.05, 0.06, 0.08, 0.98)
    window.backdrop:SetEdgeColor(0.62, 0.56, 0.40, 1)
    window.backdrop:SetMouseEnabled(true)
    window.backdrop:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StartMoving()
        end
    end)
    window.backdrop:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StopMovingOrResizing()
        end
    end)

    window.title = CreatePopupLabel(windowName .. "Title", window, "ZoFontWinH1", titleText)
    window.title:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 18)

    window.closeButton = CreatePopupButton(windowName .. "Close", window, "Close", 100, 30)
    window.closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -22, 16)
    window.closeButton:SetHandler("OnClicked", function()
        window:SetHidden(true)
    end)

    return window
end

function ZeroPanel:PopulatePopupDropdown(dropdown, entries, selectedPredicate, textFormatter, onSelect, emptyText)
    dropdown:ClearItems()

    local selectedItem
    for _, entry in ipairs(entries or {}) do
        local itemEntry = dropdown:CreateItemEntry(textFormatter(entry), function()
            onSelect(entry)
        end)
        dropdown:AddItem(itemEntry)
        if selectedPredicate and selectedPredicate(entry) then
            selectedItem = itemEntry
        end
    end

    if selectedItem then
        dropdown:SelectItem(selectedItem, true)
    else
        dropdown:SetSelectedItemText(emptyText or "")
    end
end

function ZeroPanel:RefreshPopupResultsList(window, entries, state, selectedPredicate, rowFormatter, onSelect, emptyText)
    if not window or not window.resultsList then
        return
    end

    local pageSize = ResolvePopupBrowserPageSize(state.pageSize)
    state.pageSize = pageSize

    local entryCount = #entries
    local pageCount = GetPopupBrowserPageCount(entryCount, pageSize)
    local selectedIndex = FindPopupBrowserEntryIndex(entries, selectedPredicate)
    if selectedIndex > 0 then
        state.pageIndex = GetPopupBrowserPageForIndex(selectedIndex, pageSize)
    end
    state.pageIndex = ClampPopupBrowserValue(state.pageIndex, 1, pageCount)

    local pageIndex = state.pageIndex
    local firstEntryIndex = ((pageIndex - 1) * pageSize) + 1
    local lastEntryIndex = math.min(entryCount, firstEntryIndex + pageSize - 1)

    window.resultsList.onSelect = function(entry)
        onSelect(entry)
    end
    window.resultsList.onPageDelta = function(pageDelta)
        if entryCount == 0 then
            return
        end

        local nextPageIndex = ClampPopupBrowserValue(pageIndex + pageDelta, 1, pageCount)
        if nextPageIndex == pageIndex then
            return
        end

        local firstPageEntry = entries[((nextPageIndex - 1) * pageSize) + 1]
        if firstPageEntry then
            onSelect(firstPageEntry)
        end
    end

    for rowIndex, row in ipairs(window.resultsList.rows) do
        local entry = rowIndex <= pageSize and entries[firstEntryIndex + rowIndex - 1] or nil
        row.data = entry
        row.isHovered = false
        row.isSelected = entry ~= nil and selectedPredicate ~= nil and selectedPredicate(entry) or false

        if entry then
            local rowData = rowFormatter(entry) or {}
            local iconPath = TrimText(rowData.icon)
            local secondaryText = TrimText(rowData.secondaryText)

            row.primaryLabel:SetText(rowData.primaryText or "")
            row.secondaryLabel:SetText(secondaryText)
            row.secondaryLabel:SetHidden(secondaryText == "")
            row.icon:SetTexture(iconPath ~= "" and iconPath or "")
            row.icon:SetHidden(iconPath == "")
            row.iconBackdrop:SetHidden(iconPath == "")
            row:SetHidden(false)
        else
            row:SetHidden(true)
        end

        RefreshPopupResultRowAppearance(row)
    end

    window.resultsList.emptyLabel:SetText(emptyText or "No results available.")
    window.resultsList.emptyLabel:SetHidden(entryCount > 0)

    if entryCount > 0 then
        window.pageInfoLabel:SetText(string.format("Showing %d-%d of %d | Page %d/%d", firstEntryIndex, lastEntryIndex, entryCount, pageIndex, pageCount))
    else
        window.pageInfoLabel:SetText("Showing 0 of 0 | Page 1/1")
    end

    window.prevPageButton:SetEnabled(entryCount > 0 and pageIndex > 1)
    window.nextPageButton:SetEnabled(entryCount > 0 and pageIndex < pageCount)
end

function ZeroPanel:GetTextureBrowserState()
    self.textureBrowserState = self.textureBrowserState or {
        filter = "",
        selectedTexturePath = "",
        pageSize = 6,
        pageIndex = 1,
    }

    self.textureBrowserState.pageSize = tonumber(self.textureBrowserState.pageSize) or 6
    self.textureBrowserState.pageIndex = tonumber(self.textureBrowserState.pageIndex) or 1

    return self.textureBrowserState
end

function ZeroPanel:BuildTextureBrowserMeta()
    if self.textureBrowserMeta then
        return self.textureBrowserMeta
    end

    local entries = {}
    local seenPaths = {}

    for _, definition in ipairs(BUTTON_DEFINITIONS) do
        AddTextureBrowserEntry(entries, seenPaths, self:GetButtonIcon(definition), definition.name, "Built-in Button")
    end

    for actionId, action in pairs(CUSTOM_BUTTON_ACTIONS) do
        local actionIcon = action.icon
        if type(actionIcon) == "function" then
            actionIcon = actionIcon(self, {})
        end
        AddTextureBrowserEntry(entries, seenPaths, actionIcon, action.name or actionId, "Custom Action")
    end

    for _, preset in ipairs(CUSTOM_BUTTON_PRESETS) do
        local presetIcon = preset.icon
        if type(presetIcon) ~= "string" or TrimText(presetIcon) == "" then
            local action = CUSTOM_BUTTON_ACTIONS[preset.actionType]
            presetIcon = action and action.icon or nil
            if type(presetIcon) == "function" then
                presetIcon = presetIcon(self, {})
            end
        end
        AddTextureBrowserEntry(entries, seenPaths, presetIcon, preset.name, "Preset")
    end

    for commandText, texturePath in pairs(COMMAND_ICON_OVERRIDES) do
        AddTextureBrowserEntry(entries, seenPaths, texturePath, commandText, "Slash Command")
    end

    local collectibleEntries = (self:BuildCollectibleBrowserMeta().entriesByCategory or {}).all or {}
    for _, entry in ipairs(collectibleEntries) do
        AddTextureBrowserEntry(entries, seenPaths, entry.icon, entry.name, entry.categoryName or "Collectible")
    end

    table.sort(entries, function(left, right)
        local leftName = string.lower(left.name or left.path or "")
        local rightName = string.lower(right.name or right.path or "")
        if leftName == rightName then
            return string.lower(left.path or "") < string.lower(right.path or "")
        end
        return leftName < rightName
    end)

    self.textureBrowserMeta = {
        entries = entries,
    }

    return self.textureBrowserMeta
end

function ZeroPanel:GetTextureBrowserEntries()
    local state = self:GetTextureBrowserState()
    local filterText = NormalizeBrowserText(state.filter)
    local filteredEntries = {}
    local hasSelectedPath = false

    for _, entry in ipairs((self:BuildTextureBrowserMeta().entries or {})) do
        if filterText == "" or string.find(entry.filterText, filterText, 1, true) then
            filteredEntries[#filteredEntries + 1] = entry
            if entry.path == state.selectedTexturePath then
                hasSelectedPath = true
            end
        end
    end

    local selectedTexturePath = TrimText(state.selectedTexturePath)
    if not hasSelectedPath and selectedTexturePath ~= "" then
        local currentEntry = {
            path = selectedTexturePath,
            name = "Current Texture",
            source = "Current Selection",
            filterText = NormalizeBrowserText(string.format("%s %s %s", "Current Texture", selectedTexturePath, "Current Selection")),
        }
        if filterText == "" or string.find(currentEntry.filterText, filterText, 1, true) then
            table.insert(filteredEntries, 1, currentEntry)
        end
    end

    return filteredEntries
end

function ZeroPanel:GetSelectedCollectibleBrowserEntry(entries)
    local state = self:GetCollectibleBrowserState()
    for _, entry in ipairs(entries or {}) do
        if entry.id == state.selectedCollectibleId then
            return entry
        end
    end

    return nil
end

function ZeroPanel:GetSelectedTextureBrowserEntry(entries)
    local state = self:GetTextureBrowserState()
    for _, entry in ipairs(entries or {}) do
        if entry.path == state.selectedTexturePath then
            return entry
        end
    end

    return nil
end

function ZeroPanel:RefreshCollectibleBrowserPopup()
    local window = self.collectibleBrowserWindow
    if not window then
        return
    end

    local state = self:GetCollectibleBrowserState()
    local meta = self:BuildCollectibleBrowserMeta()
    local categoryEntries = {}
    local statusEntries = {}
    local collectibleEntries = self:GetCollectibleBrowserEntries()
    local selectedEntry = self:GetSelectedCollectibleBrowserEntry(collectibleEntries)

    if not selectedEntry and collectibleEntries[1] then
        state.selectedCollectibleId = collectibleEntries[1].id
        selectedEntry = collectibleEntries[1]
    end

    local customButtonId = self:GetSelectedCustomButtonId()
    if customButtonId then
        window.targetLabel:SetText(string.format("Editing %s", self:GetCustomButtonDisplayName(customButtonId)))
    else
        window.targetLabel:SetText("No custom button selected.")
    end

    if not window.isUpdatingFilterText and window.filterEdit:GetText() ~= state.filter then
        window.isUpdatingFilterText = true
        window.filterEdit:SetText(state.filter)
        window.isUpdatingFilterText = false
    end

    self:PopulatePopupDropdown(window.pageSizeDropdown, POPUP_BROWSER_PAGE_SIZE_ENTRIES, function(entry)
        return entry.value == ResolvePopupBrowserPageSize(state.pageSize)
    end, function(entry)
        return entry.label
    end, function(entry)
        state.pageSize = entry.value
        self:RefreshCollectibleBrowserPopup()
    end, "Per page")

    for index, categoryLabel in ipairs(meta.categoryChoices or {}) do
        categoryEntries[#categoryEntries + 1] = {
            label = categoryLabel,
            value = meta.categoryValues[index],
        }
    end

    for index, statusLabel in ipairs(COLLECTIBLE_BROWSER_STATUS_NAMES) do
        statusEntries[#statusEntries + 1] = {
            label = statusLabel,
            value = COLLECTIBLE_BROWSER_STATUS_KEYS[index],
        }
    end

    self:PopulatePopupDropdown(window.categoryDropdown, categoryEntries, function(entry)
        return entry.value == state.category
    end, function(entry)
        return entry.label
    end, function(entry)
        state.category = entry.value
        state.selectedCollectibleId = 0
        state.pageIndex = 1
        self:RefreshCollectibleBrowserControls()
    end, "No categories available.")

    self:PopulatePopupDropdown(window.statusDropdown, statusEntries, function(entry)
        return entry.value == state.status
    end, function(entry)
        return entry.label
    end, function(entry)
        state.status = entry.value
        state.selectedCollectibleId = 0
        state.pageIndex = 1
        self:RefreshCollectibleBrowserControls()
    end, "No statuses available.")

    window.resultLabel:SetText(TrimText(state.filter) ~= "" and "Matching Collectibles" or "Collectibles")
    self:RefreshPopupResultsList(window, collectibleEntries, state, function(entry)
        return selectedEntry and entry.id == selectedEntry.id
    end, function(entry)
        local statusText = entry.active and "Active" or (entry.unlocked and "Unlocked" or "Locked")
        return {
            icon = entry.icon,
            primaryText = entry.name,
            secondaryText = string.format("%s | #%d | %s", entry.categoryName or "Collectible", entry.id, statusText),
        }
    end, function(entry)
        state.selectedCollectibleId = entry.id
        self:RefreshCollectibleBrowserPopup()
    end, "No collectibles match the current filter.")

    if selectedEntry then
        window.previewTexture:SetTexture(selectedEntry.icon or "")
        window.previewTexture:SetHidden(false)
        window.selectionName:SetText(selectedEntry.name)
        window.selectionInfo:SetText(string.format("%s\nCollectible ID: %d", selectedEntry.categoryName or "Collectible", selectedEntry.id))
    else
        window.previewTexture:SetHidden(true)
        window.selectionName:SetText("No matching collectible")
        window.selectionInfo:SetText("Adjust Category, Status, or Filter to find a collectible.")
    end

    window.applyButton:SetEnabled(selectedEntry ~= nil and self:GetSelectedCustomButtonData() ~= nil)
end

function ZeroPanel:RefreshTextureBrowserPopup()
    local window = self.textureBrowserWindow
    if not window then
        return
    end

    local state = self:GetTextureBrowserState()
    local textureEntries = self:GetTextureBrowserEntries()
    local selectedEntry = self:GetSelectedTextureBrowserEntry(textureEntries)
    local customButtonId = self:GetSelectedCustomButtonId()
    local customButtonData = self:GetSelectedCustomButtonData()

    if not selectedEntry and textureEntries[1] then
        state.selectedTexturePath = textureEntries[1].path
        selectedEntry = textureEntries[1]
    end

    if customButtonId then
        window.targetLabel:SetText(string.format("Editing %s", self:GetCustomButtonDisplayName(customButtonId)))
    else
        window.targetLabel:SetText("No custom button selected.")
    end

    if not window.isUpdatingFilterText and window.filterEdit:GetText() ~= state.filter then
        window.isUpdatingFilterText = true
        window.filterEdit:SetText(state.filter)
        window.isUpdatingFilterText = false
    end

    self:PopulatePopupDropdown(window.pageSizeDropdown, POPUP_BROWSER_PAGE_SIZE_ENTRIES, function(entry)
        return entry.value == ResolvePopupBrowserPageSize(state.pageSize)
    end, function(entry)
        return entry.label
    end, function(entry)
        state.pageSize = entry.value
        self:RefreshTextureBrowserPopup()
    end, "Per page")

    window.resultLabel:SetText(TrimText(state.filter) ~= "" and "Matching Textures" or "Textures")
    self:RefreshPopupResultsList(window, textureEntries, state, function(entry)
        return selectedEntry and entry.path == selectedEntry.path
    end, function(entry)
        return {
            icon = entry.path,
            primaryText = entry.name,
            secondaryText = string.format("%s | %s", entry.source, entry.path),
        }
    end, function(entry)
        state.selectedTexturePath = entry.path
        self:RefreshTextureBrowserPopup()
    end, "No textures match the current filter.")

    if selectedEntry then
        window.previewTexture:SetTexture(selectedEntry.path)
        window.previewTexture:SetHidden(false)
        window.selectionName:SetText(selectedEntry.name)
        window.selectionInfo:SetText(string.format("%s\n%s", selectedEntry.source, selectedEntry.path))
    else
        window.previewTexture:SetHidden(true)
        window.selectionName:SetText("No matching texture")
        window.selectionInfo:SetText("Adjust the filter to find a texture path.")
    end

    window.applyButton:SetEnabled(selectedEntry ~= nil and customButtonData ~= nil)
    window.clearButton:SetEnabled(customButtonData ~= nil and TrimText(customButtonData.icon) ~= "")
end

function ZeroPanel:RefreshTextureBrowserControls()
    self:RefreshTextureBrowserPopup()
end

function ZeroPanel:EnsureCollectibleBrowserPopup()
    if self.collectibleBrowserWindow then
        return self.collectibleBrowserWindow
    end

    local window = self:CreatePopupWindow("ZeroPanelCollectibleBrowserWindow", "Browse Collectibles", 780, 620)

    window.targetLabel = CreatePopupLabel(window:GetName() .. "TargetLabel", window, "ZoFontGameLargeBold", "")
    window.targetLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 56)

    window.description = CreatePopupLabel(window:GetName() .. "Description", window, "ZoFontGame", "Pick a collectible and Zero Panel will write the command and icon into the selected custom button.")
    window.description:SetAnchor(TOPLEFT, window.targetLabel, BOTTOMLEFT, 0, 10)
    window.description:SetWidth(720)

    window.categoryLabel = CreatePopupLabel(window:GetName() .. "CategoryLabel", window, "ZoFontGame", "Category")
    window.categoryLabel:SetAnchor(TOPLEFT, window.description, BOTTOMLEFT, 0, 18)
    window.categoryCombo, window.categoryDropdown = CreatePopupComboBox(window:GetName() .. "CategoryCombo", window, 330, 28)
    window.categoryCombo:SetAnchor(TOPLEFT, window.categoryLabel, BOTTOMLEFT, 0, 6)
    ConfigurePopupComboBoxOverlay(window.categoryDropdown, 2)

    window.statusLabel = CreatePopupLabel(window:GetName() .. "StatusLabel", window, "ZoFontGame", "Status")
    window.statusLabel:SetAnchor(TOPLEFT, window.description, BOTTOMLEFT, 372, 18)
    window.statusCombo, window.statusDropdown = CreatePopupComboBox(window:GetName() .. "StatusCombo", window, 170, 28)
    window.statusCombo:SetAnchor(TOPLEFT, window.statusLabel, BOTTOMLEFT, 0, 6)
    ConfigurePopupComboBoxOverlay(window.statusDropdown, 2)

    window.filterLabel = CreatePopupLabel(window:GetName() .. "FilterLabel", window, "ZoFontGame", "Filter")
    window.filterLabel:SetAnchor(TOPLEFT, window.categoryCombo, BOTTOMLEFT, 0, 18)
    window.filterBackdrop, window.filterEdit = CreatePopupBackdropEditBox(window:GetName() .. "Filter", window, 500, 30, 120)
    window.filterBackdrop:SetAnchor(TOPLEFT, window.filterLabel, BOTTOMLEFT, 0, 6)
    window.filterEdit:SetHandler("OnTextChanged", function(control)
        if window.isUpdatingFilterText then
            return
        end

        local state = self:GetCollectibleBrowserState()
        state.filter = tostring(control:GetText() or "")
        state.selectedCollectibleId = 0
        state.pageIndex = 1
        self:RefreshCollectibleBrowserControls()
    end)

    window.pageSizeLabel = CreatePopupLabel(window:GetName() .. "PageSizeLabel", window, "ZoFontGame", "Per Page")
    window.pageSizeCombo, window.pageSizeDropdown = CreatePopupComboBox(window:GetName() .. "PageSizeCombo", window, 170, 28)
    window.pageSizeCombo:SetAnchor(TOPLEFT, window.filterBackdrop, TOPRIGHT, 26, 0)
    window.pageSizeLabel:SetAnchor(BOTTOMLEFT, window.pageSizeCombo, TOPLEFT, 0, -4)
    ConfigurePopupComboBoxOverlay(window.pageSizeDropdown, 2)

    window.resultLabel = CreatePopupLabel(window:GetName() .. "ResultLabel", window, "ZoFontGame", "Collectibles")
    window.resultLabel:SetAnchor(TOPLEFT, window.filterBackdrop, BOTTOMLEFT, 0, 18)
    window.resultsList = CreatePopupResultsList(window:GetName() .. "ResultsList", window, 468)
    window.resultsList:SetAnchor(TOPLEFT, window.resultLabel, BOTTOMLEFT, 0, 6)

    window.pageInfoLabel = CreatePopupLabel(window:GetName() .. "PageInfoLabel", window, "ZoFontGame", "")
    window.pageInfoLabel:SetAnchor(TOPLEFT, window.resultsList, BOTTOMLEFT, 0, 10)
    window.pageInfoLabel:SetWidth(260)

    window.prevPageButton = CreatePopupButton(window:GetName() .. "PrevPageButton", window, "Previous", 100, 28)
    window.prevPageButton:SetAnchor(TOPRIGHT, window.resultsList, BOTTOMRIGHT, -108, 6)
    window.prevPageButton:SetHandler("OnClicked", function()
        if window.resultsList.onPageDelta then
            window.resultsList.onPageDelta(-1)
        end
    end)

    window.nextPageButton = CreatePopupButton(window:GetName() .. "NextPageButton", window, "Next", 100, 28)
    window.nextPageButton:SetAnchor(TOPRIGHT, window.resultsList, BOTTOMRIGHT, 0, 6)
    window.nextPageButton:SetHandler("OnClicked", function()
        if window.resultsList.onPageDelta then
            window.resultsList.onPageDelta(1)
        end
    end)

    window.previewSection = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewSection", window, CT_CONTROL)
    window.previewSection:SetDimensions(244, 398)
    window.previewSection:SetAnchor(TOPLEFT, window.resultsList, TOPRIGHT, 20, 0)

    window.previewSectionBackdrop = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewSectionBackdrop", window.previewSection, CT_BACKDROP)
    window.previewSectionBackdrop:SetAnchorFill()
    window.previewSectionBackdrop:SetCenterColor(0.06, 0.07, 0.10, 0.98)
    window.previewSectionBackdrop:SetEdgeColor(0.32, 0.30, 0.24, 1)

    window.previewSectionLabel = CreatePopupLabel(window:GetName() .. "PreviewSectionLabel", window.previewSection, "ZoFontGame", "Selected Collectible")
    window.previewSectionLabel:SetAnchor(TOPLEFT, window.previewSection, TOPLEFT, 12, 12)

    window.previewBackdrop = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewBackdrop", window.previewSection, CT_BACKDROP)
    window.previewBackdrop:SetDimensions(96, 96)
    window.previewBackdrop:SetAnchor(TOPLEFT, window.previewSectionLabel, BOTTOMLEFT, 0, 12)
    window.previewBackdrop:SetCenterColor(0.10, 0.11, 0.15, 0.98)
    window.previewBackdrop:SetEdgeColor(0.28, 0.28, 0.32, 1)

    window.previewTexture = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewTexture", window.previewBackdrop, CT_TEXTURE)
    window.previewTexture:SetAnchorFill()

    window.selectionName = CreatePopupLabel(window:GetName() .. "SelectionName", window.previewSection, "ZoFontGameLargeBold", "")
    window.selectionName:SetAnchor(TOPLEFT, window.previewBackdrop, BOTTOMLEFT, 0, 18)
    window.selectionName:SetWidth(220)

    window.selectionInfo = CreatePopupLabel(window:GetName() .. "SelectionInfo", window.previewSection, "ZoFontGame", "")
    window.selectionInfo:SetAnchor(TOPLEFT, window.selectionName, BOTTOMLEFT, 0, 8)
    window.selectionInfo:SetWidth(220)

    window.applyButton = CreatePopupButton(window:GetName() .. "ApplyButton", window.previewSection, "Apply Collectible", 134, 30)
    window.applyButton:SetAnchor(BOTTOMRIGHT, window.previewSection, BOTTOMRIGHT, -12, -12)
    window.applyButton:SetHandler("OnClicked", function()
        self:ApplySelectedCollectibleToCustomButton()
        self:CloseCollectibleBrowserPopup()
    end)

    window.closeButton:ClearAnchors()
    window.closeButton:SetAnchor(BOTTOMRIGHT, window.applyButton, BOTTOMLEFT, -10, 0)

    self.collectibleBrowserWindow = window
    return window
end

function ZeroPanel:EnsureTextureBrowserPopup()
    if self.textureBrowserWindow then
        return self.textureBrowserWindow
    end

    local window = self:CreatePopupWindow("ZeroPanelTextureBrowserWindow", "Browse Textures", 780, 620)

    window.targetLabel = CreatePopupLabel(window:GetName() .. "TargetLabel", window, "ZoFontGameLargeBold", "")
    window.targetLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 56)

    window.description = CreatePopupLabel(window:GetName() .. "Description", window, "ZoFontGame", "Pick a texture path for Icon Override. This writes an explicit icon path into the selected custom button.")
    window.description:SetAnchor(TOPLEFT, window.targetLabel, BOTTOMLEFT, 0, 10)
    window.description:SetWidth(720)

    window.filterLabel = CreatePopupLabel(window:GetName() .. "FilterLabel", window, "ZoFontGame", "Filter")
    window.filterLabel:SetAnchor(TOPLEFT, window.description, BOTTOMLEFT, 0, 18)
    window.filterBackdrop, window.filterEdit = CreatePopupBackdropEditBox(window:GetName() .. "Filter", window, 500, 30, 180)
    window.filterBackdrop:SetAnchor(TOPLEFT, window.filterLabel, BOTTOMLEFT, 0, 6)
    window.filterEdit:SetHandler("OnTextChanged", function(control)
        if window.isUpdatingFilterText then
            return
        end

        local state = self:GetTextureBrowserState()
        state.filter = tostring(control:GetText() or "")
        state.pageIndex = 1
        self:RefreshTextureBrowserControls()
    end)

    window.pageSizeLabel = CreatePopupLabel(window:GetName() .. "PageSizeLabel", window, "ZoFontGame", "Per Page")
    window.pageSizeCombo, window.pageSizeDropdown = CreatePopupComboBox(window:GetName() .. "PageSizeCombo", window, 170, 28)
    window.pageSizeCombo:SetAnchor(TOPLEFT, window.filterBackdrop, TOPRIGHT, 26, 0)
    window.pageSizeLabel:SetAnchor(BOTTOMLEFT, window.pageSizeCombo, TOPLEFT, 0, -4)
    ConfigurePopupComboBoxOverlay(window.pageSizeDropdown, 2)

    window.resultLabel = CreatePopupLabel(window:GetName() .. "ResultLabel", window, "ZoFontGame", "Textures")
    window.resultLabel:SetAnchor(TOPLEFT, window.filterBackdrop, BOTTOMLEFT, 0, 18)
    window.resultsList = CreatePopupResultsList(window:GetName() .. "ResultsList", window, 468)
    window.resultsList:SetAnchor(TOPLEFT, window.resultLabel, BOTTOMLEFT, 0, 6)

    window.pageInfoLabel = CreatePopupLabel(window:GetName() .. "PageInfoLabel", window, "ZoFontGame", "")
    window.pageInfoLabel:SetAnchor(TOPLEFT, window.resultsList, BOTTOMLEFT, 0, 10)
    window.pageInfoLabel:SetWidth(260)

    window.prevPageButton = CreatePopupButton(window:GetName() .. "PrevPageButton", window, "Previous", 100, 28)
    window.prevPageButton:SetAnchor(TOPRIGHT, window.resultsList, BOTTOMRIGHT, -108, 6)
    window.prevPageButton:SetHandler("OnClicked", function()
        if window.resultsList.onPageDelta then
            window.resultsList.onPageDelta(-1)
        end
    end)

    window.nextPageButton = CreatePopupButton(window:GetName() .. "NextPageButton", window, "Next", 100, 28)
    window.nextPageButton:SetAnchor(TOPRIGHT, window.resultsList, BOTTOMRIGHT, 0, 6)
    window.nextPageButton:SetHandler("OnClicked", function()
        if window.resultsList.onPageDelta then
            window.resultsList.onPageDelta(1)
        end
    end)

    window.previewSection = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewSection", window, CT_CONTROL)
    window.previewSection:SetDimensions(244, 398)
    window.previewSection:SetAnchor(TOPLEFT, window.resultsList, TOPRIGHT, 20, 0)

    window.previewSectionBackdrop = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewSectionBackdrop", window.previewSection, CT_BACKDROP)
    window.previewSectionBackdrop:SetAnchorFill()
    window.previewSectionBackdrop:SetCenterColor(0.06, 0.07, 0.10, 0.98)
    window.previewSectionBackdrop:SetEdgeColor(0.32, 0.30, 0.24, 1)

    window.previewSectionLabel = CreatePopupLabel(window:GetName() .. "PreviewSectionLabel", window.previewSection, "ZoFontGame", "Selected Texture")
    window.previewSectionLabel:SetAnchor(TOPLEFT, window.previewSection, TOPLEFT, 12, 12)

    window.previewBackdrop = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewBackdrop", window.previewSection, CT_BACKDROP)
    window.previewBackdrop:SetDimensions(96, 96)
    window.previewBackdrop:SetAnchor(TOPLEFT, window.previewSectionLabel, BOTTOMLEFT, 0, 12)
    window.previewBackdrop:SetCenterColor(0.10, 0.11, 0.15, 0.98)
    window.previewBackdrop:SetEdgeColor(0.28, 0.28, 0.32, 1)

    window.previewTexture = WINDOW_MANAGER:CreateControl(window:GetName() .. "PreviewTexture", window.previewBackdrop, CT_TEXTURE)
    window.previewTexture:SetAnchorFill()

    window.selectionName = CreatePopupLabel(window:GetName() .. "SelectionName", window.previewSection, "ZoFontGameLargeBold", "")
    window.selectionName:SetAnchor(TOPLEFT, window.previewBackdrop, BOTTOMLEFT, 0, 18)
    window.selectionName:SetWidth(220)

    window.selectionInfo = CreatePopupLabel(window:GetName() .. "SelectionInfo", window.previewSection, "ZoFontGame", "")
    window.selectionInfo:SetAnchor(TOPLEFT, window.selectionName, BOTTOMLEFT, 0, 8)
    window.selectionInfo:SetWidth(220)

    window.applyButton = CreatePopupButton(window:GetName() .. "ApplyButton", window.previewSection, "Apply Texture", 112, 30)
    window.applyButton:SetAnchor(BOTTOMRIGHT, window.previewSection, BOTTOMRIGHT, -12, -12)
    window.applyButton:SetHandler("OnClicked", function()
        self:ApplySelectedTextureToCustomButton()
        self:CloseTextureBrowserPopup()
    end)

    window.clearButton = CreatePopupButton(window:GetName() .. "ClearButton", window.previewSection, "Clear Override", 112, 30)
    window.clearButton:SetAnchor(BOTTOMRIGHT, window.applyButton, BOTTOMLEFT, -10, 0)
    window.clearButton:SetHandler("OnClicked", function()
        self:ClearSelectedCustomButtonIconOverride()
    end)

    self.textureBrowserWindow = window
    return window
end

function ZeroPanel:OpenCollectibleBrowserPopup()
    if not self:GetSelectedCustomButtonData() then
        return
    end

    local state = self:GetCollectibleBrowserState()
    local currentCollectibleId = self:GetCollectibleIdFromCommand(self:GetSelectedCustomButtonData().command)
    if currentCollectibleId and currentCollectibleId > 0 then
        state.selectedCollectibleId = currentCollectibleId
    end

    local window = self:EnsureCollectibleBrowserPopup()
    self:RefreshCollectibleBrowserControls()
    window:SetHidden(false)
end

function ZeroPanel:CloseCollectibleBrowserPopup()
    if self.collectibleBrowserWindow then
        self.collectibleBrowserWindow:SetHidden(true)
    end
end

function ZeroPanel:OpenTextureBrowserPopup()
    local customButtonId = self:GetSelectedCustomButtonId()
    local customButtonData = self:GetSelectedCustomButtonData()
    if not customButtonId or not customButtonData then
        return
    end

    local state = self:GetTextureBrowserState()
    local currentTexturePath = TrimText(customButtonData.icon)
    if currentTexturePath == "" then
        currentTexturePath = TrimText(self:GetCustomButtonIcon(customButtonId))
    end
    state.selectedTexturePath = currentTexturePath

    local window = self:EnsureTextureBrowserPopup()
    self:RefreshTextureBrowserControls()
    window:SetHidden(false)
end

function ZeroPanel:CloseTextureBrowserPopup()
    if self.textureBrowserWindow then
        self.textureBrowserWindow:SetHidden(true)
    end
end

function ZeroPanel:ApplySelectedTextureToCustomButton()
    local customButtonData = self:GetSelectedCustomButtonData()
    local texturePath = TrimText(self:GetTextureBrowserState().selectedTexturePath)
    if not customButtonData or texturePath == "" then
        return
    end

    customButtonData.icon = texturePath
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:ClearSelectedCustomButtonIconOverride()
    local customButtonId = self:GetSelectedCustomButtonId()
    local customButtonData = self:GetSelectedCustomButtonData()
    if not customButtonId or not customButtonData then
        return
    end

    customButtonData.icon = ""
    self:GetTextureBrowserState().selectedTexturePath = TrimText(self:GetCustomButtonIcon(customButtonId))
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:GetCollectibleIdFromCommand(commandText)
    local collectibleId = tostring(commandText or ""):match("[Uu]seCollectible%s*%(%s*(%d+)")
    return tonumber(collectibleId)
end

function ZeroPanel:GetAutoCommandTitle(commandText)
    local command = TrimText(commandText)
    local lowerCommand = string.lower(command)
    if command == "" then
        return "Run Custom Command."
    end

    local collectibleId = self:GetCollectibleIdFromCommand(command)
    if collectibleId and GetCollectibleName(collectibleId) ~= "" then
        return string.format("Use %s.", self:GetCollectibleName(collectibleId))
    end

    if COMMAND_FRIENDLY_TITLES[lowerCommand] then
        return COMMAND_FRIENDLY_TITLES[lowerCommand]
    end

    if string.find(lowerCommand, "zo_compassframe:sethidden", 1, true) then
        return "Toggle Compass."
    elseif string.find(lowerCommand, "startchatinput('/w '..name", 1, true) then
        return "Whisper Current Target."
    elseif string.find(lowerCommand, "areanyitemsstolen", 1, true) then
        return "Check For Stolen Items."
    elseif string.find(lowerCommand, "selectslotability", 1, true) then
        return "Slot Purge."
    end

    local slashCommand = lowerCommand:match("^(%S+)")
    if slashCommand and COMMAND_FRIENDLY_TITLES[slashCommand] then
        return COMMAND_FRIENDLY_TITLES[slashCommand]
    elseif slashCommand then
        return string.format("Run %s.", slashCommand)
    end

    return "Run Custom Command."
end

function ZeroPanel:GetAutoCommandIcon(commandText)
    local command = TrimText(commandText)
    local lowerCommand = string.lower(command)
    local collectibleId = self:GetCollectibleIdFromCommand(command)

    if collectibleId then
        local collectibleIcon = GetCollectibleIcon(collectibleId)
        if collectibleIcon and collectibleIcon ~= "" then
            return collectibleIcon
        end
    end

    if COMMAND_ICON_OVERRIDES[lowerCommand] then
        return COMMAND_ICON_OVERRIDES[lowerCommand]
    end

    if string.find(lowerCommand, "zo_compassframe:sethidden", 1, true) then
        return "/esoui/art/icons/ability_rogue_062.dds"
    elseif string.find(lowerCommand, "startchatinput('/w '..name", 1, true) then
        return "/esoui/art/tutorial/chat-notifications_up.dds"
    end

    local slashCommand = lowerCommand:match("^(%S+)")
    return COMMAND_ICON_OVERRIDES[slashCommand] or CUSTOM_BUTTON_ACTIONS.command.icon
end

function ZeroPanel:ExecuteCommand(commandText)
    local command = TrimText(commandText)
    if command == "" then
        self:Print("That custom button does not have a command yet.")
        return
    end

    local collectibleId = self:GetCollectibleIdFromCommand(command)
    if collectibleId then
        if not IsCollectibleUnlocked(collectibleId) then
            self:Print(string.format("%s is not unlocked on this account.", self:GetCollectibleName(collectibleId)))
            return
        end

        UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        return
    end

    local slashCommand, argumentText = command:match("^(%S+)%s*(.-)$")
    local lowerSlashCommand = slashCommand and string.lower(slashCommand) or nil

    if lowerSlashCommand == "/reloadui" or lowerSlashCommand == "/rl" then
        ReloadUI()
        return
    end

    if lowerSlashCommand == "/script" then
        local loader = zo_loadstring or LoadString
        if type(loader) ~= "function" then
            self:Print("This client cannot execute /script commands from a custom button.")
            return
        end

        local compiledChunk, errorMessage = loader(argumentText or "")
        if type(compiledChunk) ~= "function" then
            self:Print(errorMessage or "The custom script could not be compiled.")
            return
        end

        local ok, runtimeError = pcall(compiledChunk)
        if not ok then
            self:Print(runtimeError or "The custom script failed to execute.")
        end
        return
    end

    local handler = slashCommand and (SLASH_COMMANDS[slashCommand] or SLASH_COMMANDS[lowerSlashCommand])
    if type(handler) == "function" then
        handler(argumentText or "")
        return
    end

    if type(DoCommand) == "function" then
        DoCommand(command)
        return
    end

    self:Print("Unable to execute that command in this client.")
end

function ZeroPanel:EnsureCustomButtons()
    self.savedVars.customButtons = self.savedVars.customButtons or {}
    self.savedVars.customSeparators = self.savedVars.customSeparators or {}

    local nextCustomButtonId = tonumber(self.savedVars.nextCustomButtonId) or 1
    for _, customButtonId in ipairs(GetSortedNumericKeys(self.savedVars.customButtons)) do
        local buttonData = self.savedVars.customButtons[customButtonId]
        buttonData.enabled = buttonData.enabled ~= false
        buttonData.actionType = buttonData.actionType or "command"
        buttonData.title = tostring(buttonData.title or "")
        buttonData.useAutoTitle = buttonData.useAutoTitle ~= false
        buttonData.icon = tostring(buttonData.icon or "")
        buttonData.command = tostring(buttonData.command or "")
        nextCustomButtonId = math.max(nextCustomButtonId, customButtonId + 1)
    end
    self.savedVars.nextCustomButtonId = nextCustomButtonId

    local nextCustomSeparatorId = tonumber(self.savedVars.nextCustomSeparatorId) or 1
    for _, customSeparatorId in ipairs(GetSortedNumericKeys(self.savedVars.customSeparators)) do
        local separatorData = self.savedVars.customSeparators[customSeparatorId]
        if type(separatorData) ~= "table" then
            separatorData = {}
            self.savedVars.customSeparators[customSeparatorId] = separatorData
        end
        separatorData.name = tostring(separatorData.name or string.format("Custom Separator %d", customSeparatorId))
        nextCustomSeparatorId = math.max(nextCustomSeparatorId, customSeparatorId + 1)
    end
    self.savedVars.nextCustomSeparatorId = nextCustomSeparatorId
end

function ZeroPanel:GetCustomButtonIds()
    return GetSortedNumericKeys(self.savedVars.customButtons)
end

function ZeroPanel:GetCustomSeparatorIds()
    return GetSortedNumericKeys(self.savedVars.customSeparators)
end

function ZeroPanel:GetSelectedCustomButtonId()
    if type(self.selectedCustomButtonId) == "number" and self.savedVars.customButtons[self.selectedCustomButtonId] then
        return self.selectedCustomButtonId
    end

    local customButtonIds = self:GetCustomButtonIds()
    self.selectedCustomButtonId = customButtonIds[1]
    return self.selectedCustomButtonId
end

function ZeroPanel:SetSelectedCustomButtonId(customButtonId)
    if type(customButtonId) == "number" and self.savedVars.customButtons[customButtonId] then
        self.selectedCustomButtonId = customButtonId
        self.selectedEditorLayoutKey = GetCustomButtonLayoutKey(customButtonId)
        self:SetSelectedLayoutOrderKey(self.selectedEditorLayoutKey)
    else
        if self.selectedEditorLayoutKey and string.find(self.selectedEditorLayoutKey, "^custom_button:", 1) then
            self.selectedEditorLayoutKey = nil
        end
        self.selectedCustomButtonId = nil
    end
end

function ZeroPanel:GetSelectedCustomButtonData()
    local customButtonId = self:GetSelectedCustomButtonId()
    return customButtonId and self.savedVars.customButtons[customButtonId] or nil
end

function ZeroPanel:GetSelectedCustomSeparatorId()
    if type(self.selectedCustomSeparatorId) == "number" and self.savedVars.customSeparators[self.selectedCustomSeparatorId] then
        return self.selectedCustomSeparatorId
    end

    local customSeparatorIds = self:GetCustomSeparatorIds()
    self.selectedCustomSeparatorId = customSeparatorIds[1]
    return self.selectedCustomSeparatorId
end

function ZeroPanel:SetSelectedCustomSeparatorId(customSeparatorId)
    if type(customSeparatorId) == "number" and self.savedVars.customSeparators[customSeparatorId] then
        self.selectedCustomSeparatorId = customSeparatorId
        self.selectedEditorLayoutKey = GetCustomSeparatorLayoutKey(customSeparatorId)
        self:SetSelectedLayoutOrderKey(self.selectedEditorLayoutKey)
    else
        if self.selectedEditorLayoutKey and string.find(self.selectedEditorLayoutKey, "^custom_separator:", 1) then
            self.selectedEditorLayoutKey = nil
        end
        self.selectedCustomSeparatorId = nil
    end
end

function ZeroPanel:GetCustomButtonAction(actionType)
    return CUSTOM_BUTTON_ACTIONS[actionType or "command"] or CUSTOM_BUTTON_ACTIONS.command
end

function ZeroPanel:GetCustomButtonResolvedTitle(customButtonId)
    local buttonData = self.savedVars.customButtons[customButtonId]
    if not buttonData then
        return "Custom Button."
    end

    local customTitle = TrimText(buttonData.title)
    if not buttonData.useAutoTitle and customTitle ~= "" then
        return customTitle
    end

    local action = self:GetCustomButtonAction(buttonData.actionType)
    if buttonData.actionType == "command" then
        return self:GetAutoCommandTitle(buttonData.command)
    elseif buttonData.actionType == "cycle_group_role" then
        local roleName = self:GetRoleName(GetSelectedLFGRole())
        if not CanUpdateSelectedLFGRole() then
            return string.format("Current Role: %s. Role Changes Are Unavailable Here.", roleName)
        end
        return string.format("Cycle Group Role. Current Role: %s.", roleName)
    elseif buttonData.actionType == "toggle_group_difficulty" then
        local difficultyName = self:GetDungeonDifficultyName()
        if not CanPlayerChangeGroupDifficulty() then
            return string.format("Current Difficulty: %s. Changes Are Unavailable Here.", difficultyName)
        end
        return string.format("Toggle Dungeon Difficulty. Current: %s.", difficultyName)
    elseif string.find(buttonData.actionType or "", "^summon_") then
        return self:GetSummonTooltip(buttonData.actionType)
    end

    return action.tooltip or action.name or "Custom Button."
end

function ZeroPanel:GetCustomButtonDisplayName(customButtonId)
    local buttonData = self.savedVars.customButtons[customButtonId]
    if not buttonData then
        return string.format("Custom Button %d", customButtonId)
    end

    local customTitle = TrimText(buttonData.title)
    if not buttonData.useAutoTitle and customTitle ~= "" then
        return string.format("Custom: %s", customTitle:gsub("%.$", ""))
    end

    local labelText
    if buttonData.actionType == "command" then
        labelText = tostring(self:GetAutoCommandTitle(buttonData.command) or ""):gsub("%.$", "")
    else
        local action = self:GetCustomButtonAction(buttonData.actionType)
        labelText = tostring((action and action.name) or "Custom Button")
    end

    if labelText == "" then
        labelText = string.format("Custom Button %d", customButtonId)
    end

    return string.format("Custom: %s", labelText)
end

function ZeroPanel:GetCustomButtonIcon(customButtonId)
    local buttonData = self.savedVars.customButtons[customButtonId]
    if not buttonData then
        return CUSTOM_BUTTON_ACTIONS.command.icon
    end

    local customIcon = TrimText(buttonData.icon)
    if customIcon ~= "" then
        return customIcon
    end

    if buttonData.actionType == "command" then
        return self:GetAutoCommandIcon(buttonData.command)
    end

    local action = self:GetCustomButtonAction(buttonData.actionType)
    if type(action.icon) == "function" then
        return action.icon(self, buttonData)
    end

    return action.icon or CUSTOM_BUTTON_ACTIONS.command.icon
end

function ZeroPanel:IsCustomButtonUsable(customButtonId)
    local buttonData = self.savedVars.customButtons[customButtonId]
    if not buttonData or buttonData.enabled == false then
        return false
    end

    if buttonData.actionType == "command" then
        local command = TrimText(buttonData.command)
        if command == "" then
            return false
        end

        local collectibleId = self:GetCollectibleIdFromCommand(command)
        if collectibleId then
            return IsCollectibleUnlocked(collectibleId)
        end

        return true
    elseif buttonData.actionType == "cycle_group_role" then
        return CanUpdateSelectedLFGRole()
    elseif buttonData.actionType == "toggle_group_difficulty" then
        return CanPlayerChangeGroupDifficulty()
    elseif buttonData.actionType == "dismiss_combat_pets" then
        return self:HasDismissablePet()
    elseif string.find(buttonData.actionType or "", "^summon_") then
        if buttonData.actionType == "summon_ally" then
            return self:GetSelectedCollectibleId("summon_ally") ~= nil
        end
        return self:GetSelectedCollectibleId(buttonData.actionType) ~= nil
    end

    return true
end

function ZeroPanel:IsCustomButtonActive(customButtonId)
    local buttonData = self.savedVars.customButtons[customButtonId]
    if not buttonData then
        return false
    end

    if buttonData.actionType == "cycle_group_role" then
        return CanUpdateSelectedLFGRole()
    elseif buttonData.actionType == "toggle_group_difficulty" then
        return self:IsVeteranDungeonDifficulty()
    elseif string.find(buttonData.actionType or "", "^summon_") then
        return false
    end

    local collectibleId = self:GetCollectibleIdFromCommand(buttonData.command)
    if collectibleId then
        local categoryType = GetCollectibleCategoryType(collectibleId)
        local activeCollectibleId = categoryType and GetActiveCollectibleByType(categoryType, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        return activeCollectibleId == collectibleId
    end

    return false
end

function ZeroPanel:ExecuteCustomButton(customButtonId)
    local buttonData = self.savedVars.customButtons[customButtonId]
    if not buttonData then
        return
    end

    if buttonData.actionType == "command" then
        self:ExecuteCommand(buttonData.command)
    elseif buttonData.actionType == "open_settings" then
        self:OpenSettings()
    elseif buttonData.actionType == "reload_ui" then
        ReloadUI()
    elseif buttonData.actionType == "cycle_group_role" then
        self:CycleGroupRole()
    elseif buttonData.actionType == "toggle_group_difficulty" then
        self:ToggleGroupDifficulty()
    elseif buttonData.actionType == "dismiss_combat_pets" then
        self:DismissCombatPets()
    elseif string.find(buttonData.actionType or "", "^summon_") then
        self:UseConfiguredCollectible(buttonData.actionType)
    end
end

function ZeroPanel:GetUnlockedCollectibles(actionId)
    local summonable = SUMMONABLES[actionId]
    local unlocked = {}
    if not summonable then
        return unlocked
    end

    for _, collectibleId in ipairs(summonable.ids) do
        if IsCollectibleUnlocked(collectibleId) then
            unlocked[#unlocked + 1] = collectibleId
        end
    end

    return unlocked
end

function ZeroPanel:HasUnlockedCollectible(actionId)
    return #self:GetUnlockedCollectibles(actionId) > 0
end

function ZeroPanel:GetCollectibleChoice(actionId)
    local summonable = SUMMONABLES[actionId]
    if not summonable then
        return nil
    end

    local defaultChoiceValue = summonable.defaultChoiceValue
    if type(defaultChoiceValue) ~= "number" then
        defaultChoiceValue = DEFAULT_COLLECTIBLE_CHOICE
    end

    self.savedVars.collectibleChoices = self.savedVars.collectibleChoices or {}
    local choice = self.savedVars.collectibleChoices[actionId]
    if choice == nil then
        choice = DEFAULTS.collectibleChoices[actionId]
        if type(choice) ~= "number" then
            choice = defaultChoiceValue
        end
        self.savedVars.collectibleChoices[actionId] = choice
    end

    if summonable.randomChoice and choice == DEFAULT_COLLECTIBLE_CHOICE and defaultChoiceValue == RANDOM_COLLECTIBLE_CHOICE then
        choice = defaultChoiceValue
        self.savedVars.collectibleChoices[actionId] = choice
    end

    if choice ~= DEFAULT_COLLECTIBLE_CHOICE and choice ~= RANDOM_COLLECTIBLE_CHOICE and not IsCollectibleUnlocked(choice) then
        choice = DEFAULTS.collectibleChoices[actionId]
        if type(choice) ~= "number" then
            choice = defaultChoiceValue
        end
        self.savedVars.collectibleChoices[actionId] = choice
    end

    return choice
end

function ZeroPanel:GetCollectibleChoiceEntries(actionId)
    local summonable = SUMMONABLES[actionId]
    local choices = {}
    local choiceValues = {}
    if not summonable then
        return choices, choiceValues
    end

    local defaultChoiceValue = summonable.defaultChoiceValue
    if type(defaultChoiceValue) ~= "number" then
        defaultChoiceValue = DEFAULT_COLLECTIBLE_CHOICE
    end

    choices[1] = summonable.defaultChoiceLabel
    choiceValues[1] = defaultChoiceValue

    local baseOffset = 1
    if summonable.randomChoice and type(summonable.randomChoiceLabel) == "string" and summonable.randomChoiceLabel ~= "" then
        choices[2] = summonable.randomChoiceLabel
        choiceValues[2] = RANDOM_COLLECTIBLE_CHOICE
        baseOffset = 2
    end

    local unlocked = self:GetUnlockedCollectibles(actionId)
    for index, collectibleId in ipairs(unlocked) do
        choices[index + baseOffset] = self:GetCollectibleName(collectibleId)
        choiceValues[index + baseOffset] = collectibleId
    end

    return choices, choiceValues
end

function ZeroPanel:GetActiveCollectibleForAction(actionId)
    local summonable = SUMMONABLES[actionId]
    if not summonable or not summonable.categoryType then
        return nil
    end

    local activeCollectibleId = GetActiveCollectibleByType(summonable.categoryType, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    if type(activeCollectibleId) == "number" and activeCollectibleId > 0 then
        return activeCollectibleId
    end

    return nil
end

function ZeroPanel:GetSelectedCollectibleId(actionId)
    local summonable = SUMMONABLES[actionId]
    if not summonable then
        return nil
    end

    local unlocked = self:GetUnlockedCollectibles(actionId)
    if #unlocked == 0 then
        return nil
    end

    local choice = self:GetCollectibleChoice(actionId)
    if choice ~= DEFAULT_COLLECTIBLE_CHOICE and choice ~= RANDOM_COLLECTIBLE_CHOICE and IsCollectibleUnlocked(choice) then
        return choice
    end

    if summonable.randomChoice and choice == RANDOM_COLLECTIBLE_CHOICE then
        local candidates = unlocked
        local activeCollectibleId = self:GetActiveCollectibleForAction(actionId)
        if #unlocked > 1 and activeCollectibleId then
            candidates = {}
            for _, collectibleId in ipairs(unlocked) do
                if collectibleId ~= activeCollectibleId then
                    candidates[#candidates + 1] = collectibleId
                end
            end
            if #candidates == 0 then
                candidates = unlocked
            end
        end

        return candidates[math.random(#candidates)]
    end

    return unlocked[1]
end

function ZeroPanel:GetSummonTooltip(actionId)
    local summonable = SUMMONABLES[actionId]
    if not summonable then
        return "Summon NPC."
    end

    local choice = self:GetCollectibleChoice(actionId)
    if summonable.randomChoice and choice == RANDOM_COLLECTIBLE_CHOICE then
        return summonable.randomTooltip or summonable.buttonTooltip
    end

    if choice ~= DEFAULT_COLLECTIBLE_CHOICE and choice ~= RANDOM_COLLECTIBLE_CHOICE and IsCollectibleUnlocked(choice) then
        return string.format("%s: %s.", summonable.tooltipPrefix, self:GetCollectibleName(choice))
    end

    return summonable.buttonTooltip
end

function ZeroPanel:UseConfiguredCollectible(actionId)
    local summonable = SUMMONABLES[actionId]
    local collectibleId = self:GetSelectedCollectibleId(actionId)
    if not collectibleId then
        self:Print((summonable and summonable.emptyText) or "No unlocked summonable NPC is available for that action.")
        return
    end

    local activeCollectibleId = self:GetActiveCollectibleForAction(actionId)
    if activeCollectibleId == collectibleId then
        self:Print(string.format("%s is already active.", self:GetCollectibleName(collectibleId)))
        return
    end

    UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
end

function ZeroPanel:HasDismissablePet()
    for buffIndex = 1, GetNumBuffs("player") do
        local _, _, _, buffSlot, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", buffIndex)
        if PET_BUFF_IDS[abilityId] and buffSlot then
            return true
        end
    end

    return false
end

function ZeroPanel:DismissCombatPets()
    local dismissedAny = false

    for buffIndex = 1, GetNumBuffs("player") do
        local _, _, _, buffSlot, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", buffIndex)
        if PET_BUFF_IDS[abilityId] and buffSlot then
            CancelBuff(buffSlot)
            dismissedAny = true
        end
    end

    if not dismissedAny then
        self:Print("No dismissable combat pets are active.")
    end
end

function ZeroPanel:CycleGroupRole()
    if not CanUpdateSelectedLFGRole() then
        return
    end

    local currentRole = GetSelectedLFGRole()
    local nextRole = ROLE_ORDER[1]

    for index, role in ipairs(ROLE_ORDER) do
        if role == currentRole then
            nextRole = ROLE_ORDER[(index % #ROLE_ORDER) + 1]
            break
        end
    end

    UpdateSelectedLFGRole(nextRole)
end

function ZeroPanel:ToggleGroupDifficulty()
    if not CanPlayerChangeGroupDifficulty() then
        return
    end

    SetVeteranDifficulty(not self:IsVeteranDungeonDifficulty())
end

function ZeroPanel:GetCurrentDungeonDifficulty()
    if type(ZO_GetEffectiveDungeonDifficulty) == "function" then
        local dungeonDifficulty = ZO_GetEffectiveDungeonDifficulty()
        if dungeonDifficulty ~= nil then
            return dungeonDifficulty
        end
    end

    local isVeteran = IsUnitUsingVeteranDifficulty("player")
    if isVeteran == true or isVeteran == 1 then
        return DUNGEON_DIFFICULTY_VETERAN
    end

    return DUNGEON_DIFFICULTY_NORMAL
end

function ZeroPanel:IsVeteranDungeonDifficulty()
    return self:GetCurrentDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN
end

function ZeroPanel:GetDungeonDifficultyName()
    return self:IsVeteranDungeonDifficulty() and "Veteran" or "Normal"
end

function ZeroPanel:GetCatalog()
    return BUTTON_DEFINITIONS
end

function ZeroPanel:GetCatalogByKey()
    local buttonsByKey = {}

    for _, definition in ipairs(self:GetCatalog()) do
        buttonsByKey[definition.uniqueKey] = definition
    end

    return buttonsByKey
end

function ZeroPanel:CreateCustomButtonDefinition(customButtonId)
    if not self.savedVars.customButtons[customButtonId] then
        return nil
    end

    return {
        id = GetCustomButtonLayoutKey(customButtonId),
        uniqueKey = GetCustomButtonLayoutKey(customButtonId),
        name = self:GetCustomButtonDisplayName(customButtonId),
        isCustom = true,
        customButtonId = customButtonId,
        icon = function()
            return self:GetCustomButtonIcon(customButtonId)
        end,
        tooltip = function()
            return self:GetCustomButtonResolvedTitle(customButtonId)
        end,
        isUsable = function()
            return self:IsCustomButtonUsable(customButtonId)
        end,
        isActive = function()
            return self:IsCustomButtonActive(customButtonId)
        end,
        click = function(panel)
            panel:ExecuteCustomButton(customButtonId)
        end,
    }
end

function ZeroPanel:GetLayoutCatalog()
    local layoutCatalog = {}

    for _, definition in ipairs(self:GetCatalog()) do
        layoutCatalog[#layoutCatalog + 1] = {
            key = GetDefaultButtonLayoutKey(definition.uniqueKey),
            orderUniqueKey = definition.uniqueKey,
            kind = "button",
            name = definition.name,
            definition = definition,
            builtin = true,
        }
    end

    for _, separatorDefinition in ipairs(DEFAULT_SEPARATOR_DEFINITIONS) do
        layoutCatalog[#layoutCatalog + 1] = {
            key = separatorDefinition.key,
            orderUniqueKey = separatorDefinition.orderUniqueKey,
            kind = "separator",
            name = separatorDefinition.name,
            tooltip = separatorDefinition.tooltip,
            builtin = true,
        }
    end

    for _, customButtonId in ipairs(self:GetCustomButtonIds()) do
        local definition = self:CreateCustomButtonDefinition(customButtonId)
        if definition then
            layoutCatalog[#layoutCatalog + 1] = {
                key = GetCustomButtonLayoutKey(customButtonId),
                orderUniqueKey = GetCustomButtonOrderUniqueKey(customButtonId),
                kind = "button",
                name = definition.name,
                definition = definition,
                custom = true,
                customButtonId = customButtonId,
            }
        end
    end

    for _, customSeparatorId in ipairs(self:GetCustomSeparatorIds()) do
        local separatorData = self.savedVars.customSeparators[customSeparatorId]
        layoutCatalog[#layoutCatalog + 1] = {
            key = GetCustomSeparatorLayoutKey(customSeparatorId),
            orderUniqueKey = GetCustomSeparatorOrderUniqueKey(customSeparatorId),
            kind = "separator",
            name = (separatorData and separatorData.name) or string.format("Custom Separator %d", customSeparatorId),
            tooltip = "Insert a horizontal separator line at this point in the panel layout.",
            custom = true,
            customSeparatorId = customSeparatorId,
        }
    end

    return layoutCatalog
end

function ZeroPanel:GetLayoutCatalogByKey()
    local entriesByKey = {}

    for _, entry in ipairs(self:GetLayoutCatalog()) do
        entriesByKey[entry.key] = entry
    end

    return entriesByKey
end

function ZeroPanel:EnsureCollectibleChoices()
    self.savedVars.collectibleChoices = self.savedVars.collectibleChoices or {}
    for _, actionId in ipairs(SUMMONABLE_ACTION_ORDER) do
        if self.savedVars.collectibleChoices[actionId] == nil then
            self.savedVars.collectibleChoices[actionId] = DEFAULTS.collectibleChoices[actionId] or DEFAULT_COLLECTIBLE_CHOICE
        end
    end
end

function ZeroPanel:EnsureOrder()
    local seen = {}
    local merged = {}
    local layoutByKey = self:GetLayoutCatalogByKey()

    for _, entryKey in ipairs(self.savedVars.order or {}) do
        local normalizedKey
        if type(entryKey) == "number" then
            normalizedKey = GetDefaultButtonLayoutKey(entryKey)
        elseif type(entryKey) == "string" then
            normalizedKey = entryKey
        end

        if normalizedKey and layoutByKey[normalizedKey] then
            AddUniqueValue(merged, seen, normalizedKey)
        end
    end

    for _, entryKey in ipairs(DEFAULT_LAYOUT_ORDER) do
        if layoutByKey[entryKey] then
            AddUniqueValue(merged, seen, entryKey)
        end
    end

    for _, customButtonId in ipairs(self:GetCustomButtonIds()) do
        AddUniqueValue(merged, seen, GetCustomButtonLayoutKey(customButtonId))
    end

    for _, customSeparatorId in ipairs(self:GetCustomSeparatorIds()) do
        AddUniqueValue(merged, seen, GetCustomSeparatorLayoutKey(customSeparatorId))
    end

    self.savedVars.order = merged
end

function ZeroPanel:IsButtonEnabledBySettings(definition)
    if definition.isCustom and definition.customButtonId then
        local buttonData = self.savedVars.customButtons[definition.customButtonId]
        return buttonData and buttonData.enabled ~= false
    end

    return self.savedVars.buttons[definition.id] ~= false
end

function ZeroPanel:ShouldDisplayButton(definition)
    if not self:IsButtonEnabledBySettings(definition) then
        return false
    end

    if definition.hideWhenUnavailable and definition.collectibleActionId then
        return self:HasUnlockedCollectible(definition.collectibleActionId)
    end

    return true
end

function ZeroPanel:IsButtonUsable(definition)
    if type(definition.isUsable) == "function" then
        return definition.isUsable()
    elseif definition.isUsable ~= nil then
        return definition.isUsable
    end

    return true
end

function ZeroPanel:IsButtonActive(definition)
    if type(definition.isActive) == "function" then
        return definition.isActive()
    elseif definition.isActive ~= nil then
        return definition.isActive
    end

    return false
end

function ZeroPanel:GetButtonIcon(definition)
    if type(definition.icon) == "function" then
        return definition.icon()
    end

    return definition.icon
end

function ZeroPanel:GetButtonTooltip(definition)
    if type(definition.tooltip) == "function" then
        return definition.tooltip(self)
    end

    return definition.tooltip or definition.name
end

function ZeroPanel:GetLayoutDirection()
    if self.savedVars.layoutDirection == "horizontal" then
        return "horizontal"
    end

    return "vertical"
end

function ZeroPanel:GetButtonsPerLine()
    local buttonsPerLine = tonumber(self.savedVars.buttonsPerLine) or DEFAULTS.buttonsPerLine
    buttonsPerLine = math.floor(buttonsPerLine)
    if buttonsPerLine < 1 then
        buttonsPerLine = 1
    end
    return buttonsPerLine
end

function ZeroPanel:GetMaximumVisibleButtons()
    local maxVisibleButtons = tonumber(self.savedVars.maxVisibleButtons) or DEFAULTS.maxVisibleButtons
    maxVisibleButtons = math.floor(maxVisibleButtons)
    if maxVisibleButtons < 1 then
        maxVisibleButtons = 1
    elseif maxVisibleButtons > 60 then
        maxVisibleButtons = 60
    end
    return maxVisibleButtons
end

function ZeroPanel:NormalizeOrderedLayoutEntries(layoutEntries)
    local normalizedEntries = {}
    local previousWasSeparator = true

    for _, entry in ipairs(layoutEntries) do
        if entry.kind == "separator" then
            if not previousWasSeparator then
                normalizedEntries[#normalizedEntries + 1] = entry
                previousWasSeparator = true
            end
        elseif entry.definition and self:ShouldDisplayButton(entry.definition) then
            normalizedEntries[#normalizedEntries + 1] = entry
            previousWasSeparator = false
        end
    end

    if #normalizedEntries > 0 and normalizedEntries[#normalizedEntries].kind == "separator" then
        table.remove(normalizedEntries)
    end

    return normalizedEntries
end

function ZeroPanel:GetOrderedLayoutEntries()
    local orderedEntries = {}
    local used = {}
    local layoutByKey = self:GetLayoutCatalogByKey()

    for _, entryKey in ipairs(self.savedVars.order or {}) do
        local entry = layoutByKey[entryKey]
        if entry then
            orderedEntries[#orderedEntries + 1] = entry
            used[entry.key] = true
        end
    end

    for _, defaultEntryKey in ipairs(DEFAULT_LAYOUT_ORDER) do
        local entry = layoutByKey[defaultEntryKey]
        if entry and not used[defaultEntryKey] then
            orderedEntries[#orderedEntries + 1] = entry
            used[defaultEntryKey] = true
        end
    end

    for _, customButtonId in ipairs(self:GetCustomButtonIds()) do
        local customEntryKey = GetCustomButtonLayoutKey(customButtonId)
        local entry = layoutByKey[customEntryKey]
        if entry and not used[customEntryKey] then
            orderedEntries[#orderedEntries + 1] = entry
            used[customEntryKey] = true
        end
    end

    for _, customSeparatorId in ipairs(self:GetCustomSeparatorIds()) do
        local customEntryKey = GetCustomSeparatorLayoutKey(customSeparatorId)
        local entry = layoutByKey[customEntryKey]
        if entry and not used[customEntryKey] then
            orderedEntries[#orderedEntries + 1] = entry
        end
    end

    return self:NormalizeOrderedLayoutEntries(orderedEntries)
end

function ZeroPanel:GetLayoutItems()
    local layoutItems = {}
    local visibleButtonCount = 0
    local maxVisibleButtons = self:GetMaximumVisibleButtons()

    for _, entry in ipairs(self:GetOrderedLayoutEntries()) do
        if entry.kind == "separator" then
            if visibleButtonCount > 0 and visibleButtonCount < maxVisibleButtons then
                layoutItems[#layoutItems + 1] = {
                    kind = "divider",
                    entry = entry,
                }
            end
        elseif entry.definition then
            if visibleButtonCount >= maxVisibleButtons then
                break
            end

            layoutItems[#layoutItems + 1] = {
                kind = "button",
                definition = entry.definition,
                entry = entry,
            }
            visibleButtonCount = visibleButtonCount + 1
        end
    end

    if #layoutItems > 0 and layoutItems[#layoutItems].kind == "divider" then
        table.remove(layoutItems)
    end

    return layoutItems
end

function ZeroPanel:GetLayoutHeight(layoutItems, buttonSize, spacing, padding)
    if #layoutItems == 0 then
        return buttonSize + (padding * 2)
    end

    local height = padding * 2
    for index, item in ipairs(layoutItems) do
        height = height + (item.kind == "divider" and DIVIDER_LAYOUT_HEIGHT or buttonSize)
        if index < #layoutItems then
            height = height + spacing
        end
    end

    return height
end

function ZeroPanel:BuildPanelLayout(layoutItems, buttonSize, spacing, padding)
    if #layoutItems == 0 then
        return {}, buttonSize + (padding * 2), buttonSize + (padding * 2)
    end

    local placements = {}
    local direction = self:GetLayoutDirection()
    local buttonsPerLine = self:GetButtonsPerLine()
    local majorOffset = padding
    local minorOffset = padding
    local buttonsInCurrentLine = 0
    local maxX = padding
    local maxY = padding

    local function WrapToNextLine()
        majorOffset = padding
        minorOffset = minorOffset + buttonSize + spacing
        buttonsInCurrentLine = 0
    end

    local function RegisterPlacement(kind, item, x, y, width, height)
        placements[#placements + 1] = {
            kind = kind,
            item = item,
            x = x,
            y = y,
            width = width,
            height = height,
        }
        maxX = math.max(maxX, x + width)
        maxY = math.max(maxY, y + height)
    end

    if direction == "horizontal" then
        local rowWidth = (buttonsPerLine * buttonSize) + (math.max(0, buttonsPerLine - 1) * spacing)

        local function AdvanceToNextRow(heightUsed)
            majorOffset = padding
            minorOffset = minorOffset + heightUsed + spacing
            buttonsInCurrentLine = 0
        end

        for _, item in ipairs(layoutItems) do
            if item.kind == "divider" then
                if buttonsInCurrentLine > 0 then
                    AdvanceToNextRow(buttonSize)
                end

                local dividerY = minorOffset + math.floor((DIVIDER_LAYOUT_HEIGHT - DIVIDER_LINE_HEIGHT) / 2)
                RegisterPlacement("divider", item, padding, dividerY, rowWidth, DIVIDER_LINE_HEIGHT)
                AdvanceToNextRow(DIVIDER_LAYOUT_HEIGHT)
            else
                RegisterPlacement("button", item, majorOffset, minorOffset, buttonSize, buttonSize)
                buttonsInCurrentLine = buttonsInCurrentLine + 1

                if buttonsInCurrentLine >= buttonsPerLine then
                    AdvanceToNextRow(buttonSize)
                else
                    majorOffset = majorOffset + buttonSize + spacing
                end
            end
        end
    else
        local columnHeight = (buttonsPerLine * buttonSize) + (math.max(0, buttonsPerLine - 1) * spacing)

        local function AdvanceToNextColumn(widthUsed)
            majorOffset = padding
            minorOffset = minorOffset + widthUsed + spacing
            buttonsInCurrentLine = 0
        end

        for _, item in ipairs(layoutItems) do
            if item.kind == "divider" then
                if buttonsInCurrentLine > 0 then
                    AdvanceToNextColumn(buttonSize)
                end

                local dividerX = minorOffset + math.floor((DIVIDER_LAYOUT_HEIGHT - DIVIDER_LINE_HEIGHT) / 2)
                RegisterPlacement("divider", item, dividerX, padding, DIVIDER_LINE_HEIGHT, columnHeight)
                AdvanceToNextColumn(DIVIDER_LAYOUT_HEIGHT)
            else
                RegisterPlacement("button", item, minorOffset, majorOffset, buttonSize, buttonSize)
                buttonsInCurrentLine = buttonsInCurrentLine + 1

                if buttonsInCurrentLine >= buttonsPerLine then
                    AdvanceToNextColumn(buttonSize)
                else
                    majorOffset = majorOffset + buttonSize + spacing
                end
            end
        end
    end

    return placements, maxX + padding, maxY + padding
end

function ZeroPanel:SetSelectedLayoutOrderKey(layoutKey)
    if type(layoutKey) == "string" and self:GetLayoutCatalogByKey()[layoutKey] then
        self.selectedLayoutOrderKey = layoutKey
    else
        self.selectedLayoutOrderKey = nil
    end
end

function ZeroPanel:GetSelectedLayoutEntry()
    local layoutKey = self.selectedLayoutOrderKey
    if type(layoutKey) ~= "string" or layoutKey == "" then
        return nil
    end

    return self:GetLayoutCatalogByKey()[layoutKey]
end

function ZeroPanel:GetLayoutOrderKeyFromSelectedData(selectedData)
    if type(selectedData) ~= "table" then
        return nil
    end

    local layoutByKey = self:GetLayoutCatalogByKey()
    local candidateTables = {selectedData}

    if type(selectedData.data) == "table" then
        candidateTables[#candidateTables + 1] = selectedData.data
    end

    for _, candidate in ipairs(candidateTables) do
        local layoutKey = candidate.value
        if type(layoutKey) == "string" and layoutByKey[layoutKey] then
            return layoutKey
        end
    end

    for _, candidate in ipairs(candidateTables) do
        local uniqueKey = tonumber(candidate.uniqueKey)
        if uniqueKey then
            for _, entry in ipairs(self:GetOrderListEntries()) do
                if tonumber(entry.uniqueKey) == uniqueKey and type(entry.value) == "string" and layoutByKey[entry.value] then
                    return entry.value
                end
            end
        end
    end

    return nil
end

function ZeroPanel:SyncEditorSelectionFromLayoutEntry(entry)
    if type(entry) ~= "table" then
        return
    end

    if entry.customButtonId ~= nil and self.savedVars.customButtons[entry.customButtonId] then
        self.selectedCustomButtonId = entry.customButtonId
        self.selectedEditorLayoutKey = entry.key
    elseif entry.customSeparatorId ~= nil and self.savedVars.customSeparators[entry.customSeparatorId] then
        self.selectedCustomSeparatorId = entry.customSeparatorId
        self.selectedEditorLayoutKey = entry.key
    elseif entry.builtin then
        self.selectedEditorLayoutKey = nil
    end
end

function ZeroPanel:HandleLayoutOrderSelection(selectedData)
    local layoutKey = self:GetLayoutOrderKeyFromSelectedData(selectedData)
    self:SetSelectedLayoutOrderKey(layoutKey)

    local entry = self:GetSelectedLayoutEntry()
    if entry then
        self:SyncEditorSelectionFromLayoutEntry(entry)
    end
end

function ZeroPanel:GetSelectedLayoutEntryFromOrderListControl()
    local orderListControl = _G.ZeroPanelLayoutOrderList
    local orderListBox = orderListControl and orderListControl.orderListBox
    local scrollListControl = orderListBox and orderListBox.scrollListControl
    if not scrollListControl then
        return nil
    end

    local selectedData = type(ZO_ScrollList_GetSelectedData) == "function" and ZO_ScrollList_GetSelectedData(scrollListControl) or nil
    if not selectedData then
        local selectedIndex = type(ZO_ScrollList_GetSelectedDataIndex) == "function" and ZO_ScrollList_GetSelectedDataIndex(scrollListControl) or nil
        local selectedEntry = selectedIndex and scrollListControl.data and scrollListControl.data[selectedIndex]
        selectedData = selectedEntry and (selectedEntry.data or selectedEntry) or nil
    end

    local layoutKey = self:GetLayoutOrderKeyFromSelectedData(selectedData)
    if type(layoutKey) ~= "string" or layoutKey == "" then
        return nil
    end

    return self:GetLayoutCatalogByKey()[layoutKey], layoutKey
end

function ZeroPanel:SyncLayoutSelectionFromOrderListControl()
    local entry, layoutKey = self:GetSelectedLayoutEntryFromOrderListControl()
    if entry and layoutKey then
        self:SetSelectedLayoutOrderKey(layoutKey)
        self:SyncEditorSelectionFromLayoutEntry(entry)
    end

    return entry
end

function ZeroPanel:GetDeleteSelectedLayoutEntry()
    local entry = self:SyncLayoutSelectionFromOrderListControl()
    if entry then
        return entry
    end

    entry = self:GetSelectedLayoutEntry()
    if entry then
        return entry
    end

    local layoutKey = self.selectedEditorLayoutKey
    if type(layoutKey) == "string" and layoutKey ~= "" then
        return self:GetLayoutCatalogByKey()[layoutKey]
    end

    return nil
end

function ZeroPanel:IsLayoutEntryRemovable(entry)
    return entry ~= nil and (entry.customButtonId ~= nil or entry.customSeparatorId ~= nil)
end

function ZeroPanel:GetButtonOrderHelpText()
    return table.concat({
        "Drag rows or use the move buttons to change the live Zero Panel order.",
        string.format("|c%sGold rows|r are removable custom buttons or custom separators.", ORDER_ENTRY_REMOVABLE_HEX),
        string.format("|c%sGray rows|r are built-in Zero Panel entries. You can reorder or hide them, but you cannot delete them.", ORDER_ENTRY_FIXED_HEX),
        string.format("To delete a removable entry, click its row first, then press |c%sDelete Selected Entry|r below.", ORDER_HELP_DELETE_HEX),
        "Hidden or unavailable rows still keep their saved place here.",
    }, "\n")
end

function ZeroPanel:GetDeleteSelectedLayoutEntryReason()
    local entry = self:GetDeleteSelectedLayoutEntry()
    if not entry then
        return "No row is selected in Reorder Layout. Click a row there, or pick a custom button or custom separator so Zero Panel can target its layout entry."
    end

    local entryName = tostring(entry.name or entry.key or "Selected entry")
    if not self:IsLayoutEntryRemovable(entry) then
        local entryType = entry.kind == "separator" and "built-in separator" or "built-in button"
        return string.format("%s is a %s, so it cannot be deleted.", entryName, entryType)
    end

    if entry.customSeparatorId ~= nil then
        return string.format("%s is the selected custom separator and can be deleted.", entryName)
    elseif entry.customButtonId ~= nil then
        return string.format("%s is the selected custom button and can be deleted.", entryName)
    end

    return string.format("%s is selected and can be deleted.", entryName)
end

function ZeroPanel:GetDeleteSelectedLayoutEntryTooltip()
    return table.concat({
        "Delete the selected removable layout entry from Zero Panel.",
        "Current Reason: " .. self:GetDeleteSelectedLayoutEntryReason(),
    }, "\n")
end

function ZeroPanel:GetDeleteSelectedLayoutEntryWarning()
    local entry = self:GetDeleteSelectedLayoutEntry()
    if not self:IsLayoutEntryRemovable(entry) then
        return nil
    end

    local entryName = tostring(entry.name or entry.key or "Selected entry")
    if entry.customSeparatorId ~= nil then
        return string.format("Delete %s from Zero Panel? This removes the selected custom separator from Button Order.", entryName)
    elseif entry.customButtonId ~= nil then
        return string.format("Delete %s from Zero Panel? This removes the selected custom button from Button Order.", entryName)
    end

    return string.format("Delete %s from Zero Panel?", entryName)
end

function ZeroPanel:ApplySettingsVisualStyles()
    local buttonOrderHelp = _G.ZeroPanelButtonOrderHelp
    if buttonOrderHelp and buttonOrderHelp.desc then
        buttonOrderHelp.desc:SetFont("ZoFontGameSmall")
    end
end

function ZeroPanel:RefreshButtonOrderControlState()
    self:SyncLayoutSelectionFromOrderListControl()

    local deleteControl = _G.ZeroPanelDeleteLayoutEntryButton
    if deleteControl then
        local tooltipText = self:GetDeleteSelectedLayoutEntryTooltip()
        deleteControl.data = deleteControl.data or {}
        deleteControl.data.tooltipText = tooltipText

        if deleteControl.button then
            deleteControl.button.data = deleteControl.button.data or {}
            deleteControl.button.data.tooltipText = tooltipText
        end

        if not deleteControl.zeroPanelTooltipHandlersBound then
            deleteControl:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
            deleteControl:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
            deleteControl.zeroPanelTooltipHandlersBound = true
        end

        if type(deleteControl.UpdateDisabled) == "function" then
            deleteControl:UpdateDisabled()
        end

        if type(deleteControl.UpdateWarning) == "function" then
            deleteControl:UpdateWarning()
        elseif deleteControl.warning then
            deleteControl.warning.data = deleteControl.warning.data or {}
            deleteControl.warning.data.tooltipText = self:GetDeleteSelectedLayoutEntryWarning()
        end
    end

    self:ApplySettingsVisualStyles()
end

function ZeroPanel:GetLayoutEntryTooltip(entry)
    if entry.kind == "separator" then
        local tooltipText = entry.tooltip or "Insert a horizontal separator line at this point in the panel layout."
        if self:IsLayoutEntryRemovable(entry) then
            return tooltipText .. "\nThis custom separator can be deleted from Button Order."
        end
        return tooltipText .. "\nThis built-in separator cannot be deleted."
    elseif entry.definition then
        local tooltipText = self:GetButtonTooltip(entry.definition)
        if self:IsLayoutEntryRemovable(entry) then
            return tooltipText .. "\nThis custom button can be deleted from Button Order."
        end
        return tooltipText .. "\nThis built-in button cannot be deleted."
    end

    return ""
end

function ZeroPanel:GetOrderListEntries()
    self:EnsureOrder()

    local entries = {}
    local layoutByKey = self:GetLayoutCatalogByKey()

    for _, entryKey in ipairs(self.savedVars.order or {}) do
        local entry = layoutByKey[entryKey]
        if entry then
            local orderUniqueKey = tonumber(entry.orderUniqueKey)
            local suffix = ""
            if entry.kind == "button" and entry.definition then
                if not self:IsButtonEnabledBySettings(entry.definition) then
                    suffix = "(hidden)"
                elseif entry.definition.hideWhenUnavailable and entry.definition.collectibleActionId and not self:HasUnlockedCollectible(entry.definition.collectibleActionId) then
                    suffix = "(unavailable)"
                end
            end

            if orderUniqueKey then
                local entryColorHex = self:IsLayoutEntryRemovable(entry) and ORDER_ENTRY_REMOVABLE_HEX or ORDER_ENTRY_FIXED_HEX
                local entryText = string.format("|c%s%s|r", entryColorHex, tostring(entry.name or entry.key))
                if suffix ~= "" then
                    entryText = string.format("%s |c%s%s|r", entryText, ORDER_ENTRY_STATUS_HEX, suffix)
                end

                entries[#entries + 1] = {
                    uniqueKey = orderUniqueKey,
                    value = entry.key,
                    text = entryText,
                    tooltip = self:GetLayoutEntryTooltip(entry),
                }
            end
        end
    end

    return entries
end

function ZeroPanel:GetCustomButtonChoiceEntries()
    local choices = {}
    local values = {}

    for _, customButtonId in ipairs(self:GetCustomButtonIds()) do
        choices[#choices + 1] = self:GetCustomButtonDisplayName(customButtonId)
        values[#values + 1] = customButtonId
    end

    if #choices == 0 then
        choices[1] = "No custom buttons yet."
        values[1] = 0
    end

    return choices, values
end

function ZeroPanel:GetCustomSeparatorChoiceEntries()
    local choices = {}
    local values = {}

    for _, customSeparatorId in ipairs(self:GetCustomSeparatorIds()) do
        local separatorData = self.savedVars.customSeparators[customSeparatorId]
        choices[#choices + 1] = (separatorData and separatorData.name) or string.format("Custom Separator %d", customSeparatorId)
        values[#values + 1] = customSeparatorId
    end

    if #choices == 0 then
        choices[1] = "No custom separators yet."
        values[1] = 0
    end

    return choices, values
end

function ZeroPanel:RefreshCustomEditorControls()
    local customButtonChoices, customButtonValues = self:GetCustomButtonChoiceEntries()
    local customButtonId = self:GetSelectedCustomButtonId() or 0
    self:UpdateDropdownReference("ZeroPanelCustomButtonSelector", customButtonChoices, customButtonValues, customButtonId)

    local customSeparatorChoices, customSeparatorValues = self:GetCustomSeparatorChoiceEntries()
    local customSeparatorId = self:GetSelectedCustomSeparatorId() or 0
    self:UpdateDropdownReference("ZeroPanelCustomSeparatorSelector", customSeparatorChoices, customSeparatorValues, customSeparatorId)

    self:RefreshCollectibleBrowserControls()
    self:RefreshTextureBrowserControls()
    self:RefreshButtonOrderControlState()
    self:RequestSettingsRefresh()
end

function ZeroPanel:RemoveLayoutKey(layoutKey)
    local filteredOrder = {}

    for _, entryKey in ipairs(self.savedVars.order or {}) do
        if entryKey ~= layoutKey then
            filteredOrder[#filteredOrder + 1] = entryKey
        end
    end

    self.savedVars.order = filteredOrder
end

function ZeroPanel:CreateCustomButton()
    local customButtonId = tonumber(self.savedVars.nextCustomButtonId) or 1
    self.savedVars.nextCustomButtonId = customButtonId + 1
    self.savedVars.customButtons[customButtonId] = {
        enabled = true,
        actionType = "command",
        title = "",
        useAutoTitle = true,
        icon = "",
        command = "",
    }

    self.savedVars.order[#self.savedVars.order + 1] = GetCustomButtonLayoutKey(customButtonId)
    self:SetSelectedCustomButtonId(customButtonId)
    self:EnsureOrder()
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:DeleteSelectedCustomButton()
    local customButtonId = self:GetSelectedCustomButtonId()
    if not customButtonId then
        return
    end

    self.savedVars.customButtons[customButtonId] = nil
    local layoutKey = GetCustomButtonLayoutKey(customButtonId)
    self:RemoveLayoutKey(layoutKey)
    if self.selectedLayoutOrderKey == layoutKey then
        self:SetSelectedLayoutOrderKey(nil)
    end
    if self.selectedEditorLayoutKey == layoutKey then
        self.selectedEditorLayoutKey = nil
    end
    self:SetSelectedCustomButtonId(nil)
    self:EnsureOrder()
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:SaveSelectedCustomButton()
    local customButtonData = self:GetSelectedCustomButtonData()
    if not customButtonData then
        return
    end

    customButtonData.title = TrimText(customButtonData.title)
    customButtonData.icon = TrimText(customButtonData.icon)
    if customButtonData.actionType == "command" then
        customButtonData.command = tostring(customButtonData.command or "")
    else
        customButtonData.command = ""
    end

    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:AddCustomSeparator()
    local customSeparatorId = tonumber(self.savedVars.nextCustomSeparatorId) or 1
    self.savedVars.nextCustomSeparatorId = customSeparatorId + 1
    self.savedVars.customSeparators[customSeparatorId] = {
        name = string.format("Custom Separator %d", customSeparatorId),
    }

    self.savedVars.order[#self.savedVars.order + 1] = GetCustomSeparatorLayoutKey(customSeparatorId)
    self:SetSelectedCustomSeparatorId(customSeparatorId)
    self:EnsureOrder()
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:DeleteSelectedCustomSeparator()
    local customSeparatorId = self:GetSelectedCustomSeparatorId()
    if not customSeparatorId then
        return
    end

    self.savedVars.customSeparators[customSeparatorId] = nil
    local layoutKey = GetCustomSeparatorLayoutKey(customSeparatorId)
    self:RemoveLayoutKey(layoutKey)
    if self.selectedLayoutOrderKey == layoutKey then
        self:SetSelectedLayoutOrderKey(nil)
    end
    if self.selectedEditorLayoutKey == layoutKey then
        self.selectedEditorLayoutKey = nil
    end
    self:SetSelectedCustomSeparatorId(nil)
    self:EnsureOrder()
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:CanDeleteSelectedLayoutEntry()
    return self:IsLayoutEntryRemovable(self:GetDeleteSelectedLayoutEntry())
end

function ZeroPanel:DeleteSelectedLayoutEntry()
    local entry = self:GetDeleteSelectedLayoutEntry()
    if not self:IsLayoutEntryRemovable(entry) then
        self:Print(self:GetDeleteSelectedLayoutEntryReason())
        return
    end

    if entry.customButtonId ~= nil then
        self.savedVars.customButtons[entry.customButtonId] = nil
        if self.selectedCustomButtonId == entry.customButtonId then
            self:SetSelectedCustomButtonId(nil)
        end
    elseif entry.customSeparatorId ~= nil then
        self.savedVars.customSeparators[entry.customSeparatorId] = nil
        if self.selectedCustomSeparatorId == entry.customSeparatorId then
            self:SetSelectedCustomSeparatorId(nil)
        end
    end

    self:RemoveLayoutKey(entry.key)
    self:SetSelectedLayoutOrderKey(nil)
    if self.selectedEditorLayoutKey == entry.key then
        self.selectedEditorLayoutKey = nil
    end
    self:EnsureOrder()
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:ApplyCustomButtonPreset(presetId)
    local customButtonData = self:GetSelectedCustomButtonData()
    local preset = GetCustomButtonPresetById(presetId)
    if not customButtonData or not preset then
        return
    end

    customButtonData.enabled = true
    customButtonData.actionType = preset.actionType or "command"
    customButtonData.useAutoTitle = true
    customButtonData.title = ""
    customButtonData.icon = preset.icon or ""
    customButtonData.command = preset.command or ""
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:ApplySelectedCollectibleToCustomButton()
    local customButtonData = self:GetSelectedCustomButtonData()
    local state = self:GetCollectibleBrowserState()
    local collectibleId = tonumber(state.selectedCollectibleId) or 0
    if not customButtonData or collectibleId <= 0 then
        return
    end

    customButtonData.enabled = true
    customButtonData.actionType = "command"
    customButtonData.useAutoTitle = true
    customButtonData.title = ""
    customButtonData.icon = GetCollectibleIcon(collectibleId) or ""
    customButtonData.command = string.format("/script UseCollectible(%d, GAMEPLAY_ACTOR_CATEGORY_PLAYER)", collectibleId)
    self:RefreshPanel()
    self:RefreshCustomEditorControls()
end

function ZeroPanel:GetCustomButtonEditorDescription()
    local customButtonId = self:GetSelectedCustomButtonId()
    local customButtonData = self:GetSelectedCustomButtonData()
    if not customButtonId or not customButtonData then
        return "Create a custom button, then select it here to edit its action, icon, and hover title. Default Zero Panel buttons cannot be edited in this section."
    end

    local parts = {
        string.format("Editing custom button %d.", customButtonId),
        string.format("Current title: %s", self:GetCustomButtonResolvedTitle(customButtonId)),
    }

    local action = self:GetCustomButtonAction(customButtonData.actionType)
    parts[#parts + 1] = string.format("Action type: %s.", action.name or customButtonData.actionType)

    local command = TrimText(customButtonData.command)
    if customButtonData.actionType == "command" then
        if command ~= "" then
            parts[#parts + 1] = string.format("Command: %s.", command)
        else
            parts[#parts + 1] = "No command is configured yet."
        end
    end

    return table.concat(parts, " ")
end

function ZeroPanel:GetCustomButtonEditorTitleValue()
    local customButtonId = self:GetSelectedCustomButtonId()
    local buttonData = self:GetSelectedCustomButtonData()
    if not customButtonId or not buttonData then
        return ""
    end

    local customTitle = TrimText(buttonData.title)
    if buttonData.useAutoTitle and customTitle == "" then
        return self:GetCustomButtonResolvedTitle(customButtonId)
    end

    return customTitle
end

function ZeroPanel:ApplyAnchor()
    if not self.window then
        return
    end

    local edge = self.savedVars.edge == "right" and "right" or "left"
    local xOffset = tonumber(self.savedVars.offsetX) or DEFAULTS.offsetX
    local yOffset = tonumber(self.savedVars.offsetY) or DEFAULTS.offsetY
    local clampedXOffset, clampedYOffset = GetClampedWindowOffsets(self.window, xOffset, yOffset)

    if clampedXOffset ~= xOffset or clampedYOffset ~= yOffset then
        self.savedVars.offsetX = clampedXOffset
        self.savedVars.offsetY = clampedYOffset
    end

    self.window:ClearAnchors()
    if edge == "right" then
        self.window:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -clampedXOffset, clampedYOffset)
    else
        self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, clampedXOffset, clampedYOffset)
    end
end

function ZeroPanel:SaveAnchor()
    if not self.window then
        return
    end

    local centerX = (self.window:GetLeft() or 0) + (self.window:GetWidth() / 2)
    local guiCenterX = GuiRoot:GetWidth() / 2
    local isRight = centerX >= guiCenterX

    self.savedVars.edge = isRight and "right" or "left"
    self.savedVars.offsetY = self.window:GetTop() or DEFAULTS.offsetY
    if isRight then
        self.savedVars.offsetX = GuiRoot:GetWidth() - (self.window:GetRight() or GuiRoot:GetWidth())
    else
        self.savedVars.offsetX = self.window:GetLeft() or DEFAULTS.offsetX
    end

    ResetTopLevelAnchor(self.window, self.savedVars.edge)
end

function ZeroPanel:ResetPosition()
    self.savedVars.edge = DEFAULTS.edge
    self.savedVars.offsetX = DEFAULTS.offsetX
    self.savedVars.offsetY = DEFAULTS.offsetY
    self:ApplyAnchor()
end

function ZeroPanel:StopWindowMovement()
    if self.window and self.isMovingWindow then
        self.window:StopMovingOrResizing()
    end

    self.isMovingWindow = false
end

function ZeroPanel:ApplyWindowLockState()
    if not self.window or not self.backdrop then
        return
    end

    if self.savedVars.locked then
        self:StopWindowMovement()
    end

    self.window:SetMovable(not self.savedVars.locked)
    self.backdrop:SetEdgeColor(unpack(self.savedVars.locked and BORDER_LOCKED or BORDER_UNLOCKED))
    self.backdrop:SetMouseEnabled(not self.savedVars.locked)
end

function ZeroPanel:IsMouseOverControl(control)
    if not control or control:IsHidden() then
        return false
    end

    if type(MouseIsOver) == "function" then
        return MouseIsOver(control)
    end

    return WINDOW_MANAGER:GetMouseOverControl() == control
end

function ZeroPanel:RefreshButtonHoverState(control)
    if not control or not control.bg then
        return
    end

    local isHovered = self:IsMouseOverControl(control)
    if isHovered then
        control.bg:SetCenterColor(0.18, 0.20, 0.26, 0.98)
        if control.definition then
            ZO_Tooltips_ShowTextTooltip(control, RIGHT, self:GetButtonTooltip(control.definition))
        end
    else
        control.bg:SetCenterColor(0.12, 0.13, 0.17, 0.96)
        ZO_Tooltips_HideTextTooltip()
    end
end

function ZeroPanel:RefreshButtonHoverStates()
    local hoveredButton

    for _, button in ipairs(self.buttons or {}) do
        if button and not button:IsHidden() and button.bg then
            local isHovered = self:IsMouseOverControl(button)
            if isHovered then
                hoveredButton = button
                button.bg:SetCenterColor(0.18, 0.20, 0.26, 0.98)
            else
                button.bg:SetCenterColor(0.12, 0.13, 0.17, 0.96)
            end
        end
    end

    if hoveredButton and hoveredButton.definition then
        ZO_Tooltips_ShowTextTooltip(hoveredButton, RIGHT, self:GetButtonTooltip(hoveredButton.definition))
    else
        ZO_Tooltips_HideTextTooltip()
    end
end

function ZeroPanel:QueueHoveredTooltipRefresh()
    if type(zo_callLater) ~= "function" then
        self:RefreshButtonHoverStates()
        return
    end

    self.hoverTooltipRefreshToken = (tonumber(self.hoverTooltipRefreshToken) or 0) + 1
    local refreshToken = self.hoverTooltipRefreshToken
    local refreshDelays = {25, 125}

    for _, delayMs in ipairs(refreshDelays) do
        zo_callLater(function()
            if self.hoverTooltipRefreshToken ~= refreshToken then
                return
            end

            self:RefreshPanel()
        end, delayMs)
    end
end

function ZeroPanel:CreateWindow()
    if self.window then
        return
    end

    local window = WINDOW_MANAGER:CreateTopLevelWindow(CONTROL_NAME_PREFIX .. "Window")
    window:SetClampedToScreen(true)
    window:SetMovable(false)
    window:SetMouseEnabled(true)
    window:SetDrawTier(DT_MEDIUM)
    window:SetHandler("OnMoveStart", function()
        self.isMovingWindow = true
    end)
    window:SetHandler("OnMoveStop", function()
        local wasMoving = self.isMovingWindow
        self.isMovingWindow = false
        if wasMoving then
            self:SaveAnchor()
        end
    end)
    window:SetHandler("OnEffectivelyShown", function()
        self:RefreshVisibility()
    end)

    local backdrop = WINDOW_MANAGER:CreateControl(window:GetName() .. "Backdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill()
    backdrop:SetCenterColor(0.08, 0.09, 0.12, 0.72)
    backdrop:SetEdgeColor(unpack(self.savedVars.locked and BORDER_LOCKED or BORDER_UNLOCKED))
    backdrop:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not self.savedVars.locked then
            self.isMovingWindow = true
            window:StartMoving()
        end
    end)
    backdrop:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StopWindowMovement()
        end
    end)

    self.window = window
    self.backdrop = backdrop
    self:ApplyWindowLockState()
    self.fragment = ZO_SimpleSceneFragment:New(window)
    self.sceneRegistration = {
        hud = false,
        hudui = false,
    }
end

function ZeroPanel:UpdateSceneRegistration()
    if not self.fragment then
        return
    end

    if not self.sceneRegistration.hud then
        HUD_SCENE:AddFragment(self.fragment)
        self.sceneRegistration.hud = true
    end

    local wantsHudUi = self.savedVars.showInHudUI == true
    if wantsHudUi and not self.sceneRegistration.hudui then
        HUD_UI_SCENE:AddFragment(self.fragment)
        self.sceneRegistration.hudui = true
    elseif not wantsHudUi and self.sceneRegistration.hudui then
        HUD_UI_SCENE:RemoveFragment(self.fragment)
        self.sceneRegistration.hudui = false
    end
end

function ZeroPanel:RefreshButtonAppearance(button, definition)
    local usable = self:IsButtonUsable(definition)
    local active = usable and self:IsButtonActive(definition)

    button.icon:SetTexture(self:GetButtonIcon(definition) or "")
    if active then
        button.icon:SetColor(unpack(COLOR_ACTIVE))
    elseif usable then
        button.icon:SetColor(unpack(COLOR_READY))
    else
        button.icon:SetColor(unpack(COLOR_DISABLED))
    end

    button.usable = usable
    button.definition = definition
    button:SetMouseEnabled(true)
end

function ZeroPanel:RefreshPanel()
    if not self.window then
        return
    end

    local layoutItems = self:GetLayoutItems()
    local buttonSize = tonumber(self.savedVars.buttonSize) or DEFAULTS.buttonSize
    local spacing = tonumber(self.savedVars.spacing) or DEFAULTS.spacing
    local padding = tonumber(self.savedVars.padding) or DEFAULTS.padding
    local placements, panelWidth, panelHeight = self:BuildPanelLayout(layoutItems, buttonSize, spacing, padding)
    local buttonCount = 0
    for _, item in ipairs(layoutItems) do
        if item.kind == "button" then
            buttonCount = buttonCount + 1
        end
    end
    self.hasButtons = buttonCount > 0

    self.window:SetDimensions(panelWidth, panelHeight)
    self:ApplyAnchor()

    self.backdrop:SetCenterColor(0.08, 0.09, 0.12, (tonumber(self.savedVars.backgroundAlpha) or DEFAULTS.backgroundAlpha) / 100)
    self:ApplyWindowLockState()

    self.buttons = self.buttons or {}
    self.dividers = self.dividers or {}

    local buttonIndex = 0
    local dividerIndex = 0
    for _, placement in ipairs(placements) do
        if placement.kind == "divider" then
            dividerIndex = dividerIndex + 1
            local divider = self.dividers[dividerIndex]
            if not divider then
                divider = WINDOW_MANAGER:CreateControl(self.window:GetName() .. "Divider" .. dividerIndex, self.window, CT_BACKDROP)
                divider:SetMouseEnabled(false)
                self.dividers[dividerIndex] = divider
            end

            divider:ClearAnchors()
            divider:SetDimensions(placement.width, placement.height)
            divider:SetAnchor(TOPLEFT, self.window, TOPLEFT, placement.x, placement.y)
            divider:SetCenterColor(unpack(DIVIDER_COLOR))
            divider:SetEdgeColor(0, 0, 0, 0)
            divider:SetHidden(false)
        else
            buttonIndex = buttonIndex + 1
            local definition = placement.item.definition
            local button = self.buttons[buttonIndex]
            if not button then
                button = WINDOW_MANAGER:CreateControl(self.window:GetName() .. "Button" .. buttonIndex, self.window, CT_BUTTON)
                button:SetDrawTier(DT_MEDIUM)

                button.bg = WINDOW_MANAGER:CreateControl(button:GetName() .. "Backdrop", button, CT_BACKDROP)
                button.bg:SetAnchorFill()
                button.bg:SetCenterColor(0.12, 0.13, 0.17, 0.96)
                button.bg:SetEdgeColor(0.22, 0.22, 0.26, 1)

                button.icon = WINDOW_MANAGER:CreateControl(nil, button, CT_TEXTURE)
                button.icon:SetAnchorFill()
                button.icon:SetDrawLevel(1)

                button:SetHandler("OnMouseEnter", function(control)
                    self:RefreshButtonHoverStates()
                end)
                button:SetHandler("OnMouseExit", function(control)
                    self:RefreshButtonHoverStates()
                end)
                button:SetHandler("OnClicked", function(control)
                    if control.usable and control.definition and control.definition.click then
                        control.definition.click(self)
                        self:RefreshPanel()
                        self:QueueHoveredTooltipRefresh()
                    end
                end)

                self.buttons[buttonIndex] = button
            end

            button:ClearAnchors()
            button:SetDimensions(placement.width, placement.height)
            button:SetAnchor(TOPLEFT, self.window, TOPLEFT, placement.x, placement.y)
            button:SetHidden(false)
            self:RefreshButtonAppearance(button, definition)
        end
    end

    for index = buttonIndex + 1, #(self.buttons or {}) do
        self.buttons[index]:SetHidden(true)
    end

    for index = dividerIndex + 1, #(self.dividers or {}) do
        self.dividers[index]:SetHidden(true)
    end

    self:RefreshButtonHoverStates()
    self:RefreshVisibility()
end

function ZeroPanel:RefreshVisibility()
    if not self.window then
        return
    end

    local shouldShow = self.savedVars.enabled
    if shouldShow and self.savedVars.showOnlyWhenReticleHidden then
        shouldShow = self.reticleHidden ~= false
    end
    if shouldShow then
        shouldShow = self.hasButtons ~= false
    end

    self.window:SetHidden(not shouldShow)
end

function ZeroPanel:OpenSettings()
    if self.addonPanel then
        LibAddonMenu2:OpenToPanel(self.addonPanel)
        if type(zo_callLater) == "function" then
            zo_callLater(function()
                self:RefreshCustomEditorControls()
                self:ApplySettingsVisualStyles()
            end, 50)
        else
            self:RefreshButtonOrderControlState()
        end
    end
end

function ZeroPanel:BuildSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local panelData = {
        type = "panel",
        name = ZERO_PANEL_SETTINGS_NAME,
        displayName = ZERO_PANEL_SETTINGS_NAME,
        author = GetBrandedZeroAddonName(),
        version = self.versionDisplay,
        slashCommand = "/zp",
        website = ZERO_PANEL_GITHUB_URL,
        feedback = ZERO_PANEL_GITHUB_ISSUES_URL,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    self.addonPanel = LAM:RegisterAddonPanel(self.panelId, panelData)
    if not self.lamPanelClosedCallback and CALLBACK_MANAGER and type(CALLBACK_MANAGER.RegisterCallback) == "function" then
        self.lamPanelClosedCallback = function(panel)
            if panel ~= self.addonPanel then
                return
            end

            self:CloseCollectibleBrowserPopup()
            self:CloseTextureBrowserPopup()
        end
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", self.lamPanelClosedCallback)
    end

    local visibleButtonsControls = {}
    local appearanceControls = {
        {
            type = "description",
            text = "Adjust the panel layout and visual styling. Layout Direction flips the bar between vertical and horizontal flow, while Buttons Per Line controls when the panel wraps to the next column or row.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Layout Direction",
            tooltip = "Vertical stacks buttons top to bottom. Horizontal runs them left to right. Buttons Per Line controls how many buttons fit before wrapping.",
            choices = {"Vertical", "Horizontal"},
            choicesValues = {"vertical", "horizontal"},
            getFunc = function()
                return self:GetLayoutDirection()
            end,
            setFunc = function(value)
                self.savedVars.layoutDirection = value == "horizontal" and "horizontal" or "vertical"
                self:RefreshPanel()
            end,
            default = DEFAULTS.layoutDirection,
            width = "half",
        },
        {
            type = "slider",
            name = "Buttons Per Line",
            tooltip = "How many buttons fit on each column or row before Zero Panel wraps to the next line. Separators stay in sequence and do not count toward this limit.",
            min = 1,
            max = 24,
            step = 1,
            getFunc = function()
                return self:GetButtonsPerLine()
            end,
            setFunc = function(value)
                self.savedVars.buttonsPerLine = math.max(1, math.floor(tonumber(value) or DEFAULTS.buttonsPerLine))
                self:RefreshPanel()
            end,
            default = DEFAULTS.buttonsPerLine,
            width = "half",
        },
        {
            type = "dropdown",
            name = "Screen Edge",
            choices = {"Left", "Right"},
            choicesValues = {"left", "right"},
            getFunc = function()
                return self.savedVars.edge
            end,
            setFunc = function(value)
                self.savedVars.edge = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.edge,
            width = "half",
        },
        {
            type = "slider",
            name = "Button Size",
            min = 24,
            max = 56,
            step = 1,
            getFunc = function()
                return self.savedVars.buttonSize
            end,
            setFunc = function(value)
                self.savedVars.buttonSize = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.buttonSize,
            width = "half",
        },
        {
            type = "slider",
            name = "Spacing",
            min = 0,
            max = 12,
            step = 1,
            getFunc = function()
                return self.savedVars.spacing
            end,
            setFunc = function(value)
                self.savedVars.spacing = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.spacing,
            width = "half",
        },
        {
            type = "slider",
            name = "Background Alpha",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function()
                return self.savedVars.backgroundAlpha
            end,
            setFunc = function(value)
                self.savedVars.backgroundAlpha = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.backgroundAlpha,
            width = "full",
        },
    }
    local panelSettingsControls = {
        {
            type = "description",
            text = "Control how Zero Panel behaves as a whole. Maximum Visible Buttons caps rendered buttons so larger layouts do not overwhelm the user. Separators do not count toward that limit.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable Panel",
            getFunc = function()
                return self.savedVars.enabled
            end,
            setFunc = function(value)
                self.savedVars.enabled = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.enabled,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Only When Reticle Is Hidden",
            tooltip = "Match the classic utility-panel behavior and stay off-screen while the reticle is active.",
            getFunc = function()
                return self.savedVars.showOnlyWhenReticleHidden
            end,
            setFunc = function(value)
                self.savedVars.showOnlyWhenReticleHidden = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.showOnlyWhenReticleHidden,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show In HUD UI Scenes",
            tooltip = "Keep the panel available in HUD UI scenes like inventory-style overlays.",
            getFunc = function()
                return self.savedVars.showInHudUI
            end,
            setFunc = function(value)
                self.savedVars.showInHudUI = value
                self:UpdateSceneRegistration()
                self:RefreshPanel()
            end,
            default = DEFAULTS.showInHudUI,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Lock Position",
            tooltip = "Unlock to drag the panel in the world. It snaps to the nearest screen edge when you release it, and the border turns red while it is movable.",
            getFunc = function()
                return self.savedVars.locked
            end,
            setFunc = function(value)
                self.savedVars.locked = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.locked,
            width = "half",
        },
        {
            type = "button",
            name = "Reset Position",
            func = function()
                self:ResetPosition()
                self:RefreshPanel()
            end,
            width = "half",
        },
        {
            type = "slider",
            name = "Maximum Visible Buttons",
            tooltip = "Caps how many buttons Zero Panel renders at once. This counts buttons only, not separators.",
            min = 1,
            max = 60,
            step = 1,
            getFunc = function()
                return self:GetMaximumVisibleButtons()
            end,
            setFunc = function(value)
                self.savedVars.maxVisibleButtons = math.max(1, math.min(60, math.floor(tonumber(value) or DEFAULTS.maxVisibleButtons)))
                self:RefreshPanel()
            end,
            default = DEFAULTS.maxVisibleButtons,
            width = "full",
        },
    }
    local assistantControls = {
        {
            type = "description",
            text = "Choose which unlocked assistant each summon button uses. Only unlocked options are listed.",
            width = "full",
        },
    }
    local commandControls = {
        {
            type = "description",
            text = "Available slash commands for Zero Panel.",
            width = "full",
        },
    }
    for _, commandInfo in ipairs(SLASH_COMMAND_HELP_ENTRIES) do
        commandControls[#commandControls + 1] = {
            type = "description",
            title = commandInfo.command,
            text = commandInfo.description,
            width = "full",
        }
    end
    local allyControls = {
        {
            type = "description",
            text = "Choose whether the ally button summons a random unlocked ally or one specific unlocked ally.",
            width = "full",
        },
    }
    local customButtonChoices, customButtonValues = self:GetCustomButtonChoiceEntries()
    local customSeparatorChoices, customSeparatorValues = self:GetCustomSeparatorChoiceEntries()
    self.selectedCustomButtonPresetId = self.selectedCustomButtonPresetId or CUSTOM_BUTTON_PRESET_VALUES[1]

    local customButtonControls = {
        {
            type = "description",
            text = "Create and edit custom buttons here. Only custom buttons can be modified. Default Zero Panel buttons stay read-only.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Custom Button",
            reference = "ZeroPanelCustomButtonSelector",
            choices = customButtonChoices,
            choicesValues = customButtonValues,
            getFunc = function()
                return self:GetSelectedCustomButtonId() or 0
            end,
            setFunc = function(value)
                self:SetSelectedCustomButtonId(tonumber(value))
                self:RefreshCustomEditorControls()
            end,
            disabled = function()
                return #self:GetCustomButtonIds() == 0
            end,
            width = "full",
        },
        {
            type = "description",
            title = "Custom Button Editor",
            text = function()
                return self:GetCustomButtonEditorDescription()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function()
                local buttonData = self:GetSelectedCustomButtonData()
                return buttonData and buttonData.enabled or false
            end,
            setFunc = function(value)
                local buttonData = self:GetSelectedCustomButtonData()
                if buttonData then
                    buttonData.enabled = value
                    self:RefreshPanel()
                    self:RefreshCustomEditorControls()
                end
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Use Auto-Detected Title",
            tooltip = "When enabled, Zero Panel derives the hover title from the selected action or command.",
            getFunc = function()
                local buttonData = self:GetSelectedCustomButtonData()
                return buttonData and buttonData.useAutoTitle or true
            end,
            setFunc = function(value)
                local buttonData = self:GetSelectedCustomButtonData()
                if buttonData then
                    buttonData.useAutoTitle = value
                    self:RefreshPanel()
                    self:RefreshCustomEditorControls()
                end
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "half",
        },
        {
            type = "dropdown",
            name = "Action Type",
            choices = CUSTOM_BUTTON_ACTION_NAMES,
            choicesValues = CUSTOM_BUTTON_ACTION_VALUES,
            getFunc = function()
                local buttonData = self:GetSelectedCustomButtonData()
                return buttonData and buttonData.actionType or "command"
            end,
            setFunc = function(value)
                local buttonData = self:GetSelectedCustomButtonData()
                if buttonData then
                    buttonData.actionType = value
                    if value ~= "command" then
                        buttonData.command = ""
                    end
                    self:RefreshPanel()
                    self:RefreshCustomEditorControls()
                end
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "full",
        },
        {
            type = "editbox",
            name = "Title",
            tooltip = "When auto-detected title is enabled, this shows the detected title currently in use. Turn auto-detected title off to edit it manually.",
            getFunc = function()
                return self:GetCustomButtonEditorTitleValue()
            end,
            setFunc = function(value)
                local buttonData = self:GetSelectedCustomButtonData()
                if buttonData then
                    buttonData.title = TrimText(value)
                    self:RefreshPanel()
                    self:RefreshCustomEditorControls()
                end
            end,
            disabled = function()
                local buttonData = self:GetSelectedCustomButtonData()
                return buttonData == nil or buttonData.useAutoTitle == true
            end,
            maxChars = 140,
            width = "full",
        },
        {
            type = "editbox",
            name = "Icon Override",
            tooltip = "Optional texture path. Leave this blank to use the action icon or an automatically detected collectible icon.",
            getFunc = function()
                local buttonData = self:GetSelectedCustomButtonData()
                return buttonData and buttonData.icon or ""
            end,
            setFunc = function(value)
                local buttonData = self:GetSelectedCustomButtonData()
                if buttonData then
                    buttonData.icon = TrimText(value)
                    self:RefreshPanel()
                    self:RefreshCustomEditorControls()
                end
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            maxChars = 260,
            width = "half",
        },
        {
            type = "button",
            name = "Browse Textures",
            tooltip = "Open a popup texture picker for the Icon Override field instead of expanding more controls inline here.",
            func = function()
                self:OpenTextureBrowserPopup()
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "half",
        },
        {
            type = "editbox",
            name = "Command",
            tooltip = "Used by the Custom Command action type. Supports slash commands and /script. Browse Collectibles can fill this in for you automatically.",
            getFunc = function()
                local buttonData = self:GetSelectedCustomButtonData()
                return buttonData and buttonData.command or ""
            end,
            setFunc = function(value)
                local buttonData = self:GetSelectedCustomButtonData()
                if buttonData then
                    buttonData.command = tostring(value or "")
                    self:RefreshPanel()
                    self:RefreshCustomEditorControls()
                end
            end,
            disabled = function()
                local buttonData = self:GetSelectedCustomButtonData()
                return not buttonData or buttonData.actionType ~= "command"
            end,
            isMultiline = true,
            maxChars = 600,
            width = "half",
        },
        {
            type = "button",
            name = "Browse Collectibles",
            tooltip = "Open a popup collectible picker that writes the command and icon into the selected custom button.",
            func = function()
                self:OpenCollectibleBrowserPopup()
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "half",
        },
        {
            type = "description",
            title = "Presets",
            text = "Apply a common button preset to the selected custom button, then tweak it if needed.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Preset",
            choices = CUSTOM_BUTTON_PRESET_NAMES,
            choicesValues = CUSTOM_BUTTON_PRESET_VALUES,
            choicesTooltips = CUSTOM_BUTTON_PRESET_TOOLTIPS,
            getFunc = function()
                return self.selectedCustomButtonPresetId
            end,
            setFunc = function(value)
                self.selectedCustomButtonPresetId = value
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Apply Preset",
            func = function()
                self:ApplyCustomButtonPreset(self.selectedCustomButtonPresetId)
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Save",
            func = function()
                self:SaveSelectedCustomButton()
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Delete Button",
            func = function()
                self:DeleteSelectedCustomButton()
            end,
            disabled = function()
                return self:GetSelectedCustomButtonData() == nil
            end,
            width = "half",
        },
    }

    local customSeparatorControls = {
        {
            type = "description",
            text = "Custom separators are extra horizontal lines you can insert anywhere in Button Order.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Custom Separator",
            reference = "ZeroPanelCustomSeparatorSelector",
            choices = customSeparatorChoices,
            choicesValues = customSeparatorValues,
            getFunc = function()
                return self:GetSelectedCustomSeparatorId() or 0
            end,
            setFunc = function(value)
                self:SetSelectedCustomSeparatorId(tonumber(value))
                self:RefreshCustomEditorControls()
            end,
            disabled = function()
                return #self:GetCustomSeparatorIds() == 0
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Delete Selected Custom Separator",
            func = function()
                self:DeleteSelectedCustomSeparator()
            end,
            disabled = function()
                return self:GetSelectedCustomSeparatorId() == nil
            end,
            width = "full",
        },
    }

    for _, actionId in ipairs(SUMMONABLE_ACTION_ORDER) do
        local currentActionId = actionId
        local summonable = SUMMONABLES[currentActionId]
        local choices, choiceValues = self:GetCollectibleChoiceEntries(currentActionId)
        local controlData = {
            type = "dropdown",
            name = summonable.choiceLabel,
            tooltip = "Only unlocked options are listed here.",
            choices = choices,
            choicesValues = choiceValues,
            getFunc = function()
                return self:GetCollectibleChoice(currentActionId)
            end,
            setFunc = function(value)
                self.savedVars.collectibleChoices[currentActionId] = value
                self:RefreshPanel()
            end,
            disabled = function()
                return #self:GetUnlockedCollectibles(currentActionId) == 0
            end,
            default = DEFAULTS.collectibleChoices[currentActionId],
            width = "full",
        }

        if currentActionId == "summon_ally" then
            allyControls[#allyControls + 1] = controlData
        else
            assistantControls[#assistantControls + 1] = controlData
        end
    end

    local options = {
        {
            type = "description",
            text = "Standalone screen-edge utility strip with reorderable buttons, configurable assistants, and a dedicated ally section.",
            width = "full",
        },
        {
            type = "description",
            title = "Support",
            text = string.format("Please report bugs and feature requests via GitHub: %s", ZERO_PANEL_GITHUB_ISSUES_URL),
            width = "full",
        },
        {
            type = "submenu",
            name = "Commands",
            controls = commandControls,
        },
        {
            type = "submenu",
            name = "Appearance",
            controls = appearanceControls,
        },
        {
            type = "submenu",
            name = "Panel Settings",
            controls = panelSettingsControls,
        },
        {
            type = "submenu",
            name = "Visible Buttons",
            controls = visibleButtonsControls,
        },
        {
            type = "submenu",
            name = "Assistant Selection",
            controls = assistantControls,
        },
        {
            type = "submenu",
            name = "Ally Selection",
            controls = allyControls,
        },
        {
            type = "submenu",
            name = "Custom Buttons",
            controls = customButtonControls,
        },
        {
            type = "submenu",
            name = "Custom Separators",
            controls = customSeparatorControls,
        },
        {
            type = "button",
            name = "Add Custom Button",
            func = function()
                self:CreateCustomButton()
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Add Separator",
            func = function()
                self:AddCustomSeparator()
            end,
            width = "half",
        },
        {
            type = "description",
            title = "Button Order",
            reference = "ZeroPanelButtonOrderHelp",
            text = function()
                return self:GetButtonOrderHelpText()
            end,
            width = "full",
        },
        {
            type = "orderlistbox",
            name = "Reorder Layout",
            reference = "ZeroPanelLayoutOrderList",
            tooltip = "Drag and drop rows here or use the row move buttons to reorder the live panel, including custom buttons and separators.",
            listEntries = self:GetOrderListEntries(),
            showPosition = true,
            rowSelectedCallback = function(orderListControl, _, selectedData)
                if not selectedData and orderListControl and orderListControl.orderListBox and type(ZO_ScrollList_GetSelectedData) == "function" then
                    selectedData = ZO_ScrollList_GetSelectedData(orderListControl.orderListBox.scrollListControl)
                end
                self:HandleLayoutOrderSelection(selectedData)
                self:RefreshButtonOrderControlState()
            end,
            minHeight = 220,
            maxHeight = 320,
            isExtraWide = true,
            getFunc = function()
                return self:GetOrderListEntries()
            end,
            setFunc = function(sortedEntries)
                local order = {}
                for _, entry in ipairs(sortedEntries) do
                    if type(entry.value) == "string" and entry.value ~= "" then
                        order[#order + 1] = entry.value
                    end
                end
                self.savedVars.order = order
                self:EnsureOrder()
                self:RefreshPanel()
                self:RefreshCustomEditorControls()
            end,
            default = function()
                return self:GetOrderListEntries()
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Delete Selected Entry",
            reference = "ZeroPanelDeleteLayoutEntryButton",
            tooltip = function()
                return self:GetDeleteSelectedLayoutEntryTooltip()
            end,
            isDangerous = true,
            warning = function()
                local entry = self:GetDeleteSelectedLayoutEntry()
                if not self:IsLayoutEntryRemovable(entry) then
                    return nil
                end
                return self:GetDeleteSelectedLayoutEntryWarning()
            end,
            func = function()
                self:DeleteSelectedLayoutEntry()
            end,
            disabled = function()
                return not self:CanDeleteSelectedLayoutEntry()
            end,
            width = "full",
        },
    }

    for _, definition in ipairs(self:GetCatalog()) do
        local currentDefinition = definition
        visibleButtonsControls[#visibleButtonsControls + 1] = {
            type = "checkbox",
            name = currentDefinition.name,
            tooltip = self:GetButtonTooltip(currentDefinition),
            getFunc = function()
                return self.savedVars.buttons[currentDefinition.id] ~= false
            end,
            setFunc = function(value)
                self.savedVars.buttons[currentDefinition.id] = value
                self:RefreshPanel()
            end,
            default = DEFAULTS.buttons[currentDefinition.id],
            width = "full",
        }
    end

    LAM:RegisterOptionControls(self.panelId, options)
    self:RefreshButtonOrderControlState()
end

function ZeroPanel:HandleSlashCommand(argumentText)
    local command = TrimText(argumentText)

    if command == "unlock" then
        self.savedVars.locked = false
        self:RefreshPanel()
        self:Print("Unlocked. Drag it in the world, then use /zp lock when done.")
    elseif command == "lock" then
        self.savedVars.locked = true
        self:RefreshPanel()
        self:Print("Locked.")
    elseif command == "reset" then
        self:ResetPosition()
        self:RefreshPanel()
        self:Print("Position reset.")
    else
        self:OpenSettings()
    end
end

function ZeroPanel:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide(self.savedVarName, 1, nil, DEFAULTS)
    self.reticleHidden = true
    self:EnsureCustomButtons()
    self:EnsureCollectibleChoices()
    self:EnsureOrder()
    self:CreateWindow()
    self:UpdateSceneRegistration()
    self:ApplyAnchor()
    self:BuildSettings()
    self:RefreshPanel()

    SLASH_COMMANDS["/zp"] = function(text)
        self:HandleSlashCommand(text)
    end

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_HIDDEN_UPDATE, function(_, hidden)
        self.reticleHidden = hidden
        self:RefreshVisibility()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function()
        self:RefreshPanel()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_JOINED, function()
        self:RefreshPanel()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_LEFT, function()
        self:RefreshPanel()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_UPDATE, function()
        self:RefreshPanel()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_VETERAN_DIFFICULTY_CHANGED, function()
        self:RefreshPanel()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, function()
        self:RefreshPanel()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LEADER_UPDATE, function()
        self:RefreshPanel()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHAMPION_POINT_UPDATE, function(_, unitTag)
        if unitTag == nil or unitTag == "player" then
            self:RefreshPanel()
        end
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ZONE_UPDATE, function(_, unitTag)
        if unitTag == nil or unitTag == "player" or (type(ZO_Group_IsGroupUnitTag) == "function" and ZO_Group_IsGroupUnitTag(unitTag)) then
            self:RefreshPanel()
        end
    end)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ZeroPanel.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ZeroPanel.name, EVENT_ADD_ON_LOADED)
    ZeroPanel:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ZeroPanel.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)


