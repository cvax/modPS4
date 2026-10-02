/***********************************************************************
/** Storage indicator showing used and available storage
/***********************************************************************
/** Copyright © 2025 CDProjektRed
/** Author : Lilla Toma
/***********************************************************************/

package red.game.witcher3.menus.modmenu
{	
	import flash.display.MovieClip;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.getDefinitionByName;
    import flash.events.MouseEvent;

    import scaleform.clik.core.UIComponent;

    import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Exponential;

    import red.core.events.GameEvent;
    import red.core.CoreComponent;

	public class ModMenuStorageIndicator extends UIComponent
	{
        public var tfUsed : TextField;
        public var tfAvailable : TextField;
        public var tfDynUsed : TextField;
        public var tfDynAvailable : TextField;
        public var mcProgressBar : MovieClip;
        public var mcIcon : MovieClip;

        private static const MOD_STORAGE_TEXT_GAP : Number = 0;
        private static const MOD_STORAGE_TEXT_SAFETY_LEN : Number = 39;
        private static const MOD_STORAGE_TEXT_BACKPUSH : Number = 20;

        public function setStorage(used:String, available:String)
        {
            if(CoreComponent.isArabicAligmentMode) {
                gotoAndStop("rtl");
                setupStuffForArabic(used, available);
                return;
            }
            else
                gotoAndStop("ltr");

            var usedFormatted : String = ModStatics.formatBytes(Number(used));
            var availableFormatted : String = ModStatics.formatBytes(Number(available));

            var usedStaticLength = tfUsed.textWidth;
            var availableStaticLength = tfAvailable.textWidth;
            
            //var dynStartX = (usedStaticLength > availableStaticLength) ? usedStaticLength : availableStaticLength;
            //tfDynUsed.x = tfUsed.x + dynStartX + MOD_STORAGE_TEXT_GAP;
            //tfDynAvailable.x = tfUsed.x + dynStartX + MOD_STORAGE_TEXT_GAP;

            tfDynUsed.text = usedFormatted;
            tfDynAvailable.text = availableFormatted;

            var usedDynLength = tfDynUsed.textWidth;
            var availableDynLength = tfDynAvailable.textWidth;

            var dynWidthX = (usedDynLength > availableDynLength) ? usedDynLength : availableDynLength;

            tfDynUsed.width = dynWidthX + MOD_STORAGE_TEXT_SAFETY_LEN;
            tfDynAvailable.width = dynWidthX + MOD_STORAGE_TEXT_SAFETY_LEN;
            tfDynUsed.x = mcIcon.x - tfDynUsed.width - MOD_STORAGE_TEXT_SAFETY_LEN + MOD_STORAGE_TEXT_BACKPUSH;
            tfDynAvailable.x = mcIcon.x - tfDynAvailable.width - MOD_STORAGE_TEXT_SAFETY_LEN + MOD_STORAGE_TEXT_BACKPUSH;

            var progress : Number = 100 * Number(used) / (Number(used) + Number(available));
            mcProgressBar.gotoAndStop(progress);
        }

        public function setupStuffForArabic(used : String, available: String)
        {
                var usedFormatted : String = ModStatics.formatBytes(Number(used));
                var availableFormatted : String = ModStatics.formatBytes(Number(available));

                var usedStaticLength = tfUsed.textWidth;
                var availableStaticLength = tfAvailable.textWidth;
                
                //var dynStartX = (usedStaticLength > availableStaticLength) ? usedStaticLength : availableStaticLength;
                //tfDynUsed.x = tfUsed.x + dynStartX + MOD_STORAGE_TEXT_GAP;
                //tfDynAvailable.x = tfUsed.x + dynStartX + MOD_STORAGE_TEXT_GAP;

                tfDynUsed.text = usedFormatted;
                tfDynAvailable.text = availableFormatted;

                var usedDynLength = tfDynUsed.textWidth;
                var availableDynLength = tfDynAvailable.textWidth;

                var dynWidthX = (usedDynLength > availableDynLength) ? usedDynLength : availableDynLength;
                tfDynUsed.width = dynWidthX + MOD_STORAGE_TEXT_SAFETY_LEN + 5;
                tfDynAvailable.width = dynWidthX + MOD_STORAGE_TEXT_SAFETY_LEN + 5;

                tfUsed.x = mcIcon.x - tfUsed.width - MOD_STORAGE_TEXT_SAFETY_LEN + MOD_STORAGE_TEXT_BACKPUSH;
                tfAvailable.x = mcIcon.x - tfAvailable.width - MOD_STORAGE_TEXT_SAFETY_LEN + MOD_STORAGE_TEXT_BACKPUSH;

                var progress : Number = 100 * Number(used) / (Number(used) + Number(available));
                mcProgressBar.gotoAndStop(progress);
        }
    }
}