package red.game.witcher3.menus.photomode 
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.controls.Slider;
	import flash.text.TextField;
	import scaleform.clik.data.ListData;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.events.SliderEvent;
	import red.core.constants.KeyCode;
	import flash.events.KeyboardEvent;
	import red.core.events.GameEvent;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import red.game.witcher3.menus.photomode.PhotomodeSliderDataModel;
	import red.game.witcher3.managers.InputManager;

	import com.gskinner.motion.GTweener;
	
	public class PhotomodeSaverRenderer extends PhotomodeRenderer
	{	
		public var m_txtValue : TextField;
        public var m_txtValueAlt : TextField;
		public var m_txtLabel : TextField;
		public var m_progressBar : Slider;
		public var m_bar : MovieClip;
		
		private var _valuePrecision : Number;

		private static const HOLD_TIME : Number = 1;
		public var holdProgress : Number = 0;
		private var isHoldingSave : Boolean = false;
		private var isHoldingLoad : Boolean = false;
		private var holdComplete : Boolean = false;
		private var tween : Object;

		private var slotIdx : int;
		
		public function PhotomodeSaverRenderer() 
		{
            super();
			preventAutosizing = true;
        }
		
        public override function set selected(value:Boolean):void 
		{
            super.selected = value;
			
			if (value){
				gotoAndStop("focused");
			}
			else{
				gotoAndStop("unfocused");
			}
        }
		
        public override function set enabled(value:Boolean):void 
		{			
            super.enabled = value;
			
			this.visible = value;
        }
		
		public override function setListData(listData:ListData):void 
		{
			index = listData.index;
			selected = listData.selected;
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
			//TODO: proper date format
			m_txtValue.text = dataModel.date;
			m_txtValueAlt.text = dataModel.date;
			slotIdx = dataModel.id;

        }
       
        override protected function configUI():void 
		{
			super.configUI();	
			
			this.removeEventListener(InputEvent.INPUT, handleInput);
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			m_bar.m_bar.gotoAndStop(1);
        }
		

		private function checkHoldComplete()
		{
			if(!isHoldingLoad && !isHoldingSave) {
				holdComplete = false;
				holdProgress = 0;
				GTweener.removeTweens(this);
				tween = null;
			}
		}

		private function updateFrame()
		{
			var frame : int = 1 + Math.floor(holdProgress * 99);
			m_bar.m_bar.gotoAndStop(frame);
		}

		private function onSavePressed()
		{
			// we dont want save and load at the same time
			if(tween)
				return;

			isHoldingSave = true;

			tween = GTweener.to(this, HOLD_TIME, { holdProgress : 1 }, 
			{
				onChange:updateFrame, 
				onComplete:onSaveComplete
			});
		}

		private function onSaveComplete()
		{
			holdProgress = 0;
			updateFrame();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSaveOnSlot", [ slotIdx ] ) );	
		}

		private function onLoadPressed()
		{
			// we dont want save and load at the same time
			if(tween)
				return;

			isHoldingLoad = true;

			tween = GTweener.to(this, HOLD_TIME, {holdProgress : 1 }, 
			{
				onChange:updateFrame, 
				onComplete:onLoadComplete
			});
		}

		private function onLoadComplete()
		{
			holdProgress = 0;
			updateFrame();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnLoadOnSlot", [ slotIdx ] ) );	
		}

		private function onSaveReleased()
		{
			isHoldingSave = false;
			checkHoldComplete();
			updateFrame();
		}

		private function onLoadReleased()
		{
			isHoldingLoad = false;
			checkHoldComplete();
			updateFrame();
		}
	
		
		public override function handleInput(event:InputEvent):void 
		{
			var details:InputDetails = event.details;
			
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

			if (!selected)
				return;

			if(!visible || (parent && !parent.visible) 
			|| (parent && parent.parent && !parent.parent.visible)
			|| (parent && parent.parent && parent.parent.parent && !parent.parent.parent.visible))
				return;
			
			if(details.code == KeyCode.ENTER || details.navEquivalent == NavigationCode.GAMEPAD_A) 
			{ 
				if(keyDown) 
				{
					onSavePressed();
					event.handled = true;
				}
				else if (keyUp) 
				{
					onSaveReleased();
					event.handled = true;
				}
			}
			// else if (details.code == KeyCode.BACKSPACE ||
			// 	(isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X) ||		// X on switch
			// 	(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y))		// Y on other platforms
			// { 
			// 	if(keyDown)
			// 	{
			// 		onLoadPressed();
			// 		event.handled = true;
			// 	}
			// 	else if (keyUp)
			// 	{
			// 		onLoadReleased();
			// 		event.handled = true;
			// 	}
			// }
		}
	}
}