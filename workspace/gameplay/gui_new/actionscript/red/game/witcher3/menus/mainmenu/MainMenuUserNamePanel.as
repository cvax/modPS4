package red.game.witcher3.menus.mainmenu
{
    import scaleform.clik.core.UIComponent;
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextLineMetrics;
    import red.core.events.GameEvent;
    import flash.utils.setTimeout;
    import flash.display.InteractiveObject;

    public class MainMenuUserNamePanel extends UIComponent
	{
        public var mcBackground : MovieClip;
        public var mcCloudUserName : IconedAccountName;

        private var _isInMainMenu : Boolean;
        private var _fontLoadInProgess : Boolean;
        private var _isInPanel : Boolean;

        public function MainMenuUserNamePanel()
        {
            _isInMainMenu = false;
            _fontLoadInProgess = false;
            _isInPanel = false;
        }

        override protected function configUI() : void
        {
            super.configUI();

            dispatchEvent( new GameEvent( GameEvent.REGISTER, "userpanel.accountData", [handleDataEvent] ) );
            //Delay a bit, otherwise the data will never arrive due to some bug
            setTimeout( requestData, 0 );
        }

        public function setIsMainMenu( value : Boolean ) : void
        {
            _isInMainMenu = value;
            updateVisibility();
        }

        public function setIsInPanel( value : Boolean ) : void
        {
            _isInPanel = value;
            updateVisibility();
        }

        private function updateVisibility() : void
        {
            trace( "MainMenuUserNamePanel::updateVisibility : ", _isInPanel, _isInMainMenu, _fontLoadInProgess, mcCloudUserName.visible );
            visible = !_isInPanel && _isInMainMenu && !_fontLoadInProgess && mcCloudUserName.visible;
        }

        private function requestData( ) : void
        {
            trace( "MainMenuUserNamePanel::requestData" );
            dispatchEvent( new GameEvent( GameEvent.CALL, 'OnUserPanelInit' ) );
        }

		public function handleDataEvent( data : Object ) : void 
		{
			if ( !data )
			{
				return;
			}

            trace( "MainMenuUserNamePanel::handleDataEvent2 : ", data.cloudPersona, data.userNameIcon, data.userName );

            mcCloudUserName.setData( AccountIcon.RAROG, data.cloudPersona );

            layout();
            updateVisibility();
        }

        private function layout() : void
        {
            const PAD_X : Number = 12.0;

            var userNameWidth = mcCloudUserName.measureWidth();
            var contentWidth : Number = PAD_X + userNameWidth + PAD_X;
            var centerX : Number = mcBackground.x + mcBackground.width / 2.0;

            mcBackground.width = contentWidth;
            mcBackground.x = centerX - mcBackground.width / 2.0;

            mcCloudUserName.x = centerX - userNameWidth / 2.0 - 3.0;
        }

        //Hide the username while the fonts are loading
        public function HACK_languageUpdateStart() : void
        {
            trace( "MainMenuUserNamePanel::HACK_languageUpdateStart" );
            _fontLoadInProgess = true;
            updateVisibility();
        }

        //Fonts are loaded layout, and show the username
        public function HACK_languageUpdateEnd() : void
        {
            trace( "MainMenuUserNamePanel::HACK_languageUpdateEnd" );

            _fontLoadInProgess = false;
            layout();
            updateVisibility();
        }
    }
}
