package red.game.witcher3.menus.worldmap
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.controls.ListItemRenderer;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	
	public class HubMapQuestTrackerNewQuestRenderer extends BaseListItem
	{
		public var tfQuest : TextField;
		public var mcTrackIndicator : MovieClip;
		public var mcBackground : MovieClip;
		public var mcPinIcon : MovieClip;
		public var mcSelection : MovieClip;
		
		private var _scriptName : uint;
		
		public function HubMapQuestTrackerNewQuestRenderer()
		{
			// constructor code
		}
		
		protected override function configUI():void
		{
			if(mcSelection) mcSelection.visible = false;
			super.configUI();
		}

		private const RIGHT_MARGIN : int = 70;
		private const LEFT_MARGIN : int = 45;
		private const TRACK_INDICATOR_SPACING : int = 15;
		
		override public function setData(data:Object):void
		{
			super.setData(data);

			if ( data )
			{
				_scriptName = data.questScriptName;
				
				tfQuest.htmlText = data.questName;
				tfQuest.textColor = data.highlighted ? 0xe7e7e7 : 0xc59e75;
				mcTrackIndicator.visible = data.highlighted;

				mcBackground.width = RIGHT_MARGIN + tfQuest.textWidth + ( ( data.highlighted ) ? LEFT_MARGIN : 0 );
				mcTrackIndicator.x = mcBackground.x - mcBackground.width + TRACK_INDICATOR_SPACING;
				tfQuest.width = tfQuest.textWidth;
				tfQuest.x = mcBackground.x - mcBackground.width + ( ( data.highlighted ) ? LEFT_MARGIN : 0 ) + TRACK_INDICATOR_SPACING;

				if(mcSelection) mcSelection.width = mcBackground.width;

				switch ( data.questType )
				{
					case 0:
					case 1:
					case 2:
						{
							switch( data.contentType )
							{
								case 0:
									mcPinIcon.gotoAndStop( 'Quest' );
									break;
								case 1:
									mcPinIcon.gotoAndStop( 'QuestHoS' );
									break;
								case 2:
									mcPinIcon.gotoAndStop( 'QuestBaW' );
									break;
								case 3:
									mcPinIcon.gotoAndStop( 'QuestLy' ); 
									break;
							}
						}
						break;
					case 3:
						mcPinIcon.gotoAndStop( "MonsterHunt" );
						break;
					case 4:
						mcPinIcon.gotoAndStop( "TreasureHunt" );
						break;
				}
			}
		}

		override public function set selected(value : Boolean):void
		{
			super.selected = value;

			if(mcSelection) mcSelection.visible = value;

			if(value)
			{
				tfQuest.textColor = 0xF1D6B8;
			}
			else if (_data)
			{
				tfQuest.textColor = _data.highlighted ? 0xe7e7e7 : 0xc59e75;
			}
		}

		//0xF1D6B8 <- selected color
		
		public function getScriptName() : uint
		{
			return _scriptName;
		}
	}
}
