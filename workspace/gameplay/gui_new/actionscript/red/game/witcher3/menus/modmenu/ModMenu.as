/***********************************************************************
/** Mod Menu root object - Main control
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getTimer;

	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;

	import red.game.witcher3.controls.ConditionalCloseButton;
	import red.game.witcher3.controls.TabListItem;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.menus.common_menu.MenuHubTabListItem;
	import red.game.witcher3.menus.modmenu.ModMenuBrowsePage;
	import red.game.witcher3.menus.modmenu.ModMenuInstalledPage;

	public class ModMenu extends CoreMenu
	{
		// CONSTS
		private static const IFB_ACTIVATE:int = 100;
		private static const IFB_NAVIGATE:int = 101;
		private static const IFB_NEXT_MENU:int = 102;
		private static const IFB_PRIOR_MENU:int = 103;
		private static const IFB_CLOSE:int = 1001;
		private static const IFB_CLOSE_ALL:int = 10011;
		private static const IFB_MOD_DETAILS:int = 1100;
		private static const IFB_MOD_MORE:int = 1101;
		private static const IFB_SHOW_FILTERS:int = 1530;
		private static const IFB_HIDE_FILTERS:int = 1531;
		private static const IFB_SIGN_OUT:int = 2500;
		private static const IFB_BROWSE_INSTALL:int = 567;

		private static const LSTICK_HOLD_NEEDED:Number = 500; //in ms

		// ART CLIPS

		public var mcCloseBtn				:	ConditionalCloseButton;

		public var mcTabHolder				:	MovieClip;
		public var mcTabListItem1			:	MenuHubTabListItem;
		public var mcTabListItem2			:	MenuHubTabListItem;

		public var mcInputFeedback			:	ModuleInputFeedback;

		public var mcBrowsePage				: 	ModMenuBrowsePage;
		public var mcInstalledPage			:	ModMenuInstalledPage;
		
		public var mcLoadIndicatorSmall		:	MovieClip;
		public var mcModDetails				:	ModDetailsWindow;
		public var mcStorageIndicator		: 	ModMenuStorageIndicator;

		public var mcReportWindow			:	ModReportWindow;
		public var textInputManager			:	TextInputManager;

		public var mcSandwichPanel			:	MoreSandwichPanel;

		public var mcFogOfWar	: MovieClip;
		public var mcBlockAll : MovieClip;

		// VARS

		protected var _lastMouseOveredItem	:	MenuHubTabListItem;
		protected var currentTabName		:	String;

		private var currentTab 				:	UIComponent;
		private var logoLoadHandler			:	ModImageLoadHandler;
		private var galleryLoadHandler		:	ModImageLoadHandler;
		private var loadReasons				:	Vector.<String> = new Vector.<String>();
		private var installedOpenable		:	Boolean = true;

		private var lstickPressTime			: 	Number = 0;
		private var lstickPressedEnough		:	Boolean = false;

		private var ignoreInputForThisFrame : Boolean = false;

		override protected function get menuName():String { return "ModMenu"; }

		public function ModMenu()
		{
			_disableShowAnimation = true;
			super();
			_restrictDirectClosing = true;

			logoLoadHandler = new ModImageLoadHandler();
			addChild(logoLoadHandler);
			galleryLoadHandler = new ModImageLoadHandler();
			galleryLoadHandler.wsFunctionName = "OnRequestMediaGallery";
			addChild(galleryLoadHandler);
			ModStatics.setModMenu(this);
		}

		override protected function configUI():void
		{
			super.configUI();

			if (mcCloseBtn)
			{
				mcCloseBtn.addEventListener(ButtonEvent.PRESS, handleClosePressed, false, 0, true);
			}

			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.input.feedback.setup', [handleSetupBindings]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.setup', [initMenuTabs]));

			setupGeneralBindings();
			setupTabControlBindings();
			setupLogoutBinding();
			setupTabContainer();

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			mcLoadIndicatorSmall.visible = false;

			hidePages(false, true);
			mcModDetails.visible = false;
			mcReportWindow.visible = false;
			mcSandwichPanel.visible = false;
			openBrowsePage(false);

			mcBlockAll.mouseEnabled = true;
			mcBlockAll.visible = false;

			sendOverrideSortMaps();

			trace("GFX - ModMenu - Config UI successful");
		}

		public function /*WS*/ startLoadingIndicator(reason : String)
		{
			var reasons : String = "";
			for(var i : int = 0; i < loadReasons.length; i++)
			{
				if(i > 0)
					reasons += ", ";
				reasons += loadReasons[i];
			}
			//trace("GFX ########## loading indicator", reasons);
			mcLoadIndicatorSmall.visible = true;

			if(loadReasons.indexOf(reason) == -1)
				loadReasons.push(reason);
		}

		public function /*WS*/ stopLoadingIndicator(reason : String)
		{
			var index: int = loadReasons.indexOf(reason);

			if(index != -1)
				loadReasons.splice(index, 1);

			if(loadReasons.length == 0)
				mcLoadIndicatorSmall.visible = false;
		}

		public function /*WS*/ dropdownUnselect():void
		{
			mcBrowsePage.dropdownUnselect();
		}

		public function /*WS*/ updateStorageIndicator(used:String, available:String)
		{
			if(mcStorageIndicator)
				mcStorageIndicator.setStorage(used, available);
		}

		/////////////////////////////////////////////////////////////////////
		// TAB GENERATION - TAB LOGIC
		/////////////////////////////////////////////////////////////////////

		public function /*WS*/ setInstalledTabOpenable(value : Boolean):void
		{
			value = true; //simplest forcing it open!

			installedOpenable = value;
			if(!mcModDetails.visible)
				mcTabListItem2.enabled = installedOpenable;

			if(currentTab == mcInstalledPage && !value)
				openBrowsePage();

			if(!installedOpenable)
				clearTabControlBindings();
			else if (isFilterOpen())
				setupTabControlBindings();
		}

		public function getInstalledTabOpenable():Boolean
		{
			return installedOpenable;
		}

		public function isInputBeingBlocked():Boolean
		{
			return mcReportWindow.visible || mcSandwichPanel.visible;
		}

		public function isModOpen():Boolean
		{
			return mcModDetails.visible;
		}

		public function isFilterOpen():Boolean
		{
			var tab : UIComponent = getCurrentTab();

			if(tab is ModMenuBrowsePage)
				return mcBrowsePage.mcFilters.alpha > 0;
			else if(tab is ModMenuInstalledPage)
				return mcInstalledPage.mcFilters.alpha > 0;
			
			return false;
		}

		public function getCurrentTab():UIComponent
		{
			return currentTab;
		}

		public function initMenuTabs(nameList:Array):void
		{
			mcTabListItem1.setData(nameList[0]);
			mcTabListItem2.setData(nameList[1]);
			setInstalledTabOpenable(nameList[1].enabled);
			mcFogOfWar.visible = false;
		}

		protected function addToListContainer_Item(component:MovieClip):void
		{
			if (component)
			{
				component.addEventListener(MouseEvent.CLICK, onTabItemClicked, false, 0, true);
				component.addEventListener(MouseEvent.MOUSE_OVER, onTabItemMouseOver, false, 0, true);
				component.addEventListener(MouseEvent.MOUSE_OUT, onTabItemMouseOut, false, 0, true);
			}
			
			addToListContainer(component);
		}

		protected function addToListContainer(component:MovieClip):void
		{
			var xOffset:Number;
			var yOffset:Number;

			if (mcTabHolder && component)
			{
				xOffset = component.x - mcTabHolder.x;
				yOffset = component.y - mcTabHolder.y;

				mcTabHolder.addChild(component);

				component.x = xOffset;
				component.y = yOffset;
			}
		}

		protected function setupTabContainer():void
		{
			addToListContainer_Item(mcTabListItem1);
			addToListContainer_Item(mcTabListItem2);
			currentTabName = mcTabListItem1.name;
		}

		protected function hidePages( playAnimation : Boolean = true, force : Boolean = false)
		{
			if(mcBrowsePage.visible || force)
			{
				mcBrowsePage.deselect(playAnimation);
			}
			if(mcInstalledPage.visible || force)
			{
				mcInstalledPage.deselect(playAnimation);
			}
		}

		public function openBrowsePage( playAnimation : Boolean = true)
		{
			if(mcBrowsePage == currentTab)
				return;
			unselectTabButtons();
			mcTabListItem1.selected = true;
			currentTabName = mcTabListItem1.name;

			hidePages(playAnimation);
			mcBrowsePage.visible = true;
			mcBrowsePage.onSelect(playAnimation);
			currentTab = mcBrowsePage;

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnBrowseMenuOpen" ) );
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_panel_open"] ) );
		}

		public function openInstalledPage( playAnimation : Boolean = true)
		{
			if(mcInstalledPage == currentTab || !installedOpenable)
				return;
			unselectTabButtons();
			mcTabListItem2.selected = true;
			currentTabName = mcTabListItem2.name;

			hidePages(playAnimation);
			mcInstalledPage.visible = true;
			mcInstalledPage.onSelect(playAnimation);
			currentTab = mcInstalledPage;

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnInstalledMenuOpen" ) );
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_panel_open"] ) );
		}

		public function requestModDetails( modid:String, requester:MovieClip ):void
		{
			mcModDetails.visible = true;
			mcModDetails.setOrigin(requester);
			mcModDetails.onSelect();
			mcModDetails.startLoad();

			dispatchEvent(new GameEvent( GameEvent.CALL, 'OnRequestModDetails', [modid] ));
			clearTabControlBindings();
			clearLogoutBinding();
			mcInstalledPage.clearCheckboxHints();

		}

		public function /*WS*/ requestModDetailsFromDetails(modid:String):void
		{
			//mcModDetails.visible = true;
			//mcModDetails.onSelect();

			dispatchEvent(new GameEvent( GameEvent.CALL, 'OnRequestModDetails', [modid] ));
			//clearTabControlBindings();
			//clearLogoutBinding();
		}

		public function openSandwichPanel( data:Object ):void
		{
			mcSandwichPanel.setupButtons(data);
			mcSandwichPanel.visible = true;
			ignoreInputForThisFrame = true;
		}

		public function closeSandwichPanel():void
		{
			mcSandwichPanel.visible = false;
		}

		public function requestReportMod( modid:String, modName:String ):void
		{
			mcReportWindow.onSwapToThis(modid, modName);
			mcReportWindow.visible = true;
		}

		/////////////////////////////////////////////////////////////////////
		// INPUT HANDLING - NAVIGATION
		/////////////////////////////////////////////////////////////////////

		protected function sendOverrideSortMaps():void
		{
			var gpadSortMap : Vector.<String> = new Vector.<String>();
			var kbSortMap : Vector.<int> = new Vector.<int>();

			//first is more right!

			gpadSortMap.push(NavigationCode.GAMEPAD_BACK);
			gpadSortMap.push(NavigationCode.GAMEPAD_B);
			gpadSortMap.push(NavigationCode.GAMEPAD_RBLB);
			gpadSortMap.push(NavigationCode.GAMEPAD_RTLT);
			gpadSortMap.push(NavigationCode.GAMEPAD_R1);
			gpadSortMap.push(NavigationCode.GAMEPAD_L1);
			gpadSortMap.push(NavigationCode.GAMEPAD_R2);
			gpadSortMap.push(NavigationCode.GAMEPAD_L2);
			gpadSortMap.push(NavigationCode.GAMEPAD_R3);
			gpadSortMap.push(NavigationCode.GAMEPAD_L3);
			gpadSortMap.push(NavigationCode.GAMEPAD_RSTICK_HOLD);
			gpadSortMap.push(NavigationCode.GAMEPAD_RSTICK_SCROLL);
			gpadSortMap.push(NavigationCode.GAMEPAD_RSTICK_TAB);
			gpadSortMap.push(NavigationCode.GAMEPAD_LSTICK_HOLD);
			gpadSortMap.push(NavigationCode.GAMEPAD_LSTICK_SCROLL);
			gpadSortMap.push(NavigationCode.GAMEPAD_LSTICK_TAB);
			gpadSortMap.push(NavigationCode.DPAD_DOWN);
			gpadSortMap.push(NavigationCode.DPAD_RIGHT);
			gpadSortMap.push(NavigationCode.DPAD_LEFT);
			gpadSortMap.push(NavigationCode.DPAD_UP);
			gpadSortMap.push(NavigationCode.GAMEPAD_Y);
			gpadSortMap.push(NavigationCode.GAMEPAD_X);
			gpadSortMap.push(NavigationCode.GAMEPAD_A);
			gpadSortMap.push(NavigationCode.GAMEPAD_START);
			
			kbSortMap.push(KeyCode.ESCAPE);
			kbSortMap.push(KeyCode.SPACE);
			kbSortMap.push(KeyCode.ENTER);
			kbSortMap.push(KeyCode.PAGE_DOWN);
			kbSortMap.push(KeyCode.PAGE_UP);
			kbSortMap.push(KeyCode.TAB);
			kbSortMap.push(KeyCode.UP);
			kbSortMap.push(KeyCode.DOWN);
			kbSortMap.push(KeyCode.LEFT);
			kbSortMap.push(KeyCode.RIGHT);
			kbSortMap.push(KeyCode.R);
			kbSortMap.push(KeyCode.T);
			kbSortMap.push(KeyCode.F);
			kbSortMap.push(KeyCode.D);
			kbSortMap.push(KeyCode.A);
			kbSortMap.push(KeyCode.END)


			mcInputFeedback.overrideSortMaps(gpadSortMap, kbSortMap);
		}

		protected function handleSetupBindings(bindingsList:Object):void
		{
			mcInputFeedback.handleSetupButtons(bindingsList);
		}

		public var closePressed:Boolean = false;

		protected function handleClosePressed( event : ButtonEvent ) : void
		{
			tryAndNavigateBack();
		}

		override protected function handleInputNavigate(event:InputEvent):void
		{
			//trace("GFX - ModMenu - handleInputNavigate", event);
			var details:InputDetails = event.details;

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var hold:Boolean = details.value == InputValue.KEY_HOLD;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;

			if(ignoreInputForThisFrame)
			{
				ignoreInputForThisFrame = false;
				return;
			}

			if(isInputBeingBlocked())
			{
				if(mcReportWindow.visible)
					mcReportWindow.handleInput(event);
				else if (mcSandwichPanel.visible)
					mcSandwichPanel.handleInput(event);
				return;
			}

			if (!event.handled)
			{
				switch (details.navEquivalent)
				{
				case NavigationCode.GAMEPAD_L2:
					if(keyDown)
					{
						openPreviousTab();
						event.handled = true;
					}
					break;
				case NavigationCode.GAMEPAD_R2:
					if(keyDown)
					{
						openNextTab();
						event.handled = true;
					}
					break;
				case NavigationCode.GAMEPAD_B:
					if (details.code != KeyCode.ESCAPE)
					{
						if(keyUp && closePressed)
						{
							closePressed = false;
							tryAndNavigateBack();
							event.handled = true;
						}
						else if (keyDown)
						{
							closePressed = true;
						}
						else if (hold && closePressed)
						{
							closePressed = false;
							if(mcModDetails.visible)
								closeAllDetailsPages();
							event.handled = true;
						}
					}
					break;
				case NavigationCode.GAMEPAD_L3:
					if(keyUp)
					{
						onLogoutRequested();
						event.handled = true;
					}
				default:
					break;
				}
			}
			if (!event.handled)
			{
				if((details.code == KeyCode.TAB || details.code == KeyCode.NUMBER_1 || details.code == KeyCode.NUMBER_3) && keyUp)
				{
					openNextTab();
					event.handled = true;
				}
				/*else if (details.code == KeyCode.PAGE_DOWN)
				{
					openPreviousTab();
					event.handled = true;
				}*/
				else if (details.code == KeyCode.ESCAPE)
				{
					if(keyUp && closePressed)
					{
						closePressed = false;
						tryAndNavigateBack();
						event.handled = true;
					}
					else if (keyDown)
					{
						closePressed = true;
					}
					else if (hold && closePressed)
					{
						closePressed = false;
						if(mcModDetails.visible)
							closeAllDetailsPages();
						event.handled = true;
					}
				}
				else if (details.code == KeyCode.END && keyUp)
				{
					if(!mcModDetails.visible)
					{
						onLogoutRequested();
						event.handled = true;
					}
				}
			}
			if (!event.handled)
			{
				//trace("GFX - ModMenu - Unhandled input: NavEqv: " + details.navEquivalent + " | Code: " + details.code, details.ctrlKey, details.shiftKey, details.altKey);
				super.handleInputNavigate(event);
			}


		}

		protected function onLogoutRequested():void
		{
			dispatchEvent(new GameEvent( GameEvent.CALL, 'OnLogoutRequested') );
		}
		
		protected function openPreviousTab():void
		{
			// TODO make it actually circular

			if(isModOpen() || isInputBeingBlocked() || isFilterOpen())
				return;

			if( currentTabName == mcTabListItem1.name )
			{
				if(mcBrowsePage.getCurrentObj() != mcBrowsePage.mcPaginatorController)
					openInstalledPage();
			}
			else
			{
				openBrowsePage();
			}
				
		}

		protected function openNextTab():void
		{
			openPreviousTab();
		}

		public function /*WS*/ closeModDetails():void
		{
			mcModDetails.deselect();
		}

		protected function closeAllDetailsPages():void
		{
			dispatchEvent(new GameEvent( GameEvent.CALL, 'OnDetailsFullClose') );
			
			if(mcBrowsePage)
				mcBrowsePage.recalibratePaginatorBindings();
		}

		protected function tryAndNavigateBack():void
		{
			if(mcModDetails.visible) {
				dispatchEvent(new GameEvent( GameEvent.CALL, 'OnDetailsBack') );
			}
			else if(currentTab == mcBrowsePage && mcBrowsePage.isShowingFilters())
			{
				mcBrowsePage.onFilterToggle();
			}
			else if(currentTab == mcInstalledPage && mcInstalledPage.isShowingFilters())
			{
				mcInstalledPage.onFilterToggle();
			}
			else {
				dispatchEvent(new GameEvent( GameEvent.CALL, 'OnNavigatedBack') );
			}
		}

		protected function setupGeneralBindings():void
		{
			mcInputFeedback.appendButton(IFB_CLOSE, NavigationCode.GAMEPAD_B, KeyCode.ESCAPE, "[[panel_button_common_close]]", true);
			//trace("GFX - ModMenu - General Bindings setup!");
		}

		public function setupDetailsBindings():void
		{
			//panel_button_mods_close_all_details
			//trace("GFX - ModMenu - General Bindings setup!");
		}

		public function clearDetailsBindings():void
		{
			//trace("GFX - ModMenu - General Bindings setup!");
		}

		public function setupCloseAllBinding():void
		{
			//panel_button_mods_close_all_details
			mcInputFeedback.appendHoldButton(IFB_CLOSE_ALL, NavigationCode.GAMEPAD_B, KeyCode.ESCAPE, "[[panel_button_mods_close_all_details]]", true, 500);
			//trace("GFX - ModMenu - General Bindings setup!");
		}

		public function clearCloseAllBinding():void
		{
			mcInputFeedback.removeButton(IFB_CLOSE_ALL, false);
			//trace("GFX - ModMenu - General Bindings setup!");
		}

		 /*WS*/ public function enableCloseAllButton(value:Boolean):void
		 {
			if(value)
				setupCloseAllBinding();
			else 
				clearCloseAllBinding();
		 }

		public function clearTabControlBindings():void
		{
			//mcInputFeedback.removeButton(IFB_PRIOR_MENU, false);
			mcInputFeedback.removeButton(IFB_NEXT_MENU, true);
		}

		public function setupTabControlBindings():void
		{
			if(!installedOpenable || isFilterOpen())
				return;
			//mcInputFeedback.appendButton(IFB_PRIOR_MENU, NavigationCode.GAMEPAD_L2, KeyCode.PAGE_DOWN, "[[panel_mods_previous_tab]]", false);
			mcInputFeedback.appendButton(IFB_NEXT_MENU, NavigationCode.GAMEPAD_L2, KeyCode.TAB, "[[panel_mods_next_tab]]", true);
		}

		
		public function handleModListBindings():void
		{
			if(mcModDetails.visible && !mcModDetails.isMarkedForDetransition())
			{
				clearModListBindings();
				return;
			}

			var selectedMod : ModPreview = mcBrowsePage.getSelectedRenderer();
			if(selectedMod && selectedMod.isSubscribed())
				clearModListBindings();
			else
				setupModListBindings();
		}

		public function setupModListBindings():void
		{
			mcInputFeedback.appendButton(IFB_BROWSE_INSTALL, NavigationCode.GAMEPAD_A, KeyCode.SPACE, "[[panel_mods_subscribe]]", true);
		}

		public function clearModListBindings():void
		{
			mcInputFeedback.removeButton(IFB_BROWSE_INSTALL, true);
		}

		public function setupLogoutBinding():void
		{
			mcInputFeedback.appendButton(IFB_SIGN_OUT, NavigationCode.GAMEPAD_LSTICK_HOLD, KeyCode.END, "[[ui_gog_button_signout]]", false);
			//mcInputFeedback.setButtonOnlyHoldOnGamepad(IFB_SIGN_OUT, -1, true);
		}

		public function clearLogoutBinding():void
		{
			mcInputFeedback.removeButton(IFB_SIGN_OUT, true);
			//mcInputFeedback.removeButtonOnlyHoldOnGamepad(IFB_SIGN_OUT, -1, true);
		}

		public function setupDetailsButtonBinding():void
		{
			mcInputFeedback.appendButton(IFB_MOD_DETAILS, NavigationCode.GAMEPAD_START, KeyCode.T, "[[panel_mods_details]]", true);
		}

		public function clearDetailsButtonBinding():void
		{
			mcInputFeedback.removeButton(IFB_MOD_DETAILS, true);
		}

		public function setupModBindings():void
		{
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
			setupDetailsButtonBinding();
			mcInputFeedback.appendButton(IFB_MOD_MORE, isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, KeyCode.R, "[[panel_mods_more]]", true);
		}

		public function clearModBindings():void
		{
			clearDetailsButtonBinding();
			mcInputFeedback.removeButton(IFB_MOD_MORE, true);
		}

		public function setupShowFilterBindings():void
		{
			mcInputFeedback.appendButton(IFB_SHOW_FILTERS, NavigationCode.GAMEPAD_RSTICK_HOLD, KeyCode.F, "[[panel_mods_show_filters]]", true);
		}

		public function clearShowFilterBindings():void
		{
			mcInputFeedback.removeButton(IFB_SHOW_FILTERS, true);
		}

		public function setupHideFilterBindings():void
		{
			mcInputFeedback.appendButton(IFB_HIDE_FILTERS, NavigationCode.GAMEPAD_RSTICK_HOLD, KeyCode.F, "[[panel_mods_hide_filters]]", true);
		}

		public function clearHideFilterBindings():void
		{
			mcInputFeedback.removeButton(IFB_HIDE_FILTERS, true);
		}

		public function setupVoteFeedback():void
		{
			return; //<-- seems like we dont want them on the bottom bar?
			if(mcModDetails.visible)
				mcModDetails.setupVoteFeedback();
		}

		public function clearVoteFeedback():void
		{
			mcModDetails.clearVoteFeedback();
		}

		protected function onTabItemMouseOver(event:MouseEvent):void
		{
			_lastMouseOveredItem = event.currentTarget as MenuHubTabListItem;
			
			if (!InputManager.getInstance().isMouse() || !_lastMoveWasMouse)
			{
				return;
			}
			
			event.stopImmediatePropagation();
			var currentTarget:MenuHubTabListItem = event.currentTarget as MenuHubTabListItem;
			currentTarget.selected = true;
			
		}
		
		protected function onTabItemMouseOut(event:MouseEvent):void
		{
			_lastMouseOveredItem = null;

			var currentTarget:MenuHubTabListItem = event.currentTarget as MenuHubTabListItem;

			if(currentTarget.name == currentTabName) {
				currentTarget.selected = true;
			}
			else {
				currentTarget.selected = false;
			}
		}
		
		protected function onTabItemClicked(event:MouseEvent):void
		{
			if (!InputManager.getInstance().isMouse() || !_lastMoveWasMouse)
			{
				return;
			}
			if(isModOpen() || isInputBeingBlocked())
				return;
			
			event.stopImmediatePropagation();
			var currentTarget:MenuHubTabListItem = event.currentTarget as MenuHubTabListItem;
			if (currentTarget && currentTarget.visible)
			{
				unselectTabButtons();
				currentTarget.selected = true;
				currentTabName = currentTarget.name; // <-- hacky solution for storing the tab button that we are on
				if(currentTarget == mcTabListItem1)
				{
					openBrowsePage();
				}
				else 
				{
					openInstalledPage();
				}
			}
		}

		protected function unselectTabButtons()
		{
			mcTabListItem1.selected = false;
			mcTabListItem2.selected = false;
		}

		public function callLogoLoad(loader:W3UILoader, modid:String, resolution:String = ModImageData.ORIGINAL)
		{
			//trace("GFX ############ callLogoLoad");
			logoLoadHandler.addLoader(loader, modid, -1, resolution);
		}

		public function callGalleryLoad(loader:W3UILoader, modid:String, index: int, resolution:String = ModImageData.ORIGINAL)
		{
			//trace("GFX ############ callGalleryLoad");
			galleryLoadHandler.addLoader(loader, modid, index, resolution);
		}

		public function callLogoRemove(loader:W3UILoader)
		{
			logoLoadHandler.removeLoader(loader);
		}

		public function callGalleryRemove(loader:W3UILoader)
		{
			galleryLoadHandler.removeLoader(loader);
		}

		public function /*WitcherScript*/ handleImageLoaded(modid:String, resolution:String, caller:String, path:String, galleryIndex:int = -1 )
		{
			path = "img://" + path + ".modimg";

			if(caller == "logo") 
			{
				logoLoadHandler.onImageLoaded(modid, resolution, path);
			}
			else if(caller == "gallery")
			{
				galleryLoadHandler.onImageLoaded(modid, resolution, path, galleryIndex );
			}
		}

		public function  /* WitcherScript */ updateProgressBar(modid:String, stage:int, progress:Number):void
		{
			//trace("GFX - updateProgressBar", modid, stage, progress);
			mcBrowsePage.updateProgressBar(modid, stage, progress);
			mcModDetails.updateProgressBar(modid, stage, progress);
		}

		public function /*WitcherScript*/ closeReportWindow():void
		{
			mcReportWindow.onCloseFinalize();
		}


		//for wingdk blocking mouse movement affecting the ui when touching the vkb
		public function /*WitcherScript*/ blockAllMouse(value : Boolean):void
		{
			mcBlockAll.visible = value;
		}
	}
}