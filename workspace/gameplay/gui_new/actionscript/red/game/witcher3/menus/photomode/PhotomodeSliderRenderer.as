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
	import red.game.witcher3.utils.CommonUtils;

	public class PhotomodeSliderRenderer extends PhotomodeRenderer
	{	
		public var m_txtValue : TextField;
		public var m_txtLabel : TextField;
		public var m_slider : Slider;

		public var arrowNavigation : Boolean = true;
		public var wasdNavigation : Boolean = true;
		public var l_stickNavigation : Boolean = true;
		
		private var _currentDataModel : PhotomodeSliderDataModel;
		private var _valuePrecision : Number;

		private var _callbackFunctionName : String;
		private var _callbackDelay : Number;

		private var _disabled : Boolean = false;
		
		public function PhotomodeSliderRenderer() 
		{
            super();
			preventAutosizing = true;
        }

		override protected function configUI():void 
		{
			super.configUI();
			//Super CLIK ListItemRenderer disables mouseChildren but we need that for slider event handling
			//So re-enable it if we are not disabled
			mouseEnabled = !_disabled;
            mouseChildren = !_disabled;
			
			m_slider.addEventListener(SliderEvent.VALUE_CHANGE, onValueChange);
			m_slider.addEventListener(FocusEvent.FOCUS_IN, onSliderFocusChange);
			m_slider.addEventListener(MouseEvent.MOUSE_DOWN, onSliderClicked, false, int.MAX_VALUE) //<-- intended control, add back value change events

			this.removeEventListener(InputEvent.INPUT, handleInput);

			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
        }
		
		private function changeFrame() : void
		{
			if( _disabled )
			{
				// trace("PhotomodeSlider::changeFrame::disabled [" + m_txtLabel.text + "]");
				gotoAndStop("inactive");
			}
			else if ( selected )
			{
				// trace("PhotomodeSlider::changeFrame::focused [" + m_txtLabel.text + "]");
				gotoAndStop("focused");
			}
			else
			{
				// trace("PhotomodeSlider::changeFrame::unfocused [" + m_txtLabel.text + "]");
				gotoAndStop("unfocused");
			}
		}

        public override function set selected(value:Boolean):void 
		{
            super.selected = value;
			// trace("PhotomodeSlider::set selected = " + value.toString() + " [" + m_txtLabel.text + "]");

			changeFrame();
			if ( value )
			{
				onSelected();
			}
        }
		
        public override function set enabled(value:Boolean):void 
		{				
			super.enabled = value;
			// trace("PhotomodeSlider::set enabled = " + value.toString() + " [" + m_txtLabel.text + "]");
			
			m_slider.enabled = value;
			this.visible = value;

			if( value )
			{
				mouseEnabled = value;
            	mouseChildren = value;
			}
        }

		public function set disabled(value : Boolean):void
		{
			_disabled = value;
			// trace("PhotomodeSlider::set disabled = " + value.toString() + " [" + m_txtLabel.text + "]");

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
			if (data == null)
				return;

			super.setData(data);
			
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
				m_slider.minimum = 0;
				m_slider.maximum = dataModel.stringValues.length - 1;
				m_slider.snapping = true;
				m_slider.snapInterval = 1.0;
				
				m_txtValue.text = dataModel.stringValues[dataModel.currentValue];
				m_slider.value = dataModel.currentValue;
			}
			else
			{
				m_txtLabel.text = dataModel.label;
				m_slider.minimum = dataModel.minValue;
				m_slider.maximum = dataModel.maxValue;
				m_slider.snapping = dataModel.slideStep > 0.0 ? true : false;
				m_slider.snapInterval = dataModel.slideStep;
				
				_valuePrecision = getCorrectPrecision( dataModel.slideStep );
				
				m_txtValue.text = dataModel.currentValue.toFixed( _valuePrecision ).toString();
				m_slider.value = dataModel.currentValue;
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
        }

		private function onSliderFocusChange():void
		{
			// trace("Slider::onSliderFocusChange [" + m_txtLabel.text + "]");

			//making sure its after the m_slider configUI!
			allowValueChangeEvents = true;
			m_slider.removeEventListener(InputEvent.INPUT, m_slider.handleInput);
		}

		private function callTheCallback():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, _callbackFunctionName ) );
		}

		private function onSliderClicked(event : MouseEvent)
		{
			// trace("Slider::onSliderClicked [" + m_txtLabel.text + "]");
			allowValueChangeEvents = true;
		}
		
		private function onValueChange(event : SliderEvent)
		{
			// trace("Slider::onValueChange [" + m_txtLabel.text + "]");

			m_txtValue.text = _currentDataModel.stringValues.length > 0 ? _currentDataModel.stringValues[event.value] : event.value.toFixed( _valuePrecision ).toString();
			_currentDataModel.currentValue = event.value;
			
			if(allowValueChangeEvents)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnParameterChanged", [ _currentDataModel.id, event.value ] ) );	
			}
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

			// this is only for photomode if the slider is hidden but visible is only a local parameter
			if(!visible || (parent && !parent.visible) 
			|| (parent && parent.parent && !parent.parent.visible)
			|| (parent && parent.parent && parent.parent.parent && !parent.parent.parent.visible))
				return;

			switch (details.navEquivalent)
			{
				case NavigationCode.RIGHT :
					if ((!InputManager.getInstance().isGamepad() && ((details.code == KeyCode.D && wasdNavigation) || (details.code == KeyCode.RIGHT && arrowNavigation)))
						|| (InputManager.getInstance().isGamepad() && details.code == KeyCode.RIGHT && l_stickNavigation))
						{
							allowValueChangeEvents = true;
							m_slider.value += m_slider.snapInterval;
						}
				break;
				case NavigationCode.LEFT :
					if ((!InputManager.getInstance().isGamepad() && ((details.code == KeyCode.A && wasdNavigation) || (details.code == KeyCode.LEFT && arrowNavigation)))
						|| (InputManager.getInstance().isGamepad() && details.code == KeyCode.LEFT && l_stickNavigation))
						{
							allowValueChangeEvents = true;
							m_slider.value -= m_slider.snapInterval;
						}
				break;
				case NavigationCode.DPAD_LEFT:
					allowValueChangeEvents = true;
					m_slider.value -= m_slider.snapInterval;
				break;
				case NavigationCode.DPAD_RIGHT:
					allowValueChangeEvents = true;
					m_slider.value += m_slider.snapInterval;
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
				
			m_slider.value = value;
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