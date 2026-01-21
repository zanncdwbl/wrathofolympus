---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.

-- These are some sample code snippets of what you can do with our modding framework:
local file = rom.path.combine(rom.paths.Content, "Game/Text/en/ShellText.en.sjson")
sjson.hook(file, function(data)
	return sjson_ShellText(data)
end)

modutil.mod.Path.Wrap("SetupMap", function(base, ...)
	prefix_SetupMap()
	return base(...)
end)

local HelpTextFile = rom.path.combine(rom.paths.Content, "Game/Text/en/HelpText.en.sjson")
local PlayerProjectilesFile = rom.path.combine(rom.paths.Content, "Game/Projectiles/PlayerProjectiles.sjson")
local Order = { "Id", "InheritFrom", "DisplayName", "Description" }

local not_public = {}
public["not"] = not_public

mod.ZeusWrathBoon_CombatText = sjson.to_object({
	Id = "ZeusWrath_CombatText",
	DisplayName = "{#CombatTextHighlightFormat}{$TempTextData.BoonName} {#Prev}{$TempTextData.Amount}x!",
}, Order)

sjson.hook(HelpTextFile, function(data)
	table.insert(data.Texts, mod.ZeusWrathBoon_CombatText)
end)

gods.CreateCustomRarity({
	Name = "Wrath",
	BlockStacking = true,
	BlockInRunRarify = true,
	BlockMenuRarify = true,
	RarityLevels = {
		Legendary = {
			MinMultiplier = 1,
			MaxMultiplier = 1,
		},
	},
	Display = {
		PathOverrides = {
			framePath = true,
			backingPath = true,
		},
		CustomRarityColor = Color.AresVoice,
		framePath = "Wistiti-WrathOfOlympusBoonFrames\\wrath_1",
		backingPath = "Wistiti-WrathOfOlympusBoonFrames\\BoonSlot_Wrath",
	},
})
local wrathTrait = gods.GetInternalRarityName("Wrath")

--[[ 
uid, internal, charactername ,legendary, rarity, slot, blockstacking,  statlines, extractval, elements, displayName
extrafields, boonIconPath, requirements, flavourtext
]]

gods.CreateBoon({
	pluginGUID = _PLUGIN.guid,
	characterName = "Poseidon",
	internalBoonName = "PoseidonWrathBoon",
	isLegendary = false,
	InheritFrom = {
		wrathTrait,
		"WaterBoon",
	},
	addToExistingGod = { boonPosition = 10 },
	reuseBaseIcons = true,
	BlockStacking = true,

	displayName = "Torrential Submersion",
	description = "Your splash effects fire your waves from {$TraitData.OmegaPoseidonProjectileBoon.Name} with more {$Keywords.BaseDamage} at no extra cost.",
	StatLines = { "BonusOceanSwellStatDisplay1" },
	customStatLine = {
		ID = "BonusOceanSwellStatDisplay1",
		displayName = "{!Icons.Bullet}{#PropertyFormat}Wave Bonus Damage:",
		description = "{#UpgradeFormat}{$TooltipData.StatDisplay1}",
	},
	requirements = {
		OneFromEachSet = {
			{ "PoseidonWeaponBoon", "PoseidonSpecialBoon", "PoseidonCastBoon" },
			{ "OmegaPoseidonProjectileBoon" },
			{ "PoseidonStatusBoon", "PoseidonExCastBoon", "EncounterStartOffenseBuffBoon" },
		},
	},
	flavourText = "The sea covers most of the world's surface already; pray it does not cover the rest.",
	boonIconPath = "GUI\\Screens\\BoonIcons\\Poseidon_39",

	ExtractValues = {
		{
			Key = "ReportedWaveMultiplier",
			ExtractAs = "TooltipData",
			Format = "PercentDelta",
		},
	},

	ExtraFields = {
		AddOutgoingDamageModifiers = {
			ValidProjectiles = { "PoseidonOmegaWave" },
			ValidWaveDamageAddition = {
				BaseValue = 2.00, -- boon description only
				SourceIsMultiplier = true,
			},
			ReportValues = { ReportedWaveMultiplier = "ValidWaveDamageAddition" },
		},
		OnEnemyDamagedAction = {
			FunctionName = "PoseidonWrath",
			ValidProjectiles = 
			{
				"PoseidonSplashSplinter",
				"PoseidonCastSplashSplinter",
				"PoseidonSplashBackSplinter",
			},
			Args = {
				ProjectileName = "PoseidonOmegaWave",
				FallbackWeaponDamageMultiplier = 1.0,
				DamageMultiplier = 2.0,
				ImpactVelocity = 600,
			},
		},
	},
})

