/***********************************************************************
/** Installed mod preview object, thin, unreactive
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
	import red.core.events.GameEvent;

	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.utils.CommonUtils;

	public class ThinModPreview extends ListItemRenderer implements IListItemRenderer
	{
		//ART CLIPS
		public var mcIcon				:	Bitmap;
		public var mcModName 			:	TextField;
		public var mc169preview			:	MovieClip;
		public var mcLoader 			: 	W3UILoader;
		public var mcLoadingAnim		:	MovieClip;

		public var mcSelectionAnim		:	MovieClip;

		public var cachedModId			: String;

		public function ThinModPreview()
		{
			super();
		}
		protected function get menuName():String { return "ModMenu"; }
		override protected function configUI():void
		{
			super.configUI();

			mcLoader.addEventListener( Event.COMPLETE, handleLoadComplete, false, 0, true );

			if(mcSelectionAnim) mcSelectionAnim.visible = false;
			//setupCorrectMousingBehaviour();
		}

		override public function setData( data:Object ):void
		{
			super.setData(data);
			if(data)
			{
				mcModName.text = data.modName;

				if(data.modid)
				{
					trace("GFX - data.modid",data.modid);
					cachedModId = data.modid;
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
						ModMenu(obj).callLogoLoad(mcLoader, data.modid, ModImageData.P320);
					}
					else
					{
						trace("GFX - Issue: Not a freaking mod menu, how?")
					}
				}
			}
		}

		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			if(parent is ModDependencyModule)
			{
				if(mcSelectionAnim) mcSelectionAnim.visible = value && (parent as ModDependencyModule).active;
			}
			else
			{
				if(mcSelectionAnim) mcSelectionAnim.visible = value
			}
		}

		protected function handleLoadComplete(e:Event):void
		{
			mcLoadingAnim.visible = false;
			mc169preview.visible = false;
		}
    }
}