---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.

-- These are some sample code snippets of what you can do with our modding framework:
local file = rom.path.combine(rom.paths.Content, 'Game/Text/en/ShellText.en.sjson')
sjson.hook(file, function(data)
	return sjson_ShellText(data)
end)

modutil.mod.Path.Wrap("SetupMap", function(base, ...)
	prefix_SetupMap()
	return base(...)
end)

local TraitTextFile = rom.path.combine(rom.paths.Content, "Game/Text/en/TraitText.en.sjson")
local HelpTextFile = rom.path.combine(rom.paths.Content, "Game/Text/en/HelpText.en.sjson")
local PlayerProjectilesFile = rom.path.combine(rom.paths.Content, "Game/Projectiles/PlayerProjectiles.sjson")
local Order = { "Id", "InheritFrom", "DisplayName", "Description" }

local not_public = {}
public["not"] = not_public

mod.HeraRandomCurseBoon_Text = sjson.to_object({
    Id = "BonusOlympianDamageStatDisplay1",
    InheritFrom = "BaseStatLine",
    DisplayName = "{!Icons.Bullet}{#PropertyFormat}Bonus Random Curses:",
    Description = "{#UpgradeFormat}{$TooltipData.ExtractData.CurseCount}",
}, Order)

mod.PoseidonWrathBoon_Text = sjson.to_object({
    Id = "BonusOceanSwellStatDisplay1",
    InheritFrom = "BaseStatLine",
    DisplayName = "{!Icons.Bullet}{#PropertyFormat}Wave Bonus Damage:",
    Description = "{#UpgradeFormat}{$TooltipData.StatDisplay1}",
}, Order)

mod.AresWrathBoon_Text = sjson.to_object({
    Id = "PlasmaDoubleDamageStatDisplay1",
    InheritFrom = "BaseStatLine",
    DisplayName = "{!Icons.Bullet}{#PropertyFormat}Chance per Collected Plasma:",
    Description = "{#UpgradeFormat}{$TooltipData.StatDisplay1}",
}, Order)

mod.AresWrathBoonPicked_Text = sjson.to_object({
    Id = "PlasmaDoubleDamageStatDisplay2",
    InheritFrom = "BaseStatLine",
    DisplayName = "{!Icons.Bullet}{#PropertyFormat}Current Double Damage Chance:",
    Description = "{#UpgradeFormat}{$TooltipData.ExtractData.CurrentMultiplier:P}",
}, Order)

mod.HephWrathBoon_Text = sjson.to_object({
    Id = "BlastRevengeStatDisplay1",
    InheritFrom = "BaseStatLine",
    DisplayName = "{!Icons.Bullet}{#PropertyFormat}Armor Gained Now:",
    Description = "{#UpgradeFormat}+{$TooltipData.ExtractData.TooltipAmount}",
}, Order)

mod.ZeusWrathBoon_Text = sjson.to_object({
    Id = "BlitzVengeanceStatDisplay1",
    InheritFrom = "BaseStatLine",
    DisplayName = "{!Icons.Bullet}{#PropertyFormat}Double Strike Chance:",
    Description = "{#UpgradeFormat}{$TooltipData.StatDisplay1}",
}, Order)

mod.DemeterWrathBoon_Text = sjson.to_object({
    Id = "FrostbiteBurstStatDisplay1",
    InheritFrom = "BaseStatLine",
    DisplayName = "{!Icons.Bullet}{#PropertyFormat}Frostbite Damage:",
    Description = "{#UpgradeFormat}{$TooltipData.StatDisplay1} {#Prev}{#ItalicFormat}(per 1 Sec.)",
}, Order)

mod.AphroWrathBoon_Text = sjson.to_object({
    Id = "BonusHeartthrobDamageStatDisplay1",
    InheritFrom = "BaseStatLine",
    DisplayName = "{!Icons.Bullet}{#PropertyFormat}Bonus Heartthrob Damage:",
    Description = "{#UpgradeFormat}{$TooltipData.StatDisplay1}",
}, Order)