gods.CreateBoon({
	pluginGUID = _PLUGIN.guid,
	characterName = "Ares",
	internalBoonName = "AresWrathBoon",
	isLegendary = false,
	InheritFrom = {
		wrathTrait,
		"EarthBoon",
	},
	addToExistingGod = { boonPosition = 10 },
	reuseBaseIcons = true,
	BlockStacking = true,

	displayName = "Ferocious Ichor",
	description = "Gain a chance to deal {$TraitData.AresStatusDoubleDamageBoon.DamagePercent:F} damage based on your current {!Icons.BloodDropWithCountIcon} count.",
	StatLines = { "PlasmaDoubleDamageStatDisplay1" },
	TrayStatLines = { "PlasmaDoubleDamageStatDisplay2" },
	customStatLine = {
		{
			ID = "PlasmaDoubleDamageStatDisplay1",
			displayName = "{!Icons.Bullet}{#PropertyFormat}Chance per Collected Plasma:",
			description = "{#UpgradeFormat}{$TooltipData.StatDisplay1}",
		},
		{
			ID = "PlasmaDoubleDamageStatDisplay2",
			displayName = "{!Icons.Bullet}{#PropertyFormat}Current Double Damage Chance:",
			description = "{#UpgradeFormat}{$TooltipData.ExtractData.CurrentMultiplier:P}",
		},
	},
	requirements = {
		OneFromEachSet = {
			{ "AresWeaponBoon", "AresSpecialBoon" },
			{ "AresManaBoon", "BloodDropRevengeBoon", "RendBloodDropBoon" },
			{ "AresStatusDoubleDamageBoon", "MissingHealthCritBoon" },
		},
	},
	flavourText = "If the sight of blood was truly so revolting, why then should it have such a striking hue?",
	boonIconPath = "GUI\\Screens\\BoonIcons\\Ares_34",

	ExtractValues = {
		{
			Key = "ReportedPlasmaCritMultiplier",
			ExtractAs = "Chance",
			Format = "LuckModifiedPercent",
			DecimalPlaces = 2,
			HideSigns = true,
		},
		{
			Key = "ReportedPlasmaCritMultiplier",
			ExtractAs = "CurrentMultiplier",
			Format = "LuckModifiedPercent",
			MultiplyByPlasmaCount = true,
			DecimalPlaces = 2,
			SkipAutoExtract = true,
			HideSigns = true,
		},
	},

	ExtraFields = {
		AddOutgoingDoubleDamageModifiers = {
			IncreasingPlasmaCritChance = {
				BaseValue = 0.005,
				DecimalPlaces = 4,
			},
			ReportValues = { ReportedPlasmaCritMultiplier = "IncreasingPlasmaCritChance" },
		},
	},
})

gods.CreateBoon({
	pluginGUID = _PLUGIN.guid,
	characterName = "Hephaestus",
	internalBoonName = "HephWrathBoon",
	isLegendary = false,
	InheritFrom = {
		wrathTrait,
		"CostumeTrait", -- necessary for the boon's functionality
		"FireBoon",
	},
	addToExistingGod = { boonPosition = 10 },
	reuseBaseIcons = true,
	BlockStacking = true,

	displayName = "Eruptive Plating",
	description = "After you take damage while having {!Icons.ArmorTotal}, create a blast that deals {$TooltipData.ExtractData.Damage} damage in an area.",
	StatLines = { "BlastRevengeStatDisplay1" },
	customStatLine = {
		ID = "BlastRevengeStatDisplay1",
		displayName = "{!Icons.Bullet}{#PropertyFormat}Armor Gained Now:",
		description = "{#UpgradeFormat}+{$TooltipData.ExtractData.TooltipAmount}",
	},
	requirements = {
		OneFromEachSet = {
			{ "HephaestusWeaponBoon", "HephaestusSpecialBoon", "HephaestusSprintBoon" },
			{ "HeavyArmorBoon", "ArmorBoon", "EncounterStartDefenseBuffBoon" },
			{ "HephaestusManaBoon", "ManaToHealthBoon" },
		},
	},
	flavourText = "The roughest hands can often be the ones to produce the most immaculate results.",
	boonIconPath = "GUI\\Screens\\BoonIcons\\Hephaestus_29",

	ExtractValues = {
		{
			Key = "ReportedBlastDamageMultiplier",
			ExtractAs = "Damage",
			Format = "MultiplyByBase",
			BaseType = "Projectile",
			BaseName = "MassiveSlamBlast",
			BaseProperty = "Damage",
			SkipAutoExtract = true,
			DecimalPlaces = 1,
		},
		{
			Key = "ReportedExtraArmor",
			ExtractAs = "TooltipAmount",
		},
	},

	ExtraFields = {
		Frame = "Unity",
		Invincible = true,
		OnSelfDamagedFunction = {
			Name = "rom.mods." .. _PLUGIN.guid .. ".not.HephRetaliate",
			FunctionArgs = {
				ProjectileName = "MassiveSlamBlast",
				Cooldown = 0.4,
				BlastDelay = 0.08,
				DamageMultiplier = 3.0,
				ReportValues = {
					ReportedBlastDamageMultiplier = "DamageMultiplier",
				},
			},
		},
		AcquireFunctionName = "HeavyArmorInitialPresentation",
		SetupFunctions = {
			{
				Name = "CostumeArmor",
				Args = {
					Source = "Tradeoff",
					Delay = 0.75,
					BaseAmount = {
						BaseValue = 100,
					},
					ReportValues = {
						ReportedExtraArmor = "BaseAmount",
					},
				},
			},
		},
	},
})

