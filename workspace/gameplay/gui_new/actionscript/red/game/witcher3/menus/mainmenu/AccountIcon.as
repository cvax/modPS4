package red.game.witcher3.menus.mainmenu
{
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextLineMetrics;

    public class AccountIcon extends MovieClip
	{
        public static const RAROG : uint = 0;
		public static const EPIC : uint = 1;
		public static const GOG : uint = 2;
		public static const PSN : uint = 3;
		public static const STEAM : uint = 4;
		public static const XBOX : uint = 5;
		public static const UNKNOWN : uint = 6;

        public function AccountIcon()
        {
            gotoAndStop(1);
        }

        public function setData( icon : uint ) : void
        {
            icon = icon < totalFrames ? icon + 1 : totalFrames;
            gotoAndStop( icon );
        }
    }
}