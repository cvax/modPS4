package red.game.witcher3.hud.modules.lootpopup
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import red.core.CoreComponent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.RenderersList;
	import red.game.witcher3.menus.common.ColorSprite;
	import scaleform.clik.constants.InvalidationType;
	import scaleform.clik.controls.ListItemRenderer;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.controls.BaseListItem;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.managers.InputManager;
	import flash.events.MouseEvent;
	import red.game.witcher3.events.ControllerChangeEvent;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import scaleform.gfx.MouseEventEx;
	import red.core.constants.KeyCode;
	import scaleform.clik.events.InputEvent;
	import flash.events.Event;

	public class HudLootItemsListItem extends BaseListItem
	{

	//{region Private variables
	// ------------------------------------------------

	private var bTakeAllItem : Boolean = false;
	protected var _over:Boolean;

	protected var _isMouse:Boolean;

	//{region Private constants
	// ------------------------------------------------
	private static const TEXT_PADDING:Number = 4;
	private static const READ_BOOK_ALPHA:Number = .3;
	protected static const RECT_MARGIN:Number = 0; //15;

	//{region Art clips
	// ------------------------------------------------

	public var tfType : TextField;
	public var tfQuantity : TextField;
	public var mcFrame : MovieClip;
	public var mcIconLoader : W3UILoader;
	public var mcColorBackground : ColorSprite;
	public var genStatsList : RenderersList;
	
	public var mcQuestIndicator : MovieClip;

	//{region Initialization
	// ------------------------------------------------

		public function HudLootItemsListItem()
		{
			super();
			tfType.text = "";
			tfQuantity.text = "";
			textField.text = "";
			visible = false;
		}

	//{region Overrides
	// ------------------------------------------------

		override public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			// Do nothing.
			// Stops the unwanted resizing behavior because the movie clip has a different frame size when showing an icon.

		}

		override protected function configUI():void
		{
			super.configUI();
			config_init_call();
		}

		public function setStateOver()
		{
			this.setState("over");
		}

		override public function setData( data:Object ):void
		{
			if (data)
			{
				if ( data.label && data.label != "" )
				{
					super.setData( data );
				}
				if ( data.quantity && tfQuantity && data.quantity > 1 )
				{
					tfQuantity.text = "x" + data.quantity;
				}
				else
				{
					tfQuantity.text = "";
				}
				if( data.iconPath && mcIconLoader )
				{
					if ( data.iconPath != "" )
					{
						mcIconLoader.source = "img://" + data.iconPath;
					}
					else
					{
						mcIconLoader.source = "";
					}
				}
				if (mcIconLoader)
				{
					mcIconLoader.alpha = data.isRead ? READ_BOOK_ALPHA : 1;
				}
				if (mcQuestIndicator)
				{
					if (data.isQuestItem)
					{
						mcQuestIndicator.visible = true;
						mcQuestIndicator.gotoAndStop(data.questTag);
					}
					else
					{
						mcQuestIndicator.visible = false;
					}
				}
				if (mcColorBackground && data.quality)
				{
					mcColorBackground.visible = true;
					mcColorBackground.colorBlind = CoreComponent.isColorBlindMode;
					mcColorBackground.setByItemQuality(_data.quality);
				}
				else
				{
					mcColorBackground.visible = false;
				}
				if (genStatsList && data.genericStats)
				{
					genStatsList.dataList = data.genericStats;
					genStatsList.validateNow();
				}
				
				updateTypeText();
			}
			else
			{
				visible = false;
			}
		}
		
		override protected function updateText():void
		{
			const SINGLE_LINE_TF1 = 30;
			const SINGLE_LINE_TF2 = 47;
			const DOUBLE_LINE_TF1 = 17;
			const DOUBLE_LINE_TF1_LARGE = 6;
			const DOUBLE_LINE_TF2 = 53;
			const DOUBLE_LINE_TF2_LARGE = 58;
			const ARAB_TEXT_LIMIT = 34;
			const NO_TYPE		  = 30;
			
			super.updateText();
			updateTypeText();
			
			textField.height = textField.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			
			// #Y textField.numLines returns incorrect value for arabic :E
			if ((textField.numLines > 1 && !CoreComponent.isArabicAligmentMode) || (CoreComponent.isArabicAligmentMode && textField.height > ARAB_TEXT_LIMIT))
			{
				textField.y = DOUBLE_LINE_TF1_LARGE;
				tfType.y = DOUBLE_LINE_TF2_LARGE;
			}
			else
			{
				if (data && data.itemType)
				{
					textField.y = DOUBLE_LINE_TF1;
					tfType.y = SINGLE_LINE_TF2;
				}
				else
				{
					textField.y = SINGLE_LINE_TF1;
					tfType.y = SINGLE_LINE_TF2;
				}
			}
		}
		
		protected function updateTypeText():void
		{
			if (data && data.itemType)
			{
				if ( CoreComponent.isArabicAligmentMode )
				{
					tfType.htmlText = "<p align=\"right\">" + data.itemType + "</p>";
				}
				else
				{
					tfType.htmlText = data.itemType;
				}
			}
			else
			{
				tfType.htmlText = "";
			}
		}

		protected function selectingTooltipShowCheck():Boolean
		{
			return true; // !InputManager.getInstance().isMouse();
		}

		protected var _useContextMgr:Boolean = true;
		public function get useContextMgr():Boolean { return _useContextMgr }
		public function set useContextMgr(value:Boolean):void
		{
			_useContextMgr = value;
		}

		protected function handleMouseOver(event:MouseEvent):void
		{
			var isMouse:Boolean = InputManager.getInstance().isMouse();
			
			//trace("GFX [SLOT handleMouseOver][", this, "]; _over: ", _over, "; _isEmpty: ", _isEmpty, "; isMouse: ", isMouse);
			
			if (useContextMgr && isMouse)
			{
				updateMouseContext();
			}
			
			if (!_over && isMouse && selectable)
			{
				_over = true;
				fireTooltipShowEvent(true);
			}
			
			invalidateState();
		}

		protected function handleMouseOut(event:MouseEvent):void
		{
			var isMouse:Boolean = InputManager.getInstance().isMouse();
			//trace("GFX [SLOT handleMouseOut][", this, "]; _over: ", _over, "; _isEmpty: ", _isEmpty, "; isMouse: ", isMouse);
			if (_over && isMouse && selectable)
			{
				_over = false;
				fireTooltipHideEvent(true);
			}
			invalidateState();
		}
		
		protected function handleMouseDown(event:MouseEvent):void
		{
			// virtual
		}
		
		protected function updateMouseContext():void
		{
			// virtual
		}

		protected function executeDefaultAction(keyCode:Number, event:InputEvent):void
		{

		}

		protected function canExecuteAction():Boolean
		{
			return _data;
		}
		
		protected function handleMouseDoubleClick(event:MouseEvent):void
		{
			var superMouseEvent:MouseEventEx = event as MouseEventEx;
			if (superMouseEvent && superMouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON)
			{
				if (canExecuteAction())
				{
					executeDefaultAction(KeyCode.PAD_A_CROSS, null);
				}
			}
		}
		
		protected function handleMouseClick(event:MouseEvent):void
		{
			
		}

		protected function handleControllerChanged(event:ControllerChangeEvent):void
		{
			_isMouse = event.isMouse;
			invalidateState();
		}

		protected function config_init_call():void
		{
			doubleClickEnabled = true;
			var hitArea:MovieClip = this as MovieClip;
			
			hitArea.doubleClickEnabled = true;
			hitArea.addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver, false, 0, true);
			hitArea.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut, false, 0, true);
			hitArea.addEventListener(MouseEvent.DOUBLE_CLICK, handleMouseDoubleClick, false, 0, true);
			hitArea.addEventListener(MouseEvent.CLICK, handleMouseClick, false, 0, true);

			_isMouse = InputManager.getInstance().isMouse();
			InputManager.getInstance().addEventListener(ControllerChangeEvent.CONTROLLER_CHANGE, handleControllerChanged, false, 0, true);
		}


