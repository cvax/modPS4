/***********************************************************************
/** Load handler for w3uiloaders
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.display.MovieClip;
    import flash.utils.Dictionary;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.getDefinitionByName;
    import flash.events.MouseEvent;

    import scaleform.clik.core.UIComponent;

    import red.core.events.GameEvent;
    import red.game.witcher3.controls.W3UILoader;

	public class ModImageLoadHandler extends UIComponent
	{
        // CONSTS

		// ART CLIPS

        // VARS
        public var wsFunctionName = 'OnRequestMediaLogo';
        var loaderMap:Dictionary = new Dictionary();


        public function ModImageLoadHandler() 
		{
            super();
		}
        protected function get menuName():String { return "ModMenu"; }
        override protected function configUI():void
		{
		}

        public function getModIdResolutionString(modid:String,resolution:String, galleryIndex:int = -1):String
        {
            var str : String = modid + "_" + resolution;
            if(galleryIndex >= 0)
                str += "_" + galleryIndex;
            return str;
        }

        public function addLoader(loader:W3UILoader, modid:String, galleryIndex:int = -1, resolution:String = ModImageData.ORIGINAL):void
        {
            var submitable : Boolean = false;
            var key : String = getModIdResolutionString(modid, resolution, galleryIndex); 
            //trace("GFX - addLoader",modid, resolution, galleryIndex);
            if(!(key in loaderMap))
            {
                loaderMap[key] = new Vector.<W3UILoader>();
                submitable = true;
                //trace("GFX - New modid entry added");
            }
            var result = loaderMap[key] as Vector.<W3UILoader>;

            if(result)
            {
                result.push(loader);
                //trace("GFX - Pushed back entry", modid, resolution);
            }
            //else trace("GFX - Result not exist");

            if(submitable)
                submitToLoading(modid, resolution, galleryIndex);
        }

        public function removeLoader(loader:W3UILoader)
        {
            for(var key:String in loaderMap)
            {
                var result : Vector.<W3UILoader> = loaderMap[key];
                for(var i = result.length - 1; i >= 0; i--)
                {
                    if(result[i] == loader)
                        result.splice(i, 1);
                }
            }
        }

        public function submitToLoading(modid:String, resolution:String, galleryIndex:int):void
        {
            if(galleryIndex < 0)
                dispatchEvent(new GameEvent( GameEvent.CALL, wsFunctionName, [modid, resolution]) );
            else
                dispatchEvent(new GameEvent( GameEvent.CALL, wsFunctionName, [modid, resolution, galleryIndex]) );
            //trace("Dispatching to", wsFunctionName, modid);
        }

        public function onImageLoaded(modid:String,resolution:String,imgPath:String,galleryIndex:int = -1):void
        {
            trace("GFX ## onImageLoaded",modid,resolution,imgPath);
            var key : String = getModIdResolutionString(modid,resolution,galleryIndex); 
            var loaders : Vector.<W3UILoader> = loaderMap[key] as Vector.<W3UILoader>;
            if(loaders)
            {
                //trace("GFX ## loaders exist");
                for(var i: int = 0; i < loaders.length; i++)
                {
                    if(loaders[i])
                        loaders[i].source = imgPath;
                }
                delete loaderMap[key];
            }
            //else trace("GFX ## no loaders, huh??")
            //trace("GFX @@@@@@@@@@@ onImageLoaded finished")
        }
	}
	
}