/***********************************************************************
/** Remote mod preview
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;

	import flash.geom.Rectangle;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;

	import red.core.CoreMenu;	
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.core.CoreComponent;

	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.utils.CommonUtils;

	public class ModPreview extends UIComponent
	{
		// CONSTS
		private static const DL_STATE_UNSUBSCRIBED = -1;
		private static const DL_STATE_SUBSCRIBED = 200;
		private static const BTN_SUBSCRIBE:int = 100;
		// ART CLIPS
		public var mcBG					:	MovieClip;

		public var nameText 			:	TextField;
		public var downloadsText		:	TextField;
		public var likesText			:	TextField;
		public var sizeText				:	TextField;

		public var mcSubscribedTick		:	MovieClip;
		public var subscribedText		: 	TextField;
		//public var mcInputBackground	:	MovieClip;
		//public var mcInputFeedback		:	ModuleInputFeedback;
		public var mcProgressBar		: 	MovieClip;

		public var mcSelectionIndicator	:	MovieClip;

		public var mcLoader 							: 	W3UILoader;
		public var mcLoadingAnim						:	MovieClip;
		public var mc169preview							:	MovieClip;
		// VARS
		public var rowIndex				: 	int;
		public var columnIndex			:	int;

		private var imageLoader:Loader;
		private var imageHolder:Bitmap;

		private var bSelected			: 	Boolean;
		private var i_index				:	int;
		private var m_modid 			:	String;

		private var loadhandlerSet : Boolean = false;
		private var cachedData : Object;

		private var cachedState : int;
		private var cachedPercent : int;

		public function ModPreview()
		{
			super();
			//loadImage("https://dummyimage.com/640x360/eee/aaa");
			//loadImage("file:///Z:/aaa.png");
			//loadImage("textures/journal/treasure/img_treasurehunt_place.png");
			//loadImage("gameplay\gui_new\textures\journal\treasure\img_treasurehunt_place.png");

			//mcInputBackground.scrollRect = new Rectangle(0,0,100,100);
			//mcInputFeedback.scrollRect = new Rectangle(0,0,100,100);
		}

		override protected function configUI():void
		{
			super.configUI();
			mcSelectionIndicator.visible = false;

			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

			//mcInputFeedback.mcInputBackground = mcInputBackground;
			//mcInputFeedback.buttonAlign = "center";
			//mcInputFeedback.y = mcInputBackground.y + mcInputBackground.height / 2;
			
			setupGeneralBindings();
			setLoadHandler();
		}

		public function onSelect():void
		{
			bSelected = true;
			mcSelectionIndicator.visible = true;
			mcSelectionIndicator.gotoAndStop(1);
			stage.addEventListener(InputEvent.INPUT, handleInputNavigate, false, -9, true);
		}

		public function deselect():void
		{
			bSelected = false;
			mcSelectionIndicator.visible = false;
			stage.removeEventListener(InputEvent.INPUT, handleInputNavigate);
		}

		public function getWidth():Number
		{
			return mcBG.width;
		}

		public function getHeight():Number
		{
			return mcBG.height;
		}

		protected function handleLoadComplete(e:Event):void
		{
			//trace("load complete");
			mcLoadingAnim.visible = false;
			mc169preview.visible = false;

			removeChild(mcProgressBar);
			addChild(mcProgressBar);

			removeChild(mcSelectionIndicator);
			addChild(mcSelectionIndicator);

			var tickVisible = mcSubscribedTick.visible;
			removeChild(mcSubscribedTick);
			addChild(mcSubscribedTick);
			mcSubscribedTick.visible = tickVisible;
		}

		///////////////////////////////////////////////////////////////////////////////
		// INPUT HANDLING - NAVIGATION
		///////////////////////////////////////////////////////////////////////////////

		protected function setupGeneralBindings():void
		{
			//mcInputFeedback.appendButton(BTN_SUBSCRIBE, NavigationCode.GAMEPAD_A, KeyCode.E, "[[panel_mods_subscribe]]", true);
			//mcInputFeedback.appendButton(IFB_UNSUBSCRIBE, NavigationCode.GAMEPAD_L1, KeyCode.PAGE_DOWN, "[[panel_button_common_prior_menu]]", false);
			//mcInputFeedback.appendButton(IFB_REPORT, NavigationCode.GAMEPAD_R1, KeyCode.PAGE_UP, "[[panel_button_common_next_menu]]", false);
		}

		protected function onMouseOver(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
			if(bSelected)
				mcSelectionIndicator.gotoAndStop(1);
			else if ( !mcSelectionIndicator.visible )
			{
				mcSelectionIndicator.visible = true;
				mcSelectionIndicator.gotoAndPlay(1);
			}
		}

		protected function onMouseOut(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
			if(bSelected)
			{
				mcSelectionIndicator.gotoAndStop(1);
			}
			else
				mcSelectionIndicator.visible = false;
		}

		protected function handleInputNavigate(event:InputEvent):void
		{
			var details:InputDetails = event.details;

			if(!bSelected || cachedState != DL_STATE_UNSUBSCRIBED || !visible || !parent || !(parent as MovieClip) || !parent.parent || !(parent.parent as MovieClip) || !(parent.parent as MovieClip).visible)
				return;
			
			// parent.parent.parent.parent.parent.parent.parent.parent.parent....... :)
			if (parent.parent.parent && ModMenu(parent.parent.parent).isInputBeingBlocked())
				return;

			//trace("GFX - ModPreview - handleInputNavigate", event);
			//trace("GFX - ModPreview - handleInputNavigate reasons", bSelected, cachedState == DL_STATE_UNSUBSCRIBED, visible, (parent.parent as MovieClip).visible);

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;

			//event handling thing disabled because now this handler should only call when the object is actually selected
			//if (!event.handled)
			{
				if( ( details.navEquivalent == NavigationCode.GAMEPAD_A && keyDown ) || ( details.code == KeyCode.SPACE && keyUp ) ) //#L keyUp happens when input feedback is clicked
				{
					onSubscribeMod();
					//event.handled = true;
				}
			}
		}

		protected function onSubscribeMod()
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSubscribeMod", [i_index] ) );
		}


		///////////////////////////////////////////////////////////////////////////////
		// DATA HANDLING
		///////////////////////////////////////////////////////////////////////////////

		private function setLoadHandler():void
		{
			if(!loadhandlerSet) //#LT solution for when the image loads faster than the registering of the handle event
			{
				mcLoader.addEventListener( Event.COMPLETE, handleLoadComplete, false, 0, true );
				loadhandlerSet = true;
			}
		}

		public function setName(name:String)
		{
			var nameCopy : String = name;
			nameText.htmlText = nameCopy;

			while(nameText.textWidth > nameText.width && nameCopy.length > 0)
			{
				nameCopy = nameCopy.slice(0, -1);
				nameText.htmlText = nameCopy + "...";
				trace("GFX truncating to", nameCopy, nameText.textWidth);
			}

			if(CoreComponent.isArabicAligmentMode)
			{
				nameText.htmlText = "<p align=\"right\">" + nameText.htmlText + "</p>"
			}
		}

		public function setData( data:Object ):void
		{
			mouseEnabled = true;
			if(data)
			{
				cachedData = data;
				if(CoreComponent.isArabicAligmentMode)
					gotoAndStop("rtl");
				else
					gotoAndStop("ltr");

				m_modid = data.modid;
				setName(data.modName)
				setState(data);
				i_index = data.id;
				downloadsText.text = ModStatics.formatNumber(Number(data.downloads)); 
				sizeText.text = ModStatics.formatBytes(Number(data.size));
				likesText.text = ModStatics.formatNumber(Number(data.likes));
				this.filters = data.enabled?[]:[CommonUtils.generateGrayscaleFilter()];

				var lang : String = CoreComponent.gameLanguage;
				var isArabic : Boolean = lang == "AR";
				if(isArabic)
				{
					sizeText.width = 85;
					sizeText.x = 198;
				}
					
			}
		}
		public function getData():Object
		{
			return cachedData;
		}

		public function setImage(data:Object):void
		{
			if(data && data.modid)
			{
				trace("GFX - data.modid",data.modid);
				setLoadHandler();
				if(ModStatics.getModMenu())
					ModStatics.getModMenu().callLogoLoad(mcLoader,data.modid,ModImageData.P320);
			}
		}

		protected function setState( data:Object ):void
		{
			var state : int = data.state;
			var percent : int = data.percent;

			updateState(state, percent);
		}

		public function updateState(state : int, percent: int):void
		{
			if(subscribedText)
				subscribedText.visible = false;
			trace("GFX test updateState", state, percent);
			cachedState = state;
			cachedPercent = percent;
			//mcInputFeedback.alpha = 0;
			//mcInputFeedback.visible = false;
			if(state == DL_STATE_UNSUBSCRIBED)
			{
				//subscribedText.visible = false;
				mcSubscribedTick.visible = false;
				//mcInputBackground.visible = false;
				//mcInputFeedback.visible = true;
				//mcInputFeedback.alpha = 1;
				mcProgressBar.visible = false;
			}
			else if(state == DL_STATE_SUBSCRIBED)
			{
				//subscribedText.visible = true;
				mcSubscribedTick.visible = true;
				//mcSubscribedTick.gotoAndStop(cachedData.enabled?"enabled":"disabled")
				mcSubscribedTick.gotoAndStop("enabled");
				//mcInputBackground.visible = false;
				//mcInputFeedback.visible = false;
				mcProgressBar.visible = false;
			}
			else {


				//subscribedText.visible = false;
				mcSubscribedTick.visible = false;
				//mcInputBackground.visible = false;
				//mcInputFeedback.visible = false;
				mcProgressBar.visible = true;
				mcProgressBar.gotoAndStop(percent);
			}
		}

		///////////////////////////////////////////////////////////////////////////////
		// MISC
		///////////////////////////////////////////////////////////////////////////////

		public function getIndex():int
		{
			return i_index;
		}

		public function getModid():String
		{
			return m_modid;
		}

		public function isSubscribed():Boolean
		{
			return cachedState == DL_STATE_SUBSCRIBED;
		}
	}
}