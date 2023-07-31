untyped


global function MenuLobby_Init

global function InitLobbyMenu
global function UICodeCallback_SetupPlayerListGenElements
global function UpdateAnnouncementDialog
global function EnableButton
global function DisableButton

global function UICodeCallback_CommunityUpdated
global function UICodeCallback_FactionUpdated
global function Lobby_UpdateInboxButtons

global function GetTimeToRestartMatchMaking

global function RefreshCreditsAvailable

global function InviteFriendsIfAllowed
global function SetPutPlayerInMatchmakingAfterDelay
global function StartNSPrivateMatch
global function OpenNSServerBrowser

global function DLCStoreShouldBeMarkedAsNew

global function SetNextAutoMatchmakingPlaylist
global function GetNextAutoMatchmakingPlaylist

global function OnDpadCommsButton_Activate

global function GetActiveSearchingPlaylist

global function Lobby_SetFDModeBasedOnSearching
global function Lobby_IsFDMode
global function Lobby_SetAutoFDOpen
global function Lobby_SetFDMode
global function Lobby_ToggleFDMode
global function Lobby_CallsignButton3EventHandler
global function Lobby_RefreshButtons

global function OnStoreButton_Activate
global function OnStoreBundlesButton_Activate
global function OnStoreNewReleasesButton_Activate

global function loebAdd
global function loebSetLockedButton

const string MATCHMAKING_AUDIO_CONNECTING = "menu_campaignsummary_titanunlocked"

struct
{
	struct {
		string playlistName = ""
		int mapIdx = -1
		int modeIdx = -1
	} preCacheInfo

	array searchIconElems
	array searchTextElems
	array matchStartCountdownElems
	array matchStatusRuis

	array creditsAvailableElems

	table<int, int> buttonCoords
	table<string, var> buttonIdentifiers

	var chatroomMenu
	var chatroomMenu_chatroomWidget

	var findGameButton
	var inviteRoomButton
	var inviteFriendsButton
	var inviteFriendsToNetworkButton
	var toggleMenuModeButton

	var networksMoreButton

	int inboxHeaderIndex
	var inboxButton

	int customizeHeaderIndex
	var pilotButton
	var titanButton
	var boostsButton
	var storeButton
	var storeNewReleasesButton
	var storeBundlesButton
	var factionButton
	var bannerButton
	var patchButton
	var statsButton
	var networksHeader
	var settingsHeader
	var storeHeader
	var browseNetworkButton
	var faqButton
	var dpadCommsButton

	var genUpButton

	array<var> lobbyButtons
	var playHeader
	var customizeHeader
	var callsignHeader

	float timeToRestartMatchMaking = 0

	string nextAutoMatchmakingPlaylist

	var callsignCard

	bool putPlayerInMatchmakingAfterDelay = false
	float matchmakingStartTime = 0.0
	int etaTime = 0
	int etaMaxMinutes = 15
	string lastMixtapeMatchmakingStatus

	ComboStruct &lobbyComboStruct

	bool isFDMode = false
	bool shouldAutoOpenFDMenu = false
} file

void function MenuLobby_Init()
{
	PrecacheHUDMaterial( $"ui/menu/lobby/player_hover" )
	PrecacheHUDMaterial( $"ui/menu/lobby/chatroom_player" )
	PrecacheHUDMaterial( $"ui/menu/lobby/chatroom_hover" )
	PrecacheHUDMaterial( $"ui/menu/main_menu/motd_background" )
	PrecacheHUDMaterial( $"ui/menu/main_menu/motd_background_happyhour" )

	AddUICallback_OnLevelInit( OnLobbyLevelInit )
}

//////////////////////
/// LOEB FUNCTIONS ///
//////////////////////

void function loebAdd ( int headerIndexParam, string buttonNameParam, void functionref(var) funcParam)
{
	ComboStruct comboStruct = file.lobbyComboStruct
	array<table <int,int> > buttonIndexes
	var button
	int buttonIndexParam
    if (headerIndexParam in file.buttonCoords)
	{
		file.buttonCoords[headerIndexParam] <- file.buttonCoords[headerIndexParam] + 1
	} else {
		file.buttonCoords[headerIndexParam] <- 0
	}
	button = AddComboButton( comboStruct, headerIndexParam, file.buttonCoords[headerIndexParam], buttonNameParam)
	file.lobbyButtons.append(button)
	file.buttonIdentifiers[buttonNameParam] <- button
	Hud_AddEventHandler (button, UIE_CLICK, funcParam)
}

void function loebSetLockedButton (string identifier, bool enabled)
{
	Hud_SetLocked(file.buttonIdentifiers[identifier], enabled)
}

//////////////////////

bool function ChatroomIsVisibleAndFocused()
{
	return Hud_IsVisible( file.chatroomMenu ) && Hud_IsFocused( file.chatroomMenu_chatroomWidget );
}

bool function ChatroomIsVisibleAndNotFocused()
{
	return Hud_IsVisible( file.chatroomMenu ) && !Hud_IsFocused( file.chatroomMenu_chatroomWidget );
}

void function Lobby_UpdateInboxButtons()
{
	var menu = GetMenu( "LobbyMenu" )
	if ( GetUIPlayer() == null || !IsPersistenceAvailable() )
		return

	bool hasNewMail = (Inbox_HasUnreadMessages() && Inbox_GetTotalMessageCount() > 0) || PlayerRandomUnlock_GetTotal( GetUIPlayer() ) > 0
	if ( hasNewMail )
	{
		int messageCount = Inbox_GetTotalMessageCount()
		int lootCount = PlayerRandomUnlock_GetTotal( GetUIPlayer() )
		int totalCount = messageCount + lootCount

		string countString
		if ( totalCount >= MAX_MAIL_COUNT )
			countString = MAX_MAIL_COUNT + "+"
		else
			countString = string( totalCount )

		SetComboButtonHeaderTitle( menu, 3, Localize( "#MENU_HEADER_NETWORKS_NEW_MSGS", countString )  )
		ComboButton_SetText( file.buttonIdentifiers[Localize("#MENU_TITLE_INBOX")], Localize( "#MENU_TITLE_INBOX_NEW_MSGS", countString ) )
	}
	else
	{
		SetComboButtonHeaderTitle( menu, 3, Localize( "#MENU_HEADER_NETWORKS" )  )
		ComboButton_SetText( file.buttonIdentifiers[Localize("#MENU_TITLE_INBOX")], Localize( "#MENU_TITLE_READ" ) )
	}

	ComboButton_SetNewMail( file.buttonIdentifiers[Localize("#MENU_TITLE_INBOX")], hasNewMail )
}