gods.CreateBoon({
	pluginGUID = _PLUGIN.guid,
	characterName = "Zeus",
	internalBoonName = "ZeusWrathBoon",
	isLegendary = false,
	InheritFrom = {
		wrathTrait,
		"AirBoon",
	},
	addToExistingGod = { boonPosition = 10 },
	reuseBaseIcons = true,
	BlockStacking = true,

	displayName = "Spurned Patriarch",
	description = "Activating {$Keywords.Echo} on foes strikes them with {#BoldFormatGraft}{$TooltipData.ExtractData.BoltsNumber} {#Prev}lightning bolts, each dealing {#BoldFormatGraft}{$TooltipData.ExtractData.WrathBoltDamage} {#Prev}damage.",
	StatLines = { "BlitzVengeanceStatDisplay1" },
	customStatLine = {
		ID = "BlitzVengeanceStatDisplay1",
		displayName = "{!Icons.Bullet}{#PropertyFormat}Double Strike Chance:",
		description = "{#UpgradeFormat}{$TooltipData.StatDisplay1}",
	},
	requirements = {
		OneFromEachSet = {
			{ "SuperSacrificeBoonHera" },
			{ "ZeusWeaponBoon", "ZeusSpecialBoon" },
		},
	},
	flavourText = "The lightning bolt forever remains a symbol of the impulsive power of the Lord of Olympus.",
	boonIconPath = "GUI\\Screens\\BoonIcons\\Zeus_33",

	ExtractValues = {
		{
			Key = "ReportedBoltChance",
			ExtractAs = "DoubleChance",
			Format = "LuckModifiedPercent",
		},
		{
			Key = "ReportedMinStrikes",
			ExtractAs = "BoltsNumber",
			SkipAutoExtract = true,
		},
		{
			Key = "BoltDamage",
			ExtractAs = "WrathBoltDamage",
			SkipAutoExtract = true,
		},
		{
			ExtractAs = "EchoDuration",
			SkipAutoExtract = true,
			External = true,
			BaseType = "EffectData",
			BaseName = "DamageEchoEffect",
			BaseProperty = "Duration",
		},
		{
			ExtractAs = "EchoThreshold",
			SkipAutoExtract = true,
			External = true,
			BaseType = "EffectData",
			BaseName = "DamageEchoEffect",
			BaseProperty = "DamageThreshold",
		},
	},

	ExtraFields = {
		BoltDamage = 100, -- used for description only
		OnEnemyDamagedAction = {
			FunctionName = "ZeusWrath",
			ValidProjectiles = { "ZeusEchoStrike" },
			Args = {
				ProjectileName = "ZeusRetaliateStrike",
				DoubleBoltChance = 0.4,
				MinStrikes = 3,
				MaxStrikes = {
					BaseValue = 6,
					MinValue = 3,
					IdenticalMultiplier = {
						Value = -0.5,
					},
				},
				ReportValues = {
					ReportedMaxStrikes = "MaxStrikes",
					ReportedMinStrikes = "MinStrikes",
					ReportedBoltChance = "DoubleBoltChance",
				},
			},
		},
	},
})

gods.CreateBoon({
	pluginGUID = _PLUGIN.guid,
	characterName = "Aphrodite",
	internalBoonName = "AphroWrathBoon",
	isLegendary = false,
	InheritFrom = {
		wrathTrait,
		"WaterBoon",
	},
	addToExistingGod = { boonPosition = 10 },
	reuseBaseIcons = true,
	BlockStacking = true,

	displayName = "Lustful Confession",
	description = "Your {$Keywords.HeartBurstPlural} are stronger and fire your {$Keywords.CastEX} upon striking a foe.",
	StatLines = { "BonusHeartthrobDamageStatDisplay1" },
	customStatLine = {
		ID = "BonusHeartthrobDamageStatDisplay1",
		displayName = "{!Icons.Bullet}{#PropertyFormat}Bonus Heartthrob Damage:",
		description = "{#UpgradeFormat}{$TooltipData.StatDisplay1}",
	},
	requirements = {
		OneFromEachSet = {
			{ "AphroditeWeaponBoon", "AphroditeSpecialBoon" },
			{ "ManaBurstBoon" },
			{ "HighHealthOffenseBoon", "HealthRewardBonusBoon", "FocusRawDamageBoon" },
		},
	},
	flavourText = "Love and beauty can be so overwhelming as to strike each of the senses numb.",
	boonIconPath = "GUI\\Screens\\BoonIcons\\Aphrodite_40",

	ExtractValues = {
		{
			Key = "ReportedHeartthrobMultiplier",
			ExtractAs = "HeartthrobMultiplier",
			Format = "PercentDelta",
		},
		{
			ExtractAs = "Duration",
			SkipAutoExtract = true,
			External = true,
			BaseType = "ProjectileBase",
			BaseName = "AphroditeBurst",
			BaseProperty = "Fuse",
		},
	},

	ExtraFields = {
		HeartthrobBonusDamageModifiers = {
			ValidProjectiles = "AphroditeBurst",
			HeartthrobBonusMultiplier = {
				BaseValue = 1.5,
			},
			SourceIsMultiplier = true,
			ReportValues = { ReportedHeartthrobMultiplier = "HeartthrobBonusMultiplier" },
		},
	},
})

gods.CreateBoon({
	pluginGUID = _PLUGIN.guid,
	characterName = "Hestia",
	internalBoonName = "HestiaWrathBoon",
	isLegendary = false,
	InheritFrom = {
		wrathTrait,
		"FireBoon",
	},
	addToExistingGod = { boonPosition = 10 },
	reuseBaseIcons = true,
	BlockStacking = true,

	displayName = "Cindered Ritual",
	description = "Foes combust when their inflicted {$Keywords.Burn} exceeds their current remaining {!Icons.EnemyHealth}.",
	StatLines = { "CombustThresholdStatDisplay1" },
	customStatLine = {
		ID = "CombustThresholdStatDisplay1",
		displayName = "{!Icons.Bullet}{#PropertyFormat}Health Threshold for Combustion:",
		description = "{#UpgradeFormat}{$TooltipData.StatDisplay1}",
	},
	requirements = {
		OneFromEachSet = {
			{ "HestiaWeaponBoon", "HestiaSpecialBoon", "HestiaCastBoon" },
			{ "OmegaZeroBurnBoon", "BurnArmorBoon" },
			{ "BurnExplodeBoon", "AloneDamageBoon" },
		},
	},
	flavourText = "Flames can be a source of warmth and comfort, provided one is careful not to draw too close.",
	boonIconPath = "GUI\\Screens\\BoonIcons\\Hestia_39",

	ExtractValues = {
		{
			Key = "ReportedThreshold",
			ExtractAs = "CombustThreshold",
			Format = "Percent",
			HideSigns = true,
		},
		{
			ExtractAs = "BurnRate",
			SkipAutoExtract = true,
			External = true,
			BaseType = "EffectLuaData",
			BaseName = "BurnEffect",
			BaseProperty = "DamagePerSecond",
			DecimalPlaces = 1,
		},
	},

	ExtraFields = {
		OnDamageEnemyFunction = {
			FunctionName = "BurnInstaKill",
			FunctionArgs = {
				ExecuteImmunities = {
					Prometheus = {
						GameStateRequirement = {
							{
								Path = { "GameState", "ShrineUpgrades", "BossDifficultyShrineUpgrade" },
								Comparison = ">=",
								Value = 3,
							},
						}
					}
				},
				CombustDeathThreshold = 0.4,
				ProjectileName = "IcarusExplosion",
				DamageMultiplier = 0,
				ReportValues = 
				{ 
					ReportedThreshold = "CombustDeathThreshold",
				}
			},
		},
	},
})

