package red.game.witcher3.slots
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import red.game.witcher3.events.ItemDragEvent;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IDropTarget;
	import red.game.witcher3.interfaces.IInventorySlot;
	import red.game.witcher3.utils.Math2;
	import scaleform.clik.core.UIComponent;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.MouseEventEx;
	import flash.events.TransformGestureEvent;
	import flash.events.GestureEvent;
	import red.core.events.GestureEventEx;
	
	/**
	 * Drag manager for slots
	 * @author Yaroslav Getsevich
	 */
	public class SlotsTransferManager extends EventDispatcher
	{
		protected static const DRAG_START_OFFSET:Number = 10;
		protected static var _instance:SlotsTransferManager;
		protected var _dragTargets:Vector.<IDragTarget>;
		protected var _dropTargets:Vector.<IDropTarget>;
		protected var _actualDropTargets:Vector.<IDropTarget>;
		
		protected var _downPoint:Point;
		protected var _dragging:Boolean;
		protected var _canvas:Sprite;
		protected var _avatar:SlotDragAvatar;
		
		protected var _disabled:Boolean;
		
		protected var _currentStage:Stage;
		protected var _currentDragItem:IDragTarget;
		protected var _currentRecepient:IDropTarget;

		private var _enableTouch : Boolean;
		private var _dragStartedByTouch : Boolean;
		
		public static function getInstance():SlotsTransferManager
		{
			if (!_instance) _instance = new SlotsTransferManager();
			return _instance;
		}
		
		public function SlotsTransferManager()
		{
			_dragTargets = new Vector.<IDragTarget>;
			_dropTargets = new Vector.<IDropTarget>;
			_actualDropTargets = new Vector.<IDropTarget>;
			_enableTouch = false;
			_dragStartedByTouch = false;
		}
		
		public function get disabled():Boolean { return _disabled }
		public function set disabled(value:Boolean):void
		{
			_disabled = value;
			
			if (_disabled && _dragging)
			{
				stopDrag();
			}
		}

		public function enableDragWithPan( enable : Boolean ) : void
		{
			_enableTouch = enable;

			var i : int;
			for ( i = 0; i < _dragTargets.length; ++i )
			{
				var dragTarget : IDragTarget = _dragTargets[i];
				if (dragTarget)
				{
					if ( enable )
					{
						dragTarget.addEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan, false, 0, true );
					}
					else
					{
						dragTarget.removeEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan );
					}
				}
			}
		}
		
		public function init(targetCanvas:Sprite):void
		{
			_canvas = targetCanvas;
		}
		
		public function isDragging():Boolean
		{
			return _dragging;
		}
		
		public function addDragTarget(target:IDragTarget):void
		{
			_dragTargets.push(target);
			target.addEventListener(Event.REMOVED_FROM_STAGE, handleDragRemovedFromStage, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut, false, 0, true);
			if ( _enableTouch )
			{
				target.addEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan, false, 0, true );
			}
		}
		
		public function removeDragTarget(target:IDragTarget):void
		{
			var idx:int = _dragTargets.indexOf(target);
			if (idx > -1)
			{
				var dragTarget : IDragTarget = _dragTargets[idx];

				target.removeEventListener( Event.REMOVED_FROM_STAGE, handleDragRemovedFromStage );
				target.removeEventListener( MouseEvent.MOUSE_DOWN, handleMouseDown );
				target.removeEventListener( MouseEvent.MOUSE_OVER, handleMouseOver );
				target.removeEventListener( MouseEvent.MOUSE_OUT, handleMouseOut );
				target.removeEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan );

				_dragTargets.splice(idx, 1);
			}
		}

		public function addDropTarget(target:IDropTarget):void
		{
			_dropTargets.push(target);
			target.addEventListener(Event.REMOVED_FROM_STAGE, handleDropRemovedFromStage, false, 0, true);
		}
		
		public function removeDropTarget(target:IDropTarget):void
		{
			var idx:int = _dropTargets.indexOf(target);
			if (idx > -1) _dropTargets.splice(idx, 1);
		}
		
		public function showDropTargets(target:IDragTarget):void
		{
			if (!_dragging)
			{
				removeDropHighlighting();
				if (target.canDrag())
				{
					highlightDropTargets(target);
				}
			}
		}
		
		public function hideDropTargets():void
		{
			if (!_dragging)
			{
				removeDropHighlighting();
			}
		}
		
		/*
		 * 				- Handlers -
		 */
		
		private function handleMouseOver(event:MouseEvent):void
		{
			if (!_dragging)
			{
				var target:IDragTarget = event.currentTarget as IDragTarget;
				
				removeDropHighlighting();
				if (target && target.canDrag())
				{
					highlightDropTargets(event.currentTarget as IDragTarget);
				}
			}
		}
		
		private function handleMouseOut(event:MouseEvent):void
		{
			var target:IDragTarget = event.currentTarget as IDragTarget;
			
			if (target && !_dragging)
			{
				removeDropHighlighting();
			}
		}
		
		private function handleMouseDown(event:MouseEvent):void
		{
			if (_disabled)
			{
				return;
			}
			
			var eventEx:MouseEventEx = event as MouseEventEx;
			if (eventEx && eventEx.buttonIdx != MouseEventEx.LEFT_BUTTON)
			{
				// ignor all buttons except LEFT_BUTTON
				return;
			}
			
			if ( beginDrag( event.currentTarget, event.stageX, event.stageY ) )
			{
				_currentStage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 0, true);
				_currentStage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
			}
		}
		
		private function handleDragRemovedFromStage(event:Event):void
		{
			removeDragTarget(event.currentTarget as IDragTarget);
		}
		
		private function handleDropRemovedFromStage(event:Event):void
		{
			removeDropTarget(event.currentTarget as IDropTarget);
		}
		
		private function beginDrag( target : Object, stageX : Number, stageY : Number ) : Boolean
		{
			var dragTarget : IDragTarget = target as IDragTarget;
			if ( dragTarget && dragTarget.canDrag() )
			{
				_downPoint = new Point(stageX, stageY);

				var targetComponent:UIComponent = dragTarget as UIComponent;
				var targetStage:Stage = targetComponent.stage;
				
				_currentStage = targetStage;
				_currentDragItem = dragTarget;

				return true;
			}

			return false;
		}

		private function updateDrag(stageX:Number, stageY:Number):void
		{
			if (!_dragging)
			{
				tryStartDrag(stageX, stageY);
			}
			else if (_dragging)
			{
				// check for recepient
				var overObject:DisplayObject = Extensions.getTopMostEntity(stageX, stageY, true);
				var overDropTarget:IDropTarget;
				
				var lastEnabledDropTarget:IDropTarget;
				while (overObject && !overDropTarget && overObject.parent)
				{
					overDropTarget = overObject as IDropTarget;
					overObject = overObject.parent;
					
					if (overDropTarget && overDropTarget.dropEnabled)
					{
						lastEnabledDropTarget = overDropTarget
					}
					else
					{
						overDropTarget = null;
					}
				}
				if (!overDropTarget && lastEnabledDropTarget)
				{
					overDropTarget = lastEnabledDropTarget;
				}
				
				var canDropNow:Boolean = overDropTarget && overDropTarget.canDrop(_currentDragItem);
				
				if (overDropTarget && canDropNow)
				{
					if (_currentRecepient && _currentRecepient != overDropTarget)
					{
						_currentRecepient.processOver(null);
					}
					
					_currentRecepient = overDropTarget;
					_currentRecepient.dropSelection = true;
					
					var actionId:int = _currentRecepient.processOver(_avatar);
					if (_avatar)
					{
						_avatar.setActionIcon(actionId);
					}
				}
				else
				{
					if (_currentRecepient)
					{
						_currentRecepient.processOver(null);
					}
					_currentRecepient = null;
					
					if (_avatar)
					{
						if (!canDropNow && overDropTarget && overDropTarget != _currentDragItem)
						{
							_avatar.setActionIcon(SlotDragAvatar.ACTION_ERROR);
						}
						else
						{
							_avatar.setActionIcon(SlotDragAvatar.ACTION_NONE);
						}
					}
				}
			}
		}

		private function handleGesturePan( event : TransformGestureEvent ) : void
		{
			switch (event.phase)
			{
				case "begin" : 
				{
					if (_disabled)
					{
						return;
					}
					
					_dragStartedByTouch = true;
					beginDrag(event.currentTarget, event.stageX, event.stageY );
				}
				break;
				case "update" :
					//Check if we have something to drag, because tryStartDrag might have called stopDrag already
					//if we have failed the deadzone test.
					if ( _currentDragItem )
					{
						updateDrag( event.stageX, event.stageY );
						_avatar.x = event.stageX;
						_avatar.y = event.stageY;
					}
				break;
				case "end" : 
					_dragStartedByTouch = false;
					stopDrag();
				break;
			}
		}

		protected function handleMouseMove(event:MouseEvent):void
		{
			updateDrag( event.stageX, event.stageY );
		}
		
		protected function handleMouseUp(event:MouseEvent):void
		{
			stopDrag();
		}
		
		/*
		 * 				- Core -
		 */
		
		protected function tryStartDrag(curX : Number, curY : Number):void
		{
			if (!_currentDragItem || !_downPoint || !_canvas)
			{
				return;
			}

			var currentPoint : Point = new Point( curX, curY );
			var currentDeviation : Number = Math2.getSegmentLength(_downPoint, new Point(curX, curY));

			var exitedDeadzone : Boolean = ( currentDeviation > DRAG_START_OFFSET );
			var exitDrag : Boolean = false;

			//For gestures check the direction too. Up and down should not initiate drag.
			//If we left the deadzone in up or right direction, then stop the drag.
			if ( _dragStartedByTouch )
			{
				var deltaX : Number = curX - _downPoint.x;
				var deltaY : Number = curY - _downPoint.y;
				exitDrag = Math.abs( deltaX ) < Math.abs( deltaY );
				if ( exitDrag )
				{
					stopDrag();
				}
			}

			_dragging = exitedDeadzone && !exitDrag;
			if (_dragging && !_avatar)
			{
				_avatar = new SlotDragAvatar(_currentDragItem.getAvatar(), _currentDragItem.getDragData(), _currentDragItem);
				if (_avatar)
				{
					_canvas.addChild(_avatar);
					_avatar.x = curX;
					_avatar.y = curY;
					_avatar.startDrag(true);
					_avatar.mouseChildren = false;
					_avatar.mouseEnabled = false;
					_currentDragItem.dragSelection = true;
					
					var startEvent:ItemDragEvent = new ItemDragEvent(ItemDragEvent.START_DRAG);
					startEvent.targetItem = _currentDragItem;
					dispatchEvent(startEvent);
					highlightDropTargets(_currentDragItem);
				}
				else
				{
					_dragging = false;
					throw new Error("Can't get dragging view avatar from object ", _currentDragItem);
				}
			}
		}
		
		protected function stopDrag():void
		{
			var stopEvent:ItemDragEvent = new ItemDragEvent(ItemDragEvent.STOP_DRAG);
			if (_dragging)
			{
				if (_currentRecepient)
				{
					_currentRecepient.processOver(null);
					_currentRecepient.applyDrop(_currentDragItem);
					stopEvent.targetRecepient = _currentRecepient;
				}
				if (_avatar)
				{
					_avatar.stopDrag();
					_canvas.removeChild(_avatar);
					_avatar = null;
				}
				_dragging = false;
				_currentDragItem.dragSelection = false;
				removeDropHighlighting();
			}
			if (_currentStage)
			{
				_currentStage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
				_currentStage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
				_currentDragItem = null;
			}
			dispatchEvent(stopEvent);
		}
		
		protected function highlightDropTargets(keyTarget:IDragTarget):void
		{
			var len:int = _dropTargets.length;
			
			for (var i:int = 0; i < len; i++ )
			{
				var curTarget:IDropTarget = _dropTargets[i];
				var isSameSlot:Boolean = keyTarget == curTarget;
				
				if (curTarget.canDrop(keyTarget) && !isSameSlot)
				{
					curTarget.dropSelection = true;
					_actualDropTargets.push(curTarget);
				}
			}
		}
		
		protected function removeDropHighlighting():void
		{
			while (_actualDropTargets.length)
			{
				_actualDropTargets.pop().dropSelection = false;
			}
		}
	}
	
}