void function InitLobbyMenu()
{
	var menu = GetMenu( "LobbyMenu" )

	InitOpenInvitesMenu()

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT", "", null, ChatroomIsVisibleAndNotFocused )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( menu, BUTTON_BACK, "#BACK_BUTTON_POSTGAME_REPORT", "#POSTGAME_REPORT", OpenPostGameMenu, IsPostGameMenuValid )
	AddMenuFooterOption( menu, BUTTON_TRIGGER_RIGHT, "#R_TRIGGER_CHAT", "", null, IsVoiceChatPushToTalk )

	InitChatroom( menu )

	file.chatroomMenu = Hud_GetChild( menu, "ChatRoomPanel" )
	file.chatroomMenu_chatroomWidget = Hud_GetChild( file.chatroomMenu, "ChatRoom" )
	file.genUpButton = Hud_GetChild( menu, "GenUpButton" )

	SetupComboButtonTest( menu )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnLobbyMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnLobbyMenu_Close )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnLobbyMenu_NavigateBack )

	RegisterUIVarChangeCallback( "gameStartTime", GameStartTime_Changed )

	RegisterUIVarChangeCallback( "showGameSummary", ShowGameSummary_Changed )

	file.searchIconElems = GetElementsByClassnameForMenus( "SearchIconClass", uiGlobal.allMenus )
	file.searchTextElems = GetElementsByClassnameForMenus( "SearchTextClass", uiGlobal.allMenus )
	file.matchStartCountdownElems = GetElementsByClassnameForMenus( "MatchStartCountdownClass", uiGlobal.allMenus )
	file.matchStatusRuis = GetElementsByClassnameForMenus( "MatchmakingStatusRui", uiGlobal.allMenus )
	file.creditsAvailableElems = GetElementsByClassnameForMenus( "CreditsAvailableClass", uiGlobal.allMenus )

	file.callsignCard = Hud_GetChild( menu, "CallsignCard" )

	AddEventHandlerToButton( menu, "GenUpButton", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "Generation_Respawn" ) ) )

	AddMenuVarChangeHandler( "focus", UpdateFooterOptions )
	AddMenuVarChangeHandler( "isFullyConnected", UpdateFooterOptions )
	AddMenuVarChangeHandler( "isPartyLeader", UpdateFooterOptions )
	AddMenuVarChangeHandler( "isPrivateMatch", UpdateFooterOptions )
	#if DURANGO_PROG
		AddMenuVarChangeHandler( "DURANGO_canInviteFriends", UpdateFooterOptions )
		AddMenuVarChangeHandler( "DURANGO_isJoinable", UpdateFooterOptions )
		AddMenuVarChangeHandler( "DURANGO_isGameFullyInstalled", UpdateFooterOptions )
	#elseif PS4_PROG
		AddMenuVarChangeHandler( "PS4_canInviteFriends", UpdateFooterOptions )
	#elseif PC_PROG
		AddMenuVarChangeHandler( "ORIGIN_isEnabled", UpdateFooterOptions )
		AddMenuVarChangeHandler( "ORIGIN_isJoinable", UpdateFooterOptions )
	#endif

	RegisterSignal( "BypassWaitBeforeRestartingMatchmaking" )
	RegisterSignal( "PutPlayerInMatchmakingAfterDelay" )
	RegisterSignal( "CancelRestartingMatchmaking" )
	RegisterSignal( "LeaveParty" )
}

void function SetupComboButtonTest( var menu )
{
	ComboStruct comboStruct = ComboButtons_Create( menu )
	file.lobbyComboStruct = comboStruct

	int headerIndex = 0
	int buttonIndex = 0
	for (int i = -1; i < 5; i++)
	{
		switch(i)
		{
			case 0:
				file.playHeader = AddComboButtonHeader( comboStruct, 0, "#MENU_HEADER_PLAY")
			case 1:
				file.customizeHeader = AddComboButtonHeader( comboStruct, 1, "#MENU_HEADER_LOADOUTS")
			case 2:
				file.callsignHeader = AddComboButtonHeader( comboStruct, 2, "#MENU_HEADER_CALLSIGN")
			case 3:
				file.networksHeader = AddComboButtonHeader( comboStruct, 3, "#MENU_HEADER_NETWORKS")
			case 4:
				file.storeHeader = AddComboButtonHeader( comboStruct, 4, "#MENU_HEADER_STORE")
			case 5:
				file.settingsHeader = AddComboButtonHeader( comboStruct, 5, "#MENU_HEADER_SETTINGS")
		}
	}

	bool isModded = IsNorthstarServer()

	loebLoadDefault()

	comboStruct.navUpButtonDisabled = true
	comboStruct.navDownButton = file.genUpButton


}

bool function MatchResultsExist()
{
	return true // TODO
}

void function DoRoomInviteIfAllowed( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	if ( !DoesCurrentCommunitySupportInvites() )
	{
		OnBrowseNetworksButton_Activate( button )
		return
	}

	entity player = GetUIPlayer()

	if ( IsValid( player ) && Player_NextAvailableMatchmakingTime( player ) > 0 )
	{
		DisplayMatchmakingPenaltyDialog( player )
		return
	}

	SendOpenInvite( true )
	OpenSelectedPlaylistMenu()
}

void function DisplayMatchmakingPenaltyDialog( entity player )
{
	int minutesRemaining = int( ceil( Player_GetRemainingMatchmakingDelay( player ) / 60) )
	if ( minutesRemaining <= 1 )
		ServerCallback_GenericDialog( 30, 31, true )
	else if ( minutesRemaining == 2 )
		ServerCallback_GenericDialog( 30, 32, true )
	else if ( minutesRemaining == 3 )
		ServerCallback_GenericDialog( 30, 33, true )
	else if ( minutesRemaining == 4 )
		ServerCallback_GenericDialog( 30, 34, true )
	else if ( minutesRemaining == 5 )
		ServerCallback_GenericDialog( 30, 35, true )
	else
		ServerCallback_GenericDialog( 30, 36, true )
}

void function CreatePartyAndInviteFriends()
{
	if ( CanInvite() )
	{
		while ( !PartyHasMembers() && !AmIPartyLeader() )
		{
			ClientCommand( "createparty" )
			WaitFrameOrUntilLevelLoaded()
		}
		InviteFriends( file.inviteFriendsButton )
	}
	else
	{
		printt( "Not inviting friends - CanInvite() returned false" );
	}
}

void function ToggleLobbyMode( var button )
{
	Lobby_ToggleFDMode()
}

void function Lobby_ToggleFDMode()
{
	Hud_SetFocused( file.findGameButton )
	ComboButtons_ResetColumnFocus( file.lobbyComboStruct )
	file.isFDMode = !file.isFDMode
	Lobby_RefreshButtons()
}

void function Lobby_CallsignButton3EventHandler( var button )
{
	if ( Lobby_IsFDMode() )
	{
		AdvanceMenu( GetMenu( "ViewStatsMenu" ) )
	}
	else
	{
		AdvanceMenu( GetMenu( "FactionChoiceMenu" ) )
	}
}

