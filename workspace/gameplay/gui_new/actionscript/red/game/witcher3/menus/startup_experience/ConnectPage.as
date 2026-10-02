/***********************************************************************
/** Connect Page
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
    import red.game.witcher3.constants.PlatformType;
    import red.game.witcher3.managers.InputManager;
    import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.events.ButtonEvent;
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.ui.InputDetails;
    import scaleform.clik.constants.InputValue;
    import flash.events.Event;
    import flash.utils.getDefinitionByName;
    import flash.filters.BlurFilter;
    import flash.filters.BitmapFilterQuality;
    import flash.display.MovieClip;
    import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
    import red.core.events.GestureEventEx;

    public class ConnectPage extends UIComponent
	{
        public var mcCDPRAccount : MovieClip;
        public var tfTitle : TextField;

        public var mcIcon1 : TextedIcon;
        public var mcIcon2 : TextedIcon;
        public var mcIcon3 : TextedIcon;
        public var mcIcon4 : TextedIcon;

        public var mcInputFeedbackPanel : ModuleInputFeedback;

        private var mcQrPanel : QrPanel;
        private var mcLoadingSpinnerPanel : MovieClip;

        private var mBlurFilter : BlurFilter;

		public function ConnectPage()
		{
            mBlurFilter = new BlurFilter( 16, 16, BitmapFilterQuality.HIGH );

            //Instantiate this way, so properties get filled
			var clazz : Class = getDefinitionByName( "MC_QrPanel" ) as Class;
            mcQrPanel = new clazz() as QrPanel;
            mcQrPanel.init( this );
            mcQrPanel.visible = false;

            clazz = getDefinitionByName( "LoadingSpinnerPanelRef" ) as Class;
            mcLoadingSpinnerPanel = new clazz() as MovieClip;
            mcLoadingSpinnerPanel.tfLoadingText.text = "[[panel_telemetry_processing]]";
            mcLoadingSpinnerPanel.visible = false;

            addEventListener( Event.REMOVED_FROM_STAGE, handleRemovedFromStage, false, 0, true );
		}

        override protected function configUI():void
        {
            super.configUI();

            setupInputFeedbackButtons(true);

            mcQrPanel.mcSkipButton.setDataFromStage( NavigationCode.GAMEPAD_B, KeyCode.ESCAPE );
            mcQrPanel.mcSkipButton.label = "[[startup_connect_skip]]";
            mcQrPanel.mcSkipButton.addEventListener( ButtonEvent.CLICK, onSkip, false, 0, true );
            mcQrPanel.mcSkipButton.addEventListener( GestureEventEx.GESTURE_TAP, onSkip, false, 0, true );
        }

        private function setupInputFeedbackButtons(show : Boolean):void
        {
            if (show)
            {
                mcInputFeedbackPanel.appendButton( 1, NavigationCode.GAMEPAD_B, KeyCode.ESCAPE, "[[startup_connect_skip]]", true );
                mcInputFeedbackPanel.appendButton( 2, NavigationCode.GAMEPAD_A, KeyCode.E, "[[startup_connect_connect]]", true );
            }
            else
            {
                mcInputFeedbackPanel.removeButton( 1, true );
                mcInputFeedbackPanel.removeButton( 2, true );
            }
        }

        public function setData(data:Object):void
        {
            mcCDPRAccount.tfText.htmlText = data.cdprAccountText;
            tfTitle.htmlText = data.title;

            mcIcon1.setData(data.icons[0]);
            mcIcon2.setData(data.icons[1]);
            mcIcon3.setData(data.icons[2]);
            mcIcon4.setData(data.icons[3]);

            mcQrPanel.setTitleAndDesc( data.qrTitle, data.qrDesc );
        }

        private function showQrPanel( show : Boolean ) : void
        {
            if ( show )
            {
                setupInputFeedbackButtons( false ); 
                
                this.filters = [ mBlurFilter ];
                stage.addChild( mcQrPanel );
                mcQrPanel.visible = true;
            }
            else
            {
                mcQrPanel.visible = false;
                stage.removeChild( mcQrPanel );
                this.filters = [ ];

                setupInputFeedbackButtons( true ); 
            }
        }

        private function showSpinnerPanel( show : Boolean ) : void
        {
            if ( show )
            {
                setupInputFeedbackButtons( false ); 
                
                this.filters = [ mBlurFilter ];
                stage.addChild( mcLoadingSpinnerPanel );
                mcLoadingSpinnerPanel.visible = true;
            }
            else
            {
                mcLoadingSpinnerPanel.visible = false;
                stage.removeChild( mcLoadingSpinnerPanel );
                this.filters = [ ];

                setupInputFeedbackButtons( true ); 
            }
        }

        //Handles the case where we switch page while we are in QR Panel shown mode.
        //Happens when we log in.
		private function handleRemovedFromStage( event : Event ) : void
		{
            showQrPanel( false );
            showSpinnerPanel( false );
		}

        public function onSkip( event : Event = null ) : void
        {
            showQrPanel( false );
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnConnectPageSkipConnect" ) );
        }

        public function onConnect( event : Event = null ) : void
        {
            var platformType:uint = InputManager.getInstance().getPlatform();

            if(!mcQrPanel.visible)
            {
                showSpinnerPanel( true );
                dispatchEvent( new GameEvent( GameEvent.CALL, "OnConnectPageRequestConnect" ) );
            }
            else if(platformType != PlatformType.PLATFORM_XB_SCARLETT_ANACONDA
                && platformType != PlatformType.PLATFORM_XB_SCARLETT_LOCKHART
                && platformType != PlatformType.PLATFORM_PS5
                && platformType != PlatformType.PLATFORM_SWITCH2)
            {
                dispatchEvent( new GameEvent( GameEvent.CALL, "OnQrPanelLinkClicked" ));
            }
        }

        public function showQrCode( url : String ) : void
        {
            showSpinnerPanel( false );
            showQrPanel( true );
            mcQrPanel.setUrlAndLoadQrCode( url );
        }

        public function showError( error : String ) : void
        {
            showSpinnerPanel( false );
            showQrPanel( false );
            //NOTE : notification show is called in WS
        }

        protected function handleInputNavigate(event:InputEvent):void
		{	
            trace( "ConnectPage::handleInputNavigate : ", event );

			var details:InputDetails = event.details;
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;

            if ((details.navEquivalent == NavigationCode.GAMEPAD_B && keyDown) || (details.code == KeyCode.ESCAPE && keyUp))
            {
                onSkip();
                event.handled = true;
            }
            else if ((details.navEquivalent == NavigationCode.GAMEPAD_A && keyDown) || (details.code == KeyCode.E && keyUp))
            {
                onConnect();
                event.handled = true;
            }
		}
    }
}
