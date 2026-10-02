/***********************************************************************
/** Text with framed icon
/***********************************************************************
/** Copyright © 2026 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.startup_experience
{
    import scaleform.clik.core.UIComponent;
    import flash.display.MovieClip;
    import flash.text.TextField;

    public class TextedIcon extends UIComponent
	{
        public var mcIcon : MovieClip;
        public var tfText : TextField;
        
		public function TextedIcon()
		{
			super();
		}

        public function setData(data:Object):void
        {
            tfText.htmlText = data.label;
            mcIcon.gotoAndStop(data.icon);
        }
    }
}
