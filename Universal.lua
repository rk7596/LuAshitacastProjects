-- ============================================================================
-- Universal.lua - Universal LuAshitacast Profile - Version: 2026-10-03.1216
-- Ashita v4 / LuAshitacast 2.x / CatsEyeXI
--
-- IMPORTANT AUTO-LOAD NOTE
-- LuAshitacast's normal per-character loader looks for JOB.lua inside the
-- character-ID directory.  This package therefore supplies, for example:
--   LuAshitacast\Finley_51953\RDM.lua
-- and that tiny wrapper simply returns gFunc.LoadFile("Universal.lua").
-- Change only the character-ID directory name for another character.
--
-- Human-editor rule:
--   The gear tables are intentionally explicit.  A player should be able to
--   search for a spell, WS, JA, or set name and understand what is happening
--   without tracing through a constructor function.
--
-- Character-specific rule:
--   Equipment used here is restricted to items already present in Finley's
--   supplied inventory list.  Public guides provide optimization candidates;
--   they do NOT authorize adding gear that Finley does not own.
--
-- CatsEyeXI Magus +1 rule:
--   All Magus / "Mag." +1 equipment owned by this character is assumed to have
--   its maximum Tier 3 CatsEyeXI Artifact +1 augmentation for optimization.
--
-- SMN note:
--   Blood Pact activation and execution are separate concerns.  Blood Pact
--   Delay gear is worn at activation; execution gear is based on avatar-side
--   performance and pact mechanics, not the player's own WS WSC.
--
-- WS gorget rule:
--   Fotia Gorget replaces the old elemental-gorget system.  Skillchain-property
--   WS use Fotia; non-skillchain WS such as Sanguine Blade do not.
-- ============================================================================
-- SECTION ORGANIZATION RULE:
--   Every job owns one self-contained section.  Older "starter" blocks are not
--   retained once a job is graduated.  RDM is the organizational scaffold; each
--   job uses the same readable shape while retaining job-specific mechanics.
--   Shared engine code stays centralized below the job sections.


local profile = { "Universal, All Jobs, 75" }
local sets = {}
local smnStaffMode = "Gridarvor"

-- Finley character-specific build: 2026-10-03 / WHM75 + DRK75 + NIN41 leveling update + DRK WS integrity repair + structural graduation preservation

-- ============================================================================
-- GENERAL CONFIGURATION
-- ============================================================================

local CONFIG = {
    WeaponLockTP = 50,

    -- CatsEyeXI status effect ID for Mounted. Movement gear must not override
    -- Magus Shalwar +1 while mounted (e.g. for its Auto Regen/Refresh augment).
    MountedStatusId = 252,

    PDTKey = "!pageup",
    MDTKey = "!pagedown",
    ManualDefenseSeconds = 5,

    -- Global Alt-F12 toggle for automatic Engaged-state weapon selection.
    -- ON by default. OFF lets the player manually choose Main/Sub weapons
    -- without the shared state handler restoring the configured weapon pair.
    EngagedWeaponToggleKey = "!F12",

    -- Global Hachirin-no-Obi ownership toggle.  When true, the shared magic
    -- handler may replace a caster set's Waist slot with Hachirin-no-Obi
    -- when the spell element matches the current day or weather.  The helper
    -- deliberately refuses opposing elements, preventing Hachirin's latent
    -- negative day/weather effect from making a spell worse.
    HachirinObiOwned = true,

    -- Plain F12 displays the effective Universal macro deck. Alt-F12 remains
    -- reserved for the global engaged-weapon selection toggle.
    MacroDisplayKey = "F12",

    ManualSetSeconds = 5,

    -- CatsEyeXI subjob rule: all three currently grant DW as subjobs here.
    DualWieldSubJobs = {
        NIN = true,
        THF = true,
        DNC = true,
    },

    -- Native DW below the level-75 cap.
    NativeDualWieldLevel = {
        NIN = 10,
        DNC = 20,
        -- CatsEyeXI grants THF native Dual Wield I at level 20.
        THF = 20,
        -- BLU native DW remains above the current 75 cap.
    },

    -- Your established movement rule.
    BloodCuissesJobs = {
        RDM = true, PLD = true, DRK = true, RNG = true,
        DRG = true, BLU = true, COR = true, RUN = true,
    },
    BloodCuissesMinLevel = 73,

    -- Dynamic Enspell is available only when RDM is main or support job.
    -- Enlight/Endark are intentionally never selected here.
    DynamicEnspellJobs = { RDM = true },

    -- Universal macro keys owned by this profile.  These are cleared on load
    -- before the applicable job deck is installed; unrelated keys are never
    -- touched.  Ctrl-BACKSLASH is intentionally excluded because it belongs
    -- exclusively to the Dynamic Enspell system.  Alt-F12 is also reserved
    -- for the global Engaged-weapon toggle and is not part of job macros.
    MacroKeys = {
        '^`','^1','^2','^3','^4','^5','^6','^7','^8','^9','^0','^-','^=',
        '!`','!1','!2','!3','!4','!5','!6','!7','!8','!9','!0','!-','!=',
        '^!`','^!1','^!2','^!3','^!4','^!5','^!6','^!7','^!8','^!9','^!0','^!-','^!=',
        '!Backspace','^Backspace',"!LEFTBRACKET", "!RIGHTBRACKET", "!\'", '!\\',
    },
}

-- Newly confirmed inventory additions / confirmations:
--   Gloom Breastplate (DRK-only; Drain/Aspir enhancement body piece)
--   Abyssal Earring
--   Hecate's Crown (MP+23, Mag.Acc.-2, Mag.Atk.+4)
--   Hecatomb Harness (no augments yet)
--   Shura Togi (Haste +2%, Critical Hit Rate +2%, Ninja Tool Expertise +3%)
--   Enfeebling Torque is confirmed owned and is already used in RDM skill sets.
-- These ownership confirmations do not automatically insert a piece into an
-- unrelated runtime set.  DRK-specific placement is handled in the dedicated
-- DRK section below.

-- ============================================================================
-- FINLEY CURRENT JOB LEVELS
-- ============================================================================
-- Current character levels as of 2026-10-03.  These levels are authoritative
-- for equipment/action availability.  Macro decks are intentionally allowed to
-- be prepared through level 75, per project rules; equipment and executable
-- action mappings should not assume a job has reached 75 yet.
local CurrentJobLevels = {
    WAR = 40, WHM = 75, RDM = 75, PLD = 75, BST = 42, RNG = 43,
    NIN = 41, SMN = 75, COR = 50, DNC = 40, GEO = 51, MNK = 75,
    BLM = 75, THF = 75, DRK = 75, BRD = 40, SAM = 75, DRG = 75,
    BLU = 75, PUP = 55, SCH = 40, RUN = 51,
}

-- ============================================================================
-- ALL JOB CONTAINERS
-- ============================================================================

local JOBS = {}

local function NewJob()
    return {
        Sets = {
            Idle = {},
            Resting = {},
            Engaged = {},
            EngagedSolo = {},
            EngagedParty = {},

            Movement = {},

            PDT = {},
            MDT = {},

            Precast = {},
            Preshot = {},
            Midshot = {},

            Haste = {},
            FastCast = {},
            Cure = {},
            HealingSkill = {},
            EnhancingSkill = {},
            EnfeeblingSkill = {},
            ElementalSkill = {},
            ElementalDamage = {},
            DarkSkill = {},
            DarkDamage = {},
            DivineSkill = {},
            DivineDamage = {},

            BlueMagicSkill = {},
            BlueMagicPhysical = {},
            BlueMagicMagical = {},

            JA_Default = {},
            JA_Offensive = {},
            JA_Defensive = {},
            JA_Enmity = {},

            WS_Default = {},
            WS_STR = {},
            WS_STRDEX = {},
            WS_DEX = {},
            WS_VIT = {},
            WS_AGI = {},
            WS_MND = {},
            WS_INT = {},
            WS_CHR = {},
            WS_Magic = {},

            Pet = {},
            PetPhysical = {},
            PetMagical = {},
            PetHealing = {},
        },

        JA = {},
        MA = {},
        WS = {},
        PET = {},

        Weapons = {
            Main = nil,
            Sub = nil,
            DWMain = nil,
            DWSub = nil,
            Shield = nil,
            Range = nil,
            Ammo = nil,
        },
    }
end

for _, jobName in ipairs({
    "WAR", "MNK", "WHM", "BLM", "RDM", "THF", "PLD", "DRK", "BST", "BRD", "RNG",
    "SAM", "NIN", "DRG", "SMN", "BLU", "COR", "PUP", "DNC", "SCH", "GEO", "RUN",
}) do
    JOBS[jobName] = NewJob()
end

-- ============================================================================
-- SMALL HELPERS
-- ============================================================================

local function IsDefined(value)
    return value ~= nil and value ~= ""
end

local function MergeSets(base, overlay)
    local result = {}
    if base then
        for k, v in pairs(base) do result[k] = v end
    end
    if overlay then
        for k, v in pairs(overlay) do result[k] = v end
    end
    return result
end

local function IsMounted()
    return gData.GetBuffCount(CONFIG.MountedStatusId) > 0
end

local function GetJob(player)
    if not player or not player.MainJob then
        return nil
    end
    return JOBS[player.MainJob]
end

local function GetLevelSetOverlay(job, name)
    if not job or not name then
        return nil
    end

    local byLevel = job.Sets[name .. "ByLevel"]
    if type(byLevel) ~= "table" then
        return nil
    end

    local player = gData.GetPlayer()
    local level = player and (player.MainJobLevel or 0) or 0
    if level <= 0 then
        return nil
    end

    local thresholds = {}
    for minimumLevel, candidate in pairs(byLevel) do
        local n = tonumber(minimumLevel)
        if n and type(candidate) == "table" and n <= level then
            table.insert(thresholds, n)
        end
    end

    if #thresholds == 0 then
        return nil
    end

    table.sort(thresholds)

    local result = {}
    for _, minimumLevel in ipairs(thresholds) do
        result = MergeSets(result, byLevel[minimumLevel])
    end

    return result
end

local function GetSet(job, name, fallback)
    if not job then
        return {}
    end

    local base = name and job.Sets[name] or nil
    local overlay = GetLevelSetOverlay(job, name)
    if overlay then
        return MergeSets(base, overlay)
    end

    return base or (fallback and job.Sets[fallback]) or {}
end

local function IsNativeDualWield(player)
    if not player then
        return false
    end

    local minimum = CONFIG.NativeDualWieldLevel[player.MainJob]
    if minimum == nil then
        return false
    end

    return (player.MainJobLevel or 0) >= minimum
end

local function CanDualWield(player)
    if not player then
        return false
    end

    if CONFIG.DualWieldSubJobs[player.SubJob] then
        return true
    end

    return IsNativeDualWield(player)
end

local HasRealPlayerInParty

-- Some jobs have sensible weapon upgrades at known level milestones.  A job may
-- provide WeaponsByLevel = { [minimumLevel] = { ... } } without forcing the
-- human editor to duplicate the shared weapon-selection logic.  If no such
-- table exists, the normal Weapons table is used unchanged.
local function GetWeaponConfig(job, player)
    if not job then
        return nil
    end

    if not job.WeaponsByLevel then
        return job.Weapons
    end

    local selected = job.Weapons
    local selectedLevel = 0
    local level = player and (player.MainJobLevel or 0) or 0

    for minimumLevel, candidate in pairs(job.WeaponsByLevel) do
        minimumLevel = tonumber(minimumLevel)
        if minimumLevel and minimumLevel <= level and minimumLevel >= selectedLevel then
            selected = candidate
            selectedLevel = minimumLevel
        end
    end

    return selected
end

local function EquipJobWeapons(job, player)
    if not job or not player then
        return
    end

    if player.MainJob == "SMN" then
        local pet = gData.GetPet()
        local avatarActive = pet ~= nil and pet.Name ~= nil and pet.Name ~= ""
        local useGridarvor = player.Status == "Engaged" or avatarActive or smnStaffMode == "Gridarvor"

        if useGridarvor then
            gFunc.Equip("Main", "Gridarvor")
            gFunc.Equip("Sub", "Ossa Grip")
        else
            gFunc.Equip("Main", "Chatoyant Staff")
            gFunc.Equip("Sub", "Ossa Grip")
        end
        return
    end

    if player.MainJob == "PLD" then
        local realParty = HasRealPlayerInParty()
        local pldCanDW = player.SubJob == "NIN"
            or player.SubJob == "THF"
            or player.SubJob == "DNC"

        gFunc.Equip("Main", job.Weapons.Main)
        if not realParty and pldCanDW then
            gFunc.Equip("Sub", job.Weapons.DWSub)
        else
            gFunc.Equip("Sub", job.Weapons.Shield)
        end
        return
    end

    -- THF main job always has Dual Wield.  Do not route THF through the
    -- generic CanDualWield() check or any weapon milestone table.
    if player.MainJob == "THF" then
        if IsDefined(job.Weapons.DWMain) then
            gFunc.Equip("Main", job.Weapons.DWMain)
        end
        if IsDefined(job.Weapons.DWSub) then
            gFunc.Equip("Sub", job.Weapons.DWSub)
        end
        return
    end

    local weapons = GetWeaponConfig(job, player) or {}

    if CanDualWield(player)
        and IsDefined(weapons.DWMain)
        and IsDefined(weapons.DWSub) then
        gFunc.Equip("Main", weapons.DWMain)
        gFunc.Equip("Sub", weapons.DWSub)
        return
    end

    if IsDefined(weapons.Main) then
        gFunc.Equip("Main", weapons.Main)
    end

    if IsDefined(weapons.Shield) then
        gFunc.Equip("Sub", weapons.Shield)
    elseif IsDefined(weapons.Sub) then
        gFunc.Equip("Sub", weapons.Sub)
    end

    -- Ranged jobs can specify Range/Ammo independently of Main/Sub.
    -- This matters for RNG/COR, whose ranged weapon configuration may not
    -- have a meaningful melee Main/Sub pair.
    if IsDefined(job.Weapons.Range) then
        gFunc.Equip("Range", job.Weapons.Range)
    end
    if IsDefined(job.Weapons.Ammo) then
        gFunc.Equip("Ammo", job.Weapons.Ammo)
    end
end

-- ============================================================================
-- MOVEMENT
-- ============================================================================
-- Moving overrides the Legs slot of Idle / Engaged / Resting before the
-- final state set is submitted.  This avoids sending two competing Leg-slot
-- EquipSet requests during a single poll.
--
-- Level 73+ and one of the eight jobs below:
--   Blood Cuisses = Movement Speed +12% on CatsEyeXI.
--
-- Everyone else:
--   Track Pants +1.  IMPORTANT: no Feet entry here because Track Pants +1
--   disables the Feet slot.
-- ============================================================================

local function GetMovementSet(player)
    if not player then
        return {}
    end

    if CONFIG.BloodCuissesJobs[player.MainJob]
        and (player.MainJobLevel or 0) >= CONFIG.BloodCuissesMinLevel then
        return {
            Legs = "Blood Cuisses",
        }
    end

    return {
        Legs = "Track Pants +1",
    }
end

-- ============================================================================
-- PLD REAL-PLAYER PARTY DETECTION
-- ============================================================================
-- Trusts count as party members in gData.GetParty(); PLD's current profile
-- distinguishes actual player parties so solo/Trust tanking can remain on the
-- solo weapon policy.  The names below follow the current PLD profile.

local KnownTrustNames = {
    ["Shantotto"] = true, ["Shantotto II"] = true, ["Koru-Moru"] = true,
    ["Valaineral"] = true, ["MihliAliapoh"] = true, ["SemihLafihna"] = true,
    ["Joachim"] = true, ["Ulmia"] = true, ["F.Coffin"] = true,
    ["KingofHearts"] = true, ["AAHM"] = true, ["AAEV"] = true,
    ["AAGK"] = true, ["AAMR"] = true, ["AATT"] = true,
    ["August"] = true, ["Yoran-Oran"] = true, ["Apururu"] = true,
    ["Sylvie"] = true, ["Monberaux"] = true, ["Lion II"] = true,
    ["Zeid II"] = true, ["Elivira"] = true, ["Noillurie"] = true,
    ["Lilisette II"] = true,
}

HasRealPlayerInParty = function()
    local party = gData.GetParty()
    if not party or not party.InParty or (party.Count or 0) <= 1 then
        return false
    end

    local ashitaParty = AshitaCore:GetMemoryManager():GetParty()
    local myName = ashitaParty:GetMemberName(0)

    for i = 0, 17 do
        local name = ashitaParty:GetMemberName(i)
        if name ~= nil and name ~= "" and name ~= myName and not KnownTrustNames[name] then
            return true
        end
    end

    return false
end

-- Merge movement gear into the state set before calling EquipSet().
-- This is intentionally a single EquipSet operation per poll.  Calling
-- EquipSet(stateSet) and then EquipSet(movementSet) every poll causes LuAshita-
-- cast to receive two competing Leg-slot requests while moving, which can
-- produce the observed visible equipment oscillation as the requests are
-- processed.  A merged set makes the desired final slot assignment atomic
-- from the profile's point of view.
local function GetStateSet(job, player)
    if player.Status == "Engaged" then
        if player.MainJob == "PLD" then
            if HasRealPlayerInParty() then
                return GetSet(job, "EngagedParty")
            else
                return GetSet(job, "EngagedSolo")
            end
        end
        return GetSet(job, "Engaged")
    elseif player.Status == "Resting" then
        return GetSet(job, "Resting")
    end

    return GetSet(job, "Idle")
end

-- ============================================================================
-- DYNAMIC ENSPELL
-- ============================================================================

local EnspellByElement = {
    Fire = "Enfire",
    Ice = "Enblizzard",
    Wind = "Enaero",
    Earth = "Enstone",
    Thunder = "Enthunder",
    Water = "Enwater",
}

local OpposingElement = {
    Fire = "Water",
    Water = "Thunder",
    Thunder = "Earth",
    Earth = "Wind",
    Wind = "Ice",
    Ice = "Fire",
    Light = "Dark",
    Dark = "Light",
}

-- The elemental wheel also defines which element is ascendant to the next.
-- If the day is ascendant to a non-double weather element, the day wins.
local AscendantElement = {
    Fire = "Ice",
    Ice = "Wind",
    Wind = "Earth",
    Earth = "Thunder",
    Thunder = "Water",
    Water = "Fire",
}

local function IsDoubleWeather(env)
    if not env or not env.Weather then
        return false
    end

    local weather = tostring(env.Weather):lower()
    return weather:find("x2", 1, true) ~= nil
        or weather:find("double", 1, true) ~= nil
end

local function GetBestEnspell()
    local env = gData.GetEnvironment()
    if not env then
        return "Enfire"
    end

    local day = env.DayElement
    local weather = env.WeatherElement

    if day == nil and weather == nil then
        return "Enfire"
    end
    if day == nil then
        return EnspellByElement[weather] or "Enfire"
    end
    if weather == nil then
        return EnspellByElement[day] or "Enfire"
    end

    -- Established profile rule:
    --   * Matching day/weather uses that element.
    --   * Double weather takes priority over the day.
    --   * If weather is ascendant to the day, weather wins.
    --   * If the day is ascendant to single weather, the day wins.
    --   * If neither directly outranks the other, use weather.
    if day == weather then
        return EnspellByElement[day] or "Enfire"
    end

    if IsDoubleWeather(env) then
        return EnspellByElement[weather] or "Enfire"
    end

    -- Weather is the element that defeats/opposes the day.
    -- Example: Firesday + Water weather -> Enwater.
    if OpposingElement[day] == weather then
        return EnspellByElement[weather] or "Enfire"
    end

    -- The day can also defeat the weather.
    -- Example: Lightningday + Rain (Water weather) -> Enthunder.
    if AscendantElement[day] == weather then
        return EnspellByElement[day] or "Enfire"
    end

    return EnspellByElement[weather] or EnspellByElement[day] or "Enfire"
end

local currentEnspell = "Enfire"
local lastEnspellSignature = nil

-- Ctrl-BACKSLASH is a persistent player-triggered command while RDM is main or /RDM.
-- The key itself is rebound only when the live day/weather state changes; the bind
-- directly contains the current /recast + /ma pair, matching the original design.
local function UpdateEnspellState(force)
    local player = gData.GetPlayer()
    local env = gData.GetEnvironment()
    if not player or not env then
        return
    end

    local signature = table.concat({
        tostring(player.MainJob or "None"),
        tostring(player.SubJob or "None"),
        tostring(env.DayElement or "None"),
        tostring(env.WeatherElement or "None"),
        tostring(env.Weather or "None"),
    }, "|")

    if not force and signature == lastEnspellSignature then
        return
    end

    if player.MainJob == "RDM" or player.SubJob == "RDM" then
        currentEnspell = GetBestEnspell()
    else
        currentEnspell = ""
    end

    lastEnspellSignature = signature
end


local function UpdateEnspellBind(force)
    local player = gData.GetPlayer()
    local env = gData.GetEnvironment()
    if not player or not env then
        return
    end

    local signature = table.concat({
        tostring(player.MainJob or "None"),
        tostring(player.SubJob or "None"),
        tostring(env.DayElement or "None"),
        tostring(env.WeatherElement or "None"),
        tostring(env.Weather or "None"),
    }, "|")

    if not force and signature == lastEnspellSignature then
        return
    end

    if player.MainJob == "RDM" or player.SubJob == "RDM" then
        currentEnspell = GetBestEnspell()
        lastEnspellSignature = signature

        -- Bind the actual dynamic spell command directly.  This preserves the
        -- original Universal/RDM behavior: Ctrl-BACKSLASH itself executes the
        -- current /recast + /ma pair.  Rebind only when day/weather/job state
        -- changes (or when explicitly forced), rather than routing the key
        -- through an extra /lac command.
        AshitaCore:GetChatManager():QueueCommand(
            -1,
            "/bind ^BACKSLASH down /recast \"" .. currentEnspell ..
            "\";/ma \"" .. currentEnspell .. "\" <stpc>"
        )
    else
        currentEnspell = ""
        lastEnspellSignature = signature
        AshitaCore:GetChatManager():QueueCommand(-1, "/unbind ^BACKSLASH down")
    end
end

-- ============================================================================
-- WEAPONSKILL REFERENCE LIBRARY
-- ============================================================================
-- Purpose:
--   Human-readable reference for WS mechanics relevant to the current/future
--   RDM, BLU, PLD, and SMN build.  This section documents the WS itself; it
--   does NOT select gear.  Each job owns its own WS map and execution sets.
--
-- Set naming convention:
--   WS-<Type>-<Modifier>[-<Modifier>...]
--   Examples: WS-Physical-STR-DEX, WS-Magical-MND-STR
--
-- Reference notation:
--   WSC    = listed weapon-skill stat modifier.
--   fTP    = TP multiplier at 1000 / 2000 / 3000 TP where the WS scales.
--   Replicating = fTP is copied to additional hits; otherwise it normally
--                 applies only to the first hit.
--   dSTAT  = magical-WS pINT/mINT term where applicable.
--   SC     = skillchain properties.
--
-- SOURCE / SCOPE:
--   Standard FFXI/BG-Wiki data is used as the baseline.  CatsEyeXI-specific
--   changes take precedence once verified.  A future-level WS may be documented
--   here even when the present level-75 cap cannot execute it.
-- ============================================================================

-- ============================================================================
-- SWORD
-- ============================================================================

-- Fast Blade
--   Physical | 2 hits | WSC: 40% STR / 40% DEX
--   fTP: 1.0 / 3.0 / 5.0 | SC: Scission
--   RDM / BLU / PLD available at low level.

-- Burning Blade
--   Magical | Fire | 1 hit | WSC: 40% STR / 40% INT
--   dSTAT: (pINT-mINT)/2 + 8, cap 32
--   fTP: 1.0 / 2.09765625 / 3.3984375 | SC: Liquefaction

-- Red Lotus Blade
--   Magical | Fire | 1 hit | WSC: 40% STR / 40% INT
--   dSTAT: (pINT-mINT)/2 + 8, cap 32
--   fTP: 1.0 / 2.3828125 / 3.75 | SC: Liquefaction / Detonation

-- Flat Blade
--   Physical | 1 hit | WSC: 100% STR | fTP: 1.0
--   SC: Impaction | Additional Effect: Stun

-- Shining Blade
--   Magical | Light | 1 hit | WSC: 40% STR / 40% MND | dSTAT: 0
--   fTP: 1.125 / 2.22265625 / 3.5234375 | SC: Scission

-- Seraph Blade
--   Magical | Light | 1 hit | WSC: 40% STR / 40% MND | dSTAT: 0
--   fTP: verify against the active CatsEyeXI ruleset before treating the
--        numerical TP progression as authoritative. | SC: Scission
--   Common Abyssea-era utility: Light elemental WS / Red !! candidate.

-- Circle Blade
--   Physical | 1 hit | AoE | WSC: 100% STR | fTP: 1.0
--   SC: Reverberation / Impaction

-- Spirits Within
--   Breath damage | 1 hit | No normal WSC/fTP model
--   Damage is based on current HP and the TP modifier.
--   SC: None
--   Do not gear this like an ordinary physical WS.

-- Vorpal Blade
--   Physical | 4 hits | WSC: 60% STR | fTP: 1.375 (replicating)
--   Critical-hit rate varies with TP. | SC: Scission / Impaction

-- Swift Blade
--   Physical | 3 hits | WSC: 50% STR / 50% MND | fTP: 1.5 (replicating)
--   Accuracy varies with TP. | SC: Gravitation
--   Standard job access is PLD/RUN; RDM/BLU access depends on later weapon
--   unlocks, so keep this as reference data rather than assuming level-75 RDM
--   access.

-- Savage Blade
--   Physical | 2 hits | WSC: 50% STR / 50% MND
--   fTP: 4.0 / 10.25 / 13.75 | SC: Fragmentation / Scission
--   RDM access at 73; PLD/BLU access at 68.

-- Knights of Round
--   Physical | 1 hit | WSC: 40% STR / 40% MND | fTP: 5.0
--   SC: Light / Fusion | Relic WS
--   RDM / PLD at level 75 via Caliburn/Excalibur.
--   Relic aftermath: +10 HP/tick Regen for 20/40/60 sec at 1000/2000/3000 TP.

-- Death Blossom (NOT "Death Blade")
--   Physical | 3 hits | WSC: 50% MND / 30% STR | fTP: 4.0
--   SC: Fragmentation / Distortion | Additional effect: Magic Evasion Down
--   RDM-only Mythic WS at level 75.

-- Sanguine Blade
--   Magical | Dark | 1 hit | WSC: 50% MND / 30% STR
--   dSTAT: (pINT-mINT) x 2 | fTP: 2.75
--   HP drain/convert effect scales with TP: 50% / 100% / 160%
--   SC: None

-- Requiescat
--   Physical | 5 hits | WSC: 73% to 85% MND depending merit level | fTP: 1.0
--   Attack penalty: -20% / -10% / 0% at 1000 / 2000 / 3000 TP
--   SC: Darkness / Gravitation / Scission | Merit WS; above level-75 era.

-- Chant du Cygne
--   Physical | 3 hits | WSC: 80% DEX | fTP: 1.6328125 (replicating)
--   Critical-hit rate: +15% / +25% / +40% at 1000 / 2000 / 3000 TP
--   SC: Light / Distortion
--   RDM / PLD / BLU, level 85 standard access via Almace-family weapons.
--   Included here for CatsEyeXI's forward Abyssea/Almace progression.

-- ============================================================================
-- DAGGER
-- ============================================================================

-- Wasp Sting
--   Physical | 1 hit | WSC: 100% DEX | fTP: 1.0
--   SC: Scission | Additional Effect: Poison

-- Viper Bite
--   Physical | 1 hit | WSC: 100% DEX | fTP: 1.0
--   SC: Scission | Additional Effect: Poison

-- Cyclone
--   Magical | Wind | 1 hit | WSC: 40% DEX / 40% INT
--   fTP: 1.0 / 2.5 / 3.75 | SC: Detonation / Impaction
--   AoE; useful for RDM/BLU dagger access and Abyssea wind procs.

-- Gust Slash
--   Magical | Wind | 1 hit | WSC: 40% DEX / 40% INT
--   fTP: 1.0 / 2.5 / 3.75 | SC: Detonation

-- Energy Steal
--   Magical | Dark | no damage | WSC: 100% MND
--   MP multiplier: 1.0 / 2.1 / 3.4 at 1000 / 2000 / 3000 TP
--   SC: None
--   Formula uses dagger skill + WSC, not ordinary WS damage.

-- Energy Drain
--   Magical | Dark | no damage | WSC: 100% MND
--   MP multiplier varies with TP. | SC: None
--   Treat as a utility WS, not a damage WS.

-- Evisceration
--   Physical | 5 hits | WSC: 50% DEX | fTP: 1.25
--   Critical-hit rate varies with TP. | SC: Gravitation / Transfixion

-- ============================================================================
-- CLUB
-- ============================================================================

-- Judgment
--   Physical | 1 hit | WSC: 50% STR / 50% MND
--   fTP: 3.5 / 8.75 / 12.0 | SC: Impaction
--   RDM level 70; PLD level 60; BLU level 62; SMN level 64.

-- Black Halo
--   Physical | 2 hits | WSC: 70% MND / 30% STR
--   fTP: 3.0 / 7.25 / 9.75 | SC: Fragmentation / Compression
--   SMN level 75; BLU level 73; PLD level 67.
--   Future RDM access requires an appropriate later weapon (e.g. Kaja Rod/Maxentius).

-- ============================================================================
-- STAFF
-- ============================================================================

-- Heavy Swing
--   Physical | 1 hit | WSC: 100% STR | fTP: 1.0 / 2.0 / 3.0
--   SC: Impaction
--   SMN available from level 1.

-- Rock Crusher
--   Magical | Earth | 1 hit | WSC: 40% STR / 40% INT
--   fTP: verify from the current reference before execution optimization.
--   SC: Impaction
--
-- Earth Crusher
--   Magical | Earth | AoE | WSC: 40% STR / 40% INT
--   fTP: verify from the current reference before execution optimization.
--   SC: Detonation / Impaction

-- Starburst
--   Magical | Light/Dark (random element) | 1 hit
--   WSC: 40% STR / 40% MND | dSTAT: (pINT-mINT)/2 + 8, cap 32
--   fTP: 1.0 / 3.27 / 5.54 | SC: Compression / Reverberation
--   Special base-damage formula; uses Blunt DT in the magic-damage calculation.

-- Sunburst
--   Magical | Light/Dark (random element) | 1 hit
--   WSC: 40% STR / 40% MND | dSTAT: (pINT-mINT)/2 + 8, cap 32
--   fTP: verify before execution optimization. | SC: Compression / Reverberation

-- Shell Crusher
--   Physical | 1 hit | WSC: 100% STR | fTP: 1.0
--   SC: Detonation | DEF Down: -25%
--   Duration: 180 / 360 / 540 sec at 1000 / 2000 / 3000 TP (unresisted).
--   SMN level 56.

-- Full Swing
--   Physical | 1 hit | WSC: 50% STR
--   fTP: verify before execution optimization. | SC: Liquefaction / Impaction
--   SMN access; 200 staff skill.

-- Spirit Taker
--   Physical | 1 hit | WSC: 50% INT / 50% MND
--   Restores MP equal to damage dealt. | fTP: verify before execution optimization.
--   SC: None | 215 staff skill | SMN available above level 68.

-- Retribution
--   Physical | 1 hit | WSC: 50% MND / 30% STR | Attack modifier: 1.5
--   fTP: 2.0 / 3.0 / 5.0 | SC: Gravitation / Reverberation
--   SMN level 71; later RDM access via Kaja Staff/Xoanon, not level-75 RDM.

-- Garland of Bliss
--   Magical | Light | 1 hit | WSC: 70% MND / 30% STR
--   dSTAT: (pMND-mMND) x 2 | fTP: 2.25
--   DEF Down: 12.5% | SC: Fusion / Reverberation
--   SMN-only Mythic WS at level 75.

-- ============================================================================
-- JOB ACCESS / FUTURE-PROOFING NOTES
-- ============================================================================
-- RDM: sword WS above plus later dagger/club access; Death Blossom and Knights
--      of Round are especially relevant at the level-75-era endpoint.
-- BLU: sword WS above plus club/staff access; Chant du Cygne is future-level
--      and intentionally documented now for Almace progression.
-- PLD: sword/club/staff WS are all relevant; Atonement is a separate enmity-based
--      Mythic WS and should never be forced into a normal stat-modifier set.
-- SMN: staff/club WS are relevant; Garland of Bliss is the level-75 Mythic WS.
--
-- IMPORTANT: A WS listed here is not automatically executable.  A job's own WS
-- map determines whether the profile will gear it.  This prevents a BLU-specific
-- set from ever being selected merely because another job shares a WS name.
-- ============================================================================

