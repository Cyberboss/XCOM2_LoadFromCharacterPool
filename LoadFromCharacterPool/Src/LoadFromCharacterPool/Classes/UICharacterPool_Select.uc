// This is an Unreal Script

class UICharacterPool_Select extends UICharacterPool;

var XComCharacterCustomization CustomizationManager;
var XComHumanPawn Pawn;
var UICheckbox LastCheckedBox;
var XComGameState_Unit LastSelectedUnit;

var UIButton LoadButton;

var localized string m_strLoadCharacter;

delegate OnReturn();

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	//now basically undo everything that was just done
	DeselectAllButton.Hide();
	SelectAllButton.Hide();

	LastCheckedBox = none;

	//HACK ALERT
	 m_strLoadCharacter = "Load Character";

	
	LoadButton = Spawn(class'UIButton', Container);
	LoadButton.InitButton('',  Caps(m_strLoadCharacter), OnSelectedCharCallback, eUIButtonStyle_HOTLINK_BUTTON);
	LoadButton.DisableButton(m_strNothingSelected);
	LoadButton.SetResizeToText(true);
	LoadButton.SetPosition(SelectAllButton.X, SelectAllButton.Y);

}

simulated function OnSelectedCharCallback(UIButton kButton)
{
	local XComGameState_Unit SelectedUnit, UpdatedState;
	local array<X2BodyPartTemplate> BodyParts;
	local int Index;

	UpdatedState = CustomizationManager.UpdatedUnitState;

	SelectedUnit = SelectedCharacters[0];

	//set the gender first the normal way to deal with the genetailia	
	CustomizationManager.OnCategoryValueChange(eUICustomizeCat_Gender, 0, SelectedUnit.kAppearance.iGender);

	//These should be the droids that we're looking for
	UpdatedState.SetTAppearance(SelectedUnit.kAppearance);
	UpdatedState.SetCharacterName(SelectedUnit.SafeGetCharacterFirstName(), SelectedUnit.SafeGetCharacterLastName(), SelectedUnit.SafeGetCharacterNickName());
	UpdatedState.SetCountry(SelectedUnit.GetCountry());
	UpdatedState.SetBackground(SelectedUnit.GetBackground());

	//shouldnt do this, that's a gameplay changer
	//UpdatedState.SetSoldierClassTemplate(SelectedUnit.GetSoldierClassTemplateName());

	UpdatedState.UpdatePersonalityTemplate();

	Pawn.SetAppearance(UpdatedState.kAppearance);
	Pawn.PlayHQIdleAnim(, , true);
	UpdatedState.StoreAppearance();

	//Updating the weapon is a complete bitch (See XComCharacterCustomization.uc lines 551 and 589)
	//It's a bold strategy cotton we'll see if it works

	CustomizationManager.OnCategoryValueChange(eUICustomizeCat_WeaponColor, -1, SelectedUnit.kAppearance.iWeaponTint);

	//so this is dumb, we need to search for the part name to find the part index.... so it can find the part name

	class'X2BodyPartTemplateManager'.static.GetBodyPartTemplateManager().GetFilteredUberTemplates("Patterns", CustomizationManager, `XCOMGAME.SharedBodyPartFilter.FilterAny, BodyParts);
	
	for(Index = 0; Index < BodyParts.Length; ++Index)
		if(SelectedUnit.kAppearance.nmWeaponPattern == BodyParts[Index].DataName)
			break;

	if(Index != BodyParts.Length)
		CustomizationManager.OnCategoryValueChange(eUICustomizeCat_WeaponPatterns, 0, Index);
	else
	{
		`Log("LFCP: Warning unable to find index of weapon camo:");
		`Log(SelectedUnit.kAppearance.nmWeaponPattern);
	}

	//GOT 'EM

	OnCancel();

}

simulated function UpdateEnabledButtons()
{
	if(SelectedCharacters.Length == 0)
		LoadButton.DisableButton(m_strNothingSelected);
	else
		LoadButton.EnableButton();

	super.UpdateEnabledButtons();
}
simulated function SelectSoldier(UICheckbox CheckBox)
{
	local UIPanel SelectedPanel;
	local XComGameState_Unit SelectedUnit;
	local int itemIndex;

	SelectedPanel = List.GetSelectedItem();
	itemIndex = List.GetItemIndex(SelectedPanel);
	SelectedUnit = GetSoldierInSlot(itemIndex);

	if(LastCheckedBox != none)
	{
		LastCheckedBox.SetChecked(false, false);
		SelectedCharacters.RemoveItem(LastSelectedUnit);
	}

	if (CheckBox.bChecked)
	{
		SelectedCharacters.AddItem(SelectedUnit);
		LastSelectedUnit = SelectedUnit;
		LastCheckedBox = CheckBox;
	}
	else
		LastCheckedBox = none;
	
	UpdateEnabledButtons();
}
function SetParams(XComCharacterCustomization ACustomizationManager, delegate<OnReturn> AOnReturn, XComHumanPawn APawn)
{
	CustomizationManager = ACustomizationManager;
	OnReturn = AOnReturn;
	Pawn = APawn;
}

simulated function OnCancel()
{
	//super has a weird fade to black thing that we won't do
	AnimateOut();
	CloseScreen();
	OnReturn();
}