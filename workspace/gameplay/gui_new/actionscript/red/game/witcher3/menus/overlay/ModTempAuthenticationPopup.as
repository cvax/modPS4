package red.game.witcher3.menus.overlay
{
	import flash.display.MovieClip;
	import flash.text.TextField;

	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.constants.InputValue;

	import red.core.events.GameEvent;
	import red.core.constants.KeyCode;

	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.menus.modmenu.W3TextInput;
	import red.game.witcher3.menus.modmenu.W3TextInputEvent;
	import red.game.witcher3.menus.modmenu.TextInputManager;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.data.KeyBindingData;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	public class ModTempAuthenticationPopup extends BasePopup
	{
		private static const HEIGHT_PADDING: Number = 10;
		private static const INPUT_PADDING: Number = 10;
		private static const FINAL_HEIGHT_PADDING: Number = 40;
		
		public var txtMessage:TextField;
		public var txtTitle:TextField;
		public var textBorder:MovieClip;
		private var curHeight:Number;
		public var mcHeader: MovieClip;
		public var mcInputBackground: MovieClip;
		public var mcBackground: MovieClip;
		public var mcTextInput : W3TextInput;
		public var mcManager : TextInputManager;

		private var lastGamepad : Boolean = false;
		private var cachedButtonsList : Array;

		override protected function configUI():void
		{
			super.configUI();
			
			mcTextInput.setupInputForDelegate();
			mcTextInput.addEventListener(W3TextInputEvent.TEXT_CHANGED, onTextChanged, false, 0, true);
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);

			mcTextInput.textInputManager = mcManager;

			mcTextInput.focused = 0;
			stage.focus = parent;

			mcTextInput.skipKeys.push(KeyCode.DOWN);
			mcTextInput.skipKeys.push(KeyCode.UP);
			mcTextInput.skipGamepadKeys.push(NavigationCode.GAMEPAD_A);
			mcTextInput.skipGamepadKeys.push(NavigationCode.GAMEPAD_B);
		}

		public function onModTempUpdate(data:Object)
        {
            _data = data;
			populateData();
			trace("GFX ModTemp populate data");
        }

		override protected function populateData():void
		{
			super.populateData();
			
			txtMessage.htmlText = _data.TextContent;
			txtMessage.height = txtMessage.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			txtTitle.htmlText = CommonUtils.toUpperCaseSafe( _data.TextTitle );
			if (txtTitle.text == "")
			{
				txtMessage.y = 16.85;
				mcHeader.visible = false;
			}
			curHeight = txtMessage.y + txtMessage.textHeight + HEIGHT_PADDING;
			mcBackground.height = curHeight + FINAL_HEIGHT_PADDING;

			cachedButtonsList = _data.ButtonsList;
			mcInpuFeedback.handleSetupButtons(cachedButtonsList);
			onResizeInputBg();

			if(_data.Email)
			{
				mcTextInput.consoleTitle = "[[textinput_email]]";
				mcTextInput.consoleDefault = "[[textinput_email_default]]";
				mcTextInput.inputScope = 1;
			}
			else
			{
				mcTextInput.consoleTitle = "[[textinput_code]]";
				mcTextInput.consoleDefault = "[[textinput_code_default]]";
				mcTextInput.inputScope = 0;
			}
			mcTextInput.resetText();
		}

		protected function onResizeInputBg():void
		{
			var gamepad : Boolean = InputManager.getInstance().isGamepad();
			if(gamepad && !lastGamepad)
			{
				var butArray : Array = [];
				for(var i : int = 0; i < cachedButtonsList.length; i++)
					butArray.push(cachedButtonsList[i]);

				var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
				var newButton : KeyBindingData = new KeyBindingData();
				newButton["gamepad_navEquivalent"] = isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X;
				newButton["keyboard_keyCode"] = 75;
				newButton["label"] = "[[panel_enter_text]]";

				butArray.push( newButton );
				mcInpuFeedback.clearAllButtons();
				mcInpuFeedback.handleSetupButtons(butArray);
				lastGamepad = true;
			}
			else if (!gamepad && lastGamepad)
			{
				mcInpuFeedback.clearAllButtons();
				mcInpuFeedback.handleSetupButtons(cachedButtonsList);
				lastGamepad = false;
			}
			mcInputBackground.y  = mcBackground.height - mcInputBackground.height / 2;
			mcInpuFeedback.y = mcInputBackground.y + mcInputBackground.height / 2;
			mcInputBackground.x = mcBackground.width / 2;
			mcInputBackground.width = mcInpuFeedback.buttonsContainer.width + INPUT_PADDING;
		}

		protected function onTextChanged(event:W3TextInputEvent):void
		{
			var text : String = event.text;
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSetText', [text] ) );
		}

		override public function handleInput(event:InputEvent):void
		{
			if (event.handled)
			{
				return;
			}
			onResizeInputBg();
			mcTextInput.focused = 1;
			stage.focus = mcTextInput;
			
			var details : InputDetails = event.details;
			var navEqv : String = details.navEquivalent;
			
			super.handleInput(event);
		}
	}

}