-- ============================================================================
-- ============================================================================
-- WAR: CHARACTER-SPECIFIC EQUIPMENT / ACTION DATA
-- ============================================================================
-- Current job level: 40
-- This section is the authoritative home for WAR-specific configuration.
-- Runtime equipment/action mappings must respect the current job level.
-- Future level-75 macro preparation may be documented here without becoming
-- executable runtime gear.

local WAR = JOBS.WAR

-- ----------------------------------------------------------------------------
-- WAR: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------

WAR.Sets.Idle = {
        Head="Warrior's Mask", Neck="Fortitude Torque", Ear1="Brutal Earring", Ear2="Static Earring",
        Body="Warrior's Lorica", Hands="Eisenhentzes", Ring1="Rajas Ring", Ring2="Sattva Ring",
        Back="Ryl. Army Mantle", Waist="Swift Belt", Legs="Eisendiechlings", Feet="Warrior's Calligae",
    }

WAR.Sets.Resting = {
        Head="Warrior's Mask", Neck="Fortitude Torque", Body="Warrior's Lorica", Hands="Eisenhentzes",
        Ring1="Rajas Ring", Ring2="Sattva Ring", Legs="Eisendiechlings", Feet="Warrior's Calligae",
    }

WAR.Sets.Engaged = {
        Head="Walahra Turban", Neck="Fortitude Torque", Ear1="Brutal Earring", Ear2="Static Earring",
        Body="Warrior's Lorica", Hands="Eisenhentzes", Ring1="Rajas Ring", Ring2="Ulthalam's Ring",
        Back="Ryl. Army Mantle", Waist="Swift Belt", Legs="Eisendiechlings", Feet="Warrior's Calligae",
    }

-- ----------------------------------------------------------------------------
-- WAR: WEAPONS
-- ----------------------------------------------------------------------------

WAR.Weapons = { Main="Sturdy Axe" }

-- ----------------------------------------------------------------------------
-- WAR: JOB ABILITIES / MAGIC / WEAPON SKILLS / MACROS
-- ----------------------------------------------------------------------------
-- Dedicated mechanics and ownership audit remains to be completed here.
-- Keep all WAR-specific additions inside this section.


-- ============================================================================
-- WHM: WHITE MAGE
-- ============================================================================
-- Current job level: 75
--
-- This is the complete WHM home.  It follows the RDM organizational model:
-- state sets first, then action-specific sets/maps, weapons, progression notes,
-- and the job's macro deck.  WHM is now at the level-75 endpoint.
--
-- Owned WHM equipment used here includes the complete base Artifact/Relic sets
-- and the explicitly confirmed inventory listed in the project reference files.
-- No WHM +1/+augmented Artifact pieces are assumed unless explicitly confirmed.
-- Key WHM weapons include Arcana Breaker / Hoplon, Brass Jadagna / Genbu's Shield,
-- Asklepios, Chatoyant Staff, and Kirin's Pole.
--
-- Global Engaged priority applies here as elsewhere:
--   Haste > Double/Triple Attack > Accuracy > Attack > Store TP > DEX > STR
--   > Critical Hit Rate > Critical Hit Damage.
-- ============================================================================

local WHM = JOBS.WHM

-- ----------------------------------------------------------------------------
-- WHM: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------
-- Idle priority:
--   Enmity reduction > high MP > defensive stats > high HP.
-- The complete level-60 Healer's Attire set is an unusually clean fit:
--   -10 Enmity, +63 MP, +15 Healing skill, +15 Divine skill,
--   and solid defense/HP contribution from the AF pieces.
--
-- Resting priority is specifically MP recovered while healing (hMP), not
-- maximum MP.  Chatoyant Staff is explicitly equipped here alongside the
-- owned hMP-focused armor pieces.
--
-- Engaged priority remains:
--   Haste > Double/Triple Attack > Accuracy > Attack > Store TP > DEX > STR
--   > Critical Hit Rate > Critical Hit Damage.
--
-- The current WHM75 engaged set deliberately uses the user's explicit baseline:
-- Walahra Turban / Ancient Torque / Brutal + Hollow / Noble's Tunic /
-- Healer's Mitts / Rajas + Mars's / Aesir Mantle / Ninurta's / Cleric's Pantaln. /
-- Healer's Duckbills.  Suppanomimi is not inserted unconditionally because this
-- set must remain valid when WHM is not actually dual-wielding.

WHM.Sets.Idle = {
    Head  = "Healer's Cap",
    Body  = "Noble's Tunic",
    Hands = "Healer's Mitts",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Legs  = "Healer's Pantaln.",
    Feet  = "Healer's Duckbills",
}

WHM.Sets.Resting = {
    Head  = "Seer's Crown",
    Body  = "Errant Hpl.",
    Main  = "Chatoyant Staff",
    Feet  = "Seer's Pumps",
}

WHM.Sets.Engaged = {
    Head  = "Walahra Turban",
    Neck  = "Ancient Torque",
    Ear1  = "Brutal Earring",
    Ear2  = "Hollow Earring",
    Body  = "Noble's Tunic",
    Hands = "Healer's Mitts",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Aesir Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Cleric's Pantaln.",
    Feet  = "Healer's Duckbills",
}

-- ----------------------------------------------------------------------------
-- WHM: CASTING / CURE
-- ----------------------------------------------------------------------------

WHM.Sets.Precast = {
    Ear1  = "Loquac. Earring",
}

-- Cure-family spell names get the dedicated Cure set.  This intentionally does
-- not mean every Healing Magic spell receives Cure-specific gear.
WHM.Sets.Cure = {
    Head  = "Healer's Cap",
    Neck  = "Fylgja Torque +1",
    Body  = "Noble's Tunic",
    Hands = "Healer's Mitts",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Dew Silk Cape +1",
    Legs  = "Healer's Pantaln.",
    Feet  = "Healer's Duckbills",
}

WHM.Sets.Curaga = WHM.Sets.Cure
WHM.Sets.Cura = WHM.Sets.Cure

WHM.Sets.FastCast = {
}

WHM.Sets.HealingSkill = {
}

-- ----------------------------------------------------------------------------
-- WHM: ENHANCING / ENFEEBLING / DIVINE
-- ----------------------------------------------------------------------------

WHM.Sets.EnhancingSkill = {
    Neck  = "Enhancing Torque",
}

WHM.Sets.EnfeeblingSkill = {
    Neck  = "Enfeebling Torque",
}

WHM.Sets.DivineSkill = {
}

WHM.Sets.DivineDamage = {
    -- Priority: Magic Atk. Bonus > Magic Accuracy > MND.
    -- Static Earring is retained for magic-burst use.
    Head  = "Goliard Chapeau",
    Ear1  = "Moldavite Earring",
    Ear2  = "Static Earring",
    Body  = "Healer's Bliaut",
    Hands = "Healer's Mitts",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Waist = "Salire Belt",
    Legs  = "Healer's Pantaln.",
    Feet  = "Healer's Duckbills",
}

-- ----------------------------------------------------------------------------
-- WHM: JOB ABILITY SETS
-- ----------------------------------------------------------------------------

WHM.Sets.JA_Default = {}
WHM.Sets.JA_Offensive = {}
WHM.Sets.JA_Defensive = {}

WHM.Sets.AfflatusSolace = {}
WHM.Sets.AfflatusMisery = {}
WHM.Sets.DivineSeal = {}
WHM.Sets.Benediction = {}

WHM.JA = {
    ["Divine Seal"]     = "DivineSeal",
    ["Afflatus Solace"] = "AfflatusSolace",
    ["Afflatus Misery"] = "AfflatusMisery",
    ["Benediction"]     = "Benediction",
}

-- ----------------------------------------------------------------------------
-- WHM: MANUAL DEFENSE MODES
-- ----------------------------------------------------------------------------
-- No dedicated current-level PDT/MDT reduction set is claimed here.  Keep the
-- fallback explicit and conservative until inventory/research supplies verified
-- reduction pieces.

WHM.Sets.PDT = {
}

WHM.Sets.MDT = WHM.Sets.PDT

-- ----------------------------------------------------------------------------
-- WHM: WEAPON SKILLS
-- ----------------------------------------------------------------------------
-- WHM club/staff WS are deliberately separated by damage model. Hecatomb Harness
-- is NOT WHM-equipable, so it is never used here despite being in the inventory.
WHM.Sets.WS_Club_Physical = { Head='Empress Hairpin', Neck='Ancient Torque', Ear1='Brutal Earring', Ear2='Hollow Earring', Body="Healer's Bliaut", Hands="Healer's Mitts", Ring1='Rajas Ring', Ring2="Ulthalam's Ring", Back='Aesir Mantle', Waist='Swift Belt', Legs="Healer's Pantaln.", Feet="Healer's Duckbills" }
WHM.Sets.WS_HexaStrike = WHM.Sets.WS_Club_Physical
WHM.Sets.WS_BlackHalo = { Head='Healer\'s Cap', Neck='Ancient Torque', Ear1='Static Earring', Ear2='Hollow Earring', Body="Healer's Bliaut", Hands="Healer's Mitts", Ring1='Rajas Ring', Ring2='Tamas Ring', Back='Aesir Mantle', Waist='Swift Belt', Legs="Healer's Pantaln.", Feet="Healer's Duckbills" }
WHM.Sets.WS_Club_STR = WHM.Sets.WS_Club_Physical
WHM.Sets.WS_Club_MND = { Head='Healer\'s Cap', Neck='Ancient Torque', Ear1='Static Earring', Ear2='Hollow Earring', Body="Healer's Bliaut", Hands="Healer's Mitts", Ring1='Tamas Ring', Ring2="Balrahn's Ring", Back='Aesir Mantle', Waist='Swift Belt', Legs="Healer's Pantaln.", Feet="Healer's Duckbills" }
WHM.Sets.WS_Club_Magical_STR_MND = {
    Head="Goliard Chapeau", Neck='Ancient Torque',
    Ear1='Moldavite Earring', Ear2='Static Earring',
    Body="Healer's Bliaut", Hands="Healer's Mitts",
    Ring1='Tamas Ring', Ring2="Balrahn's Ring",
    Back='Merciful Cape', Waist='Swift Belt',
    Legs="Healer's Pantaln.", Feet="Healer's Duckbills"
}

-- ----------------------------------------------------------------------------
-- WHM: MAGIC ACTION MAP
-- ----------------------------------------------------------------------------
-- Current runtime mappings cover the WHM75 spell set.
-- Future spells may be added below to the macro deck without becoming active
-- runtime gear selections before their acquisition level.

WHM.MA = {
    -- Cure family: explicit spell names, not the whole Healing Magic skill.
    ["Cure"] = "Cure",
    ["Cure II"] = "Cure",
    ["Cure III"] = "Cure",
    ["Cure IV"] = "Cure",
    ["Cure V"] = "Cure",
    ["Curaga"] = "Curaga",
    ["Curaga II"] = "Curaga",
    ["Curaga III"] = "Curaga",
    ["Cura"] = "Cura",
    ["Cura II"] = "Cura",

    -- Healing / status / utility.
    ["Raise"] = "Precast",
    ["Raise II"] = "Precast",
    ["Raise III"] = "Precast",
    ["Reraise"] = "Precast",
    ["Reraise II"] = "Precast",
    ["Erase"] = "Precast",
    ["Sacrifice"] = "Precast",
    ["Esuna"] = "Precast",

    -- Enhancing Magic.
    ["Protect"] = "Precast",
    ["Protect II"] = "Precast",
    ["Protect III"] = "Precast",
    ["Protect IV"] = "Precast",
    ["Protect V"] = "Precast",
    ["Protectra"] = "Precast",
    ["Protectra II"] = "Precast",
    ["Protectra III"] = "Precast",
    ["Protectra IV"] = "Precast",
    ["Protectra V"] = "Precast",
    ["Shell"] = "Precast",
    ["Shell II"] = "Precast",
    ["Shell III"] = "Precast",
    ["Shell IV"] = "Precast",
    ["Shell V"] = "Precast",
    ["Shellra"] = "Precast",
    ["Shellra II"] = "Precast",
    ["Shellra III"] = "Precast",
    ["Shellra IV"] = "Precast",
    ["Shellra V"] = "Precast",
    ["Stoneskin"] = "EnhancingSkill",
    ["Aquaveil"] = "EnhancingSkill",
    ["Blink"] = "Precast",
    ["Haste"] = "EnhancingSkill",
    ["Regen"] = "EnhancingSkill",
    ["Regen II"] = "EnhancingSkill",
    ["Auspice"] = "EnhancingSkill",
    ["Barfire"] = "EnhancingSkill",
    ["Barblizzard"] = "EnhancingSkill",
    ["Baraero"] = "EnhancingSkill",
    ["Barstone"] = "EnhancingSkill",
    ["Barthunder"] = "EnhancingSkill",
    ["Barwater"] = "EnhancingSkill",
    ["Barfira"] = "EnhancingSkill",
    ["Barblizzara"] = "EnhancingSkill",
    ["Baraera"] = "EnhancingSkill",
    ["Barstonra"] = "EnhancingSkill",
    ["Barthundra"] = "EnhancingSkill",
    ["Barwatera"] = "EnhancingSkill",
    ["Barparalyze"] = "EnhancingSkill",
    ["Barsilence"] = "EnhancingSkill",
    ["Barsleep"] = "EnhancingSkill",
    ["Barparalyzera"] = "EnhancingSkill",
    ["Barsilencera"] = "EnhancingSkill",
    ["Barsleepra"] = "EnhancingSkill",

    -- Enfeebling Magic.
    ["Dia"] = "Precast",
    ["Dia II"] = "Precast",
    ["Diaga"] = "Precast",
    ["Paralyze"] = "EnfeeblingSkill",
    ["Slow"] = "EnfeeblingSkill",
    ["Silence"] = "EnfeeblingSkill",
    ["Blind"] = "EnfeeblingSkill",
    ["Sleep"] = "EnfeeblingSkill",
    ["Repose"] = "EnfeeblingSkill",

    -- Divine Magic.
    ["Banish"] = "DivineDamage",
    ["Banish II"] = "DivineDamage",
    ["Banish III"] = "DivineDamage",
    ["Banishga"] = "DivineDamage",
    ["Banishga II"] = "DivineDamage",
    ["Banishga III"] = "DivineDamage",
    ["Holy"] = "DivineDamage",
    ["Flash"] = "DivineSkill",
}

-- ----------------------------------------------------------------------------
-- WHM: WEAPONS / PROGRESSION
-- ----------------------------------------------------------------------------
-- Current WHM75 weapon.  Future weapon milestones are selected by the shared
-- WeaponsByLevel resolver, not by polluting the current runtime weapon line.

WHM.Weapons = { Main = "Arcana Breaker", Sub = "Hoplon" }
WHM.WeaponsByLevel = {
    [55] = { Main="Arcana Breaker", Sub="Hoplon" },
    [63] = { Main="Octave Club", Sub="Hoplon" },
    [71] = { Main="Brass Jadagna", Sub="Hoplon", DWMain="Brass Jadagna", DWSub="Octave Club" },
    [74] = { Main="Brass Jadagna", Shield="Genbu's Shield", DWMain="Brass Jadagna", DWSub="Octave Club" },
}

-- Cure/Curaga/Cura weapon specialization: Asklepios becomes available at 62 and
-- is used for Cure-family casts while TP is below the universal 50-TP lock.
-- At higher TP, the global weapon lock remains authoritative and no weapon swap
-- is attempted.

local WHMCureSpells = {
    ["Cure"] = true,
    ["Cure II"] = true,
    ["Cure III"] = true,
    ["Cure IV"] = true,
    ["Curaga"] = true,
    ["Curaga II"] = true,
}

-- ----------------------------------------------------------------------------
-- WHM: LEVEL-75 PROGRESSION / REFERENCE NOTES
-- ----------------------------------------------------------------------------
-- WHM is now level 75, so the level-75 runtime mappings above are active.
-- Historical acquisition checkpoints retained for reference:
--   Cure V / Esuna: 61
--   Raise III: 75
--   Curaga III: 51
--   Auspice: 55
--   Raise II: 56
--   Shell III / Shellra III: 57
--
-- Base Cleric Artifact pieces are now part of the current WHM75 equipment pool.
-- +1/+augmented WHM Artifact upgrades are not assumed unless explicitly confirmed.
-- Asklepios remains a documented WHM weapon milestone; Chatoyant Staff is used by
-- the low-TP Cure/elemental/dark/enfeebling spell overlay and for resting.
-- ============================================================================

-- END WHM

-- ============================================================================
-- THF: THIEF
-- ============================================================================
-- Current job level: 75
--
-- This is the complete THF home.  Keep THF gear, actions, weapon skills,
-- weapons, and macros together here so a human editor does not need to chase
-- definitions through the shared engine.
--
-- CatsEyeXI notes:
--   * THF has native Dual Wield I at Lv20 and Dual Wield II at Lv40.
--   * Sneak Attack / Trick Attack remain the core positional damage tools.
--   * Bully is available at Lv60 on CatsEyeXI.
--   * Conspirator and Despoil are available at Lv75 on CatsEyeXI.
--   * Treasure Hunter has a CatsEyeXI-specific proc/cap system; passive TH gear
--     should be incorporated deliberately rather than treated as ordinary TP gear.
--
-- Ownership: all named equipment below is either present in the supplied
-- inventory or covered by the project's explicit eventual-Artifact rule.
-- ============================================================================

local THF = JOBS.THF

-- ----------------------------------------------------------------------------
-- THF: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------
-- Current level: 75.  The Engaged set now uses the user's finalized
-- 75-era melee priorities; keep future upgrades explicit rather than implicit.
THF.Sets.Idle = {
    Head  = "Empress Hairpin",
    Neck  = "Chivalrous Chain",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Rogue's Vest",
    Hands = "Rogue's Armlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Ulthalam's Ring",
    Waist = "Swift Belt",
    Legs  = "Rogue's Culottes",
    Feet  = "Rogue's Poulaines",
}

THF.Sets.Resting = {
    Head  = "Empress Hairpin",
    Neck  = "Chivalrous Chain",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Rogue's Vest",
    Hands = "Rogue's Armlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Ulthalam's Ring",
    Waist = "Swift Belt",
    Legs  = "Rogue's Culottes",
    Feet  = "Rogue's Poulaines",
}

-- THF does not need a melee-oriented engaged set for the current design.
-- Keep the state explicit so the shared state machine remains predictable.
-- Engaged sets follow the global project priority:
-- Haste > Double/Triple Attack > Accuracy > Attack > Store TP > DEX > STR
-- > Critical Hit Rate > Critical Hit Damage.
THF.Sets.Engaged = {
    Head  = "Walahra Turban",
    Neck  = "Ancient Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Pln. Khazagand",
    Hands = "Assassin's Armlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Aesir Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Rogue's Culottes",
    Feet  = "Dusk Ledelsens +1",
}

-- ----------------------------------------------------------------------------
-- THF: DEFENSIVE MODES
-- ----------------------------------------------------------------------------
-- No dedicated PDT/MDT armor set has been verified in the current inventory
-- for Lv69.  These are conservative survival fallbacks, not claimed PDT/MDT
-- optimization sets.  Replace them when a specific reduction piece is verified.

THF.Sets.PDT = {
    Body  = "Rogue's Vest",
    Hands = "Rogue's Armlets",
    Ring1 = "Sattva Ring",
    Legs  = "Rogue's Culottes",
    Feet  = "Rogue's Poulaines",
}

THF.Sets.MDT = {
    Body  = "Rogue's Vest",
    Hands = "Rogue's Armlets",
    Ring1 = "Sattva Ring",
    Legs  = "Rogue's Culottes",
    Feet  = "Rogue's Poulaines",
}

-- ----------------------------------------------------------------------------
-- THF: JOB ABILITY SETS
-- ----------------------------------------------------------------------------

THF.Sets.JA_SneakAttack = {
    Head  = "Empress Hairpin",
    Neck  = "Spike Necklace",
    Ear1  = "Wing Earring",
    Body  = "Rogue's Vest",
    Hands = "Rogue's Armlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Assassin's Cape",
    Waist = "Ryl.Kgt. Belt",
    Legs  = "Rogue's Culottes",
    Feet  = "Rogue's Poulaines",
}

-- LegacyAC special-rule translation: while Sneak Attack is active, the old
-- XML explicitly locked its P-WS-DEX set until the ability was consumed.
-- LuAshitacast does not need an arbitrary timed lock for this; the Universal
-- profile instead reapplies this small DEX overlay while the SA buff exists.
-- Only currently owned/current-level DEX pieces are included here.  The old
-- XML's Magna/Balance/Spike pieces are not carried forward because they are
-- not established as current inventory.
THF.Sets.SneakAttackDEX = {
    Hands = "Rogue's Armlets",   -- DEX+3
    Ring1 = "Rajas Ring",         -- DEX+5
    Feet  = "Rogue's Poulaines",-- DEX+3
}

THF.Sets.JA_TrickAttack = {
    Head  = "Rogue's Bonnet",
    Ear1  = "Wing Earring",
    Body  = "Rogue's Vest",
    Hands = "Rogue's Armlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Assassin's Cape",
    Waist = "Ryl.Kgt. Belt",
    Legs  = "Rogue's Culottes",
    Feet  = "Bounding Boots",
}

THF.Sets.JA_Steal = {
    Head  = "Rogue's Bonnet",
    Hands = "Rogue's Armlets",
    Legs  = "Rogue's Culottes",
    Feet  = "Rogue's Poulaines",
}

THF.Sets.JA_Hide = {
    Body = "Rogue's Vest",
}

THF.Sets.JA_Flee = {
    Feet = "Rogue's Poulaines",
}

THF.Sets.JA_PerfectDodge = {
    Body  = "Rogue's Vest",
    Ring1 = "Sattva Ring",
}

THF.Sets.JA_Offensive = {
    Head  = "Rogue's Bonnet",
    Body  = "Rogue's Vest",
    Hands = "Rogue's Armlets",
    Ring1 = "Rajas Ring",
    Legs  = "Rogue's Culottes",
    Feet  = "Rogue's Poulaines",
}

THF.Sets.JA_Enmity = {
    Ring1 = "Sattva Ring",
}

-- ----------------------------------------------------------------------------
-- THF: JOB ABILITY MAP
-- ----------------------------------------------------------------------------
-- Keep the action map here, beside the sets it uses.  The macro deck below may
-- contain future Lv75 abilities, but runtime gear mappings remain current-level.

THF.JA = {
    ["Mug"] = "JA_Offensive",
    ["Sneak Attack"] = "JA_SneakAttack",
    ["Trick Attack"] = "JA_TrickAttack",
    ["Accomplice"] = "JA_Enmity",
    ["Collaborator"] = "JA_Enmity",
    ["Flee"] = "JA_Flee",
    ["Steal"] = "JA_Steal",
    ["Hide"] = "JA_Hide",
    ["Perfect Dodge"] = "JA_PerfectDodge",
    ["Bully"] = "JA_Offensive",
    ["Feint"] = "JA_Offensive",
    ["Despoil"] = "JA_Steal",
    ["Conspirator"] = "JA_Offensive",
    ["Assassin's Charge"] = "JA_Offensive",
}

-- ----------------------------------------------------------------------------
-- THF: LEGACYAC SPECIAL-RULE NOTES / LUASHITACAST TRANSLATION
-- ----------------------------------------------------------------------------
-- The supplied LegacyAC/XML has several behaviors worth preserving or explicitly
-- accounting for:
--
-- 1. Sneak Attack DEX lock:
--      <if buffactive="Sneak Attack">
--          <equip set="P-WS-DEX" lock="true"/>
--      </if>
--    -> translated above as SneakAttackDEX.  HandleDefault merges that overlay
--       while the SA buff remains active.  A fixed-duration LockSet() is not used
--       because SA naturally ends when the next qualifying melee attack/WS occurs.
--
-- 2. Buff/status update behavior:
--    The old XML requested buff/status reprocessing.  Universal already processes
--    the active state through its shared callback lifecycle, so there is no THF-
--    specific XML setting to reproduce here.  The SA overlay is therefore part of
--    that normal state evaluation.
--
-- 3. External macro-file execution:
--    The old XML /exec'd a character/job-specific text macro file at load time.
--    Universal replaces that mechanism with THF.Macro + the shared macro installer
--    below, keeping the bindings in one human-readable file.
--
-- 4. Legacy elemental-staff / obi spell swapping:
--    The XML also contained a broad, cross-job TP<49 spell rule that selected an
--    element-matched staff and, at Lv75, an elemental obi/Twilight Cape combination.
--    This is intentionally NOT duplicated as a THF-specific rule: it was global
--    magic logic, requires element staves/obis that are not established in the
--    current inventory, and would conflict with the newer job-specific BLM
--    Chatoyant behavior.  Revisit globally if the relevant equipment is acquired.
--
-- 5. Legacy utility-ring re-equipping:
--    Area-specific ring protection is already centralized in Universal.  It is not
--    duplicated here, avoiding competing ring requests.
--
-- 6. Legacy sample equipment:
--    Gear names appearing only in the XML are historical examples/configuration,
--    not permission to equip them.  Current inventory and explicit user ownership
--    updates remain authoritative.

-- ----------------------------------------------------------------------------
-- THF: WEAPON SKILL SETS
-- ----------------------------------------------------------------------------

THF.Sets["WS-Physical-DEX"] = {
    Head  = "Rogue's Bonnet",
    Ear1  = "Wing Earring",
    Body  = "Rogue's Vest",
    Hands = "Rogue's Armlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Legs  = "Rogue's Culottes",
    Feet  = "Rogue's Poulaines",
}

THF.Sets["WS-Physical-DEX-CHR"] = {
    Head  = "Rogue's Bonnet",
    Ear1  = "Wing Earring",
    Body  = "Rogue's Vest",
    Hands = "Rogue's Armlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Legs  = "Rogue's Culottes",
    Feet  = "Rogue's Poulaines",
}

THF.Sets["WS-Physical-DEX-AGI"] = {
    Head  = "Rogue's Bonnet",
    Ear1  = "Wing Earring",
    Body  = "Rogue's Vest",
    Hands = "Rogue's Armlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Legs  = "Rogue's Culottes",
    Feet  = "Rogue's Poulaines",
}

THF.Sets["WS-Magical-DEX-INT"] = {
    Head  = "Rogue's Bonnet",
    Ear1  = "Moldavite Earring",
    Body  = "Rogue's Vest",
    Hands = "Rogue's Armlets",
    Ring1 = "Tamas Ring",
    Ring2 = "Rajas Ring",
    Legs  = "Rogue's Culottes",
    Feet  = "Rogue's Poulaines",
}

THF.Sets["WS-Utility-MND"] = {
    Head  = "Rogue's Bonnet",
    Ear1  = "Moldavite Earring",
    Ring1 = "Tamas Ring",
    Ring2 = "Sattva Ring",
}

THF.Sets["WS-Utility-CHR"] = {
    Head  = "Rogue's Bonnet",
    Ring1 = "Tamas Ring",
    Ring2 = "Sattva Ring",
}

THF.WS = {
    ["Wasp Sting"] = "WS-Physical-DEX",
    ["Viper Bite"] = "WS-Physical-DEX",
    ["Gust Slash"] = "WS-Magical-DEX-INT",
    ["Cyclone"] = "WS-Magical-DEX-INT",
    ["Energy Steal"] = "WS-Utility-MND",
    ["Energy Drain"] = "WS-Utility-MND",
    ["Shadowstitch"] = "WS-Utility-CHR",
    ["Dancing Edge"] = "WS-Physical-DEX-CHR",
    ["Shark Bite"] = "WS-Physical-DEX-AGI",
}

-- Future/current-75 WS map.  These are reference-only until the character
-- reaches the required skill/level; they deliberately do not become active
-- runtime mappings merely because the macro deck can be prepared in advance.
THF.Future75WS = {
    ["Evisceration"] = "WS-Physical-DEX",
    ["Mandalic Stab"] = "WS-Physical-DEX",
}

-- ----------------------------------------------------------------------------
-- THF: WEAPONS
-- ----------------------------------------------------------------------------
-- THF main job always has Dual Wield in the current project rules.
-- The weapon set is therefore unconditional: there is no level-switch table
-- and no CanDualWield() decision involved for THF as the main job.

THF.Weapons = {
    Main   = "Blau Dolch",
    Sub    = "Octave Club",
    DWMain = "Blau Dolch",
    DWSub  = "Octave Club",
}

-- ----------------------------------------------------------------------------
-- THF: FUTURE LV73-75 EQUIPMENT NOTES
-- ----------------------------------------------------------------------------
-- Hecatomb Harness is owned and becomes equippable at Lv73; its STR+12 and
-- Accuracy+10 make it a meaningful physical-WS/attack candidate.  The broader
-- Hecatomb set should be considered only piece-by-piece because its Slow effect
-- is substantial.
-- Rogue's Attire +1 becomes available at Lv74.  Rogue's Armlets +1 specifically
-- enhance Trick Attack, while the +1 set improves the base artifact pieces.
-- Assassin's Attire spans Lv71-75 and is already represented in inventory;
-- Assassin's Poulaines provide Triple Attack +1, Culottes enhance Steal, and
-- Armlets add Treasure Hunter +1 at Lv75.
-- These future upgrades should be incorporated into the active Lv74/75 set after
-- the current Lv72 leveling test cycle, rather than prematurely equipping them.

-- ----------------------------------------------------------------------------
-- THF: MACRO DECK
-- ----------------------------------------------------------------------------
-- Practical 75-era deck: core THF damage/utility first, then less frequent or
-- future actions.  The CatsEye-specific Lv75 additions (Bully/Despoil/Conspirator)
-- are retained here even though the character is currently Lv69.

THF.Macro = {
    Alt = {
        ['!`'] = 'Mug',
        ['!1'] = 'Sneak Attack',
        ['!2'] = 'Trick Attack',
        ['!3'] = 'Accomplice',
        ['!4'] = 'Collaborator',
        ['!5'] = 'Bully',
        ['!6'] = 'Feint',
        ['!7'] = 'Despoil',
        ['!8'] = 'Conspirator',
        ['!9'] = "Assassin's Charge",
    },
    Ctrl = {
        ['^`'] = 'Perfect Dodge',
        ['^1'] = 'Steal',
        ['^2'] = 'Flee',
        ['^3'] = 'Hide',
    },
    WS = {
        ['^!`'] = 'Wasp Sting',
        ['^!1'] = 'Viper Bite',
        ['^!2'] = 'Gust Slash',
        ['^!3'] = 'Cyclone',
        ['^!4'] = 'Dancing Edge',
        ['^!5'] = 'Shark Bite',
        ['^!6'] = 'Evisceration',
        ['^!7'] = 'Energy Drain',
        ['^!8'] = 'Mandalic Stab',
    },
}

-- END THF

-- ============================================================================
-- DRK: CHARACTER-SPECIFIC EQUIPMENT / ACTION DATA
-- ============================================================================
-- Current job level: 75
-- DRK is now level 75 and is maintained as a completed level-75 job section.
-- CatsEyeXI retains its gear scaling at the level cap, so this section no
-- longer carries leveling-state equipment overlays.  The final 75-cap sets
-- are the runtime source of truth, following the RDM organizational model.
--
-- OWNERSHIP / SOURCE NOTES:
--   Perdu Sickle       = currently owned (also used by BLM) and the automatic
--                        primary scythe for the completed level-75 DRK build.
--   Gloom Breastplate  = newly confirmed DRK body; user-confirmed CatsEyeXI
--                        Drain/Aspir enhancement.  Standard FFXI also gives it
--                        Souleater enhancement, but the CatsEye-specific
--                        Drain/Aspir behavior supplied by the user is the
--                        authority for this profile.
--   Abyssal Earring    = newly confirmed owned; Lv72, Scythe Skill +5 and
--                        Dark Magic Skill +5 on the standard item.
--   Shura Togi        = owned with Haste +2%, Critical Hit Rate +2%, and
--                        Ninja Tool Expertise +3%, but it is not DRK-equipable and
--                        therefore is intentionally excluded from every DRK set.
--   Hecatomb Harness   = owned, currently no augments.  Its native Slow makes
--                        it inappropriate for normal TP, but its STR/Accuracy
--                        make it useful for physical WS at the level-75 cap.
--   Base Chaos Artifact armor is treated as eventual ownership per project
--   rules.  No Chaos +1 is assumed.
--
-- SOURCE / MECHANICS NOTES:
--   CatsEyeXI moves Occult Acumen I to Lv37 and gives DRK its other listed
--   custom job changes.  Frostbite / Freezebite and Shadow of Death also have
--   CatsEyeXI damage changes.  See the sourced research notes below.
--   Standard DRK combat ranks are Scythe A+ and Great Sword A.  Both weapon
--   families therefore remain represented in the WS deck, while the owned
--   Perdu Sickle is the automatic level-75 primary weapon.
-- ============================================================================

local DRK = JOBS.DRK

