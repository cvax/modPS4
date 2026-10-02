/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2015 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;

	import red.game.witcher3.utils.CommonUtils;
	import flash.events.TransformGestureEvent;
	
	public class InstalledDLCModule extends StaticOptionModule
	{
		public var mcScrollbar : ScrollBar;
		public var mcList : W3ScrollingList;
		public var mcItemRenderer1 : InstalledDLCMItemRenderer;
		public var mcItemRenderer2 : InstalledDLCMItemRenderer;
		public var mcItemRenderer3 : InstalledDLCMItemRenderer;
		public var mcItemRenderer4 : InstalledDLCMItemRenderer;
		public var mcItemRenderer5 : InstalledDLCMItemRenderer;
		public var mcItemRenderer6 : InstalledDLCMItemRenderer;
		public var mcItemRenderer7 : InstalledDLCMItemRenderer;
		public var mcItemRenderer8 : InstalledDLCMItemRenderer;
		public var mcItemRenderer9 : InstalledDLCMItemRenderer;
		public var mcItemRenderer10 : InstalledDLCMItemRenderer;
		public var mcItemRenderer11 : InstalledDLCMItemRenderer;
		public var txtSelectionInfo : TextField;

		public var _lastMoveWasMouse : Boolean;
		private var _panYAccumulator : Number;
		protected var _mouseEventsRegistered : Boolean;
		protected var _lastMouseOveredItem : int;
		
		public function InstalledDLCModule()
		{
			_lastMoveWasMouse = false;
			_panYAccumulator = 0;
			_mouseEventsRegistered = false;
			_lastMouseOveredItem = -1;
		}

		public function get lastMoveWasMouse():Boolean 
		{ 
			return _lastMoveWasMouse; 
		}

		public function set lastMoveWasMouse(value:Boolean):void
		{
			_lastMoveWasMouse = value;
			
			if (!_lastMoveWasMouse)
			{
				if (mcList.selectedIndex == -1)
				{
					mcList.selectedIndex = 0;
				}
			}
			else
			{
				mcList.selectedIndex = _lastMouseOveredItem;
			}
		}
		
		override protected function configUI():void
		{
			super.configUI();
			focusable = false;
			
			if (mcScrollbar)
			{
				mcScrollbar.addEventListener( Event.SCROLL, handleScroll, false, 1, true) ;
			}
			
			if (mcList)
			{
				mcList.addEventListener(ListEvent.INDEX_CHANGE, OnListItemSelectionChange, false, 0, true);
			}
		}

		protected function handleGesturePan( event : TransformGestureEvent ) : void
		{	
			var rowHeight : Number = mcItemRenderer1.height;
			var result : Object = CommonUtils.stagePanToRowScroll( _panYAccumulator, rowHeight, event );

			mcScrollbar.position -= result.outRowsToScroll;
			_panYAccumulator = result.outPanYAccumulator;
		}
		
		public function showWithData(data:Array):void
		{
			super.show();
			
			mcList.dataProvider = new DataProvider(data);
			mcList.validateNow();
			
			if (!_lastMoveWasMouse)
			{
				mcList.selectedIndex = 0;
			}
			
			registerMouseAndTouchEvents();
		}
		
		protected function OnListItemSelectionChange( event:ListEvent ):void
		{
			if (event.index == -1)
			{
				txtSelectionInfo.text = "";
			}
			else
			{
				txtSelectionInfo.htmlText = (mcList.getRendererAt(event.index) as InstalledDLCMItemRenderer).getDLCDescription();
			}
		}
		
		override public function hide():void
		{
			super.hide();
			
			unregisterMouseAndTouchEvents();
		}
		
		public function registerMouseAndTouchEvents():void
		{
			if (!_mouseEventsRegistered)
			{
				_mouseEventsRegistered = true;
				
				registerMouseEventsForItem(mcItemRenderer1);
				registerMouseEventsForItem(mcItemRenderer2);
				registerMouseEventsForItem(mcItemRenderer3);
				registerMouseEventsForItem(mcItemRenderer4);
				registerMouseEventsForItem(mcItemRenderer5);
				registerMouseEventsForItem(mcItemRenderer6);
				registerMouseEventsForItem(mcItemRenderer7);
				registerMouseEventsForItem(mcItemRenderer8);
				registerMouseEventsForItem(mcItemRenderer9);
				registerMouseEventsForItem(mcItemRenderer10);
				registerMouseEventsForItem(mcItemRenderer11);
				
				_panYAccumulator = 0;
				addEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan, false, 0, true );
				mcList.enableTouch( true );
			}
		}
		
		public function unregisterMouseAndTouchEvents():void
		{
			if (_mouseEventsRegistered)
			{
				_mouseEventsRegistered = false;
				
				unregisterMouseEventsForItem(mcItemRenderer1);
				unregisterMouseEventsForItem(mcItemRenderer2);
				unregisterMouseEventsForItem(mcItemRenderer3);
				unregisterMouseEventsForItem(mcItemRenderer4);
				unregisterMouseEventsForItem(mcItemRenderer5);
				unregisterMouseEventsForItem(mcItemRenderer6);
				unregisterMouseEventsForItem(mcItemRenderer7);
				unregisterMouseEventsForItem(mcItemRenderer8);
				unregisterMouseEventsForItem(mcItemRenderer9);
				unregisterMouseEventsForItem(mcItemRenderer10);
				unregisterMouseEventsForItem(mcItemRenderer11);
				
				_panYAccumulator = 0;
				mcList.enableTouch( false );
				removeEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan, false );
			}
		}
		
		protected function registerMouseEventsForItem(item:InstalledDLCMItemRenderer):void
		{
			item.addEventListener(MouseEvent.MOUSE_OVER, onItemMouseOver, false, 0, true);
			item.addEventListener(MouseEvent.MOUSE_OUT, onItemMouseOut, false, 0, true);
		}
		
		protected function unregisterMouseEventsForItem(item:InstalledDLCMItemRenderer):void
		{
			item.removeEventListener(MouseEvent.MOUSE_OVER, onItemMouseOver);
			item.removeEventListener(MouseEvent.MOUSE_OUT, onItemMouseOut);
		}
		
		protected function onItemMouseOver(event:MouseEvent):void
		{
			var currentTarget:InstalledDLCMItemRenderer = event.currentTarget as InstalledDLCMItemRenderer;
			
			_lastMouseOveredItem = mcList.getRenderers().indexOf(currentTarget);
			
			if (_lastMoveWasMouse)
			{
				mcList.selectedIndex = currentTarget.index;
			}
		}
		
		protected function onItemMouseOut(event:MouseEvent):void
		{
			_lastMouseOveredItem = -1;
			
			if (_lastMoveWasMouse)
			{
				mcList.selectedIndex = -1;
			}
		}
		
		override public function handleInputNavigate(event:InputEvent):void
		{
			if (!visible)
			{
				return;
			}
			
			var details:InputDetails = event.details;
			
			CommonUtils.convertWASDCodeToNavEquivalent(details);
				
			mcList.handleInput(event);
			
			if (!event.handled)
			{
				super.handleInputNavigate(event);
			}
		}
		
		private function handleScroll(e:Event) : void
		{
			mcList.validateNow();
			
			if (_lastMouseOveredItem != -1 && lastMoveWasMouse)
			{
				var currentTarget:InstalledDLCMItemRenderer  = mcList.getRendererAt(_lastMouseOveredItem) as InstalledDLCMItemRenderer;
				
				if (currentTarget)
				{
					mcList.selectedIndex = currentTarget.index;
					mcList.validateNow();
				}
			}
		}
	}
}