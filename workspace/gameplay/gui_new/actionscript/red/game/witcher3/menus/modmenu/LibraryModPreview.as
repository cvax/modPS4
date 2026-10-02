/***********************************************************************
/** Installed mod preview object
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

	import red.core.CoreComponent;
	import red.core.CoreMenu;	
	import red.core.events.GameEvent;

	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.utils.CommonUtils;

	public class LibraryModPreview extends ListItemRenderer implements IListItemRenderer
	{
		//ART CLIPS
		public var mcSelectionIndicator : 	MovieClip;
		public var mcIcon				:	Bitmap;
		public var mcModName 			:	TextField;
		public var mcModDescription 	:	TextField;
		public var mcModVersion			: 	TextField;
		public var mcCheckbox			:	MovieClip;
		public var mcOrderUpButton		:	OrderButton;
		public var mcOrderDownButton	:	OrderButton;
		public var mc169preview			:	MovieClip;
		public var mcLoader 			: 	W3UILoader;
		public var mcLoadingAnim		:	MovieClip;

		//VARS

		public var bSelected 			: 	Boolean;
		public var i_index				: 	int;
		public var i_index_max			:	int;
		public var bEnabled				: 	Boolean;

		public var isFirstItem			:	Boolean;
		public var isLastItem			:	Boolean;
		public var isOrderFocusAllowed 	: 	Boolean;
		public var isFocusOnOrder		:	Boolean;
		public var isFocusOnOrderUp		:	Boolean;

		public function LibraryModPreview()
		{
			super();
			bSelected = false;
		}

		protected function get menuName():String { return "ModMenu"; }

		override protected function configUI():void
		{
			super.configUI();
			mouseChildren = true;
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			mcSelectionIndicator.visible = false;

			mcCheckbox.addEventListener(MouseEvent.CLICK, onCheckboxClicked, false, 0, true);
			mcLoader.addEventListener( Event.COMPLETE, handleLoadComplete, false, 0, true );
			mcOrderUpButton.addEventListener(StatusButtonEvent.RELEASED, onOrderUp);
			mcOrderDownButton.addEventListener(StatusButtonEvent.RELEASED, onOrderDown);

			mcOrderUpButton.visible = false;
			mcOrderDownButton.visible = false;
			//setupCorrectMousingBehaviour();
		}

		public function onSelect():void
		{
			mcSelectionIndicator.visible = true;
			bSelected = true;
			mcSelectionIndicator.gotoAndStop(1);
			if (isOrderFocusAllowed)
			{
				mcOrderUpButton.visible = true;
				mcOrderDownButton.visible = true;
			}
		}

		public function deselect():void
		{
			//trace("GFX -- deselect", name);
			mcSelectionIndicator.visible = false;
			bSelected = false;
			mcOrderUpButton.visible = false;
			mcOrderDownButton.visible = false;
		}

		override public function setData( data:Object ):void
		{
			super.setData(data);
			if(data)
			{
				setupCorrectMousingBehaviour();
				if(CoreComponent.isArabicAligmentMode)
					gotoAndStop("rtl");
				else
					gotoAndStop("ltr");

				mcModName.text = data.modName;
				mcModDescription.text = data.modSummary;
				mcModVersion.text = data.modVersion;
				i_index = data.id;
				isFirstItem = i_index == 0;
				isLastItem = i_index == i_index_max;
				setEnabled(data.enabled);
				mcOrderUpButton.statusEnabled = !isFirstItem;
				mcOrderDownButton.statusEnabled = !isLastItem;

				if(data.modid)
				{
					//trace("GFX - data.modid",data.modid);
					var obj : MovieClip = this as MovieClip;
					while(obj && obj.parent)
					{
						if(obj is ModMenu)
							break;
						else
							obj = obj.parent as MovieClip;
					}
					if(obj is ModMenu)
					{
						ModMenu(obj).callLogoRemove(mcLoader);
						ModMenu(obj).callLogoLoad(mcLoader, data.modid, ModImageData.P320);
					}
					else
					{
						trace("GFX - Issue: Not a freaking mod menu, how?")
					}
				}
			}
		}

		public function setPortrait( value : String )
		{
			//mcLoader.fallbackIconPath = "icons/inventory/bombs/something_does_not_exist.png";
			// #Y Cut first '\', if it exist, to prevent conflict with prefix 'img://'
			// TODO: Implement it to all UI Loaders
			if (value.charAt(0) == '\\')
			{
				value = value.slice(1, value.length);
			}
			if(value.indexOf("https://") != 0)
				mcLoader.source = /*"img://"*/ value;
			mc169preview.visible = false;

			//trace("GFX Trying / tried setting portrait for", value);
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

			this.filters = value?[]:[CommonUtils.generateGrayscaleFilter()];
		}

		public function onEnabledChange()
		{
			setEnabled(!bEnabled);
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnLibraryModCheckboxClicked", [i_index, bEnabled] ) );
			if(parent && (parent as ModMenuInstalledPage))
				(parent as ModMenuInstalledPage).reflectEnablednessToDetails(bEnabled);
		}

		protected function handleLoadComplete(e:Event):void
		{
			mcLoadingAnim.visible = false;
			mc169preview.visible = false;
			removeChild(mcSelectionIndicator);
			addChild(mcSelectionIndicator);
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

		override public function handleInput(event:InputEvent):void
        {
			//dont do stuff
            //if(CommonUtils.isActuallyVisible(this))
            //    super.handleInput(event);
        }

		private function onOrderUp(event:StatusButtonEvent):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnModOrderChange", [i_index, true] ) );
			// reorder in ui
		}

		private function onOrderDown(event:StatusButtonEvent):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnModOrderChange", [i_index, false] ) );
			// reorder in ui
		}
	}
}