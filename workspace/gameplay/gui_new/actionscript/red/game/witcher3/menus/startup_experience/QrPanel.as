/***********************************************************************
/** QR Panel
/***********************************************************************
/** Copyright © 2026 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.startup_experience
{
    import scaleform.clik.core.UIComponent;
    import flash.text.TextField;
    import red.game.witcher3.controls.InputFeedbackButton;
    import red.game.witcher3.controls.W3UILoader;
    import red.game.witcher3.data.KeyBindingData;
    import red.core.constants.KeyCode;
    import red.game.witcher3.constants.PlatformType;
    import red.game.witcher3.managers.InputManager;
    import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.events.ButtonEvent;
    import flash.events.Event;
    import flash.events.TextEvent;
    import red.core.events.GameEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.events.IEventDispatcher;
    import red.core.events.GestureEventEx;

    public class QrPanel extends UIComponent
	{
        public var tfTitle : TextField;
        public var tfDesc : TextField;
        public var tfUrl : TextField;

        public var mcLoader : W3UILoader;

        public var mcSkipButton : InputFeedbackButton;

        private var mDispatcher : IEventDispatcher;

		public function QrPanel( )
		{
            var colorFilterMatrix : Array = new Array(  155.0/255.0, 0, 0, 0, 0,
												        0, 144.0/255.0, 0, 0, 0,
												        0, 0, 118.0/255.0, 0, 0,
												        0,  0, 0, 1, 0 );
			var colorFilter : ColorMatrixFilter = new ColorMatrixFilter( colorFilterMatrix );

            mcLoader.filters = [ colorFilter ];

            tfUrl.htmlText = "";
		}

        public function init( dispatcher : IEventDispatcher ) : void
        {
            mDispatcher = dispatcher;
        }

        override protected function configUI():void
        {
            trace( "QrPanel::configUI" );
        }

        public function setTitleAndDesc( title : String, desc : String )
        {
            trace( "QrPanel::setTitleAndDesc : ", title, desc );
            tfTitle.htmlText = title;
            tfDesc.htmlText = desc;
        }

        public function setUrlAndLoadQrCode( url : String )
        {
            tfUrl.htmlText = "<a href='event:idQrUrl'><u>" + url + "</u></a>";
            tfUrl.addEventListener( TextEvent.LINK, onLinkClickOrTap, false, 0, true );
            tfUrl.addEventListener( GestureEventEx.GESTURE_TAP, onLinkClickOrTap, false, 0, true );
            trace( "QrPanel::setUrlAndLoadQrCode : ", url, mouseEnabled, mouseChildren );

            //File name can be anything as long as it ends with .qrcode
            //.qrcode extension is mapped to a special buffer
            mcLoader.source = "useruri.qrcode";
            mcLoader.visible = true;

            mcLoader.validateNow();
            mcLoader.addEventListener( GestureEventEx.GESTURE_TAP, onLinkClickOrTap, false, 0, true );
        }

        private function onLinkClickOrTap( event : Event ) : void 
        {
            var platformType:uint = InputManager.getInstance().getPlatform();

            if ( mDispatcher && platformType != PlatformType.PLATFORM_SWITCH2
                && platformType != PlatformType.PLATFORM_XB_SCARLETT_ANACONDA
                && platformType != PlatformType.PLATFORM_XB_SCARLETT_LOCKHART
                && platformType != PlatformType.PLATFORM_PS5 )
            {
                mDispatcher.dispatchEvent( new GameEvent( GameEvent.CALL, "OnQrPanelLinkClicked" ));
            }
        }
    }
}
