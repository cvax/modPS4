/***********************************************************************
/** Patch notes enry (icon, title, description)
/***********************************************************************
/** Copyright © 2026 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.startup_experience
{
    import scaleform.clik.core.UIComponent;
    import flash.display.MovieClip;
    import flash.text.TextField;

    public class PatchNotesEntry extends UIComponent
	{
        public var mcIcon : MovieClip;
        public var tfTitle : TextField;
        public var tfDesc : TextField;
        
		public function PatchNotesEntry()
		{
			super();
		}

        public function setData(data:Object):void
        {
            visible = true;
            tfTitle.htmlText = data.title;
            tfDesc.htmlText = data.desc;
            mcIcon.gotoAndStop(data.icon);
        }
    }
}
