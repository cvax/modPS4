package red.game.witcher3.managers
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import red.core.CoreComponent;
	import red.core.CoreHud;
	import red.core.CoreHudModule;
	import red.core.CoreMenu;
	import red.core.CorePopup;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.EInputDeviceType;
	import red.game.witcher3.constants.KeyCode;
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.events.ControllerChangeEvent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;

	/**
	 * @author Yaroslav Getsevich
	 */
	public class InputManager extends EventDispatcher
	{
		public static const LOCKED_SCHEME_NONE:uint = 0;
		public static const LOCKED_SCHEME_GPAD:uint = 1;
		public static const LOCKED_SCHEME_MOUSE:uint = 2;
		
		protected static const CHANGE_CONTROLLER_TYPE_DELAY:Number = -1; // [ms] -1 to turn off
		protected static const CHANGE_CONTROLLER_MOUSE_DELTA:Number = 3; // [px]
		protected static const HOLD_DELAY:Number = 500;
		protected static const HOLD_INTERVAL:Number = 200;
		protected static const HOLD_INTERVAL_MIN:Number = 30;
		protected static const HOLD_INTERVAL_SPEED_UP_SCALE : Number = 0.88; // maximal 30 will be achieved after 600 ms in that case
		
		protected var currentHoldInterval : Number = HOLD_INTERVAL;

		protected static var _instance:InputManager;
		protected static var _instanceID:int = 0;

		public static function getInstance():InputManager
		{
			if (!_instance)
			{
				_instanceID = Math.floor(Math.random( ) * 1000) + 1;
				trace("Initializing InputManager (" + _instanceID + ")");
				_instance = new InputManager();
			}
			return _instance;
		}
		private var _inputBlocks:Object = { };
		protected var _inputDelegate:InputDelegate;
		protected var _rootStage:DisplayObjectContainer;
		protected var _isGamepad:Boolean;
		protected var _isMouse:Boolean;
		protected var _gpadInputReceived:Boolean;
		protected var _pendedGamepadInput:Boolean;
		protected var _pendedMouseInput:Boolean;

		protected var _holdCount:int = 0;
		protected var _holdInfoMap:Object = { };
		protected var _holdTimer:Timer;

		protected var _ctrlChangeTimer:Timer;
		protected var _bufMouseX:Number = 0;
		protected var _bufMouseY:Number = 0;
		protected var _platformType:uint  = PlatformType.PLATFORM_PC;
		
		protected var _initialized:Boolean;
		protected var _enableHoldEmulation:Boolean;
		protected var _enableInputDeviceCheck:Boolean;
		protected var _swapAcceptCancel:Boolean;
		
		protected var _lockedControlScheme:uint = 0;
		// modPS4++
		// protected var _gamepadType:uint = EInputDeviceType.IDT_Xbox1;
		protected var _gamepadType:uint = EInputDeviceType.IDT_PS4;
		// modPS4--
		
		public function init(targetRoot:DisplayObjectContainer, bHoldEmulation:Boolean = true, bInputDeviceCheck:Boolean = true):void
		{
			trace("InputManager (" + _instanceID + ") init");
		
			if (_initialized)
			{
				return;
			}
			
			if (!targetRoot)
			{
				return;
			}
			
			if ( ExternalInterface.available )
			{
				_isGamepad = true; //  ExternalInterface.call("isUsingPad"); // Initial state #Y TODO: Get from WS
				_isMouse = false;
			}
			
			_initialized = true;
			_rootStage = targetRoot;
			
			enableInputDeviceCheck = bInputDeviceCheck;
			enableHoldEmulation = bHoldEmulation;
		}
		
		public function addInputBlocker(blockInput:Boolean, factor:String = "default"):void
		{
			_inputBlocks[factor] = blockInput ? 1 : 0;
			updateInputBlockers();
		}
		
		public function removeInputBlocker(factor:String = "default"):void
		{
			delete _inputBlocks[factor];
			updateInputBlockers();
		}
		
		protected function updateInputBlockers():void
		{
			var blockerExist:Boolean = false;
			var unblockerExist:Boolean = false;
			
			for (var curFactor:String in _inputBlocks )
			{
				if (_inputBlocks[curFactor])
				{
					blockerExist = true;
				}
				else
				{
					unblockerExist = true;
					break;
				}
			}
			
			// unblock input if at least one module needs it
			if (unblockerExist || !blockerExist)
			{
				InputDelegate.getInstance().disableInputEvents(false);
			}
			else
			{
				InputDelegate.getInstance().disableInputEvents(true);
			}
		}
		
		public function forceInputFeedbackUpdate():void
		{
			fireCtrlChangeEvent(_isGamepad, _isMouse);
		}
		
		public function get gamepadType():uint
		{
			if (getPlatform() == PlatformType.PLATFORM_PS4)
			{
				return EInputDeviceType.IDT_PS4;
			}
			else if (getPlatform() == PlatformType.PLATFORM_PS5)
			{
				return EInputDeviceType.IDT_PS5;
			}
			else if (isXboxPlatform())
			{
				return EInputDeviceType.IDT_Xbox1;
			}
			
			//trace("InputManager (" + _instanceID + ") gamepadType() return " + _gamepadType);
			return _gamepadType;
		}
		
		public function set gamepadType(value:uint):void
		{
			var isMouseDevice:Boolean = (value == EInputDeviceType.IDT_KeyboardMouse || value == EInputDeviceType.IDT_Switch2_Mouser);
			var isGamePad = value != EInputDeviceType.IDT_KeyboardMouse;
			var forceGamepadChange = false;	// For switching between Xbox/Steam Controller
			
			//trace("InputManager (" + _instanceID + ") setGamepadType()" + 
			//	" _gamepadType: " + _gamepadType + " -> " + value +
			//	" ; _isMouse: " + _isMouse + " -> " + isMouseDevice +
			//	" ; _isGamepad: " + _isGamepad + " -> " + isGamePad);

			if (_gamepadType != value || _isMouse != isMouseDevice || _isGamepad != isGamePad)
			{
				if ( _isGamepad && value != EInputDeviceType.IDT_Switch2_Mouser && _gamepadType != value )
				{
					forceGamepadChange = true;
				}

				_gamepadType = value;
				setGamepadInputType(isGamePad, isMouseDevice, forceGamepadChange);
			}
		}
		
		public function get lockedControlScheme():uint { return _lockedControlScheme }
		public function set lockedControlScheme(value:uint):void
		{
			switch (_lockedControlScheme)
			{
				case LOCKED_SCHEME_GPAD:
					setGamepadInputType(true, false, true);
					break;
				case LOCKED_SCHEME_MOUSE:
					setGamepadInputType(false, true, true);
					break;
			}
			_lockedControlScheme = value;
		}
		
		public function get swapAcceptCancel():Boolean { return _swapAcceptCancel }
		public function set swapAcceptCancel(value:Boolean):void
		{
			_swapAcceptCancel = value;
			fireCtrlChangeEvent(_isGamepad, _isMouse);
		}
		
		public function get enableInputDeviceCheck():Boolean { return _enableInputDeviceCheck }
		public function set enableInputDeviceCheck(value:Boolean):void
		{
			_enableInputDeviceCheck = value;
			
			_rootStage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouse, false);
			_rootStage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouse, false);
			_rootStage.removeEventListener(MouseEvent.MOUSE_WHEEL, handleMouse, false);
			
			if (_enableInputDeviceCheck)
			{
				_rootStage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouse, false, 0, true);
				_rootStage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse, false, 0, true);
				_rootStage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouse, false, 0, true);
			}
			
			updateInputListeners();
		}
		
		public function get enableHoldEmulation():Boolean { return _enableHoldEmulation }
		public function set enableHoldEmulation(value:Boolean):void
		{
			_enableHoldEmulation = value;
			
			if (_holdTimer)
			{
				_holdTimer.stop();
				_holdTimer.removeEventListener(TimerEvent.TIMER, handleHoldEvent);
				_holdTimer = null;
			}
			
			if (_enableHoldEmulation)
			{
				_holdTimer = new Timer(HOLD_DELAY);
				_holdTimer.addEventListener(TimerEvent.TIMER, handleHoldEvent, false, 0, true);
				_holdTimer.start();
			}
			
			updateInputListeners();
		}
		
		public function getPlatform():uint
		{
			return _platformType;
		}
		
		public function isXboxPlatform():Boolean
		{
			return _platformType == PlatformType.PLATFORM_XBOX1 || _platformType == PlatformType.PLATFORM_XB_SCARLETT_LOCKHART || _platformType == PlatformType.PLATFORM_XB_SCARLETT_ANACONDA;
		}
		
		public function isPsPlatform():Boolean
		{
			return _platformType == PlatformType.PLATFORM_PS4 || _platformType == PlatformType.PLATFORM_PS5;
		}

		public function isSwitchPlatform():Boolean
		{
			return _platformType == PlatformType.PLATFORM_SWITCH2;
		}
		
		public function isGamepad():Boolean
		{
			return _isGamepad;
		}

		public function isPsGamepad():Boolean
		{
			return _gamepadType == EInputDeviceType.IDT_PS4 || _gamepadType == EInputDeviceType.IDT_PS5;
		}

		public function isMouse():Boolean
		{
			return _isMouse;
		}
		
		public function setControllerType(isGamepad:Boolean):void
		{
			//trace("InputManager (" + _instanceID + "), setControllerType() isGamepad " + isGamepad + " != _isGamepad " + _isGamepad);

			if (isGamepad != _isGamepad)
			{
				setGamepadInputType(isGamepad, _isMouse);
			}
		}
		
		public function setPlatformType(value:uint):void
		{
			//trace("InputManager (" + _instanceID + "), setPlatformType() value: " + value);

			_platformType = value;
			fireCtrlChangeEvent(_isGamepad, _isMouse);
		}
		
		protected function updateInputListeners():void
		{
			if (_enableInputDeviceCheck || _enableHoldEmulation)
			{
				_inputDelegate = InputDelegate.getInstance();
				_inputDelegate.addEventListener(InputEvent.INPUT, handleDelegatedInput, false, 1, true);
			}
			else
			{
				_inputDelegate = InputDelegate.getInstance();
				_inputDelegate.removeEventListener(InputEvent.INPUT, handleDelegatedInput, false);
				_inputDelegate = null;
			}
		}
		
		protected function handleDelegatedInput(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			var isGPad:Boolean;
			var isMouse:Boolean;
			
			isGPad = isGestureCode(details) ? _isGamepad : isGamepadCode(details) || _gamepadType == EInputDeviceType.IDT_Switch2_Mouser;
			isMouse = this.isMouse();

			//trace("InputManager (" + _instanceID + ") handleDelegatedInput()" +
			//	" isGPad: " + isGPad +
			//	", details.code: " + details.code +
			//	", details.fromJoystick: " + details.fromJoystick +
			//	", isMouse: " + isMouse);
			
			if (_enableHoldEmulation)
			{
				holdProcessing(event);
			}
			if (isGPad)
			{
				_gpadInputReceived = true;
				setGamepadInputType(isGPad, isMouse);
				return;
			}
			
			// #Y Skip first KB input after GPad input and emulated KEY_HOLD (to avoid KB inputs from dpad)
			else if (_gpadInputReceived || event.details.value == InputValue.KEY_HOLD)
			{
				_gpadInputReceived  = false;
				return;
			}
			setGamepadInputType(isGPad, isMouse);
		}

		protected function holdProcessing(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			var keycode:Number = details.code;

			if (details.value == InputValue.KEY_DOWN)
			{
				if ( _holdCount == 0 )
				{
					_holdTimer.delay = HOLD_DELAY;
					_holdTimer.reset();
					_holdTimer.start();
				}

				if ( !_holdInfoMap[keycode] )
				{
					++_holdCount;
					_holdInfoMap[keycode] = {timer: getTimer(), event: event, nextFire: getTimer() + HOLD_DELAY, holdInterval : HOLD_DELAY};
				}
				//trace("JIFIX DOWN", keycode);
			}
			else if (details.value == InputValue.KEY_UP)
			{
				if ( _holdInfoMap[keycode] )
				{
					--_holdCount;
					delete _holdInfoMap[keycode];
				}

				if ( _holdCount == 0 )
				{
					_holdTimer.stop();
				}
				//trace("JIFIX UP", keycode);
			}
		}

		protected function getSmallestDelay():Number
		{
			var currentTickTs : int = getTimer();
			var smallestTime : Number = -99999;
			for (var curKey:String in _holdInfoMap)
			{
				var curKeyTime : Number = _holdInfoMap[curKey].nextFire;
				var diffTime : Number = curKeyTime - currentTickTs;

				if(smallestTime == -99999 || diffTime < smallestTime)
					smallestTime = diffTime;

			}

			//Make it 1ms minimum, so it does not freeze the timer if there is a lag or something
			return Math.max(smallestTime,1);
		}

		protected function handleHoldEvent(event:Event):void
		{			
			var currentTickTs : int = getTimer();
			for (var curKey:String in _holdInfoMap)
			{
				var curKeyTime : int = _holdInfoMap[curKey].nextFire;
				if ( currentTickTs >= curKeyTime )
				{
					var curEvent:InputEvent = _holdInfoMap[curKey].event as InputEvent
					var curDetails:InputDetails = curEvent.details;
					
					var keyCode:int = curDetails.code;
					var navCode:String = curDetails.navEquivalent;
					if (swapAcceptCancel)
					{
						if (curDetails.code == KeyCode.PAD_A_CROSS)
						{
							keyCode = KeyCode.PAD_B_CIRCLE;
							navCode = NavigationCode.GAMEPAD_B;
						}
						else
						if (curDetails.code == KeyCode.PAD_B_CIRCLE)
						{
							keyCode = KeyCode.PAD_A_CROSS;
							navCode = NavigationCode.GAMEPAD_A;
						}
					}

					var details:InputDetails = new InputDetails("key", keyCode, InputValue.KEY_HOLD, navCode, curDetails.controllerIndex, curDetails.ctrlKey, curDetails.altKey, curDetails.shiftKey, curDetails.fromJoystick);
					var holdEvent:InputEvent = new InputEvent(InputEvent.INPUT, details)
					_inputDelegate.dispatchEvent(holdEvent);
					//trace("JIFIX InputManager::handleHoldEvent - FIRE : ", curKey, holdDuration(holdEvent) );

					var curHoldTime : int = _holdInfoMap[curKey].timer - currentTickTs;
					var curHoldInterval = _holdInfoMap[curKey].holdInterval;
					_holdInfoMap[curKey].holdInterval = Math.max(curHoldInterval * HOLD_INTERVAL_SPEED_UP_SCALE, HOLD_INTERVAL_MIN)
					_holdInfoMap[curKey].nextFire += _holdInfoMap[curKey].holdInterval;
				}
			}

			var newDelay : Number = getSmallestDelay();
			_holdTimer.delay = newDelay;
			_holdTimer.reset();
			_holdTimer.start();

			//trace("JIFIX NEW DELAY RUNS IN", newDelay)
		}

		public function holdDuration( inputEvent : InputEvent ) : int
		{
			var keycode:Number = inputEvent.details.code;
			if ( _holdInfoMap[keycode] )
			{
				var currentTs : int = getTimer();
				return currentTs - _holdInfoMap[keycode].timer;
			}

			return -1;
		}

		protected function handleMouse(event:MouseEvent):void
		{
			//trace("InputManager (" + _instanceID + ") handleMouse()");

			// I don't want to calculate pow on each mouse move event, so just simple axis delta check:
			var deltaX:Number = Math.abs(event.stageX - _bufMouseX);
			var deltaY:Number = Math.abs(event.stageY - _bufMouseY);
			
			if (deltaX > CHANGE_CONTROLLER_MOUSE_DELTA || deltaY > CHANGE_CONTROLLER_MOUSE_DELTA)
			{
				setGamepadInputType(_isGamepad, true);
			}
			_bufMouseX = event.stageX;
			_bufMouseY = event.stageY;
		}

		protected function setGamepadInputType(pGamepadInput:Boolean, pMouseInput:Boolean, forced:Boolean = false):void
		{
			//trace("START InputManager (" + _instanceID + ") setGamepadInputType() " +
			//	"(!_ctrlChangeTimer !" + _ctrlChangeTimer + " && (pGamepadInput " + pGamepadInput +  " != _isGamepad " + _isGamepad + " || pMouseInput " + pMouseInput + " != _isMouse " + _isMouse + ")) || " +
			//	"(_ctrlChangeTimer " + _ctrlChangeTimer + " && (pGamepadInput " + pGamepadInput + " != _pendedGamepadInput " + _pendedGamepadInput + " || pMouseInput " + pMouseInput + " != _pendedMouseInput " + _pendedMouseInput + " ))" );

			if ((!_ctrlChangeTimer && (pGamepadInput != _isGamepad || pMouseInput != _isMouse)) || 
				(_ctrlChangeTimer && (pGamepadInput != _pendedGamepadInput || pMouseInput != _pendedMouseInput)))
			{
				if (_ctrlChangeTimer)
				{
					_ctrlChangeTimer.removeEventListener(TimerEvent.TIMER, delayedFireControllerChangeEvent);
					_ctrlChangeTimer.stop();
				}
				
				if (lockedControlScheme != LOCKED_SCHEME_NONE && !forced)
				{
					trace("GFX Control scheme locked! Cant change it to from [gamepad ", _isGamepad, "] to [gamepad ", pGamepadInput, "]");
					return;
				}
				
				if (CHANGE_CONTROLLER_TYPE_DELAY > 0)
				{
					//trace("			InputManager (" + _instanceID + ") setGamepadInputType() CHANGE_CONTROLLER_TYPE_DELAY " + CHANGE_CONTROLLER_TYPE_DELAY + " > 0");

					_pendedGamepadInput = pGamepadInput;
					_pendedMouseInput = pMouseInput;
					_ctrlChangeTimer = new Timer(CHANGE_CONTROLLER_TYPE_DELAY, 1);
					_ctrlChangeTimer.addEventListener(TimerEvent.TIMER, delayedFireControllerChangeEvent, false, 0, true);
					_ctrlChangeTimer.start();
				}
				else
				{
					_isGamepad = pGamepadInput;
					_isMouse = pMouseInput;
					fireCtrlChangeEvent(_isGamepad, _isMouse);
				}

				//trace("			END InputManager (" + _instanceID + ") setGamepadInputType() _isGamepad: " + pGamepadInput + ", _isMouse: " + pMouseInput);
			}
		}
		
		protected function delayedFireControllerChangeEvent(event:TimerEvent):void
		{
			//trace("InputManager (" + _instanceID + ") delayedFireControllerChangeEvent()" +
			//	" _pendedGamepadInput: " + _pendedGamepadInput + " != " + " _isGamepad: " + _isGamepad +
			//	"; _pendedMouseInput: " + _pendedMouseInput + " != " + " _isMouse: " + _isMouse);

			if (_pendedGamepadInput != _isGamepad || _pendedMouseInput != _isMouse)
			{
				_isGamepad = _pendedGamepadInput;
				_isMouse = _pendedMouseInput;
				fireCtrlChangeEvent(_isGamepad, _isMouse)
			}

			if (_ctrlChangeTimer)
			{
				_ctrlChangeTimer.removeEventListener(TimerEvent.TIMER, delayedFireControllerChangeEvent);
				_ctrlChangeTimer.stop();
				_ctrlChangeTimer = null;
			}
		}
		
		protected var _validatingIsGamepad:Boolean = false;
		protected var _validatingIsMouse:Boolean = false;
		protected function fireCtrlChangeEvent(pIsGamepad:Boolean, pIsMouse:Boolean):void
		{
			//trace("InputManager (" + _instanceID + ") fireCtrlChangeEvent()" +
			//	" _validatingIsGamepad: " + _validatingIsGamepad + " -> " + " pIsGamepad: " + pIsGamepad +
			//	"; _validatingIsMouse: " + _validatingIsMouse + " -> " + " pIsMouse: " + pIsMouse);

			_validatingIsGamepad = pIsGamepad;
			_validatingIsMouse = pIsMouse;
			_rootStage.removeEventListener(Event.ENTER_FRAME, validateFireCtrlChangeEvent, false);
			_rootStage.addEventListener(Event.ENTER_FRAME, validateFireCtrlChangeEvent, false, 0, true);
		}
		
		protected function validateFireCtrlChangeEvent(event:Event = null):void
		{
			var ctrlEvent:ControllerChangeEvent = new ControllerChangeEvent(ControllerChangeEvent.CONTROLLER_CHANGE);
			
			//trace("InputManager (" + _instanceID + ") validateFireCtrlChangeEvent(): _validatingIsGamepad: " + _validatingIsGamepad + "; _validatingIsMouse: " + _validatingIsMouse);
			
			_rootStage.removeEventListener(Event.ENTER_FRAME, validateFireCtrlChangeEvent, false);
			ctrlEvent.isGamepad = _validatingIsGamepad;
			ctrlEvent.isMouse = _validatingIsMouse;
			dispatchEvent(ctrlEvent);
		}

		protected function isGamepadCode(details:InputDetails):Boolean
		{
			if (details.fromJoystick)
			{
				return true;
			}
			var keycode:Number = details.code;
			switch (keycode)
			{
				case KeyCode.PAD_A_CROSS:
				case KeyCode.PAD_B_CIRCLE:
				case KeyCode.PAD_X_SQUARE:
				case KeyCode.PAD_Y_TRIANGLE:
				case KeyCode.PAD_START:
				case KeyCode.PAD_BACK_SELECT:
				case KeyCode.PAD_DIGIT_UP:
				case KeyCode.PAD_DIGIT_DOWN:
				case KeyCode.PAD_DIGIT_LEFT:
				case KeyCode.PAD_DIGIT_RIGHT:
				case KeyCode.PAD_LEFT_THUMB:
				case KeyCode.PAD_RIGHT_THUMB:
				case KeyCode.PAD_LEFT_SHOULDER:
				case KeyCode.PAD_RIGHT_SHOULDER:
				case KeyCode.PAD_LEFT_TRIGGER:
				case KeyCode.PAD_RIGHT_TRIGGER:
				case KeyCode.PAD_LEFT_STICK_AXIS:
				case KeyCode.PAD_RIGHT_STICK_AXIS:
				case KeyCode.PAD_LEFT_TRIGGER_AXIS:
				case KeyCode.PAD_RIGHT_TRIGGER_AXIS:
				case KeyCode.PAD_RIGHT_STICK_LEFT:
				case KeyCode.PAD_RIGHT_STICK_RIGHT:
				case KeyCode.PAD_RIGHT_STICK_DOWN:
				case KeyCode.PAD_RIGHT_STICK_UP:
					return true;
			}
			return false;
		}

		protected function isGestureCode(details:InputDetails):Boolean
		{
			var keycode:Number = details.code;
			return keycode >= KeyCode.GESTURE_FIRST && keycode <= KeyCode.GESTURE_LAST;
		}

		public function reset() : void //#B
		{
			//trace("JIFIX IM RESET");
			if ( _holdInfoMap )
			{
				if (_holdTimer)
				{
					_holdTimer.reset();
					_holdTimer.stop();
				}
				_holdInfoMap = { };
				_holdCount = 0;
			}
		}
	}
}
