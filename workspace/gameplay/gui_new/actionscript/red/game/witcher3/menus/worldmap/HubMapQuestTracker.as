package red.game.witcher3.menus.worldmap
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import red.game.witcher3.LinearEase

	import flash.utils.setTimeout;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import scaleform.clik.core.UIComponent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.data.DataProvider;
	import red.game.witcher3.controls.W3ScrollingList;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import scaleform.clik.constants.NavigationCode;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.InputManager;
	import red.core.events.GestureEventEx;
	import flash.events.GestureEvent;
	import flash.events.TransformGestureEvent;
	import flash.utils.setTimeout;
	
	public class HubMapQuestTracker extends UIComponent
	{
		public var mcHubMapQuestTrackerQuest : MovieClip;
		public var mcHubMapQuestTrackerList : W3ScrollingList;
		public var mcHubMapNewQuestTrackerList : W3ScrollingList;

		public var mcNewQuestTrackerQuest : MovieClip;
		public var mcHubMapNewObjTrackerList : W3ScrollingList;

		public var mcQuestUpArrow : MovieClip;
		public var mcQuestDownArrow : MovieClip;
		public var mcObjUpArrow : MovieClip;
		public var mcObjDownArrow : MovieClip;
		
		private var _objectivesCount : int = 0;
		private var _questsCountNew : int = 0;
		private var _collapseWhenUpdated : Boolean;
		private var _expandedList : Boolean = false;

		private var _state : String = "normal";

		private var _newQuestTag : uint;

		private var m_action_TrackQuest		     : int = -1;
		private var m_action_TrackObjective		 : int = -1;
		private var m_action_OpenInJournal		 : int = -1;
		private var m_action_ShowObjectives		 : int = -1;
		private var m_action_HideObjectives	 	 : int = -1;
		private var m_action_NavQuest		 	 : int = -1;
		private var m_action_NavObjectives		 : int = -1;
		private var _panYAccumulator : Number;

		private static const MAX_QUEST_RENDERERS : int = 9;
		private static const MAX_OBJ_RENDERERS : int = 12;

		private static const QUEST_LEFT_X : Number = 231.8;
		private static const OBJ_LEFT_X : Number = 231.8;
		private static const ARROW_LEFT_X : Number = 201.9;
		private static const RIGHT_PUSH : Number = 350;
		private static const ANIM_TIME : Number = 0.22;

		
		
		public function HubMapQuestTracker()
		{
			super();
			// constructor code
			_panYAccumulator = 0;
		}
		
		protected override function configUI():void
		{
			super.configUI();
			
			addEventListener( MouseEvent.MOUSE_OVER,		OnMouseOver,		false, 0, true );
			addEventListener( MouseEvent.MOUSE_OUT,			OnMouseOut,			false, 0, true );
			
			mcHubMapQuestTrackerList.addEventListener(ListEvent.INDEX_CHANGE, handleIndexChanged, false, 0, true);
			mcHubMapNewQuestTrackerList.addEventListener(ListEvent.INDEX_CHANGE, handleIndexChangedNewQuest, false, 0, true);
			mcHubMapNewObjTrackerList.addEventListener(ListEvent.INDEX_CHANGE, handleIndexChangedNewObj, false, 0, true);

			mcHubMapNewQuestTrackerList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, handleNewQuestRendererDoubleClick, false, 0, true);
			mcHubMapNewObjTrackerList.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, handleNewObjRendererDoubleClick, false, 0, true);

			mcHubMapQuestTrackerQuest.addEventListener(MouseEvent.CLICK, handleQuestClickOrTap, false, 0, true);
			mcHubMapQuestTrackerQuest.addEventListener( GestureEventEx.GESTURE_TAP, handleQuestClickOrTap, false, 0, true );

			addEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan, false, 0, true );

			mcHubMapQuestTrackerList.enableTouch(true);
			mcHubMapNewQuestTrackerList.enableTouch(true);
			mcHubMapNewObjTrackerList.enableTouch(true);

			mcQuestUpArrow.visible = false;
			mcQuestDownArrow.visible = false;
			mcObjUpArrow.visible = false;
			mcObjDownArrow.visible = false;

			SetState("normal");
		}

		public function SetState(newState : String):void
		{
			_state = newState;
			if(_state == "normal")
			{
				handleNormalState();
			}
			else if (_state == "quest")
			{
				handleQuestState();
			}
			else if (_state == "objective")
			{
				handleObjectiveState();
			}

			handleButtonState();
			_panYAccumulator = 0;
		}

		public function GetState():String
		{
			return _state;
		}

		public function handleElemSetVisibleWithAnim(elem:MovieClip, vis:Boolean, targetX:Number, noWaitOnVis : Boolean = false)
		{
			GTweener.removeTweens(elem);

			if(vis)
			{
				//delay
				setTimeout(function()
				{
				elem.visible = true;
				GTweener.to(elem, ANIM_TIME, {alpha:1,x:targetX}, {ease:LinearEase.easeOut});
				}, noWaitOnVis ? 0 : ANIM_TIME * 1000);
			}
			else
			{
				GTweener.to(elem, ANIM_TIME, {alpha:0,x:targetX}, {ease:LinearEase.easeIn, onComplete:function(){elem.visible = false;}});
			}
		}

		private function handleButton(cond:Boolean, varName:String, gamepadCode:String, kbCode:int, label:String)
		{
			if(this[varName] != -1 && !cond)
			{
				InputFeedbackManager.removeButton(this, this[varName]);
				this[varName] = -1;
			}
			else if(this[varName] == -1 && cond)
			{
				this[varName] = InputFeedbackManager.appendButton(this, gamepadCode, kbCode, label);
			}
		}

		public function handleButtonState():void
		{
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform(); 
			handleButton(_state == "quest", "m_action_NavQuest", NavigationCode.DPAD_UP_DOWN, -1, "panel_button_navigate_quests");
			handleButton(_state == "objective", "m_action_NavObj", NavigationCode.DPAD_UP_DOWN, -1, "panel_button_navigate_objectives");
			handleButton(_state == "quest", "m_action_ShowObjectives", NavigationCode.DPAD_RIGHT, KeyCode.D, "panel_button_show_objectives");
			handleButton(_state == "objective", "m_action_HideObjectives", NavigationCode.DPAD_LEFT, KeyCode.A, "panel_button_hide_objectives");
			handleButton(_state == "quest", "m_action_TrackQuest", NavigationCode.GAMEPAD_A, KeyCode.E, "panel_button_track_quest");
			handleButton(_state == "objective", "m_action_TrackObjective", NavigationCode.GAMEPAD_A, KeyCode.E, "panel_button_track_objective");
			handleButton(_state != "normal", "m_action_OpenInJournal", isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X, KeyCode.H, "panel_button_open_journal");
			InputFeedbackManager.updateButtons(this);
		}

		public function handleNormalState():void
		{
			var i : int;
			//Normal State Elems
			handleElemSetVisibleWithAnim(mcHubMapQuestTrackerQuest, true, QUEST_LEFT_X);
			for(i = 0; i < mcHubMapQuestTrackerList.getRenderers().length; i++)
			{
				var itemRenderer : HubMapQuestTrackerItemRenderer = mcHubMapQuestTrackerList.getRendererAt(i) as HubMapQuestTrackerItemRenderer;
				if(itemRenderer.data)
					handleElemSetVisibleWithAnim(itemRenderer, true, OBJ_LEFT_X);
			}
			//Quest State Elems
			for(i = 0; i < mcHubMapNewQuestTrackerList.getRenderers().length; i++)
			{
				handleElemSetVisibleWithAnim((mcHubMapNewQuestTrackerList.getRendererAt(i) as MovieClip), false, QUEST_LEFT_X + RIGHT_PUSH);
			}
			//Obj State Elems
			handleElemSetVisibleWithAnim(mcNewQuestTrackerQuest, false, QUEST_LEFT_X + RIGHT_PUSH);
			for(i = 0; i < mcHubMapNewObjTrackerList.getRenderers().length; i++)
			{
				handleElemSetVisibleWithAnim((mcHubMapNewObjTrackerList.getRendererAt(i) as MovieClip), false, OBJ_LEFT_X + RIGHT_PUSH);
			}
			handleArrowVisibility();
		}

		public function handleQuestState():void
		{
			var i : int;
			//Normal State Elems
			handleElemSetVisibleWithAnim(mcHubMapQuestTrackerQuest, false, QUEST_LEFT_X + RIGHT_PUSH);
			mcHubMapQuestTrackerList.focused = 0;
			for(i = 0; i < mcHubMapQuestTrackerList.getRenderers().length; i++)
			{
				handleElemSetVisibleWithAnim((mcHubMapQuestTrackerList.getRendererAt(i) as MovieClip), false, OBJ_LEFT_X + RIGHT_PUSH);
			}
			//Quest State Elems
			for(i = 0; i < mcHubMapNewQuestTrackerList.getRenderers().length; i++)
			{
				var itemRenderer : HubMapQuestTrackerNewQuestRenderer = mcHubMapNewQuestTrackerList.getRendererAt(i) as HubMapQuestTrackerNewQuestRenderer
				if(itemRenderer.data)
					handleElemSetVisibleWithAnim(itemRenderer, true, QUEST_LEFT_X);
			}
			//Obj State Elems
			handleElemSetVisibleWithAnim(mcNewQuestTrackerQuest, false, QUEST_LEFT_X + RIGHT_PUSH);
			for(i = 0; i < mcHubMapNewObjTrackerList.getRenderers().length; i++)
			{
				handleElemSetVisibleWithAnim((mcHubMapNewObjTrackerList.getRendererAt(i) as MovieClip), false, OBJ_LEFT_X + RIGHT_PUSH);
			}
			handleArrowVisibility();
		}

		public function handleObjectiveState():void
		{
			var i : int;
			//Normal State Elems
			for(i = 0; i < mcHubMapNewQuestTrackerList.getRenderers().length; i++)
			{
				handleElemSetVisibleWithAnim((mcHubMapQuestTrackerList.getRendererAt(i) as MovieClip), false, OBJ_LEFT_X + RIGHT_PUSH);
			}
			//Quest State Elems
			for(i = 0; i < mcHubMapNewQuestTrackerList.getRenderers().length; i++)
			{
				handleElemSetVisibleWithAnim((mcHubMapNewQuestTrackerList.getRendererAt(i) as MovieClip), false, QUEST_LEFT_X + RIGHT_PUSH);
			}
			//Obj State Elems
			handleElemSetVisibleWithAnim(mcNewQuestTrackerQuest, true, QUEST_LEFT_X);
			for(i = 0; i < mcHubMapNewObjTrackerList.getRenderers().length; i++)
			{
				var itemRenderer : HubMapQuestTrackerNewObjRenderer = mcHubMapNewObjTrackerList.getRendererAt(i) as HubMapQuestTrackerNewObjRenderer
				if(itemRenderer.data)
					handleElemSetVisibleWithAnim(itemRenderer, true, OBJ_LEFT_X);
			}
			handleArrowVisibility();
		}
		
		public function handleArrowVisibility():void
		{
			//mcQuestUpArrow.visible = false;
			//mcQuestDownArrow.visible = false;
			//mcObjUpArrow.visible = false;
			//mcObjDownArrow.visible = false;

			if(_state == "quest")
			{
				var questRenderers : * = mcHubMapNewQuestTrackerList.getRenderers();
				var firstIndex : int = questRenderers[0].index;

				var upVisible : Boolean = firstIndex > 0;
				var downVisible : Boolean = mcHubMapNewQuestTrackerList.dataProvider.length > MAX_QUEST_RENDERERS && questRenderers[MAX_QUEST_RENDERERS - 1].index < mcHubMapNewQuestTrackerList.dataProvider.length - 1;

				handleElemSetVisibleWithAnim(mcQuestUpArrow, upVisible, mcQuestUpArrow.x, true);
				handleElemSetVisibleWithAnim(mcQuestDownArrow, downVisible, mcQuestDownArrow.x, true);
				handleElemSetVisibleWithAnim(mcObjUpArrow, false, mcObjUpArrow.x, true);
				handleElemSetVisibleWithAnim(mcObjDownArrow, false, mcObjDownArrow.x, true);
			}
			else if(_state == "objective")
			{
				var objRenderers : * = mcHubMapNewObjTrackerList.getRenderers();
				var firstIndex2 : int = objRenderers[0].index;

				var upVisible2 : Boolean = firstIndex2 > 0;
				var downVisible2 : Boolean = mcHubMapNewObjTrackerList.dataProvider.length > MAX_OBJ_RENDERERS && objRenderers[MAX_OBJ_RENDERERS - 1].index < mcHubMapNewObjTrackerList.dataProvider.length - 1;

				handleElemSetVisibleWithAnim(mcObjUpArrow, upVisible2, mcObjUpArrow.x, true);
				handleElemSetVisibleWithAnim(mcObjDownArrow, downVisible2, mcObjDownArrow.x, true);
				handleElemSetVisibleWithAnim(mcQuestUpArrow, false, mcQuestUpArrow.x, true);
				handleElemSetVisibleWithAnim(mcQuestDownArrow, false, mcQuestDownArrow.x, true);
			}
			else
			{
				handleElemSetVisibleWithAnim(mcQuestUpArrow, false, mcQuestUpArrow.x, true);
				handleElemSetVisibleWithAnim(mcQuestDownArrow, false, mcQuestDownArrow.x, true);
				handleElemSetVisibleWithAnim(mcObjUpArrow, false, mcObjUpArrow.x, true);
				handleElemSetVisibleWithAnim(mcObjDownArrow, false, mcObjDownArrow.x, true);
			}
		}

		public function enableMouse( enable : Boolean )
		{
			mouseEnabled = enable;
			mouseChildren = enable;
		}
		
		public function OnMouseOver( event : MouseEvent )
		{
			if ( mouseEnabled )
			{
				expandList( true );
			}
		}
		
		public function OnMouseOut( event : MouseEvent )
		{
			expandList( false );
		}
		
		public function OnMouseMoveFromParent(  globalMousePos : Point )
		{
			if ( mouseEnabled )
			{
				expandList( isGlobalPointInsideBounds( globalMousePos ) );
			}
		}
		
		protected function handleIndexChanged( event : ListEvent )
		{
			expandList( true );

			if ( event.index >= 0 )
			{
				var renderer : HubMapQuestTrackerItemRenderer;
				renderer = mcHubMapQuestTrackerList.getRendererAt( event.index ) as HubMapQuestTrackerItemRenderer;
				if ( renderer )
				{
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnHighlightObjective', [ renderer.getScriptName() ] ) );
				}
			}
		}

		private function addTouchQuestSelectionDelayed() : void
		{
			addEventListener( GestureEventEx.GESTURE_DOUBLE_TAP, handleTouchQuestSelection, false, 0, true);
			addEventListener( GestureEventEx.GESTURE_TAP, handleTouchQuestSelection, false, 0, true);
		}

		protected function handleIndexChangedNewQuest( event : ListEvent )
		{
			//#LT there is some weird thing when you click on the module with mouse, unfocusing solves
			mcHubMapNewQuestTrackerList.focused = 0;
			
			if ( event.index >= 0)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnUpdateNewQuestTrackerObjectives', [ uint(event.itemData.questScriptName) ] ) );
				if(_state == "quest")
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnShowQuestOnMap', [ uint(event.itemData.questScriptName) ] ) );
			}

			removeEventListener( GestureEventEx.GESTURE_DOUBLE_TAP, handleTouchQuestSelection, false );
			removeEventListener( GestureEventEx.GESTURE_TAP, handleTouchQuestSelection, false );
			setTimeout(addTouchQuestSelectionDelayed, 0);
		}

		protected function handleIndexChangedNewObj( event : ListEvent )
		{
			//expandList( true );

			if ( event.index >= 0 )
			{
				if(_state == "objective")
					dispatchEvent( new GameEvent( GameEvent.CALL, 'OnShowObjectiveOnMap', [_newQuestTag, uint(event.itemData.objectiveScriptName) ] ) );
			}
		}

		override public function handleInput( event : InputEvent ) : void
		{
            var details : InputDetails = event.details;
			var keyDown : Boolean  = (details.value == InputValue.KEY_DOWN );
			var keyUp : Boolean    = (details.value == InputValue.KEY_UP );
            var keyPress : Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			
			//trace("Minimap1 " + details.code );
			
			if ( details.code == 1000 )
			{
				expandList( false );
			}
			else if ( _state == "normal" && details.code == KeyCode.PAD_RIGHT_THUMB || details.code == KeyCode.V )
			{
				expandList( true );
				if ( keyDown )
				{
					if ( _objectivesCount > 1 )
					{
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnHighlightNextObjective' ) );
					}
				}
			}
			else if ((details.code == KeyCode.W || details.navEquivalent == NavigationCode.DPAD_UP) && keyPress)
			{
				if(_state == "quest" )
				{
					if(mcHubMapNewQuestTrackerList.selectedIndex > 0)
					{
						mcHubMapNewQuestTrackerList.selectedIndex--;
					}
					else
					{
						mcHubMapNewQuestTrackerList.selectedIndex = mcHubMapNewQuestTrackerList.dataProvider.length - 1;
					}
					mcHubMapNewQuestTrackerList.validateNow();
					event.handled = true;
				}
				else if (_state == "objective")
				{
					if(mcHubMapNewObjTrackerList.selectedIndex > 0)
					{
						mcHubMapNewObjTrackerList.selectedIndex--;
					}
					else
					{
						mcHubMapNewObjTrackerList.selectedIndex = mcHubMapNewObjTrackerList.dataProvider.length - 1;
					}
					mcHubMapNewObjTrackerList.validateNow();
					event.handled = true;
				}
				handleArrowVisibility();
			}
			else if ((details.code == KeyCode.S || details.navEquivalent == NavigationCode.DPAD_DOWN) && keyPress)
			{
				if( _state == "quest" )
				{
					if(mcHubMapNewQuestTrackerList.selectedIndex < mcHubMapNewQuestTrackerList.dataProvider.length - 1)
					{
						mcHubMapNewQuestTrackerList.selectedIndex++;
					}
					else
					{
						mcHubMapNewQuestTrackerList.selectedIndex = 0;
					}
					mcHubMapNewQuestTrackerList.validateNow();
					event.handled = true;
				}
				else if( _state == "objective" )
				{
					if(mcHubMapNewObjTrackerList.selectedIndex < mcHubMapNewObjTrackerList.dataProvider.length - 1)
					{
						mcHubMapNewObjTrackerList.selectedIndex++;
					}
					else
					{
						mcHubMapNewObjTrackerList.selectedIndex = 0;
					}
					mcHubMapNewObjTrackerList.validateNow();
					event.handled = true;
				}
				handleArrowVisibility();
			}
			else if ( _state != "normal" && (details.code == KeyCode.A || details.navEquivalent == NavigationCode.DPAD_LEFT))
			{
				if (_state == "objective" && keyUp)
					dispatchEvent( new GameEvent(GameEvent.CALL, "OnRequestQuestTrackerState", ["quest"]) );
				event.handled = true;
			}
			else if ( _state != "normal" && (details.code == KeyCode.D || details.navEquivalent == NavigationCode.DPAD_RIGHT))
			{
				if(_state == "quest" && keyUp)
					dispatchEvent( new GameEvent(GameEvent.CALL, "OnRequestQuestTrackerState", ["objective"]) );
				event.handled = true;
			}

		}
		
		private function isGlobalPointInsideBounds( globalMousePos : Point ) : Boolean
		{
			var globalBounds : Rectangle = mcHubMapQuestTrackerList.getBounds( stage );
			
			return globalMousePos.x > globalBounds.left &&
				   globalMousePos.x < globalBounds.right &&
				   globalMousePos.y > globalBounds.top &&
				   globalMousePos.y < globalBounds.bottom;
			
		}
		
		public function canBeShown() : Boolean
		{
			return _objectivesCount > 0;
		}
		
		private const RIGHT_MARGIN : int = 70;
		private const LEFT_MARGIN : int = 5;
				
		public function setCurrentQuest( value : Object, questShower:MovieClip = null )
		{
			if ( !value )
			{
				return;
			}

			if(questShower == null)
				questShower = mcHubMapQuestTrackerQuest;

			questShower.tfQuest.htmlText = value.questName;
			questShower.tfQuest.width = questShower.tfQuest.textWidth;
			questShower.tfQuest.x = questShower.mcBackground.x + 15 - RIGHT_MARGIN - questShower.tfQuest.width;
			questShower.mcBackground.width = RIGHT_MARGIN + questShower.tfQuest.textWidth + LEFT_MARGIN;

			switch ( value.questType )
			{
				case 0:
				case 1:
				case 2:
					{
						switch( value.contentType )
						{
							case 0:
								questShower.mcPinIcon.gotoAndStop( 'Quest' );
								break;
							case 1:
								questShower.mcPinIcon.gotoAndStop( 'QuestHoS' );
								break;
							case 2:
								questShower.mcPinIcon.gotoAndStop( 'QuestBaW' );
								break;
							case 3:
								questShower.mcPinIcon.gotoAndStop( 'QuestLy' ); 
								break;
						}
					}
					break;
				case 3:
					questShower.mcPinIcon.gotoAndStop( "MonsterHunt" );
					break;
				case 4:
					questShower.mcPinIcon.gotoAndStop( "TreasureHunt" );
					break;
			}
			
			_collapseWhenUpdated = !value.onHighlight;
		}

		public function setCurrentObjectives( array: Array )
		{
			if ( !array )
			{
				return;
			}
			_objectivesCount = array.length;

			mcHubMapQuestTrackerList.dataProvider = new DataProvider( array );
			mcHubMapQuestTrackerList.selectedIndex = -1;
			mcHubMapQuestTrackerList.validateNow(); // needed for resizeHitArea()
			
			if ( _collapseWhenUpdated )
			{
				if ( !expandList( false ) )
				{
					updateVisibility();
					resizeHitArea();
				}
			}
			else
			{
				updateVisibility();
				resizeHitArea();
			}
		}

		public function setQuestsNew( array: Array )
		{
			if ( !array )
			{
				return;
			}
			_questsCountNew = array.length;

			mcHubMapNewQuestTrackerList.dataProvider = new DataProvider( array );

			var i : int;

			var defIndex : int = -1;
			for(i = 0; i < array.length; i++)
			{
				if(array[i].highlighted)
				{
					_newQuestTag = (uint)(array[i].questScriptName);
					defIndex = i;
					break;
				}
			}
			mcHubMapNewQuestTrackerList.selectedIndex = defIndex;
			mcHubMapNewQuestTrackerList.validateNow(); // needed for resizeHitArea()

			for(i = 0; i < mcHubMapNewQuestTrackerList.getRenderers().length; i++)
			{
				(mcHubMapNewQuestTrackerList.getRendererAt(i) as MovieClip).visible = _state == "quest";
			}
			
			if ( _collapseWhenUpdated )
			{
				if ( !expandList( false ) )
				{
					updateVisibility();
					resizeHitArea();
				}
			}
			else
			{
				updateVisibility();
				resizeHitArea();
			}
		}

		public function setNewQuestAndObjectives( object : Object):void
		{
			if(!object)
				return;

			setCurrentQuest(object.quest, mcNewQuestTrackerQuest);
			if(object.quest.scriptName > 0)
				_newQuestTag = object.quest.scriptName;

			mcHubMapNewObjTrackerList.dataProvider = new DataProvider( object.objectives );
			mcHubMapNewObjTrackerList.selectedIndex = 0;
			mcHubMapNewObjTrackerList.validateNow(); // needed for resizeHitArea()

			for(var i : int = 0; i < mcHubMapNewObjTrackerList.getRenderers().length; i++)
			{
				(mcHubMapNewObjTrackerList.getRendererAt(i) as MovieClip).visible = _state == "objective";
			}

			if ( _collapseWhenUpdated )
			{
				if ( !expandList( false ) )
				{
					updateVisibility();
					resizeHitArea();
				}
			}
			else
			{
				updateVisibility();
				resizeHitArea();
			}
		}


		public function handleQuestClickOrTap(event:Event) : void
		{
			dispatchEvent( new GameEvent(GameEvent.CALL, "OnRequestQuestTrackerState", ["quest"]) );
		}

		private function handleTouchQuestSelection( event:GestureEvent ) : void
		{
			if(_state == "quest" )
			{
				var selectedRenderer : HubMapQuestTrackerNewQuestRenderer = mcHubMapNewQuestTrackerList.getSelectedRenderer() as HubMapQuestTrackerNewQuestRenderer;
				if ( selectedRenderer )
				{
					var hitTestResult : Boolean = selectedRenderer.hitTestPoint( event.stageX, event.stageY );
					if ( hitTestResult )
					{
						setTrackCurrentQuest();
					}
				}
			}
		}

		private function scrollListByPan( list : W3ScrollingList, event : TransformGestureEvent ) : void
		{
			var rowHeight : Number = list.getRenderers()[0].height;
			var result : Object = CommonUtils.stagePanToRowScroll( _panYAccumulator, rowHeight, event );

			list.scrollPosition = list.scrollPosition - result.outRowsToScroll;
			list.validateNow();

			_panYAccumulator = result.outPanYAccumulator;
		}

		private function getCurrentList() : W3ScrollingList
		{
			var currentList : W3ScrollingList = null;

			if(_state == "quest" )
			{
				currentList = mcHubMapNewQuestTrackerList;
			}
			else if (_state == "objective")
			{
				currentList = mcHubMapNewObjTrackerList;
			}

			return currentList;
		}

		protected function handleGesturePan( event : TransformGestureEvent ) : void
		{	
			var currentList : W3ScrollingList = getCurrentList();
			if ( currentList )
			{
				scrollListByPan( currentList, event );
			}
		}

		public function handleNewQuestRendererDoubleClick(event:ListEvent)
		{
			setTrackCurrentQuest();
		}

		public function handleNewObjRendererDoubleClick(event:ListEvent)
		{
			setTrackCurrentObjective();
		}

		public function setTrackCurrentQuest():void
		{
			var questRenderer : HubMapQuestTrackerNewQuestRenderer = mcHubMapNewQuestTrackerList.getSelectedRenderer() as HubMapQuestTrackerNewQuestRenderer;

			if(questRenderer)
			{
				dispatchEvent( new GameEvent(GameEvent.CALL, "OnTrackQuest", [questRenderer.getScriptName()]) );
			}
		}

		public function setTrackCurrentObjective():void
		{
			var objRenderer : HubMapQuestTrackerNewObjRenderer = mcHubMapNewObjTrackerList.getSelectedRenderer() as HubMapQuestTrackerNewObjRenderer;

			if(objRenderer)
			{
				dispatchEvent( new GameEvent(GameEvent.CALL, "OnHighlightObjectiveWithQuestChange", [_newQuestTag, objRenderer.getScriptName()]) );
			}
			
		}
		
		private function expandList( expand : Boolean ) : Boolean
		{
			if ( _expandedList == expand )
			{
				return false;
			}
			
			_expandedList = expand;
			
			updateVisibility();
			resizeHitArea();
			
			return true;
		}
		
		private function updateVisibility()
		{
			var i : int;
			var renderers : Vector.<IListItemRenderer>;
			var renderer : HubMapQuestTrackerItemRenderer;

			renderers = mcHubMapQuestTrackerList.getRenderers();

			for ( i = 0; i < _objectivesCount; ++i )
			{
				renderer = renderers[ i ] as HubMapQuestTrackerItemRenderer
				if ( renderer )
				{
					if ( _expandedList )
					{
						renderer.alpha = 1;
						if ( i > 2 )
						{
							renderer.visible = true;
						}
					}
					else
					{
						if(renderer.data.highlighted)
							renderer.alpha = 1;
						else 
							renderer.alpha = 0.5;
						/*if ( i == 0 )
							renderer.alpha = 1;
						else if ( i == 1 )
							renderer.alpha = 0.5;
						else if ( i == 2 )
							renderer.alpha = 0.3;
						else
							renderer.visible = false;*/
					}
				}
			}
		}
		
		private function resizeHitArea()
		{
			var left : Number = NaN;
			var right : Number = NaN;
			var top : Number = NaN;
			var bottom : Number = NaN;

			var questButtonBounds : Rectangle;
			
			questButtonBounds = mcHubMapQuestTrackerQuest.getBounds( this );
			
			top    = questButtonBounds.top;
			right  = questButtonBounds.right;
			left   = questButtonBounds.left;
			bottom = questButtonBounds.bottom;
			
			var renderers : Vector.< IListItemRenderer > = mcHubMapQuestTrackerList.getRenderers();
			var i : int;
			
			for ( i = 0; i < renderers.length; ++i )
			{
				var item : HubMapQuestTrackerItemRenderer = renderers[ i ] as HubMapQuestTrackerItemRenderer;
				if ( item && item.visible && item.alpha > 0 )
				{
					var bounds : Rectangle = item.getBounds( this );
					if ( isNaN( left ) || left > bounds.left )
					{
						left = bounds.left;
					}
					if ( isNaN( right ) || right < bounds.right )
					{
						right = bounds.right;
					}
					if ( isNaN( top ) || top > bounds.top )
					{
						top = bounds.top;
					}
					if ( isNaN( bottom ) || bottom < bounds.bottom )
					{
						bottom = bounds.bottom;
					}
				}
			}
			
			mcHubMapQuestTrackerList.x = right;
			mcHubMapQuestTrackerList.y = top;
			mcHubMapQuestTrackerList.scaleX = ( ( right - left ) / 100 );
			mcHubMapQuestTrackerList.scaleY = ( ( bottom - top ) / 100 );
		}

		public function OpenQuestInJournal()
		{
			dispatchEvent( new GameEvent(GameEvent.CALL, "OnShowQuestInJournal", [_newQuestTag]) );
		}
	}
	
}
