package red.game.witcher3.menus.worldmap
{
	import flash.display.MovieClip;
	import flash.events.GestureEvent;
	import flash.events.MouseEvent;

	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	
	import red.core.constants.KeyCode;
	import red.core.events.GestureEventEx;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.managers.InputManager;
		
	public class UserPinPanel extends UIComponent
	{
		public var mcUserPin1:UserPinItemRenderer;
		public var mcUserPin2:UserPinItemRenderer;
		public var mcUserPin3:UserPinItemRenderer;
		public var mcUserPin4:UserPinItemRenderer;
		public var mcUserPin5:UserPinItemRenderer;
		public var mcUserPin6:UserPinItemRenderer;
		public var mcUserPinsList:W3ScrollingList;
		public var btnClose:InputFeedbackButton;
		
		public var enableUserPinPanel:Function;
		public var setUserMapPin:Function;

		private var selectedIndex : int;

		public function UserPinPanel()
		{
			selectedIndex = -1;
		}
		
		override protected function configUI():void
		{
			super.configUI();

			mcUserPinsList.focusable = true;
			mcUserPinsList.dataProvider = new DataProvider([ { pinId:"User2" }, { pinId:"User3" }, { pinId:"User4" }, { pinId:"User5" }, { pinId:"User6" }, { pinId:"User7" } ]);	
			mcUserPinsList.validateNow();
			mcUserPinsList.addEventListener(ListEvent.ITEM_PRESS, handleUserPinsPress, false, 0, true);
			mcUserPinsList.addEventListener(ListEvent.INDEX_CHANGE, handleSelectionChange, false, 0 , true);
			
			btnClose.clickable = true;
			btnClose.label = "[[panel_common_cancel]]";
			btnClose.setDataFromStage( "", KeyCode.ESCAPE );				
			btnClose.visible = true;
			btnClose.addEventListener( ButtonEvent.CLICK, handleCloseButtonClicked, false, 0, true );
			btnClose.validateNow();
			
			mcUserPinsList.bSkipFocusCheck = true;
			mcUserPinsList.enableTouch( true, true, false );
			mcUserPinsList.focusable = false;
			mcUserPinsList.selectOnOver = true;

			selectedIndex = -1
		}

		protected function handleSelectionChange( event:ListEvent ):void
		{
			selectedIndex = event.index;
		}
		
		override public function handleInput( event:InputEvent ):void
		{
			super.handleInput( event );
			
			if (event.handled)
			{
				return;
			}

			var details:InputDetails = event.details;
			var keyUp : Boolean = ( details.value == InputValue.KEY_UP );
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
			
			if ((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y) ||		// Y on switch
				(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X))		// X on other platforms
			{
				if ( keyUp )
				{
					closePanelAndSetUserPin();
					event.handled = true;
				}
			}
			else if (details.navEquivalent == NavigationCode.GAMEPAD_B ) 
			{
				if ( keyUp )
				{
					enableUserPinPanel( false );
					event.handled = true;
				}
			}
			else
			{
				mcUserPinsList.handleInput(event);	
			}
		}
		
		private function handleUserPinsPress(event:ListEvent):void
		{
			selectedIndex = event.index;

			closePanelAndSetUserPin();
		}
		
		public function handleCloseButtonClicked( event : ButtonEvent )
		{
			enableUserPinPanel( false );
		}
		
		private function closePanelAndSetUserPin()
		{
			if ( selectedIndex == -1 )
			{
				selectedIndex = mcUserPinsList.selectedIndex;
			}

			if ( selectedIndex != -1 )
			{
				setUserMapPin( selectedIndex, true );
			}

			enableUserPinPanel( false );
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if ( value )
			{
				selectedIndex = -1;
				mcUserPinsList.selectedIndex = 0;
			}
		}
	}
}
