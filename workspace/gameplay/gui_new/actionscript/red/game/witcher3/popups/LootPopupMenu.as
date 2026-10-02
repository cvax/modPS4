package red.game.witcher3.popups
{
	import flash.events.MouseEvent;
	import flash.display.MovieClip;

	import red.core.CorePopup;
	import red.core.events.GameEvent;
	import red.game.witcher3.hud.modules.lootpopup.HudLootItemModule;
	import red.game.witcher3.managers.ContextInfoManager;
	import red.game.witcher3.managers.RuntimeAssetsManager;
	
	import scaleform.clik.events.InputEvent;

	/**
	 * System messages
	 * @author Jason Slama
	 */
	public class LootPopupMenu extends CorePopup
	{
		public var mcLootItemModule : HudLootItemModule;
		protected var _contextMgr:ContextInfoManager;
		protected var _assetsMgr:RuntimeAssetsManager;
		

		public function LootPopupMenu()
		{
			_enableInputValidation = true;
			
			mcLootItemModule.mcInputFeedback.filterKeyCodeFunction = isKeyCodeValid;
			mcLootItemModule.mcInputFeedback.filterNavCodeFunction = isNavEquivalentValid;

			visible = false;
		}
		
		override protected function get popupName():String { return "LootPopup" } 
		
		override protected function configUI():void
		{
			super.configUI();
			
			registerDataBinding( "LootItemList", mcLootItemModule.handleItemListData );
			registerDataBinding( "LootItemList", resetVisibility);
			
			stage.addEventListener( InputEvent.INPUT, mcLootItemModule.handleInput, false, 0, true );
			
			mcLootItemModule._bWaitForKey = true;
			mcLootItemModule.visible = false;
			
			//dispatchEvent( new GameEvent( GameEvent.REGISTER, 'message.show', [showMessage]));
			
			//playStartupAnim();
			//mcMessageModule.focused = 1;

			initManagers();
			
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnConfigUI' ) );
		}

		private function resetVisibility(gameData:Object, index:int)
		{
			visible = true;
		}

		private function initManagers():void
		{
			var _overlayCanvas : MovieClip = new MovieClip();
			_overlayCanvas.mouseChildren = _overlayCanvas.mouseEnabled = false;
			addChild(_overlayCanvas);

			_contextMgr = ContextInfoManager.getInstanse();
			_contextMgr.init(_overlayCanvas, _inputMgr);
			_contextMgr.addGridEventsTooltipHolder(stage, false);

			_assetsMgr = RuntimeAssetsManager.getInstanse();
			_assetsMgr.loadLibrary();
		}
		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		override public function setPlatform(platformType:uint):void
		{
			super.setPlatform(platformType);

			mcLootItemModule.setPlatform(platformType);
		}
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function SetWindowTitle( _Title : String )
		{
			mcLootItemModule.tfTitle.text = _Title;
		}
		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function SetWindowScale( scale : Number )
		{
			mcLootItemModule.scaleX = scale;
			mcLootItemModule.scaleY = scale;
			mcLootItemModule.visible = true;
		}
		
		public function resizeBackground( value:Boolean ):void
		{
			mcLootItemModule.resizeBackground( value );
		}
		
		//>------------------------------------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------------------------------------
		public function SetSelectionIndex( _Index:int )
		{
			mcLootItemModule.m_indexToSelect = _Index;
		}
	}
}
