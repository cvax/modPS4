/***********************************************************************
/** Installed mod preview object, thin, unreactive
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
    import flash.utils.setTimeout;

	import scaleform.clik.core.UIComponent;
    import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.constants.InputValue;

	import red.core.CoreMenu;	
	import red.core.events.GameEvent;
    import red.core.constants.KeyCode;

	import red.game.witcher3.controls.W3UILoader;
    import red.game.witcher3.controls.InputFeedbackButton;
    import red.game.witcher3.managers.InputManager;
    import red.game.witcher3.utils.CommonUtils;

	public class MoreSandwichPanel extends UIComponent
	{
        //CONSTS
        private static const PANEL_HORIZONTAL_PAD : Number = 50;
        private static const PANEL_VERTICAL_PAD : Number = 25;
        private static const PANEL_BUTTON_GAP : Number = 10;
        private static const ASSUMED_BUTTON_HEIGHT : Number = 40;

		//ART CLIPS
        public var mcWindow : MovieClip;

		public var mcReportButton : InputFeedbackButton;
        public var mcHideButton : InputFeedbackButton;
        public var mcHideAuthorButton : InputFeedbackButton;
        public var mcCancelButton : InputFeedbackButton;

        //VARS
        private var cachedData:Object;
        private var ignoresInput : Boolean = false;


		public function MoreSandwichPanel()
		{
			super();
		}

		protected function get menuName():String { return "ModMenu"; }
		override protected function configUI():void
		{
			super.configUI();
            mcReportButton.addEventListener(ButtonEvent.PRESS, onReportPressed, false, 0, false);
            mcHideButton.addEventListener(ButtonEvent.PRESS, onHidePressed, false, 0, false);
            mcHideAuthorButton.addEventListener(ButtonEvent.PRESS, onHideAuthorPressed, false, 0, false);
            mcCancelButton.addEventListener(ButtonEvent.PRESS, onCancelPressed, false, 0, false);
		}

        private function refreshInputIn(ms:int)
        {
            setTimeout(function(){
				trace("GFX Sandwich Panel refreshing input");
				ignoresInput = false;
			}, ms);
        }

        public function setupButtons(data:Object) : void
        {
            cachedData = data;
            ignoresInput = true;
            refreshInputIn(100);

            var subscribed : Boolean = data.subscribed;
            var hideallString : String = CommonUtils.getLocalization("panel_mods_hide_all");
            hideallString = hideallString.replace("{x}", data.author);
            var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

            mcReportButton.visible = true;
			mcReportButton.clickable = true;
			mcReportButton.label = "[[panel_mods_report]]";
			mcReportButton.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.R);
			mcReportButton.validateNow();

            mcHideButton.visible = true;
			mcHideButton.clickable = true;
            if(subscribed)
			    mcHideButton.label = "[[panel_mods_hide_uninstall]]";
            else
                mcHideButton.label = "[[panel_mods_hide]]";
			mcHideButton.setDataFromStage(isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, KeyCode.T);
			mcHideButton.validateNow();

            mcHideAuthorButton.visible = true;
			mcHideAuthorButton.clickable = true;
			mcHideAuthorButton.label = hideallString;
			mcHideAuthorButton.setDataFromStage(isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X, KeyCode.F);
			mcHideAuthorButton.validateNow();

            mcCancelButton.visible = true;
			mcCancelButton.clickable = true;
			mcCancelButton.label = "[[panel_common_cancel]]";
			mcCancelButton.setDataFromStage(NavigationCode.GAMEPAD_B, KeyCode.ESCAPE);
			mcCancelButton.validateNow();

            mcReportButton.x = mcWindow.x + (mcWindow.width - mcReportButton.getViewWidth()) / 2;
            mcHideButton.x = mcWindow.x + (mcWindow.width - mcHideButton.getViewWidth()) / 2;
            mcHideAuthorButton.x = mcWindow.x + (mcWindow.width - mcHideAuthorButton.getViewWidth()) / 2;
            mcCancelButton.x = mcWindow.x + (mcWindow.width - mcCancelButton.getViewWidth()) / 2;

            var longest = Math.max(mcReportButton.getViewWidth(), mcHideButton.getViewWidth());
            longest = Math.max(longest, mcHideAuthorButton.getViewWidth());
            longest = Math.max(longest, mcCancelButton.getViewWidth());

            resizeBgWidth(longest + PANEL_HORIZONTAL_PAD);
            resizeBgHeight(4 * ASSUMED_BUTTON_HEIGHT + 3 * PANEL_BUTTON_GAP + PANEL_VERTICAL_PAD);
            repositionButtonsVertically();
        }

        public override function handleInput(event:InputEvent):void
        {
            var details:InputDetails = event.details;

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var hold:Boolean = details.value == InputValue.KEY_HOLD;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
            var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

            if(ignoresInput || event.handled)
                return;

            if (keyDown)
            {
                switch (details.navEquivalent)
                {
                    case NavigationCode.GAMEPAD_A:
                        onReport();
                        event.handled = true;
                        break;
                    case NavigationCode.GAMEPAD_Y:
                    case NavigationCode.GAMEPAD_X:
                        if ((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X) ||	// X on switch
                            (!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y))	// Y on all other platforms
                        {
                            onHide();
                            event.handled = true;
                        }
                        if ((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y) ||	// Y on switch
                            (!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X))	// X on all other platforms
                        {
                            onHideAll();
                            event.handled = true;
                        }
                        break;
                    case NavigationCode.GAMEPAD_B:
                        if (details.code != KeyCode.ESCAPE)
                        {
                            onCancel();
                            event.handled = true;
                        }
                        break;
                    default:
                        break;
                }
            }

			if (keyUp)
			{
				if(details.code == KeyCode.R)
				{
					onReport();
					event.handled = true;
				}
				else if (details.code == KeyCode.T)
				{
					onHide();
					event.handled = true;
				}
				else if (details.code == KeyCode.ESCAPE)
				{
					onCancel();
					event.handled = true;
				}
				else if (details.code == KeyCode.F)
				{
                    onHideAll();
                    event.handled = true;
				}
			}
        }

        public function onReportPressed(event:ButtonEvent):void
        {
            onReport();
        }

        public function onHidePressed(event:ButtonEvent):void
        {
            onHide();
        }

        public function onHideAuthorPressed(event:ButtonEvent):void
        {
            onHideAll();
        }

        public function onCancelPressed(event:ButtonEvent):void
        {
            onCancel();
        }

        public function onReport():void
        {
            onCancel();
            ModMenu(parent).requestReportMod(cachedData.modid, cachedData.modName);
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnReportMod" ) );
        }

        public function onHide():void
        {
            onCancel();
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnHideMod", [cachedData.modid] ) );
        }

        public function onHideAll():void
        {
            onCancel();
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnHideAuthor", [cachedData.modid] ) );
        }

        public function onCancel():void
        {
            ModMenu(parent).closeSandwichPanel();
        }

        public function resizeBgWidth(newWidth:Number)
        {
            var oldWidth : Number = mcWindow.width;

            mcWindow.width = newWidth;
            mcWindow.x += (oldWidth - newWidth) / 2;
        }

        public function resizeBgHeight(newHeight:Number)
        {
            var oldHeight : Number = mcWindow.height;

            mcWindow.height = newHeight;
            mcWindow.y += (oldHeight - newHeight) / 2;
        }

        public function repositionButtonsVertically():void
        {
            var y = mcWindow.y + PANEL_VERTICAL_PAD / 2 + ASSUMED_BUTTON_HEIGHT / 2;

            mcReportButton.y = y;
            y += ASSUMED_BUTTON_HEIGHT + PANEL_BUTTON_GAP;

            mcHideButton.y = y;
            y += ASSUMED_BUTTON_HEIGHT + PANEL_BUTTON_GAP;

            mcHideAuthorButton.y = y;
            y += ASSUMED_BUTTON_HEIGHT + PANEL_BUTTON_GAP;

            mcCancelButton.y = y;
        }

    }
}