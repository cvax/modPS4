package red.game.witcher3.menus.character_menu
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import red.core.constants.KeyCode;
	import red.core.CoreMenu;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.EInputDeviceType;
	import red.game.witcher3.constants.InventoryActionType;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.managers.ContextInfoManager;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.menus.common.PlayerStatsModule;
	import red.game.witcher3.menus.overlay.BookPopup;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import red.game.witcher3.slots.SlotSkillGrid;
	import red.game.witcher3.slots.SlotSkillMutagen;
	import red.game.witcher3.slots.SlotSkillSocket;
	import red.game.witcher3.slots.SlotsTransferManager;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
	import red.game.witcher3.slots.SlotsListBase;
	import red.game.witcher3.menus.character_menu.CharacterSkillsGridModule;
	import flash.utils.setTimeout;
	import flash.events.GestureEvent;
	import red.core.events.GestureEventEx;

	/**
	 * Character development menu
	 * @author Getsevich Yaroslav
	 */
	public class MenuCharacterDupe extends CoreMenu
	{
		private const UNEQUIP_MUTAGEN_HOLD_DURATION:Number = 1000;
		private const POINTS_AVAILABLE_GAP:Number = 25;

		public var mcDupeTabModule:CharacterTabbedListModuleDupe;
		
		public var moduleSkillSlot:ModuleSkillsSocketsDupe;
		
		public var applyMode:CharacterModeBackground;
		public var tooltipAnchor:DisplayObject;
		public var txfAvailablePoints:TextField;
		public var txfPointsValue:TextField;
		public var btnMutationMode:InputFeedbackButton;
		
		public var mcPointIcon:MovieClip;
		public var mcPointsBorder:MovieClip;
		public var mcBackgroundImage:MovieClip;
		public var mcRunewordIcon:MovieClip;
		public var tfRunewordDescription:TextField;

		public var mcSlotChangeHighlight:MovieClip;
		
		public var _calledWSChange:Boolean = false;
		public var _pointsCount:int = 0;
		
		protected var _cachedSlotData:Object;
		protected var _holdY_triggered:Boolean = false;
		
		public var mcMasterMutation:MasterMutationItemRenderer;
		
		//private var _isMutationBonusMode:Boolean = false;
		private var _isMutationEnabled:Boolean = false;
		private var _mcMutationPanel:MutationsPanel;
		
		private var _btn_mutation : int = -1;
		private var _btn_switch_sections    : int = -1;
		private var _btn_left_tab    : int = -1;
		private var _btn_right_tab   : int = -1;
		
		public function MenuCharacterDupe()
		{
			applyMode.deactivate();

			btnMutationMode = mcMasterMutation.btnMutationMode;
			btnMutationMode.visible = true;
			btnMutationMode.label = "[[mutation_title_mutations]]";
			
			btnMutationMode.clickable = false;
			btnMutationMode.mouseChildren = btnMutationMode.mouseEnabled = false;

			btnMutationMode.x = mcMasterMutation.tfState.x + mcMasterMutation.tfState.width - btnMutationMode.getOccupiedWidth() - 130; //Magic push offset so its correctly aligned
			
			if (mcMasterMutation)
			{
				mcMasterMutation.enabled = false;
				mcMasterMutation.selectable = false;
				mcMasterMutation.visible = false;
				mcMasterMutation.mouseChildren = mcMasterMutation.mouseEnabled = false;
				mcMasterMutation.addEventListener(MouseEvent.CLICK, handleMasterMutationTapOrClick, false, 0, true);
				mcMasterMutation.addEventListener(GestureEventEx.GESTURE_TAP, handleMasterMutationTapOrClick, false, 0, true);
			}
			
			setTimeout( configButtonDelayed_HACK, 500 ); 
		}

		private function configButtonDelayed_HACK() : void
		{
			//We have to do this because InputManager platform gets set AFTER this::configUI.

			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
			btnMutationMode.setDataFromStage(isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, KeyCode.C);
		}
		
		override protected function get menuName():String { return "CharacterMenuDupe"	}
		override protected function configUI():void
		{
			super.configUI();
			
			if (mcRunewordIcon)
			{
				mcRunewordIcon.visible = false;
			}
			if (tfRunewordDescription)
			{
				tfRunewordDescription.visible = false;
			}
			
			txfAvailablePoints.text = "[[panel_character_availablepoints]]";
			txfAvailablePoints.text = CommonUtils.toUpperCaseSafe(txfAvailablePoints.text);
			txfPointsValue.text = "0";
			
			// base
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'character.skills.grid', [ updateSkillsGrid ] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'character.skills.slots', [ updateSkillsSockets ] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'character.skills.slot.update', [ updateSkillSocket ] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'character.skills.mutagens', [ updateSkillMutagens ] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'character.skills.points', [ setSkillPoints ] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'character.groups.bonus', [ updateGroupsBonus ] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'character.skills.grid.stable', [ stableUpdateSkillsGrid ] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, 'character.paperdoll.changed', [ onPaperdollChanged ] ) );
			
			// mutations
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "character.mutations.list", [setMutationDataList] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "character.mutation", [setSingleMutationData] ) );
			
			if (!Extensions.isScaleform)
			{
				initDebugData();
			}
			
			mcDupeTabModule.mcSkillModule.addEventListener( "EVENT_SELECTED_SKILL_TAPPED", onSkillTappedTwice, false, 0, true );
			mcDupeTabModule.mcMutagenSlotList.addEventListener( SlotsListBase.EVENT_SELECTED_TAPPED, onMutagenTappedTwice, false, 0, true );
			moduleSkillSlot.socketsList.addEventListener( SlotsListBase.EVENT_SELECTED_TAPPED, onSocketTappedTwice, false, 0, true);

			moduleSkillSlot.addEventListener(SlotActionEvent.EVENT_ACTIVATE, handleSlotAction, false, 0, true);
			moduleSkillSlot.socketsList.addEventListener(ListEvent.INDEX_CHANGE, onSlotSelected, false, 0, true);
			moduleSkillSlot.addEventListener(SlotActionEvent.EVENT_SELECT, handleSlotActivate, false, 0, true);
			
			moduleSkillSlot.addEventListener(SlotActionEvent.EVENT_SECONDARY_ACTION, handleSkillSecondaryAction, false, 0, true);

			mcDupeTabModule.addEventListener(SlotActionEvent.EVENT_ACTIVATE, handleSkillAction, false, 0, true);
			mcDupeTabModule.addEventListener(SlotActionEvent.EVENT_SECONDARY_ACTION, handleSkillSecondaryAction, false, 0, true);
			
			applyMode.addEventListener(CharacterModeBackground.CANCEL, handleApplyModeCancel, false, 0, true);
			applyMode.addEventListener(CharacterModeBackground.ACCEPT, handleApplyModeAccept, false, 0, true);

			var inputMgr:InputManager = InputManager.getInstance();
			inputMgr.addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
			
			_contextMgr.defaultAnchor = tooltipAnchor;
			_contextMgr.addGridEventsTooltipHolder(stage);
			_contextMgr.addEventListener(ContextInfoManager.TOOLTIP_SHOW_ERROR, handleTooltipFailedToShow, false, 0, true);
			_contextMgr.enableInputFeedbackShowing(true);
			_contextMgr.saveScaleValue = true;
			
			currentModuleIdx = 1;
			
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnConfigUI" ) );
			
			if (_btn_switch_sections == -1 && InputManager.getInstance().gamepadType != EInputDeviceType.IDT_Switch2_Mouser)
			{
				_btn_switch_sections = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_R3, -1 , "panel_button_common_jump_sections");
			}

			if (_btn_left_tab == -1 && _btn_right_tab == -1)
			{
				var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;

				_btn_left_tab = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_L2, -1 , "photomode_navigation_previous_tab");
				_btn_right_tab = InputFeedbackManager.appendButton(this, isSwitch2Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_R2, -1 , "photomode_navigation_next_tab");
			}
			InputFeedbackManager.updateButtons(this);

			SlotsTransferManager.getInstance().enableDragWithPan( true );
		}
		
		private var _isMutationInited:Boolean = false;
		public function get mcMutationPanel():MutationsPanel
		{
			if (!_mcMutationPanel)
			{
				const MUT_PANEL_DEF_X:Number = -23.6;
				const MUT_PANEL_DEF_Y:Number = 8.55;
				const MUT_PANEL_CLASS_NAME:String = "MutationPanelRef";
				
				var classRef:Class = getDefinitionByName( MUT_PANEL_CLASS_NAME ) as Class;
				
				_mcMutationPanel = new classRef() as MutationsPanel;
				_mcMutationPanel.x = MUT_PANEL_DEF_X;
				_mcMutationPanel.y = MUT_PANEL_DEF_Y;
				_mcMutationPanel.addEventListener(Event.ACTIVATE, handleMutationPanelToggled , false, 0, true);
				_mcMutationPanel.addEventListener(Event.DEACTIVATE, handleMutationPanelToggled, false, 0, true);
				
				addChild( _mcMutationPanel );
				
				_mcMutationPanel.validateNow();
				_isMutationInited = true;
			}
			
			return _mcMutationPanel;
		}
		
		public function confirmMutationResearch():void
		{
			//mcMutationPanel.confirmResearch();
		}
		
		public function /*WS*/ setMutationDataList(value:Array):void
		{
			var isMutationEquipped:Boolean = false;
			var isMasterFound:Boolean = false;
			var masterMutation:MasterMutationItemRenderer = mcMutationPanel.mcMutation13 as MasterMutationItemRenderer;
			
			//trace("GFX ========================= setMutationDataList ", value);
			
			masterMutation.resetColor();
			mcMasterMutation.resetColor();
			
			if (value)
			{
				var len:int = value.length;
				
				_isMutationEnabled = len > 0;
				
				moduleSkillSlot.mutationMode = _isMutationEnabled;
				
				if (!_isMutationEnabled)
				{
					btnMutationMode.visible = false;
					mcMasterMutation.visible = false;
					mcMasterMutation.mouseChildren = mcMasterMutation.mouseEnabled = false;
				}
				else
				{
					if (_btn_mutation == -1)
					{
						var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
						_btn_mutation = InputFeedbackManager.appendButton(this, isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, KeyCode.C, "mutation_title_mutations");
					}
					btnMutationMode.visible = !mcMutationPanel.active;
					mcMutationPanel.setDataList(value);
					
					for (var i:int = 0; i < len; i++)
					{
						var curDataItem:Object = value[i];
						
						if (curDataItem.isEquipped)
						{
							mcMutationPanel.equippedMutationId = curDataItem.mutationId;
							masterMutation.setColorByMutationId(curDataItem.mutationId);
							mcMasterMutation.setColorByMutationId(curDataItem.mutationId);
							mcMasterMutation.setEquippedMutationData(curDataItem);
							isMutationEquipped = true;
							
							if (isMasterFound)
							{
								break;
							}
						}
						else
						if (curDataItem.isMasterMutation)
						{
							mcMasterMutation.data = curDataItem;
							mcMasterMutation.validateNow();
							mcMasterMutation.visible = true;
							mcMasterMutation.enabled = false;
							mcMasterMutation.selectable = false;
							mcMasterMutation.mouseChildren = mcMasterMutation.mouseEnabled = true;
							isMasterFound = true;
							
							if (isMutationEquipped)
							{
								break;
							}
						}
					}
					
					if (!isMutationEquipped)
					{
						mcMutationPanel.equippedMutationId = -1;
						mcMasterMutation.hideDescription(true);
						moduleSkillSlot.additionalSkillsMode = false;
					}
					else
					{
						mcMasterMutation.hideDescription(false);
						moduleSkillSlot.additionalSkillsMode = true;
					}
				}
			}
		}
		
		public function /*WS*/ setSingleMutationData(value:Object):void
		{						
			if (value && value.isEquipped)
			{
				mcMasterMutation.data = value;				
				mcMasterMutation.setEquippedMutationData(value);
				mcMasterMutation.setColorByMutationId(value.mutationId);
				mcMasterMutation.hideDescription(false);				
				mcMasterMutation.validateNow();
			}
			
			if (_isMutationInited)
			{				
				mcMutationPanel.setSingleMutationData(value);
			}
			
			if (!_isMutationEnabled)
			{
				_isMutationEnabled = true;
				moduleSkillSlot.mutationMode = _isMutationEnabled;
			}
		}
		
		public function /*WS*/ setMutationBonusMode(value:Boolean):void
		{
			_isMutationEnabled = value;
			
			if (_isMutationEnabled)
			{
				moduleSkillSlot.mutationMode = _isMutationEnabled;
			}
			else
			{
				btnMutationMode.visible = false;
				mcMasterMutation.visible = false;
				mcMasterMutation.enabled = false;
				mcMasterMutation.selectable = false;
				mcMasterMutation.mouseChildren = mcMasterMutation.mouseEnabled = false;
			}
			
			mcMasterMutation.hideDescription(true);
		}
		
		public function /*WS*/ activateRunwordBuf(value:Boolean, textDescription:String):void
		{
			if (mcRunewordIcon && tfRunewordDescription)
			{
				mcRunewordIcon.visible = value;
				tfRunewordDescription.visible = value;
				tfRunewordDescription.htmlText = textDescription;
				//tfRunewordDescription.height = tfRunewordDescription.textHeight;
				mcRunewordIcon.y = tfRunewordDescription.y + tfRunewordDescription.textHeight / 2;
			}
			SlotSkillSocket.GLOW_EQUIPPED = value;
		}
		
		private function enableMutationButton(value:Boolean):void
		{
			/*
			 * #Y disable hold action for now
			 * TEST
			 *
			if (value)
			{
				btnMutationMode.holdCallback = onCallUnequipMutation;
				btnMutationMode.holdDuration = UNEQUIP_MUTAGEN_HOLD_DURATION;
			}
			else
			{
				btnMutationMode.holdCallback = null;
				btnMutationMode.holdDuration = -1;
			}
			*/
		}
		
		private function onCallUnequipMutation():void
		{
			_holdY_triggered = true;
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnUnequipMutation"));
		}

		override protected function handleControllerChanged(event:ControllerChangeEvent):void
		{
			super.handleControllerChanged(event);

			if (mcMutationPanel.active)
				return;

			var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;

			if (_btn_switch_sections == -1 && !isSwitch2Mouser)
			{
				_btn_switch_sections = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_R3, -1 , "panel_button_common_jump_sections");
			}
			else if (_btn_switch_sections != -1)
			{
				InputFeedbackManager.removeButton(this, _btn_switch_sections);
				_btn_switch_sections = -1;
			}

			InputFeedbackManager.removeButton(this, _btn_left_tab);
			InputFeedbackManager.removeButton(this, _btn_right_tab);
			_btn_left_tab = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_L2, -1 , "photomode_navigation_previous_tab");
			_btn_right_tab = InputFeedbackManager.appendButton(this, isSwitch2Mouser ? NavigationCode.GAMEPAD_L1 : NavigationCode.GAMEPAD_R2, -1 , "photomode_navigation_next_tab");

			InputFeedbackManager.updateButtons(this);
		}
		
		protected function startApplyMode(targetSlot:SlotBase) : void
		{
			if (_inCombat)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnSendNotification", ["menu_cannot_perform_action_combat"] ) );
			}
			else
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnStartApplyMode"));
				
				//Disable inputevents from common menu, to avoid event generation when the
				//bottom inputFeedbackButtos overlap with the apply mode modal.
				enableForeignInputEvent( false );

				applyMode.activate(targetSlot);

				if (targetSlot is SlotSkillGrid)
				{
					moduleSkillSlot.disableMutagens(true);
					moduleSkillSlot.SetUnselectableLockedAndMutagens(targetSlot.data.color);
				}
				else
				{
					moduleSkillSlot.disableNonMutagensAndLocked();
				}
				
				moduleSkillSlot.setSelectionMode(true);
				
				moduleSkillSlot.socketsList.ReselectIndexIfInvalid(moduleSkillSlot.socketsList.selectedIndex);
				
				mcDupeTabModule.enabled = false;
				
				currentModuleIdx = 0;
				_cachedSlotData = targetSlot.data;
				
				SlotsTransferManager.getInstance().disabled = true;
				
				enableMutationButton(false);
				
				_contextMgr.enableInputFeedbackShowing(false);
			}
		}

		protected function endApplyMode() : void
		{

			applyMode.deactivate();
			moduleSkillSlot.disableMutagens(false);
			moduleSkillSlot.SetAllSelectable();
			moduleSkillSlot.setSelectionMode(false);
			mcDupeTabModule.enabled = true;
			
			currentModuleIdx = 0;
			_cachedSlotData = null;
			
			SlotsTransferManager.getInstance().disabled = false;
			
			//enableMutationButton(_isMutationBonusMode);
			
			_contextMgr.enableInputFeedbackShowing(true);

			//Enable inputevents from common menu
			enableForeignInputEvent( true );
		}
		
		override protected function handleInputNavigate(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			var inputEnabled:Boolean = details.value == InputValue.KEY_UP && !event.handled;
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
			var isSwitch2Mouser : Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;
			
			//trace("GFX handleInputNavigate ", details.value, details.navEquivalent, _holdY_triggered );
			
			if( details.value == InputValue.KEY_UP &&
				_holdY_triggered &&
				((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X) ||		// X on switch
				(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y)) )		// Y on other platforms
			{
				_holdY_triggered = false;
				event.handled = true;
				return;
			}
			
			if (inputEnabled)
			{
				switch (details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_Y:
					case NavigationCode.GAMEPAD_X:
						if ((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X) ||	// X on switch
							(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y))	// Y on all other platforms
						{
							//trace("GFX handleInputNavigate ", btnMutationMode.getCurrentHoldProgress());
							
							if (_isMutationEnabled && btnMutationMode.getCurrentHoldProgress() < .1 && !applyMode.isActive()) // 0..1 progress // ignore holdinginput
							{
								mcMutationPanel.active = !mcMutationPanel.active;
								event.handled = true;
								event.stopImmediatePropagation();
								
							}
						}
						
						break;
					case NavigationCode.GAMEPAD_A:
						
						if (applyMode.isActive())
						{
							handleApplyModeAccept();
							event.handled = true;
							event.stopImmediatePropagation();
						}
						
						break;
					case NavigationCode.GAMEPAD_B:
						
						if (applyMode.isActive())
						{
							endApplyMode();
							dispatchEvent( new GameEvent( GameEvent.CALL, "OnCancelApplyMode"));
							event.handled = true;
							event.stopImmediatePropagation();
							return;
						}
						
						break;
					case NavigationCode.GAMEPAD_L2:
						if(mcDupeTabModule.mcTabList.selectedIndex > 0)
						{
							mcDupeTabModule.mcTabList.selectedIndex--;
							selectCurrentTabIcon();
							event.handled = true;
						}
						break;
					case NavigationCode.GAMEPAD_R2:
					case NavigationCode.GAMEPAD_L1:
						if(mcDupeTabModule.mcTabList.selectedIndex < 4 && 
							((isSwitch2Mouser && details.navEquivalent == NavigationCode.GAMEPAD_L1) ||
							(!isSwitch2Mouser && details.navEquivalent == NavigationCode.GAMEPAD_R2)))
						{
							mcDupeTabModule.mcTabList.selectedIndex++;
							selectCurrentTabIcon();
							event.handled = true;
						}
						break;
				}
				
				if (details.code == KeyCode.C)
				{
					// instead of stats
					if (_isMutationEnabled && !applyMode.isActive())
					{
						mcMutationPanel.active = !mcMutationPanel.active;
						event.handled = true;
						event.stopImmediatePropagation();
					}
					
					/*
					event.handled = true;
					showFullStats();
					*/
				}
				else
				if (details.code == KeyCode.SPACE || details.code == KeyCode.E)
				{
					if ( applyMode.isActive() )
					{
						handleApplyModeAccept();
						event.handled = true;
						event.stopImmediatePropagation();
					}
				}
			}
			
			super.handleInputNavigate(event);
		}
		
		private function handleMasterMutationTapOrClick(event:Event):void
		{
			if (_isMutationEnabled && !mcMutationPanel.active && !applyMode.isActive())
			{
				mcMutationPanel.active = true;
			}
		}
		
		protected function handleMutationPanelToggled(event:Event):void
		{
			trace("GFX handleMutationPanelToggled ", mcMutationPanel.active);
			
			updateMutationPanelVisibility();
			
			if (mcMutationPanel.active)
			{
				SlotsTransferManager.getInstance().disabled = true;
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnOpenMutationPanel' ));
				
				moduleSkillSlot.hideInputFeedback = true;
				
				moduleSkillSlot.enabled = false;
				
				_contextMgr.blockModeSwitching = true;
				_contextMgr.enableInputFeedbackShowing(false);
				
				if (_btn_mutation != -1)
				{
					InputFeedbackManager.removeButton(this, _btn_mutation);
					_btn_mutation = -1;
				}
				if (_btn_switch_sections != -1)
				{
					InputFeedbackManager.removeButton(this, _btn_switch_sections);
					_btn_switch_sections = -1;
				}
				InputFeedbackManager.updateButtons(this);
			}
			else
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnCloseMutationPanel' ));
				SlotsTransferManager.getInstance().disabled = false;
				
				moduleSkillSlot.hideInputFeedback = false;
				
				moduleSkillSlot.enabled = true;
				
				_contextMgr.blockModeSwitching = false;
				_contextMgr.enableInputFeedbackShowing(true);
				
				if (_btn_mutation == -1)
				{
					var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
					_btn_mutation = InputFeedbackManager.appendButton(this, isSwitchPlatform ? NavigationCode.GAMEPAD_X : NavigationCode.GAMEPAD_Y, KeyCode.C, "mutation_title_mutations");
					
				}
				if (_btn_switch_sections == -1 && InputManager.getInstance().gamepadType != EInputDeviceType.IDT_Switch2_Mouser)
				{
					_btn_switch_sections = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_R3, -1 , "panel_button_common_jump_sections");
				}
				InputFeedbackManager.updateButtons(this);
				
			}
		}
		
		protected function updateMutationPanelVisibility():void
		{
			GTweener.removeTweens(moduleSkillSlot);
			GTweener.removeTweens(mcMutationPanel);
			GTweener.removeTweens(mcMasterMutation);
			
			GTweener.removeTweens(mcBackgroundImage);
			
			if (mcMutationPanel.active)
			{
				txfPointsValue.visible = false;
				mcPointIcon.visible = false;
				mcPointsBorder.visible = false;
				mcRunewordIcon.visible = false;
				btnMutationMode.visible = false;
				mcMutationPanel.visible = true;
				mcMutationPanel.alpha = 0;
				mcRunewordIcon.alpha = 0;
				txfAvailablePoints.alpha = 0;
				
				//moduleSkillSlot.focused = 0;
				
				GTweener.to(moduleSkillSlot, .5, { alpha:0 }, { ease: Sine.easeOut } );
				GTweener.to(mcMasterMutation, .5, { alpha:0 }, { ease: Sine.easeOut } );
				GTweener.to(mcBackgroundImage, .5, { alpha:0 }, { ease: Sine.easeOut } );
				GTweener.to(mcMutationPanel, .5, { alpha:1 }, { ease: Sine.easeOut } );
			}
			else
			{
				
				GTweener.to(moduleSkillSlot, .5, { alpha:1 }, { ease: Sine.easeOut } );
				GTweener.to(mcMasterMutation, .5, { alpha:1 }, { ease: Sine.easeOut } );
				GTweener.to(mcBackgroundImage, .5, { alpha:1 }, { ease: Sine.easeOut } );
				GTweener.to(mcMutationPanel, .5, { alpha:0 }, { ease: Sine.easeOut, onComplete:handleMutationHidden } );
			}
		}
		
		protected function handleMutationHidden(tw:GTween = null):void
		{
			mcMutationPanel.visible = false;
			txfAvailablePoints.visible = true;
			mcPointsBorder.visible = true;
			btnMutationMode.visible = true;
			txfPointsValue.visible = true;
			mcPointIcon.visible = true;
			
			mcRunewordIcon.alpha = 1;
			txfAvailablePoints.alpha = 1;
		}
		
		protected function showFullStats():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnShowFullStats' ));
		}
		
		protected function onSlotSelected( event:ListEvent ):void
		{

		}

		// Start slot selection mode
		protected function handleSkillAction(event:SlotActionEvent):void
		{
			var targetSlot:SlotSkillGrid = event.targetSlot as SlotSkillGrid;
			var inventorySlot:SlotInventoryGrid = event.targetSlot as SlotInventoryGrid;
			
			//trace("GFX ## MenuCharacter :: handleSkillAction event.actionType ", event.actionType, "; targetSlot ", targetSlot);
			
			if (event.actionType == InventoryActionType.DROP)
			{
				// ignore drop action in character development
				return;
			}
			
			if (targetSlot)
			{
				if (targetSlot.data == null || targetSlot.isLocked || targetSlot.data.isCoreSkill || targetSlot.data.level == 0)
					return;
				
				if (moduleSkillSlot.hasSkillSlotUnlocked())
				{
					//skill
					startApplyMode(targetSlot);
				}
			}
			else if (inventorySlot && inventorySlot.data != null && moduleSkillSlot.hasMutagenSlotUnlocked() )
			{
				// mutagen
				startApplyMode(inventorySlot);
			}
		}

		// Equip / Unequp skill
		protected function handleSlotAction(event:SlotActionEvent):void
		{
			//trace("GFX --------- handleSlotAction,  is mut: ", (event.targetSlot as SlotSkillMutagen), applyMode.isActive());
			
			if ( applyMode.isActive() )
			{
				handleApplyModeAccept();
				return;
			}
			
			var mutSocket:SlotSkillMutagen = event.targetSlot as SlotSkillMutagen;
			if (mutSocket && !mutSocket.isLocked())
			{
				mutagenSlotAction(event.targetSlot as SlotSkillMutagen);
			}
			else
			{
				var skillSocket:SlotSkillSocket = event.targetSlot as SlotSkillSocket;
				if (event.targetSlot.data.skillPath != SlotSkillSocket.NULL_SKILL || applyMode.isActive())
				{
					skillSlotAction(event.targetSlot as SlotSkillGrid);
				}
				else if (skillSocket && skillSocket.data && !skillSocket.isLocked)
				{
					currentModuleIdx = 0;
				}
			}
		}

		// Upgrade skill
		protected function handleSkillSecondaryAction(event:SlotActionEvent):void
		{
			var targetSlot:SlotSkillGrid = event.targetSlot as SlotSkillGrid;
			
			//trace("GFX ## MenuCharacter :: handleSkillSecondaryAction event.actionType ", event.actionType, "; targetSlot ", targetSlot);
			
			if ( applyMode.isActive() )
			{
				handleApplyModeAccept();
				return;
			}
			
			if (targetSlot)
			{
				skillSlotSecondaryAction(targetSlot);
			}
			//else
			//{
				//mutagenSlotAction(event.targetSlot as SlotSkillMutagen);
			//}
		}

		protected function skillSlotAction(skillSlot:SlotSkillGrid):void
		{
			var slotData:Object = _cachedSlotData;
			var slotId:int = skillSlot.data.slotId;
			
			//trace("GFX ## MenuCharacter :: skillSlotAction");
			
			if (slotData && slotData.level == 0)
			{
				return;
			}
			
			if (applyMode.isActive())
			{
				var skillId:int = slotData.skillTypeId;
				endApplyMode();
				
				callEquipSkill(skillId, slotId);
			}
			else
			{
				changeHighlightSize(0.5);
				moveHighlightOverTreeSkill(skillSlot);
				callUnequipSkill(slotId);
			}
		}

		protected function skillSlotSecondaryAction(targetSlot:SlotSkillGrid):void
		{
			if (applyMode.isActive())
			{
				return;
			}
			
			if (targetSlot)
			{
				var targetData:Object = targetSlot.data;
				var upgradeAvailable:Boolean = targetData.level < targetData.maxLevel;
				var checkSkill:Boolean = upgradeAvailable && !targetData.notEnoughPoints && !targetSlot.isLocked;
				
				if(targetData.hasOwnProperty("isUsingSkillDependency") && targetData.isUsingSkillDependency)
				{
					checkSkill = checkSkill && targetData.hasRequiredSkillDependency;
				}

				if (targetData.notEnoughPoints)
				{
					callNotifyNotEnoughtPoints();
					return;
				}
				if (checkSkill)
				{
					callUpgradeSkill(targetData.skillTypeId);
					if (_pointsCount > 0)
					{
						changeHighlightSize(0.5);
						moveHighlightOverTreeSkill(targetSlot);
					}
				}
			}
		}

		protected function mutagenSlotAction(mutagenSlot:SlotSkillMutagen):void
		{
			//trace("GFX mutagenSlotAction ", applyMode.isActive());
			
			if (applyMode.isActive())
			{
				moveHighlightOverMutagenSlot(mutagenSlot);
				changeHighlightSize(0.5);
				callEquipMutagen(_cachedSlotData.id, mutagenSlot.slotType);
			}
			else
			{
				if (!mutagenSlot.isMutEquiped())
				{
					currentModuleIdx = 0;
				}
				else
				{
					changeHighlightSize(0.5);
					moveHighlightOverMutagenSlot(mutagenSlot);
					callUnequipMutagen(mutagenSlot.slotType);
				}
			}
		}
		
		protected function handleSlotActivate( event: SlotActionEvent ):void
		{
			var mutSlot:SlotSkillMutagen = event.target as SlotSkillMutagen;
			var skillSlot:SlotSkillSocket = event.target as SlotSkillSocket;
			
		}

		private function onSkillTappedTwice( event : Event ) : void
		{
			var selected : SlotBase = event.target.getSelectedRenderer() as SlotBase;
			trace( "MenuCharacterDupe::onSkillTappedTwice : ", mcDupeTabModule.isOpen, mcDupeTabModule.hasFocus, selected, event );

			//Since we disabled focus handling (mcPlayerGrid.focusable = false in super) We have to check if we are in focus manually.
			if ( mcDupeTabModule.isOpen &&  mcDupeTabModule.hasFocus && selected )
			{
				var selectedSkill : SlotSkillGrid = selected as SlotSkillGrid;
				if ( selectedSkill )
				{
					skillSlotSecondaryAction( selectedSkill );
				}
			}
		}

		private function onMutagenTappedTwice( event : Event ) : void
		{
			var selected : SlotBase = event.target.getSelectedRenderer() as SlotBase;
			trace( "MenuCharacterDupe::onMutagenTappedTwice : ", mcDupeTabModule.hasFocus, selected, event );

			//Since we disabled focus handling (mcPlayerGrid.focusable = false in super) We have to check if we are in focus manually.
			if ( mcDupeTabModule.hasFocus && selected )
			{
				var selectedMutagen : SlotInventoryGrid = selected as SlotInventoryGrid;
				if ( selectedMutagen )
				{
					trace( "MenuCharacter::onMutagenTappedTwice B");
					startApplyMode( selectedMutagen );
				}
			}
		}

		private function onSocketTappedTwice( event : Event ) : void
		{
			var selected : SlotBase = event.target.getSelectedRenderer() as SlotBase;
			trace( "MenuCharacterDupe::onSocketTappedTwice : ", moduleSkillSlot.hasFocus, selected, event );

			//Since we disabled focus handling (mcPlayerGrid.focusable = false in super) We have to check if we are in focus manually.
			if ( moduleSkillSlot.hasFocus && selected )
			{
				var mutSocket:SlotSkillMutagen = selected as SlotSkillMutagen;
				var skillSocket:SlotSkillSocket = selected as SlotSkillSocket;

				//We have to send a dummy event, so EVENT_SELECT will fire for the tab change
				if ( mutSocket || skillSocket )
				{
					selected.executeAction( KeyCode.PAD_A_CROSS, new InputEvent( "dummy", null ) );
				}
			}
		}

		public function handleApplyModeAccept( event : Event = null ) : void
		{
			var selectedSlot:IListItemRenderer = moduleSkillSlot.socketsList.getSelectedRenderer();
			var mutSlot:SlotSkillMutagen = selectedSlot as SlotSkillMutagen;
			var skillSlot:SlotSkillSocket = selectedSlot as SlotSkillSocket;
			var targetData:Object = applyMode.originalSlot.data;
			
			if (mutSlot)
			{
				moveHighlightOverMutagenSlot(mutSlot);
				changeHighlightSize(0.5);
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipMutagen', [uint(targetData.id), mutSlot.slotType] ) );
			}
			else
			if (skillSlot)
			{
				moveHighlightOverSocket(skillSlot);
				changeHighlightSize(0.5);
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipSkill', [uint(targetData.id), skillSlot.slotId] ));
			}
			
			endApplyMode();
		}

		public function handleApplyModeCancel( event : Event )
		{
			endApplyMode();
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnCancelApplyMode"));
		}

		public function handleTooltipFailedToShow( event : Event )
		{
			//moduleSkillSlot.fireFirstTooltip();
		}

		public function onBuyButtonClicked( event : ButtonEvent )
		{
			if (event.buttonIdx == 0) // #J Left click RAWR!
			{
				if (moduleSkillSlot.focused)
				{
					skillSlotSecondaryAction(moduleSkillSlot.socketsList.getSelectedRenderer() as SlotSkillGrid);
				}
				else
				{
					trace("GFX - These are not the modules you are looking for!");
				}
			}
		}

		protected function updateGroupsBonus(value:Array):void
		{
			moduleSkillSlot.setBonusData(value);
		}

		public function onPaperdollChanged():void
		{
			mcSlotChangeHighlight.gotoAndPlay("animation");
		}
		
		public function notifySkillUpgraded(skillType:int):void
		{

		}

		protected function stableUpdateSkillsGrid(value:Array):void
		{
			//moduleSkillList.stableUpdateData(value);

		}

		protected function updateSkillsGrid(value:Array):void
		{
			//moduleSkillList.handleListData(value, -1);
		}

		protected function updateSkillsSockets(value:Array):void
		{
			moduleSkillSlot.setData(value);
		}
		
		protected function updateSkillSocket(value:Object):void
		{
			moduleSkillSlot.updateSocket(value);
		}
		
		public function clearSkillSlot(slotId:int):void
		{
			moduleSkillSlot.clearSkillSlot(slotId);
		}

		protected function updateSkillMutagens(value:Array):void
		{
			moduleSkillSlot.setMutagensData(value);
		}

		protected function setSkillPoints(curPoint:int):void
		{
			_pointsCount = curPoint;
			mcDupeTabModule.pointsCount = curPoint;
			moduleSkillSlot.pointsCount = curPoint;
			txfAvailablePoints.text = "[[panel_character_availablepoints]]";
			txfPointsValue.text = curPoint.toString();
			txfAvailablePoints.text = CommonUtils.toUpperCaseSafe(txfAvailablePoints.text);
			txfAvailablePoints.x = txfPointsValue.x + txfPointsValue.width - txfPointsValue.textWidth - POINTS_AVAILABLE_GAP - txfAvailablePoints.width;
		}

		protected function callNotifyNotEnoughtPoints():void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnNotEnoughtPoints' ));
		}

		protected function callBuySkill(skillId:int, slotId:int):void
		{
			if (_pointsCount > 0)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnBuySkill', [skillId, slotId] ));
			}
		}

		protected function callEquipSkill(skillId:int, slotId:int):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipSkill', [skillId, slotId] ));

			if (applyMode.visible)
			{
				endApplyMode();
			}
		}

		protected function callUnequipSkill(slotId:int):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnUnequipSkill', [slotId] ));
		}

		protected function callUpgradeSkill(skillId:int):void
		{
			if (_pointsCount > 0)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnUpgradeSkill', [skillId] ));
				InputFeedbackManager.updateButtons(this);
			}
		}

		protected function callOpenMutagenList(slotType:int):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRequestMutagenList', [slotType] ));
		}

		protected function callEquipMutagen(itemID:uint, slotId:int):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnEquipMutagen', [itemID, slotId] ) );

			if (applyMode.visible)
			{
				endApplyMode();
			}
		}

		protected function callUnequipMutagen(slotType:int):void
		{
			trace("GFX call callUnequipMutagen ",slotType);
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnUnequipMutagen', [slotType] ));
		}

		protected function initDebugData():void
		{
			var testGridData:Array = [];

			var obj1 = { dropDownLabel:"cat1", skillType:"11", skillSubPath:"ESP_Sword" };
			var obj2 = { dropDownLabel:"cat1", skillType:"11", skillSubPath:"ESP_Sword" };
			var obj3 = { dropDownLabel:"cat1", skillType:"11", skillSubPath:"ESP_Sword" };
			testGridData.push(obj1);
			testGridData.push(obj2);
			testGridData.push(obj3);

			updateSkillsGrid(testGridData);
		}

		protected function debugTraceData(valuesList:Array):void
		{
			if (valuesList)
			{
				for (var i:int = 0; i < valuesList.length; i++)
				{
					if (valuesList[i].skillType != "S_Undefined")
						CommonUtils.traceObject(valuesList[i], "GFX [MUTAGENS] ");
				}
			}
		}

		public function /*WS*/ selectTabByColor(color:String):void
		{
			mcDupeTabModule.handleSelectTabByColor(color);
		}

		public function selectCurrentTabIcon():void
		{
			switch(mcDupeTabModule.mcTabList.selectedIndex)
			{
				case 0: selectTabByColor("SC_Red"); break;
				case 1: selectTabByColor("SC_Blue"); break;
				case 2: selectTabByColor("SC_Green"); break;
				case 3: selectTabByColor("SC_Yellow"); break;
			}
		}

		public function changeHighlightSize(ratio:Number)
		{
			mcSlotChangeHighlight.scaleX = mcSlotChangeHighlight.scaleY = ratio;
		}

		public function moveHighlightOverSocket(item:SlotSkillSocket)
		{
			var globalPos : Point = item.localToGlobal(new Point(32, 32));
			var highlightPos:Point = globalToLocal(globalPos);

			mcSlotChangeHighlight.x = highlightPos.x;
			mcSlotChangeHighlight.y = highlightPos.y;
		}

		public function moveHighlightOverMutagenSlot(item:SlotSkillMutagen)
		{
			var globalPos : Point = item.localToGlobal(new Point(35, 35));
			var highlightPos:Point = globalToLocal(globalPos);

			mcSlotChangeHighlight.x = highlightPos.x;
			mcSlotChangeHighlight.y = highlightPos.y;
		}

		public function moveHighlightOverTreeSkill(item:SlotSkillGrid)
		{
			var globalPos : Point = item.localToGlobal(new Point(32, 32));
			var highlightPos:Point = globalToLocal(globalPos);

			mcSlotChangeHighlight.x = highlightPos.x;
			mcSlotChangeHighlight.y =highlightPos.y;
		}
	}
}
