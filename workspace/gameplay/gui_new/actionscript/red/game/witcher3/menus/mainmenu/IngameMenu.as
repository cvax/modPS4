/***********************************************************************
/** Main Options Menu class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTweener;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent; 
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.events.GesturePhase;
	import flash.events.TransformGestureEvent;
	import flash.events.GestureEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	import red.core.CoreMenu;
	import red.core.CoreComponent;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.core.events.GestureEventEx;
	import red.game.witcher3.constants.AspectRatio;
	import red.game.witcher3.constants.EInputDeviceType;
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.controls.ConditionalCloseButton;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3Background;
	import red.game.witcher3.controls.W3TextArea;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.menus.common_menu.MenuHubTabListItem;
	import red.game.witcher3.menus.mainmenu.PatchNotesInfoBlock;
	import red.game.witcher3.menus.mainmenu.PatchNotesPopup;
	import red.game.witcher3.menus.mainmenu.SwitchFeaturesPopUp;
	import red.game.witcher3.menus.modmenu.ModImageLoadHandler;
	import red.game.witcher3.menus.modmenu.ModImageData;
	import red.game.witcher3.menus.overlay.ModVerificationPopup;
	import red.game.witcher3.menus.overlay.CheckboxListPopup;
	import red.game.witcher3.menus.overlay.W3LicenseAgreementPopup;
	import red.game.witcher3.modules.SimpleListModule;
	import red.game.witcher3.utils.CommonUtils;

	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.gfx.MouseEventEx;

	public class IngameMenu extends CoreMenu
	{
		// #J The following list of tags should match the enum in witcherscript InGameMenuActionType
		// {
		public static const IGMActionType_CommonMenu		: uint = 0;
		public static const IGMActionType_Close				: uint = 1;
		public static const IGMActionType_MenuHolder 		: uint = 2;
		public static const IGMActionType_MenuLastHolder	: uint = 3;
		public static const IGMActionType_Load 				: uint = 4;
		public static const IGMActionType_Save 				: uint = 5;
		public static const IGMActionType_Quit 				: uint = 6;
		public static const IGMActionType_Preset 			: uint = 7;
		public static const IGMActionType_Toggle 			: uint = 8;
		public static const IGMActionType_List 				: uint = 9;
		public static const IGMActionType_Slider 			: uint = 10;
		public static const IGMActionType_LoadLastSave		: uint = 11;
		public static const IGMActionType_Tutorials 		: uint = 12;
		public static const IGMActionType_Credits			: uint = 13;
		public static const IGMActionType_Help				: uint = 14;
		public static const IGMActionType_Controls			: uint = 15;
		public static const IGMActionType_ControllerHelp	: uint = 16;
		public static const IGMActionType_NewGame			: uint = 17;
		public static const IGMActionType_CloseGame			: uint = 18;
		public static const IGMActionType_UIRescale			: uint = 19;
		public static const IGMActionType_Gamma				: uint = 20;
		public static const IGMActionType_DbgStartQuest 	: uint = 21;
		public static const IGMActionType_Gwint				: uint = 22;
		public static const IGMActionType_ImportSave   		: uint = 23;
		public static const IGMActionType_KeyBinds			: uint = 24;
		public static const IGMActionType_Back				: uint = 25;
		public static const IGMActionType_NewGamePlus		: uint = 26;
		public static const IGMActionType_InstalledDLC		: uint = 27;
		public static const IGMActionType_Button			: uint = 28;
		public static const IGMActionType_ToggleRender		: uint = 29;
		public static const IGMActionType_ListWithCondition : uint = 32;
		public static const IGMActionType_Stepper			: uint = 33;
		public static const IGMActionType_ToggleStepper		: uint = 34;
		public static const IGMActionType_Separator			: uint = 35;
		public static const IGMActionType_SubtleSeparator   : uint = 36;

		public static const IGMActionType_PurchaseEP3   	: uint = 43;
 

		public static const IGMActionType_Options		: uint = 100;
		// }
		
		private var importME:IngameMenuEntry;
		
		private static const ACTION_CLOSE  			: uint = 0;
		private static const ACTION_SCROLL 			: uint = 1;
		private static const ACTION_USE    			: uint = 2;
		private static const ACTION_Y      			: uint = 3;
		private static const ACTION_X	   			: uint = 4;
		private static const ACTION_APPLY_PRESET	: uint = 5;
		private static const ACTION_DOWNLOAD		: uint = 66;
		
		public static const CST_CLOUD    = 30;
		
		public static const OnOptionPanelClosed			: String = "OnOptionPanelClosed";
		
		public static var	_DLSSIsSupported : Boolean = true;
		public static var	_RTEnabled : Boolean = true;
		public static var AAModeIntTag : uint = 0;
		public static var Virtual_SSAOSolutionIntTag : uint = 0;
		
		public var mcInputFeedbackModule : ModuleInputFeedback;
		
		public var mcCloseBtn : ConditionalCloseButton;
		
		public var menuListModule : SimpleListModule;
		
		public var mcCustomDialogEp1 : MovieClip;
		public var mcCustomDialogEp2 : MovieClip;
		public var mcCustomDialogGOTY : MovieClip;
		public var mcCustomDialogGOTY_NGE : MovieClip;
		public var mcCustomDialogGalaxySignIn : MovieClip;
		public var mcCustomDialogMod : MovieClip;
		public var mcCustomDialogMarketing : CheckboxListPopup;
		public var mcCustomDialogLicenseAgreement : W3LicenseAgreementPopup;
		public var mcCustomDialogReminder : MovieClip;
		public var mcTermsOfUseDialog : MovieClip;
		public var mcErrorDialog : MovieClip;
		public var mcCloudSavesModalDialog : MovieClip;
		
		public var mcGammaModule : GammaSettingModule;
		public var mcHelpModule : StaticOptionModule;
		public var mcUIRescaleModule : UIRescaleModule;
		public var mcGameMappingModule : GamepadMappingModule;
		public var mcOptionListModule : OptionListModule;
		public var mcSaveSlotListModule : SaveSlotListModule;
		public var mcKeyBindModule : KeyBindsOptionModule;
		public var mcInstalledDLCModule : InstalledDLCModule;
		public var mcLoadIndicator : MovieClip;

		public var mcModdedTooltip : TooltipModded;
		
		public var _lastRequestedUrl : String;
		
		public var mcBlackBackground : W3Background;
		public var mcInputBackground: MovieClip;
		
		public var txtUserName : TextField;
		public var txtVersion : TextField;
		public var txtFrameRateMode : TextField;
		
		public var mcCloudSaveButton : InputFeedbackButton;
		public var brCloudSaveBorder : DisplayObject;
		public var isCloudUserSignedIn : Boolean = false;
		
		public var mcAnchor_MODULE_Tooltip : MovieClip;
		
		public var previousEntries : Vector.<DataProvider>;
		public var previousContainers : Vector.<Object>;
		public var previousSelections : Vector.<int>;
		public var rootData : Array;
		
		private var _isMainMenu : Boolean = false;
		private var _ignoreInput : Boolean = false;
		public var _hardwareCursorOn : Boolean = false;
		public var _telemetryConsent : Boolean = false;
		public var _consentPopupWasShown : Boolean = false;
		public var _waitingQRCodePicture : Boolean = false;
		public var _hidNavButtUse : Boolean = false;
		public var _hidNavButtStick : Boolean = false;
		public var _hidNavButtProfile : Boolean = false;
	
		private var _hideAnimationPlaying : Boolean = false;
		
		private var _platform : int = PlatformType.PLATFORM_PC;
		private var _isPlatformXBox : Boolean = false; // autochanged with _platform
		private var _isPlatformPlayStation : Boolean = false; // autochanged with _platform
		
		private var _panelMode : Boolean = false; // This means the menu was opened just for access to panel. Close it all when panel closes
		
		private var _inPanel : Boolean = false;
		
		private var popupQueue : Array = [];

		private var _reminderIsPlatformPC : Boolean;

		public var switchFeaturesPopUp : SwitchFeaturesPopUp
		public var mcSwitchHoldMode : W3TextArea;

		public var mcMyRewardsPanel : MyRewardsPanel;
		public var mcAccountButtonPanel : AccountButtonPanel;
		public var mcUserNamePanel : MainMenuUserNamePanel;

		var cachedBalladTooltipVis : Boolean = false;
		var cachedBalladTooltipText : String = "";
		static const BALLAD_TOOLTIP_TEXT_MARGIN : Number = 12;
		static const BALLAD_TOOLTIP_FRAME_EXTRA : Number = 6;

		public function set inPanel(value:Boolean):void
		{
			trace( "IngameMenu::inPanel : ", value );

			_inPanel = value;

			if ( mcAccountButtonPanel ) mcAccountButtonPanel.visible = _isMainMenu && !_inPanel;
			if ( mcUserNamePanel ) mcUserNamePanel.setIsInPanel( _inPanel );
			
			if (menuListModule)
			{
				menuListModule.lockSelection = _inPanel;
			}
			
			if (mcCloseBtn)
			{
				mcCloseBtn.visible = _inPanel;
			}
		}
		
		public function get inPanel():Boolean { return _inPanel; }
		
		public function IngameMenu()
		{
			super();
			
			previousEntries = new Vector.<DataProvider>();
			previousContainers = new Vector.<Object>();
			previousSelections = new Vector.<int>();
			upToCloseEnabled = false;
			
			mcInputFeedbackModule.clickable = false;
			mcInputFeedbackModule.showBackground = true;
			
			mcInputBackground = mcInputFeedbackModule["mcInputBackground"] as MovieClip;
			
			stage.addEventListener( MouseEvent.CLICK, onStageClicked, false, 1, true );
			stage.addEventListener( GestureEvent.GESTURE_TWO_FINGER_TAP, handleGestureTwoFingerTap, false, 0, true );
			
			mcBlackBackground.visibilityChangeCallback = onBackgroundVisibilityChanged;
		}
	
		public function handleGestureTwoFingerTap( event : GestureEvent ) : void 
		{
			if ( handleNavigateBack() )
			{
				
			}
			else if ( !_isMainMenu )
			{
				hideAnimation();
			}
		}

		public function onBackgroundVisibilityChanged( value : Boolean ) : void
		{
			mcInputFeedbackModule.showBackground = !value;
		}
		
		public function setGogCloudState(data:Object)
		{
			isCloudUserSignedIn = data.isUserSignedIn;
		}

		public function SetCloudSaveVisibility( show : Boolean ) : void
		{
			// WW-7227 design change -- we want a hint in line with other borders
			if (brCloudSaveBorder) {
				//brCloudSaveBorder.visible = show; 
				brCloudSaveBorder.visible = false;
			}
			if (mcCloudSaveButton) {
				//mcCloudSaveButton.visible = show;
				mcCloudSaveButton.visible = false;
				mcCloudSaveButton.clickable = false;
				mcCloudSaveButton.label = "[[ui_gog_cloud_saves_sign_in]]";
				mcCloudSaveButton.setDataFromStage(NavigationCode.GAMEPAD_L2, KeyCode.NUMBER_1);			
				mcCloudSaveButton.validateNow();
			}

			if (show) {
				mcInputFeedbackModule.appendButton(ACTION_APPLY_PRESET, NavigationCode.GAMEPAD_L2, KeyCode.C, "[[ui_gog_cloud_saves_title]]", true);
			} else	{
				mcInputFeedbackModule.removeButton(ACTION_APPLY_PRESET, true);
			}
		}
		
		override protected function configUI():void
		{
			super.configUI();

			inPanel = false;
			
			_contextMgr.defaultAnchor = mcAnchor_MODULE_Tooltip;
			_contextMgr.addGridEventsTooltipHolder(stage);
			
			//stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			
			if (txtUserName)
			{
				txtUserName.text = "";
			}

			if (txtVersion)
			{
				txtVersion.text = "";
			}
			
			SetCloudSaveVisibility(false);
			
			if (mcCustomDialogEp1)
			{
				closeCustomDialog( 1, false );
			}
			if (mcCustomDialogEp2)
			{
				closeCustomDialog( 2, false );
			}
			if (mcCustomDialogGOTY)
			{
				closeCustomDialog( 3, false );
			}
			if (mcCustomDialogMod)
			{
				mcCustomDialogMod.visible = false;
			}
			if (mcCustomDialogMarketing)
			{
				mcCustomDialogMarketing.visible = false;
			}

			if(mcCustomDialogLicenseAgreement)
			{
				mcCustomDialogLicenseAgreement.visible = false;
			}

			if(mcCustomDialogReminder)
			{
				mcCustomDialogReminder.visible = false;
			}
		
			if (mcCustomDialogGOTY)
			{
				mcCustomDialogGOTY.visible = false;
			}

			if (mcCustomDialogGOTY_NGE)
			{
				mcCustomDialogGOTY_NGE.visible = false;
			}
			
			closeGalaxySignInDialog();
			
			if (mcErrorDialog)
			{
				mcErrorDialog.visible = false;
			}
			
			if (mcCloudSavesModalDialog)
			{
				mcCloudSavesModalDialog.visible = false;
			}
			
			if (mcTermsOfUseDialog) 
			{
				mcTermsOfUseDialog.visible = false;
			}

			if ( mcMyRewardsPanel )
			{
				mcMyRewardsPanel.visible = false;
			}

			_lastRequestedUrl = "Requested. Please wait";
			
			focused = 1;
			
			if (mcBlackBackground)
			{
				mcBlackBackground.forceHide();
			}
			
			if (menuListModule)
			{
				menuListModule.focusable = false;
				menuListModule.titleText = "";
				
				var contMenu:MovieClip = menuListModule.getChildByName("MenuContinue") as MovieClip;
				if (contMenu) {
					contMenu.visible = false;
				}
			}
			
			if (txtFrameRateMode) 
			{
				txtFrameRateMode.visible = false;
			}
			
			if (mcCloseBtn)
			{
				mcCloseBtn.addEventListener(ButtonEvent.PRESS, handleClosePressed, false, 0, true);
				mcCloseBtn.showOnSwitch2Mouser = true;
			}
			
			if (mcGammaModule)
			{
				mcGammaModule.addEventListener( OnOptionPanelClosed, handlePanelClosed, false, 0, true);
			}
			
			if (mcKeyBindModule)
			{
				mcKeyBindModule.addEventListener( OnOptionPanelClosed, handlePanelClosed, false, 0, true);
			}
			
			if (mcInstalledDLCModule)
			{
				mcInstalledDLCModule.addEventListener( OnOptionPanelClosed, handlePanelClosed, false, 0, true);
			}
			
			if (mcHelpModule)
			{
				mcHelpModule.addEventListener( OnOptionPanelClosed, handlePanelClosed, false, 0, true);
			}
			
			if (mcUIRescaleModule)
			{
				mcUIRescaleModule.addEventListener( OnOptionPanelClosed, handlePanelClosed, false, 0, true);
			}
			
			if (mcGameMappingModule)
			{
				mcGameMappingModule.addEventListener( OnOptionPanelClosed, handlePanelClosed, false, 0, true);
			}
			
			if (mcOptionListModule)
			{
				mcOptionListModule.addEventListener( OnOptionPanelClosed, handlePanelClosed, false, 0, true);
			}
			
			if (mcSaveSlotListModule)
			{
				mcSaveSlotListModule.addEventListener( OnOptionPanelClosed, handlePanelClosed, false, 0, true);
				mcSaveSlotListModule.mcScrollingList.addEventListener(ListEvent.INDEX_CHANGE, onSaveSlotSelected, false, 0, true);
			}

			if(mcLoadIndicator)
			{
				mcLoadIndicator.visible = false;
			}

			if(mcSwitchHoldMode)
			{
				mcSwitchHoldMode.visible = false;
			}

			if ( mcAccountButtonPanel )
			{
				mcAccountButtonPanel.addEventListener( MouseEvent.CLICK, handleAccountButtonClickOrTap, false, 0, true );
				mcAccountButtonPanel.addEventListener( GestureEventEx.GESTURE_TAP, handleAccountButtonClickOrTap, false, 0, true );
			}
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.entries", [handleEntriesSet] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.addloading", [handleAddLoadingOption] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.gamepad.mappings", [handleGamepadInfoRecieved] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.loadSlots", [handleRecievedLoadSlots] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.saveSlots", [handleRecievedSaveSlots] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.importSlots", [handleReceivedImportSlots] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.newGamePlusSlots", [handleReceivedNewGamePlusSlots] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.uirescale", [handleSetUIRescale] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.options.entries", [handleOptionsSet] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.optionPresetChange", [handleOptionPresetChanged] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.keybindValues", [handleKeybindValuesSet] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.installedDLCs", [handleInstalledDLCsSet] ) );
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.bigMessage1", [prepareBigMessageEp1] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.bigMessage2", [prepareBigMessageEp2] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.bigMessage3", [prepareBigMessageGOTY] ) );
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.bigMessage4", [prepareBigMessageGalaxySignIn] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.bigMessageMod", [prepareBigMessageMod] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.MarketingWindow", [setMarketingWindow] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.LicenseAgreementWindow", [setLicenseAgreementWindow] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.ReminderWindow", [setRedReminderWindow] ) );
			
						
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.framerateModeTooltip", [handleSetFramrateModeTooltip] ) );
			
			dispatchEvent (new GameEvent (GameEvent.REGISTER, "ingamemenu.ErrorHandleWindow", [setErrorHandlingWindow]));
			dispatchEvent (new GameEvent (GameEvent.REGISTER, "ingamemenu.AccountsTermsOfUseWindow", [setTermsOfUseWindow]));
			dispatchEvent (new GameEvent (GameEvent.REGISTER, "ingamemenu.gogCloudState", [setGogCloudState]));

			dispatchEvent (new GameEvent (GameEvent.REGISTER, "ingamemenu.myrewardspanel", [showMyRewardsPanel]));

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_common_select]]", false);
			mcInputFeedbackModule.appendButton(ACTION_SCROLL, NavigationCode.GAMEPAD_L3, -1, "[[panel_button_common_navigation]]", true);
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "ingamemenu.switchPopUp", [prepareSwtichPopUp] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.switch.setup', [callSwitchFeatureFillData]));
		}

		public function callSwitchFeatureFillData(nameList:Array):void 
		{
			switchFeaturesPopUp.fillDataSwitchFeatureTabs(nameList);
		}
		
		override public function setPlatform(platformType:uint):void
		{
			var ctn : PatchNotesPopup;

			super.setPlatform(platformType);
			
			_platform = platformType;
			
			_isPlatformXBox = _inputMgr.isXboxPlatform();
			_isPlatformPlayStation = _inputMgr.isPsPlatform();

			if (_isMainMenu && _platform == PlatformType.PLATFORM_XBOX1 )
			{
				mcInputFeedbackModule.appendButton(ACTION_Y, NavigationCode.GAMEPAD_Y, -1, "[[panel_button_common_choose_profile]]", true);
			}

			ctn = mcCustomDialogGOTY_NGE.getChildByName( "content") as PatchNotesPopup;			
			ctn.SetupData_41();
		}
		
		public function setIgnoreInput(value:Boolean):void
		{
			_ignoreInput = value;
		}
		
		public function setHardwareCursorOn(value:Boolean):void
		{
			_hardwareCursorOn = value;
		}
		
		private function addToPopupQueue(popup:MovieClip) : void
		{
			//if(_currentDialogIndex == -1)
			//	popup.visible = true;

			trace("GFX -- Emplacing into", popupQueue.length, "length list", popup.name);

			if(popupQueue.length == 0)
			{
				popupQueue.push(popup);
				popup.visible = true;
			}
			else {
				popupQueue.push(popup);
				popup.visible = false;
			}
		}

		private function showNextPopup():void
		{
			if(popupQueue.length > 0)
			{
				popupQueue.splice(0, 1);

				if(popupQueue.length > 0)
					popupQueue[0].visible = true;
			}
		}

		private function getCustomDialogByIndex( index : int ) : MovieClip
		{
			switch ( index )
			{
				case 1:
				case 2:
					return getChildByName( "mcCustomDialogEp" + index ) as MovieClip;
				case 3:
					if( _platform == PlatformType.PLATFORM_PC ||
						_platform == PlatformType.PLATFORM_PC_GDK ||
						_platform == PlatformType.PLATFORM_PS5 ||
						_platform == PlatformType.PLATFORM_XB_SCARLETT_LOCKHART ||
						_platform == PlatformType.PLATFORM_XB_SCARLETT_ANACONDA ||
						_platform == PlatformType.PLATFORM_SWITCH2 )
					{
						return getChildByName( "mcCustomDialogGOTY_NGE" ) as MovieClip;
					}
					else
					{
						return getChildByName( "mcCustomDialogGOTY" ) as MovieClip;
					}
				case 4: 
					return getChildByName ("mcCustomDialogGalaxySignIn") as MovieClip;
				case 5: 
					return getChildByName ("mcCustomDialogMod") as MovieClip;	
				case 6:
					return getChildByName("mcCustomDialogMarketing") as MovieClip;	
				case 7:
					return getChildByName("mcCustomDialogLicenseAgreement") as MovieClip;
				case 8:
					return getChildByName("mcCustomDialogReminder") as MovieClip;
			}
			return null;
		}
		
		public function handleSetFramrateModeTooltip(data:Object)
		{
			txtFrameRateMode.visible = data.isVisible;
			if(data.text)
				txtFrameRateMode.text = data.text;
		}
		
		public function prepareSwtichPopUp(data:Object)
		{
			switchFeaturesPopUp.openSwitchFeaturePopUpMenu();
		}

		public function prepareBigMessageEp1(data:Object)
		{
			prepareBigMessage(data);
		}
		
		public function prepareBigMessageEp2(data:Object):void
		{
			prepareBigMessage(data);
		}

		private var _currentDialogIndex : int = -1;
		private var _queuedDialogIndices : Vector.< int > = new Vector.< int >;
		private var _currentDialogTimer : Timer;

		public function prepareBigMessage(data:Object):Boolean
		{
			if ( !data )
			{
				return false;
			}
			
			var customDialog : MovieClip = getCustomDialogByIndex( data.index );
			if ( !customDialog )
			{
				return false;
			}
			
			addToPopupQueue(customDialog);
				
			setMessageTextValue(customDialog, "tfTitle1", data.tfTitle1, true );
			setMessageTextValue(customDialog, "tfTitle2", data.tfTitle2, true);
			setMessageTextValue(customDialog, "tfTitlePath1", data.tfTitlePath1, true , "mcPathTitle" );
			setMessageTextValue(customDialog, "tfTitlePath2", data.tfTitlePath2, true , "mcPathTitle" );
			setMessageTextValue(customDialog, "tfTitlePath3", data.tfTitlePath3, true , "mcPathTitle" );
			setMessageTextValue(customDialog, "tfDescPath1", data.tfDescPath1 , false , "mcPathDescription" );
			setMessageTextValue(customDialog, "tfDescPath2", data.tfDescPath2 , false , "mcPathDescription" );
			setMessageTextValue(customDialog, "tfDescPath3", data.tfDescPath3 , false , "mcPathDescription" );
			setMessageTextValue(customDialog, "tfWarning1", data.tfWarning , false , "mcPathWarning" );
			setMessageTextValue(customDialog, "tfWarning2", data.tfWarning , false , "mcPathWarning" );
			setMessageTextValue(customDialog, "tfGoodLuck", data.tfGoodLuck, true);
			
			if ( _queuedDialogIndices )
			{
				_queuedDialogIndices[ _queuedDialogIndices.length ] = data.index;
			}
			
			showNextCustomDialog();
			
			return true;
		}
		
		public function prepareBigMessageGOTY(data:Object):Boolean
		{
			if ( !data )
			{
				return false;
			}

			var customDialog : MovieClip = getCustomDialogByIndex( data.index );
			if ( !customDialog )
			{
				return false;
			}

			setMessageTextValue(customDialog, "tfTitle1", data.tfTitle1, true );
			setMessageTextValue(customDialog, "tfContent", data.tfContent, false );
			setMessageTextValue(customDialog, "tfTitleEnd", data.tfTitleEnd, true );
			
			addToPopupQueue(customDialog);

			if ( _queuedDialogIndices )
			{
				_queuedDialogIndices[ _queuedDialogIndices.length ] = data.index;
			}
			
			showNextCustomDialog();
			
			return true;
		}

		public function prepareBigMessageMod(data:Object):Boolean
		{
			if ( !data )
			{
				return false;
			}
			var customDialog : MovieClip = getCustomDialogByIndex( 5 );
			if ( !customDialog )
			{
				return false;
			}
			var modVerifWindow : ModVerificationPopup = customDialog as ModVerificationPopup;
			if(modVerifWindow)
			{
				modVerifWindow.data = data;
			}
			
			addToPopupQueue(customDialog);

			/*if ( _queuedDialogIndices )
			{
				_queuedDialogIndices[ _queuedDialogIndices.length ] = data.index;
			}
			
			showNextCustomDialog();*/
			
			return true;
		}
		
		public function prepareBigMessageGalaxySignIn(data:Object):Boolean
		{
			if ( !data )
			{
				return false;
			}
			
			var customDialog : MovieClip = getCustomDialogByIndex( data.index );
			if ( !customDialog )
			{
				return false;
			}
			customDialog.visible = true;
				
			setMessageTextValue(customDialog, "tfTitleSignIn", data.tfTitleSignIn, false );
			setMessageTextValue(customDialog, "tfContentSignInTopA", data.tfContentSignInTopA, false );
			setMessageTextValue(customDialog, "tfContentSignInTopB", data.tfContentSignInTopB, false );
			setMessageTextValue(customDialog, "tfContentSignInTopC", data.tfContentSignInTopC, false );
			setMessageTextValue(customDialog, "tfContentSignIn2", data.tfContentSignIn2, false );
			setMessageTextValue(customDialog, "tfContentSignIn3", data.tfContentSignIn3, false );
			setMessageTextValue(customDialog, "tfLink1", data.tfLink1, false);
			
			var QrCodeLoader:W3UILoader = mcCustomDialogGalaxySignIn.getChildByName("mcQrCodeLoader") as W3UILoader;
			if (QrCodeLoader) {
				QrCodeLoader.visible = false;
				QrCodeLoader.source = "";
			}
			
			if (data.isPlatformPC)	{
				var backGroundtfLink1: MovieClip = customDialog.getChildByName("textFieldBackground") as MovieClip;
				backGroundtfLink1.visible = false;
			}

			if ( _queuedDialogIndices )
			{
				_queuedDialogIndices[ _queuedDialogIndices.length ] = data.index;
			}

			// Cancel
			var cancelButton:InputFeedbackButton = customDialog.getChildByName("mcCancelButton") as InputFeedbackButton;
			if (cancelButton)
			{
				// WW-3800 in disabled form
				var shift : int = 227;
				cancelButton.x = 513 + shift;

				// WW-5013 the border causes misalignments
				var escBorder : DisplayObject = customDialog.getChildByName("brEscBorder") as DisplayObject;
				if (escBorder) {
					escBorder.x = 468 + shift;
					escBorder.visible = false;
				}
				
				// regular setup
				cancelButton.visible = true;
				cancelButton.clickable = true;
				cancelButton.label = "[[panel_common_cancel]]";
			    cancelButton.setShiftForGamepad(26, 0);
				cancelButton.setDataFromStage(NavigationCode.GAMEPAD_B, KeyCode.ESCAPE);			
				cancelButton.addEventListener(ButtonEvent.PRESS, showBigMessageFinished4, false, 0, true);			
				cancelButton.validateNow();
			}		
			
			// Terms
			setupTermsButton(customDialog);

			// WW-3953 don't show inactive buttons
			hideNavButtonsMainMenu();
			
			return true;
		}
		
		public function closeGalaxySignInDialog()
		{
			if (mcCustomDialogGalaxySignIn)
			{
				if (mcCustomDialogGalaxySignIn.visible) {
					showNavButtonsMainMenu();
				}
				mcCustomDialogGalaxySignIn.visible = false;
			}
			if(mcCustomDialogReminder)
			{
				if(mcCustomDialogReminder.visible)
				{	
					showNextPopup();
					mcCustomDialogReminder.visible = false;
				}
			}
		}
		
		public function ShowCloudModal(value :String)
		{
			if (!mcCloudSavesModalDialog) {
				return;
			}
			
			var personaName: TextField;
			var loggedIn: TextField;
			
			// texts
			var txtEp1:TextField = mcCloudSavesModalDialog.getChildByName("tfPersonaName") as TextField;
			if (txtEp1 != null) {
				txtEp1.htmlText = value;
			}
			personaName = txtEp1;
			txtEp1 = mcCloudSavesModalDialog.getChildByName("tfTitle") as TextField;
			if (txtEp1 != null) {
				txtEp1.htmlText = "[[ui_gog_cloud_saves_title]]";
			}
			txtEp1 = mcCloudSavesModalDialog.getChildByName("tfExplain") as TextField;
			if (txtEp1 != null) {
				txtEp1.htmlText = "[[ui_gog_cloud_saves_explained]]";
			}
			txtEp1 = mcCloudSavesModalDialog.getChildByName("tfLoggedIn") as TextField;
			if (txtEp1 != null) {
				txtEp1.htmlText = "[[ui_gog_cloud_logged_in]]";
			}
			loggedIn = txtEp1;
			
			var format: TextFormat = new TextFormat();
			if(CoreComponent.isArabicAligmentMode){
				personaName.x = -146.05;
				loggedIn.x = 220.05;
				
				format.align = "right";				
				personaName.setTextFormat(format);
				
				format.align = "left";
				loggedIn.setTextFormat(format);
			}else{
				personaName.x = 220.05;
				loggedIn.x = -146.05;
				
				format.align = "left";				
				personaName.setTextFormat(format);
				
				format.align = "right";
				loggedIn.setTextFormat(format);
			}
				
			// sign out
			var unlinkButton : InputFeedbackButton = mcCloudSavesModalDialog.getChildByName("mcSignOutButton") as InputFeedbackButton;
			if (!unlinkButton)	{
				return;
			}

			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
			unlinkButton.visible = true;
			unlinkButton.clickable = true;
			unlinkButton.label = "[[ui_gog_button_signout]]";
			unlinkButton.setDataFromStage(isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X, KeyCode.Q);
			unlinkButton.addEventListener(ButtonEvent.PRESS,handleMyRewardsSignOut,false,0,false);
			unlinkButton.validateNow();
			
			// accept
			var tryButton : InputFeedbackButton = mcCloudSavesModalDialog.getChildByName("mcAcceptButton") as InputFeedbackButton;
			if (!tryButton)	{
				return;
			}

			tryButton.visible = true;
			tryButton.clickable = true;
			tryButton.label = "[[panel_common_accept]]";
			tryButton.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.ENTER);
			tryButton.addEventListener(ButtonEvent.PRESS,handleMyRewardsAccept,false,0,false);
			tryButton.validateNow();
			// Center accept button on PC since the sign out button is removed.
			if(_platform == PlatformType.PLATFORM_PC){
				tryButton.x = 146.6;
				tryButton.setShiftForGamepad(10, 0);
			}else{
				tryButton.x = 317.65;
				tryButton.setShiftForGamepad(20, 0);
			}
			
			// hints at the screen bottom
			if (mcInputFeedbackModule) {
				mcInputFeedbackModule.setVisibility(false);
			}
			
			// ready
			addToPopupQueue(mcCloudSavesModalDialog);
		}
		
		public function GalaxyQRSignInCancel()
		{
			closeGalaxySignInDialog();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnGalaxyQRSignInCancel" ) );
		}
		
		private function LoadQR(clip:MovieClip)
		{
			var QrCodeLoader:W3UILoader = clip.getChildByName("mcQrCodeLoader") as W3UILoader;
			if (QrCodeLoader) {
				QrCodeLoader.source = "qrcode.qrcode";
				QrCodeLoader.visible = true;
				QrCodeLoader.validateNow();
			}
			
			if(clip.getChildByName("tfLink1")) {
				var tfUrl:TextField = clip.getChildByName("tfLink1") as TextField;
				tfUrl.addEventListener( MouseEvent.CLICK, handleTfUrl, false, 0, true );
				if (tfUrl.htmlText != _lastRequestedUrl) {
					tfUrl.htmlText = _lastRequestedUrl;
				}
			}
		}
		
		public function QRCodeReadyToLoad(value :String)
		{
			if (_lastRequestedUrl != value)	{
				_lastRequestedUrl = value;
			}

			if (mcCustomDialogGalaxySignIn) {
				LoadQR(mcCustomDialogGalaxySignIn);
			}
			
			if(mcCustomDialogReminder)
			{
				LoadQR(mcCustomDialogReminder.mcQRPanel)
			}
		}
		
		protected function handleTfUrl()
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnVisitSignInPage" ) );
		}
		
		public function setMarketingWindow(data:Object):Boolean
		{
			if ( !data )
			{
				return false;
			}
			var customDialog : MovieClip = getCustomDialogByIndex( 6 );
			if ( !customDialog )
			{
				return false;
			}
			var marketingWindow : CheckboxListPopup = customDialog as CheckboxListPopup;
			if(marketingWindow)
			{
				marketingWindow.data = data;
			}
			addToPopupQueue(customDialog);
			
			return true;
		}

		public function setLicenseAgreementWindow(data:Object):Boolean
		{
			if ( !data )
			{
				return false;
			}
			var customDialog : MovieClip = getCustomDialogByIndex( 7 );
			if ( !customDialog )
			{
				return false;
			}
			var laWindow : W3LicenseAgreementPopup = customDialog as W3LicenseAgreementPopup;
			if(laWindow)
			{
				laWindow.data = data;
				laWindow.btnAccept.addEventListener(ButtonEvent.PRESS, onLAButtonAcceptClicked, false, 0, true);
				laWindow.btnDecline.addEventListener(ButtonEvent.PRESS, onLAButtonDeclineClicked, false, 0, true);
			}
			addToPopupQueue(customDialog);
			
			return true;
		}

		public function setRedReminderWindow(data:Object):Boolean
		{
			if ( !data )
			{
				return false;
			}
			var customDialog : MovieClip = getCustomDialogByIndex( 8 );
			if ( !customDialog )
			{
				return false;
			}
			if(customDialog)
			{
				var title : String = CommonUtils.toUpperCaseSafe( data.TextTitle);
				setMessageTextValue(customDialog, "txtTitle", title, false, "", true);
				setMessageTextValue(customDialog, "txtMessage", data.TextContent, false, "", true);
				setMessageTextValue(customDialog, "txtPcLoginInfo", data.TextLoginInfo, false, "", true);
				setMessageTextValue(customDialog.mcQRPanel, "txtSignin", data.TextSignIn, false, "", true);

				_reminderIsPlatformPC = data.isPlatformPC;

				customDialog.mcQRPanel.visible = !data.isPlatformPC;
				customDialog.txtPcLoginInfo.visible = data.isPlatformPC;

				customDialog.x = (1920 - customDialog.mcBackground.width)/2;
				customDialog.y = (1080 - customDialog.mcBackground.height)/2;

				var okButton = customDialog.getChildByName("btnOkay");

				okButton.visible = true; //<--required to scroll down!
				okButton.clickable = true;
				okButton.label = "[[panel_common_cancel]]";
				okButton.setDataFromStage(NavigationCode.GAMEPAD_B, KeyCode.ESCAPE);
				okButton.addEventListener(ButtonEvent.PRESS, onReminderOkClicked, false, 0, false);
				okButton.validateNow();

				var QrCodeLoader:W3UILoader = customDialog.mcQRPanel.getChildByName("mcQrCodeLoader") as W3UILoader;
				if (QrCodeLoader) {
					QrCodeLoader.visible = false;
					QrCodeLoader.source = "";
				}
			}
			addToPopupQueue(customDialog);
			
			return true;
		}
		
		private function feedbackViewTerms(event : ButtonEvent):void
		{
			setTermsOfUseWindow(null);
		}
		
		private function setupTermsButton( clip : MovieClip ):void
		{
			var termsButton : InputFeedbackButton = clip.getChildByName("mcTermsButton") as InputFeedbackButton;
			if (!termsButton)	{
				return;
			}
			
			// WW-3800 is expected to be waived
			var termsBorder : DisplayObject= clip.getChildByName("brTermsBorder") as DisplayObject;
			if (termsBorder) {
				termsBorder.visible = false;
			}
			termsButton.visible = false;
			
			// in case we need that
			// termsButton.visible = true;
			// termsButton.clickable = true;
			// termsButton.label = "[[ui_gog_button_terms]]";
			// termsButton.setDataFromStage(NavigationCode.GAMEPAD_Y, KeyCode.T);
			// termsButton.addEventListener(ButtonEvent.PRESS,feedbackViewTerms,false,0,false);
			// termsButton.validateNow();
			
		}

		private function onLAButtonAcceptClicked(event : ButtonEvent):void
		{
			if(mcCustomDialogLicenseAgreement.hasScrolledDownFully())
			{
				mcCustomDialogLicenseAgreement.visible = false;
				mcCustomDialogLicenseAgreement.tryAcceptFromOutside();
				showNextPopup();
			}
		}

		private function onLAButtonDeclineClicked(event : ButtonEvent):void
		{
			if(mcCustomDialogLicenseAgreement.hasScrolledDownFully())
			{
				
			}
		}

		private function onReminderOkClicked(event : ButtonEvent):void
		{
			if(mcCustomDialogReminder.visible)
			{
				dispatchEvent(new GameEvent( GameEvent.CALL, 'OnGalaxyQRSignInCancel' ));	
				showNextPopup();
				mcCustomDialogReminder.visible = false;
			}
		}
		
		public function setErrorHandlingWindow(data:Object)
		{
			if (!data || !mcErrorDialog)
			{
				return false;
			}
			
			closeGalaxySignInDialog();
			
			addToPopupQueue(mcErrorDialog);
			
			setMessageTextValue(mcErrorDialog, "tfTitleError", data.tfTitleError, false);
			setMessageTextValue(mcErrorDialog, "tfDescription", data.tfDescription, false);
			
			var tryButton : InputFeedbackButton = mcErrorDialog.getChildByName("mcTryButton") as InputFeedbackButton;
			if (tryButton == null)
			{
				return false;
			}
			
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
			tryButton.visible = true;
			tryButton.clickable = true;
			tryButton.label = "[[ui_gog_error_close_button]]";
			tryButton.setDataFromStage(isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X, KeyCode.ENTER);
			tryButton.addEventListener(ButtonEvent.PRESS,feedbackErrorHandling,false,0,false);
			tryButton.validateNow();
		}
		
		public function hideErrorHandlingWindow():void
		{
			if (mcErrorDialog)
			{
				mcErrorDialog.visible = false;
			}
		}
		
		private function handleMyRewardsAccept(event : ButtonEvent):void
		{
			if (mcCloudSavesModalDialog) {
				mcCloudSavesModalDialog.visible = false;
			}
			
			// Display the keybinds at the bottom of the screen.
			if (mcInputFeedbackModule) {
				mcInputFeedbackModule.setVisibility(true);
			}

			showNextPopup();
		}

		private function handleMyRewardsSignOut(event : ButtonEvent):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnGalaxyUnlinkAccounts" ) );

			handleMyRewardsAccept(null);
		}
		
		private function hideNavButtonsMainMenu():void
		{
			trace("IngameMenu::hideNavButtonsMainMenu");

			// hide extra hints
			if (mcInputFeedbackModule) {
				_hidNavButtUse     = mcInputFeedbackModule.removeButton(ACTION_USE, true);
				_hidNavButtStick   = mcInputFeedbackModule.removeButton(ACTION_SCROLL, true);
				_hidNavButtProfile = mcInputFeedbackModule.removeButton(ACTION_Y, true);
				
				// WW-4451
				mcInputFeedbackModule.removeButton(ACTION_X, true);
				mcInputFeedbackModule.removeButton(ACTION_CLOSE, true);
			}
		}

		private function showNavButtonsMainMenu():void
		{
			// show only the hints hidden
			if (_hidNavButtUse) {
				mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_common_select]]", true);
			}
			if (_hidNavButtStick) {
				mcInputFeedbackModule.appendButton(ACTION_SCROLL, NavigationCode.GAMEPAD_L3, -1, "[[panel_button_common_navigation]]", true);
			}
			if (_hidNavButtProfile) {
				var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
				mcInputFeedbackModule.appendButton(ACTION_Y, isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, -1, "[[panel_button_common_choose_profile]]", true);
			}
		}

		public function showMainMenuButtonPanel( show : Boolean ) : void
		{
			mcInputFeedbackModule.visible = show;
		}
		
		private function feedbackTermsOfUse(event : ButtonEvent):void
		{
			if (mcTermsOfUseDialog)
			{
				mcTermsOfUseDialog.visible = false;
				showNextPopup();
			}
		}

		private function chooseTermsOfUseText():String
		{
			// use that when we need it: _isPlatformXBox, _isPlatformPlayStation
			return "[[ui_gog_terms_big_text_xb1]]";
		}
		
		public function setTermsOfUseWindow(data:Object)
		{
			// WW-3800 is expected to be waived
			return false;
				
			// pre-req
			if (!mcTermsOfUseDialog)
			{
				return false;
			}
			var acceptButton:InputFeedbackButton = mcTermsOfUseDialog.getChildByName("mcAcceptButton") as InputFeedbackButton;
			if (!acceptButton)
			{
				return false;
			}

			// main contents
			setMessageTextValue(mcTermsOfUseDialog, "tfTitleTerms", "[[ui_gog_terms_use_title]]", false);
			setMessageTextValue(mcTermsOfUseDialog, "tfTermsBigText", chooseTermsOfUseText(), false, "", true);
			addToPopupQueue(mcTermsOfUseDialog);

			// single button
			acceptButton.visible = true;
			acceptButton.clickable = true;
			acceptButton.label = "[[panel_button_common_exit]]";
			acceptButton.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.ENTER);
			acceptButton.addEventListener(ButtonEvent.PRESS, feedbackTermsOfUse, false, 0, true);
			acceptButton.validateNow();
		}
		
		public function DLSSIsSupported(IsSupported : Boolean,tag : uint)
		{
			_DLSSIsSupported = IsSupported;
			if (AAModeIntTag == 0)
			{
				AAModeIntTag = tag;
			}
		}
		
		public function RTEnabled(IsEnabled : Boolean,tag : uint)
		{
			_RTEnabled = IsEnabled;			
			if (Virtual_SSAOSolutionIntTag == 0)
			{
				Virtual_SSAOSolutionIntTag = tag;
			}
		}
		
		private function feedbackErrorHandling(event : ButtonEvent):void
		{
			if (mcErrorDialog)
			{
				mcErrorDialog.visible = false;
				showNextPopup();
			}
		}

		private function showNextCustomDialog()
		{
			if ( _currentDialogIndex == -1 )
			{
				if ( _queuedDialogIndices.length > 0 )
				{
					_currentDialogIndex = _queuedDialogIndices[ 0 ];
					showBigMessageByIndex( _currentDialogIndex );
				}
			}
		}
		
		public function showBigMessageByIndex( index : int ):void
		{
			var customDialog : MovieClip = getCustomDialogByIndex( index );
			if ( customDialog )
			{
				showBigMessage( customDialog );
			}
		}
		
		public function setOunceGamepadType( onceType : int ):void
		{
			updateSwitchHoldMode(onceType);
		}
		
		private function showBigMessage( customDialog : MovieClip )
		{
			customDialog.gotoAndPlay(2);
			var animTitleGlow1:MovieClip = customDialog.getChildByName("animTitleGlow1") as MovieClip;
			var animTitleGlow2:MovieClip = customDialog.getChildByName("animTitleGlow2") as MovieClip;
			var animTitleGlow3:MovieClip = customDialog.getChildByName("animTitleGlow3") as MovieClip;
			if (animTitleGlow1)
			{
				animTitleGlow1.gotoAndPlay(2);
			}
			if (animTitleGlow2)
			{
				animTitleGlow2.gotoAndPlay(2);
			}
			if (animTitleGlow3)
			{
				animTitleGlow3.gotoAndPlay(2);
			}

			createDialogTimer();

			var okButton:InputFeedbackButton = customDialog.getChildByName("mcOkButton") as InputFeedbackButton;
			if (okButton != null)
			{
				okButton.visible = false;
			}
		}
		
		private function createDialogTimer()
		{
			removeDialogTimer();
			
			_currentDialogTimer = new Timer( 10 );
			_currentDialogTimer.addEventListener( TimerEvent.TIMER, handleCurrentDialogTimer, false, 0, true );
			_currentDialogTimer.start();
		}
		
		private function removeDialogTimer()
		{
			if ( _currentDialogTimer )
			{
				_currentDialogTimer.stop();
				_currentDialogTimer.removeEventListener(TimerEvent.TIMER, handleCurrentDialogTimer );
				_currentDialogTimer = null;
			}
		}
		
		private function handleCurrentDialogTimer( event : TimerEvent )
		{
			var customDialog : MovieClip = getCustomDialogByIndex( _currentDialogIndex );
			if ( customDialog )
			{
				var okButton:InputFeedbackButton = customDialog.getChildByName("mcOkButton") as InputFeedbackButton;
				if (okButton != null)
				{
					okButton.visible = true;
					okButton.clickable = true;
					okButton.label = "[[panel_common_ok]]";
					okButton.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.E);
					if ( customDialog == mcCustomDialogEp1 )
					{
						okButton.addEventListener(ButtonEvent.PRESS, showBigMessageFinished1, false, 0, true);
					}
					else if ( customDialog == mcCustomDialogEp2 )
					{
						okButton.addEventListener(ButtonEvent.PRESS, showBigMessageFinished2, false, 0, true);
					}
					else if ( customDialog == mcCustomDialogGOTY || customDialog == mcCustomDialogGOTY_NGE )
					{
						okButton.addEventListener(ButtonEvent.PRESS, showBigMessageFinished3, false, 0, true);
					}
					okButton.validateNow();
				}
			}
			
			removeDialogTimer();
		}
		
		private function closeCustomDialog( index : int, sendEvent : Boolean = true )
		{
			if ( _currentDialogTimer )
			{
				return;
			}
			
			var customDialog : MovieClip = getCustomDialogByIndex( index );
			if ( customDialog )
			{
				customDialog.visible = false;
				
				if ( sendEvent )
				{
					_currentDialogIndex = -1;
					if ( _queuedDialogIndices.length > 0 )
					{
						_queuedDialogIndices.splice( 0, 1 );
					}
					showNextCustomDialog();
				}
			}
		}

		private function setMessageTextValue(customDialog:MovieClip, textFieldName:String, value:String, upperCase:Boolean = false, parentName:String = "", fixArabicAlignment:Boolean = false ):void
		{
			var targetTextField:TextField;
			var mcParent:MovieClip;

			if (parentName == "")
			{
				
				targetTextField = customDialog.getChildByName(textFieldName) as TextField;
			}
			else
			{
				mcParent =  customDialog.getChildByName(parentName)as MovieClip;
				targetTextField = mcParent.getChildByName(textFieldName) as TextField;
			}
			
			if (targetTextField != null)
			{
				if (value)
				{
					if (upperCase)
					{
						targetTextField.htmlText = CommonUtils.toUpperCaseSafe(value);
					}
					else
					{
						targetTextField.htmlText = value;	
					}
					targetTextField.visible = true;
				}
				else
				{
					targetTextField.visible = false;
				}
				
				if ( fixArabicAlignment )
				{
					var format: TextFormat = targetTextField.getTextFormat();

					if (CoreComponent.isArabicAligmentMode && format.align == TextFormatAlign.LEFT)
						format.align = TextFormatAlign.RIGHT;

					targetTextField.setTextFormat(format);
				}
			}
		}

		protected function showBigMessageFinished1( event : ButtonEvent ) : void
		{
			closeCustomDialog( 1 );
			showNextPopup();
		}

		protected function showBigMessageFinished2( event : ButtonEvent ) : void
		{
			closeCustomDialog( 2 );
			showNextPopup();
		}
		
		protected function showBigMessageFinished3( event : ButtonEvent ) : void
		{
			closeCustomDialog( 3 );
			showNextPopup();
		}
		
		protected function showBigMessageFinished4( event : ButtonEvent ) : void
		{
			GalaxyQRSignInCancel();
		}

		private var _fontLoadTimer:Timer;
		private var _fontLoadDelay:Number = 1000;
		public function updateInputFeedback():void
		{
			if (mcInputFeedbackModule)
			{
				mcInputFeedbackModule.buttonsContainer.visible = false;
			}

			if ( mcUserNamePanel )
			{
				mcUserNamePanel.HACK_languageUpdateStart();
			}

			if (!_fontLoadTimer)
			{
				_fontLoadTimer = new Timer(_fontLoadDelay);
				_fontLoadTimer.addEventListener(TimerEvent.TIMER, delayedUpdateInputFeedback, false, 0, true);
			}
			_fontLoadTimer.reset();
			_fontLoadTimer.start();
		}
		
		public function delayedUpdateInputFeedback(event:Event = null):void
		{
			if (_fontLoadTimer)
			{
				_fontLoadTimer.stop();
				_fontLoadTimer.removeEventListener(TimerEvent.TIMER, delayedUpdateInputFeedback, false);
				_fontLoadTimer = null;
			}

			if (mcInputFeedbackModule)
			{
				mcInputFeedbackModule.refreshButtonList();
				mcInputFeedbackModule.buttonsContainer.visible = true;
			}

			if ( mcUserNamePanel )
			{
				mcUserNamePanel.HACK_languageUpdateEnd();
			}

			if ( mcMyRewardsPanel )
			{
				mcMyRewardsPanel.HACK_languageUpdateEnd();
			}
		}
		
		public function setVisible(shouldShow:Boolean):void
		{
			visible = shouldShow;
		}
		
		public function setPanelMode(panelMode:Boolean):void
		{
			_panelMode = panelMode;
			inPanel = panelMode;
			menuListModule.visible = !panelMode;
		}
		
		override protected function get menuName():String
		{
			return "IngameMenu";
		}
		
		override protected function closeMenu():void
		{
			var _inputMgr:InputManager;
			_inputMgr = InputManager.getInstance();
			_inputMgr.reset();
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBack' ) );
		}
		
		override protected function showAnimation():void
		{
			visible = true;
			alpha = 0;
			GTweener.to(this, SHOW_ANIM_DURATION, { alpha:1 },  { ease: Exponential.easeOut, onComplete:handleShowAnimComplete } );
		}
		
		override public function hideAnimation():void
		{
			if (!_hideAnimationPlaying)
			{
				_hideAnimationPlaying = true;
				GTweener.removeTweens(this);
				
				GTweener.to(this, 0.3, { alpha:0 },  { ease: Exponential.easeOut, onComplete:handleHideAnimComplete } );
			}
		}
		
		public function setForceBackgroundVisible(value:Boolean):void
		{
			if (mcBlackBackground)
			{
				mcBlackBackground.backgroundForceVisible = value;
			}
		}
		
		public function setCurrentUsername(name:String):void
		{
			if (txtUserName)
			{
				txtUserName.text = name;
			}
		}

		public function setVersion(version:String):void
		{
			if (txtVersion)
			{
				txtVersion.text = version;
			}
		}
		
		public function removeOption(tag:int):void
		{
			var i : int;
			var currentData : Object;
			var foundItem : Boolean = false;

			if (rootData != null)
			{
				for ( i = 0; i < rootData.length; ++i )
				{
					currentData = rootData[i];

					if (currentData.tag == tag)
					{
						rootData.splice(i, 1);
						foundItem = true;
						break;
					}
				}
			}
			
			if (foundItem)
			{
				refreshRootData();
			}
		}

		protected function handleEntriesSet( gameData : Array ) : void
		{
			rootData = gameData;
			
			while (previousContainers.length > 0)
			{
				handleNavigateBack();
			}
			
			setListData(new DataProvider(rootData));
		}
		
		protected function refreshRootData() : void
		{
			if (previousContainers.length == 0) // Check to see if we are in the root menu)
			{
				setListData( new DataProvider(rootData), menuListModule.mcList.selectedIndex);
			}
			else
			{
				if (previousContainers.length == 1 && inPanel == true)
				{
					setListData( new DataProvider(rootData), menuListModule.mcList.selectedIndex);
				}
				
				previousEntries[0] = new DataProvider(rootData);
			}
		}
		
		protected function handleAddLoadingOption( optionData : Object ) : void
		{
			var i:int;
			var saveOptionIndex:int = -1;
			
			// Make sure not to add in said ID a second time.
			for (i = 0; i < rootData.length; ++i)
			{
				if (rootData[i].type == IGMActionType_Load)
				{
					return;
				}
				else if (rootData[i].type == IGMActionType_Save)
				{
					saveOptionIndex = i;
				}
			}
			
			if (saveOptionIndex != -1)
			{
				rootData.splice(saveOptionIndex + 1, 0, optionData); // Put load after save
			}
			
			refreshRootData();
		}
		
		protected function setListData( data : DataProvider, selectionIndex:int = 0 ) : void
		{
			menuListModule.setListData( data, selectionIndex );
		}
		
		public function activateMenuListItem( index:int = -1 ):void
		{
			if ( index == -1 )
			{
				index = menuListModule.mcList.selectedIndex;
			}

			var firstIndex:int = 0;
			if(menuListModule.mcList.getRenderers() && menuListModule.mcList.getRenderers().length > 0) //#LT fix for when we have more data objects than renderers
			{
				firstIndex = menuListModule.mcList.getRenderers()[0].index;
			}
			var renderer : BaseListItem =  menuListModule.mcList.getRendererAt( index - firstIndex ) as BaseListItem;
			if (!renderer || !renderer.data)
			{
				return;
			}
			
			if ( ( mcCustomDialogEp1 != null && mcCustomDialogEp1.visible ) ||
			     ( mcCustomDialogEp2 != null && mcCustomDialogEp2.visible ) ||
				 ( mcCustomDialogGOTY != null && mcCustomDialogGOTY.visible ) ||
				 ( mcCustomDialogGalaxySignIn != null && mcCustomDialogGalaxySignIn.visible) ||
				 ( mcCustomDialogMod != null && mcCustomDialogMod.visible ) ||
				 ( mcCustomDialogMarketing != null && mcCustomDialogMarketing.visible) ||
				 ( mcCustomDialogLicenseAgreement != null && mcCustomDialogLicenseAgreement.visible ) ||
				 ( mcCustomDialogReminder != null && mcCustomDialogReminder.visible) )
			{
				return;
			}
			
			var l_data : Object = renderer.data;
			var tag : int = l_data.tag;
			var type : int = l_data.type;

			if ( l_data.unavailable )
			{
				// option unavailable
				return;
			}

			if (inPanel)
			{
				if (previousContainers.length > 0 && previousContainers[previousContainers.length - 1] == l_data) // If we just activate a panel item that is already open, then we shouldn't do anything (TTP#118866)
				{
					return;
				}
				
				handleNavigateBack();
				if (type == IGMActionType_Back)
				{
					showBardsBalladTooltip(false);
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnItemActivated', [type, tag] ) );
					return;
				}
			}
			
			if (!handleEntrySelected(l_data))
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnItemActivated', [type, tag] ) );
			}
		}
		
		override protected function handleInputNavigate(event:InputEvent):void
		{
			if (!visible || _ignoreInput )
			{
				event.handled = true;
				return;
			}
			
			var details:InputDetails = event.details;
            var keyUp:Boolean = (details.value == InputValue.KEY_UP);
			var keyDown:Boolean = (details.value == InputValue.KEY_DOWN);
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
			var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;

			if(switchFeaturesPopUp != null && switchFeaturesPopUp.isSwitchFeaturesPopUpOpen)
			{
				if(keyUp && ((details.code == KeyCode.RIGHT) || (!isSwitch2Mouser && details.navEquivalent == NavigationCode.GAMEPAD_R1)))
				{
					switchFeaturesPopUp.openNextSwitchFeatureTab();
					event.handled = true;
					return;
				}
				else if(keyUp && ((details.code == KeyCode.LEFT) || (!isSwitch2Mouser && details.navEquivalent == NavigationCode.GAMEPAD_L1)))
				{
					switchFeaturesPopUp.openPreviousSwitchFeatureTab();
					event.handled = true;
					return;
				}
				else if(keyUp && (details.code == KeyCode.ESCAPE || details.navEquivalent == NavigationCode.GAMEPAD_B))
				{
					switchFeaturesPopUp.closeSwitchFeaturePopUpMenu();
					event.handled = true;
					return;
				}
				return;
			}

			if (mcCustomDialogEp1 != null && mcCustomDialogEp1.visible)
			{
				if (keyUp && (details.navEquivalent == NavigationCode.GAMEPAD_A || details.code == KeyCode.SPACE || details.code == KeyCode.E))
				{
					closeCustomDialog( 1 );
					showNextPopup();
				}
				event.handled = true;
				return;
			}

			if (mcCustomDialogEp2 != null && mcCustomDialogEp2.visible)
			{
				if (keyUp && (details.navEquivalent == NavigationCode.GAMEPAD_A || details.code == KeyCode.SPACE || details.code == KeyCode.E))
				{
					closeCustomDialog( 2 );
					showNextPopup();
				}
				
				event.handled = true;
				return;
			}

			var customDialog = getCustomDialogByIndex( 3 );
			if (customDialog != null && customDialog.visible)
			{
				if (keyUp && (details.navEquivalent == NavigationCode.GAMEPAD_A || details.code == KeyCode.SPACE || details.code == KeyCode.E  || details.code == KeyCode.ESCAPE ))
				{
					closeCustomDialog( 3 );
					showNextPopup();
				}
				
				event.handled = true;
				return;
			}
			
			if (mcErrorDialog != null && mcErrorDialog.visible)
			{
				if (keyUp &&
					(details.code == KeyCode.ENTER ||
					(isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y) ||		// Y on switch
					(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X)))		// X on other platforms
				{
					mcErrorDialog.visible = false;
					showNextPopup();
				}
				event.handled = true;
				return;
			}
			
			if (mcTermsOfUseDialog != null && mcTermsOfUseDialog.visible)
			{
				if (keyUp &&
					(details.code == KeyCode.ENTER ||
					(isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y) ||		// Y on switch
					(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X)))		// X on other platforms
				{
					mcTermsOfUseDialog.visible = false;
					showNextPopup();
				}
				event.handled = true;
				return;
			}
						
			if (mcCustomDialogGalaxySignIn != null && mcCustomDialogGalaxySignIn.visible)
			{
				if (keyUp && (details.navEquivalent == NavigationCode.GAMEPAD_B || details.code == KeyCode.SPACE || details.code == KeyCode.ESCAPE))
				{
					GalaxyQRSignInCancel();
				}

				if (keyUp &&
					((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X) || // X on switch
					(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y) || // Y on other platforms
					details.code == KeyCode.T))
				{
					setTermsOfUseWindow(null);
				}
				event.handled = true;
				return;
			}

						
			if (mcCustomDialogMarketing != null && mcCustomDialogMarketing.visible)
			{
				if (keyUp &&
					(details.navEquivalent == NavigationCode.GAMEPAD_B ||
					 details.code == KeyCode.ENTER ||
					 details.code == KeyCode.ESCAPE ||
					 details.navEquivalent == NavigationCode.GAMEPAD_A ||
					 details.code == KeyCode.F ||
					(isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X) ||	// X on switch
					(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y)))	// Y on other platforms
				{
					if(details.code != KeyCode.SPACE || details.navEquivalent != NavigationCode.GAMEPAD_A) 
					{
						//#LT Note: event dispatching is handled internally in the BasePopup, and then the recommended action is taken in WS
						//#LT that is not true, it may happen that the event dispatching is not handled, so triggering it twice
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnInputHandled', [details.navEquivalent, (uint)(details.code), 0] ) ); //actionId is not properly readable from here, but should not matter either
						mcCustomDialogMarketing.visible = false;
						showNextPopup();
					}
				}
				event.handled = true;
				return;
			}

			if (mcCustomDialogLicenseAgreement != null && mcCustomDialogLicenseAgreement.visible)
			{
				if (keyUp && mcCustomDialogLicenseAgreement.hasScrolledDownFully()
				&& (details.code == KeyCode.ENTER || details.navEquivalent == NavigationCode.GAMEPAD_A))
				{
					//#LT Note: event dispatching is handled internally in the BasePopup, and then the recommended action is taken in WS
					mcCustomDialogLicenseAgreement.visible = false;
					mcCustomDialogLicenseAgreement.tryAcceptFromOutside();
					showNextPopup();
				}
				else if (keyUp && mcCustomDialogLicenseAgreement.hasScrolledDownFully()
				&& (details.navEquivalent == NavigationCode.GAMEPAD_B || details.code == KeyCode.ESCAPE))
				{
					//#LT: maybe do something?? shake screen, reinitalize this window, whatever?
				}
				event.handled = true;
				return;
			}

			if (mcCustomDialogReminder != null && mcCustomDialogReminder.visible)
			{
				if (keyUp && (details.code == KeyCode.ESCAPE || details.navEquivalent == NavigationCode.GAMEPAD_B))
				{
					GalaxyQRSignInCancel();
					showNextPopup();
				}
				event.handled = true;
				return;
			}

			if (mcCustomDialogMod != null && mcCustomDialogMod.visible)
			{
				if (keyUp &&
					(details.navEquivalent == NavigationCode.GAMEPAD_B ||
					details.code == KeyCode.SPACE ||
					details.code == KeyCode.ESCAPE ||
					details.navEquivalent == NavigationCode.GAMEPAD_A ||
					details.code == KeyCode.E))
				{
					// This is super stupid, does this condition do anything at all??
					if(details.code != KeyCode.SPACE || (details.navEquivalent != NavigationCode.GAMEPAD_A && details.navEquivalent != NavigationCode.GAMEPAD_X)) 
					{
						//#LT Note: event dispatching is handled internally in the BasePopup, and then the recommended action is taken in WS
						mcCustomDialogMod.visible = false;
						showNextPopup();
					}
				}
				event.handled = true;
				return;
			}
			
			if ( mcMyRewardsPanel != null && mcMyRewardsPanel.visible )
			{
				mcMyRewardsPanel.handleInputNavigate(event);

				event.handled = true;
				return;
			}
			
			if (mcCloudSavesModalDialog != null && mcCloudSavesModalDialog.visible) 
			{
				if (keyUp && (details.navEquivalent == NavigationCode.GAMEPAD_A || details.code == KeyCode.ENTER))
				{
					mcCloudSavesModalDialog.visible = false;
					mcInputFeedbackModule.setVisibility(true);
					showNextPopup();
				}

				if (keyUp &&
					(details.code == KeyCode.Q ||
					(isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y) ||		// Y on switch
					(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X)))		// X on other platforms
				{
					mcCloudSavesModalDialog.visible = false;
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnGalaxyUnlinkAccounts" ) );
					handleNavigateBack();
					mcInputFeedbackModule.setVisibility(true);
				}
				event.handled = true;
				return;
			}
						
			if (details.navEquivalent == NavigationCode.GAMEPAD_A && details.code == KeyCode.SPACE) // Not sure why space == gamepad_a but we certainly dont want it in this menu TTP#117983
			{
				details.navEquivalent = "";
			}
			
			if ( keyUp && !event.handled) // #B for debug only
			{
				if (details.code == KeyCode.E)
				{
					if (!inPanel)
					{
						event.handled = true;
						activateMenuListItem();
					}
				}
				else
				{
					switch(details.navEquivalent)
					{
						case NavigationCode.GAMEPAD_A :
							if (!inPanel)
							{
								event.handled = true;
								activateMenuListItem();
							}
						break;
						case NavigationCode.GAMEPAD_B :
							if (!inPanel && details.code)
							{
								if (handleNavigateBack())
								{
									event.handled = true;
								}
								else if (!_isMainMenu)
								{
									hideAnimation();
									event.handled = true;
									event.stopImmediatePropagation();
								}
							}
						break;
						case NavigationCode.GAMEPAD_Y:
							if( _platform == PlatformType.PLATFORM_XBOX1 && _isMainMenu )
							{
								dispatchEvent( new GameEvent( GameEvent.CALL, 'OnProfileChange', [] ) );
							}
						break;
					}
				}
			}
			
			if (!inPanel)
			{
				if ( mcAccountButtonPanel && mcAccountButtonPanel.visible && mcAccountButtonPanel.handleInputNavigate( event ) )
				{
					trace( "IngameMenu::handleInputNavigate mcAccountButtonPanel handled event : ", inPanel, event );
					handleAccountButtonClickOrTap();
				}

				//Menu navigation
				menuListModule.mcList.handleInput(event);
			}
			else
			{
				mcKeyBindModule.handleInputNavigate(event);
				mcOptionListModule.handleInputNavigate(event);
				mcSaveSlotListModule.handleInputNavigate(event);
				mcGameMappingModule.handleInputNavigate(event);
				mcGammaModule.handleInputNavigate(event);
				mcHelpModule.handleInputNavigate(event);
				mcUIRescaleModule.handleInputNavigate(event);
				mcInstalledDLCModule.handleInputNavigate(event);
			}
		}		

		public function updateSwitchHoldMode( currentmode : int)
		{
			if(mcSwitchHoldMode)
			{
				switch(currentmode)
				{
					// OunceGamepadStyle_FullKey = 1 pro contorller
					case 1:
						mcSwitchHoldMode.htmlText = "[[menu_panel_console_playstyle_procontroller]]";
						mcSwitchHoldMode.gotoAndStop(10);
						break;
					// OunceGamepadStyle_Handheld = 2
					case 2:
						mcSwitchHoldMode.htmlText = "[[menu_panel_console_playstyle_handheld]]";
						mcSwitchHoldMode.gotoAndStop(1);
						break;
					// OunceGamepadStyle_JoyDual = 3 DualGrip
					case 3:
						mcSwitchHoldMode.htmlText = "[[menu_panel_console_playstyle_dualgrip]]";
						mcSwitchHoldMode.gotoAndStop(5);
						break;
					// OunceGamepadStyle_Mouser = 4
					case 4:
						mcSwitchHoldMode.htmlText = "[[menu_panel_console_playstyle_mousesensor]]";
						mcSwitchHoldMode.gotoAndStop(15);
						break;
				}
			}
		}

		protected function handleOptionsSet(data:Array):void
		{
			var i:int;
			var currentObject:Object;
			
			for (i = 0; i < rootData.length; ++i)
			{
				currentObject = rootData[i];
				
				if (currentObject.type == IGMActionType_Options)
				{
					currentObject.subElements = data;
					break;
				}
			}
			
			refreshRootData();
			
			inPanel = false;
			previousEntries.push(menuListModule.mcList.dataProvider);
			previousContainers.push(currentObject);
			previousSelections.push(menuListModule.mcList.selectedIndex);
			
			if (!inPanel)
			{
				menuListModule.titleText = currentObject.listTitle;
			}
			setListData(new DataProvider(currentObject.subElements));
			
			mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_common_select]]", true);
			mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", true);
			if (mcBlackBackground) { mcBlackBackground.backgroundVisible = false; }
		}
		
		public function forceEnterCurrentEntry():void
		{
			var renderer : BaseListItem =  menuListModule.mcList.getRendererAt(menuListModule.mcList.selectedIndex) as BaseListItem;
			
			if (renderer)
			{
				if (inPanel)
				{
					handleNavigateBack(); 
				}
				
				storeCurrentMenuState(renderer.data, false);
				if(renderer.data.subElements && renderer.data.subElements.length > 0 && renderer.data.subElements[0].id == "mainmenu_BardsBallad")
					setListData(new DataProvider(renderer.data.subElements), 1);
				else
					setListData(new DataProvider(renderer.data.subElements), (renderer.data.id == "NewGame") ? 1 : 0);
				
				mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_common_select]]", true);
				mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", true);
				if (mcBlackBackground) { mcBlackBackground.backgroundVisible = false; }
			}
		}
		
		protected function handleEntrySelected(l_data:Object):Boolean
		{
			if( l_data.type == IGMActionType_Save )
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnShowSaveGameMenu' ) );
			}
			else
			if( l_data.type == IGMActionType_Load )
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnShowLoadGameMenu' ) );
			}

			switch (l_data.type)
			{
			case IGMActionType_Back:
				{
					handleNavigateBack();
					return true;
				}
				break;
			case IGMActionType_Options:
				// This system is an optimization to NOT send all the options data since most of the time the user may never enter this menu and it is quite costly performance wise
				if ( _platform == PlatformType.PLATFORM_SWITCH2 )
				{
					if (mcSwitchHoldMode)
					{
						mcSwitchHoldMode.visible = true;
					}
				}
				if (!l_data.subElements || l_data.subElements.length == 0)
				{
					return false;
				}		
				break;				
			case IGMActionType_MenuHolder:
				storeCurrentMenuState(l_data, false);
				if(l_data.subElements && l_data.subElements.length > 0 && l_data.subElements[0].id == "mainmenu_BardsBallad")
					setListData(new DataProvider(l_data.subElements), 1);
				else
					setListData(new DataProvider(l_data.subElements), (l_data.id == "NewGame") ? 1 : 0);
				
				mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_common_select]]", true);
				mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", true);
				if (mcBlackBackground) { mcBlackBackground.backgroundVisible = false; }
				
				return false;
			case IGMActionType_MenuLastHolder:
				if (l_data.subElements[0].type == IGMActionType_Gamma)
				{
					storeCurrentMenuState(l_data, true);
					if(mcInputBackground){mcInputBackground.visible = false;}
					if(menuListModule){menuListModule.visible = false;}
					if (mcBlackBackground) { mcBlackBackground.backgroundVisible = true; }
					
					mcInputFeedbackModule.removeButton(ACTION_USE);
					//mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_RSTICK_TAB, -1, "[[panel_common_toggle_filters]]", true);
					mcInputFeedbackModule.appendButton(ACTION_SCROLL, NavigationCode.GAMEPAD_L3, -1, "[[panel_button_common_navigation]]", true);
					mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", true);
					//mcInputFeedbackModule.removeButton(ACTION_SCROLL, true);
					
					mcGammaModule.showWithData(l_data.subElements[0]);
					return false;
				}
				else
				{
					storeCurrentMenuState(l_data, true);

					showBardsBalladTooltip(l_data.id == "option_accessibility");
					
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnItemActivated', [l_data.type, l_data.tag] ) );
					
					mcOptionListModule.showWithData(l_data.subElements);
					mcInputFeedbackModule.removeButton(ACTION_USE);
					//mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_RSTICK_TAB, -1, "[[panel_common_toggle_filters]]", true);
					mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", true);
					
					if (mcBlackBackground) { mcBlackBackground.backgroundVisible = true; }

					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnShowOptionSubmenu', [l_data.type, l_data.tag, l_data.id] ) );
					
					return true;
				}
				
				return false;
			case IGMActionType_Close:
				hideAnimation();
				return false;
			case IGMActionType_KeyBinds:
				mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", true);
				storeCurrentMenuState(l_data, true);
				if (mcBlackBackground) { mcBlackBackground.backgroundVisible = true; }
				return false;
			case IGMActionType_ControllerHelp:
				mcInputFeedbackModule.removeButton(ACTION_USE, true);
				mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", true);
				storeCurrentMenuState(l_data, true);
				if (mcBlackBackground) { mcBlackBackground.backgroundVisible = true; }
				return false;

			case IGMActionType_Save:
			case IGMActionType_Load:
			case IGMActionType_Help:
			case IGMActionType_ImportSave:
			case IGMActionType_UIRescale:
			case IGMActionType_NewGamePlus:
			case IGMActionType_InstalledDLC:
				storeCurrentMenuState(l_data, true);
				if (mcBlackBackground) { mcBlackBackground.backgroundVisible = (l_data.type != IGMActionType_UIRescale); }
				return false; // Send this event to WS so it can auto send save information
				
			case IGMActionType_ToggleRender:
				return false;
			}
			
			return false;
		}
		
		protected function storeCurrentMenuState(l_data:Object, param_inPanel:Boolean):void
		{		
			inPanel = param_inPanel;
			previousEntries.push(menuListModule.mcList.dataProvider);
			previousContainers.push(l_data);
			previousSelections.push(menuListModule.mcList.selectedIndex);
			
			if (!inPanel)
			{
				menuListModule.titleText = l_data.listTitle;
			}
		}
		
		protected function onStageClicked(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				if (!_isMainMenu && (previousContainers.length == 0 || _panelMode))
				{
					closeMenu();
				}
				else if (!inPanel)
				{
					handleNavigateBack();
				}
				else
				{
					if (mcOptionListModule) { mcOptionListModule.onRightClick(event); }
					if (mcSaveSlotListModule) { mcSaveSlotListModule.onRightClick(event); }
					if (mcGameMappingModule) { mcGameMappingModule.onRightClick(event); }
					if (mcGammaModule) { mcGammaModule.onRightClick(event); }
					if (mcKeyBindModule) { mcKeyBindModule.onRightClick(event); }
					if (mcInstalledDLCModule) { mcInstalledDLCModule.onRightClick(event); }
					if (mcHelpModule) { mcHelpModule.onRightClick(event); }
					if (mcUIRescaleModule) { mcUIRescaleModule.onRightClick(event); }
				}
			}
			
			if (mcKeyBindModule) { mcKeyBindModule.onMouseClick(event); }
		}
		
		protected function handleClosePressed( event : ButtonEvent ) : void
		{
			if (inPanel)
			{
				if (mcOptionListModule.visible)
				{
					mcOptionListModule.handleNavigateBack();
				}
				else
				{
					handleNavigateBack();
				}
			}
		}
		
		public function handleNavigateBack():Boolean
		{
			if (mcOptionListModule && mcOptionListModule.visible)
			{
				dispatchEvent(new GameEvent( GameEvent.CALL, 'OnOptionPanelNavigateBack') );
			}
			
			if (menuListModule) { menuListModule.visible = true; }
			if (mcInputBackground) { mcInputBackground.visible = true; }
			
			if (mcOptionListModule) { mcOptionListModule.hide(); }
			if (mcSaveSlotListModule) { mcSaveSlotListModule.hide(); }
			if (mcGameMappingModule) { mcGameMappingModule.hide(); }
			if (mcGammaModule) { mcGammaModule.hide(); }
			if (mcKeyBindModule) { mcKeyBindModule.hide(); }
			if (mcInstalledDLCModule) { mcInstalledDLCModule.hide(); }
			if (mcHelpModule) { mcHelpModule.hide(); }
			if (mcUIRescaleModule) { mcUIRescaleModule.hide(); }
			//if (switchFeaturesPopUp) { switchFeaturesPopUp.closeSwitchFeaturePopUpMenu(); }
			
			SetCloudSaveVisibility(false);
			
			if (_panelMode)
			{
				//hideAnimation();
				stage.visible = false;
				closeMenu();
				
				return true;
			}
			
			if (previousContainers.length > 0)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnNavigatedBack" ) );
				
				var prevEntry:DataProvider = previousEntries[previousEntries.length - 1];
				var prevSelection:int = previousSelections[previousSelections.length - 1];
				
				previousEntries.pop();
				previousSelections.pop();
				
				setListData(prevEntry, prevSelection);
				
				mcInputFeedbackModule.removeButton(ACTION_DOWNLOAD, false);
				mcInputFeedbackModule.removeButton(ACTION_X, true);
				
				previousContainers.pop();
				if (previousContainers.length > 0)
				{
					menuListModule.titleText = previousContainers[previousContainers.length - 1].listTitle;
					mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", false);
					mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_common_select]]", true);
				}
				else
				{
					if ( _platform == PlatformType.PLATFORM_SWITCH2 && mcSwitchHoldMode )
					{
						mcSwitchHoldMode.visible = false;
					}

					menuListModule.titleText = "";
					if (mcBlackBackground) { mcBlackBackground.backgroundVisible = false; }
					if (!_isMainMenu)
					{
						mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_button_common_exit]]", false);
					}
					else
					{
						mcInputFeedbackModule.removeButton(ACTION_CLOSE);
					}
					mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_common_select]]", true);
				}
				
				mcInputFeedbackModule.appendButton(ACTION_SCROLL, NavigationCode.GAMEPAD_L3, -1, "[[panel_button_common_navigation]]", false);
				mcInputFeedbackModule.removeButton(ACTION_X, true)
				
				inPanel = false;
				
				//if (previousContainers.length > 0)
				//{
					if (mcBlackBackground) { mcBlackBackground.backgroundVisible = false; }
				//}
				
				return true;
			}
			return false;
		}
		
		public function updateOptionValue(tag:uint, value:String) : void
		{
			var targetData : Object = null;
			var i : int;
			var currentData : Object;
			
			currentData = findOptionDataRecursive(tag, rootData);
			
			if (currentData != null)
			{
				currentData.current = value;
				currentData.startingValue = value;
			}
		}
		
		public function updateOptionLabel(tag:uint, value:String) : void
		{
			var targetData : Object = null;
			var i : int;
			var currentData : Object;
			
			currentData = findOptionDataRecursive(tag, rootData);
			
			if (currentData != null)
			{				
				currentData.label = value;				
				menuListModule.updateSelectedItemText(value);
			}
		}
		
		private function findOptionDataRecursive(tag:uint, parent:Object) : Object
		{
			var i :int;
			var currentData : Object;
			var foundData : Object;
			var dataArray : Array;
			
			if (parent is Array)
			{
				dataArray = parent as Array;
			}
			else if (parent != null && parent.hasOwnProperty("tag"))
			{
				if (parent.tag == tag)
				{
					return parent;
				}
				
				dataArray = parent.subElements as Array;
			}
			else
			{
				return null;
			}
			
			if (dataArray != null)
			{
				for ( i = 0; i < dataArray.length; ++i)
				{
					foundData = findOptionDataRecursive(tag, dataArray[i]);
					if (foundData != null)
					{
						return foundData;
					}
				}
			}
			
			return null;
		}
		
		public function setIsMainMenu(value:Boolean):void
		{
			trace( "IngameMenu::setIsMainMenu : ", value );

			if ( mcAccountButtonPanel ) mcAccountButtonPanel.visible = value;
			if ( mcUserNamePanel )
			{
				mcUserNamePanel.setIsMainMenu( value );
			} 

			_isMainMenu = value;
			if (!_isMainMenu)
			{
				mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_button_common_exit]]", true);
			}
			else
			{
				if ( _platform == PlatformType.PLATFORM_XBOX1 )
				{
					mcInputFeedbackModule.appendButton(ACTION_Y, NavigationCode.GAMEPAD_Y, -1, "[[panel_button_common_choose_profile]]", true);
				}
				mcInputFeedbackModule.removeButton(ACTION_CLOSE);
			}
		}

		protected function handlePanelClosed(event:Event):void
		{
			handleNavigateBack();
		}
		
		protected function handleGamepadInfoRecieved(data:Array):void
		{
			if (mcGameMappingModule)
			{
				mcGameMappingModule.showWithData(data, _platform);
			}
			else
			{
				handleNavigateBack(); // #J fallback in case data was not received properly as planned
			}
		}
		
		public function getDeleteSaveString() : String
		{
			if (_isPlatformPlayStation)
			{
				return "[[panel_mainmenu_deletesave_ps4]]";
			}
			else if (_isPlatformXBox)
			{
				return "[[panel_mainmenu_deletesave_x1]]";
			}
			
			return "[[panel_mainmenu_deletesave]]";
		}
		
		protected function handleRecievedLoadSlots(data:Array):void
		{
			if (mcSaveSlotListModule && data.length > 0)
			{
				if (mcBlackBackground) { mcBlackBackground.backgroundVisible = true; }
				mcSaveSlotListModule.showWithData(data, SaveSlotListModule.SLOT_MODE_LOAD);
				mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_mainmenu_loadgame]]", false);
				mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", true);
				if (data[0].id != "EMPTY" && data[0].cloudStatus != CST_CLOUD)
				{
					var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
					mcInputFeedbackModule.appendButton(ACTION_X, isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X, KeyCode.DELETE, getDeleteSaveString(), true);
				}
				SetCloudSaveVisibility( true );
			}
			else
			{
				handleNavigateBack(); // #J fallback in case data was not received properly as planned
			}
		}
		
		protected function handleRecievedSaveSlots(data:Array):void
		{
			if (mcSaveSlotListModule && data.length > 0)
			{
				if (mcBlackBackground) { mcBlackBackground.backgroundVisible = true; }
				mcSaveSlotListModule.showWithData(data, SaveSlotListModule.SLOT_MODE_SAVES);
				
				if (_isPlatformXBox)
				{
					mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_mainmenu_savegame_x1]]", false);
				}
				else if (_isPlatformPlayStation)
				{
					mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_mainmenu_savegame_ps4]]", false);
				}
				else
				{
					mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_mainmenu_savegame]]", false);
				}
				
				mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", true);
				if (data.length > 1 && data[0].id != "EMPTY" && data[0].cloudStatus != CST_CLOUD)
				{
					var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
					mcInputFeedbackModule.appendButton(ACTION_X, isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X, KeyCode.DELETE, getDeleteSaveString(), true);
				}
				else
				{
					mcInputFeedbackModule.removeButton(ACTION_X, true);
				}
				SetCloudSaveVisibility( true );
			}
			else
			{
				handleNavigateBack(); // #J fallback in case data was not received properly as planned
			}
		}
		
		protected function handleReceivedImportSlots(data:Array):void
		{
			if (mcSaveSlotListModule && data.length > 0)
			{
				if (mcBlackBackground) { mcBlackBackground.backgroundVisible = true; }
				mcSaveSlotListModule.showWithData(data, SaveSlotListModule.SLOT_MODE_IMPORT);
				mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_common_select]]", false);
				mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", true);
			}
			else
			{
				handleNavigateBack(); // #J fallback in case data was not received properly as planned
			}
		}
		
		protected function handleReceivedNewGamePlusSlots(data:Array):void
		{
			if (mcSaveSlotListModule && data.length > 0)
			{
				if (mcBlackBackground) { mcBlackBackground.backgroundVisible = true; }
				mcSaveSlotListModule.showWithData(data, SaveSlotListModule.SLOT_MODE_NEWGAME_PLUS);
				mcInputFeedbackModule.appendButton(ACTION_USE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_common_select]]", false);
				mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", true);
			}
			else
			{
				handleNavigateBack(); // #J fallback in case data was not received properly as planned
			}
		}
		
		protected function handleSetUIRescale(object:Object):void
		{
			if (mcUIRescaleModule)
			{
				if (mcBlackBackground) { mcBlackBackground.backgroundVisible = false; }
				mcUIRescaleModule.show(object);
				mcInputFeedbackModule.removeButton(ACTION_USE, true);
				mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", true);
			}
			else
			{
				handleNavigateBack(); // #J fallback in case data was not received properly as planned
			}
		}
		
		protected function handleKeybindValuesSet(array:Array):void
		{
			mcKeyBindModule.showWithData(array);
		}
		
		protected function handleInstalledDLCsSet(array:Array):void
		{
			mcInstalledDLCModule.showWithData(array);
			mcInputFeedbackModule.removeButton(ACTION_USE, true);
			
			if (array.length < 2)
			{
				mcInputFeedbackModule.removeButton(ACTION_SCROLL, true);
			}
		}
		
		public function showHelpPanel():void
		{
			if (mcBlackBackground) { mcBlackBackground.backgroundVisible = true; }
			mcHelpModule.show();
			mcInputFeedbackModule.removeButton(ACTION_USE, true);
			mcInputFeedbackModule.appendButton(ACTION_CLOSE, NavigationCode.GAMEPAD_B, -1, "[[panel_mainmenu_back]]", true);
		}
		
		protected function onSaveSlotSelected( event:ListEvent ):void
		{
			if (mcSaveSlotListModule.slotMode != SaveSlotListModule.SLOT_MODE_IMPORT)
			{
				var item:SaveSlotItemRenderer = mcSaveSlotListModule.mcScrollingList.getSelectedRenderer() as SaveSlotItemRenderer;
				
				if (item && item.data)
				{
					if (item.data.tag == -1)
					{
						mcInputFeedbackModule.removeButton(ACTION_X, true);
					}
					else if (item.data.cloudStatus == CST_CLOUD) 
					{
						// WW-7673 hide deletion hint for cloud only save
						mcInputFeedbackModule.removeButton(ACTION_X, true);
					}
					else if (mcSaveSlotListModule.slotMode != SaveSlotListModule.SLOT_MODE_NEWGAME_PLUS)
					{
						var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
						mcInputFeedbackModule.appendButton(ACTION_X, isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X, KeyCode.DELETE, getDeleteSaveString(), true);
					}
				}
			}
		}
		
		public function updateSaveSlot():void
		{
			var timer: Timer = new Timer(200, 1);
			timer.addEventListener(TimerEvent.TIMER, function(e: TimerEvent):void { if(mcSaveSlotListModule.enabled) onSaveSlotSelected(null); });
			timer.start();
		}
		
		public function onSaveScreenshotLoaded():void
		{
			mcSaveSlotListModule.onLoadingScreenshotComplete();	
		}

		public function onSetModioBorderVisibility(value:Boolean):void
		{
			mcSaveSlotListModule.onSetModioBorderVisibility(value);
		}
		
		public function setGameLogoLanguage(  language : String ) : void
		{
			if ( menuListModule )
			{
				menuListModule.setGameLogoLanguage( language );
			}
			
			if (mcCustomDialogEp1)
			{
				var heartsOfStoneImagePopup:MovieClip = mcCustomDialogEp1.getChildByName("HeartsOfStoneImg") as MovieClip;
				if (heartsOfStoneImagePopup)
				{
					heartsOfStoneImagePopup.gotoAndStop(language);
				}
			}

			if (mcCustomDialogEp2)
			{
				var bloodAndWineImagePopup:MovieClip = mcCustomDialogEp2.getChildByName("BloodAndWineImg") as MovieClip;
				if (bloodAndWineImagePopup)
				{
					bloodAndWineImagePopup.gotoAndStop(language);
				}
			}

			// is there any picture to localize?
			/*
			if (mcCustomDialogGOTY)
			{
				var gotyImagePopup:MovieClip = mcCustomDialogGOTY.getChildByName("GOTYImg") as MovieClip;
				if (gotyImagePopup)
				{
					gotyImagePopup.gotoAndStop(language);
				}
			}
			*/
		}
		
		protected var _lastSetShowPresetInputFeedback:Boolean = false;
		public function showApplyPresetInputFeedback(show:Boolean):void
		{
			if (_lastSetShowPresetInputFeedback == show)
			{
				return;
			}
			
			_lastSetShowPresetInputFeedback = show;
			
			if (show)
			{
				mcInputFeedbackModule.appendButton(ACTION_APPLY_PRESET, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_common_apply]]", true);
			}
			else
			{
				mcInputFeedbackModule.removeButton(ACTION_APPLY_PRESET, true);
			}
		}
		
		protected function handleOptionPresetChanged(optionsToUpdate:Object):void
		{
			var optionsRoot:Object;
			var targetOptionParent:Object;
			var currentObject:Object;
			var targetPresetID:uint = optionsToUpdate.presetGroupID;
			var optionsToChange:Array = optionsToUpdate.optionList as Array;
			var curOptionToChange:Object;
			var toChangeIter:int;
			var curSubElementIter:int;
			
			// Search for the option list that needs to be updated (data wise)
			// {
			trace("GFX ----- Searching for Options root");
			for (var i:int = 0; i < rootData.length; ++i)
			{
				currentObject = rootData[i];
				
				if (currentObject.type == IGMActionType_Options)
				{
					optionsRoot = currentObject;
					break;
				}
			}
			
			if (optionsRoot)
			{
				trace("GFX ---------------------------- Starting recursive search for proper option branch to update ----------------------------");
				targetOptionParent = searchForPresetRecursive(optionsRoot, targetPresetID);
			}
			else
			{
				trace("GFX --- :( failed to find options root");
			}
			// }
			
			// Update the actual data directly
			// {
			if (targetOptionParent)
			{
				trace("GFX --- YAY found target branch, updating values -------------------------------------");
				for (toChangeIter = 0; toChangeIter < optionsToChange.length; ++toChangeIter)
				{
					curOptionToChange = optionsToChange[toChangeIter];
					trace("GFX ====== Searching for option: " + curOptionToChange.optionName + ", to update");
					for (curSubElementIter = 0; curSubElementIter < targetOptionParent.subElements.length; ++curSubElementIter)
					{
						currentObject = targetOptionParent.subElements[curSubElementIter];
						trace("GFX ========= Checking: " + currentObject + ", to see if it matches with tag: " + currentObject.tag);
						if (currentObject.tag == curOptionToChange.optionName)
						{
							currentObject.current = curOptionToChange.optionValue;
							currentObject.startingValue = curOptionToChange.optionValue;
							currentObject.skip = curOptionToChange.skip;
							currentObject.lock = curOptionToChange.lock;
							trace("GFX ============== Successfully updated option :D");
							break;
						}
					}
				}
			}
			else
			{
				trace("GFX --- :( failed to find proper target branch");
				return;
			}
			// }
			// If the currently visible option list is the one that was updated, make sure to update the visuals
			// {
			trace("GFX ---- Checking if we need to update the OptionListModule");
			if (previousContainers.length > 0 && mcOptionListModule.visible)
			{
				var currentContainer:Object = previousContainers[previousContainers.length - 1];
				var validContainer:Boolean = false;
				if (currentContainer)
				{
					for (curSubElementIter = 0; curSubElementIter < currentContainer.subElements.length; ++curSubElementIter)
					{
						currentObject = currentContainer.subElements[curSubElementIter];
						
						if (currentObject.id == "Presets" && currentObject.GroupName == targetPresetID)
						{
							validContainer = true;
							break;
						}
					}
					trace("GFX ---- Will proceed to update option list container: " + validContainer);
					
					if (validContainer)
					{
						mcOptionListModule.updateData(targetOptionParent.subElements as Array);
					}
				}
			}
			// }
		}
		
		protected function searchForPresetRecursive(currentObject:Object, targetGroupName:uint):Object
		{
			var result:Object;
			var iterObject:Object;
			var i:int = 0;
			
			if (currentObject && currentObject.subElements)
			{
				trace("GFX --------------------- Searching Recursively into: " + currentObject + ", with label: " + currentObject.label + ", and type: " + currentObject.type);
				for (i = 0; i < currentObject.subElements.length; ++i)
				{
					iterObject = currentObject.subElements[i];
					
					if (iterObject && iterObject.id == "Presets" && iterObject.GroupName == targetGroupName)
					{
						trace("GFX ----- OOOOOOOOHHHH yessesss");
						result = currentObject;
						break;
					}
					
					if (iterObject.id != "Presets" && !iterObject.hasOwnProperty("startingValue") && iterObject.hasOwnProperty("type") && (iterObject.type == IGMActionType_MenuHolder || iterObject.type == IGMActionType_MenuLastHolder))
					{
						result = searchForPresetRecursive(iterObject, targetGroupName);
					}
					
					if (result != null)
					{
						break;
					}
				}
			}
			
			return result;
		}
		
		override protected function onLastMoveStatusChanged()
		{
			if (menuListModule)
			{
				menuListModule.onLastMoveStatusChanged(_lastMoveWasMouse);
			}
			
			if (mcOptionListModule)
			{
				mcOptionListModule.lastMoveWasMouse = _lastMoveWasMouse;
			}
			
			if (mcKeyBindModule)
			{
				mcKeyBindModule.lastMoveWasMouse = _lastMoveWasMouse;
			}
			
			if (mcSaveSlotListModule)
			{
				mcSaveSlotListModule.lastMoveWasMouse = _lastMoveWasMouse;
			}
			
			if (mcInstalledDLCModule)
			{
				mcInstalledDLCModule.lastMoveWasMouse = _lastMoveWasMouse;
			}
		}
		
		public function UpdateAnchorsAspectRatio( screenWidth : int, screenHeight : int ):void
		{
			if ( !mcUIRescaleModule )
			{
				return;
			}

			var currentAspectRatio : int = AspectRatio.getCurrentAspectRatio( screenWidth, screenHeight );

			//////////////////
			//
			// uncomment to force 21:9 in editor
			//
			//currentAspectRatio = AspectRatio.ASPECT_RATIO_21_9;
			//
			//////////////////

			switch ( currentAspectRatio )
			{
				case AspectRatio.ASPECT_RATIO_DEFAULT:
				//case AspectRatio.ASPECT_RATIO_4_3:		// not implemented
				case AspectRatio.ASPECT_RATIO_21_9:
					mcUIRescaleModule.mcScaleFrame.gotoAndStop( currentAspectRatio );
					break;
				case AspectRatio.ASPECT_RATIO_UNDEFINED:
					break;
			}
		}

		public function showModdedTooltip( item:W3MenuListItemRenderer, show:Boolean )
		{
			if(show) {
				mcModdedTooltip.visible = true;
				mcModdedTooltip.x = menuListModule.x + item.x + item.width - 109; //<-- there is some offset from somewhere
				mcModdedTooltip.y = menuListModule.y + item.y + (item.height - mcModdedTooltip.height) / 2 - 4;
			}
			else
				mcModdedTooltip.visible = false;
		}

		public function /*WS*/ showModioLoadIndicator( value: Boolean )
		{
			mcLoadIndicator.visible = value;
		}

		private var logoLoadHandler			:	ModImageLoadHandler;
		public function callLogoLoad(loader:W3UILoader, modid:String, resolution:String = ModImageData.ORIGINAL)
		{
			trace("GFX ############ callLogoLoad");
			if(!logoLoadHandler) {
				logoLoadHandler = new ModImageLoadHandler();
				addChild(logoLoadHandler);
			}

			logoLoadHandler.addLoader(loader, modid, -1, resolution);
		}

		public function /*WitcherScript*/ handleImageLoaded(modid:String, resolution:String, caller:String, path:String, galleryIndex:int = -1 )
		{
			path = "img://" + path + ".modimg";

			if(caller == "logo") 
			{
				logoLoadHandler.onImageLoaded(modid, resolution, path);
			}
		}

		public function showBardsBalladTooltip(show:Boolean):void
		{
			cachedBalladTooltipVis = show;
			if(cachedBalladTooltipText.length == 0)
				show = false;
			mcOptionListModule.tooltip.visible = show;
		}

		public function /*WS*/ updateBardsBalladText(newText:String):void
		{
			cachedBalladTooltipText = newText;
			if (CoreComponent.isArabicAligmentMode)
			{
				mcOptionListModule.tooltip.textField.htmlText = "<p align=\"right\">" + newText + "</p>";
			}
			else
			{
				mcOptionListModule.tooltip.textField.htmlText = newText;
			}

			//Resizing
			mcOptionListModule.tooltip.mcFrame.height = mcOptionListModule.tooltip.textField.textHeight + BALLAD_TOOLTIP_TEXT_MARGIN * 2 + BALLAD_TOOLTIP_FRAME_EXTRA;
			mcOptionListModule.tooltip.textField.y = BALLAD_TOOLTIP_TEXT_MARGIN - 10; //originally placed 10 pixels below the frame start;

			showBardsBalladTooltip(cachedBalladTooltipVis);
		}

		public function showMyRewardsPanel( unlockedIds : Array ) : void
		{
			trace("IngameMenu::showMyRewardsPanel");

			showMainMenuButtonPanel( false );

			mcMyRewardsPanel.visible = true;
			mcMyRewardsPanel.setData( unlockedIds );
			mcMyRewardsPanel.addEventListener( MyRewardsPanel.EVENT_RESULT_CLOSE, handleMyRewardsResultAccept, false, 0, true );
			mcMyRewardsPanel.addEventListener( MyRewardsPanel.EVENT_RESULT_LOGOUT, handleMyRewardsResultLogOut, false, 0, true );
		}

		public function closeMyRewardsPanel( ) : void
		{
			trace("IngameMenu::closeMyRewardsPanel");

			mcMyRewardsPanel.removeEventListener( MyRewardsPanel.EVENT_RESULT_CLOSE, handleMyRewardsResultAccept, false );
			mcMyRewardsPanel.removeEventListener( MyRewardsPanel.EVENT_RESULT_LOGOUT, handleMyRewardsResultLogOut, false );
			mcMyRewardsPanel.visible = false;

			showMainMenuButtonPanel( true );
		}

		private function handleMyRewardsResultLogOut( ) : void
		{
			trace("IngameMenu::handleMyRewardsResultLogOut");

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnGalaxyUnlinkAccounts" ) );
			closeMyRewardsPanel( );
		}

		private function handleMyRewardsResultAccept( ) : void
		{
			trace("IngameMenu::handleMyRewardsResultAccept");

			closeMyRewardsPanel( );
		}

		private function handleAccountButtonClickOrTap( event : Event = null ) : void
		{
			trace( "IngameMenu::handleAccountButtonClickOrTap : ", event );

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnRedAccountButtonActivated" ) );
		}

		public function /*WitcherScript*/ showTelemetryDataRequestPopup( qrBufferId : String, description : String, url : String ) : void
		{
			trace( "IngameMenu::showTelemetryDataRequestPopup : ", url );
			mcOptionListModule.showTelemetryDataRequestPopup( qrBufferId, description, url );
		}
	}
}
