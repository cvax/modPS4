/***********************************************************************
/** Startup Experience Menu
/***********************************************************************
/** Copyright © 2026 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.startup_experience
{
    import red.core.CoreMenu;
	import flash.utils.getDefinitionByName;
	import red.core.events.GameEvent;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	import flash.events.Event;
	import flash.system.System;
	import scaleform.gfx.SystemEx;
	import scaleform.clik.events.InputEvent;

    public class StartupExperienceMenu extends CoreMenu
	{
		private var m_pageDef : String = null; 
		private var m_pageData : Object = null;
		private var m_pageObject : Object = null;
		private var m_page : MovieClip = null;
		private var m_loader : Loader = null;

		public function StartupExperienceMenu()
		{
			_disableShowAnimation = true;
			_restrictDirectClosing = true;
			super();
		}

		override protected function get menuName():String 
		{ 
			return "StartupExperienceMenu"; 
		}

		override protected function configUI():void
		{
			super.configUI();

			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'startup.connect.page', [showConnectPage]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'startup.connected.page', [showConnectedPage]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'startup.telemetry.page', [showTelemetryPage]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'startup.patch.notes.page', [showPatchNotesPage]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'startup.qrData', [qrDataReady]));
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'startup.qrError', [qrError]));

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
		}

		override protected function handleInputNavigate(event:InputEvent):void
		{
			super.handleInputNavigate(event);

			if ( m_page )
			{
				m_page.handleInputNavigate(event);
			}
		}

		private function qrDataReady( data : Object ) : void
		{
			var connectPage :  ConnectPage = m_page as ConnectPage;
			if ( connectPage )
			{
				connectPage.showQrCode( data.url );
			}
		}

		private function qrError( error : String ) : void
		{
			var connectPage :  ConnectPage = m_page as ConnectPage;
			if ( connectPage )
			{
				connectPage.showError( error );
			}
		}

		public function showConnectPage(data:Object):void
		{
			showPage( "MCConnectPage", data );
		}

		public function showConnectedPage(data:Object):void
		{
			showPage( "MCConnectedPage", data );
		}

		public function showTelemetryPage(data:Object):void
		{
			showPage( "MCTelemetryPage", data );
		}

		public function showPatchNotesPage(data:Object):void
		{
			showPage( "MCPatchNotesPage", data );
		}

		private function loadPage() : void
		{
			if ( !m_loader )
			{
				trace( "StartupExperienceMenu::loadPage - loading SWF " );
				m_loader = new Loader();
				m_loader.load( new URLRequest( "swf\\startup\\panel_startup.swf" ), new LoaderContext( false, ApplicationDomain.currentDomain ) );
				m_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, handleMovieLoadComplete, false, 0, true );
				m_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, handleMovieLoadError, false, 0, true );
			}
			else
			{
				trace( "StartupExperienceMenu::loadPage : ", m_pageDef );
				if( m_page )
				{
					trace( "StartupExperienceMenu::loadPage removing prev page : ", m_page, m_pageDef );
					removeChild( m_page );
					//TODO : fix GFX GC so this is not needed.
					System.gc(); //Collect weak ref callback zombies
					m_page = null;
				}

				var clazz : Class = getDefinitionByName( m_pageDef ) as Class;
				if ( clazz )
				{
					var page : MovieClip = new clazz() as MovieClip;
					if ( page )
					{
						trace( "StartupExperienceMenu::loadPage adding new page : ", page, m_pageDef );
						addChild( page );
						page.setData( m_pageData );

						m_page = page;
					}
				}
			}
		}

		private function handleMovieLoadError( event : Event ):void
		{
			var loaderInfo:LoaderInfo = LoaderInfo( event.target );
			var loader:Loader = loaderInfo.loader;
			loaderInfo.removeEventListener( Event.COMPLETE, handleMovieLoadComplete, false );
			loaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, handleMovieLoadError, false );
			
			trace( "StartupExperienceMenu::handleMovieLoadError : ", loaderInfo.url );
		}

		private function handleMovieLoadComplete( event:Event ):void
		{
			var loaderInfo:LoaderInfo = LoaderInfo( event.target );
			var loader:Loader = loaderInfo.loader;
			loaderInfo.removeEventListener( Event.COMPLETE, handleMovieLoadComplete, false );
			loaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, handleMovieLoadError, false );

			//Keep a strong ref so GC wont collect it. If you dont do this you will crash at method calls
			//in the VM since the VMAbcFile will be unloaded :) 
			m_pageObject = loader.content;

			trace( "StartupExperienceMenu::handleMovieLoadComplete : ", m_loader, m_pageObject );

			loadPage();
		}

		private function showPage( className : String, data : Object ) : void
		{
			trace( "StartupExperienceMenu::showPage : - inputHandlers", _inputHandlers.length );
			m_pageDef = className;
			m_pageData = data;
			loadPage();
		}
    }
}