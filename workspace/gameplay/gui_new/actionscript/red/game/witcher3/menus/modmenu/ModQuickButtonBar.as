/***********************************************************************
/** ModQuickButtonBar
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.display.MovieClip;
	import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;
    import flash.utils.getDefinitionByName;
    import flash.events.MouseEvent;

    import scaleform.clik.core.UIComponent;

    import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

    import red.core.events.GameEvent;
    import red.game.witcher3.utils.CommonUtils;

	public class ModQuickButtonBar extends UIComponent
	{
        // CONSTS
        private static const BUTTON_GAP : Number = 8;
        private static const FILTER_LISTER_GAP : Number = 20;

		// ART CLIPS
        public var mcFilterButton : StatusButton;
        public var tfModsFound : TextField;
        public var tfFilters : TextField;
        public var mcNewButton : StatusButton;
        public var mcUpdatedButton : StatusButton;
        public var mcTrendingButton : StatusButton;
        public var mcPopularButton : StatusButton;

        
        // VARS
        private var cachedWidth : Number = 1000;
        private var lastSelectedButton:int = 0;

        private var filterIndex : int = 1;
        private var dataBindingKey : String = "mods.filters.list";

        override protected function configUI():void
        {
            mcFilterButton.scalingOption = "left";
            mcNewButton.scalingOption = "right";
            mcUpdatedButton.scalingOption = "right";
            mcTrendingButton.scalingOption = "right";
            mcPopularButton.scalingOption = "right";

            mcFilterButton.statusEnabled = false;
            mcNewButton.statusEnabled = false;
            mcUpdatedButton.statusEnabled = false;
            mcTrendingButton.statusEnabled = false;
            mcPopularButton.statusEnabled = false;

            mcFilterButton.addEventListener(StatusButtonEvent.RELEASED, onFiltersClicked);
            mcNewButton.addEventListener(StatusButtonEvent.RELEASED, onNewClicked);
            mcUpdatedButton.addEventListener(StatusButtonEvent.RELEASED, onUpdatedClicked);
            mcTrendingButton.addEventListener(StatusButtonEvent.RELEASED, onTrendingClicked);
            mcPopularButton.addEventListener(StatusButtonEvent.RELEASED, onPopularClicked);

            dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey, [analyzeFiltersReceived] ) );
        }

        public function setDataBindingKey(newKey:String):void
        {
            dispatchEvent( new GameEvent( GameEvent.UNREGISTER, dataBindingKey, [analyzeFiltersReceived] ) );
            dataBindingKey = newKey;
            dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey, [analyzeFiltersReceived] ) );
        }

        public function fillData(modCount : int):void
        {
            trace("GFX - MQBB - fillData", modCount);
            mcFilterButton.setText("[[panel_mods_show_filters]]");
            tfModsFound.htmlText = "[[panel_mods_found]]";
            tfModsFound.text = tfModsFound.text.replace("{x}", modCount);
            mcNewButton.setText("[[panel_mods_filter_new]]");
            mcUpdatedButton.setText("[[panel_mods_filter_updated]]");
            mcTrendingButton.setText("[[panel_mods_filter_trending]]");
            mcPopularButton.setText("[[panel_mods_filter_popular]]");
            positionElements();
        }

        public function setCachedWidth(w : Number):void
        {
            cachedWidth = w;
        }

        private function positionElements():void
        {
            trace("GFX - MQBB - positionElements");
            tfModsFound.x = mcFilterButton.getWidth() + BUTTON_GAP;
            mcPopularButton.x = cachedWidth - mcPopularButton.getWidth();
            mcTrendingButton.x = mcPopularButton.x -  mcTrendingButton.getWidth() - BUTTON_GAP;
            mcUpdatedButton.x = mcTrendingButton.x -  mcUpdatedButton.getWidth() - BUTTON_GAP;
            mcNewButton.x = mcUpdatedButton.x -  mcNewButton.getWidth() - BUTTON_GAP;

            tfFilters.x = tfModsFound.x + tfModsFound.textWidth + FILTER_LISTER_GAP;
            tfFilters.width = mcNewButton.x - tfFilters.x - FILTER_LISTER_GAP;
        }

        private function onFiltersClicked(event:StatusButtonEvent):void
        {
            if(parent is ModMenuBrowsePage)
                ModMenuBrowsePage(parent).onFilterToggle();
            mcFilterButton.statusEnabled = false;
        }

        private function onNewClicked(event:StatusButtonEvent):void
        {
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnRadioClicked", [filterIndex, ModStatics.MFST_DateMarkedLive, 1, 0]) );
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnRadioClicked", [filterIndex, ModStatics.MFSD_Descending, 1, 0]) );
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnApplyFilters", [filterIndex]) );
            mcNewButton.statusEnabled = false;
        }

        private function onUpdatedClicked(event:StatusButtonEvent):void
        {
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnRadioClicked", [filterIndex, ModStatics.MFST_DateUpdated, 1, 0]) );
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnRadioClicked", [filterIndex, ModStatics.MFSD_Descending, 1, 0]) );
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnApplyFilters", [filterIndex]) );
            mcUpdatedButton.statusEnabled = false;
        }

        private function onTrendingClicked(event:StatusButtonEvent):void
        {
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnRadioClicked", [filterIndex, ModStatics.MFST_Rating, 1, 0]) );
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnRadioClicked", [filterIndex, ModStatics.MFSD_Descending, 1, 0]) );
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnApplyFilters", [filterIndex]) );
            mcTrendingButton.statusEnabled = false;
        }

        private function onPopularClicked(event:StatusButtonEvent):void
        {
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnRadioClicked", [filterIndex, ModStatics.MFST_Rating, 1, 0]) );
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnRadioClicked", [filterIndex, ModStatics.MFST_DownloadsTotal, 1, 0]) );
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnApplyFilters", [filterIndex]) );
            mcPopularButton.statusEnabled = false;
        }

        public function selectLeft():Boolean
        {
            if(lastSelectedButton <= 0)
                return false;
            lastSelectedButton--;
            selectCurrent();
            return true;
        }

        public function selectRight():Boolean
        {
            if(lastSelectedButton >= 4)
                return false;
            lastSelectedButton++;
            selectCurrent();
            return true;
        }

        private function deselectButtons():void
        {
            mcFilterButton.setBackgroundFrame("default");
            mcPopularButton.setBackgroundFrame("default");
            mcTrendingButton.setBackgroundFrame("default");
            mcUpdatedButton.setBackgroundFrame("default");
            mcNewButton.setBackgroundFrame("default");
        }

        private function selectCurrent():void
        {
            deselectButtons();
            switch(lastSelectedButton)
            {
                case 0: mcFilterButton.setBackgroundFrame("hover"); break;
                case 1: mcNewButton.setBackgroundFrame("hover"); break;
                case 2: mcUpdatedButton.setBackgroundFrame("hover"); break;
                case 3: mcTrendingButton.setBackgroundFrame("hover"); break;
                case 4: mcPopularButton.setBackgroundFrame("hover"); break;
            }
        }

        public function onHitButton():void
        {
            switch(lastSelectedButton)
            {
                case 0: onFiltersClicked(null); break;
                case 1: onNewClicked(null); break;
                case 2: onUpdatedClicked(null); break;
                case 3: onTrendingClicked(null); break;
                case 4: onPopularClicked(null); break;
            }
            selectCurrent();
        }

        public function onSelect():void
        {
            selectCurrent();
        }

        public function deselect():void
        {
            deselectButtons();
        }

        public function getLastSelectedButtonIndex():int
        {
            return lastSelectedButton;
        }

        public function analyzeCurrentlyPressedQuickButton(data : Array):void
        {
            var sortMethod : int = 0;
            var sortDirection : int = 0;

            for(var i : int = 0; i < data.length; i++)
            {
                var obj : Object = data[i] as Object;
                if(obj.value == 1 && obj.index < 8)
                    sortMethod = obj.index;
                else if (obj.value == 1 && obj.index < 10)
                    sortDirection = obj.index - 8;
            }

            mcNewButton.statusEnabled = false;
            mcUpdatedButton.statusEnabled = false;
            mcTrendingButton.statusEnabled = false;
            mcPopularButton.statusEnabled = false;

            if(sortMethod == 4 && sortDirection == 1)
            {
                mcNewButton.statusName = "activated";
                mcNewButton.statusEnabled = true;
            }
            if(sortMethod == 5 && sortDirection == 1)
            {
                mcUpdatedButton.statusName = "activated";
                mcUpdatedButton.statusEnabled = true;
            }
            if(sortMethod == 3 && sortDirection == 1)
            {
                mcTrendingButton.statusName = "activated";
                mcTrendingButton.statusEnabled = true;
            }
            if(sortMethod == 6 && sortDirection == 1)
            {
                mcPopularButton.statusName = "activated";
                mcPopularButton.statusEnabled = true;
            }
        }

        public function analyzeFiltersReceived(data : Array):void
        {
            var result : Vector.<String> = new Vector.<String>();

            analyzeCurrentlyPressedQuickButton(data);

            for(var i : int = 0; i < data.length; i++)
            {
                var obj : Object = data[i] as Object;
                if(obj.value == 1 && obj.index >= 12)
                    result.push(obj.label);
            }
            setFilterData(result);
        }

        public function setFilterData(data : Vector.<String>):void
        {
            var done : Boolean = false;
            var maxFilters : int = data.length;

            while(true)
            {
                var result : String = "";

                for(var i : int = 0; i < maxFilters; i++)
                {
                    if(i != 0)
                        result += ", ";

                    result += data[i];
                }

                if(maxFilters != data.length)
                {
                    var append : String = CommonUtils.getLocalization("mods_filters_x_more");
                    //var append : String = "and {x} more";

                    append = append.replace("{x}", data.length - maxFilters);

                    result += " " + append;
                }

                tfFilters.text = result;

                if(tfFilters.textWidth < tfFilters.width)
                    break;
                maxFilters--;
            }
        }
	}
	
}