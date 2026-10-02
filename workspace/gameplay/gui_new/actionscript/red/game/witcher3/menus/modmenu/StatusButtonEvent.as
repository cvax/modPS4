/***********************************************************************
/** Status button
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.events.Event;

	public class StatusButtonEvent extends Event
	{
        public static const RELEASED:String = "released";
        public var status : Boolean;

        public function StatusButtonEvent(type:String, bubbles:Boolean = false, cancelable: Boolean = false)
        {
            super(type, bubbles, cancelable);
        }

        override public function clone():Event 
        {
            return new StatusButtonEvent(type,bubbles,cancelable);
        }
	}
	
}