package red.game.witcher3.menus.mainmenu
{
    import scaleform.clik.core.UIComponent;
    import red.game.witcher3.controls.InputFeedbackButton;
    import scaleform.clik.constants.NavigationCode;
    import red.core.constants.KeyCode;
    import flash.text.TextField;
    import flash.text.TextLineMetrics;
    import scaleform.clik.data.DataProvider;
    import red.game.witcher3.controls.W3ScrollingList;
    import red.game.witcher3.controls.W3UILoader;
    import scaleform.clik.events.ListEvent;
    import scaleform.clik.events.InputEvent;
    import flash.events.Event;
    import scaleform.clik.events.ButtonEvent;
    import red.core.events.GameEvent;
    import flash.display.MovieClip;
    import red.game.witcher3.managers.InputManager;
    import scaleform.clik.ui.InputDetails;
    import scaleform.clik.constants.InputValue;
    import flash.utils.Dictionary;
    import red.core.events.GestureEventEx;
    import flash.events.GestureEvent;
    import flash.events.TransformGestureEvent;
    import red.game.witcher3.utils.CommonUtils;

    import flash.display.Loader;
	import flash.display.LoaderInfo;
    import flash.system.LoaderContext;
    import flash.net.URLRequest;
    import flash.events.IOErrorEvent;
    import flash.system.ApplicationDomain;
    import flash.utils.getDefinitionByName;
    import flash.events.MouseEvent;

    public class MyRewardsPanel extends UIComponent
	{
        public static const EVENT_RESULT_CLOSE : String = "EVENT_RESULT_CLOSE";
        public static const EVENT_RESULT_LOGOUT : String = "EVENT_RESULT_LOGOUT";

        private static const ID_WITCHER_NG_STEEL_SWORD : int = 6;
        private static const ID_WITCHER_NG_SILVER_SWORD : int = 7;
        private static const ID_WITCHER_NG_ARMOR : int = 8;
        private static const ID_WITCHER_NG_TROUSERS : int = 9;
        private static const ID_WITCHER_NG_BOOTS : int = 10;
        private static const ID_WITCHER_NG_GLOVES : int = 11;
        private static const ID_ROACH_GWENT_CARD : int = 12;

        private static const ID_WITCHER_FIRE_HORSE_SADDLEBAGS_TWITCH : int = 13;
        private static const ID_WITCHER_FIRE_HORSE_BLINDERS_TWITCH : int = 14;
        private static const ID_WITCHER_FIRE_HORSE_SADDLE_TWITCH : int = 15;
        private static const ID_WITCHER_FIRE_HORSE_SADDLEBAGS_BILIBILI : int = 16;
        private static const ID_WITCHER_FIRE_HORSE_BLINDERS_BILIBILI : int = 17;
        private static const ID_WITCHER_FIRE_HORSE_SADDLE_BILIBILI : int = 18;
        private static const ID_WITCHER_WOLF_BANDANA : int = 19;
        private static const ID_WITCHER_RABBLE_ROUSER_HAIR : int = 20;
        private static const ID_WITCHER_SCARLET_CREST_ARMOR : int = 21;
        private static const ID_WITCHER_SCARLET_CREST_BOOTS : int = 22;
        private static const ID_WITCHER_SCARLET_CREST_GAUNTLETS : int = 23;
        private static const ID_WITCHER_SCARLET_CREST_TROUSERS : int = 24;

        public static const DROP_TAG_TWITCH : int = 1;
        public static const DROP_TAG_BILIBILI : int = 2;
        public static const DROP_TAG_NONE : int = 3;

        public var mcCDPRAccountText : MovieClip;
        public var tfAccount : TextField;
        public var tfTitle : TextField;

        public var mcUserPanel : MyRewardsUserNamePanel

        public var tfRewardName : TextField;
        public var tfRewardDescription : TextField;
        public var mcRewardDropTag : MovieClip;

        public var mcLogoutButton : InputFeedbackButton;
        public var mcCloseButton : InputFeedbackButton;

        public var mcImageAnchor : MovieClip;

        public var mcRewardsList : W3ScrollingList;
        public var mcRewardsListItem1 : MyRewardsListItem;
		public var mcRewardsListItem2 : MyRewardsListItem;
		public var mcRewardsListItem3 : MyRewardsListItem;
		public var mcRewardsListItem4 : MyRewardsListItem;
        public var mcRewardsListItem5 : MyRewardsListItem;
        public var mcRewardsListItem6 : MyRewardsListItem;
        public var mcRewardsListItem7 : MyRewardsListItem;
        public var mcRewardsListItem8 : MyRewardsListItem;

        private var mDataProvider : DataProvider;
        private var mContentMap : Dictionary;
        private var mPanYAccumulator:Number;

        private var mcMyRewardsImages : MovieClip;
        private var m_loader : Loader = null;
        private var m_assetLib : Object = null;

        private var m_renderers : Array = null;

        public function MyRewardsPanel()
        {
            trace( "MyRewardsPanel::MyRewardsPanel : ");

            mDataProvider = null;

            mContentMap = new Dictionary();
            /*
            OLD loc keys
            ui_gog_reward_armor_reason
            ui_gog_reward_gloves_reason
            ui_gog_reward_trousers_reason
            ui_gog_reward_boots_reason
            ui_gog_reward_steel_sword_reason
            ui_gog_reward_silver_sword_reason
            ui_gog_reward_roach_gwent_card_reason
            */
            mContentMap[ ID_WITCHER_NG_ARMOR ] = { id : ID_WITCHER_NG_ARMOR, name : "[[ui_gog_reward_armor]]", description : "[[startup_rewards_armor_desc]]", icon : "armor_thumb.png", frameIdx : 2, dropTag : DROP_TAG_NONE };
            mContentMap[ ID_WITCHER_NG_GLOVES ] = { id : ID_WITCHER_NG_GLOVES, name : "[[ui_gog_reward_gloves]]", description : "[[startup_rewards_armor_desc]]", icon : "gloves_thumb.png", frameIdx : 3, dropTag : DROP_TAG_NONE };
            mContentMap[ ID_WITCHER_NG_TROUSERS ] = { id : ID_WITCHER_NG_TROUSERS, name : "[[ui_gog_reward_trousers]]", description : "[[startup_rewards_armor_desc]]", icon : "pants_thumb.png", frameIdx : 4, dropTag : DROP_TAG_NONE };
            mContentMap[ ID_WITCHER_NG_BOOTS ] = { id : ID_WITCHER_NG_BOOTS, name : "[[ui_gog_reward_boots]]", description : "[[startup_rewards_armor_desc]]", icon : "boots_thumb.png", frameIdx : 5, dropTag : DROP_TAG_NONE };
            mContentMap[ ID_WITCHER_NG_STEEL_SWORD ] = { id : ID_WITCHER_NG_STEEL_SWORD, name : "[[ui_gog_reward_steel_sword]]", description : "[[startup_rewards_armor_desc]]", icon : "sword1_thumb.png", frameIdx : 6, dropTag : DROP_TAG_NONE };
            mContentMap[ ID_WITCHER_NG_SILVER_SWORD ] = { id : ID_WITCHER_NG_SILVER_SWORD, name : "[[ui_gog_reward_silver_sword]]", description : "[[startup_rewards_armor_desc]]", icon : "sword2_thumb.png", frameIdx : 7, dropTag : DROP_TAG_NONE };
            mContentMap[ ID_ROACH_GWENT_CARD ] = { id : ID_ROACH_GWENT_CARD, name : "[[ui_gog_reward_roach_gwent_card]]", description : "[[startup_rewards_gwent_desc]]", icon : "roach_card_thumb.png", frameIdx : 8, dropTag : DROP_TAG_NONE };

            mContentMap[ ID_WITCHER_FIRE_HORSE_SADDLEBAGS_TWITCH ] = { id : ID_WITCHER_FIRE_HORSE_SADDLEBAGS_TWITCH, name : "[[ui_gog_reward_fire_horse_saddlebags]]", description : "[[startup_rewards_armor_desc]]", icon : "saddlebags_thumb.png", frameIdx : 13, dropTag : DROP_TAG_TWITCH };
            mContentMap[ ID_WITCHER_FIRE_HORSE_BLINDERS_TWITCH ] = { id : ID_WITCHER_FIRE_HORSE_BLINDERS_TWITCH, name : "[[ui_gog_reward_fire_horse_blinders]]", description : "[[startup_rewards_armor_desc]]", icon : "horse_armor_blinders_thumb.png", frameIdx : 11, dropTag : DROP_TAG_TWITCH };
            mContentMap[ ID_WITCHER_FIRE_HORSE_SADDLE_TWITCH ] = { id : ID_WITCHER_FIRE_HORSE_SADDLE_TWITCH, name : "[[ui_gog_reward_fire_horse_saddle]]", description : "[[startup_rewards_armor_desc]]", icon : "horse_armor_thumb.png", frameIdx : 12, dropTag : DROP_TAG_TWITCH };

            mContentMap[ ID_WITCHER_FIRE_HORSE_SADDLEBAGS_BILIBILI ] = { id : ID_WITCHER_FIRE_HORSE_SADDLEBAGS_BILIBILI, name : "[[ui_gog_reward_fire_horse_saddlebags]]", description : "[[startup_rewards_armor_desc]]", icon : "saddlebags_thumb.png", frameIdx : 13, dropTag : DROP_TAG_BILIBILI };
            mContentMap[ ID_WITCHER_FIRE_HORSE_BLINDERS_BILIBILI ] = { id : ID_WITCHER_FIRE_HORSE_BLINDERS_BILIBILI, name : "[[ui_gog_reward_fire_horse_blinders]]", description : "[[startup_rewards_armor_desc]]", icon : "horse_armor_blinders_thumb.png", frameIdx : 11, dropTag : DROP_TAG_BILIBILI };
            mContentMap[ ID_WITCHER_FIRE_HORSE_SADDLE_BILIBILI ] = { id : ID_WITCHER_FIRE_HORSE_SADDLE_BILIBILI, name : "[[ui_gog_reward_fire_horse_saddle]]", description : "[[startup_rewards_armor_desc]]", icon : "horse_armor_thumb.png", frameIdx : 12, dropTag : DROP_TAG_BILIBILI };

            mContentMap[ ID_WITCHER_WOLF_BANDANA ] = { id : ID_WITCHER_WOLF_BANDANA, name : "[[ui_gog_reward_wolf_bandana]]", description : "[[startup_rewards_armor_desc]]", icon : "bandana_thumb.png", frameIdx : 9, dropTag : DROP_TAG_NONE };
            mContentMap[ ID_WITCHER_RABBLE_ROUSER_HAIR ] = { id : ID_WITCHER_RABBLE_ROUSER_HAIR, name : "[[ui_gog_reward_rabble_rouser_hairstyle]]", description : "[[startup_rewards_hair_desc]]", icon : "hairdo_thumb.png", frameIdx : 10, dropTag : DROP_TAG_NONE };

            mContentMap[ ID_WITCHER_SCARLET_CREST_ARMOR ] = { id : ID_WITCHER_SCARLET_CREST_ARMOR, name : "[[ui_gog_reward_scarlet_crest_armor]]", description : "[[startup_rewards_armor_desc]]", icon : "scarlet_armor_thumb.png", frameIdx : 14, dropTag : DROP_TAG_NONE };
            mContentMap[ ID_WITCHER_SCARLET_CREST_BOOTS ] = { id : ID_WITCHER_SCARLET_CREST_BOOTS, name : "[[ui_gog_reward_scarlet_crest_boots]]", description : "[[startup_rewards_armor_desc]]", icon : "scarlet_boots_thumb.png", frameIdx : 15, dropTag : DROP_TAG_NONE };
            mContentMap[ ID_WITCHER_SCARLET_CREST_GAUNTLETS ] = { id : ID_WITCHER_SCARLET_CREST_GAUNTLETS, name : "[[ui_gog_reward_scarlet_crest_gauntlets]]", description : "[[startup_rewards_armor_desc]]", icon : "scarlet_gauntlets_thumb.png", frameIdx : 16, dropTag : DROP_TAG_NONE };
            mContentMap[ ID_WITCHER_SCARLET_CREST_TROUSERS ] = { id : ID_WITCHER_SCARLET_CREST_TROUSERS, name : "[[ui_gog_reward_scarlet_crest_trousers]]", description : "[[startup_rewards_armor_desc]]", icon : "scarlet_trousers_thumb.png", frameIdx : 17, dropTag : DROP_TAG_NONE };

            m_renderers = 
            [
                mcRewardsListItem1, mcRewardsListItem2, mcRewardsListItem3, mcRewardsListItem4, 
                mcRewardsListItem5, mcRewardsListItem6, mcRewardsListItem7, mcRewardsListItem8
            ];

            //Load images
            trace( "StartupExperienceMenu::loadPage - loading SWF " );
            m_loader = new Loader();
            m_loader.load( new URLRequest( "swf\\mainmenu\\myrewardassets.swf" ), new LoaderContext( false, ApplicationDomain.currentDomain ) );
            m_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, handleImageLoadComplete, false, 0, true );
            m_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, handleImageLoadError, false, 0, true );

            mPanYAccumulator = 0;
        }

		private function handleImageLoadError( event : Event ):void
		{
			var loaderInfo:LoaderInfo = LoaderInfo( event.target );
			var loader:Loader = loaderInfo.loader;
			loaderInfo.removeEventListener( Event.COMPLETE, handleImageLoadComplete, false );
			loaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, handleImageLoadError, false );
			
			trace( "MyRewardsPanel::handleImageLoadError : ", loaderInfo.url );
		}

		private function handleImageLoadComplete( event:Event ):void
		{
			var loaderInfo:LoaderInfo = LoaderInfo( event.target );
			var loader:Loader = loaderInfo.loader;
			loaderInfo.removeEventListener( Event.COMPLETE, handleImageLoadComplete, false );
			loaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, handleImageLoadError, false );

			m_assetLib = loader.content;

            var clazz : Class = getDefinitionByName( "MyRewardsImagesRef" ) as Class;
			trace( "MyRewardsPanel::handleImageLoadComplete : ", m_loader, m_assetLib, clazz );
            if ( clazz )
            {
                mcMyRewardsImages = new clazz() as MovieClip;
                if ( mcMyRewardsImages )
                {
                    trace( "MyRewardsPanel::handleImageLoadComplete 2 ", mcImageAnchor, mcMyRewardsImages );

                    mcMyRewardsImages.gotoAndStop( 1 );
                    mcImageAnchor.addChild( mcMyRewardsImages );
                }
            }
		}

        override protected function configUI() : void
        {
            trace( "MyRewardsPanel::configUI : ");

            super.configUI();

            mcCDPRAccountText.tfText.text = "[[panel_cdpr_account]]";
            tfTitle.text = "[[ui_gog_rewards_table_title]]";

            mcRewardDropTag.gotoAndStop( 1 );
            mcRewardsList.selectedIndex = -1;
            mcRewardsList.addEventListener( ListEvent.INDEX_CHANGE, handleListChange );

			stage.addEventListener( MouseEvent.MOUSE_MOVE, handleMouseMove, false, 0, true );
            stage.addEventListener( MouseEvent.MOUSE_WHEEL, handleMouseScroll, false, 0, true );
            stage.addEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan, false, 0, true );
            stage.addEventListener( GestureEventEx.GESTURE_TAP, handleGestureTap );

            setupInputFeedbackButtons();
        }

        private function setupInputFeedbackButtons() : void
        {
            var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

            mcCloseButton.setDataFromStage( NavigationCode.GAMEPAD_B, KeyCode.ENTER );
            mcCloseButton.label = "[[panel_common_accept]]";
            mcCloseButton.clickable = false;
            mcCloseButton.validateNow(); // Apply size changes due to text change
            //NOTE : you have to use different measurement method if the IFB is clickable or not. Awesome!!! NOT.
            //mcCloseButton.x = 1920 - 87 - mcCloseButton.getViewWidth();
            mcCloseButton.x = 1920 - 87 - mcCloseButton.getOccupiedWidth();
            mcCloseButton.addEventListener( ButtonEvent.PRESS, handleAcceptAction, false, 0, true );
            mcCloseButton.addEventListener( GestureEventEx.GESTURE_TAP, handleAcceptAction, false, 0, true );
            
            mcLogoutButton.setDataFromStage( isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, KeyCode.Q, -1, 1500 );
            mcLogoutButton.label = "[[ui_gog_button_signout]]";
            mcLogoutButton.clickable = false;
            mcLogoutButton.validateNow(); // Apply size changes due to text change
            //mcLogoutButton.x = mcCloseButton.x - 29 - mcLogoutButton.getViewWidth();
            mcLogoutButton.x = mcCloseButton.x - 29 - mcLogoutButton.getOccupiedWidth();
            mcLogoutButton.enablePressToHold(true);
            mcLogoutButton.holdCallback = handleSignOutAction;
        }

        public function HACK_languageUpdateEnd() : void
        {
            setupInputFeedbackButtons();
        }

        //TODO : queue it up if mcMyRewardsImages did not load yet
        private function showReward( id : int ) : void
        {
            trace( "MyRewardsPanel::showReward : ", id, mcMyRewardsImages );

            if ( mcMyRewardsImages && id != -1 )
            {
                var rewardData : Object = mContentMap[ id ];

                mcMyRewardsImages.gotoAndStop( rewardData.frameIdx );
                mcRewardDropTag.gotoAndStop( rewardData.dropTag );
                tfRewardName.text = rewardData.name;
                tfRewardDescription.text = rewardData.description;
            }
        }

        private function handleListChange( event : ListEvent ) : void
		{
            var listItem : MyRewardsListItem = mcRewardsList.getSelectedRenderer() as MyRewardsListItem;

            trace( "MyRewardsPanel::handleListChange : ", mcRewardsList.selectedIndex, listItem );
            if( listItem )
            {
			    trace( "MyRewardsPanel::handleListChange2 : ", listItem.id, listItem, event.index, mcRewardsList.selectedIndex );
                showReward( listItem.id );
            }
		}

		private function createDataProvider( unlockedIds : Array ) : DataProvider 
		{
            const DISPLAY_ORDER : Array = 
            [
                ID_WITCHER_SCARLET_CREST_ARMOR,
                ID_WITCHER_SCARLET_CREST_GAUNTLETS,
                ID_WITCHER_SCARLET_CREST_TROUSERS,
                ID_WITCHER_SCARLET_CREST_BOOTS,

                ID_WITCHER_FIRE_HORSE_SADDLE_BILIBILI,
                ID_WITCHER_FIRE_HORSE_BLINDERS_BILIBILI,
                ID_WITCHER_FIRE_HORSE_SADDLEBAGS_BILIBILI,

                ID_WITCHER_FIRE_HORSE_SADDLE_TWITCH,
                ID_WITCHER_FIRE_HORSE_BLINDERS_TWITCH,
                ID_WITCHER_FIRE_HORSE_SADDLEBAGS_TWITCH,

                ID_WITCHER_WOLF_BANDANA,
                ID_WITCHER_RABBLE_ROUSER_HAIR,
                ID_ROACH_GWENT_CARD,

                ID_WITCHER_NG_STEEL_SWORD,
                ID_WITCHER_NG_SILVER_SWORD,
                ID_WITCHER_NG_ARMOR,
                ID_WITCHER_NG_TROUSERS,
                ID_WITCHER_NG_BOOTS,
                ID_WITCHER_NG_GLOVES
            ];

			var dataProvider : DataProvider = new DataProvider();
			var gutter : Object = { id : -1 };

            for each( var id : int in DISPLAY_ORDER )
            {
                if ( unlockedIds.indexOf( id ) != -1 )
                {
                    var rewardData : Object = mContentMap[ id ];
                    dataProvider.push( rewardData );
                }
            }
            dataProvider.push( gutter );
			
			return dataProvider;
		}

        public function setData( unlockedIds : Array ) : void
        {
            mDataProvider = createDataProvider( unlockedIds );

            trace( "MyRewardsPanel::setData : ", unlockedIds,  mDataProvider.size, mDataProvider);

            mcRewardsList.dataProvider = mDataProvider;
            mcRewardsList.validateNow();

            mcRewardsList.selectedIndex = 0;
        }

        private function handleAcceptAction( event : Event = null ) : void
		{
            trace( "MyRewardsPanel::handleAcceptAction" );

            dispatchEvent( new Event(EVENT_RESULT_CLOSE) );
		}

		private function handleSignOutAction( event : Event = null ) : void
		{
            trace( "MyRewardsPanel::handleSignOutAction" );

            dispatchEvent( new Event(EVENT_RESULT_LOGOUT) );
		}

        override public function set visible( value : Boolean) : void 
        {
            super.visible = value;

            //Dont forget to remove the focus when you hide the panel :)
            mcRewardsList.focused = value ? 1 : 0;
        }

        public function handleInputNavigate(event:InputEvent):void
        {
            trace( "MyRewardsPanel::handleInputNavigate" );
            
            //Manual focus handling because we dont use modules
            mcRewardsList.focused = 1;
            mcRewardsList.handleInput(event);

            centerSelected();

            var details:InputDetails = event.details;
            var keyUp:Boolean = (details.value == InputValue.KEY_UP);

            //Close/Accept
            if (keyUp && (details.navEquivalent == NavigationCode.GAMEPAD_B || details.code == KeyCode.ENTER) )
            {
                handleAcceptAction();
            }
        }

        private function centerSelected() : void
        {
            if ( mcRewardsList.selectedIndex > 2 )
            {
                mcRewardsList.scrollPosition = mcRewardsList.selectedIndex - 3;
            }
        }

        private function handleScroll( dir : int ) : void
        {
            var index : int = mcRewardsList.selectedIndex;
            if ( dir > 0 )
            {
                if ( index > 0 )
                {
                    mcRewardsList.selectedIndex = index - 1;
                    centerSelected();
                }
            }
            else if (dir < 0)
            {
                if (index < (mDataProvider.length - 1))
                {
                    mcRewardsList.selectedIndex = index + 1;
                    centerSelected();
                }
            }
        }

        private function handleMouseScroll( event : MouseEvent ) : void
		{
            if (!visible)
			{
				return;
			}

            handleScroll( event.delta );
		}

        private function handleGesturePan( event : TransformGestureEvent ) : void
		{	
            if (!visible)
			{
				return;
			}

			var rowHeight : Number = mcRewardsListItem1.height;
			var result : Object = CommonUtils.stagePanToRowScroll( mPanYAccumulator, rowHeight, event );

            handleScroll( result.outRowsToScroll );

			mPanYAccumulator = result.outPanYAccumulator;

		}

		private function handleMouseMove( event : MouseEvent ) : void
		{
			if (!visible)
			{
				return;
			}
			
            var listItem : MyRewardsListItem = getListItem( event.stageX, event.stageY );
            if ( listItem )
            {
                mcRewardsList.selectedIndex = listItem.index;
            }
		}

        private function handleGestureTap( event : GestureEvent ) : void
		{
			if (!visible)
			{
				return;
			}
			
            var listItem : MyRewardsListItem = getListItem( event.stageX, event.stageY );
            if ( listItem )
            {
                mcRewardsList.selectedIndex = listItem.index;
            }
		}

        private function getListItem( stageX : int, stageY : int ) : MyRewardsListItem
		{
            var renderer : MyRewardsListItem = null;
            for ( var i : uint = 0; i < m_renderers.length; ++i )
            {
                renderer = m_renderers[ i ];
                if ( renderer.hitTestPoint( stageX, stageY ))
                {
                    return renderer;
                }
            }

            return null;
		}
    }
}
