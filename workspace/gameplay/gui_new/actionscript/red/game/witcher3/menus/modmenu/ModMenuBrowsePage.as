/***********************************************************************
/** Mod Menu - Browse Page
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.FocusEvent;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.gfx.Extensions;
	import scaleform.clik.managers.InputDelegate;

	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

	import red.core.events.GameEvent;
	import red.core.constants.KeyCode;

	import red.game.witcher3.constants.EInputDeviceType;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.controls.W3DropdownMenuListItem;
	import red.game.witcher3.data.KeyBindingData;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.DropdownListModuleBase;
	import red.game.witcher3.utils.CommonUtils;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class ModMenuBrowsePage extends UIComponent
	{
		// CONSTS
		private static const IFB_SELECT_PAGE:int = 1000;
		private static const IFB_PREVIOUS_PAGE:int = 1010;
		private static const IFB_NEXT_PAGE:int = 1011;
		private static const IFB_PREVIOUS_PAGE_KBM_ONLY:int = 1020;
		private static const IFB_NEXT_PAGE_KBM_ONLY:int = 1021;
		private static const IFB_RESET_FILTERS:int = 2320;
		private static const IFB_APPLY_FILTERS:int = 2330;
		private static const IFB_ENTER_TEXT:int = 3000;

		private static const DOUBLE_CLICK_MS = 250;

		// ART CLIPS

		public var mcModList				: W3ScrollingList;
		public var mcModlistBG				: MovieClip;
		public var mcPaginatorController	: ModPaginatorController;
		public var mcMainListModule			: DropdownListModuleBase;
		public var inpSearchInput			: W3TextInput;
		public var mcModAnchor				: MovieClip;
		public var mcNoMods					: MovieClip;
		public var mcFilters				: MovieClip;
		public var mcQuickButtonBar			: ModQuickButtonBar;


		// VARS

		private var renderers 	: Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>();
		protected var _selectedPreviewColumnIndex:int = -1;
		protected var _lastMouseOveredItem:int = -1;
		public var _lastMoveWasMouse:Boolean = true;
		private var currentObj : MovieClip;
		protected var   lastSelectedItem					: ModFilterItemRenderer;
		private var _lastSelectedDropdownIndex:int = -1;
		private var _lastSelectedDropdownSubindex:int = -1;
		private var _markedForDetransition:Boolean = false;
		private var clickCount:int = 0;
		private var lastDropdownElemIndex:int = 0;
		private var showingFilters:Boolean = false;
		private var initFinished:Boolean = false;

		protected function get menuName():String { return "ModMenu"; }
		override protected function configUI():void
		{
			//trace("GFX - MOD MENU BROWSE PAGE: Config UI: Start");
			super.configUI();

			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.browse.setup', [setupPage] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.browse.update_data', [updateData] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.filters.radio.clicked', [onRadioPressed] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'mods.filters.list', [onDropdownDataGot] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'mods.update.mods.found', [updateModsFound] ) );
			
			var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;

			if(mcFilters)
			{
				mcFilters.x = -500;
				mcFilters.alpha = 0;
				//mcFilters.mcInputFeedback.mcInputBackground = mcFilters.mcInputBackground;
				mcFilters.mcInputFeedback.buttonAlign = "center";
				mcFilters.mcInputFeedback.appendButton(IFB_RESET_FILTERS, NavigationCode.GAMEPAD_L2, KeyCode.R, "[[panel_mods_reset_filters]]", true);
				mcFilters.mcInputFeedback.appendButton(IFB_APPLY_FILTERS, isSwitch2Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_R2, KeyCode.T, "[[panel_mods_apply_filters]]", true);
				mcFilters.mcShadow.visible = false;
				mcFilters.mcCloseHit.visible = false;
				mcFilters.mcCloseHit.addEventListener(MouseEvent.CLICK, function(e:MouseEvent){ swapCurrentObject(mcModList, true) }, false, -100);
				mcMainListModule = mcFilters.mcMainListModule;
				inpSearchInput = mcFilters.inpSearchInput;
			}
			if(mcPaginatorController)
			{
				positionPaginatorController();
				mcPaginatorController.addEventListener(MouseEvent.CLICK, onModuleMouseClick, false, -100);
			}
			if(mcQuickButtonBar)
				positionQuickButtonBar();

			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.browse.pages.setup', [setupPaginatorController] ) );
			//mcMainListModule.focused = 1;
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
			mcModList.addEventListener(MouseEvent.CLICK, onModuleMouseClick, false, -100);
			
			mcModList.itemRendererName = "ModPreviewLine";

			stage.addEventListener(InputEvent.INPUT, handleInputNavigate, false, 5, true);

			if(inpSearchInput)
			{
				inpSearchInput.skipKeys.push(KeyCode.UP);
				inpSearchInput.skipKeys.push(KeyCode.DOWN);
				inpSearchInput.skipKeys.push(KeyCode.ENTER);
				inpSearchInput.skipKeys.push(KeyCode.ESCAPE);
				inpSearchInput.skipGamepadKeys.push(NavigationCode.GAMEPAD_L2);
				inpSearchInput.skipGamepadKeys.push(isSwitch2Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_R2);
				inpSearchInput.skipGamepadKeys.push(NavigationCode.GAMEPAD_B);
							
				inpSearchInput.addEventListener(MouseEvent.CLICK, onModuleMouseClick, false, -100);
				inpSearchInput.addEventListener(W3TextInputEvent.TEXT_CHANGED, sendSearchDataToWS, false, 0);
			}

			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);

			//trace("GFX - MOD MENU BROWSE PAGE: Config UI: Done");
		}

		private function handleControllerChanged(event:ControllerChangeEvent):void
		{
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

			if (isSwitchPlatform)
			{
				var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;

				if(mcFilters)
				{
					mcFilters.mcInputFeedback.removeButton(IFB_RESET_FILTERS);
					mcFilters.mcInputFeedback.removeButton(IFB_APPLY_FILTERS);

					mcFilters.mcInputFeedback.appendButton(IFB_RESET_FILTERS, NavigationCode.GAMEPAD_L2, KeyCode.R, "[[panel_mods_reset_filters]]", true);
					mcFilters.mcInputFeedback.appendButton(IFB_APPLY_FILTERS, isSwitch2Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_R2, KeyCode.T, "[[panel_mods_apply_filters]]", true);
				}

				if(inpSearchInput)
				{
					// Find and swap the "old" entry with the new
					var skipKeyIdx : int = inpSearchInput.skipGamepadKeys.indexOf(isSwitch2Mouser ? NavigationCode.GAMEPAD_R2 : NavigationCode.GAMEPAD_L1);
					if (skipKeyIdx != -1)
					{
						inpSearchInput.skipGamepadKeys[skipKeyIdx] = isSwitch2Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_R2;
					}
				}
			}
		}

		public function onSelect(playAnimation:Boolean = true):void
		{
			_markedForDetransition = false;
			if(showingFilters)
				ModMenu(parent).setupHideFilterBindings();
			else
			{
				ModMenu(parent).setupShowFilterBindings();
				ModMenu(parent).setupTabControlBindings();
			}
			if(playAnimation)
			{
				//alpha = 0;
				GTweener.removeTweens(this);
				//x=-1920;
				GTweener.to(this, 1, { alpha:1, x:0}, { ease:Exponential.easeOut } );
			}
			else {
				alpha = 1;
				x = 0;
			}
		}

		public function deselect(playAnimation:Boolean = true):void
		{
			if(_markedForDetransition)
				return;

			ModMenu(parent).clearShowFilterBindings();
			ModMenu(parent).clearHideFilterBindings();
			ModMenu(parent).clearShowFilterBindings();
			ModMenu(parent).clearModListBindings();
			ModMenu(parent).clearVoteFeedback();

			swapCurrentObject(null);
			_markedForDetransition = true;
			if(playAnimation)
			{
				//alpha = 1;
				GTweener.removeTweens(this);
				GTweener.to(this, 1, { alpha:0,x:-1920}, { ease:Exponential.easeOut, onComplete: onDeselectTweenComplete} );
			}
			else
			{
				alpha = 0;
				x = -1920;
				visible = false;
			}
		}

		protected function onDeselectTweenComplete():void
		{
			visible = false;
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
			ModMenu(parent).setupShowFilterBindings();

			showingFilters = false;
			GTweener.removeTweens(mcFilters);
			GTweener.to(mcFilters, 0.6, { alpha:0,x:-500}, { onComplete: function(){	mcFilters.mcShadow.visible = false; mcFilters.mcCloseHit.visible = false;} } );
		}

		///////////////////////////////////////////////////////////////////////////////
		// LAYOUT - POSITIONING - SCALING
		///////////////////////////////////////////////////////////////////////////////

		protected function positionQuickButtonBar():void
		{
			var classRef2:Class = getDefinitionByName("ModPreview") as Class;
			var modPreview:ModPreview = new classRef2() as ModPreview;

			mcQuickButtonBar.x = mcModAnchor.x;
			mcQuickButtonBar.setCachedWidth( (ModStatics.MOD_PREVIEW_LINE_MEMBER_COUNT) * (modPreview.getWidth() + ModStatics.MOD_PREVIEW_GAP_X) - ModStatics.MOD_PREVIEW_GAP_X);
		}

		protected function positionPaginatorController():void
		{
			mcPaginatorController.x = mcModAnchor.x;

			var classRef2:Class = getDefinitionByName("ModPreview") as Class;
			var modPreview:ModPreview = new classRef2() as ModPreview;

			var newWidth:Number = ModStatics.MOD_PREVIEW_LINE_MEMBER_COUNT * (modPreview.getWidth() + ModStatics.MOD_PREVIEW_GAP_X) - ModStatics.MOD_PREVIEW_GAP_X;
			//mcPaginatorController.invBG.width = ;
			//mcPaginatorController.width = ModStatics.MOD_PREVIEW_LINE_MEMBER_COUNT * (modPreview.getWidth() + 5);
			//mcPaginatorController.invBG.scaleX = newWidth / mcPaginatorController.invBG.width
			mcPaginatorController.expectedWidth = newWidth;

			//Recalc size hack
			var temp:Shape = new Shape();
			mcPaginatorController.addChild(temp);
			mcPaginatorController.removeChild(temp);

			//trace("GFX - Paginator controller resized to", mcPaginatorController.width, mcPaginatorController.expectedWidth);
		}

		///////////////////////////////////////////////////////////////////////////////
		// DATA SETUP - MANAGEMENT
		///////////////////////////////////////////////////////////////////////////////

		protected function bundleData(modList:Array):Array
		{
			mcNoMods.visible = modList.length == 0;
			var mcText : TextField = mcNoMods.getChildByName("mcText") as TextField
			if(mcText)
			{
				mcText.text = "[[panel_no_mods_remote]]";
				mcText.text = CommonUtils.toUpperCaseSafe(mcText.text);
			}

			var mainArray:Array = new Array();
			var arr:Array = new Array();
			var turn:int = ModStatics.MOD_PREVIEW_LINE_MEMBER_COUNT;


			for( var i : int = 0; i < modList.length; i++)
			{
				arr.push(modList[i]);
				if(i % turn == turn - 1 
				|| i == modList.length - 1)
				{
					var obj:Object = new Object();
					obj.modArray = arr;
					mainArray.push(obj);
					arr = new Array();
				}
			}
			return mainArray;
		}

		protected function updateData(modList:Array)
		{
			var mainArray:Array = bundleData(modList);
			mcModList.dataProvider = new DataProvider(mainArray);
		}

		protected function updateModsFound(modsCount:int)
		{
			mcQuickButtonBar.fillData(modsCount);
		}

		protected function clearPage()
		{
			while(renderers.length > 0)
			{
				var preview : ModPreviewLine = renderers.pop();
				if(preview.parent)
					preview.parent.removeChild(preview);
			}
		}

		protected function setupPage(modList:Array)
		{
			trace("ModMenuBrowsePage - SETUPPAGE");
			trace(" |- Mod count:", modList.length);
			initFinished = true;

			clearPage();

			var mainArray:Array = bundleData(modList);

			for( var i = 0; i < mainArray.length && i < ModStatics.MOD_PREVIEW_MAXLINES; i++)
			{
				var classRef:Class = getDefinitionByName("ModPreviewLine") as Class;
				var modPreviewLine:ModPreviewLine = new classRef() as ModPreviewLine;
				
				addChild(modPreviewLine);
				modPreviewLine.reservePreviews(mainArray[i].modArray.length);
				modPreviewLine.x = mcModAnchor.x;
				modPreviewLine.y = mcModAnchor.y + i * (modPreviewLine.getHeight() + ModStatics.MOD_PREVIEW_GAP_Y);
				renderers.push(modPreviewLine);
			}
			mcModList.itemRendererList = renderers;
			mcModList.dataProvider = new DataProvider(mainArray);
			mcModList.validateNow();

			setupPreviewMouseHandling();

			removeChild(mcFilters);
			addChild(mcFilters);

			//trace("GFX - Browse page - Setup Page ended");
		}

		public function filterSortFunc(targetArray:Array):void
		{
			targetArray.sortOn( "sortTag" );
		}

		protected function setupPaginatorController(data:Object)
		{
			mcPaginatorController.createPaginators(data.numPages,data.currentPage);

			recalibratePaginatorBindings(true);
			if(currentObj != mcPaginatorController) {
				clearPaginatorBindingsOnModMenu();

				//triggering refresh myb?
				(parent as ModMenu).mcInputFeedback.appendButton(1234567, NavigationCode.GAMEPAD_L1, KeyCode.PAGE_DOWN, "[[panel_mods_previous_page]]", true);
				(parent as ModMenu).mcInputFeedback.removeButton(1234567, true);
			}
		}

		public function onDropdownDataGot(data:Object)
		{
			setTimeout(function(){
				if(currentObj == mcMainListModule)
					dropdownSelect();
			}, 1);
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

		///////////////////////////////////////////////////////////////////////////////
		// INPUT HANDLING - NAVIGATION
		///////////////////////////////////////////////////////////////////////////////

		private function handleScroll(e:Event) : void
		{
			mcModList.validateNow();
			
			if (_lastMouseOveredItem != -1 && lastMoveWasMouse)
			{
				var currentTarget:ModPreview  = mcModList.getRendererAt(_lastMouseOveredItem) as ModPreview;
				
				if (currentTarget)
				{
					mcModList.selectedIndex = currentTarget.getIndex();
					mcModList.validateNow();
					swapCurrentObject(mcModList);
				}
			}
		}

		public function recalibratePaginatorBindings(force:Boolean = false):void
		{
			if(currentObj != mcPaginatorController && !force)
				return;

			var previousButton:Boolean = (parent as ModMenu).mcInputFeedback.hasButton(IFB_PREVIOUS_PAGE);
			var nextButton:Boolean = (parent as ModMenu).mcInputFeedback.hasButton(IFB_NEXT_PAGE);

			if ((!previousButton && mcPaginatorController.canGoPreviousPage()) //#LT super hacky to achieve A is before D
				|| (!nextButton && mcPaginatorController.canGoNextPage()))
			{
				(parent as ModMenu).mcInputFeedback.removeButton(IFB_PREVIOUS_PAGE, true);
				(parent as ModMenu).mcInputFeedback.removeButton(IFB_NEXT_PAGE, true);
				(parent as ModMenu).mcInputFeedback.removeButton(IFB_PREVIOUS_PAGE_KBM_ONLY, true);
				(parent as ModMenu).mcInputFeedback.removeButton(IFB_NEXT_PAGE_KBM_ONLY, true);
			
				if(mcPaginatorController.canGoPreviousPage())
				{
					(parent as ModMenu).mcInputFeedback.appendButton(IFB_PREVIOUS_PAGE, NavigationCode.GAMEPAD_L1, KeyCode.PAGE_DOWN, "[[panel_mods_previous_page]]", true);
					(parent as ModMenu).mcInputFeedback.appendButton(IFB_PREVIOUS_PAGE_KBM_ONLY, "-1", KeyCode.PAGE_DOWN, "[[panel_mods_previous_page]]", true);
				}
				if(mcPaginatorController.canGoNextPage())
				{
					(parent as ModMenu).mcInputFeedback.appendButton(IFB_NEXT_PAGE, NavigationCode.GAMEPAD_R1, KeyCode.PAGE_UP, "[[panel_mods_next_page]]", true);
					(parent as ModMenu).mcInputFeedback.appendButton(IFB_NEXT_PAGE_KBM_ONLY, "-1", KeyCode.PAGE_UP, "[[panel_mods_next_page]]", true);
				}
			}

			if (!mcPaginatorController.canGoPreviousPage() && previousButton) 
			{
				(parent as ModMenu).mcInputFeedback.removeButton(IFB_PREVIOUS_PAGE, true);
				(parent as ModMenu).mcInputFeedback.removeButton(IFB_PREVIOUS_PAGE_KBM_ONLY, true);
			}
			if (!mcPaginatorController.canGoNextPage() && nextButton)
			{
				(parent as ModMenu).mcInputFeedback.removeButton(IFB_NEXT_PAGE, true);
				(parent as ModMenu).mcInputFeedback.removeButton(IFB_NEXT_PAGE_KBM_ONLY, true);
			}
			
		}

		protected function setupPaginatorBindingsOnModMenu():void
		{
			(parent as ModMenu).mcInputFeedback.appendButton(IFB_SELECT_PAGE, NavigationCode.GAMEPAD_A, KeyCode.SPACE, "[[panel_button_common_select]]", true);
			recalibratePaginatorBindings();
		}

		protected function clearPaginatorBindingsOnModMenu():void
		{
			(parent as ModMenu).mcInputFeedback.removeButton(IFB_PREVIOUS_PAGE, false);
			(parent as ModMenu).mcInputFeedback.removeButton(IFB_PREVIOUS_PAGE_KBM_ONLY, false);
			(parent as ModMenu).mcInputFeedback.removeButton(IFB_NEXT_PAGE, false);
			(parent as ModMenu).mcInputFeedback.removeButton(IFB_NEXT_PAGE_KBM_ONLY, false);
			(parent as ModMenu).mcInputFeedback.removeButton(IFB_SELECT_PAGE, true);
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
			mcMainListModule.validateNow();
		}

		protected function sendSearchDataToWS(ev : W3TextInputEvent):void
		{
			var text : String = ev.text;
			var words : Array = [];

			words = text.split(" ");

			//#LT: this is yuck, but easier here than in WS...
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSearchInputClear", [1] ) );
			for each(var word:String in words)
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnSearchInputAddWord", [1, word] ) );

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSearchInputTextFinalized", [1] ) );
		}

		protected function clearPreviousObject(mouseOrigin:Boolean = false):void
		{
			//Handling previous object clear	
			if(currentObj == mcPaginatorController)
			{
				clearPaginatorBindingsOnModMenu();
				mcPaginatorController.onLeave();
			}
			else if (currentObj == mcQuickButtonBar)
			{
				mcQuickButtonBar.deselect();
				ModMenu(parent).clearTabControlBindings();
			}
			else if (currentObj == inpSearchInput)
			{
				inpSearchInput.focused = 0;
				stage.focus = parent;
				(parent as ModMenu).mcInputFeedback.removeButton(IFB_ENTER_TEXT, true);
			}
			else if(currentObj == mcModList)
			{
				deselectAllPreviews();
				ModMenu(parent).clearModBindings();
				ModMenu(parent).clearTabControlBindings();
				ModMenu(parent).clearModListBindings();
				ModMenu(parent).clearVoteFeedback();
			}
			else if(currentObj == mcMainListModule)
			{
				dropdownUnselect();
			}
		}

		protected function setupNewObject(mouseOrigin:Boolean = false):void
		{
			//Handling new object setup
			if(currentObj == mcPaginatorController)
			{
				setupPaginatorBindingsOnModMenu();
				if(!mouseOrigin)
					mcPaginatorController.onEnter();
			}
			else if (currentObj == mcQuickButtonBar)
			{
				mcQuickButtonBar.onSelect();
				ModMenu(parent).setupTabControlBindings();
			}
			else if (currentObj == inpSearchInput)
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
			else if(currentObj == mcModList)
			{
				ModMenu(parent).setupModBindings();
				if(_selectedPreviewColumnIndex == -1 || mcModList.selectedIndex == -1)
				{
					selectDefaultElement();
				}
				if(!mouseOrigin)
					highlightSelectedRenderer();
				ModMenu(parent).setupTabControlBindings();
				ModMenu(parent).setupModListBindings();
			}
			else if (currentObj == mcMainListModule)
			{
				if(!mouseOrigin)
					dropdownSelect();
				showFilters();
			}
		}


		protected function onModuleMouseClick(event:MouseEvent)
		{
			//trace("GFX",this,"onModuleMouseClick");
			var currentTarget : MovieClip = event.currentTarget as MovieClip;
			if(currentTarget) {
				if(currentTarget != mcMainListModule && currentObj == mcMainListModule)
				{
					dropdownUnselect();
				}
				swapCurrentObject(currentTarget, true);
			}
		}

		protected function swapCurrentObject(newObj:MovieClip, mouseOrigin:Boolean = false)
		{
			if(currentObj == newObj)
				return;

			/*if(currentObj && newObj)
				trace("GFX - BrowsePage - Swap:",currentObj.name,newObj.name);
			else
				trace ("GFX - Browsepage - Swap unnamed");

			trace("GFX - Swap: Mouse:",mouseOrigin);*/

			if((currentObj == mcMainListModule || currentObj == inpSearchInput)
				&& newObj != mcMainListModule && newObj != inpSearchInput)
				hideFilters();

			clearPreviousObject(mouseOrigin);

			currentObj = newObj;

			setupNewObject(mouseOrigin);
		}

		private function setupPreviewMouseHandling():void
		{
			var previews : Vector.<ModPreview> = getPreviews();

			for(var i : int = 0; i < previews.length; i++)
			{
				previews[i].doubleClickEnabled = true;
				previews[i].addEventListener(MouseEvent.CLICK,onPreviewMouseClick, false, -1);
				previews[i].addEventListener(MouseEvent.DOUBLE_CLICK,onPreviewDoubleClick, false, -1);
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
					mcModList.selectedIndex = _lastMouseOveredItem;
				}
			}
			else
			{
				if (mcModList.selectedIndex == -1)
				{
					mcModList.selectedIndex = 0;
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
				onPreviewDoubleClick(event);
				return;
			}

			var currentTarget:ModPreview = event.currentTarget as ModPreview;
			if(currentTarget)
			{
				var line : ModPreviewLine = currentTarget.parent as ModPreviewLine;
				if(currentObj != mcModList)
					swapCurrentObject(mcModList,true);
				_selectedPreviewColumnIndex = currentTarget.columnIndex;
				mcModList.selectedIndex = line.index;
				mcModList.validateNow();
				deselectAllPreviews();
				line.selectPreview(currentTarget.columnIndex);
				ModMenu(parent).handleModListBindings();
				//currentTarget.onSelect();
				
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
			}
 		}

		private function onPreviewDoubleClick(event:MouseEvent):void
		{
			//trace("GFX ------------- ONPREVIEWDOUBLECLICK",event.currentTarget);
			var currentTarget:ModPreview = event.currentTarget as ModPreview;
			if(currentTarget)
			{
				ModMenu(parent).requestModDetails(currentTarget.getModid(), this);
				event.stopImmediatePropagation();
			}
		}

		protected function selectDefaultElement():void
		{
			swapCurrentObject(mcModList);
			deselectAllPreviews();
			mcModList.selectedIndex = 0;
			mcModList.validateNow();
			
			var previewLine:ModPreviewLine = mcModList.getRendererAt(0) as ModPreviewLine;
			previewLine.selectPreview(0);
			_selectedPreviewColumnIndex = 0;
		}

		protected function handleDown(event:InputEvent):void
		{
			var tempRenderer : W3DropdownMenuListItem;
			if(currentObj == mcModList)
			{
				if(mcModList.selectedIndex < mcModList.dataProvider.length - 1)
				{
					mcModList.selectedIndex++;
					mcModList.validateNow();
					highlightSelectedRenderer();
				}
				else {
					swapCurrentObject(mcPaginatorController);
				}
				event.handled = true;
			}
			else if (currentObj == mcQuickButtonBar)
			{
				swapCurrentObject(mcModList);
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
			else if (isCurrentObjUnhandled())
			{
				selectDefaultElement();

				event.handled = true;
			}
		}

		protected function handleUp(event:InputEvent):void
		{
			if(currentObj == mcModList)
			{
				if(mcModList.selectedIndex > 0)
				{
					mcModList.selectedIndex--;
					mcModList.validateNow();
					highlightSelectedRenderer();
				}
				else
				{
					swapCurrentObject(mcQuickButtonBar);
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
			else if(currentObj == mcPaginatorController)
			{
				swapCurrentObject(mcModList);
				var nIndex : int = mcModList.getRenderers().length - 1 + mcModList.getRenderers()[0].index; 
				mcModList.selectedIndex = nIndex;
				mcModList.validateNow();
				//trace("GFX NINDEX SEL", nIndex, mcModList.selectedIndex);
				highlightSelectedRenderer();
				event.handled = true;
			}
			else if (currentObj == mcMainListModule)
			{
				var tempRenderer : W3DropdownMenuListItem;
				var index = mcMainListModule.mcDropDownList.selectedIndex;
				tempRenderer = mcMainListModule.mcDropDownList.getRendererAt( index ) as W3DropdownMenuListItem;
				lastDropdownElemIndex = tempRenderer.selectedIndex;

				if(mcMainListModule.mcDropDownList.selectedIndex == 0 && tempRenderer.selectedIndex == -1 && event.details.value != InputValue.KEY_HOLD)
				{
					swapCurrentObject(inpSearchInput);
					event.handled = true;
				}
			}
			else if (isCurrentObjUnhandled())
			{
				selectDefaultElement();

				event.handled = true;
			}
		}

		protected function handleLeft(event:InputEvent):void
		{
			if(currentObj == mcModList)
			{
					//TODO at == 0 it goes to filters
				if(_selectedPreviewColumnIndex == 0) {
					swapCurrentObject(mcMainListModule);
					event.handled = true;
					return;
				}
				if(_selectedPreviewColumnIndex > 0) 
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
					_selectedPreviewColumnIndex--;
				}
				highlightSelectedRenderer();
				event.handled = true;
			}
			else if(currentObj == mcQuickButtonBar)
			{
				if(mcQuickButtonBar.selectLeft())
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
				}
			}
			else if(currentObj == mcPaginatorController)
			{
				mcPaginatorController.onLeft();
				event.handled = true;
			}
			else if (isCurrentObjUnhandled())
			{
				selectDefaultElement();

				event.handled = true;
			}
		}

		protected function handleRight(event:InputEvent):void
		{
			if(currentObj == mcModList)
			{
				var firstIndex:int = mcModList.getRenderers()[0].index;
				var selectedRenderer : ModPreviewLine = mcModList.getRendererAt(mcModList.selectedIndex - firstIndex) as ModPreviewLine;
				var maxRight = selectedRenderer.getPreviewCount();
				if(_selectedPreviewColumnIndex > -1)
				{
					if(_selectedPreviewColumnIndex < maxRight - 1) {
						_selectedPreviewColumnIndex++;
						dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
					}
					else if(_selectedPreviewColumnIndex > maxRight - 1)
						_selectedPreviewColumnIndex = 0;
				}
				highlightSelectedRenderer();
				event.handled = true;
			}
			else if(currentObj == mcQuickButtonBar)
			{
				if(mcQuickButtonBar.selectRight())
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
				}
			}
			else if(currentObj == mcPaginatorController)
			{
				mcPaginatorController.onRight();
				event.handled = true;
			}
			else if (currentObj == mcMainListModule || currentObj == inpSearchInput)
			{
				swapCurrentObject(mcModList);
				event.handled = true;
			}
			else if (isCurrentObjUnhandled())
			{
				selectDefaultElement();

				event.handled = true;
			}
		}

		protected function handleInputNavigate(event:InputEvent):void
		{	
			if(_markedForDetransition || ModMenu(parent).isModOpen() || ModMenu(parent).isInputBeingBlocked())
				return;

			if(!initFinished) //#LT prevents funny stretched mod bug
				return;

			/*trace("GFX - ModMenuBrowsePage - handleInputNavigate", event.handled, event);
			if(currentObj)
				trace("GFX - Browse - input currentObj",currentObj.name);
			trace("GFX - Browse - input columnIndex", _selectedPreviewColumnIndex);
			trace("GFX - Browse - input modlistindex",mcModList.selectedIndex);*/

			if(!visible)
				return;

			var details:InputDetails = event.details;

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var hold:Boolean = details.value == InputValue.KEY_HOLD;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
			var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;

			var mainIndex : int;
			var subIndex : int;

			mainIndex = mcMainListModule.mcDropDownList.selectedIndex;
			var subRenderer = W3DropdownMenuListItem(mcMainListModule.mcDropDownList.getRendererAt( mcMainListModule.mcDropDownList.selectedIndex ))
			
			if(subRenderer)
				subIndex = subRenderer.selectedIndex;


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
				else if (details.navEquivalent == NavigationCode.LEFT && (keyDown || hold))
				{
					handleLeft(event);
				}
				else if (details.navEquivalent == NavigationCode.RIGHT && (keyDown || hold))
				{
					handleRight(event);
				}

				if(event.handled)
					return;

				if ((details.navEquivalent == NavigationCode.GAMEPAD_A || details.code == KeyCode.SPACE) && keyUp)
				{
					if(currentObj == mcPaginatorController) {
						mcPaginatorController.onHit();
						event.handled = true;
						return;
					}
					else if (currentObj == mcMainListModule)
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
					else if (currentObj == mcQuickButtonBar)
					{
						mcQuickButtonBar.onHitButton();
						if(mcQuickButtonBar.getLastSelectedButtonIndex() == 0)
							mcQuickButtonBar.deselect();
						event.handled = true;
						return;
					}
				}
				if ((details.navEquivalent == NavigationCode.GAMEPAD_START && keyDown) || (details.code == KeyCode.T && keyUp))
				{
					if(currentObj == mcModList)
					{
						var lineRenderer : ModPreviewLine = mcModList.getRendererAt(mcModList.selectedIndex) as ModPreviewLine;
						var preview : ModPreview = lineRenderer.getPreviews()[_selectedPreviewColumnIndex]
						ModMenu(parent).requestModDetails(preview.getModid(), this);
						event.handled = true;
						return;	
					}
				}
				if (keyUp &&
					((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X) ||		// Y on switch
					(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y) ||		// X on other platforms
					details.code == KeyCode.R))
				{
					if(currentObj == mcModList)
					{
						var lineRenderer2 : ModPreviewLine = mcModList.getRendererAt(mcModList.selectedIndex) as ModPreviewLine;
						var preview2 : ModPreview = lineRenderer2.getPreviews()[_selectedPreviewColumnIndex]
						ModMenu(parent).openSandwichPanel(preview2.getData())
						event.handled = true;
						return;	
					}
				}
				if ((details.navEquivalent == NavigationCode.GAMEPAD_L1 || details.code == KeyCode.PAGE_DOWN) && keyUp)
				{
					if((currentObj == mcPaginatorController || details.code == KeyCode.PAGE_DOWN) && mcPaginatorController.canGoPreviousPage())
					{
						mcPaginatorController.goPreviousPage();
						event.handled = true;
						return;	
					}
				}
				if ((details.navEquivalent == NavigationCode.GAMEPAD_R1 || details.code == KeyCode.PAGE_UP) && keyUp)
				{
					if((currentObj == mcPaginatorController || details.code == KeyCode.PAGE_UP) && mcPaginatorController.canGoNextPage())
					{
						mcPaginatorController.goNextPage();
						event.handled = true;
						return;	
					}
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
				if (((isSwitch2Mouser && details.navEquivalent == NavigationCode.GAMEPAD_L1) ||
					(!isSwitch2Mouser && details.navEquivalent == NavigationCode.GAMEPAD_R2) ||
					details.code == KeyCode.T || details.code == KeyCode.ENTER) && keyUp)
				{
					if(currentObj == mcMainListModule || currentObj == inpSearchInput)
					{
						onApplyFilters();
						event.handled = true;
						return;	
					}
				}
				if (keyUp &&
					(details.navEquivalent == NavigationCode.GAMEPAD_R3 ||
					details.code == KeyCode.F))
				{
					onFilterToggle();
					event.handled = true;
					return;	
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
				swapCurrentObject(mcModList);
				hideFilters();
			}
			else
				showFilters();
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
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnResetFilters", [1]) );
		}


		protected function onApplyFilters():void
		{
			cacheDropdownIndexes();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnApplyFilters", [1]) );
		}

		
		protected function isCurrentObjUnhandled():Boolean
		{
			return currentObj != mcModList 
			&& currentObj != mcPaginatorController 
			&& currentObj != mcMainListModule 
			&& currentObj != inpSearchInput
			&& currentObj != mcQuickButtonBar;
		}

		public function getCurrentObj():MovieClip
		{
			return currentObj;
		}

		public function handleSelectChange(event:ListEvent):void
		{	
			var tempRenderer : W3DropdownMenuListItem;
			var index = mcMainListModule.mcDropDownList.selectedIndex;

			if (index != -1)
			{
				tempRenderer = mcMainListModule.mcDropDownList.getRendererAt( index ) as W3DropdownMenuListItem;
				lastDropdownElemIndex = tempRenderer.selectedIndex;
				_lastSelectedDropdownIndex =  mcMainListModule.mcDropDownList.selectedIndex;
			}
		}

		private function handleItemDoubleClick(event:ListEvent):void
		{
			if (event.itemRenderer is ModFilterItemRenderer)
			{
				ModFilterItemRenderer(event.itemRenderer).onEnabledChange();
			}
		}

		///////////////////////////////////////////////////////////////////////////////
		// MISC
		///////////////////////////////////////////////////////////////////////////////

		public function  /* WitcherScript */ updateProgressBar(modid:String, stage:int, progress:Number):void
		{
			var data:DataProvider = mcModList.dataProvider as DataProvider;
			
			if(stage == 1 || stage == 2)
				ModMenu(parent).startLoadingIndicator(modid);

			for(var lineIndex : int = 0; lineIndex < mcModList.dataProvider.length; lineIndex++)
			{
				var lineData : Array = mcModList.dataProvider[lineIndex].modArray;

				for(var index : int = 0; index < lineData.length; index++)
				{
					var line : ModPreviewLine = renderers[lineIndex] as ModPreviewLine;
					var preview : ModPreview = line.getPreviews()[index];

					if(modid == lineData[index].modid)
					{
						if(stage == 1 || stage == 2)
						{
							data[lineIndex].modArray[index].state = 200; //ModPreview.DL_STATE_SUBSCRIBED;
							data[lineIndex].modArray[index].percent = (int)(100 * progress);
							//data.invalidate();
							mcModList.dataProvider = data;
							preview.updateState(0, (int)(100 * progress));
							if(stage == 2 && progress >= 0.995) // #LT hack to update state to subscribed when almost extracted
							{	
								ModMenu(parent).stopLoadingIndicator(modid);
								preview.updateState(200, 1);
								ModMenu(parent).handleModListBindings();
							}
							return;
						}
						else
						{
							data[lineIndex].modArray[index].state = -1; //ModPreview.DL_STATE_UNSUBSCRIBED;
							data[lineIndex].modArray[index].percent = 0;
							mcModList.dataProvider = data;
							preview.updateState(-1, 0);
							ModMenu(parent).handleModListBindings();
						}
					}
				}
			}
			//mcModList.invalidateData();
			//mcModList.validateNow();
		}


		private function getPreviews():Vector.<ModPreview>
		{
			var previews : Vector.<ModPreview> = new Vector.<ModPreview>();

			for(var i:int = 0; i < renderers.length; i++)
			{
				var line:ModPreviewLine = renderers[i] as ModPreviewLine;
				var prevs:Vector.<ModPreview> = line.getPreviews();
				for(var j:int = 0; j < prevs.length; j++)
					previews.push(prevs[j]);
			}

			return previews;
		}

		private function deselectAllPreviews():void
		{
			var previews : Vector.<ModPreview> = getPreviews();
			for(var i : int = 0; i < previews.length; i++)
			{
				previews[i].deselect();
			}
		}

		protected function highlightSelectedRenderer()
		{
			var selectedIndex:int = mcModList.selectedIndex;
			var selectedRenderer:ModPreviewLine = null;

			if(mcModList.getRenderers().length > 0)
			{
				var firstIndex:int = mcModList.getRenderers()[0].index;
				selectedRenderer = mcModList.getRendererAt(selectedIndex - firstIndex) as ModPreviewLine;
				_lastMouseOveredItem = selectedIndex - firstIndex;
			}
			if(selectedRenderer != null)
			{
				//trace("GFX highlightSelectedRenderer SR", selectedRenderer.name, selectedRenderer, selectedRenderer.index, selectedIndex, mcModList.selectedIndex);
				deselectAllPreviews();
				_selectedPreviewColumnIndex = Math.min(_selectedPreviewColumnIndex, selectedRenderer.getPreviewCount() - 1);
				selectedRenderer.selectPreview(_selectedPreviewColumnIndex);
			}
			ModMenu(parent).handleModListBindings();
		}

		public function getSelectedRenderer():ModPreview
		{
			var selectedLine:ModPreviewLine = null;
			var selectedIndex:int = mcModList.selectedIndex;
			if(mcModList.getRenderers().length > 0)
			{
				var firstIndex:int = mcModList.getRenderers()[0].index;
				selectedLine = mcModList.getRendererAt(selectedIndex - firstIndex) as ModPreviewLine;
			}
			if(selectedLine != null)
			{
				_selectedPreviewColumnIndex = Math.min(_selectedPreviewColumnIndex, selectedLine.getPreviewCount() - 1);
				return selectedLine.getPreviews()[_selectedPreviewColumnIndex];
			}
			return null;
		}

	}
}