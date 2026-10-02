/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2015 CDProjektRed
/** Author : 	Jason Slama
/***********************************************************************/

package red.game.witcher3.menus.common
{
	import flash.text.TextField;
	import flash.display.MovieClip;
	import red.game.witcher3.controls.BaseListItem;
	import scaleform.clik.core.UIComponent;
	import red.core.CoreComponent;
	
	public class CheckboxListItem extends BaseListItem
	{
		public var mcCheckbox : MovieClip;
		public var mcSelection : MovieClip;

		public var mcCheckboxLabeled : MovieClip;
		
		protected var _isChecked:Boolean = false;
		public function get isChecked() : Boolean
		{
			return _isChecked;
		}
		public function set isChecked(value:Boolean):void
		{
			if (_isChecked == value)
			{
				return;
			}
			
			_isChecked = value;
			
			updateCheckbox();
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			updateCheckbox();
		}
		
		protected function updateCheckbox():void
		{
			if (mcCheckbox)
			{
				if (_isChecked)
				{
					mcCheckbox.gotoAndStop("on");
				}
				else
				{
					mcCheckbox.gotoAndStop("off");
				}
			}
			else if (mcCheckboxLabeled)
			{
				if (mcCheckboxLabeled.mcCheckbox)
				{
					if (_isChecked)
					{
						mcCheckboxLabeled.mcCheckbox.gotoAndStop("on");
					}
					else
					{
						mcCheckboxLabeled.mcCheckbox.gotoAndStop("off");
					}
				}
			}
			updateRTL();
		}
		
		protected var _groupID:String = "";
		public function get groupID():String { return _groupID }
		public function set groupID( value:String ):void { _groupID = value; }
		
		protected var _dataKey:String = "";
		public function get dataKey():String { return _dataKey }
		public function set dataKey( value:String ):void { _dataKey = value; }
		
		override public function setData( data:Object ):void
		{
			super.setData(data);
			
			if (data)
			{
				isChecked = data.isChecked;
				dataKey = data.key;
				
				if (data.hasOwnProperty("groupId") && data.groupId != "")
				{
					groupID = data.groupId;
				}
				else
				{
					groupID = "";
				}
			}
			updateRTL();
		}

		//overriding this coz the base function doesn't use htmlText which doesn't allow us to employ colors
        override protected function updateText():void
		{
            if (_label != null && textField != null)
			{
				if ( CoreComponent.isArabicAligmentMode )
				{
					textField.htmlText = "<p align=\"right\">" + _label + "</p>";
					return;
				}
                textField.htmlText = _label;
            }
			else if (mcCheckboxLabeled)
			{
				if(_label != null && mcCheckboxLabeled.textField != null)
				{
					if ( CoreComponent.isArabicAligmentMode )
					{
						mcCheckboxLabeled.textField.htmlText = "<p align=\"right\">" + _label + "</p>";
						return;
					}
					mcCheckboxLabeled.textField.htmlText = _label;
				}
			}
        }

		public function setLabel(lbl : String):void
		{
			if(_label)
			{
				_label = lbl;
				updateText();
			}
			updateRTL();
		}

		public function getTextField():TextField
		{
			if(textField)
				return textField;
			if(mcCheckboxLabeled && mcCheckboxLabeled.textField)
				return mcCheckboxLabeled.textField;

			return null;
		}

		private function isLTRSetup()
		{
			return mcCheckbox.x < textField.x;
		}

		public function updateRTL()
		{
			var checkboxX : Number;
			var textfieldX : Number;

			if(mcCheckbox)
				checkboxX = mcCheckbox.x;
			
			textfieldX = textField.x;
			if(isLTRSetup() && CoreComponent.isArabicAligmentMode)
			{
				if (mcCheckbox) {
					textField.x = checkboxX - mcCheckbox.width / 2;
					mcCheckbox.x = textfieldX + textField.width - mcCheckbox.width / 2;
				}
			}
			else if(!isLTRSetup() && !CoreComponent.isArabicAligmentMode)
			{
				if (mcCheckbox) {
					mcCheckbox.x = textfieldX + mcCheckbox.width / 2;
					textField.x = checkboxX - textField.width + mcCheckbox.width / 2;
				}
			}
		}

	}
}