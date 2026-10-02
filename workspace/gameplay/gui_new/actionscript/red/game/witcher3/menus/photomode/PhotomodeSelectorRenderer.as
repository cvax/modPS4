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
	
	public class PhotomodeSelectorRenderer extends PhotomodeRenderer
	{	
		public var m_txtValue : TextField;
		public var m_txtLabel : TextField;
		
        public var m_btnLeft : MovieClip;
        public var m_btnRight : MovieClip;

		public var mcDropDownBG : MovieClip;
		
		private var _currentDataModel : PhotomodeSliderDataModel;

		private var _callbackFunctionName : String;
		private var _callbackDelay : Number;

		private var _disabled : Boolean = false;
		
		public function PhotomodeSelectorRenderer() 
		{
            super();
			preventAutosizing = true;
        }

        override protected function configUI():void 
		{
			super.configUI();	
			
			this.removeEventListener(InputEvent.INPUT, handleInput);
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);

            m_btnLeft.addEventListener(MouseEvent.CLICK, onLeftButtonClick);
            m_btnRight.addEventListener(MouseEvent.CLICK, onRightButtonClick);

            //hover
            m_btnLeft.addEventListener(MouseEvent.MOUSE_OVER, onMoveButtonMouseEnter);
            m_btnRight.addEventListener(MouseEvent.MOUSE_OVER, onMoveButtonMouseEnter);
            m_btnLeft.addEventListener(MouseEvent.MOUSE_OUT, onMoveButtonMouseLeft);
            m_btnRight.addEventListener(MouseEvent.MOUSE_OUT, onMoveButtonMouseLeft);

			mouseEnabled = !_disabled;
            mouseChildren = !_disabled;

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

		private function changeFrame() : void
		{
			if( _disabled )
			{
				// trace("PhotomodeSelector::changeFrame::disabled [" + m_txtLabel.text + "]");
				gotoAndStop("inactive");
			}
			else if ( selected )
			{
				// trace("PhotomodeSelector::changeFrame::focused [" + m_txtLabel.text + "]");
				gotoAndStop("focused");
			}
			else
			{
				// trace("PhotomodeSelector::changeFrame::unfocused [" + m_txtLabel.text + "]");
				gotoAndStop("unfocused");
			}
		}
		
        public override function set selected(value:Boolean):void 
		{
            super.selected = value;
			// trace("PhotomodeSelector::set selected = " + value.toString() + " [" + m_txtLabel.text + "]");

			changeFrame();
			if ( value )
			{
				onSelected();
			}
        }
		
        public override function set enabled(value:Boolean):void 
		{				
            super.enabled = value;
			
			this.visible = value;

			if(value)
			{
				mouseEnabled = value;
            	mouseChildren = value;
			}
        }

		public function set disabled(value : Boolean):void
		{
			_disabled = value;
			// trace("PhotomodeSelector::set disabled = " + value.toString() + " [" + m_txtLabel.text + "]");

			changeFrame();
			mouseEnabled = !_disabled;
            mouseChildren = !_disabled;
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
			
			var dataModel : PhotomodeSliderDataModel;
			dataModel = data.sliderData;

			if (dataModel == null)
				return;
			
			//#LT Removing this sameness check, because it does not work well with loading data from WS
			/*if (_currentDataModel == dataModel)
				return;*/
				
			_currentDataModel = dataModel;
			
			if (dataModel.stringValues.length > 0)
			{				
				m_txtLabel.text = dataModel.label;				
				m_txtValue.text = dataModel.stringValues[dataModel.currentValue];
			}

			if(data.data.hasOwnProperty("callback"))
			{
				_callbackFunctionName = data.data["callback"];
				_callbackDelay = data.data["callbackDelay"];
			}
			else
			{
				_callbackFunctionName = "";
			}

			disabled = data.data.hasOwnProperty("disabled");
			checkArrows();
        }
       
		private function onEnterFrame(e:Event):void
		{
			stop(); //#LT: we dont want it to play over if this object is invisible->visible
		}

		
		private function callTheCallback():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, _callbackFunctionName ) );
		}
		
		private function onValueChange(value : int)
		{
			m_txtValue.text = _currentDataModel.stringValues[value];
			_currentDataModel.currentValue = value;
			
			if(allowValueChangeEvents)
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnParameterChanged", [ _currentDataModel.id, Number(value) ] ) );	

			if(_callbackFunctionName)
			{
				if(_callbackDelay <= 0)
					callTheCallback();
				else 
					setTimeout(callTheCallback, _callbackDelay);
			}

			checkArrows();
		}

		public override function onDestroy():void
		{
			stage.removeEventListener(InputEvent.INPUT, handleInput);
		}

		private function canGoLeft():Boolean
		{
			return !_disabled && _currentDataModel.currentValue > 0;
		}

		private function canGoRight():Boolean
		{
			return !_disabled && _currentDataModel.currentValue < _currentDataModel.stringValues.length - 1;
		}

		private function checkArrows():void
		{
			m_btnLeft.visible = canGoLeft();
			m_btnRight.visible = canGoRight();
		}
	
        public function moveValueLeft(amount:int)
        {
			if(_disabled)
				return;

            var curVal : int = _currentDataModel.currentValue;
            var newVal : int = curVal;
            if(curVal - amount < 0)
                newVal = 0;
            else
                newVal = curVal - amount;

            if(curVal != newVal)
                onValueChange(newVal)
        }

        public function moveValueRight(amount:int)
        {
			if(_disabled)
				return;

            var curVal : int = _currentDataModel.currentValue;
            var newVal : int = curVal;
            if(curVal + amount >= _currentDataModel.stringValues.length)
                newVal = _currentDataModel.stringValues.length - 1;
            else
                newVal = curVal + amount;

            if(curVal != newVal)
                onValueChange(newVal)
        }

        private function onMoveButtonMouseEnter(event:MouseEvent)
        {
            var btn : MovieClip = event.currentTarget as MovieClip;
            if(btn)
                btn.gotoAndStop("over")
        }

        
        private function onMoveButtonMouseLeft(event:MouseEvent)
        {
            var btn : MovieClip = event.currentTarget as MovieClip;
            if(btn)
                btn.gotoAndStop("up")
        }

        private function onLeftButtonClick(event:MouseEvent)
        {
			allowValueChangeEvents = true;
            moveValueLeft(1);
        }

        private function onRightButtonClick(event:MouseEvent)
        {
			allowValueChangeEvents = true;
            moveValueRight(1);
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
				allowValueChangeEvents = true;
                moveValueRight(1);
				break;
			case KeyCode.RIGHT:
				if (InputManager.getInstance().isGamepad())
					break;
				allowValueChangeEvents = true;
				moveValueRight(1);
				break;
			case KeyCode.PAD_DIGIT_LEFT:
				allowValueChangeEvents = true;
				moveValueLeft(1);
					break;
			case KeyCode.LEFT:
				if (InputManager.getInstance().isGamepad())
					break;
				allowValueChangeEvents = true;
				moveValueLeft(1);
				break;
			default:
				break;
			}
		}
		
		public override function onUpdateParam( param : Object):void 
		{
			var id : uint = param.id;
			var value : Number = param.value;
			
			if ( id != _currentDataModel.id )
				return;
				
            onValueChange(value);
		}

		private function onSelected():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnParameterSelected", [ _currentDataModel.id ] ) );	
		}

		public function	setDropDownBackgroundVisible(visible : Boolean) :void
		{
			if(mcDropDownBG) mcDropDownBG.visible = visible;
		}
	}
}