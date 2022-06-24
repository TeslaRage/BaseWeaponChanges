class X2DownloadableContentInfo_BaseWeaponChanges extends X2DownloadableContentInfo;

var config (BaseWeaponChanges) array<name> LightWeaponTemplates;
var config (BaseWeaponChanges) array<name> HeavyWeaponTemplates;
var config (BaseWeaponChanges) array<name> BurningWeaponTemplates;
var config (BaseWeaponChanges) array<name> BleedingWeaponTemplates;
var config (BaseWeaponChanges) array<name> StunningWeaponTemplates;

var config (BaseWeaponChanges) int BurnDamage;
var config (BaseWeaponChanges) int BurnChance;
var config (BaseWeaponChanges) int BleedTurns;
var config (BaseWeaponChanges) int BleedDamage;
var config (BaseWeaponChanges) int BleedChance;
var config (BaseWeaponChanges) int Stun1Chance;
var config (BaseWeaponChanges) int Stun2Chance;

var config (BaseWeaponChanges) float BreakThroughTechTimeScalar;
var config (BaseWeaponChanges) array<name> TechsToDisable;
var config (BaseWeaponChanges) array<name> BreakthroughsToConvert;

var localized string BleedChanceLabel;
var localized string BleedLabel;

static event OnPostTemplatesCreated()
{
	PatchWeapons();
    PatchTechs();
}

static function PatchWeapons()
{
    local X2ItemTemplateManager ItemTemplateMan;
    local array<X2DataTemplate> DataTemplates;
    local X2DataTemplate DataTemplate;
    local X2WeaponTemplate WeaponTemplate;
    local X2Effect_Burning BurningEffect;
    local X2Effect_Persistent BleedingEffect;
    local name TemplateName;

    ItemTemplateMan = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
    
    // Light Weapon
    foreach default.LightWeaponTemplates(TemplateName)
    {
        ItemTemplateMan.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);

        foreach DataTemplates(DataTemplate)
        {
            WeaponTemplate = X2WeaponTemplate(DataTemplate);
            if (WeaponTemplate == none) continue;

            WeaponTemplate.Abilities.AddItem('TR_LightWeapon');
            WeaponTemplate.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, class'X2Ability_TRWeaponAbilitySet'.default.LightWeaponMobilityBonus);
        }
    }

    // Heavy Weapon
    DataTemplates.Length = 0;
    foreach default.HeavyWeaponTemplates(TemplateName)
    {
        ItemTemplateMan.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);

        foreach DataTemplates(DataTemplate)
        {
            WeaponTemplate = X2WeaponTemplate(DataTemplate);
            if (WeaponTemplate == none) continue;

            WeaponTemplate.Abilities.AddItem('TR_HeavyWeapon');
            WeaponTemplate.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, -class'X2Ability_TRWeaponAbilitySet'.default.HeavyWeaponMobilityPenalty);
        }
    }

    // Burning Weapon
    DataTemplates.Length = 0;
    foreach default.BurningWeaponTemplates(TemplateName)
    {
        ItemTemplateMan.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);

        foreach DataTemplates(DataTemplate)
        {
            WeaponTemplate = X2WeaponTemplate(DataTemplate);
            if (WeaponTemplate == none) continue;

            WeaponTemplate.Abilities.AddItem('TR_BurningWeapon');
            
            BurningEffect = class'X2StatusEffects'.static.CreateBurningStatusEffect(default.BurnDamage, 0);
            BurningEffect.ApplyChance = default.BurnChance;
            WeaponTemplate.BonusWeaponEffects.AddItem(BurningEffect);
            WeaponTemplate.SetUIStatMarkup(class'XLocalizedData'.default.BurnChanceLabel, , default.BurnChance, , , "%");
            WeaponTemplate.SetUIStatMarkup(class'XLocalizedData'.default.BurningLabel, , default.BurnDamage);
        }
    }

    // Bleeding and Stunning are applied to Ripjacks and they have existing effects that need to be cleared off
    ClearExistingEffects(default.BleedingWeaponTemplates, ItemTemplateMan);
    ClearExistingEffects(default.StunningWeaponTemplates, ItemTemplateMan);
    ClearExistingEffects(default.BurningWeaponTemplates, ItemTemplateMan);

    // Bleeding Weapon
    DataTemplates.Length = 0;
    foreach default.BleedingWeaponTemplates(TemplateName)
    {
        ItemTemplateMan.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);

        foreach DataTemplates(DataTemplate)
        {
            WeaponTemplate = X2WeaponTemplate(DataTemplate);
            if (WeaponTemplate == none) continue;

            WeaponTemplate.Abilities.AddItem('TR_BleedingWeapon');
            
            BleedingEffect = class'X2StatusEffects'.static.CreateBleedingStatusEffect(default.BleedTurns, default.BleedDamage);
            BleedingEffect.ApplyChance = default.BleedChance;
            WeaponTemplate.BonusWeaponEffects.AddItem(BleedingEffect);
            WeaponTemplate.SetUIStatMarkup(default.BleedChanceLabel, , default.BleedChance, , , "%");
            WeaponTemplate.SetUIStatMarkup(default.BleedLabel, , default.BleedDamage);
        }
    }

    // Stunning Weapon
    DataTemplates.Length = 0;
    foreach default.StunningWeaponTemplates(TemplateName)
    {
        ItemTemplateMan.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);

        foreach DataTemplates(DataTemplate)
        {
            WeaponTemplate = X2WeaponTemplate(DataTemplate);
            if (WeaponTemplate == none) continue;

            WeaponTemplate.Abilities.AddItem('TR_StunningWeapon');
            
            WeaponTemplate.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateStunnedStatusEffect(1, default.Stun1Chance, false));
		    WeaponTemplate.BonusWeaponEffects.AddItem(class'X2StatusEffects'.static.CreateStunnedStatusEffect(1, default.Stun2Chance, false));
            WeaponTemplate.SetUIStatMarkup(class'XLocalizedData'.default.StunChanceLabel, , default.Stun1Chance + default.Stun2Chance, , , "%");
        }
    }

    // Chosen Sniper Rifle XCOM
    ItemTemplateMan.FindDataTemplateAllDifficulties('ChosenSniperRifle_XCOM', DataTemplates);

    foreach DataTemplates(DataTemplate)
    {
        WeaponTemplate = X2WeaponTemplate(DataTemplate);
        if (WeaponTemplate == none) continue;

        WeaponTemplate.iTypicalActionCost = 2;
    }
}

