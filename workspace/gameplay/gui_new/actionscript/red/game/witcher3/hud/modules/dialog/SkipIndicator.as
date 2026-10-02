package red.game.witcher3.hud.modules.dialog
{
	import flash.text.TextField;

	import red.core.constants.KeyCode;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.managers.InputManager;

	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;

	public class SkipIndicator extends UIComponent
	{
		public var btnSkip:InputFeedbackButton;
		private var inited:Boolean;
		
		public function SkipIndicator()
		{
			inited = false;
		}
		
		protected override function configUI():void
		{
			super.configUI();
			alpha = 0.0;
			setupData();
		}
		
		public function setupData():void
		{
			if (!inited)
			{
				var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

				btnSkip.clickable = false;
				btnSkip.label = "[[panel_button_dialogue_skip]]";
				btnSkip.setDataFromStage(isSwitchPlatform ? NavigationCode.GAMEPAD_B : NavigationCode.GAMEPAD_X, KeyCode.SPACE);
				btnSkip.validateNow();
				inited = true;
			}
		}
		
	}
}
