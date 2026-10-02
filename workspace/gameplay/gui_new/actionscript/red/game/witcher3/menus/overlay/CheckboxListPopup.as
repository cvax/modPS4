package red.game.witcher3.menus.overlay
{
	import flash.display.MovieClip;
    import flash.events.MouseEvent;
	import flash.text.TextField;
    import flash.utils.getDefinitionByName;

	import red.core.CoreComponent;
    import red.core.constants.KeyCode;
    import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3TextArea;
	import red.game.witcher3.managers.InputManager;
    import red.game.witcher3.menus.common.CheckboxListItem;
	import red.game.witcher3.menus.common.URLButton;
	import red.game.witcher3.menus.mainmenu.IngameMenu;
    import red.game.witcher3.menus.modmenu.ModMenuTextAreaModule;
	import red.game.witcher3.utils.CommonUtils;

	import scaleform.clik.events.InputEvent;
    import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.managers.InputDelegate;
    import scaleform.clik.ui.InputDetails;
	import flash.events.GestureEvent;
	import red.core.events.GestureEventEx;
	import flash.events.Event;

	/**
	 * ...
	 * @author Lilla Toma
	 */
	public class CheckboxListPopup extends BasePopup
	{
		private static const HEIGHT_PADDING: Number = 10;
		private static const HEIGHT_PADDING_AFTER_TEXT: Number = 20;
        private static const HEIGHT_PADDING_CHECKBOXES: Number = 10;
		private static const HEIGHT_PADDING_URL_BUTTONS: Number = 20;
		private static const HEIGHT_PADDING_BETWEEN_CB_AND_URL : Number = 15;
		private static const INPUT_PADDING: Number = 10;
		private static const INPUT_PUSH: Number = 30;
		private static const FINAL_HEIGHT_PADDING: Number = 40;
        private static const TEXTFIELD_MAX_HEIGHT: Number = 200;
		private static const MIN_GAP_INPUT_FEEDBACK : Number = 30;
		
		public var txtArea:ModMenuTextAreaModule;
		public var mcTextArea:TextField;
		public var txtTitle:TextField;
		public var textBorder:MovieClip;
		private var curHeight:Number;
		public var mcHeader: MovieClip;
		public var mcInputBackground: MovieClip;
		public var mcBackground: MovieClip;
		public var mcSecondaryText : TextField;
		public var mcImagePanel : MovieClip;

        private var checkboxes:Vector.<CheckboxListItem> = new Vector.<CheckboxListItem>();
		private var buttons:Vector.<URLButton> = new Vector.<URLButton>();
        private var selectedIndex : int = -1;
		private var buttonList: Array;

		public function CheckboxListPopup()
		{
			mcInpuFeedback.buttonAlign = "center";
			mcInpuFeedback.coloringButtons = true;
			mcInputBackground.visible = false;
			visible = false;
			// not calling super because we don't want other hotkeys to work
		}

        override protected function configUI():void
        {
            super.configUI();
            InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 1000, true);
        }
		
		override protected function populateData():void
		{	
			buttonList = _data.ButtonsList as Array;
			mcInpuFeedback.handleSetupButtons(buttonList);
			if ( mcInpuFeedback.buttonsContainer.width + 2 * MIN_GAP_INPUT_FEEDBACK > mcBackground.width )
			{
				mcBackground.width = mcInpuFeedback.buttonsContainer.width + 2 * MIN_GAP_INPUT_FEEDBACK;
				txtTitle.width = mcBackground.width - 4;
				if(mcTextArea)
					mcTextArea.width = mcBackground.width - 60;
				if(mcSecondaryText)
					mcSecondaryText.width = mcBackground.width - 60;

				mcInpuFeedback.x = (mcBackground.width + mcInpuFeedback.width) / 2;
			}

			var i : int = 0;

			clearCheckboxes();
			
			if(txtArea)
            	txtArea.SetText(_data.TextContent);
			else if(mcTextArea) {
				var value : String = _data.TextContent;
				if ( CoreComponent.isArabicAligmentMode )
				{
					value = "<p align=\"right\">" + value+"</p>";
				}
				mcTextArea.htmlText = value;
			}

			if(mcSecondaryText && _data.TextSecondary)
			{
				var value2 : String = _data.TextSecondary;
				if ( CoreComponent.isArabicAligmentMode )
				{
					value2 = "<p align=\"right\">" + value2 +"</p>";
				}
				mcSecondaryText.htmlText = value2;
			}

            var tHeight : Number = 0;
			if(txtArea)
				tHeight = txtArea.mcTextArea.textField.textHeight + HEIGHT_PADDING;
			else if(mcTextArea)
				tHeight = mcTextArea.textHeight + HEIGHT_PADDING;
            if (tHeight > TEXTFIELD_MAX_HEIGHT)
                tHeight = TEXTFIELD_MAX_HEIGHT;

            if(txtArea)
			{
				txtArea.mcScrollbar.height = tHeight;
				txtArea.mcTextArea.textField.height = tHeight;
			}
			else if (mcTextArea)
			{
				mcTextArea.height = mcTextArea.textHeight + 5;
			}

			//TODO - Fix the bug with clicking on the text
			//Currently these ones below, and some combination of them did not work.
			//txtArea.mcTextArea.height = tHeight;
			//txtArea.mcTextArea.setActualSize(txtArea.mcTextArea.width, tHeight);
            //txtArea.height = tHeight;
			//txtArea.setActualSize(txtArea.width, tHeight);
			//txtArea.invalidate(InvalidationType.SIZE);
			//txtArea.mcTextArea.invalidate(InvalidationType.SIZE);
			// also tried adding a click listener that would stop the click from propagating, didnt work

			txtTitle.htmlText = CommonUtils.toUpperCaseSafe( _data.TextTitle );
			if (txtTitle.text == "")
			{
				if(txtArea)
					txtArea.y = 16.85;
				else if(mcTextArea)
					mcTextArea.y = 16.85;
				mcHeader.visible = false;
			}

			if(txtArea)
				curHeight = txtArea.y + txtArea.mcScrollbar.height + HEIGHT_PADDING;
			else if (mcTextArea)
				curHeight = mcTextArea.y + mcTextArea.textHeight + HEIGHT_PADDING_AFTER_TEXT + HEIGHT_PADDING;

			if(mcSecondaryText) {
				mcSecondaryText.y = curHeight;
				curHeight += mcSecondaryText.textHeight + HEIGHT_PADDING;
			}

			if(_data.URLButtons)
			{
                for(i = 0; i < _data.URLButtons.length; i++)
                {
                    var buttonData = _data.URLButtons[i] as Object;
                    var button : URLButton = createURLButton(buttonData);
                   
                    button.x = 30;
                    button.y = curHeight + 15;
                    curHeight += button.textField.height + HEIGHT_PADDING_URL_BUTTONS;
					button.index = i;

					button.tryResizeWidth(mcBackground.width - 2 * 30);
                }
				curHeight += HEIGHT_PADDING_BETWEEN_CB_AND_URL;
			}
			
            if(_data.CheckBoxes)
            {
                for(i = 0; i < _data.CheckBoxes.length; i++)
                {
                    var checkboxData = _data.CheckBoxes[i] as Object;
                    var checkbox : CheckboxListItem = createCheckbox(checkboxData);
                   
                    checkbox.x = 50; //(mcBackground.width - 690) / 2; //50;
					if(CoreComponent.isArabicAligmentMode)
						checkbox.x = mcBackground.width - 50 - checkbox.width + 23.5 * 2; //23.5 is magic translation in flash
                    checkbox.y = curHeight + 15;
                    curHeight += checkbox.textField.height + HEIGHT_PADDING_CHECKBOXES;
					checkbox.index = i;
                }
				if(selectedIndex == -1 && checkboxes.length > 0)
				{
					selectedIndex = 0;
					handleCheckboxHighlighting();
				}
            }

			mcInputBackground.y  = curHeight - mcInputBackground.height / 2 + INPUT_PUSH;
			mcInpuFeedback.y = mcInputBackground.y + mcInputBackground.height / 2;

			curHeight += mcInputBackground.height;

			mcBackground.height = curHeight + FINAL_HEIGHT_PADDING;
			//handleButtonList(areAllCheckboxesClicked());
			mcInputBackground.width = mcInpuFeedback.buttonsContainer.width + INPUT_PADDING;
			mcInputBackground.x = mcBackground.width / 2;
			if (parent is IngameMenu)
			{
				this.x = (1920 - mcBackground.width) / 2;
				this.y = (1080 - mcBackground.height) / 2;

				if(mcImagePanel) {
					mcImagePanel.x = (mcBackground.width - mcImagePanel.width) / 2
					mcImagePanel.y = 1080 - mcImagePanel.height - this.y;
					mcImagePanel.mcQRText.y = (mcImagePanel.height - mcImagePanel.mcQRText.textHeight - 5) / 2;
					mcImagePanel.mcQRCode.y = (mcImagePanel.height - mcImagePanel.mcQRCode.height) / 2;
					//trace("GFX QRCode positioning: iph, ipy, qrh mcbgh", mcImagePanel.height, mcImagePanel.y, mcImagePanel.mcQRCode.height, mcBackground.height);
				}
			}
			else 
			{
				super.populateData();
			}
			
			mcInpuFeedback.clearHotkeys();
		}

		protected function clearCheckboxes():void
		{
			for(var i = 0; i < checkboxes.length; i++)
			{
				removeChild(checkboxes[i]);
			}
			checkboxes = new Vector.<CheckboxListItem>();
		}

        protected function createCheckbox(data : Object):CheckboxListItem
        {
            // spawn checkboxes
            var checkboxRef = getDefinitionByName("ModuleFilters_CheckboxListItem") as Class;
            var checkbox = new checkboxRef() as CheckboxListItem;
            addChild(checkbox);
            checkboxes.push(checkbox);

            registerMouseEventsForItem(checkbox);
			var label : String = data.label;
			if ( CoreComponent.isArabicAligmentMode )
			{
				label = "<p align=\"right\">" + label +"</p>";
			}
            checkbox.textField.htmlText = label;
			checkbox.textField.height = checkbox.textField.textHeight + 5

			if(data.checked)
			{
				checkbox.isChecked = true;
				
				if(checkbox.getChildByName("mcSelection") && checkbox.getChildByName("mcSelection").getChildByName("mcSelection"))
				{
					checkbox.getChildByName("mcSelection").getChildByName("mcSelection").height = checkbox.textField.height + 5;
				}
			}
			else
			{
				checkbox.isChecked = false;
				checkbox.gotoAndStop("selected_up");
				if(checkbox.getChildByName("mcSelection") && checkbox.getChildByName("mcSelection").getChildByName("mcSelection"))
				{
					checkbox.getChildByName("mcSelection").getChildByName("mcSelection").height = checkbox.textField.height + 5;
				}
				checkbox.gotoAndStop("up");
			}
			
            return checkbox;
        }

		protected function createURLButton(data : Object):URLButton
        {
            // spawn checkboxes
            var buttonRef = getDefinitionByName("URLButton") as Class;
            var button = new buttonRef() as URLButton;
            addChild(button);
            buttons.push(button);
			button.setLabel(data.label);
			button.setUrlIndex(data.link)
			button.validateNow();
			
            return button;
        }

        protected function registerMouseEventsForItem(item:CheckboxListItem):void
		{
			if (item)
			{
				item.addEventListener(MouseEvent.CLICK, onItemTappedOrClicked, false, 1, true);
				item.addEventListener(MouseEvent.MOUSE_OVER, onItemMouseOver, false, 1, true);
				item.addEventListener(MouseEvent.MOUSE_OUT, onItemMouseOut, false, 1, true);

				item.addEventListener(GestureEventEx.GESTURE_TAP, onItemTappedOrClicked, false, 1, true);
			}
		}
		
		protected function unregisterMouseEventsForItem(item:CheckboxListItem):void
		{
			if (item)
			{
				item.removeEventListener(MouseEvent.CLICK, onItemTappedOrClicked);
				item.removeEventListener(MouseEvent.MOUSE_OVER, onItemMouseOver);
				item.removeEventListener(MouseEvent.MOUSE_OUT, onItemMouseOut);

				item.removeEventListener(GestureEventEx.GESTURE_TAP, onItemTappedOrClicked);
			}
		}

		private function onCheckboxSelectionEnabled(checkbox:CheckboxListItem)
		{
			//#LT hacky but this ensures that the checkbox selection is sized big enough...
			if(MovieClip(checkbox.getChildByName("mcSelection")) && MovieClip(MovieClip(checkbox.getChildByName("mcSelection")).getChildByName("mcSelection")))
			{
				var minHeight = 42.3;
				var newHeight = checkbox.textField.height + 5;
				newHeight = Math.max(newHeight, minHeight);
				MovieClip(MovieClip(checkbox.getChildByName("mcSelection")).getChildByName("mcSelection")).height = newHeight;
			}
		}
		
		protected function onItemTappedOrClicked(event:Event):void
		{
            var selectedItem : CheckboxListItem = event.currentTarget as CheckboxListItem;
                
            if (selectedItem)
            {
                selectedIndex = checkboxes.indexOf(selectedItem);

				if (event is GestureEvent )
				{
					handleCheckboxHighlighting();
				}
				
                toggleValue(selectedItem);
            }
		}
		
		protected function onItemMouseOver(event:MouseEvent):void
		{
			var currentTarget:CheckboxListItem = event.currentTarget as CheckboxListItem;
			
            currentTarget.selected = true;

			onCheckboxSelectionEnabled(currentTarget);
		}
		
		protected function onItemMouseOut(event:MouseEvent):void
		{
			for(var i : int; i < checkboxes.length; i++)
            {
                checkboxes[i].selected = false;
            }
		}

		private function handleButtonList(allClicked:Boolean)
		{
			var tempButtonList : Array = [];
			for(var i : int = 0; i < buttonList.length; i++)
			{
				if(buttonList[i].gamepad_navEquivalent != NavigationCode.GAMEPAD_A || allClicked)
					tempButtonList.push(buttonList[i]);
			}
			mcInpuFeedback.handleSetupButtons(tempButtonList);
			mcInputBackground.width = mcInpuFeedback.buttonsContainer.width + INPUT_PADDING;
		}

        protected function toggleValue(target:CheckboxListItem):void
		{
			if (target)
			{
				target.isChecked = !target.isChecked;
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_switch"]));

				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSetCheckboxesClicked', [target.index, target.isChecked] ) );
			}
		}

		private function handleCheckboxHighlighting():void
		{
			var i : int = 0;
			for(i = 0; i < checkboxes.length; i++)
			{
				checkboxes[i].selected = i == selectedIndex;
				if(i == selectedIndex)
					onCheckboxSelectionEnabled(checkboxes[i]);
			}
		}

		private function getInvertIndex():int
		{
			return buttons.length + selectedIndex;
		}

		private function handleUrlButtonHighlighting():void
		{
			var invertIndex : int = getInvertIndex();
			var i : int = 0;
			for(i = 0; i < buttons.length; i++)
			{
				buttons[i].selected = i == invertIndex;
				if(i == invertIndex)
				{
					buttons[i].doRollOver();
				}
				else
				{
					buttons[i].doRollOut();
				}
			}
		}

        override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);
			var details:InputDetails = event.details;
			if (event.handled || details.value == InputValue.KEY_DOWN || !visible)
			{
				// ignore
				return;
			}

			
			switch( details.navEquivalent )
			{
				case NavigationCode.UP:
					if(selectedIndex >= -buttons.length) {
                        selectedIndex--;
						handleCheckboxHighlighting();
						handleUrlButtonHighlighting();
                    }
					event.handled = true;
					break;
					
				case NavigationCode.DOWN:
					if(selectedIndex < checkboxes.length - 1) {
                        selectedIndex++;
						handleCheckboxHighlighting();
						handleUrlButtonHighlighting();
                    }
					event.handled = true;
					break;
			}
			
			if ( !event.handled )
			{
				var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

                if(((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y) ||		// Y on switch
					(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X) ||		// X on other platforms
					details.code == KeyCode.SPACE) &&
					details.value == InputValue.KEY_UP)
                {
                    if(selectedIndex >= 0)
                        toggleValue(checkboxes[selectedIndex]);
                }

				if((details.navEquivalent == NavigationCode.GAMEPAD_A || details.code == KeyCode.SPACE) && details.value == InputValue.KEY_UP)
                {
                    if(selectedIndex < 0) {
                        buttons[getInvertIndex()].signalOpenUrl();
						event.handled = true;
					}
                }
			}
			
		}

		private function areAllCheckboxesClicked():Boolean
		{
			for(var i : int = 0; i < checkboxes.length; i++)
			{
				if(!checkboxes[i].isChecked)
					return false;
			}
			return true;
		}

	}

}