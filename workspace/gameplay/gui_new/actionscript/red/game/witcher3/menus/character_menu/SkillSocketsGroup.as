package red.game.witcher3.menus.character_menu
{
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	import red.game.witcher3.events.SlotConnectorEvent;
	import red.game.witcher3.slots.SlotSkillMutagen;
	import red.game.witcher3.slots.SlotSkillSocket;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.core.UIComponent;
	
	/**
	 * ...
	 * @author Yaroslav Getsevich
	 */
	public class SkillSocketsGroup extends EventDispatcher
	{
		public var mutagenSlot:SlotSkillMutagen;
		public var dnaBranch:MovieClip;
		public var connector:SkillSlotConnector;
		public var bonusText:TextField;
		
		protected var _skillSlotConnectorsList:Vector.<SkillSlotConnector>;
		protected var _skillSlotRefs:Vector.<SlotSkillSocket>;
		protected var _currentColor:String;
		protected var _mutagenData:Object;
		
		public function SkillSocketsGroup()
		{
			_skillSlotConnectorsList	= new Vector.<SkillSlotConnector>;
			_skillSlotRefs = new Vector.<SlotSkillSocket>;
		}
		
		public function addSlotConnector(targetSlot:SkillSlotConnector):void
		{
			_skillSlotConnectorsList.push(targetSlot);
		}
		
		public function addSlotSkillRef(targetRef:SlotSkillSocket)
		{
			_skillSlotRefs.push(targetRef);
		}
		
		public function get mutagenData():Object { return _mutagenData }
		public function set mutagenData(value:Object):void
		{
			trace("GFX [SkillSocketsGroup] set mutagenData ------------- ", value);
			
			if (value)
			{
				trace("GFX ", value.color);
			}
			
			_mutagenData = value;
			_mutagenData.gridSize = 1;
			mutagenSlot.cleanup();
			mutagenSlot.data = _mutagenData;
			updateData();
		}

		public function isMutagenRare(mutagenColor : String):Boolean
		{
			return mutagenColor == COLOR_REDBLUE || mutagenColor == COLOR_REDGREEN || mutagenColor == COLOR_BLUEGREEN
				|| mutagenColor == COLOR_REDWHITE || mutagenColor == COLOR_GREENWHITE || mutagenColor == COLOR_BLUEWHITE;
		}
		
		const COLOR_NONE:String = "SC_None";
		const COLOR_MIX:String = "SC_Mix";
		const COLOR_RED:String = "SC_Red";
		const COLOR_GREEN:String = "SC_Green";
		const COLOR_BLUE:String = "SC_Blue";
		const COLOR_WHITE:String = "SC_Yellow";
		const COLOR_REDBLUE:String = "SC_RedBlue";
		const COLOR_REDGREEN:String = "SC_RedGreen";
		const COLOR_BLUEGREEN:String = "SC_BlueGreen";
		const COLOR_REDWHITE:String = "SC_RedWhite";
		const COLOR_GREENWHITE:String = "SC_GreenWhite";
		const COLOR_BLUEWHITE:String = "SC_BlueWhite";
		public function updateData():void
		{
			var skillExist:Boolean;
			var notNullAny:Boolean;
			var len:int = _skillSlotConnectorsList.length;
			var i:int;
			var mutagenColor:String = mutagenSlot.data ? mutagenSlot.data.color : COLOR_NONE;
			skillExist = false;
			notNullAny = true;
			
			if (_skillSlotRefs.length != _skillSlotConnectorsList.length)
			{
				throw new Error("GFX [ERROR] " + this + " has invalid number of skills to connectors: " + _skillSlotRefs.length + ", " + _skillSlotConnectorsList.length);
			}
			
			/*
			trace("GFX [SkillSocketsGroup][", mutagenSlot, "] ------------------------------ updateData ", mutagenColor, mutagenSlot.data);
			
			if( mutagenSlot.data )
			{
				trace("GFX * ", mutagenSlot.data.color );
			}
			*/
			/*var txt : String = "";
			for (i = 0; i < len; i++)
			{
				if(txt.length > 0)
					txt += ", ";
				if(_skillSlotRefs[i].data != null)
					txt += _skillSlotRefs[i].data.color;
				else
					txt += "null";
			}
			trace("GFX -_skillSlotRefs[i].data.color s:",txt);
			*/
			for (i = 0; i < len; i++)
			{
				if (_skillSlotConnectorsList[i])
				{
					if (mutagenColor != COLOR_NONE && _skillSlotRefs[i].data != null && mutagenColor == _skillSlotRefs[i].data.color)
					{
						_skillSlotConnectorsList[i].currentColor = mutagenColor;
						skillExist = true;
					}
					else if (isMutagenRare(mutagenColor))
					{
						if(_skillSlotRefs[i].data != null)
						{
							if(mutagenColor == COLOR_REDBLUE && (_skillSlotRefs[i].data.color == COLOR_RED || _skillSlotRefs[i].data.color == COLOR_BLUE))
							{
								_skillSlotConnectorsList[i].currentColor = _skillSlotRefs[i].data.color;
								skillExist = true;
							}
							else if(mutagenColor == COLOR_REDGREEN && (_skillSlotRefs[i].data.color == COLOR_RED || _skillSlotRefs[i].data.color == COLOR_GREEN))
							{
								_skillSlotConnectorsList[i].currentColor = _skillSlotRefs[i].data.color;
								skillExist = true;
							}
							else if(mutagenColor == COLOR_BLUEGREEN && (_skillSlotRefs[i].data.color == COLOR_BLUE || _skillSlotRefs[i].data.color == COLOR_GREEN))
							{
								_skillSlotConnectorsList[i].currentColor = _skillSlotRefs[i].data.color;
								skillExist = true;
							}
							else if(mutagenColor == COLOR_REDWHITE && (_skillSlotRefs[i].data.color == COLOR_RED || _skillSlotRefs[i].data.color == COLOR_WHITE))
							{
								_skillSlotConnectorsList[i].currentColor = _skillSlotRefs[i].data.color;
								skillExist = true;
							}
							else if(mutagenColor == COLOR_GREENWHITE && (_skillSlotRefs[i].data.color == COLOR_GREEN || _skillSlotRefs[i].data.color == COLOR_WHITE))
							{
								_skillSlotConnectorsList[i].currentColor = _skillSlotRefs[i].data.color;
								skillExist = true;
							}
							else if(mutagenColor == COLOR_BLUEWHITE && (_skillSlotRefs[i].data.color == COLOR_BLUE || _skillSlotRefs[i].data.color == COLOR_WHITE))
							{
								_skillSlotConnectorsList[i].currentColor = _skillSlotRefs[i].data.color;
								skillExist = true;
							}
							else 
							{
								_skillSlotConnectorsList[i].currentColor = COLOR_NONE;
							}
						}
						else
						{
							notNullAny = false;
						}
					}
					else if(_skillSlotRefs[i].data != null)
					{
						_skillSlotConnectorsList[i].currentColor = COLOR_NONE;
					}
					else
					{
						notNullAny = false;
					}
				}
			}
			
			if (skillExist)
			{
				connector.currentColor = mutagenColor;
			}
			else if(notNullAny) // #LT <-- this is because the data is transfered one by one for each skill 
			// (red, null, null)->(red,none,null)->(red,none,green) for example, so linkage won't break if the first skill is not good for the mutagen but another skill is good
			{
				connector.currentColor = COLOR_NONE;
			}
		}
		
		protected function getGroupColor(colorsList:Array):String
		{
			var curGroupColor:String = COLOR_NONE;
			var len:int = colorsList.length;
			for (var i:int; i < len; i++)
			{
				if (colorsList[i] != curGroupColor && colorsList[i] != COLOR_NONE)
				{
					if (curGroupColor == COLOR_NONE)
					{
						curGroupColor = colorsList[i];
					}
					else
					{
						return COLOR_NONE;
					}
				}
			}
			return curGroupColor;
		}
		
		protected function getGroupBonus(groupColor:String):String
		{
			return "";
		}
		
	}
}
