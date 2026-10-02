package red.game.witcher3.menus.common
{
	import adobe.utils.CustomActions;
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.GestureEvent;
	import red.core.constants.KeyCode;
	import red.core.CoreComponent;
	import red.core.data.InputAxisData;
	import red.core.events.GameEvent;
	import red.core.events.GestureEventEx;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.constants.EInputDeviceType;
	import red.game.witcher3.constants.KeyboardKeys;
	import red.game.witcher3.constants.PlatformType;
    import red.game.witcher3.controls.KeyboardButtonClickArea;
	import red.game.witcher3.data.KeyBindingData;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.Button;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;

	/**
	 * URL button binded
	 * @author Yaroslav Getsevich
	 */
	public class URLButton extends Button
	{
		protected static const HOLD_ANIM_STEPS_COUNT:Number = 30;
		protected static const HOLD_ANIM_INTERVAL:Number = 20; // ms
		protected static const DISABLED_ALPHA = .4;
		protected static const CLICKABLE_BK_OFFSET = 10;
		protected static const INVALIDATE_DISPLAY_DATA:String = "invalidate_display_data";
		protected static const GPAD_ICON_SIZE:Number = 64;
		protected static const TEXT_PADDING_KEYBOARD:Number = 5; // Distance between text and icon
		protected static const TEXT_PADDING_PAD:Number = 1; // Distance between text and icon
		protected static const TEXT_OFFSET:Number = 6;  // Hack to prevent text's cutting
		protected static const KEY_LABEL_PADDING:Number = 5;
		
		protected static const HOLD_INT_MAX_ANGLE:Number = 360;
		protected static const HOLD_INT_MAX_FRAME:Number = 28;
		protected static const HOLD_INT_FIRST_FRAME:Number = 2;
		
		public var mcHoldAnimation:MovieClip;
		
		public var mcClickRect:MovieClip;
		
		
		public var holdCallback:Function;
		public var addHoldPrefix:Boolean;
		
		protected var _currentWidth:Number;
		protected var _targetViewer:DisplayObject;
		protected var _bindingData:KeyBindingData;
		protected var _isGamepad:Boolean;
		protected var _gpadIcon:MovieClip;
		protected var _clickable:Boolean = true;
		protected var _labelPosition:Number;

		protected var _posXSource:int = 0;
		
		protected var _contentInvalid:Boolean = false;
		protected var _actualVisibility:Boolean = true;
		protected var _lowercaseLabels:Boolean = false;
		protected var _overrideTextColor:Number = -1;
		
		private var _timerActivated:Boolean = false;

		private var _cachedRequiredWidth : Number = -1;
		private var _urlIndex : int = -1;

		public var index : int;
		
		public function URLButton()
		{
			constraintsDisabled = true;
			preventAutosizing = true;
			focusable = false;
			if (textField)
			{
				textField.text = "";
				textField.autoSize = TextFieldAutoSize.LEFT;
			}
			
			if (mcClickRect) mcClickRect.visible = false;
			if (mcHoldAnimation) mcHoldAnimation.visible = false;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			addEventListener(MouseEvent.CLICK, onClickOrTap, false, 1, true);
			addEventListener(GestureEventEx.GESTURE_TAP, onClickOrTap, false, 1, true);
		}
		
		public function get overrideTextColor():Number { return _overrideTextColor };
		public function set overrideTextColor(value:Number):void
		{
			_overrideTextColor = value;
		}
		
		/**
		 * WARNING! Can cause problems in german localization!
		 */
		public function get lowercaseLabels():Boolean { return _lowercaseLabels }
		public function set lowercaseLabels(value:Boolean):void
		{
			_lowercaseLabels = value;
		}
		
		override public function set visible(value:Boolean):void
		{
			_actualVisibility = value;
			updateVisibility();
		}
		

		public function get clickable():Boolean { return _clickable }
		public function set clickable(value:Boolean):void
		{
			_clickable = value;
		}

		public function getViewWidth():Number
		{
			if (mcClickRect.visible)
			{
				return mcClickRect.actualWidth;
			}
			return _currentWidth ? _currentWidth : width;
		}

		public function getBindingData():KeyBindingData
		{
			return _bindingData;
		}


		public function setData(bindingData:KeyBindingData, isGamepad:Boolean, dontUpdate:Boolean = false):void
		{
			_bindingData = bindingData;
		}

		
		private var _isRadialMenu, _doubleTap : Boolean; // NGE
		
		protected function updateVisibility():void
		{
			var newVisibilityValue = _actualVisibility && !_contentInvalid
			if (super.visible != newVisibilityValue)
			{
				super.visible = newVisibilityValue;
			}
		}
		
		override protected function updateText():void
		{			
            if (_label != null && textField != null)
			{
				if (_overrideTextColor >= 0)
				{
					textField.textColor = _overrideTextColor
                	textField.text = _label;
				}
				else
				{
					textField.htmlText = _label;
				}
				if (_lowercaseLabels)
				{
					textField.text = CommonUtils.toLowerCaseExSafe(textField.text);
				}
				textField.width = textField.textWidth + TEXT_OFFSET;
				if (mcClickRect && mcClickRect.visible)
				{
					// #Y mcClickRect size changed in code, so we can't provide any animation on stage for it
					if(_cachedRequiredWidth != -1)
						tryResizeWidth(_cachedRequiredWidth);
					else 
					{
						var animStateClip:KeyboardButtonClickArea = mcClickRect as KeyboardButtonClickArea;
						if (animStateClip)
						{
							animStateClip.state = state;
							var newActualWidth : Number = CLICKABLE_BK_OFFSET + textField.x + textField.width;
							animStateClip.setActualSize(newActualWidth, mcClickRect.height);
							mcClickRect.x = 0;
							mcClickRect.y = - mcClickRect.height / 2;
							mcClickRect.visible = true;
						}
						else if (mcClickRect)
						{
							mcClickRect.visible = false;
						}
					}
				}
            }
			if (enabled)
			{
				this.filters = []
				alpha = 1;
			}
			else if (this.filters.length < 1)
			{
				var desaturationFilter:ColorMatrixFilter = CommonUtils.getDesaturateFilter();
				this.filters = [desaturationFilter];
				alpha = DISABLED_ALPHA;
			}
        }
		
		public function getOccupiedWidth():int 
		{
			return textField.x + textField.textWidth;
		}

		override public function toString():String
		{
			return "InputFeedbackButton [" + this.name +"]";
		}

		public function setLabel(label:String)
		{
			_label = label;
		}

		public function setUrlIndex(index:int)
		{
			_urlIndex = index;
		}

		public function tryResizeWidth(value:Number):void
		{
			_cachedRequiredWidth = value;
			var animStateClip:KeyboardButtonClickArea = mcClickRect as KeyboardButtonClickArea;
			if (animStateClip)
			{
				animStateClip.state = state;
				var newActualWidth : Number = value;
				animStateClip.setActualSize(newActualWidth, mcClickRect.height);
				mcClickRect.x = 0;
				textField.x = (value - textField.width) / 2;
				mcClickRect.y = - mcClickRect.height / 2;
				mcClickRect.visible = true;
			}
			else if (mcClickRect)
			{
				mcClickRect.visible = false;
			}
		}

		public function doRollOver():void {
            // MOUSE_OVER
			if (!enabled) { return; }
			if (_focused || _displayFocus) {
				if (_focusIndicator != null) { setState("over"); }
			} else {
				setState("over");
			}
            
        }

        public function doRollOut():void {
            // ROLL_OUT
			if (!enabled) { return; }
			if (_focused || _displayFocus) {
				if (_focusIndicator != null) { setState("out"); }
			}
			else {
				setState("out");
			}
        }

		public function signalOpenUrl():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSignalOpenUrl", [_urlIndex] ) );
		}

		public function onClickOrTap(event:Event):void
		{
			signalOpenUrl();
			event.stopImmediatePropagation();
		}
	}
}
