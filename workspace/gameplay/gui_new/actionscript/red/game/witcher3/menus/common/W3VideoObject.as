package red.game.witcher3.menus.common
{
	import scaleform.clik.core.UIComponent;
	
	import flash.display.MovieClip;
	
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.media.SoundTransform;
	import flash.events.NetStatusEvent;
	
	import scaleform.gfx.Extensions;
	
	import red.core.events.GameEvent;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;
	
	public class W3VideoObject extends UIComponent
	{
		public var video : MovieClip;

		private var m_videoObj : Video;
		private var m_netConnection : NetConnection;
		private var m_netStream : NetStream;
		private var m_netClient : Object;
		private var m_currentMovie : String;
		private var m_loop : Boolean;
		private var m_soundTransform : SoundTransform;
		private var m_subSoundTransform : SoundTransform;
		
		public function W3VideoObject()
		{
			super();

			m_videoObj = new Video(video.width, video.height);

			video.addChild(m_videoObj);

			m_netConnection = new NetConnection();
			m_netConnection.connect(null);

			m_netStream = new NetStream(m_netConnection);

			m_videoObj.attachNetStream(m_netStream);

			m_netClient = new Object();
			m_netClient.onMetaData = handleMetaDataEvent;
			m_netClient.onCuePoint = handleCuePointEvent;
			m_netClient.onSubtitle = handleSubtitleEvent;

			m_netStream.client = m_netClient;
			//m_netStream.bufferTime = 1.5;

			SetSoundVolume( 1.0 );

			m_netStream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler, false, 0, true);
		}
		
		protected override function configUI():void
		{
			super.configUI();
		}
		
		public function PlayVideo(movieName : String, loop : Boolean ) : void
		{
			if (m_currentMovie == movieName && m_loop == loop)
			{
				return;
			}

			m_videoObj.clear();
			m_netStream.close()

			m_currentMovie = movieName;
			m_loop = loop;

			if ( Extensions.isScaleform )
			{
				m_netStream["loop"] = m_loop;
			}
			
			m_netStream.play(m_currentMovie);
			
			trace("video play " + m_currentMovie);
		}
		
		private function statusHandler(event : NetStatusEvent) : void
		{
			trace("status: " + event.info.code);

			if(event.info.code == "NetStream.Play.Start")
			{

			}

			if (event.info.code == "NetStream.Play.Stop")
			{
				//dispatchEvent( new GameEvent( GameEvent.CALL, 'OnSkipMovie' ) );
			}
		}
		
		private function handleMetaDataEvent(meta : Object) : void
		{
			if (meta)
			{
				trace("duration: "    + meta.duration);
				trace("width: "       + meta.width);
				trace("height: "      + meta.height);
				trace("frameRate: "   + meta.frameRate);
				trace("totalFrames: " + meta.totalFrames);
				trace("audioTracks: "    + meta.audioTracksCount);
				trace("subtitleTracks: " + meta.subtitleTracksCount);
				trace("cuePoints: "      + meta.cuePointsCount);
			}
		}

		private function handleCuePointEvent(item : Object) : void
		{
			if (item)
			{
				trace("cuePoint: " + item.name + ", " + item.time + ", " + item.type);

				for (var param : String in item.parameters)
				{
					trace("\t" + param + ":\t" + item.parameters[param]);
				}
			}
		}

		private function handleSubtitleEvent(msg : String) : void
		{
			if (msg)
			{
				trace("subtitle: " + msg);
			}
		}
		
		public function PauseVideo() : void
		{
			m_netStream.togglePause();
		}
		
		public function SetSoundVolume(value : Number) : void
		{
			m_soundTransform = new SoundTransform( value );
			m_subSoundTransform = new SoundTransform( value );
			
			m_netStream.soundTransform = m_soundTransform;
			
			if ( Extensions.enabled )
			{
				m_netStream["subSoundTransform"] = m_subSoundTransform;
			}
		}
	}
}