gods.CreateBoon({
	pluginGUID = _PLUGIN.guid,
	characterName = "Apollo",
	internalBoonName = "ApolloWrathBoon",
	isLegendary = false,
	InheritFrom = {
		wrathTrait,
		"AirBoon",
	},
	addToExistingGod = { boonPosition = 10 },
	reuseBaseIcons = true,
	BlockStacking = true,

	displayName = "Critical Fiasco",
	description = "Whenever {$Keywords.Blind} causes a foe to miss, it takes {#BoldFormatGraft}{$TooltipData.ExtractData.MissDamage} {#Prev}damage and becomes {$Keywords.Mark}.",
	StatLines = { "DazeCritStatDisplay1" },
	customStatLine = {
		ID = "DazeCritStatDisplay1",
		displayName = "{!Icons.Bullet}{#PropertyFormat}Critical Chance vs. Daze:",
		description = "{#UpgradeFormat}{$TooltipData.StatDisplay1}",
	},
	requirements = {
		OneFromEachSet = {
			{ "ApolloWeaponBoon", "ApolloSpecialBoon" },
			{ "ApolloCastBoon", "ApolloSprintBoon" },
			{ "BlindChanceBoon", "ApolloRetaliateBoon" },
		},
	},
	flavourText = "We cannot all be the best at what we do, for the god of light has much of it covered.",
	boonIconPath = "GUI\\Screens\\BoonIcons\\Apollo_36",

	ExtractValues = {
		{
			Key = "DazeMissDamage",
			ExtractAs = "MissDamage",
			SkipAutoExtract = true,
		},
		{
			ExtractAs = "BlindChance",
			SkipAutoExtract = true,
			External = true,
			BaseType = "EffectData",
			BaseName = "BlindEffect",
			BaseProperty = "MissChance",
			Format = "Percent"
		},
		{
			ExtractAs = "BlindDuration",
			SkipAutoExtract = true,
			External = true,
			BaseType = "EffectData",
			BaseName = "BlindEffect",
			BaseProperty = "Duration",
		},
		{
			Key = "ReportedCritBonus",
			ExtractAs = "CritBonus",
			Format = "LuckModifiedPercent"
		},
		{
			External = true,
			BaseType = "EffectData",
			BaseName = "ArtemisBoonHuntersMark",
			BaseProperty = "Duration",
			ExtractAs = "TooltipMarkDuration",
			SkipAutoExtract = true,
		},
		{
			External = true,
			BaseType = "EffectLuaData",
			BaseName = "ArtemisBoonHuntersMark",
			BaseProperty = "CritVulnerability",
			ExtractAs = "CritRate",
			Format = "Percent",
			SkipAutoExtract = true,
		}
	},

	ExtraFields = {
		DazeMissDamage = 100, -- used for description only
		OnDodgeFunction = 
		{
			FunctionName = "ApolloWrath",
			RunOnce = true,
			FunctionArgs =
			{
				ProjectileName = "ApolloRetaliateStrike",
				EffectName = "ArtemisBoonHuntersMark",
				DamageMultiplier =
				{
					BaseValue = 2,
					MinMultiplier = 0.1,
					IdenticalMultiplier =
					{
						Value = -0.5,
					},
				},
				ReportValues = { ReportedMissDamage = "DamageMultiplier" },
			},
		},
		AddOutgoingCritModifiers =
		{
			Chance = { BaseValue = 0.1 },
			ValidActiveEffects = { "BlindEffect" },
			ReportValues = { ReportedCritBonus = "Chance"},
		},
	},
})

