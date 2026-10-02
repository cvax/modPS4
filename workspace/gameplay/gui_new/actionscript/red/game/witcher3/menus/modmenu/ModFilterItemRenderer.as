/***********************************************************************
/** Mod filter item
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.ListEvent;
	
	import red.core.CoreComponent;
	import red.core.events.GameEvent;

	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.menus.common.IconItemRenderer;
	import red.game.witcher3.controls.W3DropDownItemRenderer;
	import red.game.witcher3.events.GridEvent;

	public class ModFilterItemRenderer extends IconItemRenderer
	{
		public static const NoException:int = 0;
		
		public static const PINNED_EVENT:String = "PinChangedEvent";

		public var mcItemQuality		: MovieClip;
		public var mcCheckbox			: MovieClip;
		public var mcRadio				: MovieClip;
		public var mcAdditionalHighlight: MovieClip;

		public var bValue				: 	int;
		private var i_filterIndex		:	int;
		private var i_index				:	int;
		private var isRadio				:	Boolean;
		private var i_category			:	int;
		
		protected static var _currentPinnedTag:uint;
		public static function setCurrentPinnedTag(stage:Stage, value:uint):void
		{
			_currentPinnedTag = value;
			stage.dispatchEvent(new Event(PINNED_EVENT));
		}

		public function ModFilterItemRenderer()
		{
			super();
			skipTextCentering = false;
			canBePressed = false;
		}

		override protected function configUI():void
		{
			super.configUI();
			
			mouseChildren = true;
			if(mcCheckbox) 
			{
				mcCheckbox.mouseEnabled = true;
			}
			if(mcRadio) 
			{
				mcRadio.mouseEnabled = true;
			}
			addEventListener(MouseEvent.CLICK,onCheckboxClicked);
		}

		override public function setData( data:Object ):void
		{
			super.setData(data);

			if(data.radio)
			{
				isRadio = true;
			}
			setGraphics();
			setEnabled(data.value);
			i_index = data.index;
			i_filterIndex = data.filterIndex;
			if(data.category)
				i_category = data.category;

			// #J If data is set while already selected, we need to send the tooltip manually as the normal selection logic that sends the tooltip won't be called (since it won't if theres no data set at the time of selection).
			if (selected)
			{
				fireShowTooltipEvent();
			}
			
			if (mcItemQuality)
			{
				mcItemQuality.gotoAndStop(data.rarity);
			}
			updateRTL();
		}

		override protected function updateText():void
		{
			super.updateText();

            if (_label != null && textField != null)
			{
				textField.y = 2.95;
            }
			
        }

		override public function handleEntryPress() : void
		{
			// #J Override to remove base class behavior
		}

		override public function handleInput(event:InputEvent):void
		{
			// #J Override to remove base class behavior
		}

		public function fireShowTooltipEvent():void
		{
			var displayEvent:GridEvent;
			displayEvent = new GridEvent(GridEvent.DISPLAY_TOOLTIP, true, false, index, -1, -1, null, null);
			displayEvent.tooltipContentRef = "ItemTooltipRef";
			displayEvent.tooltipDataSource = "OnShowCraftedItemTooltip";
			displayEvent.tooltipCustomArgs = [ data.tag ];
			dispatchEvent(displayEvent);
		}

		override public function toString() : String
		{
			return "[W3 ModFilterItemRenderer ", data.label ,"]"
		}

		public function setEnabled(value : int):void
		{
			bValue = value;
			data.value = value;

			if(value == 1)
				mcAdditionalHighlight.gotoAndStop("on");
			else if(value == 2)
				mcAdditionalHighlight.gotoAndStop("exclude");
			else
				mcAdditionalHighlight.gotoAndStop("off");

			if(isRadio)
			{
				if(value == 1)
					mcRadio.gotoAndStop("on");
				else if(value == 2)
					mcRadio.gotoAndStop("exclude");
				else
					mcRadio.gotoAndStop("off");
			}
			else
			{
				if(value == 1)
					mcCheckbox.gotoAndStop("on");
				else if(value == 2)
					mcCheckbox.gotoAndStop("exclude");
				else
					mcCheckbox.gotoAndStop("off");
			}
		}

		public function onEnabledChange():void
		{
			var cycledValue : int = bValue + 1;
				if(cycledValue == 3)
					cycledValue = 0;
			if(isRadio)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnRadioClicked", [i_filterIndex, i_index, cycledValue, i_category] ) );
				//here we don't change value because we notify WS that notifies the Browse panel to change every category value
			}
			else {
				setEnabled(cycledValue);
				dispatchEvent( new GameEvent( GameEvent.CALL, "OnFilterCheckboxClicked", [i_filterIndex, i_index, bValue] ) );
			}
		}

		protected function onCheckboxClicked(event:MouseEvent):void
		{
			onEnabledChange()
		}

		protected function setGraphics():void
		{
			if(isRadio)
			{
				mcRadio.visible = true;
				mcCheckbox.visible = false;
			}
			else
			{
				mcRadio.visible = false;
				mcCheckbox.visible = true;
			}
		}

		private function isLTRSetup()
		{
			if(isRadio)
				return mcRadio.x < textField.x;
			else
				return mcCheckbox.x < textField.x;
		}

		public function updateRTL()
		{
			var radioX : Number;
			var checkboxX : Number;
			var textfieldX : Number;

			if(mcRadio)
				radioX = mcRadio.x;
			if(mcCheckbox)
				checkboxX = mcCheckbox.x;
			
			textfieldX = textField.x;

			if(isLTRSetup() && CoreComponent.isArabicAligmentMode)
			{
				if(mcRadio) {
					mcRadio.x = textfieldX + textField.width - mcRadio.width / 2;
					textField.x = radioX - mcRadio.width / 2;
				}
				if (mcCheckbox) {
					textField.x = checkboxX - mcCheckbox.width / 2;
					mcCheckbox.x = textfieldX + textField.width - mcCheckbox.width / 2;
				}
			}
			else if(!isLTRSetup() && !CoreComponent.isArabicAligmentMode)
			{
				if(mcRadio) {
					mcRadio.x = textfieldX + mcRadio.width / 2;
					textField.x = radioX - textField.width + mcRadio.width / 2;
				}
				if (mcCheckbox) {
					mcCheckbox.x = textfieldX + mcCheckbox.width / 2;
					textField.x = checkboxX - textField.width + mcCheckbox.width / 2;
				}
			}
		}
	}

}
