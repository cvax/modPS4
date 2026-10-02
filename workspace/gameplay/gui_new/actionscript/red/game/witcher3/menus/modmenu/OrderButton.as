/***********************************************************************
/** Mod order button
 ** StatusButton used as a base
/***********************************************************************
/** Copyright © 2026 CDProjektRed
/** Author : Ryan Ash
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.display.MovieClip;
	import flash.display.Sprite;
    import flash.utils.getDefinitionByName;
    import flash.events.MouseEvent;

    import scaleform.clik.core.UIComponent;

    import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

    import red.core.events.GameEvent;

	public class OrderButton extends BoxedText
	{
 		// ART CLIPS
        public var mcBackground : MovieClip;
        public var mcIcon : MovieClip;
        
        // VARS
        public var _statusEnabled : Boolean = false;
        public var deactivated : Boolean = false;

        private var hovered : Boolean = false;
        private var lastFrame : String = "default";

        public function OrderButton() 
		{
            super();
            statusEnabled = true;
		}

        public function set statusEnabled(value:Boolean):void
        {
            _statusEnabled = value;

            if (_statusEnabled)
                setBackgroundFrame(lastFrame);
            else
                setBackgroundFrame("inactive");            
        }

        public function get statusEnabled():Boolean
        {
            return _statusEnabled;
        }

        override protected function configUI():void
        {
            addEventListener(MouseEvent.MOUSE_OVER, onHoverIn);
            addEventListener(MouseEvent.MOUSE_OUT, onHoverOut);
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }

        public function setBackgroundFrame(label:String)
        {
            if (label != "inactive")
            {
                lastFrame = label;
                if (_statusEnabled)
                {
                    mcIcon.alpha = 1;
                    mcBackground.gotoAndStop(label);
                }
            }
            else
            {
                mcBackground.gotoAndStop(label);
                mcIcon.alpha = 0.5;
            }
        }

        public function select()
        {
            if(deactivated)
                return;

            hovered = true;
            setBackgroundFrame("hover");
        }

        public function deselect()
        {
            if(deactivated)
                return;

            hovered = false;
            setBackgroundFrame("default");
        }

        public function press()
        {
            if(deactivated)
                return;

            setBackgroundFrame("pressed");
        }

        public function release()
        {
           if(deactivated)
                return;

            if(hovered)
                setBackgroundFrame("hover");
            else
                setBackgroundFrame("default");

            interact();
        }

        public function interact()
        {
            var ev : StatusButtonEvent = new StatusButtonEvent(StatusButtonEvent.RELEASED);
            dispatchEvent(ev);
        }

        protected function onHoverIn(event:MouseEvent)
        {
            select();
            event.stopImmediatePropagation();
        }

        protected function onHoverOut(event:MouseEvent)
        {
            deselect();
            event.stopImmediatePropagation();
        }

        protected function onMouseDown(event:MouseEvent)
        {
            press();
            event.stopImmediatePropagation();
        }

        protected function onMouseUp(event:MouseEvent)
        {
            release();
            event.stopImmediatePropagation();
        }
	}
}