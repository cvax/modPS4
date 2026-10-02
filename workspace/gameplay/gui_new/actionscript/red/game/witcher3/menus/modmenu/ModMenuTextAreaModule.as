/***********************************************************************
/** Mod Menu text area module
/** Handpicked TextAreaModule
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.menus.common.TextAreaModule;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	

	public class ModMenuTextAreaModule extends TextAreaModule
	{
		public static const TEXT_HEADER_PADDING 	: int = 10;
		
		public var	_scrollSpeed : Number = 1;

		public var selected : Boolean;
		
		
		function ModMenuTextAreaModule()
		{
			InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleCustomInput, false, 0, true);
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			SetAsActiveContainer(true);
			updateInputFeedback();
		}
	
		private function handleCustomInput(event:InputEvent ): void
		{
			var details:InputDetails = event.details;
			
			if(!selected)
				return;

			if( details.code == KeyCode.PAD_RIGHT_STICK_AXIS )
			{
				var axisData:InputAxisData;
				var yvalue:Number;
				
				axisData = InputAxisData(details.value);
				yvalue = axisData.yvalue;
				mcScrollbar.position -= yvalue;
			}
		}
		
		override public function hasSelectableItems():Boolean
		{
			return false;
		}
		
		override public function SetText( value : String  ) : void
		{
			super.SetText(value);
			
			mcTextArea.validateNow();
			updateInputFeedback();
		}
		
		override public function SetTitle(value:String):void
		{
			if(tfTitle)
			{
				super.SetTitle(value);
				
				tfTitle.height = tfTitle.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			}
			//mcTextArea.y = tfTitle.y + tfTitle.textHeight + TEXT_HEADER_PADDING * 2;
			//mcScrollbar.y = mcTextArea.y;
		}
		
		override protected function scrollFocusCheck():Boolean
		{
			return true;
		}
		
		override public function handleInput(event:InputEvent):void
		{
		}
		
	}
	
}