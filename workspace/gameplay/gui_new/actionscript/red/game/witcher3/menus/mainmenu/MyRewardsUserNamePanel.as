package red.game.witcher3.menus.mainmenu
{
    import scaleform.clik.core.UIComponent;
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextLineMetrics;
    import red.core.events.GameEvent;
    import flash.events.Event;

    import red.game.witcher3.utils.CommonUtils;
    import flash.geom.Rectangle;
    import flash.display.Sprite;

    public class MyRewardsUserNamePanel extends UIComponent
	{
        public var mcBackground : MovieClip;
        public var mcCloudUserName : IconedAccountName;
        private var mAnchorX : Number;

        public function MyRewardsUserNamePanel()
        {
            mAnchorX = x + width;
        }

        override protected function configUI() : void
        {
            super.configUI();

            dispatchEvent( new GameEvent( GameEvent.REGISTER, "userpanel.accountData", [handleDataEvent] ) );
            hackDelayedInit();
        }

        private function hackDelayedInit() : void
        {
            dispatchEvent( new GameEvent( GameEvent.CALL, 'OnUserPanelInit' ) );
        }

        public function handleDataEvent( data : Object ) : void 
		{
            trace( "MyRewardsUserNamePanel::handleDataEvent : ", data );

			if ( !data )
			{
				return;
			}

            trace( "MyRewardsUserNamePanel::handleDataEvent2 : ", data.cloudPersona, data.userNameIcon, data.userName );

            mcCloudUserName.setData( AccountIcon.RAROG, data.cloudPersona );

            layout();
        }

        private function layout() : void
        {
            trace( "MyRewardsUserNamePanel::layout : ", x, width, scaleX, mcBackground.width, mAnchorX );
            
            const PAD_X : Number = 32.0;
            var userNameWidth = mcCloudUserName.measureWidth();
            var contentWidth : Number = PAD_X + userNameWidth + PAD_X;

            mcBackground.width = contentWidth;

            x = mAnchorX - mcBackground.width * scaleX;
        }
    }
}
