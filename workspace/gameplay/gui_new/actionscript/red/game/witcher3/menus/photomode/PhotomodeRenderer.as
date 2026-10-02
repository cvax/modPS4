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
	import red.core.constants.KeyCode;
	import flash.events.KeyboardEvent;
	import red.core.events.GameEvent;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import red.game.witcher3.managers.InputManager;
	import flash.events.MouseEvent;
	
	public class PhotomodeRenderer extends BaseListItem implements IListItemRenderer
	{	
		public var allowValueChangeEvents : Boolean = true;

		public function PhotomodeRenderer() 
		{
            super();
			preventAutosizing = true;
			mouseEnabled = true;
            mouseChildren = true;
        }

		override protected function configUI():void
		{
			super.configUI();
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseOnThis);
		}

		//To be called when we destroy - clean up event handlers 
		public function onDestroy():void
        {

        }

		public function onUpdateParam( param:Object ):void
        {
        }

		private function onMouseOnThis(event : MouseEvent)
		{
			onRequestParentSelectionChangeToThis();
		}

		private function onRequestParentSelectionChangeToThis()
		{
			var elem : PhotomodeMenuElement = parent as PhotomodeMenuElement;

			if(elem)
			{
				elem.tabbedMenu.m_content.selectedIndex = elem.index;
			}
		}
	}
}