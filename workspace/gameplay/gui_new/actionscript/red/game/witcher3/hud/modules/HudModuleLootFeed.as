package red.game.witcher3.hud.modules
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
	import red.game.witcher3.hud.modules.lootfeed.HudLootFeedShower;
	
	public class HudModuleLootFeed extends HudModuleBase
	{
		//>------------------------------------------------------------------------------------------------------------------
		// VARIABLES
		//-------------------------------------------------------------------------------------------------------------------

		private var m_showers : Vector.<HudLootFeedShower>;

		private var m_pendingData : Vector.<Object>;
		private var m_maxShowers : int = 5;

		private var m_fadeInTime : Number = 0.5;
        private var m_fullAlphaLifetime : Number = 3;
        private var m_fadeOutTime : Number = 0.5;
		private var m_sametimeSpawnDelay : Number = 0.6;
		private var m_moveTime : Number = 0.25;

		private var m_elemScale : Number = 1;
		private var m_yGap : Number = 0;

		public function HudModuleLootFeed()
		{
			super();
			m_showers = new Vector.<HudLootFeedShower>();
			m_pendingData = new Vector.<Object>();
		}

		override public function get moduleName():String
		{
			return "LootFeedModule";
		}
		
		override protected function configUI():void
		{
			super.configUI();
			alpha = 0;

			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );

			dispatchEvent( new GameEvent( GameEvent.REGISTER, "hud.lootfeed.add", [addLootFeedData] ) );
		}

		public function addLootFeedData(dataArray:Array):void
		{
			for(var i : int = 0; i < dataArray.length; i++)
			{
				m_pendingData.push(dataArray[i]);
			}

			if(dataArray.length > 0 && m_showers.length < m_maxShowers)
			{
				spawnShowers();
			}
		}

		public function spawnShowers():void
		{
			var showerClass:Class = getDefinitionByName("LootFeedShower") as Class;
			var spawnsHappened:int = 0;

			if(!showerClass)
				return;

			while(m_pendingData.length > 0)
			{
				if(m_showers.length >= m_maxShowers)
					break;

				var lfShower : HudLootFeedShower = new showerClass() as HudLootFeedShower;

				if(lfShower)
				{
					addChild(lfShower);
					m_showers.splice(0, 0, lfShower); //this is adding, not removing, don't be distracted!

					lfShower.m_fadeInTime = m_fadeInTime;
					lfShower.m_fullAlphaLifetime = m_fullAlphaLifetime + spawnsHappened * m_sametimeSpawnDelay;
					lfShower.m_fadeOutTime = m_fadeOutTime;
					lfShower.alpha = 0;
					lfShower.scaleX = m_elemScale;
					lfShower.scaleY = m_elemScale;
					lfShower.m_lootfeedRef = this;
					
					lfShower.setData(m_pendingData[0]);
					m_pendingData.splice(0,1);
					
					lfShower.startLifeProcess(0);
					spawnsHappened++;
				}
				
			}

			if(spawnsHappened > 0)
			{
				//reposition!!!
				for(var i : int = 0; i < m_showers.length; i++)
				{
					m_showers[i].onMoveToY((m_showers[i].height + m_yGap) * i, m_moveTime, i < spawnsHappened);
				}
			}
		}

		public function OnElementFadeInOver(shower : HudLootFeedShower):void
		{
		}

		public function OnElementLifeTimeOver(shower : HudLootFeedShower):void
		{
		}

		public function OnElementDie(shower : HudLootFeedShower):void //in other words OnElementFadeOutOver
		{
			var index:int = m_showers.indexOf(shower);
			if(index != -1)
				m_showers.splice(index, 1);
			removeChild(shower);
			spawnShowers();
		}

		public function /*WS*/ setMaxShowerCount(count : int) : void
		{
			m_maxShowers = count;
		}

		public function /*WS*/ setTimes(fadeinTime : Number, fullTime : Number, fadeoutTime : Number, spawnDelay : Number, moveTime : Number) : void
		{
			m_fadeInTime = fadeinTime;
			m_fullAlphaLifetime = fullTime;
			m_fadeOutTime = fadeoutTime;
			m_sametimeSpawnDelay = spawnDelay;
			m_moveTime = moveTime;
		}

		public function /*WS*/ setElemScale(scale : Number):void
		{
			m_elemScale = scale;
		}

		public function /*WS*/ setYGap(gap : Number):void
		{
			m_yGap = gap;
		}


	}
}
