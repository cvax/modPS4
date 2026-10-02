package red.game.witcher3.menus.overlay
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.utils.setTimeout;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.ui.InputDetails;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.constants.CommonConstants;
    import red.game.witcher3.controls.InputFeedbackButton;
    import red.game.witcher3.menus.modmenu.ModMenuTextAreaModule;
	
	/**
	 * ...
	 * @author Lilla Toma
	 */
	public class W3LicenseAgreementPopup extends BasePopup
	{
		private static const HEIGHT_PADDING: Number = 10;
		private static const INPUT_PADDING: Number = 10;
		private static const FINAL_HEIGHT_PADDING: Number = 40;
		
		public var txtTitle:TextField;
		public var textBorder:MovieClip;
		private var curHeight:Number;
		public var mcHeader: MovieClip;
		public var mcBackground: MovieClip;

        public var btnAccept:InputFeedbackButton;
        public var btnDecline:InputFeedbackButton;
		public var btnScroll:InputFeedbackButton;

        public var txtArea:ModMenuTextAreaModule;

		private var hasScrolledDown:Boolean = false;
		private var hasHandledAccept:Boolean = false;

		private function turkishIFixHack(text:String):String
		{
			var goodChar:String = "İ";
			var badChar:String = "İ";

			text = text.split(badChar).join(goodChar);

			return text;
		}
		
		override protected function populateData():void
		{		
			var title : String = turkishIFixHack(_data.TextTitle);
			var content : String = turkishIFixHack(_data.TextContent)
			
			txtTitle.htmlText = CommonUtils.toUpperCaseSafe(title);

            if(txtArea) {
            	txtArea.SetText(content);
			}

			btnAccept.visible = true; //<--required to scroll down!
			btnAccept.clickable = false;
			btnAccept.label = "[[panel_eula_scroll_agree]]";
			btnAccept.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.ENTER);
			btnAccept.addEventListener(ButtonEvent.PRESS, onAcceptClicked, false, 0, false);
			btnAccept.validateNow();

			btnDecline.visible = true; //<--required to scroll down!
			btnDecline.clickable = false;
			btnDecline.label = "[[panel_eula_scroll_disagree]]";
			btnDecline.setDataFromStage(NavigationCode.GAMEPAD_B, KeyCode.ESCAPE);
			btnDecline.addEventListener(ButtonEvent.PRESS, onDeclineClicked, false, 0, false);
			btnDecline.validateNow();

			btnScroll.visible = true;
			btnScroll.clickable = false;
			btnScroll.label = "[[panel_button_common_navigation]]";
			btnScroll.setDataFromStage(NavigationCode.GAMEPAD_R3, -1);
			btnScroll.validateNow();

			txtArea.selected = true;

			txtArea.mcScrollbar.addEventListener(Event.SCROLL, handleScroll, false, 1, true);
			txtArea.mcTextArea.allowSounds = false;
			hasScrolledDown = false;
		}

		public function handleScroll(event : Event):void
		{
			//#LT hack: delaying, because when grabbing the scrollbar to scroll, the event gets dispatched earlier than the actual scroll on the text
			setTimeout( hasScrolledDownFully, 1);
		}

		public function hasScrolledDownFully():Boolean
		{
			trace("GFX fullScrolldown check!", hasScrolledDown);
			if(hasScrolledDown)
				return true;
			//handling check if the textbox is fully down
			if(txtArea.mcTextArea.textField.scrollV == txtArea.mcTextArea.textField.maxScrollV)
			{
				hasScrolledDown = true;
				btnAccept.clickable = true;
				btnDecline.clickable = true;

				btnAccept.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.ENTER);
				btnDecline.setDataFromStage(NavigationCode.GAMEPAD_B, KeyCode.ESCAPE);
				btnAccept.validateNow();
				btnDecline.validateNow();
				return true;
			}
			return false;
		}

        override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);

			if( event.details.code == KeyCode.PAD_RIGHT_STICK_AXIS )
			{
				hasScrolledDownFully();
			}

			if (event.handled || !visible)
			{
				return;
			}

			if(hasScrolledDownFully())
			{
				var details : InputDetails = event.details;

				if(details.navEquivalent == NavigationCode.GAMEPAD_A || details.code == KeyCode.ENTER)
				{
					onAccept();
					event.handled = true;
				}
				else if(details.navEquivalent == NavigationCode.GAMEPAD_B || details.code == KeyCode.ESCAPE)
				{
					onDecline();
					event.handled = true;
				}
			}
        }

		public function onAccept():void
		{
			if(hasScrolledDown)
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnLicenseAgreementAccepted" ) );
			hasHandledAccept = true;
		}

		public function onDecline():void
		{
			if(hasScrolledDown)
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnLicenseAgreementDeclined" ) );
		}

		private function onAcceptClicked(event : ButtonEvent):void
		{
			onAccept();
		}

		private function onDeclineClicked(event : ButtonEvent):void
		{
			onDecline();
		}

		public function tryAcceptFromOutside():void
		{
			if(!hasHandledAccept)
				onAccept();
		}
	}

}