
package red.game.witcher3.menus.photomode 
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.controls.Slider;
	import flash.text.TextField;
	import scaleform.clik.data.ListData;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.events.SliderEvent;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import flash.events.KeyboardEvent;
	import red.core.events.GameEvent;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import red.game.witcher3.menus.photomode.PhotomodeSliderDataModel;
	import red.game.witcher3.managers.InputManager;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.utils.CommonUtils;
	
	public class PhotomodePropSelectorRenderer extends PhotomodeRenderer
	{	
		public var m_txtLabel : TextField;
		
		public var mc_PropSlot1 : PhotomodePropSelectorSlot;
		public var mc_PropSlot2 : PhotomodePropSelectorSlot;
		public var mc_PropSlot3 : PhotomodePropSelectorSlot;
		public var mc_PropSlot4 : PhotomodePropSelectorSlot;
		public var mc_PropSlot5 : PhotomodePropSelectorSlot;
		public var mc_PropSlot6 : PhotomodePropSelectorSlot;
		public var mc_PropSlot7 : PhotomodePropSelectorSlot;
		public var mc_PropSlot8 : PhotomodePropSelectorSlot;
		public var mc_PropSlot9 : PhotomodePropSelectorSlot;
		public var mc_PropSlot10 : PhotomodePropSelectorSlot;

		private var _disabled : Boolean = false;
		private var _callbackFunctionName : String;
		private var _callbackDelay : Number;		
		private var _selectedSlotID : int;

		public function PhotomodePropSelectorRenderer() 
		{
            super();
			//preventAutosizing = false;			
        }

        override protected function configUI():void 
		{
			super.configUI();

			mouseEnabled = true;
            mouseChildren = true;
			
			this.removeEventListener(InputEvent.INPUT, handleInput);
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
        }

		public override function onDestroy():void
		{
			stage.removeEventListener(InputEvent.INPUT, handleInput);
		}

		public override function set selected(value:Boolean):void 
		{
            super.selected = value;
			
			if(_disabled)
			{
				gotoAndStop("disabled");
			}
			else if (value)
			{
				gotoAndStop("focused");
				//onSelected();
			}
			else
			{
				gotoAndStop("unfocused");
			}
        }

		public override function set enabled(value:Boolean):void 
		{				
            super.enabled = value;
						
			this.visible = value;

			if(value)
			{
				mouseEnabled = true;
            	mouseChildren = true;
			}
        }

		public function setDisabled(value : Boolean):void
		{
			_disabled = value;
			selected = selected;
		}
        
        public override function setData(data:Object):void 
		{	
			if (data != null)
				super.setData(data);

			if (data == null)
				return;
			
			var dataModel : Object;
			dataModel = data.data.args;

			if (dataModel == null)
				return;

			m_txtLabel.text = dataModel.label;	
			
			mc_PropSlot1.InitializePhotomodePropSelectorSlot(this,0, dataModel.slotData[0].spawnableName , dataModel.slotData[0].iconPath);
			mc_PropSlot2.InitializePhotomodePropSelectorSlot(this,1, dataModel.slotData[1].spawnableName , dataModel.slotData[1].iconPath);
			mc_PropSlot3.InitializePhotomodePropSelectorSlot(this,2, dataModel.slotData[2].spawnableName , dataModel.slotData[2].iconPath);
			mc_PropSlot4.InitializePhotomodePropSelectorSlot(this,3, dataModel.slotData[3].spawnableName , dataModel.slotData[3].iconPath);
			mc_PropSlot5.InitializePhotomodePropSelectorSlot(this,4, dataModel.slotData[4].spawnableName , dataModel.slotData[4].iconPath);
			mc_PropSlot6.InitializePhotomodePropSelectorSlot(this,5, dataModel.slotData[5].spawnableName , dataModel.slotData[5].iconPath);
			mc_PropSlot7.InitializePhotomodePropSelectorSlot(this,6, dataModel.slotData[6].spawnableName , dataModel.slotData[6].iconPath);
			mc_PropSlot8.InitializePhotomodePropSelectorSlot(this,7, dataModel.slotData[7].spawnableName , dataModel.slotData[7].iconPath);
			mc_PropSlot9.InitializePhotomodePropSelectorSlot(this,8, dataModel.slotData[8].spawnableName , dataModel.slotData[8].iconPath);
			mc_PropSlot10.InitializePhotomodePropSelectorSlot(this,9, dataModel.slotData[9].spawnableName , dataModel.slotData[9].iconPath);
			
			_selectedSlotID = dataModel.currentSlotId;
			updateSlotSelection();

			// CommonUtils.traceCallstack("====================== photomode setData prop [" + _selectedSlotID + "]");
        }

		private function onSelected():void
		{
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
		}

		public function onSlotSelect(slotId : int)
		{	
			_selectedSlotID = slotId;
			this.removeEventListener(InputEvent.INPUT, handleInput);
			updateSlotSelection();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnPropSlotSelect", [ _selectedSlotID ] ) );	
		}

		public function updateSlotSelection()
		{			
			mc_PropSlot1.deselectSlot();
			mc_PropSlot2.deselectSlot();
			mc_PropSlot3.deselectSlot();
			mc_PropSlot4.deselectSlot();
			mc_PropSlot5.deselectSlot();
			mc_PropSlot6.deselectSlot();
			mc_PropSlot7.deselectSlot();
			mc_PropSlot8.deselectSlot();
			mc_PropSlot9.deselectSlot();
			mc_PropSlot10.deselectSlot();

			switch (_selectedSlotID)
			{
				case 0:
					mc_PropSlot1.selectSlot();
					break;
				case 1:
					mc_PropSlot2.selectSlot();
					break;
				case 2:
					mc_PropSlot3.selectSlot();
					break;
				case 3:
					mc_PropSlot4.selectSlot();
					break;
				case 4:
					mc_PropSlot5.selectSlot();
					break;
				case 5:
					mc_PropSlot6.selectSlot();
					break;
				case 6:
					mc_PropSlot7.selectSlot();
					break;
				case 7:
					mc_PropSlot8.selectSlot();
					break;
				case 8:
					mc_PropSlot9.selectSlot();
					break;
				case 9:
					mc_PropSlot10.selectSlot();
					break;
			}
		}


		// ---NAVIGATION---
		public override function handleInput(event:InputEvent):void 
		{
			var details:InputDetails = event.details;
			
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD;
			var keyUp:Boolean = details.value == InputValue.KEY_UP ;
			
			if(event.handled)
				return;
			if (!selected)
				return;

			if(!visible || (parent && !parent.visible) 
			|| (parent && parent.parent && !parent.parent.visible)
			|| (parent && parent.parent && parent.parent.parent && !parent.parent.parent.visible))
				return;

			if(keyDown)
			{			
				switch (details.code) 
				{
				case KeyCode.PAD_DIGIT_RIGHT:
					moveSlotRight();
					break;
				case KeyCode.RIGHT:
					if (InputManager.getInstance().isGamepad())
						break;
					moveSlotRight();
					break;
				case KeyCode.PAD_DIGIT_LEFT:
					moveSlotLeft();
						break;
				case KeyCode.LEFT:
					if (InputManager.getInstance().isGamepad())
						break;
					moveSlotLeft();
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
					clickCurrentSelectedSlot();
					break;
				default:
					break;
				}
					
				if(details.navEquivalent == NavigationCode.GAMEPAD_A)
				{
					event.handled = true;
					clickCurrentSelectedSlot();
				}
			}		
		}	

		public function moveSlotRight()
		{
			if(_selectedSlotID == 9)
			{
				_selectedSlotID = 0;
				
			}
			else
			{
				_selectedSlotID ++;
			}
			onSlotSelect(_selectedSlotID);
		}
		
		public function moveSlotLeft()
		{
			if(_selectedSlotID == 0)
			{
				_selectedSlotID = 9;
				
			}
			else
			{
				_selectedSlotID --;
			}
			onSlotSelect(_selectedSlotID);
		}

		public function clickCurrentSelectedSlot()
		{
			onSlotSelect(_selectedSlotID);
		}
	}
}