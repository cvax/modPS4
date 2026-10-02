package red.game.witcher3.menus.overlay
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import scaleform.gfx.Extensions;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class WatermarkPanel extends MovieClip
	{
		public var tfWatermark:TextField;

		public function WatermarkPanel()
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
			tfWatermark.text = text;
		}

		public function changeWatermarkHtmlText(text:String)
		{
			tfWatermark.htmlText = text;
		}
	}
}