-- ----------------------------------------------------------------------------
-- DRK: LEVEL-75 BASE STATE
-- ----------------------------------------------------------------------------
-- End-state TP/idle gear is built from the character's confirmed inventory.
-- Empty slots remain omitted where no useful DRK-specific item is owned.
DRK.Sets.Idle = {
    Head  = "Walahra Turban",
    Neck  = "Ancient Torque",
    Ear1  = "Ethereal Earring",
    Ear2  = "Static Earring",
    Body  = "Chaos Cuirass",
    Hands = "Abyss Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Aesir Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Dusk Ledelsens +1",
}

DRK.Sets.Resting = {
    Main  = "Chatoyant Staff",
    Body  = "Errant Hpl.",
}

-- DRK engaged priority remains the universal project convention:
-- Haste > Double/Triple Attack > Accuracy > Attack > Store TP > DEX > STR >
-- Critical Hit Rate > Critical Hit Damage.
--
-- Hecatomb Harness is reserved for WS because its native Slow +13%
-- is counterproductive to normal TP generation.
DRK.Sets.Engaged = {
    Head  = "Walahra Turban",
    Neck  = "Ancient Torque",
    Ear1  = "Brutal Earring",
    Ear2  = "Hollow Earring",
    Body  = "Chaos Cuirass",
    Hands = "Abyss Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Aesir Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Dusk Ledelsens +1",
}

-- ----------------------------------------------------------------------------
-- DRK: LEVEL-75 FINAL STATE
-- ----------------------------------------------------------------------------
-- DRK is level 75.  No sub-75 equipment progression overlays are retained:
-- the completed job uses its final level-75 sets directly, matching the RDM
-- scaffolding pattern.  Lower-level items remain in inventory only when they
-- are still the best owned item for a particular specialized set.

-- ----------------------------------------------------------------------------
-- DRK: DEFENSIVE SETS
-- ----------------------------------------------------------------------------
-- No genuine owned PDT/MDT equipment package has been established yet.
-- Keep these empty rather than pretending the offensive set is defensive gear.
DRK.Sets.PDT = {}
DRK.Sets.MDT = {}

-- ----------------------------------------------------------------------------
-- DRK: PRECAST / SPELL SETS
-- ----------------------------------------------------------------------------
-- Loquac. Earring is the one established generic Fast Cast piece that is both
-- owned and safe for DRK at the current level.
DRK.Sets.Precast = {
    Ear1  = "Loquac. Earring",
    Legs  = "Homam Cosciales",
}

DRK.Sets.FastCast = {
    Ear1  = "Loquac. Earring",
    Legs  = "Homam Cosciales",
}

-- Dark-magic skill set. Aesir Torque is a direct +7 Dark Magic piece at 75;
-- Abyssal Earring and the owned Abyss hands/legs add their Dark Magic skill.
DRK.Sets.DarkMagic = {
    Head  = "Chaos Burgeonet",
    Ear2  = "Abyssal Earring",
    Hands = "Abyss Gauntlets",
    Neck  = "Aesir Torque",
    Legs  = "Abyss Flanchard",
    Feet  = "Abyss Sollerets",
}
DRK.Sets.DrainAspir = {
    Body  = "Gloom Breastplate",
    Head  = "Chaos Burgeonet",
    Ear2  = "Abyssal Earring",
    Hands = "Abyss Gauntlets",
    Neck  = "Aesir Torque",
    Legs  = "Abyss Flanchard",
    Feet  = "Abyss Sollerets",
}
DRK.Sets.EnfeeblingMagic = {
    Neck  = "Enfeebling Torque",
    Body  = "Chaos Cuirass",
    Feet  = "Abyss Sollerets",
}

DRK.Sets.ElementalDamage = {
    Main  = "Chatoyant Staff",
    Sub   = "Wizzan Grip",
    Ear1  = "Moldavite Earring",
    Ear2  = "Static Earring",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
}

-- Dread Spikes is HP-scaled at cast time.  This set intentionally uses only
-- owned pieces with documented HP+ values.
DRK.Sets.DreadSpikes = {
    Body  = "Chaos Cuirass",
    Ear1  = "Ethereal Earring",
    Ring1 = "Bomb Queen Ring",
    Ring2 = "Sattva Ring",
    Legs  = "Homam Cosciales",
}

-- ----------------------------------------------------------------------------
-- DRK: JOB-ABILITY SETS
-- ----------------------------------------------------------------------------
DRK.Sets.JA_Offensive = DRK.Sets.Engaged
DRK.Sets.JA_BloodWeapon = DRK.Sets.JA_Offensive
DRK.Sets.JA_LastResort = {
    Feet = "Abyss Sollerets",
}
DRK.Sets.JA_ArcaneCircle = {
    Feet = "Chaos Sollerets",
}
DRK.Sets.JA_WeaponBash = {
    Hands = "Chaos Gauntlets",
}

DRK.Sets.JA_Souleater = {
    Head  = "Chaos Burgeonet",
    Body  = "Gloom Breastplate",
}
DRK.JA = {
    ["Blood Weapon"]     = "JA_BloodWeapon",
    ["Arcane Circle"]    = "JA_ArcaneCircle",
    ["Last Resort"]      = "JA_LastResort",
    ["Weapon Bash"]      = "JA_WeaponBash",
    ["Souleater"]        = "JA_Souleater",
    ["Dark Seal"]        = "DarkMagic",
    ["Diabolic Eye"]     = "JA_Offensive",
    ["Nether Void"]      = "DarkMagic",
    ["Scarlet Delirium"] = "JA_Offensive",
}

-- ----------------------------------------------------------------------------
-- DRK: MAGIC ACTION MAP
-- ----------------------------------------------------------------------------
-- Current/future action levels follow the standard DRK spell list, with the
-- CatsEyeXI custom changes taking precedence where explicitly documented.
DRK.MA = {
    ["Drain"]       = "DrainAspir",
    ["Aspir"]       = "DrainAspir",
    ["Drain II"]    = "DrainAspir",

    ["Absorb-MND"]   = "DarkMagic",
    ["Absorb-CHR"]   = "DarkMagic",
    ["Absorb-VIT"]   = "DarkMagic",
    ["Absorb-AGI"]   = "DarkMagic",
    ["Absorb-INT"]   = "DarkMagic",
    ["Absorb-DEX"]   = "DarkMagic",
    ["Absorb-STR"]   = "DarkMagic",
    ["Absorb-TP"]    = "DarkMagic",
    ["Absorb-ACC"]   = "DarkMagic",
    ["Absorb-Attri"] = "DarkMagic",
    ["Stun"]         = "DarkMagic",
    ["Dread Spikes"] = "DreadSpikes",

    ["Poison"]       = "EnfeeblingMagic",
    ["Bind"]         = "EnfeeblingMagic",
    ["Poisonga"]     = "EnfeeblingMagic",
    ["Sleep"]        = "EnfeeblingMagic",
    ["Poison II"]    = "EnfeeblingMagic",
    ["Sleep II"]     = "EnfeeblingMagic",
    ["Bio"]          = "EnfeeblingMagic",
    ["Bio II"]       = "EnfeeblingMagic",

    ["Stone"]        = "ElementalDamage",
    ["Water"]        = "ElementalDamage",
    ["Aero"]         = "ElementalDamage",
    ["Fire"]         = "ElementalDamage",
    ["Blizzard"]     = "ElementalDamage",
    ["Thunder"]      = "ElementalDamage",
    ["Stone II"]     = "ElementalDamage",
    ["Water II"]     = "ElementalDamage",
    ["Aero II"]      = "ElementalDamage",
    ["Fire II"]      = "ElementalDamage",
    ["Blizzard II"]  = "ElementalDamage",
    ["Thunder II"]   = "ElementalDamage",
    ["Tractor"]      = "FastCast",
}

-- ----------------------------------------------------------------------------
-- DRK: WEAPONS
-- ----------------------------------------------------------------------------
-- DRK is level 75, so the owned Perdu Sickle is the automatic primary weapon.
-- Axe Grip remains the owned grip for the completed scythe configuration.
DRK.Weapons = {
    Main = "Perdu Sickle",
    Sub  = "Axe Grip",
}

-- ----------------------------------------------------------------------------
-- DRK: WEAPONSKILL SETS
-- ----------------------------------------------------------------------------
-- Physical WS use the owned Hecatomb Harness despite its Slow because WS
-- snapshots are separate from TP generation. Fotia Gorget is used for the
-- skillchain-property WS family; Hollow/Brutal provide accuracy/DA where useful.
DRK.Sets.WS_Default = {
    Head  = "Chaos Burgeonet",
    Neck  = "Fotia Gorget",
    Ear1  = "Brutal Earring",
    Ear2  = "Hollow Earring",
    Body  = "Hecatomb Harness",
    Hands = "Abyss Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Aesir Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Dusk Ledelsens +1",
}

local DRK_WS_PhysicalBase = {
    Head  = "Chaos Burgeonet",
    Neck  = "Fotia Gorget",
    Ear1  = "Brutal Earring",
    Ear2  = "Hollow Earring",
    Body  = "Hecatomb Harness",
    Hands = "Abyss Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Aesir Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Dusk Ledelsens +1",
}

DRK.Sets["WS-Physical-STR"] = DRK_WS_PhysicalBase
DRK.Sets["WS-Physical-STR-MND"] = DRK_WS_PhysicalBase
DRK.Sets["WS-Physical-STR-INT"] = DRK_WS_PhysicalBase
DRK.Sets["WS-Physical-STR-DEX"] = DRK_WS_PhysicalBase
DRK.Sets["WS-Physical-STR-VIT"] = DRK_WS_PhysicalBase

DRK.Sets["WS-Magical-STR-INT"] = {
    Head  = "Chaos Burgeonet",
    Neck  = "Fotia Gorget",
    Ear1  = "Abyssal Earring",
    Ear2  = "Moldavite Earring",
    Body  = "Hecatomb Harness",
    Hands = "Abyss Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Aesir Mantle",
    Waist = "Charmer's Sash",
    Legs  = "Abyss Flanchard",
    Feet  = "Abyss Sollerets",
}
DRK.WS = {
    ["Dark Harvest"]    = "WS-Physical-STR",
    ["Shadow of Death"] = "WS-Physical-STR-INT",
    ["Vorpal Scythe"]   = "WS-Physical-STR",
    ["Guillotine"]      = "WS-Physical-STR-MND",
    ["Sickle Moon"]     = "WS-Physical-STR-DEX",
    ["Cross Reaper"]    = "WS-Physical-STR-MND",
    ["Spinning Slash"]  = "WS-Physical-STR-INT",
    ["Spiral Hell"]     = "WS-Physical-STR-INT",
    ["Ground Strike"]   = "WS-Physical-STR-INT",
    ["Hard Slash"]      = "WS-Physical-STR",
    ["Power Slash"]     = "WS-Physical-STR-VIT",
    ["Frostbite"]       = "WS-Magical-STR-INT",
    ["Freezebite"]      = "WS-Magical-STR-INT",
    ["Shockwave"]       = "WS-Physical-STR",
    ["Crescent Moon"]   = "WS-Physical-STR",
}

-- ----------------------------------------------------------------------------
-- DRK: MACRO DECK
-- ----------------------------------------------------------------------------
-- New-job macro deck.  Unlike RDM's frozen deck, DRK is arranged in practical
-- action groups, with lower-level actions before later upgrades within each
-- group.  The deck may contain future Lv75 actions while the job is Lv75.
DRK.Macro = {
    Alt = {
        ['!`'] = 'Drain',
        ['!1'] = 'Aspir',
        ['!2'] = 'Absorb-MND',
        ['!3'] = 'Absorb-CHR',
        ['!4'] = 'Absorb-VIT',
        ['!5'] = 'Absorb-AGI',
        ['!6'] = 'Absorb-INT',
        ['!7'] = 'Absorb-DEX',
        ['!8'] = 'Absorb-STR',
        ['!9'] = 'Absorb-TP',
        ['!0'] = 'Stun',
        ['!-'] = 'Bio II',
        ['!='] = 'Poison II',
        ['!Backspace'] = 'Drain II',
        ['!\\'] = 'Absorb-Attri',
    },

    Ctrl = {
        ['^`'] = 'Blood Weapon',
        ['^1'] = 'Arcane Circle',
        ['^2'] = 'Last Resort',
        ['^3'] = 'Weapon Bash',
        ['^4'] = 'Souleater',
        ['^6'] = 'Dark Seal',
        ['^7'] = 'Diabolic Eye',
        ['^8'] = 'Nether Void',
        ['^9'] = 'Scarlet Delirium',
    },

    Spells = {
        ['^5'] = 'Dread Spikes',
    },

    WS = {
        ['^!`'] = 'Dark Harvest',
        ['^!1'] = 'Shadow of Death',
        ['^!2'] = 'Vorpal Scythe',
        ['^!3'] = 'Guillotine',
        ['^!4'] = 'Sickle Moon',
        ['^!5'] = 'Cross Reaper',
        ['^!6'] = 'Spinning Slash',
        ['^!7'] = 'Spiral Hell',
        ['^!8'] = 'Ground Strike',
        ['^!9'] = 'Hard Slash',
        ['^!0'] = 'Power Slash',
        ['^!-'] = 'Frostbite',
        ['^!='] = 'Freezebite',
    },
}

-- END DRK

-- ============================================================================
-- BST: CHARACTER-SPECIFIC EQUIPMENT / ACTION DATA
-- ============================================================================
-- Current job level: 42
-- This section is the authoritative home for BST-specific configuration.
-- Runtime equipment/action mappings must respect the current job level.
-- Future level-75 macro preparation may be documented here without becoming
-- executable runtime gear.

local BST = JOBS.BST

-- ----------------------------------------------------------------------------
-- BST: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------

BST.Sets.Idle = {
        Head="Monster Helm", Neck="Fortitude Torque", Ear1="Brutal Earring", Ear2="Static Earring",
        Body="Monster Jackcoat", Hands="Monster Gloves", Ring1="Rajas Ring", Ring2="Ulthalam's Ring",
        Back="High Brth. Mantle", Waist="Monster Belt", Legs="Monster Trousers", Feet="Monster Gaiters",
    }

BST.Sets.Resting = {
        Head="Monster Helm", Neck="Fortitude Torque", Body="Monster Jackcoat", Hands="Monster Gloves",
        Ring1="Rajas Ring", Ring2="Ulthalam's Ring", Waist="Monster Belt", Legs="Monster Trousers", Feet="Monster Gaiters",
    }

BST.Sets.Engaged = {
        Head="Walahra Turban", Neck="Fortitude Torque", Ear1="Suppanomimi", Ear2="Brutal Earring",
        Body="Monster Jackcoat", Hands="Monster Gloves", Ring1="Rajas Ring", Ring2="Ulthalam's Ring",
        Back="High Brth. Mantle", Waist="Monster Belt", Legs="Monster Trousers", Feet="Monster Gaiters",
    }

-- ----------------------------------------------------------------------------
-- BST: WEAPONS
-- ----------------------------------------------------------------------------

BST.Weapons = { Main="Sturdy Axe" }

-- ----------------------------------------------------------------------------
-- BST: JOB ABILITIES / MAGIC / WEAPON SKILLS / MACROS
-- ----------------------------------------------------------------------------
-- Dedicated mechanics and ownership audit remains to be completed here.
-- Keep all BST-specific additions inside this section.


-- ============================================================================
-- BRD: CHARACTER-SPECIFIC EQUIPMENT / ACTION DATA
-- ============================================================================
-- Current job level: 40
-- This section is the authoritative home for BRD-specific configuration.
-- Runtime equipment/action mappings must respect the current job level.
-- Future level-75 macro preparation may be documented here without becoming
-- executable runtime gear.

local BRD = JOBS.BRD

-- ----------------------------------------------------------------------------
-- BRD: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------

BRD.Sets.Idle = {
        Head="Bard's Roundlet", Neck="Star Necklace", Ear1="Loquac. Earring", Ear2="Brutal Earring",
        Body="Errant Hpl.", Hands="Bard's Cuffs", Ring1="Tamas Ring", Ring2="Balrahn's Ring",
        Back="Grapevine Cape", Waist="Salire Belt", Legs="Bard's Cannions", Feet="Bard's Slippers",
    }

BRD.Sets.Resting = {
        Head="Bard's Roundlet", Neck="Star Necklace", Body="Errant Hpl.", Hands="Bard's Cuffs",
        Ring1="Tamas Ring", Ring2="Balrahn's Ring", Waist="Salire Belt", Legs="Bard's Cannions", Feet="Bard's Slippers",
    }

BRD.Sets.Engaged = {
        Head="Walahra Turban", Neck="Fortitude Torque", Ear1="Brutal Earring", Ear2="Loquac. Earring",
        Body="Errant Hpl.", Hands="Bard's Cuffs", Ring1="Rajas Ring", Ring2="Ulthalam's Ring",
        Back="Grapevine Cape", Waist="Swift Belt", Legs="Bard's Cannions", Feet="Bard's Slippers",
    }

-- ----------------------------------------------------------------------------
-- BRD: WEAPONS
-- ----------------------------------------------------------------------------

BRD.Weapons = { Main="Joyeuse" }

-- ----------------------------------------------------------------------------
-- BRD: JOB ABILITIES / MAGIC / WEAPON SKILLS / MACROS
-- ----------------------------------------------------------------------------
-- Dedicated mechanics and ownership audit remains to be completed here.
-- Keep all BRD-specific additions inside this section.


-- ============================================================================
-- RNG: CHARACTER-SPECIFIC EQUIPMENT / ACTION DATA
-- ============================================================================
-- Current job level: 43
-- This section is the authoritative home for RNG-specific configuration.
-- Runtime equipment/action mappings must respect the current job level.
-- Future level-75 macro preparation may be documented here without becoming
-- executable runtime gear.

local RNG = JOBS.RNG

-- ----------------------------------------------------------------------------
-- RNG: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------

RNG.Sets.Idle = {
        Head="Scout's Beret", Neck="Fortitude Torque", Ear1="Brutal Earring", Ear2="Static Earring",
        -- Body intentionally omitted: no safely verified inventory-owned Scout body was listed.
        Hands="Scout's Bracers", Ring1="Rajas Ring", Ring2="Ulthalam's Ring",
        Back="Ryl. Army Mantle", Waist="Swift Belt", Legs="Scout's Braccae", Feet="Dusk Ledelsens +1",
    }

RNG.Sets.Resting = {
        Head="Scout's Beret", Neck="Fortitude Torque", Hands="Scout's Bracers",
        Ring1="Rajas Ring", Ring2="Ulthalam's Ring", Legs="Scout's Braccae", Feet="Dusk Ledelsens +1",
    }

RNG.Sets.Engaged = {
        Head="Walahra Turban", Neck="Fortitude Torque", Ear1="Brutal Earring", Ear2="Static Earring",
        Hands="Scout's Bracers", Ring1="Rajas Ring", Ring2="Bellona's Ring", Back="Ryl. Army Mantle",
        Waist="Swift Belt", Legs="Scout's Braccae", Feet="Dusk Ledelsens +1",
    }

-- ----------------------------------------------------------------------------
-- RNG: WEAPONS
-- ----------------------------------------------------------------------------

RNG.Weapons = { Main="Failnaught", Range="Ajjub Bow", Ammo="Demon Arrow" }

-- ----------------------------------------------------------------------------
-- RNG: JOB ABILITIES / MAGIC / WEAPON SKILLS / MACROS
-- ----------------------------------------------------------------------------
-- Dedicated mechanics and ownership audit remains to be completed here.
-- Keep all RNG-specific additions inside this section.


-- ============================================================================
-- NIN: CHARACTER-SPECIFIC EQUIPMENT / ACTION DATA
-- ============================================================================
-- Current job level: 41
-- This section is the authoritative home for NIN-specific configuration.
-- Runtime equipment/action mappings must respect the current job level.
-- Future level-75 macro preparation may be documented here without becoming
-- executable runtime gear.

local NIN = JOBS.NIN

-- ----------------------------------------------------------------------------
-- NIN: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------
-- NIN41 currently uses the owned CatsEyeXI quest-reward Shade set as the
-- level-appropriate armor foundation.  Idle and Engaged both explicitly own
-- Legs and Feet so the global Track Pants +1 movement overlay never leaves
-- these state slots empty.
--
-- Idle:
--   Bounding Boots = DEX+3 AGI+3; no Haste item is needed while idle.
--
-- Engaged:
--   Spike Necklace = STR+3 DEX+3, level 21; shifts the set toward direct
--   melee damage for the current Innin/DD leveling role.
--   Sarutobi Kyahan = Haste+3%, available at NIN39.
--   Ochimusha Kote = Attack+20, available at NIN34; retained over Shade
--   Mittens for the engaged attack priority.
--   Rajas Ring + Sattva Ring are both available at level 30. Rajas supplies
--   STR/DEX/Store TP; Sattva supplies AGI/HP/VIT and preserves the preferred
--   AGI-oriented defensive bias.
--
-- Tamas Ring is also level-30 and documented in Equipment.csv, but its
-- MP/INT/MND profile is not preferred for this melee-oriented NIN set.
--
-- Low-level accessory slots use only owned, level-appropriate pieces whose
-- relevant stats are documented in Equipment.csv. No future-level NIN gear
-- is allowed to enter the active runtime sets.

NIN.Sets.Idle = {
    Head  = "Empress Hairpin",
    Neck  = "Wing Pendant",
    Ear1  = "Wing Earring",
    Ear2  = "Wing Earring",
    Body  = "Shade Harness",
    Hands = "Shade Mittens",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Frugal Cape",
    Legs  = "Shade Tights",
    Feet  = "Bounding Boots",
}

NIN.Sets.Resting = {
    Head  = "Empress Hairpin",
    Neck  = "Wing Pendant",
    Ear1  = "Wing Earring",
    Ear2  = "Wing Earring",
    Body  = "Shade Harness",
    Hands = "Shade Mittens",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Frugal Cape",
    Legs  = "Shade Tights",
    Feet  = "Bounding Boots",
}

NIN.Sets.Engaged = {
    Head  = "Empress Hairpin",
    Neck  = "Spike Necklace",
    Ear1  = "Wing Earring",
    Ear2  = "Wing Earring",
    Body  = "Shade Harness",
    Hands = "Ochimusha Kote",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Frugal Cape",
    Legs  = "Shade Tights",
    Feet  = "Sarutobi Kyahan",
}

-- ----------------------------------------------------------------------------
-- NIN: JOB ABILITIES / MAGIC / WEAPON SKILLS / MACROS
-- ----------------------------------------------------------------------------
-- Dedicated mechanics and ownership audit remains to be completed here.
-- Keep all NIN-specific additions inside this section.


-- ============================================================================
-- DRG: CHARACTER-SPECIFIC EQUIPMENT / ACTION DATA
-- ============================================================================
-- Current job level: 75
-- This section is the authoritative home for DRG-specific configuration.
-- Runtime equipment/action mappings must respect the current job level.
-- Future level-75 macro preparation may be documented here without becoming
-- executable runtime gear.

local DRG = JOBS.DRG

-- ----------------------------------------------------------------------------
-- DRG: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------

DRG.Sets.Idle = {
    Head="Walahra Turban", Neck="Ancient Torque", Ear1="Brutal Earring", Ear2="Hollow Earring",
    Body="Pln. Khazagand", Hands="Drachen Fng. Gnt.", Ring1="Rajas Ring", Ring2="Mars's Ring",
    Back="Aesir Mantle", Waist="Ninurta's Sash", Legs="Homam Cosciales", Feet="Wyrm Greaves",
}

DRG.Sets.HighJump = {
    Legs = "Wyrm Brais",
}

DRG.Sets.DeepBreathing = {
    Head  = "Wyrm Armet",
    Body  = "Drachen Mail",
    Legs  = "Wyrm Brais",
    Feet  = "Wyrm Greaves",
}

DRG.Sets.AncientCircle = {
    Legs = "Drachen Brais",
}

DRG.Sets.PDT = {
    Head  = "Wyrm Armet",
    Body  = "Drachen Mail",
    Hands = "Drachen Fng. Gnt.",
    Legs  = "Wyrm Brais",
    Feet  = "Wyrm Greaves",
}

DRG.Sets.MDT = DRG.Sets.PDT

DRG.Sets.JA_Default = {}
DRG.Sets.JA_Offensive = DRG.Sets.Jump
DRG.Sets.JA_Defensive = {}
DRG.Sets.JA_Enmity = {}

DRG.JA["Jump"] = "Jump"
DRG.JA["High Jump"] = "HighJump"
DRG.JA["Deep Breathing"] = "DeepBreathing"
DRG.JA["Ancient Circle"] = "AncientCircle"

-- Spirit Link is intentionally left without a special gear mapping here.
-- The specific Spirit Link enhancement belongs to Drachen Armet +1 in the
-- standard reference data, which is not an explicitly owned piece in the
-- current inventory.
DRG.JA["Super Jump"] = "JA_Default"
DRG.JA["Spirit Link"] = "JA_Default"

-- ----------------------------------------------------------------------------
-- DRG: WYVERN ACTIONS
-- ----------------------------------------------------------------------------

DRG.Sets.PetHealing = {
    Head  = "Wyrm Armet",
    Body  = "Drachen Mail",
    Legs  = "Wyrm Brais",
    Feet  = "Wyrm Greaves",
}

DRG.Sets.PetMagical = DRG.Sets.PetHealing

DRG.PET["Healing Breath"] = "PetHealing"
DRG.PET["Healing Breath II"] = "PetHealing"
DRG.PET["Healing Breath III"] = "PetHealing"
DRG.PET["Elemental Breath"] = "PetMagical"

-- ----------------------------------------------------------------------------
-- DRG: WEAPON SKILLS
-- ----------------------------------------------------------------------------
-- Penta Thrust is the practical TP-burn workhorse; Wheeling Thrust is the
-- defense-ignoring option; Impulse Drive is the later two-hit WS and requires
-- the Methods Create Madness quest.  Geirskogul is intentionally absent: the
-- inventory contains Gae Bolg, not the Gae Assail/Gungnir weapon requirement.

DRG.Sets.WS_DoubleThrust = {
    Head  = "Walahra Turban",
    Neck  = "Fortitude Torque",
    Ear1  = "Brutal Earring",
    Ear2  = "Static Earring",
    Body  = "Shura Togi",
    Hands = "Wyrm Fng. Gnt.",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "High Brth. Mantle",
    Waist = "Swift Belt",
    Legs  = "Wyrm Brais",
    Feet  = "Wyrm Greaves",
}

DRG.Sets.WS_PentaThrust = DRG.Sets.WS_DoubleThrust
DRG.Sets.WS_Skewer = DRG.Sets.WS_DoubleThrust

DRG.Sets.WS_WheelingThrust = {
    Head  = "Walahra Turban",
    Neck  = "Fortitude Torque",
    Ear1  = "Brutal Earring",
    Ear2  = "Static Earring",
    Body  = "Shura Togi",
    Hands = "Wyrm Fng. Gnt.",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "High Brth. Mantle",
    Waist = "Swift Belt",
    Legs  = "Wyrm Brais",
    Feet  = "Wyrm Greaves",
}

DRG.Sets.WS_ImpulseDrive = DRG.Sets.WS_WheelingThrust
DRG.Sets.WS_VorpalThrust = DRG.Sets.WS_DoubleThrust
DRG.Sets.WS_LegSweep = DRG.Sets.WS_DoubleThrust
DRG.Sets.WS_Default = DRG.Sets.WS_PentaThrust

DRG.WS["Double Thrust"] = "WS_DoubleThrust"
DRG.WS["Thunder Thrust"] = "WS_DoubleThrust"
DRG.WS["Raiden Thrust"] = "WS_DoubleThrust"
DRG.WS["Leg Sweep"] = "WS_LegSweep"
DRG.WS["Penta Thrust"] = "WS_PentaThrust"
DRG.WS["Vorpal Thrust"] = "WS_VorpalThrust"
DRG.WS["Skewer"] = "WS_Skewer"
DRG.WS["Wheeling Thrust"] = "WS_WheelingThrust"
DRG.WS["Impulse Drive"] = "WS_ImpulseDrive"

-- ----------------------------------------------------------------------------
-- DRG: WEAPONS
-- ----------------------------------------------------------------------------

DRG.Weapons = { Main="Stone-splitter", Sub="Axe Grip" }


-- ============================================================================
-- COR: CHARACTER-SPECIFIC EQUIPMENT / ACTION DATA
-- ============================================================================
-- Current job level: 50
-- This section is the authoritative home for COR-specific configuration.
-- Runtime equipment/action mappings must respect the current job level.
-- Future level-75 macro preparation may be documented here without becoming
-- executable runtime gear.

local COR = JOBS.COR

-- ----------------------------------------------------------------------------
-- COR: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------

COR.Sets.Idle = {
        Head="Comm. Tricorne", Neck="Fortitude Torque", Ear1="Brutal Earring", Ear2="Static Earring",
        Hands="Commodore Gants", Ring1="Rajas Ring", Ring2="Luzaf's Ring", Back="Ryl. Army Mantle",
        Waist="Commodore Belt", Legs="Comm. Trews", Feet="Comm. Bottes",
    }

COR.Sets.Resting = {
        Head="Comm. Tricorne", Neck="Fortitude Torque", Hands="Commodore Gants", Ring1="Rajas Ring", Ring2="Luzaf's Ring",
        Waist="Commodore Belt", Legs="Comm. Trews", Feet="Comm. Bottes",
    }

COR.Sets.Engaged = {
        Head="Walahra Turban", Neck="Fortitude Torque", Ear1="Brutal Earring", Ear2="Static Earring",
        Hands="Commodore Gants", Ring1="Rajas Ring", Ring2="Luzaf's Ring", Back="Ryl. Army Mantle",
        Waist="Commodore Belt", Legs="Comm. Trews", Feet="Comm. Bottes",
    }

-- ----------------------------------------------------------------------------
-- COR: WEAPONS
-- ----------------------------------------------------------------------------

COR.Weapons = { Range="Tartaglia", Ammo="Demon Arrow" }

-- ----------------------------------------------------------------------------
-- COR: JOB ABILITIES / MAGIC / WEAPON SKILLS / MACROS
-- ----------------------------------------------------------------------------
-- Dedicated mechanics and ownership audit remains to be completed here.
-- Keep all COR-specific additions inside this section.


-- ============================================================================
-- PUP: CHARACTER-SPECIFIC EQUIPMENT / ACTION DATA
-- ============================================================================
-- Current job level: 55
-- This section is the authoritative home for PUP-specific configuration.
-- Runtime equipment/action mappings must respect the current job level.
-- Future level-75 macro preparation may be documented here without becoming
-- executable runtime gear.

local PUP = JOBS.PUP

-- ----------------------------------------------------------------------------
-- PUP: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------

PUP.Sets.Idle = {
        Head="Pantin Taj", Neck="Fortitude Torque", Ear1="Suppanomimi", Ear2="Brutal Earring",
        Body="Pantin Tobe", Hands="Pantin Dastanas", Ring1="Rajas Ring", Ring2="Ulthalam's Ring",
        Back="Aesir Mantle", Waist="Charmer's Sash", Legs="Pantin Churidars", Feet="Pantin Babouches",
    }

PUP.Sets.Resting = {
        Head="Pantin Taj", Neck="Fortitude Torque", Body="Pantin Tobe", Hands="Pantin Dastanas",
        Ring1="Rajas Ring", Ring2="Ulthalam's Ring", Waist="Charmer's Sash", Legs="Pantin Churidars", Feet="Pantin Babouches",
    }

PUP.Sets.Engaged = {
        Head="Walahra Turban", Neck="Fortitude Torque", Ear1="Suppanomimi", Ear2="Brutal Earring",
        Body="Pantin Tobe", Hands="Pantin Dastanas", Ring1="Rajas Ring", Ring2="Ulthalam's Ring",
        Back="Aesir Mantle", Waist="Charmer's Sash", Legs="Pantin Churidars", Feet="Pantin Babouches",
    }

-- ----------------------------------------------------------------------------
-- PUP: WEAPONS
-- ----------------------------------------------------------------------------

PUP.Weapons = { Main="Avengers", Sub="Animator" }

-- ----------------------------------------------------------------------------
-- PUP: JOB ABILITIES / MAGIC / WEAPON SKILLS / MACROS
-- ----------------------------------------------------------------------------
-- Dedicated mechanics and ownership audit remains to be completed here.
-- Keep all PUP-specific additions inside this section.


-- ============================================================================
-- DNC: CHARACTER-SPECIFIC EQUIPMENT / ACTION DATA
-- ============================================================================
-- Current job level: 40
-- This section is the authoritative home for DNC-specific configuration.
-- Runtime equipment/action mappings must respect the current job level.
-- Future level-75 macro preparation may be documented here without becoming
-- executable runtime gear.

local DNC = JOBS.DNC

-- ----------------------------------------------------------------------------
-- DNC: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------

DNC.Sets.Idle = {
        Head="Etoile Tiara", Neck="Fortitude Torque", Ear1="Suppanomimi", Ear2="Brutal Earring",
        Body="Etoile Casaque", Hands="Etoile Bangles", Ring1="Rajas Ring", Ring2="Ulthalam's Ring",
        Back="Aesir Mantle", Waist="Swift Belt", Legs="Etoile Tights", Feet="Etoile Toe Shoes",
    }

