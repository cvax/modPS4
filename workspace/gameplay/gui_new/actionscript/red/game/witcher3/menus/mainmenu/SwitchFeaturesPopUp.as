package red.game.witcher3.menus.mainmenu
{
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ButtonEvent;

	import flash.events.Event;
	import flash.events.GestureEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;

	import red.core.constants.KeyCode;
	import red.core.events.GestureEventEx;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.ConditionalButton;
	import red.game.witcher3.constants.PlatformType;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.W3VideoObject;
	import red.game.witcher3.menus.common_menu.MenuHubTabListItem;
	import red.game.witcher3.menus.mainmenu.PatchNotesInfoBlock;
   
	public class SwitchFeaturesPopUp extends UIComponent
    {   
		public static const switchFeatureCircularTabsEnabled 	: 	Boolean = true;
		public static const maxSwitchFeatureTabIndex			:	int = 3;

		public var isSwitchFeaturesPopUpOpen	:	Boolean = true;
		
		private var currentSwitchFeatureTabIndex		:	int;
		private var currentSwitchFeatureTabName			:	String;		

		public var tfSwitchFeatureDescription			: 	TextField;
		public var tfSwitchFeatureTitle					: 	TextField;
		public var tfSwitchFeatureDescriptionTitle		: 	TextField;
		public var tfSwitchFeatureClose					: 	TextField;

		public var mcInputFeedbackB						:	InputFeedbackButton;
		public var mcInputFeedbackLeftShoulder			:	InputFeedbackButton;
		public var mcInputFeedbackRightShoulder			:	InputFeedbackButton;
		public var mcLeftPCButton						:	ConditionalButton;
        public var mcRightPCButton						:	ConditionalButton;

		public var mcSwitchImage						:	MovieClip;

		public var mcSwitchTabListItem1					:	MenuHubTabListItem;
		public var mcSwitchTabListItem2					:	MenuHubTabListItem;
		public var mcSwitchTabListItem3					:	MenuHubTabListItem;
		public var mcSwitchTabListItem4					:	MenuHubTabListItem;

		public var _lastMouseOvereSwitchFeatureItem		:	MenuHubTabListItem;
		public var switchFeatureTabList 				:	Vector.<MenuHubTabListItem>;

		public var	mcVideoObject	 					: W3VideoObject;
		public var	topmenu_nameList	 				: Array;

        public function SwitchFeaturesPopUp()
		{
			super();
		}

		override protected function configUI():void
		{
			super.configUI();

            closeSwitchFeaturePopUpMenu();

			tfSwitchFeatureTitle.htmlText = "[[menu_panel_console_features_switch2_title]]";
			tfSwitchFeatureClose.htmlText = "[[panel_button_common_close]]";

			if (mcLeftPCButton)
			{
				mcLeftPCButton.visible = true;
				mcLeftPCButton.addEventListener( ButtonEvent.PRESS, openPreviousSwitchFeatureTab, false, 0, true );
				mcLeftPCButton.addEventListener( GestureEventEx.GESTURE_TAP, inputFeedbackLeftShoulderTouch, false, 0, true );
				mcLeftPCButton.showOnSwitch2Mouser = true;
			}
			if (mcRightPCButton)
			{
				mcRightPCButton.visible = true;
				mcRightPCButton.addEventListener( ButtonEvent.PRESS, openNextSwitchFeatureTab, false, 0, true );
				mcRightPCButton.addEventListener( GestureEventEx.GESTURE_TAP, inputFeedbackRightShoulderTouch, false, 0, true );
				mcRightPCButton.showOnSwitch2Mouser = true;
			}

			if (mcInputFeedbackLeftShoulder)
			{
				mcInputFeedbackLeftShoulder.setDataFromStage( NavigationCode.GAMEPAD_L1, -1 );
				mcInputFeedbackLeftShoulder.addEventListener( GestureEventEx.GESTURE_TAP, inputFeedbackLeftShoulderTouch, false, 0, true );
				mcInputFeedbackLeftShoulder.showKeyboardIconOnSwitch2Mouser(true);
			}
			if (mcInputFeedbackRightShoulder)
			{
				mcInputFeedbackRightShoulder.setDataFromStage( NavigationCode.GAMEPAD_R1, -1 );
				mcInputFeedbackRightShoulder.addEventListener( GestureEventEx.GESTURE_TAP, inputFeedbackRightShoulderTouch, false, 0, true );
				mcInputFeedbackRightShoulder.showKeyboardIconOnSwitch2Mouser(true);
			}
			if (mcInputFeedbackB)
			{
				mcInputFeedbackB.setDataFromStage( NavigationCode.GAMEPAD_B, -1 );
				mcInputFeedbackB.addEventListener( ButtonEvent.PRESS, closeSwitchFeaturePopUpMenu, false, 0, true );
				mcInputFeedbackB.addEventListener( GestureEventEx.GESTURE_TAP, inputFeedbackBTouch, false, 0, true );
			}

			setupSwitchFeatureTabContainer();

			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
		}

		private function handleControllerChange(event:ControllerChangeEvent):void
		{
			tfSwitchFeatureClose.visible = event.isGamepad;
		}

		public function setupSwitchFeatureTabContainer():void
		{
			switchFeatureTabList = new Vector.<MenuHubTabListItem>();

			switchFeatureTabList.push(mcSwitchTabListItem1);
			switchFeatureTabList.push(mcSwitchTabListItem2);
			switchFeatureTabList.push(mcSwitchTabListItem3);
			switchFeatureTabList.push(mcSwitchTabListItem4);

			mcSwitchTabListItem1.isSmallTab = true;
			mcSwitchTabListItem2.isSmallTab = true;
			mcSwitchTabListItem3.isSmallTab = true;
			mcSwitchTabListItem4.isSmallTab = true;

			mcSwitchTabListItem1.noSafeUpperCase = true;
			mcSwitchTabListItem2.noSafeUpperCase = true;
			mcSwitchTabListItem3.noSafeUpperCase = true;
			mcSwitchTabListItem4.noSafeUpperCase = true;

			for (var i:int = 0; i < switchFeatureTabList.length; i++)
			{
				addToSwitchFeatureListContainer_Item(switchFeatureTabList[i]);
			}

			currentSwitchFeatureTabIndex	=	0;

			mcSwitchTabListItem1.addEventListener( GestureEventEx.GESTURE_TAP, switchTabListItem1Touch, false, 0, true );
			mcSwitchTabListItem2.addEventListener( GestureEventEx.GESTURE_TAP, switchTabListItem2Touch, false, 0, true );
			mcSwitchTabListItem3.addEventListener( GestureEventEx.GESTURE_TAP, switchTabListItem3Touch, false, 0, true );
			mcSwitchTabListItem4.addEventListener( GestureEventEx.GESTURE_TAP, switchTabListItem4Touch, false, 0, true );
		}

		public function switchTabListItem1Touch( event : GestureEvent ):void
		{
			selectSwitchFeatureTab(0);
		}

		public function switchTabListItem2Touch( event : GestureEvent ):void
		{
			selectSwitchFeatureTab(1);
		}

		public function switchTabListItem3Touch( event : GestureEvent ):void
		{
			selectSwitchFeatureTab(2);
		}

		public function switchTabListItem4Touch( event : GestureEvent ):void
		{
			selectSwitchFeatureTab(3);
		}

		public function inputFeedbackBTouch( event : GestureEvent ):void
		{
			closeSwitchFeaturePopUpMenu();
		}

		public function inputFeedbackLeftShoulderTouch( event : GestureEvent ):void
		{
			openPreviousSwitchFeatureTab();
		}

		public function inputFeedbackRightShoulderTouch( event : GestureEvent ):void
		{
			openNextSwitchFeatureTab();
		}

		public function openSwitchFeaturePopUpMenu():void
		{
			if (isSwitchFeaturesPopUpOpen)
			{
				return;
			}

			isSwitchFeaturesPopUpOpen = true;
			this.visible = true;

			UpdateSwitchFeatureTopMenu();

			// default tab reset (optional)
			currentSwitchFeatureTabIndex	=	0;
			selectSwitchFeatureTab(currentSwitchFeatureTabIndex);
		}

		public function closeSwitchFeaturePopUpMenu():void
		{
			if (!isSwitchFeaturesPopUpOpen)
			{
				return;
			}

			isSwitchFeaturesPopUpOpen = false;

			this.visible = false;		
		}

		public function fillDataSwitchFeatureTabs(nameList:Array):void
		{
			topmenu_nameList = nameList;
			UpdateSwitchFeatureTopMenu();
		}

		public function UpdateSwitchFeatureTopMenu()
		{
			if(topmenu_nameList && topmenu_nameList.length > 3)
			{
				topmenu_nameList[0].label = "[[menu_panel_console_features_gyroscope_title]]";
				topmenu_nameList[1].label = "[[menu_panel_console_features_motionpatterns_title]]";
				topmenu_nameList[2].label = "[[menu_panel_console_features_mouser_title]]";
				topmenu_nameList[3].label = "[[menu_panel_console_features_touch_title]]";

				mcSwitchTabListItem1.setData(topmenu_nameList[0]);
				mcSwitchTabListItem2.setData(topmenu_nameList[1]);
				mcSwitchTabListItem3.setData(topmenu_nameList[2]);
				mcSwitchTabListItem4.setData(topmenu_nameList[3]);
			}
		}

		public function addToSwitchFeatureListContainer_Item(component:MovieClip):void
		{
			if (component)
			{
				component.addEventListener(MouseEvent.CLICK, onSwitchFeatureTabItemClicked, false, 0, true);
				component.addEventListener(MouseEvent.MOUSE_OVER, onSwitchFeatureTabItemMouseOver, false, 0, true);
				component.addEventListener(MouseEvent.MOUSE_OUT, onSwitchFeatureTabItemMouseOut, false, 0, true);
			}
		}

		public function onSwitchFeatureTabItemMouseOver(event:MouseEvent):void
		{
			var currentTab =event.currentTarget as MenuHubTabListItem;

			if(_lastMouseOvereSwitchFeatureItem!=currentTab)
			{

				_lastMouseOvereSwitchFeatureItem = event.currentTarget as MenuHubTabListItem;

				if (!InputManager.getInstance().isMouse())
				{
					currentTarget.selected = true;
					return;
				}

				event.stopImmediatePropagation();
				var currentTarget:MenuHubTabListItem = event.currentTarget as MenuHubTabListItem;
			}
		}

		public function onSwitchFeatureTabItemMouseOut(event:MouseEvent):void
		{
			var currentTarget:MenuHubTabListItem = event.currentTarget as MenuHubTabListItem;

			if(currentTarget.name == currentSwitchFeatureTabName) {
				currentTarget.selected = true;
			}
			else
			{
				currentTarget.selected = false;
			}
		}

		public function onSwitchFeatureTabItemClicked(event:MouseEvent):void
		{
			if (!InputManager.getInstance().isMouse())
			{
				return;
			}

			event.stopImmediatePropagation();
			var currentTarget:MenuHubTabListItem = event.currentTarget as MenuHubTabListItem;
			if (currentTarget)
			{
				currentSwitchFeatureTabName = currentTarget.name; // <-- hacky solution for storing the tab button that we are on
			}
			var index:int = switchFeatureTabList.indexOf(currentTarget);

			if (index != -1)
			{
			selectSwitchFeatureTab(index);
			}
		}

		public function openPreviousSwitchFeatureTab():void
		{
			var index:int = currentSwitchFeatureTabIndex;

			if (--index < 0)
			{
				index = switchFeatureCircularTabsEnabled
				? maxSwitchFeatureTabIndex
				: 0;
			}
			selectSwitchFeatureTab(index);
		}

		public function openNextSwitchFeatureTab():void
		{
			var index:int  = currentSwitchFeatureTabIndex;

			if (++index > maxSwitchFeatureTabIndex)
			{
				index = switchFeatureCircularTabsEnabled
				? 0
				: maxSwitchFeatureTabIndex;
			}

			selectSwitchFeatureTab(index);
		}

		public function selectSwitchFeatureTab(index:int):void
		{
			currentSwitchFeatureTabIndex = index;
			selectCorrectSwitchFeatureTabButton(index);
			currentSwitchFeatureTabName=switchFeatureTabList[index].name;

			if(tfSwitchFeatureDescription)
			{
				switch(index)
				{
					// gyro
					case 0:
						tfSwitchFeatureDescriptionTitle.htmlText= "[[menu_panel_console_features_gyroscope_title]]";
						tfSwitchFeatureDescription.htmlText = "[[menu_panel_console_features_gyroscope_description]]";
						break;

					// motion
					case 1:
						tfSwitchFeatureDescriptionTitle.htmlText= "[[menu_panel_console_features_motionpatterns_title]]";
						tfSwitchFeatureDescription.htmlText ="[[menu_panel_console_features_motionpatterns_description]]";
						break;

					// mouse
					case 2:
						tfSwitchFeatureDescriptionTitle.htmlText= "[[menu_panel_console_features_mouser_title]]";
						tfSwitchFeatureDescription.htmlText = "[[menu_panel_console_features_mouser_description]]";
						break;

					// touch
					case 3:
						tfSwitchFeatureDescriptionTitle.htmlText= "[[menu_panel_console_features_touch_title]]";
						tfSwitchFeatureDescription.htmlText ="[[menu_panel_console_features_touch_description]]";
						break;
				}
			}
			
			if ( tfSwitchFeatureDescriptionTitle.numLines > 1 )
			{
				tfSwitchFeatureDescriptionTitle.y = 275;
			}
			else
			{
				tfSwitchFeatureDescriptionTitle.y = 300;
			}
			
			loadCorrectSwitchAnim(index);
		}

		public function loadCorrectSwitchAnim(index:int)
		 {	
			switch(index)
			{
				//gyro
				case 0:
					StartLoadSwitchAnim("gyro_aiming_bomb");
					break;

				//motion
					case 1:
					StartLoadSwitchAnim("horse_summon");

					break;
				//mouse
				case 2:
					StartLoadSwitchAnim("mouser");		
					break;

				//touch
				case 3:
					StartLoadSwitchAnim("touch_screen_swipe_pinch");	
					break;
			}
		}

		public function selectCorrectSwitchFeatureTabButton(index:int)
		{
			for (var i:int = 0; i < switchFeatureTabList.length; i++)
			{
				switchFeatureTabList[i].selected = false;
			}

			if (index >= 0 && index < switchFeatureTabList.length)
			{
				switchFeatureTabList[index].selected = true;
			}
		}

		private function StartLoadSwitchAnim( name : String)
		{			
			if(mcVideoObject)
			{		
				mcVideoObject.visible = true;
				mcVideoObject.PlayVideo("movies\\gui\\embedded\\tutorials\\switch2\\" + name + ".usm", true);							
			}
			else
			{
				trace( "DebugTutorial GlossaryTutorial: NOMC:"+ name );
			}		
			
		}
	}
}