sjson.hook(TraitTextFile, function(data)
    table.insert(data.Texts, mod.HeraRandomCurseBoon_Text)
	table.insert(data.Texts, mod.PoseidonWrathBoon_Text)
	table.insert(data.Texts, mod.AresWrathBoon_Text)
	table.insert(data.Texts, mod.AresWrathBoonPicked_Text)
	table.insert(data.Texts, mod.HephWrathBoon_Text)
	table.insert(data.Texts, mod.ZeusWrathBoon_Text)
	table.insert(data.Texts, mod.DemeterWrathBoon_Text)
	table.insert(data.Texts, mod.AphroWrathBoon_Text)
end)

mod.ZeusWrathBoon_CombatText = sjson.to_object({
	Id = "ZeusWrath_CombatText",
	DisplayName = "{#CombatTextHighlightFormat}{$TempTextData.BoonName} {#Prev}{$TempTextData.Amount}x!",
}, Order)

sjson.hook(HelpTextFile, function(data)
	table.insert(data.Texts, mod.ZeusWrathBoon_CombatText)
end)

--[[mod.FrostbiteBurst_Data = sjson.to_object({
	Name = "FrostbiteProjectile",
	InheritFrom = "1_BaseProjectile",
	DetonateFx = "RadialNovaDemeter",
	Type = "INSTANT",
	Fuse = 0.1,
	Range = 0,
	Damage = 75,
	DamageRadius = 220.0,
	DamageRadiusScaleY = 0.6,
	DamageRadiusScaleX = 1.1,
	AutoAdjustForTarget = false,
	UseVulnerability = false,
	NumPenetrations = 999,
	IgnoreDodge = true,
	SpawnRadius = 0,
	Speed = -100,
	UseStartLocation = true,
	DetonateLineOfSight = true,
	CanHitWithoutDamage = true,
	SilentImpactOnInvulnerable = true,
}, Order)

sjson.hook(PlayerProjectilesFile, function(data)
	table.insert(data.Texts, mod.FrostbiteBurst_Data)
end)]]--

game.TraitData.WrathTrait = {
    BlockStacking = true,
    BlockInRunRarify = true,
    BlockMenuRarify = true,
    CustomRarityName = "Wrath",
    CustomRarityColor = Color.BoonPatchHeroic,
    InfoBackingAnimation = "BoonSlotHeroic",
    UpgradeChoiceBackingAnimation = "BoonSlotHeroic",
    Frame = "Unity",
    RarityLevels = {
        Legendary = {
            MinMultiplier = 1,
            MaxMultiplier = 1,
        },
    },
}