DNC.Sets.Resting = {
        Head="Etoile Tiara", Neck="Fortitude Torque", Body="Etoile Casaque", Hands="Etoile Bangles",
        Ring1="Rajas Ring", Ring2="Ulthalam's Ring", Legs="Etoile Tights", Feet="Etoile Toe Shoes",
    }

DNC.Sets.Engaged = {
        Head="Walahra Turban", Neck="Fortitude Torque", Ear1="Suppanomimi", Ear2="Brutal Earring",
        Body="Etoile Casaque", Hands="Etoile Bangles", Ring1="Rajas Ring", Ring2="Ulthalam's Ring",
        Back="Aesir Mantle", Waist="Swift Belt", Legs="Etoile Tights", Feet="Etoile Toe Shoes",
    }

-- ----------------------------------------------------------------------------
-- DNC: WEAPONS
-- ----------------------------------------------------------------------------

DNC.Weapons = { Main="Blau Dolch", DWMain="Blau Dolch", DWSub="Chiroptera Dagger" }

-- ----------------------------------------------------------------------------
-- DNC: JOB ABILITIES / MAGIC / WEAPON SKILLS / MACROS
-- ----------------------------------------------------------------------------
-- Dedicated mechanics and ownership audit remains to be completed here.
-- Keep all DNC-specific additions inside this section.


-- ============================================================================
-- SCH: CHARACTER-SPECIFIC EQUIPMENT / ACTION DATA
-- ============================================================================
-- Current job level: 40
-- This section is the authoritative home for SCH-specific configuration.
-- Runtime equipment/action mappings must respect the current job level.
-- Future level-75 macro preparation may be documented here without becoming
-- executable runtime gear.

local SCH = JOBS.SCH

-- ----------------------------------------------------------------------------
-- SCH: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------

SCH.Sets.Idle = {
        Head="Argute M.board", Neck="Elementium Torque", Ear1="Loquac. Earring", Ear2="Magnetic Earring",
        Body="Argute Gown", Hands="Argute Bracers", Ring1="Tamas Ring", Ring2="Aqua Ring",
        Back="Grapevine Cape", Waist="Salire Belt", Legs="Argute Pants", Feet="Argute Loafers",
    }

SCH.Sets.Resting = {
        Head="Argute M.board", Neck="Elementium Torque", Body="Argute Gown", Hands="Argute Bracers",
        Ring1="Tamas Ring", Ring2="Aqua Ring", Waist="Salire Belt", Legs="Argute Pants", Feet="Argute Loafers",
    }

SCH.Sets.Engaged = {
        Head="Walahra Turban", Neck="Fortitude Torque", Ear1="Loquac. Earring", Ear2="Brutal Earring",
        Body="Argute Gown", Hands="Argute Bracers", Ring1="Tamas Ring", Ring2="Aqua Ring",
        Back="Grapevine Cape", Waist="Salire Belt", Legs="Argute Pants", Feet="Argute Loafers",
    }

-- ----------------------------------------------------------------------------
-- SCH: WEAPONS
-- ----------------------------------------------------------------------------

SCH.Weapons = { Main="Kirin's Pole" }

-- ----------------------------------------------------------------------------
-- SCH: JOB ABILITIES / MAGIC / WEAPON SKILLS / MACROS
-- ----------------------------------------------------------------------------
-- Dedicated mechanics and ownership audit remains to be completed here.
-- Keep all SCH-specific additions inside this section.


-- ============================================================================
-- GEO: CHARACTER-SPECIFIC EQUIPMENT / ACTION DATA
-- ============================================================================
-- Current job level: 51
-- This section is the authoritative home for GEO-specific configuration.
-- Runtime equipment/action mappings must respect the current job level.
-- Future level-75 macro preparation may be documented here without becoming
-- executable runtime gear.

local GEO = JOBS.GEO

-- ----------------------------------------------------------------------------
-- GEO: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------

GEO.Sets.Idle = {
        Head="Bagua Galero", Neck="Gnole Torque", Ear1="Loquac. Earring", Ear2="Magnetic Earring",
        Hands="Bagua Mitaines", Ring1="Tamas Ring", Ring2="Aqua Ring", Back="Grapevine Cape",
        Waist="Salire Belt", Legs="Bagua Pants", Feet="Bagua Sandals",
    }

GEO.Sets.Resting = {
        Head="Bagua Galero", Neck="Gnole Torque", Hands="Bagua Mitaines", Ring1="Tamas Ring", Ring2="Aqua Ring",
        Waist="Salire Belt", Legs="Bagua Pants", Feet="Bagua Sandals",
    }

GEO.Sets.Engaged = {
        Head="Walahra Turban", Neck="Fortitude Torque", Ear1="Brutal Earring", Ear2="Suppanomimi",
        Hands="Bagua Mitaines", Ring1="Rajas Ring", Ring2="Tamas Ring", Back="Grapevine Cape",
        Waist="Swift Belt", Legs="Bagua Pants", Feet="Bagua Sandals",
    }

-- ----------------------------------------------------------------------------
-- GEO: WEAPONS
-- ----------------------------------------------------------------------------

GEO.Weapons = { Main="Gridarvor" }

-- ----------------------------------------------------------------------------
-- GEO: JOB ABILITIES / MAGIC / WEAPON SKILLS / MACROS
-- ----------------------------------------------------------------------------
-- Dedicated mechanics and ownership audit remains to be completed here.
-- Keep all GEO-specific additions inside this section.


-- ============================================================================
-- RUN: CHARACTER-SPECIFIC EQUIPMENT / ACTION DATA
-- ============================================================================
-- Current job level: 51
-- This section is the authoritative home for RUN-specific configuration.
-- Runtime equipment/action mappings must respect the current job level.
-- Future level-75 macro preparation may be documented here without becoming
-- executable runtime gear.

local RUN = JOBS.RUN

-- ----------------------------------------------------------------------------
-- RUN: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------

RUN.Sets.Idle = {
        Head="Futhark Bandeau", Neck="Fortitude Torque", Ear1="Brutal Earring", Ear2="Static Earring",
        Body="Futhark Coat", Hands="Futhark Mitons", Ring1="Rajas Ring", Ring2="Sattva Ring",
        Back="Ryl. Army Mantle", Waist="Swift Belt", Legs="Runeist Trousers", Feet="Runeist Bottes",
    }

RUN.Sets.Resting = {
        Head="Futhark Bandeau", Neck="Fortitude Torque", Body="Futhark Coat", Hands="Futhark Mitons",
        Ring1="Rajas Ring", Ring2="Sattva Ring", Legs="Runeist Trousers", Feet="Runeist Bottes",
    }

RUN.Sets.Engaged = {
        Head="Walahra Turban", Neck="Fortitude Torque", Ear1="Brutal Earring", Ear2="Static Earring",
        Body="Futhark Coat", Hands="Futhark Mitons", Ring1="Rajas Ring", Ring2="Ulthalam's Ring",
        Back="Ryl. Army Mantle", Waist="Swift Belt", Legs="Runeist Trousers", Feet="Runeist Bottes",
    }

-- ----------------------------------------------------------------------------
-- RUN: WEAPONS
-- ----------------------------------------------------------------------------

RUN.Weapons = { Main="Sowilo Claymore", Shield="Genbu's Shield" }

-- ----------------------------------------------------------------------------
-- RUN: JOB ABILITIES / MAGIC / WEAPON SKILLS / MACROS
-- ----------------------------------------------------------------------------
-- Dedicated mechanics and ownership audit remains to be completed here.
-- Keep all RUN-specific additions inside this section.

-- RDM: CHARACTER-SPECIFIC EQUIPMENT
-- ============================================================================

local RDM = JOBS.RDM

RDM.Sets.Idle = {
    Head  = "Dls. Chapeau +1",
    Neck  = "Elementium Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Wlk. Tabard +1",
    Hands = "Wlk. Gloves +1",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Merciful Cape",
    Waist = "Hierarch Belt",
    Legs  = "Blood Cuisses",
    Feet  = "Duelist's Boots",
}

RDM.Sets.Resting = {
    Head  = "Goliard Chapeau",
    Neck  = "Gnole Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Wlk. Tabard +1",
    Ring2 = "Balrahn's Ring",
    Waist = "Hierarch Belt",
    Legs  = "Wlk. Tights +1",
    Feet  = "Wlk. Boots +1",
    -- Hands = "",
    -- Ring1 = "",
    -- Back = "",
}

RDM.Sets.Engaged = {
    Head  = "Walahra Turban",
    Neck  = "Ancient Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Chasuble +1",
    Hands = "Wlk. Gloves +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Aesir Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Wise Braconi +1",
    Feet  = "Dusk Ledelsens +1",
}

-- Fast Cast + recast-oriented Haste set.
-- Priority here is Fast Cast > Haste because this set is the common
-- fast-cast/recast tool rather than the duration-specialist midcast set.
RDM.Sets.FastCastHaste = {
    Head  = "Wlk. Chapeau +1",
    Ear1  = "Loquac. Earring",
    Body  = "Duelist's Tabard",
    Waist = "Ninurta's Sash",
    Feet  = "Dusk Ledelsens +1",
    -- Back = "",
    -- Neck = "",
    -- Ear2 = "",
    -- Hands = "",
    -- Ring1 = "",
    -- Ring2 = "",
    -- Legs = "",
}

-- Enhancing Magic Duration set.  Used only for spells whose effect does not
-- benefit from Enhancing Magic skill in this profile.  Priority:
-- Enhancing Magic Duration > Haste > Fast Cast.
-- Grapevine Cape provides CatsEyeXI Enhancing Magic Duration +3%.
RDM.Sets.EnhancingMagicDuration = {
    Head  = "Wlk. Chapeau +1",
    Ear1  = "Loquac. Earring",
    Body  = "Duelist's Tabard",
    Back  = "Grapevine Cape",
    Waist = "Ninurta's Sash",
    Feet  = "Dusk Ledelsens +1",
    -- Neck = "",
    -- Ear2 = "",
    -- Hands = "",
    -- Ring1 = "",
    -- Ring2 = "",
    -- Legs = "",
}

RDM.Sets.Precast = RDM.Sets.FastCastHaste

RDM.Sets.Cure = {
    Head  = "Goliard Chapeau",
    Neck  = "Fylgja Torque +1",
    Ear1  = "Loquac. Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Duelist's Tabard",
    Hands = "Yigit Gages",
    Ring1 = "Aqua Ring",
    Ring2 = "Aqua Ring",
    Back  = "Dew Silk Cape +1",
    Waist = "Hierarch Belt",
    Legs  = "Wlk. Tights +1",
    Feet  = "Ogre Ledelsens +1",
}

RDM.Sets.EnhancingSkill = {
    Head  = "Zenith Crown +1",
    Neck  = "Enhancing Torque",
    Ear1  = "Augment. Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Glamor Jupon",
    Hands = "Dls. Gloves +1",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Merciful Cape",
    Waist = "Ninurta's Sash",
    Legs  = "Wlk. Tights +1",
    Feet  = "Duelist's Boots",
}

RDM.Sets.EnfeeblingSkill = {
    Head  = "Dls. Chapeau +1",
    Neck  = "Enfeebling Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Wlk. Tabard +1",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Dew Silk Cape +1",
    Waist = "Salire Belt",
    Legs  = "Errant Slops",
    Feet  = "Yigit Crackows",
}

RDM.Sets.ElementalSkill = {
    Head  = "Wlk. Chapeau +1",
    Neck  = "Aesir Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Glamor Jupon",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Merciful Cape",
    Waist = "Salire Belt",
    Legs  = "Duelist's Tights",
    Feet  = "Wlk. Boots +1",
}

RDM.Sets.DarkSkill = {
    Neck  = "Aesir Torque",
}

RDM.Sets.Stoneskin = {
    Head  = "Yigit Turban",
    Neck  = "Stone Gorget",
    Body  = "Chasuble +1",
    Hands = "Yigit Gages",
    Ring1 = "Aqua Ring",
    Ring2 = "Aqua Ring",
    Back  = "Grapevine Cape",
    Waist = "Pythia Sash",
    Legs  = "Wlk. Tights +1",
    Feet  = "Ogre Ledelsens +1",
}

RDM.Sets.Phalanx = {
    Head  = "Wlk. Chapeau +1",
    Neck  = "Enhancing Torque",
    Ear1  = "Augment. Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Glamor Jupon",
    Hands = "Dls. Gloves +1",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Merciful Cape",
    Waist = "Salire Belt",
    Legs  = "Wlk. Tights +1",
    Feet  = "Duelist's Boots",
}

RDM.Sets.EnfeeblingMND = {
    Head  = "Dls. Chapeau +1",
    Neck  = "Enfeebling Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Chasuble +1",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Dew Silk Cape +1",
    Waist = "Salire Belt",
    Legs  = "Errant Slops",
    Feet  = "Yigit Crackows",
}

RDM.Sets.ElementalDamage = {
    Head  = "Wlk. Chapeau +1",
    Neck  = "Lmg. Medallion +1",
    Ear1  = "Moldavite Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Errant Hpl.",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Grapevine Cape",
    Waist = "Salire Belt",
    Legs  = "Errant Slops",
    Feet  = "Duelist's Boots",
}

RDM.Sets.PDT = {
    Neck  = "Fortitude Torque",
    Waist = "Ryl.Kgt. Belt",
}

-- ============================================================================
-- RDM WEAPONSKILL SETS
-- ============================================================================
-- Finley_RDM.lua is the blueprint for RDM WS modifier routing.
-- Each set is explicitly editable by slot; empty slots are commented out so
-- commenting one item cannot accidentally force an empty-slot unequip.

RDM.Sets["WS-Physical-STR"] = {
    Head  = "Pln. Qalansuwa",
    Neck  = "Fotia Gorget",
    Ear1  = "Hollow Earring",
    Ear2  = "Brutal Earring",
    Body  = "Chasuble +1",
    Hands = "Wlk. Gloves +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Wise Braconi +1",
    Feet  = "Ogre Ledelsens +1",
}

RDM.Sets["WS-Physical-DEX"] = {
    Head  = "Empress Hairpin",
    Neck  = "Fotia Gorget",
    Ear1  = "Hollow Earring",
    Ear2  = "Brutal Earring",
    Body  = "Chasuble +1",
    Hands = "Wlk. Gloves +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Aesir Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Wise Braconi +1",
    Feet  = "Bounding Boots",
}

RDM.Sets["WS-Physical-STR-DEX"] = {
    Head  = "Pln. Qalansuwa",
    Neck  = "Fotia Gorget",
    Ear1  = "Hollow Earring",
    Ear2  = "Brutal Earring",
    Body  = "Chasuble +1",
    Hands = "Wlk. Gloves +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Wise Braconi +1",
    Feet  = "Ogre Ledelsens +1",
}

RDM.Sets["WS-Physical-STR-MND"] = {
    Head  = "Goliard Chapeau",
    Neck  = "Fotia Gorget",
    Ear1  = "Hollow Earring",
    Ear2  = "Brutal Earring",
    Body  = "Chasuble +1",
    Hands = "Wlk. Gloves +1",
    Ring1 = "Aqua Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Salire Belt",
    Legs  = "Wise Braconi +1",
    Feet  = "Ogre Ledelsens +1",
}

RDM.Sets["WS-Physical-MND"] = {
    Head  = "Goliard Chapeau",
    Neck  = "Fotia Gorget",
    Ear1  = "Hollow Earring",
    Ear2  = "Brutal Earring",
    Body  = "Chasuble +1",
    Hands = "Wlk. Gloves +1",
    Ring1 = "Aqua Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Salire Belt",
    Legs  = "Wise Braconi +1",
    Feet  = "Ogre Ledelsens +1",
}

RDM.Sets["WS-Physical-MND-STR"] = {
    Head  = "Goliard Chapeau",
    Neck  = "Fotia Gorget",
    Ear1  = "Hollow Earring",
    Ear2  = "Brutal Earring",
    Body  = "Chasuble +1",
    Hands = "Wlk. Gloves +1",
    Ring1 = "Aqua Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Salire Belt",
    Legs  = "Wise Braconi +1",
    Feet  = "Ogre Ledelsens +1",
}

RDM.Sets["WS-Magical-MND"] = {
    Head  = "Yigit Turban",
    Neck  = "Gnole Torque",
    Ear1  = "Moldavite Earring",
    Ear2  = "Hollow Earring",
    Body  = "Chasuble +1",
    Hands = "Yigit Gages",
    Ring1 = "Aqua Ring",
    Ring2 = "Aqua Ring",
    Back  = "Dew Silk Cape +1",
    Waist = "Salire Belt",
    Legs  = "Errant Slops",
    Feet  = "Ogre Ledelsens +1",
}

RDM.Sets["WS-Magical-STR-INT"] = {
    Head  = "Wlk. Chapeau +1",
    Neck  = "Fotia Gorget",
    Ear1  = "Moldavite Earring",
    Ear2  = "Hollow Earring",
    Body  = "Chasuble +1",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Grapevine Cape",
    Waist = "Salire Belt",
    Legs  = "Wise Braconi +1",
    Feet  = "Duelist's Boots",
}

RDM.Sets["WS-Magical-INT-STR"] = {
    Head  = "Wlk. Chapeau +1",
    Neck  = "Elementium Torque",
    Ear1  = "Moldavite Earring",
    Ear2  = "Hollow Earring",
    Body  = "Errant Hpl.",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Grapevine Cape",
    Waist = "Salire Belt",
    Legs  = "Errant Slops",
    Feet  = "Duelist's Boots",
}

RDM.Sets["WS-Magical-INT-DEX"] = {
    Head  = "Wlk. Chapeau +1",
    Neck  = "Elementium Torque",
    Ear1  = "Moldavite Earring",
    Ear2  = "Hollow Earring",
    Body  = "Errant Hpl.",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Grapevine Cape",
    Waist = "Salire Belt",
    Legs  = "Duelist's Tights",
    Feet  = "Duelist's Boots",
}

RDM.Sets["WS-Magical-STR-MND"] = {
    Head  = "Wlk. Chapeau +1",
    Neck  = "Fotia Gorget",
    Ear1  = "Moldavite Earring",
    Ear2  = "Hollow Earring",
    Body  = "Chasuble +1",
    Hands = "Yigit Gages",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Dew Silk Cape +1",
    Waist = "Salire Belt",
    Legs  = "Wlk. Tights +1",
    Feet  = "Duelist's Boots",
}

RDM.Sets["WS-Magical-MND-STR"] = {
    Head  = "Wlk. Chapeau +1",
    Neck  = "Fotia Gorget",
    Ear1  = "Moldavite Earring",
    Ear2  = "Hollow Earring",
    Body  = "Chasuble +1",
    Hands = "Yigit Gages",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Dew Silk Cape +1",
    Waist = "Salire Belt",
    Legs  = "Wlk. Tights +1",
    Feet  = "Duelist's Boots",
}

RDM.Sets["WS-Magical-INT"] = {
    Head  = "Wlk. Chapeau +1",
    Neck  = "Elementium Torque",
    Ear1  = "Moldavite Earring",
    Ear2  = "Hollow Earring",
    Body  = "Errant Hpl.",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Grapevine Cape",
    Waist = "Salire Belt",
    Legs  = "Errant Slops",
    Feet  = "Duelist's Boots",
}

RDM.Sets["WS-Magical-INT-MND"] = {
    Head  = "Wlk. Chapeau +1",
    Neck  = "Fotia Gorget",
    Ear1  = "Moldavite Earring",
    Ear2  = "Hollow Earring",
    Body  = "Chasuble +1",
    Hands = "Yigit Gages",
    Ring1 = "Aqua Ring",
    Ring2 = "Aqua Ring",
    Back  = "Dew Silk Cape +1",
    Waist = "Salire Belt",
    Legs  = "Wlk. Tights +1",
    Feet  = "Duelist's Boots",
}

RDM.Sets.WS_Default = RDM.Sets["WS-Physical-STR-DEX"]

RDM.Weapons = {
    Main   = "Octave Club",
    Sub    = "Genbu's Shield",
    DWMain = "Egeking",
    DWSub  = "Octave Club",
    Shield = "Genbu's Shield",
}

-- RDM owns this WS map.  Other jobs may legitimately use the same WS name but
-- must define their own mapping and sets inside their own job section.
RDM.WS = {
    ["Wasp Sting"]       = "WS-Physical-DEX",
    ["Viper Bite"]       = "WS-Physical-DEX",
    ["Evisceration"]     = "WS-Physical-DEX",
    ["Chant du Cygne"]   = "WS-Physical-DEX",
    ["Flat Blade"]       = "WS-Physical-STR",
    ["Circle Blade"]     = "WS-Physical-STR",
    ["Vorpal Blade"]     = "WS-Physical-STR",
    ["Requiescat"]       = "WS-Physical-MND",
    ["Realmrazer"]       = "WS-Physical-MND",
    ["Fast Blade"]       = "WS-Physical-STR-DEX",
    ["Swift Blade"]      = "WS-Physical-STR-MND",
    ["Savage Blade"]     = "WS-Physical-STR-MND",
    ["Knights of Round"] = "WS-Physical-STR-MND",
    ["Death Blossom"]    = "WS-Physical-MND-STR",
    ["Energy Steal"]     = "WS-Magical-MND",
    ["Energy Drain"]     = "WS-Magical-MND",
    ["Shining Blade"]    = "WS-Magical-MND-STR",
    ["Seraph Blade"]     = "WS-Magical-MND-STR",
    ["Burning Blade"]    = "WS-Magical-STR-INT",
    ["Red Lotus Blade"]  = "WS-Magical-STR-INT",
    ["Sanguine Blade"]   = "WS-Magical-INT-MND",
    ["Gust Slash"]       = "WS-Magical-INT-MND",
    ["Cyclone"]          = "WS-Magical-INT-DEX",
    ["Aeolian Edge"]     = "WS-Magical-INT-DEX",
}

RDM.MA = {
    ["Stoneskin"] = "Stoneskin",
    ["Phalanx"] = "Phalanx",
    ["Blink"] = "EnhancingSkill",
    ["Aquaveil"] = "EnhancingSkill",

    -- These spell effects do not gain potency from Enhancing Magic skill in
    -- this profile, so explicit duration gear wins, followed by Haste, then
    -- Fast Cast.
    ["Protect"] = "EnhancingMagicDuration",
    ["Protect II"] = "EnhancingMagicDuration",
    ["Protect III"] = "EnhancingMagicDuration",
    ["Protect IV"] = "EnhancingMagicDuration",
    ["Protect V"] = "EnhancingMagicDuration",
    ["Shell"] = "EnhancingMagicDuration",
    ["Shell II"] = "EnhancingMagicDuration",
    ["Shell III"] = "EnhancingMagicDuration",
    ["Shell IV"] = "EnhancingMagicDuration",
    ["Shell V"] = "EnhancingMagicDuration",
    ["Haste"] = "EnhancingMagicDuration",
    ["Regen"] = "EnhancingMagicDuration",
    ["Refresh"] = "EnhancingMagicDuration",

    ["Cure"] = "Cure",
    ["Cure II"] = "Cure",
    ["Cure III"] = "Cure",
    ["Cure IV"] = "Cure",

    ["Paralyze"] = "EnfeeblingMND",
    ["Paralyze II"] = "EnfeeblingMND",
    ["Slow"] = "EnfeeblingMND",
    ["Slow II"] = "EnfeeblingMND",
    ["Silence"] = "EnfeeblingSkill",
    ["Blind"] = "EnfeeblingSkill",
    ["Gravity"] = "EnfeeblingSkill",
    ["Gravity II"] = "EnfeeblingSkill",
    ["Sleep"] = "EnfeeblingSkill",
    ["Sleep II"] = "EnfeeblingSkill",
    ["Dispel"] = "EnfeeblingSkill",
    ["Distract"] = "EnfeeblingSkill",

    -- Dia/Bio do not require Enfeebling/Dark skill for this profile; use the
    -- common Fast Cast + Haste set instead.
    ["Dia"] = "FastCastHaste",
    ["Dia II"] = "FastCastHaste",
    ["Dia III"] = "FastCastHaste",
    ["Bio"] = "FastCastHaste",
    ["Bio II"] = "FastCastHaste",
    ["Bio III"] = "FastCastHaste",

    ["Fire"] = "ElementalDamage",
    ["Fire II"] = "ElementalDamage",
    ["Fire III"] = "ElementalDamage",
    ["Blizzard"] = "ElementalDamage",
    ["Blizzard II"] = "ElementalDamage",
    ["Blizzard III"] = "ElementalDamage",
    ["Thunder"] = "ElementalDamage",
    ["Thunder II"] = "ElementalDamage",
    ["Thunder III"] = "ElementalDamage",
    ["Aero"] = "ElementalDamage",
    ["Aero II"] = "ElementalDamage",
    ["Aero III"] = "ElementalDamage",
    ["Stone"] = "ElementalDamage",
    ["Stone II"] = "ElementalDamage",
    ["Stone III"] = "ElementalDamage",
    ["Water"] = "ElementalDamage",
    ["Water II"] = "ElementalDamage",
    ["Water III"] = "ElementalDamage",
}

-- ============================================================================
-- BLM: CHARACTER-SPECIFIC EQUIPMENT
-- ============================================================================
-- Current character level: 75
--
-- This is a self-contained BLM section modeled on the RDM organization.
-- Runtime gear below is limited to equipment the current level-75 BLM can
-- actually equip.  Future level-75 gear is documented separately and does not
-- enter current runtime mappings.
--
-- OWNERSHIP / PROGRESSION NOTES
--   * Full base Wizard's Attire is owned.
--   * Current level-75 runtime uses the manually tested Sorcerer's Petas. / Tonban /
--     Sabots combination, Wizard's Coat, and Yigit Gages where specified below.
--   * Charmer's Sash is owned and level-appropriate at BLM75.
--   * Perdu Sickle + Axe Grip is the current intentionally experimental weapon pair
--     while leveling with Trusts; do not replace it with a generic staff policy.
--   * Kirin's Pole and Norn's Grip remain owned level-75 weapon candidates.
--
-- The Wizard pieces are used intentionally: Petasos supplies INT/MP, Coat supplies
-- Enfeebling Magic Skill, Gloves supply Elemental Magic Skill, and Tonban supplies
-- Dark Magic Skill.  Empty slots stay commented rather than being filled with
-- unverified equipment merely to make a table look complete.
-- ============================================================================

local BLM = JOBS.BLM

-- ----------------------------------------------------------------------------
-- BLM: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------

BLM.Sets.Idle = {
    Head  = "Sorcerer\'s Petas.",
    Neck  = "Elementium Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Wizard\'s Coat",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn\'s Ring",
    Back  = "Merciful Cape",
    Waist = "Charmer\'s Sash",
    Legs  = "Sorcerer\'s Tonban",
    Feet  = "Sorcerer\'s Sabots",
}

BLM.Sets.Resting = {
    Head  = "Yigit Turban",
    Neck  = "Elementium Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Moldavite Earring",
    Body  = "Errant Hpl.",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn\'s Ring",
    Back  = "Merciful Cape",
    Waist = "Charmer\'s Sash",
    Legs  = "Sorcerer\'s Tonban",
    Feet  = "Sorcerer\'s Sabots",
}

-- BLM does not need a melee-oriented engaged set for the current design.
-- Keep the state explicit so the shared state machine remains predictable.
BLM.Sets.Engaged = {
    Head  = "Walahra Turban",
    Neck  = "Ancient Torque",
    Ear1  = "Hollow Earring",
    Ear2  = "Brutal Earring",
    Body  = "Wizard\'s Coat",
    Hands = "Yigit Gages",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars\'s Ring",
    Back  = "Aesir Mantle",
    Waist = "Ninurta\'s Sash",
    Legs  = "Sorcerer\'s Tonban",
    Feet  = "Sorcerer\'s Sabots",
}

-- ----------------------------------------------------------------------------
-- BLM: FAST CAST / PRECAST
-- ----------------------------------------------------------------------------

BLM.Sets.FastCast = {
    Head  = "Wizard's Petasos",
    Neck  = "Elementium Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Moldavite Earring",
    Body  = "Wizard's Coat",
    Hands = "Wizard's Gloves",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Legs  = "Wizard's Tonban",
    Feet  = "Wizard's Sabots",
}

BLM.Sets.Precast = BLM.Sets.FastCast

-- ----------------------------------------------------------------------------
-- BLM: HEALING / ENHANCING MAGIC
-- ----------------------------------------------------------------------------
-- BLM may access Cure through a WHM support job.  The set remains conservative
-- because no dedicated BLM cure gear is currently documented/required.

BLM.Sets.Cure = BLM.Sets.FastCast
BLM.Sets.HealingSkill = BLM.Sets.FastCast

BLM.Sets.EnhancingSkill = {
    Head  = "Wizard's Petasos",
    Neck  = "Elementium Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Moldavite Earring",
    Body  = "Wizard's Coat",
    Hands = "Wizard's Gloves",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Legs  = "Wizard's Tonban",
    Feet  = "Wizard's Sabots",
}

-- ----------------------------------------------------------------------------
-- BLM: ENFEEBLING MAGIC
-- ----------------------------------------------------------------------------
-- Wizard's Coat provides Enfeebling Magic Skill +10 at the current level.

BLM.Sets.EnfeeblingSkill = {
    Head  = "Wizard's Petasos",
    Neck  = "Elementium Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Moldavite Earring",
    Body  = "Wizard's Coat",
    Hands = "Wizard's Gloves",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Legs  = "Wizard's Tonban",
    Feet  = "Wizard's Sabots",
}

-- ----------------------------------------------------------------------------
-- BLM: ELEMENTAL MAGIC
-- ----------------------------------------------------------------------------
-- Wizard's Gloves provide Elemental Magic Skill +15.  Moldavite Earring adds
-- Magic Attack Bonus +5 for damage sets.

BLM.Sets.ElementalSkill = {
    Head  = "Wizard's Petasos",
    Neck  = "Elementium Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Moldavite Earring",
    Body  = "Wizard's Coat",
    Hands = "Wizard's Gloves",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Legs  = "Wizard's Tonban",
    Feet  = "Wizard's Sabots",
}

BLM.Sets.ElementalDamage = {
    Head  = "Hecate's Crown",
    Neck  = "Lmg. Medallion +1",
    Ear1  = "Moldavite Earring",
    Ear2  = "Static Earring",
    Body  = "Errant Hpl.",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Merciful Cape",
    Waist = "Salire Belt",
    Legs  = "Sorcerer's Tonban",
    Feet  = "Sorcerer's Sabots",
}

-- ----------------------------------------------------------------------------
-- BLM: DARK MAGIC
-- ----------------------------------------------------------------------------
-- Wizard's Tonban supplies Dark Magic Skill +15.

BLM.Sets.DarkSkill = {
    Head  = "Wizard's Petasos",
    Neck  = "Elementium Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Moldavite Earring",
    Body  = "Wizard's Coat",
    Hands = "Wizard's Gloves",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Legs  = "Wizard's Tonban",
    Feet  = "Wizard's Sabots",
}

BLM.Sets.DarkDamage = {
    Head  = "Wizard's Petasos",
    Neck  = "Elementium Torque",
    Ear1  = "Moldavite Earring",
    Ear2  = "Loquac. Earring",
    Body  = "Wizard's Coat",
    Hands = "Wizard's Gloves",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    -- Back = "",
    -- Waist = "",
    Legs  = "Wizard's Tonban",
    Feet  = "Wizard's Sabots",
}

-- ----------------------------------------------------------------------------
-- BLM: JOB ABILITIES
-- ----------------------------------------------------------------------------

BLM.Sets.JA_Default = BLM.Sets.FastCast
BLM.Sets.JA_Offensive = BLM.Sets.ElementalDamage

BLM.JA = {
    ["Manafont"]      = "JA_Offensive",
    ["Elemental Seal"] = "ElementalSkill",
}

-- ----------------------------------------------------------------------------
-- BLM: MANUAL DEFENSE MODES
-- ----------------------------------------------------------------------------
-- These are level-safe baseline sets, not claimed to be specialized endgame
-- PDT/MDT builds.  The manual !pageup / !pagedown controls therefore still work
-- without introducing level-75-only equipment to the active level-75 profile.

BLM.Sets.PDT = {
    Head  = "Wizard's Petasos",
    Neck  = "Elementium Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Moldavite Earring",
    Body  = "Wizard's Coat",
    Hands = "Wizard's Gloves",
    Ring1 = "Aqua Ring",
    Ring2 = "Tamas Ring",
    Legs  = "Wizard's Tonban",
    Feet  = "Wizard's Sabots",
}

BLM.Sets.MDT = {
    Head  = "Wizard's Petasos",
    Neck  = "Elementium Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Moldavite Earring",
    Body  = "Wizard's Coat",
    Hands = "Wizard's Gloves",
    Ring1 = "Aqua Ring",
    Ring2 = "Aqua Ring",
    Legs  = "Wizard's Tonban",
    Feet  = "Wizard's Sabots",
}