protected var _activeSelectionEnabled:Boolean = true;
		public function get activeSelectionEnabled():Boolean
		{
			if (_activeSelectionEnabled)
			{
				return true;
			}
			return false;
		}
		public function set activeSelectionEnabled(value:Boolean):void
		{
			_activeSelectionEnabled = value;
			invalidateState();
			
			///trace("GFX [SlotBase][", this, "] activeSelectionEnabled ", value, "; selected ", selected, "; ", isParentEnabled());
			
			if ( selectingTooltipShowCheck() )
			{
				if (value && selected)
				{
					fireTooltipShowEvent(false);
				}
				else
				{
					fireTooltipHideEvent(false)
				}
			}
		}

		public override function set selected(value : Boolean):void
		{
			super.selected = value;

			if ( selectingTooltipShowCheck() )
			{
				if (_selected)
				{
					showTooltip();
				}
				else
				{
					hideTooltip();
				}
			}
		}

		// Get slot rect in stage coordinate system
		public function getRectGlobal():Rectangle
		{
			var targetRect:Rectangle = this.getRect(this);
			var globalPoint:Point =	localToGlobal(new Point(targetRect.x, targetRect.y));
			targetRect.x = globalPoint.x + RECT_MARGIN;
			targetRect.y = globalPoint.y + RECT_MARGIN;

			//meh, need to have a recursive scaler, but works for the LootPopup
			targetRect.width = width * scaleX * parent.scaleX; 
			targetRect.height = height * scaleY * parent.scaleY;
			return targetRect;
		}

		// We use pending because of problem with data transfering during one tick
		public function showTooltip():void
		{
			//trace("GFX [SlotBase][", this, "] TP [", this.index, "] <", owner, "> showTooltip; parent enabled: ", isParentEnabled());
			if (selectingTooltipShowCheck())
			{
				removeEventListener(Event.ENTER_FRAME, pendedTooltipShow);
				removeEventListener(Event.ENTER_FRAME, pendedTooltipHide);
				addEventListener(Event.ENTER_FRAME, pendedTooltipShow, false, 0, true);
			}
		}
		
		public function hideTooltip():void
		{
			//trace("GFX [SlotBase][", this, "] TP [", this.index, "] <", owner, "> hideTooltip; parent enabled: ", isParentEnabled());
			if (selectingTooltipShowCheck())
			{
				removeEventListener(Event.ENTER_FRAME, pendedTooltipShow);
				removeEventListener(Event.ENTER_FRAME, pendedTooltipHide);
				addEventListener(Event.ENTER_FRAME, pendedTooltipHide, false, 0, true);
			}
		}

		protected function pendedTooltipShow(event:Event):void
		{
			//trace("GFX [SlotBase][", this, "] TP pendedTooltipShow ", selectable, "]--");
			removeEventListener(Event.ENTER_FRAME, pendedTooltipShow);
			if (selectable)
			{
				fireTooltipShowEvent(false);
			}
		}
		protected function pendedTooltipHide(event:Event):void
		{
			//trace("GFX [SlotBase][", this, "] TP pendedTooltipHide ", selectable, "]--");
			removeEventListener(Event.ENTER_FRAME, pendedTooltipHide);
			if (selectable)
			{
				fireTooltipHideEvent(false);
			}
		}

		protected var _tooltipRequested:Boolean;
		protected var _defaultTooltipAnchor:String = "tooltipLeftAnchor";
		protected function fireTooltipShowEvent(isMouseTooltip:Boolean = false):void
		{
			if ((activeSelectionEnabled || _isMouse) && _data)
			{
				var displayEvent:GridEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
				
				displayEvent.isMouseTooltip = isMouseTooltip;
				displayEvent.anchorRect = getRectGlobal();
				displayEvent.defaultAnchor = _defaultTooltipAnchor;
				displayEvent.tooltipAlignment = CommonConstants.ALIGNMENT_RIGHT;
				
				if (!_data.showExtendedTooltip)
				{
					displayEvent.tooltipContentRef = "ItemDescriptionTooltipRef";
				}
				
				displayEvent.tooltipMouseContentRef = "ItemTooltipRef_mouse";
				
				dispatchEvent(displayEvent);
				_tooltipRequested = true;
			}
		}

		protected function fireTooltipHideEvent(isMouseTooltip:Boolean = false):void
		{
			//trace("GFX [SlotBase][", this, "] fireTooltipHideEvent ", isMouseTooltip, _tooltipRequested);
			
			if (_tooltipRequested)
			{
				var hideEvent:GridEvent = new GridEvent(GridEvent.HIDE_TOOLTIP, true, false, index, -1, -1, null, _data as Object);
				dispatchEvent(hideEvent);
				_tooltipRequested = false;
			}
		}

	}

}