void function InviteFriendsIfAllowed( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	entity player = GetUIPlayer()
	if ( IsValid( player ) && Player_NextAvailableMatchmakingTime( player ) > 0 )
	{
		DisplayMatchmakingPenaltyDialog( player )
		return
	}

	#if PC_PROG
		if ( !Origin_IsOverlayAvailable() )
		{
			PopUpOriginOverlayDisabledDialog()
			return
		}
	#endif

	thread CreatePartyAndInviteFriends()
}

void function StartNSPrivateMatch( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	ClientCommand( "StartPrivateMatchSearch" )
}

void function OpenNSServerBrowser( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	AdvanceMenu( GetMenu( "ServerBrowserMenu" ) )
}

bool function CanInvite()
{
	if ( Player_NextAvailableMatchmakingTime( GetUIPlayer() ) > 0 )
		return false

#if DURANGO_PROG
		return ( GetMenuVarBool( "isFullyConnected" ) && GetMenuVarBool( "DURANGO_canInviteFriends" ) && GetMenuVarBool( "DURANGO_isJoinable" ) && GetMenuVarBool( "DURANGO_isGameFullyInstalled" ) )
	#elseif PS4_PROG
		return GetMenuVarBool( "PS4_canInviteFriends" )
	#elseif PC_PROG
		return ( GetMenuVarBool( "isFullyConnected" ) && GetMenuVarBool( "ORIGIN_isEnabled" ) && GetMenuVarBool( "ORIGIN_isJoinable" ) && Origin_IsOverlayAvailable() )
	#endif
}

void function Lobby_RefreshButtons()
{
	bool fdMode = Lobby_IsFDMode()
	var menu = GetMenu( "LobbyMenu" )

	if ( GetTopNonDialogMenu() == GetMenu( "LobbyMenu" ) )
	{
		if ( fdMode )
			UI_SetPresentationType( ePresentationType.FD_MAIN )
		else
			UI_SetPresentationType( ePresentationType.DEFAULT )
	}

	//string buttonString = fdMode ? "#MENU_LOBBY_SWITCH_DEFAULT" : "#MENU_LOBBY_SWITCH_FD"
	// ComboButton_SetText( file.toggleMenuModeButton, buttonString )

	//buttonString = fdMode ? "" : "#MENU_TITLE_BOOSTS"
	//Hud_SetEnabled( file.boostsButton, !fdMode )
	//ComboButton_SetText( file.boostsButton, buttonString )

	//buttonString = fdMode ? "#MENU_TITLE_STATS" : "#MENU_TITLE_FACTION"
	//ComboButton_SetText( file.factionButton, buttonString )

	//buttonString = fdMode ? "" : "#MENU_TITLE_STATS"
	//Hud_SetEnabled( file.statsButton, !fdMode )
	//ComboButton_SetText( file.statsButton, buttonString )

	//buttonString = fdMode ? "#MENU_HEADER_PLAY_FD" : "#MENU_HEADER_PLAY"
	//SetComboButtonHeaderTitle( menu, 0, buttonString )

	if ( fdMode )
		Hud_Hide( Hud_GetChild( menu, "ImgTopBar" ) )
	else
		Hud_Show( Hud_GetChild( menu, "ImgTopBar" ) )

	ComboButtons_ResetColumnFocus( file.lobbyComboStruct )

	if ( fdMode )
	{
		Hud_SetText( Hud_GetChild( menu, "MenuTitle" ), "" )
	}
	else
	{
		Hud_SetText( Hud_GetChild( menu, "MenuTitle" ), "#MULTIPLAYER" )
	}
}

void function OnLobbyMenu_Open()
{
	Assert( IsConnected() )

	ComboButtons_Finalize( file.lobbyComboStruct )

	// code will start loading DLC info from first party unless already done
	InitDLCStore()

	thread UpdateCachedNewItems()
	if ( file.putPlayerInMatchmakingAfterDelay )
	{
		entity player = GetUIPlayer()
		if (IsValid( player ))
		{
			string playlistToSearch = expect string( player.GetPersistentVar( "lastPlaylist" ) )
			string nextAutoPlaylist = GetNextAutoMatchmakingPlaylist()
			if ( nextAutoPlaylist.len() > 0 )
				playlistToSearch = nextAutoPlaylist

			Lobby_SetFDModeBasedOnSearching( playlistToSearch )
		}
		AdvanceMenu( GetMenu( "SearchMenu" ) )
		thread PutPlayerInMatchmakingAfterDelay()
		file.putPlayerInMatchmakingAfterDelay = false
	}
	else if ( uiGlobal.activeMenu == GetMenu( "LobbyMenu" ) )
		Lobby_SetFDMode( false )

	thread UpdateLobbyUI()
	thread LobbyMenuUpdate( GetMenu( "LobbyMenu" ) )

	Hud_Show( file.chatroomMenu )

	Lobby_RefreshButtons()

	if ( IsFullyConnected() )
	{
		entity player = GetUIPlayer()
		if ( !IsValid( player ) )
			return

		while ( IsPersistenceAvailable() && (player.GetPersistentVarAsInt( "initializedVersion" ) < PERSISTENCE_INIT_VERSION) )
		{
			WaitFrame()
		}
		if ( !IsPersistenceAvailable() )
			return

		// Clear hidden boosts
		array<ItemData> boosts = GetAllItemsOfType( eItemTypes.BURN_METER_REWARD )
		foreach ( boost in boosts )
		{
			if ( boost.hidden )
			{
				ClearNewStatus( null, boost.ref )
			}
		}

		UpdateCallsignElement( file.callsignCard )
		RefreshCreditsAvailable()

		bool emotesAreEnabled = EmotesEnabled()
		// "Customize"
		{
			bool anyNewPilotItems = HasAnyNewPilotItems( player )
			bool anyNewTitanItems = HasAnyNewTitanItems( player )
			bool anyNewBoosts = HasAnyNewBoosts( player )
			bool anyNewCommsIcons = emotesAreEnabled ? HasAnyNewDpadCommsIcons( player ) : false
			bool anyNewCustomizeHeader = (anyNewPilotItems || anyNewTitanItems || anyNewBoosts || anyNewCommsIcons)

			RuiSetBool( Hud_GetRui( file.customizeHeader ), "isNew", anyNewCustomizeHeader )
			ComboButton_SetNew( file.buttonIdentifiers[Localize("#MENU_TITLE_PILOT")], anyNewPilotItems )
			ComboButton_SetNew( file.buttonIdentifiers[Localize("#MENU_TITLE_TITAN")], anyNewTitanItems )
			ComboButton_SetNew( file.buttonIdentifiers[Localize("#MENU_TITLE_BOOSTS")], anyNewBoosts )
		}

		// "Store"
		{
			bool storeIsNew = DLCStoreShouldBeMarkedAsNew()
			RuiSetBool( Hud_GetRui( file.storeHeader ), "isNew", storeIsNew )
			ComboButton_SetNew( file.buttonIdentifiers[Localize("#MENU_TITLE_STORE_BROWSE")], storeIsNew )
		}

		// "Callsign"
		{
			bool anyNewBanners = HasAnyNewCallsignBanners( player )
			bool anyNewPatches = HasAnyNewCallsignPatches( player )
			bool anyNewFactions = HasAnyNewFactions( player ) && Lobby_IsFDMode()
			bool anyNewCallsignHeader = (anyNewBanners || anyNewPatches || anyNewFactions)

			RuiSetBool( Hud_GetRui( file.callsignHeader ), "isNew", anyNewCallsignHeader )
			ComboButton_SetNew( file.buttonIdentifiers[Localize("#MENU_TITLE_BANNER")], anyNewBanners )
			ComboButton_SetNew( file.buttonIdentifiers[Localize("#MENU_TITLE_PATCH")], anyNewPatches )
			ComboButton_SetNew( file.buttonIdentifiers[Localize("#MENU_TITLE_FACTION")], anyNewFactions )
		}

		/*bool faqIsNew = !GetConVarBool( "menu_faq_viewed" ) || HaveNewPatchNotes() || HaveNewCommunityNotes()
		RuiSetBool( Hud_GetRui( file.settingsHeader ), "isNew", faqIsNew )
		ComboButton_SetNew( file.faqButton, faqIsNew )*/

		TryUnlockSRSCallsign()

		Lobby_UpdateInboxButtons()

		if ( file.shouldAutoOpenFDMenu )
		{
			file.shouldAutoOpenFDMenu = false
			AdvanceMenu( GetMenu( GetPlaylistMenuName() ) )
			AdvanceMenu( GetMenu( "FDMenu" ) )
		}
	}
}