-- ----------------------------------------------------------------------------
-- BLM: WEAPONSKILLS
-- ----------------------------------------------------------------------------
-- BLM's relevant current-era staff WS are kept in BLM's own map.  Heavy Swing
-- is physical; Rock Crusher, Starburst, and Sunburst are magical staff WS.

BLM.Sets.WS_SpiritTaker = {
    Head  = "Zenith Crown +1",
    Neck  = "Ancient Torque",
    Ear1  = "Static Earring",
    Ear2  = "Brutal Earring",
    Body  = "Seer\'s Tunic",
    Hands = "Yigit Gages",
    Ring1 = "Rajas Ring",
    Ring2 = "Tamas Ring",
    Back  = "Stormlord Shawl",
    Waist = "Charmer\'s Sash",
    Legs  = "Sorcerer\'s Tonban",
    Feet  = "Errant Pigaches",
}

BLM.Sets.WS_Default = BLM.Sets.ElementalDamage
BLM.Sets.WS_HeavySwing = {
    Head  = "Wizard's Petasos",
    Neck  = "Elementium Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Moldavite Earring",
    Body  = "Wizard's Coat",
    Hands = "Wizard's Gloves",
    Ring1 = "Rajas Ring",
    Ring2 = "Tamas Ring",
    -- Back = "",
    -- Waist = "",
    Legs  = "Wizard's Tonban",
    Feet  = "Wizard's Sabots",
}

BLM.WS = {
    ["Heavy Swing"] = "WS_HeavySwing",
    ["Full Swing"] = "WS_HeavySwing",
    ["Spirit Taker"] = "WS_SpiritTaker",
    ["Rock Crusher"] = "ElementalDamage",
    ["Starburst"] = "ElementalDamage",
    ["Sunburst"] = "ElementalDamage",
}

-- ----------------------------------------------------------------------------
-- BLM: MAGIC ACTION MAP
-- ----------------------------------------------------------------------------
-- Current runtime mappings are intentionally conservative.  Macro bindings may
-- include future level-75 actions, but runtime gear selection must remain level-safe.

BLM.MA = {
    -- Enhancing Magic
    ["Blaze Spikes"] = "EnhancingSkill",
    ["Ice Spikes"] = "EnhancingSkill",
    ["Shock Spikes"] = "EnhancingSkill",
    ["Blink"] = "EnhancingSkill",
    ["Stoneskin"] = "EnhancingSkill",

    -- Healing Magic: explicit spell names only.  Do not use a wildcard such as
    -- "Cur*" because target/action names can contain the same text (e.g. Curilla).
    ["Cure"] = "Cure",
    ["Cure II"] = "Cure",
    ["Cure III"] = "Cure",
    ["Cure IV"] = "Cure",
    ["Curaga"] = "Cure",
    ["Curaga II"] = "Cure",

    -- Enfeebling Magic
    ["Poison"] = "EnfeeblingSkill",
    ["Blind"] = "EnfeeblingSkill",
    ["Bind"] = "EnfeeblingSkill",
    ["Rasp"] = "EnfeeblingSkill",
    ["Sleep"] = "EnfeeblingSkill",
    ["Choke"] = "EnfeeblingSkill",
    ["Frost"] = "EnfeeblingSkill",
    ["Burn"] = "EnfeeblingSkill",
    ["Poisonga"] = "EnfeeblingSkill",
    ["Drown"] = "EnfeeblingSkill",
    ["Sleepga"] = "EnfeeblingSkill",
    ["Sleep II"] = "EnfeeblingSkill",
    ["Poison II"] = "EnfeeblingSkill",
    ["Sleepga II"] = "EnfeeblingSkill",

    -- Elemental Magic
    ["Stone"] = "ElementalDamage",
    ["Water"] = "ElementalDamage",
    ["Aero"] = "ElementalDamage",
    ["Fire"] = "ElementalDamage",
    ["Blizzard"] = "ElementalDamage",
    ["Thunder"] = "ElementalDamage",
    ["Stonega"] = "ElementalDamage",
    ["Waterga"] = "ElementalDamage",
    ["Aeroga"] = "ElementalDamage",
    ["Firaga"] = "ElementalDamage",
    ["Blizzaga"] = "ElementalDamage",
    ["Thundaga"] = "ElementalDamage",
    ["Stone II"] = "ElementalDamage",
    ["Water II"] = "ElementalDamage",
    ["Aero II"] = "ElementalDamage",
    ["Fire II"] = "ElementalDamage",
    ["Blizzard II"] = "ElementalDamage",
    ["Thunder II"] = "ElementalDamage",
    ["Stonega II"] = "ElementalDamage",
    ["Waterga II"] = "ElementalDamage",
    ["Aeroga II"] = "ElementalDamage",
    ["Freeze"] = "ElementalDamage",
    ["Stone III"] = "ElementalDamage",
    ["Tornado"] = "ElementalDamage",
    ["Firaga II"] = "ElementalDamage",
    ["Quake"] = "ElementalDamage",
    ["Water III"] = "ElementalDamage",
    ["Burst"] = "ElementalDamage",
    ["Blizzaga II"] = "ElementalDamage",
    ["Flood"] = "ElementalDamage",
    ["Aero III"] = "ElementalDamage",
    ["Flare"] = "ElementalDamage",

    -- Dark Magic
    ["Bio"] = "DarkDamage",
    ["Drain"] = "DarkDamage",
    ["Aspir"] = "DarkDamage",
    ["Bio II"] = "DarkDamage",
    ["Stun"] = "DarkDamage",
    ["Tractor"] = "DarkDamage",

    -- Travel / utility magic
    ["Warp"] = "FastCast",
    ["Warp II"] = "FastCast",
    ["Escape"] = "FastCast",
    ["Retrace"] = "FastCast",
}

-- ----------------------------------------------------------------------------
-- BLM: WEAPONS
-- ----------------------------------------------------------------------------
-- Current runtime weapon pair is intentionally the user's manually restored
-- Perdu Sickle + Axe Grip.  This is a leveling/test configuration and should be
-- preserved unless the user explicitly changes it.

BLM.Weapons = {
    Main = "Perdu Sickle",
    Sub  = "Axe Grip",
}

-- ----------------------------------------------------------------------------
-- BLM: FUTURE LEVEL-75 EQUIPMENT NOTES
-- ----------------------------------------------------------------------------
-- These notes are progression/reference notes for the level-75 BLM build.
--
-- Wizard's Attire +1 is level 74.  Sorcerer's Attire becomes available from
-- levels 71-75, with Sorcerer's Petasos at 75.  Charmer's Sash is level 73 and
-- gives MP+25, INT+5, CHR+5, Magic Attack Bonus +3, and Drain/Aspir potency +5.
-- Aesir Torque, Merciful Cape, Static Earring, Kirin's Pole, and Norn's Grip are
-- also future level-75-era candidates from the supplied inventory.  These must be
-- compared against the eventual CatsEyeXI-appropriate BLM set before activation.

-- ----------------------------------------------------------------------------
-- BLM: MACRO DECK
-- ----------------------------------------------------------------------------
-- ALT = enemy-targeted / offensive / enfeebling.
-- CTRL = self/party / defensive / enhancing / utility.
-- CTRL+ALT = weapon skills.
--
-- This deck is intentionally selective rather than attempting to bind every BLM
-- spell.  The runtime MA map above remains the authoritative gear-selection map.

BLM.Macro = {
    Alt = {
        ['!`'] = 'Bind',
        ['!1'] = 'Silence',
        ['!2'] = 'Gravity',
        ['!3'] = 'Paralyze',
        ['!4'] = 'Slow',
        ['!5'] = 'Blind',
        ['!6'] = 'Sleep',
        ['!7'] = 'Sleep II',
        ['!8'] = 'Fire IV',
        ['!9'] = 'Blizzard IV',
        ['!0'] = 'Thunder IV',
        ['!-'] = 'Drain',
        ['!='] = 'Aspir',
        ['!Backspace'] = 'Sleepga',
    },
    Ctrl = {
        ['^`'] = 'Blaze Spikes',
        ['^1'] = 'Blink',
        ['^2'] = 'Ice Spikes',
        ['^3'] = 'Shock Spikes',
        ['^4'] = 'Stoneskin',
        ['^5'] = 'Warp',
        ['^6'] = 'Tractor',
        ['^7'] = 'Escape',
        ['^8'] = 'Warp II',
        ['^9'] = 'Retrace',
    },
    JA = {
        ['^0'] = 'Elemental Seal',
        ['^-'] = 'Divine Seal',
    },
    WS = {
        ['^!`'] = 'Retribution',
        ['^!1'] = 'Shell Crusher',
        ['^!2'] = 'Full Swing',
        ['^!3'] = 'Spirit Taker',
    },
}
-- ============================================================================

-- PLD: CHARACTER-SPECIFIC EQUIPMENT
--
-- Integrated from the current PLD.lua supplied on 2026-09-14.
-- Macro corrections: Flash is Divine/Enmity magic (not "DivingMagic"),
-- Death Blossom is an RDM WS rather than a PLD WS, and Starlight/Moonlight are
-- staff WS not appropriate for this Joyeuse/Octave Club weapon policy.
-- The source profile is the authority for PLD gear/action choices here;
-- universal-only callback names are bridged where necessary.
-- ============================================================================

local PLD = JOBS.PLD

PLD.Sets.Idle = {
    Head  = "Glt. Coronet +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Ethereal Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Glt. Surcoat +1",
    Hands = "Valor Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Blood Cuisses",
    Feet  = "Valor Leggings",
}

PLD.Sets.Resting = {
    Head  = "Glt. Coronet +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Ethereal Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Glt. Surcoat +1",
    Hands = "Valor Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Valor Leggings",
}

PLD.Sets.EngagedSolo = {
    Head  = "Glt. Coronet +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Ethereal Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Glt. Surcoat +1",
    Hands = "Valor Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Valor Leggings",
}

PLD.Sets.EngagedParty = {
    Head  = "Glt. Coronet +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Ethereal Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Glt. Surcoat +1",
    Hands = "Valor Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Valor Leggings",
}

-- Keep a separate editable Engaged table rather than aliasing Solo.
PLD.Sets.Engaged = {
    Head  = "Glt. Coronet +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Ethereal Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Glt. Surcoat +1",
    Hands = "Valor Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Valor Leggings",
}

PLD.Sets.Precast = {
    Head  = "Glt. Coronet +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Ethereal Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Glt. Surcoat +1",
    Hands = "Valor Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Valor Leggings",
}

PLD.Sets.EnhancingMagic = {
    Head  = "Glt. Coronet +1",
    Neck  = "Enhancing Torque",
    Ear1  = "Augmenting Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Glt. Surcoat +1",
    Hands = "Valor Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Glt. Breeches +1",
    Feet  = "Valor Leggings",
}

PLD.Sets.RapidShot = {
    Head  = "Walahra Turban",
    Neck  = "Fortitude Torque",
    Ear1  = "Ethereal Earring",
    Ear2  = "Brutal Earring",
    Body  = "Valor Surcoat",
    Hands = "Valor Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Valor Leggings",
}

PLD.Sets.Ranged = {
    Head  = "Walahra Turban",
    Neck  = "Fortitude Torque",
    Ear1  = "Ethereal Earring",
    Ear2  = "Brutal Earring",
    Body  = "Valor Surcoat",
    Hands = "Valor Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Valor Leggings",
}

-- Bridge the source profile's ranged set names to the universal callbacks.
PLD.Sets.Preshot = PLD.Sets.RapidShot
PLD.Sets.Midshot = PLD.Sets.Ranged

PLD.Sets.PDT = {
    Head  = "Glt. Coronet +1",
    Neck  = "Fortitude Torque",
    Body  = "Glt. Surcoat +1",
    Hands = "Valor Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Valor Leggings",
}

PLD.Sets.MDT = {
    Head  = "Glt. Coronet +1",
    Neck  = "Fortitude Torque",
    Body  = "Glt. Surcoat +1",
    Hands = "Valor Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Valor Leggings",
}

PLD.Sets.EngagingEnmity = {
    Head  = "Glt. Coronet +1",
    Neck  = "Fortitude Torque",
    Body  = "Glt. Surcoat +1",
    Hands = "Valor Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Glt. Breeches +1",
    Feet  = "Valor Leggings",
}

PLD.Sets.WS_Default = {
    Head  = "Walahra Turban",
    Neck  = "Soil Gorget",
    Ear1  = "Ethereal Earring",
    Ear2  = "Brutal Earring",
    Body  = "Valor Surcoat",
    Hands = "Valor Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Valor Leggings",
}

PLD.Weapons = {
    Main   = "Joyeuse",
    Sub    = "Koenig Shield",
    DWMain = "Joyeuse",
    DWSub  = "Octave Club",
    Shield = "Koenig Shield",
}

-- Known PLD sword WS share a PLD-owned physical set.  Club WS are kept
-- separate so later optimization cannot accidentally borrow sword assumptions.
PLD.Sets["WS-Physical-STR"] = {
    Head  = "Walahra Turban",
    Neck  = "Fortitude Torque",
    Ear1  = "Ethereal Earring",
    Ear2  = "Brutal Earring",
    Body  = "Valor Surcoat",
    Hands = "Valor Gauntlets",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Valor Leggings",
}

PLD.Sets["WS-Physical-MND"] = PLD.Sets["WS-Physical-STR"]
PLD.Sets["WS-Magical-STR-INT"] = PLD.Sets["WS-Physical-STR"]
PLD.Sets["WS-Magical-MND-STR"] = PLD.Sets["WS-Physical-STR"]
PLD.Sets["WS-Club-STR"] = PLD.Sets["WS-Physical-STR"]

PLD.WS = {
    ["Fast Blade"]       = "WS-Physical-STR",
    ["Flat Blade"]       = "WS-Physical-STR",
    ["Burning Blade"]    = "WS-Magical-STR-INT",
    ["Red Lotus Blade"]  = "WS-Magical-STR-INT",
    ["Shining Blade"]    = "WS-Magical-MND-STR",
    ["Seraph Blade"]     = "WS-Magical-MND-STR",
    ["Circle Blade"]     = "WS-Physical-STR",
    ["Vorpal Blade"]     = "WS-Physical-STR",
    ["Swift Blade"]      = "WS-Physical-STR-MND",
    ["Savage Blade"]     = "WS-Physical-STR-MND",
    ["Requiescat"]       = "WS-Physical-MND",
    ["Shining Strike"]   = "WS-Club-STR",
    ["Seraph Strike"]    = "WS-Club-STR",
    ["Brainshaker"]      = "WS-Club-STR",
    ["True Strike"]      = "WS-Club-STR",
    ["Judgment"]         = "WS-Club-STR",
}

PLD.JA = {
    ["Shield Bash"] = "JA_Defensive",
    ["Sentinel"] = "JA_Defensive",
    ["Rampart"] = "JA_Defensive",
    ["Cover"] = "JA_Defensive",
    ["Provoke"] = "JA_Enmity",
}

PLD.MA = {
    ["Flash"] = "JA_Enmity",
    ["Cure"] = "Cure",
    ["Cure II"] = "Cure",
    ["Cure III"] = "Cure",
    ["Cure IV"] = "Cure",
    ["Stoneskin"] = "EnhancingSkill",
    ["Phalanx"] = "EnhancingSkill",
    ["Reprisal"] = "EnhancingSkill",
}

-- ============================================================================
local BLU = JOBS.BLU

-- BLU: CHARACTER-SPECIFIC EQUIPMENT / ACTION DATA
-- ============================================================================

BLU.Sets.Idle = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Brutal Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Aesir Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Blood Cuisses",
    Feet  = "Magus Charuqs +1",
}

BLU.Sets.Resting = {
    Head  = "Magus Keffiyeh +1",
    -- Neck  = "",
    -- Ear1  = "",
    -- Ear2  = "",
    Body  = "Magus Jubbah +1",
    -- Hands = "",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    -- Back  = "",
    -- Waist = "",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

BLU.Sets.Engaged = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Brutal Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Aesir Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Homam Cosciales",
    Feet  = "Dusk Ledelsens +1",
}

BLU.Sets.Precast = {
    -- Head  = "",
    -- Neck  = "",
    Ear1 = "Loquac. Earring",
    Ear2 = "Magnetic Earring",
    -- Body  = "",
    -- Hands = "",
    -- Ring1 = "",
    -- Ring2 = "",
    -- Back  = "",
    -- Waist = "",
    Legs  = "Blood Cuisses",
    -- Feet  = "",
}

-- No character-owned ranged-attack gear is currently configured.
BLU.Sets.RapidShot = {}
BLU.Sets.Ranged = {}

-- Two-handed staff & grip for magical Blue Magic and selected support-job spells.
-- Staff and grip are equipped only when the player has less than 50 TP.
-- This ensures TP (over 50) is not lost when a spell is cast.
BLU.Sets.Chatoyant = {
    Main = "Chatoyant Staff",
    Sub  = "Wizzan Grip",
}

-- ============================================================================
-- WEAPONSKILL SETS
-- ============================================================================

-- Physical WS: STR
-- Used for: Flat Blade, Circle Blade, Vorpal Blade
BLU.Sets["WS-Physical-STR"] = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Brutal Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Physical WS: STR / DEX
-- Used for: Fast Blade, Chant du Cygne
BLU.Sets["WS-Physical-STR-DEX"] = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Brutal Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Physical WS: STR / DEX / INT
-- Used for: Expiacion
BLU.Sets["WS-Physical-STR-DEX-INT"] = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Brutal Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Physical WS: STR / MND
-- Used for: Swift Blade, Savage Blade
BLU.Sets["WS-Physical-STR-MND"] = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Brutal Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Physical WS: MND
-- Used for: Requiescat
BLU.Sets["WS-Physical-MND"] = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Gnole Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Brutal Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Aqua Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Magical WS: STR / INT
-- Used for: Burning Blade, Red Lotus Blade
BLU.Sets["WS-Magical-STR-INT"] = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Elementium Torque",
    Ear1  = "Moldavite Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Tamas Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Magical WS: INT / STR
-- Used for: Seraph Blade
BLU.Sets["WS-Magical-INT-STR"] = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Elementium Torque",
    Ear1  = "Moldavite Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Tamas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Magical WS: MND / STR
-- Used for: Shining Blade
BLU.Sets["WS-Magical-MND-STR"] = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Gnole Torque",
    Ear1  = "Moldavite Earring",
    Ear2  = "Static Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Salire Belt",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Magical WS: INT / MND
-- Used for: Sanguine Blade
-- Sanguine Blade has no skillchain property; it does NOT receive Fotia Gorget.
BLU.Sets["WS-Magical-INT-MND"] = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Elementium Torque",
    Ear1  = "Moldavite Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Dew Silk Cape +1",
    Waist = "Salire Belt",
    Legs  = "Errant Slops",
    Feet  = "Magus Charuqs +1",
}

-- ============================================================================
-- BLUE MAGIC: PHYSICAL
-- ============================================================================

-- Blue Magic: Physical / general / primarily Accuracy-focused
-- Used for: Sprout Smack, Wild Oats, Queasyshroom, Battle Dance, Head Butt,
--           Feather Storm, Terror Touch, Frypan
BLU.Sets.BlueMagic_Physical = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Physical STR
-- Used for: Uppercut, Death Scissors, Dimensional Death, Spinal Cleave,
--           Asuran Claws, Vertical Cleave
BLU.Sets.BlueMagic_Physical_STR = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Physical STR / DEX
-- Used for: Foot Kick, Smite of Rage, Frenetic Rip, Disseverment
BLU.Sets.BlueMagic_Physical_STR_DEX = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Physical STR / AGI
-- Used for: Pinecone Bomb
BLU.Sets.BlueMagic_Physical_STR_AGI = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Physical STR / VIT
-- Used for: Power Attack, Cannonball, Glutinous Dart
BLU.Sets.BlueMagic_Physical_STR_VIT = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Physical STR / MND
-- Used for: Screwdriver, Sub-zero Smash
BLU.Sets.BlueMagic_Physical_STR_MND = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Gnole Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Physical STR / INT
-- Used for: Mandibular Bite
BLU.Sets.BlueMagic_Physical_STR_INT = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Elementium Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Tamas Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Physical DEX
-- Used for: Claw Cyclone, Sickle Slash, Seedspray, Hysteric Barrage
BLU.Sets.BlueMagic_Physical_DEX = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Physical VIT
-- Used for: Body Slam
BLU.Sets.BlueMagic_Physical_VIT = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Physical VIT / STR
-- Used for: Tail Slap
BLU.Sets.BlueMagic_Physical_VIT_STR = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Physical AGI
-- Used for: Helldive, Jet Stream, Spiral Spin, Hydro Shot
BLU.Sets.BlueMagic_Physical_AGI = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Physical INT
-- Used for: Grand Slam
BLU.Sets.BlueMagic_Physical_INT = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Elementium Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Brutal Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Tamas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Salire Belt",
    Legs  = "Errant Slops",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Physical MND / STR
-- Used for: Ram Charge
BLU.Sets.BlueMagic_Physical_MND_STR = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Gnole Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Physical CHR
-- Used for: Bludgeon
BLU.Sets.BlueMagic_Physical_CHR = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Star Necklace",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Used for: Sprout Smack, Wild Oats, Queasyshroom, Feather Storm, Pinecone Bomb
-- Only these five Blue Magic spells receive the ranged Accuracy/Attack overlay.
-- NOTE: Glutinous Dart is intentionally NOT included; per the CatsEyeXI profile
-- rules, it uses its normal physical accuracy, so does not need ranged accuracy.
BLU.Sets.BlueMagic_RangedPhysical = {
    Ear2  = "Hollow Earring",
    Ring1 = "Bellona's Ring",
    Ring2 = "Jalzahn's Ring",
}

-- ============================================================================
-- BLUE MAGIC: MAGICAL
-- ============================================================================

-- Blue Magic: Magical INT / MAB
-- Used for: Sandspin, Cursed Sphere, Blastbomb, Blood Drain, Bomb Toss,
--           Death Ray, Digest, Venom Shell, Blitzstrahl, Ice Break, Cold Wave,
--           Hecatomb Wave, Acrid Stream, Leafstorm, and other INT-based magic.
BLU.Sets.BlueMagic_Magical_INT = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Elementium Torque",
    Ear1  = "Moldavite Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Dew Silk Cape +1",
    Waist = "Salire Belt",
    Legs  = "Errant Slops",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Magical MND / MAB
-- Used for: Regurgitation, Mind Blast, Magic Hammer
BLU.Sets.BlueMagic_Magical_MND = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Gnole Torque",
    Ear1  = "Moldavite Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Yigit Gages",
    Ring1 = "Aqua Ring",
    Ring2 = "Aqua Ring",
    Back  = "Dew Silk Cape +1",
    Waist = "Salire Belt",
    Legs  = "Errant Slops",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Magical INT / MND / MAB
-- Used for: Maelstrom, Firespit, Tenebral Crush
BLU.Sets.BlueMagic_Magical_INT_MND = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Lmg. Medallion +1",
    Ear1  = "Moldavite Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Dew Silk Cape +1",
    Waist = "Salire Belt",
    Legs  = "Errant Slops",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Magical CHR / MAB
-- Used for: Mysterious Light, Eyes On Me, Blinding Fulgor
BLU.Sets.BlueMagic_Magical_CHR = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Star Necklace",
    Ear1  = "Moldavite Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Dew Silk Cape +1",
    Waist = "Salire Belt",
    Legs  = "Errant Slops",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Magical DEX / MAB
-- Used for: Anvil Lightning
BLU.Sets.BlueMagic_Magical_DEX = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Magical AGI / MAB
-- Used for: Silent Storm
BLU.Sets.BlueMagic_Magical_AGI = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Aqua Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Magical VIT / MAB
-- Used for: Entomb
BLU.Sets.BlueMagic_Magical_VIT = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Moldavite Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Stormlord Shawl",
    Waist = "Salire Belt",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Blue Magic: Magical STR / MAB
-- Used for: Searing Tempest
BLU.Sets.BlueMagic_Magical_STR = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Fortitude Torque",
    Ear1  = "Suppanomimi",
    Ear2  = "Hollow Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Tamas Ring",
    Back  = "Stormlord Shawl",
    Waist = "Ninurta's Sash",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Used for: Blood Drain, Digest, MP Drainkiss, Blood Saber, Osmosis
-- Drain spells do not use MAB or INT to increase the amount drained.
-- Blue Magic Skill, then Magic Accuracy are important instead.
-- Supplement with Fast Cast/Haste/Conserve MP to reduce recast & cost.
BLU.Sets.BlueMagic_Drain = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Elementium Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    -- Ring1 = "",
    -- Ring2 = "",
    -- Back  = "",
    Waist = "Salire Belt",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- ============================================================================
-- BLUE MAGIC: BREATH
-- ============================================================================

-- Breath damage uses Current HP and Blue Magic Skill rather than MAB.
-- Used for: Poison Breath, Magnetite Cloud, Hecatomb Wave, Radiant Breath,
--           Flying Hip Press, Bad Breath, Frost Breath, Heat Breath,
--           Self-Destruct, and any Blue Magic whose name ends in " Breath".
BLU.Sets.BlueMagic_Breath = {
    Head  = "Magus Keffiyeh +1",
    -- Neck  = "",
    Ear1  = "Ethereal Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Bomb Queen Ring",
    Ring2 = "Bloodbead Ring",
    Back  = "Stormlord Shawl",
    -- Waist = "",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- ============================================================================
-- BLUE MAGIC: HEALING
-- ============================================================================

-- Cure-potency / MND-oriented Blue Magic healing.
-- Used for: Pollen, Healing Breeze, Wild Carrot, Magic Fruit, Exuviation
BLU.Sets.BlueMagic_Healing = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Gnole Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Yigit Gages",
    Ring1 = "Aqua Ring",
    Ring2 = "Aqua Ring",
    Back  = "Dew Silk Cape +1",
    Waist = "Salire Belt",
    Legs  = "Errant Slops",
    Feet  = "Magus Charuqs +1",
}

-- ============================================================================
-- BLUE MAGIC: ENHANCING / ENFEEBLING
-- ============================================================================

-- Blue Magic Skill oriented enhancing set.  Blue Magic Skill is used for
-- Metallic Body / Diamondhide absorption and is also relevant to Blue Magic
-- interruption and other spell mechanics.
-- Used for: Metallic Body, Cocoon, Refueling, Feather Barrier, Memento Mori,
--           Voracious Trunk, Diamondhide, Warm-Up, Amplification, Saline Coat,
--           Reactor Cool, Plasma Charge, Magic Barrier, Orcish Counterstance,
--           Harden Shell, Pyric Bulwark, Carcharian Verve, Animating Wail,
--           Battery Charge
BLU.Sets.BlueMagic_Enhancing = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Elementium Torque",
    Ear1  = "Augment. Earring",
    Ear2  = "Loquac. Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Ring1 = "Rajas Ring",
    Ring2 = "Tamas Ring",
    Back  = "Grapevine Cape",
    Waist = "Hierarch Belt",
    Legs  = "Magus Shalwar +1",
    Feet  = "Magus Charuqs +1",
}

-- Enfeebling / M.Acc / Blue Magic Skill.
-- Used for: Sheep Song, Soporific, Sound Blast, Chaotic Eye, Blank Gaze,
--           Stinking Gas, Awful Eye, Jettatura, Geist Wall, Frightful Roar,
--           Light of Penance, Bad Breath, Feather Tickle, Yawn, Infrasonics,
--           Enervation, Sandspray, Actinic Burst, and similar effects.
BLU.Sets.BlueMagic_Enfeebling = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Elementium Torque",
    Ear1  = "Loquac. Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Magus Jubbah +1",
    Hands = "Yigit Gages",
    Ring1 = "Tamas Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Grapevine Cape",
    Waist = "Salire Belt",
    Legs  = "Errant Slops",
    Feet  = "Magus Charuqs +1",
}

-- ============================================================================
-- SPECIAL / FIXED-DAMAGE BLUE MAGIC
-- ============================================================================

-- 1000 Needles is fixed damage; there is no relevant stat gear to increase the
-- fixed 1000-damage component. Preferred Blue Magic Skill.
-- Used for: 1000 Needles
BLU.Sets.BlueMagic_Special = {
    Head  = "Magus Keffiyeh +1",
    Neck  = "Elementium Torque",
    Body  = "Magus Jubbah +1",
    Hands = "Mag. Bazubands +1",
    Feet  = "Magus Charuqs +1",
}

-- ============================================================================
-- ACTION MAPS
-- ============================================================================

BLU.WS = {
    ["Flat Blade"]       = "WS-Physical-STR",
    ["Circle Blade"]     = "WS-Physical-STR",
    ["Vorpal Blade"]     = "WS-Physical-STR",
    ["Fast Blade"]       = "WS-Physical-STR-DEX",
    ["Chant du Cygne"]   = "WS-Physical-STR-DEX",
    ["Expiacion"]        = "WS-Physical-STR-DEX-INT",
    ["Swift Blade"]      = "WS-Physical-STR-MND",
    ["Savage Blade"]     = "WS-Physical-STR-MND",
    ["Requiescat"]       = "WS-Physical-MND",
    ["Burning Blade"]    = "WS-Magical-STR-INT",
    ["Red Lotus Blade"]  = "WS-Magical-STR-INT",
    ["Shining Blade"]    = "WS-Magical-MND-STR",
    ["Seraph Blade"]     = "WS-Magical-INT-STR",
    ["Sanguine Blade"]   = "WS-Magical-INT-MND",
}

-- Skillchain-capable WS use Fotia Gorget.
-- Sanguine Blade intentionally omitted.
local skillchain_weaponskills = {
    ["Fast Blade"]       = true,
    ["Flat Blade"]       = true,
    ["Circle Blade"]     = true,
    ["Vorpal Blade"]     = true,
    ["Swift Blade"]      = true,
    ["Savage Blade"]     = true,
    ["Requiescat"]       = true,
    ["Chant du Cygne"]   = true,
    ["Burning Blade"]    = true,
    ["Red Lotus Blade"]  = true,
    ["Shining Blade"]    = true,
    ["Seraph Blade"]     = true,
}

local blue_magic_sets = {}

local function AddBlueMagic(setName, names)
    for _, name in ipairs(names) do
        blue_magic_sets[name] = setName
    end
end

AddBlueMagic("BlueMagic_Physical", {
    "Sprout Smack", "Wild Oats", "Queasyshroom", "Battle Dance", "Head Butt",
    "Feather Storm", "Terror Touch", "Frypan",
})

AddBlueMagic("BlueMagic_Physical_STR", {
    "Uppercut", "Death Scissors", "Dimensional Death", "Spinal Cleave",
    "Asuran Claws", "Vertical Cleave",
})

AddBlueMagic("BlueMagic_Physical_STR_DEX", {
    "Foot Kick", "Smite of Rage", "Frenetic Rip", "Disseverment",
})

AddBlueMagic("BlueMagic_Physical_STR_AGI", {
    "Pinecone Bomb",
})

AddBlueMagic("BlueMagic_Physical_STR_VIT", {
    "Power Attack", "Cannonball", "Glutinous Dart",
})

AddBlueMagic("BlueMagic_Physical_STR_MND", {
    "Screwdriver", "Sub-zero Smash",
})

AddBlueMagic("BlueMagic_Physical_STR_INT", {
    "Mandibular Bite",
})

AddBlueMagic("BlueMagic_Physical_DEX", {
    "Claw Cyclone", "Sickle Slash", "Seedspray", "Hysteric Barrage",
})

AddBlueMagic("BlueMagic_Physical_VIT", {
    "Body Slam", "Tail Slap",
})

AddBlueMagic("BlueMagic_Physical_AGI", {
    "Helldive", "Jet Stream", "Spiral Spin", "Hydro Shot",
})

AddBlueMagic("BlueMagic_Physical_INT", {
    "Grand Slam",
})

AddBlueMagic("BlueMagic_Physical_MND_STR", {
    "Ram Charge",
})

AddBlueMagic("BlueMagic_Physical_CHR", {
    "Bludgeon",
})

AddBlueMagic("BlueMagic_Magical_INT", {
    "Sandspin", "Cursed Sphere", "Blastbomb", "Death Ray", "Venom Shell",
    "Blitzstrahl", "Ice Break", "Cold Wave", "Hecatomb Wave", "Acrid Stream",
    "Leafstorm", "Spectral Floe",
})

AddBlueMagic("BlueMagic_Magical_MND", {
    "Mind Blast", "Magic Hammer", "Regurgitation", "Scouring Spate",
})

AddBlueMagic("BlueMagic_Magical_INT_MND", {
    "Maelstrom", "Firespit", "Tenebral Crush",
})

AddBlueMagic("BlueMagic_Magical_CHR", {
    "Mysterious Light", "Eyes On Me", "Blinding Fulgor",
})

AddBlueMagic("BlueMagic_Magical_DEX", {
    "Anvil Lightning",
})

AddBlueMagic("BlueMagic_Magical_AGI", {
    "Silent Storm",
})

AddBlueMagic("BlueMagic_Magical_VIT", {
    "Entomb",
})

