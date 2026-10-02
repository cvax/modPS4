package red.game.witcher3.menus.glossary
{
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import red.core.CorePopup;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.MouseCursorComponent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.gfx.Extensions;
	import scaleform.clik.controls.UILoader;
	import red.game.witcher3.controls.W3UILoader;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import red.game.witcher3.menus.overlay.BookItemRenderer;
	import red.core.CoreMenu;
	import red.game.witcher3.controls.W3ScrollingList;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import scaleform.clik.events.ListEvent;
	import flash.text.TextField;
    import red.game.witcher3.menus.common_menu.TopBarNewGlossary;
	import red.game.witcher3.managers.InputFeedbackManager;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import flash.utils.setTimeout;
	import red.game.witcher3.events.ControllerChangeEvent;

	/**
	 * 
	 * @author Lilla Toma
	 * Sorry for anyone discovering this most useless menu
	 */
	public class GlossaryMainMenu extends CoreMenu
	{		
		//CONST

		//ART CLIPS
		public var mcTopBar : TopBarNewGlossary;
        public var mcMiddleBar : GlossaryMainTabController;

		var selectIndex : int = -1;

		public function GlossaryMainMenu()
		{
            super();
            _enableInputValidation = true;
			_loadAssets = false;
            _restrictDirectClosing = true;
			//_disableShowAnimation = true;
		}
		
		override protected function get menuName():String { return "GlossaryMainMenu" }
		override protected function configUI():void
		{
			super.configUI();
			setHasMenu(false);

			mcTopBar.elemClassName = "mcBotBarTabItemContainer";
			mcTopBar.MAX_HEIGHT = 60;

			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}

        public function setHasMenu(has:Boolean):void
        {
            mcTopBar.visible = true;
            mcMiddleBar.visible = false;

            mcTopBar.navigationEnabled = true;
            mcMiddleBar.navigationEnabled = false;
			showSelect(false);
        }

		private function showSelect(value : Boolean):void
		{
			if(value)
			{
				setTimeout(addSelectButton, 10);
			}
			else
			{
				setTimeout(removeSelectButton, 10);
			}
		}

		private function addSelectButton():void
		{
			selectIndex = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.ENTER, "panel_button_common_select", false)
			InputFeedbackManager.updateButtons(this);
		}

		private function removeSelectButton():void
		{
			if(selectIndex != -1)
			{
				InputFeedbackManager.removeButton(this, selectIndex);
				InputFeedbackManager.updateButtons(this);
				selectIndex = -1;
			}
		}

		override public function setControllerType(isGamePad:Boolean):void
		{
			super.setControllerType(isGamePad);
		}

		protected function handleCtrlChanged(event:ControllerChangeEvent):void
		{
		}

        override protected function handleInputNavigate(event:InputEvent):void
		{
			//trace("GFX <MenuCommon> handleInputNavigate  ", details.value, details.navEquivalent);
			
			//super.handleInput(event); // #J We don't want CoreMenu's behavior is MenuCommon
			var details:InputDetails = event.details;
			
			// Handle only down state to avoid jumping
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD; //#B should be also hold here
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
			
			if (!event.handled)
			{
				switch (details.navEquivalent)
				{
				case NavigationCode.GAMEPAD_B:
					if (keyDown)
					{
						hideAnimation();
					}
					break;
				}
			}
		}
		
	}
}
