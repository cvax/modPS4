/***********************************************************************
/** Mod Menu paginator controller / page selector 
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.display.MovieClip;
    import flash.utils.getDefinitionByName;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;

    import scaleform.clik.core.UIComponent;

    import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

    import red.core.events.GameEvent;
    import red.core.CoreComponent;

	public class ModPaginatorController extends UIComponent
	{
        // CONSTS
        private static const PAGINATOR_START_PAGES = 1;
		private static const PAGINATOR_BEFORE_PAGES = 2;
        private static const PAGINATOR_AFTER_PAGES = 2;
        private static const PAGINATOR_END_PAGES = 1;
        private static const PAGINATOR_GAP = 5;

        // ART CLIPS
        public var invBG    :   MovieClip;

        // VARS
        public var expectedWidth : Number;
        private var paginators : Vector.<MovieClip>;
        private var cachedCurrentPage : int;
        private var cachedNumPages : int;
        private var cachedPageArray : Array = [];
        private var _currentPaginatorIndex : int;

        public var m_filterIndex : int = 1;

        protected function get menuName():String { return "ModMenu"; }
		function ModPaginatorController()
		{
            super();
            paginators = new Vector.<MovieClip>();
            expectedWidth = width;
		}
		
		override protected function configUI():void
		{
            invBG.alpha = 0;
			super.configUI();
		}

        ///////////////////////////////////////////////////////////////////////////////
		// CREATION LOGIC
		///////////////////////////////////////////////////////////////////////////////

        public function clearPaginators()
        {
            while(paginators.length > 0)
			{
				var paginator : MovieClip = paginators.pop();
				if(paginator.parent)
					paginator.parent.removeChild(paginator);
			}
        }

        public function centralizePaginators()
        {
            trace("GFX -- centralizePaginators", paginators.length);
            var totalWidth:int = 0;
            for(var j: int = 0; j < paginators.length; j++)
            {
                var btn : MovieClip = paginators[j];
                totalWidth += btn.width;
                if(j < paginators.length - 1)
                    totalWidth += PAGINATOR_GAP;
            }

            var xPos:int = (expectedWidth - totalWidth) / 2;
            invBG.x = xPos;

            trace("GFX -- totalwidth/xPos", totalWidth, xPos);

            for(var i:int = 0; i < paginators.length; i++)
            {
                var button : MovieClip = paginators[i];
                button.x = xPos;
                xPos += button.width + PAGINATOR_GAP;
            }

            invBG.width = totalWidth;
        }

        public function createPaginators(numPages: int, currentPage: int)
        {
            clearPaginators();

            cachedNumPages = numPages;
            cachedCurrentPage = currentPage;

            var pages       :Array = [];
            var pageNums    :Array = [];
            var startSet    :Array = [];
            var middleSet   :Array = [];
            var endSet      :Array = [];

            var startLimit:int = Math.min(PAGINATOR_START_PAGES, numPages);
            var endStart:int = Math.max(numPages - PAGINATOR_END_PAGES + 1, startLimit + 1);

            var middleStart:int = Math.max(currentPage - PAGINATOR_BEFORE_PAGES, startLimit + 1);
            var middleEnd:int = Math.min(currentPage + PAGINATOR_AFTER_PAGES, endStart - 1);

            //Start pages
            for (var i : int = 1; i <= startLimit; i++)
            {
                startSet.push(i);
            }

            //Middle pages
            for ( i = middleStart; i <= middleEnd; i++)
            {
                middleSet.push(i);
            }

            //End pages
            for ( i = endStart; i <= numPages; i++)
            {
                endSet.push(i);
            }

            if(currentPage > 1)
                pages = ["<-"];

            pageNums = startSet;

            if(middleSet.length > 0 && middleStart > startLimit + 1)
            {
                pageNums.push("...");
            }
            pageNums = pageNums.concat(middleSet);

            if (endSet.length > 0 && middleEnd < endStart - 1)
            {
                pageNums.push("...");
            }
            pageNums = pageNums.concat(endSet);

            if(CoreComponent.isArabicAligmentMode)
                pageNums = pageNums.reverse();

            pages = pages.concat(pageNums);

            if(currentPage < numPages)
                pages.push("->");

            for(var j : int = 0; j < pages.length; j++)
            {
                var pageData:* = pages[j];

				var classRef:Class = getDefinitionByName("ModPaginator") as Class;
				var btn:MovieClip = new classRef() as MovieClip;

                btn.mcText.text = String(pageData);

                btn.mouseChildren = false;
                btn.mouseEnabled = true;

                addChild(btn);
                paginators.push(btn);
                btn.width = 48;
                btn.height = 48;

                btn.pageData = pageData;

                if(pageData is int)
                {
                    btn.pageNumber = pageData;

                    if(pageData == currentPage)
                    {
                        btn.gotoAndStop("current");
                        _currentPaginatorIndex = paginators.length - 1;
                        var format:TextFormat = new TextFormat();
                        format.color = 0xC9BDB5;
                        btn.mcText.setTextFormat(format);
                    }
                    else {
                        btn.gotoAndStop("regular");
                        btn.addEventListener(MouseEvent.CLICK, onPaginatorClick);
                        btn.addEventListener(MouseEvent.MOUSE_OVER, onPaginatorMouseOver);
                        btn.addEventListener(MouseEvent.MOUSE_OUT, onPaginatorMouseOut);
                    }
                }
                else
                {
                    var pageString = pageData as String;
                    if(pageString == "...")
                        btn.gotoAndStop("dots");
                    else {
                        btn.mcText.text = "";
                        trace("GFX - paginator string", pageString);


                        if(pageString == "->")
                            btn.gotoAndStop("next");
                        else if(pageString == "<-")
                            btn.gotoAndStop("previous");

                        btn.addEventListener(MouseEvent.CLICK, onPaginatorClick);
                        btn.addEventListener(MouseEvent.MOUSE_OVER, onPaginatorMouseOver);
                        btn.addEventListener(MouseEvent.MOUSE_OUT, onPaginatorMouseOut);
                    }
                }
            }
            
            centralizePaginators();
            cachedPageArray = pages;

            var browsePage = ModMenuBrowsePage(parent);
            if(browsePage)
            {
                browsePage.recalibratePaginatorBindings()
            }
        }

        ///////////////////////////////////////////////////////////////////////////////
		// INPUT HANDLING - NAVIGATION
		///////////////////////////////////////////////////////////////////////////////

        function onPageClick(page:int)
        {
            createPaginators(cachedNumPages, page);
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnPageClick", [m_filterIndex, page] ) );
        }

        function onPaginatorClick(e:MouseEvent):void
        {
            var btn:MovieClip = e.currentTarget as MovieClip;
            trace("GFX - Paginator click", btn.pageNumber);
            if(btn.pageData == "<-")
                onPageClick(cachedCurrentPage - 1);
            else if (btn.pageData == "->")
                onPageClick(cachedCurrentPage + 1);
            else 
                onPageClick(btn.pageNumber);
        }

        function onPaginatorMouseOver(e:MouseEvent):void
        {
            unHighlightPaginators();
            var btn:MovieClip = e.currentTarget as MovieClip;
            if(btn.pageData == "<-")     
                btn.gotoAndStop("hoverPrevious");
            else if(btn.pageData == "->")  
                btn.gotoAndStop("hoverNext");
            else           
                btn.gotoAndStop("hover");
        }

        function onPaginatorMouseOut(e:MouseEvent):void
        {
            var btn:MovieClip = e.currentTarget as MovieClip;
            trace("GFX########", btn.pageData);
            if(btn.pageData == "<-")     
                btn.gotoAndStop("previous");
            else if(btn.pageData == "->")  
                btn.gotoAndStop("next");
            else           
                btn.gotoAndStop("regular");
        }

        public function unHighlightPaginators()
        {
            for(var i : int = 0; i < paginators.length; i++)
            {
                if(cachedPageArray[i] is int && cachedPageArray[i] != cachedCurrentPage)
                    paginators[i].gotoAndStop("regular");
                else if (cachedPageArray[i] is String && (cachedPageArray[i] as String) == "<-")
                    paginators[i].gotoAndStop("previous");
                else if (cachedPageArray[i] is String && (cachedPageArray[i] as String) == "->")
                    paginators[i].gotoAndStop("next");
            }
        }

        public function onLeft():void
        {
            for(var i : int = _currentPaginatorIndex - 1; i >= 0; i--)
            {
                if(cachedPageArray[i] is int && cachedPageArray[i] != cachedCurrentPage)
                {
                    _currentPaginatorIndex = i;
                    unHighlightPaginators();
                    paginators[i].gotoAndStop("hover");
                    dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
                    break;
                }
            }
        }

        public function onRight():void
        {
            for(var i : int = _currentPaginatorIndex + 1; i < paginators.length; i++)
            {
                if(cachedPageArray[i] is int && cachedPageArray[i] != cachedCurrentPage)
                {
                    _currentPaginatorIndex = i;
                    unHighlightPaginators();
                    paginators[i].gotoAndStop("hover");
                    dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
                    break;
                }
            }
        }

        public function onHit():void
        {
            onPageClick(cachedPageArray[_currentPaginatorIndex]);
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_panel_open"] ) );
        }

        public function onLeave():void
        {
            unHighlightPaginators();
            GTweener.removeTweens(invBG);
            GTweener.to(invBG, 0.5, { alpha:0}, { ease:Exponential.easeOut } );
        }

        public function onEnter():void
        {
            var i: int = _currentPaginatorIndex;

            if(cachedPageArray[i] is int && cachedPageArray[i] != cachedCurrentPage)
                paginators[i].gotoAndStop("hover");

            dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );

            GTweener.removeTweens(invBG);
            GTweener.to(invBG, 0.5, { alpha:0.2}, { ease:Exponential.easeOut } );
        }

        public function canGoPreviousPage():Boolean
        {
            return cachedCurrentPage > 1;
        }

        public function canGoNextPage():Boolean
        {
            return cachedCurrentPage < cachedNumPages;
        }

        public function goPreviousPage():void
        {
            onPageClick(cachedCurrentPage - 1);
        }

        public function goNextPage():void
        {
            onPageClick(cachedCurrentPage + 1);
        }
		
	}
	
}