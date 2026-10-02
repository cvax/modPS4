/***********************************************************************
/** Telemetry Page
/***********************************************************************
/** Copyright © 2026 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.startup_experience
{
    import scaleform.clik.core.UIComponent;
    import flash.text.TextField;
    import flash.display.MovieClip;
    import red.game.witcher3.controls.InputFeedbackButton;
    import red.core.events.GameEvent;
    import red.game.witcher3.data.KeyBindingData;
    import red.core.constants.KeyCode;
    import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.events.ButtonEvent;
    import scaleform.clik.data.DataProvider;
    import red.game.witcher3.menus.photomode.PhotomodeSliderRenderer;
    import red.game.witcher3.menus.photomode.PhotomodeSliderDataModel;
    import flash.utils.getDefinitionByName;
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.ui.InputDetails;
    import scaleform.clik.constants.InputValue;
    import red.game.witcher3.managers.InputManager;
    import flash.events.Event;
    import scaleform.clik.events.SliderEvent;
    import red.game.witcher3.menus.common_menu.ModuleInputFeedback;

    import red.game.witcher3.utils.CommonUtils;
    import scaleform.clik.controls.ScrollBar;
    import red.game.witcher3.controls.W3ScrollingList;
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.text.StyleSheet;
    import flash.geom.Rectangle;
    import red.core.events.GestureEventEx;

    public class TelemetryPage extends UIComponent
	{
        private static const BUTTON_CUSTOMIZE : int = 1;
		private static const BUTTON_REJECT_ALL : int = 2;
		private static const BUTTON_CONSENT_ALL : int = 3;
        private static const BUTTON_CONFIRM : int = 4;

        private static const RENDERER_GAP : Number = 5;

        public var tfTitle : TextField;
        public var tfDesc : TextField;
        public var mcQrLearnMore : MovieClip;

        public var mcConsentListScrollbar : ScrollBar;
		public var mcConsentList : W3ScrollingList;
		public var mcConsentListItem1 : PhotomodeSliderRenderer;
		public var mcConsentListItem2 : PhotomodeSliderRenderer;
		public var mcConsentListItem3 : PhotomodeSliderRenderer;
		public var mcConsentListItem4 : PhotomodeSliderRenderer;

        public var mcInputFeedbackPanel : ModuleInputFeedback;

        private var mDataProvider : DataProvider;
        private var mChoicesChangedState : Boolean;

        private var mAcceptAllHoldTriggered : Boolean;
        private var mRejectAllHoldTriggered : Boolean;

		public function TelemetryPage()
		{
            mDataProvider = null;
            mAcceptAllHoldTriggered = false;
            mRejectAllHoldTriggered = false;
		}

        override protected function configUI():void
        {
            super.configUI();

            mChoicesChangedState = false;
            mAcceptAllHoldTriggered = false;
            mRejectAllHoldTriggered = false;
            mcInputFeedbackPanel.focusable = false;
            mcInputFeedbackPanel.appendButton( BUTTON_CUSTOMIZE, NavigationCode.GAMEPAD_LSTICK_SCROLL, -1, "[[panel_button_customize]]", true );
            mcInputFeedbackPanel.appendHoldButton( BUTTON_REJECT_ALL, NavigationCode.GAMEPAD_X, KeyCode.ESCAPE, "[[startup_telemetry_reject_all]]", true, 300 );
            mcInputFeedbackPanel.appendHoldButton( BUTTON_CONSENT_ALL, NavigationCode.GAMEPAD_A, KeyCode.E, "[[startup_telemetry_consent_all]]", true, 300 );
        }

        public function setData( data : Object ) : void
        {
            tfTitle.htmlText = data.title;
            tfDesc.htmlText = data.desc;

            var urlHtml : String = "<a href='event:idPlayerDataUrl'><u>" + data.url + "</u></a>";

            mcQrLearnMore.tfMore.htmlText = data.more;
            mcQrLearnMore.tfMore.htmlText = mcQrLearnMore.tfMore.htmlText.replace("{x}", urlHtml );
            mcQrLearnMore.tfMore.y += (mcQrLearnMore.tfMore.height - mcQrLearnMore.tfMore.textHeight) / 2; //vertical align
            mcQrLearnMore.tfMore.addEventListener( TextEvent.LINK, onLinkClickOrTap, false, 0, true );
            mcQrLearnMore.addEventListener( GestureEventEx.GESTURE_TAP, onLinkClickOrTap, false, 0, true );

            showWithData( data.options );

            var bounds : Rectangle = mcConsentList.getRect( stage );
            
            var height = Math.min( mcConsentList.GetDropdownListHeight(), mcConsentList.height );
            mcQrLearnMore.x = bounds.x;
            mcQrLearnMore.y = bounds.y + height + 48.0

            mcConsentListItem1.m_slider.addEventListener( SliderEvent.VALUE_CHANGE, onSliderValueChange, false, 0, true );
            mcConsentListItem2.m_slider.addEventListener( SliderEvent.VALUE_CHANGE, onSliderValueChange, false, 0, true );
            mcConsentListItem3.m_slider.addEventListener( SliderEvent.VALUE_CHANGE, onSliderValueChange, false, 0, true );
            mcConsentListItem4.m_slider.addEventListener( SliderEvent.VALUE_CHANGE, onSliderValueChange, false, 0, true );
        }

        private function onLinkClickOrTap( event : Event ) : void 
        {
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnTelemetryPageLinkClicked" ));
        }

		private function createDataProvider( tabData : Array ) : DataProvider 
		{
			var dataProvider : DataProvider = new DataProvider();
			
			for each(var item : Object in tabData)
			{
				var dataObj : Object = { data : item }; 

				if(item.rendererType == "slider" || item.rendererType == "selector") {
					var sliderModel : PhotomodeSliderDataModel = new PhotomodeSliderDataModel();
					sliderModel.setDataModel.apply(sliderModel, item.args);
					dataObj["sliderData"] = sliderModel;
				}
				dataProvider.push(dataObj);
			}
			
			return dataProvider;
		}

        private function showWithData( data : Array ) : void
        {
            mDataProvider = createDataProvider( data );

            mcConsentList.dataProvider = mDataProvider;
            mcConsentList.validateNow();//Fire data update on renderers
        }

        private function onSliderValueChange( event : SliderEvent ) : void
        {
            if ( event.value == 0 )
            {
                return;
            }

            mcConsentListItem1.m_slider.removeEventListener( SliderEvent.VALUE_CHANGE, onSliderValueChange, false );
            mcConsentListItem2.m_slider.removeEventListener( SliderEvent.VALUE_CHANGE, onSliderValueChange, false );
            mcConsentListItem3.m_slider.removeEventListener( SliderEvent.VALUE_CHANGE, onSliderValueChange, false );
            mcConsentListItem4.m_slider.removeEventListener( SliderEvent.VALUE_CHANGE, onSliderValueChange, false );

            mcInputFeedbackPanel.removeButton( BUTTON_CUSTOMIZE, true );
            mcInputFeedbackPanel.removeButton( BUTTON_REJECT_ALL, true );
            mcInputFeedbackPanel.removeButton( BUTTON_CONSENT_ALL, true );

            mcInputFeedbackPanel.appendButton( BUTTON_CONFIRM, NavigationCode.GAMEPAD_A, KeyCode.E, "[[startup_telemetry_confirm]]", true );            

            mChoicesChangedState = true;
        }

        private function onAcceptAll( event : Event = null ) : void
        {
            submitConsentSliderValues( true, true );
        }

        private function onRejectAll( event : Event = null ) : void
        {
            submitConsentSliderValues( true, false );
        }

        private function onConfirmChoices( event : Event = null ) : void
        {
            submitConsentSliderValues( );
        }

        private function submitConsentSliderValues( override : Boolean = false, overrideValue : Boolean = false ):void
        {
            if ( !mDataProvider )
            {
                return;
            }

			for ( var i: uint = 0; i < mDataProvider.length; i++ )
			{	
                var sliderModel : PhotomodeSliderDataModel = mDataProvider[i]["sliderData"];
                var value : Boolean = override ? overrideValue : ( sliderModel.currentValue != 0 );

                dispatchEvent( new GameEvent( GameEvent.CALL, "OnTelemetryPageSubmitConsentValue", [ sliderModel.id, value ] ) );
			}

            dispatchEvent( new GameEvent( GameEvent.CALL, "OnTelemetryPageSubmitConsentValuesDone" ) );
        }

        protected function handleInputNavigate(event:InputEvent):void
		{	
            trace( "TelemetryPage::handleInputNavigate : ", event );

            //Manual focus handling because we dont use modules
            mcConsentList.focused = 1;

			var details:InputDetails = event.details;
            var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
            var keyHold:Boolean = details.value == InputValue.KEY_HOLD;
			if ( !CommonUtils.convertWASDCodeToNavEquivalent(details) )
            {
                if ( mChoicesChangedState )
                {
                    if ((details.navEquivalent == NavigationCode.GAMEPAD_A && keyDown) || (details.code == KeyCode.E && keyUp ))
                    {
                        onConfirmChoices();
                        event.handled = true;
                    }
                }
                else
                {                    
                    if ((details.navEquivalent == NavigationCode.GAMEPAD_A && keyHold) || (details.code == KeyCode.E && keyHold ))
                    {
                        mAcceptAllHoldTriggered = true;
                        event.handled = true;
                    }
                    else if ((details.navEquivalent == NavigationCode.GAMEPAD_X && keyHold) || (details.code == KeyCode.ESCAPE && keyHold ))
                    {
                        mRejectAllHoldTriggered = true;
                        event.handled = true;
                    }

                    if ( mAcceptAllHoldTriggered && ((details.navEquivalent == NavigationCode.GAMEPAD_A && keyUp) || (details.code == KeyCode.E && keyUp )))
                    {
                        onAcceptAll();
                        mAcceptAllHoldTriggered = false;
                        mRejectAllHoldTriggered = false;
                        event.handled = true;
                    }
                    else if ( mRejectAllHoldTriggered && ((details.navEquivalent == NavigationCode.GAMEPAD_X && keyUp) || (details.code == KeyCode.ESCAPE && keyUp )))
                    {
                        onRejectAll();
                        mAcceptAllHoldTriggered = false;
                        mRejectAllHoldTriggered = false;
                        event.handled = true;
                    }

                }
            }

			mcConsentList.handleInput(event);
		}
    }
}
