package red.game.witcher3.menus.glossary 
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

	/**
	 * Top panel navigation bar
	 * @author Lilla Toma
	 */
	public class GlossaryMainTabController extends UIComponent
	{
		//ART CLIPS
        public var mcTabList:W3ScrollingList;

        //CONSTS

        //LOCALS
        private var mcTabButtons : Vector.<MenuHubTabListItem> = new Vector.<MenuHubTabListItem>();
        protected var _lastMoveWasMouse:Boolean = false;
		protected var _lastMouseOveredItem:MenuHubTabListItem;
        private var cachedSelectedId : uint;
        public var navigationEnabled:Boolean = true;
        public var rblbenabled:Boolean = true;

        public function GlossaryMainTabController()
        {
        }

        protected override function configUI():void
        {
            dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.main.setup', [setTabData]));
            dispatchEvent( new GameEvent( GameEvent.REGISTER, 'panel.main.select.tab', [setSelectedTab]));

            InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, 10, true);
        }

        private function doRequestMenu(menuId:int):void
        {
            cachedSelectedId = (uint)(menuId);
            dispatchEvent( new GameEvent( GameEvent.CALL, 'OnRequestMenu', [(uint)(menuId), ""] ) );
        }

        public function spawnBarElems(count : int):void
        {
            var classRef : Class = getDefinitionByName("mcTopBarTabItemContainer") as Class;
            var tempList : Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>();
            for(var i : int = 0; i < count; i++)
            {
                var newElem : MovieClip = new classRef() as MovieClip;
                addChild(newElem); 
                newElem.x = (-(count - 1)/2 + i) * newElem.width
                newElem.y = 14.5;

                mcTabButtons.push(newElem.mcMain);
                addToListContainer_Item(newElem);
                tempList.push(newElem.mcMain as IListItemRenderer);
            }
            mcTabList.itemRendererList = tempList;
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
			if (!InputManager.getInstance().isMouse())
			{
				return;
			}
			
			event.stopImmediatePropagation();
			var currentTarget:MenuHubTabListItem = event.currentTarget.mcMain as MenuHubTabListItem;
			if (currentTarget && currentTarget.visible && currentTarget.data && currentTarget.data.enabled)
			{
                doRequestMenu(currentTarget.data.id);
			}
		}

        protected function onTabItemGestureTap(event:GestureEvent):void
		{
            event.stopImmediatePropagation();
            var currentTarget:MenuHubTabListItem = event.currentTarget.mcMain as MenuHubTabListItem;
            if (currentTarget && currentTarget.visible && currentTarget.data && currentTarget.data.enabled)
            {
                doRequestMenu(currentTarget.data.id);
            }
		}

        protected function onTabItemMouseOver(event:MouseEvent):void
		{
			_lastMouseOveredItem = event.currentTarget.mcMain as MenuHubTabListItem;
            _lastMouseOveredItem.selected = true;
			
			event.stopImmediatePropagation();
		}

        protected function onTabItemMouseOut(event:MouseEvent):void
		{
            if(_lastMouseOveredItem && _lastMouseOveredItem.data && _lastMouseOveredItem.data.id != cachedSelectedId)
                _lastMouseOveredItem.selected = false;
			_lastMouseOveredItem = null;
			
			event.stopImmediatePropagation();
		}

        public function setTabData(data:Array):void
		{
			if (!data)
			{
				return;
			}

            spawnBarElems(data.length);

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
            for(var i : int = 0; i < mcTabButtons.length; i++)
            {
                //mcTabButtons[i].selected = mcTabButtons[i].data.id == id;
                if(mcTabButtons[i].data.id == id)
                    mcTabList.selectedIndex = i;
            }
            
        }

		protected function handlePrevButtonPress( event : ButtonEvent ) : void
		{
			selectPrevTabItem();
		}
		
		protected function handleNextButtonPress( event : ButtonEvent ) : void
		{
			selectNextTabItem();
		}

        private function selectPrevTabItem():void
		{
			var selectedParent:MenuHubTabListItem = mcTabList.getSelectedRenderer() as MenuHubTabListItem;

			if (selectedParent)
			{
				// #J WARNING this code assumes there is no disabled indexes in children, sooooo DONT add sublist items that can't be opened
				if (mcTabList.dataProvider.length > 1 && selectedParent.data.subItems.length == 0)
				{
					mcTabList.moveUp(true);
                    var newItem : MenuHubTabListItem = mcTabList.getSelectedRenderer() as MenuHubTabListItem;
                    doRequestMenu(newItem.data.id);
				}
			}
		}

		private function selectNextTabItem():void
		{
			var selectedParent:MenuHubTabListItem = mcTabList.getSelectedRenderer() as MenuHubTabListItem;

			if (selectedParent)
			{
				if (mcTabList.dataProvider.length > 1 && selectedParent.data.subItems.length == 0)
				{
					mcTabList.moveDown(true);
                    var newItem : MenuHubTabListItem = mcTabList.getSelectedRenderer() as MenuHubTabListItem;
                    doRequestMenu(newItem.data.id);
				}
			}
		}

        override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);

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
				
				// WASD support

				var isSwitch2Mouser:Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;

				switch (inputDetails.navEquivalent)
				{
					case NavigationCode.LEFT:
						if (allowInput && (isKeyDown || isKeyHold))
						{
                            if(mcTabList.selectedIndex > 0)
                                mcTabList.selectedIndex--;
						}
                    	break;
                    case NavigationCode.RIGHT:
						if (allowInput && (isKeyDown || isKeyHold))
						{
                            if(mcTabList.selectedIndex < mcTabButtons.length - 1)
                                mcTabList.selectedIndex++;
						}
                    	break;
                    case NavigationCode.GAMEPAD_A:
                        if (allowInput && isKeyUp)
						{
                            var selectedElem:MenuHubTabListItem = mcTabList.getSelectedRenderer() as MenuHubTabListItem;
                            if(selectedElem && selectedElem.data)
                                doRequestMenu(selectedElem.data.id);
						}
                        break;
				}
			}
		}
	}
}