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
	
	public class PhotomodeResetButtonsRenderer extends PhotomodeRenderer
	{	
		public var mcButton1 : MovieClip;
		public var mcButton2 : MovieClip;

		private var _disabled : Boolean = false;
		private var _callbackButton1FunctionName : String;	
		private var _callbackButton2FunctionName : String;	
		private var _selectedButton : int;

		public var button1Label : TextField;
		public var button2Label : TextField;

		public function PhotomodeResetButtonsRenderer() 
		{
            super();
        }

        override protected function configUI():void 
		{
			super.configUI();

			mouseEnabled = true;
            mouseChildren = true;

			this.removeEventListener(InputEvent.INPUT, handleInput);
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);

			mcButton1.addEventListener(MouseEvent.MOUSE_OVER, onButton1MouseEnter);
            mcButton2.addEventListener(MouseEvent.MOUSE_OVER, onButton2MouseEnter);
            mcButton1.addEventListener(MouseEvent.MOUSE_OUT, onButton1MouseLeft);
            mcButton2.addEventListener(MouseEvent.MOUSE_OUT, onButton2MouseLeft);

			mcButton1.addEventListener(MouseEvent.CLICK, onButton1Click);
            mcButton2.addEventListener(MouseEvent.CLICK, onButton2Click);

			selectButton(0);
        }

		private function onButton1MouseEnter(event:MouseEvent)
        {
            mcButton1.gotoAndStop("over");
        }
        
        private function onButton1MouseLeft(event:MouseEvent)
        {
           if(_selectedButton ==  0)
			{
			 	mcButton1.gotoAndStop("up");
			}
			else
			{
				mcButton1.gotoAndStop("blank");
			}  
        }

		private function onButton2MouseEnter(event:MouseEvent)
        {
            mcButton2.gotoAndStop("over");
        }
        
        private function onButton2MouseLeft(event:MouseEvent)
        {
           if(_selectedButton ==  1)
			{
			 	mcButton2.gotoAndStop("up");
			}
			else
			{
				mcButton2.gotoAndStop("blank");
			}  
        }

        private function onButton1Click(event:MouseEvent)
        {	
			if(_selectedButton == 0)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, _callbackButton1FunctionName ) ); 
			}
			else
			{
				selectButton(0);
			}
        }

        private function onButton2Click(event:MouseEvent)
        {				
			if(_selectedButton == 1)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, _callbackButton2FunctionName ) ); 
			}
			else
			{
				selectButton(1);
			}		
        }	

		public function selectButton(id : int)
		{	
			_selectedButton = id;

			if(_selectedButton == 0)
			{
				mcButton1.gotoAndStop("up");
				mcButton2.gotoAndStop("blank");				
			}
			else
			{
				mcButton1.gotoAndStop("blank");
				mcButton2.gotoAndStop("up");
			}
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
			trace("Debug UI Renderer set data");
			if (data != null)
				super.setData(data);

			if (data == null)
				return;	
			
			var dataModel : Object;
			dataModel = data.data.args;

			if (dataModel == null)
				return;

				//tf_label
			updateButtonDatas(data);
        }

		private function updateButtonDatas(data:Object)
		{
			button1Label = mcButton1.getChildByName("tf_label") as TextField;
			button2Label = mcButton2.getChildByName("tf_label") as TextField;

			var dataModel : Object;
			dataModel = data.data.args;

			button1Label.text = dataModel.label1;
			button2Label.text = dataModel.label2;

			if(data.data.hasOwnProperty("callback"))
			{
				_callbackButton1FunctionName = data.data["callback"];
			}
			else
			{
				_callbackButton1FunctionName = "";
			}

			if(data.data.hasOwnProperty("callbackSecondary"))
			{
				_callbackButton2FunctionName = data.data["callbackSecondary"];
			}
			else
			{
				_callbackButton2FunctionName = "";
			}
		}

		private function onSelected():void
		{
			
		}

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
                selectNextButton();
				break;
			case KeyCode.RIGHT:
				if (InputManager.getInstance().isGamepad())
					break;
				selectNextButton();
				break;
			case KeyCode.PAD_DIGIT_LEFT:
				selectNextButton();
					break;
			case KeyCode.LEFT:
				if (InputManager.getInstance().isGamepad())
					break;
				selectNextButton();
				break;
			case KeyCode.ENTER:
				clickCurrentSelectedButton();
				break;
			default:
				break;
			}

			if(details.navEquivalent == NavigationCode.GAMEPAD_A)
			{
				clickCurrentSelectedButton();
			}
		}	
	
		public function selectNextButton()
		{
			if(_selectedButton == 0)
			{
				selectButton(1);
			}
			else
			{
				selectButton(0);
			}
		}

		public function clickCurrentSelectedButton()
		{
			if(_selectedButton == 0)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, _callbackButton1FunctionName ) ); 
			}
			else
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, _callbackButton2FunctionName ) ); 
			}
		}
	}
}
