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

sjson.hook(TraitTextFile, function(data)
    table.insert(data.Texts, mod.HeraRandomCurseBoon_Text)
	table.insert(data.Texts, mod.PoseidonWrathBoon_Text)
end)

game.TraitData.WrathTrait = {
    BlockStacking = true,
    BlockInRunRarify = true,
    BlockMenuRarify = true,
    CustomRarityName = "Wrath",
    CustomRarityColor = Color.BoonPatchHeroic,
    InfoBackingAnimation = "BoonSlotHeroic",
    UpgradeChoiceBackingAnimation = "BoonSlotHeroic",
    Frame = "Untiy",
    RarityLevels = {
        Legendary = {
            MinMultiplier = 1,
            MaxMultiplier = 1,
        },
    },
}

--[[sjson.hook(TraitData, function(data)
	table.insert(data.WeaponRarityUpgradeOrder, mod.WrathTrait_Rarity)
end)]]--

--[[ 
uid, internal, charactername ,legendary, rarity, slot, blockstacking,  statlines, extractval, elements, displayName
extrafields, boonIconPath, requirements, flavourtext
]]
gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    characterName = "Hera",    
	internalBoonName = "RandomCurseBoon",
    isLegendary = false,
    Elements = {"Fire"},
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
		--[[{
			Key = "ReportedBonusOlympianDamage",
			ExtractAs = "TooltipDamageBonus",
			Format = "PercentDelta",
		},]]--
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

gods.IsBoonRegistered("RandomCurseBoon", true)

gods.CreateBoon({
    pluginGUID = _PLUGIN.guid,
    internalBoonName = "PoseidonWrathBoon",
    isLegendary = false,
	InheritFrom = Water
    characterName = "Poseidon",
    addToExistingGod = true,
	reuseBaseIcons = true,
    BlockStacking = true,

    displayName = "Wrath of Poseidon",
    description = "Your splash effects fire your effects from {$TraitData.OmegaPoseidonProjectileBoon.Name} with greater {$Keywords.BaseDamage} at no extra cost.",
	StatLines = { "BonusOceanSwellStatDisplay1" },
	requirements =
	{
		OneFromEachSet =
		{
			{ "OmegaPoseidonProjectileBoon" },
			{ "PoseidonWeaponBoon", "PoseidonSpecialBoon", "FocusDamageShaveBoon" },
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
		OnEnemyDamagedAction =
		{
			FunctionName = "rom.mods." .. _PLUGIN.guid .. ".not.CheckPoseidonSplashAndWave",
		}
    },
})

-- local PoseidonWrathBoonPluginGUID = _PLUGIN.guid .. '-' .. 'PoseidonWrathBoon'

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
function not_public.CheckPoseidonSplashAndWave(victim, functionArgs, triggerArgs )
	local cooldownName = "PoseidonSplash"
	if functionArgs.CooldownName then
		cooldownName = functionArgs.CooldownName
	end
	if ProjectileHasUnitHit( triggerArgs.ProjectileId, "PoseidonSplash") 
		and (triggerArgs.SourceWeapon == nil or not functionArgs.MultihitWeaponWhitelistLookup or not functionArgs.MultihitWeaponWhitelistLookup[triggerArgs.SourceWeapon])
		and (triggerArgs.SourceProjectile == nil or not functionArgs.MultihitProjectileWhitelistLookup or not functionArgs.MultihitProjectileWhitelistLookup[triggerArgs.SourceProjectile])  then
		return
	end
	local passesMultihitCheck = true
	if triggerArgs.SourceProjectile ~= nil and functionArgs.MultihitProjectileWhitelistLookup and functionArgs.MultihitProjectileWhitelistLookup[triggerArgs.SourceProjectile] and functionArgs.MultihitProjectileConditions[triggerArgs.SourceProjectile] then
		local conditions = ShallowCopyTable(functionArgs.MultihitProjectileConditions[triggerArgs.SourceProjectile])
		
		if conditions.TraitNameRequirements then
			for _, traitConditions in pairs( conditions.TraitNameRequirements ) do
				if traitConditions.TraitName and HeroHasTrait(traitConditions.TraitName) then
					conditions = ShallowCopyTable(traitConditions)
					break
				end
			end
		end
		if not conditions.Cooldown and not conditions.Window and ProjectileHasUnitHit( triggerArgs.ProjectileId, "PoseidonSplash") then
			return
		end
		if conditions.Cooldown and not CheckCooldown( "PoseidonSplash", conditions.Cooldown ) then
			return
		end
		if conditions.Window and CheckCountInWindow("PoseidonSplash", conditions.Window, conditions.Count ) then
			return
		end
	elseif triggerArgs.SourceWeapon ~= nil and functionArgs.MultihitWeaponWhitelistLookup[triggerArgs.SourceWeapon] and functionArgs.MultihitWeaponConditions[triggerArgs.SourceWeapon] then
		local conditions = functionArgs.MultihitWeaponConditions[triggerArgs.SourceWeapon]
		if conditions.Cooldown and not CheckCooldown( "PoseidonSplash", conditions.Cooldown ) then
			return
		end
		if conditions.Window and CheckCountInWindow("PoseidonSplash", conditions.Window, conditions.Count ) then
			return
		end
	else
		if functionArgs.Cooldown and not CheckCooldown( "PoseidonSplash", functionArgs.Cooldown ) then
			return
		end
		if functionArgs.Window and CheckCountInWindow("PoseidonSplash", functionArgs.Window, functionArgs.Count ) then
			return
		end		
	end
	local graphic = nil
	local count = 1
	local traitData = GetHeroTrait("OmegaPoseidonProjectileBoon")
	--[[print(traitData)
	for k,v in pairs(traitData) do
		print(k)
	end
	print(traitData.OnWeaponFiredFunctions.FunctionArgs.DamageMultiplier)]]--

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
end

--[[modutil.mod.Path.Context.Wrap.Static("CheckPoseidonSplash", function()
  modutil.mod.Path.Wrap("CreateProjectileFromUnit",
    function(base, args, ...)
      if not HeroHasTrait(PoseidonWrathBoonPluginGUID) then
        return base(args, ...)
      end
      base(args, ...) -- spawn splash
      args.Name = "PoseidonOmegaWave"
      return base(args, ...) -- spawn swell
    end)
end)]]--

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