gods.CreateBoon({
	pluginGUID = _PLUGIN.guid,
	characterName = "Hera",
	internalBoonName = "HeraWrathBoon",
	isLegendary = false,
	InheritFrom = {
		wrathTrait,
		"AetherBoon",
	},
	addToExistingGod = { boonPosition = 10 },
	reuseBaseIcons = true,
	BlockStacking = true,

	displayName = "Perfidious Matrimony",
	description = "Your {$Keywords.CastSet} summon a sturdy {$Keywords.Link}-afflicted critter in the binding circle.",
	StatLines = { "HitchPunchingBagStatDisplay1" },
	customStatLine = {
		ID = "HitchPunchingBagStatDisplay1",
		displayName = "{!Icons.Bullet}{#PropertyFormat}Hitch Damage from Critter:",
		description = "{#UpgradeFormat}{$TooltipData.StatDisplay1}",
	},
	requirements = {
		OneFromEachSet = {
			{ "SuperSacrificeBoonZeus" },
			{ "HeraWeaponBoon", "HeraSpecialBoon", "HeraCastBoon", "HeraSprintBoon" },
		},
	},
	flavourText = "The more disparate personalities a family contains, the stronger it can be; thus says the Queen.",
	boonIconPath = "GUI\\Screens\\BoonIcons\\Hera_37",

	ExtractValues = {
		{
			Key = "ReportedHitchBonus",
			ExtractAs = "TooltipData",
			Format = "PercentDelta",
		},
		{
			ExtractAs = "DamageShareDuration",
			SkipAutoExtract = true,
			External = true,
			BaseType = "EffectData",
			BaseName = "DamageShareEffect",
			BaseProperty = "Duration",
		},
		{
			ExtractAs = "DamageShareAmount",
			SkipAutoExtract = true,
			External = true,
			BaseType = "EffectData",
			BaseName = "DamageShareEffect",
			BaseProperty = "Amount",
			Format = "Percent",
		},
	},

	ExtraFields = {
		OnWeaponFiredFunctions =
		{
			ValidWeapons =  WeaponSets.HeroNonPhysicalWeapons,
			FunctionName = "HeraMoutonSpawn",
			FunctionArgs =
			{
				SpawnedEnemy = "Sheep",
				EffectName = "DamageShareEffect",
				MaxHealthMultiplier = 2,
				StartDelay = 0.2,
				HitchShareAmountBonus = 2.0, --used for description only
				ReportValues = { ReportedHitchBonus = "HitchShareAmountBonus" },
			},
		},
	},
})

gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    characterName = "Demeter",
	internalBoonName = "DemeterWrathBoon",
    isLegendary = false,
	InheritFrom = {
		wrathTrait,
		"WaterBoon",
	},
    addToExistingGod = { boonPosition = 10 },
	reuseBaseIcons = true,
    BlockStacking = true,

    displayName = "Wrath of Demeter",
    description = "After the {$Keywords.Root} duration on your foes expires, they suffer from Frostbite.",
	StatLines = { "FrostbiteBurstStatDisplay1" },
    customStatLine = {
        Id = "FrostbiteBurstStatDisplay1",
        displayName = "{!Icons.Bullet}{#PropertyFormat}Frostbite Damage:",
        description = "{#UpgradeFormat}{$TooltipData.StatDisplay1} {#Prev}{#ItalicFormat}(per 1 Sec.)",
    },
	requirements =
	{
		OneFromEachSet =
		{
			{ "DemeterWeaponBoon", "DemeterSpecialBoon", "DemeterCastBoon" },
			{ "DemeterSprintBoon", "CastNovaBoon" },
			{ "SlowExAttackBoon", "CastAttachBoon" },
		},
	},
    flavourText = "Life is resilient, and can take root even in cold, harsh environments... but only to a point.",
    boonIconPath = "GUI\\Screens\\BoonIcons\\Demeter_32",
    
	ExtractValues =
	{
		{
			Key = "ReportedFrostbiteMultiplier",
			ExtractAs = "Damage",
			Format = "MultiplyByBase",
			BaseType = "Projectile",
			BaseName = "FrostbiteProjectile",
			BaseProperty = "Damage",
		},
		{
			ExtractAs = "ChillDuration",
			SkipAutoExtract = true,
			External = true,
			BaseType = "EffectData",
			BaseName = "ChillEffect",
			BaseProperty = "Duration",
		},
		{
			ExtractAs = "ChillActiveDuration",
			SkipAutoExtract = true,
			External = true,
			BaseType = "EffectData",
			BaseName = "ChillEffect",
			BaseProperty = "ActiveDuration",
		},
	},

	ExtraFields = 
	{
		OnEnemyDamagedAction =
		{
			FunctionName = "FrostbiteDamage",
			FunctionArgs =
			{
				EffectName = "ChillEffect",
				FrostbiteMultiplier = 75,
			},
			ReportedValues =
			{
				ReportedFrostbiteMultiplier = "FrostbiteMultipier",
			},
		},
    },
})

-- Function Library --

-- PoseidonWrath custom function
modutil.mod.Path.Override("PoseidonWrath", function(unit, functionArgs, triggerArgs)
	-- If Hero doesnt have Ocean Swell, dont crash, just dont do it
	if not HeroHasTrait("OmegaPoseidonProjectileBoon") then
		return
	end

	local traitData = GetHeroTrait("OmegaPoseidonProjectileBoon")

	-- This does nothing currently, but we can for example extract if red color must be used if trigger projectile is Ares one 
	local dataProperties = GetProjectileProperty({ ProjectileId = triggerArgs.ProjectileId, Property = "DataProperties" })

	local omegaPoseidonProjectile = 
	{
		Name = functionArgs.ProjectileName,
		Id = CurrentRun.Hero.ObjectId,
		Angle = triggerArgs.ImpactAngle,
		DestinationId = unit.ObjectId,
		FireFromTarget = true,
		DamageMultiplier = (traitData.OnWeaponFiredFunctions.FunctionArgs.DamageMultiplier or functionArgs.FallbackWeaponDamageMultiplier) * functionArgs.DamageMultiplier,
		DataProperties =
		{
			StartFx = dataProperties.StartFx,
			ImpactVelocity = triggerArgs.ImpactVelocity or functionArgs.ImpactVelocity,
			StartDelay = 0
		},
		ProjectileCap = 2,
	}

	local count = 1
	for i=1, count do
		CreateProjectileFromUnit(omegaPoseidonProjectile)
		local doubleChance = GetTotalHeroTraitValue("DoubleOlympianProjectileChance") * GetTotalHeroTraitValue( "LuckMultiplier", { IsMultiplier = true })
		if RandomChance(doubleChance) then
			wait( GetTotalHeroTraitValue("DoubleOlympianProjectileInterval" ))
			CreateProjectileFromUnit(omegaPoseidonProjectile)
		end
	end
	
end)

