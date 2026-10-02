package red.game.witcher3.menus.mainmenu
{
    import flash.text.TextField;

    import scaleform.clik.events.InputEvent;
    import scaleform.clik.constants.InputValue;
    import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.core.UIComponent;
    import scaleform.clik.ui.InputDetails;

    import red.core.constants.KeyCode;
    import red.game.witcher3.controls.InputFeedbackButton;
    import red.game.witcher3.constants.EInputDeviceType;
    import red.game.witcher3.events.ControllerChangeEvent;
    import red.game.witcher3.managers.InputManager;
    
    public class AccountButtonPanel extends UIComponent
	{
        public var mcInputFeedbackButton : InputFeedbackButton;
        public var tfText : TextField;

        public function AccountButtonPanel()
        {
            
        }

        override protected function configUI() : void
        {
            super.configUI();

            tfText.htmlText = "[[panel_cdpr_account]]";
            setupInputFeedback();
            InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChange, false, 0, true);
        }

        private function handleControllerChange(event:ControllerChangeEvent):void
        {
            setupInputFeedback();
        }

        private function setupInputFeedback():void
        {
            var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;
            mcInputFeedbackButton.setDataFromStage( isSwitch2Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_R1, KeyCode.NUMBER_3 );
            mcInputFeedbackButton.clickable = false;
        }

        public function handleInputNavigate( event : InputEvent ) : Boolean 
        {
            var details:InputDetails = event.details;
            var keyUp:Boolean = (details.value == InputValue.KEY_UP);
            var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;

            if ( visible )
            {
                if ( keyUp && ( (details.code == KeyCode.NUMBER_3) ||
                    (isSwitch2Mouser && details.navEquivalent == NavigationCode.GAMEPAD_L1) ||
                    (!isSwitch2Mouser && details.navEquivalent == NavigationCode.GAMEPAD_R1) ) )
                {
                    return true;
                }
            }

            return false;
        }
    }
}