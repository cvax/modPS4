package red.game.witcher3.hud.modules.lootfeed
{
	import adobe.utils.CustomActions;
	import flash.display.MovieClip;
	import flash.events.TextEvent;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.hud.modules.HudModuleBase;
	import scaleform.clik.controls.StatusIndicator;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;
	import scaleform.clik.core.UIComponent;
	import flash.utils.getDefinitionByName;
    import red.game.witcher3.controls.W3UILoader;
    import flash.utils.setTimeout;
    import red.game.witcher3.hud.modules.HudModuleLootFeed;
	
	public class HudLootFeedShower extends UIComponent
	{
		//>------------------------------------------------------------------------------------------------------------------
		// VARIABLES
		//-------------------------------------------------------------------------------------------------------------------
        public var mcIconLoader : W3UILoader
        public var tfName : TextField;
        public var tfQuantity : TextField;

        public var m_lootfeedRef : HudModuleLootFeed;
        public var m_fadeInTime : Number = 0.25;
        public var m_fullAlphaLifetime : Number = 1.25;
        public var m_fadeOutTime : Number = 0.5;

        private var m_moveTween : GTween;

        public function customEase(ratio: Number, unused1: Number, unused2: Number, unused3: Number):Number
        {
            return ratio;
        }

		public function HudLootFeedShower()
		{
			super();
		}

        public function setData(data:Object):void
        {
            tfName.text = data.name;
            tfQuantity.text = data.quantityText;
            mcIconLoader.source = "img://" + data.iconPath;
        }
		
		override protected function configUI():void
		{
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
            if(m_lootfeedRef)
                m_lootfeedRef.OnElementFadeInOver(this);
            startFullAlphaLifeTime();
        }

        public function startFullAlphaLifeTime():void
        {
            setTimeout( startFadeOut, m_fullAlphaLifetime * 1000); //ms
        }

        public function startFadeOut():void
        {
            if(m_lootfeedRef)
                m_lootfeedRef.OnElementLifeTimeOver(this);
            GTweener.to(this, m_fadeOutTime, {alpha : 0.01}, {ease: customEase, onComplete:onFadeOutEnded});
        }

        public function onFadeOutEnded():void
        {
            if(m_lootfeedRef)
                m_lootfeedRef.OnElementDie(this);
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
