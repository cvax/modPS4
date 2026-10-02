/***********************************************************************
/** PANEL WorldMap main class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.worldmap
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import red.game.witcher3.LinearEase;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.events.TransformGestureEvent;
	import flash.events.GestureEvent;

	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.core.events.GestureEventEx;
	import red.core.events.TransformGestureEventEx;
	import red.game.witcher3.constants.EInputDeviceType;
	import red.game.witcher3.constants.MapState;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.data.StaticMapPinData;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.events.MapContextEvent;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.LoadingSymbol;
	import red.game.witcher3.menus.worldmap.data.CategoryData;
	import red.game.witcher3.tooltips.TooltipMap;
	import red.game.witcher3.utils.CommonUtils;

	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.TileList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.interfaces.IDataProvider;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.MouseEventEx;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class MapMenu extends CoreMenu
	{
		private const GOTO_WORLD_HINT_HIDDEN_Y:Number = 946;
		private const GOTO_WORLD_HINT_SHOWN_Y:Number = 870;
		
		private const TOOLTIP_POS:Number = 1006;
		private const FAST_TRAVEL_ZOOM:Number = 1;
		
		private const DROPDOWN_POS_LEFT:Number = 138;
		private const DROPDOWN_POS_RIGHT:Number = 1200;
		
		private const LAYER_UNIVERSE = 0;
		private const LAYER_HUB      = 1;
		private const LAYER_INTERIOR = 2;

		private const MAPNAME_SAFE_PADDING:Number = 10;

		private static const ANIM_TIME : Number = 0.22;

		public var tfDebugInfo		: TextField;

		public var mcVisibleArea	: MovieClip;
		public var mcUniverseMap	: UniverseMap;
		public var mcHubMap			: HubMap;
		public var mcInteriorMap	: InteriorMap;

		public var tooltipAnchor	: Sprite;
		public var tooltipInstance  : TooltipMap;
		public var userPinPanel		: UserPinPanel;
		public var userPinPanelBackground : MovieClip;
		public var mcHubMapPinPanel		: HubMapPinPanel;
		public var mcHubMapQuestTracker : MovieClip; //<-- current quest objective tracker
		public var mcHubMapQuestTrackerMain : MovieClip;

		public var mcGotoWorldMap		: MovieClip;
		public var mapName				: MovieClip;
		public var objectivesTitleHint	: CurrentQuestMapHint;
		public var mcWorldMapButton		: MovieClip;
		public var mcQTButtons			: MovieClip;

		private var m_fastTravelPinData	 : Object;
		private var m_trackableMappinTag : uint;
		private var m_currentLayer  	 : int = -1;
		private var m_currentState  	 : String = ""; //"GlobalMap";
		private var m_blockNavigation    : Boolean;
		private var m_loadingState       : Boolean;

		// key bindings
		private var m_action_Zoom		     : int = -1;
		private var m_action_QuestTrack      : int = -1;
		private var m_action_FastTravel      : int = -1;
		private var m_action_OpenRegion		 : int = -1;
		private var m_action_PlaceMappin	 : int = -1;
		private var m_action_MappinPanel     : int = -1;
		private var m_action_Back			 : int = -1;
		
		//private var m_action_MapPreview      : int = -1;
		//private var m_action_OpenWorldMap	 : int = -1;
		//private var m_action_Navigate		 : int = -1;
		
		private var m_action_NavigateFilters : int = -1;
		
		private var m_action_GotoPlayer		 : int = -1;
		private var m_action_GotoQuest		 : int = -1;
		
		// deprecated
		private var m_action_GotoObjectives  : int = -1;
		private var m_action_GotoFastTravel  : int = -1;
		
		private var m_selectedPinData    : StaticMapPinData;
		private var m_userPinPanelShown  : Boolean;
		private var m_invalidateState    : String;
		private var m_gotoWorldHintShown : Boolean;

		private var _pendingMapContext:MapContextEvent;
		
		static public var m_debugInfo : MapDebugInfo;
		static public var m_showDebugBorders : Boolean = false; // true
		
		private var m_isLMBDown : Boolean = false;
		private var m_lastLMBPos : Point = new Point;

		static private var m_currGlobalMousePos : Point = new Point;
		static private var m_currLocalMousePos : Point = new Point;
		static private var m_isUsingGamepad : Boolean = false;
		static private var m_isUsingMouse : Boolean = false;
		
		public var mcPointersCanvas			: MovieClip;
		public var mcMapHitArea:Sprite;
		
		private var _lastVisitedHub : UniverseArea;
		private var cachedAreaName : String;
		
		public function MapMenu()
		{
			super();
			
			userPinPanel.visible = false;
			userPinPanelBackground.visible = false;
			mcHubMapPinPanel.visible = false;
			mcHubMapQuestTracker.visible = false;
			invalidateControlPanels();
			upToCloseEnabled = false;

			_enableInputValidation = true;
			_restrictDirectClosing = true;
			//objectivesTitleHint.visible = false;
			
			tfDebugInfo.visible = false; // true
			m_debugInfo = new MapDebugInfo();
			m_debugInfo.__mapMenu = this;
			
			mcHubMap.showGotoWorldHint = showGotoWorldHint;
			mcHubMap.showGotoPlayerPin = ShowGotoPlayerButton;
			mcHubMap.showGotoQuestPin  = ShowGotoQuestButton;
			mcHubMap.enableUserPinPanel  = enableUserPinPanel;
			mcHubMap.funcClearCategoryPanel = clearCategoryPanel;
			mcHubMap.funcInitializeCategoryPanel = initializeCategoryPanel;
			mcHubMap.funcUpdateCategoryPanel = updateCategoryPanel;
			mcHubMap.funcEnableCategoryPanel = enableCategoryPanel;
			mcHubMap.funcAddPinToCategoryPanel = addPinToCategoryPanel;
			mcHubMap.funcEnableQuestTracker = enableQuestTracker;
			mcHubMapPinPanel.funcCenterOnWorldPosition = centerOnWorldPosition;
			mcHubMapPinPanel.funcShowPinsFromCategory = showPinsFromCategory;
			mcHubMapPinPanel.funcIsAnimationRunning = isAnimationRunning;
			userPinPanel.enableUserPinPanel = enableUserPinPanel;
			userPinPanel.setUserMapPin = setUserMapPin;
		
			mcPointersCanvas.mouseChildren = false;
			mcPointersCanvas.mouseEnabled = false;
			PinPointersManager.getInstance().init(mcPointersCanvas);
		}
		
		override protected function configUI() : void
		{
			super.configUI();

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.name.set', [setMapName] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.current.area.id', [setCurrentArea] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.current.area.name', [setCurrentName] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.quest.name', [setCurrentQuest] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.objectives', [setCurrentObjectives] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.quests.new', [setQuestsNew] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.quest.new.objective', [setNewQuestAndObjectives] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.hubs.custom', [handleCustomHubs] ) ); // NGE
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.quest.tracker.state', [setQuestTrackerState] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'map.show.pin.from.list', [tryShowingAPinFromList] ) );
			
			
			_inputHandlers.push( mcUniverseMap );
			_inputHandlers.push( mcHubMap );
			_inputHandlers.push( mcInteriorMap );

			//stage.doubleClickEnabled = true;
			//stage.mouseChildren = false;
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );

			mcMapHitArea.doubleClickEnabled = true;
			mcMapHitArea.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true );
			mcMapHitArea.addEventListener( MouseEvent.CLICK, onMouseClick, false, 0, true );
			mcMapHitArea.addEventListener( MouseEvent.DOUBLE_CLICK, onMouseDoubleClick, false, 0, true );
			mcMapHitArea.addEventListener( MouseEvent.MOUSE_UP, onMouseUp, false, 0, true );
			mcMapHitArea.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true );
			mcMapHitArea.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true );
			mcMapHitArea.addEventListener( TransformGestureEvent.GESTURE_ZOOM, onGestureZoom, false, 0, true );
			mcMapHitArea.addEventListener( TransformGestureEvent.GESTURE_PAN, onGesturePan, false, 0, true );
			mcMapHitArea.addEventListener( GestureEventEx.GESTURE_TAP, onGestureTap, false, 0, true );
			mcMapHitArea.addEventListener( GestureEventEx.GESTURE_PRESS, onGesturePress, false, 0, true );
			mcMapHitArea.addEventListener( GestureEventEx.GESTURE_DOUBLE_TAP, onGestureDoubleTap, false, 0, true );
			
			userPinPanelBackground.addEventListener( MouseEvent.MOUSE_DOWN, onUserPinBackgroundClickOrTouch, false, 0, true );
			userPinPanelBackground.addEventListener( GestureEventEx.GESTURE_TAP, onUserPinBackgroundClickOrTouch, false, 0, true );
			userPinPanelBackground.addEventListener( GestureEventEx.GESTURE_PRESS, onUserPinBackgroundClickOrTouch, false, 0, true );

			userPinPanelBackground.addEventListener( MouseEvent.MOUSE_MOVE, onUserPinBackgroundMouseMove, false, 0, true );
			userPinPanel.addEventListener( MouseEvent.MOUSE_MOVE, onUserPinBackgroundMouseMove, false, 0, true );

			mcHubMap.addEventListener(MapContextEvent.CONTEXT_CHANGE, handleMapContext, false, 0, true);
			mcHubMap.addEventListener(Event.CHANGE, handleHubMapUpdated, false, 0, true);
			mcUniverseMap.addEventListener(MapContextEvent.CONTEXT_CHANGE, handleMapContext, false, 0, true);

			initializeKeyboardButtons();
			
			if (!Extensions.isScaleform)
			{
				debugData();
			}
			
			// goto World hint
			var tfCloseHint:TextField = mcGotoWorldMap["textField"] as TextField;
			var btnCloseHint:InputFeedbackButton = mcGotoWorldMap["button"] as InputFeedbackButton;
			tfCloseHint.text = "[[panel_map_title_worldmap]]";
			btnCloseHint.label = "";
			btnCloseHint.setDataFromStage(NavigationCode.GAMEPAD_RSTICK_DOWN, -1);
			
			/*
			if (m_action_Navigate < 0)
			{
				m_action_Navigate = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_L3, 1001, "panel_button_common_navigation"); // replace 1001 with MOUSE_PAN
			}
			*/
			if ( m_action_NavigateFilters < 0 )
			{
				m_action_NavigateFilters = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_DPAD_ALL, -1, "panel_map_navigate_filters");
			}

			
			UpdateLayers( LAYER_HUB, true );
			
			updateKeyboardButtons();
			initializeQTButtons();
		}
		
		override protected function handleShowAnimComplete(instTween:GTween) : void
		{
			super.handleShowAnimComplete(instTween);
			
			mcHubMap.SetMenuAnimCompleted();
		}
		
		public static function GetCurrGlobalMousePos() : Point
		{
			return m_currGlobalMousePos;
		}
		
		public static function GetCurrLocalMousePos() : Point
		{
			return m_currLocalMousePos;
		}
		
		public static function IsUsingGamepad() : Boolean
		{
			return m_isUsingGamepad;
		}

		public static function IsUsingMouse() : Boolean
		{
			return m_isUsingMouse;
		}
		
		public function setDefaultMapPostion(defX:Number, defY:Number) : void
		{
			mcHubMap.setDefaultPosition(defX, defY);
		}
		
		public function isGotoWorldHintFullyVisible() : Boolean
		{
			if ( !mcGotoWorldMap.visible )
			{
				return false;
			}
			return mcGotoWorldMap.y <= GOTO_WORLD_HINT_SHOWN_Y;
		}
		
		public function showGotoWorldHint(value:Boolean) : void
		{
			if (value && !m_gotoWorldHintShown)
			{
				mcGotoWorldMap.visible = true;
				GTweener.removeTweens(mcGotoWorldMap);
				GTweener.to(mcGotoWorldMap, .5, { y : GOTO_WORLD_HINT_SHOWN_Y }, { ease:Exponential.easeOut } );
				m_gotoWorldHintShown = true;
			}
			else if (!value && m_gotoWorldHintShown)
			{
				GTweener.removeTweens(mcGotoWorldMap);
				GTweener.to(mcGotoWorldMap, .5, { y : GOTO_WORLD_HINT_HIDDEN_Y }, { ease:Exponential.easeOut, onComplete:handleGotoWorldHintHidden } );
				m_gotoWorldHintShown = false;
			}
		}

		public function setUserMapPin( index : int, fromSelectionPanel : Boolean ) : void
		{
			mcHubMap.setUserMapPin( index, fromSelectionPanel );
		}

		private function updateKeyboardButtons() : void
		{
			var show : Boolean = ( IsLayer( LAYER_HUB ) && !m_isUsingGamepad );

			if ( IsLayer( LAYER_HUB ) )
			{
				mcWorldMapButton.btnWorldMap.label = "[[panel_map_title_worldmap]]";
			}
			else
			{
				if ( _lastVisitedHub )
				{
					mcWorldMapButton.btnWorldMap.label = "[[map_location_" + _lastVisitedHub.GetWorldName() + "]]";
				}
			}
			mcWorldMapButton.btnWorldMap.updateDataFromStage();
			
			var buttonWidth         : Number = mcWorldMapButton.btnWorldMap.getViewWidth();
			var backgroundWidth     : Number = buttonWidth + 2 * 20;
			var backgroundWidthDiff : Number = backgroundWidth - mcWorldMapButton.mcBackground.width;

			mcWorldMapButton.btnWorldMap.x = -buttonWidth;
			mcWorldMapButton.mcBackground.x -= backgroundWidthDiff;
			mcWorldMapButton.mcBackground.width = backgroundWidth;
		}

		private function initializeQTButtons() : void
		{
			mcQTButtons.btnChangeQuest.clickable = true;
			mcQTButtons.btnChangeQuest.setDataFromStage( NavigationCode.GAMEPAD_L2, KeyCode.F );				
			mcQTButtons.btnChangeQuest.visible = true;
			mcQTButtons.btnChangeQuest.addEventListener( ButtonEvent.CLICK, handleChangeQuestClickOrTap, false, 0, true );
			mcQTButtons.btnChangeQuest.addEventListener( GestureEventEx.GESTURE_TAP, handleChangeQuestClickOrTap, false, 0, true );
			mcQTButtons.btnChangeQuest.label = "[[panel_button_map_change_quest]]";
			mcQTButtons.btnChangeQuest.validateNow();
			mcQTButtons.btnChangeQuest.x = - mcQTButtons.btnChangeQuest.getViewWidth();

			mcQTButtons.btnChangeObj.clickable = true;
			mcQTButtons.btnChangeObj.setDataFromStage( getChangeObjectiveGPadNavCode(), KeyCode.G );				
			mcQTButtons.btnChangeObj.visible = true;
			mcQTButtons.btnChangeObj.addEventListener( ButtonEvent.CLICK, handleChangeObjClickOrTap, false, 0, true );
			mcQTButtons.btnChangeObj.addEventListener( GestureEventEx.GESTURE_TAP, handleChangeObjClickOrTap, false, 0, true );
			mcQTButtons.btnChangeObj.label = "[[panel_button_map_change_objective]]";
			mcQTButtons.btnChangeObj.validateNow();
			mcQTButtons.btnChangeObj.x = mcQTButtons.btnChangeQuest.x + mcQTButtons.btnChangeQuest.getViewWidth() - mcQTButtons.btnChangeObj.getViewWidth();

			updateQTButtons();
		}

		private function updateQTButtons() : void //only positioning
		{
			mcQTButtons.btnChangeObj.updateDataFromStage();
			mcQTButtons.btnChangeQuest.updateDataFromStage();

			var BUTTON_GAP : Number = 10;
			var buttonWidth : Number = mcQTButtons.btnChangeQuest.getViewWidth() + mcQTButtons.btnChangeObj.getViewWidth() + BUTTON_GAP;
			var backgroundWidth     : Number = buttonWidth + 2 * 20;
			var backgroundWidthDiff : Number = backgroundWidth - mcQTButtons.mcBackground.width;
			//mcQTButtons.btnChangeObj.validateNow();
			//mcQTButtons.btnChangeQuest.validateNow();

			mcQTButtons.mcBackground.x -= backgroundWidthDiff;
			mcQTButtons.mcBackground.width = backgroundWidth;
			//mcWorldMapButton.btnWorldMap.x = -buttonWidth;
			mcQTButtons.btnChangeObj.x = - mcQTButtons.btnChangeObj.getViewWidth();
			mcQTButtons.btnChangeQuest.x = - mcQTButtons.btnChangeObj.getViewWidth() - BUTTON_GAP - mcQTButtons.btnChangeQuest.getViewWidth();
			//mcQTButtons.btnChangeQuest.x = - mcQTButtons.btnChangeQuest.getViewWidth();
			//mcQTButtons.btnChangeObj.x = mcQTButtons.btnChangeQuest.x + mcQTButtons.btnChangeQuest.getViewWidth() - mcQTButtons.btnChangeObj.getViewWidth() + BUTTON_GAP;;		
		}
		
		private function initializeKeyboardButtons() : void
		{
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

			mcWorldMapButton.btnWorldMap.clickable = true;
			mcWorldMapButton.btnWorldMap.setDataFromStage( isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, KeyCode.SPACE );				
			mcWorldMapButton.btnWorldMap.visible = true;
			mcWorldMapButton.btnWorldMap.addEventListener( ButtonEvent.CLICK, handleWorldMapButtonClickOrTap, false, 0, true );
			mcWorldMapButton.btnWorldMap.addEventListener( GestureEventEx.GESTURE_TAP, handleWorldMapButtonClickOrTap, false, 0, true );
			mcWorldMapButton.btnWorldMap.validateNow();
			mcWorldMapButton.btnWorldMap.x = - mcWorldMapButton.btnWorldMap.getViewWidth();
		}
		
		public function handleWorldMapButtonClickOrTap( event : Event ) : void
		{
			if ( IsLayer( LAYER_HUB ) )
			{
				if ( mcHubMap.CanProcessInput() )
				{
					switchMap();
				}
			}
			else if ( IsLayer( LAYER_UNIVERSE ) )
			{
				if ( mcUniverseMap.CanProcessInput() )
				{
					switchMap( true );
				}
			}
		}

		public function handleChangeObjClickOrTap( event : Event ) : void
		{
			if (IsLayer(LAYER_HUB))
			{
				dispatchEvent( new GameEvent(GameEvent.CALL, "OnCycleObjectivesDefault") );
			}
		}

		public function handleChangeQuestClickOrTap( event : Event ) : void
		{
			var hubState = mcHubMapQuestTracker.GetState();

			if (IsLayer(LAYER_HUB))
			{
				if(hubState == "normal")
					dispatchEvent( new GameEvent(GameEvent.CALL, "OnRequestQuestTrackerState", ["quest"]) );
				else
					dispatchEvent( new GameEvent(GameEvent.CALL, "OnRequestQuestTrackerState", ["normal"]) );
			}
		}

		override protected function handleControllerChanged(event:ControllerChangeEvent) : void		
		{
			super.handleControllerChanged(event);

			m_isUsingGamepad = InputManager.getInstance().isGamepad(); // event.isGamepad
			m_isUsingMouse = InputManager.getInstance().isMouse();
			
			mcUniverseMap.OnControllerChanged( m_isUsingGamepad, m_isUsingMouse );
			mcHubMap.OnControllerChanged( m_isUsingGamepad, m_isUsingMouse );
			
			mcHubMapPinPanel.OnControllerChanged( m_isUsingGamepad, m_isUsingMouse );

			// Update input hints
			if (m_action_PlaceMappin > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_PlaceMappin);
				m_action_PlaceMappin =	InputFeedbackManager.appendButton(this, getWaypointGPadNavCode(), KeyCode.RIGHT_MOUSE, "panel_map_open_waypoint_panel");
			}
			if (m_action_MappinPanel > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_MappinPanel);
				m_action_MappinPanel =	InputFeedbackManager.appendButton(this, getWaypointGPadNavCode(), KeyCode.RIGHT_MOUSE, "panel_map_place_waypoint", true);
			}

			mcQTButtons.btnChangeObj.setDataFromStage( getChangeObjectiveGPadNavCode(), KeyCode.G );
			
			InputFeedbackManager.updateButtons(this);
			
			updateKeyboardButtons();
			updateQTButtons();
		}
		
		private function handleGotoWorldHintHidden(tweenInstance:GTween) : void
		{
			mcGotoWorldMap.visible = false;
		}
		
