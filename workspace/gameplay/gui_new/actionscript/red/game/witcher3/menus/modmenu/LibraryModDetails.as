/***********************************************************************
/** Installed mod small detail object
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{

	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;

	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

	import red.core.CoreMenu;	
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;

	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.TextAreaModule;
	import red.game.witcher3.menus.common.TextAreaModuleCustomInput;
	import red.game.witcher3.menus.modmenu.ModMenuTextAreaModule;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;

	import red.game.witcher3.controls.W3UILoader;

	public class LibraryModDetails extends UIComponent
	{
		//CONSTS
		private static const BTN_UNSUBSCRIBE:int = 100;
		private static const BTN_MORE:int = 101;
		private static const BTN_DETAILS:int = 200;

		//ART CLIPS
		public var mcIcon								:	Bitmap;
		public var mcTextAreaModule						: 	ModMenuTextAreaModule;
		public var mcInputFeedback						:	ModuleInputFeedback;
		public var mcInputBackground					: 	MovieClip;

		public var mcCheckbox							: 	MovieClip;
		public var mcEnabledText						:	TextField;
		public var mcEnabledBG							:	MovieClip;

		public var mcSelection							:	MovieClip;
		public var mcLoader 							: 	W3UILoader;
		public var mcLoadingAnim						:	MovieClip;
		public var mc169preview							:	MovieClip;

		//VARS
		public var selected								: 	Boolean;
		public var bEnabled								: 	Boolean;
		public var index								: 	int;
		public var m_modid								:	String;
		private var cachedData							:	Object;

		protected function get menuName():String { return "ModMenu"; }


		override protected function configUI():void
		{
			super.configUI();
			mouseChildren = true;

			mcInputFeedback.mcInputBackground = mcInputBackground;
			mcInputFeedback.buttonAlign = "center";
			setupGeneralBindings();

			stage.addEventListener(InputEvent.INPUT, handleInputNavigate, false, -9, true);
			mcCheckbox.addEventListener(MouseEvent.CLICK, onCheckboxClicked, false, 0, true);
			mcLoader.addEventListener( Event.COMPLETE, handleLoadComplete, false, 0, true );
			mcSelection.visible = false;
			calculateEnabledPosition();

			mcInputFeedback.clearHotkeys();

			var inputMgr:InputManager = InputManager.getInstance();
			inputMgr.addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
		}

		public function onSelect():void
		{
			selected = true;
			mcTextAreaModule.selected = true;
			mcSelection.visible = true;
		}

		public function deselect():void
		{
			selected = false;
			mcTextAreaModule.selected = false;
			mcSelection.visible = false;
		}

		public function setData( data:Object ):void
		{
			cachedData = data;
			if(data.modDesc.length == 0)
				data.modDesc = "[[mods_no_description]]";
			mcTextAreaModule.SetTitle(data.modName);
			mcTextAreaModule.SetText(data.modDesc);
			setEnabled(data.enabled);
			index = data.id;

			if(data.modid)
			{
				m_modid = data.modid;
				//trace("GFX - data.modid",data.modid);
				var obj : MovieClip = this as MovieClip;
				while(obj.parent)
				{
					if(obj is ModMenu)
						break;
					else
						obj = obj.parent as MovieClip;
				}
				if(obj is ModMenu)
				{
					ModMenu(obj).callLogoLoad(mcLoader,data.modid);
				}
				else
				{
					trace("GFX - Issue: Not a freaking mod menu, how?")
				}
			}
		}

		public function setEnabled(value : Boolean):void
		{
			bEnabled = value;
			if(value)
				mcCheckbox.gotoAndStop(5);
			else
				mcCheckbox.gotoAndStop(1);
		}

		public function setVisible( value:Boolean)
		{
			if(value)
			{
				//alpha = 0;
				visible = value;
				GTweener.removeTweens(this);
				GTweener.to(this, 1, { alpha:1 }, { ease:Exponential.easeOut } );
			}
			else
			{
				GTweener.removeTweens(this);
				GTweener.to(this, 1, { alpha:0 }, { ease:Exponential.easeOut, onComplete: function(){ visible = value; } } );
			}
		}

		protected function calculateEnabledPosition():void
		{
			var tWidth : Number = mcEnabledText.textWidth + 5;
			var pudding : Number = 20; //imagine this in Dean Winchester's voice
			var puddingHeight : Number = 10;
			var puddingGap : Number = 5;
			var offsetX : Number = -5;
			var offsetY : Number = - 5;

			var frameWidth : Number = tWidth + mcCheckbox.width + pudding + puddingGap;
			var frameHeight : Number = mcCheckbox.height + puddingHeight;

			var left : Number = mc169preview.x + mc169preview.width - frameWidth + offsetX;
			var top : Number = mc169preview.y + mc169preview.height - frameHeight + offsetY;

			mcEnabledBG.x = left;
			mcEnabledBG.y = top;
			mcEnabledBG.mcElem.width = frameWidth;
			mcEnabledBG.mcElem.height = frameHeight;

			mcCheckbox.x = left + pudding / 2 + mcCheckbox.width / 2;
			mcCheckbox.y = top + puddingHeight / 2 + mcCheckbox.height / 2;
			mcEnabledText.x = mcCheckbox.x + mcCheckbox.width / 2 + puddingGap;
			mcEnabledText.y = top + puddingHeight / 2;

			removeChild(mcEnabledBG);
			removeChild(mcCheckbox);
			removeChild(mcEnabledText);

			addChild(mcEnabledBG);
			addChild(mcCheckbox);
			addChild(mcEnabledText);
		}

		protected function handleLoadComplete(e:Event):void
		{
			mcLoadingAnim.visible = false;
			mc169preview.visible = false;
			calculateEnabledPosition();
			removeChild(mcSelection);
			addChild(mcSelection);
		}

		/////////////////////////////////////////////////////////////////////////////
		// KEY BINDINGS - NAVIGATION
		/////////////////////////////////////////////////////////////////////////////

		protected function setupGeneralBindings():void
		{
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

			mcInputFeedback.appendButton(BTN_UNSUBSCRIBE, isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X, KeyCode.X, "[[panel_mods_unsubscribe]]", false);
			mcInputFeedback.appendButton(BTN_MORE, isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, KeyCode.R, "[[panel_mods_more]]", true);
			mcInputFeedback.appendButton(BTN_DETAILS, NavigationCode.GAMEPAD_START, KeyCode.T, "[[panel_mods_details]]", true);
			//mcInputFeedback.appendButton(IFB_UNSUBSCRIBE, NavigationCode.GAMEPAD_L1, KeyCode.PAGE_DOWN, "[[panel_button_common_prior_menu]]", false);
			//mcInputFeedback.appendButton(IFB_REPORT, NavigationCode.GAMEPAD_R1, KeyCode.PAGE_UP, "[[panel_button_common_next_menu]]", false);
		}

		protected function onUnsubscribeMod()
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnUnsubscribeInstalledMod", [index] ) );
		}

		protected function onMore()
		{
			var pa : MovieClip = MovieClip(parent);
			var grandpa : MovieClip = MovieClip(pa.parent);
			ModMenu(grandpa).openSandwichPanel(cachedData);
		}

		public function onDetails()
		{
			var pa : MovieClip = MovieClip(parent);
			var grandpa : MovieClip = MovieClip(pa.parent);
			ModMenu(grandpa).requestModDetails(m_modid, pa);
		}

		protected function handleControllerChanged(event:ControllerChangeEvent):void
		{
			mcInputFeedback.removeButton(BTN_UNSUBSCRIBE, false);
			mcInputFeedback.removeButton(BTN_MORE, false);
			mcInputFeedback.removeButton(BTN_DETAILS, false);
			setupGeneralBindings();
		}


		protected function handleInputNavigate(event:InputEvent):void
		{
			var details:InputDetails = event.details;

			if(!visible || !ModMenuInstalledPage(parent).visible || ModStatics.getModMenu().isInputBeingBlocked())
				return;

			if(!ModMenuInstalledPage(parent).hasInput(this))
				return;

			//"GFX - LibraryModDetails - handleInputNavigate", event);

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

			if (!event.handled)
			{
				switch (details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_R3:

						break;
					case NavigationCode.GAMEPAD_START:
						if(keyDown)
						{
							event.handled = true;
							onDetails();
						}
						break;
					case NavigationCode.GAMEPAD_Y:
					case NavigationCode.GAMEPAD_X:
						if(keyDown &&
							((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y) ||		// Y on switch
							(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X)))		// X on other platforms
						{
							event.handled = true;
							onUnsubscribeMod();
						}
						else if(keyDown &&
							((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X) ||		// X on switch
							(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y)))		// Y on other platforms
						{
							onMore();
							event.handled = true;
						}
						break;
					default:
						break;
				}
			}
			if (keyUp && !event.handled)
			{
				if(details.code == KeyCode.X)
				{
					onUnsubscribeMod();
					event.handled = true;
				}
				else if (details.code == KeyCode.R)
				{
					event.handled = true;
					onMore();
				}
				else if (details.code == KeyCode.T)
				{
					event.handled = true;
					onDetails();
				}
			}
		}

		private function fireEnabledChange()
		{
			setEnabled(!bEnabled);
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnLibraryModCheckboxClicked", [index, bEnabled] ) );
		}

		protected function onCheckboxClicked(event:MouseEvent)
		{
			fireEnabledChange()
		}

	}
}