/***********************************************************************
/** Connected Page
/***********************************************************************
/** Copyright © 2026 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.startup_experience
{
    import scaleform.clik.core.UIComponent;
    import flash.text.TextField;
    import red.game.witcher3.controls.InputFeedbackButton;
    import red.core.events.GameEvent;
    import red.game.witcher3.data.KeyBindingData;
    import red.core.constants.KeyCode;
    import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.events.ButtonEvent;
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.ui.InputDetails;
    import scaleform.clik.constants.InputValue;
    import flash.events.Event;
    import red.game.witcher3.menus.common_menu.ModuleInputFeedback;

    public class PatchNotesPage extends UIComponent
	{
        public var tfTitle : TextField;

        public var m_entry1 : PatchNotesEntry;
        public var m_entry2 : PatchNotesEntry;
        public var m_entry3 : PatchNotesEntry;
        public var m_entry4 : PatchNotesEntry;
        public var m_entry5 : PatchNotesEntry;
        public var m_entry6 : PatchNotesEntry;
        public var m_entryList : Array;

        public var mcInputFeedbackPanel : ModuleInputFeedback;

		public function PatchNotesPage()
		{
			super();
            m_entryList = [m_entry1, m_entry2, m_entry3, m_entry4, m_entry5, m_entry6];
		}

        override protected function configUI():void
        {
            super.configUI();

            mcInputFeedbackPanel.appendButton( 1, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_continue]]", true );
        }

        public function setData(data:Object):void
        {
            tfTitle.htmlText = data.title;
            
            for( var i : int = 0; i < 6; i++ )
            {
                if(data.entries[i])
                    m_entryList[i].setData(data.entries[i]);
                else 
                    m_entryList[i].visible = false;
            }
        }

        private function onContinue( event : Event = null ) : void
        {
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnContinue" ) );
        }

        protected function handleInputNavigate(event:InputEvent):void
		{	
            trace( "PatchNotesPage::handleInputNavigate : ", event );

			var details:InputDetails = event.details;
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
            if ((details.navEquivalent == NavigationCode.GAMEPAD_A && keyDown) || (details.code == KeyCode.E && keyUp))
            {
                onContinue();
                event.handled = true;
            }
		}
    }
}
