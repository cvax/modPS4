/***********************************************************************
/** PANEL glossary tutorial main class
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/
package red.game.witcher3.menus.glossary
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import red.core.CoreComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.TextAreaModuleCustomInput;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ListEvent;

	import red.core.CoreMenu;
	import scaleform.gfx.Extensions;

	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;

	//import red.game.witcher3.managers.PanelModuleManager;
	import red.game.witcher3.menus.common.TextAreaModule;

	import red.game.witcher3.menus.common.ItemDataStub;

	import flash.display.Sprite;
	import flash.external.ExternalInterface;

	import red.game.witcher3.menus.common.DropdownListModuleBase;
	import red.game.witcher3.constants.PlatformType;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import red.game.witcher3.menus.common.W3VideoObject;

	Extensions.enabled = true;
	Extensions.noInvisibleAdvance = true;

	public class GlossaryTutorialsMenu extends CoreMenu
	{
		/********************************************************************************************************************
				ART CLIPS
		/ ******************************************************************************************************************/
		//public var mcPanelModuleManager : PanelModuleManager;

		public var 		mcMainListModule					: DropdownListModuleBase;
		public var 		mcGlossarySubModule					: GlossaryTextureSubListModule;
		public var 		mcTextAreaModule					: TextAreaModuleCustomInput;

		private var 	m_switchEntryTag					: String;

		public var		mcVideoObject	 					: W3VideoObject;

		/********************************************************************************************************************
				INTERNAL PROPERTIES
		/ ******************************************************************************************************************/

		public function GlossaryTutorialsMenu()
		{
			super();
			mcMainListModule.menuName = menuName;
			mcMainListModule.mcDropDownList.listHeight = 750;
			mcMainListModule.mcDropDownMask.height = 750; //#LT <-- for some reason this is needed here but not for the other glossary pages
			mcMainListModule.mcScrollBar.height = 740;
			mcGlossarySubModule.dataBindingKey = "glossary.tutorials";
			mcGlossarySubModule.imagePathPrefix = "img://";
		}

		override protected function get menuName():String
		{
			return "GlossaryTutorialsMenu";
		}

		override protected function configUI():void
		{
			super.configUI();
			stage.addEventListener( InputEvent.INPUT, handleInput, false, 0, true );
			mcMainListModule.enableTouch( true );
			mcTextAreaModule.enableTouch( true );

			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerUpdate, false, 0, true);
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			focused = 1;

			if( InputManager.getInstance().getPlatform() != PlatformType.PLATFORM_SWITCH2)
			{
				mcVideoObject.visible = false;
			}		
		}

		private function handleControllerUpdate(event:Event):void
		{
			mcMainListModule.mcDropDownList.clearRenderers();
			mcMainListModule.validateNow();

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnUpdateTutorials" ) );

			mcMainListModule.removeEventListener(Event.CHANGE, handleDataChanged);
			mcMainListModule.addEventListener(Event.CHANGE, handleDataChanged, false, 0, true);
		}

		private function handleDataChanged(event:Event):void
		{
			mcMainListModule.removeEventListener(Event.CHANGE, handleDataChanged);
			mcMainListModule.mcDropDownList.selectedIndex = 0;
			mcMainListModule.mcDropDownList.validateNow();
		}

		override public function ShowSecondaryModules( value : Boolean )
		{
			super.ShowSecondaryModules( value );
			mcGlossarySubModule.visible = value;
			mcGlossarySubModule.enabled = value;

			mcTextAreaModule.visible = value;
			mcTextAreaModule.enabled = value;
		}

		override public function handleInput( event:InputEvent ):void
		{
			if ( event.handled )
			{
				return;
			}

			for each ( var handler:UIComponent in actualModules )
			{
				if ( event.handled )
				{
					event.stopImmediatePropagation();
					return;
				}
				handler.handleInput( event );
			}

			var details:InputDetails = event.details;
            var keyPress:Boolean = details.value == InputValue.KEY_UP;// (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);

			if (keyPress)
			{
				switch(details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_B :
						hideAnimation();
						break;
				}
			}
		}

		/*
		 * Update selected tutorial data
		 *
		 * */

		public function setTitle( value : String ) : void
		{
			if (mcTextAreaModule)
			{
				mcTextAreaModule.SetTitle(value);
			}
		}

		public function setText( value : String  ) : void
		{
			trace( "DebugTutorial ENTRY:setText: ", value);

			if (mcTextAreaModule)
			{
				trace( "DebugTutorial ENTRY:setText valid: ", value);
				value = CommonUtils.fixFontStyleTags(value);

				// #Y hack for arabic
				if ( CoreComponent.isArabicAligmentMode && value.charAt(1) == "." )
				{
					var txtValue:String = value;

					mcTextAreaModule.SetText( "." + value.charAt(1) + value.slice(2) );
				}
				else
				{
					mcTextAreaModule.SetText(value);
				}

				if( mcTextAreaModule.mcSeparator)
				{
					mcTextAreaModule.mcSeparator.visible = value != "";
				}

				trace( "DebugTutorial ENTRY:setText done: ", value);
			}
		}

		public function setImage( value : String ) : void
		{
			trace( "DebugTutorial setImage ", value);
			if(value != null || value != "" || value != "empty_texture.PNG")
			{
				if ( mcGlossarySubModule )
				{
					mcGlossarySubModule.visible = true;
					mcGlossarySubModule.handleSetImage(value);
				}
			}
			else if( mcGlossarySubModule )
			{
				mcGlossarySubModule.visible = false;
			}
		}

		public function setEntryTag( value : String ) : void
		{
			m_switchEntryTag = value;
			trace( "DebugTutorial GlossaryTutorial: setEntryTag:"+ m_switchEntryTag );
			SetSwitchAnimation();
		}

		private function SetSwitchAnimation()
		{
			if( InputManager.getInstance().getPlatform() != PlatformType.PLATFORM_SWITCH2)
			{
				return;
			}

			switch(m_switchEntryTag)
			{
				case "TutorialJournalMotionPatternSignCast":
					StartLoadSwitchAnim("sign_activation_aard");
					break;

				case "TutorialJournalMotionPatternHorseAcceleration":
					StartLoadSwitchAnim("horse_acceleration_canter");
					break;

				case "TutorialJournalMotionPatternHorseStop":
					StartLoadSwitchAnim("horse_stop");
					break;

				case "TutorialJournalMotionPatternHorseSummon":
					StartLoadSwitchAnim("horse_summon");
					break;

				case "TutorialJournalMotionPatternPotion1":
					StartLoadSwitchAnim("primary_consumable");
					break;

				case "TutorialJournalMotionPatternPotion2":
					StartLoadSwitchAnim("secondary_consumable");
					break;

				case "TutorialJournalGyro":
					StartLoadSwitchAnim("gyro_aiming_bomb");
					break;

				case "TutorialJournalMotionPatternCrossbow":
					StartLoadSwitchAnim("crossbow");
					break;

				case "TutorialJournalMotionPatternBombs":
					StartLoadSwitchAnim("throw_bomb");
					break;

				case "TutorialJournalTouch":
					StartLoadSwitchAnim("touch_screen_swipe_pinch");
					break;

				case "TutorialJournalMouser":
					StartLoadSwitchAnim("mouser");
					break;

				case "TutorialJournalMotionPatternDetails":
					StartLoadSwitchAnim("horse_acceleration_canter");
					break;

				default:
					mcVideoObject.visible = false;
					break;
			}
		}

		private function StartLoadSwitchAnim( name : String)
		{
			trace( "DebugTutorial GlossaryTutorial: StartLoadSwitchAnim:"+ name );

			if(mcVideoObject)
			{		
				mcVideoObject.visible = true;
				mcVideoObject.PlayVideo("movies\\gui\\embedded\\tutorials\\switch2\\" + name + ".usm", true);							
			}
			else
			{
				trace( "DebugTutorial GlossaryTutorial: NOMC:"+ name );
			}
		}

		/********************************************************************************************************************
			UPDATES
		/ ******************************************************************************************************************/
		protected function Update() : void
		{

		}
	}

}
