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
	import flash.events.FocusEvent;
	
	public class PhotomodeColorSliderRenderer extends PhotomodeRenderer
	{	
		public var m_txtValue : TextField;
		public var m_txtLabel : TextField;
		public var m_slider : PhotomodeColorSlider;
		
		private var _currentDataModel : PhotomodeSliderDataModel;
		private var _valuePrecision : Number;

		private var _callbackFunctionName : String;
		private var _callbackDelay : Number;

		private var _disabled : Boolean = false;
		
		public function PhotomodeColorSliderRenderer() 
		{
            super();
			preventAutosizing = true;
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
				onSelected();
			}
			else
			{
				gotoAndStop("unfocused");
			}
        }
		
        public override function set enabled(value:Boolean):void 
		{				
            super.enabled = value;
			
			m_slider.enabled = value;
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

			m_slider.focused = 0;
			
			//#LT Removing this sameness check, because it does not work well with loading data from WS
			/*if (_currentDataModel == dataModel)
				return;*/
				
			_currentDataModel = dataModel;
			
			if (dataModel.stringValues.length > 0)
			{				
				m_txtLabel.text = dataModel.label;
				//m_slider.minimum = 0;
				//m_slider.maximum = dataModel.stringValues.length - 1;
				//m_slider.snapping = true;
				//m_slider.snapInterval = 1.0;
				
				m_txtValue.text = dataModel.stringValues[dataModel.currentValue];
				//m_slider.value = dataModel.currentValue;
			}
			else
			{
				m_txtLabel.text = dataModel.label;
				//m_slider.minimum = dataModel.minValue;
				//m_slider.maximum = dataModel.maxValue;
				//m_slider.snapping = dataModel.slideStep > 0.0 ? true : false;
				//m_slider.snapInterval = dataModel.slideStep;
				
				_valuePrecision = getCorrectPrecision( dataModel.slideStep );
				
				m_txtValue.text = dataModel.currentValue.toFixed( _valuePrecision ).toString();
				//m_slider.value = dataModel.currentValue;
			}

			//m_slider.track.gotoAndStop(data.data["colorSliderType"]);

			if(data.data.hasOwnProperty("callback"))
			{
				_callbackFunctionName = data.data["callback"];
				_callbackDelay = data.data["callbackDelay"];
			}
			else
			{
				_callbackFunctionName = "";
			}
		
			if(data.data.hasOwnProperty("disabled"))
			{
				setDisabled(true);
			}
			else
			{
				setDisabled(false);
			}
        }
       
        override protected function configUI():void 
		{
			super.configUI();	
			
			m_slider.addEventListener(SliderEvent.VALUE_CHANGE, onValueChange);
			m_slider.addEventListener(FocusEvent.FOCUS_IN, onSliderFocusChange);

			this.removeEventListener(InputEvent.INPUT, handleInput);
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);

			mouseEnabled = true;
            mouseChildren = true;
        }

		private function onSliderFocusChange():void
		{
			//making sure its after the m_slider configUI!
			m_slider.removeEventListener(InputEvent.INPUT, m_slider.handleInput);
		}

		private function callTheCallback():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, _callbackFunctionName ) );
		}
		
		private function onValueChange(event : SliderEvent)
		{
			m_txtValue.text = _currentDataModel.stringValues.length > 0 ? _currentDataModel.stringValues[event.value] : event.value.toFixed( _valuePrecision ).toString();
			_currentDataModel.currentValue = event.value;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnParameterChanged", [ _currentDataModel.id, event.value ] ) );	

			if(_callbackFunctionName)
			{
				if(_callbackDelay <= 0)
					callTheCallback();
				else 
					setTimeout(callTheCallback, _callbackDelay);
			}

			m_slider.focused = 0;
		}

		public override function onDestroy():void
		{
			m_slider.removeEventListener(SliderEvent.VALUE_CHANGE, onValueChange);
		}
	
		
		public override function handleInput(event:InputEvent):void 
		{
			var details:InputDetails = event.details;
			
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD; //#B should be also hold here
			if (!keyDown)
				return;
				
			if (!selected || _disabled)
				return;

			if(!visible || (parent && !parent.visible) 
			|| (parent && parent.parent && !parent.parent.visible)
			|| (parent && parent.parent && parent.parent.parent && !parent.parent.parent.visible))
				return;

			switch (details.code) 
			{
			case KeyCode.PAD_DIGIT_RIGHT:
				//m_slider.value += m_slider.snapInterval;
				break;
			case KeyCode.RIGHT:
				if (InputManager.getInstance().isGamepad())
					break;
				//m_slider.value += m_slider.snapInterval;
				break;
			case KeyCode.PAD_DIGIT_LEFT:
				//m_slider.value -= m_slider.snapInterval;
					break;
			case KeyCode.LEFT:
				if (InputManager.getInstance().isGamepad())
					break;
				//m_slider.value -= m_slider.snapInterval;
				break;
			default:
				break;
			}
			

			m_slider.focused = 0;
		}
		
		public override function onUpdateParam( param : Object):void 
		{
			var id : uint = param.id;
			var value : Number = param.value;
			
			if ( id != _currentDataModel.id )
				return;
				
			//m_slider.value = value;
		}
		
		private function getCorrectPrecision( value : Number ) : int 
		{
			const maxPrecision : uint = 5;
			var valueStr : String = value.toFixed( maxPrecision ).toString();
			var precision : uint = maxPrecision;
			
			for ( var i : uint = 0; i < maxPrecision; i++ )
			{	
				var charIdx = valueStr.length - i;
				
				//trace( "charIdx: " + charIdx.toString() + ", char: " + valueStr.charAt( valueStr.length - i - 1 ).toString() );
				
				if ( ( charIdx >= 0 ) && ( valueStr.charAt( valueStr.length - i - 1 ) == "0" ) )
				{
					precision--;
					continue;
				}
				
				return precision;
			}
			
			return precision;
		}

		private function onSelected():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnParameterSelected", [ _currentDataModel.id ] ) );	
		}
	}
}