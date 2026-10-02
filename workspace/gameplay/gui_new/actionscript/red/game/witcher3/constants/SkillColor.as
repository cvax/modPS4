package red.game.witcher3.constants
{
	public class SkillColor
	{
		public static var none:String = "SC_None";
		public static var red:String = "SC_Red";
		public static var blue:String = "SC_Blue";
		public static var green:String = "SC_Green";
		public static var redblue:String = "SC_RedBlue";
		public static var redgreen:String = "SC_RedGreen";
		public static var bluegreen:String = "SC_BlueGreen";
		public static var redwhite:String = "SC_RedWhite";
		public static var greenwhite:String = "SC_GreenWhite";
		public static var bluewhite:String = "SC_BlueWhite";
		public static var yellow:String = "SC_Yellow";
		
		public static function nameToEnum(value:String):uint
		{
			switch (value)
			{
				case none: return 0;
				case blue: return 1;
				case green: return 2;
				case red: return 3;
				case redblue: return 4;
				case redgreen: return 5;
				case bluegreen: return 6;
				case redwhite: return 7;
				case greenwhite: return 8;
				case bluewhite: return 9;
				case yellow: return 10;
				
			}
			return 0;
		}
		
		public static function enumToName(value:uint):String
		{
			switch (value)
			{
				case 0: return none;
				case 1: return blue;
				case 2: return green;
				case 3: return red;
				case 4: return redblue;
				case 5: return redgreen;
				case 6: return bluegreen;
				case 7: return redwhite;
				case 8: return greenwhite;
				case 9: return bluewhite;
				case 10: return yellow;
			}
			return none;
		}
		
		public static function enumToColor(value:uint):Number
		{
			switch (value)
			{
				case 0: return 0xFFFFFF;
				case 1: return 0x65b7fd;
				case 2: return 0x97fd65;
				case 3: return 0xfd5353;
				case 4: return 0xFFFF59;
			}
			return 0xFFFFFF;
		}
	}

}