//---------------------------------------------------------------------------------------------------------------------
//Witcherscript functions
		public function RemoveUserMapPin( id : uint ) : void
		{
			if ( IsLayer( LAYER_HUB ) )
			{
				mcHubMap.RemoveUserMapPin( id );
				removePinFromCategoryPanel( id );
			}
		}
		
		public function SetMapZooms( minZoom : Number, maxZoom : Number, zoom12 : Number, zoom23 : Number, zoom34 : Number ) : void
		{
			mcHubMap.SetMapZooms( minZoom,  maxZoom, zoom12, zoom23, zoom34 );
		}

		public function SetMapVisibilityBoundaries( minX : int, maxX : int, minY : int, maxY : int, gradientScale : Number ) : void
		{
			mcHubMap.SetMapVisibilityBoundaries( minX, maxX, minY, maxY, gradientScale );
		}

		public function SetMapScrollingBoundaries( minX : int, maxX : int, minY : int, maxY : int ) : void
		{
			mcHubMap.SetMapScrollingBoundaries( minX, maxX, minY, maxY );
		}

		public function SetMapSettings( mapSize : Number, tileCount : int, textureSize : int, minLod : int, maxLod : int, imagePath : String, previewAvailable : Boolean, previewMode : int ) : void
		{
			// DEBUG INFO
			//MapMenu.m_debugInfo.__DebugInfo_SetMinMaxLod( minLod, maxLod );
			mcHubMap.SetMapSettings( mapSize, tileCount, textureSize, minLod, maxLod, imagePath, mcVisibleArea, previewAvailable, previewMode );
		}

		public function ReinitializeMap() : void
		{
			mcHubMap.ReinitializeMap();
		}

		public function EnableDebugMode( enable : Boolean ) : void
		{
			if ( tfDebugInfo )
			{
				tfDebugInfo.visible = enable;
			}
		}

		public function EnableUnlimitedZoom( enable : Boolean ) : void
		{
			mcHubMap.EnableUnlimitedZoom( enable );
		}

		public function EnableManualLod( enable : Boolean ) : void
		{
			mcHubMap.EnableManualLod( enable );
		}

		public function ShowBorders( enable : Boolean ) : void
		{
			m_showDebugBorders = enable;
			mcHubMap.UpdateDebugBorders();
		}

		public function ShowToussaint( show : Boolean ) : void
		{
			mcUniverseMap.mcUniverseMapContainer.mcToussaint.visible = show;
			mcUniverseMap.mcUniverseMapContainer.mcToussaint.enabled = show;
			mcUniverseMap.mcUniverseMapContainer.mcToussaint_mask.enabled = show;
		}
		
		public function SetHighlightedMapPin( tag : int ) : void
		{
			mcHubMap.setHighlightedMapPin( tag );
		}
