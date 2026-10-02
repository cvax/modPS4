package red.game.witcher3.menus.character_menu
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import red.core.constants.KeyCode;
	import red.core.CoreMenuModule;
	import red.game.witcher3.constants.InventorySlotType;
	import red.game.witcher3.constants.SkillColor;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.controls.W3Button;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotPaperdoll;
	import red.game.witcher3.slots.SlotSkillMutagen;
	import red.game.witcher3.slots.SlotSkillSocket;
	import red.game.witcher3.slots.SlotsListPreset;
	import red.game.witcher3.slots.SlotsListSkillSockets;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.Button;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.ui.InputDetails;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	public class ModuleSkillsSockets extends CoreMenuModule
	{
		public var gr1_socket1:SlotSkillSocket;
		public var gr1_socket2:SlotSkillSocket;
		public var gr1_socket3:SlotSkillSocket;
		public var gr1_mutagen:SlotSkillMutagen;
		
		public var gr2_socket1:SlotSkillSocket;
		public var gr2_socket2:SlotSkillSocket;
		public var gr2_socket3:SlotSkillSocket;
		public var gr2_mutagen:SlotSkillMutagen;
		
		public var gr3_socket1:SlotSkillSocket;
		public var gr3_socket2:SlotSkillSocket;
		public var gr3_socket3:SlotSkillSocket;
		public var gr3_mutagen:SlotSkillMutagen;
		
		public var gr4_socket1:SlotSkillSocket;
		public var gr4_socket2:SlotSkillSocket;
		public var gr4_socket3:SlotSkillSocket;
		public var gr4_mutagen:SlotSkillMutagen;
		
		public var bonusSocket1:SlotSkillSocket;
		public var bonusSocket2:SlotSkillSocket;
		public var bonusSocket3:SlotSkillSocket;
		public var bonusSocket4:SlotSkillSocket;
		
		public var groupConnector1:SkillSlotConnector;
		public var groupConnector2:SkillSlotConnector;
		public var groupConnector3:SkillSlotConnector;
		public var groupConnector4:SkillSlotConnector;
		
		public var connector_g1_s1:SkillSlotConnector;
		public var connector_g1_s2:SkillSlotConnector;
		public var connector_g1_s3:SkillSlotConnector;
		
		public var connector_g2_s1:SkillSlotConnector;
		public var connector_g2_s2:SkillSlotConnector;
		public var connector_g2_s3:SkillSlotConnector;
		
		public var connector_g3_s1:SkillSlotConnector;
		public var connector_g3_s2:SkillSlotConnector;
		public var connector_g3_s3:SkillSlotConnector;
		
		public var connector_g4_s1:SkillSlotConnector;
		public var connector_g4_s2:SkillSlotConnector;
		public var connector_g4_s3:SkillSlotConnector;
		
		public var dnaBranch1:MovieClip;
		public var dnaBranch2:MovieClip;
		public var dnaBranch3:MovieClip;
		public var dnaBranch4:MovieClip;
		
		public var txtBonus1_1:TextField;
		public var txtBonus2_1:TextField;
		public var txtBonus3_1:TextField;
		public var txtBonus4_1:TextField;

		public var txtBonus1_2:TextField;
		public var txtBonus2_2:TextField;
		public var txtBonus3_2:TextField;
		public var txtBonus4_2:TextField;

		public var txtBonus1_1p:TextField;
		public var txtBonus2_1p:TextField;
		public var txtBonus3_1p:TextField;
		public var txtBonus4_1p:TextField;

		public var txtBonus1_2p:TextField;
		public var txtBonus2_2p:TextField;
		public var txtBonus3_2p:TextField;
		public var txtBonus4_2p:TextField;
		
		protected var _group1:SkillSocketsGroup;
		protected var _group2:SkillSocketsGroup;
		protected var _group3:SkillSocketsGroup;
		protected var _group4:SkillSocketsGroup;
		
		public var groupBonusBkg1_1:MovieClip;
		public var groupBonusBkg2_1:MovieClip;
		public var groupBonusBkg3_1:MovieClip;
		public var groupBonusBkg4_1:MovieClip;

		public var groupBonusBkg1_2:MovieClip;
		public var groupBonusBkg2_2:MovieClip;
		public var groupBonusBkg3_2:MovieClip;
		public var groupBonusBkg4_2:MovieClip;
		
		public var socketsList:SlotsListSkillSockets;
		
		public var mcSlotChangeHighlight:MovieClip;
		
		private var _inputSymbolIDA:int = -1;
		private var _inputSymbolIDX:int = -1;
		
		private var _buySkillBtnRef:Button = null;
		private var _pointsCount:int = 0;
		protected var _hideInputFeedback:Boolean;
		
		private var _additionalSkillsMode:Boolean;
		
		private var _mutationMode:Boolean;
		
		public var mcSlotsMutation:MovieClip;
		public var mcSlotsNormal:MovieClip;
		
		
        public function set BuySkillBtnRef(value:Button):void {
			_buySkillBtnRef = value;
		}
		
		public function ModuleSkillsSockets()
		{
			mcSlotsMutation.visible = false;
			mcSlotsNormal.visible = true;
			
			updateActiveSockets();
		}
		
		private function repositionMutagenBonuses(value:Boolean):void
		{
			if (value)//NORMAL MODE
			{
				groupBonusBkg1_1.y = -75;
				groupBonusBkg2_1.y = -75;
				groupBonusBkg3_1.y = 285.15;
				groupBonusBkg4_1.y = 285.15;
				
				groupBonusBkg1_2.y = 135.15;
				groupBonusBkg2_2.y = 135.15;
				groupBonusBkg3_2.y = 495;
				groupBonusBkg4_2.y = 495;
				
				txtBonus1_1.y = -54.6;
				txtBonus2_1.y = -54.6;
				txtBonus3_1.y = 305.1;
				txtBonus4_1.y = 305.1;

				txtBonus1_2.y = 155.55;
				txtBonus2_2.y = 155.55;
				txtBonus3_2.y = 515.4;
				txtBonus4_2.y = 515.4;
			}
			else//MUTATION MODE
			{
				groupBonusBkg1_1.y = -138;
				groupBonusBkg2_1.y = -138;
				groupBonusBkg3_1.y = 349;   
				groupBonusBkg4_1.y = 349;

				groupBonusBkg1_2.y = 91;
				groupBonusBkg2_2.y = 91;
				groupBonusBkg3_2.y = 577;   
				groupBonusBkg4_2.y = 577;
				
				txtBonus1_1.y = -117.6;
				txtBonus2_1.y = -117.6;
				txtBonus3_1.y = 369.4;
				txtBonus4_1.y = 369.4;

				txtBonus1_2.y = 111.4;
				txtBonus2_2.y = 111.4;
				txtBonus3_2.y = 597.4;
				txtBonus4_2.y = 597.4;
			}
		}
		
		private var _currentContainer:MovieClip;
		private function updateActiveSockets():void
		{
			var currentContainer:MovieClip = mcSlotsNormal.visible ? mcSlotsNormal : mcSlotsMutation;
			repositionMutagenBonuses( mcSlotsNormal.visible );
			// trace("GFX updateActiveSockets ", currentContainer, mcSlotsNormal, mcSlotsMutation);
			
			if (_currentContainer != currentContainer)
			{
				_currentContainer = currentContainer
				
				bonusSocket1 = currentContainer.bonusSocket1;
				bonusSocket2 = currentContainer.bonusSocket2;
				bonusSocket3 = currentContainer.bonusSocket3;
				bonusSocket4 = currentContainer.bonusSocket4;
				
				gr1_socket1 = currentContainer.gr1_socket1;
				gr1_socket2 = currentContainer.gr1_socket2;
				gr1_socket3 = currentContainer.gr1_socket3;
				
				gr2_socket1 = currentContainer.gr2_socket1;
				gr2_socket2 = currentContainer.gr2_socket2;
				gr2_socket3 = currentContainer.gr2_socket3;
				
				gr3_socket1 = currentContainer.gr3_socket1;
				gr3_socket2 = currentContainer.gr3_socket2;
				gr3_socket3 = currentContainer.gr3_socket3;
				
				gr4_socket1 = currentContainer.gr4_socket1;
				gr4_socket2 = currentContainer.gr4_socket2;
				gr4_socket3 = currentContainer.gr4_socket3;
				
				gr1_mutagen = currentContainer.gr1_mutagen;
				gr2_mutagen = currentContainer.gr2_mutagen;
				gr3_mutagen = currentContainer.gr3_mutagen;
				gr4_mutagen = currentContainer.gr4_mutagen;
				
				connector_g1_s1 = currentContainer.connector_g1_s1;
				connector_g1_s2 = currentContainer.connector_g1_s2;
				connector_g1_s3 = currentContainer.connector_g1_s3;
				groupConnector1 = currentContainer.groupConnector1;
				
				connector_g2_s1 = currentContainer.connector_g2_s1;
				connector_g2_s2 = currentContainer.connector_g2_s2;
				connector_g2_s3 = currentContainer.connector_g2_s3;
				groupConnector2 = currentContainer.groupConnector2;
				
				connector_g3_s1 = currentContainer.connector_g3_s1;
				connector_g3_s2 = currentContainer.connector_g3_s2;
				connector_g3_s3 = currentContainer.connector_g3_s3;
				groupConnector3 = currentContainer.groupConnector3;
				
				connector_g4_s1 = currentContainer.connector_g4_s1;
				connector_g4_s2 = currentContainer.connector_g4_s2;
				connector_g4_s3 = currentContainer.connector_g4_s3;
				groupConnector4 = currentContainer.groupConnector4;
				
				initGroups();
			}
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			socketsList.slotContainer = mcSlotsNormal;
			socketsList.addEventListener( ListEvent.INDEX_CHANGE, OnSkillTreeClicked, false, 0, true );
			socketsList.focusable = false;
			socketsList.enableTouch(true);
			
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			
			bonusSocket1.visible  = bonusSocket1.selectable = false;
			bonusSocket2.visible  = bonusSocket2.selectable = false;
			bonusSocket3.visible  = bonusSocket3.selectable = false;
			bonusSocket4.visible  = bonusSocket4.selectable = false;
		}
		
		protected function OnSkillTreeClicked( event:ListEvent ):void
		{
			UpdateSelectedItemInputFeedback();
		}
		
		public function get pointsCount():int { return _pointsCount }
		public function set pointsCount(value:int):void
		{
			_pointsCount = value;
		}
		
		public function updateSocket(value:Object):void
		{
			socketsList.updateSpecificData(value);
			UpdateSelectedItemInputFeedback();
		}
		
		public function clearSkillSlot(slotId:int):void
		{
			socketsList.clearSkillSlot(slotId);
			UpdateSelectedItemInputFeedback();
		}
		
		protected function UpdateSelectedItemInputFeedback():void
		{
			var selectedSlot:SlotBase = socketsList.getSelectedRenderer() as SlotBase;
			var isLocked:Boolean;
			var skillSlot:SlotSkillSocket = selectedSlot as SlotSkillSocket;
			var mutagenSlot:SlotSkillMutagen = selectedSlot as SlotSkillMutagen;
			
			if (skillSlot)
			{
				isLocked = skillSlot.isLocked;
			}
			else
			if (mutagenSlot)
			{
				isLocked = mutagenSlot.isLocked();
			}
			else
			{
				isLocked = false;
			}
			
			if (_inputSymbolIDA != -1)
			{
				InputFeedbackManager.removeButton(this, _inputSymbolIDA);
				_inputSymbolIDA = -1;
			}
			
			if (_inputSymbolIDX != -1)
			{
				InputFeedbackManager.removeButton(this, _inputSymbolIDX);
				_inputSymbolIDX = -1;
				
				if (_buySkillBtnRef) _buySkillBtnRef.enabled = false;
			}
			
			if (_hideInputFeedback)
			{
				InputFeedbackManager.updateButtons(this);
				return;
			}
			
			if (_focused && selectedSlot)
			{
				if (mutagenSlot)
				{
					if (mutagenSlot.isMutEquiped())
					{
						_inputSymbolIDA = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.SPACE, "panel_character_slot_remove_skill");
					}
					else
					if (!mutagenSlot.isLocked())
					{
						_inputSymbolIDA = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.SPACE, "panel_button_common_select");
					}
				}
				else
				if (selectedSlot.data != null && selectedSlot.data.skillPath != SlotSkillSocket.NULL_SKILL )
				{
					_inputSymbolIDA = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.SPACE, "panel_character_slot_remove_skill");
					
					if (!selectedSlot.data.isMutagen && selectedSlot.data.level < selectedSlot.data.maxLevel)
					{
						var text:String = selectedSlot.data.level == 0 ? "panel_character_popup_title_buy_skill" : "panel_character_popup_title_upgrade_skill";
						var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

						_inputSymbolIDX = InputFeedbackManager.appendButton(this, isSwitchPlatform ? NavigationCode.GAMEPAD_Y : NavigationCode.GAMEPAD_X, KeyCode.E, text);
						
						if (_buySkillBtnRef)
						{
							_buySkillBtnRef.label = text;
							_buySkillBtnRef.enabled = true;
						}
					}
				}
				else
				if (!isLocked && selectedSlot.data != null)
				{
					_inputSymbolIDA = InputFeedbackManager.appendButton(this, NavigationCode.GAMEPAD_A, KeyCode.SPACE, "panel_button_common_select");
				}
			}
			
			InputFeedbackManager.updateButtons(this);
		}
		
		override public function set focused(value:Number):void
		{
			super.focused = value;
			UpdateSelectedItemInputFeedback();
			updateActiveSelectionEnabled();
		}
		
		public function get additionalSkillsMode():Boolean { return _additionalSkillsMode; }
		public function set additionalSkillsMode(value:Boolean):void
		{
			_additionalSkillsMode = value;
			
			/*
			gr1_mutagen.visible = gr1_mutagen.selectable = !_additionalSkillsMode;
			gr2_mutagen.visible = gr2_mutagen.selectable = !_additionalSkillsMode;
			gr3_mutagen.visible = gr3_mutagen.selectable = !_additionalSkillsMode;
			gr4_mutagen.visible = gr4_mutagen.selectable = !_additionalSkillsMode;
			*/
		}
		
		public function get mutationMode():Boolean { return _mutationMode; }
		public function set mutationMode(value:Boolean):void
		{
			_mutationMode = value;
			
			if (_mutationMode)
			{
				socketsList.slotContainer = mcSlotsMutation;
				mcSlotsNormal.mouseChildren = mcSlotsNormal.mouseEnabled =  mcSlotsNormal.visible = false;
				mcSlotsMutation.mouseChildren = mcSlotsMutation.mouseEnabled = mcSlotsMutation.visible = true;
				
			}
			else
			{
				socketsList.slotContainer = mcSlotsNormal;
				mcSlotsNormal.mouseChildren = mcSlotsNormal.mouseEnabled =  mcSlotsNormal.visible = true;
				mcSlotsMutation.mouseChildren = mcSlotsMutation.mouseEnabled = mcSlotsMutation.visible = false;
			}
			
			bonusSocket1.visible = bonusSocket1.selectable = _mutationMode;
			bonusSocket2.visible = bonusSocket2.selectable = _mutationMode;
			bonusSocket3.visible = bonusSocket3.selectable = _mutationMode;
			bonusSocket4.visible = bonusSocket4.selectable = _mutationMode;
			
			updateActiveSockets();
		}
		
		public function get hideInputFeedback():Boolean { return _hideInputFeedback; }
		public function set hideInputFeedback(value:Boolean):void
		{
			_hideInputFeedback = value;
			UpdateSelectedItemInputFeedback();
		}
		
		public function setData(listValues:Array):void
		{
			trace("GFX MSS ------------------------------------- setData --------------------------------- ");
			socketsList.data = listValues;
			socketsList.validateNow();
			updateActiveSelectionEnabled();
			
			removeEventListener(Event.ENTER_FRAME, validateSelection, false );
			addEventListener(Event.ENTER_FRAME, validateSelection, false, 0, true);
		}
		
		private function validateSelection(event:Event):void
		{
			trace("GFX ------------------------------------- validateSelection --------------------------------- ");
			
			removeEventListener(Event.ENTER_FRAME, validateSelection, false );
			socketsList.validateNow();
			socketsList.selectedIndex = mcSlotsNormal.visible ? 3 : 19;
		}
		
		protected function updateActiveSelectionEnabled():void
		{
			var currentSlot:SlotBase;
			
			for (var i:int = 0; i < socketsList.getRenderersCount(); ++i)
			{
				currentSlot = socketsList.getRendererAt(i) as SlotBase;
				
				if (currentSlot)
				{
					currentSlot.activeSelectionEnabled = focused != 0;
				}
			}
		}
		
		public function hasSkillSlotUnlocked():Boolean
		{
			var currentSlot:SlotSkillSocket;
			
			for (var i:int = 0; i < socketsList.getRenderersCount(); ++i)
			{
				currentSlot = socketsList.getRendererAt(i) as SlotSkillSocket;
				
				if (currentSlot && !currentSlot.isLocked)
				{
					return true;
				}
			}
			
			return false;
		}
		
		public function hasMutagenSlotUnlocked():Boolean
		{
			var currentSlot:SlotSkillMutagen;
			
			for (var i:int = 0; i < socketsList.getRenderersCount(); ++i)
			{
				currentSlot = socketsList.getRendererAt(i) as SlotSkillMutagen;
				
				if (currentSlot && !currentSlot.isLocked())
				{
					return true;
				}
			}
			
			return false;
		}

		private function getTxtBonusPrimary( groupIndex:int):TextField
		{
			switch(groupIndex)
			{
				case 1: return txtBonus1_1;
				case 2: return txtBonus2_1;
				case 3: return txtBonus3_1;
				case 4: return txtBonus4_1;
				default: return txtBonus1_1;
			}
		}

		private function getTxtBonusSecondary( groupIndex:int):TextField
		{
			switch(groupIndex)
			{
				case 1: return txtBonus1_2;
				case 2: return txtBonus2_2;
				case 3: return txtBonus3_2;
				case 4: return txtBonus4_2;
				default: return txtBonus1_2;
			}
		}

		private function getTxtBonusPrimaryValue( groupIndex:int):TextField
		{
			switch(groupIndex)
			{
				case 1: return txtBonus1_1p;
				case 2: return txtBonus2_1p;
				case 3: return txtBonus3_1p;
				case 4: return txtBonus4_1p;
				default: return txtBonus1_1p;
			}
		}

		private function getTxtBonusSecondaryValue( groupIndex:int):TextField
		{
			switch(groupIndex)
			{
				case 1: return txtBonus1_2p;
				case 2: return txtBonus2_2p;
				case 3: return txtBonus3_2p;
				case 4: return txtBonus4_2p;
				default: return txtBonus1_2p;
			}
		}

		private function getGroupBonusBkgPrimary( groupIndex:int):MovieClip
		{
			switch(groupIndex)
			{
				case 1: return groupBonusBkg1_1;
				case 2: return groupBonusBkg2_1;
				case 3: return groupBonusBkg3_1;
				case 4: return groupBonusBkg4_1;
				default: return groupBonusBkg1_1;
			}
		}

		private function getGroupBonusBkgSecondary( groupIndex:int):MovieClip
		{
			switch(groupIndex)
			{
				case 1: return groupBonusBkg1_2;
				case 2: return groupBonusBkg2_2;
				case 3: return groupBonusBkg3_2;
				case 4: return groupBonusBkg4_2;
				default: return groupBonusBkg1_2;
			}
		}

		private function getPrimaryColor( groupIndex:int, listValues:Array):String
		{
			if(listValues[groupIndex - 1].color == SkillColor.nameToEnum("SC_RedBlue"))
				return "SC_Red";
			else if(listValues[groupIndex - 1].color == SkillColor.nameToEnum("SC_RedGreen"))
				return "SC_Red";
			else if(listValues[groupIndex - 1].color == SkillColor.nameToEnum("SC_BlueGreen"))
				return "SC_Blue";
			else if(listValues[groupIndex - 1].color == SkillColor.nameToEnum("SC_RedWhite"))
				return "SC_Red";
			else if(listValues[groupIndex - 1].color == SkillColor.nameToEnum("SC_GreenWhite"))
				return "SC_Green";
			else if(listValues[groupIndex - 1].color == SkillColor.nameToEnum("SC_BlueWhite"))
				return "SC_Blue";
			return SkillColor.enumToName(listValues[groupIndex - 1].color);
		}

		private function getSecondaryColor( groupIndex:int, listValues:Array):String
		{
			if(listValues[groupIndex - 1].color == SkillColor.nameToEnum("SC_RedBlue"))
				return "SC_Blue";
			else if(listValues[groupIndex - 1].color == SkillColor.nameToEnum("SC_RedGreen"))
				return "SC_Green";
			else if(listValues[groupIndex - 1].color == SkillColor.nameToEnum("SC_BlueGreen"))
				return "SC_Green";
			else if(listValues[groupIndex - 1].color == SkillColor.nameToEnum("SC_RedWhite"))
				return "SC_Yellow";
			else if(listValues[groupIndex - 1].color == SkillColor.nameToEnum("SC_GreenWhite"))
				return "SC_Yellow";
			else if(listValues[groupIndex - 1].color == SkillColor.nameToEnum("SC_BlueWhite"))
				return "SC_Yellow";
			return "SC_None";
		}

		private function splitBonusDescription(description : String):Array
		{
			var index:int = description.indexOf(",");

			if(index == -1)
			{
				return [description, ""];
			}
			return [description.substring(0,index),description.substring(index + 1)];
		}

		private function getTextWidth(txt:TextField):Number
		{
			//txt.autoSize = TextFieldAutoSize.LEFT;
			return txt.textWidth;
		}

		private function resizeText(bg:MovieClip, txt:TextField, autoSize:String = TextFieldAutoSize.LEFT):void
		{
			txt.autoSize = autoSize;

			// handling breaking into more lines if text's too big
			if(txt.textWidth > txt.width)
				txt.height = txt.textHeight;
			else txt.height = 31.35;

			centerTextToBackground(bg,txt);
		}

		private function centerTextToBackground( bg:MovieClip, txt:TextField ):void
		{
			txt.y = bg.y + (bg.height - txt.height) / 2 + 2;
		}

		private function setBonusDataIndividual( groupIndex:int, listValues:Array):void
		{
			var MAX_DEFINED_WIDTH = 200;

			var desc:Array = splitBonusDescription( listValues[groupIndex - 1].description );
			var desc_1:String = desc[0];
			var desc_2:String = desc[1];

			var vals:Array = splitBonusDescription( listValues[groupIndex - 1].values );
			var val_1:String = vals[0];
			var val_2:String = vals[1];

			var color_1:String = getPrimaryColor(groupIndex, listValues);
			var color_2:String = getSecondaryColor(groupIndex, listValues);
			
			var txtPrimary : TextField = getTxtBonusPrimary(groupIndex);
			var txtSecondary : TextField = getTxtBonusSecondary(groupIndex);

			var txtPrimaryValue : TextField = getTxtBonusPrimaryValue(groupIndex);
			var txtSecondaryValue : TextField = getTxtBonusSecondaryValue(groupIndex);

			{ // resizing the description text field so it does not overlap with the value
				txtPrimaryValue.htmlText = val_1;
				txtPrimary.width = (txtPrimaryValue.x + txtPrimaryValue.width - getTextWidth(txtPrimaryValue) - 10) - txtPrimary.x;
				if(txtPrimary.width > MAX_DEFINED_WIDTH)
					txtPrimary.width = MAX_DEFINED_WIDTH;
			}
			{
				txtSecondaryValue.htmlText = val_2;
				txtSecondary.width = (txtSecondaryValue.x + txtSecondaryValue.width - getTextWidth(txtSecondaryValue) - 10) - txtSecondary.x;
				if(txtSecondary.width > MAX_DEFINED_WIDTH)
					txtSecondary.width = MAX_DEFINED_WIDTH;
			}

			txtPrimary.htmlText = desc_1;
			txtSecondary.htmlText = desc_2;

			txtPrimaryValue.htmlText = val_1;
			txtSecondaryValue.htmlText = val_2;

			getGroupBonusBkgPrimary(groupIndex).gotoAndStop( color_1 );
			getGroupBonusBkgSecondary(groupIndex).gotoAndStop( color_2 );
		}
		
		public function setBonusData(listValues:Array):void
		{
			trace("GFX - listValues", listValues);

			setBonusDataIndividual( 1, listValues );
			setBonusDataIndividual( 2, listValues );
			setBonusDataIndividual( 3, listValues );
			setBonusDataIndividual( 4, listValues );
						
			resizeText(groupBonusBkg1_1, txtBonus1_1);
			resizeText(groupBonusBkg1_2, txtBonus1_2);
			resizeText(groupBonusBkg2_1, txtBonus2_1, TextFieldAutoSize.RIGHT);
			resizeText(groupBonusBkg2_2, txtBonus2_2, TextFieldAutoSize.RIGHT);
			resizeText(groupBonusBkg3_1, txtBonus3_1);
			resizeText(groupBonusBkg3_2, txtBonus3_2);
			resizeText(groupBonusBkg4_1, txtBonus4_1, TextFieldAutoSize.RIGHT);
			resizeText(groupBonusBkg4_2, txtBonus4_2, TextFieldAutoSize.RIGHT);

			resizeText(groupBonusBkg1_1, txtBonus1_1p, TextFieldAutoSize.RIGHT);
			resizeText(groupBonusBkg1_2, txtBonus1_2p, TextFieldAutoSize.RIGHT);
			resizeText(groupBonusBkg2_1, txtBonus2_1p, TextFieldAutoSize.RIGHT);
			resizeText(groupBonusBkg2_2, txtBonus2_2p, TextFieldAutoSize.RIGHT);
			resizeText(groupBonusBkg3_1, txtBonus3_1p, TextFieldAutoSize.RIGHT);
			resizeText(groupBonusBkg3_2, txtBonus3_2p, TextFieldAutoSize.RIGHT);
			resizeText(groupBonusBkg4_1, txtBonus4_1p, TextFieldAutoSize.RIGHT);
			resizeText(groupBonusBkg4_2, txtBonus4_2p, TextFieldAutoSize.RIGHT);

			/*
			txtBonus1_1.htmlText = listValues[0].description;
			txtBonus2_1.htmlText = listValues[1].description;
			txtBonus3_1.htmlText = listValues[2].description;
			txtBonus4_1.htmlText = listValues[3].description;
			
			groupBonusBkg1_1.gotoAndStop( SkillColor.enumToName( listValues[0].color ) );
			groupBonusBkg2_1.gotoAndStop( SkillColor.enumToName( listValues[1].color ) );
			groupBonusBkg3_1.gotoAndStop( SkillColor.enumToName( listValues[2].color ) );
			groupBonusBkg4_1.gotoAndStop( SkillColor.enumToName( listValues[3].color ) );
			*/
		}
		
		public function setMutagensData(listValues:Array):void
		{
			var len:int = listValues.length;
			for (var i:int = 0; i < len; i++)
			{
				var curData:Object = listValues[i];
				trace("GFX setMutagensData --------------------------------------------------------------------------------------------------------------------");
				switch (curData.slotId)
				{
					case InventorySlotType.SkillMutagen1:
						trace("GFX -",_group1," updating Mutagen 1 with unlocked: " + curData.unlocked + ", and other data:" + curData + "; color " + curData.color);
						_group1.mutagenData = curData;
						break;
					case InventorySlotType.SkillMutagen2:
						trace("GFX - -",_group2,"updating Mutagen 2 with unlocked: " + curData.unlocked + ", and other data:" + curData + "; color " + curData.color);
						_group2.mutagenData = curData;
						break;
					case InventorySlotType.SkillMutagen3:
						trace("GFX - -",_group3,"updating Mutagen 3 with unlocked: " + curData.unlocked + ", and other data:" + curData + "; color " + curData.color);
						_group3.mutagenData = curData;
						break;
					case InventorySlotType.SkillMutagen4:
						trace("GFX --",_group4," updating Mutagen 4 with unlocked: " + curData.unlocked + ", and other data:" + curData + "; color " + curData.color);
						_group4.mutagenData = curData;
						break;
				}
			}
			UpdateSelectedItemInputFeedback();
		}
		
		override public function handleInput(event:InputEvent):void
		{
			var details:InputDetails = event.details;
			CommonUtils.fixupKeyCode( details );

			if (!focused)
			{
				return;
			}
			if (!event.handled)
			{
				socketsList.handleInputPreset(event);
				socketsList.handleInput(event); // #Y Hack to execute default action
			}
		}
		
		public function disableMutagens(value:Boolean):void
		{
			gr1_mutagen.enabled = !value;
			gr2_mutagen.enabled = !value;
			gr3_mutagen.enabled = !value;
			gr4_mutagen.enabled = !value;
		}
		
		public function SetUnselectableLockedAndMutagens(colorName:String):void
		{
			var i:int;
			var slot:SlotBase;
			
			for (i = 0; i < socketsList.getRenderersLength(); ++i)
			{
				slot = socketsList.getRendererAt(i) as SlotBase;
				
				if (slot)
				{
					var curSkillSlot:SlotSkillSocket = slot as SlotSkillSocket;
					
					if (curSkillSlot)
					{
						if (curSkillSlot.isLocked)
						{
							slot.selectable = false;
						}
						else
						if (colorName && curSkillSlot.data && curSkillSlot.data.colorBorder)
						{
							// filter by color
							
							const COLOR_PREFIX_LEN:int = 3;
							
							var curSkillData:Object = curSkillSlot.data;
							var colorPureName:String = colorName.substr(COLOR_PREFIX_LEN).toUpperCase();
							var allowedColors:String = curSkillSlot.data.colorBorder.toUpperCase();
							
							if (allowedColors.indexOf(colorPureName) < 0 )
							{
								slot.selectable = false;
							}
							
						}
					}
					else if (slot is SlotSkillMutagen)
					{
						slot.selectable = false;
					}
				}
			}
		}
		
		public function disableNonMutagensAndLocked():void
		{
			var i:int;
			var slot:SlotBase;
			
			for (i = 0; i < socketsList.getRenderersLength(); ++i)
			{
				slot = socketsList.getRendererAt(i) as SlotBase;
				
				if (slot)
				{
					if (slot is SlotSkillSocket)
					{
						slot.selectable = false;
					}
					else if (slot is SlotSkillMutagen && (slot as SlotSkillMutagen).isLocked())
					{
						slot.selectable = false;
					}
				}
			}
		}
		
		public function SetAllSelectable():void
		{
			var i:int;
			var slot:SlotBase;
			
			for (i = 0; i < socketsList.getRenderersLength(); ++i)
			{
				slot = socketsList.getRendererAt(i) as SlotBase;
				
				if (slot)
				{
					slot.selectable = slot.visible;
				}
			}
		}
		
		public function setSelectionMode(value:Boolean):void
		{
			var curSlot:SlotPaperdoll;
			
			for (var i:int = 0; i < socketsList.getRenderersLength(); ++i)
			{
				curSlot = socketsList.getRendererAt(i) as SlotPaperdoll;
				
				if (curSlot)
				{
					curSlot.selectionMode = value;
				}
			}
		}
		
		protected function initGroups():void
		{
			trace("GFX ---------------------------------------------- initGroups ");
			
			_group1 = new SkillSocketsGroup();
			_group1.dnaBranch = dnaBranch1;
			_group1.connector = groupConnector1;
			_group1.mutagenSlot = gr1_mutagen;
			_group1.addSlotConnector(connector_g1_s1);
			_group1.addSlotConnector(connector_g1_s2);
			_group1.addSlotConnector(connector_g1_s3);
			_group1.addSlotSkillRef(gr1_socket1);
			_group1.addSlotSkillRef(gr1_socket2);
			_group1.addSlotSkillRef(gr1_socket3);
			
			gr1_socket1.skillSocketGroupRef = _group1;
			gr1_socket2.skillSocketGroupRef = _group1;
			gr1_socket3.skillSocketGroupRef = _group1;
			
			_group2 = new SkillSocketsGroup();
			_group2.dnaBranch = dnaBranch2;
			_group2.connector = groupConnector2;
			_group2.mutagenSlot = gr2_mutagen;
			_group2.addSlotConnector(connector_g2_s1);
			_group2.addSlotConnector(connector_g2_s2);
			_group2.addSlotConnector(connector_g2_s3);
			_group2.addSlotSkillRef(gr2_socket1);
			_group2.addSlotSkillRef(gr2_socket2);
			_group2.addSlotSkillRef(gr2_socket3);
			gr2_socket1.skillSocketGroupRef = _group2;
			gr2_socket2.skillSocketGroupRef = _group2;
			gr2_socket3.skillSocketGroupRef = _group2;
			
			_group3 = new SkillSocketsGroup();
			_group3.dnaBranch = dnaBranch3;
			_group3.connector = groupConnector3;
			_group3.mutagenSlot = gr3_mutagen;
			_group3.addSlotConnector(connector_g3_s1);
			_group3.addSlotConnector(connector_g3_s2);
			_group3.addSlotConnector(connector_g3_s3);
			_group3.addSlotSkillRef(gr3_socket1);
			_group3.addSlotSkillRef(gr3_socket2);
			_group3.addSlotSkillRef(gr3_socket3);
			gr3_socket1.skillSocketGroupRef = _group3;
			gr3_socket2.skillSocketGroupRef = _group3;
			gr3_socket3.skillSocketGroupRef = _group3;
			
			_group4 = new SkillSocketsGroup();
			_group4.dnaBranch = dnaBranch4;
			_group4.connector = groupConnector4;
			_group4.mutagenSlot = gr4_mutagen;
			_group4.addSlotConnector(connector_g4_s1);
			_group4.addSlotConnector(connector_g4_s2);
			_group4.addSlotConnector(connector_g4_s3);
			_group4.addSlotSkillRef(gr4_socket1);
			_group4.addSlotSkillRef(gr4_socket2);
			_group4.addSlotSkillRef(gr4_socket3);
			gr4_socket1.skillSocketGroupRef = _group4;
			gr4_socket2.skillSocketGroupRef = _group4;
			gr4_socket3.skillSocketGroupRef = _group4;
			
			gr1_mutagen.cleanup();
			gr2_mutagen.cleanup();
			gr3_mutagen.cleanup();
			gr4_mutagen.cleanup();
		}
	}

}
