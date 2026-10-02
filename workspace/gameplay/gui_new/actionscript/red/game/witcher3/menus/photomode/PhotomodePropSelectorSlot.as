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
	import red.game.witcher3.controls.W3UILoaderSlot;

	public class PhotomodePropSelectorSlot extends UIComponent
	{	
		protected var _propsSelectorRenderer : red.game.witcher3.menus.photomode.PhotomodePropSelectorRenderer;
		protected var _slotID : int;

		private var spawnableName : String;
		private var imagePath : String;
		public var mc_cross : MovieClip;
		private var _selected :Boolean;
		protected var _imageLoader : W3UILoaderSlot;

		public function PhotomodePropSelectorSlot() 
		{
            super();
        }

		override protected function configUI():void 
		{
			super.configUI();
			
			addEventListener(MouseEvent.MOUSE_OVER, onMoveButtonMouseEnter);
			addEventListener(MouseEvent.MOUSE_OUT, onMoveButtonMouseLeft);			
			addEventListener(MouseEvent.CLICK, onSlotClick);
        }

		public function InitializePhotomodePropSelectorSlot(
			propsSelectorRenderer : red.game.witcher3.menus.photomode.PhotomodePropSelectorRenderer , 
			slotID: int, 
			newSpawnableName : String , 
			newImagePath : String)
		{
			_propsSelectorRenderer = propsSelectorRenderer;
			_slotID = slotID;

			if(newSpawnableName == "" || newSpawnableName == "none")
			{	
				ClearSlot();			
			}
			else
			{	
				FillSlot(newSpawnableName , newImagePath);
			}
		}

		public function FillSlot(newSpawnableName : String, newImagePath : String)
		{
			spawnableName = newSpawnableName;
			imagePath = newImagePath;

			mc_cross.visible = false;
			loadIcon();
		}

		public function ClearSlot()
		{
			spawnableName = "none";
			imagePath = "";

			mc_cross.visible = true;
			unloadIcon();
		}

		protected function loadIcon():void
		{
			unloadIcon();
			_imageLoader = new W3UILoaderSlot();
			_imageLoader.maintainAspectRatio = false;
			_imageLoader.autoSize = false;
			_imageLoader.source = imagePath;
			_imageLoader.mouseChildren = false;
			_imageLoader.mouseEnabled = false;			
			_imageLoader.scaleX = 1;
			_imageLoader.scaleY = 1;
			_imageLoader.width = 64;
			_imageLoader.height = 64;
			// _imageLoader.content.width = 64;
			// _imageLoader.content.height = 64;
			_imageLoader.x = -32;
			_imageLoader.y = -32;
			addChild(_imageLoader);
		}

		protected function unloadIcon():void
		{
			if (_imageLoader)
			{
				_imageLoader.unload();
				removeChild(_imageLoader);
				_imageLoader = null;
			}
		}

		private function onSlotClick(event:MouseEvent)
		{			
			_propsSelectorRenderer.onSlotSelect(_slotID);
		}

		public function selectSlot()
		{	
			_selected = true;
			gotoAndStop("up");
		}

		public function deselectSlot()
		{
			_selected = false;
			gotoAndStop("blank");
		}
		
		private function onMoveButtonMouseEnter(event:MouseEvent)
        {
			gotoAndStop("over");
        }
        
        private function onMoveButtonMouseLeft(event:MouseEvent)
        {	if(_selected)
			{
				gotoAndStop("up");
			}
			else
			{
				gotoAndStop("blank");
			}        	
        }		
	}
}