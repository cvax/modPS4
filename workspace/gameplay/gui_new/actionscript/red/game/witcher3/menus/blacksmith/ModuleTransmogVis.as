package red.game.witcher3.menus.blacksmith
{
	import flash.events.Event;
	import red.core.events.GameEvent;
	import flash.display.MovieClip;
	import flash.events.MouseEvent; //@FIXME BIDON -> remove it (or integrate mouse to everything)
	import flash.text.TextField;
	import scaleform.clik.core.UIComponent;
	
	import scaleform.clik.constants.InputValue; //#B
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	
	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	import red.core.utils.InputUtils;
    import red.core.CoreMenuModule;
    import red.game.witcher3.slots.SlotPaperdoll;

	public class ModuleTransmogVis extends CoreMenuModule
	{
        //ART CLIPS
        public var mcCurrentBg1 : MovieClip;
        public var mcCurrentBg2 : MovieClip;
        public var mcCurrentBg3 : MovieClip;
        public var mcCurrentBg4 : MovieClip;
        public var mcCurrentItem1 : SlotPaperdoll;
        public var mcCurrentItem2 : SlotPaperdoll;
        public var mcCurrentItem3 : SlotPaperdoll;
        public var mcCurrentItem4 : SlotPaperdoll;

        public var mcAppearBg1 : MovieClip;
        public var mcAppearBg2 : MovieClip;
        public var mcAppearBg3 : MovieClip;
        public var mcAppearBg4 : MovieClip;
        public var mcAppearItem1 : SlotPaperdoll;
        public var mcAppearItem2 : SlotPaperdoll;
        public var mcAppearItem3 : SlotPaperdoll;
        public var mcAppearItem4 : SlotPaperdoll;

        public var mcArrow1 : MovieClip;
        public var mcArrow2 : MovieClip;
        public var mcArrow3 : MovieClip;
        public var mcArrow4 : MovieClip;

        private var m_positionsSetup : Boolean = false;

        public function ModuleTransmogVis()
        {

        }

        override protected function configUI():void
        {
            super.configUI();

            dispatchEvent( new GameEvent( GameEvent.REGISTER, "transmog.vis.update", [updateTransmogVis] ) );
            var paperdollArray : Array = [mcCurrentItem1, mcCurrentItem2, mcCurrentItem3, mcCurrentItem4, mcAppearItem1, mcAppearItem2, mcAppearItem3, mcAppearItem4];
            
            //#LT hack to reposition the eye transmog indicator
            for(var i : int = 0; i < paperdollArray.length; i++)
            {
                var indicator : MovieClip = paperdollArray[i].mcSlotOverlays.mcTransmogIndicator;
                indicator.width = indicator.height = 24;
                indicator.x -= 12;
                indicator.y += 20;
                paperdollArray[i].tfSlotName.visible = false;
            }
        }

        public function updateTransmogVis(data:Object)
        {
            handleUpdateEquipped(data.equipped);
            handleUpdateAppears(data.appear);

            if(!m_positionsSetup)
            {
                if(data.equipped.length == 3)
                    handle3ItemSetup();
                else if (data.equipped.length == 2)
                    handle2ItemSetup();
                else if (data.equipped.length == 1)
                    handle1ItemSetup();
                else if (data.equipped.length == 0)
                    handle0ItemSetup();

                m_positionsSetup = true;
            }
        }

        public function handleUpdateEquipped(data:Array)
        {
            var paperdollArray : Array = [mcCurrentItem1, mcCurrentItem2, mcCurrentItem3, mcCurrentItem4];
            var bgArray : Array = [mcCurrentBg1, mcCurrentBg2, mcCurrentBg3, mcCurrentBg4];

            for(var i : int = 0; i < data.length; i++)
            {
                bgArray[i].gotoAndStop(data[i].quality + 1);
                data[i].quality = 0;
                paperdollArray[i].data = data[i];
            }
        }

        public function handleUpdateAppears(data:Array)
        {
            var paperdollArray : Array = [mcAppearItem1, mcAppearItem2, mcAppearItem3, mcAppearItem4];
            var arrowArray : Array = [mcArrow1, mcArrow2, mcArrow3, mcArrow4];
            var bgArray : Array = [mcAppearBg1, mcAppearBg2, mcAppearBg3, mcAppearBg4];

            for(var i : int = 0; i < data.length; i++)
            {
                if(data[i].modified)
                {
                    bgArray[i].gotoAndStop(data[i].quality + 1);
                    data[i].quality = 0;
                    paperdollArray[i].data = data[i];
                    paperdollArray[i].visible = true;
                }
                else
                {
                    bgArray[i].gotoAndStop(1);
                    paperdollArray[i].visible = false;
                }

                arrowArray[i].alpha = data[i].modified ? 1 : 0.5;
            }
        }

        private function hideElem4()
        {
            mcCurrentItem4.visible = false;
            mcAppearItem4.visible = false;
            mcArrow4.visible = false;
            mcCurrentBg4.visible = false;
            mcAppearBg4.visible = false;
        }

        private function hideElem3()
        {
            mcCurrentItem3.visible = false;
            mcAppearItem3.visible = false;
            mcArrow3.visible = false;
            mcCurrentBg3.visible = false;
            mcAppearBg3.visible = false;
        }

        private function hideElem2()
        {
            mcCurrentItem2.visible = false;
            mcAppearItem2.visible = false;
            mcArrow2.visible = false;
            mcCurrentBg2.visible = false;
            mcAppearBg2.visible = false;
        }

        private function hideElem1()
        {
            mcCurrentItem1.visible = false;
            mcAppearItem1.visible = false;
            mcArrow1.visible = false;
            mcCurrentBg1.visible = false;
            mcAppearBg1.visible = false;
        }

        private function handle3ItemSetup()
        {
            mcCurrentItem3.x = (mcCurrentItem3.x + mcCurrentItem4.x) / 2;
            mcAppearItem3.x = (mcAppearItem3.x + mcAppearItem4.x) / 2;
            mcArrow3.x = (mcArrow3.x + mcArrow4.x) / 2;
            mcCurrentBg3.x = (mcCurrentBg3.x + mcCurrentBg4.x) / 2;
            mcAppearBg3.x = (mcAppearBg3.x + mcAppearBg4.x) / 2;

            hideElem4();
        }

        private function handle2ItemSetup()
        {
            mcCurrentItem2.x = (mcCurrentItem3.x + mcCurrentItem4.x) / 2;
            mcAppearItem2.x = (mcAppearItem3.x + mcAppearItem4.x) / 2;
            mcArrow2.x = (mcArrow3.x + mcArrow4.x) / 2;
            mcCurrentBg2.x = (mcCurrentBg3.x + mcCurrentBg4.x) / 2;
            mcAppearBg2.x = (mcAppearBg3.x + mcAppearBg4.x) / 2;
            mcCurrentItem2.y = mcCurrentItem3.y;
            mcAppearItem2.y = mcAppearItem3.y;
            mcArrow2.y = mcArrow3.y;
            mcCurrentBg2.y = mcCurrentBg3.y;
            mcAppearBg2.y = mcAppearBg3.y;

            mcCurrentItem1.x = (mcCurrentItem3.x + mcCurrentItem4.x) / 2;
            mcAppearItem1.x = (mcAppearItem3.x + mcAppearItem4.x) / 2;
            mcArrow1.x = (mcArrow3.x + mcArrow4.x) / 2;
            mcCurrentBg1.x = (mcCurrentBg3.x + mcCurrentBg4.x) / 2;
            mcAppearBg1.x = (mcAppearBg3.x + mcAppearBg4.x) / 2;

            hideElem3();
            hideElem4();
        }

        private function handle1ItemSetup()
        {
            mcCurrentItem1.x = (mcCurrentItem1.x + mcCurrentItem2.x) / 2;
            mcAppearItem1.x = (mcAppearItem1.x + mcAppearItem2.x) / 2;
            mcArrow1.x = (mcArrow1.x + mcArrow2.x) / 2;
            mcCurrentBg1.x = (mcCurrentBg1.x + mcCurrentBg2.x) / 2;
            mcAppearBg1.x = (mcAppearBg1.x + mcAppearBg2.x) / 2;
            mcCurrentItem1.y = (mcCurrentItem1.y + mcCurrentItem3.y) / 2;
            mcAppearItem1.y = (mcAppearItem1.y + mcAppearItem3.y) / 2;
            mcArrow1.y = (mcArrow1.y + mcArrow3.y) / 2;
            mcCurrentBg1.y = (mcCurrentBg1.y + mcCurrentBg3.y) / 2;
            mcAppearBg1.y = (mcAppearBg1.y + mcAppearBg3.y) / 2;

            hideElem2();
            hideElem3();
            hideElem4();
        }

        private function handle0ItemSetup()
        {
            hideElem1();
            hideElem2();
            hideElem3();
            hideElem4();
        }
    }
}