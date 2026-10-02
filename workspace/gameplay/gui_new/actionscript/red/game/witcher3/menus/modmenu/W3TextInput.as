/***********************************************************************
/** Mod Menu - TextInput
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
    import flash.display.MovieClip;
    import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.FocusEvent;
    import flash.events.MouseEvent;
	import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.text.TextLineMetrics;
    import flash.ui.Keyboard;
    import flash.desktop.Clipboard;
    import flash.desktop.ClipboardFormats;
    import flash.geom.Point;
    import flash.geom.Rectangle;

	import scaleform.clik.core.UIComponent;
	import scaleform.clik.controls.TextInput;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.managers.InputDelegate;

    import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

    import red.core.CoreComponent;
    import red.core.constants.KeyCode;
    import red.core.events.GameEvent;
    import red.game.witcher3.managers.InputManager;

    public class W3TextInput extends TextInput
	{
        // CONSTS
        private static const TEXT_LEFT_GAP = 7;
        private static const TEXT_UP_GAP = 7;
        // ART CLIPS
        public var mcCaret          : MovieClip;
        public var mcHighlightBg    : MovieClip;
        public var mcBorder         : MovieClip;
        public var mcImage          : MovieClip;
        public var textFieldPlaceholder : TextField;

        //public var textField : TextField;
        // VARS
        public var skipKeys:Array = [];
        public var skipGamepadKeys:Array = [];

        private var cursorPos:int = text.length;
        private var _ctrlPressed:Boolean = false;
        private var _allowSpecialCharacters:Boolean = true;
        private var _allowPasting:Boolean = true;
        private var _onlyUppercase:Boolean = false;
        private var _onlyLowercase:Boolean = false;
        private var _multiline:Boolean = false;
        private var _consoleTitle:String = "";
        private var _consoleDefault:String = "";
        private var _inputScope:int = 0; //0 - Normal, 1 - Email, 2 - Search
        private var _virtualKbKey:String = NavigationCode.GAMEPAD_X;

        private var _anyInputSetup = false;
        public var caretFlashingDelay:Number = 1;
        public var textInputManager:TextInputManager = null;


        [Inspectable(name = "Allow Special Characters", defaultValue = "true")]
		public function get allowSpecialCharacters():Boolean { return _allowSpecialCharacters; }
		public function set allowSpecialCharacters( value:Boolean ):void	{ _allowSpecialCharacters = value; }

        [Inspectable(defaultValue = "true")]
		public function get allowPasting():Boolean { return _allowPasting; }
		public function set allowPasting( value:Boolean ):void	{ _allowPasting = value; }

        [Inspectable(defaultValue = "false")]
		public function get onlyUppercase():Boolean { return _onlyUppercase; }
		public function set onlyUppercase( value:Boolean ):void	{ _onlyUppercase = value; if(value) _onlyLowercase = false; }
        
        [Inspectable(defaultValue = "false")]
		public function get onlyLowercase():Boolean { return _onlyLowercase; }
		public function set onlyLowercase( value:Boolean ):void	{ _onlyLowercase = value; if(value) _onlyUppercase = false; }

        [Inspectable(defaultValue = "false")]
		public function get multiline():Boolean { return _multiline; }
		public function set multiline( value:Boolean ):void	{ _multiline = value; }

        [Inspectable(defaultValue = "")]
		public function get consoleTitle():String { return _consoleTitle; }
		public function set consoleTitle( value:String ):void	{ _consoleTitle = value; }

        [Inspectable(defaultValue = "")]
		public function get consoleDefault():String { return _consoleDefault; }
		public function set consoleDefault( value:String ):void	{ _consoleDefault = value; }

        [Inspectable(defaultValue = 0)]
		public function get inputScope():int { return _inputScope; }
		public function set inputScope( value:int ):void	{ _inputScope = value; }

        [Inspectable(defaultValue = NavigationCode.GAMEPAD_X)]
		public function get virtualKbKey():String { return _virtualKbKey; }
		public function set virtualKbKey( value:String ):void	{ _virtualKbKey = value; }

        public function W3TextInput()
        {
            super();
        }

        override protected function configUI():void
        {
            super.configUI();
            focusable = true;
            tabEnabled = true;

            addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
            addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);

            textField.type = "input";
            textField.selectable = true;
            textField.maxChars = 50;
            textField.restrict = null;
            
            if(mcCaret) {
                mcCaret.visible = false;
            }
            if(mcHighlightBg)
                mcHighlightBg.alpha = 0;

            if(!_anyInputSetup)
                setupInput();

            arabicConvert();

            if(textFieldPlaceholder)
                textFieldPlaceholder.htmlText = "[[mods_report_textfield_placeholder]]";
            if(CoreComponent.isArabicAligmentMode)
                textFieldPlaceholder.htmlText = "<p align=\"right\">" + textFieldPlaceholder.htmlText + "</p>";
        }

        public function setupInput():void
        {
            trace("GFX - W3TI Setup for regular");
            addEventListener(InputEvent.INPUT, handleInput, false, int.MAX_VALUE, true);
            InputDelegate.getInstance().removeEventListener(InputEvent.INPUT, handleInput, false);
            _anyInputSetup = true;
        }

        public function setupInputForDelegate():void
        {
            trace("GFX - W3TI Setup for Input Delegate");
            removeEventListener(InputEvent.INPUT, handleInput, false);
            InputDelegate.getInstance().addEventListener(InputEvent.INPUT, handleInput, false, int.MAX_VALUE, true);
            _anyInputSetup = true;
        }

        override public function set focused(value:Number):void
        {
            super.focused = value;

            if(value == 1) {
                startCaretAnimation();
                highlightInAnimation();
            }
            else 
            {
                if(mcCaret)
                {
                    mcCaret.visible = false;
                    GTweener.removeTweens(mcCaret);
                }
                highlightOutAnimation();
            }
        }

        private function startCaretAnimation():void
        {
            if(mcCaret)
            {
                GTweener.removeTweens(mcCaret);
				GTweener.to(mcCaret, caretFlashingDelay, { }, { onComplete: startCaretAnimationPartTwo } );
                mcCaret.visible = true;
            }
        }

        private function startCaretAnimationPartTwo():void
        {
            if(mcCaret)
            {
                GTweener.removeTweens(mcCaret);
				GTweener.to(mcCaret, caretFlashingDelay, { }, { onComplete: startCaretAnimation } );
                mcCaret.visible = false;
            }
        }

        private function highlightInAnimation():void
        {
            if(mcHighlightBg)
            {
                GTweener.removeTweens(mcHighlightBg);
				GTweener.to(mcHighlightBg, 0.5, { alpha: 1 }, { ease: Exponential.easeOut } );
            }
        }

        private function highlightOutAnimation():void
        {
            if(mcHighlightBg)
            {
                GTweener.removeTweens(mcHighlightBg);
				GTweener.to(mcHighlightBg, 0.5, { alpha: 0 }, { ease: Exponential.easeOut } );
            }
        }

        private function getTextWidth(text:String, textFormat:TextFormat)
        {
            var tempField:TextField = new TextField();
            tempField.defaultTextFormat = textFormat;
            tempField.text = text;
            return tempField.textWidth;
        }

        private function getTextHeight(text:String, textFormat:TextFormat)
        {
            var tempField:TextField = new TextField();
            tempField.width = textField.width;
            tempField.defaultTextFormat = textFormat;
            tempField.multiline = multiline;
            tempField.wordWrap = textField.wordWrap;
            tempField.text = text;
            return tempField.textHeight;
        }

        private function updateCaretPosition():void
        {
            var txtBeforeCursor:String = text.substr(0,cursorPos);
            var textFormat:TextFormat = textField.getTextFormat();

            if(_multiline)
            {
                //#LT i believe this works for single line too?
                var tempIndex : int = cursorPos;
                if (cursorPos == text.length)
                    tempIndex = Math.max(0, cursorPos - 1);
                var lineIndex:int = textField.getLineIndexOfChar(tempIndex);
                var lineStartIndex:int = textField.getLineOffset(lineIndex);
                var offsetInLine:int = tempIndex - lineStartIndex;

                var lineText:String = textField.text.substr(lineStartIndex, offsetInLine);
                

                var tmpTxtWidth:Number = getTextWidth(lineText, textFormat);
                
                var caretX:Number = textField.x + tmpTxtWidth;
                if(CoreComponent.isArabicAligmentMode)
                {
                    //lineText = textField.text.substr(lineStartIndex, offsetInLine - 1);
                    //tmpTxtWidth = getTextWidth(lineText, textFormat);

                    var lineWidth : Number;
                    var nextLineStartIndex:int = textField.getLineOffset(lineIndex + 1);
                    if(nextLineStartIndex > text.length || nextLineStartIndex == -1)
                        nextLineStartIndex = text.length;
                    var fullLineText : String = text.substr(lineStartIndex, nextLineStartIndex - lineStartIndex);

                    lineWidth = getTextWidth(fullLineText, textFormat);

                    caretX = textField.x + textField.width - lineWidth + tmpTxtWidth - mcCaret.width;
                }
                if(cursorPos == text.length)
                    caretX += getTextWidth(text.substr(text.length - 1, 1), textFormat);

                var rect:Rectangle = textField.getCharBoundaries(tempIndex);
                if(rect == null)
                {
                    if(tempIndex > 0)
                    {
                        var prevRect : Rectangle = textField.getCharBoundaries(tempIndex - 1);
                        if (prevRect != null)
                            rect = new Rectangle(prevRect.x + prevRect.width, prevRect.y, 0, prevRect.height);
                    }
                }
                
                var lineMetrics:TextLineMetrics = textField.getLineMetrics(lineIndex);
                var caretY:Number = textField.y + lineMetrics.height * (lineIndex - (textField.scrollV - 1));

                if(rect != null)
                {
                    var globalPoint:Point = textField.localToGlobal(new Point(rect.x, rect.y));
                    var parentPoint:Point = mcCaret.parent.globalToLocal(globalPoint);

                    caretY = parentPoint.y;
                }

                mcCaret.x = caretX;
                mcCaret.y = caretY;
            }
            else
            {
                var txtWidth:Number = getTextWidth(txtBeforeCursor, textFormat);
                mcCaret.x = textField.x + txtWidth;
                mcCaret.y = textField.y + (textField.height - mcCaret.height) / 2;

                if(CoreComponent.isArabicAligmentMode)
                {
                    caretX = textField.x + textField.width - textField.textWidth + txtWidth;
                }
            }
        }

        private function positionText():void
        {
            var textFormat:TextFormat = textField.getTextFormat();
            if(_multiline)
            {
                var fullTextHeight:Number = getTextHeight(text, textFormat);
                var up:Number = TEXT_UP_GAP;
                var down:Number = mcBorder.height - TEXT_UP_GAP;
                var maxHeight = mcBorder.height - 2 * TEXT_UP_GAP;

                if(fullTextHeight > maxHeight)
                    textField.height = fullTextHeight + 5;
                else
                    textField.height = maxHeight;

                if(fullTextHeight < maxHeight)
                {
                    textField.y = up;
                    updateCaretPosition();
                }
                else
                {
                    if(textField.y > up)
                        textField.y = up;
                    if (textField.y + textField.height < down)
                        textField.y = down - textField.height;
                    updateCaretPosition();
                }

                if(mcCaret.y >= up && mcCaret.y + mcCaret.height <= down)
                {
                }
                else if (mcCaret.y < up)
                {
                    textField.y += up - mcCaret.y;
                }
                else if (mcCaret.y + mcCaret.height > down)
                {
                    textField.y -= mcCaret.y - down + mcCaret.height;
                }

                updateCaretPosition();
            }
            else
            {
                var fullTextWidth:Number = getTextWidth(text, textFormat);

                var left:Number = TEXT_LEFT_GAP;
                var right:Number = mcBorder.width - TEXT_LEFT_GAP;
                var maxWidth = mcBorder.width - 2 * TEXT_LEFT_GAP;

                if (mcImage)
                {
                    left += mcImage.width;
                    maxWidth -= mcImage.width;
                }

                if(fullTextWidth > maxWidth)
                    textField.width = fullTextWidth;
                else
                    textField.width = maxWidth;

                if(fullTextWidth < maxWidth)
                {
                    textField.x = left;
                    updateCaretPosition();
                }
                else
                {
                    if(textField.x > left)
                        textField.x = left;
                    if (textField.x + textField.width < right)
                        textField.x = right - textField.width;
                    updateCaretPosition();
                }
                
                if(mcCaret.x >= left && mcCaret.x <= right)
                {
                }
                else if (mcCaret.x < left)
                {
                    textField.x += left - mcCaret.x;
                }
                else if (mcCaret.x > right)
                {
                    textField.x -= mcCaret.x - right;
                }

                updateCaretPosition();
            }
        }

        private function doPlaceholderLogic():void
        {
            if(textFieldPlaceholder)
            {
                textFieldPlaceholder.visible = text.length == 0;
            }
        }

        override public function handleInput(event:InputEvent):void
        {
            if(focused == 0 || event.handled) {
                _ctrlPressed = false;
                return;
            }
            //trace("GFX - W3TI",event,event.handled);

            var keyboardLayout:Object = {
                48: {normal: "0", shift: ")", altgr: ""},
                49: {normal: "1", shift: "!", altgr: ""},
                50: {normal: "2", shift: "@", altgr: ""},
                51: {normal: "3", shift: "#", altgr: ""},
                52: {normal: "4", shift: "$", altgr: ""},
                53: {normal: "5", shift: "%", altgr: ""},
                54: {normal: "6", shift: "^", altgr: ""},
                55: {normal: "7", shift: "&", altgr: ""},
                56: {normal: "8", shift: "*", altgr: ""},
                57: {normal: "9", shift: "(", altgr: ""}
            }
            
            super.handleInput(event); //<-- does not do anything, but hey

			var details:InputDetails = event.details;

            var shift:Boolean = details.shiftKey;
            var ctrl:Boolean = details.ctrlKey;
            var alt:Boolean = details.altKey;
            var altgr:Boolean = ctrl && alt;

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var hold:Boolean = details.value == InputValue.KEY_HOLD;
            var keyUp:Boolean = details.value == InputValue.KEY_UP;

            if(!keyDown && !hold && !keyUp)
                return;

            var str:String = text;
            var keyCode:uint = details.code;

            if(keyCode == KeyCode.SHIFT || keyCode == KeyCode.ALT || keyCode == KeyCode.CTRL || keyCode == 162 || keyCode == 163) {                
                if(keyCode == KeyCode.CTRL || keyCode == 162 || keyCode == 163)
                {
                    if(keyDown)
                        _ctrlPressed = true;
                    else if (keyUp)
                        _ctrlPressed = false;
                }
                return;
            }
            var i : int;
            if(skipKeys)
            {
                for(i = 0; i < skipKeys.length; i++)
                {
                    if(keyCode == skipKeys[i])
                    {
                        trace("GFX - skipkey triggered:", keyCode);
                        return;
                    }
                }
            }
            if(skipGamepadKeys)
            {
                for(i = 0; i < skipGamepadKeys.length; i++)
                {
                    if(details.navEquivalent == skipGamepadKeys[i])
                    {
                        trace("GFX - gamepad skipkey triggered:", details.navEquivalent);
                        return;
                    }
                }
            }

            if(cursorPos > str.length)
                cursorPos = str.length;

            if(keyUp)
            {
                if(details.navEquivalent == _virtualKbKey)
                {
                    onUseTextInput();
                }
            }

            if(keyDown || hold)
            {
                if(keyCode == KeyCode.BACKSPACE)
                {
                    if(cursorPos > 0)
                    {
                        str = str.substr(0, cursorPos - 1) + str.substr(cursorPos);
                        cursorPos--;
                    }
                }
                else if (keyCode == KeyCode.DELETE)
                {
                    if(cursorPos < str.length)
                    {
                        str = str.substr(0,cursorPos) + str.substr(cursorPos + 1);
                    }
                }
                else if (keyCode == KeyCode.LEFT)
                {
                    if(cursorPos > 0) 
                    {
                        cursorPos--;
                        startCaretAnimation();
                    }
                }
                else if (keyCode == KeyCode.RIGHT)
                {
                    if(cursorPos < str.length) 
                    {
                        cursorPos++;
                        startCaretAnimation();
                    }
                }
                else if (allowPasting && (ctrl || _ctrlPressed) && keyCode == 86) // CTRL + V
                {
                    var clipboardText:String = "";

                    trace ("Cilpboard contains formats:", Clipboard.generalClipboard.formats);
                    clipboardText = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;

                    if (!clipboardText)
                    {
                        clipboardText = Clipboard.generalClipboard.getData(ClipboardFormats.HTML_FORMAT) as String;
                    }
                    if (!clipboardText)
                    {
                        clipboardText = Clipboard.generalClipboard.getData(ClipboardFormats.RICH_TEXT_FORMAT) as String;
                    }

                    trace("GFX Clipboard:",clipboardText);
                    if(clipboardText)
                    {
                        str = str.substr(0,cursorPos) + clipboardText + str.substr(cursorPos);
                        cursorPos += clipboardText.length;

                        if(str.length > _maxChars) {
                            str = str.substr(0, _maxChars);
                            cursorPos = str.length;
                        }
                    }
                }
                else if (event.details.value != "" && ((keyCode > 31 && keyCode < 127) || (keyCode == 190 || keyCode == 188) && allowSpecialCharacters))
                {
                    //trace("GFX Keycode:",keyCode, ctrl, shift, alt);
                    var char:String = String.fromCharCode(keyCode);

                    if(keyCode == 188) char = ",";
                    else if(keyCode == 190) char = ".";
                    


                    if(keyboardLayout[keyCode] != undefined)
                    {
                        if(!allowSpecialCharacters)
                            char = keyboardLayout[keyCode].normal;
                        else if (altgr && keyboardLayout[keyCode].altgr)
                            char = keyboardLayout[keyCode].altgr;
                        else if (shift && keyboardLayout[keyCode].shift)
                            char = keyboardLayout[keyCode].shift;
                        else
                            char = keyboardLayout[keyCode].normal;
                    }
                    if(!shift && keyCode >= 65 && keyCode <= 90)
                    {
                        char = char.toLowerCase();
                    }

                    if(onlyLowercase)
                        char = char.toLowerCase();
                    else if (onlyUppercase)
                        char = char.toUpperCase();

                    if(char != "" && (str.length + char.length < _maxChars || _maxChars < 1))
                    {
                        str = str.substr(0,cursorPos) + char + str.substr(cursorPos);
                        cursorPos += char.length;
                    }
                }
                else
                {
                    return;
                }
            }
            event.handled = true;
            if(keyDown || hold)
            {
                if(text != str)
                {
                    var ev : W3TextInputEvent = new W3TextInputEvent(W3TextInputEvent.TEXT_CHANGED);
                    ev.text = str;
                    dispatchEvent(ev);
                    startCaretAnimation();
                }
                text = str;
                arabicConvert();
                doPlaceholderLogic();
                updateCaretPosition();
                positionText();
                trace("GFX - Updated text:",text);
            }
            event.stopImmediatePropagation();
        }

        private function onUseTextInput()
        {
            if(textInputManager)
                textInputManager.setReference(this);
            dispatchEvent(new GameEvent(GameEvent.CALL, "OnUseTextInput", [consoleTitle, consoleDefault, text, inputScope]));
        }

        public function onFocusIn(event:FocusEvent):void
		{
			trace("GFX - Input - Focused");
		}

		public function onFocusOut(event:FocusEvent):void
		{
			trace("GFX - Input - Focus lost");
		}

        public function resetText():void
        {
            text = "";
            cursorPos = 0;
            doPlaceholderLogic();
            updateCaretPosition();
            positionText();
            var ev : W3TextInputEvent = new W3TextInputEvent(W3TextInputEvent.TEXT_CHANGED);
            ev.text = text;
            dispatchEvent(ev);
        }

        public function setText(newText:String):void
        {
            text = newText;
            updateText();
            cursorPos = newText.length;
            doPlaceholderLogic();
            updateCaretPosition();
            positionText();
            var ev : W3TextInputEvent = new W3TextInputEvent(W3TextInputEvent.TEXT_CHANGED);
            ev.text = text;
            dispatchEvent(ev);
            arabicConvert();
        }

        private function arabicConvert():void
        {
            if(!CoreComponent.isArabicAligmentMode)
                return;
            
            var format : TextFormat = textField.getTextFormat();
            format.align = TextFormatAlign.RIGHT;
            textField.setTextFormat(format);
            textField.defaultTextFormat = format;

            format= textFieldPlaceholder.getTextFormat();
            format.align = TextFormatAlign.RIGHT;
            textFieldPlaceholder.setTextFormat(format);
            textFieldPlaceholder.defaultTextFormat = format;
        }
    }
}