/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import flash.text.TextField;
	import red.core.events.GameEvent;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.game.witcher3.controls.W3Slider;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.menus.common.W3SubMenuListItemRenderer;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.SliderEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.data.DataProvider;
	import red.core.constants.KeyCode;
	
	public class HDRSettingModule extends StaticOptionModule
	{
		public var mcOptionList : W3ScrollingList;
		public var mcOptionListItem1 : W3SubMenuListItemRenderer;
		public var mcOptionListItem2 : W3SubMenuListItemRenderer;
		public var mcOptionListItem3 : W3SubMenuListItemRenderer;

		private var _data:Object;

		override protected function configUI():void
		{
			super.configUI();
			focusable = false;
		}

		public function showWithData(data:Object):void
		{
			super.show();

			setupDataProviders(data as Array);
			mcOptionList.selectedIndex = 0
			mcOptionList.validateNow();
			mcOptionList.focused = 1;
		}

		protected function setupDataProviders(data:Array):void
		{
			var i:int;
			var finalDataList:Array = new Array();

			trace("OptionListModule setupDataProviders()");

			for (i = 0; i < data.length; ++i)
			{
				finalDataList.push(data[i]);
			}
			
			mcOptionList.dataProvider = new DataProvider(finalDataList);
			mcOptionList.validateNow();
		}

		override public function hide():void
		{
			super.hide();
		}

		override public function handleInputNavigate(event:InputEvent):void
		{
			if (visible)
			{
				var details:InputDetails = event.details;
				var keyUp:Boolean = (details.value == InputValue.KEY_UP);
				var optionRenderer:W3SubMenuListItemRenderer = mcOptionList.getSelectedRenderer() as W3SubMenuListItemRenderer;

				if(details.navEquivalent == NavigationCode.GAMEPAD_A || details.code == KeyCode.E)
					return;
				
				mcOptionList.handleInput(event);
				
			}
		}
	}
}