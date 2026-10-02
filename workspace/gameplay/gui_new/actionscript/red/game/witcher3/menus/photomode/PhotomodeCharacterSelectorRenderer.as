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
	
	public class PhotomodeCharacterSelectorRenderer extends PhotomodeRenderer
	{	
		public var m_txtLabel : TextField;
		
		public var mc_CharSlot1 : PhotomodeCharacterSelectorSlot;
		public var mc_CharSlot2 : PhotomodeCharacterSelectorSlot;
		public var mc_CharSlot3 : PhotomodeCharacterSelectorSlot;

		private var _disabled : Boolean = false;
		private var _callbackFunctionName : String;
		private var _callbackDelay : Number;
		private var _selectedSlotID : int;

		public function PhotomodeCharacterSelectorRenderer() 
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
			
			mc_CharSlot1.InitializePhotomodeCharacterSelectorSlot(this , 0 , dataModel.slotData[0].spawnableName , dataModel.slotData[0].iconPath);
			mc_CharSlot2.InitializePhotomodeCharacterSelectorSlot(this , 1 , dataModel.slotData[1].spawnableName , dataModel.slotData[1].iconPath);
			mc_CharSlot3.InitializePhotomodeCharacterSelectorSlot(this , 2 , dataModel.slotData[2].spawnableName , dataModel.slotData[2].iconPath);
			
			_selectedSlotID = dataModel.currentSlotId;
			updateSlotSelection();

			// CommonUtils.traceCallstack("====================== photomode setData char [" + _selectedSlotID + "]");
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
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnCharSlotSelect", [ _selectedSlotID ] ) );
		}

		public function updateSlotSelection()
		{
			mc_CharSlot1.deselectSlot();
			mc_CharSlot2.deselectSlot();
			mc_CharSlot3.deselectSlot();

			switch (_selectedSlotID)
			{
				case 0:
					mc_CharSlot1.selectSlot();
					break;
				case 1:
					mc_CharSlot2.selectSlot();
					break;
				case 2:
					mc_CharSlot3.selectSlot();
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
			if(_selectedSlotID == 2)
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
				_selectedSlotID = 2;
				
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
			trace("Debug UI Select enter render");
		}
	}
}