bool function DLCStoreShouldBeMarkedAsNew()
{
	if ( !IsFullyConnected() )
		return false

	if ( !IsPersistenceAvailable() )
		return false

	bool hasSeenStore = expect bool( GetPersistentVar( "hasSeenStore" ) )
	bool result = (!hasSeenStore)
	return result
}

void function LobbyMenuUpdate( var menu )
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	while ( GetTopNonDialogMenu() == menu )
	{
		bool inPendingOpenInvite = InPendingOpenInvite()
		Hud_SetLocked( file.buttonIdentifiers[Localize("#MENU_TITLE_SERVER_BROWSER")], !IsPartyLeader() || inPendingOpenInvite )
		Hud_SetLocked( file.buttonIdentifiers[Localize("#PRIVATE_MATCH")], IsOpenInviteVisible() || GetPartySize() > 1 || inPendingOpenInvite )

		bool canGenUp = false
		if ( GetUIPlayer() )
			canGenUp = GetPersistentVarAsInt( "xp" ) == GetMaxPlayerXP() && GetGen() < MAX_GEN

		Hud_SetVisible( file.genUpButton, canGenUp )
		Hud_SetEnabled( file.genUpButton, canGenUp )

		WaitFrame()
	}
}

void function SetNextAutoMatchmakingPlaylist( string playlistName )
{
	file.nextAutoMatchmakingPlaylist = playlistName
}

string function GetNextAutoMatchmakingPlaylist()
{
	return file.nextAutoMatchmakingPlaylist
}

void function PutPlayerInMatchmakingAfterDelay()
{
	Signal( uiGlobal.signalDummy, "PutPlayerInMatchmakingAfterDelay" )
	EndSignal( uiGlobal.signalDummy, "PutPlayerInMatchmakingAfterDelay" )
	EndSignal( uiGlobal.signalDummy, "CancelRestartingMatchmaking" )
	EndSignal( uiGlobal.signalDummy, "LeaveParty" )
	EndSignal( uiGlobal.signalDummy, "OnCloseLobbyMenu" )
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	if ( AreWeMatchmaking() ) //Party member, party leader is already searching
		return

	entity player = GetUIPlayer()
	if ( !player )
		return

	string lastPlaylist = expect string( player.GetPersistentVar( "lastPlaylist" ) )

	//Bump player out of match making if they were playing coliseum and are out of tickets.
	if ( ("coliseum" == lastPlaylist) && Player_GetColiseumTicketCount( GetLocalClientPlayer() ) <= 0 )
	{
		SetNextAutoMatchmakingPlaylist( "" )
		return
	}

	// Need to know if you were a party member before the countdown starts in case you leave
	bool wasAPartyMemberThatIsNotLeader = AmIPartyMember()
	waitthread WaitBeforeRestartingMatchmaking()
	// Only the leader should proceed to start matchmaking
	if ( wasAPartyMemberThatIsNotLeader )
		return

	if ( !Console_HasPermissionToPlayMultiplayer() )
	{
		ClientCommand( "disconnect" )
		return
	}

	string playlistToSearch = lastPlaylist
	string nextAutoPlaylist = GetNextAutoMatchmakingPlaylist()
	if ( nextAutoPlaylist.len() > 0 )
		playlistToSearch = nextAutoPlaylist

	StartMatchmakingPlaylists( playlistToSearch )
}

void function WaitBeforeRestartingMatchmaking()
{
	Signal( uiGlobal.signalDummy, "BypassWaitBeforeRestartingMatchmaking" )
	EndSignal( uiGlobal.signalDummy, "BypassWaitBeforeRestartingMatchmaking" )

	float timeToWait

	bool isPartyMemberThatIsNotLeader = AmIPartyMember()
	SetPutPlayerInMatchmakingAfterDelay( !isPartyMemberThatIsNotLeader )

	if ( isPartyMemberThatIsNotLeader )
		timeToWait = 99999 //HACK, JFS
	else
		timeToWait = GetCurrentPlaylistVarFloat( "wait_before_restarting_matchmaking_time", 30.0 )

	float timeToEnd = Time() + timeToWait

	UpdateTimeToRestartMatchmaking( timeToEnd )

	OnThreadEnd(
	function() : (  )
		{
			UpdateTimeToRestartMatchmaking( 0.0 )
			UpdateFooterOptions()
		}
	)

	if ( isPartyMemberThatIsNotLeader )
	{
		while( Time() < timeToEnd ) //Hack hack, JFS. No appropriate signals for StartMatchmaking() being called. Replace when code gives us notifications about it
		{
			if ( isPartyMemberThatIsNotLeader != ( AmIPartyMember() ) ) //Party Status changed. Party leader probably left?
				break

			if ( AreWeMatchmaking() ) //Need to break out if Party Leader brings us into matchmaking
				break

			WaitFrame()
		}

	}
	else
	{
		wait timeToWait
	}
}

void function OnLobbyMenu_Close()
{
	Signal( uiGlobal.signalDummy, "OnCloseLobbyMenu" )
}

void function OnLobbyMenu_NavigateBack()
{
	if ( ChatroomIsVisibleAndFocused() )
	{
		foreach ( button in file.lobbyButtons )
		{
			if ( Hud_IsVisible( button ) && Hud_IsEnabled( button ) && !Hud_IsLocked( button ) )
			{
				Hud_SetFocused( button )
				return
			}
		}
	}

	if ( InPendingOpenInvite() )
		LeaveOpenInvite()
	else
		LeaveDialog()
}

