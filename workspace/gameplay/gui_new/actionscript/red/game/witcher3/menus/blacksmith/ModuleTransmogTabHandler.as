package red.game.witcher3.menus.blacksmith
{
	import flash.events.Event;
	import red.core.events.GameEvent;
	import flash.display.MovieClip;
	import flash.events.MouseEvent; //@FIXME BIDON -> remove it (or integrate mouse to everything)
	import flash.text.TextField;
    import flash.utils.getDefinitionByName;
    import flash.utils.setTimeout;
	import scaleform.clik.core.UIComponent;
	
	import scaleform.clik.constants.InputValue; //#B
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
    import scaleform.clik.interfaces.IListItemRenderer;
    import scaleform.clik.data.DataProvider;
    import scaleform.clik.events.ListEvent;
    import scaleform.clik.events.ButtonEvent;
	
	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	import red.core.utils.InputUtils;
    import red.core.CoreMenuModule;
    import red.game.witcher3.slots.SlotPaperdoll;
    import red.game.witcher3.controls.InputFeedbackButton;
    import red.game.witcher3.controls.AdvancedTabListItem;
    import red.game.witcher3.controls.W3ScrollingList;

    import flash.events.GestureEvent;
    import red.core.events.GestureEventEx;
    import red.game.witcher3.managers.InputManager;

	public class ModuleTransmogTabHandler extends CoreMenuModule
	{
        public var mcLeftGamepadButton : InputFeedbackButton;
        public var mcRightGamepadButton : InputFeedbackButton;
        public var mcPlaceholderTabItem : AdvancedTabListItem;
        public var mcTabList:W3ScrollingList;

        private var mcTabButtons : Vector.<AdvancedTabListItem> = new Vector.<AdvancedTabListItem>();
        protected var _lastMoveWasMouse:Boolean = false;
		protected var _lastMouseOveredItem:AdvancedTabListItem;
        private var cachedSelectedId : int = -1;

        public function ModuleTransmogTabHandler()
        {
            removeChild(mcPlaceholderTabItem);
        }

        override protected function configUI():void
        {
            super.configUI();

            dispatchEvent( new GameEvent( GameEvent.REGISTER, "transmog.create.tabs", [createTabs] ) );

            if (mcLeftGamepadButton)
			{
				mcLeftGamepadButton.setDataFromStage(NavigationCode.GAMEPAD_L2, -1);
				mcLeftGamepadButton.showKeyboardIconOnSwitch2Mouser(true);
                mcLeftGamepadButton.addEventListener( GestureEventEx.GESTURE_TAP, requestPrevTab, false, 0, true );
			}
			if (mcRightGamepadButton)
			{
				mcRightGamepadButton.setDataFromStage(NavigationCode.GAMEPAD_R2, -1);
				mcRightGamepadButton.showKeyboardIconOnSwitch2Mouser(true);
                mcRightGamepadButton.addEventListener( GestureEventEx.GESTURE_TAP, requestNextTab, false, 0, true );
			}
        }

        public function clearElems():void
        {
            for(var i : int = 0; i < mcTabButtons.length; i++)
            {
                removeChild(mcTabButtons[i]);
            }
            mcTabButtons = new Vector.<AdvancedTabListItem>();
        }

        public function spawnElems(count : int):void
        {
            var classRef : Class = getDefinitionByName("TabListItemRef") as Class;
            var tempList : Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>();
            for(var i : int = 0; i < count; i++)
            {
                var newElem : MovieClip = new classRef() as MovieClip;
                addChild(newElem); 
                newElem.x = (-(count - 1)/2 + i) * newElem.width
                newElem.y = 0;

                if(i == 0)
                {
                    mcLeftGamepadButton.x = newElem.x - newElem.width * 1.1;
                }
                if(i == count - 1)
                {
                    mcRightGamepadButton.x = newElem.x + newElem.width * 0.6;
                }

                mcTabButtons.push(newElem);
                addToListContainer_Item(newElem);
                tempList.push(newElem as IListItemRenderer);
            }
            mcTabList.itemRendererList = tempList;
        }

        public function createTabs(data:Array):void
        {
            if(!data)
                return;

            clearElems();
            spawnElems(data.length);

			mcTabList.dataProvider = new DataProvider(data);

			mcTabList.validateNow();

            if(cachedSelectedId == -1)
            {
                cachedSelectedId = 0;
                setTimeout(doLateRequestMenu, 10);
                mcTabList.selectedIndex = 0;
            }
            doSetButtonVisibility();
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
        }

        protected function addToListContainer_Item(component:MovieClip):void
		{
			if (component)
			{
                component.mouseChildren = false;
				component.addEventListener(MouseEvent.CLICK, onTabItemClicked, false, 0, true);
				component.addEventListener(GestureEventEx.GESTURE_TAP, onTabItemGestureTap);
				component.addEventListener(MouseEvent.MOUSE_OVER, onTabItemMouseOver, false, 0, true);
				component.addEventListener(MouseEvent.MOUSE_OUT, onTabItemMouseOut, false, 0, true);
			}
			
			//addToTopListContainer(component);
		}

        private function doLateRequestMenu():void
        {
            doRequestTab(cachedSelectedId);
        }

        private function doRequestTab(menuId:int):void
        {
            cachedSelectedId = menuId;
            dispatchEvent( new GameEvent( GameEvent.CALL, "OnTransmogItemSelectedByTabIndex", [menuId] ) );
        }
        
        protected function onTabItemClicked(event:MouseEvent):void
		{
			if (!InputManager.getInstance().isMouse())
			{
				return;
			}
			
			event.stopImmediatePropagation();
			var currentTarget:AdvancedTabListItem = event.currentTarget as AdvancedTabListItem;
			if (currentTarget && currentTarget.visible && currentTarget.data && currentTarget.data.enabled)
			{
                doRequestTab(currentTarget.index);
                mcTabList.selectedIndex = currentTarget.index;
			}

            /*for(var i : int = 0; i < mcTabButtons.length; i++)
			{
				if(mcTabButtons[i] == currentTarget)
                    continue;

                mcTabButtons[i].gotoAndStop("up");
                mcTabButtons[i].mcIcon.gotoAndStop( mcTabButtons[i].data.icon );
			}*/
		}

        protected function onTabItemGestureTap(event:GestureEvent):void
		{
            event.stopImmediatePropagation();
            var currentTarget:AdvancedTabListItem = event.currentTarget as AdvancedTabListItem;
            if (currentTarget && currentTarget.visible && currentTarget.data && currentTarget.data.enabled)
            {
                doRequestTab(currentTarget.index);
                mcTabList.selectedIndex = currentTarget.index;
            }

            /*
            for(var i : int = 0; i < mcTabButtons.length; i++)
			{
				if(mcTabButtons[i] == currentTarget)
                    continue;

                mcTabButtons[i].gotoAndStop("up");
                mcTabButtons[i].mcIcon.gotoAndStop( mcTabButtons[i].data.icon );
			}
            */
		}

        protected function onTabItemMouseOver(event:MouseEvent):void
		{
			//_lastMouseOveredItem = event.currentTarget as AdvancedTabListItem;
            //_lastMouseOveredItem.selected = true;
			
			//event.stopImmediatePropagation();
		}

        protected function onTabItemMouseOut(event:MouseEvent):void
		{
            //if(_lastMouseOveredItem && _lastMouseOveredItem.index && _lastMouseOveredItem.index != cachedSelectedId)
            //    _lastMouseOveredItem.selected = false;
			//_lastMouseOveredItem = null;
			
			//event.stopImmediatePropagation();
		}

        private function requestNextTab( event : Event = null ) : void
        {
            var newIndex : int = 0;

            if ( mcTabList.selectedIndex < mcTabList.dataProvider.length - 1 )
            {
                newIndex = mcTabList.selectedIndex + 1;
                mcTabList.selectedIndex = newIndex;
                doRequestTab(newIndex)
            }
        }

        private function requestPrevTab( event : Event = null ) : void
        {
            var newIndex : int = 0;
            
            if ( mcTabList.selectedIndex > 0 )
            {
                newIndex = mcTabList.selectedIndex - 1;
                mcTabList.selectedIndex = newIndex;
                doRequestTab(newIndex)
            }
        }

        public function handleInputAlt(event:InputEvent):void
		{
			var details:InputDetails = event.details;

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;	

            if(keyDown)
            {
                if(details.navEquivalent == NavigationCode.LEFT || details.navEquivalent == NavigationCode.GAMEPAD_L2)
                {
                    requestPrevTab();
                    event.handled = true;
                }
                else if (details.navEquivalent == NavigationCode.RIGHT || details.navEquivalent == NavigationCode.GAMEPAD_R2)
                {
                    requestNextTab();
                    event.handled = true;
                }
            }

            if(event.handled && !focused)
            {
                mcTabList.validateNow();
                var renderer : AdvancedTabListItem = mcTabList.getSelectedRenderer() as AdvancedTabListItem;
                renderer.gotoAndStop("over");
                renderer.mcIcon.gotoAndStop( renderer.data.icon );
            }
		}

        override public function set focused(value : Number):void
        {
            if(focused == value)
                return;

            super.focused = value;

            var renderer : AdvancedTabListItem = mcTabList.getSelectedRenderer() as AdvancedTabListItem;

            if(!renderer)
                return;

            if(value == 1)
            {
                renderer.gotoAndStop("selected_up");
                renderer.mcIcon.gotoAndStop( renderer.data.icon );
            }
            else
            {
                renderer.gotoAndStop("over");
                renderer.mcIcon.gotoAndStop( renderer.data.icon );
            }
        }

    }
}