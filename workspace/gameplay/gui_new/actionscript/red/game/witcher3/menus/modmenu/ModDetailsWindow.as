/***********************************************************************
/** Mod Details Window
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.getDefinitionByName;
    import flash.events.MouseEvent;

    import scaleform.clik.core.UIComponent;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;

    import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

	import red.core.CoreComponent;
    import red.core.events.GameEvent;
	import red.core.constants.KeyCode;

	import red.game.witcher3.constants.EInputDeviceType;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common_menu.ModuleInputFeedback;

	public class ModDetailsWindow extends UIComponent
	{

        // CONSTS
        private static const TEXT_BOX_GAP : int = 5;
		private static const BTN_SUBSCRIBE:int = 100;
		private static const BTN_UNSUBSCRIBE:int = 101;
		private static const BTN_MORE:int = 200;
		private static const BTN_UPVOTE:int = 1310;
		private static const BTN_DOWNVOTE:int = 1311;
		private static const BTN_UNDO_VOTE:int = 1312;
		private static const BTN_MORE_FROM_AUTHOR:int = 2000;

		private static const TEXT_MODULE_TEXT_MAX_HEIGHT : Number = 575;

		// ART CLIPS
		public var mcGallery 			: ModImageGallery;
        public var mcTextAreaModule		: 	ModMenuTextAreaModule;
		public var mcDependencies		: ModDependencyModule;

		public var mcInfoPanel			: MovieClip;
        public var mcAuthorLocText 		: TextField;
        public var tfAuthorText 		:   TextField;
        public var mcFirstUploadLocText : TextField;
        public var tfFirstUploadText 	:   TextField;
        public var mcLastUpdateLocText 	: TextField;
        public var tfLastUpdateText 	:   TextField;
        public var mcVersionLocText 	: TextField;
        public var tfVersionText 		:   TextField;
		public var mcCompatibleLocText 	: TextField;
        public var tfCompatibleText 		:   TextField;
		public var mcPlatform			: MovieClip;
		public var mcLongSubscribedText : TextField;

		public var mcTagSelection		: MovieClip;
		public var mcTagScrollList 		: ModMenuTagScrollList;

		public var mcVoteHighlight		: MovieClip;
		public var mcUpvoteButton 		: StatusButton;
		public var mcDownvoteButton 	: StatusButton;

		public var mcNumericInfo		: MovieClip;
        public var downloadsText 		: TextField;
        public var sizeText 			: TextField;
        public var likesText 			: TextField;
		public var subscribersText 		: TextField;

		public var mcInputFeedback		: ModuleInputFeedback;
		public var mcInputBackground	: MovieClip;

		public var mcProgressBar		: MovieClip;

		//VARS
		protected var _lastMouseOveredItem:int = -1;
		public var _lastMoveWasMouse:Boolean = true;

		private var currentObj : MovieClip;
		private var _markedForDetransition:Boolean = false;

		private var lastLeftObj : MovieClip;
		private var lastRightObj : MovieClip;
		private var _upvoteStatus : String = "not_voted";
		private var isSubscribed : Boolean = false;
		private var modIndex : String;
		private var origin : MovieClip;
		
		private var tagsListWidthDefault : Number;
		private var tagsListRightDefault : Number;

		private var dependencyListBottomDefault : Number;

		private var cachedData : Object;

        public function ModDetailsWindow() 
		{
            super();
			mouseEnabled = true;
			mouseChildren = true;
			mcProgressBar.visible = false;
			mcUpvoteButton.visible = false;
		}

		protected function get menuName():String { return "ModMenu"; }
		override protected function configUI():void
		{
			super.configUI();

			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.details.data', [setData] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.mod.details.data.update', [updateData] ) );

			setupVoteFunctionality();
			mcVoteHighlight.alpha = 0;

			mcInputFeedback.mcInputBackground = mcInputBackground;
			mcInputFeedback.buttonAlign = "center";

			stage.addEventListener(InputEvent.INPUT, handleInputNavigate, false, 10, true);

			if(mcInfoPanel)
			{
				mcAuthorLocText = mcInfoPanel.mcAuthorLocText;
				tfAuthorText = mcInfoPanel.tfAuthorText;
				mcFirstUploadLocText = mcInfoPanel.mcFirstUploadLocText;
				tfFirstUploadText = mcInfoPanel.tfFirstUploadText;
				mcLastUpdateLocText = mcInfoPanel.mcLastUpdateLocText;
				tfLastUpdateText = mcInfoPanel.tfLastUpdateText;
				mcVersionLocText = mcInfoPanel.mcVersionLocText;
				tfVersionText = mcInfoPanel.tfVersionText;
				//mcCompatibleLocText = mcInfoPanel.mcCompatibleLocText;
				//tfCompatibleText = mcInfoPanel.tfCompatibleText;
				mcTagSelection = mcInfoPanel.mcTagSelection;
				mcTagScrollList = mcInfoPanel.mcTagScrollList;
				mcPlatform = mcInfoPanel.mcPlatform;
			}

			if(mcNumericInfo)
			{
				downloadsText = mcNumericInfo.downloadsText;
				sizeText = mcNumericInfo.sizeText;
				likesText = mcNumericInfo.likesText;
				subscribersText = mcNumericInfo.subscribersText;
			}

			if(mcTagSelection)
				mcTagSelection.alpha = 0;

			mcGallery.addEventListener(MouseEvent.CLICK, onModuleMouseClick, false, -100);
			mcTextAreaModule.addEventListener(MouseEvent.CLICK, onModuleMouseClick, false, -100);
			mcDependencies.addEventListener(MouseEvent.CLICK, onModuleMouseClick, false, -100);
			mcDependencies.funcHandleDoubleClick = handleDependencyDoubleClick;
			if(mcTagScrollList)
				mcTagScrollList.addEventListener(MouseEvent.CLICK, onModuleMouseClick, false, -100);

			scaleInputFeedback(1.1);

			if(mcTagScrollList) 
			{
				tagsListWidthDefault = mcTagScrollList.mcTagHolder.width;
				tagsListRightDefault = mcTagScrollList.x + mcTagScrollList.width;
			}

			if(mcDependencies)
			{
				dependencyListBottomDefault = mcDependencies.y + mcDependencies.height;
			}

			mcLongSubscribedText.visible = false;

			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
		}

		private function handleControllerChanged(event:ControllerChangeEvent):void
		{
			if (hasVoteFeedback())
				setupVoteFeedback();

			clearVoteFeedbackIFB();
			if(upvoteStatus == "upvoted")
			{
				setupForUndoVoteIFB();
			}
			else // if (upvoteStatus == "not_voted")
			{
				setupForUpvoteIFB();
			}
		}

		public function set upvoteStatus(value:String):void
		{
			_upvoteStatus = value;
			if(currentObj == mcUpvoteButton)
			{
				setupVoteFeedback();
			}
		}

		public function get upvoteStatus():String
		{
			return _upvoteStatus;
		}

		protected function setupVoteFunctionality()
		{
			mcUpvoteButton.statusColor = 0x151515;
			if(mcUpvoteButton)
			{
				mcUpvoteButton.scalingOption = "center";
				mcUpvoteButton.statusName = "upvoted";
				if(upvoteStatus == "upvoted")
				{
					mcUpvoteButton.statusEnabled = true;
					mcUpvoteButton.setText("[[panel_mods_upvoted]]");
				}
				else
				{
					mcUpvoteButton.statusEnabled = false;
					mcUpvoteButton.setText("[[panel_mods_upvote]]");
				}
				if(!mcUpvoteButton.hasEventListener(StatusButtonEvent.RELEASED))
					mcUpvoteButton.addEventListener(StatusButtonEvent.RELEASED, onUpvoteReleased);
			}

			if(mcDownvoteButton)
			{
				mcDownvoteButton.scalingOption = "right";
				mcDownvoteButton.statusName = "downvoted";
				if(upvoteStatus == "downvoted")
				{
					mcDownvoteButton.statusEnabled = true;
					mcDownvoteButton.setText("[[panel_mods_downvoted]]");
				}
				else
				{
					mcDownvoteButton.statusEnabled = false;
					mcDownvoteButton.setText("[[panel_mods_downvote]]");
				}
				if(!mcDownvoteButton.hasEventListener(StatusButtonEvent.RELEASED))
					mcDownvoteButton.addEventListener(StatusButtonEvent.RELEASED, onDownvoteReleased);
			}
		}

		public function handleDependencyDoubleClick(target:DisplayObject)
		{
			var dep : ThinModPreview = target as ThinModPreview;

			if(dep)
			{
				ModMenu(parent).requestModDetailsFromDetails(dep.cachedModId);
			}
		}

		public function setOrigin( newOrigin: MovieClip):void
		{
			origin = newOrigin;
		}

		public function isMarkedForDetransition() : Boolean
		{
			return _markedForDetransition;
		}

		public function onSelect( playAnimation : Boolean = true)
		{
			_markedForDetransition = false;
			if(playAnimation)
			{
				alpha = 0;
				y = 500;
				GTweener.removeTweens(this);
				GTweener.to(this, 0.5, { alpha:1, y:120 }, { ease:Exponential.easeOut, onComplete: onSelectTweenComplete } );
			}
			mcTextAreaModule.selected = true;
			ModMenu(parent).setupDetailsBindings();
			ModMenu(parent).clearModBindings();
			ModMenu(parent).clearLogoutBinding();
			ModMenu(parent).clearShowFilterBindings();
			ModMenu(parent).clearModListBindings();
		}

		public function deselect(playAnimation:Boolean = true)
		{
			ModMenu(parent).clearDetailsBindings();
			if(_markedForDetransition)
				return;

			swapCurrentObject(null);
			_markedForDetransition = true;
			ModMenu(parent).getCurrentTab().visible = true;
			if(playAnimation)
			{
				alpha = 1;
				GTweener.removeTweens(this);
				GTweener.to(this, 0.5, { alpha:0,y:500 }, { ease:Exponential.easeOut, onComplete: onDeselectTweenComplete} );
			}
			else
			{
				visible = false;
				resizeAndPositionTagList(tagsListWidthDefault);
			}
			mcTextAreaModule.selected = false;

			if(origin && origin is ModMenuBrowsePage) {
				ModMenu(parent).setupModBindings();
				ModMenu(parent).setupShowFilterBindings();
				ModMenu(parent).handleModListBindings();
			}
			else if(origin && origin is ModMenuInstalledPage)
			{
				ModMenuInstalledPage(origin).onRestore();
			}
		}

		protected function onSelectTweenComplete():void
		{
			ModMenu(parent).getCurrentTab().visible = false;
			clearVoteFeedback();
			ModMenu(parent).mcInstalledPage.clearCheckboxHints();
			ModMenu(parent).mcTabListItem1.enabled = false;
			ModMenu(parent).mcTabListItem2.enabled = false;
		}

        protected function onDeselectTweenComplete():void
		{
			visible = false;
			setupVoteFeedback();
			ModMenu(parent).setupLogoutBinding();
			ModMenu(parent).setupTabControlBindings();
			ModMenu(parent).mcTabListItem1.enabled = true;
			ModMenu(parent).mcTabListItem2.enabled = ModMenu(parent).getInstalledTabOpenable();
			resizeAndPositionTagList(tagsListWidthDefault);
		}

		protected function isTagListOpenable():Boolean
		{
			return mcTagScrollList.canBeScrolled();
		}

		protected function resizeAndPositionTagList(value:Number):void
		{
			//trace("GFX / resizeAndPositionTagList", value);
			mcTagScrollList.resizeWidth(value);
			mcTagSelection.width = value + 19; 

			if(CoreComponent.isArabicAligmentMode)
			{
				mcTagScrollList.x = 25 - 6 - 14;
				mcTagSelection.x = 25 - 9.5 - 6 - 14;
			}
			else
			{
				mcTagScrollList.x = tagsListRightDefault - value - 6 - 14;
				mcTagSelection.x = tagsListRightDefault - value - 9.5 - 6 - 14;
			}
		}

		public function trySetText(mainObject:DisplayObjectContainer, tfName : String, value : String)
		{
			var textField : TextField;
			var child : DisplayObject;
			
			if(mainObject)
			{
				child = mainObject.getChildByName(tfName);
			}
			else
			{
				child = getChildByName(tfName);
			}

			if(child && child is TextField)
			{
				textField = child as TextField;
				textField.text = value;
			}
		}

        public function setData(data:Object):void
        {
			//trace("GFX ######################## - SetData ", data.modName);
			cachedData = data;
            mcTextAreaModule.SetTitle(data.modName);
			if(data.modDesc.length == 0) 
				data.modDesc = "[[mods_no_description]]";
			else data.modDesc += " ";

			mcTextAreaModule.SetText(data.modDesc);

			if(data.dependencies) {
				mcDependencies.setData(data.dependencies);
				mcTextAreaModule.mcTextArea.textField.height = TEXT_MODULE_TEXT_MAX_HEIGHT - mcDependencies.getHeight();
				mcDependencies.y = dependencyListBottomDefault - mcDependencies.getHeight();
			}

			mcProgressBar.visible = false;

			mcTagScrollList.clearTags();
			resizeAndPositionTagList(tagsListWidthDefault);
			mcTagScrollList.setData(data.tags);

			var tagsWidth : Number = mcTagScrollList.getTagWidthTotal();
			if(tagsWidth < tagsListWidthDefault)
				resizeAndPositionTagList(tagsWidth);
			else mcTagScrollList.callSetButtonsResizeMask(tagsListWidthDefault);

			modIndex = data.modid;

			if(tfAuthorText)
            	tfAuthorText.text = data.author;
			if(data.platform && mcPlatform)
			{
				mcPlatform.gotoAndStop(data.platform);
				mcPlatform.x = tfAuthorText.x + tfAuthorText.width - tfAuthorText.textWidth - mcPlatform.width - 10;
				mcPlatform.y = tfAuthorText.y + (tfAuthorText.textHeight - mcPlatform.height) / 2;
			}
			else if (mcPlatform)
			{
				mcPlatform.gotoAndStop("pc");
			}

			if(mcInfoPanel)
			{
				if(CoreComponent.isArabicAligmentMode)
					mcInfoPanel.gotoAndStop("rtl");
				else
					mcInfoPanel.gotoAndStop("ltr");

				trySetText(mcInfoPanel, "tfFirstUploadText", ModStatics.getSimplifiedDate(tfFirstUploadText, data.firstUploadTime));
				trySetText(mcInfoPanel, "tfLastUpdateText", ModStatics.getSimplifiedDate(tfLastUpdateText, data.lastUpdateTime));
				trySetText(mcInfoPanel, "tfAuthorText", data.author);
				trySetText(mcInfoPanel, "tfVersionText", data.modVersion);
			}

			if(tfFirstUploadText)
				tfFirstUploadText.text = ModStatics.getSimplifiedDate(tfFirstUploadText, data.firstUploadTime)
			if(tfLastUpdateText)
				tfLastUpdateText.text = ModStatics.getSimplifiedDate(tfLastUpdateText, data.lastUpdateTime)
            
			//tfFirstUploadText.text = data.firstUploadTime;
           // tfLastUpdateText.text = data.lastUpdateTime;
			if(tfVersionText)
            	tfVersionText.text = data.modVersion;
			
			if(mcNumericInfo)
			{
				if(CoreComponent.isArabicAligmentMode)
					mcNumericInfo.gotoAndStop("rtl");
				else
					mcNumericInfo.gotoAndStop("ltr");

				trySetText(mcNumericInfo, "downloadsText", ModStatics.formatNumber(Number(data.downloads)));
				trySetText(mcNumericInfo, "sizeText", ModStatics.formatBytes(Number(data.size)));
				trySetText(mcNumericInfo, "likesText", ModStatics.formatNumber(Number(data.likes)));
				trySetText(mcNumericInfo, "subscribersText", ModStatics.formatNumber(Number(data.subscribers)));
			}

			if(downloadsText)
            	downloadsText.text = ModStatics.formatNumber(Number(data.downloads));
			if(sizeText)
				sizeText.text = ModStatics.formatBytes(Number(data.size));
			if(likesText)
				likesText.text = ModStatics.formatNumber(Number(data.likes));
			if(subscribersText)
				subscribersText.text = ModStatics.formatNumber(Number(data.subscribers));

			clearLocalInputFeedback();
			isSubscribed = data.state == 200;
			mcLongSubscribedText.visible = isSubscribed;
			if(isSubscribed)
			{
				setupForUnsubscribe();
			}
			else
			{
				setupForSubscribe();
			}
			setupForMore();
			setupForMoreFromAuthor();

			if(data.upvoted)
			{
				upvoteStatus = "upvoted";
				clearVoteFeedbackIFB();
				setupForUndoVoteIFB();
			}
			/*else if(data.downvoted)
			{
				upvoteStatus = "downvoted";
			}*/
			else
			{
				upvoteStatus = "not_voted";
				clearVoteFeedbackIFB();
				setupForUpvoteIFB();
			}
			setupVoteFunctionality();

			mcGallery.setData(data);
            endLoad();
        }

		public function updateData(data:Object)
		{
			cachedData = data;
            mcTextAreaModule.SetTitle(data.modName);
			if(data.modDesc.length == 0) 
				data.modDesc = "[[mods_no_description]]";
			else data.modDesc += " ";

			mcTextAreaModule.SetText(data.modDesc);

			mcTagScrollList.clearTags();
			resizeAndPositionTagList(tagsListWidthDefault);
			mcTagScrollList.setData(data.tags);

			var tagsWidth : Number = mcTagScrollList.getTagWidthTotal();
			if(tagsWidth < tagsListWidthDefault)
				resizeAndPositionTagList(tagsWidth);
			else mcTagScrollList.callSetButtonsResizeMask(tagsListWidthDefault);

			if(tfAuthorText)
            	tfAuthorText.text = data.author;
			if(data.platform && mcPlatform)
			{
				mcPlatform.gotoAndStop(data.platform);
				mcPlatform.x = tfAuthorText.x + tfAuthorText.width - tfAuthorText.textWidth - mcPlatform.width - 10;
				mcPlatform.y = tfAuthorText.y + (tfAuthorText.textHeight - mcPlatform.height) / 2;
			}
			else if (mcPlatform)
			{
				mcPlatform.gotoAndStop("pc");
			}

			if(mcInfoPanel)
			{
				if(CoreComponent.isArabicAligmentMode)
					mcInfoPanel.gotoAndStop("rtl");
				else
					mcInfoPanel.gotoAndStop("ltr");

				trySetText(mcInfoPanel, "tfFirstUploadText", ModStatics.getSimplifiedDate(tfFirstUploadText, data.firstUploadTime));
				trySetText(mcInfoPanel, "tfLastUpdateText", ModStatics.getSimplifiedDate(tfLastUpdateText, data.lastUpdateTime));
				trySetText(mcInfoPanel, "tfAuthorText", data.author);
				trySetText(mcInfoPanel, "tfVersionText", data.modVersion);
			}

			if(tfFirstUploadText)
				tfFirstUploadText.text = ModStatics.getSimplifiedDate(tfFirstUploadText, data.firstUploadTime)
			if(tfLastUpdateText)
				tfLastUpdateText.text = ModStatics.getSimplifiedDate(tfLastUpdateText, data.lastUpdateTime)
            
			//tfFirstUploadText.text = data.firstUploadTime;
           // tfLastUpdateText.text = data.lastUpdateTime;
			if(tfVersionText)
            	tfVersionText.text = data.modVersion;
			
			if(mcNumericInfo)
			{
				if(CoreComponent.isArabicAligmentMode)
					mcNumericInfo.gotoAndStop("rtl");
				else
					mcNumericInfo.gotoAndStop("ltr");

				trySetText(mcNumericInfo, "downloadsText", ModStatics.formatNumber(Number(data.downloads)));
				trySetText(mcNumericInfo, "sizeText", ModStatics.formatBytes(Number(data.size)));
				trySetText(mcNumericInfo, "likesText", ModStatics.formatNumber(Number(data.likes)));
				trySetText(mcNumericInfo, "subscribersText", ModStatics.formatNumber(Number(data.subscribers)));
			}

			if(downloadsText)
            	downloadsText.text = ModStatics.formatNumber(Number(data.downloads));
			if(sizeText)
				sizeText.text = ModStatics.formatBytes(Number(data.size));
			if(likesText)
				likesText.text = ModStatics.formatNumber(Number(data.likes));
			if(subscribersText)
				subscribersText.text = ModStatics.formatNumber(Number(data.subscribers));
		}

		protected function updateUpvoteCount():void
		{
			if(likesText)
				likesText.text = ModStatics.formatNumber(Number(cachedData.likes));
		}

        public function startLoad():void
        {

        }

        public function endLoad():void
        {

        }

		private function clearLocalInputFeedback():void
		{
			mcInputFeedback.removeButton(BTN_SUBSCRIBE, false);
			mcInputFeedback.removeButton(BTN_UNSUBSCRIBE, false);
			mcInputFeedback.removeButton(BTN_MORE, false);
			mcInputFeedback.removeButton(BTN_MORE_FROM_AUTHOR, true);
			mcInputFeedback.removeButton(BTN_UPVOTE, true);
			mcInputFeedback.removeButton(BTN_UNDO_VOTE, true);
		}

		private function setupForMoreFromAuthor():void
		{
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

			mcInputFeedback.appendButton(BTN_MORE_FROM_AUTHOR, NavigationCode.GAMEPAD_RSTICK_HOLD, KeyCode.M, "[[panel_mods_more_from_author]]", true);
			onLocalInputFeedbackUpdate();
		}

		private function setupForMore():void
		{
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

			mcInputFeedback.appendButton(BTN_MORE, isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, KeyCode.R, "[[panel_mods_more]]", true);
			onLocalInputFeedbackUpdate();
		}

		private function setupForSubscribe():void
		{
			mcInputFeedback.appendButton(BTN_SUBSCRIBE, NavigationCode.GAMEPAD_A, KeyCode.SPACE, "[[panel_mods_subscribe]]", true);
			onLocalInputFeedbackUpdate();
		}

		private function setupForUnsubscribe():void
		{
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

			mcInputFeedback.appendButton(BTN_UNSUBSCRIBE, isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X, KeyCode.X, "[[panel_mods_unsubscribe]]", true);
			onLocalInputFeedbackUpdate();
		}

		private function setupForUpvote():void
		{
			return; //this should not show up on the bottom now?
			var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;
			ModMenu(parent).mcInputFeedback.appendButton(BTN_UPVOTE, isSwitch2Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_R1, KeyCode.V, "[[panel_mods_upvote]]", true);
		}

		private function setupForUpvoteIFB():void
		{
			var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;
			mcInputFeedback.appendButton(BTN_UPVOTE, isSwitch2Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_R1, KeyCode.V, "[[panel_mods_upvote]]", true);
			onLocalInputFeedbackUpdate();
		}

		private function setupForDownvote():void
		{
			// If this ever gets uncommented, watch out for GAMEPAD_L1 as it is already used for upvote on Switch 2 mouser controls.
			// ModMenu(parent).mcInputFeedback.appendButton(BTN_DOWNVOTE, NavigationCode.GAMEPAD_L1, KeyCode.C, "[[panel_mods_downvote]]", true);
		}

		private function setupForUndoVote():void
		{
			return; //this should not show up on the bottom now?
			var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;
			ModMenu(parent).mcInputFeedback.appendButton(BTN_UNDO_VOTE, isSwitch2Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_R1, KeyCode.V, "[[panel_mods_undo_vote]]", true);
		}

		private function setupForUndoVoteIFB():void
		{
			var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;
			mcInputFeedback.appendButton(BTN_UNDO_VOTE, isSwitch2Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_R1, KeyCode.V, "[[panel_mods_undo_vote]]", true);
			onLocalInputFeedbackUpdate();
		}

		public function clearVoteFeedback():void
		{
			ModMenu(parent).mcInputFeedback.removeButton(BTN_UPVOTE, true);
			ModMenu(parent).mcInputFeedback.removeButton(BTN_DOWNVOTE, true);
			ModMenu(parent).mcInputFeedback.removeButton(BTN_UNDO_VOTE, true);
		}

		private function hasVoteFeedback():Boolean
		{
			return ModMenu(parent).mcInputFeedback.hasButton(BTN_UPVOTE) ||
				ModMenu(parent).mcInputFeedback.hasButton(BTN_DOWNVOTE) ||
				ModMenu(parent).mcInputFeedback.hasButton(BTN_UNDO_VOTE);
		}

		private function clearVoteFeedbackIFB():void
		{
			mcInputFeedback.removeButton(BTN_UPVOTE, true);
			mcInputFeedback.removeButton(BTN_DOWNVOTE, true);
			mcInputFeedback.removeButton(BTN_UNDO_VOTE, true);
		}

		public function setupVoteFeedback():void
		{
			clearVoteFeedback();
			if(upvoteStatus == "not_voted")
			{
				//setupForDownvote();
				setupForUpvote();
			}
			else if(upvoteStatus == "upvoted")
			{
				//setupForDownvote();
				setupForUndoVote();
			}
			/*else if (upvoteStatus == "downvoted")
			{
				setupForUndoVote();
				setupForUpvote();
			}*/
		}

		private function handleUpvotePress()
		{
			if(mcUpvoteButton.statusEnabled)
			{
				mcUpvoteButton.setText("[[panel_mods_upvoted]]");
				upvoteStatus = "upvoted";
			}
			else
			{
				mcUpvoteButton.setText("[[panel_mods_upvote]]");
				upvoteStatus = "not_voted";
			}
			//mcDownvoteButton.statusEnabled = false;
			//mcDownvoteButton.setText("[[panel_mods_downvote]]");
			clearVoteFeedbackIFB();
			if(upvoteStatus == "upvoted")
				setupForUndoVoteIFB();
			else
				setupForUpvoteIFB();

			/*if(upvoteStatus == "upvoted")
				cachedData.likes++;
			else 
				cachedData.likes--;*/

			updateUpvoteCount();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnVotingStatusChanged", [upvoteStatus] ) );
		}

		private function handleDownvotePress()
		{
			if(mcDownvoteButton.statusEnabled)
			{
				mcDownvoteButton.setText("[[panel_mods_downvoted]]");
				upvoteStatus = "downvoted";
			}
			else
			{
				mcDownvoteButton.setText("[[panel_mods_downvote]]");
				upvoteStatus = "not_voted";
			}
			mcUpvoteButton.statusEnabled = false;
			mcUpvoteButton.setText("[[panel_mods_upvote]]");
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnVotingStatusChanged", [upvoteStatus] ) );
		}

		private function onUpvoteReleased(event:StatusButtonEvent):void
		{
			trace ("GFX - onUpvoteReleased",event.status);
			handleUpvotePress();
		}

		private function onDownvoteReleased(event:StatusButtonEvent):void
		{
			trace ("GFX - onDownvoteReleased",event.status);
			handleDownvotePress();
		}
        
		private function voteSelectedAnimation_Up():void
        {
            GTweener.removeTweens(mcVoteHighlight);
		    GTweener.to(mcVoteHighlight, 0.7, { alpha:0.15 }, { onComplete: voteSelectedAnimation_Down } );
        }

        private function voteSelectedAnimation_Down():void
        {
            GTweener.removeTweens(mcVoteHighlight);
		    GTweener.to(mcVoteHighlight, 0.7, { alpha:0.1 }, { onComplete: voteSelectedAnimation_Up } );
        }

		private function tagSelectedAnimation_Up():void
        {
            GTweener.removeTweens(mcTagSelection);
		    GTweener.to(mcTagSelection, 0.7, { alpha:1 }, { onComplete: tagSelectedAnimation_Down } );
        }

        private function tagSelectedAnimation_Down():void
        {
            GTweener.removeTweens(mcVoteHighlight);
		    GTweener.to(mcTagSelection, 0.7, { alpha:0.5 }, { onComplete: tagSelectedAnimation_Up } );
        }

		protected function clearPreviousObject(mouseOrigin:Boolean = false):void
		{
			//Handling previous object clear	
			if(currentObj == mcGallery)
			{
				mcGallery.deselect();
			}
			else if(currentObj == mcTextAreaModule)
			{
				//mcTextAreaModule.selected = false;
				//GTweener.removeTweens(mcTextAreaModule.mcTextArea);
				//GTweener.to(mcTextAreaModule.mcTextArea, 0.5, {alpha:0.8}, {});
				//mcTextAreaModule.focused = 0;
			}
			else if (currentObj == mcDependencies)
			{
				mcDependencies.active = false;
				ModMenu(parent).clearDetailsButtonBinding();
			}
			else if (currentObj == mcUpvoteButton)
			{
				GTweener.removeTweens(mcVoteHighlight);
				GTweener.to(mcVoteHighlight, 0.5, {alpha:0}, {});
				clearVoteFeedback();
			}
			else if (currentObj == mcTagScrollList)
			{
				mcTagScrollList.deselect();
				GTweener.removeTweens(mcTagSelection);
				GTweener.to(mcTagSelection, 0.5, {alpha:0}, {});
			}
		}

		protected function setupNewObject(mouseOrigin:Boolean = false):void
		{

			//Handling new object setup
			if(currentObj == mcGallery)
			{
				mcGallery.onSelect();
			}
			else if(currentObj == mcTagScrollList)
			{
				mcTagScrollList.onSelect();
				GTweener.removeTweens(mcTagSelection);
				tagSelectedAnimation_Up();
			}
			else
			{
				lastRightObj = currentObj;
			}

			if(currentObj == mcUpvoteButton)
			{
				//setupVoteFeedback();
				//GTweener.removeTweens(mcVoteHighlight);
				//voteSelectedAnimation_Up();
			}
			else if(currentObj == mcTextAreaModule)
			{
				//mcTextAreaModule.selected = true;
				//GTweener.removeTweens(mcTextAreaModule.mcTextArea);
				//GTweener.to(mcTextAreaModule.mcTextArea, 0.5, {alpha:1}, {});
				//mcTextAreaModule.focused = 1;
			}
			else if (currentObj == mcDependencies)
			{
				mcDependencies.active = true;
				ModMenu(parent).setupDetailsButtonBinding();
			}
			else if (currentObj == mcInputFeedback)
			{

			}
			else 
			{
				lastLeftObj = currentObj;
			}
		}


		protected function onModuleMouseClick(event:MouseEvent)
		{
			//trace("GFX",this,"onModuleMouseClick");
			var currentTarget : MovieClip = event.currentTarget as MovieClip;
			if(currentTarget) {
				if(currentTarget != mcTagScrollList || mcTagScrollList.canBeScrolled())
					swapCurrentObject(currentTarget, true);
			}
		}

		protected function swapCurrentObject(newObj:MovieClip, mouseOrigin:Boolean = false)
		{
			if(currentObj == newObj)
				return;

			//skip this
			if(newObj == mcDependencies && !mcDependencies.hasData())
				return;

			/*if(currentObj && newObj)
				trace("GFX - DetailsWindow - Swap:",currentObj.name,newObj.name);
			else
				trace ("GFX - DetailsWindow - Swap unnamed");*/

			//trace("GFX - Swap: Mouse:",mouseOrigin);

			clearPreviousObject(mouseOrigin);

			currentObj = newObj;
			
			if(currentObj)
				setupNewObject(mouseOrigin);
		}

		protected function selectDefaultElement():void
		{
			swapCurrentObject(mcGallery);
		}

		protected function selectDefaultLeftElement():void
		{
			swapCurrentObject(mcGallery);
		}

		protected function selectDefaultRightElement():void
		{
			swapCurrentObject(mcDependencies);
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
		}

		protected function selectRightSide():void
		{
			if(lastRightObj != null)
				swapCurrentObject(lastRightObj);
			else selectDefaultRightElement();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
		}

		protected function selectLeftSide():void
		{
			if(lastLeftObj != null && (lastLeftObj != mcTagScrollList || mcTagScrollList.canBeScrolled()))
				swapCurrentObject(lastLeftObj);
			else selectDefaultLeftElement();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
		}

		protected function handleDown(event:InputEvent):void
		{
			if(currentObj == mcGallery)
			{
				if(isTagListOpenable())
				{
					swapCurrentObject(mcTagScrollList);
				}
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
			}
			/*else if(currentObj == mcTextAreaModule)
			{
				swapCurrentObject(mcUpvoteButton);
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
			}
			else if(currentObj == mcUpvoteButton)
			{
				swapCurrentObject(mcInputFeedback);
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
			}*/
			else if(isCurrentObjUnhandled())
			{
				selectDefaultElement();
				event.handled = true;
			}
		}

		protected function handleUp(event:InputEvent):void
		{
			if(currentObj == mcTagScrollList)
			{
				swapCurrentObject(mcGallery);
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
			}
			/*else if(currentObj == mcUpvoteButton)
			{
				swapCurrentObject(mcTextAreaModule);
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
			}
			else if(currentObj == mcInputFeedback)
			{
				swapCurrentObject(mcUpvoteButton);
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"] ) );
			}*/
			else if(isCurrentObjUnhandled())
			{
				selectDefaultElement();
				event.handled = true;
			}
		}

		protected function handleLeft(event:InputEvent):void
		{
			if(currentObj == mcGallery) {
				//moving should be handled by gallery
				event.handled = true;
			}
			else if(currentObj == mcUpvoteButton || currentObj == mcTextAreaModule || currentObj == mcInputFeedback || currentObj == mcDependencies)
			{
				selectLeftSide();
			}
			else if(isCurrentObjUnhandled())
			{
				selectDefaultLeftElement();
				event.handled = true;
			}
		}

		protected function handleRight(event:InputEvent):void
		{
			if(currentObj == mcGallery || currentObj == mcTagScrollList) {
				//moving images should be handled by gallery
				selectRightSide();
				event.handled = true;
			}
			else if(isCurrentObjUnhandled())
			{
				selectDefaultRightElement();
				event.handled = true;
			}
		}

		protected function handleInputNavigate(event:InputEvent):void
		{	
			if(_markedForDetransition || ModMenu(parent).isInputBeingBlocked())
				return;

			//trace("GFX - ModDetailsWindow - handleInputNavigate", event.handled, event);
			//if(currentObj)
			//	trace("GFX - ModDetailsWindow - input currentObj",currentObj.name);

			if(!visible)
				return;

			var details:InputDetails = event.details;

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var hold:Boolean = details.value == InputValue.KEY_HOLD; //#B should be also hold here
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
			var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;

			if (!event.handled)
			{
				if(details.navEquivalent == NavigationCode.DOWN && (keyDown || hold))
				{
					handleDown(event);
				}
				else if (details.navEquivalent == NavigationCode.UP && (keyDown || hold))
				{
					handleUp(event);
				}
				else if (details.navEquivalent == NavigationCode.LEFT && (keyDown || hold))
				{
					handleLeft(event);
				}
				else if (details.navEquivalent == NavigationCode.RIGHT && (keyDown || hold))
				{
					handleRight(event);
				}
			}

			if(!event.handled)
			{
				//if(currentObj == mcUpvoteButton)
				{
					if (((isSwitch2Mouser && details.navEquivalent == NavigationCode.GAMEPAD_L1) ||
						(!isSwitch2Mouser && details.navEquivalent == NavigationCode.GAMEPAD_R1) ||
						details.code == KeyCode.V) && keyUp)
					{
						mcUpvoteButton.statusEnabled = !mcUpvoteButton.statusEnabled;
						handleUpvotePress();
						event.handled = true;
					}
				}
				if ((details.navEquivalent == NavigationCode.GAMEPAD_A && keyDown) || (details.code == KeyCode.SPACE && keyUp))
				{
					if (!isSubscribed)
					{
						onSubscribeMod();
						event.handled = true;
					}
				}
				else if ((details.navEquivalent == NavigationCode.GAMEPAD_START && keyDown) || (details.code == KeyCode.T && keyUp))
				{
					if(currentObj == mcDependencies)
					{
						var dependency : ThinModPreview = mcDependencies.getSelectedDependency();

						if(dependency)
						{
							ModMenu(parent).requestModDetailsFromDetails(dependency.cachedModId);
						}
					}
				}

				else if ((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y && keyDown) ||		// Y on switch
						(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X && keyDown) ||		// X on other platforms
						(details.code == KeyCode.X && keyUp))
				{
					if(isSubscribed)
					{
						onUnsubscribeMod();
						event.handled = true;
					}
				}
				else if ((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X && keyDown) ||		// Y on switch
						(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y && keyDown) ||		// X on other platforms
						(details.code == KeyCode.R && keyUp))
				{
					if(details.code != KeyCode.T) // <-- using the details button from library details triggers gamepad_x as well...
					{
						onMore();
						event.handled = true;
					}
				}
				else if ((details.navEquivalent == NavigationCode.GAMEPAD_R3 && keyDown) ||	
						(details.code == KeyCode.M && keyUp))
				{
					onMoreFromAuthor();
					event.handled = true;
				}

			}
		}

		protected function onSubscribeMod()
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSubscribeModDetails") );
		}

		protected function onUnsubscribeMod()
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnUnsubscribeInstalledModDetails") );
		}

		protected function onMore()
		{
			ModMenu(parent).openSandwichPanel(cachedData);
		}

		protected function clearAllCachedIdsInWS():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnClearCachedDetails") );
		}

		protected function onMoreFromAuthor()
		{
			if(ModStatics.getModMenu())
				ModStatics.getModMenu().openBrowsePage(true);
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnMoreFromAuthor") );
			clearAllCachedIdsInWS();
		}

		
		protected function isCurrentObjUnhandled():Boolean
		{
			return currentObj != mcGallery && currentObj != mcTextAreaModule && currentObj != mcDependencies && currentObj != mcUpvoteButton && currentObj != mcTagScrollList && currentObj != mcInputFeedback;
		}

		// scales input feedback around its center
		// its pivoted to the right center
		private function scaleInputFeedback(value:Number):void
		{
			var xRight : Number = mcInputFeedback.x;
			var yCenter : Number = mcInputFeedback.y;

			var iWidth = mcInputFeedback.width;
			var iHeight = mcInputFeedback.height;
			mcInputFeedback.setActualScale(value, value);
			var pushX : Number = (mcInputFeedback.width - iWidth) / 2;
			mcInputFeedback.x += pushX;

		}


		public function  /* WitcherScript */ updateProgressBar(modid:String, stage:int, progress:Number):void
		{
			var progressInt : int = (int)(100 * progress);

			if(modIndex == modid)
			{
				mcProgressBar.visible = true;
				mcProgressBar.gotoAndStop(progressInt);
				if(stage == 1)
				{
					mcProgressBar.tfUnderText.text = "[[mods_downloading]]";
					mcProgressBar.tfOverText.text = "[[mods_downloading]]";
				}
				else if (stage == 2)
				{
					mcProgressBar.tfUnderText.text = "[[mods_extracting]]";
					mcProgressBar.tfOverText.text = "[[mods_extracting]]";

					if(progress >= 0.995) {
						mcProgressBar.visible = false;
						mcLongSubscribedText.visible = true;
						clearLocalInputFeedback();
						setupForUnsubscribe();
						setupForMore();
						setupForMoreFromAuthor();
						if(upvoteStatus == "upvoted")
							setupForUndoVoteIFB();
						else
							setupForUpvoteIFB();
						//setupForUpvoteIFB();
						isSubscribed = true;
					}
				}
				else 
				{
					mcProgressBar.visible = false
					mcLongSubscribedText.visible = false;
					clearLocalInputFeedback();
					setupForSubscribe();
					setupForMore();
					setupForMoreFromAuthor();
					if(upvoteStatus == "upvoted")
						setupForUndoVoteIFB();
					else
						setupForUpvoteIFB();
					//setupForUpvoteIFB();
					isSubscribed = false;
					return;
				}
				mcProgressBar.tfUnderText.text = mcProgressBar.tfUnderText.text.replace("{x}", progressInt);
				mcProgressBar.tfOverText.text = mcProgressBar.tfOverText.text.replace("{x}", progressInt);
			}
			else 
				mcProgressBar.visible = false;

		}

		public function onLocalInputFeedbackUpdate():void
		{
			var scale : Number = 1.1;
			var maxAllowedWidth : Number = 720;

			while(true)
			{
				if(mcInputFeedback.buttonsContainer.width * scale < maxAllowedWidth)
					break;
				
				scale *= 0.9;
				scaleInputFeedback(scale);
			}
		}
	}
	
}