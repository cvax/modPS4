/***********************************************************************
/** Connected Page
/***********************************************************************
/** Copyright © 2026 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.startup_experience
{
    import scaleform.clik.core.UIComponent;
    import flash.text.TextField;
    import red.game.witcher3.controls.InputFeedbackButton;
    import red.core.events.GameEvent;
    import red.game.witcher3.data.KeyBindingData;
    import red.core.constants.KeyCode;
    import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.events.ButtonEvent;
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.ui.InputDetails;
    import scaleform.clik.constants.InputValue;
    import flash.events.Event;
    import flash.display.MovieClip;
    import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
    import flash.text.TextLineMetrics;
    import red.game.witcher3.utils.CommonUtils;
    import flash.geom.Point;

    public class ConnectedPage extends UIComponent
	{
        public var mcCDPRAccount : MovieClip;

        public var tfDescription : TextField;
        
        public var mcIcon1 : TextedIcon;
        public var mcIcon2 : TextedIcon;
        public var mcIcon3 : TextedIcon;
        public var mcIcon4 : TextedIcon;

        public var mcInputFeedbackPanel : ModuleInputFeedback;

        public var tfTitleA : TextField;
        public var tfTitleB : TextField;
        public var mcRarogUsername : MovieClip;

		public function ConnectedPage()
		{
			
		}

        override protected function configUI():void
        {
            super.configUI();

            mcInputFeedbackPanel.appendButton( 1, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_continue]]", true );
        }

        private function generateUserHtml( user : String ) : String
        {
            var userNameAndNumber : Array = user.split( "#" );
            var userHtml : String = "";
            if ( userNameAndNumber.length == 2 ) 
            {
                userHtml = 
                    "<font color ='#9B9076'>" + userNameAndNumber[0] + "</font>" + 
                    "<font color ='#675A48'>#</font>" + 
                    "<font color ='#675A48'>" + userNameAndNumber[1] + "</font>";
            }
            else
            {
                userHtml = 
                    "<font color ='#9B9076'>" + user + "</font>";
            }

            return userHtml;
        }

        private function layoutTitleLine() : void
        {
            //Use titleA as anchor
            var metrics : TextLineMetrics = tfTitleA.getLineMetrics(0);

            mcRarogUsername.x = tfTitleA.x + metrics.width + 8;
            
            var p:Point = new Point(0, 0);
            var lp:Point = mcRarogUsername.tfUserName.localToGlobal(p);
            metrics = mcRarogUsername.tfUserName.getLineMetrics(0);
            
            tfTitleB.x = lp.x + metrics.width;
        }

        public function setData(data:Object):void
        {
            mcCDPRAccount.tfText.htmlText = data.cdprAccountText;
            tfDescription.htmlText = data.desc;
            
            mcIcon1.setData(data.icons[0]);
            mcIcon2.setData(data.icons[1]);
            mcIcon3.setData(data.icons[2]);
            mcIcon4.setData(data.icons[3]);

            mcRarogUsername.tfUserName.htmlText = generateUserHtml( data.user );

            tfTitleA.text = data.title;
            var splitConnectedText : Array = tfTitleA.text.split( "{x}" );

            if ( splitConnectedText.length == 2 )
            {
                tfTitleA.text = splitConnectedText[0];
                tfTitleB.text = splitConnectedText[1];
            }
            else
            {
                tfTitleA.text = splitConnectedText[0];
                tfTitleB.text = "";
            }

            layoutTitleLine();

            trace( "ConnectedPage::setData : ", tfTitleA.text, data.desc, mcRarogUsername.tfUserName, mcRarogUsername.tfUserName.htmlText );
            
        }

        private function onContinue( event : Event = null ) : void
        {
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnContinue" ) );
        }

        protected function handleInputNavigate(event:InputEvent):void
		{	
            trace( "ConnectedPage::handleInputNavigate : ", event );

			var details:InputDetails = event.details;

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var hold:Boolean = details.value == InputValue.KEY_HOLD;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;

            if ((details.navEquivalent == NavigationCode.GAMEPAD_A && keyDown) || (details.code == KeyCode.E && keyUp))
            {
                onContinue();
                event.handled = true;
            }
		}
    }
}
