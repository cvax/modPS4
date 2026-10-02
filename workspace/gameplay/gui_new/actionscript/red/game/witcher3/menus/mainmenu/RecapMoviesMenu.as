/***********************************************************************
/** Common Main Menu class
/***********************************************************************
/** Copyright © 2013 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import flash.display.MovieClip;
	import flash.events.GesturePhase;
	import flash.events.TransformGestureEvent;
	import flash.events.GestureEvent;
	import flash.text.TextField;

	import red.core.CoreMenu;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.core.events.GestureEventEx;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.data.KeyBindingData;
	import red.game.witcher3.managers.InputManager;

	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;

	public class RecapMoviesMenu extends CoreMenu
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/

		public var btnSkip:InputFeedbackButton;
		public var mcLogoLoader:W3UILoader;
		public var tfSubtitles:TextField;

		public function RecapMoviesMenu()
		{
			super();
			SHOW_ANIM_OFFSET = 0;
			SHOW_ANIM_DURATION = 2;
		}

		override protected function get menuName():String
		{
			return "RecapMoviesMenu";
		}

		override protected function configUI():void
		{
			super.configUI();
			upToCloseEnabled = false;
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			stage.addEventListener( GestureEventEx.GESTURE_TAP, handleInputGestureTap );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'startup.movies.buttons.setup', [handleSetupButtons]));
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			tfSubtitles.htmlText = "";

			btnSkip.clickable = false;
			btnSkip.visible = false;
			btnSkip.validateNow();
		}

		protected function handleSetupButtons( gameData:Object, index:int ) : void
		{
			var dataList:Array = gameData as Array;
			var keyBindingData : KeyBindingData;
			keyBindingData = dataList[0] as KeyBindingData;

			if( keyBindingData )
			{
				btnSkip.clickable = false;
				btnSkip.visible = true;

				// var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
				// Keybinding data is coming from mainRecapMoviesMenu.ws !!
				btnSkip.setDataFromStage(keyBindingData.gamepad_navEquivalent, keyBindingData.keyboard_keyCode, keyBindingData.gamepad_keyCode);
				btnSkip.label = keyBindingData.label;
			}
			else
			{
				btnSkip.visible = false;
			}
		}
		
		public function setSubtitles( text : String ) : void
		{
			tfSubtitles.htmlText = text;
		}

		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled )
			{
				return;
			}

			if ( btnSkip.visible )
			{
				var details:InputDetails = event.details;
				var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
				var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

				if (keyPress && !event.handled )
				{
					switch(details.navEquivalent)
					{
						case NavigationCode.GAMEPAD_X :
						case NavigationCode.GAMEPAD_B :
							if ((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_B) ||		// B on switch
								(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X))		// X on other platforms
							{
								event.handled = true;
								dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSkipMovie' ) );
							}
							break;
					}
				}

				if (keyPress && !event.handled )
				{
					switch(details.code)
					{
						case KeyCode.SPACE :
						case KeyCode.ESCAPE :
							event.handled = true;
							dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSkipMovie' ) );
							break;
					}
				}
			}
			event.handled = true;
		}

		protected function handleInputGestureTap(event:GestureEvent):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSkipMovie' ) );
		}

		override protected function handleInputNavigate(event:InputEvent):void { }

		public function setGameLogoLanguage( show: Boolean, language : String ) : void
		{
			if ( mcLogoLoader )
			{
				mcLogoLoader.visible = show;
				if( show )
				{
					if (language != "RU" || language != "CZ" || language != "PL") // Other languages are not support (except english but since its default theres no point if'ing it out
					{
						language = "EN";
					}
					mcLogoLoader.source = "img://icons/Logos/WitcherLogo_" + language + ".png";
				}
			}
		}
	}
}
