/***********************************************************************
/** Text with a box
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.display.MovieClip;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.getDefinitionByName;
    import flash.events.MouseEvent;

    import scaleform.clik.core.UIComponent;

    import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

    import red.core.events.GameEvent;

	public class BoxedText extends UIComponent
	{
        // CONSTS
        protected static const TEXT_HORIZONTAL_GAP:Number = 10;

		// ART CLIPS
		public var mcText 			    :   TextField;
        public var mcBox	            : 	MovieClip;

        // VARS
        public var _scalingOption:String = "left";
        protected var pivotX:Number = 0;

        public function BoxedText() 
		{
            super();
            pivotX = x;
		}

        public function set scalingOption(value:String):void
        {
            _scalingOption = value;
            if(value == "left")
            {
                pivotX = x;
            }
            else if (value == "center")
            {
                pivotX = x + getWidth() / 2;
            }
            else if (value == "right")
            {
                pivotX = x + getWidth();
            }
        }

        public function setText(text:String)
        {
            mcText.text = text;
            mcText.autoSize = TextFieldAutoSize.LEFT;
            mcBox.width = mcText.textWidth + 2 * TEXT_HORIZONTAL_GAP;

            if(_scalingOption == "left")
            {
                x = pivotX;
            }
            else if (_scalingOption == "center")
            {
                x = pivotX - getWidth() / 2;
            }
            else if (_scalingOption == "right")
            {
                x = pivotX - getWidth();
            }
        }

        public function getWidth():Number
        {
            return mcBox.width;
        }
	}
	
}