//---------------------------------------------------------------------------------------------------------------------
		
		protected function setCurrentQuest(value:Object) : void
		{
			mcHubMapQuestTracker.setCurrentQuest( value );
		}
		
		protected function setCurrentObjectives( value: Object ) : void
		{
			mcHubMapQuestTracker.setCurrentObjectives( value as Array );
		}

		protected function setQuestsNew( value: Object ) : void
		{
			mcHubMapQuestTracker.setQuestsNew( value as Array );
		}

		protected function setNewQuestAndObjectives(value : Object):void
		{
			mcHubMapQuestTracker.setNewQuestAndObjectives(value);
		}

		protected function setMapName(value:String) : void
		{
			var targetTextField:TextField = mapName["textField"];
			targetTextField.text = value;
			targetTextField.text = CommonUtils.toUpperCaseSafe(targetTextField.text);
			var bgArea:MovieClip = mapName["mcBackgroundArea"];
			var oldWidth : Number = bgArea.width;
			bgArea.width = targetTextField.textWidth + 2 * MAPNAME_SAFE_PADDING;
			mapName.x = mapName.x - (oldWidth - bgArea.width) / 2;
		}

		protected function setCurrentArea(areaId:int) : void
		{
			mcHubMap.setCurrentAreaId( areaId );
		}

		protected function setCurrentName(areaName:String) : void
		{
			_lastVisitedHub = mcUniverseMap.mcUniverseMapContainer.GetHubMapByName( areaName );
			cachedAreaName = areaName;
		}

		override public function setMenuState(value:String) : void
		{
			super.setMenuState(value);

			removeEventListener(Event.ENTER_FRAME, handleStateValidate, false);
			addEventListener(Event.ENTER_FRAME, handleStateValidate, false, 1, true);
			m_invalidateState = value;
		}

		private function handleStateValidate(event:Event) : void
		{
			removeEventListener(Event.ENTER_FRAME, handleStateValidate, false);
			applyState(m_invalidateState);
		}

		private function getWaypointGPadNavCode() : String
		{
			if (InputManager.getInstance().isSwitchPlatform())
			{
				return InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser ? NavigationCode.GAMEPAD_R2 : NavigationCode.GAMEPAD_Y;
			}

			return NavigationCode.GAMEPAD_X;
		}

		private function getChangeObjectiveGPadNavCode() : String
		{
			if (InputManager.getInstance().isSwitchPlatform() && InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser)
			{
				return NavigationCode.GAMEPAD_RSTICK_HOLD;
			}

			return NavigationCode.GAMEPAD_R2;
		}

		private function applyState(stateName:String, changeMapLayer:Boolean = false) : void
		{
			if (stateName != m_currentState)
			{
				// reset
				deactivateContext();
				m_currentState = stateName;
				invalidateControlPanels();

				// common for all states
				m_blockNavigation = false;
				if (changeMapLayer)
				{
					UpdateLayers( LAYER_HUB );
				}
				if (IsLayer(LAYER_HUB))
				{
					//
					//trace("Minimap ##### applyState " + stateName + " " + changeMapLayer );
					//
					if (m_action_Zoom < 0)
					{
						m_action_Zoom =			InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_RSTICK_SCROLL,	KeyCode.MOUSE_SCROLL,	"panel_button_common_zoom");
					}
					if (m_action_PlaceMappin < 0)
					{
						m_action_PlaceMappin =	InputFeedbackManager.appendButton(this, getWaypointGPadNavCode(), KeyCode.RIGHT_MOUSE, "panel_map_open_waypoint_panel");
					}
					if (m_action_MappinPanel < 0)
					{
						m_action_MappinPanel =	InputFeedbackManager.appendButton(this, getWaypointGPadNavCode(), KeyCode.RIGHT_MOUSE, "panel_map_place_waypoint", true);
					}
					/*
					if (m_action_MapPreview < 0)
					{
						if ( mcHubMap.mcHubMapPreview.CanBeToggled() )
						{
							m_action_MapPreview = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_R2,				KeyCode.Z,	"panel_map_toggle_preview" );
						}
					}
					*/
					/*
					if (m_action_OpenWorldMap < 0)
					{
						m_action_OpenWorldMap =	InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_Y,		-1,						"panel_map_title_worldmap");
					}
					*/
					updateGotoPinButton();
					InputFeedbackManager.updateButtons(this);
				}
				if (IsLayer(LAYER_UNIVERSE))
				{
					mcUniverseMap.updateAreaSelection();
				}
			}
		}
		
		private function handleHubMapUpdated(event:Event) : void
		{
			updateGotoPinButton();
			InputFeedbackManager.updateButtons(this);
		}

		public function enableUserPinPanel(value:Boolean, stagePositionForUserPin : Point = null) : void
		{
			if ( !value && IsLayer(LAYER_HUB ) )
			{
				mcHubMap.OnUserPinPanelClose();
			}

			if ( m_userPinPanelShown != value )
			{
				if ( value )
				{
					if ( !mcVisibleArea.hitTestPoint( stagePositionForUserPin.x, stagePositionForUserPin.y ) )
					{
						return;
					}
					
					userPinPanel.btnClose.x = -userPinPanel.btnClose.getViewWidth() / 2;
				}
				
				m_userPinPanelShown = value;
				
				//m_blockNavigation = m_userPinPanelShown;
				userPinPanel.visible = m_userPinPanelShown;
				userPinPanel.enabled = m_userPinPanelShown;
				userPinPanel.focused = m_userPinPanelShown ? 1 : 0;
				userPinPanelBackground.visible = m_userPinPanelShown;
				
				if ( value )
				{
					var centerPosX, centerPosY : int;
					var finalPosX, finalPosY : int;

					centerPosX = stagePositionForUserPin.x;
					centerPosY = stagePositionForUserPin.y;
					
					// restrict to mcVisibleArea
					if ( centerPosX - userPinPanel.width / 2 < mcVisibleArea.x - mcVisibleArea.width / 2 )
					{
						centerPosX = mcVisibleArea.x - mcVisibleArea.width / 2 + userPinPanel.width / 2;
					}
					else if ( centerPosX + userPinPanel.width / 2 > mcVisibleArea.x + mcVisibleArea.width / 2 )
					{
						centerPosX = mcVisibleArea.x + mcVisibleArea.width / 2 - userPinPanel.width / 2;
					}

					if ( m_isUsingMouse )
					{
						finalPosX = centerPosX;
						finalPosY = centerPosY;
					}
					else
					{
						// move a bit up
						finalPosX = centerPosX;
						finalPosY = centerPosY - 30;
					}
					
					userPinPanel.x = finalPosX;
					userPinPanel.y = finalPosY;

				}
			}
		}
		
		private function invalidateControlPanels() : void
		{
			m_blockNavigation = false;

			if (m_action_Zoom > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_Zoom);
				m_action_Zoom = -1;
			}
			if (m_action_PlaceMappin > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_PlaceMappin);
				m_action_PlaceMappin = -1;
			}
			if (m_action_MappinPanel > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_MappinPanel);
				m_action_MappinPanel = -1;
			}
			/*
			if (m_action_MapPreview  > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_MapPreview );
				m_action_MapPreview  = -1;
			}
			*/

			InputFeedbackManager.updateButtons(this);
			deactivateContext();
		}

		private function handleMapContext(event:MapContextEvent) : void
		{			
			_pendingMapContext = event;
			removeEventListener(Event.ENTER_FRAME, pendingMapContextUpdate, false);
			addEventListener(Event.ENTER_FRAME, pendingMapContextUpdate, false, 0, true);
		}
		
		private function pendingMapContextUpdate(event:Event) : void
		{
			removeEventListener(Event.ENTER_FRAME, pendingMapContextUpdate, false);
			
			if (_pendingMapContext)
			{
				if (!_pendingMapContext.active)
				{
					deactivateContext();
				}
				else
				{
					activateContext(_pendingMapContext);
				}
			}
		}
		
		private function deactivateContext() : void
		{
			tooltipInstance.HideTooltip();
			m_trackableMappinTag = 0;
			m_selectedPinData = null;
			cleanUpContextButtons();
			updateGotoPinButton();
			InputFeedbackManager.updateButtons(this);
		}
		
		private function cleanUpContextButtons() : void
		{
			if (m_action_QuestTrack > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_QuestTrack);
				m_action_QuestTrack = -1;
			}
			if (m_action_FastTravel > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_FastTravel);
				m_action_FastTravel = -1;
			}
			if (m_action_OpenRegion > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_OpenRegion);
				m_action_OpenRegion = -1;
			}
		}

		private function activateContext(event:MapContextEvent) : void
		{
			try
			{
				tooltipInstance.ShowTooltip(event.tooltipData, isArabicAligmentMode);
				tooltipInstance.y = TOOLTIP_POS - tooltipInstance.actualHeight;
				m_selectedPinData = event.mapppinData;
				
				cleanUpContextButtons();
				
				if (event.tooltipData && event.tooltipData.openRegion)
				{
					if (m_action_OpenRegion < 0)
					{
						m_action_OpenRegion = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.E, "panel_button_map_open");
					}
				}
				else
				if (event.mapppinData.isFastTravel && mcHubMapQuestTracker.GetState() == "normal" )
				{
					if (m_action_FastTravel < 0)
					{
						m_action_FastTravel = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.E, "panel_button_map_fasttravel");
					}
				}
				else
				{
					m_trackableMappinTag = 0;
					if (m_action_QuestTrack > 0)
					{
						InputFeedbackManager.removeButton(this, m_action_QuestTrack);
						m_action_QuestTrack = -1;
					}
				}
				updateGotoPinButton();
				
				InputFeedbackManager.updateButtons(this);
			}
			catch (er:Error)
			{
				updateGotoPinButton();
				InputFeedbackManager.updateButtons(this);
			}
		}
		
		private function updateGotoPinButton() : void
		{
			var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;

			if ( IsLayer( LAYER_HUB ) && MapMenu.IsUsingMouse() && !isSwitch2Mouser)
			{
				// that depends on mouse cursor position
				return;
			}
			
			ShowGotoPlayerButton(false);
			ShowGotoQuestButton(false);
			
			if ( !IsLayer( LAYER_HUB ) )
			{
				return;	
			}

			mcHubMap.UpdateGotoButton( true );
		}
		
		private function ShowGotoPlayerButton(show:Boolean) : void
		{
			if (show && m_action_GotoPlayer < 0)
			{
				m_action_GotoPlayer = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_LSTICK_HOLD, KeyCode.TAB, "panel_map_goto_player_pin");
			}
			else
			if (!show && m_action_GotoPlayer > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_GotoPlayer);
				m_action_GotoPlayer = -1;
			}
		}
		
		private function ShowGotoQuestButton(show:Boolean) : void
		{
			if (show && m_action_GotoQuest < 0)
			{
				m_action_GotoQuest = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_LSTICK_HOLD, KeyCode.TAB, "panel_map_goto_quest_pin");
			}
			else
			if (!show && m_action_GotoQuest > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_GotoQuest);
				m_action_GotoQuest = -1;
			}
		}
		
		private function IsLayer( layer : int ) : Boolean
		{
			return m_currentLayer == layer;
		}

		private function GetCurrentMapLayer() : BaseMap
		{
			switch (m_currentLayer)
			{
				case LAYER_UNIVERSE: return mcUniverseMap;
				case LAYER_HUB: return mcHubMap;
				case LAYER_INTERIOR: return mcInteriorMap;
			}
			
			return null;
		}

		private function UpdateLayers( layer : int, force : Boolean = false ) : void
		{
			if ( layer < LAYER_UNIVERSE || layer > LAYER_INTERIOR )
			{
				throw(new Error( "Minimap Wrong layer FFS! (" + layer + ")" ));
				return;
			}
			if ( m_currentLayer == layer )
			{
				return;
			}
			deactivateContext();
			m_currentLayer = layer;

			mcUniverseMap.Enable( m_currentLayer == LAYER_UNIVERSE, force );
			mcHubMap.Enable(      m_currentLayer == LAYER_HUB,      force );
			mcInteriorMap.Enable( m_currentLayer == LAYER_INTERIOR, force );
			mcQTButtons.visible = IsLayer(LAYER_HUB);
			
			PinPointersManager.getInstance().disabled = m_currentLayer != LAYER_HUB;
		}

		override public function handleInput( event:InputEvent ) : void
		{
			if ( m_userPinPanelShown )
			{
				userPinPanel.handleInput( event );
				event.handled = true;
				event.stopImmediatePropagation();
				return;
			}
			
			if ( event.handled)
			{
				return;
			}
			
			var details:InputDetails = event.details;
			CommonUtils.fixupKeyCode( details );

			// ---------------------- States
			if ( event.handled || m_blockNavigation )
			{
				return;
			}

			// -------------------- Navigation
			if ( mcHubMapPinPanel.visible )
			{
				mcHubMapPinPanel.handleInput( event );
			}

			if ( mcHubMapQuestTracker.visible )
			{
				mcHubMapQuestTracker.handleInput( event );
			}

			var keyDown : Boolean  = (details.value == InputValue.KEY_DOWN );
			var keyUp : Boolean    = (details.value == InputValue.KEY_UP );
            var keyPress : Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
			var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;

			var hubState = mcHubMapQuestTracker.GetState();

			switch ( details.code )
			{
				case KeyCode.SPACE:
					if ( keyDown )
					{
						if ( IsLayer( LAYER_UNIVERSE ) )
						{
							if ( mcUniverseMap.CanProcessInput() )
							{
								switchMap( true );
							}
						}
						else if ( IsLayer( LAYER_HUB ) )
						{
							if ( mcHubMap.CanProcessInput() )
							{
								switchMap();
								dispatchEvent( new GameEvent(GameEvent.CALL, "OnRequestQuestTrackerState", ["normal"]) );
							}
						}
					}
					break;
				case KeyCode.E:	
				case KeyCode.ENTER:
				case KeyCode.PAD_A_CROSS:
					if ( IsLayer( LAYER_UNIVERSE ) && keyDown)
					{
						if ( mcUniverseMap.CanProcessInput() )
						{
							switchMap();
						}
					}
					else if ( IsLayer( LAYER_HUB ))
					{
						if(hubState == "normal" && keyDown)
						{
							if ( mcHubMap.CanProcessInput() && m_trackableMappinTag)
							{
								dispatchEvent(new GameEvent(GameEvent.CALL, "OnTrackQuest", [m_trackableMappinTag]));
							}
						}
						else if (hubState == "quest" && keyUp)
						{
							mcHubMapQuestTracker.setTrackCurrentQuest();
						}
						else if (hubState == "objective" && keyUp)
						{
							mcHubMapQuestTracker.setTrackCurrentObjective();
						}
					}
					break;

				case KeyCode.ESCAPE:	
				case KeyCode.PAD_B_CIRCLE:
					if((hubState == "normal" || IsLayer( LAYER_UNIVERSE )) && keyUp)
					{
						hideAnimation();
					}
					else if (keyUp)
					{
						dispatchEvent( new GameEvent(GameEvent.CALL, "OnRequestQuestTrackerState", ["normal"]) );
					}
					break;
				case KeyCode.H:
					if(hubState != "normal")
					{
						mcHubMapQuestTracker.OpenQuestInJournal();
					}
					break;
				case KeyCode.PAD_Y_TRIANGLE:
				case KeyCode.PAD_X_SQUARE:
					if (keyDown &&
						((isSwitchPlatform && details.code == KeyCode.PAD_X_SQUARE) ||		// X on switch
						(!isSwitchPlatform && details.code == KeyCode.PAD_Y_TRIANGLE)))		// Y on other platforms
					{
						if ( IsLayer( LAYER_UNIVERSE ) )
						{
							if ( mcUniverseMap.CanProcessInput() )
							{
								switchMap( true );
							}
						}
						else if ( IsLayer( LAYER_HUB ) )
						{
							if ( mcHubMap.CanProcessInput() )
							{
								dispatchEvent( new GameEvent(GameEvent.CALL, "OnRequestQuestTrackerState", ["normal"]) );
								switchMap();
							}
						}
					}
					else if (keyDown &&
						((isSwitchPlatform && details.code == KeyCode.PAD_Y_TRIANGLE) ||		// Y on switch
						(!isSwitchPlatform && details.code == KeyCode.PAD_X_SQUARE)))		// X on other platforms
					{
						if(hubState != "normal")
						{
							mcHubMapQuestTracker.OpenQuestInJournal();
						}
					}
					break;

				case KeyCode.PAD_RIGHT_STICK_UP:

					// go from universe to specific hub
					if ( IsLayer( LAYER_UNIVERSE ) && keyDown)
					{
						if ( mcUniverseMap.CanProcessInput() )
						{
							switchMap();
						}
					}
					break;

				case KeyCode.G:
				case KeyCode.PAD_RIGHT_TRIGGER:
				case KeyCode.PAD_RIGHT_STICK_DOWN:
					if (IsLayer(LAYER_HUB) && keyDown && hubState == "normal" &&
						((details.code == KeyCode.G) ||
						(isSwitch2Mouser && details.code == KeyCode.PAD_RIGHT_STICK_DOWN) ||	// R3 on switch mouser
						(!isSwitch2Mouser && details.code == KeyCode.PAD_RIGHT_TRIGGER)))		// R2 elsewhere
					{
						dispatchEvent( new GameEvent(GameEvent.CALL, "OnCycleObjectivesDefault") );
					}
					break;
				case KeyCode.F:
				case KeyCode.PAD_LEFT_TRIGGER:
					if (IsLayer(LAYER_HUB) && keyDown)
					{
						if(hubState == "normal")
							dispatchEvent( new GameEvent(GameEvent.CALL, "OnRequestQuestTrackerState", ["quest"]) );
						else
							dispatchEvent( new GameEvent(GameEvent.CALL, "OnRequestQuestTrackerState", ["normal"]) );
					}
					break;
				//case KeyCode.W:
			}

			for each ( var handler:UIComponent in _inputHandlers )
			{
				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
				if (handler.enabled)
				{
					handler.handleInput( event );
				}
			}
		}
		
		override public function handleDebugInput( event : InputEvent ) : void
		{
			if ( event.handled )
			{
				return;
			}
			
			if ( !mcHubMap.CanProcessInput() )
			{
				return;
			}
			
            var details : InputDetails = event.details;
			
			switch( details.code )
			{
				//case KeyCode.PAD_DIGIT_UP:
				case KeyCode.NUMPAD_4:
					if ( details.value == InputValue.KEY_UP && IsLayer( LAYER_HUB ) )
					{
						if ( m_selectedPinData )
						{
							dispatchEvent( new GameEvent( GameEvent.CALL, 'OnDebugTeleportToHighlightedMappin', [ m_selectedPinData.posX , m_selectedPinData.posY ] ) );
							event.handled = true;
						}
					}
					break;
					
				default:
					return;
			}
		}

		override protected function handleInputNavigate(event:InputEvent) : void
		{
			if (m_loadingState)
			{
				event.handled = true;
				event.stopImmediatePropagation();
				return;
			}
			super.handleInputNavigate(event);
		}

		protected function switchMap( goToLastHub : Boolean = false, useExternalPoint:Boolean = false, point:Point = null ) : void
		{
			if ( IsLayer( LAYER_HUB ) )
			{
				showGotoWorldHint(false);
				UpdateLayers( LAYER_UNIVERSE );
				mcUniverseMap.centerCurrentArea(false);
				
				trace( 'Minimap @@@@@ switchMap' );
				forceMouseMove();
				mcUniverseMap.updateAreaSelection( true );
				
				dispatchEvent( new GameEvent(GameEvent.CALL, 'OnSwitchToWorldMap'));
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnPlaySoundEvent', ["gui_global_panel_close"] ));
	
				if (m_action_Zoom > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_Zoom);
					m_action_Zoom = -1;
				}
				if (m_action_NavigateFilters > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_NavigateFilters);
					m_action_NavigateFilters = -1;
				}
				if (m_action_PlaceMappin > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_PlaceMappin);
					m_action_PlaceMappin = -1;
				}
				if (m_action_MappinPanel > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_MappinPanel);
					m_action_MappinPanel = -1;
				}
				if (m_action_Back > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_Back);
					m_action_Back = -1;
				}
			}
			else
			{
				var canGoToHubMap : Boolean = ( goToLastHub ) ? mcUniverseMap.GoToHubMap( _lastVisitedHub ) : mcUniverseMap.GoToSelectedHubMap( useExternalPoint, point );
				if ( canGoToHubMap )
				{					
					UpdateLayers( LAYER_HUB );

					DoHubMapButtonSetup();
				
					InputFeedbackManager.updateButtons(this);
				}
			}
			InputFeedbackManager.updateButtons(this);
			updateGotoPinButton();
			updateKeyboardButtons();
		}

		private function DoHubMapButtonSetup():void
		{
			if (m_action_Zoom > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_Zoom);
					m_action_Zoom = -1;
				}
				if (m_action_NavigateFilters > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_NavigateFilters);
					m_action_NavigateFilters = -1;
				}
				if (m_action_PlaceMappin > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_PlaceMappin);
					m_action_PlaceMappin = -1;
				}
				if (m_action_MappinPanel > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_MappinPanel);
					m_action_MappinPanel = -1;
				}
				if (m_action_Back > 0)
				{
					InputFeedbackManager.removeButton(this, m_action_Back);
					m_action_Back = -1;
				}
				InputFeedbackManager.updateButtons(this);

				var hubState = mcHubMapQuestTracker.GetState();

				if (m_action_Zoom < 0 && IsLayer(LAYER_HUB))
				{
					m_action_Zoom =	InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_RSTICK_SCROLL,	1002,					"panel_button_common_zoom"); // replace 1002 with MOUSE_SCROLL
				}
				if ( m_action_NavigateFilters < 0 && hubState == "normal" && IsLayer(LAYER_HUB))
				{
					m_action_NavigateFilters = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_DPAD_ALL, -1, "panel_map_navigate_filters");
				}
				if (m_action_PlaceMappin < 0 && hubState == "normal" && IsLayer(LAYER_HUB))
				{
					m_action_PlaceMappin =	InputFeedbackManager.appendButton(this, getWaypointGPadNavCode(), KeyCode.RIGHT_MOUSE, "panel_map_open_waypoint_panel");
				}
				if (m_action_MappinPanel < 0 && hubState == "normal" && IsLayer(LAYER_HUB))
				{
					m_action_MappinPanel =	InputFeedbackManager.appendButton(this, getWaypointGPadNavCode(), KeyCode.RIGHT_MOUSE, "panel_map_place_waypoint", true);
				}
				if (m_action_Back < 0 && hubState != "normal")
				{
					m_action_Back =	InputFeedbackManager.appendButton(this, "", KeyCode.ESCAPE, "panel_mainmenu_back");
				}
				
				InputFeedbackManager.updateButtons(this);
		}

		private function panMap( x : Number, y : Number ) : void
		{
			if ( IsLayer( LAYER_UNIVERSE ) )
			{
				if ( mcUniverseMap.CanProcessInput() )
				{
					mcUniverseMap.ScrollMap( x, y );
				}
			}
			else if ( IsLayer( LAYER_HUB ) )
			{
				if ( mcHubMap.CanProcessInput() )
				{
					mcHubMap.scrollMap( x, y );
				}
			}
		}
		
		private function onMouseClick( event : MouseEvent ) : void
		{
			if ( m_blockNavigation )
			{
				return;
			}
			
			var eventEx:MouseEventEx = event as MouseEventEx;
			if (eventEx && eventEx.buttonIdx == MouseEventEx.LEFT_BUTTON )
			{
				if ( IsLayer( LAYER_UNIVERSE ) )
				{
					if ( mcUniverseMap.CanProcessInput() )
					{
						switchMap();
					}
				}
			}
		}

		private function onMouseDoubleClick( event : MouseEvent ) : void
		{
			if ( m_blockNavigation )
			{
				return;
			}
			
			var eventEx:MouseEventEx = event as MouseEventEx;
			if (eventEx && eventEx.buttonIdx == MouseEventEx.LEFT_BUTTON )
			{
				if ( IsLayer( LAYER_HUB ) )
				{
					if ( mcHubMap.CanProcessInput() )
					{
						mcHubMap.OnMouseDoubleDown( eventEx.buttonIdx, new Point( event.stageX, event.stageY ) );
					}
				}
			}
		}

		private function onMouseDown( event : MouseEvent ) : void
		{
			mcWorldMapButton.btnWorldMap.mouseEnabled  = false;
			mcWorldMapButton.btnWorldMap.mouseChildren = false;

			updateMouseCoords( event.stageX, event.stageY, event.localX, event.localY );

			if ( m_blockNavigation )
			{
				return;
			}

			var eventEx:MouseEventEx = event as MouseEventEx;
			if (eventEx )
			{
				if ( eventEx.buttonIdx == MouseEventEx.LEFT_BUTTON )
				{
					m_isLMBDown = true;
					m_lastLMBPos.x = event.stageX;
					m_lastLMBPos.y = event.stageY;
					
					mcHubMapQuestTracker.enableMouse( false );
					mcHubMapPinPanel.enableMouse( false );
					mcWorldMapButton.mouseEnabled = false;
					mcWorldMapButton.mouseChildren = false;
				}
				else if ( eventEx.buttonIdx == MouseEventEx.MIDDLE_BUTTON )
				{
					if ( IsLayer( LAYER_HUB ) )
					{
						if ( mcHubMap.CanProcessInput() )
						{
							switchMap();
							return;
						}
					}
					else if ( IsLayer( LAYER_UNIVERSE ) )
					{
						if ( mcUniverseMap.CanProcessInput() )
						{
							switchMap( true );
							return;
						}
					}
				}
			}

			if ( IsLayer( LAYER_HUB ) )
			{
				mcHubMap.OnMouseDown( eventEx.buttonIdx, m_currGlobalMousePos );
			}
		}

		private function onMouseUp( event : MouseEvent ) : void
		{
			mcWorldMapButton.btnWorldMap.mouseEnabled  = true;
			mcWorldMapButton.btnWorldMap.mouseChildren = true;

			updateMouseCoords( event.stageX, event.stageY, event.localX, event.localY );

			if ( m_blockNavigation )
			{
				return;
			}

			var eventEx:MouseEventEx = event as MouseEventEx;
			if (eventEx && eventEx.buttonIdx == MouseEventEx.LEFT_BUTTON )
			{
				m_isLMBDown = false;

				mcHubMapQuestTracker.enableMouse( true );
				mcHubMapPinPanel.enableMouse( true );
				mcWorldMapButton.mouseEnabled = true;
				mcWorldMapButton.mouseChildren = true;
			}
			
			if ( IsLayer( LAYER_HUB ) )
			{
				mcHubMap.OnMouseUp( eventEx.buttonIdx, m_currGlobalMousePos );
			}
		}

		private function onMouseMove( event : MouseEvent ) : void
		{
			updateMouseCoords( event.stageX, event.stageY, event.localX, event.localY );
			
			if ( IsLayer( LAYER_UNIVERSE ) )
			{
				mcUniverseMap.OnMouseMove( m_currGlobalMousePos );
			}
			else if ( IsLayer( LAYER_HUB ) )
			{
				mcHubMap.OnMouseMove( m_currGlobalMousePos );
				if ( mcHubMapPinPanel.visible )
				{
					mcHubMapPinPanel.OnMouseMoveFromParent( m_currGlobalMousePos );
					mcHubMapQuestTracker.OnMouseMoveFromParent( m_currGlobalMousePos );
				}
			}

			if ( m_blockNavigation )
			{
				return;
			}

			//Pan map by mouse drag	
			if ( m_isLMBDown )
			{
				var deltaX = event.stageX - m_lastLMBPos.x;
				var deltaY = event.stageY - m_lastLMBPos.y;
				m_lastLMBPos.x = event.stageX;
				m_lastLMBPos.y = event.stageY;

				panMap( deltaX, deltaY );
			}
		}
		
		private function onMouseWheel( event : MouseEvent ) : void
		{
			if ( m_blockNavigation )
			{
				return;
			}
			
			var currentMapLayer : BaseMap = GetCurrentMapLayer();
			if ( currentMapLayer )
			{
				var zoomIn : Boolean = ( event.delta > 0 );
				currentMapLayer.Zoom( zoomIn );
			}
		}

		private function onGestureZoom( event : TransformGestureEvent ) : void 	
		{
			var currentMapLayer : BaseMap = GetCurrentMapLayer();
			if ( currentMapLayer )
			{
				currentMapLayer.ZoomByFactor( event.scaleX );
			}
		}

		private function onGesturePan( event : TransformGestureEvent ) : void 	
		{
			var handled : Boolean = false;

			if ( IsLayer( LAYER_HUB ) )
			{
				handled = mcHubMap.onGesturePan( event );
			}

			if ( !handled )
			{
				panMap( event.offsetX, event.offsetY );
			}
		}

		private function onGestureTap( event : GestureEvent ) : void
		{
			if ( m_blockNavigation )
			{
				return;
			}

			if ( !mcVisibleArea.hitTestPoint( event.stageX, event.stageY ) )
			{
				return;
			}

			if ( IsLayer( LAYER_UNIVERSE ) )
			{
				if ( mcUniverseMap.CanProcessInput() )
				{
					var cursorPos : Point = new Point();
					cursorPos.x = event.stageX;
					cursorPos.y = event.stageY;

					var sameArea : Boolean = mcUniverseMap.updateAreaSelection(false, true, cursorPos);
					if ( sameArea )
					{
						switchMap( false, true, cursorPos );
					}
					else
					{
						mcUniverseMap.centerCurrentArea();
					}
				}
			}
			else if ( IsLayer( LAYER_HUB ) && !m_userPinPanelShown )
			{
				if ( mcHubMap.CanProcessInput() )
				{
					mcHubMap.onGestureTap(event);
				}
			}
		}

		private function onGesturePress( event : GestureEvent ) : void
		{
			if ( IsLayer( LAYER_HUB ) && mcHubMap.CanProcessInput() && event.phase == "begin" )
			{
				mcHubMap.onGesturePress( event );
			}
		}
		
		private function onGestureDoubleTap( event : GestureEvent ) : void
		{
			if ( IsLayer( LAYER_HUB ) && mcHubMap.CanProcessInput() )
			{
				mcHubMap.onDoubleTapGesture( event );
			}
		}

		private function onUserPinBackgroundClickOrTouch( event : Event ) : void
		{
			enableUserPinPanel( false );
		}

		private function onUserPinBackgroundMouseMove( event : MouseEvent ) : void
		{
			updateMouseCoords( event.stageX, event.stageY, event.localX, event.localY );
		}
		
		private function updateMouseCoords( stageX : Number, stageY : Number, localX : Number, localY : Number ) : void
		{
			m_currGlobalMousePos.x = stageX;
			m_currGlobalMousePos.y = stageY;
			m_currLocalMousePos.x  = localX;
			m_currLocalMousePos.y  = localY;
		}

		private function forceMouseMove() : void
		{
			if ( m_isUsingMouse )
			{
				mcUniverseMap.OnMouseMove( m_currGlobalMousePos );
			}
		}

		override protected function get menuName() : String
		{
			return "MapMenu";
		}

		override protected function closeMenu():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMenu' ) );
		}

		public function clearCategoryPanel() : void
		{
			mcHubMapPinPanel.clearCategoryPanel();
		}
		
		public function initializeCategoryPanel() : void
		{
			mcHubMapPinPanel.initializeCategoryPanel();			
			// NGE - new "Default" category
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSetInitialFilters' ) );
		}
		
		public function updateCategoryPanel() : void
		{
			mcHubMapPinPanel.updateCategoryPanel();
		}
		
		public function enableCategoryPanel( value : Boolean ) : void
		{
			mcHubMapPinPanel.x = value?146:-300;
			mcHubMapPinPanel.alpha = value?1:0;
			mcHubMapPinPanel.visible = value;
		}

		public function enableQuestTracker( value : Boolean ) : void
		{
			if ( value )
			{
				if ( !mcHubMapQuestTracker.canBeShown() )
				{
					return;
				}
			}
			mcHubMapQuestTracker.visible = value;
		}
		
		public function addPinToCategoryPanel( pinData : StaticMapPinData ) : void
		{
			mcHubMapPinPanel.addPinInstance( pinData );
		}

		public function removePinFromCategoryPanel( id : uint ) : void
		{
			mcHubMapPinPanel.removePinInstance( id );
			
			updateCategoryPanel();
		}

		public function centerOnWorldPosition( worldPos : Point, animate : Boolean = false ) : void
		{
			mcHubMap.centerOnWorldPosition( worldPos, animate );
		}
		
		public function showPinsFromCategory( pins : Array, showUserPins : Boolean, showFastTravelPins : Boolean, showQuestPins : Boolean, disabledPins : Dictionary, onStart : Boolean ) : void
		{
			mcHubMap.showPinsFromCategory( pins, showUserPins, showFastTravelPins, showQuestPins, disabledPins, onStart );
		}

		public function isAnimationRunning() : Boolean
		{
			return mcHubMap.isAnimationRunning();
		}
		
		protected function debugData()  :void
		{
			//
		}

		public function __UpdateDebugInfo() : void
		{
			if ( tfDebugInfo )
			{
				var info : String;
				info =	"Current LOD: " + 		m_debugInfo._currentLod + " (" + m_debugInfo._minLod + ", " + m_debugInfo._maxLod + ")" +
						"<BR>Zoom: " +			m_debugInfo._zoom.toFixed( 2 ) +
						"<BR>Visible tiles: " + m_debugInfo._visibleTiles +
						"<BR>Scroll posX: " +	m_debugInfo._scrollX.toFixed( 2 ) +
						"<BR>Scroll posY: " +	m_debugInfo._scrollY.toFixed( 2 ) +
						"<BR>Center: " +		m_debugInfo._pointedTileX +    " " + m_debugInfo._pointedTileY +
						"<BR>Min tile: " +		m_debugInfo._pointedMinTileX + " " + m_debugInfo._pointedMinTileY +
						"<BR>Max tile: " +		m_debugInfo._pointedMaxTileX + " " + m_debugInfo._pointedMaxTileY +
						"<BR>";
				var zoomBoundaries : Vector.< ZoomBoundary > = mcHubMap.GetZoomBoundaries();
				if ( zoomBoundaries )
				{
					for ( var i = 0; i < zoomBoundaries.length; ++i )
					{
						if ( zoomBoundaries[ i ].IsValid() )
						{
							info +=	"<BR>LOD" + ( i + 1 ) + " - (" + zoomBoundaries[ i ]._min.toFixed( 2 ) + ", " + zoomBoundaries[ i ]._max.toFixed( 2 ) + ")";
						}
					}
				}
				info +=	"<BR>";
				
				for ( var lod = m_debugInfo._minLod; lod <= m_debugInfo._maxLod; ++lod )
				{
					if ( lod == 1 )
					{
						info +=	lod + ": " + m_debugInfo._lod1Visible + " " + m_debugInfo._lod1Invisible + "<BR>";
					}
					if ( lod == 2 )
					{
						info +=	lod + ": " + m_debugInfo._lod2Visible + " " + m_debugInfo._lod2Invisible + "<BR>";
					}
					if ( lod == 3 )
					{
						info +=	lod + ": " + m_debugInfo._lod3Visible + " " + m_debugInfo._lod3Invisible + "<BR>";
					}
					if ( lod == 4 )
					{
						info +=	lod + ": " + m_debugInfo._lod4Visible + " " + m_debugInfo._lod4Invisible + "<BR>";
					}
				}

				tfDebugInfo.htmlText =  info;
			}
		}

		// NGE
		protected function handleCustomHubs(value : Object) : void
		{
			this.mcUniverseMap.mcUniverseMapContainer.addCustomHubs(value as Array);
		}
		// NGE

		public function SetHubMapPinPanelVisibleWithAnim(vis:Boolean):void
		{
			GTweener.removeTweens(mcHubMapPinPanel);

			if(vis)
			{
				mcHubMapPinPanel.visible = true;
				GTweener.to(mcHubMapPinPanel, ANIM_TIME, {alpha:1, x:146}, {ease:LinearEase.easeOut});
			}
			else
			{
				GTweener.to(mcHubMapPinPanel, ANIM_TIME, {alpha:0, x:-300}, {ease:LinearEase.easeIn, onComplete:OnetHubMapPinPanelVisibleComplete});
			}
		}

		public function OnetHubMapPinPanelVisibleComplete():void
		{
			if(mcHubMapPinPanel.alpha == 0)
				mcHubMapPinPanel.visible = false;
		}

		public function setQuestTrackerState(state : String) : void
		{
			mcHubMapQuestTracker.SetState(state);
			mcHubMapPinPanel._inputEnabled = state == "normal";
			mcHubMap.m_questTrackerInNormalState = state == "normal";
			//mcHubMapPinPanel.visible = state == "normal" && IsLayer(LAYER_HUB);
			SetHubMapPinPanelVisibleWithAnim(state == "normal" && IsLayer(LAYER_HUB));

			if (m_action_FastTravel > 0)
			{
				InputFeedbackManager.removeButton(this, m_action_FastTravel);
				m_action_FastTravel = -1;
			}

			if(state != "normal")
			{
				ShowGotoPlayerButton(false);
				ShowGotoQuestButton(false);
			}
			else
			{
				mcHubMap.UpdateGotoButton(true);
				mcHubMap.disableAltHighlights();
			}
			DoHubMapButtonSetup();

		}

		public function tryShowingAPinFromList(data:Object)
		{
			mcHubMap.disableAltHighlights();

			var array : Array = data.array;

			var pinArray : Vector.<Object> = new Vector.<Object>();
			for(var i : int = 0; i < array.length; i++)
			{
				var tag : uint = array[i];

				var pin : Object = mcHubMap.getPinPositionByTag(tag);
				mcHubMap.setAltHighlightsByTag(tag);

				if(pin.success)
				{
					pinArray.push(pin);
				}
			}

			pinArray.sort(function(a:Object, b : Object)
			{
				var axDelta : Number = a.x - mcHubMap.m_playerWorldPosX;
				var ayDelta : Number = a.y - mcHubMap.m_playerWorldPosX;
				var aDist : Number = axDelta * axDelta + ayDelta * ayDelta;

				var bxDelta : Number = b.x - mcHubMap.m_playerWorldPosX;
				var byDelta : Number = b.y - mcHubMap.m_playerWorldPosX;
				var bDist : Number = bxDelta * bxDelta + byDelta * byDelta;

				return aDist - bDist;
			})

			if(pinArray.length > 0)
			{
				centerOnWorldPosition(new Point(pinArray[0].x, pinArray[0].y), true);
				mcHubMap.showOnlyTooltipByPosition(pinArray[0].x, pinArray[0].y);
			}
			else if(data.hasOwnProperty("fallbackData"))
			{
				mcHubMap.showOnlyTooltipByData(data.fallbackData)
			}
			else
			{
				mcHubMap.hideOnlyTooltip();
			}
		}
	}
}

