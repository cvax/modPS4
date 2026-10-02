/***********************************************************************
/** text input manager for handling console textinput
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{
	import flash.events.Event;
    import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import scaleform.clik.core.UIComponent;

	import red.core.CoreMenu;	
	import red.core.events.GameEvent;

	public class TextInputManager extends UIComponent
	{
		private var tiRef : W3TextInput;

        public function setReference(ti:W3TextInput)
        {
            tiRef = ti;
        }

        override protected function configUI():void
		{
			super.configUI();
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'textinput.text.received', [onTextReceived] ) );
		}

        public function TextInputManager()
        {
        }

        public function onTextReceived(newText:String)
        {
            trace("GFX - text is received!", newText);
            if(tiRef)
                tiRef.setText(newText);
        }
    }
}