AddBlueMagic("BlueMagic_Magical_STR", {
    "Searing Tempest",
})

AddBlueMagic("BlueMagic_Healing", {
    "Pollen", "Healing Breeze", "Wild Carrot", "Magic Fruit", "Exuviation",
})

AddBlueMagic("BlueMagic_Drain", {
    "Blood Drain", "Digest", "MP Drainkiss", "Blood Saber", "Osmosis",
})

AddBlueMagic("BlueMagic_Breath", {
    "Poison Breath", "Magnetite Cloud", "Hecatomb Wave", "Radiant Breath",
    "Flying Hip Press", "Bad Breath", "Frost Breath", "Heat Breath", "Self-Destruct",
})

AddBlueMagic("BlueMagic_Enhancing", {
    "Metallic Body", "Cocoon", "Refueling", "Feather Barrier", "Memento Mori",
    "Voracious Trunk", "Diamondhide", "Warm-Up", "Amplification", "Saline Coat",
    "Reactor Cool", "Plasma Charge", "Magic Barrier", "Orcish Counterstance",
    "Harden Shell", "Pyric Bulwark", "Carcharian Verve", "Animating Wail", "Battery Charge",
})

AddBlueMagic("BlueMagic_Enfeebling", {
    "Sheep Song", "Soporific", "Sound Blast", "Chaotic Eye", "Blank Gaze",
    "Stinking Gas", "Geist Wall", "Awful Eye", "Jettatura", "Frightful Roar",
    "Light of Penance", "Feather Tickle", "Yawn", "Infrasonics", "Enervation",
    "Sandspray", "Actinic Burst", "Stinking Gas",
})

AddBlueMagic("BlueMagic_Special", {
    "1000 Needles",
})

-- Any unclassified spell is intentionally left alone rather than guessing.

local ranged_blue_magic = {
    ["Feather Storm"] = true,
    ["Pinecone Bomb"] = true,
    ["Sprout Smack"] = true,
    ["Queasyshroom"] = true,
    ["Wild Oats"] = true,
}

local elemental_ninjutsu = {}
for _, element in ipairs({
    "Katon", "Hyoton", "Doton", "Suiton", "Huton", "Raiton",
}) do
    elemental_ninjutsu[element .. ": Ichi"] = true
    elemental_ninjutsu[element .. ": Ni"] = true
end


-- Character weapons used by the universal weapon selector.
BLU.Weapons = {
    Main   = "Mimesis",
    Sub    = "Genbu's Shield",
    DWMain = "Mimesis",
    DWSub  = "Perdu Hanger",
    Shield = "Genbu's Shield",
}

-- BLU has no verified Finley-owned JA-enhancement gear at this stage.
BLU.JA = {}

-- The latest BLU data uses explicit, searchable local maps.
local BLU_MagicSets = blue_magic_sets
local BLU_RangedPhysical = ranged_blue_magic

-- COMMON / OTHER-JOB ACTION SCAFFOLD
-- ============================================================================
-- All jobs have the same editable action buckets.  We intentionally do not
-- invent equipment for jobs that have not yet gone through the inventory +
-- modifier research process.

-- Examples of action mappings that are safe to keep because the target sets
-- are empty until researched:
JOBS.WAR.JA = {
    ["Berserk"] = "JA_Offensive",
    ["Aggressor"] = "JA_Offensive",
    ["Warcry"] = "JA_Offensive",
    ["Mighty Strikes"] = "JA_Offensive",
    ["Provoke"] = "JA_Enmity",
    ["Defender"] = "JA_Defensive",
}

-- DRK.JA is fully defined in the dedicated DRK section above.

JOBS.NIN.JA = {
    ["Yonin"] = "JA_Defensive",
    ["Innin"] = "JA_Offensive",
    ["Mijin Gakure"] = "JA_Offensive",
    ["Sange"] = "JA_Offensive",
}

JOBS.DRG.JA = {
    ["Jump"] = "JA_Offensive",
    ["High Jump"] = "JA_Offensive",
    ["Super Jump"] = "JA_Defensive",
    ["Spirit Link"] = "JA_Offensive",
    ["Angon"] = "JA_Offensive",
}

JOBS.DNC.JA = {
    ["Haste Samba"] = "JA_Offensive",
    ["Reverse Flourish"] = "JA_Offensive",
    ["Saber Dance"] = "JA_Offensive",
    ["Fan Dance"] = "JA_Defensive",
    ["Trance"] = "JA_Offensive",
}

JOBS.RNG.JA = {
    ["Sharpshot"] = "JA_Offensive",
    ["Barrage"] = "JA_Offensive",
    ["Eagle Eye Shot"] = "JA_Offensive",
}

JOBS.COR.JA = {
    ["Phantom Roll"] = "JA_Offensive",
    ["Wild Card"] = "JA_Offensive",
    ["Random Deal"] = "JA_Offensive",
}

JOBS.SMN.JA = {
    ["Astral Flow"] = "JA_Offensive",
    ["Elemental Siphon"] = "JA_Offensive",
    ["Astral Conduit"] = "JA_Offensive",
    ["Apogee"] = "JA_Offensive",
}

JOBS.PUP.JA = {
    ["Activate"] = "JA_Offensive",
    ["Repair"] = "JA_Defensive",
    ["Deploy"] = "JA_Offensive",
    ["Retrieve"] = "JA_Defensive",
}

JOBS.SCH.JA = {
    ["Light Arts"] = "JA_Defensive",
    ["Dark Arts"] = "JA_Offensive",
    ["Sublimation"] = "JA_Defensive",
    ["Tabula Rasa"] = "JA_Offensive",
}

JOBS.GEO.JA = {
    ["Full Circle"] = "JA_Offensive",
    ["Life Cycle"] = "JA_Offensive",
    ["Blaze of Glory"] = "JA_Offensive",
    ["Dematerialize"] = "JA_Defensive",
}

JOBS.RUN.JA = {
    ["Vallation"] = "JA_Defensive",
    ["Vex"] = "JA_Defensive",
    ["Pflug"] = "JA_Defensive",
    ["Liement"] = "JA_Defensive",
    ["Swordplay"] = "JA_Offensive",
    ["Elemental Sforzo"] = "JA_Defensive",
    ["Rayke"] = "JA_Offensive",
    ["Gambit"] = "JA_Offensive",
}

-- ============================================================================
-- WEAPONSKILL / FOTIA DATA
-- ============================================================================
-- These common mappings are a seed, not a claim that every server-specific
-- WS is fully optimized yet.  The universal engine is ready for all WS names;
-- unknown WS use the job's explicit WS_Default table.

local SkillchainWeaponskills = {
    ["Fast Blade"] = true,
    ["Flat Blade"] = true,
    ["Circle Blade"] = true,
    ["Vorpal Blade"] = true,
    ["Swift Blade"] = true,
    ["Savage Blade"] = true,
    ["Knights of Round"] = true,
    ["Requiescat"] = true,
    ["Chant du Cygne"] = true,
    ["Burning Blade"] = true,
    ["Red Lotus Blade"] = true,
    ["Shining Blade"] = true,
    ["Seraph Blade"] = true,

    ["Rampage"] = true,
    ["Ukko's Fury"] = true,
    ["King's Justice"] = true,
    ["Steel Cyclone"] = true,
    ["Spinning Slash"] = true,
    ["Resolution"] = true,
    ["Torcleaver"] = true,
    ["Raging Rush"] = true,
    ["Evisceration"] = true,
    ["Dancing Edge"] = true,
    ["Rudra's Storm"] = true,
    ["Wasp Sting"] = true,
    ["Viper Bite"] = true,
    ["Gust Slash"] = true,
    ["Cyclone"] = true,
    ["Dancing Edge"] = true,
    ["Shark Bite"] = true,
    ["Evisceration"] = true,
    ["Mandalic Stab"] = true,

    -- Samurai Great Katana WS with skillchain properties.  These are listed
    -- explicitly because HandleWeaponskill uses this table to apply Fotia
    -- Gorget at execution time.
    ["Tachi: Enpi"] = true,
    ["Tachi: Hobaku"] = true,
    ["Tachi: Goten"] = true,
    ["Tachi: Kagero"] = true,
    ["Tachi: Jinpu"] = true,
    ["Tachi: Koki"] = true,
    ["Tachi: Yukikaze"] = true,
    ["Tachi: Gekko"] = true,
    ["Tachi: Kasha"] = true,
    ["Tachi: Rana"] = true,

    -- Monk hand-to-hand WS with skillchain properties.
    ["Combo"] = true,
    ["Shoulder Tackle"] = true,
    ["One Inch Punch"] = true,
    ["Backhand Blow"] = true,
    ["Raging Fists"] = true,
    ["Spinning Attack"] = true,
    ["Howling Fist"] = true,
    ["Dragon Kick"] = true,
    ["Asuran Fists"] = true,
    ["Ascetic's Fury"] = true,
    ["Victory Smite"] = true,
    ["Final Heaven"] = true,

    -- Dragoon Polearm WS with skillchain properties.
    ["Double Thrust"] = true,
    ["Thunder Thrust"] = true,
    ["Leg Sweep"] = true,
    ["Penta Thrust"] = true,
    ["Vorpal Thrust"] = true,
    ["Skewer"] = true,
    ["Wheeling Thrust"] = true,
    ["Impulse Drive"] = true,
}


-- Non-skillchain WS deliberately absent:
--   Sanguine Blade, Energy Drain, Energy Steal, etc.

-- ============================================================================
-- SAM: CHARACTER-SPECIFIC EQUIPMENT
-- ============================================================================
-- Current level: 75
--
-- SAM has graduated from the temporary starter area.  Everything SAM-specific
-- is kept here so a human editor can search for "SAM:" and find the complete
-- job configuration in one place.
--
-- OWNERSHIP / SOURCE NOTES:
--   Current inventory explicitly contains the NQ Myochin and Saotome pieces,
--   Shura Togi, Shinsoku, Magoroku, and the accessories used below.
--   Base Saotome Domaru is treated as eventual Artifact ownership per project
--   rules.  No Saotome +1 / Shura +1 augment is assumed without ownership data.
--   Hecatomb Harness is owned but is NOT SAM-equipable and is deliberately not
--   used here.
--
-- EQUIPMENT RESEARCH HIGHLIGHTS:
--   Walahra Turban       = Haste +5%
--   Ninurta's Sash       = Haste +6%, Attack +6
--   Dusk Ledelsens +1    = Haste +3% (used for TP rather than slower AF feet)
--   Shura Togi           = Accuracy +10, Attack +20, HP -50; confirmed augments:
--                           Haste +2%, Critical Hit Rate +2%, Ninja Tool Expertise +3%
--   Bushinomimi          = STR +2, Great Katana skill +5
--   Brutal Earring       = Double Attack +5%, Store TP +1
--   Rajas Ring           = STR +5, DEX +5, Store TP +5 at level 75
--   Mars's Ring          = Accuracy +8, Attack +8
--   Aesir Mantle         = Attack +8, Double Attack +1%
--   Cerberus Mantle      = STR +3, Attack +12
--   Saotome Kote         = Attack +10 and enhances Meditate
--   Saotome Haidate      = enhances Third Eye
--   Myochin Kabuto       = enhances Warding Circle / Meditate
--   Saotome Sune-Ate     = HP +23, DEX +5, Attack +8
--
-- SOURCES:
--   CatsEyeXI BG-Wiki equipment data is preferred for server-specific gear.
--   Standard BG-Wiki job / WS data is used where no CatsEyeXI override is
--   documented in the researched source.  See the global WS reference library.
-- ============================================================================

local SAM = JOBS.SAM

-- ----------------------------------------------------------------------------
-- SAM: IDLE
-- ----------------------------------------------------------------------------
SAM.Sets.Idle = {
    Head  = "Myochin Kabuto",
    Neck  = "Fortitude Torque",
    Ear1  = "Ethereal Earring",
    Ear2  = "Bushinomimi",
    Body  = "Saotome Domaru",
    Hands = "Myochin Kote",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Myochin Haidate",
    Feet  = "Saotome Sune-Ate",
}

-- ----------------------------------------------------------------------------
-- SAM: RESTING
-- ----------------------------------------------------------------------------
-- SAM has no native resting-magic advantage.  Keep this intentionally simple
-- and defensive instead of pretending the job owns a mage resting set.
SAM.Sets.Resting = {
    Head  = "Myochin Kabuto",
    Neck  = "Fortitude Torque",
    Ear1  = "Ethereal Earring",
    Ear2  = "Bushinomimi",
    Body  = "Saotome Domaru",
    Hands = "Myochin Kote",
    Ring1 = "Rajas Ring",
    Ring2 = "Sattva Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Myochin Haidate",
    Feet  = "Saotome Sune-Ate",
}

-- ----------------------------------------------------------------------------
-- SAM: ENGAGED / TP
-- ----------------------------------------------------------------------------
-- The TP set favors confirmed haste, accuracy, attack, and multi-attack gear.
-- It incorporates the confirmed CatsEyeXI Shura Togi augments: Haste +2%,
-- Critical Hit Rate +2%, and Ninja Tool Expertise +3%.
SAM.Sets.Engaged = {
    Head  = "Walahra Turban",
    Neck  = "Ancient Torque",
    Ear1  = "Brutal Earring",
    Ear2  = "Bushinomimi",
    Body  = "Shura Togi",
    Hands = "Saotome Kote",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Aesir Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Myochin Haidate",
    Feet  = "Dusk Ledelsens +1",
}

-- ----------------------------------------------------------------------------
-- SAM: FAST CAST / SUPPORT MAGIC
-- ----------------------------------------------------------------------------
-- SAM has no native magic.  The profile intentionally leaves Precast and
-- named magic-skill sets empty rather than inventing mage equipment for every
-- possible support job.  Support-job spells still function through the shared
-- callback and fall back to these empty sets unless a future audit adds a
-- verified support-magic set.
SAM.Sets.Precast = {}
SAM.Sets.HealingSkill = {}
SAM.Sets.EnhancingSkill = {}
SAM.Sets.EnfeeblingSkill = {}

-- ----------------------------------------------------------------------------
-- SAM: JOB ABILITY SETS
-- ----------------------------------------------------------------------------
-- Myochin Kabuto enhances Warding Circle and Meditate.  Saotome Kote adds
-- additional TP to Meditate and only needs to be worn when Meditate is used.
-- Saotome Haidate improves the Third Eye counter interaction.
SAM.Sets.WardingCircle = {
    Head = "Myochin Kabuto",
}

SAM.Sets.Meditate = {
    Head  = "Myochin Kabuto",
    Hands = "Saotome Kote",
}

SAM.Sets.ThirdEye = {
    Legs = "Saotome Haidate",
}

SAM.Sets.Seigan = {
    Legs = "Saotome Haidate",
}

-- No verified SAM-specific gear modifier was identified for these abilities,
-- so their JA sets deliberately remain empty rather than forcing a TP set onto
-- a job ability with no documented benefit.
SAM.Sets.JA_Offensive = {}
SAM.Sets.JA_Defensive = {}
SAM.Sets.JA_Enmity = {}
SAM.Sets.JA_Default = {}

SAM.JA = {
    ["Warding Circle"] = "WardingCircle",
    ["Third Eye"]      = "ThirdEye",
    ["Hasso"]          = "JA_Offensive",
    ["Meditate"]       = "Meditate",
    ["Seigan"]         = "Seigan",
    ["Meikyo Shisui"]  = "JA_Offensive",
    ["Sekkanoki"]      = "JA_Offensive",
    ["Konzen-ittai"]   = "JA_Offensive",
    ["Shikikoyo"]      = "JA_Offensive",
    ["Blade Bash"]     = "JA_Offensive",
}

-- ----------------------------------------------------------------------------
-- SAM: MANUAL DEFENSE
-- ----------------------------------------------------------------------------
-- The supplied inventory does not contain a verified 25%-style PDT/MDT set
-- for SAM.  These are conservative HP/defense overlays only; do not confuse
-- them with a completed capped PDT/MDT build.
SAM.Sets.PDT = {
    Body  = "Saotome Domaru",
    Ear1  = "Ethereal Earring",
    Ring1 = "Sattva Ring",
    Legs  = "Saotome Haidate",
    Feet  = "Saotome Sune-Ate",
}

SAM.Sets.MDT = {
    Body  = "Saotome Domaru",
    Ear1  = "Ethereal Earring",
    Ring1 = "Sattva Ring",
    Legs  = "Saotome Haidate",
    Feet  = "Saotome Sune-Ate",
}

-- ----------------------------------------------------------------------------
-- SAM: WEAPON SKILLS
-- ----------------------------------------------------------------------------
-- Physical WS:
--   Enpi / Hobaku = STR-based
--   Yukikaze / Gekko / Kasha = STR 75%
--   Rana = STR 50%, 3-hit
-- Hybrid / elemental WS:
--   Goten = STR 60%
--   Kagero = STR 75%
--   Jinpu = STR 30%
--   Koki = STR 50% / MND 30%
-- All WS below carry skillchain properties, so the shared callback replaces
-- their neck with Fotia Gorget at execution time.
SAM.Sets["WS-Physical-STR"] = {
    Head  = "Saotome Kabuto",
    Neck  = "Ancient Torque", -- replaced by Fotia Gorget for skillchain WS
    Ear1  = "Bushinomimi",
    Ear2  = "Brutal Earring",
    Body  = "Shura Togi",
    Hands = "Saotome Kote",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Myochin Haidate",
    Feet  = "Saotome Sune-Ate",
}

SAM.Sets["WS-Hybrid-STR"] = {
    Head  = "Saotome Kabuto",
    Neck  = "Ancient Torque", -- replaced by Fotia Gorget for skillchain WS
    Ear1  = "Moldavite Earring",
    Ear2  = "Bushinomimi",
    Body  = "Shura Togi",
    Hands = "Saotome Kote",
    Ring1 = "Rajas Ring",
    Ring2 = "Tamas Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Myochin Haidate",
    Feet  = "Saotome Sune-Ate",
}

SAM.Sets["WS-Hybrid-STR-MND"] = {
    Head  = "Saotome Kabuto",
    Neck  = "Ancient Torque", -- replaced by Fotia Gorget for skillchain WS
    Ear1  = "Moldavite Earring",
    Ear2  = "Bushinomimi",
    Body  = "Shura Togi",
    Hands = "Saotome Kote",
    Ring1 = "Rajas Ring",
    Ring2 = "Tamas Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Myochin Haidate",
    Feet  = "Saotome Sune-Ate",
}

SAM.Sets.WS_Default = SAM.Sets["WS-Physical-STR"]

SAM.WS = {
    ["Tachi: Enpi"]    = "WS-Physical-STR",
    ["Tachi: Hobaku"]  = "WS-Physical-STR",
    ["Tachi: Yukikaze"] = "WS-Physical-STR",
    ["Tachi: Gekko"]   = "WS-Physical-STR",
    ["Tachi: Kasha"]   = "WS-Physical-STR",
    ["Tachi: Rana"]    = "WS-Physical-STR",

    ["Tachi: Goten"]   = "WS-Hybrid-STR",
    ["Tachi: Kagero"]  = "WS-Hybrid-STR",
    ["Tachi: Jinpu"]   = "WS-Hybrid-STR",
    ["Tachi: Koki"]    = "WS-Hybrid-STR-MND",
}

-- ----------------------------------------------------------------------------
-- SAM: WEAPONS
-- ----------------------------------------------------------------------------
-- Shinsoku is the current level-72 great katana in inventory and therefore the
-- active weapon.  Magoroku remains an owned lower-level fallback/reference.
SAM.Weapons = {
    Main = "Shinsoku",
}

-- ----------------------------------------------------------------------------
-- SAM: MACRO DECK
-- ----------------------------------------------------------------------------
-- ALT = offensive/job abilities, ordered by acquisition level.
-- CTRL = defensive/self abilities, ordered by acquisition level.
-- CTRL+ALT = Great Katana WS, ordered by acquisition level.
-- Future level-75 bindings are allowed; runtime equipment/action maps above are
-- still constrained by the character's actual SAM level.
SAM.Macro = {
    Alt = {
        ['!`'] = 'Meikyo Shisui', -- Lv1
        ['!1'] = 'Hasso',         -- Lv25
        ['!2'] = 'Meditate',      -- Lv30
        ['!3'] = 'Sekkanoki',     -- Lv40
        ['!4'] = 'Konzen-ittai',  -- Lv65
        ['!5'] = 'Shikikoyo',     -- Lv75
        ['!6'] = 'Blade Bash',    -- Lv75
    },
    Ctrl = {
        ['^`'] = 'Warding Circle', -- Lv5
        ['^1'] = 'Third Eye',      -- Lv15
        ['^2'] = 'Seigan',         -- Lv35
    },
    WS = {
        ['^!`'] = 'Tachi: Enpi',
        ['^!1'] = 'Tachi: Hobaku',
        ['^!2'] = 'Tachi: Goten',
        ['^!3'] = 'Tachi: Kagero',
        ['^!4'] = 'Tachi: Jinpu',
        ['^!5'] = 'Tachi: Koki',
        ['^!6'] = 'Tachi: Yukikaze',
        ['^!7'] = 'Tachi: Gekko',
        ['^!8'] = 'Tachi: Kasha',
        ['^!9'] = 'Tachi: Rana',
    },
}

-- ============================================================================
-- MNK: CHARACTER-SPECIFIC EQUIPMENT
-- ============================================================================
-- Current character level: 75
--
-- This is a completed, self-contained MNK section.  It follows the RDM/BLM
-- organizational model but only defines categories that make sense for Monk.
-- Runtime gear is restricted to the character's current level and confirmed
-- ownership.  Future-75 macro bindings are allowed separately.
--
-- OWNERSHIP / PROGRESSION NOTES
--   * Avengers is the active H2H weapon; Beat Cesti remains a lower-level owned
--     fallback.  H2H uses the Main slot only in this profile.
--   * Shura Togi is owned and usable at level 73.  Its guaranteed base stats are
--     HP-50, Accuracy+10, Attack+20.  No unreported Synergy augment is assumed.
--   * Base Melee Attire and Temple Attire are owned.  Melee +1 is NOT assumed.
--   * CatsEyeXI extends Focus and Dodge duration to 75 seconds, and Footwork to
--     120 seconds.  CatsEyeXI also grants Perfect Counter and Impetus at level 75.
--
-- SET DESIGN NOTES
--   * Engaged prioritizes known Haste, Accuracy, Attack, Double Attack, and
--     Store TP/multi-hit support from owned equipment.
--   * Temple Crown / Gaiters / Cyclas / Gloves are reserved for the MNK JAs they
--     actually enhance rather than wasting their special properties in TP gear.
--   * Melee Gaiters specifically enhance Counterstance; Temple Crown enhances
--     Focus; Temple Gaiters enhance Dodge; Temple Cyclas enhances Chakra; Temple
--     Gloves enhance Boost.
--   * Confirmed Shura Togi augments: Haste +2%, Critical Hit Rate +2%, and
--     Ninja Tool Expertise +3%.
-- ============================================================================

local MNK = JOBS.MNK

-- ----------------------------------------------------------------------------
-- MNK: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------

MNK.Sets.Idle = {
    Head  = "Melee Crown",
    Neck  = "Ancient Torque",
    Ear1  = "Ethereal Earring",
    Ear2  = "Hollow Earring",
    Body  = "Melee Cyclas",
    Hands = "Melee Gloves",
    Ring1 = "Sattva Ring",
    Ring2 = "Rajas Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Melee Hose",
    Feet  = "Melee Gaiters",
}

MNK.Sets.Resting = {
    Head  = "Melee Crown",
    Neck  = "Ancient Torque",
    Ear1  = "Ethereal Earring",
    Ear2  = "Hollow Earring",
    Body  = "Melee Cyclas",
    Hands = "Melee Gloves",
    Ring1 = "Sattva Ring",
    Ring2 = "Rajas Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Melee Hose",
    Feet  = "Melee Gaiters",
}

MNK.Sets.Engaged = {
    Head  = "Walahra Turban",
    Neck  = "Ancient Torque",
    Ear1  = "Brutal Earring",
    Ear2  = "Hollow Earring",
    Body  = "Shura Togi",
    Hands = "Melee Gloves",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Melee Hose",
    Feet  = "Dusk Ledelsens +1",
}

-- No separate solo/party policy is required for MNK; the generic state handler
-- uses Engaged for non-PLD jobs.

-- ----------------------------------------------------------------------------
-- MNK: SUPPORT MAGIC / PRECAST
-- ----------------------------------------------------------------------------
-- Monk has no native magic.  These are intentionally conservative because the
-- useful /WHM support spells are secondary to MNK's melee role.  Shared magic
-- handling still works; empty categories simply avoid forcing questionable
-- job-restricted caster gear onto the player.

MNK.Sets.FastCast = {
    Ear1 = "Loquac. Earring",
}

MNK.Sets.Precast = MNK.Sets.FastCast

MNK.Sets.Cure = {
    Ear1  = "Loquac. Earring",
    Ear2  = "Magnetic Earring",
    Body  = "Melee Cyclas",
    Ring1 = "Aqua Ring",
    Ring2 = "Aqua Ring",
    Back  = "Dew Silk Cape +1",
    Waist = "Hierarch Belt",
    Feet  = "Melee Gaiters",
}

MNK.Sets.HealingSkill = MNK.Sets.Cure
MNK.Sets.EnhancingSkill = MNK.Sets.FastCast
MNK.Sets.EnfeeblingSkill = MNK.Sets.FastCast

-- ----------------------------------------------------------------------------
-- MNK: JOB ABILITY SETS
-- ----------------------------------------------------------------------------

MNK.Sets.Boost = {
    Hands = "Temple Gloves",
}

MNK.Sets.Focus = {
    Head = "Temple Crown",
}

MNK.Sets.Dodge = {
    Feet = "Temple Gaiters",
}

MNK.Sets.Chakra = {
    Head  = "Genbu's Kabuto",
    Neck  = "Fortitude Torque",
    Body  = "Temple Cyclas",
    Ring1 = "Sattva Ring",
    Ring2 = "Rajas Ring",
    -- Legs intentionally left unchanged: no verified owned VIT/Chakra-specific
    -- leg piece is needed to justify replacing the current state gear.
}

MNK.Sets.ChiBlast = {
    Head  = "Genbu's Kabuto",
    Neck  = "Fortitude Torque",
    Body  = "Melee Cyclas",
    Ring1 = "Sattva Ring",
    Ring2 = "Rajas Ring",
}

MNK.Sets.Counterstance = {
    Feet = "Melee Gaiters",
}

-- These JAs have no verified owned equipment modifier that warrants forcing a
-- separate gear set at activation time.
MNK.Sets.HundredFists = {}
MNK.Sets.Footwork = {}
MNK.Sets.PerfectCounter = {}
MNK.Sets.Mantra = {}
MNK.Sets.FormlessStrikes = {}
MNK.Sets.Impetus = {}

MNK.Sets.JA_Default = {}
MNK.Sets.JA_Offensive = {}
MNK.Sets.JA_Defensive = {}
MNK.Sets.JA_Enmity = {}

MNK.JA = {
    ["Hundred Fists"]    = "HundredFists",
    ["Boost"]            = "Boost",
    ["Focus"]            = "Focus",
    ["Chi Blast"]        = "ChiBlast",
    ["Dodge"]            = "Dodge",
    ["Chakra"]           = "Chakra",
    ["Counterstance"]    = "Counterstance",
    ["Footwork"]         = "Footwork",
    ["Perfect Counter"]  = "PerfectCounter",
    ["Mantra"]            = "Mantra",
    ["Formless Strikes"] = "FormlessStrikes",
    ["Impetus"]           = "Impetus",
}

-- ----------------------------------------------------------------------------
-- MNK: MANUAL DEFENSE
-- ----------------------------------------------------------------------------
-- These are conservative defensive overlays from equipment actually owned.
-- They are NOT presented as a capped PDT/MDT set.

MNK.Sets.PDT = {
    Head  = "Genbu's Kabuto",
    Body  = "Melee Cyclas",
    Ring1 = "Sattva Ring",
    Legs  = "Melee Hose",
    Feet  = "Melee Gaiters",
}

MNK.Sets.MDT = {
    Head  = "Genbu's Kabuto",
    Body  = "Melee Cyclas",
    Ring1 = "Sattva Ring",
    Legs  = "Melee Hose",
    Feet  = "Melee Gaiters",
}

-- ----------------------------------------------------------------------------
-- MNK: WEAPON SKILLS
-- ----------------------------------------------------------------------------
-- The active WS map below is restricted to hand-to-hand WS executable with the
-- owned Avengers weapon.  Weapon-gated level-75 WS remain macro-only below.
--
-- Accuracy is intentionally prominent because Raging Fists / Asuran Fists are
-- multi-hit WS.  Skillchain WS receive Fotia Gorget from the shared execution
-- handler, so the neck shown here is the normal fallback neck.

MNK.Sets["WS-Physical-STR-DEX"] = {
    Head  = "Melee Crown",
    Neck  = "Ancient Torque", -- replaced by Fotia Gorget for skillchain WS
    Ear1  = "Brutal Earring",
    Ear2  = "Hollow Earring",
    Body  = "Shura Togi",
    Hands = "Melee Gloves",
    Ring1 = "Rajas Ring",
    Ring2 = "Mars's Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Melee Hose",
    Feet  = "Dusk Ledelsens +1",
}

MNK.Sets["WS-Physical-STR"] = MNK.Sets["WS-Physical-STR-DEX"]

MNK.Sets["WS-Physical-STR-VIT"] = {
    Head  = "Genbu's Kabuto",
    Neck  = "Fortitude Torque", -- replaced by Fotia Gorget for skillchain WS
    Ear1  = "Brutal Earring",
    Ear2  = "Hollow Earring",
    Body  = "Shura Togi",
    Hands = "Melee Gloves",
    Ring1 = "Sattva Ring",
    Ring2 = "Rajas Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Melee Hose",
    Feet  = "Dusk Ledelsens +1",
}

-- Asuran Fists is an eight-hit WS; use Attack on the earring slot rather than
-- relying on Double Attack on the Brutal Earring, because the eight WS hits
-- already consume the normal attack-round hit allowance.
MNK.Sets["WS-Physical-STR-VIT-8Hit"] = {
    Head  = "Genbu's Kabuto",
    Neck  = "Fortitude Torque", -- replaced by Fotia Gorget for skillchain WS
    Ear1  = "Ethereal Earring",
    Ear2  = "Hollow Earring",
    Body  = "Shura Togi",
    Hands = "Melee Gloves",
    Ring1 = "Sattva Ring",
    Ring2 = "Rajas Ring",
    Back  = "Cerberus Mantle",
    Waist = "Ninurta's Sash",
    Legs  = "Melee Hose",
    Feet  = "Dusk Ledelsens +1",
}

MNK.Sets.WS_Default = MNK.Sets["WS-Physical-STR-DEX"]

MNK.WS = {
    -- Common level-75-era hand-to-hand WS with researched modifier sets.
    ["Backhand Blow"]   = "WS-Physical-STR-DEX",
    ["Raging Fists"]    = "WS-Physical-STR-DEX",
    ["Spinning Attack"] = "WS-Physical-STR",
    ["Howling Fist"]    = "WS-Physical-STR-VIT",
    ["Dragon Kick"]     = "WS-Physical-STR-DEX",
    ["Asuran Fists"]    = "WS-Physical-STR-VIT-8Hit",
}

-- Lower-tier H2H WS and any future WS not listed above intentionally fall back
-- to WS_Default until their individual mechanics are audited for this server.

-- ----------------------------------------------------------------------------
-- MNK: WEAPONS
-- ----------------------------------------------------------------------------
-- Avengers is the owned level-69 H2H weapon selected for the active level-75
-- build.  Beat Cesti is retained in inventory but is intentionally not the
-- primary weapon because Avengers has the stronger current weapon profile.

MNK.Weapons = {
    Main = "Avengers",
}

-- ----------------------------------------------------------------------------
-- MNK: MACRO DECK
-- ----------------------------------------------------------------------------
-- Macro selection is intentionally biased toward actions a level-75 Monk uses
-- frequently, using CatsEyeXI's documented level-75 job additions where they
-- apply.  The deck remains ordered by acquisition level within each category.
--
-- ALT = offensive / accuracy / offensive JAs.
-- CTRL = defensive / recovery / defensive JAs.
-- CTRL+ALT = commonly used H2H WS, with optional weapon-gated 75-era WS last.
-- Boost remains a standalone JA macro rather than being chained automatically
-- into WS execution; the profile never performs autonomous combat actions.