import red.game.witcher3.menus.worldmap.MapMenu;
class MapDebugInfo
{
	public var __mapMenu	   : MapMenu;

	public var _currentLod		: int = -1;
	public var _minLod			: int = -1;
	public var _maxLod			: int = -1;
	public var _zoom			: Number;
	public var _visibleTiles	: int = 0;
	public var _scrollX			: Number;
	public var _scrollY			: Number;
	public var _pointedTileX	: int = -1;
	public var _pointedTileY	: int = -1;
	public var _pointedMinTileX	: int = -1;
	public var _pointedMinTileY	: int = -1;
	public var _pointedMaxTileX	: int = -1;
	public var _pointedMaxTileY	: int = -1;
	
	public var _lod1Visible     : int = 0;
	public var _lod1Invisible   : int = 0;
	public var _lod2Visible     : int = 0;
	public var _lod2Invisible   : int = 0;
	public var _lod3Visible     : int = 0;
	public var _lod3Invisible   : int = 0;
	public var _lod4Visible     : int = 0;
	public var _lod4Invisible   : int = 0;

	public function __DebugInfo_SetCurrentLod( lod : int ) : void
	{
		_currentLod = lod;

		__mapMenu.__UpdateDebugInfo();
	}

	public function __DebugInfo_SetMinMaxLod( minLod : int, maxLod : int ) : void
	{
		_minLod = minLod;
		_maxLod = maxLod;

		__mapMenu.__UpdateDebugInfo();
	}

