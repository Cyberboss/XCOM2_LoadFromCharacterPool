class UIScreenListener_Customize_LFCP extends UIScreenListener;

var UICustomize ParentScreen;

var int listIndex;

var public localized string strLFP;

event OnInit(UIScreen Screen)
{
	
	`Log("LFCP: Customize menu initialized");
	//HACK: I don't know how to properly use the localization files
	strLFP = "Load from Character Pool";

	listIndex = -1;
	ParentScreen = UICustomize(Screen); 
	ParentScreen.List.AddOnInitDelegate(AddListButton);
}

simulated function OnReceiveFocus(UIScreen Screen)
{
	`Log("LFCP: Customize menu recieved focus");
	AddListButton(none);
}
// This event is triggered after a screen loses focus
//event OnLoseFocus(UIScreen Screen);


// This event is triggered when a screen is removed
event OnRemoved(UIScreen Screen)
{
	//clear reference to UIScreen so it can be garbage collected
	ParentScreen = none;
}

//adds a button to the existing MainMenu list
simulated function AddListButton(UIPanel Panel)
{
	if(listIndex == -1)
		listIndex = ParentScreen.List.ItemCount;
	ParentScreen.GetListItem(listIndex).UpdateDataDescription(class'UIUtilities_Text'.static.GetColoredText(strLFP, eUIState_Normal), OnLFPButtonCallback);
}


//callback handler for list button -- invokes the character pool loader element
simulated function OnLFPButtonCallback()
{

	
	local XComHQPresentationLayer HQPres;
	local UICharacterPool_Select PoolSelect;
	`Log("LFCP: Entering Character Pool UI");

	//hide the pawn
	ParentScreen.CustomizeManager.ActorPawn.SetHidden(true);

	HQPres = `HQPRES;
	PoolSelect = UICharacterPool_Select(HQPres.ScreenStack.Push(HQPres.Spawn(class'UICharacterPool_Select', HQPres), HQPres.Get3DMovie()));
	PoolSelect.SetParams(ParentScreen.CustomizeManager, OnLFPReturn, XComHumanPawn(ParentScreen.CustomizeManager.ActorPawn));
}

simulated function OnLFPReturn()
{
	ParentScreen.CustomizeManager.ActorPawn.SetHidden(false);
	//we need to leave now, otherwise the neck goes INSANE if the gender was changed, this fixes that
	ParentScreen.CloseScreen();
}

defaultproperties
{
	// Leaving this assigned to none will cause every screen to trigger its signals on this class
	ScreenClass = UICustomize_Menu;
}