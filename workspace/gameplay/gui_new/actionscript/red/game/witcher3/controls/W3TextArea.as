package red.game.witcher3.controls
{
	import com.gskinner.motion.plugins.CurrentFramePlugin;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import red.core.CoreComponent;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.TextArea;
    import flash.text.TextField;

    import scaleform.gfx.Extensions;
    import scaleform.clik.utils.ConstrainedElement;
	
	import scaleform.clik.controls.ScrollIndicator;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import red.core.events.GameEvent;
	import flash.events.TransformGestureEvent;
	import red.game.witcher3.utils.CommonUtils;
	
	public class W3TextArea extends TextArea
	{
		//public var bBlockSound : Boolean = false;
		protected var _panYAccumulator : Number	= 0;
		protected var _scrollSpeed 		: Number;
		protected var _baseTextColor 	: uint
		protected var _uppercase 		: Boolean;
		protected var _alignArabicText  : Boolean;
		
		// hack to arabic alignment
		protected var txtInitPosition	: Number; 

		public var allowSounds : Boolean = true;

		private var lastSetPositionSoundTime : Number = 0;
		static const SET_POSITION_SOUND_WAIT_TIME_MS : Number = 100;
		
		public function W3TextArea()
		{
			super();
			txtInitPosition = textField.x;
		}
		
		public function get uppercase():Boolean { return _uppercase };
		public function set uppercase(value:Boolean):void
		{
			_uppercase = value;
		}
		
		[Inspectable(defaultValue="false")]
		public function get alignArabicText():Boolean { return _alignArabicText };
		public function set alignArabicText(value:Boolean):void
		{
			_alignArabicText = value;
		}
		
		override public function set text(value:String):void 
		{
			if (value == null) value = "";
			super.text = value;
        }

		protected override function configUI():void
		{
			super.configUI();
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelScroll, false, 0, true);
			_baseTextColor = textField.textColor;
			_textColorChange = _baseTextColor;
		}
		
		override public function set position(value:int):void
		{
			super.position = value;
			//updateScrollBar();
			scrollBar.position = value;
			if ( _maxScroll > 1 )
			{
				var curTime = new Date().time;
				if(curTime - lastSetPositionSoundTime >= SET_POSITION_SOUND_WAIT_TIME_MS)
				{
					if ( position != value && allowSounds)
					{
						dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_scroll_description"]));
					}
					else if (allowSounds)
					{
						dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_scroll_description_failed"]));
					}
					lastSetPositionSoundTime = curTime;
				}
			}
        }
		
		[Inspectable(defaultValue = 40)]
		public function get scrollSpeed( ) : Number
		{
			return _scrollSpeed;
		}
		public function set scrollSpeed( value : Number ) : void
		{
			_scrollSpeed = value;
		}
		
		// #J possible values: "on", "off", "auto"
		public function changeScrollBarPolicy( policy : String ) : void
		{
			_scrollPolicy = policy;
			updateScrollBar();
		}
		
		 override protected function updateText():void 
		 {
            super.updateText();
			
			if (_baseTextColor != _textColorChange || textField.textColor != _baseTextColor)
			{
				textField.textColor = _textColorChange;
			}
						
			if (_uppercase)
			{
				textField.htmlText = CommonUtils.toUpperCaseSafe(textField.htmlText);
			}
			
			if (_alignArabicText && CoreComponent.isArabicAligmentMode)
			{
				var curTF:TextFormat = textField.getTextFormat();
				curTF.align = TextFormatAlign.RIGHT;
				textField.setTextFormat(curTF);
				textField.x = txtInitPosition - (textField.width - textField.textWidth);
			}
			else
			{
				textField.x = txtInitPosition;
			}
        }
		
        /** Updates the scroll position and thumb size of the ScrollBar. */ //#B fix for hide scrool bar when no neeeded
       override protected function updateScrollBar():void
	   {
            _maxScroll = textField.maxScrollV;
            var sb:ScrollIndicator = _scrollBar as ScrollIndicator;
            if ( sb == null )
			{
				return;
			}
            var element:ConstrainedElement = constraints.getElement("textField");
            if (_scrollPolicy == "on" || (_scrollPolicy == "auto" && textField.maxScrollV > 1))
			{
                if (_autoScrollBar && !sb.visible)  // Add some space on the right for the scrollBar
                {
					if (element != null)
                    {
						constraints.update(_width, _height);
                        invalidate();
                    }
                    _maxScroll = textField.maxScrollV; // Set this again, in case adding a scrollBar made the maxScroll larger.
                }
                sb.visible = true;
            }

            // If no ScrollIndicator is needed, hide it.
            if (_scrollPolicy == "off" || (_scrollPolicy == "auto" && textField.maxScrollV < 2))
			{
				if( sb.visible ) // #B this is fix
				{
					sb.visible = false; // Hide the ScrollBar before calling availableWidth to remove it from the calculation.
				}
                if (_autoScrollBar) // Remove any added space.
				{
                    if (element != null)
					{
                        constraints.update(availableWidth, _height);
                        invalidate();
                    }
                }
            }

            if (sb.enabled != enabled)
			{
				sb.enabled = enabled;
			}
        }
		
		protected function handleGesturePan( event : TransformGestureEvent ) : void
		{
			var avgLineHeight : Number = textField.textHeight / textField.numLines;
			var result : Object = CommonUtils.stagePanToRowScroll( _panYAccumulator, avgLineHeight, event );

			textField.scrollV -= result.outRowsToScroll; //(Ab)Use scrollV to clamp the position :)
			position = textField.scrollV;

			_panYAccumulator = result.outPanYAccumulator;
		}

		public function enableScrollWithPan( enable : Boolean ) : void
		{
			_panYAccumulator = 0;
			if ( enable )
			{
				addEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan, false, 0, true );
			}
			else
			{
				removeEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan, false );
			}
		}

		public function CanBeFocused() : Boolean
		{
			return (textField.maxScrollV > 1 );
		}
		
		protected var _textColorChange:uint;
		public function setTextColor(color:uint):void
		{
			_textColorChange = color;
			textField.textColor = _textColorChange;
		}
		
		public function resetTextColor():void
		{
			_textColorChange = _baseTextColor;
			textField.textColor = _textColorChange;
		}
		
		override protected function blockMouseWheel(event:MouseEvent):void
		{
		}
		
		protected function onMouseWheelScroll(event:MouseEvent):void
		{
			position = textField.scrollV;
		}
		
		override protected function onScroller(event:Event):void {
			super.onScroller(event);
			updateScrollBar();
        }
	}
}
