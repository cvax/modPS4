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
	import flash.events.TransformGestureEvent;

	import flash.utils.setTimeout;

	/**
	 * Top panel navigation bar
	 * @author Lilla Toma
	 */
	public class TopBarNewGlossary extends TopBarNew
	{
        public function TopBarNewGlossary()
        {
            super();
        }

        protected override function configUI():void
        {
            super.configUI();

			if (mcLeftGamepadButton)
			{
				mcLeftGamepadButton.setDataFromStage(NavigationCode.GAMEPAD_L2, -1);
				mcLeftGamepadButton.showKeyboardIconOnSwitch2Mouser(true);
			}
			if (mcRightGamepadButton)
			{
				mcRightGamepadButton.setDataFromStage(NavigationCode.GAMEPAD_R2, -1);
				mcRightGamepadButton.showKeyboardIconOnSwitch2Mouser(true);
			}

			RENDERER_GAP = 12;
        }

		override protected function handleGestureTwoFingerSwipe( event : TransformGestureEvent ) : void
		{
			//No two finger swipe nav for you!
		}

        public override function spawnTopBarElems(count : int):void
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
                newElem.y = 8.5;

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
            }

            doSetButtonVisibility();
            mcTabList.itemRendererList = tempList;
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
				var parentMenu:MenuCommon = this.parent && this.parent.parent? this.parent.parent as MenuCommon:null;
				if (parentMenu)
				{
					allowInput = isKeyDown || !parentMenu.isInputValidationEnabled() || ( parentMenu.isNavEquivalentValid(inputDetails.navEquivalent) || parentMenu.isKeyCodeValid(inputDetails.code) ) ;
				}
				
				// WASD support

				var isSwitch2Mouser:Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;

				switch (inputDetails.navEquivalent)
				{
					case NavigationCode.GAMEPAD_L2:
						if (allowInput && isKeyUp && !isSwitch2Mouser)
						{
							selectPrevTabItem();
						}
					break;
					case NavigationCode.GAMEPAD_R2:
						if (allowInput && isKeyUp && !isSwitch2Mouser)
						{
							selectNextTabItem();
						}
					break;
				}
			}
		}
	}
}