	public function __DebugInfo_SetZoom( zoom : Number ) : void
	{
		_zoom = zoom;

		__mapMenu.__UpdateDebugInfo();
	}

	public function __DebugInfo_SetScroll( sx : Number, sy : Number ) : void
	{
		_scrollX = -sx;
		_scrollY = -sy;

		__mapMenu.__UpdateDebugInfo();
	}

	public function __DebugInfo_SetPointedTile( ptx : int, pty : int ) : void
	{
		_pointedTileX = ptx;
		_pointedTileY = pty;

		__mapMenu.__UpdateDebugInfo();
	}

	public function __DebugInfo_SetVisibleAndPointedTiles( tiles : int, mintx : int, minty : int, maxtx : int, maxty : int ) : void
	{
		_visibleTiles = tiles;
		_pointedMinTileX = mintx;
		_pointedMinTileY = minty;
		_pointedMaxTileX = maxtx;
		_pointedMaxTileY = maxty;

		__mapMenu.__UpdateDebugInfo();
	}
	
	public function __DebugInfo_SetTileStats( lod : int, tilesVisible : int, tilesInvisible : int ) : void
	{
		if ( lod == 1 )
		{
			_lod1Visible     = tilesVisible;
			_lod1Invisible   = tilesInvisible;
		}
		else if ( lod == 2 )
		{
			_lod2Visible     = tilesVisible;
			_lod2Invisible   = tilesInvisible;
		}
		else if ( lod == 3 )
		{
			_lod3Visible     = tilesVisible;
			_lod3Invisible   = tilesInvisible;
		}
		else if ( lod == 4 )
		{
			_lod4Visible     = tilesVisible;
			_lod4Invisible   = tilesInvisible;
		}
	}
}
