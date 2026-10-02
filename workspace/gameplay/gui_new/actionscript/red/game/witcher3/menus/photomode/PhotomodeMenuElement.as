package red.game.witcher3.menus.photomode 
{
	import flash.display.MovieClip;
    import flash.utils.getDefinitionByName;
    import flash.events.KeyboardEvent;
    import flash.events.Event;
    import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
    import flash.text.TextField;

    import scaleform.clik.controls.Slider;
    import scaleform.clik.data.ListData;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.events.SliderEvent;


	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.menus.photomode.PhotomodeSliderDataModel;
	import red.game.witcher3.managers.InputManager;
	
	public class PhotomodeMenuElement extends BaseListItem implements IListItemRenderer
	{		
        private var _photomodeRenderer : PhotomodeRenderer;

        private var allowValueChangeEvents : Boolean = true;

        public var tabbedMenu : PhotomodeTabbedMenu;
		
		public function PhotomodeMenuElement() 
		{
            super();
			preventAutosizing = true;

            tabbedMenu = parent as PhotomodeTabbedMenu;
        }
		
        public override function set selected(value:Boolean):void 
		{
            super.selected = value;

            //Zeroing focus because of double focus on slider thumb, and arrow key value change
            stage.focus = null;

            if(_photomodeRenderer)
                _photomodeRenderer.selected = value;
        }
		
        public function GetPhotoModeRenderer() : PhotomodeRenderer
        {
            return _photomodeRenderer;
        }

        public override function set enabled(value:Boolean):void 
		{
	        super.enabled = value;

			if(_photomodeRenderer)
                _photomodeRenderer.enabled = value;
        }
		
        public function createRenderer(data:Object):void
        {
            if(_photomodeRenderer) {
                _photomodeRenderer.onDestroy();
                removeChild(_photomodeRenderer);
            }

            var classRef:Class;

            switch(data.data.rendererType)
            {
                case "slider":
                    classRef = getDefinitionByName("PhotomodeSliderRenderer") as Class;
				    _photomodeRenderer = new classRef() as PhotomodeSliderRenderer;
                    (_photomodeRenderer as PhotomodeSliderRenderer).wasdNavigation = false;
                    (_photomodeRenderer as PhotomodeSliderRenderer).l_stickNavigation = false;
                    addChild(_photomodeRenderer);
                    break;
                case "selector":
                    classRef = getDefinitionByName("PhotomodeSelectorRenderer") as Class;
				    _photomodeRenderer = new classRef() as PhotomodeSelectorRenderer;
                    addChild(_photomodeRenderer);
                    break;
                case "saver":
                    classRef = getDefinitionByName("PhotomodeSaverRenderer") as Class;
				    _photomodeRenderer = new classRef() as PhotomodeSaverRenderer;
                    addChild(_photomodeRenderer);
                    break;
                case "charSlotSelector":
                    classRef = getDefinitionByName("PhotomodeCharacterSelectorRenderer") as Class;
				    _photomodeRenderer = new classRef() as PhotomodeCharacterSelectorRenderer;
                    addChild(_photomodeRenderer);
                    break;
                case "propsSlotSelector":
                    classRef = getDefinitionByName("PhotomodePropSelectorRenderer") as Class;
				    _photomodeRenderer = new classRef() as PhotomodePropSelectorRenderer;
                    addChild(_photomodeRenderer);
                    break;
                 case "lightSlotSelector":
                    classRef = getDefinitionByName("PhotomodeLightSelectorRenderer") as Class;
				    _photomodeRenderer = new classRef() as PhotomodeLightSelectorRenderer;
                    addChild(_photomodeRenderer);
                    break;
                case "colorSlider":
                    classRef = getDefinitionByName("PhotomodeColorSliderRenderer") as Class;
				    _photomodeRenderer = new classRef() as PhotomodeColorSliderRenderer;
                    addChild(_photomodeRenderer);
                    break;
                case "buttonRenderer":
                    classRef = getDefinitionByName("PhotomodeResetButtonsRenderer") as Class;
				    _photomodeRenderer = new classRef() as PhotomodeResetButtonsRenderer;
                    addChild(_photomodeRenderer);
                    break;
            }

            if(_photomodeRenderer) {
                _photomodeRenderer.x = 0;
                _photomodeRenderer.y = 0;
                _photomodeRenderer.setData(data);
                _photomodeRenderer.selected = selected;
                _photomodeRenderer.allowValueChangeEvents = allowValueChangeEvents;
            }
        }
        
        public override function setData(data:Object):void 
		{
			if (data == null)
				return;
			
			if(!_photomodeRenderer || _data.data.rendererType != data.data.rendererType)
                createRenderer(data);
            else 
                _photomodeRenderer.setData(data);
				
            mouseEnabled = true;
            mouseChildren = true;

            dispatchEvent(new Event("PM_ELEM_SETDATA"))
            
			_data = data;
        }
       
        override protected function configUI():void 
		{
			super.configUI();	
            mouseEnabled = true;
            mouseChildren = true;
        }

        public function onUpdateParam( param:Object )
        {
            if(_photomodeRenderer)
                _photomodeRenderer.onUpdateParam(param);
        }		

        public function setAllowValueChangeEvent(value : Boolean)
        {
            allowValueChangeEvents = value;
            if(_photomodeRenderer)
                _photomodeRenderer.allowValueChangeEvents = allowValueChangeEvents;

        }
	}
}