MNK.Macro = {
    Alt = {
        ['!`'] = 'Hundred Fists',     -- Lv1
        ['!1'] = 'Boost',             -- Lv5
        ['!2'] = 'Focus',             -- Lv25
        ['!3'] = 'Chi Blast',         -- Lv41
        ['!4'] = 'Footwork',          -- Lv65 / CatsEyeXI duration 120 sec
        ['!5'] = 'Formless Strikes',  -- Lv75
        ['!6'] = 'Impetus',           -- Lv75 / CatsEyeXI
    },
    Ctrl = {
        ['^`'] = 'Dodge',             -- Lv15 / CatsEyeXI duration 75 sec
        ['^1'] = 'Chakra',            -- Lv35
        ['^2'] = 'Counterstance',     -- Lv45
        ['^3'] = 'Perfect Counter',   -- Lv75 / CatsEyeXI
        ['^4'] = 'Mantra',            -- Lv75
    },
    WS = {
        ['^!`'] = 'Backhand Blow',     -- Lv33
        ['^!1'] = 'Raging Fists',      -- Lv41
        ['^!2'] = 'Spinning Attack',   -- Lv49
        ['^!3'] = 'Howling Fist',      -- Lv60
        ['^!4'] = 'Dragon Kick',       -- Lv65
        ['^!5'] = 'Asuran Fists',      -- Lv71
        ['^!6'] = 'Ascetic\'s Fury',   -- Lv75 / weapon-gated
        ['^!7'] = 'Victory Smite',     -- Lv75 / weapon-gated
    },
}

-- ============================================================================

-- ============================================================================
-- SMN: CHARACTER-SPECIFIC EQUIPMENT / BLOOD PACT DATA
-- ============================================================================
-- Current owned SMN armor is NQ Evoker's / Summoner's.  This stage deliberately
-- keeps execution sets conservative: BP Delay is separated from BP effect gear,
-- while individual pact names are explicitly editable below.  The two verified
-- high-value named examples are Predator Claws and Wind Blade.
--
-- Blood Pact activation and execution are intentionally separate concepts:
--   * HandleAbility() maps named BP actions to BPDelay when that callback sees them.
--   * HandleDefault()/GetPetSet() maps the actual pet move to the execution set.
-- If the game/client delivers a BP only through GetPetAction(), the execution
-- stage still works; the activation-stage hook is simply not invoked.
-- ============================================================================

local SMN = JOBS.SMN

-- ----------------------------------------------------------------------------
-- SMN: IDLE / RESTING / ENGAGED
-- ----------------------------------------------------------------------------

SMN.Sets.Idle = {
        Head="Evoker's Horn", Neck="Smn. Torque", Ear1="Loquac. Earring", Ear2="Magnetic Earring",
        Body="Evoker's Doublet", Hands="Evoker's Bracers", Ring1="Evoker's Ring", Ring2="Aqua Ring",
        Back="Grapevine Cape", Waist="Salire Belt", Legs="Evoker's Spats", Feet="Evoker's Pigaches",
    }

SMN.Sets.Resting = {
        Head="Evoker's Horn", Neck="Smn. Torque", Body="Evoker's Doublet", Hands="Evoker's Bracers",
        Ring1="Evoker's Ring", Ring2="Aqua Ring", Waist="Salire Belt", Legs="Evoker's Spats", Feet="Evoker's Pigaches",
    }

SMN.Sets.Engaged = {
        Head="Evoker's Horn", Neck="Fortitude Torque", Ear1="Loquac. Earring", Ear2="Brutal Earring",
        Body="Evoker's Doublet", Hands="Evoker's Bracers", Ring1="Rajas Ring", Ring2="Evoker's Ring",
        Back="Grapevine Cape", Waist="Salire Belt", Legs="Evoker's Spats", Feet="Evoker's Pigaches",
    }

-- ----------------------------------------------------------------------------
-- SMN: WEAPONS
-- ----------------------------------------------------------------------------

SMN.Weapons = {
    Main = "Chatoyant Staff",
    Sub = "Ossa Grip",
}


SMN.Sets.BPDelay = {
    Head  = "Summoner's Horn",
    Neck  = "Smn. Torque",
    Body  = "Summoner's Dblt.",
    Hands = "Summoner's Brcr.",
    Legs  = "Summoner's Spats",
    Feet  = "Summoner's Pgch.",
}

SMN.Sets["BP-Rage-Physical"] = {
    -- Physical Rage execution: avatar performance first; no player-stat WSC set.
    Head  = "Summoner's Horn",
    Neck  = "Smn. Torque",
    Body  = "Summoner's Dblt.",
    Hands = "Summoner's Brcr.",
    Ring1 = "Evoker's Ring",
    Ring2 = "Rajas Ring",
    Back  = "Grapevine Cape",
    Legs  = "Summoner's Spats",
    Feet  = "Summoner's Pgch.",
}

SMN.Sets["BP-Rage-Magical"] = {
    -- Magical Rage execution: avatar M.Acc/MAB where owned; no player INT set.
    Head  = "Summoner's Horn",
    Neck  = "Smn. Torque",
    Body  = "Summoner's Dblt.",
    Hands = "Summoner's Brcr.",
    Ring1 = "Evoker's Ring",
    Ring2 = "Tamas Ring",
    Back  = "Grapevine Cape",
    Legs  = "Summoner's Spats",
    Feet  = "Summoner's Pgch.",
}

SMN.Sets["BP-Ward"] = {
    Head  = "Summoner's Horn",
    Neck  = "Smn. Torque",
    Body  = "Summoner's Dblt.",
    Hands = "Summoner's Brcr.",
    Ring1 = "Evoker's Ring",
    Ring2 = "Aqua Ring",
    Back  = "Grapevine Cape",
    Legs  = "Summoner's Spats",
    Feet  = "Summoner's Pgch.",
}

SMN.Sets["BP-Ward-Healing"] = SMN.Sets["BP-Ward"]

SMN.Sets.ElementalSiphon = {
    Head  = "Summoner's Horn",
    Neck  = "Smn. Torque",
    Body  = "Summoner's Dblt.",
    Hands = "Summoner's Brcr.",
    Ring1 = "Evoker's Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Grapevine Cape",
    Waist = "Hierarch Belt",
    Legs  = "Summoner's Spats",
    Feet  = "Summoner's Pgch.",
}

SMN.Sets.AvatarFavor = {
    Head  = "Evoker's Horn",
    Neck  = "Smn. Torque",
    Body  = "Evoker's Doublet",
    Hands = "Evoker's Bracers",
    Ring1 = "Evoker's Ring",
    Ring2 = "Balrahn's Ring",
    Back  = "Grapevine Cape",
    Waist = "Hierarch Belt",
    Legs  = "Evoker's Spats",
    Feet  = "Evoker's Pigaches",
}

-- ============================================================================
-- BLOOD PACT REFERENCE / GEARING MODEL
-- ============================================================================
-- Blood Pacts are NOT weapon skills.  Do not gear the Summoner by the player's
-- own WS WSC (for example, Predator Claws does not call for player DEX gear).
-- Activation priority: Blood Pact Ability Delay first; after the pact is sent,
-- execution gear emphasizes avatar-side performance and pact-specific bonuses.
--
-- Base Rage and Ward recast is 60s.  Blood Pact Ability Delay I/II can reduce
-- the shared Rage/Ward timers to a combined hard cap of -30s.  Avatar's Favor
-- can supply additional delay reduction, up to -10s, beyond that hard cap.
--
-- Some Rage BPs replicate fTP across all hits (including Predator Claws,
-- Chaotic Strike, Double Punch, Eclipse Bite, and Hysteric Assault).
-- Elemental gorget/belt WS rules do NOT automatically transfer to Blood Pacts.
-- Reference: BG-Wiki Blood Pact Ability Delay / FTP Replicating WS.
--
-- Avatar-specific stat examples verified in the reference data:
--   Predator Claws: Avatar DEX; 3 hits; Fragmentation / Scission.
--   Spinning Dive: Avatar STR; Distortion / Detonation.
--   Shock Strike: Avatar STR + INT; Impaction; stun.
--   Thunderstorm: Avatar INT; thunder elemental; merit TP bonus.
--   Rock Buster: Avatar VIT; Reverberation; Bind.
--   Aerial Blast: Avatar INT; wind elemental; Astral Flow.
--   Diamond Dust: Avatar INT; ice elemental; Astral Flow.
--   Howling Moon: Avatar INT; darkness elemental; Astral Flow.
--   Nether Blast: ranged darkness attack; not affected by avatar TP.
--
-- These avatar-stat facts describe the BP mechanics; they do not by themselves
-- create player-stat gear sets.  Executable gear remains character-specific.
-- ============================================================================

SMN.JA["Astral Flow"] = "BPDelay"
SMN.JA["Astral Conduit"] = "BPDelay"
SMN.JA["Mana Cede"] = "BPDelay"
SMN.JA["Elemental Siphon"] = "ElementalSiphon"
SMN.JA["Apogee"] = "BPDelay"
SMN.JA["Avatar's Favor"] = "AvatarFavor"

-- ============================================================================
-- SMN BLOOD PACT DATABASE
-- ============================================================================
-- Key slots are intentionally common-purpose and avatar-oriented.  Individual
-- pacts only get a separate execution set when their mechanics justify it.
-- Current scope covers the classic avatars and commonly used Pacts through the
-- current level-75-era progression.  Future/above-cap entries can be added to
-- the database without changing the macro engine.

SMN.PET = {
    -- Garuda
    ["Claw"] = "BP-Rage-Physical",
    ["Predator Claws"] = "BP-Rage-Physical",
    ["Wind Blade"] = "BP-Rage-Magical",
    ["Aerial Blast"] = "BP-Rage-Magical",
    ["Aerial Armor"] = "BP-Ward",
    ["Whispering Wind"] = "BP-Ward-Healing",
    ["Hastega"] = "BP-Ward",

    -- Ifrit
    ["Punch"] = "BP-Rage-Physical",
    ["Double Punch"] = "BP-Rage-Physical",
    ["Burning Strike"] = "BP-Rage-Physical",
    ["Flaming Crush"] = "BP-Rage-Physical",
    ["Meteor Strike"] = "BP-Rage-Magical",
    ["Crimson Howl"] = "BP-Ward",

    -- Shiva
    ["Axe Kick"] = "BP-Rage-Physical",
    ["Double Slap"] = "BP-Rage-Physical",
    ["Rush"] = "BP-Rage-Physical",
    ["Heavenly Strike"] = "BP-Rage-Magical",
    ["Diamond Dust"] = "BP-Rage-Magical",
    ["Frost Armor"] = "BP-Ward",
    ["Sleepga (Blood Pact)"] = "BP-Ward",

    -- Titan
    ["Rock Throw"] = "BP-Rage-Physical",
    ["Rock Buster"] = "BP-Rage-Physical",
    ["Megalith Throw"] = "BP-Rage-Physical",
    ["Mountain Buster"] = "BP-Rage-Physical",
    ["Geocrush"] = "BP-Rage-Physical",
    ["Earthen Fury"] = "BP-Rage-Magical",
    ["Earthen Ward"] = "BP-Ward",

    -- Ramuh
    ["Shock Strike"] = "BP-Rage-Physical",
    ["Thunderspark"] = "BP-Rage-Physical",
    ["Chaotic Strike"] = "BP-Rage-Physical",
    ["Thunderstorm (Blood Pact)"] = "BP-Rage-Magical",
    ["Judgment Bolt"] = "BP-Rage-Magical",
    ["Rolling Thunder"] = "BP-Ward",
    ["Lightning Armor"] = "BP-Ward",

    -- Leviathan
    ["Barracuda Dive"] = "BP-Rage-Physical",
    ["Tail Whip"] = "BP-Rage-Physical",
    ["Spinning Dive"] = "BP-Rage-Physical",
    ["Grand Fall"] = "BP-Rage-Physical",
    ["Tidal Wave"] = "BP-Rage-Magical",
    ["Slowga"] = "BP-Ward",
    ["Spring Water"] = "BP-Ward-Healing",

    -- Fenrir
    ["Moonlit Charge"] = "BP-Rage-Physical",
    ["Crescent Fang"] = "BP-Rage-Physical",
    ["Eclipse Bite"] = "BP-Rage-Physical",
    ["Howling Moon"] = "BP-Rage-Magical",
    ["Lunar Cry"] = "BP-Ward",
    ["Lunar Roar"] = "BP-Ward",
    ["Ecliptic Growl"] = "BP-Ward",
    ["Ecliptic Howl"] = "BP-Ward",

    -- Diabolos
    ["Camisado"] = "BP-Rage-Physical",
    ["Nether Blast"] = "BP-Rage-Magical",
    ["Ruinous Omen"] = "BP-Rage-Magical",
    ["Somnolence"] = "BP-Ward",
    ["Nightmare"] = "BP-Ward",
    ["Ultimate Terror"] = "BP-Ward",
    ["Noctoshield"] = "BP-Ward",
    ["Dream Shroud"] = "BP-Ward",

    -- Carbuncle
    ["Poison Nails"] = "BP-Rage-Physical",
    ["Meteorite (Blood Pact)"] = "BP-Rage-Magical",
    ["Searing Light"] = "BP-Rage-Magical",
    ["Healing Ruby"] = "BP-Ward-Healing",
    ["Shining Ruby"] = "BP-Ward",
    ["Glittering Ruby"] = "BP-Ward",
    ["Healing Ruby II"] = "BP-Ward-Healing",

    -- Cait Sith
    ["Regal Scratch"] = "BP-Rage-Physical",
    ["Regal Gash"] = "BP-Rage-Physical",
    ["Level ? Holy"] = "BP-Rage-Magical",
    ["Mewing Lullaby"] = "BP-Ward",
    ["Raise II (Blood Pact)"] = "BP-Ward",
    ["Reraise II (Blood Pact)"] = "BP-Ward",
}

-- Blood Pact reference notes.  These are mechanics, not player-stat gearing:
-- * Base Rage/Ward recast is 60s; delay gear caps the ordinary reduction at 30s.
-- * Avatar's Favor can add up to another 10s of delay reduction.
-- * Predator Claws: Avatar DEX, three hits, fTP transfers, Fragmentation/Scission.
-- * Spinning Dive: Avatar STR, Distortion/Detonation.
-- * Shock Strike: Avatar STR + INT, Impaction, stun.
-- * Thunderstorm: Avatar INT, thunder elemental; merit TP bonus.
-- * Rock Buster: Avatar VIT, Reverberation, bind.
-- * Aerial Blast / Diamond Dust / Howling Moon are Astral Flow magical Rages.
-- * Nether Blast is a ranged magical Rage whose damage is not affected by avatar TP.
-- * Some physical Rages have fTP transfer and therefore can receive multiattack.
-- References: BG-Wiki Blood Pact Ability Delay; Category: Blood Pact; individual BP pages.

-- Dynamic macro selection: Alt = Rage, Ctrl = Ward.  These are command aliases
-- rather than permanently bound pact names, so changing avatars updates instantly.
local SMNMacroRage = {'!`','!1','!2','!3','!4','!5','!6','!7','!8','!9','!0','!-','!='}
local SMNMacroWard = {'^`','^1','^2','^3','^4','^5','^6','^7','^8','^9','^0','^-','^='}













-- ============================================================================
-- HACHIRIN-NO-OBI / DAY-WEATHER MAGIC OVERLAY
-- ============================================================================
-- Hachirin-no-Obi forces active day/weather effects instead of leaving the
-- normal proc chance to game behavior. It can therefore also force the
-- corresponding opposing-element penalty, so it remains conditional.
--
-- Included:
--   Elemental, Healing, Enfeebling, Dark, Divine, magical Blue Magic,
--   Blue Magic healing/enfeebling, and Ninjutsu.
--
-- Excluded:
--   Dia/Diaga, Bio, physical/breath/enhancing Blue Magic, Summoning,
--   Geomancy, Singing, and Quick Draw.
--
-- Healing Magic is deliberately allowed on self/party targets because Cure
-- and Blue Magic healing spells are modified by elemental day/weather.

local HachirinEligibleSkills = {
    ["Elemental Magic"] = true,
    ["Healing Magic"] = true,
    ["Enfeebling Magic"] = true,
    ["Dark Magic"] = true,
    ["Divine Magic"] = true,
    ["Blue Magic"] = true,
    ["Ninjutsu"] = true,
}

local HachirinHealingSpells = {
    ["Cure"] = true,
    ["Cure II"] = true,
    ["Cure III"] = true,
    ["Cure IV"] = true,
    ["Cure V"] = true,
    ["Cure VI"] = true,
    ["Curaga"] = true,
    ["Curaga II"] = true,
    ["Curaga III"] = true,
    ["Curaga IV"] = true,
    ["Curaga V"] = true,
    ["Cura"] = true,
    ["Cura II"] = true,
    ["Cura III"] = true,
    ["Full Cure"] = true,
}

local HachirinExcludedSpells = {
    ["Dia"] = true,
    ["Diaga"] = true,
    ["Dia II"] = true,
    ["Dia III"] = true,
    ["Bio"] = true,
    ["Bio II"] = true,
    ["Bio III"] = true,
}

local HachirinBlueMagicSets = {
    ["BlueMagic_Magical_INT"] = true,
    ["BlueMagic_Magical_MND"] = true,
    ["BlueMagic_Magical_INT_MND"] = true,
    ["BlueMagic_Magical_CHR"] = true,
    ["BlueMagic_Magical_DEX"] = true,
    ["BlueMagic_Magical_AGI"] = true,
    ["BlueMagic_Magical_VIT"] = true,
    ["BlueMagic_Magical_STR"] = true,
    ["BlueMagic_Healing"] = true,
    ["BlueMagic_Drain"] = true,
    ["BlueMagic_Enfeebling"] = true,
}

local function IsHachirinPartyTarget(target)
    if not target or not target.Name or target.Name == "" then
        return true
    end

    local party = AshitaCore:GetMemoryManager():GetParty()
    if not party then
        return true
    end

    for i = 0, 17 do
        local name = party:GetMemberName(i)
        if name ~= nil and name ~= "" and name == target.Name then
            return true
        end
    end

    return false
end

local function IsHachirinEligibleAction(action)
    if not CONFIG.HachirinObiOwned or not action then
        return false
    end

    if not HachirinEligibleSkills[action.Skill]
        or HachirinExcludedSpells[action.Name]
        or not action.Element
        or action.Element == "" then
        return false
    end

    local isHealingAction = HachirinHealingSpells[action.Name] == true
        or (action.Skill == "Blue Magic"
            and BLU_MagicSets[action.Name] == "BlueMagic_Healing")

    -- Healing is allowed on self/party targets. Other eligible magic remains
    -- enemy-targeted in this profile.
    if not isHealingAction and IsHachirinPartyTarget(gData.GetActionTarget()) then
        return false
    end

    if action.Skill == "Blue Magic" then
        if BLU_RangedPhysical[action.Name] then
            return false
        end

        local setName = BLU_MagicSets[action.Name]
        if not HachirinBlueMagicSets[setName] then
            return false
        end
    end

    return true
end

local function ShouldEquipHachirinObi(action, env)
    if not action or not env then
        return false
    end

    local element = action.Element
    local day = env.DayElement
    local weather = env.WeatherElement

    if element ~= day and element ~= weather then
        return false
    end

    -- If the spell matches the day but opposing double weather is active,
    -- forcing both effects would be net-negative. Matching weather remains
    -- beneficial or neutral against an opposing day.
    if element == day
        and weather == OpposingElement[element]
        and IsDoubleWeather(env) then
        return false
    end

    return true
end

local function EquipHachirinObi(action)
    if not IsHachirinEligibleAction(action) then
        return
    end

    local env = gData.GetEnvironment()
    if not env then
        return
    end

    if ShouldEquipHachirinObi(action, env) then
        gFunc.Equip("Waist", "Hachirin-no-Obi")
    end
end

-- GENERIC SKILL FALLBACKS
-- ============================================================================

local SkillSet = {
    ["Healing Magic"] = "HealingSkill",
    ["Enhancing Magic"] = "EnhancingSkill",
    ["Enfeebling Magic"] = "EnfeeblingSkill",
    ["Elemental Magic"] = "ElementalDamage",
    ["Dark Magic"] = "DarkDamage",
    ["Divine Magic"] = "DivineDamage",
    ["Ninjutsu"] = "Spell_Default",
    ["Summoning Magic"] = "PetMagical",
    ["Singing"] = "Spell_Buff",
    ["Geomancy"] = "Spell_Buff",
}

local weaponLocked = false
local defenseSet = nil
local engagedWeaponLogicEnabled = true
local lastEngagedState = nil
local ApplyMacroDeck
local ShowMacroDeck

-- Fencer's Ring is a RDM-main persistent state overlay. Dynamic Enspell
-- selection is deliberately unrelated to this latent-effect check.
local FencerEnspellBuffs = {
    "Enfire", "Enblizzard", "Enaero", "Enstone", "Enthunder", "Enwater",
    "Enfire II", "Enblizzard II", "Enaero II", "Enstone II",
    "Enthunder II", "Enwater II",
}

local function HasActiveEnspell()
    for _, buffName in ipairs(FencerEnspellBuffs) do
        if gData.GetBuffCount(buffName) > 0 then
            return true
        end
    end
    return false
end

local function ShouldEquipFencerRing(player)
    return player
        and player.MainJob == "RDM"
        and (player.MainJobLevel or 0) >= 50
        and (player.HPP or 0) < 75
        and (player.TP or 0) < 1000
        and HasActiveEnspell()
end

local function ApplyFencerRingOverlay(stateSet, player)
    if ShouldEquipFencerRing(player) then
        -- Ring2 is the existing secondary RDM ring slot; Ring1 remains Tamas.
        return MergeSets(stateSet, { Ring2 = "Fencer's Ring" })
    end
    return stateSet
end

-- ============================================================================
-- PET RESOLUTION
-- ============================================================================

local PetJobs = {
    SMN = true,
    BST = true,
    DRG = true,
    PUP = true,
}

local function GetPetJob(player)
    if not player then
        return nil
    end

    if PetJobs[player.MainJob] then
        return JOBS[player.MainJob]
    end

    if PetJobs[player.SubJob] then
        return JOBS[player.SubJob]
    end

    return nil
end

local function GetPetSet(job, petAction)
    if not job or not petAction then
        return nil
    end

    if job.PET[petAction.Name] then
        return GetSet(job, job.PET[petAction.Name], "Pet")
    end

    return GetSet(job, "Pet")
end

-- ============================================================================
-- DEFAULT / STATE HANDLING
-- ============================================================================

profile.HandleDefault = function()
    local player = gData.GetPlayer()
    if not player then
        return
    end

    -- Keep the direct Ctrl-BACKSLASH Enspell bind synchronized with live
    -- day/weather changes.  The signature check prevents repeated rebinds
    -- during ordinary polling when nothing has changed.
    UpdateEnspellBind(false)

    -- HandleDefault() is already evaluated repeatedly by LuAshitacast, so a
    -- one-variable transition check lets us report the moment we ENTER the
    -- Engaged state without producing chat spam on every poll.
    local isEngaged = player.Status == "Engaged"
    if isEngaged and lastEngagedState ~= true then
        gFunc.Message(
            "[Universal.lua] Engaged: automatic weapon selection "
                .. (engagedWeaponLogicEnabled and "ON" or "OFF")
        )
    end
    lastEngagedState = isEngaged

    -- Reconcile shared/job-local macro bindings when the job or subjob changes
    -- without a zone transition.  The signature cache prevents per-poll churn.
    ApplyMacroDeck(player)

    local job = GetJob(player)
    if not job then
        return
    end

    -- Pet actions take priority over ordinary state gear.
    local petAction = gData.GetPetAction()
    if petAction then
        local petJob = GetPetJob(player)
        local petSet = GetPetSet(petJob, petAction)
        if petSet and next(petSet) ~= nil then
            gFunc.EquipSet(petSet)
            return
        end
    end

    if CONFIG.WeaponLockTP ~= nil then
        local tp = player.TP or 0

        if tp >= CONFIG.WeaponLockTP then
            if not weaponLocked then
                gFunc.Disable("Main")
                gFunc.Disable("Sub")
                weaponLocked = true
            end
        elseif weaponLocked then
            gFunc.Enable("Main")
            gFunc.Enable("Sub")
            weaponLocked = false
        end
    end

    local moving = player.IsMoving == true and not IsMounted()
    local stateSet = moving and {} or GetStateSet(job, player)

    -- MOVEMENT IS A STATE OVERRIDE, NOT AN OVERLAY.
    -- While moving, do not re-send Idle/Resting/Engaged armor at all.  The
    -- movement set changes only the movement-specific slots, allowing the
    -- already-equipped armor to remain in place without the profile repeatedly
    -- fighting itself.  This is especially important for Track Pants +1, which
    -- suppresses Feet.  When movement stops, the normal state set is reapplied.
    -- Mounted status suppresses movement gear so mounted idle gear remains intact.

    -- THF LegacyAC compatibility: keep the DEX overlay active while Sneak Attack
    -- is actually buffed.  While moving, apply the special SA set first and the
    -- movement override second so movement Legs remain authoritative.
    if player.MainJob == "THF" and gData.GetBuffCount("Sneak Attack") > 0 then
        stateSet = MergeSets(stateSet, THF.Sets.SneakAttackDEX)
    end

    if moving then
        stateSet = MergeSets(stateSet, GetMovementSet(player))
    end

    -- Persistent latent-effect overlay; part of the final state set so it
    -- cannot fight movement or state equipment with a second Equip request.
    stateSet = ApplyFencerRingOverlay(stateSet, player)

    gFunc.EquipSet(stateSet)

    if player.Status == "Engaged" then
        local action = gData.GetAction()
        local spellActive = action and action.ActionType == "Spell"

        if not spellActive and engagedWeaponLogicEnabled then
            EquipJobWeapons(job, player)
        end
    elseif player.MainJob == "SMN" then
        EquipJobWeapons(job, player)
    end
end

-- ============================================================================
-- WHM SPELL WEAPON OVERLAY
-- ============================================================================
-- While TP is below the universal 50-TP lock threshold, WHM uses Chatoyant Staff
-- + Wizzan Grip for the explicitly selected Cure/elemental/dark/enfeebling spells.
-- The TP lock remains independent; at TP >= 50 no spell overlay changes Main/Sub.

local function EquipWHMSpellWeapons(player, action)
    if not player or player.MainJob ~= "WHM" or not action
        or action.ActionType ~= "Spell" then
        return
    end

    if (player.TP or 0) >= CONFIG.WeaponLockTP then
        return
    end

    if WHMCureSpells[action.Name] then
        gFunc.Equip("Main", "Chatoyant Staff")
        gFunc.Equip("Sub", "Wizzan Grip")
        return
    end

    local setName = WHM.MA[action.Name]
    if setName == "ElementalDamage"
        or setName == "DarkDamage"
        or setName == "EnfeeblingSkill" then
        gFunc.Equip("Main", "Chatoyant Staff")
        gFunc.Equip("Sub", "Wizzan Grip")
    end
end

-- ============================================================================
-- BLM SPELL WEAPON OVERLAY
-- ============================================================================
-- While TP is below the 50-TP lock threshold, BLM uses Chatoyant Staff +
-- Wizzan Grip for spellcasting.  This is deliberately based on explicit spell
-- names/categories rather than a wildcard such as "Cur*"; a target/action name
-- containing "Cur" (for example a Trust named Curilla) must never trigger it.
--
-- Cure/Curaga spells are listed explicitly because "Healing Magic" is a skill
-- category, not a reliable indicator of which spells benefit from Chatoyant Staff.
-- Elemental, Dark, and Enfeebling spell mappings use their existing BLM.MA
-- categories.  At 50+ TP the global weapon lock takes precedence and no weapon
-- change is attempted.
-- ============================================================================

local BLMCureSpells = {
    ["Cure"] = true,
    ["Cure II"] = true,
    ["Cure III"] = true,
    ["Cure IV"] = true,
    ["Curaga"] = true,
    ["Curaga II"] = true,
}

local function ShouldEquipBLMSpellWeapons(player, action)
    if not player or player.MainJob ~= "BLM" or not action
        or action.ActionType ~= "Spell" then
        return false
    end

    if (player.TP or 0) >= CONFIG.WeaponLockTP then
        return false
    end

    if BLMCureSpells[action.Name] then
        return true
    end

    local setName = BLM.MA[action.Name]
    return setName == "ElementalDamage"
        or setName == "DarkDamage"
        or setName == "EnfeeblingSkill"
end

local function EquipBLMSpellWeapons(player, action)
    if ShouldEquipBLMSpellWeapons(player, action) then
        gFunc.Equip("Main", "Chatoyant Staff")
        gFunc.Equip("Sub", "Wizzan Grip")
    end
end

-- ============================================================================
-- SPELL PRECAST
-- ============================================================================

profile.HandlePrecast = function()
    local player = gData.GetPlayer()
    local action = gData.GetAction()

    if not player or not action then
        return
    end

    local job = GetJob(player)
    if not job then
        return
    end

    if action.ActionType == "Spell" then
        gFunc.EquipSet(job.Sets.Precast)
        EquipWHMSpellWeapons(player, action)
        EquipBLMSpellWeapons(player, action)
    end
end

-- ============================================================================
-- RANGED ATTACK
-- ============================================================================

profile.HandlePreshot = function()
    local player = gData.GetPlayer()
    if not player then
        return
    end

    local job = GetJob(player)
    if job then
        gFunc.EquipSet(job.Sets.Preshot)
    end
end

profile.HandleMidshot = function()
    local player = gData.GetPlayer()
    if not player then
        return
    end

    local job = GetJob(player)
    if job then
        gFunc.EquipSet(job.Sets.Midshot)
    end
end

-- ============================================================================
-- JOB ABILITIES
-- ============================================================================

profile.HandleAbility = function()
    local player = gData.GetPlayer()
    local action = gData.GetAction()

    if not player or not action then
        return
    end

    local job = GetJob(player)
    if not job then
        return
    end

    if player.MainJob == "SMN" then
        local bpNames = {
            ["Predator Claws"] = true, ["Wind Blade"] = true,
            ["Volt Strike"] = true, ["Chaotic Strike"] = true,
            ["Aerial Blast"] = true, ["Meteor Strike"] = true, ["Heavenly Strike"] = true,
            ["Thunderstorm"] = true, ["Inferno"] = true, ["Diamond Dust"] = true,
            ["Earthen Fury"] = true, ["Howling Moon"] = true, ["Ruinous Omen"] = true,
        }
        if bpNames[action.Name] then
            gFunc.EquipSet(GetSet(job, "BPDelay"))
            return
        end
    end

    local setName = job.JA[action.Name]
    if setName then
        gFunc.EquipSet(GetSet(job, setName))
    end
end

-- ============================================================================
-- WEAPONSKILLS
-- ============================================================================

profile.HandleWeaponskill = function()
    local player = gData.GetPlayer()
    local action = gData.GetAction()

    if not player or not action then
        return
    end

    local job = GetJob(player)
    if not job then
        return
    end

    local setName = job.WS[action.Name]
    local wsSet = GetSet(job, setName, "WS_Default")

    gFunc.EquipSet(wsSet)

    -- Fotia applies only to WS with a skillchain property.
    if SkillchainWeaponskills[action.Name] then
        gFunc.Equip("Neck", "Fotia Gorget")
    end
end

-- ============================================================================
-- MIDCAST
-- ============================================================================

profile.HandleMidcast = function()
    local player = gData.GetPlayer()
    local action = gData.GetAction()

    if not player or not action then
        return
    end

    -- Protect an active pet action from ordinary player spell gear.
    local petAction = gData.GetPetAction()
    if petAction then
        local petJob = GetPetJob(player)
        local petSet = GetPetSet(petJob, petAction)

        if petSet and next(petSet) ~= nil then
            gFunc.EquipSet(petSet)
            return
        end
    end

    if action.ActionType ~= "Spell" then
        return
    end

    local job = GetJob(player)
    if not job then
        return
    end

    if action.Skill == "Blue Magic" and player.MainJob == "BLU" then
        local setName = action.Name:match(" Breath$") and "BlueMagic_Breath"
            or BLU_MagicSets[action.Name]

        if setName and BLU.Sets[setName] then
            gFunc.EquipSet(BLU.Sets[setName])
        end

        if BLU_RangedPhysical[action.Name] then
            gFunc.EquipSet(BLU.Sets.BlueMagic_RangedPhysical)
        end

        local magicalSet = setName == "BlueMagic_Magical_INT"
            or setName == "BlueMagic_Magical_MND"
            or setName == "BlueMagic_Magical_INT_MND"
            or setName == "BlueMagic_Magical_CHR"
            or setName == "BlueMagic_Magical_DEX"
            or setName == "BlueMagic_Magical_AGI"
            or setName == "BlueMagic_Magical_VIT"
            or setName == "BlueMagic_Magical_STR"
            or setName == "BlueMagic_Drain"

        if magicalSet then
            gFunc.EquipSet(BLU.Sets.Chatoyant)
        end

        EquipHachirinObi(action)
        return
    end

    local namedSet = job.MA[action.Name]
    if namedSet then
        gFunc.EquipSet(GetSet(job, namedSet))
        EquipWHMSpellWeapons(player, action)
        EquipBLMSpellWeapons(player, action)
        EquipHachirinObi(action)
        return
    end

    local skillSet = SkillSet[action.Skill]
    if skillSet then
        gFunc.EquipSet(GetSet(job, skillSet))
        EquipWHMSpellWeapons(player, action)
        EquipBLMSpellWeapons(player, action)
        EquipHachirinObi(action)
    end
