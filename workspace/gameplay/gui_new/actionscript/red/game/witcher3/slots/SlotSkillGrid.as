package red.game.witcher3.slots
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import red.game.witcher3.LinearEase

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import red.core.constants.KeyCode;
	import red.game.witcher3.constants.InventoryActionType;
	import red.game.witcher3.constants.InventorySlotType;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IInventorySlot;
	import red.game.witcher3.managers.InputManager;
	
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.InputEvent;
	import scaleform.gfx.MouseEventEx;

	import red.game.witcher3.utils.CommonUtils;
	
	/**
	 * ...
	 * @author Getsevich Yaroslav
	 */
	
	 // Why SlotPaperdoll ???
	//public class SlotSkillGrid extends SlotBase implements IInventorySlot
	public class SlotSkillGrid extends SlotPaperdoll implements IInventorySlot
	{
		public var colorBorder:MovieClip;
		//public var equipedIcon:Sprite;
		public var unlockAnim:MovieClip;
		public var mcCollapsedTooltipIcon : MovieClip;
		public var coreFrame: MovieClip;
		public var mcSkillPoints: SlotPointIndicator;
		public var mcHoldAnimBlock : MovieClip;
		
		private var _isFirstDataUpdate:Boolean;
		private var _isUnlockedAnimPlayed:Boolean;

		private var _mouseRMBdownStatus:Boolean = false;

		private static const HOLD_TIME : Number = 1;
		
		public function SlotSkillGrid()
		{
			_isLocked = false;
			if (iconLock)
			{
				iconLock.visible = false;
				iconLock.mouseEnabled = false;
				iconLock.mouseChildren = false;
			}
			if (equipedIcon)
			{
				equipedIcon.mouseEnabled = false;
				equipedIcon.mouseChildren = false;
			}
			if (mcSkillPoints) mcSkillPoints.mouseEnabled = false;
			if (colorBorder) {colorBorder.mouseEnabled = false; colorBorder.mouseChildren = false;}
			if (mcHoldAnimBlock) {mcHoldAnimBlock.visible = false;}
			
			dropEnabled = false;
			
			_isFirstDataUpdate = true;
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			var hitArea:MovieClip = getHitArea() as MovieClip;
			if (hitArea)
			{
				hitArea.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDownGrid, false, 0, true);
				hitArea.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
				hitArea.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOutGrid, false, 0, true);
			}
		}
		
		override protected function initCollapsedIconBehavior():void
		{
			AUTO_SHOW_COLLAPSED_ICON = true;
			
			_mcCollapsedTooltipIcon = mcCollapsedTooltipIcon;
			
			if (_mcCollapsedTooltipIcon)
			{
				_mcCollapsedTooltipIcon.visible = false;
			}
			
			super.initCollapsedIconBehavior();
		}
		
		override public function get isLocked():Boolean
		{
			return _isLocked;
		}
		
		override protected function updateData()
		{
			super.updateData();
			
			if (!_data) return;
			//trace("GFX * update slot data [", this, "]", _data.maxLevel, _data.level);
			
			if(_data.skillPath != "ESP_NotSet")
			{
				if (_data.color && colorBorder && _data.level > 0 && !_data.isCoreSkill)
				{
					colorBorder.gotoAndStop(_data.color);
				}
				else if(colorBorder)
				{
					colorBorder.gotoAndStop("SC_Grey");
					if(_data.isUsingSkillDependency && !_data.hasRequiredSkillDependency)
						colorBorder.gotoAndStop("SC_Grey_Transparent")
				}
			}
			else
			{
				if(colorBorder) colorBorder.gotoAndStop("SC_None");
			}
			
			if (_data.level && _data.level > 0 && _data.maxLevel && _data.maxLevel > 0 && !_data.isCoreSkill)
			{
				mcSkillPoints.setCount(_data.level, _data.maxLevel);
				mcSkillPoints.setColor(_data.color);
				mcSkillPoints.visible = true;
			}
			else
			{
				mcSkillPoints.visible = false;
			}
			applyAvailability();

			if(mcColorBackground) mcColorBackground.visible = false;
		}

		public function updateIconAlpha():void
		{
			if (_imageLoader.content)
			{
				if (_data.level < 1 && !_data.hasRequiredPointsSpent)
				{
					_imageLoader.content.alpha = 0.2;
				}
				else if(_data.hasOwnProperty("isUsingSkillDependency") && _data.isUsingSkillDependency && !_data.hasRequiredSkillDependency)
				{
					_imageLoader.content.alpha = 0.2;
				}
				else
				{
					_imageLoader.content.alpha = 1;
				}
			}
		}
		
		override protected function handleIconLoaded(event:Event):void
		{
			super.handleIconLoaded(event);
			
			if (colorBorder) addChild(colorBorder);
			if (iconLock) addChild(iconLock);
			if (mcSkillPoints) addChild(mcSkillPoints);
			if (mcCollapsedTooltipIcon) addChild(mcCollapsedTooltipIcon);
			if (hitArea) addChild(hitArea);
			
			if (_imageLoader.content)
			{
				if (_data.level < 1 && !_data.hasRequiredPointsSpent)
				{
					_imageLoader.content.alpha = 0.2;
				}
				else if(_data.hasOwnProperty("isUsingSkillDependency") && _data.isUsingSkillDependency && !_data.hasRequiredSkillDependency)
				{
					_imageLoader.content.alpha = 0.2;
				}
				else
				{
					_imageLoader.content.alpha = 1;
				}
			}
		}

		protected function handleMouseDownGrid(event:MouseEvent):void
		{
			var eventEx:MouseEventEx = event as MouseEventEx;
			if (eventEx)
			{
				switch (eventEx.buttonIdx)
				{
					case MouseEventEx.RIGHT_BUTTON:
						_mouseRMBdownStatus = true;
						startPurchaseAnimation(HOLD_TIME);
						break;
					case MouseEventEx.MIDDLE_BUTTON:
						// equip ?
						break;
					default:
						break;
				}
			}
		}
		
		protected function handleMouseUp(event:MouseEvent):void
		{
			var eventEx:MouseEventEx = event as MouseEventEx;
			if (eventEx)
			{
				switch (eventEx.buttonIdx)
				{
					case MouseEventEx.RIGHT_BUTTON:
						_mouseRMBdownStatus = false;
						stopPurchaseAnimation();
						break;
					case MouseEventEx.MIDDLE_BUTTON:
						// equip ?
						break;
					default:
						break;
				}
			}
		}

		protected function handleMouseOutGrid(event:MouseEvent):void
		{
			if(_mouseRMBdownStatus)
				stopPurchaseAnimation();
		}
		
		protected function applyAvailability():void
		{
			this.filters = []; // Reset the filters
			
			if (equipedIcon)
			{
				equipedIcon.visible = true;
				if(equipedIcon.getChildByName("mcFullColor"))
				{
					equipedIcon.mcFullColor.gotoAndStop(_data.color);

					equipedIcon.mcFullColor.alpha = (_data.isEquipped || _data.level > 0)? 1 : (_data.isUsingSkillDependency && _data.hasRequiredSkillDependency) ? 0.5 : 0;
				}

				if(_data.isEquipped) 
					equipedIcon.gotoAndStop("equipped");
				else if (_data.level > 0)
					equipedIcon.gotoAndStop("purchased");
				else if (_data.isUsingSkillDependency && _data.hasRequiredSkillDependency)
					equipedIcon.gotoAndStop("available");
				else 
					equipedIcon.gotoAndStop("none");

				if (_data.isCoreSkill)
				{
					if (coreFrame)
					{
						coreFrame.visible = true;
						coreFrame.gotoAndStop(_data.color);
					}
				}
				else
				{
					coreFrame.visible = false;
				}
			}
			
			this.alpha = 1;
			if (_data.level < 1 && !_data.hasRequiredPointsSpent)
			{
				//darkenIcon(0.2);
				
				if (_imageLoader.content)
				{
					_imageLoader.content.alpha = 0.2;
				}
				
				_isLocked = true;
			}
			else
			{
				_isLocked = false;
				
				if (_imageLoader.content)
				{
					_imageLoader.content.alpha = 1;
				}
				
			}
			
			if (unlockAnim && _data.playUpgradeAnimation)
			{
				unlockAnim.gotoAndPlay(2);
				_data.playUpgradeAnimation = false;
			}
			
			iconLock.visible = false;
		}
		
		override protected function setBackgroundColor():void
		{
			if(mcColorBackground) mcColorBackground.setBySkillType(_data.color);
		}
		
		override protected function fireTooltipShowEvent(isMouseTooltip:Boolean = false):void
		{
			//trace("GFX ** [SlotSkillGRID][", this, this.owner, "] fireTooltipShowEvent ", activeSelectionEnabled, isParentEnabled());
			
			if (!(activeSelectionEnabled || InputManager.getInstance().isMouse()) && isParentEnabled())
			{
				return;
			}
			
			if (_data)
			{
				var displayEvent:GridEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
				
				displayEvent.tooltipContentRef = "SkillTooltipRef";
				displayEvent.tooltipDataSource = "OnGetGridSkillTooltipData";
				displayEvent.isMouseTooltip = isMouseTooltip;
				displayEvent.anchorRect = getGlobalSlotRect();
				
				_tooltipRequested = true;
				dispatchEvent(displayEvent);
			}
		}
		
		override protected function fireTooltipHideEvent(isMouseTooltip:Boolean = false):void
		{
			//trace("GFX ** [SlotSkillMutagen][", this, "] fireTooltipHideEvent ", _tooltipRequested);
			
			if (_tooltipRequested)
			{
				var hideEvent:GridEvent = new GridEvent(GridEvent.HIDE_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
				
				dispatchEvent(hideEvent);
				_tooltipRequested = false;
			}
		}
		
		/*
		 * 	 Actions
		 */
		
	 	override protected function handleMouseDoubleClick(event:MouseEvent):void
		{
			//trace("GFX SlotSkillgrid::handleMouseDoubleClick");
			
			if (canExecuteAction())
			{
				executeDefaultAction(KeyCode.PAD_A_CROSS, null);
			}
		}
		
		override protected function executeDefaultAction(keyCode:Number, event:InputEvent):void
		{
			//trace("GFX SlotSkillgrid::executeDefaultAction");
			
			if ( !selectable )
			{
				return;
			}

			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
			
			if ((keyCode == KeyCode.PAD_A_CROSS || keyCode == KeyCode.ENTER || keyCode == KeyCode.NUMPAD_ENTER || keyCode == KeyCode.SPACE))
			{
				if(event && event.details && event.details.value != InputValue.KEY_UP)
					return;
				fireActionEvent(InventoryActionType.EQUIP, SlotActionEvent.EVENT_ACTIVATE);
				
				if (event)
				{
					event.handled = true;
				}
			}
			else if (keyCode == KeyCode.E ||
					(isSwitchPlatform && keyCode == KeyCode.PAD_Y_TRIANGLE) ||		// Y on switch
					(!isSwitchPlatform && keyCode == KeyCode.PAD_X_SQUARE) )		// X on other platforms
			{
				if(!event)
					fireActionEvent(InventoryActionType.SUB_ACTION, SlotActionEvent.EVENT_SECONDARY_ACTION);
				else if(event.details.value == InputValue.KEY_DOWN)
					startPurchaseAnimation(HOLD_TIME);
				else if(event.details.value == InputValue.KEY_UP)
					stopPurchaseAnimation();

				if (event && event.details.value == InputValue.KEY_DOWN)
				{
					event.handled = true;
				}
			}
		}
		
		override public function executeAction(keyCode:Number, event:InputEvent):Boolean
		{
			if (canExecuteAction())
			{
				executeDefaultAction(keyCode, event);
				return true;
			}
			return false;
		}
		
		/*
		 * 		- Drag & Drop -
		 */
		
		override public function canDrag():Boolean
		{
			return _data && !isLocked && _data.level > 0 && !data.isCoreSkill;
		}
		
		override public function canDrop(dragData:IDragTarget):Boolean
		{
			return false;
		}
		
		override protected function initDropTarget():void
		{
			// none
		}

		public function onDie():void
		{
			fireTooltipHideEvent();
		}

		function splitEase(timePercent:Number, progressPercent:Number):Function
		{
			return function(ratio : Number, unused1 : Number, unused2 : Number, unused3 : Number)
			{
				if(ratio <= timePercent)
				{
					var p:Number = ratio / timePercent;

					p = p * p * (3 - 2 * p);
					return progressPercent * p;
				}
				else
				{
					p = (ratio-timePercent) / (1 - timePercent);
					p = p * p * (3 - 2 * p);

					return progressPercent + (1 - progressPercent) * p;
				}
			}
		}

		public function startPurchaseAnimation(time:Number)
		{
			if(_data.isUsingSkillDependency && _data.hasRequiredSkillDependency && _data.level < 3)
			{	
				GTweener.removeTweens(equipedIcon.mcFullColor);

				GTweener.to(equipedIcon.mcFullColor, time - 0.05, {alpha:1},{ease:LinearEase.easeIn, onComplete:completePurchase});
				
				if(mcHoldAnimBlock)
				{
					mcHoldAnimBlock.y = 64;
					mcHoldAnimBlock.height = 0;
					mcHoldAnimBlock.alpha = 0.5;
					mcHoldAnimBlock.visible = true;

					GTweener.removeTweens(mcHoldAnimBlock);
					GTweener.to(mcHoldAnimBlock, time, {height:62, y:2});
					GTweener.to(mcHoldAnimBlock, time, {alpha:0}, {ease:splitEase(0.75,0.25)});
					//GTweener.to(mcHoldAnimBlock, 3 * time / 4, {alpha:0.33}, {ease:LinearEase.easeIn, 
					//onComplete: function(){GTweener.to(mcHoldAnimBlock, time/4, {alpha: 0}, {ease:Exponential.easeOut})}});
				}
			}
		}

		public function stopPurchaseAnimation()
		{
			var DEFAULT_BACK_TIME:Number = 0.2;
			GTweener.removeTweens(equipedIcon.mcFullColor);

			if(mcHoldAnimBlock)
			{
				mcHoldAnimBlock.visible = false;
				GTweener.removeTweens(mcHoldAnimBlock);
			}

			if(_data.isUsingSkillDependency && _data.hasRequiredSkillDependency)
			{
				var afterAlpha = _data.level > 0 ? 1 : 0.5
				GTweener.to(equipedIcon.mcFullColor, DEFAULT_BACK_TIME, {alpha:afterAlpha});
			}
		}

		public function completePurchase()
		{
			fireActionEvent(InventoryActionType.SUB_ACTION, SlotActionEvent.EVENT_SECONDARY_ACTION);
		}

		public override function set selected(value:Boolean):void
		{
			super.selected = value;
			if(!value)
			{
				stopPurchaseAnimation();
			}
		}
		
	}
}
