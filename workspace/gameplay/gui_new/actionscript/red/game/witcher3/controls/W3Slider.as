package red.game.witcher3.controls
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import scaleform.clik.controls.Slider;
	import red.core.events.GameEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.SliderEvent;
	import flash.events.TransformGestureEvent;
	import flash.events.GestureEvent;
	import red.core.events.GestureEventEx;
	import flash.events.Event;

	/**
	 * Slider component
	 * @author Yaroslav Getsevich
	 * 		   Bartosz Bigaj
	 */
	public class W3Slider extends Slider
	{
		public var txtValue:TextField;
		public var previousValue:Number = -1;
		private var errorTimer : Timer;
		protected var _lockedValue : Number = -1;
		protected var _gEvent : GameEvent = null;
		protected var _skipValue : Number = -1;
		public var isVertical:Boolean = false;
		private var _enableSounds:Boolean;

		[Inspectable(defaultValue="false")]
		public function get enableSounds():Boolean 
		{ 
			return _enableSounds 
		};

		public function set enableSounds(value:Boolean):void
		{
			_enableSounds = value;
		}

		override protected function configUI():void
		{
			super.configUI();
			errorTimer = new Timer(500,1);
			errorTimer.addEventListener( TimerEvent.TIMER, onErrorTimer, false, 0, true );
		}
		
        public function get gEvent():GameEvent 
		{ 
			return _gEvent; 
		}

        public function set gEvent(value:GameEvent):void 
		{
            _gEvent = value;
        }
		
        public function get lockedValue():Number 
		{ 
			return _lockedValue; 
		}

        public function set lockedValue(value:Number):void 
		{
            _lockedValue = value;
        }
		
		public function get skipValue():Number 
		{ 
			return _skipValue; 
		}

        public function set skipValue(value:Number):void 
		{
            _skipValue = value;
        }
		
		//Checks if trying to set value that should be skipped. Retunrs the same value if it should't be skipped or a next if it should.
		private function checkSkipValue(newValue : Number) : Number
		{
			if (newValue == skipValue && skipValue >= 0)
			{
				if (newValue > _value)
				{
					newValue = newValue + 1;
					if (_gEvent != null)
					{
						dispatchEvent(_gEvent);
					}
				}
				else if (newValue < _value)
				{
					newValue = newValue - 1;
					if (_gEvent != null)
					{
						dispatchEvent(_gEvent);
					}
				}	
			}
			return newValue;
		}

		private function isTwoState() : Boolean
		{
			return (maximum - minimum) < 2 && _snapInterval == 1;
		}
		
		override public function set value(value:Number):void
		{
			var newValue:Number = value;
			if (newValue >= _lockedValue && _lockedValue >= 0)
			{
				if (_gEvent != null)
				{
					dispatchEvent(_gEvent);
				}
				return;
			}
			
			newValue = checkSkipValue(newValue);
			
			const EPSILON:Number = 0.000001; //#LT hacky but with adding this error threshold, 0.09999999999 < 0.1 won't be an issue any longer

			if( newValue > maximum + EPSILON || newValue < minimum - EPSILON )
			{
				if ( previousValue != newValue && _enableSounds)
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPlaySoundEvent', ["gui_global_slider_move_failed"] ));
				}
				previousValue = newValue;
				if ( errorTimer == null )
				{
					errorTimer = new Timer(500,1);
					errorTimer.addEventListener( TimerEvent.TIMER, onErrorTimer, false, 0, true );
				}
				errorTimer.reset();
				errorTimer.start();
				return;
			}
			if (_enableSounds)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPlaySoundEvent', ["gui_global_slider_move"] ));
			}
			super.value = newValue;
			if ( txtValue )
			{
				txtValue.text = _value.toString();
			}
		}

		private function setNewValue( newValue : Number )
		{
			if (newValue >= _lockedValue && _lockedValue >= 0)
			{
				if (_gEvent != null)
				{
					dispatchEvent(_gEvent);	
				}
				return;
			}
			
            if (newValue != checkSkipValue(newValue))
			{
				newValue = checkSkipValue(newValue);
			}
            else if (value == newValue) 
			{
				return; 
			}
            value = newValue;
            
            if (!liveDragging) 
			{ 
                dispatchEvent( new SliderEvent(SliderEvent.VALUE_CHANGE, false, true, _value) );
            }
		}

		override public function handleInput(event:InputEvent):void {
			super.handleInput(event);

            var details:InputDetails = event.details;
            var index:uint = details.controllerIndex;
            
            var keyPress:Boolean = (details.value == InputValue.KEY_UP);
            switch (details.navEquivalent) {
                case NavigationCode.GAMEPAD_A:
                    if (keyPress) {
						// Step ahead once
						var newValue:Number = (value + _snapInterval);
						if (newValue > maximum) {
							newValue = minimum;
						}
						
						setNewValue(newValue);

						_trackDragMouseIndex = 0 // e.mouseIdx; // @todo, NFM: This needs to use the multi-controller system.
						_dragOffset = {x:0};

						event.handled = true;
                    }
                    break;
                default:
                    break;
            }
        }
		
		public function enableTouch( enable : Boolean ) : void
		{
			//Track is too hard to hit so register the gesture listeners to W3Slider bounds
			if ( enable )
			{
				addEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan, false, 0, true );
				addEventListener( GestureEventEx.GESTURE_TAP, handleGestureTap, false, 0, true );
			}
			else
			{
				removeEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan, false );
			    removeEventListener( GestureEventEx.GESTURE_TAP, handleGestureTap, false );
			}
		}

		private function onStartDrag( stageX : Number, stageY : Number ) : void 
		{
            _thumbPressed = true;
            
            var lp:Point = globalToLocal( new Point( stageX, stageY ) );
            _dragOffset = { x: (lp.x - thumb.x) - thumb.width / 2 };
		}

		private function onUpdateDrag( stageX : Number, stageY : Number ) : void
		{
 			var lp:Point = globalToLocal( new Point( stageX, stageY ) );
			var thumbPosition:Number = lp.x - _dragOffset.x;
			var trackWidth:Number = (_width - offsetLeft - offsetRight);
			var newValue:Number = lockValue( (thumbPosition - offsetLeft) / trackWidth * (_maximum - _minimum) + _minimum );
			
			setNewValue( newValue );

			updateThumb();
		}

		private function onStopDrag( ) : void
		{
            if ( !liveDragging ) 
			{ 
                dispatchEvent( new SliderEvent(SliderEvent.VALUE_CHANGE, false, true, _value) ); 
            }
            
            _trackDragMouseIndex = undefined;
            _thumbPressed = false;
            _trackPressed = false;
		}

		protected function handleGesturePan( event : TransformGestureEvent ) : void 
		{
			switch ( event.phase )
			{
				case "begin" : 
				{
					onStartDrag( event.stageX, event.stageY );
				}
				break;
				case "update" : 
				{
					onUpdateDrag( event.stageX, event.stageY );
				}
				break;
				case "end" : 
				{
					onStopDrag( );
				}
				break;
			}
		}

		override protected function beginDrag( event : MouseEvent ) : void 
		{
			onStartDrag( event.stageX, event.stageY );

			stage.addEventListener( MouseEvent.MOUSE_MOVE, doDrag, false, 0, true );
            stage.addEventListener( MouseEvent.MOUSE_UP, endDrag, false, 0, true );
        }

		override protected function endDrag( event : MouseEvent ) : void 
		{
            stage.removeEventListener( MouseEvent.MOUSE_MOVE, doDrag, false );
            stage.removeEventListener( MouseEvent.MOUSE_UP, endDrag, false );
            
			onStopDrag();
        }
		
		override protected function doDrag( event : MouseEvent ) : void 
		{
            onUpdateDrag( event.stageX, event.stageY );
        }

		protected function handleGestureTap( event : GestureEvent ) : void 
		{
			var newValue:Number = 0.0;

			//Run toggle logic if the slider is two state (to make it easier for the user to control it,
			//you just have to hit the bounds to toggle between the two states)
			if (isTwoState())
			{
				newValue = (value == minimum) ? (maximum) : (minimum);
			}
			//Run drag logic if there are multiple states
			else
			{
				_trackPressed = true;
				track.focused = _focused;
				
				var trackWidth:Number = (_width - offsetLeft - offsetRight);
				//Do not use event.localX here, because it can be local to the thumb if you hit that instead of the track
				var trackLocal : Point = track.globalToLocal( new Point(event.stageX, event.stageY) );
				newValue = lockValue( (trackLocal.x * scaleX - offsetLeft) / trackWidth * (_maximum - _minimum) + _minimum);
			}
			
			setNewValue(newValue);
            
            // Pressing on the track moves the grip to the cursor and the thumb becomes draggable.
            _trackDragMouseIndex = 0 // e.mouseIdx; // @todo, NFM: This needs to use the multi-controller system.
            
            // thumb.onPress(trackDragMouseIndex);
            _dragOffset = {x:0};
		}

		override protected function trackPress(e:MouseEvent):void 
		{
			var newValue:Number = 0.0;

			//Run toggle logic if the slider is two state (to make it easier for the user to control it,
			//you just have to hit the bounds to toggle between the two states)
			if (isTwoState())
			{
				newValue = (value == minimum) ? (maximum) : (minimum);
			}
			else
			{
            	_trackPressed = true;
            
            	track.focused = _focused;
            
            	var trackWidth:Number = (_width - offsetLeft - offsetRight);
            	newValue = lockValue( (e.localX * scaleX - offsetLeft) / trackWidth * (_maximum - _minimum) + _minimum);
			}

			setNewValue(newValue);

			// Pressing on the track moves the grip to the cursor and the thumb becomes draggable.
            _trackDragMouseIndex = 0 // e.mouseIdx; // @todo, NFM: This needs to use the multi-controller system.
            
            // thumb.onPress(trackDragMouseIndex);
            _dragOffset = {x:0};
        }
		
		public function onErrorTimer( event : TimerEvent )
		{
			errorTimer.stop();
			previousValue = -1;
		}
	}
}
