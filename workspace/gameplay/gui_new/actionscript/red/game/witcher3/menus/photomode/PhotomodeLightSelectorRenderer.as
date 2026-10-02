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
	
	public class PhotomodeLightSelectorRenderer extends PhotomodeRenderer
	{	
		public var m_txtLabel : TextField;
		
		public var mc_LightSlot1 : PhotomodeLightSelectorSlot;
		public var mc_LightSlot2 : PhotomodeLightSelectorSlot;
		public var mc_LightSlot3 : PhotomodeLightSelectorSlot;
		public var mc_LightSlot4 : PhotomodeLightSelectorSlot;
		public var mc_LightSlot5 : PhotomodeLightSelectorSlot;

		private var _disabled : Boolean = false;
		private var _callbackFunctionName : String;
		private var _callbackDelay : Number;
		private var _selectedSlotID : int;

		public function PhotomodeLightSelectorRenderer() 
		{
            super();
			//preventAutosizing = false;
        }

        override protected function configUI():void 
		{
			super.configUI();
		
		
			
			mouseEnabled = true;
            mouseChildren = true;

           	mc_LightSlot1.InitializePhotomodeLightSelectorSlot(this , 0);
			mc_LightSlot2.InitializePhotomodeLightSelectorSlot(this , 1);
			mc_LightSlot3.InitializePhotomodeLightSelectorSlot(this , 2);
			mc_LightSlot4.InitializePhotomodeLightSelectorSlot(this , 3);
			mc_LightSlot5.InitializePhotomodeLightSelectorSlot(this , 4);

			
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
        }

		private function onSelected():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnParameterSelected", [ 0 ] ) );	
		}

		public function onSlotClick(slotId : int)
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnLightSlotSelect", [ slotId ] ) );	
		}

		public function onSlotSelect(slotId : int)
		{	
			_selectedSlotID = slotId;
			updateSlotSelection();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnLightSlotSelect", [ slotId ] ) );	
		}

		public function updateSlotSelection()
		{			
			//mc_LightSlot1.deselectSlot();
			//mc_LightSlot2.deselectSlot();
			//mc_LightSlot3.deselectSlot();
			//mc_LightSlot4.deselectSlot();
			//mc_LightSlot5.deselectSlot();

			switch (_selectedSlotID)
			{
				case 0:
					//mc_LightSlot1.selectSlot();
					break;
				case 1:
					//mc_LightSlot2.selectSlot();
					break;
				case 2:
					//mc_LightSlot3.selectSlot();
					break;
				case 3:
					//mc_LightSlot4.selectSlot();
					break;
				case 4:
					//mc_LightSlot5.selectSlot();
					break;
			}
		}
///NAVIGATION
		public override function handleInput(event:InputEvent):void 
		{
			var details:InputDetails = event.details;
			
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD; //#B should be also hold here
			if (!keyDown)
				return;
				
			if (!selected)
				return;

			if(!visible || (parent && !parent.visible) 
			|| (parent && parent.parent && !parent.parent.visible)
			|| (parent && parent.parent && parent.parent.parent && !parent.parent.parent.visible))
				return;

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
			case KeyCode.ENTER:
				clickCurrentSelectedSlot();
				break;
			default:
				break;
			}

			if(details.navEquivalent == NavigationCode.GAMEPAD_A)
			{
				clickCurrentSelectedSlot();
			}
		}	

		public function moveSlotRight()
		{
			if(_selectedSlotID == 4)
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
				_selectedSlotID = 4;
				
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