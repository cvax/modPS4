/***********************************************************************
/** Status button
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

	public class StatusButton extends BoxedText
	{
        // CONSTS

		// ART CLIPS
        public var mcBackground : MovieClip;
        public var mcIcon : MovieClip;
        
        // VARS
        public var statusName : String = "";
        public var _statusEnabled : Boolean = false;
        public var deactivated : Boolean = false;

        public var statusColor:uint = 0xC0967D;
        public var nonStatusColor:uint = 0xC0967D;

        private var clicked : Boolean = false;
        private var hovered : Boolean = false;

        private var lastFrame : String = "default";

        public function StatusButton() 
		{
            super();
            statusEnabled = false;
		}

        public function set statusEnabled(value:Boolean):void
        {
            _statusEnabled = value;
            setBackgroundFrame("default");
            
            var format:TextFormat = new TextFormat();
            if(_statusEnabled) {
                format.color = statusColor;
            }
            else {
                format.color = nonStatusColor;
            }
            mcText.setTextFormat(format);  

            //trace("JIFIX Resetting", statusEnabled, statusName, lastFrame);
            setBackgroundFrame(lastFrame)
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

        override public function setText(text:String)
        {
            trace("GFX - StatusButton - setText",text);
            super.setText(text);

            if(mcIcon)
            {
                super.setText("");
                mcBox.width = mcIcon.width + 2 * TEXT_HORIZONTAL_GAP + 40;
                mcIcon.x = (mcBox.width - mcIcon.width) / 2
                if(_scalingOption == "left")
                {
                    x = pivotX;
                }
                else if (_scalingOption == "center")
                {
                    x = pivotX - getWidth() / 2;
                }
                else if (_scalingOption == "right")
                {
                    x = pivotX - getWidth();
                }
            }
            mcBackground.width = mcBox.width;
        }

        public function setBackgroundFrame(label:String)
        {
            lastFrame = label;
            if(_statusEnabled && statusName.length > 0)
                mcBackground.gotoAndStop(statusName + "_" + label);
            else
                mcBackground.gotoAndStop(label);
        }

        protected function onHoverIn(event:MouseEvent)
        {
            if(deactivated)
                return;
            hovered = true;
            setBackgroundFrame("hover");
            event.stopImmediatePropagation();
        }

        protected function onHoverOut(event:MouseEvent)
        {
            if(deactivated)
                return;
            hovered = false;
            clicked = false;
            setBackgroundFrame("default");
            event.stopImmediatePropagation();
        }

        protected function onMouseDown(event:MouseEvent)
        {
            if(deactivated)
                return;
            setBackgroundFrame("pressed");
            clicked = true;
            event.stopImmediatePropagation();
        }

        protected function onMouseUp(event:MouseEvent)
        {
            if(deactivated)
                return;

            if(clicked)
            {
                statusEnabled = !statusEnabled;
                
                var ev : StatusButtonEvent = new StatusButtonEvent(StatusButtonEvent.RELEASED);
                ev.status = _statusEnabled;
                dispatchEvent(ev);
            }
            if(hovered)
                setBackgroundFrame("hover");
            else
                setBackgroundFrame("default");
            event.stopImmediatePropagation();
        }

	}
	
}