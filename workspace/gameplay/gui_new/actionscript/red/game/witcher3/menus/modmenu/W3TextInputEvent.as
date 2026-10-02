/***********************************************************************
/** Status button
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.events.Event;

	public class W3TextInputEvent extends Event
	{
        public static const TEXT_CHANGED:String = "text_changed";
        public var text : String;

        public function W3TextInputEvent(type:String, bubbles:Boolean = false, cancelable: Boolean = false)
        {
            super(type, bubbles, cancelable);
        }

        override public function clone():Event 
        {
            return new W3TextInputEvent(type,bubbles,cancelable);
        }
	}
	
}