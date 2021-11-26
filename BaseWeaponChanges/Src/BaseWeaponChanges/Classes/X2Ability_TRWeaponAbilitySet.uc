class X2Ability_TRWeaponAbilitySet extends X2Ability config(BaseWeaponChanges);

var config int LightWeaponMobilityBonus;
var config int HeavyWeaponMobilityPenalty;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(TR_LightWeapon());
    Templates.AddItem(TR_HeavyWeapon());
    Templates.AddItem(TR_BurningWeapon());
    Templates.AddItem(TR_BleedingWeapon());
    Templates.AddItem(TR_StunningWeapon());

	return Templates;
}

static function X2AbilityTemplate TR_LightWeapon()
{
	local X2AbilityTemplate Template;
    local X2Effect_PersistentStatChange StatEffect;

	Template = CreatePassiveAbility('TR_LightWeapon', "img:///UILibrary_PerkIcons.UIPerk_hunter",, false);

    StatEffect = new class 'X2Effect_PersistentStatChange';
	StatEffect.BuildPersistentEffect(1, true, false, false);
	StatEffect.AddPersistentStatChange(eStat_Mobility, default.LightWeaponMobilityBonus);
	Template.AddTargetEffect(StatEffect);

	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, default.LightWeaponMobilityBonus);

	return Template;
}

static function X2AbilityTemplate TR_HeavyWeapon()
{
	local X2AbilityTemplate Template;
    local X2Effect_PersistentStatChange StatEffect;

	Template = CreatePassiveAbility('TR_HeavyWeapon', "img:///UILibrary_PerkIcons.UIPerk_hunter",, false);

    StatEffect = new class 'X2Effect_PersistentStatChange';
	StatEffect.BuildPersistentEffect(1, true, false, false);
	StatEffect.AddPersistentStatChange(eStat_Mobility, -default.HeavyWeaponMobilityPenalty);
	Template.AddTargetEffect(StatEffect);

	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, -default.HeavyWeaponMobilityPenalty);

	return Template;
}

static function X2AbilityTemplate TR_BurningWeapon()
{
	local X2AbilityTemplate Template;

	Template = CreatePassiveAbility('TR_BurningWeapon', "img:///UILibrary_PerkIcons.UIPerk_hunter",, false);

	return Template;
}

static function X2AbilityTemplate TR_BleedingWeapon()
{
	local X2AbilityTemplate Template;

	Template = CreatePassiveAbility('TR_BleedingWeapon', "img:///UILibrary_PerkIcons.UIPerk_hunter",, false);

	return Template;
}

static function X2AbilityTemplate TR_StunningWeapon()
{
	local X2AbilityTemplate Template;

	Template = CreatePassiveAbility('TR_StunningWeapon', "img:///UILibrary_PerkIcons.UIPerk_hunter",, false);

	return Template;
}

// HELPER
static function X2AbilityTemplate CreatePassiveAbility(name AbilityName, optional string IconString, optional name IconEffectName = AbilityName, optional bool bDisplayIcon = true)
{	
	local X2AbilityTemplate Template;
	local X2Effect_Persistent IconEffect;	

	`CREATE_X2ABILITY_TEMPLATE (Template, AbilityName);
	Template.IconImage = IconString;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bCrossClassEligible = false;
	Template.bUniqueSource = true;
	Template.bIsPassive = true;

	// Dummy effect to show a passive icon in the tactical UI for the SourceUnit
	IconEffect = new class'X2Effect_Persistent';
	IconEffect.BuildPersistentEffect(1, true, false);
	IconEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage, bDisplayIcon,, Template.AbilitySourceName);
	IconEffect.EffectName = IconEffectName;
	Template.AddTargetEffect(IconEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	return Template;
}