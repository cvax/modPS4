package red.game.witcher3.menus.mainmenu
{
    import scaleform.clik.core.UIComponent;
    import flash.text.TextField;
    import red.game.witcher3.controls.InputFeedbackButton;
    import red.game.witcher3.controls.W3UILoader;
    import red.game.witcher3.data.KeyBindingData;
    import red.core.constants.KeyCode;
    import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.events.ButtonEvent;
    import flash.events.Event;
    import flash.events.TextEvent;
    import red.core.events.GameEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.events.IEventDispatcher;
    import red.game.witcher3.managers.InputManager;
    import scaleform.clik.events.InputEvent;
    import flash.display.MovieClip;
    import scaleform.clik.ui.InputDetails;
    import scaleform.clik.constants.InputValue;
    import flash.events.GestureEvent;
    import red.core.events.GestureEventEx;
    import red.game.witcher3.constants.PlatformType;

    public class TelemetryDataRequestPopup extends UIComponent
	{
        public static const EVENT_CLOSE : String = "EVENT_CLOSE";

        public var tfDescription : TextField;
        public var tfUrl : TextField;

        public var mcInputBg : MovieClip;
        public var mcQrLoader : W3UILoader;
        public var mcQuietZone : MovieClip;
        public var mcBackButton : InputFeedbackButton;

		public function TelemetryDataRequestPopup( )
		{
            var colorFilterMatrix : Array = new Array(  155.0/255.0, 0, 0, 0, 0,
												        0, 144.0/255.0, 0, 0, 0,
												        0, 0, 118.0/255.0, 0, 0,
												        0,  0, 0, 1, 0 );
			var colorFilter : ColorMatrixFilter = new ColorMatrixFilter( colorFilterMatrix );

            mcQrLoader.filters = [ colorFilter ];
            mcQuietZone.filters = [ colorFilter ];
            
            mcInputBg.mouseChildren = true;
            mcInputBg.mouseEnabled = true;
		}

        override protected function configUI():void
        {
            super.configUI();

            visible = false;

            tfDescription.visible = false;
            tfUrl.visible = false;
            mcQrLoader.visible = false;
            mcQuietZone.visible = false;

            //Back button
            var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

            mcBackButton.clickable = false;
			mcBackButton.label = "[[panel_mainmenu_back]]";
			mcBackButton.setDataFromStage(isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_B, KeyCode.ESCAPE);
			mcBackButton.validateNow();
        }

        override public function set visible(value:Boolean):void
        {
            super.visible = value;

            //Hide URL on consoles, that are unlike to have any mouse that can be used to click the link.
            var platformType : uint = InputManager.getInstance().getPlatform();
			switch (platformType)
			{
				case PlatformType.PLATFORM_PS4:
				case PlatformType.PLATFORM_PS5:
				case PlatformType.PLATFORM_XBOX1:
				case PlatformType.PLATFORM_XB_SCARLETT_ANACONDA:
				case PlatformType.PLATFORM_XB_SCARLETT_LOCKHART:
                    tfUrl.visible = false;
                break;
			}

            if ( visible )
            {
                mcBackButton.addEventListener( GestureEventEx.GESTURE_TAP, handleBackNavigation, false, 0, true );
                stage.addEventListener( GestureEvent.GESTURE_TWO_FINGER_TAP, handleBackNavigation, false, 0, true );
                stage.addEventListener( GestureEventEx.GESTURE_TAP, handleTap, false, 0, true );
            }
            else
            {
                mcBackButton.removeEventListener( GestureEventEx.GESTURE_TAP, handleBackNavigation );
                stage.removeEventListener( GestureEvent.GESTURE_TWO_FINGER_TAP, handleBackNavigation );
                stage.removeEventListener( GestureEventEx.GESTURE_TAP, handleTap );
            }
        }

        public function setData( qrBufferId : String, description : String, url : String ) : void
        {
            trace( "TelemetryDataRequestPopup::set : ", qrBufferId, description, url );

            tfDescription.htmlText = description;
            tfDescription.visible = true;

            tfUrl.htmlText = "<a href='event:idQrUrl'><u>" + url + "</u></a>";
            tfUrl.addEventListener( TextEvent.LINK, onLinkActivate, false, 0, true );
            tfUrl.visible = true;

            mcQrLoader.source = qrBufferId;
            mcQrLoader.validateNow();
            mcQrLoader.visible = true;
            mcQuietZone.visible = true;
        }

        private function handleTap( event : GestureEvent ) : void
        {
            trace( "TelemetryDataRequestPopup::handleTap : ", event ); 

            if ( tfUrl.hitTestPoint( event.stageX, event.stageY ) || mcQuietZone.hitTestPoint( event.stageX, event.stageY ) )
            {
                onLinkActivate();
            }
        }

        private function onLinkActivate( event : TextEvent = null ) : void 
        {
            trace( "TelemetryDataRequestPopup::onLinkActivate : ", event );

            dispatchEvent( new GameEvent( GameEvent.CALL, "OnTelemetryDataRequestPopupLinkClicked" ));
        }

        override public function handleInput( event : InputEvent ) : void
        {
            var details:InputDetails = event.details;
            var keyUp:Boolean = (details.value == InputValue.KEY_UP);

            if(keyUp && (details.code == KeyCode.ESCAPE || details.navEquivalent == NavigationCode.GAMEPAD_B))
            {
                handleBackNavigation();
                event.handled = true;
            }
        }

        private function handleBackNavigation( event : Event = null ) : void
        {
            dispatchEvent( new Event(EVENT_CLOSE) );
        }
    }
}
