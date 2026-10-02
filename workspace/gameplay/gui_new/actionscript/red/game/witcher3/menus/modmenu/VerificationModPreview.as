/***********************************************************************
/** Mod verification preview object
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.interfaces.IListItemRenderer;

	import red.core.CoreMenu;	
	import red.core.CoreComponent;
	import red.core.events.GameEvent;

	import red.game.witcher3.controls.W3UILoader;
    import red.game.witcher3.menus.overlay.OverlayPanel;
	import red.game.witcher3.menus.mainmenu.IngameMenu;

	public class VerificationModPreview extends ListItemRenderer implements IListItemRenderer
	{
		//ART CLIPS
		public var mcSelectionIndicator : 	MovieClip;
		public var mcIcon				:	Bitmap;
		public var mcModName 			:	TextField;
		public var mcModDescription 	:	TextField;
		public var mcModVersion			: 	TextField;
		public var mcCheckbox			:	MovieClip;
		public var mc169preview			:	MovieClip;
		public var mcLoader 			: 	W3UILoader;
		public var mcLoadingAnim		:	MovieClip;

		//VARS

		public var bSelected 			: 	Boolean;
		public var bEnabled				: 	Boolean;
		private var modid				:	String;

        private var _menuName           :   String = "ModMenu";

		public function VerificationModPreview()
		{
			super();
			bSelected = false;
		}
        protected function set menuName(value:String):void
        {
            _menuName = value;
        }
		protected function get menuName():String { return _menuName; }
		override protected function configUI():void
		{
			super.configUI();
			mouseChildren = true;
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			mcSelectionIndicator.visible = false;

			mcCheckbox.addEventListener(MouseEvent.CLICK, onCheckboxClicked, false, 0, true);
			mcLoader.addEventListener( Event.COMPLETE, handleLoadComplete, false, 0, true );
			//setupCorrectMousingBehaviour();
		}

		public function onSelect():void
		{
			mcSelectionIndicator.visible = true;
			bSelected = true;
			mcSelectionIndicator.gotoAndStop(1);
		}

		public function deselect():void
		{
			trace("GFX -- deselect", name);
			mcSelectionIndicator.visible = false;
			bSelected = false;
		}

		override public function setData( data:Object ):void
		{
			trace("JIFIX start of setdata");
			super.setData(data);
			if(data)
			{
				setupCorrectMousingBehaviour();
				if(CoreComponent.isArabicAligmentMode)
					gotoAndStop("rtl");
				else
					gotoAndStop("ltr");

				if(!data.UGCAllowed)
				{
					if(CoreComponent.isArabicAligmentMode)
						gotoAndStop("noUgc_rtl");
					else
						gotoAndStop("noUgc_ltr");
				}

				if(mcModName) {
					mcModName.htmlText = data.modName;
					if(!data.UGCAllowed)
						mcModName.htmlText = data.modid;
				}
				if(mcModDescription) {
					mcModDescription.htmlText = data.modDesc;
					if(!data.UGCAllowed)
						mcModDescription.htmlText = "";
				}

				if(mcModVersion) {
					mcModVersion.text = data.modVersion;
					if(!data.UGCAllowed)
						mcModVersion.htmlText = "";
				}
				setEnabled(data.enabled);

				if(data.modid && data.UGCAllowed)
				{
					modid = data.modid;
					trace("GFX - data.modid",data.modid);
					var obj : MovieClip = this as MovieClip;
					while(obj.parent)
					{
						if(obj is OverlayPanel || obj is IngameMenu)
							break;
						else
							obj = obj.parent as MovieClip;
					}
					if(obj is OverlayPanel)
					{
						OverlayPanel(obj).callLogoLoad(mcLoader, data.modid, ModImageData.P320);
					}
					else if(obj is IngameMenu)
					{
						IngameMenu(obj).callLogoLoad(mcLoader, data.modid, ModImageData.P320);
					}
					else
					{
						trace("GFX - Issue: Not a freaking OverlayPanel, nor IngameMenu, how?")
					}
				}
				else 
				{
					mc169preview.visible = false;
					mcLoader.visible = false;
					mcLoadingAnim.visible = false;
				}

				if(data.hideCheckbox) {
					mcCheckbox.visible = false;
					if(mcModVersion) {
						if(CoreComponent.isArabicAligmentMode)
							mcModVersion.x = 30;
						else 
							mcModVersion.x = 623;
					}
				}
				else
					mcCheckbox.visible = true;

				trace("JIFIX e of data");
			}
		}

		protected function setupCorrectMousingBehaviour():void
		{
			mouseEnabled = true;
			mouseChildren = true;

			for(var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				var mcChild : MovieClip = child as MovieClip;
				if(mcChild)
					mcChild.mouseEnabled = false;
			}
			mcCheckbox.mouseEnabled = true;
			mcCheckbox.mouseChildren = true;
		}

		public function setEnabled(value : Boolean):void
		{
			bEnabled = value;
			if(value)
				mcCheckbox.gotoAndStop(5);
			else
				mcCheckbox.gotoAndStop(1);
		}

		public function onEnabledChange()
		{
			setEnabled(!bEnabled);
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnVerificationCheckboxClicked", [modid, bEnabled] ) );
			_data.enabled = !_data.enabled;
			//(parent as ModMenuInstalledPage).reflectEnablednessToDetails(bEnabled);
		}

		protected function handleLoadComplete(e:Event):void
		{
			mcLoadingAnim.visible = false;
			mc169preview.visible = false;
		}

		/////////////////////////////////////////////////////////////////////////////
		// MOUSE INPUT HANDLING
		/////////////////////////////////////////////////////////////////////////////

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

		protected function onCheckboxClicked(event:MouseEvent)
		{
			onEnabledChange()
		}
	}
}