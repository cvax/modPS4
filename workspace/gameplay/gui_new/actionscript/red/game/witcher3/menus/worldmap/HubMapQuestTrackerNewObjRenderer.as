package red.game.witcher3.menus.worldmap
{
	import flash.display.MovieClip;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.controls.ListItemRenderer;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	
	public class HubMapQuestTrackerNewObjRenderer extends BaseListItem
	{
		public var tfObjective : TextField;
		public var mcTrackIndicator : MovieClip;
		public var mcBackground : MovieClip;
		public var mcPinIcon : MovieClip;
		public var mcSelection : MovieClip;
		
		private var _scriptName : uint;
		
		public function HubMapQuestTrackerNewObjRenderer()
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
				_scriptName = data.objectiveScriptName;
				
				tfObjective.htmlText = data.objectiveName;
				tfObjective.textColor = 0xf0be38;
				mcTrackIndicator.visible = data.highlighted;

				mcBackground.width = RIGHT_MARGIN + tfObjective.textWidth + ( ( data.highlighted ) ? LEFT_MARGIN : 0 );
				mcTrackIndicator.x = mcBackground.x - mcBackground.width + TRACK_INDICATOR_SPACING;
				tfObjective.width = tfObjective.textWidth;
				tfObjective.x = mcBackground.x - mcBackground.width + ( ( data.highlighted ) ? LEFT_MARGIN : 0 ) + TRACK_INDICATOR_SPACING;

				if(mcSelection) mcSelection.width = mcBackground.width;

				if(data.highlighted)
					mcPinIcon.gotoAndStop("GenericPin");
				else if(data.isQuestTracked)
					mcPinIcon.gotoAndStop("QuestObjective");
				else
					mcPinIcon.gotoAndStop("QuestObjectiveOther");
			}
		}

		override public function set selected(value : Boolean):void
		{
			super.selected = value;

			if(mcSelection) mcSelection.visible = value;
		}
		
		public function getScriptName() : uint
		{
			return _scriptName;
		}
	}
}
