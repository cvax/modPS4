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
	
	public class PhotomodePropList extends UIComponent
	{
		public var tfSelectedItemName : TextField;	
		public var tfSelectedItemText : TextField;	

		public var mc_PropCatSelector : PhotomodeSelectorRenderer;

		public var mcPropSlotList : SlotsListGrid;
		private var currentSelectedEnity : String;

		public var mc_topselection : MovieClip;
		public var mc_botselection : MovieClip;

		public var mcGridMask : MovieClip;

		private var _selectionIndex : int;
		private var _listSelectionIndex : int;
		private var _listCount : int;

		public var onThisList : Boolean;

		public function PhotomodePropList() 
		{
            super();
        }

		override protected function configUI():void
		{
			super.configUI();

			mc_PropCatSelector.setDropDownBackgroundVisible(false);
			mc_PropCatSelector.visible = false;

			SetupPropsSlots();

			dispatchEvent( new GameEvent( GameEvent.REGISTER, "photomode.props.filter", [fillPropFilter] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "photomode.props.list.update", [ updatePropsList ] ) );

			tfSelectedItemText.text = "[[photomode_proplist_selectedprop]]";
			updateSelectedText("[[photomode_proplist_selectedprop_none]]");

			mcGridMask.visible = true;
			mcPropSlotList.mask = mcGridMask;

			selectTab(0);

			this.removeEventListener(InputEvent.INPUT, handleInput);
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
		}

		public function SetupPropsSlots()
		{
			if (mcPropSlotList)
			{
				mcPropSlotList.enableTouch( true );
				mcPropSlotList.enableScrollWithPan( true );
				mcPropSlotList.focusable = true;
				mcPropSlotList.visible = true;
				mcPropSlotList.handleScrollBar = true;
				mcPropSlotList.ignoreGridPosition = true;
				mcPropSlotList.addEventListener(ListEvent.ITEM_CLICK, onListClick, false, 0, true );
	
				_listSelectionIndex = 0;
				
				updateListSelectionUI();
			}
		}

		public function updateListSelectionUI()
		{
			var selectedItem:PhotomodeGridSlot = mcPropSlotList.getRendererAt(_listSelectionIndex) as PhotomodeGridSlot;

			updateSelectedText(selectedItem.displayName);
			currentSelectedEnity = selectedItem.entityName;

			mcPropSlotList.focused = _listSelectionIndex;
			mcPropSlotList.selectedIndex = _listSelectionIndex;
			mcPropSlotList.findSelection();
			mcPropSlotList.validateNow();
		}

		public function updateSelectedText(newText : String): void
		{
			tfSelectedItemName.text = newText;
		}

		protected function onListClick( event : ListEvent ):void
		{
			var selectedItem:PhotomodeGridSlot = mcPropSlotList.getRendererAt(event.index) as PhotomodeGridSlot;
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
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnSelectPropFromList",[currentSelectedEnity , selectedItem.iconPath, _listSelectionIndex] ) );	
			}	
		}

		// created for calling from .ws scripts
		public function fillPropFilter(obj : Object) : void
		{
			var sliderModel : PhotomodeSliderDataModel = new PhotomodeSliderDataModel();
			var dataObj : Object = { data: obj[0] }; 

			sliderModel.setDataModel.apply(sliderModel, obj[0].args);
			dataObj["sliderData"] = sliderModel;
						
			mc_PropCatSelector.setData(dataObj);
		}
		
		protected function updatePropsList(itemsList:Array):void
		{		
			_listCount = itemsList.length;
		
			for each (var curDataStub in itemsList)
			{
				mcPropSlotList.updateItemData(curDataStub);
			}

			mcPropSlotList.calculateColumnsAndRows(itemsList.size);
		}

		public function /*WS*/ setCurrentProp(index:int)
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
			var selectedItem:PhotomodeGridSlot = mcPropSlotList.getRendererAt(_listSelectionIndex) as PhotomodeGridSlot;
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSelectPropFromList",[currentSelectedEnity , selectedItem.iconPath, _listSelectionIndex] ) );
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
				mc_PropCatSelector.moveValueLeft(1);
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
				mc_PropCatSelector.moveValueRight(1);
			}

			else if(_selectionIndex == 1)
			{
				if(_listSelectionIndex < _listCount -1)
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