function GameStartTime_Changed()
{
	UpdateGameStartTimeCounter()
}

function ShowGameSummary_Changed()
{
	if ( level.ui.showGameSummary )
		uiGlobal.EOGOpenInLobby = true
}

function UpdateGameStartTimeCounter()
{
	if ( level.ui.gameStartTime == null )
		return

	MatchmakingSetSearchText( "#STARTING_IN_LOBBY" )
	MatchmakingSetCountdownTimer( expect float( level.ui.gameStartTime + 0.0 ), true )

	HideMatchmakingStatusIcons()
}

bool function MatchmakingStatusShouldShowAsActiveSearch( string matchmakingStatus )
{
	if ( matchmakingStatus == "#MATCHMAKING_QUEUED" )
		return true
	if ( matchmakingStatus == "#MATCHMAKING_ALLOCATING_SERVER" )
		return true
	if ( matchmakingStatus == "#MATCHMAKING_MATCH_CONNECTING" )
		return true

	return false
}

string function GetActiveSearchingPlaylist()
{
	if ( !IsConnected() )
		return ""
	if ( !AreWeMatchmaking() )
		return ""

	string matchmakingStatus = GetMyMatchmakingStatus()
	if ( !MatchmakingStatusShouldShowAsActiveSearch( matchmakingStatus ) )
		return ""

	string param1 = GetMyMatchmakingStatusParam( 1 )
	return param1
}

float function CalcMatchmakingWaitTime()
{
	float result = ((file.matchmakingStartTime > 0.01) ? (Time() - file.matchmakingStartTime) : 0.0)
	return result
}

float function GetMixtapeWaitTimeForPlaylist( string playlistName )
{
	float maxWaitTime = float( GetPlaylistVarOrUseValue( playlistName, "mixtape_timeout", "0" ) )
	return maxWaitTime
}

void function UpdateRestartMatchmakingStatus( float time )
{
	if ( AmIPartyMember() )
	{
		MatchmakingSetSearchText( "#MATCHMAKING_WAIT_ON_PARTY_LEADER_RESTARTING_MATCHMAKING" )
	}
	else
	{
		string statusText = "#MATCHMAKING_WAIT_BEFORE_RESTARTING_MATCHMAKING"
		string matchmakeNowText = ""
		if ( uiGlobal.activeMenu == GetMenu( "SearchMenu" ) )
			matchmakeNowText = Localize( "#MATCHMAKING_WAIT_MATCHMAKE_NOW" )
		MatchmakingSetSearchText( statusText, matchmakeNowText )
		MatchmakingSetCountdownTimer( time, false )
	}
}

void function UpdateMatchmakingStatus()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	OnThreadEnd(
		function() : ()
		{
			printt( "Hiding all matchmaking elems due to UpdateMatchmakingStatus thread ending" )

			HideMatchmakingStatusIcons()

			MatchmakingSetSearchText( "" )
			MatchmakingSetCountdownTimer( 0.0, true )

			MatchmakingSetSearchVisible( false )
			MatchmakingSetCountdownVisible( false )
		}
	)

	MatchmakingSetSearchVisible( true )
	MatchmakingSetCountdownVisible( true )

	var lobbyMenu = GetMenu( "LobbyMenu" )
	var searchMenu = GetMenu( "SearchMenu" )
	var postGameMenu = GetMenu( "PostGameMenu" )

	string lastActiveSearchingPlaylist
	file.matchmakingStartTime = 0.0
	file.etaTime = 0
	file.etaMaxMinutes = int( GetCurrentPlaylistVarOrUseValue( "etaMaxMinutes", file.etaMaxMinutes ) )
	file.lastMixtapeMatchmakingStatus = ""

	while ( true )
	{
		int lobbyType = GetLobbyTypeScript()
		string matchmakingStatus = GetMyMatchmakingStatus()
		bool isConnectingToMatch = matchmakingStatus == "#MATCHMAKING_MATCH_CONNECTING"

		{
			string activeSearchingPlaylist = GetActiveSearchingPlaylist()
			if ( lastActiveSearchingPlaylist != activeSearchingPlaylist )
			{
				if ( activeSearchingPlaylist.len() > 0 )
				{
					lastActiveSearchingPlaylist = activeSearchingPlaylist
					file.matchmakingStartTime = Time()
				}
				else
				{
					lastActiveSearchingPlaylist = ""
					file.matchmakingStartTime = 0.0
				}
			}

			if ( isConnectingToMatch && (matchmakingStatus != file.lastMixtapeMatchmakingStatus) )
			{
				EmitUISound( MATCHMAKING_AUDIO_CONNECTING )

				int mixtape_version = GetMixtapeMatchmakingVersion()
				if ( IsMixtapeVersionNew() )
					LogMixtapeHasNew( mixtape_version )
			}

			file.lastMixtapeMatchmakingStatus = matchmakingStatus
		}

		if ( level.ui.gameStartTime != null || lobbyType == eLobbyType.PRIVATE_MATCH )
		{
			if ( level.ui.gameStartTimerComplete )
			{
				MatchmakingSetSearchText( matchmakingStatus, GetMyMatchmakingStatusParam( 1 ), GetMyMatchmakingStatusParam( 2 ), GetMyMatchmakingStatusParam( 3 ), GetMyMatchmakingStatusParam( 4 ) )
			}

			if ( uiGlobal.activeMenu == searchMenu )
				CloseActiveMenu()
		}
		else if ( GetTimeToRestartMatchMaking() > 0  )
		{
			UpdateRestartMatchmakingStatus( GetTimeToRestartMatchMaking() )
		}
		else if ( level.ui.gameStartTime == null )
		{
			MatchmakingSetCountdownTimer( 0.0, true )
			MatchmakingSetSearchText( "" )
			HideMatchmakingStatusIcons()

			if ( !IsConnected() || !AreWeMatchmaking() )
			{
				if ( uiGlobal.activeMenu == searchMenu )
					CloseActiveMenu()
			}
			else
			{
				ShowMatchmakingStatusIcons()

				if ( GetActiveMenu() == lobbyMenu && !IsMenuInMenuStack( searchMenu ) )
				{
					CloseAllDialogs()
					AdvanceMenu( searchMenu )
				}

				var statusEl = Hud_GetChild( searchMenu, "MatchmakingStatusBig" )
				if ( matchmakingStatus == "#MATCH_NOTHING" )
				{
					Hud_Hide( statusEl )
				}
				else if ( MatchmakingStatusShouldShowAsActiveSearch( matchmakingStatus ) )
				{
					string playlistName = GetMyMatchmakingStatusParam( 1 )
					int etaSeconds = int( GetMyMatchmakingStatusParam( 2 ) )
					int mapIdx = int( GetMyMatchmakingStatusParam( 3 ) )
					int modeIdx = int( GetMyMatchmakingStatusParam( 4 ) )
					string playlistList = GetMyMatchmakingStatusParam( 5 )

					{
						string statusText = Localize( "#MATCHMAKING_PLAYLISTS" )
						RuiSetString( Hud_GetRui( statusEl ), "statusText", statusText )
						for ( int idx = 1; idx <= 5; ++idx )
							RuiSetString( Hud_GetRui( statusEl ), ("bulletPointText" + idx), "" )

						const int MAX_SHOWN_PLAYLISTS = 9
						array< string > searchingPlaylists = split( playlistList, "," )
						int searchingCount = minint( searchingPlaylists.len(), MAX_SHOWN_PLAYLISTS )
						RuiSetInt( Hud_GetRui( statusEl ), "playlistCount", searchingCount )
						for( int idx = 0; idx < searchingCount; ++idx )
						{
							asset playlistThumbnail = GetPlaylistThumbnailImage( searchingPlaylists[idx] )
							RuiSetImage( Hud_GetRui( statusEl ), format( "playlistIcon%d", idx ), playlistThumbnail )
						}
					}

					Hud_Show( statusEl )

					if ( mapIdx > -1 && modeIdx > -1 )
					{
						if ( file.preCacheInfo.playlistName != playlistName || file.preCacheInfo.mapIdx != mapIdx || file.preCacheInfo.modeIdx != modeIdx )
						{
							file.preCacheInfo.playlistName = playlistName
							file.preCacheInfo.mapIdx = mapIdx
							file.preCacheInfo.modeIdx = modeIdx
						}
					}

					string etaStr = ""
					if ( !etaSeconds && !isConnectingToMatch )
					{
						matchmakingStatus = "#MATCHMAKING_SEARCHING_FOR_MATCH"
					}
					else
					{
						int now = int( Time() )
						int etaTime = now + etaSeconds
						if ( !file.etaTime || etaTime < file.etaTime )
							file.etaTime = etaTime

						int etaSeconds = file.etaTime - now
						if ( etaSeconds <= 0 )
							file.etaTime = etaTime

						etaSeconds = file.etaTime - now
						if ( etaSeconds <= 90 )
						{
							etaStr = Localize( "#MATCHMAKING_ETA_SECONDS", etaSeconds )
						}
						else
						{
							int etaMinutes = int( ceil( etaSeconds / 60.0 ) )
							if ( etaMinutes < file.etaMaxMinutes )
								etaStr = Localize( "#MATCHMAKING_ETA_MINUTES", etaMinutes )
							else
								etaStr = Localize( "#MATCHMAKING_ETA_UNKNOWN", etaMinutes )
						}
					}

					MatchmakingSetSearchText( matchmakingStatus, etaStr )
				}
				else
				{
					Hud_Show( statusEl )
					RuiSetString( Hud_GetRui( statusEl ), "statusText", "" )
					RuiSetInt( Hud_GetRui( statusEl ), "playlistCount", 0 )
				}
			}
		}

		WaitFrameOrUntilLevelLoaded()
	}
}

