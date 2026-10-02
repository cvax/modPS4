/***********************************************************************
/** Main Achivments Sub Menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.events.ListEvent;
	import flash.events.TransformGestureEvent;
	import flash.events.GestureEvent;
	import red.core.events.GestureEventEx;
	import red.game.witcher3.utils.CommonUtils;
	import flash.utils.setTimeout;

	public class MainDbgStartQuestSubMenu extends MainSubMenu
	{
		private var _panYAccumulator : Number;
		private var _selectedIndex : int;
		
		public function MainDbgStartQuestSubMenu()
		{
			dataBindingKey = "mainmenu.quests.entries";

			_panYAccumulator = 0;
			_selectedIndex = -1;
			mcMenuList.enableTouch( true, true, false );
			mcMenuList.addEventListener( ListEvent.INDEX_CHANGE, onItemSelected, false, 0, true );
			addEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan, false, 0, true );
		}

		protected function handleGesturePan( event : TransformGestureEvent ) : void
		{	
			var rowHeight : Number = mcMenuListItem1.height;
			var result : Object = CommonUtils.stagePanToRowScroll( _panYAccumulator, rowHeight, event );

			mcScrollbar.position -= result.outRowsToScroll;
			_panYAccumulator = result.outPanYAccumulator;
		}

		override protected function get menuName():String
		{
			return "MainDbgStartQuestMenu";
		}

		override protected function closeMenu():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBack' ) );
		}

		protected function onItemTap( event : GestureEvent ) : void
		{	
			if ( _selectedIndex >= 0 )
			{
				var renderer : BaseListItem = mcMenuList.getRendererAt( _selectedIndex, mcMenuList.scrollPosition ) as BaseListItem;
				if ( renderer )
				{
					var hitTestResult : Boolean = renderer.hitTestPoint( event.stageX, event.stageY );
					if ( hitTestResult )
					{
						trace( "MainDbgStartQuestSubMenu::onItemTap - start quest : ", renderer.data.tag );
						dispatchEvent( new GameEvent( GameEvent.CALL, 'OnStartQuest', [ renderer.data.tag ] ) );
					}
				}
			}
		}

		private function addTapListener() : void
		{
			addEventListener( GestureEventEx.GESTURE_TAP, onItemTap, false, 0, true );
			addEventListener( GestureEventEx.GESTURE_DOUBLE_TAP, onItemTap, false, 0, true );
		}

		protected function onItemSelected( event:ListEvent ):void
		{
			//WARN : cant add Tap listener directly to the ListItemRenderer, since it will be reused on list scroll. 
			//Used selected index and hit detection instead.
			if (_selectedIndex != event.index )
			{
				removeEventListener( GestureEventEx.GESTURE_TAP, onItemTap, false );
				removeEventListener( GestureEventEx.GESTURE_DOUBLE_TAP, onItemTap, false );
				//Delay the event listener registration, to avoid triggering immediately
				setTimeout( addTapListener, 0 );
			}

			_selectedIndex = event.index;
		}

		private function onItemClicked( event : ListEvent ):void
		{
			var renderer : BaseListItem =  mcMenuList.getRendererAt( event.index, mcMenuList.scrollPosition ) as BaseListItem;
			if(renderer)
			{
				trace( "MainDbgStartQuestSubMenu::onItemClicked - start quest : ", renderer.data.tag );
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnStartQuest', [ renderer.data.tag ] ) );
			}
		}
	}
}
