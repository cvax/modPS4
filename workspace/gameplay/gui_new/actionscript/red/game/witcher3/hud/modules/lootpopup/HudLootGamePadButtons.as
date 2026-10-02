package red.game.witcher3.hud.modules.lootpopup
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.W3GamepadButton;
	import red.game.witcher3.managers.InputManager;
	
	public class HudLootGamePadButtons extends MovieClip 
	{
		//>------------------------------------------------------------------------------------------------------------------
		// VARIABLES
		//-------------------------------------------------------------------------------------------------------------------
		public var btnTake					: W3GamepadButton;
		public var btnTakeAll				: W3GamepadButton;
		public var btnOptions				: W3GamepadButton;
		public var btnClose					: W3GamepadButton;
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function HudLootGamePadButtons() 
		{
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

			mouseEnabled = false;
			
			btnTake.mcIcon.gotoAndStop("enter-gamepad_A");
			if (isSwitchPlatform)
			{
				btnTakeAll.mcIcon.gotoAndStop("gamepad_X");
				btnOptions.mcIcon.gotoAndStop("gamepad_Y");
			}
			else
			{
				btnTakeAll.mcIcon.gotoAndStop("gamepad_Y");
				btnOptions.mcIcon.gotoAndStop("gamepad_X");
			}
			btnClose.mcIcon.gotoAndStop("escape-gamepad_B");
			
			btnTake.textField.htmlText = "[[panel_button_common_take]]";
			btnTakeAll.textField.htmlText = "[[panel_button_common_take_all]]";
			btnOptions.textField.htmlText = "[[panel_buton_common_more]]";
			btnClose.textField.htmlText = "[[panel_button_common_close]]";
		}
	}

}