end

-- ============================================================================
-- ITEM / COMMAND
-- ============================================================================

profile.HandleItem = function()
    -- Intentionally no automatic item usage.
end

profile.HandleCommand = function(args)
    if not args or not args[1] then
        return
    end

    local command = tostring(args[1]):lower()

    -- Manual set testing: /lac fwd set Engaged (or Idle/Resting/PDT/etc.).
    -- This resolves the common set name against the CURRENT MAIN JOB, so the
    -- behavior is global rather than duplicated inside each job section.
    -- It is a temporary equip/lock for testing; it does not change the state.
    if command == "set" then
        local player = gData.GetPlayer()
        local job = GetJob(player)
        local setName = nil

        if args[2] then
            local requested = {}
            for i = 2, #args do
                requested[#requested + 1] = tostring(args[i])
            end
            setName = table.concat(requested, " ")
        end

        if not job or not setName or setName == "" then
            gFunc.Message("[Universal.lua] Usage: /lac fwd set <SetName>")
            return
        end

        local selected = job.Sets[setName]
        if not selected or next(selected) == nil then
            gFunc.Message(
                "[Universal.lua] Set not found for " .. tostring(player.MainJob) .. ": " .. setName
            )
            return
        end

        gFunc.LockSet(selected, CONFIG.ManualSetSeconds)
        gFunc.Message(
            "[Universal.lua] " .. tostring(player.MainJob) .. " -> " .. setName
            .. " (" .. tostring(CONFIG.ManualSetSeconds) .. "s test lock)"
        )
        return
    end

    if command == "toggleengagedweapons" then
        engagedWeaponLogicEnabled = not engagedWeaponLogicEnabled
        gFunc.Message(
            "[Universal.lua] Automatic Engaged weapon selection: "
                .. (engagedWeaponLogicEnabled and "ON" or "OFF")
        )
        return
    end

    if command == "pdt" or command == "mdt" then
        local player = gData.GetPlayer()
        local job = GetJob(player)

        if job then
            defenseSet = command == "pdt" and job.Sets.PDT or job.Sets.MDT
            if defenseSet and next(defenseSet) ~= nil then
                gFunc.LockSet(defenseSet, CONFIG.ManualDefenseSeconds)
            end
        end

        return
    end

    if command == "enspell" then
        UpdateEnspellBind(true)
        if currentEnspell ~= "" then
            gFunc.Message("Current dynamic spell: " .. currentEnspell)
        else
            gFunc.Message("Dynamic Enspell unavailable: RDM is neither main nor support job.")
        end
        return
    end

    if command:match("^smnrage%d+$") then
        local index = tonumber(command:match("%d+"))
        ExecuteSMNBP("Rage", index)
        return
    end

    if command:match("^smnward%d+$") then
        local index = tonumber(command:match("%d+"))
        ExecuteSMNBP("Ward", index)
        return
    end

    if command == "smnstaff" then
        smnStaffMode = (smnStaffMode == "Gridarvor") and "Chatoyant Staff" or "Gridarvor"
        gFunc.Message("[SMN] Staff preference: " .. smnStaffMode)
        return
    end

    if command == "macros" then
        if ShowMacroDeck then
            ShowMacroDeck()
        end
        return
    end

    if command == "job" then
        local player = gData.GetPlayer()
        if player then
            gFunc.Message(
                "Main: " .. tostring(player.MainJob) ..
                " Lv" .. tostring(player.MainJobLevel) ..
                " /" .. tostring(player.SubJob) ..
                " | TP=" .. tostring(player.TP)
            )
        end
        return
    end
end

-- ============================================================================
-- UNIVERSAL MACRO DECKS
-- ============================================================================
-- Universal records its effective macro deck as bindings are installed. F12
-- therefore shows the profile's actual job deck, including later shared
-- NIN/DNC overrides, rather than Ashita's unrelated global bind table.

local macroDeck = {
    Ctrl = {},
    Alt = {},
    CtrlAlt = {},
}

local function MacroDeckCategory(key)
    if key:sub(1, 2) == "^!" then
        return "CtrlAlt"
    elseif key:sub(1, 1) == "^" then
        return "Ctrl"
    elseif key:sub(1, 1) == "!" then
        return "Alt"
    end
    return nil
end

local function RecordMacro(key, label)
    local category = MacroDeckCategory(key)
    if category then
        macroDeck[category][key] = label
    end
end

local function RecordMacroFromCommand(key, command)
    local label = command:match('/ma "([^"]+)"')
        or command:match('/ja "([^"]+)"')
        or command:match('/ws "([^"]+)"')
        or command:match('/lac fwd ([^%s;]+)')
    if label then
        RecordMacro(key, label)
    end
end

local function MacroDeckLine(category, label)
    local parts = {}
    for _, key in ipairs(CONFIG.MacroKeys) do
        if MacroDeckCategory(key) == category and macroDeck[category][key] then
            parts[#parts + 1] = key .. "=" .. macroDeck[category][key]
        end
    end
    return label .. ": " .. (#parts > 0 and table.concat(parts, " | ") or "(none)")
end

ShowMacroDeck = function()
    local player = gData.GetPlayer()
    if not player then
        return
    end

    ApplyMacroDeck(player)

    gFunc.Message(
        "[Macros] " .. tostring(player.MainJob or "None")
            .. tostring(player.MainJobLevel or 0)
            .. "/" .. tostring(player.SubJob or "None")
            .. tostring(player.SubJobLevel or 0)
    )
    gFunc.Message(MacroDeckLine("Ctrl", "CTRL"))
    gFunc.Message(MacroDeckLine("Alt", "ALT"))
    gFunc.Message(MacroDeckLine("CtrlAlt", "CTRL+ALT"))
end

local function QueueBind(key, command)
    RecordMacroFromCommand(key, command)

    -- Explicitly bind on key-down.  This is equivalent to Ashita's default,
    -- but makes the intended behavior unambiguous for punctuation keys such
    -- as Alt-[ and Alt-].  Ashita documents [ and ] as bindable key names.
    AshitaCore:GetChatManager():QueueCommand(
        -1,
        "/bind " .. key .. " down " .. command
    )
end

local function ClearOwnedMacroBinds()
    for _, key in ipairs(CONFIG.MacroKeys) do
        AshitaCore:GetChatManager():QueueCommand(-1, "/unbind " .. key .. " down")
    end
end

local function BindSpell(key, name, target)
    target = target or "<stpc>"
    QueueBind(key, '/recast "' .. name .. '";/ma "' .. name .. '" ' .. target)
end

local function BindJA(key, name, target)
    target = target or "<stnpc>"
    QueueBind(key, '/recast "' .. name .. '";/ja "' .. name .. '" ' .. target)
end

local function BindWS(key, name)
    QueueBind(key, '/echo [' .. name .. '];/ws "' .. name .. '" <stnpc>')
end

local RDMMacroWS = {
    ['^!`'] = 'Flat Blade', ['^!1'] = 'Vorpal Blade', ['^!2'] = 'Red Lotus Blade',
    ['^!3'] = 'Seraph Blade', ['^!4'] = 'Savage Blade', ['^!5'] = 'Death Blossom',
    ['^!6'] = 'Gust Slash', ['^!7'] = 'Cyclone', ['^!8'] = 'Energy Drain',
    ['^!9'] = 'Evisceration', ['^!0'] = 'Knights of Round', ['^!-'] = 'Spirits Within',
    ['^!='] = 'Spirit Taker',
}

local function ApplyRDMMacros(player)
    if not player or player.MainJob ~= 'RDM' then return end

    if player.SubJob == 'WHM' then
        BindSpell('^`', 'Erase', '<stpc>')
    else
        BindSpell('^`', 'Cure II', '<stpc>')
    end
    BindSpell('^1', 'Cure III', '<stpc>')
    BindSpell('^2', 'Cure IV', '<stpc>')
    BindSpell('^3', 'Regen', '<stpc>')
    BindSpell('^4', 'Refresh', '<stpc>')
    BindSpell('^5', 'Haste', '<stpc>')
    BindSpell('^6', 'Aquaveil', '<stpc>')
    BindSpell('^7', 'Blink', '<stpc>')
    BindSpell('^8', 'Stoneskin', '<stpc>')
    BindSpell('^9', 'Blaze Spikes', '<stpc>')
    BindSpell('^0', 'Ice Spikes', '<stpc>')
    BindSpell('^-', 'Shock Spikes', '<stpc>')
    BindSpell('^=', 'Phalanx', '<stpc>')

    BindSpell('!`', 'Dispel', '<stnpc>')
    BindSpell('!1', 'Silence', '<stnpc>')
    BindSpell('!2', 'Gravity', '<stnpc>')
    BindSpell('!3', 'Paralyze II', '<stnpc>')
    BindSpell('!4', 'Slow II', '<stnpc>')
    BindSpell('!5', 'Blind II', '<stnpc>')
    BindSpell('!6', 'Sleep', '<stnpc>')
    BindSpell('!7', 'Sleep II', '<stnpc>')
    BindSpell('!8', 'Fire III', '<stnpc>')
    BindSpell('!9', 'Blizzard III', '<stnpc>')
    BindSpell('!0', 'Thunder III', '<stnpc>')
    BindSpell('!-', 'Bio II', '<stnpc>')
    BindSpell('!=', 'Poison II', '<stnpc>')
    BindSpell('!Backspace', 'Dia III', '<stnpc>')
    BindSpell('!\\', 'Distract', '<stnpc>')

    if (player.SubJob == 'BLM' and player.MainJobLevel > 49) or
       (player.SubJob == 'DRK' and player.MainJobLevel > 39) then
        BindSpell('^Backspace', 'Aspir', '<stnpc>')
    end

    for key, ws in pairs(RDMMacroWS) do BindWS(key, ws) end
end

local function ApplyNINDNCMacros(player)
    if not player then return end

    -- GLOBAL shared-job keys.
    --
    --   NIN main       : Utsusemi Ichi/Ni -> Alt-Minus / Alt-Equal
    --   DNC main       : Quickstep/Box Step -> Alt-Minus / Alt-Equal
    --   another main / NIN
    --                  : Utsusemi Ichi/Ni -> Alt-LBRACKET / Alt-RBRACKET
    --   another main / DNC
    --                  : Quickstep/Box Step -> Alt-LBRACKET / Alt-RBRACKET
    --   NIN/DNC        : Utsusemi -> brackets; Steps -> Minus / Equal
    --   DNC/NIN        : Steps -> brackets; Utsusemi -> Minus / Equal
    --
    -- This keeps the two shared skill families usable together while giving
    -- the main job priority when only one of NIN/DNC is present.
    local mainIsNIN = player.MainJob == 'NIN'
    local mainIsDNC = player.MainJob == 'DNC'
    local subIsNIN = player.SubJob == 'NIN'
    local subIsDNC = player.SubJob == 'DNC'
    local hasDNC = mainIsDNC or subIsDNC

    if mainIsNIN and subIsDNC then
        BindSpell('!LEFTBRACKET', 'Utsusemi: Ichi', '<stpc>')
        BindSpell('!RIGHTBRACKET', 'Utsusemi: Ni', '<stpc>')
        BindJA('!-', 'Quickstep')
        BindJA('!=', 'Box Step')
    elseif mainIsDNC and subIsNIN then
        BindJA('!LEFTBRACKET', 'Quickstep')
        BindJA('!RIGHTBRACKET', 'Box Step')
        BindSpell('!-', 'Utsusemi: Ichi', '<stpc>')
        BindSpell('!=', 'Utsusemi: Ni', '<stpc>')
    elseif mainIsNIN then
        BindSpell('!-', 'Utsusemi: Ichi', '<stpc>')
        BindSpell('!=', 'Utsusemi: Ni', '<stpc>')
    elseif mainIsDNC then
        BindJA('!-', 'Quickstep')
        BindJA('!=', 'Box Step')
    elseif subIsNIN then
        BindSpell('!LEFTBRACKET', 'Utsusemi: Ichi', '<stpc>')
        BindSpell('!RIGHTBRACKET', 'Utsusemi: Ni', '<stpc>')
    elseif subIsDNC then
        BindJA('!LEFTBRACKET', 'Quickstep')
        BindJA('!RIGHTBRACKET', 'Box Step')
    end

    -- Spectral Jig is available whenever DNC is main or support and occupies
    -- the established Alt-apostrophe slot without conflicting with the matrix.
    if hasDNC then
        QueueBind('!\'', '/recast "Spectral Jig";/ja "Spectral Jig" <stpc>')
    end
end

local BLUMacroWS = {
    ['^!`'] = 'Flat Blade', ['^!1'] = 'Fast Blade', ['^!2'] = 'Red Lotus Blade',
    ['^!3'] = 'Seraph Blade', ['^!4'] = 'Vorpal Blade', ['^!5'] = 'Spirits Within',
    ['^!6'] = 'Savage Blade', ['^!7'] = 'Requiescat',
}

local function ApplyBLUMacros(player)
    if not player or player.MainJob ~= 'BLU' then return end

    -- CTRL: healing / support / defensive / self-enhancement.
    -- The layout deliberately parallels RDM's CTRL philosophy while using
    -- BLU's actual level-75 functional vocabulary.
    BindSpell('^`', 'Wild Carrot', '<stpc>')
    BindSpell('^1', 'Magic Fruit', '<stpc>')
    BindSpell('^2', 'Plenilune Embrace', '<stpc>')
    BindSpell('^3', 'Healing Breeze', '<me>')
    BindSpell('^4', 'Battery Charge', '<me>')
    BindSpell('^5', 'Animating Wail', '<me>')
    BindSpell('^6', 'Diamondhide', '<me>')
    BindSpell('^7', 'Zephyr Mantle', '<me>')
    BindSpell('^8', 'Saline Coat', '<me>')
    BindSpell('^9', 'Orcish Counterstance', '<me>')
    BindSpell('^0', 'Cocoon', '<me>')
    BindSpell('^-', 'Harden Shell', '<me>')
    BindSpell('^=', 'Carcharian Verve', '<me>')

    -- Ctrl-Backspace retains the RDM-family "status removal" concept:
    -- Exuviation restores HP and removes a detrimental status effect.
    BindSpell('^Backspace', 'Exuviation', '<me>')

    -- CTRL-BACKSLASH is intentionally NOT bound here.  It remains the
    -- universal Dynamic Enspell key for any job running /RDM.
    --
    -- ALT: offensive / offensive utility / control / magical damage.
    BindSpell('!`', 'Head Butt', '<stnpc>')
    BindSpell('!1', 'Tail Slap', '<stnpc>')
    BindSpell('!2', 'Frenetic Rip', '<stnpc>')
    BindSpell('!3', 'Disseverment', '<stnpc>')
    BindSpell('!4', 'Quadratic Continuum', '<stnpc>')
    BindSpell('!5', 'Actinic Burst', '<stnpc>')
    BindSpell('!6', 'Sheep Song', '<stnpc>')
    BindSpell('!7', 'MP Drainkiss', '<stnpc>')
    BindSpell('!8', 'Acrid Stream', '<stnpc>')
    BindSpell('!9', 'Entomb', '<stnpc>')
    BindSpell('!0', 'Spectral Floe', '<stnpc>')
    BindSpell('!-', 'Anvil Lightning', '<stnpc>')
    BindSpell('!=', 'Blinding Fulgor', '<stnpc>')
    BindSpell('!Backspace', 'Tenebral Crush', '<stnpc>')

    for key, ws in pairs(BLUMacroWS) do BindWS(key, ws) end
end

local PLDMacroWS = {
    ['^!`'] = 'Flat Blade', ['^!1'] = 'Fast Blade', ['^!2'] = 'Burning Blade',
    ['^!3'] = 'Shining Blade', ['^!4'] = 'Savage Blade', ['^!5'] = 'Seraph Blade',
    ['^!6'] = 'Shining Strike', ['^!7'] = 'Seraph Strike', ['^!8'] = 'Brainshaker',
    ['^!9'] = 'True Strike', ['^!0'] = 'Judgment',
}

local function ApplyBLMMacros(player)
    if not player or player.MainJob ~= 'BLM' then return end

    for key, spell in pairs(BLM.Macro.Alt) do
        BindSpell(key, spell, '<stnpc>')
    end

    for key, spell in pairs(BLM.Macro.Ctrl) do
        BindSpell(key, spell, '<stpc>')
    end

    for key, ja in pairs(BLM.Macro.JA) do
        BindJA(key, ja, '<me>')
    end

    for key, ws in pairs(BLM.Macro.WS) do
        BindWS(key, ws)
    end
end

local function ApplyPLDMacros(player)
    if not player or player.MainJob ~= 'PLD' then return end
    BindSpell('^`', 'Cure', '<stpc>')
    BindSpell('^1', 'Cure II', '<stpc>')
    BindSpell('^2', 'Cure III', '<stpc>')
    BindJA('^3', 'Holy Circle', '<me>')
    BindSpell('!1', 'Flash', '<stnpc>')
    BindJA('!5', 'Provoke', '<stnpc>')
    -- Utsusemi shared-job keys are owned by ApplyNINDNCMacros().
    for key, ws in pairs(PLDMacroWS) do BindWS(key, ws) end
end

local function ApplySAMMacros(player)
    if not player or player.MainJob ~= 'SAM' then return end

    -- ALT: offensive / job abilities, ordered by acquisition level.
    for key, ja in pairs(SAM.Macro.Alt) do
        local target = ja == 'Shikikoyo' and '<stpc>' or '<me>'
        BindJA(key, ja, target)
    end

    -- CTRL: defensive / self abilities, ordered by acquisition level.
    for key, ja in pairs(SAM.Macro.Ctrl) do
        BindJA(key, ja, '<me>')
    end

    -- CTRL+ALT: Great Katana weapon skills.
    for key, ws in pairs(SAM.Macro.WS) do
        BindWS(key, ws)
    end
end

local function ApplyMNKMacros(player)
    if not player or player.MainJob ~= 'MNK' then return end

    -- ALT = offensive / accuracy JAs.
    for key, ja in pairs(MNK.Macro.Alt) do
        BindJA(key, ja, '<me>')
    end

    -- CTRL = defensive / recovery JAs.
    for key, ja in pairs(MNK.Macro.Ctrl) do
        BindJA(key, ja, '<me>')
    end

    -- CTRL+ALT = common hand-to-hand WS plus future weapon-gated level-75 WS.
    for key, ws in pairs(MNK.Macro.WS) do
        BindWS(key, ws)
    end
end

local function ApplyWHMMacros(player)
    if not player or player.MainJob ~= 'WHM' then return end

    -- CTRL: healing / support / defensive actions.
    BindSpell('^`', 'Cure III', '<stpc>')
    BindSpell('^1', 'Cure IV', '<stpc>')
    BindSpell('^2', 'Cure V', '<stpc>')
    BindSpell('^3', 'Curaga II', '<stpc>')
    BindSpell('^4', 'Curaga III', '<stpc>')
    BindSpell('^5', 'Haste', '<stpc>')
    BindSpell('^6', 'Erase', '<stpc>')
    BindSpell('^7', 'Blink', '<stpc>')
    BindSpell('^8', 'Stoneskin', '<stpc>')
    BindSpell('^9', 'Aquaveil', '<stpc>')
    BindSpell('^0', 'Raise III', '<stpc>')
    BindSpell('^-', 'Sacrifice', '<stpc>')
    BindSpell('^=', 'Esuna', '<stpc>')
    BindSpell('^Backspace', 'Auspice', '<me>')

    -- ALT: hostile magic / enfeebling / Divine damage.
    -- Alt-BACKTICK and Alt-2 are support-job-aware:
    --   /RDM : Dispel / Gravity
    --   /BLM : Aspir  / Blind
    -- Sleep II is not available through either subjob at WHM's normal
    -- subjob cap, so Alt-7 uses the highest shared Sleep spell instead.
    if player.SubJob == 'RDM' then
        BindSpell('!`', 'Dispel', '<stnpc>')
        BindSpell('!2', 'Gravity', '<stnpc>')
    elseif player.SubJob == 'BLM' then
        BindSpell('!`', 'Aspir', '<stnpc>')
        BindSpell('!2', 'Blind', '<stnpc>')
    end

    BindSpell('!1', 'Silence', '<stnpc>')
    BindSpell('!2', 'Blind', '<stnpc>')
    BindSpell('!3', 'Paralyze', '<stnpc>')
    BindSpell('!4', 'Slow', '<stnpc>')
    BindSpell('!5', 'Flash', '<stnpc>')
    BindSpell('!6', 'Repose', '<stnpc>')
    BindSpell('!7', 'Sleep II', '<stnpc>')
    BindSpell('!8', 'Banish II', '<stnpc>')
    BindSpell('!9', 'Banish III', '<stnpc>')
    BindSpell('!0', 'Holy', '<stnpc>')
    BindSpell('!-', 'Banishga', '<stnpc>')
    BindSpell('!=', 'Banishga II', '<stnpc>')
    BindSpell('!Backspace', 'Dia II', '<stnpc>')

    -- CTRL+ALT: WHM damage WS, including future relic/mythic/empyrean entries.
    BindWS('^!`', 'Rock Crusher')
    BindWS('^!1', 'Shell Crusher')
    BindWS('^!2', 'Full Swing')
    BindWS('^!3', 'Spirit Taker')
    BindWS('^!4', 'Hexa Strike')
    BindWS('^!5', 'Black Halo')
    BindWS('^!6', 'Shining Strike')
    BindWS('^!7', 'Seraph Strike')
    BindWS('^!8', 'Brainshaker')
    BindWS('^!9', 'Judgment')
    BindWS('^!0', 'True Strike')
    BindWS('^!-', 'Randgrith')
    BindWS('^!=', 'Mystic Boon')
end

local function ApplyTHFMacros(player)
    if not player or player.MainJob ~= 'THF' then return end

    for key, ja in pairs(THF.Macro.Alt) do
        local target = (ja == 'Accomplice' or ja == 'Collaborator') and '<stpc>' or '<stnpc>'
        if ja == 'Sneak Attack' or ja == 'Trick Attack' or ja == 'Bully'
            or ja == 'Feint' or ja == 'Conspirator' or ja == "Assassin's Charge"
        then
            target = '<me>'
        end
        BindJA(key, ja, target)
    end

    for key, ja in pairs(THF.Macro.Ctrl) do
        local target = (ja == 'Steal') and '<stnpc>' or '<me>'
        BindJA(key, ja, target)
    end

    for key, ws in pairs(THF.Macro.WS) do
        BindWS(key, ws)
    end
end

local function ApplyDRGMacros(player)
    if not player or player.MainJob ~= 'DRG' then return end
    for key, ja in pairs(DRG.Macro.Alt) do
        BindJA(key, ja, '<me>')
    end
    for key, ja in pairs(DRG.Macro.Ctrl) do
        BindJA(key, ja, '<me>')
    end
    for key, ws in pairs(DRG.Macro.WS) do
        BindWS(key, ws)
    end
end

local function ApplyDRKMacros(player)
    if not player or player.MainJob ~= 'DRK' then return end

    for key, spell in pairs(DRK.Macro.Alt) do
        BindSpell(key, spell, '<stnpc>')
    end

    for key, spell in pairs(DRK.Macro.Spells or {}) do
        BindSpell(key, spell, '<me>')
    end

    for key, ja in pairs(DRK.Macro.Ctrl) do
        local target = ja == 'Weapon Bash' and '<stnpc>' or '<me>'
        BindJA(key, ja, target)
    end

    for key, ws in pairs(DRK.Macro.WS) do
        BindWS(key, ws)
    end
end

local function ExecuteSMNBP(kind, index)
    local avatar = GetCurrentAvatarName()
    local avatarKey = avatar and avatar:gsub("[%s']", "") or nil

    -- Compact avatar lists used by the human-facing macro deck.  The database
    -- above remains the executable BP-to-set authority.
    local lists = {
        Garuda = { Rage = {'Claw','Predator Claws','Wind Blade','Aerial Blast'}, Ward = {'Aerial Armor','Whispering Wind','Hastega'} },
        Ifrit = { Rage = {'Punch','Double Punch','Burning Strike','Flaming Crush','Meteor Strike'}, Ward = {'Crimson Howl'} },
        Shiva = { Rage = {'Axe Kick','Double Slap','Rush','Heavenly Strike','Diamond Dust'}, Ward = {'Frost Armor','Sleepga (Blood Pact)'} },
        Titan = { Rage = {'Rock Throw','Rock Buster','Megalith Throw','Mountain Buster','Geocrush','Earthen Fury'}, Ward = {'Earthen Ward'} },
        Ramuh = { Rage = {'Shock Strike','Thunderspark','Chaotic Strike','Thunderstorm (Blood Pact)','Judgment Bolt'}, Ward = {'Rolling Thunder','Lightning Armor'} },
        Leviathan = { Rage = {'Barracuda Dive','Tail Whip','Spinning Dive','Grand Fall','Tidal Wave'}, Ward = {'Slowga','Spring Water'} },
        Fenrir = { Rage = {'Moonlit Charge','Crescent Fang','Eclipse Bite','Howling Moon'}, Ward = {'Lunar Cry','Lunar Roar','Ecliptic Growl','Ecliptic Howl'} },
        Diabolos = { Rage = {'Camisado','Nether Blast','Ruinous Omen'}, Ward = {'Somnolence','Nightmare','Ultimate Terror','Noctoshield','Dream Shroud'} },
        Carbuncle = { Rage = {'Poison Nails','Meteorite (Blood Pact)','Searing Light'}, Ward = {'Healing Ruby','Shining Ruby','Glittering Ruby','Healing Ruby II'} },
        ['Cait Sith'] = { Rage = {'Regal Scratch','Regal Gash','Level ? Holy'}, Ward = {'Mewing Lullaby','Raise II (Blood Pact)','Reraise II (Blood Pact)'} },
    }

    local data = avatar and lists[avatar]
    local list = data and data[kind]
    local pact = list and list[index]
    if not pact then
        gFunc.Message('[SMN] No mapped ' .. kind .. ' BP for current avatar/key.')
        return
    end

    local setName = SMN.PET[pact]
    if setName then
        gFunc.EquipSet(GetSet(SMN, setName))
    end

    local target = kind == 'Rage' and '<stnpc>' or '<me>'
    AshitaCore:GetChatManager():QueueCommand(1, '/recast "' .. pact .. '";/pet "' .. pact .. '" ' .. target)
end

local function ApplySMNMacros(player)
    if not player or player.MainJob ~= 'SMN' then return end
    QueueBind('!Backspace', '/lac fwd smnstaff')
    QueueBind('!`', '/lac fwd smnrage1')
    for i, key in ipairs({'!1','!2','!3','!4','!5','!6','!7','!8','!9','!0','!-','!='}) do
        QueueBind(key, '/lac fwd smnrage' .. (i + 1))
    end
    QueueBind('^`', '/lac fwd smnward1')
    for i, key in ipairs({'^1','^2','^3','^4','^5','^6','^7','^8','^9','^0','^-','^='}) do
        QueueBind(key, '/lac fwd smnward' .. (i + 1))
    end
end

local lastMacroSignature = nil

ApplyMacroDeck = function(player, force)
    local signature = player and table.concat({
        tostring(player.MainJob or 'None'),
        tostring(player.SubJob or 'None'),
        tostring(player.MainJobLevel or '0'),
        tostring(player.SubJobLevel or '0'),
    }, '|') or 'None'

    -- Do not clear/rebind the keyboard every HandleDefault poll.  Rebuild only
    -- when the job/subjob/level context changes or when lifecycle code forces it.
    if not force and signature == lastMacroSignature then
        return
    end

    macroDeck.Ctrl = {}
    macroDeck.Alt = {}
    macroDeck.CtrlAlt = {}

    ClearOwnedMacroBinds()
    ApplyWHMMacros(player)
    ApplyTHFMacros(player)
    ApplyRDMMacros(player)
    ApplyBLUMacros(player)
    ApplyBLMMacros(player)
    ApplyPLDMacros(player)
    ApplySAMMacros(player)
    ApplyMNKMacros(player)
    ApplyDRGMacros(player)
    ApplyDRKMacros(player)
    ApplySMNMacros(player)

    -- Shared NIN/DNC bindings are deliberately installed LAST so job-local
    -- macros cannot overwrite the hybrid-key matrix.  Ctrl-BACKSLASH remains
    -- exclusively owned by UpdateEnspellBind().
    ApplyNINDNCMacros(player)

    lastMacroSignature = signature
end

-- ============================================================================
-- PROFILE LIFECYCLE
-- ============================================================================

profile.OnLoad = function()
    gSettings.AllowAddSet = true

    AshitaCore:GetChatManager():QueueCommand(
        -1,
        "/bind " .. CONFIG.PDTKey .. " /lac fwd pdt"
    )

    AshitaCore:GetChatManager():QueueCommand(
        -1,
        "/bind " .. CONFIG.MDTKey .. " /lac fwd mdt"
    )

    -- Alt-F12 is a reserved global control, not part of the ordinary job macro deck.
    AshitaCore:GetChatManager():QueueCommand(
        -1,
        "/bind " .. CONFIG.EngagedWeaponToggleKey
            .. " down /lac fwd toggleengagedweapons"
    )

    AshitaCore:GetChatManager():QueueCommand(
        -1,
        "/bind " .. CONFIG.MacroDisplayKey .. " down /lac fwd macros"
    )

    local player = gData.GetPlayer()
    lastEngagedState = player and player.Status == "Engaged" or false
    ApplyMacroDeck(player, true)
    UpdateEnspellBind(true)
end

profile.OnUnload = function()
    if weaponLocked then
        gFunc.Enable("Main")
        gFunc.Enable("Sub")
        weaponLocked = false
    end

    AshitaCore:GetChatManager():QueueCommand(-1, "/unbind " .. CONFIG.PDTKey)
    AshitaCore:GetChatManager():QueueCommand(-1, "/unbind " .. CONFIG.MDTKey)
    AshitaCore:GetChatManager():QueueCommand(-1, "/unbind " .. CONFIG.EngagedWeaponToggleKey .. " down")
    AshitaCore:GetChatManager():QueueCommand(-1, "/unbind " .. CONFIG.MacroDisplayKey .. " down")
    ClearOwnedMacroBinds()
    macroDeck.Ctrl = {}
    macroDeck.Alt = {}
    macroDeck.CtrlAlt = {}
    lastEngagedState = nil
end

profile.OnZone = function()
    local player = gData.GetPlayer()
    lastEngagedState = player and player.Status == "Engaged" or false
    ApplyMacroDeck(player, true)
    UpdateEnspellBind(true)

    local env = gData.GetEnvironment()
    if env then
        AshitaCore:GetChatManager():QueueCommand(
            1,
            "/echo [Universal.lua] Weather: "
                .. tostring(env.Weather)
                .. " | Day: "
                .. tostring(env.DayElement)
        )
    end
end

-- ============================================================================
-- HUMAN EDITOR NOTES
-- ============================================================================
-- ADD/CHANGE GEAR:
--   Find the appropriate JOB.Sets section above and edit the named slots.
--
-- ADD A JOB ABILITY:
--   1. Add the equipment to JOBS.WAR.Sets.MyAbility.
--   2. Add JOBS.WAR.JA["Berserk"] = "MyAbility".
--
-- ADD A SPELL:
--   1. Add the appropriate set to JOBS.RDM.Sets.
--   2. Add JOBS.RDM.MA["Spell Name"] = "SetName".
--
-- ADD A WEAPONSKILL:
--   1. Add JOBS.<JOB>.WS["WS Name"] = "WS_SetName" inside that job's own
--      character-specific section.  Do not create a new generic starter block.
--   2. Add the WS to SkillchainWeaponskills only if it actually has a
--      skillchain property.
--
-- ADD PET ACTION:
--   1. Add the set to JOBS.SMN.Sets / JOBS.BST.Sets / JOBS.DRG.Sets /
--      JOBS.PUP.Sets.
--   2. Add JOBS.<JOB>.PET["Action Name"] = "SetName".
--
-- ENGAGED WEAPON TOGGLE:
--   Alt-F12 toggles automatic Engaged-state weapon selection globally.
--   ON  = use the current job's configured automatic Main/Sub weapons.
--   OFF = leave Main/Sub alone so the player can manually choose weapons.
--         The 50-TP weapon lock remains independent of this toggle.
--
-- MOVEMENT:
--   Blood Cuisses are selected for the eight specified jobs at level 73+.
--   Everyone else gets Track Pants +1.  Movement is a STATE OVERRIDE: while
--   moving, the normal Idle / Engaged / Resting armor set is suppressed and
--   only the movement-specific set is submitted.
--
-- NO AUTONOMOUS ACTIONS:
--   This profile never casts, weaponskills, uses job abilities, or deploys a
--   pet on its own.  It only changes equipment in response to actions the
--   player initiates.
-- ============================================================================

return profile
