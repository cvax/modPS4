package red.game.witcher3.hud.modules.journalupdate
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.InputFeedbackButton;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
    import red.game.witcher3.controls.W3UILoader;
    import red.game.witcher3.controls.W3Label;
    import flash.utils.getDefinitionByName;
    import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
    import red.game.witcher3.hud.modules.HudModuleJournalUpdate;
	import red.game.witcher3.utils.CommonUtils;
    import flash.geom.ColorTransform;
    import flash.utils.setTimeout;
    import red.game.witcher3.menus.common_menu.ModuleInputFeedback;

	public class QuestFinishedWindow extends UIComponent
	{
		public var mcCrests : MovieClip;
        public var mcText : W3Label;
        public var mcTitle : W3Label;
        public var mcItemListBg : MovieClip;
        public var hudModuleRef : HudModuleJournalUpdate;
        public var mcInputFeedback:ModuleInputFeedback;

        private static const BG_HEIGHT : Number = 274;
        private static const MAX_ITEMS : Number = 5;
        private static const RENDERER_Y_PUSH : Number = 115 + 28;
        private static const RENDERER_X_PUSH : Number = 15;
        private static const FADE_IN_TIME : Number = 0.5;
        private static const FADE_OUT_TIME : Number = 0.5;

		private var _data        : Object;
        private var m_pendingData : Vector.<Object> = new Vector.<Object>;
        private var m_renderers : Vector.<QuestItemRenderer> = new Vector.<QuestItemRenderer>;

        private var m_fadeInTime : Number = 0.5;
        private var m_fullAlphaLifetime : Number = 3;
        private var m_fadeOutTime : Number = 0.5;
		private var m_sametimeSpawnDelay : Number = 0.6;
		private var m_moveTime : Number = 0.4;
        private var m_yGap : Number = 0;
        private var m_minOnlineTime : Number = 2;

        private var m_resizeTween : GTween;
        private var m_endPhaseAllowed : Boolean = false;
		
		public function get data():Object { return _data; }
		public function set data(value:Object):void
		{
			_data = value;
			populateData();
		}

        private function getRendererAvailableHeight():Number
        {
            return BG_HEIGHT / MAX_ITEMS;
        }
		
		private function populateData():void
		{
            mcInputFeedback.cleanupButtons();

			mcCrests.gotoAndStop(data.crest);

            mcText.text = CommonUtils.toUpperCaseSafe(data.text);
            mcTitle.text = CommonUtils.toUpperCaseSafe(data.title);

            m_minOnlineTime = data.minOnlineTime;
            m_fullAlphaLifetime = data.itemRendererLifeTime;
            m_fadeInTime = data.itemRendererFadeInTime;
            m_fadeOutTime = data.itemRendererFadeOutTime;
            m_sametimeSpawnDelay = data.itemRendererSpawnDelay;
            m_moveTime = data.itemRendererMoveTime;


            var ct:ColorTransform = new ColorTransform();
            switch(data.colorId)
            {
                case 0: //"inactive":
                case 1: //"active":
                    ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 0;
                    break;
                case 2: //"success":
                    ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 0.4;
                    ct.color = 0xECC066;
                    break;
                case 3: //"failed":
                    ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 0.6;
                    ct.color = 0xFF0000;
                    break;
            }
            if(data.colorId > 1)
                mcText.textField.transform.colorTransform = ct;

            if(data.items.length > 0)
            {
                mcItemListBg.visible = true;
                mcItemListBg.height = BG_HEIGHT * Math.min(MAX_ITEMS, data.items.length) / MAX_ITEMS;
                for(var i : int = 0; i < data.items.length; i++)
                    m_pendingData.push(data.items[i]);
            }
            else
            {
                mcItemListBg.visible = false;
            }

            StartBeginPhase();

            mcInputFeedback.y = mcText.y + mcText.textField.textHeight + mcInputFeedback.height / 2 + (mcItemListBg.visible? (mcItemListBg.height + 15) : 0);
		}

        public function spawnRenderers():void
		{
			var showerClass:Class = getDefinitionByName("MC_QuestItemRenderer") as Class;
			var spawnsHappened:int = 0;

			if(!showerClass)
				return;

			while(m_pendingData.length > 0)
			{
				if(m_renderers.length >= MAX_ITEMS)
					break;

				var qiRenderer : QuestItemRenderer = new showerClass() as QuestItemRenderer;

				if(qiRenderer)
				{
					addChild(qiRenderer);
					m_renderers.splice(0, 0, qiRenderer); //this is adding, not removing, don't be distracted!
                    //m_renderers.push(qiRenderer);

					qiRenderer.m_fadeInTime = m_fadeInTime;
					qiRenderer.m_fullAlphaLifetime = m_fullAlphaLifetime + spawnsHappened * m_sametimeSpawnDelay;
					qiRenderer.m_fadeOutTime = m_fadeOutTime;
					qiRenderer.alpha = 0;
                    qiRenderer.x = RENDERER_X_PUSH;
					//qiRenderer.scaleX = m_elemScale;
					//qiRenderer.scaleY = m_elemScale;
					qiRenderer.m_questWindow = this;
					
					qiRenderer.data = m_pendingData[0];
					m_pendingData.splice(0,1);
					
					qiRenderer.startLifeProcess(0);
					spawnsHappened++;
				}
				
			}

			{
				//reposition!!!
				for(var i : int = 0; i < m_renderers.length; i++)
				{
					m_renderers[i].onMoveToY(RENDERER_Y_PUSH + (Math.min(m_renderers.length - 1, 4) - i) * getRendererAvailableHeight() - m_yGap * i, m_moveTime, i < spawnsHappened);
				}
			}

            if(m_renderers.length == 0)
                StartEndPhase();
		}

        public function OnElementFadeInOver(renderer : QuestItemRenderer):void
		{
		}

		public function OnElementLifeTimeOver(renderer : QuestItemRenderer):void
		{
		}

		public function OnElementDie(renderer : QuestItemRenderer):void //in other words OnElementFadeOutOver
		{
			var index:int = m_renderers.indexOf(renderer);
			if(index != -1)
				m_renderers.splice(index, 1);
			removeChild(renderer);
			spawnRenderers();
            changeBgHeight(BG_HEIGHT * Math.min(MAX_ITEMS, m_renderers.length) / MAX_ITEMS, m_moveTime);
		}

        public function StartBeginPhase():void
        {
            visible = true;
            alpha = 0;
            GTweener.to(this, FADE_IN_TIME, {alpha: 1}, {ease: customEase, onComplete:StartMidPhase})
            m_endPhaseAllowed = false;
        }

        public function StartMidPhase():void
        {
            spawnRenderers();
            setTimeout(AllowEndPhase, m_minOnlineTime * 1000) //1000 as it's ms not seconds
        }

        public function AllowEndPhase():void
        {
            m_endPhaseAllowed = true;
            if(m_renderers.length == 0)
                StartEndPhase();
        }

        public function StartEndPhase():void
        {
            if(!m_endPhaseAllowed)
                return;
            visible = true;
            alpha = 1;
            GTweener.to(this, FADE_IN_TIME, {alpha: 0}, {ease: customEase})

            hudModuleRef.endQuestFinished();
        }

        public function customEase(ratio: Number, unused1: Number, unused2: Number, unused3: Number):Number
        {
            return ratio;
        }

        public function changeBgHeight(newHeight:Number, fadeTime : Number = 0.2, instant:Boolean = false):void
        {
            if(instant)
                mcItemListBg.height = newHeight;
            else
            {
                if(m_resizeTween)
                {
                    m_resizeTween.paused = true;
                    GTweener.remove(m_resizeTween);
                }
                m_resizeTween = GTweener.to(mcItemListBg, fadeTime, {height : newHeight}, {ease: customEase});
            }
        }

        public function handleSetupButtons( gameData:Object ) : void
		{
			mcInputFeedback.handleSetupButtons(gameData);
		}
		
	}

}
