package red.game.witcher3.slots
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
    import flash.utils.getDefinitionByName;

	import red.core.constants.KeyCode;
	import red.game.witcher3.constants.InventoryActionType;
	import red.game.witcher3.constants.InventorySlotType;
	import red.game.witcher3.events.GridEvent;
	import red.game.witcher3.events.SlotActionEvent;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IInventorySlot;
	import red.game.witcher3.managers.InputManager;

    import scaleform.clik.core.UIComponent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.events.InputEvent;
	import scaleform.gfx.MouseEventEx;
	
	public class SlotPointIndicator extends UIComponent
	{
		public var spawnedClips : Vector.<MovieClip> = new Vector.<MovieClip>();
		
        public function clean():void
        {
            for(var i : int = 0; i < spawnedClips.length; i++)
                removeChild(spawnedClips[i]);
            spawnedClips = new Vector.<MovieClip>();
        }

        public function setCount(filled : int, max : int)
        {
            var indicatorRef : Class = getDefinitionByName("SkillPointIndicatorSingle") as Class;

            clean();

            for(var i : int = 0; i < max; i++)
            {
                var indicator : MovieClip = new indicatorRef() as MovieClip;

                addChild(indicator);
                spawnedClips.push(indicator);

                indicator.x = (i - (max - 1) / 2) * indicator.width;

                indicator.gotoAndStop(i < filled ? "on" : "off");
            }
        }

        public function setColor(color:String)
        {
            for(var i : int = 0; i < spawnedClips.length; i++)
            {
                var clip : MovieClip = spawnedClips[i];

                if(clip.getChildByName("mcBackground"))
                    clip.mcBackground.gotoAndStop(color);
            }
        }
		
		
	}
}