void function UpdateAnnouncementDialog()
{
	while ( IsLobby() && IsFullyConnected() )
	{
		// Only safe on these menus. Not safe if these variables are true because they indicate the search menu or postgame menu are going to be opened.
		if ( ( uiGlobal.activeMenu == GetMenu( "LobbyMenu" ) || uiGlobal.activeMenu == GetMenu( "PrivateLobbyMenu" ) ) && !file.putPlayerInMatchmakingAfterDelay && !uiGlobal.EOGOpenInLobby )
		{
			entity player = GetUIPlayer()

			// Only initialize here, CloseAnnouncementDialog() handles setting it when closing
			if ( uiGlobal.announcementVersionSeen == -1 )
				uiGlobal.announcementVersionSeen = player.GetPersistentVarAsInt( "announcementVersionSeen" )

			int announcementVersion = GetConVarInt( "announcementVersion" )
			if ( announcementVersion > uiGlobal.announcementVersionSeen )
			{
				OpenAnnouncementDialog()
			}
			else if ( uiGlobal.activeMenu != "AnnouncementDialog" && ShouldShowEmotesAnnouncement( player ) )
			{
				OpenCommsIntroDialog()
			}
		}

		WaitFrame()
	}
}

bool function CurrentMenuIsPVEMenu()
{
	var topMenu = GetTopNonDialogMenu()
	if ( topMenu == null )
		return false

	return (uiGlobal.menuData[topMenu].isPVEMenu)
}

void function RefreshCreditsAvailable( int creditsOverride = -1 )
{
	entity player = GetUIPlayer()
	if ( !IsValid( player ) )
		return
	if ( !IsPersistenceAvailable() )
		return

	int credits = creditsOverride >= 0 ? creditsOverride : GetAvailableCredits( GetLocalClientPlayer() )
	string pveTitle = ""
	int pveCredits = 0
	bool isPVE = CurrentMenuIsPVEMenu()
	if ( isPVE )
	{
		TitanLoadoutDef loadout = GetCachedTitanLoadout( uiGlobal.editingLoadoutIndex )
		pveCredits = GetAvailableFDUnlockPoints( player, loadout.titanClass )
		pveTitle = GetTitanLoadoutName( loadout )
	}

	foreach ( elem in file.creditsAvailableElems )
	{
		SetUIPlayerCreditsInfo( elem, credits, GetLocalClientPlayer().GetXP(), GetGen(), GetLevel(), GetNextLevel( GetLocalClientPlayer() ), isPVE, pveCredits, pveTitle )
	}
}

void function SetUIPlayerCreditsInfo( var infoElement, int credits, int xp, int gen, int level, int nextLevel, bool isPVE, int pveCredits, string pveTitle )
{
	var rui = Hud_GetRui( infoElement )
	RuiSetInt( rui, "credits", credits )
	RuiSetString( rui, "nameText", GetPlayerName() )

	RuiSetBool( rui, "isPVE", isPVE )
	if ( isPVE )
	{
		RuiSetInt( rui, "pveCredits", pveCredits )
		RuiSetString( rui, "pveTitle", pveTitle )
	}

	if ( xp == GetMaxPlayerXP() && gen < MAX_GEN )
	{
		RuiSetString( rui, "levelText", PlayerXPDisplayGenAndLevel( gen, level ) )
		RuiSetString( rui, "nextLevelText", Localize( "#REGEN_AVAILABLE" ) )
		RuiSetInt( rui, "numLevelPips", GetXPPipsForLevel( level - 1 ) )
		RuiSetInt( rui, "filledLevelPips", GetXPPipsForLevel( level - 1 ) )
	}
	else if ( xp == GetMaxPlayerXP() && gen == MAX_GEN )
	{
		RuiSetString( rui, "levelText", PlayerXPDisplayGenAndLevel( gen, level ) )
		RuiSetString( rui, "nextLevelText", Localize( "#MAX_GEN" ) )
		RuiSetInt( rui, "numLevelPips", GetXPPipsForLevel( level - 1 ) )
		RuiSetInt( rui, "filledLevelPips", GetXPPipsForLevel( level - 1 ) )
	}
	else
	{
		RuiSetString( rui, "levelText", PlayerXPDisplayGenAndLevel( gen, level ) )
		RuiSetString( rui, "nextLevelText", PlayerXPDisplayGenAndLevel( gen, nextLevel ) )
		RuiSetInt( rui, "numLevelPips", GetXPPipsForLevel( level ) )
		RuiSetInt( rui, "filledLevelPips", GetXPFilledPipsForXP( xp ) )
	}

	CallsignIcon callsignIcon = PlayerCallsignIcon_GetActive( GetLocalClientPlayer() )

	RuiSetImage( rui, "callsignIcon", callsignIcon.image )
}


