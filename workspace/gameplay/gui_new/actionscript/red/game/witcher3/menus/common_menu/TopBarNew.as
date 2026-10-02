package red.game.witcher3.menus.common_menu 
{
	import scaleform.clik.core.UIComponent;
    import red.game.witcher3.controls.InputFeedbackButton;
    import red.game.witcher3.controls.ConditionalButton;
	import red.game.witcher3.menus.common_menu.MenuHubTabListItem;
    import flash.utils.getDefinitionByName;
    import red.game.witcher3.controls.W3ScrollingList;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.GestureEvent;
    import red.core.events.GestureEventEx;
	import flash.events.TransformGestureEvent;
	import red.core.events.TransformGestureEventEx;
    import flash.events.MouseEvent;
    import red.core.events.GameEvent;
	import red.game.witcher3.managers.InputManager;
    import scaleform.clik.data.DataProvider;
    import scaleform.clik.interfaces.IListItemRenderer;
    import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
    import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import red.game.witcher3.utils.CommonUtils;
    import scaleform.clik.constants.InputValue;
    import red.game.witcher3.constants.EInputDeviceType;

	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.utils.setTimeout;

	/**
	 * Top panel navigation bar
	 * @author Lilla Toma
	 */
	public class TopBarNew extends UIComponent
	{
		//ART CLIPS
        public var mcLeftGamepadButton : InputFeedbackButton;
        public var mcRightGamepadButton : InputFeedbackButton;
        public var mcLeftPCButton : ConditionalButton;
        public var mcRightPCButton : ConditionalButton;
        public var mcTestElem : MenuHubTabListItem;
        public var mcTabList:W3ScrollingList;

        //CONSTS
       	public var MAX_HEIGHT:Number = 105;
		public var RENDERER_GAP:Number = 0;
		public var MAX_ALLOWED_TEXT_HEIGHT:Number = 52;
		public var MAX_ALLOWED_COMBINED_HEIGHT:Number = 120; //text + icon
		public var MAX_ALLOWED_TEXT_UP_PUSH : Number = 25;
		public var PUSH_RATIO : Number = 0.8;

		public var TEXT_Y_POSITION:Number = 46.9;

        //LOCALS
        protected var mcTabButtons : Vector.<MenuHubTabListItem> = new Vector.<MenuHubTabListItem>();
        protected var _lastMoveWasMouse:Boolean = false;
		protected var _lastMouseOveredItem:MenuHubTabListItem;
        protected var cachedSelectedId : uint;
        public var navigationEnabled:Boolean = true;
        public var rblbenabled:Boolean = true;

		public var elemClassName : String = "mcTopBarTabItemContainer";

		private var hadResize : Boolean = false;
		private var cachedTextY : Number;
		private var cachedTextSize : Number;
		private var cachedIconSize : Number = -1;
		private var cachedIconY : Number = 0;

        public function TopBarNew()
        {
            removeChild(mcTestElem);
        }

        protected override function configUI():void
        {
            dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.main.setup', [setTabData]));
            dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.main.select.tab', [setSelectedTab]));

            if (mcLeftPCButton)
			{
				mcLeftPCButton.addEventListener(ButtonEvent.PRESS, handlePrevButtonPress, false, 0, true);
				mcLeftPCButton.showOnSwitch2Mouser = true;
			}
			if (mcLeftGamepadButton)
			{
				mcLeftGamepadButton.setDataFromStage(NavigationCode.GAMEPAD_L1, -1);
				mcLeftGamepadButton.showKeyboardIconOnSwitch2Mouser(true);
			}
			if (mcRightPCButton)
			{
				mcRightPCButton.addEventListener(ButtonEvent.PRESS, handleNextButtonPress, false, 0, true);
				mcRightPCButton.showOnSwitch2Mouser = true;
			}
			if (mcRightGamepadButton)
			{
				mcRightGamepadButton.setDataFromStage(NavigationCode.GAMEPAD_R1, -1);
				mcRightGamepadButton.showKeyboardIconOnSwitch2Mouser(true);
			}

            InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 10, true);
			stage.addEventListener( GestureEventEx.GESTURE_TAP, handleInputGestureTap );
			stage.addEventListener( TransformGestureEventEx.GESTURE_TWO_FINGER_SWIPE, handleGestureTwoFingerSwipe, false, 0, true );
        }

        protected function doRequestMenu(menuId:int, state:String):void
        {
            cachedSelectedId = (uint)(menuId);
            dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRequestMenu', [(uint)(menuId), state] ) );
        }

        public function spawnTopBarElems(count : int):void
        {
            var classRef : Class = getDefinitionByName(elemClassName) as Class;
            var tempList : Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>();
            for(var i : int = 0; i < count; i++)
            {
                var newElem : MovieClip = new classRef() as MovieClip;
                var ratio : Number = MAX_HEIGHT / newElem.height;
                addChild(newElem); 
                newElem.width = newElem.width * ratio;
                newElem.height = newElem.height * ratio;
                newElem.x = (-(count - 1)/2 + i) * (newElem.width + RENDERER_GAP);
                newElem.y = 18.5;

                if(i == 0)
                {
                    mcLeftPCButton.x = newElem.x - newElem.width * 0.6;
                    mcLeftGamepadButton.x = newElem.x - newElem.width * 0.875;
                }
                if(i == count - 1)
                {
                    mcRightPCButton.x = newElem.x + newElem.width * 0.6;
                    mcRightGamepadButton.x = newElem.x + newElem.width * 0.6;
                }

                mcTabButtons.push(newElem.mcMain);
                addToListContainer_Item(newElem);
                tempList.push(newElem.mcMain as IListItemRenderer);

				newElem.mcMain.addEventListener("setLabel", onLabelChange);
            }

            doSetButtonVisibility();
            mcTabList.itemRendererList = tempList;
        }

		protected function onLabelChange(event:Event):void
		{
			if(!hadResize)
				setTimeout(checkTextOverflow, 1); //needs delay otherwise text is still "Character Development"
			else
				forceButtonUpdate();
		}

		protected function checkTextOverflow():void
		{
			var biggestProblemTextSize : Number = -1;
			var biggestProblemCombined : Number = -1;

			for(var i : int = 0; i < mcTabButtons.length; i++)
			{
				var elem : MenuHubTabListItem = mcTabButtons[i];

				if(elem.txtLabel.textHeight + elem.mcIcon.height > MAX_ALLOWED_COMBINED_HEIGHT 
				&& elem.txtLabel.textHeight + elem.mcIcon.height > biggestProblemCombined)
				{
					biggestProblemCombined = elem.txtLabel.textHeight + elem.mcIcon.height;
				}

				if(elem.txtLabel.textHeight > MAX_ALLOWED_TEXT_HEIGHT && elem.txtLabel.textHeight > biggestProblemTextSize)
				{
					biggestProblemTextSize = elem.txtLabel.textHeight;
				}
			}

			if(biggestProblemTextSize != -1)
			{
				if(biggestProblemCombined != -1) //no need to resize images if text is fine
					onCombinedOverflow();
				onTextOverflow(biggestProblemTextSize);
			}
		}

		public function doImageResizeOnOverflow(biggest : Number):void
		{

		}

		public function onCombinedOverflow():void
		{
			var newSize : Number = MAX_ALLOWED_COMBINED_HEIGHT - MAX_ALLOWED_TEXT_HEIGHT;
			//only doing image resize and up pushing a little
			for(var i : int = 0; i < mcTabButtons.length; i++)
			{
				var elem : MenuHubTabListItem = mcTabButtons[i];
				var oldSize = elem.mcIcon.width;

				elem.mcIcon.width = elem.mcIcon.height = newSize;
				elem.mcIcon.y -= (oldSize - newSize) / 2; 
				cachedIconY = elem.mcIcon.y;
				
				if(i == 0)
					TEXT_Y_POSITION -= (oldSize - newSize);

				elem.txtLabel.y = TEXT_Y_POSITION;
				cachedIconSize = newSize;
			}
		}

		public function onTextOverflow(biggest : Number):void
		{			
			var difference : Number = biggest - MAX_ALLOWED_TEXT_HEIGHT;
			var textPush : Number = Math.min(difference * PUSH_RATIO, MAX_ALLOWED_TEXT_UP_PUSH);

			var currentUpPush : Number = TEXT_Y_POSITION - mcTabButtons[0].txtLabel.y;

			var pushNeeded : Number = Math.min(MAX_ALLOWED_TEXT_UP_PUSH, textPush - currentUpPush);
			var resizePart : Number = difference - pushNeeded;

			for(var i : int = 0; i < mcTabButtons.length; i++)
			{
				var elem : MenuHubTabListItem = mcTabButtons[i];
				var format : TextFormat = elem.txtLabel.getTextFormat();
				var newSize : Number = Number(format.size) * MAX_ALLOWED_TEXT_HEIGHT / (resizePart + MAX_ALLOWED_TEXT_HEIGHT);
				format.size = newSize;
				elem.txtLabel.setTextFormat(format);
				elem.y -= pushNeeded;

				cachedTextY = elem.txtLabel.y;
				cachedTextSize = newSize;
			}

			hadResize = true;
		}

		public function forceButtonUpdate():void
		{
			if(!hadResize)
				return;
			
			for(var i : int = 0; i < mcTabButtons.length; i++)
			{
				var elem : MenuHubTabListItem = mcTabButtons[i];
				var format : TextFormat = elem.txtLabel.getTextFormat();
				format.size = cachedTextSize;
				elem.txtLabel.setTextFormat(format);
				elem.txtLabel.y = cachedTextY;
				if(cachedIconSize != -1)
					elem.mcIcon.width = elem.mcIcon.height = cachedIconSize;
				elem.mcIcon.y = cachedIconY;
			}
		}

        protected function doSetButtonVisibility():void
        {
            var count : int = mcTabButtons.length;

            if(mcLeftGamepadButton)
            {
                mcLeftGamepadButton.visible = count > 1;
            }
            if(mcRightGamepadButton)
            {
                mcRightGamepadButton.visible = count > 1;
            }
            if(mcLeftPCButton)
            {
                mcLeftPCButton.visible = count > 1;
            }
            if(mcRightPCButton)
            {
                mcRightPCButton.visible = count > 1;
            }
        }

        protected function addToListContainer_Item(component:MovieClip):void
		{
			if (component)
			{
				component.addEventListener(MouseEvent.CLICK, onTabItemClicked, false, 0, true);
				component.addEventListener(GestureEventEx.GESTURE_TAP, onTabItemGestureTap);
				component.addEventListener(MouseEvent.MOUSE_OVER, onTabItemMouseOver, false, 0, true);
				component.addEventListener(MouseEvent.MOUSE_OUT, onTabItemMouseOut, false, 0, true);
			}
			
			//addToTopListContainer(component);
		}

        protected function onTabItemClicked(event:Event):void
		{
			if(!navigationEnabled) return;
			if (!InputManager.getInstance().isMouse())
			{
				return;
			}
			
			event.stopImmediatePropagation();
			var currentTarget:MenuHubTabListItem = event.currentTarget.mcMain as MenuHubTabListItem;
			if (currentTarget && currentTarget.visible && currentTarget.data && currentTarget.data.enabled)
			{
                doRequestMenu(currentTarget.data.id, currentTarget.data.state);
			}
		}

        protected function onTabItemGestureTap(event:GestureEvent):void
		{
			if(!navigationEnabled) return;
            event.stopImmediatePropagation();
            var currentTarget:MenuHubTabListItem = event.currentTarget.mcMain as MenuHubTabListItem;
            if (currentTarget && currentTarget.visible && currentTarget.data && currentTarget.data.enabled)
            {
                doRequestMenu(currentTarget.data.id, currentTarget.data.state);
            }
		}

        protected function onTabItemMouseOver(event:MouseEvent):void
		{
			if(!navigationEnabled) return;
			_lastMouseOveredItem = event.currentTarget.mcMain as MenuHubTabListItem;
            _lastMouseOveredItem.selected = true;
			
			event.stopImmediatePropagation();
		}

        protected function onTabItemMouseOut(event:MouseEvent):void
		{
			if(!navigationEnabled) return;
            if(_lastMouseOveredItem && _lastMouseOveredItem.data && _lastMouseOveredItem.data.id != cachedSelectedId)
                _lastMouseOveredItem.selected = false;
			_lastMouseOveredItem = null;
			
			event.stopImmediatePropagation();
		}

		public function updateTabDataEnabled(menuId:uint, menuState:String, enabled:Boolean)
		{
			var topTabIT:int;
			var botTabIT:int;

			var subTabArray:Array;

			var currentTab:MenuHubTabListItem;
			var newData:Object = null;
			var newDataArray:Array = new Array();
			
			trace("GFX - Trying to select hub tab with id: " + menuId + " and state: " + menuState);

			for (topTabIT = 0; topTabIT < mcTabList.dataProvider.length; ++topTabIT)
			{
				currentTab = mcTabList.getRendererAt(topTabIT) as MenuHubTabListItem;
				
				if (currentTab && currentTab.data && currentTab.data.id == menuId)
				{
					newData = currentTab.data;
					newData.enabled = enabled;
					currentTab.setData(newData);
					
					subTabArray = currentTab.data.subItems;
					/*for (botTabIT = 0; botTabIT < subTabArray.length; ++botTabIT)
					{
						newData = subTabArray[botTabIT].data;
						newData.enabled = enabled;
						subTabArray[botTabIT].setData(newData);
					}*/
					
					if (mcTabList.selectedIndex == topTabIT && !enabled)
					{
						mcTabList.moveUp(true);
					}
					
					trace("GFX - Successfully updated enabled state for menu with id: " + menuId + ", and enabled:" + enabled);
				}
				
				newDataArray.push(currentTab.data);
			}
			
			mcTabList.dataProvider = new DataProvider(newDataArray);
			mcTabList.validateNow();
			//setupAllItemsList(newDataArray);
			//updateTabName(currentlySelectedMenu());
		}

        public function setTabData(data:Array):void
		{
			if (!data)
			{
				return;
			}

            spawnTopBarElems(data.length);

			mcTabList.dataProvider = new DataProvider(data);

			mcTabList.validateNow();
			//mcTabList.selectedIndex = data.length / 2;

			//setupAllItemsList(data);
		}

        public function setSelectedTab(data:Object):void
        {
			var id : int = data.id;
			var state : String = data.state;
            cachedSelectedId = (uint)(id);

			var foundIndex : int = -1;
            for(var i : int = 0; i < mcTabButtons.length; i++)
            {
                //mcTabButtons[i].selected = mcTabButtons[i].data.id == id;
                if(mcTabButtons[i].data.id == id && mcTabButtons[i].data.state == state)
				{
                    mcTabList.selectedIndex = i;
					foundIndex = i;
				}
            }

			mcTabList.validateNow();

			//extra force hack
			for(i = 0; i < mcTabButtons.length; i++)
			{
				mcTabButtons[i].selected = foundIndex == i;
			}
			forceButtonUpdate();
        }

		protected function handlePrevButtonPress( event : ButtonEvent ) : void
		{
			selectPrevTabItem();
		}
		
		protected function handleNextButtonPress( event : ButtonEvent ) : void
		{
			selectNextTabItem();
		}

        protected function selectPrevTabItem():void
		{
			var selectedParent:MenuHubTabListItem = mcTabList.getSelectedRenderer() as MenuHubTabListItem;

			if (selectedParent)
			{
				// #J WARNING this code assumes there is no disabled indexes in children, sooooo DONT add sublist items that can't be opened
				if (mcTabList.dataProvider.length > 1 && selectedParent.data.subItems.length == 0)
				{
					mcTabList.moveUp(true);
                    var newItem : MenuHubTabListItem = mcTabList.getSelectedRenderer() as MenuHubTabListItem;
                    doRequestMenu(newItem.data.id, newItem.data.state);
				}
			}
		}

		protected function selectNextTabItem():void
		{
			var selectedParent:MenuHubTabListItem = mcTabList.getSelectedRenderer() as MenuHubTabListItem;

			if (selectedParent)
			{
				if (mcTabList.dataProvider.length > 1 && selectedParent.data.subItems.length == 0)
				{
					mcTabList.moveDown(true);
                    var newItem : MenuHubTabListItem = mcTabList.getSelectedRenderer() as MenuHubTabListItem;
                    doRequestMenu(newItem.data.id, newItem.data.state);
				}
			}
		}

		public function requestCurrentMenu():void
		{
			var currentTarget : MenuHubTabListItem = mcTabList.getSelectedRenderer() as MenuHubTabListItem;

			if(currentTarget)
				doRequestMenu(currentTarget.data.id, currentTarget.data.state);
		}

		protected function handleInputGestureTap( event : GestureEvent ) : void
		{
			if(!navigationEnabled) return;
			if (mcLeftGamepadButton && mcLeftGamepadButton.hitTestPoint(event.stageX, event.stageY))
			{
				selectPrevTabItem();
			}
			else if (mcRightGamepadButton && mcRightGamepadButton.hitTestPoint(event.stageX, event.stageY))
			{
				selectNextTabItem();
			}
		}

		protected function handleGestureTwoFingerSwipe( event : TransformGestureEvent ) : void
		{	
			trace( "TopBarNew::handleGestureTwoFingerSwipe : ", event );

			switch( event.rotation )
			{
				case TransformGestureEventEx.GESTURE_DIRECTION_RIGHT : 
					selectPrevTabItem();
				break;
				case TransformGestureEventEx.GESTURE_DIRECTION_LEFT : 
					selectNextTabItem();
				break;
			}
		}

        override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);

			if(this is TopBarNewGlossary) //Hack so this is skipped but core behaviour is kept
				return;

			//trace("GFX <MenuHub> handleInput ", event.handled, event.details.navEquivalent, navigationEnabled);

			if (event.handled || !navigationEnabled)
			{
				return;
			}
			
			var inputDetails:InputDetails = event.details as InputDetails;
			CommonUtils.convertWASDCodeToNavEquivalent(inputDetails);
			
			if (inputDetails.navEquivalent == NavigationCode.UP || inputDetails.navEquivalent == NavigationCode.DOWN || inputDetails.navEquivalent == NavigationCode.LEFT || inputDetails.navEquivalent == NavigationCode.RIGHT)
			{
				_lastMoveWasMouse = false;
			}

			if (!event.handled)
			{
				var isKeyUp:Boolean = inputDetails.value == InputValue.KEY_UP;
				var isKeyDown:Boolean = inputDetails.value == InputValue.KEY_DOWN;
				var isKeyHold:Boolean = inputDetails.value == InputValue.KEY_HOLD;
				
				var allowInput:Boolean = true;
				var parentMenu:MenuCommon = this.parent && this.parent.parent? this.parent.parent as MenuCommon:null;
				if (parentMenu)
				{
					allowInput = isKeyDown || !parentMenu.isInputValidationEnabled() || ( parentMenu.isNavEquivalentValid(inputDetails.navEquivalent) || parentMenu.isKeyCodeValid(inputDetails.code) ) ;
				}
				
				// WASD support

				var isSwitch2Mouser:Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;

				switch (inputDetails.navEquivalent)
				{
					case NavigationCode.GAMEPAD_L1:
						if (allowInput && isKeyUp && !isSwitch2Mouser)
						{
							selectPrevTabItem();
						}
					break;
					case NavigationCode.GAMEPAD_R1:
						if (allowInput && isKeyUp && !isSwitch2Mouser)
						{
							selectNextTabItem();
						}
					break;
					default:
						if (allowInput && isKeyUp && rblbenabled)
						{
							if (inputDetails.code == KeyCode.NUMBER_1 || inputDetails.code == KeyCode.NUMPAD_1 || inputDetails.code == KeyCode.PAGE_DOWN)
							{
								selectPrevTabItem();
							}
							else if (inputDetails.code == KeyCode.NUMBER_3 || inputDetails.code == KeyCode.NUMPAD_3 || inputDetails.code == KeyCode.PAGE_UP)
							{
								selectNextTabItem();
							}
						}
					break;
				}
			}
		}
	}
}