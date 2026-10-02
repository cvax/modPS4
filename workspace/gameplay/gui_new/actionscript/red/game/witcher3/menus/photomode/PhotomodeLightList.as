package red.game.witcher3.menus.photomode
{
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	import flash.utils.getDefinitionByName;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.controls.ButtonBar;
	import scaleform.clik.events.IndexEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.interfaces.IDataProvider;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.controls.Button;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.text.TextField;
	import flash.display.MovieClip;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import scaleform.clik.events.ListEvent;
	import red.game.witcher3.utils.CommonUtils;
	import flash.events.MouseEvent;
	
	public class PhotomodeLightList extends UIComponent
	{			
		public var tfSelectedItemText : TextField;
		public var tfSelectedItemName : TextField;

        public var mc_LightCatSelector : PhotomodeSelectorRenderer;

		public var mcLightSlotList : SlotsListGrid;
		private var currentSelectedEnity : String;

		public function PhotomodeLightList() 
		{
            super();
        }

		override protected function configUI():void
		{
			super.configUI();

			mc_LightCatSelector.setDropDownBackgroundVisible(false);

			SetupLightSlots();

			dispatchEvent( new GameEvent( GameEvent.REGISTER, "photomode.lightlist", [fillLightFilter] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "photomode.light.list.update", [ updateLightList ] ) );

			tfSelectedItemText.text = "[[photomode_lightlist_selectedlight]]";
			updateSelectedText("[[photomode_lightlist_selectedlight_none]]");
		}

		public function SetupLightSlots()
		{
			if (mcLightSlotList)
			{
				mcLightSlotList.enableTouch( true );
				mcLightSlotList.enableScrollWithPan( true );
				mcLightSlotList.focusable = false;
				//_inputHandlers.push(mcLightSlotList);
				mcLightSlotList.visible = true;
				mcLightSlotList.handleScrollBar = true;
				mcLightSlotList.ignoreGridPosition = true;
				//mcLightSlotList.addEventListener( ListEvent.INDEX_CHANGE, onLightSelectionChanged, false, 0, true );
				mcLightSlotList.addEventListener( ListEvent.ITEM_CLICK, onLightSelectionChanged, false, 0, true );
			}
		}

		public function updateSelectedText(newText : String): void
		{
			tfSelectedItemName.text = newText;
		}

		protected function onLightSelectionChanged( event:ListEvent ):void
		{				
			var selectedItem:PhotomodeGridSlot = mcLightSlotList.getRendererAt(event.index) as PhotomodeGridSlot;

			if(currentSelectedEnity != selectedItem.entityName)
			{
				//trace("Debug UI: onLightSelectionChanged 1. currentSelectedEnity: " +currentSelectedEnity+" selectedItem.entityName: "+ selectedItem.entityName + " selectedItem.iconPath: "+selectedItem.iconPath)
				updateSelectedText(selectedItem.displayName);
				currentSelectedEnity = selectedItem.entityName;
			}
			else
			{
				//trace("Debug UI: onLightSelectionChanged 2. currentSelectedEnity: " +currentSelectedEnity+" selectedItem.entityName: "+ selectedItem.entityName + " selectedItem.iconPath: "+selectedItem.iconPath)
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnSelectLightFromList",[currentSelectedEnity , selectedItem.iconPath] ) );	
			}				
		}

		// created for calling from .ws scripts
		public function fillLightFilter(obj : Object) : void
		{
			var sliderModel : PhotomodeSliderDataModel = new PhotomodeSliderDataModel();
			var dataObj : Object = { data: obj[0] }; 

			sliderModel.setDataModel.apply(sliderModel, obj[0].args);
			dataObj["sliderData"] = sliderModel;			
				
			mc_LightCatSelector.setData(dataObj);
		}

		protected function updateLightList(itemsList:Array):void
		{
			for each (var curDataStub in itemsList)
			{					
				mcLightSlotList.updateItemData(curDataStub);
			}
		}
	}
}