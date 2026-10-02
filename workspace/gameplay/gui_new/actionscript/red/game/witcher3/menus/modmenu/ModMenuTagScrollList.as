/***********************************************************************
/** Scrollable list of tags
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.getDefinitionByName;
    import flash.events.MouseEvent;

    import scaleform.clik.core.UIComponent;
    import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
    import scaleform.clik.ui.InputDetails;
    import scaleform.clik.constants.InputValue;

    import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

    import red.core.events.GameEvent;

	public class ModMenuTagScrollList extends UIComponent
	{
        // CONSTS
        private static const TAG_GAP_X = 25;
        private static const TAG_END_X = 10;
        private static const SCROLL_MOVE = 50;

        private static const MASK_PUSH = 7;
        private static const MASK_BTN_CROP = 35;

		// ART CLIPS
        public var mcTagHolder      :   MovieClip;
        public var mcMask           :   MovieClip;
        public var btnLeft          :   MovieClip;
        public var btnRight          :   MovieClip;

        // VARS
        private var spawnedTags         :  Vector.<MovieClip> = new Vector.<MovieClip>();
        private var _mcTagHolder_x      :  Number;
        private var _mcTagHolder_y      :  Number;
        private var _mcTagHolder_width  :  Number;
        private var hitTestShape        :  Shape;
        private var bSelected            :  Boolean;

        private var lastLeftButton : Boolean = false;
        private var lastRightButton : Boolean = false;


        public function ModMenuTagScrollList() 
		{
            super();
            if(mcTagHolder)
            {
                _mcTagHolder_x = mcTagHolder.x;
                _mcTagHolder_y = mcTagHolder.y;
                _mcTagHolder_width = mcTagHolder.width;
            }
		}

		protected function get menuName():String { return "ModMenu"; }
        override protected function configUI():void
        {
            super.configUI();
            mcTagHolder.mouseEnabled = true;
            mouseEnabled = true;
            mouseChildren = true;
            mcTagHolder.addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel)
            stage.addEventListener(InputEvent.INPUT, handleInputNavigate, false, 11, true);

            setupButtonsForClick();
        }

        public function onSelect():void
        {
            bSelected = true;
        }

        public function deselect():void
        {
            bSelected = false;
        }

        public function canBeScrolled():Boolean
        {
            var mostLeft : Number  = mcTagHolder.x + spawnedTags[0].x;
            var mostRight : Number  = mcTagHolder.x + spawnedTags[spawnedTags.length - 1].x + spawnedTags[spawnedTags.length - 1].mcBg.width - 4;
            if(mcTagHolder.x < _mcTagHolder_x)
                return true;
            if(mostRight > _mcTagHolder_x + _mcTagHolder_width)
                return true;
            return false;
        }

        public function canBeScrolledRight():Boolean
        {
            if(spawnedTags.length == 0)
                return false;
            var mostRight : Number  = mcTagHolder.x + spawnedTags[spawnedTags.length - 1].x + spawnedTags[spawnedTags.length - 1].mcBg.width - 4;

            if(mostRight > _mcTagHolder_x + _mcTagHolder_width + 0.1)
                return true;
            return false;
        }

        public function canBeScrolledLeft():Boolean
        {
            if(mcTagHolder.x < _mcTagHolder_x)
                return true;
            return false;
        }

        protected function updateScrollButtons():void
        {
            btnLeft.visible = canBeScrolledLeft();
            btnRight.visible = canBeScrolledRight();

            if(btnLeft.visible && !lastLeftButton)
            {
                mcMask.width -= MASK_BTN_CROP;
                mcMask.x = MASK_BTN_CROP - MASK_PUSH;
            }
            else if (!btnLeft.visible && lastLeftButton)
            {
                mcMask.width += MASK_BTN_CROP;
                mcMask.x = -MASK_PUSH;
            }
            if(btnRight.visible && !lastRightButton)
            {
                mcMask.width -= MASK_BTN_CROP;
            }
            else if(!btnRight.visible && lastRightButton)
            {
                mcMask.width += MASK_BTN_CROP;
            }

            lastLeftButton = btnLeft.visible;
            lastRightButton = btnRight.visible;
        }

        protected function scrollRight( amount:Number ):void
        {
            var mostLeft : Number  = mcTagHolder.x + spawnedTags[0].x;
            var mostRight : Number  = mcTagHolder.x + spawnedTags[spawnedTags.length - 1].x + spawnedTags[spawnedTags.length - 1].mcBg.width - 4;
            if(mostRight > _mcTagHolder_x + _mcTagHolder_width)
            {
                mcTagHolder.x -= amount;
                if(mostRight - amount < _mcTagHolder_x + _mcTagHolder_width)
                {
                    mcTagHolder.x = _mcTagHolder_x + _mcTagHolder_width - (mostRight - mostLeft);
                }
            }
        }

        protected function scrollLeft( amount:Number ):void
        {
            mcTagHolder.x += amount;
                if(mcTagHolder.x > _mcTagHolder_x)
                    mcTagHolder.x = _mcTagHolder_x;
        }

        protected function onMouseWheel(event:MouseEvent)
        {
            if(spawnedTags.length == 0)
                return;
            if(event.delta > 0) // scroll up
            {
                scrollLeft(SCROLL_MOVE);
            }
            else // scroll down
            {
                scrollRight(SCROLL_MOVE);
            }

            updateScrollButtons();

            event.stopImmediatePropagation();
        }

        public function clearTags():void
		{
            if(hitTestShape && hitTestShape.parent)
                hitTestShape.parent.removeChild(hitTestShape);

			while(spawnedTags.length > 0)
			{
				var tag : MovieClip = spawnedTags.pop();
				if(tag.parent)
					tag.parent.removeChild(tag);
			}
		}

        protected function createHitTestShape():void
        {
            if(spawnedTags.length == 0)
                return;

            var mostLeft : Number = mcTagHolder.x + spawnedTags[0].x;
            var mostRight : Number = mcTagHolder.x + spawnedTags[spawnedTags.length - 1].x + spawnedTags[spawnedTags.length - 1].width;

            hitTestShape = new Shape();
            mcTagHolder.addChildAt(hitTestShape,0);
            hitTestShape.graphics.beginFill(0x000000,0);
            hitTestShape.graphics.drawRect(mostLeft,0,mostRight,mcTagHolder.height);
            hitTestShape.graphics.endFill();
            // hitTestShape.mouseEnabled = true;
        }

        public function spawnTags(tagList:Array):void
        {
            clearTags();

            mcTagHolder.x = _mcTagHolder_x;
            mcTagHolder.y = _mcTagHolder_y;

            var x : Number = 0;
            for(var i : int = 0; i < tagList.length; i++)
            {
                var classRef:Class = getDefinitionByName("TagText") as Class;
                var tfText:MovieClip = new classRef() as MovieClip;

                tfText.mcText.text = tagList[i];
                mcTagHolder.addChild(tfText);
                spawnedTags.push(tfText);
                tfText.x = x;
                tfText.y = 0;
                tfText.mcText.width = tfText.mcText.textWidth + 4;
                tfText.mcBg.width = tfText.mcText.width + 12;
                x += tfText.mcText.textWidth + TAG_GAP_X;
            }

            createHitTestShape();

            btnLeft.visible = canBeScrolledLeft();
            btnRight.visible = canBeScrolledRight();
        }

        public function setData(tagList:Array):void
        {
            spawnTags(tagList);
        }

        protected function moveLeft(hold:Boolean):Boolean
        {
            var curX = mcTagHolder.x;
            if(hold)
                scrollLeft(SCROLL_MOVE);
            else
                scrollLeft(2 * SCROLL_MOVE);

            updateScrollButtons();

            return curX != mcTagHolder.x || hold;
        }

        protected function moveRight(hold:Boolean):Boolean
        {
            var curX = mcTagHolder.x;
            if(hold)
                scrollRight(SCROLL_MOVE);
            else
                scrollRight(2 * SCROLL_MOVE);

            updateScrollButtons();
                
            return curX != mcTagHolder.x || hold;
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
                    event.handled = moveLeft(hold);
				}
				else if (details.navEquivalent == NavigationCode.RIGHT && (keyDown || hold))
				{
                    event.handled = moveRight(hold);
				}

                if(event.handled)
                    dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
			}
		}

        public function resizeWidth(value:Number):void
        {
            var i : int = 0;

            for(i = 0; i < spawnedTags.length; i++)
            {
                spawnedTags[i].width *= mcTagHolder.width / value;
                spawnedTags[i].x *= mcTagHolder.width / value;
                mcTagHolder.removeChild(spawnedTags[i]);
            }
            
            trace("GFX / resizeWidth", mcTagHolder.width, _mcTagHolder_width, value);
            mcTagHolder.width = value;
            //_mcTagHolder_width = value;
            mcMask.x = -MASK_PUSH;
            mcMask.width = value + 2 * MASK_PUSH;
            btnRight.x = mcMask.width - 35.6;
            trace("GFX / resizeWidth aft", mcTagHolder.width, _mcTagHolder_width, value);
       
            for(i = 0; i < spawnedTags.length; i++)
                mcTagHolder.addChild(spawnedTags[i]);


            callSetButtons();
        }

        public function callSetButtons():void
        {
            //this is to avoid double stacking the mask reduction
            lastLeftButton = false;
            lastRightButton = false;
            mcMask.x = -MASK_PUSH;
            updateScrollButtons();
        }

        public function callSetButtonsResizeMask(value:Number):void
        {
            //this is to avoid double stacking the mask reduction
            mcMask.width = value + 2 * MASK_PUSH;
            lastLeftButton = false;
            lastRightButton = false;
            mcMask.x = -MASK_PUSH;
            updateScrollButtons();
        }

        public function getTagWidthTotal():Number
        {
            if(spawnedTags.length == 0)
                return 0;

            var mostLeft : Number = mcTagHolder.x + spawnedTags[0].x;
            var mostRight : Number = mcTagHolder.x + spawnedTags[spawnedTags.length - 1].x + spawnedTags[spawnedTags.length - 1].mcBg.width - 4;

            return mostRight - mostLeft;
        }

        private function setupButtonsForClick():void
        {
            btnLeft.addEventListener(MouseEvent.CLICK, onLeftButtonClick);
            btnRight.addEventListener(MouseEvent.CLICK, onRightButtonClick);
        }

        private function onLeftButtonClick(event:MouseEvent):void
        {
            moveLeft(false);
        }

        private function onRightButtonClick(event:MouseEvent):void
        {
            moveRight(false);
        }

	}
	
}