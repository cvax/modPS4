package red.game.witcher3.tooltips
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import red.core.constants.KeyCode;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.NavigationCode;
	import flash.events.GestureEvent;
	import red.core.events.GestureEventEx;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;

	/**
	 * Alchemy / Craftion tooltip
	 * @author Getsevich Yaroslav
	 */
	public class IngredientTooltip extends TooltipBase
	{
		private const ICON_PADDING:Number = 8;
		private const BK_PADDING:Number = 20;
		
		public var btnBuy:InputFeedbackButton;
		public var mcCoinIcon:MovieClip;
		public var mcBackground:MovieClip;
		
		public var tfItemName:TextField;
		public var tfItemType:TextField;
		
		public function IngredientTooltip()
		{
			visible = false;
			mcCoinIcon.visible = false;
			btnBuy.visible = false;
		}
		
		override protected function populateData():void
		{
			//  data we also have:
			// _data.vendorQuantity
			// _data.vendorPrice
			
			super.populateData();
			
			if (!_data) return;
			
			visible = true;
			
			tfItemName.text = CommonUtils.toUpperCaseSafe( _data.ItemName );
			tfItemName.width = tfItemName.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			tfItemType.htmlText = CommonUtils.toUpperCaseSafe( _data.ItemType );
			tfItemType.width = tfItemType.textWidth + CommonConstants.SAFE_TEXT_PADDING;
			
			var bkHeight:Number = tfItemType.y + tfItemType.height + BK_PADDING;
			var bkWidth:Number;
			
			if (_data.vendorPrice)
			{
				var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

				btnBuy.clickable = false;
				btnBuy.label = _data.vendorInfoText;
				btnBuy.setDataFromStage(isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, KeyCode.RIGHT_MOUSE);
				//HACK : for some reason adding a Tap listener for these buttons wont work. So hack it with stage + hitTest
				stage.addEventListener( GestureEventEx.GESTURE_TAP, onBuyButtonTap, false, 0, true );
				btnBuy.validateNow();
				btnBuy.visible = true;
				
				var btnWidth:Number = btnBuy.getViewWidth();
				var btnHeight:Number = 40;
				var vendorInfoWidth:Number = btnWidth + mcCoinIcon.width + ICON_PADDING;
				
				mcCoinIcon.x = btnBuy.x + btnWidth + ICON_PADDING;
				mcCoinIcon.visible = true;
				
				bkHeight = btnBuy.y + btnHeight;
				bkWidth = Math.max(vendorInfoWidth, Math.max( tfItemName.width, tfItemType.width ) ) ;
			}
			else
			{
				btnBuy.visible = false;
				mcCoinIcon.visible = false;
				bkWidth = Math.max( tfItemName.width, tfItemType.width )
			}
			
			mcBackground.width = bkWidth + BK_PADDING;
			mcBackground.height = bkHeight;
		}

		private function onBuyButtonTap( event : GestureEvent ) : void
		{
			if ( btnBuy && btnBuy.mcClickRect.hitTestPoint(event.stageX, event.stageY) )
			{
				var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
				CommonUtils.simulateKeyInputEvent( KeyCode.PAD_Y_TRIANGLE, InputValue.KEY_DOWN, isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y );
				CommonUtils.simulateKeyInputEvent( KeyCode.PAD_Y_TRIANGLE, InputValue.KEY_UP, isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y );
			}
		}
	}
}