-- AresWrath custom function
modutil.mod.Path.Wrap("CalculateDoubleDamageChance", function(baseFunc, attacker, victim, weaponData, triggerArgs)
	baseFunc(attacker, victim, weaponData, triggerArgs)
	return CalculatePlasmaDoubleDamageChance(attacker, victim, weaponData, triggerArgs)
end)

function CalculatePlasmaDoubleDamageChance( attacker, victim, weaponData, triggerArgs )
	--[[if not HeroHasTrait(gods.GetInternalBoonName("AresWrathBoon")) then
		return
	end]]--
	if attacker ~= nil and attacker.OutgoingDoubleDamageModifiers ~= nil then
		local appliedEffectTable = {}
		for i, modifierData in ipairs( attacker.OutgoingDoubleDamageModifiers ) do

			local validWeapon = modifierData.ValidWeaponsLookup == nil or ( modifierData.ValidWeaponsLookup[ triggerArgs.SourceWeapon ] ~= nil and triggerArgs.EffectName == nil )
			local validTrait = modifierData.RequiredTrait == nil or ( attacker == CurrentRun.Hero and HeroHasTrait( modifierData.RequiredTrait ) )
			local validActiveEffect = modifierData.ValidActiveEffects == nil or (victim.ActiveEffects and ContainsAnyKey( victim.ActiveEffects, modifierData.ValidActiveEffects))
			local validEx = true
			if modifierData.IsEx or modifierData.IsNotEx then
				validEx = false
				if weaponData then
					local baseWeaponData = WeaponData[weaponData.Name]
					local isEx = IsExWeapon( weaponData.Name, { Combat = true }, triggerArgs )
					if modifierData.IsEx and isEx then
						validEx = true
					elseif modifierData.IsNotEx and not isEx then
						validEx = true
					end
				end
			end
			if validWeapon and validTrait and validActiveEffect and validEx then
				if modifierData.IncreasingPlasmaCritChance then
					local totalPlasma = CurrentRun.CurrentRoom.BloodDropCount * GetTotalHeroTraitValue( "BloodDropMultiplier", { IsMultiplier = true } )
					addDdMultiplier( modifierData, modifierData.IncreasingPlasmaCritChance * totalPlasma, triggerArgs)
					-- modutil.mod.Hades.PrintOverhead("DoubleDamageChance "..(triggerArgs.DdChance))
				end
			end
		end
	end
	return triggerArgs.DdChance
end

modutil.mod.Path.Wrap("FormatExtractedValue", function(baseFunc, value, extractData)
	if extractData.MultiplyByPlasmaCount then
		value = value * (CurrentRun.CurrentRoom.BloodDropCount * 0.5)
	end
	return baseFunc(value, extractData)
end)

-- HephaestusWrath custom function
function not_public.HephRetaliate( unit, args )
	if not HeroHasTrait(gods.GetInternalBoonName("HephWrathBoon")) then
		return
	end
	if not unit or unit.SkipModifiers or not CheckCooldown( "HephRetaliate"..unit.ObjectId, args.Cooldown ) then
		return
	end
	if CurrentRun.Hero.HealthBuffer <= 0 then
		return
	end

	local blastModifier = GetTotalHeroTraitValue( "MassiveAttackSizeModifier", { IsMultiplier = true })
	waitUnmodified( args.BlastDelay or 0 )
	if unit then
		CreateProjectileFromUnit({ Name = args.ProjectileName, Id = CurrentRun.Hero.ObjectId, DestinationId = unit.ObjectId, DamageMultiplier = args.DamageMultiplier, BlastRadiusModifier = blastModifier, FireFromTarget = true })
		if unit.IsDead then
			CreateAnimation({ Name = "HephMassiveHit", DestinationId = unit.ObjectId })
		end
	else
		CreateProjectileFromUnit({ Name = args.ProjectileName, Id = CurrentRun.Hero.ObjectId, ProjectileDestinationId = args.ProjectileId, DamageMultiplier = args.DamageMultiplier, BlastRadiusModifier = blastModifier, FireFromTarget = true })
	end
end

--ZeusWrath custom function 
modutil.mod.Path.Override("ZeusWrath", function(unit, args)
	local strikeCount = args.MinStrikes
	while RandomChance( args.DoubleBoltChance * GetTotalHeroTraitValue( "LuckMultiplier", { IsMultiplier = true }) ) and strikeCount < args.MaxStrikes do
		strikeCount = strikeCount + 1
	end
	if strikeCount > 1 then
		thread( InCombatTextArgs, { TargetId = unit.ObjectId, Text = "ZeusWrath_CombatText", LuaKey = "TempTextData", ShadowScaleX = 1.1, LuaValue = { Amount = strikeCount, BoonName = gods.GetInternalBoonName("ZeusWrathBoon") }} )
	end
	CreateZeusBolt({
		ProjectileName = args.ProjectileName, 
		TargetId = unit.ObjectId, 
		DamageMultiplier = args.DamageMultiplier,
		Delay = 0.2, 
		FollowUpDelay = 0.2, 
		Count = strikeCount
		})
end)

--DemeterWrath custom functions

