/***********************************************************************
/** Mod Image Gallery
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.display.MovieClip;
    import flash.utils.getDefinitionByName;
    import flash.utils.Dictionary;
    import flash.events.MouseEvent;
    import flash.events.Event;

    import scaleform.clik.core.UIComponent;
    import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
    import scaleform.clik.ui.InputDetails;
    import scaleform.clik.constants.InputValue;

    import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

    import red.core.events.GameEvent;

    import red.game.witcher3.controls.W3UILoader;

	public class ModImageGallery extends UIComponent
	{
        //CONST
        private static const GALLERY_VERTICAL_GAP = 2;
        private static const GALLERY_HORIZONTAL_GAP = 2;
        private static const GALLERY_HORIZONTAL_GAP_EDGE = 2;
        private static const SCROLL_MOVE = 50;

        //ART CLIPS
        public var mcLoader 			: 	W3UILoader;
        public var mcGalleryImages      :   MovieClip;
        public var mcHighlight          :   MovieClip;
        public var mcLoadingAnim        :   MovieClip;

        //VARS
        private var galleryUrls          :  Array;
        private var galleryImages        :  Vector.<W3UILoader> = new Vector.<W3UILoader>();
        private var _mcGalleryImages_x   :  Number;
        private var _mcGalleryImages_y   :  Number;
        private var loaderData           :  Dictionary;
        private var selectedIndex        :  int;
        private var bSelected            :  Boolean;

        public function ModImageGallery()
		{
			super();
            galleryUrls = [];
            _mcGalleryImages_x = mcGalleryImages.x;
            _mcGalleryImages_y = mcGalleryImages.y;
		}

		protected function get menuName():String { return "ModMenu"; }
        override protected function configUI():void
        {
            super.configUI();
            mcGalleryImages.addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel)
            stage.addEventListener(InputEvent.INPUT, handleInputNavigate, false, 11, true);
            mcLoader.addEventListener( Event.COMPLETE, handleBigImageLoadComplete, false, 0, true );
            mcHighlight.visible = false;
        }

        private function startSelectAnimation_Up():void
        {
            GTweener.removeTweens(mcHighlight);
		    GTweener.to(mcHighlight, 0.7, { alpha:0.2 }, { onComplete: startSelectAnimation_Down } );
        }

        private function startSelectAnimation_Down():void
        {
            GTweener.removeTweens(mcHighlight);
		    GTweener.to(mcHighlight, 0.7, { alpha:0 }, { onComplete: startSelectAnimation_Up } );
        }

        private function startUnselectAnimation():void
        {
            GTweener.removeTweens(mcHighlight);
		    GTweener.to(mcHighlight, 0.4, { alpha:0 }, { onComplete: onUnselectAnimationComplete } );
        }

        private function onUnselectAnimationComplete():void
        {
            mcHighlight.visible = false;
        }

        public function onSelect():void
        {
            bSelected = true;
            mcHighlight.visible = true;
            mcHighlight.alpha = 0;
            startSelectAnimation_Up();
        }

        public function deselect():void
        {
            bSelected = false;
            startUnselectAnimation();
        }

        protected function handleBigImageLoadComplete(e:Event):void
		{
			//trace("handleBigImageLoadComplete load complete");
			mcLoadingAnim.visible = false;

			//removeChild(mcLoadingAnim);
			//addChild(mcLoadingAnim);
            //trace("handleBigImageLoadComplete load complete finish", mcLoadingAnim.visible, mcLoadingAnim.alpha);
		}


        protected function scrollRight( amount:Number ):void
        {
            var mostLeft : Number  = mcGalleryImages.x + galleryImages[0].x;
            var mostRight : Number  = mcGalleryImages.x + galleryImages[galleryImages.length - 1].x + galleryImages[galleryImages.length - 1].width;
            if(mostRight > _mcGalleryImages_x + mcLoader.width)
            {
                mcGalleryImages.x -= amount;
                if(mostRight - amount < _mcGalleryImages_x + mcLoader.width)
                {
                    mcGalleryImages.x = _mcGalleryImages_x + mcLoader.width - (mostRight - mostLeft);
                }
            }
        }

        protected function scrollLeft( amount:Number ):void
        {
            mcGalleryImages.x += amount;
            if(mcGalleryImages.x > _mcGalleryImages_x)
                mcGalleryImages.x = _mcGalleryImages_x;
        }

        protected function onMouseWheel(event:MouseEvent):void
        {
            if(galleryImages.length == 0)
                return;
            if(event.delta > 0) // scroll up
            {
                scrollLeft(SCROLL_MOVE);
            }
            else // scroll down
            {
                scrollRight(SCROLL_MOVE);
                //if(mcGalleryImages)
            }
            event.stopImmediatePropagation();
        }

        public function getSelectedIndex():int
        {
            return selectedIndex;
        }

        public function getMaxImageCount():int
        {
            return galleryImages.length;
        }

        protected function clearImages():void
		{
			while(galleryImages.length > 0)
			{
				var image : W3UILoader = galleryImages.pop();
				if(image.parent)
					image.parent.removeChild(image);
			}
		}

        public function setData(data:Object):void
        {
            //trace("GFX - ModImageGallery - Setting Data");
            mcLoadingAnim.visible = true;
            mcLoader.unload();

            if(data.gallery)
                galleryUrls = data.gallery;
            else galleryUrls = [data.modid];
            loaderData = new Dictionary(true);

            //Reseting mcGalleryImages to original position
            clearImages();
            mcGalleryImages.x = _mcGalleryImages_x;
            mcGalleryImages.y = _mcGalleryImages_y;
            if (data.hasOwnProperty("gallerySize"))
            {
                for(var j: int = 0; j < data.gallerySize; j++)
                {
                    createGalleryImage(data, j);
                }
                if(data.gallerySize > 0) 
                {
                    selectedIndex = 0;
                    selectGalleryElement(galleryImages[selectedIndex]);
                }
                else
                {
                    selectGalleryElement(null, true);
                }
            }
        }

        protected function createGalleryImage(data:Object, i : int)
        {
            var classRef:Class = getDefinitionByName("IconLoader169_BlackBG") as Class;
            var loader:W3UILoader = new classRef() as W3UILoader;

            setBGLoaderHeight(loader, mcGalleryImages.height - 2 * GALLERY_VERTICAL_GAP);
            setBGLoaderWidth(loader, loader.height * 16 / 9);

            mcGalleryImages.addChild(loader);
            loader.y = GALLERY_VERTICAL_GAP;
            loader.x = GALLERY_HORIZONTAL_GAP_EDGE + (i * (loader.width + GALLERY_HORIZONTAL_GAP));

            loaderData[loader] = i;

            loader.addEventListener(MouseEvent.MOUSE_OVER, onGalleryImageHoverIn);
            loader.addEventListener(MouseEvent.MOUSE_OUT, onGalleryImageHoverOut);
            loader.addEventListener(MouseEvent.CLICK, onGalleryImageClick);
            loader.addEventListener( Event.COMPLETE, handleLoadComplete, false, 0, true );

            if(data.modid)
            {
                callModMenuGalleryLoad(loader, i, ModImageData.P320);
            }
            galleryImages.push(loader);
        }

        protected function callModMenuGalleryLoad(loader:W3UILoader, i:int, quality:String = ModImageData.ORIGINAL)
        {
            if( ModStatics.getModMenu() )
                ModStatics.getModMenu().callGalleryLoad(loader,galleryUrls[0],i,quality);
        }

        protected function callModMenuGalleryRemove(loader:W3UILoader)
        {
            if( ModStatics.getModMenu() )
                ModStatics.getModMenu().callGalleryRemove(loader);
        }
        
        protected function callModMenuLogoLoad(loader:W3UILoader, quality:String = ModImageData.ORIGINAL)
        {
            if( ModStatics.getModMenu() )
                ModStatics.getModMenu().callLogoLoad(loader,galleryUrls[0],quality);
        }

        protected function unSelectGalleryImages():void
        {
            for(var i : int = 0; i < galleryImages.length; i++)
            {
                galleryImages[i].getChildByName("mcSelection").visible = false;
            }
        }

        protected function selectGalleryElement(currentTarget : W3UILoader, fallback: Boolean = false)
        {
            //trace("GFX - select gallery element")
            if(fallback)
            {
                callModMenuLogoLoad(mcLoader);
                return;
            }
            if(currentTarget)
            {
                var galleryIndex : int = loaderData[currentTarget];

                callModMenuGalleryRemove(mcLoader);
                callModMenuGalleryLoad(mcLoader, galleryIndex);
                
                selectedIndex = galleryIndex;

                unSelectGalleryImages();
                currentTarget.getChildByName("mcSelection").visible = true;
                currentTarget.getChildByName("mcSelection").alpha = 1;
            }
        }

        protected function onGalleryImageClick(event:MouseEvent)
        {
            var currentTarget : W3UILoader = event.currentTarget as W3UILoader;

            selectGalleryElement(currentTarget);
        }

        protected function onGalleryImageHoverIn(event:MouseEvent)
        {
            var currentTarget : W3UILoader = event.currentTarget as W3UILoader;

            if(!currentTarget.getChildByName("mcSelection").visible)
            {
                currentTarget.getChildByName("mcSelection").visible = true;
                currentTarget.getChildByName("mcSelection").alpha = 0.5;
            }
        }

        protected function onGalleryImageHoverOut(event:MouseEvent)
        {
            var currentTarget : W3UILoader = event.currentTarget as W3UILoader;

            if(currentTarget.getChildByName("mcSelection").alpha != 1)
            {
                currentTarget.getChildByName("mcSelection").visible = false;
            }
        }

        public function setBGLoaderWidth(loader : W3UILoader,width:Number)
        {
            loader.width = width;
            loader.getChildByName("blackBG").width = width;
            loader.getChildByName("mcSelection").width = width;
        }
        public function setBGLoaderHeight(loader : W3UILoader,height:Number)
        {
            loader.height = height;
            loader.getChildByName("blackBG").height = height;
            loader.getChildByName("mcSelection").height = height;
        }

        public function setLoaderPortrait( loader : W3UILoader, value : String )
		{
			//mcLoader.fallbackIconPath = "icons/inventory/bombs/something_does_not_exist.png";
			// #Y Cut first '\', if it exist, to prevent conflict with prefix 'img://'
			// TODO: Implement it to all UI Loaders
			if (value.charAt(0) == '\\')
			{
				value = value.slice(1, value.length);
			}
		    loader.source = "img://" + value;
		}

        protected function handleLoadComplete(e:Event):void
        {
            // #LT We disparent the selection and reparent it, so it will always be over the loaded image.
            var loader = e.target as W3UILoader;
            if(loader)
            {
                var selection : MovieClip = loader.getChildByName("mcSelection") as MovieClip;
                loader.removeChild(selection);
                loader.addChild(selection);
            }
        }


        protected function leftPushNeeded(currentTarget : W3UILoader):Number
        {
            var left:Number = mcGalleryImages.x + currentTarget.x;

            //trace("GFX - GalleryImage Visibility Left Check", _mcGalleryImages_x, left);

            return _mcGalleryImages_x - left;
        }

        protected function rightPushNeeded(currentTarget : W3UILoader):Number
        {
            var left:Number = mcGalleryImages.x + currentTarget.x;
            var right:Number = left + currentTarget.width;

            //trace("GFX - GalleryImage Visibility Right Check", right, _mcGalleryImages_x + mcLoader.width);

            return right - (_mcGalleryImages_x + mcLoader.width);
        }

        protected function doPush(currentTarget : W3UILoader):void
        {
            var leftNeeded:Number = leftPushNeeded(currentTarget);
            var rightNeeded:Number = rightPushNeeded(currentTarget);

            //trace("GFX ############ doPush - leftNeeded",leftNeeded);
            //trace("GFX ############ doPush - rightNeeded",rightNeeded);

            if(leftNeeded > 0)
                scrollLeft(leftNeeded);
            else if(rightNeeded > 0)
                scrollRight(rightNeeded);
        }


        protected function moveLeft()
        {
            if(selectedIndex > 0)
            {
                var currentElement: W3UILoader = galleryImages[selectedIndex];
                var leftElement: W3UILoader = galleryImages[selectedIndex - 1];

                doPush(leftElement);
                selectGalleryElement(leftElement);
                dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
            }
        }

        protected function moveRight()
        {
            if(selectedIndex < galleryImages.length - 1)
            {
                var currentElement: W3UILoader = galleryImages[selectedIndex];
                var rightElement: W3UILoader = galleryImages[selectedIndex + 1];

                doPush(rightElement);
                selectGalleryElement(rightElement);
                dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
            }
        }

        protected function handleInputNavigate(event:InputEvent):void
		{
			var details:InputDetails = event.details;

			if(!bSelected)
				return;

			//trace("GFX - ModPreview - handleInputNavigate", event);

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN; //#B should be also hold here
            var hold:Boolean = details.value == InputValue.KEY_HOLD;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;

			if (!event.handled)
			{
                if (details.navEquivalent == NavigationCode.LEFT && (keyDown || hold))
				{
					moveLeft();
                    event.handled = true;
				}
				else if (details.navEquivalent == NavigationCode.RIGHT && (keyDown || hold))
				{
                    if(selectedIndex < galleryImages.length - 1) {
					    moveRight();
                        event.handled = true;
                    }
                    else if(hold)
                        event.handled = true;
				}
			}
		}

	}
	
}