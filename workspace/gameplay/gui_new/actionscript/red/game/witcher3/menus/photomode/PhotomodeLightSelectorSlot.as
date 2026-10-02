package red.game.witcher3.menus.photomode 
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.controls.Slider;
	import flash.text.TextField;
	import scaleform.clik.data.ListData;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.events.SliderEvent;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import flash.events.KeyboardEvent;
	import red.core.events.GameEvent;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import red.game.witcher3.menus.photomode.PhotomodeSliderDataModel;
	import red.game.witcher3.managers.InputManager;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import red.game.witcher3.slots.SlotsListGrid;
	import scaleform.clik.core.UIComponent;
	
	public class PhotomodeLightSelectorSlot extends UIComponent
	{	
		protected var _colorSelectorRenderer : red.game.witcher3.menus.photomode.PhotomodeLightSelectorRenderer;
		protected var _slotID : int;

		public function PhotomodeLightSelectorSlot() 
		{
            super();		
        }

		public function InitializePhotomodeLightSelectorSlot(propsSelectorRenderer : red.game.witcher3.menus.photomode.PhotomodeLightSelectorRenderer , slotID: int)
		{
			_colorSelectorRenderer = propsSelectorRenderer;
			_slotID = slotID;
		}

        override protected function configUI():void 
		{
			super.configUI();
			
			addEventListener(MouseEvent.MOUSE_OVER, onMoveButtonMouseEnter);
			addEventListener(MouseEvent.MOUSE_OUT, onMoveButtonMouseLeft);			
			addEventListener(MouseEvent.CLICK, onSlotClick);
        }

		private function onSlotClick(event:MouseEvent)
		{			
			_colorSelectorRenderer.onSlotClick(_slotID);
		}

		private function onMoveButtonMouseEnter(event:MouseEvent)
        {
			gotoAndStop("over");
        }
        
        private function onMoveButtonMouseLeft(event:MouseEvent)
        {
        	gotoAndStop("up");
        }
	}
}