void function BigPlayButton1_Activate( var button )
{
	if ( Hud_IsLocked( button ) )
		return

	SendOpenInvite( false )
	OpenSelectedPlaylistMenu()
}

function EnableButton( button )
{
	Hud_SetEnabled( button, true )
	Hud_Show( button )
}

function DisableButton( button )
{
	Hud_SetEnabled( button, false )
	Hud_Hide( button )
}

void function OpenSelectedPlaylistMenu()
{
	if ( Lobby_IsFDMode() )
	{
		AdvanceMenu( GetMenu( "FDMenu" ) )
	}
	else
	{
		string playlistMenuName = GetPlaylistMenuName()
		AdvanceMenu( GetMenu( playlistMenuName ) )
	}
}

function UpdateLobbyUI()
{
	if ( uiGlobal.updatingLobbyUI )
		return
	uiGlobal.updatingLobbyUI = true

	thread UpdateLobbyType()
	thread UpdateMatchmakingStatus()
	thread UpdateChatroomThread()
	//thread UpdateInviteJoinButton()
	//thread UpdateInviteFriendsToNetworkButton()
	thread UpdatePlayerInfo()

	if ( uiGlobal.menuToOpenFromPromoButton != null )
	{
		// Special case because this menu needs a few properties set before opening

		if ( IsStoreMenu( uiGlobal.menuToOpenFromPromoButton ) )
		{
			string menuName = expect string( uiGlobal.menuToOpenFromPromoButton._name )

			void functionref() preOpenfunc = null
			if ( uiGlobal.menuToOpenFromPromoButton == GetMenu( "StoreMenu_WeaponSkins" ) ) // Hardcoded special case for now
				preOpenfunc = DefaultToDLC11WeaponWarpaintBundle

			OpenStoreMenu( [ menuName ], preOpenfunc )
		}
		else
		{
			AdvanceMenu( uiGlobal.menuToOpenFromPromoButton )
		}

		uiGlobal.menuToOpenFromPromoButton = null
	}
	else if ( uiGlobal.EOGOpenInLobby )
	{
		EOGOpen()
	}

	WaitSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )
	uiGlobal.updatingLobbyUI = false
}

void function UpdateInviteJoinButton()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )
	var menu = GetMenu( "LobbyMenu" )

	while ( true )
	{
		if ( DoesCurrentCommunitySupportInvites() )
			ComboButton_SetText( file.inviteRoomButton, Localize( "#MENU_TITLE_INVITE_ROOM" ) )
		else
			ComboButton_SetText( file.inviteRoomButton, Localize( "#MENU_TITLE_JOIN_NETWORK" ) )

		WaitFrame()
	}
}

//void function UpdateInviteFriendsToNetworkButton()
//{
//	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )
//	var menu = GetMenu( "LobbyMenu" )
//
//	while ( true )
//	{
//		bool areInvitesToNetworkNotAllowed = !DoesCurrentCommunitySupportChat()
//		if ( areInvitesToNetworkNotAllowed || ( IsCurrentCommunityInviteOnly() && !AreWeAdminInCurrentCommunity() ) )
//			DisableButton( file.inviteFriendsToNetworkButton )
//		else
//			EnableButton( file.inviteFriendsToNetworkButton )
//
//		WaitFrame()
//	}
//}

function UpdateLobbyType()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	var menu = GetMenu( "LobbyMenu" )
	int lobbyType
	local lastType
	local partySize
	local lastPartySize
	local debugArray = [ "SOLO", "PARTY_LEADER", "PARTY_MEMBER", "MATCH", "PRIVATE_MATCH" ] // Must match enum

	WaitFrameOrUntilLevelLoaded()

	while ( true )
	{
		lobbyType = GetLobbyTypeScript()
		partySize = GetPartySize()

		if ( IsConnected() && ((lobbyType != lastType) || (partySize != lastPartySize))  )
		{
			if ( lastType == null )
				printt( "Lobby lobbyType changing from:", lastType, "to:", debugArray[lobbyType] )
			else
				printt( "Lobby lobbyType changing from:", debugArray[lastType], "to:", debugArray[lobbyType] )

			local animation = null

			switch ( lobbyType )
			{
				case eLobbyType.SOLO:
					animation = "SoloLobby"
					break

				case eLobbyType.PARTY_LEADER:
					animation = "PartyLeaderLobby"
					break

				case eLobbyType.PARTY_MEMBER:
					animation = "PartyMemberLobby"
					break

				case eLobbyType.MATCH:
					animation = "MatchLobby"
					break

				case eLobbyType.PRIVATE_MATCH:
					animation = "PrivateMatchLobby"
					break
			}

			if ( animation != null )
			{
				menu.RunAnimationScript( animation )
			}

			// Force the animation scripts (which have zero duration) to complete before anything can cancel them.
			ForceUpdateHUDAnimations()

			lastType = lobbyType
			lastPartySize = partySize
		}

		WaitFrameOrUntilLevelLoaded()
	}
}

void function UICodeCallback_CommunityUpdated()
{
	Community_CommunityUpdated()
	UpdateChatroomUI()
}

void function UICodeCallback_FactionUpdated()
{
	printt( "Faction changed! to " + GetCurrentFaction() );
}

void function UICodeCallback_SetupPlayerListGenElements( table params, int gen, int rank, bool isPlayingRanked, int pilotClassIndex )
{
	params.image = ""
	params.label = ""
	params.imageOverlay = ""
}

float function GetTimeToRestartMatchMaking()
{
	return file.timeToRestartMatchMaking
}

void function UpdateTimeToRestartMatchmaking( float time )//JFS: This uses UI time instead of server time, which leads to awkwardness in MatchmakingSetCountdownTimer() and the rui involved
{
	file.timeToRestartMatchMaking  = time

	if ( time > 0  )
	{
		UpdateRestartMatchmakingStatus( time )
		ShowMatchmakingStatusIcons()
	}
	else
	{
		MatchmakingSetSearchText( "" )
		MatchmakingSetCountdownTimer( 0.0, true )
		HideMatchmakingStatusIcons()
	}
}

