/***********************************************************************/
/** Action Script file - Meditation Clock Menu Base Class
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.meditation {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.menus.meditation.Clock;
	import red.game.witcher3.menus.meditation_menu.MeditationClock;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;

	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import red.game.witcher3.LinearEase;
	import com.gskinner.motion.easing.Sine;
	
	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	public class MeditationClockMenu extends CoreMenu
	{
		public var mcMeditationBonuses:MeditationBonusPanel;
		public var meditationClock:MeditationClock;
		public var mcGeraltImage:MovieClip;
		public var stBg:MovieClip;

        private var _navBlocked:Boolean;
		private var _bonusMeditationTime:int;
		
		public function MeditationClockMenu()
		{
			_disableShowAnimation = true;
			upToCloseEnabled = false;
			
			super();
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
            dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.clock.blocked', [blockClock] ) );
			dispatchEvent( new GameEvent(GameEvent.REGISTER, 'meditation.bonus', [setMeditationBonus] ) );
			
			meditationClock.timeChangeCallback = timeChangedCallback;

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			focused = 1;
            _navBlocked = false;
		}

        protected function blockClock(value:Boolean):void
		{
            _navBlocked = value;
		}
		
		public function setBonusMeditationTime(value:int):void
		{
			_bonusMeditationTime = value;
			
			var modDelta : Number = Math.abs( meditationClock.selectedTime - meditationClock.currentTime );
			
			mcMeditationBonuses.active = modDelta >= _bonusMeditationTime;
		}
		
		protected function setMeditationBonus(value:Array):void
		{
			trace("GFX -- setMeditationBonus ", value);
			mcMeditationBonuses.data = value;
			
			meditationClock.setLabels("[[panel_name_sleep]]", "[[panel_meditationclock_sleep_hours]]");
			//meditationClock.setLabels("sleep", "sleep until");
		}
		
		protected function timeChangedCallback( value : uint ):void
		{
			trace("GFX meditationClock.currentTime ", meditationClock.selectedTime, _bonusMeditationTime);
			
			var modDelta : Number = Math.abs( meditationClock.selectedTime - meditationClock.currentTime );
			
			mcMeditationBonuses.active = modDelta >= _bonusMeditationTime;
		}
		
        override protected function handleInputNavigate(event:InputEvent):void
        {
            if (!_navBlocked && !(meditationClock.isMeditating))
            {
                super.handleInputNavigate(event);
            }
        }
		
		public function setGeraltBackgroundVisible(value:Boolean):void
		{
			if (mcGeraltImage)
			{
				mcGeraltImage.visible = value;
			}
		}

		public function fadeInEverything(timeInSeconds:Number):void
		{
			alpha = 0
			GTweener.removeTweens(this);
			GTweener.to(this, timeInSeconds, {alpha: 1})
		}

		public function fadeOutGeraltBackground(timeInSeconds:Number):void
		{
			GTweener.removeTweens(mcGeraltImage);
			GTweener.to(mcGeraltImage, timeInSeconds, {alpha: 0})
		}

		public function movePanelXTo(_x : Number, _time : Number = 0)
		{
			if(_time <= 0)
			{
				meditationClock.x = _x;
				stBg.x = _x - 682;
				meditationClock.calcInitStuff();
			}
			else
			{
				GTweener.removeTweens(meditationClock);
				GTweener.to(meditationClock, _time, {x: _x}, {ease:Sine.easeInOut, onComplete: function(){meditationClock.calcInitStuff(); } } );
				GTweener.removeTweens(stBg);
				GTweener.to(stBg, _time, {x: _x - 682}, {ease:Sine.easeInOut});
			}
		}
		
		override protected function get menuName():String
		{
			return "MeditationClockMenu";
		}
		
		public function SetBlockMeditation( value : Boolean )
		{
			meditationClock.SetBlockMeditation( value );
		}
		
		public function Set24HRFormat( value : Boolean )
		{
			meditationClock.Set24HRFormat( value );
		}

		public function setCurrentTime( hours : int, minutes : int):void /*WS*/
		{
			meditationClock.setCurrentHours(hours);
			meditationClock.setCurrentMin(minutes);
		}

		public function meditationConfirmed()/*WS*/
		{
			meditationClock.OnMeditationConfirmed();
		}
	}
}
