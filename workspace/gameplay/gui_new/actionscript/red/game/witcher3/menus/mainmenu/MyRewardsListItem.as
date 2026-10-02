package red.game.witcher3.menus.mainmenu
{
	import  red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.controls.ListItemRenderer;
	import flash.text.TextField;
	import red.game.witcher3.controls.W3UILoader;
	import flash.display.MovieClip;

	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;
	import red.game.witcher3.utils.CommonUtils;

	public class MyRewardsListItem extends BaseListItem
	{
		public var mcIconLoader : W3UILoader;
		public var mcSelectedFrame : MovieClip;
		public var mcDropTag : MovieClip;
		public var mcBackground : MovieClip;

		public var id: int;

		public function MyRewardsListItem()
		{
			trace ( "MyRewardsListItem::MyRewardsListItem" );

			id = -1;
		}

		override protected function configUI() : void
		{
			trace ( "MyRewardsListItem::configUI" );
			super.configUI();
		}

		override public function setData( data : Object ) : void 
		{ 
			super.setData(data);
			trace ( "MyRewardsListItem::setData : ", data );

			if ( !data || ( data && data.id == -1 ) )
			{
				mcDropTag.gotoAndStop( 3 );

				mcIconLoader.visible = false;
				mcSelectedFrame.visible = false;
				mcDropTag.visible = false;
				mcBackground.visible = false;
				selectable = false;

				return;
			}

			const ICON_ROOT : String = "img://icons/rewards/";
			var iconPath : String = ICON_ROOT + data.icon;
			trace ( "MyRewardsListItem::setData : ", iconPath, data, data.id );

			mcBackground.visible = true;
			mcDropTag.visible = true;
			selectable = true;
			id = data.id;
			mcIconLoader.source = iconPath;
			mcDropTag.gotoAndStop( data.dropTag );
		}

		override public function set selected( value : Boolean ) : void
		{
			super.selected = value;
			
			if ( selected )
			{
				GTweener.removeTweens(this);
				GTweener.to(this, 0.66, { scaleX:1.3, scaleY:1.3 }, { ease:Exponential.easeOut } );
			}
			else
			{
				GTweener.removeTweens(this);
				GTweener.to(this, 0.66, { scaleX:1.0, scaleY:1.0 }, { ease:Exponential.easeOut } );
			}

			if (mcSelectedFrame)
			{
				mcSelectedFrame.visible = selected;
			}
			
		}
	}
}
