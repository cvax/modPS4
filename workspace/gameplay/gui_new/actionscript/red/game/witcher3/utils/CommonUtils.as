package red.game.witcher3.utils
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.InteractiveObject;
	import flash.filters.ColorMatrixFilter;
	import flash.events.Event;
	import red.core.events.GestureEventEx;
	import flash.events.GestureEvent;
	import scaleform.gfx.MouseEventEx;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import red.game.witcher3.constants.InventorySlotType;
	import red.game.witcher3.constants.KeyCode;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.ui.InputDetails;
	import scaleform.gfx.Extensions;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;

	public class CommonUtils
	{
		public static function drawPie(canvas:Graphics, radius:Number, steps:Number = 30, startAngle:Number = -90, endAngle:Number = 270):void
		{
			var startAngleRad:Number = startAngle / 180 * Math.PI;
			var endAngleRad:Number = endAngle / 180 * Math.PI;
			var angleStep:Number = (endAngleRad - startAngleRad) / steps;
			var currentAngle:Number = startAngleRad;

			canvas.beginFill(0xFF0000, 1);
			canvas.moveTo(0, 0);
			for (var i:int = 0; i <= steps; i++)
			{
				var dx:Number = radius * Math.cos(currentAngle);
				var dy:Number = radius * Math.sin(currentAngle);

				canvas.lineTo(dx, dy);
				currentAngle += angleStep;
			}
			canvas.lineTo(0, 0);
			canvas.endFill();
		}

		public static function traceObject(target:Object, logPrefix:String = ""):void
		{
			for (var key:String in target)
			{
				if ((target[key] is Object) || (target[key] is Array))
				{
					traceObject(target[key], logPrefix);
				}
				else
				{
					trace(logPrefix, key, " : ", target[key]);
				}
			}
		}

		public static function traceObjectFixed(data : Object, prefix : String = ""):void
		{
			// trace("JIFIX CommonUtils traceObjectFixed", prefix);
			if(data is Array)
			{
				for(var i : int = 0; i < data.length; i++)
					traceObjectFixed(data[i], prefix + "[" + i + "]");
			}
			else if (data is Object)
			{
				var properties : Boolean = false;
				for(var key : String in data)
				{
					properties = true;
					traceObjectFixed(data[key], prefix + (prefix?".":"") + key);
				}
				if(!properties) // <-- every simple type is object, too, but they don't have subelements
					trace(prefix, data);
			}
		}

		public static function getDesaturateFilter():ColorMatrixFilter
		{
			var desaturateMatrix:Array = new Array(0.309, 0.609, 0.082, 0, 0, 0.309, 0.609, 0.082, 0, 0, 0.309, 0.609, 0.082, 0, 0, 0, 0, 0, 1, 0);
			var desaturateFilter:ColorMatrixFilter = new ColorMatrixFilter(desaturateMatrix);
			return desaturateFilter;
		}
		
		public static function getRedWarningFilter():ColorMatrixFilter
		{
			var desaturateMatrix:Array = new Array(.9, 0, 0, 0, 0.5,
												   0, 0, 0, 0, 0,
												   0, 0, 0, 0, 0,
												   0,  0, 0, 1, 0);
			var desaturateFilter:ColorMatrixFilter = new ColorMatrixFilter(desaturateMatrix);
			return desaturateFilter;
		}

		// TODO: Remove magic numbers, use something like Math.PI*2/3 or constants
		public static function convertAxisToNavigationCode(angle:Number):InputDetails
		{
			var inputDetails:InputDetails = new InputDetails("key", 0, InputValue.KEY_DOWN, null, 0, true, false, false, true);
			var isGamepad:Boolean = InputManager.getInstance().isGamepad();

			var angleDeg:Number = angle * 180 / Math.PI;
			if (angleDeg < 135 && angleDeg > 45 )
			{

				inputDetails.code = isGamepad ? KeyCode.PAD_DIGIT_UP : KeyCode.UP;
				inputDetails.navEquivalent = isGamepad ? NavigationCode.DPAD_UP : NavigationCode.UP;
				return inputDetails;
			}
			if ((angleDeg <= 45 && angleDeg >= 0) || (angleDeg > 315 && angleDeg <= 360))
			{
				inputDetails.code = isGamepad ? KeyCode.PAD_DIGIT_RIGHT : KeyCode.RIGHT;
				inputDetails.navEquivalent = isGamepad ? NavigationCode.DPAD_RIGHT : NavigationCode.RIGHT;
				return inputDetails;
			}
			if (angleDeg >= 135 && angleDeg <= 225 )
			{
				inputDetails.code = isGamepad ? KeyCode.PAD_DIGIT_LEFT : KeyCode.LEFT;
				inputDetails.navEquivalent = isGamepad ? NavigationCode.DPAD_LEFT : NavigationCode.LEFT;
				return inputDetails;
			}
			if (angleDeg > 225 && angleDeg <= 315 )
			{
				inputDetails.code = isGamepad ? KeyCode.PAD_DIGIT_DOWN : KeyCode.DOWN;
				inputDetails.navEquivalent = isGamepad ? NavigationCode.DPAD_DOWN :NavigationCode.DOWN;
				return inputDetails;
			}
			return null;
		}

		public static function convertNavigationCodeToAxis(targetKeyCode:Number):Number
		{
			switch (targetKeyCode)
			{
				case KeyCode.UP:
					return 0;
					break;
				case KeyCode.RIGHT:
					return Math.PI / 2;
					break;
				case KeyCode.DOWN:
					return Math.PI;
					break;
				case KeyCode.LEFT:
					return -Math.PI / 2;
					break;
			}
			return NaN;
		}

		public static function traceCallstack(tracePrefix:String):void
		{
			var err:Error = new Error();
			trace(tracePrefix, err.getStackTrace());
		}

		public static function convertKeyCodeToFrame(keyCode:uint):uint
		{
			// TODO: Currently no way to represent both Left shoulder and right shoulder at same time. (ditto for triggers)
			switch (keyCode)
			{
				case KeyCode.PAD_X_SQUARE:
					return 2;
				case KeyCode.PAD_A_CROSS:
					return 3;
				case KeyCode.PAD_B_CIRCLE:
					return 4;
				case KeyCode.PAD_Y_TRIANGLE:
					return 5;
				case KeyCode.PAD_LEFT_SHOULDER:
					return 6;
				case KeyCode.PAD_RIGHT_SHOULDER:
					return 7;
				case KeyCode.PAD_LEFT_TRIGGER:
				case KeyCode.PAD_LEFT_TRIGGER_AXIS:
					return 8;
				case KeyCode.PAD_RIGHT_TRIGGER:
				case KeyCode.PAD_RIGHT_TRIGGER_AXIS:
					return 9;
				case KeyCode.PAD_LEFT_STICK_AXIS:
				case KeyCode.PAD_LEFT_STICK_UP:
				case KeyCode.PAD_LEFT_STICK_DOWN:
				case KeyCode.PAD_LEFT_STICK_LEFT:
				case KeyCode.PAD_LEFT_STICK_RIGHT:
					return 10;
				case KeyCode.PAD_RIGHT_STICK_AXIS:
				case KeyCode.PAD_RIGHT_STICK_UP:
				case KeyCode.PAD_RIGHT_STICK_DOWN:
				case KeyCode.PAD_RIGHT_STICK_LEFT:
				case KeyCode.PAD_RIGHT_STICK_RIGHT:
					return 11;
				case KeyCode.PAD_DIGIT_UP:
					return 14;
				case KeyCode.PAD_DIGIT_DOWN:
					return 15;
				case KeyCode.PAD_DIGIT_RIGHT:
					return 16;
				case KeyCode.PAD_DIGIT_LEFT:
					return 17;
				case KeyCode.PAD_START:
					return 18;
				case KeyCode.PAD_BACK_SELECT:
					return 19;
				default:
					break;
			}

			return 1;
		}

		public static function hasFrameLabel(mcToCheck:MovieClip, label:String):Boolean
		{
			var i:int;

			for (i = 0; i < mcToCheck.currentLabels.length; ++i)
			{
				if (mcToCheck.currentLabels[i].name == label)
				{
					return true;
				}
			}

			return false;
		}

		public static function getScreenRect():Rectangle
		{
			if (Extensions.isScaleform)
			{
				return Extensions.visibleRect;
			}
			else
			{
				return new Rectangle(0, 0, 1920, 1080);
			}
		}
		
		public static function createSolidColorSprite(rect:Rectangle, color:Number, alpha:Number):Sprite
		{
			var spriteInst:Sprite = new Sprite();
			var spriteGraphics:Graphics = spriteInst.graphics;
			
			spriteGraphics.lineStyle(0, 0, 0);
			spriteGraphics.beginFill(color, alpha);
			spriteGraphics.moveTo(rect.x, rect.y);
			spriteGraphics.lineTo(rect.x + rect.width, rect.y);
			spriteGraphics.lineTo(rect.x + rect.width, rect.y + rect.height);
			spriteGraphics.lineTo(rect.x, rect.y + rect.height);
			spriteGraphics.lineTo(rect.x, rect.y);
			spriteGraphics.endFill();
			return spriteInst;
		}
		
		public static function createFullscreenSprite(color:Number, alpha:Number):Sprite
		{
			var spriteInst:Sprite = new Sprite();
			var spriteGraphics:Graphics = spriteInst.graphics;
			var screenRect:Rectangle = CommonUtils.getScreenRect();
			
			spriteGraphics.lineStyle(0, 0, 0);
			spriteGraphics.beginFill(color, alpha);
			spriteGraphics.moveTo(screenRect.x, screenRect.y);
			spriteGraphics.lineTo(screenRect.x + screenRect.width, screenRect.y);
			spriteGraphics.lineTo(screenRect.x + screenRect.width, screenRect.y + screenRect.height);
			spriteGraphics.lineTo(screenRect.x, screenRect.y + screenRect.height);
			spriteGraphics.lineTo(screenRect.x, screenRect.y);
			spriteGraphics.endFill();
			return spriteInst;
		}
		
		public static function strTrim(source:String):String
		{
			var resultString:String = ""
			var len:int = source.length;
			var i, from, to:int;
			i = 0;
			while ((i < len - 1) && ((source.charCodeAt(i) == 32) || (source.charCodeAt(i) == 9)))
			{
				i++;
			}
			from = i;
			i = len - 1;
			while ((i > 0) && ((source.charCodeAt(i) == 32) || (source.charCodeAt(i) == 9)))
			{
				i--;
			}
			to = i;
			resultString = source.slice(from, to + 1);
			return resultString;
		}
		
		public static function generateDesaturationFilter(amount:Number):ColorMatrixFilter
		{
			// #J advanced feature could have sr,sg,sb change depending of their luminance
			var sr = 1 - amount;
			var sg = 1 - amount;
			var sb = 1 - amount;
			var primaryValue:Number = amount;
			var secondValue:Number = primaryValue * 0.5;
			var matrix:Array = new Array();
			matrix=matrix.concat([sr + amount, sr,          sr,          0, 0]);// red
			matrix=matrix.concat([sg,          sg + amount, sg,          0, 0]);// green
			matrix=matrix.concat([sb,          sb,          sb + amount, 0, 0]);// blue
			matrix=matrix.concat([0,           0,           0,           1, 0]);// alpha
			matrix=matrix.concat([0,           0,           0,           0, 2]); // white
			var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);

			return filter;
		}
		
		public static function generateDarkenFilter(amount:Number):ColorMatrixFilter
		{
			var matrix:Array = new Array();
			matrix=matrix.concat(  [amount, 0,      0,      0, 0]);// red
			matrix=matrix.concat(  [0,      amount, 0,      0, 0]);// green
			matrix=matrix.concat(  [0,      0,      amount, 0, 0]);// blue
			matrix=matrix.concat(  [0,      0,      0,      1, 0]);// alpha
			var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			return filter;
		}
		
		public static function generateGrayscaleFilter():ColorMatrixFilter
		{
			var third:Number = 1 / 3;
			var remainder:Number = 2 / 3;
			var matrix:Array = new Array();
			matrix=matrix.concat(  [third, 	third,   	third,   	0, 0]);// red
			matrix=matrix.concat(  [third,   	third,  third,   	0, 0]);// green
			matrix=matrix.concat(  [third,   	third,   	third,  0, 0]);// blue
			matrix=matrix.concat(  [0,      	0,      	0,      	1, 0]);// alpha
			var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			return filter;
		}

		public static function toArray(iterable:*):Array
		{
			var resultAr:Array = [];
     		for each (var elem:* in iterable) resultAr.push(elem);
     		return resultAr;
		}

		public static function getMiddlePoint(startPoint:Point, endPoint:Point):Point
		{
			var halfLen:Number = Point.distance(startPoint, endPoint) / 2;
			var dx:Number = startPoint.x - endPoint.x;
			var dy:Number = startPoint.x - endPoint.x;
			var angle:Number = Math.atan2(dx, dy);
			var resX:Number = dx + halfLen * Math.cos(angle);
			var resY:Number = dy + halfLen * Math.sin(angle);
			return new Point(resX, resY);
		}
		
		// TURKISH SUPPORT
		static private var isTurkish : Boolean = false;

		public static function setTurkish( turkish : Boolean )
		{
			isTurkish = turkish;
		}

		static private const GERMAN_SS_STRING             : String = 'ß';
		static private const GERMAN_SS_REPLACEMENT        : String = 'SS';
		
		static private const TURKISH_FIRST_LC_I_STRING    : String = 'i';
		static private const TURKISH_FIRST_UC_I_STRING    : String = 'İ';

		static private const TURKISH_SECOND_LC_I_STRING   : String = 'ı';
		static private const TURKISH_SECOND_UC_I_STRING   : String = 'I';
		
		/**
		 * First char - upper case, the rest - lower case
		 * @return
		 */
		public static function toLowerCaseExSafe(value : String):String
		{
			var res : String = "";
			var firstChar : String;
			
			if ( !value || value.length == 0 )
			{
				return res;
			}

			firstChar = value.charAt(0);

			if ( isTurkish )
			{
				if ( firstChar == TURKISH_FIRST_LC_I_STRING )
				{
					res += TURKISH_FIRST_UC_I_STRING;
				}
				else if ( firstChar == TURKISH_SECOND_LC_I_STRING )
				{
					res += TURKISH_SECOND_UC_I_STRING;
				}
				else if ( firstChar == TURKISH_FIRST_UC_I_STRING ||
				          firstChar == TURKISH_SECOND_UC_I_STRING )
				{
					res += firstChar;
				}
				else
				{
					res += firstChar.toUpperCase();
				}
			}
			else
			{
				if ( firstChar == GERMAN_SS_STRING )
				{
					res += GERMAN_SS_REPLACEMENT;
				}
				else
				{
					res += firstChar.toUpperCase();
				}
			}
			var chunk:String = value.slice(1, value.length);
			res += chunk.toLowerCase();
			return res;
		}
		
		public static function toSmallCaps(targetTextField:TextField):void
		{
			const decFont = 2;
			const incFont = 2;
			
			var str:String = toUpperCaseSafe(targetTextField.text);
			var txtFormat:TextFormat = targetTextField.getTextFormat();
			var txtSize:Number = txtFormat.size ? (txtFormat.size as Number) : 12;
			var resStr:String = "<font size = \"" + (txtSize + incFont) + "\"  >" + str.charAt(0) + "</font><font size = \"" + (txtSize - decFont) + "\"  >" + str.slice(1) + "</font>";
			
			targetTextField.htmlText = resStr;
		}

		public static function test():void
		{
			trace("ASD");
		}
		
		public static function toUpperCaseSafe( value : String ):String
		{
			var str : String;
			
			if ( isTurkish )
			{
				str = value.split( TURKISH_FIRST_LC_I_STRING  ).join( TURKISH_FIRST_UC_I_STRING );
				str =   str.split( TURKISH_SECOND_LC_I_STRING ).join( TURKISH_SECOND_UC_I_STRING );
				str = str.toUpperCase();
			}
			else
			{
				str = value.split( GERMAN_SS_STRING ).join( GERMAN_SS_REPLACEMENT );
				str = str.toUpperCase();
			}
			
			return str;
		}
		
		public static function fixupKeyCode(details:InputDetails)
		{
			//HACK : fixup tap simulated input feedback button keypresses. 
			if ( details.code == KeyCode.GESTURE_TAP || details.code == KeyCode.GESTURE_PRESS )
			{
				//Try to figure it out from nav-code
				switch (details.navEquivalent)
				{
					case NavigationCode.GAMEPAD_A:
						details.code = KeyCode.PAD_A_CROSS;
					break;
					case NavigationCode.GAMEPAD_B:
						details.code = KeyCode.PAD_B_CIRCLE;
					break;
					case NavigationCode.GAMEPAD_X:
						details.code = KeyCode.PAD_X_SQUARE;
					break;
					case NavigationCode.GAMEPAD_Y:
						details.code = KeyCode.PAD_Y_TRIANGLE;
					break;
					case NavigationCode.GAMEPAD_L1:
						details.code = KeyCode.PAD_LEFT_SHOULDER;
					break;
					case NavigationCode.GAMEPAD_L2:
						details.code = KeyCode.PAD_LEFT_TRIGGER;
					break;
					case NavigationCode.GAMEPAD_LSTICK_HOLD:
					case NavigationCode.GAMEPAD_LSTICK_DOWN:
						details.navEquivalent = NavigationCode.GAMEPAD_L3;
					//NOTE : fallthrough!!
					case NavigationCode.GAMEPAD_L3:
						details.code = KeyCode.PAD_LEFT_THUMB;
					break;
					case NavigationCode.GAMEPAD_R1:
						details.code = KeyCode.PAD_RIGHT_SHOULDER;
					break;
					case NavigationCode.GAMEPAD_R2:
						details.code = KeyCode.PAD_RIGHT_TRIGGER;
					break;
					case NavigationCode.GAMEPAD_RSTICK_HOLD:
					case NavigationCode.GAMEPAD_RSTICK_DOWN:
						details.navEquivalent = NavigationCode.GAMEPAD_R3;
					//NOTE : fallthrough!!
					case NavigationCode.GAMEPAD_R3:
						details.code = KeyCode.PAD_RIGHT_THUMB;
					break;
				}
			}
		}

		public static function convertWASDCodeToNavEquivalent(inputDetails:InputDetails) : Boolean
		{
			switch (inputDetails.code)
			{
				case KeyCode.W:
					inputDetails.navEquivalent = NavigationCode.UP;
				return true;
				case KeyCode.S:
					inputDetails.navEquivalent = NavigationCode.DOWN;
				return true;
				case KeyCode.A:
					inputDetails.navEquivalent = NavigationCode.LEFT;
				return true;
				case KeyCode.D:
					inputDetails.navEquivalent = NavigationCode.RIGHT;
				return true;
			}

			return false;
		}
		
		public static function checkSlotsCompatibility(slot1:int, slot2:int):Boolean
		{
			if ((slot1 == InventorySlotType.Quickslot1 || slot1 == InventorySlotType.Quickslot2) &&
				(slot2 == InventorySlotType.Quickslot1 || slot2 == InventorySlotType.Quickslot2))
			{
				return true;
			}
			if ((slot1 == InventorySlotType.Potion1 || slot1 == InventorySlotType.Potion2) &&
				(slot2 == InventorySlotType.Potion1 || slot2 == InventorySlotType.Potion2))
			{
				return true;
			}
			if ((slot1 == InventorySlotType.Petard1 || slot1 == InventorySlotType.Petard2) &&
				(slot2 == InventorySlotType.Petard1 || slot2 == InventorySlotType.Petard2))
			{
				return true;
			}
			return slot1 == slot2;
		}
		
		public static function getPointOfIntersection(p1:Point, p2:Point, p3:Point, p4:Point):Point
		{
			var d:Number = (p1.x - p2.x) * (p4.y - p3.y) - (p1.y - p2.y) * (p4.x - p3.x);
			var da:Number = (p1.x - p3.x) * (p4.y - p3.y) - (p1.y - p3.y) * (p4.x - p3.x);
			var db:Number = (p1.x - p2.x) * (p1.y - p3.y) - (p1.y - p2.y) * (p1.x - p3.x);
		
			var ta:Number = da / d;
			var tb:Number = db / d;
		
			if (ta >= 0 && ta <= 1 && tb >= 0 && tb <= 1)
			{
				var dx:Number = p1.x + ta * (p2.x - p1.x);
				var dy:Number = p1.y + ta * (p2.y - p1.y);
		
				return new Point(dx, dy);
			}
		
			return null;
		}
		
		// replace <i> and <b> tags
		public static function fixFontStyleTags(source:String):String
		{
			var pattern:RegExp;
			var res:String;
			
			pattern = /<i>/g;
			res = source.replace(pattern, "<font face='$ItalicFont'>");
			
			pattern = /<b>/g;
			res = res.replace(pattern, "<font face='$BoldFont'>");
			
			pattern = /<\/i>/g;
			res = res.replace(pattern, "</font>");
			
			pattern = /<\/b>/g;
			res = res.replace(pattern, "</font>");
			
			return res;
		}
		
		
		public static function spawnTextField(fontSize:Number = 24, fontColor:Number = 0xFFFFFF, debugBackground:Boolean = false):TextField
		{
			var textField  : TextField = new TextField();
			var textFormat : TextFormat = new TextFormat("$NormalFont", fontSize);
			
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.font = "$NormalFont";
			
			textField.embedFonts = true;
			textField.defaultTextFormat = textFormat;
			textField.setTextFormat(textFormat);
			textField.textColor = fontColor;
			
			if (debugBackground)
			{
				textField.background = true;
				textField.backgroundColor = 0x800000;
			}
			
			return textField;
		}
		
		public static function getClosestSlot(fromPoint:Point, list:Vector.<IBaseSlot>):IBaseSlot
		{
			var currentMinDistance:Number = -1;
			var currentClosestRenderer:IBaseSlot;
			var len:int = list.length;
			
			for (var i:int = 0; i < len; i++)
			{
				var curSlot:IBaseSlot = list[i];
				var parentContainert:Sprite = (curSlot as Sprite).parent as Sprite;
				var slotRect:Rectangle = curSlot.getSlotRect();
				var slotLocalX:Number = curSlot.x + slotRect.x + slotRect.width / 2;
				var slotLocalY:Number = curSlot.y + slotRect.y + slotRect.height / 2;
				var globalPosition:Point = parentContainert.localToGlobal(new Point(slotLocalX, slotLocalY));
				var curDistance:Number = Point.distance(fromPoint, globalPosition);
				
				if (currentMinDistance > curDistance || currentMinDistance == -1)
				{
					currentMinDistance = curDistance;
					currentClosestRenderer = curSlot;
				}
			}
			
			return currentClosestRenderer;
		}
		
		public static function replicateDataObject(source:Object):Object
		{
			var replica:Object = { };
			
			for (var keyValue:String in source )
		 	{
				replica[keyValue] = source[keyValue];
			}
			
			return replica;
		}
		
		public static function getLocalization(key:String):String
		{
			var tmpTextField:TextField = new TextField();
			
			tmpTextField.text = "[[" + key + "]]";
			
			return tmpTextField.text;
		}

		public static function isActuallyVisible(obj:DisplayObject):Boolean
		{
			while(obj != null)
			{
				if(!obj.visible)
					return false;
				obj = obj.parent;
			}
			return true;
		}

		public static function getPath(obj:DisplayObject):String
		{
			var path:String = obj.name;
			obj = obj.parent;
			while (obj)
			{
				path = obj.name + "." + path;
				obj = obj.parent;
			}
			return path;
		}

		public static function getTopDisplayObject(targetDO:DisplayObject, x:Number, y:Number, onlyTopMost:Boolean = false):DisplayObject
		{
			var objects:Array;
			if (onlyTopMost)
			{
				objects = [Extensions.getTopMostEntity(x, y)];
			}
			else
			{
				objects = targetDO.stage.getObjectsUnderPoint(new Point(x, y));
			}
			var target:DisplayObject;
			var dispatchedTargets:Array = [];
			while(target = objects.pop())
			{
				while (target && (!(target is InteractiveObject) || !target.hasEventListener(MouseEvent.CLICK))) {
					target = target.parent;
				}
				if(target is InteractiveObject)
				{
					if(target !== null && target.name != null && target.parent != null)
					{
						if(dispatchedTargets.indexOf(target) < 0)
						{
							return target;
						}
					}
				}
			}
			
			if(target == null && !onlyTopMost)
			{
				return targetDO.stage;
			}

			return targetDO.stage;
		}
		
		public static function simulateKeyInputEvent( keyCode : uint, value : String, navCode : String) : void
		{
			var details : InputDetails = new InputDetails( "key", keyCode, value, navCode );
			var event : InputEvent = new InputEvent( InputEvent.INPUT, details );
			InputDelegate.getInstance().dispatchEvent( event );
		}

		public static function simulateClick(targetDO:DisplayObject, x:Number, y:Number, onlyTopMost:Boolean = false):void
		{
			var objects:Array;
			if (onlyTopMost)
			{
				objects = [Extensions.getTopMostEntity(x, y)];
			}
			else
			{
				objects = targetDO.stage.getObjectsUnderPoint(new Point(x, y));
			}
			var target:DisplayObject;
			var dispatchedTargets:Array = [];
			while(target = objects.pop())
			{
				while (target && (!(target is InteractiveObject) || !target.hasEventListener(MouseEvent.CLICK))) {
					target = target.parent;
				}
				if(target is InteractiveObject)
				{
					if(target !== null && target.name != null && target.parent != null)
					{
						if(dispatchedTargets.indexOf(target) < 0)
						{
							var local:Point = target.globalToLocal(new Point(x, y));
							var eLocal:MouseEventEx = new MouseEventEx(MouseEvent.CLICK);
							eLocal.localX = local.x;
							eLocal.localY = local.y;
							eLocal.buttonIdx = MouseEventEx.LEFT_BUTTON;
							trace("GFX dispatchEvent to " + getPath(target));
							target.dispatchEvent(eLocal);
							dispatchedTargets.push(target);
						}
					}
				}
			}
			
			if(target == null && !onlyTopMost)
			{
				var e:MouseEventEx = new MouseEventEx(MouseEvent.CLICK);
				e.localX = x;
				e.localY = y;
				e.buttonIdx = MouseEventEx.LEFT_BUTTON;
				trace("GFX dispatchEvent to stage");
				targetDO.stage.dispatchEvent(e);
			}
		}

		public static function isEventTapGestureOrMouseLeftClick( event : Event ) : Boolean
		{
			var result : Boolean = false;

			if ( event is MouseEventEx )
			{
				var mouseEvent : MouseEventEx = event as MouseEventEx;
				if ( mouseEvent.buttonIdx == MouseEventEx.LEFT_BUTTON )
				{
					result = true;
				}
			}
			else if ( event is GestureEvent )
			{
				var gestureEvent : GestureEvent = event as GestureEvent;
				if (gestureEvent.type == GestureEventEx.GESTURE_TAP)
				{
					result = true;
				}
			}

			return result;
		}

		public static function stagePanToRowScroll( panYAccumulator : Number, rowHeight : Number, event : TransformGestureEvent ) : Object
		{
			panYAccumulator += event.offsetY;

			var rowsToScroll : int = int ( panYAccumulator / rowHeight );
			if ( Math.abs( rowsToScroll ) > 0 )
			{
				//Put the remainder back to the accumulator (fmod)
				panYAccumulator = panYAccumulator % rowHeight;
			}
			
			return { outRowsToScroll : rowsToScroll, outPanYAccumulator : panYAccumulator };
		}

		public static function formatUserName( userName : String, mainColor : String = "#F7F7F7", secondaryColor : String = "#828597" ) : String
		{
			var nameAndNumber : Array = userName.split( "#" );

            var htmlText : String = "";
            if ( nameAndNumber.length == 2 ) 
            {
                htmlText = 
                    "<font color ='" + mainColor + "'>" + nameAndNumber[0] + "</font>" + 
                    "<font color ='" + secondaryColor + "'>#</font>" + 
                    "<font color ='" + secondaryColor + "'>" + nameAndNumber[1] + "</font>";
            }
            else
            {
                htmlText = "<font color ='" + mainColor + "'>" + nameAndNumber[0] + "</font>";
            }

			return htmlText;
		}

		public static function dbgPoint(x:Number, y:Number, color:uint, alpha:Number = 1.0, width:Number = 2.0):Sprite
		{
			var spriteInst:Sprite = CommonUtils.createSolidColorSprite( new Rectangle( x, y, width, width ), color, alpha );

			return spriteInst;
		}

	}
}
