global function loebLoadDefault

void function loebLoadDefault()
{
    //PLAY (headerIndex 0)
    loebAdd(0, Localize("#MENU_TITLE_SERVER_BROWSER"), OpenNSServerBrowser)
    loebAdd(0, Localize("#PRIVATE_MATCH"), StartNSPrivateMatch)
    //CUSTOMIZE (headerIndex 1)
    loebAdd(1, Localize("#MENU_TITLE_PILOT"), AdvanceMenuEventHandler(GetMenu("EditPilotLoadoutsMenu")))    //Pilot
    loebAdd(1, Localize("#MENU_TITLE_TITAN"), AdvanceMenuEventHandler(GetMenu("EditTitanLoadoutsMenu")))    //Titan
    loebAdd(1, Localize("#MENU_TITLE_BOOSTS"), AdvanceMenuEventHandler(GetMenu("BurnCardMenu")))            //Boosts
    //CALLSIGN (headerIndex 2)
    loebAdd(2, Localize("#MENU_TITLE_BANNER"), AdvanceMenuEventHandler(GetMenu("CallsignCardSelectMenu")))  //Banner
    loebAdd(2, Localize("#MENU_TITLE_PATCH"), AdvanceMenuEventHandler(GetMenu("CallsignIconSelectMenu")))   //Patch
    loebAdd(2, Localize("#MENU_TITLE_FACTION"), Lobby_CallsignButton3EventHandler)                          //Faction
    loebAdd(2, Localize("#MENU_TITLE_STATS"), AdvanceMenuEventHandler(GetMenu("ViewStatsMenu")))            //Stats
    //NETWORKS (headerIndex 3)
    loebAdd(3, Localize("#MENU_TITLE_INBOX"), OnInboxButton_Activate)                                       //Inbox
    loebAdd(3, Localize("#COMMUNITY_SWITCHCOMMUNITY"), OnSwitchButton_Activate)                             //My Networks
    loebAdd(3, Localize("#COMMUNITY_BROWSE_NETWORKS"), OnBrowseNetworksButton_Activate)                     //Browse
    //loebAdd(3, Localize("#INVITE_FRIENDS"), OnInviteFriendsToNetworkButton_Activate)                      //Invite friends (doesn't work on Northstar)
    //STORE (headerIndex 4)
    loebAdd(4, Localize("#MENU_TITLE_STORE_BROWSE"), OnStoreButton_Activate)                                //Browse
    loebAdd(4, Localize("#MENU_TITLE_STORE_NEW_RELEASES"), OnStoreNewReleasesButton_Activate)               //New Releases
    loebAdd(4, Localize("#MENU_TITLE_STORE_BUNDLES"), OnStoreBundlesButton_Activate)                        //Sales
    //SETTINGS (headerIndex 5)
    loebAdd(5, Localize("#MENU_TITLE_CONTROLS"), AdvanceMenuEventHandler(GetMenu("ControlsMenu")))          //Controls
    //loebAdd(5, Localize("#AUDIO_VIDEO"), AdvanceEventMenuEventHandler(GetMenu("AudioVideoMenu")))         //Audio & Video (doesn't work on Northstar, this is for consoles)
    loebAdd(5, Localize("#AUDIO"), AdvanceMenuEventHandler(GetMenu("AudioMenu")))                           //Audio
    loebAdd(5, Localize("#VIDEO"), AdvanceMenuEventHandler(GetMenu("VideoMenu")))                           //Video
    loebAdd(5, Localize("#MOD_SETTINGS"), AdvanceMenuEventHandler(GetMenu("ModSettings")))                  //Mod Settings
}