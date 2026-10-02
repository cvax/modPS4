package red.game.witcher3.menus.photomode 
{
    import flash.display.MovieClip;
	import scaleform.clik.core.UIComponent;

    public class PhotomodeThirdsLines extends UIComponent
	{
        public var m_leftLine : MovieClip;
        public var m_rightLine : MovieClip;
        public var m_topLine : MovieClip;
        public var m_bottomLine : MovieClip;

        private var m_totalWidth;
        private var m_totalHeight;

        //original aspect ratio set
        public function SetFullscreenAspectRatio(width : int, height : int) : void
        {
            var ratio : Number = Number(width)/Number(height);

            if(Math.abs(ratio - 4/3)<0.1) {
                m_totalWidth = 1920;
                m_totalHeight = 1440;
            }
            else if(Math.abs(ratio - 21/9)<0.1)
            {
                m_totalWidth = 2520;
                m_totalHeight = 1080;
            }
            else
            {
                m_totalWidth = 1920;
                m_totalHeight = 1080;
            }

            m_leftLine.width = m_rightLine.width = m_totalWidth;
            m_leftLine.height = m_rightLine.height = 1;
            m_topLine.width = m_bottomLine.width = 1;
            m_topLine.height = m_bottomLine.height = m_totalHeight;
            m_rightLine.x = m_leftLine.x = -m_totalWidth / 2;
            m_topLine.y = m_bottomLine.y = -m_totalHeight / 2;

            SetLinesAspectRatio(width,height);
        }

        public function SetLinesAspectRatio(width:int, height:int):void
        {
            if(width / height > m_totalWidth / m_totalHeight)
			{
				height = m_totalWidth * height / width;
				width = m_totalWidth;
			}
			else
			{
				width = m_totalHeight * width / height;
				height = m_totalHeight;
			}

            m_leftLine.y = -height / 6;
            m_rightLine.y = height / 6;
            m_topLine.x = -width / 6;
            m_bottomLine.x = width / 6;
        }

        public function GetAspectRatioString(width:int, height:int):String
        {
            var ratio : Number = Number(width)/Number(height);
            var aspStr : String = "";

            if(Math.abs(ratio - 4/3)<0.1)
                aspStr = "4:3";
            else if(Math.abs(ratio - 21/9)<0.1)
                aspStr = "21:9";
            else
                aspStr = "16:9";

            
            return aspStr;
        }
    }
}