package red.game.witcher3.hud.modules.journalupdate
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.InputFeedbackButton;
	import scaleform.clik.controls.UILoader;
    import red.game.witcher3.controls.W3UILoader;
    import red.game.witcher3.controls.W3Label;
	import scaleform.clik.core.UIComponent;
    import flash.utils.setTimeout;
    import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
    import red.game.witcher3.utils.CommonUtils;
	
	public class QuestItemRenderer extends UIComponent
	{
        //ART CLIPS
		public var mcIconLoader : W3UILoader;
        public var mcText : W3Label;
        public var mcPinIcon : MovieClip;

        public var m_questWindow : QuestFinishedWindow;
        private var _data        : Object;

        public var m_fadeInTime : Number = 0.25;
        public var m_fullAlphaLifetime : Number = 1.25;
        public var m_fadeOutTime : Number = 0.5;
        
        private var m_moveTween : GTween;
		
		public function get data():Object { return _data; }
		public function set data(value:Object):void
		{
			_data = value;
			populateData();
		}
		
		private function populateData():void
		{			
            if(data.iconPath)
            {
                mcIconLoader.visible = true;
			    mcIconLoader.source = "img://" + data.iconPath;
            }
            else 
                mcIconLoader.visible = false;

            if(data.hasOwnProperty("mappinType"))
            {
                mcPinIcon.visible = true;
                mcPinIcon.gotoAndStop(data.mappinType);
                mcPinIcon.filters = [CommonUtils.generateGrayscaleFilter()];
            }
            else
                mcPinIcon.visible = false;

            mcText.text = CommonUtils.toUpperCaseSafe(data.text);
		}

        
		public function customEase(ratio: Number, unused1: Number, unused2: Number, unused3: Number):Number
        {
            return ratio;
        }

        public function startLifeProcess(fadeInDelay:Number):void
        {
            if(fadeInDelay <= 0)
                startFadeIn();
            else
                setTimeout(startFadeIn, fadeInDelay * 1000);
        }

        public function startFadeIn():void
        {
            GTweener.to(this, m_fadeInTime, {alpha : 1}, {ease: customEase, onComplete:onFadeInEnded});
        }

        public function onFadeInEnded():void
        {
            if(m_questWindow)
                m_questWindow.OnElementFadeInOver(this);
            startFullAlphaLifeTime();
        }

        public function startFullAlphaLifeTime():void
        {
            setTimeout( startFadeOut, m_fullAlphaLifetime * 1000); //ms
        }

        public function startFadeOut():void
        {
            if(m_questWindow)
                m_questWindow.OnElementLifeTimeOver(this);
            GTweener.to(this, m_fadeOutTime, {alpha : 0.01}, {ease: customEase, onComplete:onFadeOutEnded});
        }

        public function onFadeOutEnded():void
        {
            if(m_questWindow)
                m_questWindow.OnElementDie(this);
        }

        public function onMoveToY(newY:Number, fadeTime : Number = 0.2, instant:Boolean = false):void
        {
            if(instant)
                y = newY;
            else
            {
                if(m_moveTween)
                {
                    m_moveTween.paused = true;
                    GTweener.remove(m_moveTween);
                }
                m_moveTween = GTweener.to(this, fadeTime, {y : newY}, {ease: customEase});
            }
        }
		
	}

}
