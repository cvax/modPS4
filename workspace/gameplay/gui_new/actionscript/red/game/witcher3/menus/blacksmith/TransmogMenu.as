package red.game.witcher3.menus.blacksmith 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.utils.Timer;		
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.CoreMenuModule;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.EInputDeviceType;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.managers.ContextInfoManager;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.character_menu.CharacterModeBackground;
	import red.game.witcher3.menus.common.CheckboxListMode;
	import red.game.witcher3.menus.common.ModuleMerchantInfo;
	import red.game.witcher3.menus.common.PlayerStatsModule;

	import red.game.witcher3.menus.inventory_menu.InventoryTabbedListModule;
	import red.game.witcher3.menus.inventory_menu.CharacterRendererController;
	import red.game.witcher3.menus.inventory_menu.PlayerDetailedStatsPanel;
	import red.game.witcher3.menus.inventory_menu.PlayerGeneralStatsPanel;
	import red.game.witcher3.menus.inventory_menu.GridTabSections;
	import red.game.witcher3.menus.inventory_menu.ItemSectionData;
	import red.game.witcher3.menus.common.ItemDataStub;

	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import red.game.witcher3.slots.SlotPaperdoll;
	import red.game.witcher3.slots.SlotSkillGrid;
	import red.game.witcher3.slots.SlotsListBase;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.slots.SlotsTransferManager;
	
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.core.UIComponent;
	import flash.utils.getDefinitionByName;
	import scaleform.clik.events.ListEvent;
	import red.game.witcher3.events.ItemDragEvent;
	import flash.events.GestureEvent;
	import red.core.events.GestureEventEx;
	import flash.utils.setTimeout;
	import flash.events.TransformGestureEvent;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.data.KeyBindingData;
	

	public class TransmogMenu extends CoreMenu
	{
		//private var mcContainerGridModule	: ModuleContainer;
		//public var mcPlayerInventory		: InventoryTabbedListModule;
		
		public var mcPlayerGridModuleRight	:	ModuleBlacksmithGrid;
		public var mcTransmogVis 			: 	ModuleTransmogVis;
		public var mcTabHandler				:	ModuleTransmogTabHandler;

		public var moduleMerchantInfo		: ModuleMerchantInfo;

		public var txtPriceLabel	: TextField;
		public var txtPriceValue	: TextField;

		public var mcCharacterModelAnchor	: MovieClip;
		public var mcCharacterRenderer		: MovieClip;
		public var mcTransmogBackground 	: MovieClip;

		public var btnExecute:			InputFeedbackButtonCustom;
		
		public var tooltipAnchor		: DisplayObject;
		public var dataStub 		: ItemDataStub;

		private var _rendererController     : CharacterRendererController;

		private const TICK_DELAY:int = 100;
		private var _timer : Timer;
	
		private var _blockItemSelectionOnGeneration : Boolean;
		private var _blockAppearSelectionOnGeneration : Boolean;


		public function TransmogMenu() 
		{
			setupCharacterRender();

			txtPriceLabel.text = "[[panel_inventory_item_price]]";
			txtPriceLabel.text = CommonUtils.toUpperCaseSafe(txtPriceLabel.text);

			trace("DebugTransmog TransmogMenu");	
		}

		override protected function configUI():void 
		{
			super.configUI();

			trace("DebugTransmog configUI");
		
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "blacksmith.merchant.info", [setMerchantInfo] ) );

			dispatchEvent( new GameEvent( GameEvent.REGISTER, "transmog.appear.list.update", [updateTransmogAppearList] ) );

			dispatchEvent( new GameEvent( GameEvent.REGISTER, "transmog.appear.grid.section", [setAppearSectionsList] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "transmog.appear.price.update", [setPriceValue] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "transmog.appear.index", [setAppearIndex] ) );

			var inputMgr:InputManager = InputManager.getInstance();
			inputMgr.addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);

			_contextMgr.defaultAnchor = tooltipAnchor;
			_contextMgr.addGridEventsTooltipHolder(stage);

			stage.removeEventListener(InputEvent.INPUT, mcPlayerGridModuleRight.handleInput, false);
			//stage.addEventListener( InputEvent.INPUT, handleInputNavigate, false, 10, true );
			
			currentModuleIdx = 0;
							
			mcPlayerGridModuleRight.mcPlayerGrid.addEventListener(ListEvent.INDEX_CHANGE, onTransmogAppearSelected, false, 0 , true);
			mcPlayerGridModuleRight.active = true;
			mcPlayerGridModuleRight.autoGridFocus = true;
			mcPlayerGridModuleRight.focusable = true;
			mcPlayerGridModuleRight.focused = 0;
	
			SlotsTransferManager.getInstance().disabled = true;
			SlotsTransferManager.getInstance().enableDragWithPan( false );

			//delayed click auto selection
			mcPlayerGridModuleRight.addEventListener( MouseEvent.MOUSE_DOWN, handleGridModuleClick, false, -99, true );
			mcPlayerGridModuleRight.mcPlayerGrid.addEventListener( SlotsListBase.EVENT_SELECTED_TAPPED, onSlotItemTappedTwice, false, 0, true );

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );

			setupTransmogExecuteBtn();

			InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.LEFT_MOUSE, "panel_button_reforge_appearance", false);
			InputFeedbackManager.updateButtons(this);
		}

		protected function handleGridModuleClick(event:MouseEvent):void
		{
			var module : UIComponent = event.currentTarget as UIComponent;

			var otherModule = module == mcPlayerGridModuleRight ? mcTabHandler : mcPlayerGridModuleRight;
			if (module == mcPlayerGridModuleRight)
				onConfirmTransmogAppearance(true);

			otherModule.focused = 0;
			module.focused = 1;
		}

		public function setupTransmogExecuteBtn(): void
		{			
			if (btnExecute)
			{
				btnExecute.addEventListener(ButtonEvent.CLICK, handleExecuteTransmogClick, false, 0, true);
				btnExecute.addEventListener(GestureEventEx.GESTURE_TAP, handleExecuteTransmogClick, false, 0, true);

				var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

				btnExecute.label = "[[panel_button_confirm_reforge]]";
				btnExecute.setDataFromStage(isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, KeyCode.Y);
				btnExecute.visible = true;
				btnExecute.validateNow();
				
				invalidateSize();
			}
		}

		override protected function handleInputNavigate(event:InputEvent):void
		{	
			//if ( event.handled ) return;
			
			var details:InputDetails = event.details;

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;		

			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

			if((!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y && keyUp)	
				|| (isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X && keyUp)	
				|| (details.code == KeyCode.Y && keyUp))
			{
				doMainAction();
			}
			else if((details.navEquivalent == NavigationCode.GAMEPAD_A && keyUp)	
				|| (details.code == KeyCode.E && keyUp))
			{
				doSelectAction();
			}

			if (mcTabHandler.focused || details.navEquivalent == NavigationCode.GAMEPAD_L2 || details.navEquivalent == NavigationCode.GAMEPAD_R2)
			{
				mcTabHandler.handleInputAlt(event);

				if(!event.handled && (details.navEquivalent == NavigationCode.DOWN || details.navEquivalent == NavigationCode.RIGHT_STICK_DOWN) && keyDown)
				{
					mcTabHandler.focused = 0;
					mcPlayerGridModuleRight.focused = 1;		
					event.handled = true;			
				}
			}
			else if(mcPlayerGridModuleRight.focused)
			{
				mcPlayerGridModuleRight.handleInput(event);

				if(!event.handled && (details.navEquivalent == NavigationCode.UP || details.navEquivalent == NavigationCode.RIGHT_STICK_UP) && keyDown)
				{
					mcPlayerGridModuleRight.focused = 0;
					mcTabHandler.focused = 1;
					event.handled = true;
				}
			}

			if(details.navEquivalent == NavigationCode.RIGHT_STICK_LEFT || details.navEquivalent == NavigationCode.RIGHT_STICK_RIGHT)
			{
				//prevent default module handling
				event.handled = true;
			}

			if(!event.handled)
			{
				super.handleInputNavigate(event);
			}

		}

		private function fixExtraHighlightHack():void
		{
			if(!mcPlayerGridModuleRight.focused)
			{
				var slot : SlotInventoryGrid = mcPlayerGridModuleRight.mcPlayerGrid.getSelectedRenderer() as SlotInventoryGrid;
				slot.activeSelectionEnabled = false;
			}
		}

		private function onSlotItemTappedTwice( event : Event ) : void
		{
			var selected : SlotBase = event.target.getSelectedRenderer() as SlotBase;
			trace( "TransmogMenu::onSlotItemTappedTwice : ", mcPlayerGridModuleRight.hasFocus, selected, event );

			//Since we disabled focus handling (mcPlayerGrid.focusable = false in super) We have to check if we are in focus manually.
			if ( mcPlayerGridModuleRight.hasFocus && selected )
			{
				doSelectAction();
			}
		}

		protected function doSelectAction():void
		{
			{
				onConfirmTransmogAppearance();
			}
		}

		protected function doMainAction():void
		{
			trace("DebugTransmog handleExecuteTransmogClick");
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnRequestConfirmation" ) );
		}

		protected function handleExecuteTransmogClick(event:Event):void
		{	
			doMainAction();
		}

		private function onConfirmTransmogAppearance(fromMouse:Boolean = false):void
		{
			var selectedItem:SlotBase = mcPlayerGridModuleRight.mcPlayerGrid.getSelectedRenderer() as SlotBase;
			var itemData : Object;		

			if(_blockAppearSelectionOnGeneration)
			{
				trace("DebugTransmog onTransmogAppearSelected BLOCKED");
				return;
			}
			
			itemData = selectedItem.data;
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnTransmogAppearSelected", [(uint)(itemData.id)] ) );	

			if(!fromMouse)
			{
			}
		}

		private function onTransmogItemSelected(event:ListEvent):void
		{
			return;			
		}

		private function onTransmogAppearSelected(event:ListEvent):void
		{	
			return;
		}

		private var _fistInitDone 	: 	Boolean;

		//transmog.appear.list.update
		public function updateTransmogAppearList(itemsList:Array):void
		{			
			//aggressively removing selections because I am mad at them
			var rCount : int = mcPlayerGridModuleRight.mcPlayerGrid.getRenderersCount()

			for(var i : int = 0; i < rCount * 2; i++) //2 because each item has 2 brev
			{
				var renderer : SlotInventoryGrid = mcPlayerGridModuleRight.mcPlayerGrid.getRendererAt(i) as SlotInventoryGrid;

				if(renderer && renderer.selected)
				{
					renderer.selected = false;
				}
				else if (!renderer)
				{
				}
				else
				{
				}
			}
			_blockAppearSelectionOnGeneration = true;
			mcPlayerGridModuleRight.mcPlayerGrid.removeAllItemData();

			trace("DebugTransmog as updateTransmogAppearList length: " + itemsList.length)
			for each (var curDataStub in itemsList)
			{
				dataStub = curDataStub as ItemDataStub;
				trace("DebugTransmog as updateTransmogAppearList itemName: " + curDataStub.itemName +" grid postion :"+ curDataStub.gridPosition);
					
				mcPlayerGridModuleRight.mcPlayerGrid.updateItemData(curDataStub);
			}

			//#LT not now, don't have time to fix the weird focusing glitch
			mcPlayerGridModuleRight.mcPlayerGrid.ignoreSelectable = true;
			mcPlayerGridModuleRight.mcPlayerGrid.selectedIndex = 0;
			mcPlayerGridModuleRight.mcPlayerGrid.ignoreSelectable = false;
			mcPlayerGridModuleRight.mcPlayerGrid.validateNow();
			_blockAppearSelectionOnGeneration = false;
			fixExtraHighlightHack();

			/*rCount = mcPlayerGridModuleRight.mcPlayerGrid.getRenderersCount()
			for(i = 0; i < rCount; i++)
			{
				renderer = mcPlayerGridModuleRight.mcPlayerGrid.getRendererAt(i) as SlotInventoryGrid;

				if(renderer)
				{
					renderer.activeSelectionEnabled = true;
				}
			}*/
		}		
	
		private function setMerchantInfo(value:Object):void
		{
			trace("DebugTransmog setMerchantInfo");
			moduleMerchantInfo.data = value;
		}
		
		override protected function get menuName():String
		{ 
			return "TransmogMenu";
		}
		
		public function CloseMenu() : void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenu' ) );
		}	
	
		public function setupCharacterRender():void
		{	
			_rendererController = new CharacterRendererController(mcCharacterRenderer, this);

			_rendererController.setCenterAnchor(450, 50);
			_rendererController.setDefaultAnchor(mcCharacterModelAnchor.x, 50);
			_rendererController.addFadeOutComponent(mcPlayerGridModuleRight);

			mcCharacterRenderer.mouseChildren = mcCharacterRenderer.mouseEnabled = true;
			mcCharacterRenderer.mcBackground = mcTransmogBackground;

			mcCharacterRenderer.x = mcCharacterModelAnchor.x;
			mcCharacterRenderer.y = mcCharacterModelAnchor.y;

			// disabled since this is a debug feature / not actually needed in release; uncomment if you wanna test paperdoll animations
			// mcCharacterRenderer.addEventListener(MouseEvent.CLICK, onCharacterRendererClicked, false, 0, true);

			_rendererController.enabled = true;
			mcCharacterRenderer.visible = true;

			registerRenderTarget( "test_nopack", 1024, 1024 );
		}

		private function setAppearSectionsList(value:Array):void
		{
			mcPlayerGridModuleRight.mcPlayerGrid.setItemSections( value );
			mcPlayerGridModuleRight.displaySection( value );
		}

		protected function onCharacterRendererClicked(event:Event):void
		{
			trace("DebugTransmog onCharacterClicked")
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCharacterRendererClicked'));
		}

		public function setPriceValue(value:int):void
		{
			trace("DebugTransmog Price change :" + value);
			txtPriceValue.text = String(value);
		}

		public function setAppearIndex(appearIndex:int):void
		{
			trace("DebugTransmog setAppearIndex :" + appearIndex);
		}

		override protected function handleControllerChanged(event:ControllerChangeEvent):void
		{
			super.handleControllerChanged(event);

			_rendererController.handleControllerChanged(event);
			setupTransmogExecuteBtn();
			
			InputFeedbackManager.updateButtons(this);
		}

		override public function setMenuState(value:String):void
		{
			super.setMenuState(value);
		}
	}		
}


