/***********************************************************************
/** Modded MainMenu Indicator Tooltip
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : 	Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.utils.setTimeout;
    import scaleform.clik.core.UIComponent;
    import red.core.events.GameEvent;

	public class TooltipModded extends UIComponent
	{
        private static const FRAME_PADDING_WIDTH : Number = 30;
        private static const FRAME_PADDING_HEIGHT : Number = 15;
        private static const FRAME_MIN_LENGTH : Number = 300;
        private static const SAFETY_PAD : Number = 7;
        
        public var textField : TextField;
        public var mcFrame : MovieClip;

        public function TooltipModded()
        {
            visible = false;
        }

        override protected function configUI():void
        {
            dispatchEvent( new GameEvent(GameEvent.REGISTER, "mod.tooltip.text", [delayedSetText]));
        }

        public function delayedSetText(text:String):void
        {
            //#LT hack to languages that use different font
            //especially chinese (traditional) characters seem to be not in the english version
			setTimeout(function(){
				setText(text);
			}, 20);
        }

        public function setText(text : String):void
        {
            textField.htmlText = text;
            
            textField.width = textField.textWidth + SAFETY_PAD;

            mcFrame.x = 0;
            textField.x = FRAME_PADDING_WIDTH;

            mcFrame.width = textField.textWidth + 2 * FRAME_PADDING_WIDTH;
            if(mcFrame.width < FRAME_MIN_LENGTH) {
                mcFrame.width = FRAME_MIN_LENGTH
                textField.x = (mcFrame.width - textField.textWidth) / 2;
            }
            mcFrame.height = textField.textHeight + 2 * FRAME_PADDING_HEIGHT;

            mcFrame.y = 0;
            textField.y = FRAME_PADDING_HEIGHT - 2;
        }
	}
}
