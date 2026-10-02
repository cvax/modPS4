/***********************************************************************
/** Text with a box
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.display.MovieClip;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.getDefinitionByName;
    import flash.events.MouseEvent;

    import scaleform.clik.core.UIComponent;
    import scaleform.clik.interfaces.IListItemRenderer;
    import scaleform.clik.data.DataProvider;
    import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;

    import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

    import red.core.events.GameEvent;
    import red.game.witcher3.controls.W3ScrollingList;

	public class ModDependencyModule extends UIComponent
	{
        // CONSTS
        protected static const DEPENDENCY_GAP:Number = 4;

		// ART CLIPS
		public var mcText 			    :   TextField;
        public var mcDependencyList     : 	W3ScrollingList;
        public var mcDependency1        :   ThinModPreview;
        public var mcDependency2        :   ThinModPreview;
        public var mcDependency3        :   ThinModPreview;

        public var _active               :   Boolean;
        public var funcHandleDoubleClick :  Function;

        public function get active():Boolean
        {
            return _active;
        }

        public function set active(value:Boolean):void
        {
            _active = value;
            mcDependency1.selected = mcDependency1.selected;
            mcDependency2.selected = mcDependency2.selected;
            mcDependency3.selected = mcDependency3.selected;
        }

        override protected function configUI():void
        {
            var renderers : Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>();
            renderers.push(mcDependency1 as IListItemRenderer);
            renderers.push(mcDependency2 as IListItemRenderer);
            renderers.push(mcDependency3 as IListItemRenderer);
            mcDependencyList.itemRendererList = renderers;

            stage.addEventListener(InputEvent.INPUT, handleInputNavigate, false, -9, true);
            mcDependency1.addEventListener(MouseEvent.DOUBLE_CLICK, handleItemDoubleClick);
            mcDependency2.addEventListener(MouseEvent.DOUBLE_CLICK, handleItemDoubleClick);
            mcDependency3.addEventListener(MouseEvent.DOUBLE_CLICK, handleItemDoubleClick);
        }

        public function setData(data:Array):void
        {
            mcDependencyList.dataProvider = new DataProvider(data);

            visible = data.length > 0;
            mcDependencyList.validateNow();

            if(data.length > 1)
            {
                mcText.text = "[[panel_mods_dependencies]]";
                //mcText.text = "Dependencies ({x}):";
                mcText.text = mcText.text.replace("{x}", data.length);
                mcDependencyList.selectedIndex = 0;
            }
            else
            {
                mcText.text = "[[panel_mods_dependency_single]]";
                //mcText.text = "Dependency:";
            }
        }

        public function getHeight():Number
        {
            if(mcDependencyList.dataProvider.length == 0)
                return 0;
            var count : int = Math.min(mcDependencyList.dataProvider.length,3);

            return mcText.height + count * mcDependency1.height + (count - 1) * DEPENDENCY_GAP;
        }

        public function hasData():Boolean
        {
            return mcDependencyList.dataProvider.length > 0;
        }

        protected function handleInputNavigate(event:InputEvent):void
		{
            if(!_active || !visible)
                return;

			var details:InputDetails = event.details;

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD; //#B should be also hold here
			var keyUp:Boolean = details.value == InputValue.KEY_UP;

			if (!event.handled)
			{
                if(details.navEquivalent == NavigationCode.DOWN && keyDown)
                {
                    if(mcDependencyList.selectedIndex < mcDependencyList.dataProvider.length - 1)
                    {
                        mcDependencyList.selectedIndex++;
                        event.handled = true;
                    }
                }
                else if(details.navEquivalent == NavigationCode.UP && keyDown)
                {
                    if(mcDependencyList.selectedIndex > 0)
                    {
                        mcDependencyList.selectedIndex--;
                        event.handled = true;
                    }
                }
			}
		}

        public function getSelectedDependency():ThinModPreview
        {
            if(mcDependency1.selected) return mcDependency1;
            if(mcDependency2.selected) return mcDependency2;
            if(mcDependency3.selected) return mcDependency3;

            return null;
        }
        
        protected function handleItemDoubleClick(event:MouseEvent):void
        {
            if(funcHandleDoubleClick != null)
                funcHandleDoubleClick(event.currentTarget);
        }
        

	}
	
}