/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.events.GestureEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreMenuModule;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.controls.ConditionalButton;
	import red.game.witcher3.controls.W3TextArea;
	import red.game.witcher3.constants.EInputDeviceType;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import red.game.witcher3.constants.PlatformType;
	import red.core.events.GestureEventEx;
	import flash.events.TransformGestureEvent;
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import red.game.witcher3.utils.CommonUtils;

	public class GamepadMappingModule extends CoreMenuModule
	{
		public var txtLayoutName  : TextField;
		public var mcLeftPCButton : ConditionalButton;
		public var mcRightPCButton : ConditionalButton;

		public var txtRightJoy : W3TextArea;
		public var txtLeftJoyRightJoy : W3TextArea;
		public var txtXButton : W3TextArea;
		public var txtAButton : W3TextArea;
		public var txtBButton : W3TextArea;
		public var txtYButton : W3TextArea;
		public var txtYButtonPs : W3TextArea;
		public var txtYButtonXbox : W3TextArea;
		public var txtRightBumper : W3TextArea;
		public var txtRightBumperWithLines : W3TextArea;
		public var txtRightTrigger : W3TextArea;
		public var txtStartButton : W3TextArea;
		public var txtSelectButton : W3TextArea;
		public var txtLeftTrigger : W3TextArea;
		public var txtLeftTriggerWithLines : W3TextArea;
		public var txtLeftBumper : W3TextArea;
		public var txtLeftJoy : W3TextArea;
		public var txtDPad : W3TextArea;
		public var txtDPadWithLines : W3TextArea;
		
		public var txtLayoutName2 : TextField;
		public var txtLayoutName3 : TextField;
		public var txtLayoutName4 : TextField;
		public var txtLayoutName5 : TextField;
		public var txtLayoutName6 : TextField;
		protected var tabList:Vector.<TextField> = null;

		protected var dataArray : Array;
		protected var selectedIndex : int = 0;
		protected var platformType : int = PlatformType.PLATFORM_UNKNOWN;

		override protected function configUI():void
		{
			super.configUI();
			
			if (mcLeftPCButton)
			{
				mcLeftPCButton.addEventListener(ButtonEvent.PRESS, handlePrevButtonTapOrClick, false, 0, true);
			}
			
			if (mcRightPCButton)
			{
				mcRightPCButton.addEventListener(ButtonEvent.PRESS, handleNextButtonTapOrClick, false, 0, true);
			}

			enabled = false;
			visible = false;
			alpha = 0;
		}

		private function enableTouch() : void
		{
			if ( mcLeftPCButton )
			{
				mcLeftPCButton.addEventListener( GestureEventEx.GESTURE_TAP, handlePrevButtonTapOrClick, false, 0, true );
			}

			if ( mcRightPCButton )
			{
				mcRightPCButton.addEventListener( GestureEventEx.GESTURE_TAP, handleNextButtonTapOrClick, false, 0, true );
			}

			stage.addEventListener( TransformGestureEvent.GESTURE_SWIPE, handleGestureSwipe, false, 0, true );
		}

		private function disableTouch() : void
		{
			if ( mcLeftPCButton )
			{
				mcLeftPCButton.removeEventListener( GestureEventEx.GESTURE_TAP, handlePrevButtonTapOrClick, false );
			}

			if ( mcRightPCButton )
			{
				mcRightPCButton.removeEventListener( GestureEventEx.GESTURE_TAP, handleNextButtonTapOrClick, false );
			}

			stage.removeEventListener( TransformGestureEvent.GESTURE_SWIPE, handleGestureSwipe, false );
		}

		private function handleGestureSwipe( event : TransformGestureEvent ) : void
		{	
			switch( event.rotation )
			{
				case 0.0 : 
					navigateRight();
				break;
				case 180.0 : 
					navigateLeft();
				break;
			}
		}
		
		private function selectTab( event : Event ) : void
		{
			if ( CommonUtils.isEventTapGestureOrMouseLeftClick( event ) )
			{
				navigateToIndex(event.currentTarget.tabIndex);
			}
		}

		public function showWithData( data:Array, platform:int ):void
		{
			visible = true;
			GTweener.removeTweens(this);
			GTweener.to(this, 0.2, { alpha:1.0 }, { } );
	
			platformType = platform;
			
			switch (platform)
			{
			case PlatformType.PLATFORM_PC:
			case PlatformType.PLATFORM_PC_GDK:
				showControllerPC();
				break;
			case PlatformType.PLATFORM_XBOX1:
				gotoAndStop("xboxone");
				break;
			case PlatformType.PLATFORM_XB_SCARLETT_LOCKHART:
			case PlatformType.PLATFORM_XB_SCARLETT_ANACONDA:
				gotoAndStop("xboxseries");
				break;
			case PlatformType.PLATFORM_PS4:
				gotoAndStop("ps4");
				break;
			case PlatformType.PLATFORM_PS5:
				gotoAndStop("ps5");
				addEventListener( Event.ENTER_FRAME, handleEnterFrame, false, 0, true );
				break;
			case PlatformType.PLATFORM_SWITCH2:
				gotoAndStop("switch");
				break;
			}
			
			dataArray = data;
			selectedIndex = 0;
			updateButtonMapping();
			//Add listeners
			enableTouch();
		}

		private function showControllerPC(): void
		{
			var gamepadType:uint = InputManager.getInstance().gamepadType;

			switch (gamepadType)
			{
			case EInputDeviceType.IDT_PS4:
				gotoAndStop("ps4");
				return;
			case EInputDeviceType.IDT_PS5:
				gotoAndStop("ps5");
				return;
			case EInputDeviceType.IDT_Xbox1: // There isn't one for XSS
				gotoAndStop("xboxseries"); // Should it be XB1
				return;
			case EInputDeviceType.IDT_Switch2:
			case EInputDeviceType.IDT_Switch2_Mouser:
				gotoAndStop("switch");
				return;
			default:
				// modPS4++
				// gotoAndStop("xboxseries");
				gotoAndStop("ps4");
				// modPS4--
				return;
			}
		}
		
		private function handleEnterFrame(event:Event):void
		{
			if (txtLeftBumper)
			{
				txtLeftBumper.x = 125.7;
				txtLeftBumper.y = 376.9;
			}
			
			if (txtRightBumper)
			{
				txtRightBumper.x = 1098.05;
				txtRightBumper.y = 312.15;
			}
			
			if (txtYButton)
			{
				txtYButton.x = 1108.95;
				txtYButton.y = 438.3;
			}
			
			removeEventListener( Event.ENTER_FRAME, handleEnterFrame );
		}
		
		public function hide():void
		{
			if (visible)
			{
				disableTouch();
				GTweener.removeTweens(this);
				
				enabled = false;
				GTweener.to(this, 0.2, { alpha:0.0 }, { onComplete:onHideComplete } );
			}
		}
		
		protected function onHideComplete(curTween:GTween):void
		{
			visible = false;
		}
		
		protected function handlePrevButtonTapOrClick( event : Event ) : void
		{
			navigateLeft();
		}
		
		protected function handleNextButtonTapOrClick( event : Event ) : void
		{
			navigateRight();
		}
		
		public function handleInputNavigate(event:InputEvent):void
		{
			if (visible)
			{
				var details:InputDetails = event.details;
				var keyUp:Boolean = (details.value == InputValue.KEY_UP);
				
				if ( keyUp && !event.handled )
				{
					switch( details.navEquivalent )
					{
					case NavigationCode.GAMEPAD_B:
						{
							handleNavigateBack();
							event.handled = true;
						}
						break;
					case NavigationCode.LEFT:
						{
							navigateLeft();
							event.handled = true;
						}
						break;
					case NavigationCode.RIGHT:
						{
							navigateRight();
							event.handled = true;
						}						
						break;
				 	}
				}

				if( keyUp && !event.handled )
				{
					if( (details.code == KeyCode.LEFT || details.code == KeyCode.PAD_LEFT_SHOULDER))
					{
						navigateLeft();
						event.handled = true;
						return;
					}
					else if((details.code == KeyCode.RIGHT || details.code == KeyCode.PAD_RIGHT_SHOULDER))
					{
						navigateRight();
						event.handled = true;
						return;
					}
					else if((details.code == KeyCode.ESCAPE || details.code == KeyCode.PAD_B_CIRCLE))
					{
						handleNavigateBack();
						event.handled = true;
						return;
					}
				}
			}
		}
		
		protected function navigateLeft():void
		{
			selectedIndex = selectedIndex > 0 ? selectedIndex - 1 : dataArray.length - 1;
			updateButtonMapping();
		}
		
		protected function navigateRight():void
		{
			selectedIndex = selectedIndex < ( dataArray.length - 1 ) ? selectedIndex + 1 : 0;
			updateButtonMapping();
		}

		protected function navigateToIndex(index : int):void
		{
			trace( "GamepadMappingModule::navigateToIndex : ", index, selectedIndex );
			selectedIndex = index;
			updateButtonMapping();
		}
		
		private function createTabList() : void
		{
			trace( "GamepadMappingModule::createTabList" );

			tabList = new Vector.<TextField>();
			tabList.push( txtLayoutName, txtLayoutName2, txtLayoutName3, txtLayoutName4, txtLayoutName5, txtLayoutName6 );

			var len : int = tabList.length;
			for ( var i : int = 0; i < len; i++ )
			{
				var tab : TextField = tabList[i];
				tab.tabIndex = i;
				tab.addEventListener( GestureEventEx.GESTURE_TAP, selectTab, false, 0, true );
				tab.addEventListener( MouseEvent.CLICK, selectTab, false, 0, true );
			}
		}

		private function updateButtonCaption( textArea : W3TextArea, text : String ) : void
		{
			const HTML_SIZE_OPEN : String = "<font size='24'>";
			const HTML_SIZE_CLOSE : String = "</font>";

			if (textArea)
			{
				var visible : Boolean = text != "" && text != "null";
				textArea.visible = visible;
				if ( visible )
				{	
					textArea.htmlText = platformType != PlatformType.PLATFORM_SWITCH2 ? text : HTML_SIZE_OPEN + text + HTML_SIZE_CLOSE;
					//trace("DEBUGMAP: " + textArea + " " + textArea.htmlText);
				}
			}
		}

		private function updateSwitch2TabList() : void
		{
			tabList = null;

			if( platformType == PlatformType.PLATFORM_SWITCH2)
			{
				const BASE_COLOR : uint = 0x888478;
				const HIGHLIGHT_COLOR : uint = 0xE9E9E9;
				
				var animFrame : String = ( selectedIndex == 5 ) ? "switchMouser" : "switch";
				gotoAndStop( animFrame );

				createTabList();

				for each ( var tf : TextField in tabList )
				{
					tf.textColor = BASE_COLOR;
					tf.htmlText = dataArray[tf.tabIndex].layoutName;
				}

				if ( selectedIndex < tabList.length )
				{
					tabList[selectedIndex].textColor = HIGHLIGHT_COLOR;
				}
			}
		}

		protected function updateButtonMapping():void
		{
			var currentData : Object = dataArray[ selectedIndex ];

			if ( platformType != PlatformType.PLATFORM_SWITCH2 )
			{
				if ( txtLayoutName )
				{
					txtLayoutName.htmlText = currentData.layoutName;
				}
			}
			else
			{
				updateSwitch2TabList();
			}
		
			if (txtLeftJoyRightJoy)
			{
				var visible : Boolean = currentData.txtLeftJoyRightJoy != "" && platformType != PlatformType.PLATFORM_PS4 && platformType != PlatformType.PLATFORM_XBOX1;
				txtLeftJoyRightJoy.visible = visible;
				if ( visible )
				{	
					if( platformType == PlatformType.PLATFORM_SWITCH2)
						txtLeftJoyRightJoy.htmlText = "<p align='center'><font size='34'>" + currentData.txtLeftJoyRightJoy + "</font></p>";
					else
						txtLeftJoyRightJoy.htmlText = "<p align='center'>" + currentData.txtLeftJoyRightJoy + "</p>";
				}
			}
			
			updateButtonCaption( txtRightJoy, currentData.txtRightJoy );
			updateButtonCaption( txtXButton, currentData.txtXButton );
			updateButtonCaption( txtAButton, currentData.txtAButton );
			updateButtonCaption( txtBButton, currentData.txtBButton );
			updateButtonCaption( txtYButton, currentData.txtYButton );
			updateButtonCaption( txtYButtonXbox, currentData.txtYButton );
			updateButtonCaption( txtYButtonPs, currentData.txtYButton );
			updateButtonCaption( txtRightBumper, currentData.txtRightBumper );
			updateButtonCaption( txtRightBumperWithLines, currentData.txtRightBumper );
			updateButtonCaption( txtRightTrigger, currentData.txtRightTrigger );
			updateButtonCaption( txtStartButton, currentData.txtStartButton );
			updateButtonCaption( txtSelectButton, currentData.txtSelectButton );
			updateButtonCaption( txtLeftTrigger, currentData.txtLeftTrigger );
			updateButtonCaption( txtLeftTriggerWithLines, currentData.txtLeftTrigger );
			updateButtonCaption( txtLeftBumper, currentData.txtLeftBumper );
			updateButtonCaption( txtLeftJoy, currentData.txtLeftJoy );
			updateButtonCaption( txtDPad, currentData.txtDPad );
			updateButtonCaption( txtDPadWithLines, currentData.txtDPad );
		}

		public function onRightClick( event:MouseEvent ):void
		{
			if ( visible )
			{
				handleNavigateBack();
			}
		}

		protected function handleNavigateBack():void
		{
			dispatchEvent( new Event(IngameMenu.OnOptionPanelClosed, false, false) );
		}
	}
}