void function HideMatchmakingStatusIcons()
{
	foreach ( element in file.searchIconElems )
		Hud_Hide( element )

	foreach ( element in file.matchStatusRuis )
		RuiSetBool( Hud_GetRui( element ), "iconVisible", false )
}

void function ShowMatchmakingStatusIcons()
{
	//foreach ( element in file.searchIconElems )
	//	Hud_Show( element )

	foreach ( element in file.matchStatusRuis )
		RuiSetBool( Hud_GetRui( element ), "iconVisible", true )
}

void function MatchmakingSetSearchVisible( bool state )
{
	foreach ( el in file.searchTextElems )
	{
		//if ( state )
		//	Hud_Show( el )
		//else
			Hud_Hide( el )
	}

	foreach ( element in file.matchStatusRuis )
		RuiSetBool( Hud_GetRui( element ), "statusVisible", state )
}

void function MatchmakingSetSearchText( string searchText, var param1 = "", var param2 = "", var param3 = "", var param4 = "" )
{
	foreach ( el in file.searchTextElems )
	{
		Hud_SetText( el, searchText, param1, param2, param3, param4 )
	}

	foreach ( element in file.matchStatusRuis )
	{
		RuiSetBool( Hud_GetRui( element ), "statusHasText", searchText != "" )

		RuiSetString( Hud_GetRui( element ), "statusText", Localize( searchText, param1, param2, param3, param4 ) )
	}
}


void function MatchmakingSetCountdownVisible( bool state )
{
	foreach ( el in file.matchStartCountdownElems )
	{
		//if ( state )
		//	Hud_Show( el )
		//else
			Hud_Hide( el )
	}

	foreach ( element in file.matchStatusRuis )
		RuiSetBool( Hud_GetRui( element ), "timerVisible", state )
}

void function MatchmakingSetCountdownTimer( float time, bool useServerTime = true ) //JFS: useServerTime bool is awkward, comes from level.ui.gameStartTime using server time and UpdateTimeToRestartMatchmaking() uses UI time.
{
	foreach ( element in file.matchStatusRuis )
	{
		RuiSetBool( Hud_GetRui( element ), "timerHasText", time != 0.0 )
		RuiSetGameTime( Hud_GetRui( element ), "startTime", Time() )
		RuiSetBool( Hud_GetRui( element ), "useServerTime", useServerTime )
		RuiSetGameTime( Hud_GetRui( element ), "timerEndTime", time )
	}
}

void function OnLobbyLevelInit()
{
	UpdateCallsignElement( file.callsignCard )
	RefreshCreditsAvailable()
}

function UpdatePlayerInfo()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	var menu = GetMenu( "LobbyMenu" )

	WaitFrameOrUntilLevelLoaded()

	while ( true )
	{
		RefreshCreditsAvailable()
		WaitFrame()
	}
}

void function TryUnlockSRSCallsign()
{
	if ( Script_IsRunningTrialVersion() )
		return

	int numCallsignsToUnlock = 0

	if ( GetTotalLionsCollected() >= GetTotalLionsInGame() )
		numCallsignsToUnlock = 3
	else if ( GetTotalLionsCollected() >= ACHIEVEMENT_COLLECTIBLES_2_COUNT )
		numCallsignsToUnlock = 2
	else if ( GetTotalLionsCollected() >= ACHIEVEMENT_COLLECTIBLES_1_COUNT )
		numCallsignsToUnlock = 1
	else
		numCallsignsToUnlock = 0

	if ( numCallsignsToUnlock > 0 )
		ClientCommand( "UnlockSRSCallsign " + numCallsignsToUnlock )
}

void function SetPutPlayerInMatchmakingAfterDelay( bool value )
{
	file.putPlayerInMatchmakingAfterDelay = value
}

void function OnStoreButton_Activate( var button )
{
	LaunchGamePurchaseOrDLCStore()
}

void function OnStoreNewReleasesButton_Activate( var button )
{
	//LaunchGamePurchaseOrDLCStore( [ "StoreMenu", "StoreMenu_NewReleases" ] )
	LaunchGamePurchaseOrDLCStore( [ "StoreMenu", "StoreMenu_WeaponSkins" ] )
}

void function OnStoreBundlesButton_Activate( var button )
{
	LaunchGamePurchaseOrDLCStore( [ "StoreMenu", "StoreMenu_Sales" ] )
}

void function OnDpadCommsButton_Activate( var button )
{
	AdvanceMenu( GetMenu( "EditDpadCommsMenu" ) )
}

void function OpenCommsIntroDialog()
{
	DialogData dialogData
	dialogData.menu = GetMenu( "AnnouncementDialog" )
	dialogData.header = "#DPAD_COMMS_ANNOUNCEMENT_HEADER"
	dialogData.ruiMessage.message = "#DPAD_COMMS_ANNOUNCEMENT"
	dialogData.image = $"ui/menu/common/dialog_announcement_1"

	AddDialogButton( dialogData, "#DPAD_COMMS_ANNOUNCEMENT_B1" , OpenDpadCommsMenu )
	AddDialogButton( dialogData, "#DPAD_COMMS_ANNOUNCEMENT_B2" )

	AddDialogPCBackButton( dialogData )
	AddDialogFooter( dialogData, "#A_BUTTON_ACCEPT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )

	ClientCommand( "SetCommsIntroSeen" )
}

void function OpenDpadCommsMenu()
{
	OnDpadCommsButton_Activate( null )
}

bool function ShouldShowEmotesAnnouncement( entity player )
{
	if ( !EmotesEnabled() )
		return false

	if ( player.GetPersistentVarAsInt( "numTimesUsedComms" ) > 2 )
		return false

	if ( player.GetPersistentVar( "hasBeenIntroducedToComms" ) )
		return false

	#if !DEV
	if ( PlayerGetRawLevel( player ) <= 2 )
		return false
	#endif

	return true
}

void function Lobby_SetFDMode( bool mode )
{
	file.isFDMode = mode
}

//Function returns whether lobby is currently in "Frontier Defense" lobby mode.
bool function Lobby_IsFDMode()
{
	return file.isFDMode
}

void function Lobby_SetAutoFDOpen( bool autoFD )
{
	Lobby_SetFDMode( autoFD )
	file.shouldAutoOpenFDMenu = autoFD
}

void function Lobby_SetFDModeBasedOnSearching( string playlistToSearch )
{
	array< string > searchingPlaylists = split( playlistToSearch, "," )

	bool isFDMode = false
	int searchingCount = searchingPlaylists.len()
	for( int idx = 0; idx < searchingCount; ++idx )
	{
		isFDMode = isFDMode || IsFDMode( searchingPlaylists[idx] )
		if ( isFDMode )
			break
	}

	Lobby_SetFDMode( isFDMode )
}