--[[ 
uid, internal, charactername ,legendary, rarity, slot, blockstacking,  statlines, extractval, elements, displayName
extrafields, boonIconPath, requirements, flavourtext
]]
gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    characterName = "Hera",    
	internalBoonName = "RandomCurseBoon",
    isLegendary = false,
	InheritFrom = 
	{
		"FireBoon",
	},
    addToExistingGod = true,

    displayName = "Family Discourse",
    description = "Whenever you inflict {$Keywords.Link}, also randomly inflict {$Keywords.StatusPlural} from other Olympians.",
	StatLines = { "BonusOlympianDamageStatDisplay1" },
	requirements = { OneOf = { "HeraWeaponBoon", "HeraSpecialBoon", "HeraCastBoon", "HeraSprintBoon" } },
    boonIconPath = "GUI\\Screens\\BoonIcons\\Hera_33",
	reuseBaseIcons = true,
	BlockStacking = true,
	RarityLevels = {
			Common = 1.00,
       		Rare = 2,
        	Epic = 3,
        	Heroic = 4,
	},	

	ExtractValues = { 
		{
			Key = "ReportedCurseCount",
			ExtractAs = "CurseCount",
		},
		-- Hitch highlight Duration and Share Damage
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
		OnEffectApplyFunction = 
		{
			FunctionName = "rom.mods." .. _PLUGIN.guid .. ".not.CheckRandomShareDamageCurse",
			FunctionArgs = 
			{
				CurseCount = { BaseValue = 1 },
				Effects = 
				{
					AmplifyKnockbackEffect = 
					{
						GameStateRequirements =
						{
							{
								PathTrue = { "GameState", "TextLinesRecord", "PoseidonFirstPickUp" },
							},
						},
						CopyValuesFromTraits = 
						{
							Modifier = {"PoseidonStatusBoon" }
						},
					},
					BlindEffect = 
					{
						GameStateRequirements =
						{
							{
								PathTrue = { "GameState", "TextLinesRecord", "ApolloFirstPickUp" },
							},
						},
					},
					DamageEchoEffect = 
					{ 
						GameStateRequirements =
						{
							{
								PathTrue = { "GameState", "TextLinesRecord", "ZeusFirstPickUp" },
							},
						},
						ExtendDuration = "EchoDurationIncrease", 
						DefaultModifier = 1,
						CopyValuesFromTraits = 
						{
							Modifier = {"ZeusWeaponBoon", "ZeusSpecialBoon"},
						},
					},
					
					DelayedKnockbackEffect = 
					{
						GameStateRequirements =
						{
							{
								PathTrue = { "GameState", "TextLinesRecord", "HephaestusFirstPickUp" },
							},
						},
						CopyValuesFromTraits = 
						{
							TriggerDamage = { "MassiveKnockupBoon" },
						},
					},
					ChillEffect = 
					{
						GameStateRequirements =
						{
							{
								PathTrue = { "GameState", "TextLinesRecord", "DemeterFirstPickUp" },
							},
						},
						CustomFunction = "ApplyRoot"
					},

					WeakEffect =
					{
						GameStateRequirements =
						{
							{
								PathTrue = { "GameState", "TextLinesRecord", "AphroditeFirstPickUp" },
							},
						},
						CustomFunction = "ApplyAphroditeVulnerability",
					}, 
					
					BurnEffect = 
					{ 
						GameStateRequirements =
						{
							{
								PathTrue = { "GameState", "TextLinesRecord", "HestiaFirstPickUp" },
							},
						},
						CustomFunction = "ApplyBurn", 
						DefaultNumStacks = 30,
						CopyNumStacksFromTraits = { "HestiaWeaponBoon", "HestiaSpecialBoon" },
					},
					
					--[[AresStatus = 
					{
						GameStateRequirements =
						{
							{
								Path = { "GameState", "TextLinesRecord", },
								HasAny = { "AresFirstPickUp" },
							},
						},
						AddOutgoingDamageModifiers =
						{
							ValidEffects = "DamageShareEffect",
							MissingEffectDamage = EffectData.AresStatus.BonusBaseDamageOnInflict,
							MissingEffectName = "AresStatus",
							MissingDamagePresentation = 
							{
								TextStartColor = Color.AresDamageLight,
								TextColor = Color.AresDamage,
								FunctionName = "AresRendApplyPresentation",
								SimSlowDistanceThreshold = 180,
								HitSimSlowCooldown = 0.8,
								HitSimSlowParameters =
								{
									{ ScreenPreWait = 0.02, Fraction = 0.13, LerpTime = 0 },
									{ ScreenPreWait = 0.10, Fraction = 1.0, LerpTime = 0.05 },
								},
							},
						},
					},]]--
				},
				ReportValues = { ReportedCurseCount = "CurseCount" },
			},
		}
	}
})

gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    characterName = "Poseidon",
	internalBoonName = "PoseidonWrathBoon",
    isLegendary = false,
	InheritFrom = 
	{
		"WrathTrait",
		"WaterBoon",
	},
    addToExistingGod = true,
	reuseBaseIcons = true,
    BlockStacking = true,

    displayName = "Wrath of Poseidon",
    description = "Your splash effects fire your waves from {$TraitData.OmegaPoseidonProjectileBoon.Name} with more {$Keywords.BaseDamage} at no extra cost.",
	StatLines = { "BonusOceanSwellStatDisplay1" },
	requirements =
	{
		OneFromEachSet =
		{
			{ "PoseidonWeaponBoon", "PoseidonSpecialBoon", "FocusDamageShaveBoon" },
			{ "OmegaPoseidonProjectileBoon" },
			{ "PoseidonStatusBoon", "PoseidonExCastBoon", "EncounterStartOffenseBuffBoon" },
		},
	},
    flavourText = "The sea covers most of the world's surface already; pray it does not cover the rest.",
    boonIconPath = "GUI\\Screens\\BoonIcons\\Poseidon_39",
    
	ExtractValues =
	{
		{
			Key = "ReportedWaveMultiplier",
			ExtractAs = "TooltipData",
			Format = "PercentDelta",
		},
	},

	ExtraFields = 
	{
        AddOutgoingDamageModifiers = 
		{
			ValidProjectiles = { "PoseidonOmegaWave" },
			ValidWaveDamageAddition = {
				BaseValue = 2.00, -- boon description only
				SourceIsMultiplier = true, 
			},
            ReportValues = { ReportedWaveMultiplier = "ValidWaveDamageAddition" },
        },
    },
})

gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    characterName = "Ares",
	internalBoonName = "AresWrathBoon",
    isLegendary = false,
	InheritFrom = 
	{
		"WrathTrait",
		"EarthBoon",
	},
    addToExistingGod = true,
	reuseBaseIcons = true,
    BlockStacking = true,

    displayName = "Wrath of Ares",
    description = "Gain a chance to deal {$TraitData.AresStatusDoubleDamageBoon.DamagePercent:F} damage based on your current amount of {!Icons.BloodDropWithCountIcon}.",
	StatLines = { "PlasmaDoubleDamageStatDisplay1" },
	TrayStatLines = { "PlasmaDoubleDamageStatDisplay2" },
	requirements =
	{
		OneFromEachSet =
		{
			{ "AresWeaponBoon", "AresSpecialBoon" },
			{ "AresManaBoon", "BloodDropRevengeBoon", "RendBloodDropBoon" },
			{ "AresStatusDoubleDamageBoon", "MissingHealthCritBoon" },
		},
	},
    flavourText = "If the sight of blood was truly so revolting, why then should it have such a striking hue?",
    boonIconPath = "GUI\\Screens\\BoonIcons\\Ares_34",
    
	ExtractValues =
	{
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

	ExtraFields = 
	{
        AddOutgoingDoubleDamageModifiers = 
		{
			IncreasingPlasmaCritChance =
			{
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
	InheritFrom = 
	{
		"WrathTrait",
		"CostumeTrait",
		"FireBoon",
	},
    addToExistingGod = true,
	reuseBaseIcons = true,
    BlockStacking = true,

    displayName = "Explosive Plating",
    description = "After you take damage while having {!Icons.ArmorTotal}, create a blast that deals {$TooltipData.ExtractData.Damage} damage in an area.",
	StatLines = { "BlastRevengeStatDisplay1" },
	requirements =
	{
		OneFromEachSet =
		{
			{ "HephaestusWeaponBoon", "HephaestusSpecialBoon", "HephaestusSprintBoon" },
			{ "HeavyArmorBoon", "ArmorBoon", "EncounterStartDefenseBuffBoon" },
			{ "HephaestusManaBoon", "ManaToHealthBoon" },
		},
	},
    flavourText = "The roughest hands can often be the ones to produce the most immaculate results.",
    boonIconPath = "GUI\\Screens\\BoonIcons\\Hephaestus_29",
    
	ExtractValues =
	{
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

	ExtraFields = 
	{
		Frame = "Unity",
		Invincible = true,
		OnSelfDamagedFunction =
		{
			Name = "rom.mods." .. _PLUGIN.guid .. ".not.HephRetaliate",
			FunctionArgs = 
			{
				ProjectileName = "MassiveSlamBlast",
				Cooldown = 0.4,
				BlastDelay = 0.08,
				DamageMultiplier = 3.0,
				ReportValues = 
				{
					ReportedBlastDamageMultiplier = "DamageMultiplier",
				}
			}
		},
		AcquireFunctionName = "HeavyArmorInitialPresentation",
		SetupFunctions =
		{
			{
				Name = "CostumeArmor",
				Args = 
				{
					Source = "Tradeoff",
					Delay = 0.75,
					BaseAmount =
					{
						BaseValue = 100,
					},
					ReportValues = 
					{
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
	InheritFrom = 
	{
		"WrathTrait",
		"AirBoon",
	},
    addToExistingGod = true,
	reuseBaseIcons = true,
    BlockStacking = true,

    displayName = "Wrath of Zeus",
    description = "Activating {$Keywords.Echo} on foes strikes them with {#BoldFormatGraft}{$TooltipData.ExtractData.BoltsNumber} {#Prev}lightning bolts, each dealing {#BoldFormatGraft}{$TooltipData.ExtractData.WrathBoltDamage} {#Prev}damage.",
	StatLines = { "BlitzVengeanceStatDisplay1" },
	requirements =
	{
		OneFromEachSet =
		{
			{ "SuperSacrificeBoonHera" },
			{ "ZeusWeaponBoon", "ZeusSpecialBoon" },
		},
	},
    flavourText = "The lightning bolt forever remains a symbol of the impulsive power of the Lord of Olympus.",
    boonIconPath = "GUI\\Screens\\BoonIcons\\Zeus_33",

	ExtractValues =
	{
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

	ExtraFields = 
	{
		BoltDamage = 100, -- used for description only
		OnEnemyDamagedAction =
		{
			Name = "ZeusWrath",
			Args = 
			{
				ProjectileName = "ZeusRetaliateStrike",
				DoubleBoltChance = 0.4,
				MinStrikes = 3,
				MaxStrikes = 
				{ 
					BaseValue = 6,
					MinValue = 3,
					IdenticalMultiplier = 
					{
						Value = -0.5,
					},
				},
				ReportValues = 
				{ 
					ReportedMaxStrikes = "MaxStrikes",
					ReportedMinStrikes = "MinStrikes",
					ReportedBoltChance = "DoubleBoltChance",
				},
			},
		},
	},
})

--[[gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    characterName = "Demeter",
	internalBoonName = "DemeterWrathBoon",
    isLegendary = false,
	InheritFrom = 
	{
		"WrathTrait",
		"WaterBoon",
	},
    addToExistingGod = true,
	reuseBaseIcons = true,
    BlockStacking = true,

    displayName = "Wrath of Demeter",
    description = "After the {$Keywords.Root} duration on your foes expires, they suffer from Frostbite.",
	StatLines = { "FrostbiteBurstStatDisplay1" },
	requirements =
	{
		OneFromEachSet =
		{
			{ "DemeterWeaponBoon", "DemeterSpecialBoon", "DemeterCastBoon" },
			{ "DemeterSprintBoon", "CastNovaBoon" },
			{ "SlowExAttackBoon", "CastAttachBoon", "RootDurationBoon" },
		},
	},
    flavourText = "Life is resilient, and can take root even in cold, harsh environments... but only to a point.",
    boonIconPath = "GUI\\Screens\\BoonIcons\\Demeter_32",
    
	ExtractValues =
	{
		{
			Key = "ReportedFrostbiteMutiplier",
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
		Frame = "Unity",
		OnEnemyDamagedAction =
		{
			Name = "FrostbiteDamage",
			Args =
			{
				ProjectileName = "FrostbiteEffect",
				FreezeTimeScale = 1,
				FrostbiteMultiplier =
				{
					BaseValue = 1,
				},
			},
			ReportedValues =
			{
				ReportedFrostbiteMultiplier = "FrostbiteMultipier",
			},
		},
    },
})]]--

gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    characterName = "Aphrodite",    
	internalBoonName = "AphroWrathBoon",
    isLegendary = false,
	InheritFrom = 
	{
		"WrathTrait",
		"WaterBoon",
	},
    addToExistingGod = true,
	reuseBaseIcons = true,
	BlockStacking = true,

    displayName = "Lustful Confession",
    description = "Your {$Keywords.HeartBurstPlural} are stronger and fire your {$Keywords.CastEX} upon striking a foe.",
	StatLines = { "BonusHeartthrobDamageStatDisplay1" },
	requirements = 
	{
		OneFromEachSet =
		{
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

	ExtraFields = 
	{
		HeartthrobBonusDamageModifiers = 
		{
			ValidProjectiles = "AphroditeBurst",
			HeartthrobBonusMultiplier = 
			{
				BaseValue = 1.5,
			},
			SourceIsMultiplier = true,
            ReportValues = { ReportedHeartthrobMultiplier = "HeartthrobBonusMultiplier" },
        },
	}
})

-- Function Library --

-- FamilyDiscourse custom function
function not_public.CheckRandomShareDamageCurse(victim, functionArgs, triggerArgs)
	if triggerArgs.EffectName == "DamageShareEffect" and not triggerArgs.Reapplied and victim.ActivationFinished then
		local eligibleEffects = { }
		for name, data in pairs( functionArgs.Effects ) do
			if not data.GameStateRequirements or IsGameStateEligible( data, data.GameStateRequirements ) then
				table.insert( eligibleEffects, name )
			end
		end
		local CurseCount = functionArgs.CurseCount or 1
		for i=1, CurseCount do 
			local effectName = RemoveRandomValue( eligibleEffects )
			if not effectName then
				return
			end
			local applicationData = functionArgs.Effects[effectName]
			if applicationData.CustomFunction then
				local stacks = applicationData.DefaultNumStacks
				if applicationData.CopyNumStacksFromTraits then
					for _, traitName in pairs(applicationData.CopyNumStacksFromTraits ) do
							if HeroHasTrait( traitName ) then
								local traitData = GetHeroTrait( traitName )
								if traitData.OnEnemyDamagedAction and traitData.OnEnemyDamagedAction.Args then
									local args = traitData.OnEnemyDamagedAction.Args
									if args.NumStacks and stacks < args.NumStacks then
										stacks = args.NumStacks
									end
								end
							end
					end
				end

				CallFunctionName( applicationData.CustomFunction, victim, {EffectName = effectName, NumStacks = stacks } )
			else
				local dataProperties = EffectData[effectName].EffectData or EffectData[effectName].DataProperties
				if applicationData.ExtendDuration then
					dataProperties.Duration = dataProperties.Duration + GetTotalHeroTraitValue(applicationData.ExtendDuration)
				end
				if applicationData.DefaultModifier then
					dataProperties.Modifier = applicationData.DefaultModifier
				end
				if applicationData.CopyValuesFromTraits then
					for property, traitNames in pairs(applicationData.CopyValuesFromTraits ) do
						for _, traitName in pairs( traitNames ) do
							if HeroHasTrait( traitName ) then
								local traitData = GetHeroTrait( traitName )
								if traitData and traitData.OnEnemyDamagedAction and traitData.OnEnemyDamagedAction.Args then
									if not dataProperties[property] or ( dataProperties[property] and traitData.OnEnemyDamagedAction.Args[property] > dataProperties[property] ) then
										dataProperties[ property ] = traitData.OnEnemyDamagedAction.Args[property]
									end
								end
							end
						end
					end
				end
				ApplyEffect( { DestinationId = victim.ObjectId, Id = CurrentRun.Hero.ObjectId, EffectName = effectName, DataProperties = dataProperties })
			end
		end
	end
end

-- PoseidonWrath custom function
modutil.mod.Path.Wrap("DamageEnemy", function(baseFunc, victim, triggerArgs)
	baseFunc(victim, triggerArgs)
	if not HeroHasTrait(gods.GetInternalBoonName("PoseidonWrathBoon")) then
		return
	end
	for k,v in pairs(triggerArgs) do
		print(k)
	end
	local traitData = GetHeroTrait("OmegaPoseidonProjectileBoon")

	-- If Hero doesnt have Ocean Swell, dont crash, just dont do it
	if not HeroHasTrait("OmegaPoseidonProjectileBoon") then
		return
	end
	local graphic = nil
	local count = 1
	if (triggerArgs.SourceProjectile == "PoseidonSplashSplinter") then
		for i=1, count do
			CreateProjectileFromUnit({ 
				Name = "PoseidonOmegaWave", 
				Id = CurrentRun.Hero.ObjectId, 
				Angle = triggerArgs.ImpactAngle, 
				DestinationId = victim.ObjectId, 
				FireFromTarget = true,
				DamageMultiplier = (traitData.OnWeaponFiredFunctions.FunctionArgs.DamageMultiplier or 1) * 2,
				DataProperties = 
				{
					StartFx = graphic,
					ImpactVelocity = force,
					StartDelay = (i - 1 ) * 0.1
				},
				ProjectileCap = 1,
			})
			local doubleChance = GetTotalHeroTraitValue("DoubleOlympianProjectileChance") * GetTotalHeroTraitValue( "LuckMultiplier", { IsMultiplier = true })
			if RandomChance(doubleChance) then
				wait( GetTotalHeroTraitValue("DoubleOlympianProjectileInterval" ))
				CreateProjectileFromUnit({ 
					Name = "PoseidonOmegaWave", 
					Id = CurrentRun.Hero.ObjectId, 
					Angle = triggerArgs.ImpactAngle, 
					DestinationId = victim.ObjectId, 
					FireFromTarget = true,
					DamageMultiplier = (traitData.OnWeaponFiredFunctions.FunctionArgs.DamageMultiplier or 1) * 2,
					DataProperties = 
					{
						StartFx = graphic,
						ImpactVelocity = force,
						StartDelay = (i - 1 ) * 0.1
					},
					ProjectileCap = 2,
				})
			end
		end
		return
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
modutil.mod.Path.Wrap("DamageEnemy", function(baseFunc, victim, triggerArgs)
	baseFunc(victim, triggerArgs)
	if not HeroHasTrait(gods.GetInternalBoonName("ZeusWrathBoon")) then
		return
	end
	
	if (triggerArgs.SourceProjectile == "ZeusEchoStrike") then
		for _, data in pairs(GetHeroTraitValues("OnEnemyDamagedAction")) do
			if data.Name == "ZeusWrath" then
			return ZeusWrath( victim, data.Args )
			end
		end
	end
end)

function ZeusWrath( unit, args )
	local strikeCount = args.MinStrikes
	while RandomChance( args.DoubleBoltChance * GetTotalHeroTraitValue( "LuckMultiplier", { IsMultiplier = true }) ) and strikeCount < args.MaxStrikes do
		strikeCount = strikeCount + 1
	end
	if strikeCount > 1 then
		thread( InCombatTextArgs, { TargetId = CurrentRun.Hero.ObjectId, Text = "ZeusWrath_CombatText", LuaKey = "TempTextData", ShadowScaleX = 1.1, LuaValue = { Amount = strikeCount, BoonName = gods.GetInternalBoonName("ZeusWrathBoon") }} )
	end
	CreateZeusBolt({
		ProjectileName = args.ProjectileName, 
		TargetId = unit.ObjectId, 
		DamageMultiplier = args.DamageMultiplier,
		Delay = 0.2, 
		FollowUpDelay = 0.2, 
		Count = strikeCount
		})
end

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

--[[
	AirBoon = 
	{
		Elements = { "Air" },
		DebugOnly = true,
	},
	FireBoon = 
	{
		Elements = {"Fire"},
		DebugOnly = true,
	},
	EarthBoon = 
	{
		Elements = {"Earth"},
		DebugOnly = true,
	},
	WaterBoon = 
	{
		Elements = {"Water"},
		DebugOnly = true,
	},
	AetherBoon = 
	{
		Elements = {"Aether"},
		DebugOnly = true,
	},
    	SynergyTrait =
	{
		InheritFrom = { "AetherBoon", },
		GameStateRequirements =
		{
			{
				Path = { "CurrentRun", "CurrentRoom", "ChosenRewardType", },
				IsNone = { "Devotion", },
			},
		},
		IsDuoBoon = true,
		Frame = "Duo",
		BlockStacking = true,
		DebugOnly = true,
		RarityLevels =
		{
			Duo =
			{
				MinMultiplier = 1,
				MaxMultiplier = 1,
			},
		},
	},

	LegacyTrait = 
	{
		IsLegacyTrait = true,
		DebugOnly = true,
	},

	UnityTrait = 
	{
		IsElementalTrait = true,
		BlockStacking = true,
		BlockInRunRarify = true,
		BlockMenuRarify = true,
		ExcludeFromRarityCount = true,
		CustomRarityName = "Boon_Infusion",
		CustomRarityColor = Color.BoonPatchElemental,
		InfoBackingAnimation = "BoonSlotUnity",
		UpgradeChoiceBackingAnimation = "BoonSlotUnity",
		Frame = "Unity",
		DebugOnly = true,
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1,
			},
			Rare =
			{
				Multiplier = 1,
			},
			Epic =
			{
				Multiplier = 1,
			},
		}
	},
]]