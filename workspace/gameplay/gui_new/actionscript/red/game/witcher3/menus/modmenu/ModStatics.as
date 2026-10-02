/***********************************************************************
/** static class for the mod menu
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{
	import flash.events.Event;
    import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import scaleform.clik.core.UIComponent;

	import red.core.CoreComponent;
	import red.core.CoreMenu;	
	import red.core.events.GameEvent;
	import red.game.witcher3.utils.CommonUtils;

	public class ModStatics extends EventDispatcher
	{
		public static const MOD_PREVIEW_GAP_X = 10;
		public static const MOD_PREVIEW_GAP_Y = 10;
		public static const MOD_PREVIEW_LINE_MEMBER_COUNT = 5;
		public static const MOD_PREVIEW_MAXLINES = 3;

		public static const MFST_ID = 0;
		public static const MFST_LoadOrder = 1;
		public static const MFST_DownloadsToday = 2;
		public static const MFST_SubscriberCount = 3;
		public static const MFST_Rating = 4;
		public static const MFST_DateMarkedLive = 5;
		public static const MFST_DateUpdated = 6;
		public static const MFST_DownloadsTotal = 7;
		public static const MFST_Alphabetical = 8;
		public static const	MFSD_Ascending = 9;
		public static const MFSD_Descending = 10;

        private static var modMenu : ModMenu;
        private static var instance : ModStatics;
        public static function getInstance():ModStatics
        {
            if(instance == null)
                instance = new ModStatics();
            
            return instance;
        }

        public static function getModMenu():ModMenu
        {
            return modMenu;
        }

        public static function setModMenu(m : ModMenu):void
        {
            modMenu = m;
        }

		public static function formatBytes(value:Number):String
		{
			const KB:Number = 1024;
			const MB:Number = KB * 1024;
			const GB:Number = MB * 1024;
			const TB:Number = GB * 1024;

			var bText : String = CommonUtils.getLocalization("panel_mods_size_b");
			var kbText : String = CommonUtils.getLocalization("panel_mods_size_kb");
			var mbText : String = CommonUtils.getLocalization("panel_mods_size_mb");
			var gbText : String = CommonUtils.getLocalization("panel_mods_size_gb");
			var tbText : String = CommonUtils.getLocalization("panel_mods_size_tb");

			var retStr : String = "";

			if(value >= TB)
			{
				retStr = (value / TB).toFixed(1) + tbText;
			}
			else if(value >= GB / 2)
			{
				retStr =  (value / GB).toFixed(1) + gbText;
			}
			else if(value >= MB * 10)
			{
				retStr =  (value / MB).toFixed(0) + mbText;
			}
			else if(value >= MB / 10)
			{
				retStr =  (value / MB).toFixed(1) + mbText;
			}
			else if(value >= KB)
			{
				retStr = Math.round(value / KB) + kbText;
			}
			else
				retStr = value + bText;
			
			return convertNumberString(retStr);
		}

		public static function formatNumber(value:int):String
		{
			var rnd:String;
			var retStr:String = "";
			if(value >= 500000)
			{
				//rounding to nearest 100K then dividing with 10 later so it would show like 1.1M
				rnd = (value / 1000000).toFixed(1);
				retStr = rnd + "M";
			}
			else if(value >= 10000)
			{
				//rounding to nearest thousand
				rnd = (value / 1000).toFixed(0);
				retStr = rnd + "K"
			}
			else if(value >= 500)
			{
				//rounding to nearest thousand
				rnd = (value / 1000).toFixed(1);
				retStr = rnd + "K"
			}
			else retStr = value.toString();

			return convertNumberString(retStr);
		}

		private static function convertNumberString(text:String):String
		{
			var lang : String = CoreComponent.gameLanguage;

			switch(lang)
			{
				case "ES":
				case "DE":
				case "PL":
				case "IT":
				case "FR":
				case "PT":
				case "CZ":
				case "HU":
				case "TR":
					text = text.split(".").join(",");
					break;
				default:
					break;
			}
			return text;
		}

		public static function padInteger(n : int, padTo : int) : String
		{
			var tenPower : int = 10;
			var ret : String = "";
			for(var i : int = 0; i < padTo - 1; i++)
			{
				if(n < tenPower)
					ret += "0";
				tenPower *= 10;
			}
			ret += n;

			return ret;
		}

		public static function getSimplifiedDate(tfTemp : TextField, date:String):String
		{
			var retString : String = "";
			var parts:Array = date.split(" ");
			var dateParts:Array = parts[0].split("/");
			var timeParts:Array = parts[0].split(":");

			var day:int = int(dateParts[0]);
			var month:int = int(dateParts[1]) - 1;
			var year:int = int(dateParts[2]);

			var hour:int = int(timeParts[0]);
			var minute:int = int(timeParts[1]);
			var second:int = int(timeParts[2]);

			var pastDate:Date = new Date(year, month, day, hour, minute, second);
			var now:Date = new Date();

			var diffMs = now.getTime() - pastDate.getTime();

			var diffSeconds:Number = Math.floor(diffMs / 1000);
			var diffMinutes:Number = Math.floor(diffSeconds / 60);
			var diffHours:Number = Math.floor(diffMinutes / 60);
			var diffDays:Number = Math.floor(diffHours / 24);
			var diffMonths:Number = Math.floor(diffDays / 30); //#LT: eh
			var diffYears:Number = Math.floor(diffDays / 365); //#LT little eh as well

			return year + "-" + padInteger(month + 1, 2) + "-" + padInteger(day, 2);

			// commenting out showing dates as x days/months/years ago, because we arent using it

			/*if(diffSeconds < 60)
			{
				tfTemp.text = "[[panel_date_just_now]]";
				retString = tfTemp.text;
			}
			else if(diffMinutes < 60)
			{
				if(diffMinutes == 1)
				{
					tfTemp.text = "[[panel_date_a_minute_ago]]";
					retString = tfTemp.text;
				}
				else
				{
					tfTemp.text = "[[panel_date_minutes_ago]]";
					retString = tfTemp.text;
					retString = retString.replace("{x}", diffMinutes);
				}
			}
			else if(diffHours < 24)
			{
				if(diffHours == 1)
				{
					tfTemp.text = "[[panel_date_a_hour_ago]]";
					retString = tfTemp.text;
				}
				else
				{
					tfTemp.text = "[[panel_date_hours_ago]]";
					retString = tfTemp.text;
					retString = retString.replace("{x}", diffHours);
				}
			}
			else if(diffDays < 30)
			{
				if(diffDays == 1)
				{
					tfTemp.text = "[[panel_date_yesterday]]";
					retString = tfTemp.text;
				}
				else
				{
					tfTemp.text = "[[panel_date_days_ago]]";
					retString = tfTemp.text;
					retString = retString.replace("{x}", diffDays);
				}
			}
			else if(diffMonths < 13 && diffYears < 1)
			{
				if(diffMonths == 1)
				{
					tfTemp.text = "[[panel_date_a_month_ago]]";
					retString = tfTemp.text;
				}
				else
				{
					tfTemp.text = "[[panel_date_months_ago]]";
					retString = tfTemp.text;
					retString = retString.replace("{x}", diffMonths);
				}
			}
			else 
			{
				if(diffYears == 1)
				{
					tfTemp.text = "[[panel_date_a_year_ago]]";
					retString = tfTemp.text;
				}
				else
				{
					tfTemp.text = "[[panel_date_years_ago]]";
					retString = tfTemp.text;
					retString = retString.replace("{x}", diffYears);
				}
			}*/

			return retString;
		}

    }
}