--AphroWrath custom functions
modutil.mod.Path.Wrap("DamageEnemy", function(baseFunc, victim, triggerArgs)
	baseFunc(victim, triggerArgs)
	if not HeroHasTrait(gods.GetInternalBoonName("AphroWrathBoon")) then
		return
	end
	local graphic = nil
	local count = 1
	if (triggerArgs.SourceProjectile == "AphroditeBurst") then
		local weaponName = "WeaponCast"
		local projectileName = "ProjectileCast"
		local derivedValues = GetDerivedPropertyChangeValues({
			ProjectileName = projectileName,
			WeaponName = weaponName,
			Type = "Projectile",
		})
		derivedValues.ThingPropertyChanges = derivedValues.ThingPropertyChanges or {}
		derivedValues.ThingPropertyChanges.Graphic = "null"
		local projectileId = CreateProjectileFromUnit({ WeaponName = weaponName, Name = projectileName, Id = CurrentRun.Hero.ObjectId, DestinationId = CurrentRun.Hero.ObjectId, FireFromTarget = true, 
			DataProperties = derivedValues.PropertyChanges, ThingProperties = derivedValues.ThingPropertyChanges })
				ArmAndDetonateProjectiles({ Ids = { projectileId }})
		return
	end
end)

modutil.mod.Path.Wrap("CreateProjectileFromUnit", function (baseFunc, args)
	if args.Name == "AphroditeBurst" then
		local HeartthrobWrathMultiplier = GetTotalHeroTraitValue("ReportedHeartthrobMultiplier", { IsMultiplier = true })
		args.DamageMultiplier = args.DamageMultiplier * HeartthrobWrathMultiplier
	end
	return baseFunc(args)
end)

--HestiaWrath custom functions
modutil.mod.Path.Override("BurnInstaKill", function( args, attacker, victim, triggerArgs )
	--[[for k,v in pairs(victim.ActiveEffects["BurnEffect"]) do
		print(k)
	end]]--

	if attacker == CurrentRun.Hero and HasEffectWithEffectGroup( victim, "Burn" )
		and not victim.IsDead
		and not victim.CannotDieFromDamage
		and victim.Health / victim.MaxHealth <= args.CombustDeathThreshold
		and (victim.Health - victim.ActiveEffects["BurnEffect"] <= 0)
		and ( victim.Phases == nil or victim.CurrentPhase == victim.Phases ) then

		if args.ExecuteImmunities and args.ExecuteImmunities[victim.Name] and IsGameStateEligible( victim, args.ExecuteImmunities[victim.Name].GameStateRequirement ) then
			if not victim.ResistChillKillPresentation then
				victim.ResistChillKillPresentation = true
			end
			return
		end 

		-- Projectile is created but deals no damage, only for visuals
		CreateProjectileFromUnit({ Name = args.ProjectileName, Id = CurrentRun.Hero.ObjectId, DestinationId = victim.ObjectId, DamageMultiplier = args.DamageMultiplier, FireFromTarget = true})

		thread( Kill, victim, { ImpactAngle = 0, AttackerTable = CurrentRun.Hero, AttackerId = CurrentRun.Hero.ObjectId })
		if victim.UseBossHealthBar then
			CurrentRun.BossHealthBarRecord[victim.Name] = 0 -- Health bar won't get updated again normally
		end
	end
end)

modutil.mod.Path.Override("ApplyBurn", function (victim, functionArgs, triggerArgs)
	functionArgs = ShallowCopyTable(functionArgs) or { EffectName = "BurnEffect", NumStacks = 1 }
	local effectName = functionArgs.EffectName 
	
	if victim and victim.BlockEffectWhileRootActive == effectName then
		return
	end

	if victim and victim.EffectBlocks and Contains(victim.EffectBlocks, effectName) then
		return
	end

	if not EffectData[effectName] then
		return
	end
	local dataProperties = MergeAllTables({
		EffectData[effectName].EffectData, 
		functionArgs.EffectArgs
	})
	if HeroHasTrait("BurnStackBoon") then
		for _, data in pairs( GetHeroTraitValues("EffectModifier")) do
			if EffectData[effectName].DisplaySuffix == data.ValidActiveEffectGenus then
				if data.IntervalMultiplier then
					dataProperties.Cooldown = dataProperties.Cooldown * data.IntervalMultiplier
				end
				if data.DurationIncrease then
					dataProperties.Duration = dataProperties.Duration + data.DurationIncrease
				end
			end
		end
	end
	if not SessionMapState.FirstBurnRecord[ victim.ObjectId ] then
		functionArgs.NumStacks = functionArgs.NumStacks + GetTotalHeroTraitValue("BonusFirstTimeBurn")
		SessionMapState.FirstBurnRecord[ victim.ObjectId ] = true
	end
	local maxStacks = EffectData[effectName].MaxStacks
	if HeroHasTrait(gods.GetInternalBoonName("HestiaWrathBoon")) then
		maxStacks = EffectData[effectName].MaxStacks * 10
	end
	if not victim.ActiveEffects[effectName] or victim.ActiveEffects[effectName] < maxStacks then
		IncrementTableValue( victim.ActiveEffects, effectName, functionArgs.NumStacks )
		if victim.ActiveEffects[effectName] > maxStacks then
			victim.ActiveEffects[effectName] = maxStacks
		end
	end
	ApplyEffect( { DestinationId = victim.ObjectId, Id = CurrentRun.Hero.ObjectId, EffectName = effectName, NumStacks = functionArgs.NumStacks, DataProperties = dataProperties } )
end)

--ApolloWrath custom functions
modutil.mod.Path.Override("ApolloWrath", function(unit, traitArgs)
	if unit.ActiveEffects then
		if unit.ActiveEffects["BlindEffect"] then
			CreateProjectileFromUnit({ Name = traitArgs.ProjectileName, Id = CurrentRun.Hero.ObjectId, DestinationId = unit.ObjectId, DamageMultiplier = traitArgs.DamageMultiplier})
			ApplyEffect( { DestinationId = unit.ObjectId, Id = CurrentRun.Hero.ObjectId, EffectName = traitArgs.EffectName, DataProperties = EffectData[traitArgs.EffectName].EffectData })
		end
	end
end)

