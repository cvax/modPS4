package red.game.witcher3.menus.photomode 
{
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	import flash.utils.getDefinitionByName;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.controls.ButtonBar;
	import scaleform.clik.events.IndexEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.interfaces.IDataProvider;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.controls.Button;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.text.TextField;
	import flash.display.MovieClip;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import scaleform.clik.events.ListEvent;
	import red.game.witcher3.utils.CommonUtils;
	import flash.events.MouseEvent;
	import scaleform.clik.controls.ScrollBar;
	
	public class PhotomodeCharacterList extends UIComponent
	{			
		public var tfSelectedItemText : TextField;
		public var tfSelectedItemName : TextField;

        public var mc_CharCatSelector : PhotomodeSelectorRenderer;

		public var mcCharacterSlotList : SlotsListGrid;
		private var currentSelectedEnity : String;		

		public var mc_topselection : MovieClip;
		public var mc_botselection : MovieClip;

		public var mcGridMask : MovieClip;

		private var _selectionIndex : int;
		private var _listSelectionIndex : int;
		private var _listCount : int;

		public var onThisList : Boolean;

		public function PhotomodeCharacterList() 
		{
            super();
        }

		override protected function configUI():void
		{
			super.configUI();

			mc_CharCatSelector.setDropDownBackgroundVisible(false);
			mc_CharCatSelector.visible = false;

			SetupCharacterSlots();

			dispatchEvent( new GameEvent( GameEvent.REGISTER, "photomode.character.filter", [fillCharacterFilter] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "photomode.character.list.update", [ updateCharacterList ] ) );

			tfSelectedItemText.text = "[[photomode_charlist_selectedchar]]";
			updateSelectedText("[[photomode_charlist_selectedchar_none]]");

			mcGridMask.visible = true;
			mcCharacterSlotList.mask = mcGridMask;

			selectTab(0);

			this.removeEventListener(InputEvent.INPUT, handleInput);
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
		}

		public function SetupCharacterSlots()
		{
			if (mcCharacterSlotList)
			{
				mcCharacterSlotList.enableTouch( true );
				mcCharacterSlotList.enableScrollWithPan( true );
				mcCharacterSlotList.focusable = true;
				mcCharacterSlotList.visible = true;
				mcCharacterSlotList.handleScrollBar = true;
				mcCharacterSlotList.ignoreGridPosition = true;
				mcCharacterSlotList.addEventListener( ListEvent.ITEM_CLICK, onListClick, false, 0, true );

				_listSelectionIndex = 0;
				
				updateListSelectionUI();
			}
		}

		public function updateListSelectionUI()
		{		
			var selectedItem:PhotomodeGridSlot = mcCharacterSlotList.getRendererAt(_listSelectionIndex) as PhotomodeGridSlot;

			updateSelectedText(selectedItem.displayName);
			currentSelectedEnity = selectedItem.entityName;

			mcCharacterSlotList.focused = _listSelectionIndex;
			mcCharacterSlotList.selectedIndex = _listSelectionIndex;
			mcCharacterSlotList.findSelection();
			mcCharacterSlotList.validateNow();
		}

		public function updateSelectedText(newText : String): void
		{
			tfSelectedItemName.text = newText;
		}

		protected function onListClick( event:ListEvent ):void
		{				
			var selectedItem:PhotomodeGridSlot = mcCharacterSlotList.getRendererAt(event.index) as PhotomodeGridSlot;
			_listSelectionIndex = event.index;
			
			if(_selectionIndex == 0)
			{
				selectTab(1);
			}

			if(currentSelectedEnity != selectedItem.entityName)
			{
				updateSelectedText(selectedItem.displayName);
				currentSelectedEnity = selectedItem.entityName;
			}
			else
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnSelectCharacterFromList",[currentSelectedEnity , selectedItem.iconPath, _listSelectionIndex] ) );	
			}				
		}

		// created for calling from .ws scripts
		public function fillCharacterFilter(obj : Object) : void
		{
			var sliderModel : PhotomodeSliderDataModel = new PhotomodeSliderDataModel();
			var dataObj : Object = { data: obj[0] }; 

			sliderModel.setDataModel.apply(sliderModel, obj[0].args);
			dataObj["sliderData"] = sliderModel;
				
			mc_CharCatSelector.setData(dataObj);
		}

		protected function updateCharacterList(itemsList:Array):void
		{	
			_listCount = itemsList.length;

			for each (var curDataStub in itemsList)
			{					
				mcCharacterSlotList.updateItemData(curDataStub);
			}
		}

		public function /*WS*/ setCurrentCharacter(index:int)
		{
			_listSelectionIndex = index;
			updateListSelectionUI();
		}

		//navigation

		public override function handleInput(event:InputEvent):void 
		{
			var details:InputDetails = event.details;
			
			var keyUp:Boolean = details.value == InputValue.KEY_UP ;
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD; //#B should be also hold here
			
			if(event.handled)
				return;

			if(!onThisList)
				return;
			
			if(!visible || (parent && !parent.visible) 
			|| (parent && parent.parent && !parent.parent.visible)
			|| (parent && parent.parent && parent.parent.parent && !parent.parent.parent.visible))
				return;

			if (keyDown)
			{						
				switch (details.code) 
				{
					case KeyCode.PAD_DIGIT_RIGHT:
							rightKey();
						break;
					case KeyCode.RIGHT:
						if (InputManager.getInstance().isGamepad())
							break;
							rightKey();
						break;
					case KeyCode.PAD_DIGIT_LEFT:
							leftKey();
							break;
					case KeyCode.LEFT:
						if (InputManager.getInstance().isGamepad())
							break;
							leftKey();
						break;
					case KeyCode.PAD_DIGIT_UP:
							upKey();
						break;
					case KeyCode.UP:
						if (InputManager.getInstance().isGamepad())
							break;
							upKey();
						break;
					case KeyCode.PAD_DIGIT_DOWN:
							downKey();
						break;
					case KeyCode.DOWN:
						if (InputManager.getInstance().isGamepad())
							break;			
							downKey();
						break;
					default:
						break;
				}
			}
			else if(keyUp)
			{
				switch (details.code) 
				{
					case KeyCode.ENTER:
						event.handled = true;
						selectCurrent();
						break;	
					default:
						break;
				}

				if(details.navEquivalent == NavigationCode.GAMEPAD_A)
				{
					event.handled = true;
					selectCurrent();
				}
			}		
		}	
		
		public function selectCurrent()
		{
			var selectedItem:PhotomodeGridSlot = mcCharacterSlotList.getRendererAt(_listSelectionIndex) as PhotomodeGridSlot;
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSelectCharacterFromList",[currentSelectedEnity , selectedItem.iconPath, _listSelectionIndex] ) );
		}

		protected function selectTab(index : int)
		{
			_selectionIndex = index;

			if(_selectionIndex == 0)
			{
				mc_topselection.visible = true;
				mc_botselection.visible = false;
			}
			else
			{
				mc_topselection.visible = false;
				mc_botselection.visible = true;
			}
		}

		public function downKey()
		{
			if(_selectionIndex == 0)
			{				
				selectTab(1);
			}
			else if(_selectionIndex == 1)
			{
				if(_listSelectionIndex < _listCount - 10)
				{
					_listSelectionIndex += 10;
					updateListSelectionUI();
				}
			}
		}

		public function upKey()
		{
			if(_selectionIndex == 0)
			{
				return;
			}
			else if(_selectionIndex == 1)
			{					
				if(_listSelectionIndex < 10)
				{
					selectTab(0);					
				}
				else
				{
					_listSelectionIndex -= 10;					
					updateListSelectionUI();
				}			
			}
		}

		public function leftKey()
		{
			if(_selectionIndex == 0)
			{
				mc_CharCatSelector.moveValueLeft(1);
			}

			else if(_selectionIndex == 1)
			{
				if(_listSelectionIndex > 0)
				{
					_listSelectionIndex --;
				}
				else
				{
					_listSelectionIndex = _listCount - 1;
				}

				updateListSelectionUI();
			}	
		}

		public function rightKey()
		{
			if(_selectionIndex == 0)
			{
				mc_CharCatSelector.moveValueRight(1);
			}

			else if(_selectionIndex == 1)
			{
				if(_listSelectionIndex < _listCount - 1)
				{
					_listSelectionIndex ++;
				}
				else
				{
					_listSelectionIndex = 0;
				}

				updateListSelectionUI();
			}
		}
	}
}