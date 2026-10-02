package red.game.witcher3.menus.overlay
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import scaleform.gfx.Extensions;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class WatermarkPanelEmbed extends MovieClip
	{
		public var mcWatermark:MovieClip;

		public function WatermarkPanelEmbed()
		{
			if ( ! stage )
			{
				addEventListener( Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true );
			}
			else
			{
				registerWatermarkOverlay();
			}
		}

		private function handleAddedToStage( event:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, handleAddedToStage, false );
			registerWatermarkOverlay();
		}
		
		private function registerWatermarkOverlay():void
		{
			if ( Extensions.enabled )
			{
				ExternalInterface.call( "registerWatermarkOverlay", this );
			}
		}

		public function changeWatermarkText(text:String)
		{
			// Default back to "en" if non-supported language is given.
			if (text != "en" &&
				text != "pl" &&
				text != "de" &&
				text != "it" &&
				text != "fr" &&
				text != "cz" &&
				text != "es" &&
				text != "zh" &&
				text != "ru" &&
				text != "hu" &&
				text != "jp" &&
				text != "tr" &&
				text != "kr" &&
				text != "br" &&
				text != "mx" &&
				text != "cn" &&
				text != "ar" &&
				text != "ua")
			{
				text = "en";
			}

			mcWatermark.gotoAndStop(text);
		}
	}
}
