package red.game.witcher3.menus.blacksmith 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.constants.NavigationCode;
	import red.core.events.GestureEventEx;
	import flash.utils.setTimeout;
	
	/**
	 * Display info and repair cost for selected item
	 * @author Getsevich Yaroslav
	 */
	public class ItemRepairInfo extends BlacksmithItemPanel
	{
		public var txtDurabilityLabel:TextField;
		public var txtDurabilityValue:TextField;
		public var btnRepairAll : InputFeedbackButton;
		
		public function ItemRepairInfo()
		{			
			txtDurabilityLabel.text = "[[panel_inventory_tooltip_durability]]";
		}
		
		override protected function configUI():void 
		{
			super.configUI();

			btnRepairAll.label = "[[repair_equipped_items]]";
			btnRepairAll.visible = false;
			btnRepairAll.validateNow();
			btnRepairAll.addEventListener(MouseEvent.CLICK, handleRepairAllButtonClickOrTap, false, 0, true);
			btnRepairAll.addEventListener( GestureEventEx.GESTURE_TAP, handleRepairAllButtonClickOrTap, false, 0, true );

			setTimeout( configButtonDelayed_HACK, 0 ); 
		}

		private function configButtonDelayed_HACK() : void
		{
			//We have to do this because InputManager platform gets set AFTER this::configUI.

			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
			btnRepairAll.setDataFromStage(isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X, KeyCode.SPACE);
		}
		
		override protected function updateData():void 
		{
			super.updateData();
			
			trace("GFX updateData ", _data.durability);
			
			if (_data.durability)
			{
				txtDurabilityLabel.visible = true;
				txtDurabilityValue.text = Math.round( _data.durability ) + " %";
				txtDurabilityValue.visible = true;
			}
		}
		
		override protected function cleanupView():void 
		{
			super.cleanupView();
			txtDurabilityValue.text = "";
			txtDurabilityValue.visible = false;
			txtDurabilityLabel.visible = false;
		}
		
		private function handleRepairAllButtonClickOrTap(event:Event):void
		{
			dispatchEvent(new GameEvent(GameEvent.CALL, 'OnRepairAllItems'));
		}
		
	}
}