static function ClearExistingEffects(array<name> WeaponNames, X2ItemTemplateManager ItemTemplateMan)
{
    local name TemplateName;
    local array<X2DataTemplate> DataTemplates;
    local X2DataTemplate DataTemplate;
    local X2WeaponTemplate WeaponTemplate;

    foreach WeaponNames(TemplateName)
    {
        ItemTemplateMan.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);

        foreach DataTemplates(DataTemplate)
        {
            WeaponTemplate = X2WeaponTemplate(DataTemplate);
            if (WeaponTemplate == none) continue;

            WeaponTemplate.BonusWeaponEffects.Length = 0;
        }
    }
}

static function PatchTechs()
{
    local X2StrategyElementTemplateManager StratTemplateMan;
    local array<X2DataTemplate> DataTemplates;
    local X2DataTemplate DataTemplate;
    local X2TechTemplate TechTemplate;
	local name TechName;

	// Make breakthrough techs appear as normal techs
	StratTemplateMan = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	foreach default.BreakthroughsToConvert(TechName)
	{
		StratTemplateMan.FindDataTemplateAllDifficulties(TechName, DataTemplates);

		foreach DataTemplates(DataTemplate)
		{
			TechTemplate = X2TechTemplate(DataTemplate);
			if (TechTemplate == none) continue;

			TechTemplate.PointsToComplete *= default.BreakThroughTechTimeScalar;
			TechTemplate.bBreakthrough = false;
		}
	}

	// Took this from Weapon and Item Overhaul
	// Set unobtainable requirements for all weapon damage breakthroughs
	foreach default.TechsToDisable(TechName)
	{
		StratTemplateMan.FindDataTemplateAllDifficulties(TechName, DataTemplates);
		foreach DataTemplates(DataTemplate)
		{
			TechTemplate = X2TechTemplate(DataTemplate);
			if (TechTemplate != none)
			{
				TechTemplate.Requirements.RequiredEngineeringScore = 99999;
				TechTemplate.Requirements.RequiredScienceScore = 99999;
				TechTemplate.Requirements.bVisibleIfPersonnelGatesNotMet = false;
			}
		}
	}
}