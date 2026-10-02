package red.game.witcher3.menus.photomode 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import flash.utils.Timer;

	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.MouseEventEx;

	import red.core.CoreMenu;
	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	import red.core.events.GameEvent;
	import red.core.utils.InputUtils;
	import red.game.witcher3.constants.EInputDeviceType;
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import red.game.witcher3.utils.CommonUtils;
	
	public class PhotomodeMenu extends CoreMenu
	{
		public var m_notification : PhotomodeNotification;
		public var m_tabbedMenu : PhotomodeTabbedMenu;
		public var mc_characterListMenu : PhotomodeCharacterList;
		public var mc_propListMenu : PhotomodePropList;
		public var mc_lightListMenu : PhotomodeLightList;

		public var m_bottomAnchor : MovieClip;
		public var m_leftAnchor : MovieClip;
		public var m_thirdsLines : PhotomodeThirdsLines;
		public var m_coordsText : TextField;
		public var m_background : MovieClip;
		public var mcCharHighlight : MovieClip;
		public var m_tlBlackBar : MovieClip; //topleft
		public var m_brBlackBar : MovieClip; //bottomright
		public var m_screenshotArea : MovieClip;
		
		private var m_bottomHints : Vector.<InputFeedbackButton>;
		private var m_leftHints : Vector.<InputFeedbackButton>;
		private var m_bottomHintsVisible : Boolean = true;
		private var m_leftHintsVisible : Boolean = true;

		private const TICK_INTERVAL : Number = 25; // 100 ms
		private var tickTimer:Timer = new Timer(TICK_INTERVAL);

		private var m_exitDelayTimer:Timer;

		private var m_cameraLocked : Boolean = false;

		private var m_allowedAreas : Vector.<String> = new Vector.<String>();
		private var top : Number, left : Number, bottom : Number, right : Number;

		private static const MOVE_KEYS:Array = [KeyCode.W, KeyCode.A, KeyCode.S, KeyCode.D];
		private var heldKeys:Vector.<uint> = new Vector.<uint>();
		private var m_isSwitch2MouserLeftAxisHeld : Boolean = false;
		private var m_isSwitch2MouserCameraUpHeld : Boolean = false;
		private var m_isSwitch2MouserCameraDownHeld : Boolean = false;

		private var m_leftMouseLastTarget : MovieClip;
		private var m_rightMouseLastTarget : MovieClip;

		private var m_isBackgroundDragged : Boolean = false;

		private var m_currentPhotomodeState : int;
		private var m_isUIHidden : Boolean;
		private var m_isCharacterHighlightVisible : Boolean;
		private var m_isRuleOfThirdsVisible : Boolean = true;

		public function PhotomodeMenu() 
		{			
			_disableShowAnimation = true;
			m_bottomHints = new Vector.<InputFeedbackButton>;
			m_leftHints = new Vector.<InputFeedbackButton>; 
			
			super();
			_restrictDirectClosing = true;

			m_tlBlackBar.visible = false;
			m_brBlackBar.visible = false;

			m_tlBlackBar.width = 0;
			m_tlBlackBar.height = 0;
			m_brBlackBar.width = 0;
			m_brBlackBar.height = 0;

			m_notification.visible = false;
			m_leftAnchor.visible = false;
			m_bottomAnchor.visible = false;
			
			updatePhotoModeState(0);

			///////
			/*
			var testData = {};
			testData.tabs = [{label:"Some text", data:[]}, {label:"Test"}, {label:"Yes this is some"}, {label:"The last"}];
			fillTabbedMenu(testData);
			*/
			///////
		}
		
		override protected function get menuName():String
		{
			return "PhotomodeMenu";
		}
		
		override protected function configUI():void
		{
			super.configUI();	
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "photomode.tabs", [fillTabbedMenu] ) );
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			this.visible = true;
			m_notification.visible = false;
			m_leftAnchor.visible = false;
			m_bottomAnchor.visible = false;
			
			//free camera is allowed because camera is not locked at the beginning
			m_allowedAreas.push("freeCamera");
			initHints();

			tickTimer.addEventListener(TimerEvent.TIMER, onTick);
			tickTimer.start();

			stage.addEventListener(MouseEvent.CLICK, onAnyClick);

			addEventListener(MouseEvent.MOUSE_DOWN, onAnyMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onAnyMouseUp);

			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
			mcCharHighlight.visible = false;

		}	

		public function /*WS*/ updatePhotoModeState(state : int)
		{	
			m_currentPhotomodeState = state;
			m_tabbedMenu.visible = false;
			//m_tabbedMenu.onThisList = false;
			mc_characterListMenu.visible = false;
			mc_characterListMenu.onThisList = false;
		 	mc_propListMenu.visible = false;
		 	mc_propListMenu.onThisList = false;
		 	mc_lightListMenu.visible = false;
		 	//mc_lightListMenu.onThisList = false;

			switch (state) 
			{
				case 0:
					m_tabbedMenu.visible = true;
					//m_tabbedMenu.onThisList = true;
					return;
				case 1:
					mc_characterListMenu.visible = true;
					mc_characterListMenu.onThisList = true;
					return;
				case 2:
					mc_propListMenu.visible = true;
					mc_propListMenu.onThisList = true;
					return;
				case 3:
					mc_lightListMenu.visible = true;
					//mc_lightListMenu.onThisList = true;
					return;
			}			
		}

		private function handleControllerChange(event:ControllerChangeEvent)
		{
			var isMouse : Boolean = InputManager.getInstance().isMouse();

			initHints();

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnRequestCursor", [isMouse] ) );
			//With controller we should be able to move camera all the time, except if its fully locked
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSetCameraDraggable", [isCameraDraggable()] ) );
		}

		private function onAnyClick(e:MouseEvent)
		{
			trace("JIFIX clicked on:", e.target, e.target.name);
		}

		private function isCameraDraggable():Boolean
		{
			var isSwitch2Mouser : Boolean = _inputMgr.gamepadType == EInputDeviceType.IDT_Switch2_Mouser;

			//trace("JIFIX BOOL TEST", m_lastTarget == m_background, heldKeys.length > 0);

			if (isSwitch2Mouser)
			{
				return m_isBackgroundDragged || m_isSwitch2MouserLeftAxisHeld || m_isSwitch2MouserCameraUpHeld || m_isSwitch2MouserCameraDownHeld;
			}

			return m_isBackgroundDragged || heldKeys.length > 0 || _inputMgr.isGamepad();
		}

		private function onAnyMouseDown(e:MouseEvent)
		{
			trace("JIFIX CLICKTEST DOWN");
			var superMouseEvent : MouseEventEx = e as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				m_leftMouseLastTarget = e.target as MovieClip;
			}
			if (superMouseEvent.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				m_rightMouseLastTarget = e.target as MovieClip;
			}

			if (!m_isBackgroundDragged)
			{
				m_isBackgroundDragged = m_leftMouseLastTarget == m_background || m_rightMouseLastTarget == m_background;

				if (m_isBackgroundDragged) {

					dispatchEvent( new GameEvent( GameEvent.CALL, "OnRequestCursor", [false] ) );
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnSaveLastMouseCoords", [e.stageX, e.stageY] ) );
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnSetCameraDraggable", [true] ) );
				}
			}
		}

		private function onAnyMouseUp(e:MouseEvent)
		{
			trace("JIFIX CLICKTEST UP");
			var prevIsBackgroundDragged : Boolean = m_isBackgroundDragged;
			var superMouseEvent : MouseEventEx = e as MouseEventEx;

			if (superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				m_leftMouseLastTarget = null;
			}
			if (superMouseEvent.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				m_rightMouseLastTarget = null;
			}

			m_isBackgroundDragged = m_leftMouseLastTarget == m_background || m_rightMouseLastTarget == m_background;
			var isBackgroundDraggedLetGo : Boolean = prevIsBackgroundDragged && !m_isBackgroundDragged;

			if (isBackgroundDraggedLetGo)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnRequestCursor", [true] ) );
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnRequestResetCursorPos", [true] ) );
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnSetCameraDraggable", [isCameraDraggable()] ) );
			}
		}
		
		// created for calling from .ws scripts
		public function fillTabbedMenu(obj : Object) : void
		{
			var rootDataProvider : DataProvider = new DataProvider();

			for each( var tab : Object in obj.tabs )
			{
				var tabModel : Object = new Object();
				tabModel.label = tab.label;
				tabModel.data = toDataProvider(tab.data);
				tabModel.tabId = tab.tabId;
				tabModel.totalTabs = obj.tabs.length;
				
				rootDataProvider.push(tabModel);
			}
			
			m_tabbedMenu.setTabs(rootDataProvider);
		}
		
		public function onScreenshotSaved():void 
		{
			m_notification.m_text.text = "[[photomode_screenshot_saved]]";
			m_notification.visible = true;
			m_notification.gotoAndPlay("start");
		}
		
		public function setCurrentFrameScale(vScale : Number , hScale : Number):void 
		{
			var screenCenterX = stage.width / 2;
			var screenCenterY = stage.height / 2;
			
			m_leftAnchor.x = screenCenterX - hScale * (screenCenterX - m_leftAnchor.x);
			m_leftAnchor.y = screenCenterY - vScale * (screenCenterY - m_leftAnchor.y);
			
			m_bottomAnchor.x = screenCenterX - hScale * (screenCenterX - m_bottomAnchor.x);
			m_bottomAnchor.y = screenCenterY - vScale * (screenCenterY - m_bottomAnchor.y);
			
			m_tabbedMenu.x = screenCenterX - hScale * (screenCenterX - m_tabbedMenu.x - m_tabbedMenu.width) - m_tabbedMenu.width;
			m_tabbedMenu.y = screenCenterY - hScale * (screenCenterY - m_tabbedMenu.y - m_tabbedMenu.height) - m_tabbedMenu.height;
			
			m_tabbedMenu.invalidate();
			initHints();
		}

		private function setCameraDraggable():void
		{
			//trace("JIFIX held Keys", heldKeys, heldKeys.length);
			var draggable : Boolean = isCameraDraggable();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSetCameraDraggable", [draggable] ) );
		}

		public function /*WS*/ startExitDelayTimer(millisecs : int):void
		{
			m_exitDelayTimer = new Timer(millisecs, 1);
			m_exitDelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onExitDelayTimerEnded);
			m_exitDelayTimer.start();
		}

		private function onExitDelayTimerEnded( event : TimerEvent ) : void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnExitPhotomode" ) );
		}

		protected override function handleInputNavigate(event:InputEvent):void 
		{
			var details:InputDetails = event.details;
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
			var keyHold:Boolean = details.value == InputValue.KEY_HOLD;
			var i : int = 0;

			// Set "heldKeys" and set draggableCamera flag
			if (keyDown || keyUp)
			{
				for (i = 0; i < MOVE_KEYS.length; i++)
				{
					if (details.code == MOVE_KEYS[i])
					{
						var index : int = heldKeys.indexOf(details.code);
						var isKeyHeld : Boolean = index != -1;
						if (keyDown && !isKeyHeld)
						{
							heldKeys.push(details.code);
							setCameraDraggable();
						}
						else if (keyUp && isKeyHeld) 
						{
							heldKeys.splice(index, 1);
							setCameraDraggable();
						}
					}
				}
			}

			// Hack for switch 2 mouser. We want camera dragging and movement keys to work similar like on PC..
			if ( _inputMgr.getPlatform() == PlatformType.PLATFORM_SWITCH2 && _inputMgr.gamepadType == EInputDeviceType.IDT_Switch2_Mouser)
			{
				if (details.code == KeyCode.PAD_LEFT_STICK_AXIS)
				{
					var axisData : InputAxisData = InputAxisData(details.value);
					var magnitude : Number = InputUtils.getMagnitude( axisData.xvalue, axisData.yvalue );
					var isLeftAxisHeld : Boolean = magnitude > 0.1;
					if ( isLeftAxisHeld != m_isSwitch2MouserLeftAxisHeld )
					{
						m_isSwitch2MouserLeftAxisHeld = isLeftAxisHeld;
						setCameraDraggable();
					}
				}

				if (details.code == KeyCode.PAD_LEFT_SHOULDER || details.code == KeyCode.PAD_LEFT_TRIGGER)
				{
					var isUpHeld = m_isSwitch2MouserCameraUpHeld;
					var isDownHeld = m_isSwitch2MouserCameraDownHeld;
					var updateCameraDraggable = false;

					if (details.code == KeyCode.PAD_LEFT_SHOULDER)
						isUpHeld = keyDown || keyHold;

					if (details.code == KeyCode.PAD_LEFT_TRIGGER)
						isDownHeld = keyDown || keyHold;

					if (m_isSwitch2MouserCameraUpHeld != isUpHeld)
					{
						m_isSwitch2MouserCameraUpHeld = isUpHeld;
						updateCameraDraggable = true;
					}

					if (m_isSwitch2MouserCameraDownHeld != isDownHeld)
					{
						m_isSwitch2MouserCameraDownHeld = isDownHeld;
						updateCameraDraggable = true;
					}

					if (updateCameraDraggable)
					{
						setCameraDraggable();
					}
				}
			}

			if (keyDown)
			{
				switch (details.code)
				{
					case KeyCode.SPACE:
						if( _inputMgr.getPlatform() == PlatformType.PLATFORM_PC || _inputMgr.getPlatform() == PlatformType.PLATFORM_PC_GDK )
							dispatchEvent(new GameEvent(GameEvent.CALL, 'OnScreenShotRequested'));
						return;
					case KeyCode.TAB:	
					case KeyCode.PAD_RIGHT_THUMB:
						ChangeHidePhotomodeUI();
						return;
					case KeyCode.ESCAPE:
						dispatchEvent(new GameEvent(GameEvent.CALL, 'OnTryClosingMenu'));
						return;
					default:
						break;
				}

				switch (details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_START:
						if( _inputMgr.getPlatform() == PlatformType.PLATFORM_PC || _inputMgr.getPlatform() == PlatformType.PLATFORM_PC_GDK)
							dispatchEvent(new GameEvent(GameEvent.CALL, 'OnScreenShotRequested'));
						return;
					case NavigationCode.GAMEPAD_B:
						dispatchEvent(new GameEvent(GameEvent.CALL, 'OnTryClosingMenu'));
						return;
					case NavigationCode.GAMEPAD_A:
						if( _inputMgr.getPlatform() == PlatformType.PLATFORM_SWITCH2 )
							dispatchEvent(new GameEvent(GameEvent.CALL, 'OnScreenShotRequested'));
						return;
					default:
						break;
				}
			}
		}
		
		private function toDataProvider(tabData:Array):DataProvider 
		{
			var dataProvider : DataProvider = new DataProvider;
			
			for each(var item : Object in tabData)
			{
				var dataObj : Object = { data: item }; 

				if(item.rendererType == "slider" || item.rendererType == "selector" || item.rendererType == "colorSlider") {
					var sliderModel : PhotomodeSliderDataModel = new PhotomodeSliderDataModel();
					sliderModel.setDataModel.apply(sliderModel, item.args);
					dataObj["sliderData"] = sliderModel;
				}
				dataProvider.push(dataObj);
			}
			
			return dataProvider;
		}

		public function ChangeHidePhotomodeUI()
		{
			m_isUIHidden = ! m_isUIHidden;

			switch (m_currentPhotomodeState)
			{
				case 0:
					m_tabbedMenu.visible = !m_isUIHidden;
					break;
				case 1:
					mc_characterListMenu.visible = !m_isUIHidden;
					break;
				case 2:
					mc_propListMenu.visible = !m_isUIHidden;
					break;
				case 3:
					mc_lightListMenu.visible = !m_isUIHidden;
					break;
			}
			mcCharHighlight.visible = m_isCharacterHighlightVisible && !m_isUIHidden;
			m_thirdsLines.visible = m_isRuleOfThirdsVisible && !m_isUIHidden;
			m_coordsText.visible = !m_isUIHidden;
			m_screenshotArea.visible = !m_isUIHidden;

			m_bottomHintsVisible = !m_isUIHidden;
			m_leftHintsVisible = !m_isUIHidden;

			if (m_isUIHidden)
				setHintsVisible(m_isUIHidden);
			else
				initHints();
		}

		public function removeHintArea(area : String, update : Boolean = true)
		{
			var index : int = m_allowedAreas.indexOf(area);
			
			if(index != -1)
				m_allowedAreas.splice(index, 1);

			if(update)
				initHints();
		}

		public function addHintArea(area : String, update : Boolean = true)
		{
			if(m_allowedAreas.indexOf(area) == -1)
				m_allowedAreas.push(area);

			if(update)
				initHints();
		}

		private static const HOLD_CHECK_INTERVAL : Number = 25;
		private function handleLockCameraHold(button: InputFeedbackButton):void
		{
			var pct : Number = m_tabbedMenu.getLockPercentage();

			if(!_inputMgr.isGamepad() && button.mcKeyboardIcon)
				button.mcKeyboardIcon.setFill(int(pct));
			else if (_inputMgr.isGamepad())
			{
				button.UpdateHoldAnimationWithPercentage(pct/100);
			}

			
			if(button)
				setTimeout(handleLockCameraHold, HOLD_CHECK_INTERVAL, button);
		}
		
		private function initBottomHints():int
		{
			var isSwitchPlatform : Boolean = _inputMgr.isSwitchPlatform();
			var isSwitch2Mouser : Boolean = _inputMgr.gamepadType == EInputDeviceType.IDT_Switch2_Mouser;
			var ClassRef:Class = getDefinitionByName("HintButtonRef") as Class;
			var i:int;
			var hintMaxHeight:int;

			var bottomHintsModels : Array = [
				{ txt: "[[photomode_lock_camera]]", gpCode: isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, kbCode: KeyCode.T, area: "freeCamera", hold: handleLockCameraHold, holdDuration : 1000 },
				{ txt: "[[photomode_unlock_camera]]", gpCode: isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, kbCode: KeyCode.T, area: "lockedCamera", hold: handleLockCameraHold, holdDuration: 1000 },
				{ txt: "[[photomode_navigation_previous_tab]]", gpCode: isSwitch2Mouser ? NavigationCode.INVALID : NavigationCode.GAMEPAD_L1, kbCode: KeyCode.Q },
				{ txt: "[[photomode_navigation_next_tab]]", gpCode: isSwitch2Mouser ? NavigationCode.INVALID : NavigationCode.GAMEPAD_R1, kbCode: KeyCode.E },
				{ txt: "[[photomode_navigation_take_screenshot]]", gpCode: ( _inputMgr.getPlatform() == PlatformType.PLATFORM_PC || _inputMgr.getPlatform() == PlatformType.PLATFORM_PC_GDK ) ? NavigationCode.GAMEPAD_START : 
					NavigationCode.GAMEPAD_SHARE, kbCode: KeyCode.SPACE },
				{ txt: "[[photomode_navigation_toggle_ui]]", gpCode: NavigationCode.GAMEPAD_RSTICK_HOLD, kbCode: KeyCode.TAB },
				{ txt: "[[photomode_navigation_exit]]", gpCode: NavigationCode.GAMEPAD_B, kbCode: KeyCode.ESCAPE } ];

			var predicate = function (obj:Object) 
			{
				return ((_inputMgr.isGamepad() && obj.gpCode != NavigationCode.INVALID) 
					|| (!_inputMgr.isGamepad() && obj.kbCode != KeyCode.INVALID))
					&& (!obj.hasOwnProperty("area") || m_allowedAreas.indexOf(obj.area) != -1); 
			};
			bottomHintsModels = bottomHintsModels.filter(predicate);
			
			// Remove existing hints
			if( isSwitchPlatform ) //<-- since kbm backgrounds did not show, and it was fine on controller
				{
				for (i = 0; i < m_bottomHints.length; i++)
				{
					if (m_bottomHints[i] != null)
					{
						this.removeChild(m_bottomHints[i]);
						m_bottomHints[i] = null;
					}
				}
			}

			m_bottomHints.length = bottomHintsModels.length;
			
			var padding : uint = 20;
			var xOffset : int = 0;
			// bottomHintsModels.reverse();
			hintMaxHeight = 0;

			for (i = 0; i < bottomHintsModels.length; i++)
			{
				var model : Object =  bottomHintsModels[i];
				var hint : InputFeedbackButton = m_bottomHints[i];
				
				if (hint == null)	
				{
					m_bottomHints[i] = new ClassRef() as InputFeedbackButton
					hint = m_bottomHints[i];
					this.addChild(hint);

					if(model.hasOwnProperty("hold"))
					{
						model["hold"](hint);
						hint.holdDuration = model["holdDuration"];
					}
				}
					
				hint.label = model.txt;
				hint.setDataFromStage(model.gpCode, model.kbCode);
				hint.clickable = false;
				hint.visible = m_bottomHintsVisible;
				hint.validateNow();
				
				hint.x = m_leftAnchor.x + xOffset;
				hint.y = m_bottomAnchor.y - hint.height / 2;
				xOffset += hint.getOccupiedWidth() + padding;

				if (hintMaxHeight < hint.height)
				{
					hintMaxHeight = hint.height;
				}
			}

			return hintMaxHeight;
		}

		private function initLeftHints(bottomOffset:int):void
		{
			var isSwitchPlatform : Boolean = _inputMgr.isSwitchPlatform();
			var isSwitch2Mouser : Boolean = _inputMgr.gamepadType == EInputDeviceType.IDT_Switch2_Mouser;
			var ClassRef:Class = getDefinitionByName("HintButtonRef") as Class;
			
			var leftHintsModels : Array = [
				[ 
					{ txt: "", gpCode: NavigationCode.GAMEPAD_L3, kbCode: KeyCode.LEFT_MOUSE, area: "freeCamera" },
					{ txt: "", gpCode: NavigationCode.INVALID, kbCode: KeyCode.W, area: "freeCamera" },  
					{ txt: "", gpCode: NavigationCode.INVALID, kbCode: KeyCode.A, area: "freeCamera" },
					{ txt: "", gpCode: NavigationCode.INVALID, kbCode: KeyCode.S, area: "freeCamera" },
					{ txt: "[[photomode_hints_move_camera]]", gpCode: NavigationCode.INVALID, kbCode: KeyCode.D, area: "freeCamera" } 
				],			
				[ 
					{ txt: "[[photomode_hints_rotate_camera]]", gpCode: isSwitch2Mouser ? NavigationCode.GAMEPAD_R2 : NavigationCode.GAMEPAD_R3, kbCode: KeyCode.RIGHT_MOUSE, area: "freeCamera" } 
				],		
				[
					{ txt: "[[photomode_hints_camera_distance]]", gpCode: NavigationCode.INVALID, kbCode: KeyCode.MOUSE_SCROLL, area: "freeCamera" }
				],
				[
					{ txt: "", gpCode: isSwitch2Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_L2, kbCode: KeyCode.R, area: "freeCamera" },
					{ txt: "[[photomode_hints_camera_up_down]]", gpCode: isSwitch2Mouser ? NavigationCode.GAMEPAD_L2 : NavigationCode.GAMEPAD_R2, kbCode: KeyCode.F, area: "freeCamera" }
				],
				[ 
					{ txt: "", gpCode: NavigationCode.DPAD_UP_DOWN, kbCode: KeyCode.UP, area: "multiple" },
					{ txt: "[[photomode_hints_select_option]]", gpCode: NavigationCode.INVALID, kbCode: KeyCode.DOWN, area: "multiple" } 
				],
				[ 
					{ txt: "", gpCode: NavigationCode.GAMEPAD_DPAD_LR, kbCode: KeyCode.LEFT, area: "changeValue" },
					{ txt: "[[photomode_hints_change_value]]", gpCode: NavigationCode.INVALID, kbCode: KeyCode.RIGHT, area: "changeValue" } 
				],
				// [
				// 	{ txt: "[[photomode_hints_load_slot]]", gpCode: isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, kbCode: KeyCode.BACKSPACE, area: "saver" }
				// ],
				[
					{ txt: "[[photomode_hints_save_slot]]", gpCode: NavigationCode.GAMEPAD_A, kbCode: KeyCode.ENTER, area: "saver" }
				]
			];
			
			var leftHintsButtonCount : uint = 0;
			var predicate = function (obj:Object) 
			{
				return ((_inputMgr.isGamepad() && obj.gpCode != NavigationCode.INVALID) 
					|| (!_inputMgr.isGamepad() && obj.kbCode != KeyCode.INVALID))
					&& (!obj.hasOwnProperty("area") || m_allowedAreas.indexOf(obj.area) != -1); 
			};
			
			for (var i : int = 0; i < leftHintsModels.length; i++)
			{
				var filteredArray : Array = leftHintsModels[i].filter(predicate);
				
				
				if (filteredArray.length == 0)
				{
					leftHintsModels[i] = filteredArray;
					continue;
				}
				
				leftHintsButtonCount += filteredArray.length;
				filteredArray[filteredArray.length - 1].txt = leftHintsModels[i][leftHintsModels[i].length - 1].txt;
				leftHintsModels[i] = filteredArray;
			}
			
			if(m_leftHints.length < leftHintsButtonCount)
				m_leftHints.length = leftHintsButtonCount;
			
			leftHintsModels.reverse();

			var xOffset : uint = 0;
			var yOffset : uint = bottomOffset * 0.75;
			var hintMaxHeight : uint = 0;
			var cur : uint = 0;
			var hint : InputFeedbackButton;
			var model : Object;
			for (i = 0; i < leftHintsModels.length; i++)
			{
				xOffset = 0;
				hintMaxHeight = 0;
				for (var j:int = 0; j < leftHintsModels[i].length; j++)
				{
					model = leftHintsModels[i][j];
					hint = m_leftHints[cur];
									
					if (hint == null)	
					{
						hint = m_leftHints[cur] = new ClassRef() as InputFeedbackButton;
						this.addChild(hint);
					}
									
					hint.label = model.txt;
					hint.clickable = false;
					hint.visible = m_leftHintsVisible;
					hint.setDataFromStage(model.gpCode, model.kbCode);
					hint.validateNow();
					
					if (hintMaxHeight < hint.height)
						hintMaxHeight = hint.height;
					
					hint.x = m_leftAnchor.x + xOffset;
					hint.y = m_leftAnchor.y - yOffset - hint.height / 2;
					
					xOffset += hint.getOccupiedWidth();
					
					cur++;
				}
				
				yOffset += hintMaxHeight * 0.75;	
			}
			
			for (; cur < m_leftHints.length; cur++)
			{
				hint = m_leftHints[cur];
				
				if (hint)
					hint.visible = false;
			}
		}

		private function initHints():void 
		{
			var bottomHintMaxHeight:int;
			bottomHintMaxHeight = initBottomHints();
			initLeftHints(bottomHintMaxHeight);
		}

		public function /*WS*/ setThirdsLinesAspectRatio(width:int, height:int) : void
		{
			m_thirdsLines.SetFullscreenAspectRatio(width,height);

			var asp : String = m_thirdsLines.GetAspectRatioString(width,height);
			switch(asp)
			{
				default:
				case "16:9":
					top = 0;
					left = 0;
					bottom = 1080;
					right = 1920;
					break;
				case "4:3":
					top = -180;
					left = 0;
					bottom = 1260;
					right = 1920;
					break;
				case "21:9":
					top = 0;
					left = -300;
					bottom = 1080;
					right = 2220;
					break;

			}
		}

		public function /*WS*/ setThirdsLinesVisibility(vis:Boolean) : void
		{
			m_isRuleOfThirdsVisible = vis;
			m_thirdsLines.visible = vis;
		}

		public function onTick(e:TimerEvent):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnTick", [TICK_INTERVAL / 1000] ) );
		}

		public function /*WS*/ setCoords(x:Number, y:Number, z:Number)
		{
			var cStr : String = "";

			cStr = "X " + x.toFixed(3) + " | Y " + y.toFixed(3) + " | Z " + z.toFixed(3);

			m_coordsText.text = cStr;
		}

		public /*WS*/ function updateParam(paramId:uint, val:Number)
		{
			var param : Object = {id: paramId, value:val};
			if(m_tabbedMenu)
				m_tabbedMenu.onUpdateParam(param);
		}

		public function /*WS*/ setCurrentCharacter(index:int)
		{
			mc_characterListMenu.setCurrentCharacter(index);
		}

		public function /*WS*/ setCurrentProp(index:int)
		{
			mc_propListMenu.setCurrentProp(index);
		}

		public function swapLockCamera()
		{
			m_cameraLocked = !m_cameraLocked;

			if(m_cameraLocked)
			{
				removeHintArea("freeCamera", false);
				addHintArea("lockedCamera");
			}
			else
			{
				addHintArea("freeCamera", false);
				removeHintArea("lockedCamera");
			}
		}

		public function /*WS*/ setCharacterHighlightVisibility(value:Boolean)
		{
			if (!m_isUIHidden)
				mcCharHighlight.visible = value;
			m_isCharacterHighlightVisible = value;
		}

		public function /*WS*/ setCharacterHighlightPosition(x:Number, y:Number)
		{
			mcCharHighlight.x = x;
			mcCharHighlight.y = y;
		}

		public function /*WS*/ setPhotoAspectRatio(width:int, height:int)
		{
			var screenWidth : Number = (right - left);
			var screenHeight : Number = (bottom - top);

			m_thirdsLines.SetLinesAspectRatio(width, height);

			if(width / height > screenWidth / screenHeight)
			{
				height = screenWidth * height / width;
				width = screenWidth;
			}
			else
			{
				width = screenHeight * width / height;
				height = screenHeight;
			}

			var recalcWidth : Number = width;
			var recalcHeight : Number = height;

			var recalcX : Number = left + (screenWidth - width)/2;
			var recalcY : Number = top + (screenHeight - height)/2;

			m_screenshotArea.width = recalcWidth;
			m_screenshotArea.height = recalcHeight;
			m_screenshotArea.x = recalcX;
			m_screenshotArea.y = recalcY;

			m_tlBlackBar.x = left;
			m_tlBlackBar.y = top;
			m_brBlackBar.x = right;
			m_brBlackBar.y = bottom;

			if(recalcX != left) {
				m_brBlackBar.width = m_tlBlackBar.width = recalcX - left;
				m_brBlackBar.height = m_tlBlackBar.height = screenHeight;
			}
			else if (recalcY != top)
			{
				m_brBlackBar.width = m_tlBlackBar.width = screenWidth;
				m_brBlackBar.height = m_tlBlackBar.height = recalcY - top;
			}
			else
			{
				m_brBlackBar.width = m_brBlackBar.height = 0;
				m_tlBlackBar.width = m_tlBlackBar.height = 0;
			}
		}

		public function /*WS*/ setBlackbarVisible(value:Boolean)
		{
			m_tlBlackBar.visible = value;
			m_brBlackBar.visible = value;
		}

		private function setHintsVisible(value : Boolean)
		{
			var i : int;

			for(i = 0; i < m_leftHints.length; i++)
				m_leftHints[i].visible = m_leftHintsVisible;
			for(i = 0; i < m_bottomHints.length; i++)
				m_bottomHints[i].visible = m_bottomHintsVisible;
		}
	}
}