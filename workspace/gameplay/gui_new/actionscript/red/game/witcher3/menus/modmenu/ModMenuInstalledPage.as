/***********************************************************************
/** Mod Menu installed page
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import flash.text.TextField;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;

	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.core.constants.KeyCode;
	
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.controls.W3DropdownMenuListItem;
	import red.game.witcher3.data.KeyBindingData;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.DropdownListModuleBase;
	import red.game.witcher3.menus.modmenu.LibraryModDetails;
	import red.game.witcher3.menus.modmenu.LibraryModPreview;
	import red.game.witcher3.menus.modmenu.ModMenu;
	import red.game.witcher3.utils.CommonUtils;

	public class ModMenuInstalledPage extends UIComponent
	{
		// CONSTS
		private static const IFB_ENABLE_MOD:int = 1007;
		private static const IFB_DISABLE_MOD:int = 1008;
		private static const IFB_RESET_FILTERS:int = 2320;
		private static const IFB_APPLY_FILTERS:int = 2330;
		private static const IFB_ENTER_TEXT:int = 3000;
		private static const LIB_MOD_PREVIEW_GAP:int = 7;
		private static const MAX_RENDERERS = 7;

		private static const DOUBLE_CLICK_MS = 250;

		// ART CLIPS
		public var mcModPreview 			: LibraryModPreview;
		public var mcModDetails 			: LibraryModDetails;
		public var mcInstalledModlistBG		: MovieClip;
		public var mcLibModList				: W3ScrollingList;
		public var mcScrollbar 				: ScrollBar;
		public var mcLibModAnchor			: MovieClip;
		public var mcNoMods					: MovieClip;
		public var mcFilters				: MovieClip;
		public var inpSearchInput			: W3TextInput;
		public var mcMainListModule			: DropdownListModuleBase;

		public var mcInstalledModText		: TextField;
		//VARS

		protected var _lastMouseOveredItem:int = -1;
		public var _lastMoveWasMouse:Boolean = true;

		private var renderers : Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>();
		private var currentObj : MovieClip;
		private var _markedForDetransition:Boolean = false;

		private var _modListX : Number;
		private var _modListY : Number;

		private var clickCount:int = 0;

		private var showingFilters:Boolean = false;

		protected var   lastSelectedItem					: ModFilterItemRenderer;
		private var _lastSelectedDropdownIndex:int = -1;
		private var _lastSelectedDropdownSubindex:int = -1;
		private var lastDropdownElemIndex:int = 0;

		private var isAnyFilterApplied:Boolean = false;
		private var currentSortingType:int = 0;

		public function ModMenuInstalledPage() 
		{
			mouseEnabled = true;
			mouseChildren = true;
			_modListX = mcInstalledModlistBG.x;
			_modListY = mcInstalledModlistBG.y;
		}

		protected function get menuName():String { return "ModMenu"; }
		override protected function configUI():void
		{
			super.configUI();
			removeChild(mcModPreview);
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.installed.update_data', [updateData] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.installed.setup', [setupPage] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.installed.update_order', [onUpdateOrder] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.details.setup', [setupDetails] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.deselect.details', [onDeselectDetails] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.installed.select.mod.by.id', [onSelectModById] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.installed.select.mod.by.modid', [onSelectModByModid] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.filters.radio.clicked', [onRadioPressed] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.filters.updated', [onFiltersUpdated] ) );

			if (mcScrollbar)
			{
				mcScrollbar.addEventListener( Event.SCROLL, handleScroll, false, 1, true) ;
				mcInstalledModlistBG.addChild(mcScrollbar);
				mcScrollbar.x -= mcInstalledModlistBG.x;
				mcScrollbar.y -= mcInstalledModlistBG.y;
				mcInstalledModlistBG.addChild(mcNoMods);
				mcNoMods.x -= mcInstalledModlistBG.x;
				mcNoMods.y -= mcInstalledModlistBG.y;
				//removeChild(mcInstalledModText);
				//mcInstalledModlistBG.addChild(mcInstalledModText);
				//mcInstalledModText.x -= mcInstalledModlistBG.x;
				//mcInstalledModText.y -= mcInstalledModlistBG.y;
			}

			if(mcFilters)
			{
				mcFilters.x = -500;
				mcFilters.alpha = 0;
				//mcFilters.mcInputFeedback.mcInputBackground = mcFilters.mcInputBackground;
				mcFilters.mcInputFeedback.buttonAlign = "center";
				mcFilters.mcInputFeedback.appendButton(IFB_RESET_FILTERS, NavigationCode.GAMEPAD_L2, KeyCode.R, "[[panel_mods_reset_filters]]", true);
				mcFilters.mcInputFeedback.appendButton(IFB_APPLY_FILTERS, NavigationCode.GAMEPAD_R2, KeyCode.T, "[[panel_mods_apply_filters]]", true);
				mcFilters.mcShadow.visible = false;
				mcFilters.mcCloseHit.visible = false;
				mcFilters.mcCloseHit.addEventListener(MouseEvent.CLICK, function(e:MouseEvent){ swapCurrentObject(mcLibModList) }, false, -100);
				mcMainListModule = mcFilters.mcMainListModule;
				inpSearchInput = mcFilters.inpSearchInput;

				mcMainListModule.menuName = menuName;
				mcMainListModule.mcDropDownList.listHeight = 710;
				mcMainListModule.mcScrollBar.height = 710;
				mcMainListModule.mcDropDownList.menuName = menuName;
				mcMainListModule.mcDropDownList.UpdateEmptyStateFeedback(true);
				mcMainListModule.selectModuleOnClick = true;
				mcMainListModule.mcDropDownList.addEventListener(ListEvent.INDEX_CHANGE, handleSelectChange, false, 0 , true );
				mcMainListModule.mcDropDownList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, handleItemDoubleClick, false, 0, true );
				mcMainListModule.sortFunc = filterSortFunc;

				mcMainListModule.addEventListener(MouseEvent.CLICK, onModuleMouseClick, false, -100);
			}
			mcLibModList.addEventListener(ListEvent.INDEX_CHANGE, onOptionSelectionChanged);
			mcLibModList.addEventListener( ListEvent.ITEM_CLICK, onItemClicked, false, 0, true ); 
			mcLibModList.ShowRenderers(true);
			mcLibModList.scrollBar = mcScrollbar;
			mcLibModList.itemRendererName = "LibraryModPreview";

			mcModDetails.visible = false;
			//mcModDetails.active = false;
			mcModDetails.addEventListener(MouseEvent.CLICK, setActiveSubElement);
			mcLibModList.addEventListener(MouseEvent.CLICK, setActiveSubElement);

			stage.addEventListener(InputEvent.INPUT, handleInputNavigate, false, 10, true);

			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);

			if(inpSearchInput)
			{
				var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
				inpSearchInput.virtualKbKey = isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X;

				inpSearchInput.skipKeys.push(KeyCode.DOWN);
				inpSearchInput.skipKeys.push(KeyCode.UP);
				inpSearchInput.skipKeys.push(KeyCode.ENTER);
				inpSearchInput.skipKeys.push(KeyCode.ESCAPE);
				inpSearchInput.skipGamepadKeys.push(NavigationCode.GAMEPAD_L2);
				inpSearchInput.skipGamepadKeys.push(NavigationCode.GAMEPAD_R2);
				inpSearchInput.skipGamepadKeys.push(NavigationCode.GAMEPAD_B);
							
				inpSearchInput.addEventListener(MouseEvent.CLICK, onModuleMouseClick, false, -100);
				inpSearchInput.addEventListener(W3TextInputEvent.TEXT_CHANGED, sendSearchDataToWS, false, 0);
			}
		}

		protected function showFilters():void
		{
			if(showingFilters)
				return;

			mcFilters.mcShadow.visible = true;
			mcFilters.mcCloseHit.visible = true;

			if(mcFilters.mcInputBackground.width - 20 < mcFilters.mcInputFeedback.buttonsContainer.width)
			{
				mcFilters.mcInputBackground.width = mcFilters.mcInputFeedback.buttonsContainer.width + 20;
			}

			if(currentObj != mcMainListModule && currentObj != inpSearchInput)
				swapCurrentObject(mcMainListModule);

			ModMenu(parent).clearShowFilterBindings();
			ModMenu(parent).clearTabControlBindings();
			ModMenu(parent).clearModListBindings();
			ModMenu(parent).clearVoteFeedback();
			ModMenu(parent).setupHideFilterBindings();

			showingFilters = true;
			GTweener.removeTweens(mcFilters);
			GTweener.to(mcFilters, 1, { alpha:1,x:0}, { ease:Exponential.easeOut} );
		}

		protected function hideFilters():void
		{
			if(!showingFilters)
				return;

			onApplyFilters();

			ModMenu(parent).clearHideFilterBindings();
			ModMenu(parent).setupTabControlBindings();
			ModMenu(parent).setupShowFilterBindings();

			showingFilters = false;
			GTweener.removeTweens(mcFilters);
			GTweener.to(mcFilters, 0.6, { alpha:0,x:-500}, { onComplete: function(){	mcFilters.mcShadow.visible = false; mcFilters.mcCloseHit.visible = false;} } );
		}

		public function onSelect( playAnimation : Boolean = true)
		{
			_markedForDetransition = false;
			if(showingFilters)
				ModMenu(parent).setupHideFilterBindings();
			else {
				ModMenu(parent).setupShowFilterBindings();
				ModMenu(parent).setupTabControlBindings();
			}
			if(playAnimation)
			{
				//alpha = 0;
				GTweener.removeTweens(this);
				GTweener.to(this, 1, { alpha:1, x:0 }, { ease:Exponential.easeOut } );
			}
			else {
				alpha = 1;
				x = 0;
			}
		}

		public function deselect(playAnimation:Boolean = true)
		{
			if(_markedForDetransition)
				return;
			mcModDetails.deselect();
			swapCurrentObject(null);
			_markedForDetransition = true;
			if(playAnimation)
			{
				//alpha = 1;
				GTweener.removeTweens(this);
				GTweener.to(this, 1, { alpha:0,x:1920 }, { ease:Exponential.easeOut, onComplete: onDeselectTweenComplete} );
			}
			else
			{
				x = 1920;
				alpha = 0;
				//trace("GFX - deselect ##############",x);
				visible = false;
			}

			ModMenu(parent).clearShowFilterBindings();
			ModMenu(parent).clearHideFilterBindings();
			ModMenu(parent).clearShowFilterBindings();
			ModMenu(parent).clearModListBindings();
			ModMenu(parent).clearVoteFeedback();
			ModMenu(parent).clearTabControlBindings();
		}

		public function onRestore():void
		{
			if(currentObj == mcLibModList)
				setupCheckboxHitForSelectedRenderer();
		}
		
		protected function onDeselectTweenComplete():void
		{
			visible = false;
		}

		public function setActiveSubElement(event:MouseEvent):void
		{
			if(event.currentTarget == mcModDetails) {
				currentObj = event.currentTarget as MovieClip;
				mcModDetails.onSelect();

				//#LT if we clicked on the button, then this hack will run the input feedback fake click event that would get rejected because of bSelected = false
				if(event.target is InputFeedbackButton)
				{
					var mcButton:InputFeedbackButton = event.target as InputFeedbackButton;
					var bindingData:KeyBindingData = mcButton.getBindingData();
					if (bindingData && mcButton.clickable)
					{
						var fakeInputDetails:InputDetails = new InputDetails("key", bindingData.keyboard_keyCode, InputValue.KEY_UP, bindingData.gamepad_navEquivalent);
						var fakeInputEvent:InputEvent = new InputEvent(InputEvent.INPUT, fakeInputDetails);
						InputDelegate.getInstance().dispatchEvent(fakeInputEvent);
					}
				}
			}
			else {
				mcModDetails.deselect();
			}
		}

		///////////////////////////////////////////////////////////////////////////////
		// DATA SETUP
		///////////////////////////////////////////////////////////////////////////////

		protected function setupDetails(data:Object)
		{
			mcModDetails.setVisible(true);
			onSelectDetails(true);
			//mcModDetails.active = true;
			mcModDetails.setData(data);
		}

		protected function updateData(modList:Array)
		{
			//trace("ModMenuInstalledPage - UPDATEDATA");

			if(modList.length > renderers.length && renderers.length < MAX_RENDERERS)
			{
				setupPage(modList);
				return;
			}

			mcNoMods.visible = modList.length == 0;
			var mcText : TextField = mcNoMods.getChildByName("mcText") as TextField
			if(mcText)
			{
				mcText.text = "[[panel_no_mods_installed]]";
				mcText.text = CommonUtils.toUpperCaseSafe(mcText.text);
			}
			if(renderers.length > 0)
			{
				mcScrollbar.visible = true;
				mcLibModList.dataProvider = new DataProvider(modList);
				mcLibModList.validateNow();
			}
			else
			{
				mcScrollbar.visible = false;
			}
			for(var i : int = 0; i < modList.length; i++)
			{
				if(mcModDetails.m_modid == modList[i].modid)
					mcModDetails.setData(modList[i]);
			}

			if(!isAnyModSelected() && modList.length > 0)
				onSelectModById({id:0});

		}

		protected function setupPage(modList:Array)
		{
			//trace("ModMenuInstalledPage - SETUPPAGE");
			clearPage();

			if(!mcModDetails.visible && modList.length > 0)
			{
				//dispatchEvent( new GameEvent( GameEvent.CALL, "OnRequestInstalledModData", [0] ) );
				setupDetails(modList[0]);
			}
			else if(modList.length == 0)
			{
				onDeselectDetails(0);
				mcModDetails.setVisible(false);
			}

			renderers = new Vector.<IListItemRenderer>();
			for( var i : int = 0; i < modList.length && i < MAX_RENDERERS; i++)
			{
				var classRef:Class = getDefinitionByName("LibraryModPreview") as Class;
				var libModPreview:LibraryModPreview = new classRef() as LibraryModPreview;

				mcInstalledModlistBG.addChild(libModPreview);
				libModPreview.x = mcLibModAnchor.x - _modListX;
				libModPreview.y = mcLibModAnchor.y + i * (libModPreview.height + LIB_MOD_PREVIEW_GAP) - _modListY;
				libModPreview.i_index_max = mcLibModList.dataProvider.length - 1;
				libModPreview.isOrderFocusAllowed = !isAnyFilterApplied && currentSortingType == 1;
				libModPreview.setData(modList[i]);
				libModPreview.addEventListener(MouseEvent.CLICK, onPreviewMouseClick);
				renderers.push(libModPreview);
			}
			mcLibModList.itemRendererList = renderers;
			updateData(modList);
			mcLibModList.selectedIndex = 0;
			mcLibModList.ShowRenderers(true);
			mcLibModList.validateNow();

			removeChild(mcFilters);
			addChild(mcFilters);
		}

		protected function clearPage()
		{
			while(renderers.length > 0)
			{
				var preview : LibraryModPreview = renderers.pop();
				if(preview.parent)
					preview.parent.removeChild(preview);
			}
		}

		///////////////////////////////////////////////////////////////////////////////
		// INPUT HANDLING - NAVIGATION
		///////////////////////////////////////////////////////////////////////////////

		public function onItemClicked(event : ListEvent):void
		{
			if(ModMenu(parent).isModOpen() || ModMenu(parent).isInputBeingBlocked())
				return;
			var item : LibraryModPreview;
			item = event.itemRenderer as LibraryModPreview;
			var index : int = item.i_index;

			swapCurrentObject(mcLibModList);

			if (!item.bSelected) {

				deselectAllPreviews();
				item.onSelect();

				_lastMouseOveredItem = mcLibModList.getRenderers().indexOf(item);
				setupCheckboxHitForSelectedRenderer();
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnRequestInstalledModData", [index] ) );
			}
		}

		public function get lastMoveWasMouse():Boolean { return _lastMoveWasMouse; }
		public function set lastMoveWasMouse(value:Boolean):void
		{
			_lastMoveWasMouse = value;
			
			if (_lastMoveWasMouse)
			{
				if (_lastMouseOveredItem != -1)
				{
					mcLibModList.selectedIndex = _lastMouseOveredItem;
				}
			}
			else
			{
				if (mcLibModList.selectedIndex == -1)
				{
					mcLibModList.selectedIndex = 0;
				}
			}
		}

		function onOptionSelectionChanged(e:ListEvent):void
		{

		}

		
		private function handleScroll(e:Event) : void
		{
			if(ModMenu(parent).isModOpen() || ModMenu(parent).isInputBeingBlocked())
				return;
			highlightSelectedRenderer();
			mcLibModList.validateNow();

			if (_lastMouseOveredItem != -1 && lastMoveWasMouse)
			{
				var currentTarget:LibraryModPreview  = mcLibModList.getRendererAt(_lastMouseOveredItem) as LibraryModPreview;

				if (currentTarget)
				{
					//mcLibModList.selectedIndex = currentTarget.index;
					swapCurrentObject(mcLibModList);
				}
			}
		}

		protected function setupFilters():void
		{
			(parent as ModMenu).mcInputFeedback.appendButton(IFB_ENABLE_MOD, NavigationCode.GAMEPAD_A, KeyCode.SPACE, "[[panel_checkbox_default_enable]]", true);
		}

		protected function setupEnableCheckboxHint():void
		{
			(parent as ModMenu).mcInputFeedback.appendButton(IFB_ENABLE_MOD, NavigationCode.GAMEPAD_A, KeyCode.SPACE, "[[panel_checkbox_default_enable]]", true);
		}

		protected function setupDisableCheckboxHint():void
		{
			(parent as ModMenu).mcInputFeedback.appendButton(IFB_DISABLE_MOD, NavigationCode.GAMEPAD_A, KeyCode.SPACE, "[[panel_checkbox_default_enable]]", true);
		}

		public function clearCheckboxHints():void
		{
			(parent as ModMenu).mcInputFeedback.removeButton(IFB_ENABLE_MOD, true);
			(parent as ModMenu).mcInputFeedback.removeButton(IFB_DISABLE_MOD, true);
		}


		protected function clearPreviousObject():void
		{
			if (currentObj == inpSearchInput)
			{
				inpSearchInput.focused = 0;
				stage.focus = parent;
				(parent as ModMenu).mcInputFeedback.removeButton(IFB_ENTER_TEXT, true);
			}
			else if(currentObj == mcMainListModule)
			{
				dropdownUnselect();
			}
		}

		protected function setupNewObject():void
		{
			if (currentObj == inpSearchInput)
			{
				inpSearchInput.focused = 1;
				stage.focus = inpSearchInput;
				if(!inpSearchInput.textInputManager)
					inpSearchInput.textInputManager = ModStatics.getModMenu().textInputManager;
				showFilters();

				var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
				(parent as ModMenu).mcInputFeedback.appendButton(IFB_ENTER_TEXT, isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X, -1, "[[panel_enter_text]]", true);
				inpSearchInput.virtualKbKey = isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X;
			}
			else if (currentObj == mcMainListModule)
			{
				dropdownSelect();
				showFilters();
			}
		}

		protected function swapCurrentObject(newObj:MovieClip)
		{
			if(currentObj == newObj)
				return;
			/*if(currentObj && newObj)
				trace("GFX - InstalledPage - Swap:",currentObj.name,newObj.name);
			else
				trace ("GFX - InstalledPage - Swap unnamed");*/

			if((currentObj == mcMainListModule || currentObj == inpSearchInput)
				&& newObj != mcMainListModule && newObj != inpSearchInput)
				hideFilters();

			if(currentObj == mcLibModList)
				clearCheckboxHints();

			clearPreviousObject();

			currentObj = newObj;

			setupNewObject();
		}

		protected function setupCheckboxHitForSelectedRenderer()
		{
			var data:Object = mcLibModList.dataProvider[mcLibModList.selectedIndex];
			clearCheckboxHints();
			if(data && data.enabled)
				setupDisableCheckboxHint();
			else
				setupEnableCheckboxHint();
		}

		protected function isCurrentObjUnhandled():Boolean
		{
			return currentObj != mcLibModList 
			&& currentObj != mcMainListModule 
			&& currentObj != inpSearchInput;
		}

		protected function handleDown(event:InputEvent):void
		{
			var tempRenderer : W3DropdownMenuListItem;
			if(currentObj == mcLibModList)
			{
				var selectedItem : LibraryModPreview;
				var firstIndex:int = mcLibModList.getRenderers()[0].index;
				var selectedIndex:int = mcLibModList.selectedIndex - firstIndex;
				var letNextItemSwitch:Boolean = true;
				var scheduleNextUpFocus:Boolean = false;
				var scheduleNextDownFocus:Boolean = false;
				if (mcLibModList.getRenderers().length > 0)
				{
					selectedItem = mcLibModList.getRendererAt(selectedIndex) as LibraryModPreview;
				}
				if (selectedItem && selectedItem.isFocusOnOrder)
				{
					if (!selectedItem.isLastItem)
					{
						if (selectedItem.isFocusOnOrderUp)
						{
							trace("GFX - focusOrder -> handleDown -> down");
							focusOrder(false);
							letNextItemSwitch = false;
						}
						else
						{
							removeFocusFromOrder();
							scheduleNextUpFocus = true;
						}
					}
					else
					{
						removeFocusFromOrder();
						scheduleNextDownFocus = true;
					}
				}
				if (letNextItemSwitch)
				{
					if(mcLibModList.selectedIndex < mcLibModList.dataProvider.length - 1)
					{
						mcLibModList.selectedIndex++;
						mcLibModList.validateNow();
						highlightSelectedRenderer();
						setupCheckboxHitForSelectedRenderer();
					}
					else
					{
						mcLibModList.selectedIndex = 0;
						mcLibModList.validateNow();
						highlightSelectedRenderer();
						setupCheckboxHitForSelectedRenderer();
					}
					if (scheduleNextDownFocus)
					{
						trace("GFX - focusOrder -> handleDown -> scheduleNextDownFocus -> down");
						focusOrder(false);
					}
					else if (scheduleNextUpFocus)
					{
						trace("GFX - focusOrder -> handleDown -> scheduleNextUpFocus -> up");
						focusOrder(true);
					}
				}
				event.handled = true;
			}
			else if (currentObj == inpSearchInput && event.details.value != InputValue.KEY_HOLD)
			{
				swapCurrentObject(mcMainListModule);
				mcMainListModule.mcDropDownList.selectedIndex = 0;
				mcMainListModule.validateNow();

				tempRenderer = mcMainListModule.mcDropDownList.getRendererAt( 0 ) as W3DropdownMenuListItem;
				tempRenderer.selectedIndex = -1;
				tempRenderer.validateNow();
			}
			else if (currentObj == mcMainListModule)
			{
				var index = mcMainListModule.mcDropDownList.selectedIndex;
				tempRenderer = mcMainListModule.mcDropDownList.getRendererAt( index ) as W3DropdownMenuListItem;
				lastDropdownElemIndex = tempRenderer.selectedIndex;

				if(mcMainListModule.mcDropDownList.selectedIndex == mcMainListModule.mcDropDownList.getRenderers().length - 1 && event.details.value != InputValue.KEY_HOLD)
				{
					if(!tempRenderer.isOpen()
					|| tempRenderer.selectedIndex == (tempRenderer.GetDropdownListRef() as W3ScrollingList).getRenderers().length - 1)
					{
					swapCurrentObject(inpSearchInput);
					event.handled = true;
					}
				}
			}
			else if(isCurrentObjUnhandled())
			{
				currentObj = mcLibModList;
				mcLibModList.selectedIndex = 0;
				mcLibModList.validateNow();
				highlightSelectedRenderer();
				setupCheckboxHitForSelectedRenderer();
				event.handled = true;
			}
		}

		protected function handleUp(event:InputEvent):void
		{
			var tempRenderer : W3DropdownMenuListItem;
			if(currentObj == mcLibModList)
			{
				var selectedItem : LibraryModPreview;
				var firstIndex:int = mcLibModList.getRenderers()[0].index;
				var selectedIndex:int = mcLibModList.selectedIndex - firstIndex;
				var letNextItemSwitch:Boolean = true;
				var scheduleNextUpFocus:Boolean = false;
				var scheduleNextDownFocus:Boolean = false;
				if (mcLibModList.getRenderers().length > 0)
				{
					selectedItem = mcLibModList.getRendererAt(selectedIndex) as LibraryModPreview;
				}
				if (selectedItem && selectedItem.isFocusOnOrder)
				{
					if (!selectedItem.isFirstItem)
					{
						if (!selectedItem.isFocusOnOrderUp)
						{
							trace("GFX - focusOrder -> handleUp -> up");
							focusOrder(true);
							letNextItemSwitch = false;
						}
						else
						{
							removeFocusFromOrder();
							scheduleNextDownFocus = true;
						}
					}
					else
					{
						removeFocusFromOrder();
						scheduleNextUpFocus = true;
					}
				}
				if (letNextItemSwitch)
				{
					if(mcLibModList.selectedIndex > 0)
					{
						mcLibModList.selectedIndex--;
						mcLibModList.validateNow();
						highlightSelectedRenderer();
						setupCheckboxHitForSelectedRenderer();
					}
					else
					{
						mcLibModList.selectedIndex = mcLibModList.dataProvider.length - 1;
						mcLibModList.validateNow();
						highlightSelectedRenderer();
						setupCheckboxHitForSelectedRenderer();
					}
					if (scheduleNextDownFocus)
					{
						trace("GFX - focusOrder -> handleUp -> scheduleNextDownFocus -> down");
						focusOrder(false);
					}
					else if (scheduleNextUpFocus)
					{
						trace("GFX - focusOrder -> handleUp -> scheduleNextUpFocus -> up");
						focusOrder(true);
					}
				}
				event.handled = true;
			}
			else if (currentObj == inpSearchInput && event.details.value != InputValue.KEY_HOLD)
			{
				swapCurrentObject(mcMainListModule);
				var lastIndex : int = mcMainListModule.mcDropDownList.getRenderers().length - 1;
				mcMainListModule.mcDropDownList.selectedIndex = lastIndex
				mcMainListModule.validateNow();

				tempRenderer = mcMainListModule.mcDropDownList.getRendererAt( lastIndex ) as W3DropdownMenuListItem;
				if(tempRenderer.isOpen())
				{
					tempRenderer.selectedIndex = (tempRenderer.GetDropdownListRef() as W3ScrollingList).getRenderers().length - 1;
					tempRenderer.GetDropdownListRef().selectedIndex = (tempRenderer.GetDropdownListRef() as W3ScrollingList).getRenderers().length - 1;
					tempRenderer.GetDropdownListRef().validateNow();
					tempRenderer.validateNow();
				}

				mcMainListModule.validateNow();
				event.handled = true;
			}
			else if (currentObj == mcMainListModule)
			{
				var index = mcMainListModule.mcDropDownList.selectedIndex;
				tempRenderer = mcMainListModule.mcDropDownList.getRendererAt( index ) as W3DropdownMenuListItem;
				lastDropdownElemIndex = tempRenderer.selectedIndex;

				if(mcMainListModule.mcDropDownList.selectedIndex == 0 && tempRenderer.selectedIndex == -1 && event.details.value != InputValue.KEY_HOLD)
				{
					swapCurrentObject(inpSearchInput);
					event.handled = true;
				}
			}
			else if(isCurrentObjUnhandled())
			{
				currentObj = mcLibModList;
				mcLibModList.selectedIndex = mcLibModList.dataProvider.length - 1;
				mcLibModList.validateNow();
				highlightSelectedRenderer();
				setupCheckboxHitForSelectedRenderer();
				event.handled = true;
			}
		}

		protected function handleLeft(event:InputEvent):void
		{
			if(currentObj == mcModDetails)
			{
				mcModDetails.deselect();
				swapCurrentObject(mcLibModList);
				setupCheckboxHitForSelectedRenderer();
				event.handled = true;
			}
			else if (currentObj == mcLibModList)
			{
				if(mcLibModList.getRenderers().length == 0)
				{
					swapCurrentObject(inpSearchInput);
					event.handled = true;
					return;
				}

				var selectedItem : LibraryModPreview;
				var firstIndex:int = mcLibModList.getRenderers()[0].index;
				var selectedIndex:int = mcLibModList.selectedIndex - firstIndex;
				if (mcLibModList.getRenderers().length > 0)
				{
					selectedItem = mcLibModList.getRendererAt(selectedIndex) as LibraryModPreview;
				}
				if (selectedItem && selectedItem.isFocusOnOrder)
				{
					removeFocusFromOrder();
				}
				else
				{
					swapCurrentObject(inpSearchInput);
					event.handled = true;
				}
			}
		}

		protected function handleRight(event:InputEvent):void
		{
			if(currentObj == mcLibModList)
			{
				var focusOrderButtons : Boolean = false;
				var selectedItem : LibraryModPreview;
				var firstIndex:int = mcLibModList.getRenderers()[0].index;
				var selectedIndex:int = mcLibModList.selectedIndex - firstIndex;
				if (mcLibModList.getRenderers().length > 0)
				{
					selectedItem = mcLibModList.getRendererAt(selectedIndex) as LibraryModPreview;
				}
				if (mcLibModList.getRenderers().length > 1 && selectedItem)
				{
					if (!selectedItem.isFocusOnOrder && selectedItem.isOrderFocusAllowed)
					{
						focusOrderButtons = true;
						trace("GFX - focusOrder -> handleRight -> up");
						focusOrder(true);
					}

					event.handled = true;
				}

				if (!focusOrderButtons)
				{
					if(!mcModDetails.visible || mcModDetails.index != mcLibModList.selectedIndex)
					{
						if(mcLibModList.getRenderers().length > 0)
							dispatchEvent( new GameEvent( GameEvent.CALL, "OnRequestInstalledModData", [mcLibModList.selectedIndex] ) );
					}
					else if (mcModDetails.visible)
					{
						removeFocusFromOrder();
						swapCurrentObject(mcModDetails);
						mcModDetails.onSelect();
						clearCheckboxHints();
					}
					event.handled = true;
				}
			}
			else if (currentObj == mcMainListModule)
			{
				swapCurrentObject(mcLibModList);
			}
		}

		protected function focusOrder(focusUp:Boolean) : Boolean
		{
			var selectedItem : LibraryModPreview;
			var firstIndex:int = mcLibModList.getRenderers()[0].index;
			var selectedIndex:int = mcLibModList.selectedIndex - firstIndex;
			if (mcLibModList.getRenderers().length > 0)
			{
				selectedItem = mcLibModList.getRendererAt(selectedIndex) as LibraryModPreview;
			}
			if (!selectedItem)
			{
				return false;
			}
			selectedItem.isFocusOnOrder = true;
			if (selectedItem.isFirstItem || !focusUp)
			{
				selectedItem.isFocusOnOrderUp = false;
				selectedItem.mcOrderDownButton.select();
				selectedItem.mcOrderUpButton.deselect();
			}
			else
			{
				selectedItem.isFocusOnOrderUp = true;
				selectedItem.mcOrderUpButton.select();
				selectedItem.mcOrderDownButton.deselect();
			}
			return true;
		}

		protected function removeFocusFromOrder() : Boolean
		{
			var selectedItem : LibraryModPreview;
			var firstIndex:int = mcLibModList.getRenderers()[0].index;
			var selectedIndex:int = mcLibModList.selectedIndex - firstIndex;
			if (mcLibModList.getRenderers().length > 0)
			{
				selectedItem = mcLibModList.getRendererAt(selectedIndex) as LibraryModPreview;
			}
			if (!selectedItem)
			{
				return false;
			}
			selectedItem.isFocusOnOrder = false;
			selectedItem.isFocusOnOrderUp = false;
			selectedItem.mcOrderUpButton.deselect();
			selectedItem.mcOrderDownButton.deselect();
			return true;
		}

		protected function handleInputNavigate(event:InputEvent):void
		{
			if(_markedForDetransition || ModMenu(parent).isModOpen() || ModMenu(parent).isInputBeingBlocked())
				return;
			trace("GFX - ModMenuInstalledPage - handleInputNavigate", event);

			if(!visible)
				return;

			var details:InputDetails = event.details;

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var hold:Boolean = details.value == InputValue.KEY_HOLD; //#B should be also hold here
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

			if (!event.handled)
			{
				if(details.navEquivalent == NavigationCode.DOWN && (keyDown || hold))
				{
					handleDown(event);
				}
				else if (details.navEquivalent == NavigationCode.UP && (keyDown || hold))
				{
					handleUp(event);
				}
				else if (details.navEquivalent == NavigationCode.LEFT && keyDown)
				{
					handleLeft(event);
				}
				else if (details.navEquivalent == NavigationCode.RIGHT && keyDown)
				{
					handleRight(event);
				}
				else if (details.navEquivalent == NavigationCode.GAMEPAD_A || details.code == KeyCode.SPACE)
				{
					if(currentObj == mcLibModList)
					{
						var selectedRenderer:LibraryModPreview = null;
						var firstIndex:int = mcLibModList.getRenderers()[0].index;
						selectedRenderer = mcLibModList.getRendererAt(mcLibModList.selectedIndex - firstIndex) as LibraryModPreview;
						if(selectedRenderer)
						{
							if (keyDown)
							{
								if (selectedRenderer.isFocusOnOrder)
								{
									if (selectedRenderer.isFocusOnOrderUp)
										selectedRenderer.mcOrderUpButton.press();
									else
										selectedRenderer.mcOrderDownButton.press();
								}
								else
								{
									selectedRenderer.onEnabledChange();
								}
							}
							else if (keyUp)
							{
								if (selectedRenderer.isFocusOnOrder)
								{
									if (selectedRenderer.isFocusOnOrderUp)
										selectedRenderer.mcOrderUpButton.release();
									else
										selectedRenderer.mcOrderDownButton.release();
								}
							}
						}
						event.handled = true;
					}
					else if (currentObj == mcMainListModule && keyUp)
					{
						var tempRenderer : W3DropdownMenuListItem;
						var index = mcMainListModule.mcDropDownList.selectedIndex;
						tempRenderer = mcMainListModule.mcDropDownList.getRendererAt( index ) as W3DropdownMenuListItem;
						
						if(tempRenderer.selectedIndex >= 0)
						{
							var itemRenderer : ModFilterItemRenderer = tempRenderer.GetDropdownListRef().getRendererAt(tempRenderer.selectedIndex) as ModFilterItemRenderer;
							itemRenderer.onEnabledChange();
							event.handled = true;
							return;	
						}
						else trace("GFX @@@@@@@@@@@@@@@@@@@@@@ on the collapsible thingy");
					}
				}
				else if ((details.navEquivalent == NavigationCode.GAMEPAD_R3 || details.code == KeyCode.F) && keyUp)
				{
					onFilterToggle();
					event.handled = true;
					return;	
				}

				if ((details.navEquivalent == NavigationCode.GAMEPAD_L2 || details.code == KeyCode.R) && keyUp)
				{
					if(currentObj == mcMainListModule || currentObj == inpSearchInput)
					{
						onResetFilters();
						event.handled = true;
						return;	
					}
				}
				if ((details.navEquivalent == NavigationCode.GAMEPAD_R2 || details.code == KeyCode.T || details.code == KeyCode.ENTER) && keyUp)
				{
					if(currentObj == mcMainListModule || currentObj == inpSearchInput)
					{
						onApplyFilters();
						event.handled = true;
						return;	
					}
				}
			}
		}

		public function isShowingFilters():Boolean
		{
			return showingFilters;
		}

		public function onFilterToggle():void
		{
			if(showingFilters) {
				swapCurrentObject(mcLibModList);
				hideFilters();
			}
			else
				showFilters();
		}

		///////////////////////////////////////////////////////////////////////////////
		// MISC
		///////////////////////////////////////////////////////////////////////////////

		private function isAnyModSelected():Boolean //only checking renderers
		{
			for(var i : int = 0; i < renderers.length; i++)
			{
				var libModPreview : LibraryModPreview = renderers[i] as LibraryModPreview;

				if(libModPreview && libModPreview.bSelected)
					return true;
			}
			return false;
		}

		private function onSelectModById(data:Object):void
		{
			var id:int = data.id;

			mcLibModList.selectedIndex = id;
			mcLibModList.validateNow();
			highlightSelectedRenderer();

		}

		private function onSelectModByModid(data:Object):void
		{
			var modid:String = data.modid;

			var dataProvider : DataProvider = mcLibModList.dataProvider as DataProvider;

			if(!dataProvider)
			{
				trace("GFX - Error - ModMenuInstalledPage::onSelectModByModid - no dataProvider found")
				return;
			}

			for(var i : int = 0; i < dataProvider.length; i++)
			{
				if(dataProvider[i].modid == modid)
				{
					mcLibModList.selectedIndex = i;
					mcLibModList.validateNow();
					highlightSelectedRenderer();
					return;
				}
			}
		}

		private function onPreviewMouseClick(event:MouseEvent):void
		{
			//trace("GFX ------------- ONPREVIEWMOUSECLICK",event.currentTarget);
			setTimeout(function(){
				clickCount = 0;
			}, DOUBLE_CLICK_MS);

			clickCount++;
			if(clickCount > 1)
			{
				//trace("GFX double click happened");
				mcModDetails.onDetails();
				return;
			}
 		}

		private function onSelectDetails( playAnimation:Boolean):void
		{
			if(playAnimation)
			{
				GTweener.to(mcModDetails, 1, { x:935 }, { ease:Exponential.easeOut } );
				//GTweener.to(mcInstalledModlistBG, 1, { x: _modListX }, { ease:Exponential.easeOut } );
			}
			else
			{
				mcModDetails.x = 939;
				//mcInstalledModlistBG.x = _modListX;
			}
		}

		public function onDeselectDetails( playAnimation:int):void
		{
			if(currentObj == mcModDetails)
				swapCurrentObject(mcLibModList);

			//trace("GFX #test# onDeselectDetails", playAnimation);

			mcModDetails.setVisible(false);
			mcModDetails.deselect();
			if(playAnimation > 0)
			{
				GTweener.to(mcModDetails, 1, { x: 960 - mcModDetails.width / 2 }, { ease:Exponential.easeOut } );
				//GTweener.to(mcInstalledModlistBG, 1, { x: 960 - mcInstalledModlistBG.width / 2 }, { ease:Exponential.easeOut } );
			}
			else
			{
				mcModDetails.x = 960 - mcModDetails.width / 2;
				//mcInstalledModlistBG.x = 960 - mcInstalledModlistBG.width / 2;
			}
		}

		private function deselectAllPreviews():void
		{
			//trace("GFX -- deselectAllPreviews", renderers.length)
			for( var i : int = 0; i < renderers.length; i++)
			{
				(renderers[i] as LibraryModPreview).deselect();
			}
		}

		public function reflectEnablednessToDetails(value:Boolean):void
		{
			mcModDetails.setEnabled(value);
		}


		protected function highlightSelectedRenderer():void
		{
			var selectedIndex:int = mcLibModList.selectedIndex;
			var selectedRenderer:LibraryModPreview = null;


			deselectAllPreviews();
			if(mcLibModList.getRenderers().length > 0)
			{
				var firstIndex:int = mcLibModList.getRenderers()[0].index;
				selectedRenderer = mcLibModList.getRendererAt(selectedIndex - firstIndex) as LibraryModPreview;
				_lastMouseOveredItem = selectedIndex - firstIndex;
			}
			if(selectedRenderer != null)
			{
				selectedRenderer.onSelect();
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnRequestInstalledModData", [selectedIndex] ) );
			}
		}

		protected function sendSearchDataToWS(ev : W3TextInputEvent):void
		{
			var text : String = ev.text;
			var words : Array = [];

			words = text.split(" ");

			//#LT: this is yuck, but easier here than in WS...
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSearchInputClear", [2] ) );
			for each(var word:String in words)
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnSearchInputAddWord", [2, word] ) );

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSearchInputTextFinalized", [2] ) );
		}

		protected function cacheDropdownIndexes():void
		{
			_lastSelectedDropdownIndex =  mcMainListModule.mcDropDownList.selectedIndex;

			var tempRenderer : W3DropdownMenuListItem;
			tempRenderer = mcMainListModule.mcDropDownList.getRendererAt( mcMainListModule.mcDropDownList.selectedIndex ) as W3DropdownMenuListItem;

			if(tempRenderer)
				_lastSelectedDropdownSubindex = tempRenderer.selectedIndex;
		}

		protected function onResetFilters():void
		{
			cacheDropdownIndexes();
			inpSearchInput.resetText();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnResetFilters", [2]) );
		}


		protected function onApplyFilters():void
		{
			cacheDropdownIndexes();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnApplyFilters", [2]) );
		}

		public function /*WS*/ dropdownUnselect():void
		{
			//trace("GFX @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ dropdownUnselect");
			mcMainListModule.focused = 0;
			mcMainListModule.inputEnabled = false;
			mcMainListModule.enabled = false;

			var tempRenderer : W3DropdownMenuListItem;
			tempRenderer = mcMainListModule.mcDropDownList.getRendererAt( mcMainListModule.mcDropDownList.selectedIndex ) as W3DropdownMenuListItem;

			//#L Hacky solution: the idea is to select something large, so selection indicator is not shown
			if ( tempRenderer )
			{
				_lastSelectedDropdownSubindex = tempRenderer.selectedIndex;
				_lastSelectedDropdownIndex =  mcMainListModule.mcDropDownList.selectedIndex;
				//w3DropDownList.as
				if ( tempRenderer.isOpen() ) 
				{
					tempRenderer.SelectSubListItem( -1 );
				}
				else {
					mcMainListModule.mcDropDownList.selectedIndex = -1;
				}
			}
		}

		protected function dropdownSelect():void
		{
			mcMainListModule.focused = 1;
			mcMainListModule.inputEnabled = true;
			mcMainListModule.enabled = true;

			if(_lastSelectedDropdownIndex != -1)
			{
				var tempRenderer : W3DropdownMenuListItem;
				mcMainListModule.mcDropDownList.selectedIndex = _lastSelectedDropdownIndex;
				tempRenderer = mcMainListModule.mcDropDownList.getRendererAt( _lastSelectedDropdownIndex ) as W3DropdownMenuListItem;

				if ( tempRenderer && tempRenderer.isOpen() )
				{
					tempRenderer.SelectSubListItem( _lastSelectedDropdownSubindex );
				}
			}
		}

		protected function onModuleMouseClick(event:MouseEvent):void
		{
			//trace("GFX",this,"onModuleMouseClick");
			var currentTarget : MovieClip = event.currentTarget as MovieClip;
			if(currentTarget) {
				if(currentTarget != mcMainListModule && currentObj == mcMainListModule)
				{
					dropdownUnselect();
				}
				swapCurrentObject(currentTarget);
			}
		}

		public function handleSelectChange(event:ListEvent):void
		{	
			if (event.itemRenderer is ModFilterItemRenderer)
			{
				lastSelectedItem = event.itemRenderer as ModFilterItemRenderer;
			}
			else
			{
				lastSelectedItem = null;
			}
			
			//InputFeedbackManager.updateButtons(this);
		}

		private function handleItemDoubleClick(event:ListEvent):void
		{
			if (event.itemRenderer is ModFilterItemRenderer)
			{
				ModFilterItemRenderer(event.itemRenderer).onEnabledChange();
			}
		}

		public function filterSortFunc(targetArray:Array):void
		{
			targetArray.sortOn( "sortTag" );
		}

		public function hasInput(clip : MovieClip):Boolean
		{
			if((currentObj == inpSearchInput || currentObj == mcMainListModule) && clip == mcModDetails)
				return false;
			return true;
		}

		public function onRadioPressed(data:Object)
		{
			var index = data.index;
			var value = data.value;
			var filterIndex = data.filterIndex;
			var ddRenderers = mcMainListModule.mcDropDownList.getRenderers();
			var i, j : int;
			var itemRenderer : ModFilterItemRenderer

			for(i = 0; i < ddRenderers.length; i++)
			{
				var tempRenderer : W3DropdownMenuListItem = ddRenderers[i] as W3DropdownMenuListItem;

				if(!tempRenderer.GetDropdownListRef())
					continue;
				
				var dropdownRenderers = tempRenderer.GetDropdownListRef().getAllRenderers();
				var indexFound:Boolean = false;
				for(j = 0; j < dropdownRenderers.length; j++)
				{
					itemRenderer = dropdownRenderers[j] as ModFilterItemRenderer;
					if(itemRenderer.data.index == index && itemRenderer.data.filterIndex == filterIndex)
					{
						indexFound = true;
						break;
					}
				}

				if(indexFound)
				{
					for(j = 0; j < dropdownRenderers.length; j++)
					{
						itemRenderer = dropdownRenderers[j] as ModFilterItemRenderer;

						if(value == 0 || value == 2)
						{
							if(itemRenderer.data.index == index)
								itemRenderer.setEnabled(value);
						}
						else if (value == 1)
						{
							if(itemRenderer.data.index == index)
								itemRenderer.setEnabled(1); 
							else if (itemRenderer.data.value == 1)
								itemRenderer.setEnabled(0); 
						}						
					}
					return;
				}
			}
		}

		public function onFiltersUpdated(data:Object)
		{
			isAnyFilterApplied = data.isAnyFilterApplied;
			currentSortingType = data.sortingType;

			if (mcLibModList.getRenderers().length > 0)
			{
				for (var i:int=0; i < mcLibModList.getRenderers().length; i += 1)
				{
					(mcLibModList.getRenderers()[i] as LibraryModPreview).isOrderFocusAllowed = !isAnyFilterApplied && currentSortingType == 1;
				}
			}
		}

		public function onUpdateOrder(data:Object)
		{
			var firstIndex:int = mcLibModList.getRenderers()[0].index;
			var selectedRenderer:LibraryModPreview = mcLibModList.getRendererAt(mcLibModList.selectedIndex - firstIndex) as LibraryModPreview;
			if(selectedRenderer)
			{
				selectedRenderer.isFocusOnOrder = true;
				if (data.orderUp && !selectedRenderer.isFirstItem || (!data.orderUp && selectedRenderer.isLastItem))
				{
					selectedRenderer.mcOrderUpButton.select();
					selectedRenderer.isFocusOnOrderUp = true;
				}
				else
				{
					selectedRenderer.mcOrderDownButton.select();
					selectedRenderer.isFocusOnOrderUp = false;
				}
			}
		}

		private function handleControllerChanged(event:ControllerChangeEvent)
		{
			if (event.isMouse)
			{
				var selectedItem : LibraryModPreview;
				var firstIndex:int = mcLibModList.getRenderers()[0].index;
				var selectedIndex:int = mcLibModList.selectedIndex - firstIndex;
				if (mcLibModList.getRenderers().length > 0)
				{
					selectedItem = mcLibModList.getRendererAt(selectedIndex) as LibraryModPreview;
				}
				if (selectedItem && selectedItem.isFocusOnOrder)
				{
					selectedItem.isFocusOnOrder = false;
					selectedItem.mcOrderUpButton.deselect();
					selectedItem.mcOrderDownButton.deselect();
				}
			}
		}
	}
}