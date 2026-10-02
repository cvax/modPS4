/***********************************************************************
/** Report window with a dropdown for reasons, input field, and buttons
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.getDefinitionByName;
    import flash.events.MouseEvent;
	import flash.utils.setTimeout;

    import scaleform.clik.core.UIComponent;
    import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;

    import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

    import red.core.events.GameEvent;
    import red.core.constants.KeyCode;

    import red.game.witcher3.controls.W3DropdownMenuListItem;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
    import red.game.witcher3.menus.common.DropdownListModuleBase;
	import red.game.witcher3.utils.CommonUtils;

	public class ModReportWindow extends UIComponent
	{
        private static const IFB_CANCEL : int = 1000;
        private static const IFB_SUBMIT_REPORT : int = 2000;
		private static const IFB_ENTER_TEXT : int = 3000;
		private static const IFB_OK : int = 4000;
		private static const IFB_TERMS_OF_USE : int = 5001;
		private static const IFB_PRIVACY_POLICY : int = 5002;

		private static const TEXT_GAP_AFTER_Y : Number = 13;
		private static const DD_GAP_BEFORE_Y : Number = 0;
		private static const TEXTINPUT_GAP_BEFORE_Y : Number = 5;
		private static const PREVIEW_GAP_BEFORE_Y : Number = 5;
		private static const PREVIEW_GAP_AFTER_Y : Number = 10;

        //ART CLIPS
		public var mcWindow					: 	MovieClip;
		public var mcHeader					:	MovieClip;
        public var mcReportListModule       :   DropdownListModuleBase;
		public var mcSecondaryListModule    :   DropdownListModuleBase;
        public var tfTextInput              :   W3TextInput;
		public var mcInputFeedbackTop          :   ModuleInputFeedback;
        public var mcInputFeedback          :   ModuleInputFeedback;
        public var mcInputBackground        :   MovieClip;
        public var mcBG                     :   MovieClip;
		public var mcDropdownBG				:	MovieClip;
		public var mcDropdownBGSecondary	:	MovieClip;
		public var mcThinPreview			:	ThinModPreview;
		public var mcLoadIndicator			:	MovieClip;

		public var tfTitle					:	TextField;
		public var tfDescription			:	TextField;
		public var tfReason					:	TextField;
		public var tfReasonSecondary		:	TextField;
		public var tfTextDetails			:	TextField;
		public var tfTime 					:	TextField;
		public var tfThanks					:	TextField;

        //VARS
        private var reportModid             :   String = "0";
        private var currentObj 				: 	MovieClip;
		private var cachedType 				: 	String;
		private var cachedLatestCategoryName:	String = "";
		private var cachedLatestCategoryName2:	String = "";

		protected function get menuName():String { return "ModMenu"; }

        function ModReportWindow()
        {

        }

		private function onTryClose():void
		{
			if(tfTextInput.text.length > 0 && cachedType != "finished" && cachedType != "failed")
				askForCloseConfirmation()
			else
				onCloseFinalize();
		}

		private function askForCloseConfirmation():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnCloseReportWindow" ) );
		}

		public function onCloseFinalize():void
		{
			visible = false;
			swapCurrentObject(null);
		}

        override protected function configUI():void
		{
			super.configUI();
            //registerButtons();
            mcReportListModule.mcDropDownList.listHeight = 510;

			tfTextInput.multiline = true;
            tfTextInput.skipKeys.push(KeyCode.DOWN);
			tfTextInput.skipKeys.push(KeyCode.UP);
			tfTextInput.maxChars = 1024;
			tfTextInput.textInputManager = ModStatics.getModMenu().textInputManager;

            mcBG.addEventListener(MouseEvent.CLICK, function() { onTryClose(); }, false, -1);
			setupForm("default");
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.report.radio.clicked', [onRadioPressed] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.report.setup.form', [setupForm] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.report.position.bg', [positionBg] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'mods.report.secondary.list', [onSecondaryListDataGot] ) );

			mcReportListModule.addEventListener(MouseEvent.CLICK, onModuleMouseClick, false, -100);
			mcSecondaryListModule.addEventListener(MouseEvent.CLICK, onModuleMouseClick, false, -100);
			tfTextInput.addEventListener(MouseEvent.CLICK, onModuleMouseClick, false, -100);

			tfTitle.text = CommonUtils.toUpperCaseSafe(tfTitle.text);
			positionBg({type: "primary", opened: true});
			mcLoadIndicator.visible = false;

			mcInputFeedback.mcInputBackground = mcInputBackground;
			mcInputFeedback.buttonAlign = "center";
			mcInputFeedbackTop.buttonAlign = "center";
			
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
		}

		private function handleControllerChanged(event:ControllerChangeEvent):void
		{
			unregisterSubmitButton();
			registerSubmitButton();
		}

		public function onSwapToThis(modid:String, name:String):void
        {
            swapCurrentObject(mcReportListModule);
			tfTextInput.resetText();
			mcThinPreview.setData({modName: name, modid: modid});
			setupForm("default");
			reportModid = modid;
        }

        private function registerButtons():void
        {
			if (!mcInputFeedback.hasButton(IFB_CANCEL))
            	mcInputFeedback.appendButton(IFB_CANCEL, NavigationCode.GAMEPAD_B, KeyCode.ESCAPE, "[[panel_mods_cancel]]", false);

			if (!mcInputFeedbackTop.hasButton(IFB_PRIVACY_POLICY))
				mcInputFeedbackTop.appendButton(IFB_PRIVACY_POLICY, NavigationCode.GAMEPAD_LSTICK_HOLD, KeyCode.F, "[[panel_mods_link_modio_pp]]", false);

			if (!mcInputFeedbackTop.hasButton(IFB_TERMS_OF_USE))
				mcInputFeedbackTop.appendButton(IFB_TERMS_OF_USE, NavigationCode.GAMEPAD_RSTICK_HOLD, KeyCode.T, "[[panel_mods_link_modio_tos]]", false);

			registerSubmitButton();
        }

		private function unregisterButtons():void
		{
			mcInputFeedbackTop.removeButton(IFB_PRIVACY_POLICY, true);
			mcInputFeedbackTop.removeButton(IFB_TERMS_OF_USE, true);
			unregisterCancelButton();
			unregisterSubmitButton();
		}

		private function registerSubmitButton():void
        {
			if(!mcInputFeedback.hasButton(IFB_SUBMIT_REPORT))
			{
				var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
				mcInputFeedback.appendButton(IFB_SUBMIT_REPORT, isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, KeyCode.R, "[[panel_mods_submit_report]]", true);
			}
        }

		private function registerTryAgainButton():void
        {
			if(!mcInputFeedback.hasButton(IFB_SUBMIT_REPORT))
			{
				var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
				mcInputFeedback.appendButton(IFB_SUBMIT_REPORT, isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, KeyCode.R, "[[panel_mods_report_try_again]]", true);
			}
        }

		private function unregisterSubmitButton():void
        {
			mcInputFeedback.removeButton(IFB_SUBMIT_REPORT, true);
        }

		private function unregisterCancelButton():void
        {
			mcInputFeedback.removeButton(IFB_CANCEL, true);
		}

		private function registerOkutton():void
        {
			if(!mcInputFeedback.hasButton(IFB_OK))
				mcInputFeedback.appendButton(IFB_OK, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_button_common_accept]]", true);
        }

		private function unregisterOkButton():void
        {
			mcInputFeedback.removeButton(IFB_OK, true);
        }

        public function onSubmitReport():void
        {
			if(cachedType != "finished" && cachedType != "loading")
            	dispatchEvent( new GameEvent( GameEvent.CALL, "OnSubmitReport", [reportModid, tfTextInput.text] ) );
        }

		protected function isDropdownOpen( dd : DropdownListModuleBase ):Boolean
		{
			if(!dd.visible)
				return false;

			var tempRenderer : W3DropdownMenuListItem;
			tempRenderer = dd.mcDropDownList.getRendererAt( 0 ) as W3DropdownMenuListItem;
			return tempRenderer && tempRenderer.isOpen();
		}

		protected function positionBg( obj:Object ):void
		{
			var dd : DropdownListModuleBase;
			var ddbg : MovieClip;
			
			if(obj.type == "primary")
			{
				dd = mcReportListModule;
				ddbg = mcDropdownBG;
			}
			else
			{
				dd = mcSecondaryListModule;
				ddbg = mcDropdownBGSecondary;
			}

			if(obj.opened && dd.visible)
			{
				if(ddbg)
				{
					ddbg.visible = true;
					ddbg.x = dd.x + 64;
					ddbg.y = dd.y + 20;
					var classRef:Class = getDefinitionByName(dd.mcDropDownList.dropdownMenuItemRenderer) as Class;
					var tempRenderer:MovieClip = new classRef() as MovieClip;
					ddbg.height = tempRenderer.height; 
					if(dd.currentDataArrayRef)
						ddbg.height *= dd.currentDataArrayRef.length;
					else
						ddbg.height *= 7;
					ddbg.height += 62;
					if(dd.parent && DisplayObjectContainer(dd.parent).contains(ddbg))
					{
						var ddIndex:int = dd.parent.getChildIndex(dd);
						dd.parent.setChildIndex(ddbg, Math.max(0, ddIndex - 1));
					}
					else if (dd.parent)
					{
						var insertIndex:int = Math.max(0, dd.parent.getChildIndex(dd));
						dd.parent.addChildAt(ddbg, insertIndex);
					}
				}

				var locKey : String = "";
				if(dd == mcReportListModule)
					locKey = "mods_report_reason";
				else if(dd == mcSecondaryListModule)
					locKey = "mods_report_reason_not_working";
				
				if(dd && dd.mcDropDownList)
				{
					var firstDDRenderer2 = dd.mcDropDownList.getRendererAt(0);
					if(firstDDRenderer2)
						firstDDRenderer2.label = CommonUtils.getLocalization(locKey);
				}
			}
			else
			{
				if(ddbg)
					ddbg.visible = false;

				if(dd && dd.mcDropDownList)
				{
					var firstDDRenderer = dd.mcDropDownList.getRendererAt(0);
					if(firstDDRenderer)
					{
						if(dd == mcReportListModule)
							firstDDRenderer.label = cachedLatestCategoryName;
						else if(dd == mcSecondaryListModule)
							firstDDRenderer.label = cachedLatestCategoryName2;
					}
				}
			}
		}

		public function onSecondaryListDataGot(data:Array):void
		{
			var temp = mcSecondaryListModule.mcDropDownList.getRendererAt( 0 );
			temp.close();
		}

        protected function dropdownClose( dd : DropdownListModuleBase ):void
        {
			trace("dd close", dd);
            dd.focused = 0;
			dd.inputEnabled = false;
			dd.enabled = false;
			dd.mcDropDownList.selectedIndex = -1;

            var tempRenderer : W3DropdownMenuListItem;
			tempRenderer = dd.mcDropDownList.getRendererAt( 0 ) as W3DropdownMenuListItem;

            if ( tempRenderer && tempRenderer.isOpen() ) 
                tempRenderer.close();
			trace("dd close end");
        }

        protected function dropdownOpen( dd : DropdownListModuleBase ):void
        {
            dd.focused = 1;
			dd.inputEnabled = true;
			dd.enabled = true;
			dd.mcDropDownList.selectedIndex = 0;

            var tempRenderer : W3DropdownMenuListItem;
			    tempRenderer = dd.mcDropDownList.getRendererAt( 0 ) as W3DropdownMenuListItem;

            //if ( tempRenderer && !tempRenderer.isOpen() ) 
            //    tempRenderer.open();
        }

		protected function onModuleMouseClick(event:MouseEvent):void
		{
			trace("GFX",this,"onModuleMouseClick");
			var currentTarget : MovieClip = event.currentTarget as MovieClip;
			if(currentTarget) {
				if(currentTarget != mcReportListModule && currentObj == mcReportListModule)
				{
					dropdownClose(mcReportListModule);
					if(currentTarget == mcSecondaryListModule)
						positionBg({type: "secondary", opened: true});
				}
				else if(currentTarget != mcSecondaryListModule && currentObj == mcSecondaryListModule)
				{
					dropdownClose(mcSecondaryListModule);
					if(currentTarget == mcReportListModule)
						positionBg({type: "primary", opened: true});
				}
				swapCurrentObject(currentTarget, true);
			}
		}

        protected function clearPreviousObject(mouseOrigin:Boolean = false):void
		{
			//Handling previous object clear
			if(!currentObj)
				return;
			if(currentObj == mcReportListModule)
			{
                dropdownClose(mcReportListModule);
			}
			else if(currentObj == mcSecondaryListModule)
			{
                dropdownClose(mcSecondaryListModule);
			}
            else if (currentObj == tfTextInput)
            {
                tfTextInput.focused = 0;
				stage.focus = parent;
				mcInputFeedback.removeButton(IFB_ENTER_TEXT, true);
            }
		}

		protected function setupNewObject(mouseOrigin:Boolean = false):void
		{
			//Handling new object setup
			if(!currentObj)
				return;
			if(currentObj == mcReportListModule)
			{
                dropdownOpen(mcReportListModule);
			}
			else if(currentObj == mcSecondaryListModule)
			{
                dropdownOpen(mcSecondaryListModule);
			}
            else if (currentObj == tfTextInput)
			{
				tfTextInput.focused = 1;
				stage.focus = tfTextInput;
				if(!tfTextInput.textInputManager)
					tfTextInput.textInputManager = ModStatics.getModMenu().textInputManager;
				
				var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
				mcInputFeedback.appendButton(IFB_ENTER_TEXT, isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X, -1, "[[panel_enter_text]]", true);
				tfTextInput.virtualKbKey = isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X;
			}
		}

        protected function swapCurrentObject(newObj:MovieClip, mouseOrigin:Boolean = false):void
		{
			if(currentObj == newObj)
				return;

			if(currentObj && newObj)
				trace("GFX - ReportWindow - Swap:",currentObj.name,newObj.name);
			else
				trace ("GFX - ReportWindow - Swap unnamed");

			trace("GFX - Swap: Mouse:",mouseOrigin);

			clearPreviousObject(mouseOrigin);

			currentObj = newObj;

			setupNewObject(mouseOrigin);
		}


        protected function handleUp(event:InputEvent):void
		{
			var tempRenderer : W3DropdownMenuListItem;
			trace("GFX handleup", currentObj, currentObj == mcSecondaryListModule);
            if(currentObj == tfTextInput)
            {
				if(cachedType == "default")
                	swapCurrentObject(mcReportListModule);
				else if (cachedType == "notworking") {
					swapCurrentObject(mcSecondaryListModule);
				}
                event.handled = true;
            }
			else if (currentObj == mcSecondaryListModule)
			{
			    tempRenderer = mcReportListModule.mcDropDownList.getRendererAt( 0 ) as W3DropdownMenuListItem;

				trace("GFX handleup selected", tempRenderer.selectedIndex);

                if(tempRenderer.selectedIndex == -1)//tempRenderer.GetDropdownListRef().getAllRenderers().length - 1)
				{
                    swapCurrentObject(mcReportListModule);
				}
				event.handled = true;
			}
            else if (isCurrentObjUnhandled())
			{
				selectDefaultElement();

				event.handled = true;
			}
        }

        protected function handleDown(event:InputEvent):void
		{
			var tempRenderer : W3DropdownMenuListItem;
            if(currentObj == mcReportListModule)
            {
			    tempRenderer = mcReportListModule.mcDropDownList.getRendererAt( 0 ) as W3DropdownMenuListItem;

                if(tempRenderer.selectedIndex <= 0)
				{
					if(cachedType == "default")
                    	swapCurrentObject(tfTextInput);
					else if(cachedType == "notworking")
                    	swapCurrentObject(mcSecondaryListModule);
				}
				event.handled = true;
            }
			else  if(currentObj == mcSecondaryListModule)
            {
			    tempRenderer = mcSecondaryListModule.mcDropDownList.getRendererAt( 0 ) as W3DropdownMenuListItem;

                if(tempRenderer.selectedIndex <= 0)
				{
                    swapCurrentObject(tfTextInput);
				}
				event.handled = true;
            }
            else if (isCurrentObjUnhandled())
			{
				selectDefaultElement();

				event.handled = true;
			}
        }

        public override function handleInput(event:InputEvent):void
        {
            trace("GFX repWindow input handled", event.handled,event);
            trace("GFX currentObj",currentObj);
			trace("GFX naveqv", event.details.navEquivalent);

            var details:InputDetails = event.details;

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var hold:Boolean = details.value == InputValue.KEY_HOLD;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

			if(!CommonUtils.isActuallyVisible(this))
				return;

            if (!event.handled)
			{
				if(cachedType == "default" || cachedType == "notworking")
				{
					if(details.navEquivalent == NavigationCode.DOWN && (keyDown || hold))
					{
						handleDown(event);
					}
					else if (details.navEquivalent == NavigationCode.UP && (keyDown || hold))
					{
						handleUp(event);
					}
				}

                if(event.handled)
                    return;

				switch (details.navEquivalent)
				{
				case NavigationCode.GAMEPAD_A:
					if (keyDown && cachedType == "finished")
					{
						onTryClose();
						event.handled = true;
					}
					break;
				case NavigationCode.GAMEPAD_B:
					if (keyDown && details.code != KeyCode.ESCAPE)
					{
						onTryClose();
						event.handled = true;
					}
					break;
                case NavigationCode.GAMEPAD_Y:
                case NavigationCode.GAMEPAD_X:
					if (keyDown &&
						((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X) ||		// X on switch
						(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y)))		// Y on other platforms
					{
						onSubmitReport();
						event.handled = true;
					}
					break;
				case NavigationCode.GAMEPAD_L3:
					if(keyDown)
					{
						openUrlCall("pp");
						event.handled = true;
					}
					break;
				case NavigationCode.GAMEPAD_R3:
					if(keyDown)
					{
						openUrlCall("tos");
						event.handled = true;
					}
					break;
				default:
					break;
				}
			}
			if (keyUp && !event.handled)
			{
				if (details.code == KeyCode.ESCAPE)
				{
					onTryClose();
					event.handled = true;
				}
                else if (details.code == KeyCode.R)
				{
					onSubmitReport();
					event.handled = true;
				}
				else if (details.code == KeyCode.E || details.code == KeyCode.ENTER)
				{
					if (keyUp && cachedType == "finished")
					{
						onTryClose();
						event.handled = true;
					}
				}
				else if (details.code == KeyCode.T)
				{
					openUrlCall("tos");
					event.handled = true;
				}
				else if (details.code == KeyCode.F)
				{
					openUrlCall("pp");
					event.handled = true;
				}
			}

			if(event.handled)
				return;

			var tempRenderer : W3DropdownMenuListItem;
			var itemRenderer : ModFilterItemRenderer;
			var index : int;

			if ((details.navEquivalent == NavigationCode.GAMEPAD_A || details.code == KeyCode.SPACE) && keyUp)
			{
				if (currentObj == mcReportListModule)
				{
					index = mcReportListModule.mcDropDownList.selectedIndex;
					tempRenderer = mcReportListModule.mcDropDownList.getRendererAt( index ) as W3DropdownMenuListItem;
					
					if(tempRenderer && tempRenderer.selectedIndex >= 0)
					{
						itemRenderer = tempRenderer.GetDropdownListRef().getRendererAt(tempRenderer.selectedIndex) as ModFilterItemRenderer;
						itemRenderer.onEnabledChange();
						event.handled = true;
						return;	
					}
					else trace("GFX @@@@@@@@@@@@@@@@@@@@@@ on the collapsible thingy");
				}
				else if (currentObj == mcSecondaryListModule)
				{
					index = mcSecondaryListModule.mcDropDownList.selectedIndex;
					tempRenderer = mcSecondaryListModule.mcDropDownList.getRendererAt( index ) as W3DropdownMenuListItem;
					
					if(tempRenderer.selectedIndex >= 0)
					{
						itemRenderer = tempRenderer.GetDropdownListRef().getRendererAt(tempRenderer.selectedIndex) as ModFilterItemRenderer;
						itemRenderer.onEnabledChange();
						event.handled = true;
						return;	
					}
					else trace("GFX @@@@@@@@@@@@@@@@@@@@@@ on the collapsible thingy");
				}
			}
        }

		protected function openUrlCall(urlCode : String)
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnOpenUrlByCode", [urlCode] ) );
		}

		protected function tryRememberingCategoryName(dd : DropdownListModuleBase, selectedIndex : int, value:int):void
		{
			var newName : String = dd.currentDataArrayRef[selectedIndex].label;
			if(value == 0 && dd == mcReportListModule)
				newName = "[[mods_report_reason]]";
			else if(value == 0 && dd == mcSecondaryListModule)
				newName = "[[mods_report_reason_not_working]]";
			if(dd == mcReportListModule)
				cachedLatestCategoryName = newName;
			else if (dd == mcSecondaryListModule)
				cachedLatestCategoryName2 = newName;
		}

        protected function isCurrentObjUnhandled():Boolean
		{
            trace("GFX isUnhandled");
			return currentObj == null || (currentObj != mcReportListModule && currentObj != tfTextInput && currentObj != mcSecondaryListModule);
		}

        protected function selectDefaultElement():void
		{
			swapCurrentObject(mcReportListModule);
		}

		private function resizeWindow(w:Number, h:Number):void
		{
			mcWindow.width = w;
			mcWindow.height = h;
			mcWindow.x = (1920 - mcWindow.width) / 2;
			mcWindow.y = (1080 - mcWindow.height) / 2;

			mcInputBackground.y = mcWindow.y + mcWindow.height - 67;
			mcInputBackground.x = mcWindow.x + (mcWindow.width - mcInputBackground.width) / 2;

			mcInputFeedback.y = mcInputBackground.y + 24;
			mcInputFeedback.x = mcInputBackground.x + mcInputBackground.width / 2 + 124;

			mcInputFeedbackTop.x = mcInputFeedback.x;
			mcInputFeedbackTop.y = mcInputFeedback.y - 44;
		}

		public function setupForm(type:String):void
		{
			cachedType = type;
			var yPos : Number;
			mcInputFeedbackTop.visible = true;
			if(type == "default")
			{
				resizeWindow(701.2, 550.8 + 44);
				yPos = mcWindow.y + 12;

				mcHeader.x = mcWindow.x;
				mcHeader.y = mcWindow.y;
				mcHeader.width = mcWindow.width;
				
				tfTitle.text = "[[mods_report_window_title]]";
				tfTitle.x = mcWindow.x + (mcWindow.width - tfTitle.width) / 2;
				tfTitle.y = mcWindow.y + 12;
				yPos += tfTitle.textHeight + TEXT_GAP_AFTER_Y + 5;

				/*tfDescription.text = "[[mods_report_window_description]]";
				tfDescription.x = mcWindow.x + 50;
				tfDescription.y = yPos;
				yPos += tfDescription.textHeight + TEXT_GAP_AFTER_Y;*/

				yPos += PREVIEW_GAP_BEFORE_Y;
				mcThinPreview.x = mcWindow.x + (mcWindow.width - mcThinPreview.width) / 2;
				mcThinPreview.y = yPos;
				yPos += mcThinPreview.height + PREVIEW_GAP_AFTER_Y;

				/*tfReason.x = mcWindow.x + 50;
				tfReason.y = yPos;
				yPos += tfReason.textHeight + TEXT_GAP_AFTER_Y;*/

				mcReportListModule.x = mcWindow.x + (mcWindow.width - mcReportListModule.width) / 2 - 17.8;
				mcReportListModule.y = yPos;
				yPos += 100;

				/*tfTextDetails.x = mcWindow.x + 50;
				tfTextDetails.y = yPos;
				yPos += tfTextDetails.textHeight + TEXT_GAP_AFTER_Y;*/

				yPos += TEXTINPUT_GAP_BEFORE_Y;
				tfTextInput.x = mcWindow.x + (mcWindow.width - tfTextInput.width) / 2;
				tfTextInput.y = yPos;
				yPos += tfTextInput.height + 10;

				/*yPos = mcInputBackground.y - mcInputBackground.height / 2 - tfTime.textHeight - TEXT_GAP_AFTER_Y;
				tfTime.x = mcWindow.x + 50;
				tfTime.y = yPos;*/

				tfDescription.visible = false;
				tfReason.visible = false;
				tfTextDetails.visible = false;
				tfTextInput.visible = true;
				tfTime.visible = false;
				mcReportListModule.visible = true;
				mcSecondaryListModule.visible = false;
				tfReasonSecondary.visible = false;
				tfThanks.visible = false;
				unregisterOkButton();
				registerButtons();
			}
			else if (type == "notworking")
			{
				resizeWindow(701.2, 600.8 + 44);
				yPos = mcWindow.y + 12;

				mcHeader.x = mcWindow.x;
				mcHeader.y = mcWindow.y;
				mcHeader.width = mcWindow.width;
				
				tfTitle.text = "[[mods_report_window_title]]";
				tfTitle.x = mcWindow.x + (mcWindow.width - tfTitle.width) / 2;
				tfTitle.y = mcWindow.y + 12;
				yPos += tfTitle.textHeight + TEXT_GAP_AFTER_Y + 5;

				/*tfDescription.text = "[[mods_report_window_description]]";
				tfDescription.x = mcWindow.x + 50;
				tfDescription.y = yPos;
				yPos += tfDescription.textHeight + TEXT_GAP_AFTER_Y;*/

				yPos += PREVIEW_GAP_BEFORE_Y;
				mcThinPreview.x = mcWindow.x + (mcWindow.width - mcThinPreview.width) / 2;
				mcThinPreview.y = yPos;
				yPos += mcThinPreview.height + PREVIEW_GAP_AFTER_Y;

				/*tfReason.x = mcWindow.x + 50;
				tfReason.y = yPos;
				yPos += tfReason.textHeight + TEXT_GAP_AFTER_Y;*/

				yPos += DD_GAP_BEFORE_Y;
				mcReportListModule.x = mcWindow.x + (mcWindow.width - mcReportListModule.width) / 2 - 17.8;
				mcReportListModule.y = yPos;
				yPos += 100;

				/*tfReasonSecondary.x = mcWindow.x + 50;
				tfReasonSecondary.y = yPos;
				yPos += tfReason.textHeight + TEXT_GAP_AFTER_Y;*/

				yPos += DD_GAP_BEFORE_Y;
				mcSecondaryListModule.x = mcWindow.x + (mcWindow.width - mcSecondaryListModule.width) / 2 - 17.8;
				mcSecondaryListModule.y = yPos;
				yPos += 100;

				/*tfTextDetails.x = mcWindow.x + 50;
				tfTextDetails.y = yPos;
				yPos += tfTextDetails.textHeight + TEXT_GAP_AFTER_Y;*/

				yPos += TEXTINPUT_GAP_BEFORE_Y;
				tfTextInput.x = mcWindow.x + (mcWindow.width - tfTextInput.width) / 2;
				tfTextInput.y = yPos;

				/*yPos = mcInputBackground.y - mcInputBackground.height / 2 - tfTime.textHeight - TEXT_GAP_AFTER_Y;
				tfTime.x = mcWindow.x + 50;
				tfTime.y = yPos;*/

				tfDescription.visible = false;
				tfReason.visible = false;
				tfTextDetails.visible = false;
				tfTextInput.visible = true;
				tfTime.visible = false;
				mcReportListModule.visible = true;
				mcSecondaryListModule.visible = true;
				tfReasonSecondary.visible = false;
				tfThanks.visible = false;
				mcLoadIndicator.visible = false;

				unregisterOkButton();
				registerButtons();
			}
			else if (type == "finished")
			{
				swapCurrentObject(null);
				resizeWindow(701.2, 300.8);
				yPos = mcWindow.y + 12;

				mcHeader.x = mcWindow.x;
				mcHeader.y = mcWindow.y;
				mcHeader.width = mcWindow.width;
				
				tfTitle.text = "[[panel_mods_report_finished]]";
				tfTitle.x = mcWindow.x + (mcWindow.width - tfTitle.width) / 2;
				tfTitle.y = mcWindow.y + 12;
				yPos += tfTitle.textHeight + TEXT_GAP_AFTER_Y + 5;

				//tfThanks.x = mcWindow.x + 50;
				//tfThanks.y = yPos;
				//yPos += tfThanks.textHeight + TEXT_GAP_AFTER_Y;

				tfDescription.text = "[[panel_mods_report_finished_description]]";
				tfDescription.x = mcWindow.x + 50;
				tfDescription.y = yPos;
				yPos += tfDescription.textHeight + TEXT_GAP_AFTER_Y;

				yPos += PREVIEW_GAP_BEFORE_Y;
				mcThinPreview.x = mcWindow.x + (mcWindow.width - mcThinPreview.width) / 2;
				mcThinPreview.y = yPos;
				yPos += mcThinPreview.height + PREVIEW_GAP_AFTER_Y;

				tfDescription.visible = true;
				tfReason.visible = false;
				tfTextDetails.visible = false;
				tfTextInput.visible = false;
				tfTime.visible = false;
				mcReportListModule.visible = false;
				mcSecondaryListModule.visible = false;
				tfReasonSecondary.visible = false;
				tfThanks.visible = false;
				mcLoadIndicator.visible = false;
				mcInputFeedbackTop.visible = false;
				unregisterSubmitButton();
				unregisterCancelButton();
				registerOkutton();
			}
			else if (type == "failed")
			{
				swapCurrentObject(null);
				resizeWindow(701.2, 300.8);
				yPos = mcWindow.y + 12;

				mcHeader.x = mcWindow.x;
				mcHeader.y = mcWindow.y;
				mcHeader.width = mcWindow.width;
				
				tfTitle.text = "[[mods_report_window_title]]";
				tfTitle.x = mcWindow.x + (mcWindow.width - tfTitle.width) / 2;
				tfTitle.y = mcWindow.y + 12;
				yPos += tfTitle.textHeight + TEXT_GAP_AFTER_Y + 5;

				tfDescription.text = "[[panel_mods_report_failed]]";
				tfDescription.x = mcWindow.x + 50;
				tfDescription.y = yPos;
				yPos += tfDescription.textHeight + TEXT_GAP_AFTER_Y;

				yPos += PREVIEW_GAP_BEFORE_Y;
				mcThinPreview.x = mcWindow.x + (mcWindow.width - mcThinPreview.width) / 2;
				mcThinPreview.y = yPos;
				yPos += mcThinPreview.height + PREVIEW_GAP_AFTER_Y;

				tfDescription.visible = true;
				tfReason.visible = false;
				tfTextDetails.visible = false;
				tfTextInput.visible = false;
				tfTime.visible = false;
				mcReportListModule.visible = false;
				mcSecondaryListModule.visible = false;
				tfReasonSecondary.visible = false;
				tfThanks.visible = false;
				mcLoadIndicator.visible = false;
				mcInputFeedbackTop.visible = false;
				registerButtons();
				unregisterSubmitButton();
				registerTryAgainButton();
			}
			else if (type == "loading")
			{
				resizeWindow(701.2, 350.8 + 44);
				yPos = mcWindow.y + 12;

				mcHeader.x = mcWindow.x;
				mcHeader.y = mcWindow.y;
				mcHeader.width = mcWindow.width;
				
				tfTitle.text = "[[mods_report_window_title]]";
				tfTitle.x = mcWindow.x + (mcWindow.width - tfTitle.width) / 2;
				tfTitle.y = mcWindow.y + 12;
				yPos += tfTitle.textHeight + TEXT_GAP_AFTER_Y + 5;

				tfDescription.text = "[[mods_report_processing]]";
				tfDescription.x = mcWindow.x + 50;
				tfDescription.y = yPos;
				yPos += tfDescription.textHeight + TEXT_GAP_AFTER_Y;

				yPos += PREVIEW_GAP_BEFORE_Y;
				mcThinPreview.x = mcWindow.x + (mcWindow.width - mcThinPreview.width) / 2;
				mcThinPreview.y = yPos;
				yPos += mcThinPreview.height + PREVIEW_GAP_AFTER_Y;

				yPos += PREVIEW_GAP_BEFORE_Y + 27.5;
				mcLoadIndicator.x = mcWindow.x + 50 + 40;
				mcLoadIndicator.y = yPos ;
				yPos += mcLoadIndicator.height + PREVIEW_GAP_AFTER_Y;

				tfDescription.visible = true;
				tfReason.visible = false;
				tfTextDetails.visible = false;
				tfTextInput.visible = false;
				tfTime.visible = false;
				mcReportListModule.visible = false;
				mcSecondaryListModule.visible = false;
				tfReasonSecondary.visible = false;
				tfThanks.visible = false;
				mcLoadIndicator.visible = true;
				mcInputFeedbackTop.visible = false;
				unregisterSubmitButton();
			}
		}

		public function onRadioPressed(data:Object):void
		{
			var index:int = data.index;
			var value:int = data.value;
			var ddRenderers : *;
			var i, j : int;
			var itemRenderer : ModFilterItemRenderer

			if(data.secondary)
			{
				ddRenderers = mcSecondaryListModule.mcDropDownList.getRenderers();
				dropdownClose(mcReportListModule);
				tryRememberingCategoryName(mcSecondaryListModule, index, value);
			}
			else
			{
				ddRenderers = mcReportListModule.mcDropDownList.getRenderers();
				dropdownClose(mcSecondaryListModule);
				tryRememberingCategoryName(mcReportListModule, index, value);
			}

			for(i = 0; i < ddRenderers.length; i++)
			{
				var tempRenderer : W3DropdownMenuListItem = ddRenderers[i] as W3DropdownMenuListItem;

				if(!tempRenderer.GetDropdownListRef())
					continue;
				
				var dropdownRenderers = tempRenderer.GetDropdownListRef().getAllRenderers();
				var indexFound:Boolean = false;
				for(j = 0; j < dropdownRenderers.length; j++)
				{
					itemRenderer = dropdownRenderers[j] as ModFilterItemRenderer;
					if(itemRenderer.data.index == index)
					{
						indexFound = true;
						break;
					}
				}

				if(indexFound)
				{
					for(j = 0; j < dropdownRenderers.length; j++)
					{
						itemRenderer = dropdownRenderers[j] as ModFilterItemRenderer;

						if(value == 0 || value == 2)
						{
							if(itemRenderer.data.index == index)
								itemRenderer.setEnabled(value);
						}
						else if (value == 1)
						{
							if(itemRenderer.data.index == index)
								itemRenderer.setEnabled(1); 
							else if (itemRenderer.data.value == 1)
								itemRenderer.setEnabled(0); 
						}						
					}
					if(data.secondary) 
					{
						dropdownClose(mcSecondaryListModule);
						positionBg({type: "secondary", opened: false});
						mcSecondaryListModule.mcDropDownList.selectedIndex = 0;
					}
					else 
					{
						dropdownClose(mcReportListModule);
						positionBg({type: "primary", opened: false});
						mcReportListModule.mcDropDownList.selectedIndex = 0;
					}
					
					return;
				}
			}
		}
    }

}