/***********************************************************************
/** 
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.mainmenu
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.events.GestureEvent;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.CoreMenuModule;
	import red.core.CoreComponent;
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.menus.common.W3SubMenuListItemRenderer;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.ScrollBar;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.MouseEventEx;
	import red.game.witcher3.utils.CommonUtils;
	import flash.events.TransformGestureEvent;
	import scaleform.clik.managers.FocusHandler;
	
	public class OptionListModule extends CoreMenuModule
	{
		private static const ACTION_DOWNLOAD : uint = 66;

		public var mcPresetOption : MovieClip;
		
		public var mcOptionList : W3ScrollingList;
		public var mcOptionListItem1 : W3SubMenuListItemRenderer;
		public var mcOptionListItem2 : W3SubMenuListItemRenderer;
		public var mcOptionListItem3 : W3SubMenuListItemRenderer;
		public var mcOptionListItem4 : W3SubMenuListItemRenderer;
		public var mcOptionListItem5 : W3SubMenuListItemRenderer;
		public var mcOptionListItem6 : W3SubMenuListItemRenderer;
		public var mcOptionListItem7 : W3SubMenuListItemRenderer;
		public var mcOptionListItem8 : W3SubMenuListItemRenderer;
		public var mcOptionListItem9 : W3SubMenuListItemRenderer;
		public var optionListItems : Array;
		
		protected var mcPresetList : W3ScrollingList;
		public var mcScrollingListItem1 : W3MenuListItemRenderer;
		public var mcScrollingListItem2 : W3MenuListItemRenderer;
		public var mcScrollingListItem3 : W3MenuListItemRenderer;
		public var mcScrollingListItem4 : W3MenuListItemRenderer;
		public var mcScrollingListItem5 : W3MenuListItemRenderer;
		public var mcScrollingListItem6 : W3MenuListItemRenderer;
		public var mcScrollingListItem7 : W3MenuListItemRenderer;

		public var tooltip : MovieClip;
		public var mcTelemetryDataRequestPopup : TelemetryDataRequestPopup;
		public var mcTelemetrySpinner : MovieClip;

		public var mcOptionScrollbar : ScrollBar;
		protected var txtPresetTitle : TextField;
		public var txtOptionDescription : TextField;
		public var optionListData : Array;
		protected var itemsX : Number;
		protected var currentPresetGroupName : uint;

		protected var presetSelected : Boolean = false;
		protected var presetsEnabled : Boolean = false;
		public var _lastMoveWasMouse:Boolean = false;
		private var _panYAccumulator : Number = 0;
		protected var _lastMouseOveredPresetItem:int = -1;
		protected var _lastMouseOveredOptionItem:int = -1;
		protected var _mouseIsDown:Boolean = false;
		protected var _disableStateChanged:Boolean = false;
		private var _isFakeMouseUpEvent:Boolean = false;
		
		public function showTelemetryDataRequestPopup( qrBufferId : String, description : String, url : String ) : void
		{
			var ingameMenu : IngameMenu = parent as IngameMenu;
			ingameMenu.showMainMenuButtonPanel( false );

			mcTelemetryDataRequestPopup.addEventListener( TelemetryDataRequestPopup.EVENT_CLOSE, onTelemetryDataRequestClose, false, 0, true );
			mcTelemetryDataRequestPopup.setData( qrBufferId, description, url );
			mcTelemetryDataRequestPopup.visible = true;
		}
		
		private function onTelemetryDataRequestClose( ) : void
		{
			mcTelemetryDataRequestPopup.visible = false;
			mcTelemetryDataRequestPopup.removeEventListener( TelemetryDataRequestPopup.EVENT_CLOSE, onTelemetryDataRequestClose );

			var ingameMenu : IngameMenu = parent as IngameMenu;
			ingameMenu.showMainMenuButtonPanel( true );
		}

		private function onShowSpinner( show : Boolean ) : void
		{
			mcTelemetrySpinner.tfLoadingText.text = "[[panel_telemetry_processing]]";
			mcTelemetrySpinner.visible = show;
		}

		public function get lastMoveWasMouse():Boolean 
		{ 
			return _lastMoveWasMouse; 
		}

		public function set lastMoveWasMouse(value:Boolean):void
		{
			_lastMoveWasMouse = value;
			
			if (_lastMoveWasMouse)
			{
				if (_lastMouseOveredPresetItem != -1)
				{
					presetSelected = true;
					mcPresetList.selectedIndex = _lastMouseOveredPresetItem;
					mcOptionList.selectedIndex = -1;
				}
				else if (_lastMouseOveredOptionItem != -1)
				{
					presetSelected = false;
					mcPresetList.selectedIndex = -1;
					mcOptionList.selectedIndex = mcOptionList.getRendererAt(_lastMouseOveredOptionItem, mcOptionList.scrollPosition).index;
				}
			}
			else
			{
				if (mcOptionList.selectedIndex == -1 && mcPresetList.selectedIndex == -1)
				{
					presetSelected = false;
					mcOptionList.selectedIndex = 0;
				}
			}

			_lastMouseOveredPresetItem = -1;
			_lastMouseOveredOptionItem = -1;
			
			// for (var i:int = 0; i < optionListItems.length; ++i)
			// {
			// 	optionListItems[i].setSelectionVisible(event.isGamepad);
			// }
		}
		
		protected function handleGesturePan( event : TransformGestureEvent ) : void
		{	
			//HACK : mcOptionList rowHeight is Nan (I dont think rows are added as children so it never gets propery sized)
			//Use mcOptionListItem1 height instead.
			//var rowHeight : Number = mcOptionList.rowHeight;
			var rowHeight : Number = mcOptionListItem1.height;
			var result : Object = CommonUtils.stagePanToRowScroll( _panYAccumulator, rowHeight, event );

			mcOptionScrollbar.position -= result.outRowsToScroll;
			_panYAccumulator = result.outPanYAccumulator;
		}

		private function enableTouch() : void
		{
			_panYAccumulator = 0;
			mcOptionList.enableTouch( true );
			addEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan, false, 0, true );
		}

		private function disableTouch() : void
		{
			_panYAccumulator = 0;
			mcOptionList.enableTouch( false );
			removeEventListener( TransformGestureEvent.GESTURE_PAN, handleGesturePan, false );
		}

		override protected function configUI():void
		{
			super.configUI();

			mcOptionList.bIsOptionList = true; // [dsl] Hack for a list that supports disabled items
				
			optionListItems = new Array(
				mcOptionListItem1,
				mcOptionListItem2,
				mcOptionListItem3,
				mcOptionListItem4,
				mcOptionListItem5,
				mcOptionListItem6,
				mcOptionListItem7,
				mcOptionListItem8,
				mcOptionListItem9
			);

			itemsX = mcOptionListItem1.x;
			
			if (mcOptionList)
			{
				mcOptionList.focusable = false;
				mcOptionList.addEventListener(ListEvent.INDEX_CHANGE, onOptionSelectionChanged);
			}
			
			if (mcPresetOption)
			{
				mcPresetList = mcPresetOption.getChildByName("mcScrollingList") as W3ScrollingList;
				mcPresetList.focusable = false;
				txtPresetTitle = mcPresetOption.getChildByName("txtPresetTitle") as TextField;
				mcScrollingListItem1 = mcPresetOption.getChildByName("mcScrollingListItem1") as W3MenuListItemRenderer;
				setupPresetItemMouseEvents(mcScrollingListItem1);
				mcScrollingListItem2 = mcPresetOption.getChildByName("mcScrollingListItem2") as W3MenuListItemRenderer;
				setupPresetItemMouseEvents(mcScrollingListItem2);
				mcScrollingListItem3 = mcPresetOption.getChildByName("mcScrollingListItem3") as W3MenuListItemRenderer;
				setupPresetItemMouseEvents(mcScrollingListItem3);
				mcScrollingListItem4 = mcPresetOption.getChildByName("mcScrollingListItem4") as W3MenuListItemRenderer;
				setupPresetItemMouseEvents(mcScrollingListItem4);
				mcScrollingListItem5 = mcPresetOption.getChildByName("mcScrollingListItem5") as W3MenuListItemRenderer;
				setupPresetItemMouseEvents(mcScrollingListItem5);
				mcScrollingListItem6 = mcPresetOption.getChildByName("mcScrollingListItem6") as W3MenuListItemRenderer;
				setupPresetItemMouseEvents(mcScrollingListItem6);
				mcScrollingListItem7 = mcPresetOption.getChildByName("mcScrollingListItem7") as W3MenuListItemRenderer;
				setupPresetItemMouseEvents(mcScrollingListItem7);
				
				mcPresetList.addEventListener( ListEvent.INDEX_CHANGE, handlePresetIndexChanged, false, 0, true );
				
				mcPresetList.PCUpAction = KeyCode.A;
				mcPresetList.PCDownAction = KeyCode.D;
			}

			txtOptionDescription = getChildByName("txtOptionDescription") as TextField;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
			
			if (mcOptionScrollbar)
			{
				mcOptionScrollbar.addEventListener( Event.SCROLL, handleOptionScroll, false, 1, true);
			}
			
			visible = false;
			enabled = false;
			alpha = 0;
			mcTelemetrySpinner.visible = false;
			mcTelemetryDataRequestPopup.visible = false;
			
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "options.insert_entry", [onInsertOptionsEntry] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "options.remove_entry", [onRemoveOptionsEntry] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "options.update_disabled", [onUpdateDisabled] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "options.force_update_values", [onForceUpdateValues] ) );
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "options.show_spinner", [onShowSpinner] ) );
		}
		
		override protected function handleControllerChanged(event:ControllerChangeEvent):void
		{
			super.handleControllerChanged(event);

			if (_lastMouseOveredPresetItem != -1)
			{
				presetSelected = true;
				mcPresetList.selectedIndex = _lastMouseOveredPresetItem;
				mcOptionList.selectedIndex = -1;
			}
			else if (_lastMouseOveredOptionItem != -1)
			{
				presetSelected = false;
				mcPresetList.selectedIndex = -1;
				mcOptionList.selectedIndex = mcOptionList.getRendererAt(_lastMouseOveredOptionItem, mcOptionList.scrollPosition).index;
			}
			else if (mcOptionList.selectedIndex == -1 && mcPresetList.selectedIndex == -1)
			{
				presetSelected = false;
				mcOptionList.selectedIndex = 0;
			}

			_lastMouseOveredPresetItem = -1;
			_lastMouseOveredOptionItem = -1;

			// Stupid-ass hack for switch2 to handle the disappearing cursor while toggling the Mouser on/off...
			// We have to return the focus to the menu, and send a missing MOUSE_UP event, when the mouser is turned off via the MouserActivationMode option slider...
			// Flag the mouser event as fake, so we don't call the setupDataProviders() function in MouseUp eventhandler here that repopulates all the removed options...
			{
				_isFakeMouseUpEvent = true;
				dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
				FocusHandler.getInstance().setFocus(this, 0);
			}
		}
		
		public function showWithData(data:Array):void
		{
			if (!mcOptionList)
			{
				return;
			}

			trace( "OptionListModule showWithData()" );
			
			var ingameMenu:IngameMenu = parent as IngameMenu;
			var finalData:Array = new Array();
			var i:int;
			
			visible = true;
			enabled = true;
		
			mcOptionList.selectedIndex = -1;
			txtOptionDescription.text = "";
			
			GTweener.removeTweens(this);
			GTweener.to(this, 0.2, { alpha:1.0 }, { } );
			
			presetSelected = false;
			
			// #J super hacky but current system is not built properly to do this any better way
			for (i = 0; i < data.length; ++i)
			{
				if (!(data[i].checkHardwareCursor) || !ingameMenu._hardwareCursorOn)
				{
					finalData.push(data[i]);
				}
				else
				{
					trace("GFX ------ eliminated an option! ----------");
				}
			}
			optionListData = finalData;

			setupDataProviders(finalData);
			
			if (mcOptionList.selectedIndex == 0)
			{
				dispatchEvent(new GameEvent(GameEvent.CALL, "OnPlaySoundEvent", ["gui_global_highlight"]));
			}
			
			if (!lastMoveWasMouse)
			{
				mcOptionList.selectedIndex = 0;
				mcOptionList.dispatchEvent(new ListEvent(ListEvent.INDEX_CHANGE, false, false, 0));
			}
			else
			{
				mcOptionList.selectedIndex = -1;
			}

			enableTouch();
		}
		
		public function updateData(data:Array):void
		{
			var currentPresetIndex:int;
			var currentOptionIndex:int;

			trace( "OptionListModule updateData()" );

			if (mcPresetList && mcPresetList.visible)
			{
				currentPresetIndex = mcPresetList.selectedIndex;
			}
			currentOptionIndex = mcOptionList.selectedIndex;
			
			setupDataProviders(data);
			
			if (mcPresetList && mcPresetList.visible)
			{
				mcPresetList.selectedIndex = currentPresetIndex;
			}
			mcOptionList.selectedIndex = currentOptionIndex;
			
			mcPresetList.validateNow();
			mcOptionList.validateNow();
		}
	
		protected function onOptionSelectionChanged(e:ListEvent):void
		{
			updateDescriptionText(e.itemData);
		}
		
		public function updateDescriptionText(itemData:Object):void
		{
			var description: String = ""; 
			
			if (itemData)
			{
				if (itemData.description)
					description = itemData.description;
				else if (itemData.descriptionTrue && itemData.current == "true")
					description = itemData.descriptionTrue;
				else if (itemData.descriptionFalse && itemData.current == "false")
					description = itemData.descriptionFalse;
			}
			
			// Text is center-aligend. If changed to left-aligned, make sure to handle Arabic properly.
			txtOptionDescription.htmlText = description;
		}
		
		protected function setupDataProviders(data:Array):void
		{
			var i:int;
			var presetData:Object = null;
			var finalDataList:Array = new Array();

			trace("OptionListModule setupDataProviders()");

			for (i = 0; i < data.length; ++i)
			{
				if (data[i].id == "Presets")
				{
					presetData = data[i];
				}
				else
				{
					finalDataList.push(data[i]);
				}
			}
			
			setPresetData(presetData);
			
			mcOptionList.dataProvider = new DataProvider(finalDataList);
			mcOptionList.validateNow();
		}

		// [dsl] We don't want to apply the disable states until we release the mouse
		protected function handleMouseDown(event:MouseEvent):void
		{
			trace( "OptionListModule handleMouseDown()" );

			// Sometimes UI can glitch and we missed the mouse up (Released outside window). Flash seems pretty good at sending the event no matter what, but I dont like taking any chances on this with Experience with other UI systems *cough* winforms *cough*
			if (_mouseIsDown)
			{
				_mouseIsDown = false;

				if (_disableStateChanged)
				{
					trace( "    _mouseIsDown TRUE && _disableStateChanged TRUE" );
					setupDataProviders(optionListData);
					_disableStateChanged = false;
				}
			}
			_mouseIsDown = true;
		}

		protected function handleMouseUp(event:MouseEvent):void
		{
			trace( "OptionListModule handleMouseUp()" );

			if (_isFakeMouseUpEvent)
			{
				trace( "    _isFakeMouseUpEvent TRUE" );
				_isFakeMouseUpEvent = false;
			}
			else if (_disableStateChanged)
			{
				trace( "    _disableStateChanged TRUE" );
				setupDataProviders(optionListData);
			}

			_mouseIsDown = false;
			_disableStateChanged = false;
		}

		private function onUpdateDisabled(data:Array):void
		{
			var i:int;
			var j:int;
			var changeFocus:Boolean = false;

			if (optionListData == null)  // Could be called too early it seems.
				return;

			trace( "OptionListModule onUpdateDisabled()" );

			for (i = 0; i < data.length; ++i)
			{
				for (j = 0; j < optionListData.length; ++j)
				{
					if (optionListData[j].tag == data[i].tag)
					{
						optionListData[j].disabled = data[i].disabled;

						if (j == mcOptionList.selectedIndex && data[i].disabled == true)
							changeFocus = true;

						if (data[i].current != null) optionListData[j].current = data[i].current; // We can override value
						else if (data[i].resetToStartingValue) optionListData[j].current = optionListData[j].startingValue;
						else if (data[i].resetStartingValue) optionListData[j].startingValue = optionListData[j].current;
						break;
					}
				}
			}

			_disableStateChanged = false;
			if (!_mouseIsDown) // Could have been moved with keyboard
			{
				trace( "    - _mouseIsDown FALSE" );
				setupDataProviders(optionListData);
			}
			else
			{
				_disableStateChanged = true;
			}

			if (changeFocus)
			{
				mcOptionList.selectedIndex = -1;
			}
			// HACK: force focus on list module to keep focus on IngameMenu and to avoid stuck keyboard navigation after mouse click
			FocusHandler.getInstance().setFocus(this, 0);
		}

		private function onForceUpdateValues(data:Array):void
		{
			var i:int;
			var j:int;

			if (optionListData == null) // Could be called too early it seems.
				return;

			trace( "OptionListModule onForceUpdateValues()" );

			for (i = 0; i < data.length; ++i)
			{
				for (j = 0; j < optionListData.length; ++j)
				{
					if (optionListData[j].tag == data[i].tag)
					{
						if (data[i].current != null)
						{
							trace( "    setting '" + data[i].tag + "' to value " + data[i].current );
							optionListData[j].current = data[i].current; // We can override value
						}
						else if (data[i].resetToStartingValue)
						{
							optionListData[j].current = optionListData[j].startingValue;
						}
						else if (data[i].resetStartingValue)
						{
							optionListData[j].startingValue = optionListData[j].current;
						}
						
						break;
					}
				}
			}

			setupDataProviders(optionListData);
		}

		// The menu has 9 movieclips that represents the items. Depending on scroll, the index doesn't match the index of the data.
		private function getOptionDataForScreenIndex(screenIndex:int):Object
		{
			var scrollPos:int = int(mcOptionList.scrollPosition); // uint to int because we'll do a substraction
			var index:int = screenIndex + scrollPos;
			if (index < 0 || index >= optionListData.length) return null;
			return optionListData[index];
		}

		private function getListItem(index:int):W3SubMenuListItemRenderer
		{
			if (index >= 0 && index < optionListItems.length) return optionListItems[index];
			return null;
		}
		
		public function setPresetData(presetData:Object):void
		{
			if (!mcPresetOption)
			{
				return;
			}
			
			if (presetData && mcPresetList)
			{
				presetsEnabled = true;
				mcPresetOption.visible = true;
				
				mcPresetList.dataProvider = new DataProvider(presetData.subElements);
				mcPresetList.validateNow();
				mcPresetList.selectedIndex = -1;
				currentPresetGroupName = presetData.GroupName;
				
				if (txtPresetTitle)
				{
					if(CoreComponent.isArabicAligmentMode)
						txtPresetTitle.htmlText = "<p align=\"right\">" + presetData.label + "</p>";
					else
						txtPresetTitle.htmlText = presetData.label;
				}
			}
			else
			{
				presetsEnabled = false;
				mcPresetOption.visible = false;
			}
		}
		
		public function hide():void
		{
			if (visible)
			{
				disableTouch();
				GTweener.removeTweens(this);
				
				enabled = false;
				(parent as IngameMenu).showApplyPresetInputFeedback(false);
				GTweener.to(this, 0.2, { alpha:0.0 }, { onComplete:onHideComplete } );
			}
		}
		
		protected function onHideComplete(curTween:GTween):void
		{
			visible = false;
		}

		protected function handleMouseMove(event:MouseEvent):void
		{
			if (!visible)
			{
				return;
			}

			if ( mcTelemetryDataRequestPopup.visible || mcTelemetrySpinner.visible )
			{
				return;
			}
			
			var mousedPreset:W3MenuListItemRenderer = getPresetUnderMouse(event.stageX, event.stageY);
			if (mousedPreset)
			{
				mcPresetList.selectedIndex = mousedPreset.index;
				_lastMouseOveredPresetItem = mousedPreset.index;
			}
			else
			{
				mcPresetList.selectedIndex = -1;
				_lastMouseOveredPresetItem = -1;
			}
			
			var mousedOption:W3SubMenuListItemRenderer = getOptionUnderMouse(event.stageX, event.stageY);
			if (mousedOption)
			{
				mcOptionList.selectedIndex = mousedOption.index;
				_lastMouseOveredOptionItem = mousedOption.index;
			}
			else
			{
				mcOptionList.selectedIndex = -1;
				_lastMouseOveredOptionItem = -1;
			}
		}
		
		protected function getPresetUnderMouse(stageX:int, stageY:int):W3MenuListItemRenderer
		{
			if (mcPresetList.dataProvider.length == 0)
			{
				return null;
			}
			else if (mcScrollingListItem1.hitTestPoint(stageX, stageY))
			{
				return mcScrollingListItem1;
			}
			else if (mcScrollingListItem2.hitTestPoint(stageX, stageY))
			{
				return mcScrollingListItem2;
			}
			else if (mcScrollingListItem3.hitTestPoint(stageX, stageY))
			{
				return mcScrollingListItem3;
			}
			else if (mcScrollingListItem4.hitTestPoint(stageX, stageY))
			{
				return mcScrollingListItem4;
			}
			else if (mcScrollingListItem5.hitTestPoint(stageX, stageY))
			{
				return mcScrollingListItem5;
			}
			else if (mcScrollingListItem6.hitTestPoint(stageX, stageY))
			{
				return mcScrollingListItem6;
			}
			else if (mcScrollingListItem7.hitTestPoint(stageX, stageY))
			{
				return mcScrollingListItem7;
			}
			
			return null;
		}
		
		protected function getOptionUnderMouse(stageX:int, stageY:int):W3SubMenuListItemRenderer
		{
			var scrollPos:int = int(mcOptionList.scrollPosition);

			for (var i:int = 0; i < optionListItems.length; ++i)
			{
				var mc = optionListItems[i];
				if (mc.hitTestPoint(stageX, stageY))
					return mc;
			}
			
			return null;
		}
		
		protected function setupPresetItemMouseEvents(item:W3MenuListItemRenderer):void
		{
			item.addEventListener(MouseEvent.CLICK, onPresetItemClicked, false, 0, true);
		}
		
		protected function onPresetItemClicked(event:MouseEvent):void
		{
			if (!visible)
			{
				return;
			}
			
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				dispatchEvent(new GameEvent( GameEvent.CALL, 'OnPresetApplied', [ currentPresetGroupName, mcPresetList.selectedIndex ] ));
				event.stopImmediatePropagation();
			}
		}
		
		private function handleOptionScroll(e:Event) : void
		{
			var ingameMenu:IngameMenu = parent as IngameMenu;
			if (!visible || !lastMoveWasMouse)
			{
				return;
			}
			
			if (_lastMouseOveredOptionItem != -1)
			{
				var currentTarget:W3SubMenuListItemRenderer  = mcOptionList.getRendererAt(_lastMouseOveredOptionItem, mcOptionList.scrollPosition) as W3SubMenuListItemRenderer;
				
				if (currentTarget)
				{
					mcOptionList.selectedIndex = currentTarget.index;
				}
			}
		}
		
		public function handleInputNavigate(event:InputEvent):void
		{
			if (visible)
			{
				if ( mcTelemetryDataRequestPopup.visible )
				{
					mcTelemetryDataRequestPopup.handleInput( event );
				}
				else if ( mcTelemetrySpinner.visible )
				{

				}
				else
				{
					var details:InputDetails = event.details;
					var keyUp:Boolean = (details.value == InputValue.KEY_UP);
					var optionRenderer:W3SubMenuListItemRenderer = mcOptionList.getSelectedRenderer() as W3SubMenuListItemRenderer;
					
					if (presetSelected)
					{
						mcPresetList.handleInput(event);
					}
					else
					{
						mcOptionList.handleInput(event);
					}
					
					if ( !event.handled )
					{
						if (keyUp && optionRenderer && details.code == KeyCode.E)
						{
							optionRenderer.activate();
						}
						
						switch(details.navEquivalent)
						{
						case NavigationCode.GAMEPAD_A:
							if (keyUp)
							{
								if (mcPresetList && mcPresetList.visible && mcPresetList.selectedIndex != -1)
								{
									dispatchEvent(new GameEvent( GameEvent.CALL, 'OnPresetApplied', [ currentPresetGroupName, mcPresetList.selectedIndex ] ));
								}
								else if (optionRenderer)
								{
									optionRenderer.activate();
								}
							}
							break;
						case NavigationCode.GAMEPAD_B:
							if (keyUp)
							{
								handleNavigateBack();
							}
							break;
						case NavigationCode.UP:
							if (!keyUp && presetsEnabled)
							{
								if (!presetSelected && mcPresetList.visible)
								{
									presetSelected = true;
									mcPresetList.selectedIndex = 0;
									mcOptionList.selectedIndex = -1;
								}
							}
							break;
						case NavigationCode.DOWN:
							if (!keyUp && presetsEnabled)
							{
								if (presetSelected)
								{
									presetSelected = false;
									mcPresetList.selectedIndex = -1;
									mcOptionList.selectedIndex = -1;
									mcOptionList.moveDown();
								}
							}
							break;
						}
					}
				}
			}
		}
		
		public function onRightClick(event:MouseEvent):void
		{
			if (visible)
			{
				handleNavigateBack();
			}
		}

		public function onTap(event:GestureEvent):void
		{
			if (visible)
			{
				handleNavigateBack();
			}
		}
		
		public function handleNavigateBack():void
		{
			dispatchEvent( new Event(IngameMenu.OnOptionPanelClosed, false, false) );
			(parent as IngameMenu).mcInputFeedbackModule.removeButton(ACTION_DOWNLOAD, true);
		}
		
		protected function handlePresetIndexChanged(e: ListEvent):void
		{
			if (mcPresetList && mcPresetList.visible)
			{
				(parent as IngameMenu).showApplyPresetInputFeedback(e.index != -1);
			}
		}
		
		private function onInsertOptionsEntry( entries : Object ):void 
		{
			var newData : Array;
			var masterEntryIndex : int = -1;
			var sourceData : DataProvider = mcOptionList.dataProvider as DataProvider;
			var entryAlreadyExists : Boolean = false;
			
			trace( "OptionListModule onInsertOptionsEntry() " + entries.list.length.toString() );
			
			// find item with master tag in order to insert entries after it
			for (i = 0; i < sourceData.length; i++)
			{
				if ( sourceData[i].tag == entries.masterTag )
				{
					masterEntryIndex = i;
					break;
				}
			}
			
			if ( masterEntryIndex == -1 && entries.masterTag != 0 )
				return;
				
			for ( var eId:uint = 0; eId < entries.list.length; eId++ )
			{
				entryAlreadyExists = false;
				for (var i:uint = 0; i < sourceData.length; i++)
				{
					if ( sourceData[i].tag == entries.list[eId].tag )
					{
						entryAlreadyExists = true;
						break;
					}
				}
				
				if ( !entryAlreadyExists )
				{
					sourceData.splice( masterEntryIndex + 1, 0, entries.list[eId] );
					masterEntryIndex += 1;
				}
			}
			
			mcOptionList.invalidateData();
		}
		
		private function onRemoveOptionsEntry( entries : Object ):void 
		{
			var newData : Array;
			var removeEntryIndex : int = -1;
			var sourceData : DataProvider = mcOptionList.dataProvider as DataProvider;
			
			trace( "OptionListModule onRemoveOptionsEntry() " + entries.list.length.toString() );
			
			for ( var eId:uint = 0; eId < entries.list.length; eId++ )
			{
				for (var i:uint = 0; i < sourceData.length; i++)
				{
					if ( sourceData[i].tag == entries.list[eId].tag )
					{
						removeEntryIndex = i;
						break;
					}
				}
			
				if ( removeEntryIndex != -1 )
				{
					sourceData.splice(removeEntryIndex, 1);
					removeEntryIndex = -1;
				}
			}
			
			mcOptionList.invalidateData();
		}
	}
}
