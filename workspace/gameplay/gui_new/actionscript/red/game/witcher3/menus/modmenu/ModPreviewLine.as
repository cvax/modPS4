/***********************************************************************
/** Mod preview line for simple W3ScrollingList control logic
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
    import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.interfaces.IListItemRenderer;
    import scaleform.clik.events.InputEvent;

    import red.game.witcher3.utils.CommonUtils;

	public class ModPreviewLine extends ListItemRenderer implements IListItemRenderer
	{
        private var previews : Vector.<ModPreview> = new Vector.<ModPreview>

        public var invBG    :   MovieClip;

        override protected function configUI():void
        {
            super.configUI();
            invBG.mouseEnabled = false;
			invBG.mouseChildren = false;
            mouseChildren = true;
        }

        public function getPreviews():Vector.<ModPreview>
        {
            var prevs: Vector.<ModPreview> = new Vector.<ModPreview>;
            for(var i : int = 0; i < previews.length; i++)
            {
                if(previews[i].visible)
                    prevs.push(previews[i]);
            }
            return prevs;
        }

        public function getHeight():Number
        {
            if(previews.length > 0)
                return previews[0].getHeight();
            return 0;
        }

        public function getWidth():Number
        {
            if(previews.length > 0)
                return previews.length * (previews[0].getWidth() + ModStatics.MOD_PREVIEW_GAP_X);
            return 0;
        }

        public function reservePreviews( len:int):void
        {
            for( var i:int = 0; i < len; i++)
            {
                var modPreview:ModPreview;
                if(previews.length > i)
                {
                    modPreview = previews[i];
                }
                else {
                    var classRef:Class = getDefinitionByName("ModPreview") as Class;
                    var modPreviewNew:ModPreview = new classRef() as ModPreview;
                    addChild(modPreviewNew);
                    previews.push(modPreviewNew);
                    modPreview = modPreviewNew;
                }
                modPreview.x = i * (modPreview.getWidth() + ModStatics.MOD_PREVIEW_GAP_X);
                modPreview.y = 0;
                modPreview.columnIndex = i;
                modPreview.visible = true;
            }
        }

        override public function setData( data:Object ):void
        {
            //check for initial wrong first dataset
            if(!data.hasOwnProperty("modArray"))
                return;
            super.setData(data);
            var arr: Array = data.modArray;
            mouseChildren = true;
            mouseEnabled = true;

            for( var i:int = 0; i < arr.length; i++)
            {
                var modPreview:ModPreview;
                if(previews.length > i)
                {
                    modPreview = previews[i];
                }
                else {
                    var classRef:Class = getDefinitionByName("ModPreview") as Class;
                    var modPreviewNew:ModPreview = new classRef() as ModPreview;
                    addChild(modPreviewNew);
                    previews.push(modPreviewNew);
                    modPreview = modPreviewNew;
                }
                modPreview.x = i * (modPreview.getWidth() + ModStatics.MOD_PREVIEW_GAP_X);
                modPreview.y = 0;
                modPreview.columnIndex = i;
                modPreview.visible = true;
                modPreview.setData(arr[i]);
            }
            
            for( i = arr.length; i < previews.length; i++ )
            {
                var modPrev:ModPreview = previews[i];
                modPrev.visible = false;
            }
            setImages(data);
        }

        protected function setImages( data:Object)
        {
            var arr: Array = data.modArray;
            for( var i:int = 0; i < arr.length; i++)
            {
                var modPreview:ModPreview = previews[i];
                if(!previews[i].visible)
                    continue;
                modPreview.setImage(arr[i]);
            }
        }

        public function selectPreview(index:int)
        {
            if(index < 0 || index >= previews.length)
                trace("GFX - ERROR - ModPreviewLine:selectPreview: Index out of reach");

            for(var i:int = 0; i < previews.length; i++)
            {
                var modPreview:ModPreview = previews[i] as ModPreview;
                
                if(index == i)
                    modPreview.onSelect();
                else
                    modPreview.deselect();
            }
        }

        public function getPreviewCount():int
        {
            return getPreviews().length;
        }

        override public function handleInput(event:InputEvent):void
        {
            if(CommonUtils.isActuallyVisible(this))
                super.handleInput(event);
        }

	}
}