--HeraWrath custom functions
modutil.mod.Path.Override("HeraMoutonSpawn", function(weaponData, traitArgs, triggerArgs)
	ShawnSummon(traitArgs.SpawnedEnemy, traitArgs, triggerArgs)
end)

modutil.mod.Path.Override("ShawnSummon", function(enemyName, traitArgs, triggerArgs)
	local args = traitArgs or {}
	local weaponDataMultipliers = 
	{ 
		MaxHealthMultiplier = args.MaxHealthMultiplier or 1, 
	}
	local enemyData = EnemyData[enemyName]
	local newEnemy = DeepCopyTable( enemyData )
	if enemyData.AlliedScaleMultiplier then
		weaponDataMultipliers.ScaleMultiplier = enemyData.AlliedScaleMultiplier
	end
	newEnemy.Name = "Shawn"
	newEnemy.SheepHitVelocity = 400
	newEnemy.HideHealthBar = false
	newEnemy.BlocksLootInteraction = false
	newEnemy.IgnoreCastSlow = false
	newEnemy.RequiredKill = false
	newEnemy.MaxHealth = newEnemy.MaxHealth * weaponDataMultipliers.MaxHealthMultiplier
	newEnemy.HealthBarOffsetY = (newEnemy.HealthBarOffsetY or -155 )
	
	newEnemy.DefaultAIData.ExitMapAfterDuration = 6

	newEnemy.DamageType = "Enemy"
	newEnemy.TriggersOnDamageEffects = true
	newEnemy.CanBeFrozen = true

	newEnemy.BlocksLootInteraction = false

	newEnemy.SkipModifiers = false
	newEnemy.SkipDamageText = false
	newEnemy.SkipDamagePresentation = false
	newEnemy.IgnoreAutoLock = false

	ProcessDataInheritance(newEnemy, EnemyData)
	
	local SpawnPoint = SpawnObstacle({ Name = "InvisibleTarget", DestinationId = CurrentRun.Hero.ObjectId, OffsetX = 0, OffsetY = 0, ForceToValidLocation = true})

	if SessionMapState.CurrentShawn then
		Kill(ActiveEnemies[SessionMapState.CurrentShawn], { Silent = true })
	end

	newEnemy.ObjectId = SpawnUnit({
		Name = enemyData.Name,
		Group = "Standing",
		DestinationId = SpawnPoint, OffsetX = 0, OffsetY = 0 })
	SessionMapState.CurrentShawn = newEnemy.ObjectId
	
	thread( CreateAlliedEnemyPresentation, newEnemy )
	thread( SetupUnit, newEnemy, CurrentRun, { SkipPresentation = true } )
	SetThingProperty({ Property = "ElapsedTimeMultiplier", Value = GetGameplayElapsedTimeMultiplier(), ValueChangeType = "Absolute", DataValue = false, DestinationId = newEnemy.ObjectId })
	
	if not newEnemy or newEnemy.SkipModifiers or not GetThingDataValue({ Id = newEnemy.ObjectId, Property = "StopsProjectiles" }) or IsInvulnerable({ Id = newEnemy.ObjectId }) or IsUntargetable({ Id = newEnemy.ObjectId }) then
		return
	end

	SetThingProperty({ Property = "ElapsedTimeMultiplier", Value = newEnemy.SpeedMultiplier, ValueChangeType = "Multiply", DataValue = false, DestinationId = newEnemy.ObjectId })

	SetScale({ Id = newEnemy.ObjectId, Fraction = 1, Duration = 0 })
	newEnemy.SummonHealthBarEffect = true
	ApplyDamageShare( newEnemy, args, triggerArgs )
	return newEnemy
end)

modutil.mod.Path.Wrap("ApplyDamageShare", function( baseFunc, victim, functionArgs, triggerArgs )
	if HeroHasTrait(gods.GetInternalBoonName("HeraWrathBoon")) then
		if functionArgs.EffectArgs == nil then
			functionArgs.EffectArgs = { Amount = 0.3 }
		end
		if victim.Name == "Shawn" then
			functionArgs.EffectArgs.Amount = 1.0 --needs to be modified with tooltip data
		end
	end
	baseFunc( victim, functionArgs, triggerArgs )
end)

--DemeterWrath custom functions
modutil.mod.Path.Wrap("ApplyRoot", function( baseFunc, victim, functionArgs, triggerArgs )
	baseFunc(victim, functionArgs, triggerArgs)
	if victim.ActiveEffects then
		if victim.ActiveEffects["ChillEffect"] and victim.RootActive then
			thread( FrosbiteDamage, enemy, functionArgs, triggerArgs)
		end
	end
end)

modutil.mod.Path.Override("FrosbiteDamage", function (victim, functionArgs, triggerArgs)
	local victim = triggerArgs.Victim
	local dataProperties = MergeAllTables({
		EffectData["ChillEffect"].EffectData, 
		functionArgs.EffectArgs
	})
	if victim and not victim.IsDead then
		local freezeDuration = dataProperties.Duration - (dataProperties.ExpiringTimeThreshold - GetTotalHeroTraitValue("RootDurationExtension"))
		wait(freezeDuration)
		damageAmount = freezeDuration * 75
		modutil.mod.Hades.PrintOverhead("FrosbiteDamage "..(damageAmount))
		CreateProjectileFromUnit({ 
				Name = "RubbleFallOlympus", 
				DestinationId = victim.ObjectId, 
				Id = CurrentRun.Hero.ObjectId, 
				DamageMultiplier = damageAmount / 200, --dividing by 4 again because of placeholder projectile
				FireFromTarget = true,
				ProjectileCap = 1, 
				OffsetY = -329,
			})
		CreateAnimation({ Name = "OlympusIcicleFalling", DestinationId = victim.ObjectId })
	end
end)