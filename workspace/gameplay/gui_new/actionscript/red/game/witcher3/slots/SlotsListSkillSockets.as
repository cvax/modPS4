package red.game.witcher3.slots
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import red.game.witcher3.interfaces.IBaseSlot;
	
	/**
	 * Applied skills list for Character Development menu
	 * @author Getsevich Yaroslav
	 */
	public class SlotsListSkillSockets extends SlotsListPreset
	{
		private var _slotContainer:MovieClip;

		override protected function configUI():void
		{
			super.configUI();
			
			_allowKeyDowns = true;
		}
		
		override protected function initRenderers():void
		{
			trace("GFX # initRenderers");
			super.initRenderers();
			
			// hack to restore proper indexes
			
			if (_renderers)
			{
				_renderers.sort(rendererNameSorter);
				_renderers.forEach( function(t:SlotBase) { t.index = _renderers.indexOf(t)  } );
			}
			
		}		
		
		override protected function rendererNameSorter(element1:IBaseSlot, element2:IBaseSlot):Number
		{
			var uiComponent1:SlotSkillSocket = element1 as SlotSkillSocket;
			var uiComponent2:SlotSkillSocket = element2 as SlotSkillSocket;

			if (!uiComponent1 && !uiComponent2) {

				var mcElem1 : MovieClip = element1 as MovieClip;
				var mcElem2 : MovieClip = element2 as MovieClip;
				return (mcElem1.name < mcElem2.name)? -1 : 1;
			}

			if(uiComponent1 && !uiComponent2) return -1;
			else if(uiComponent2 && !uiComponent1) return 1;

			return (uiComponent1.slotId < uiComponent2.slotId) ? -1 : 1;
		}
		
		
		/*
		override public function findSelection():void
		{
			var er:Error = new Error();
			
			trace("GFX --- CALL findSelection ", er.getStackTrace() );
			
			super.findSelection();
			
			trace("GFX # RES SEL: ", selectedIndex);
		}
		
		override public function set selectedIndex(value:int):void
		{
			var er:Error = new Error();
			
			trace("GFX --- CALL selectedIndex [", value, "] ", er.getStackTrace() );
			
			super.selectedIndex = value;
			
			trace("GFX * RES SEL: ", selectedIndex);
		}
		*/
		/*
		public function traceRenderers():void
		{
			var renderersCount:int = _renderers.length;

			var targetRenderer:MovieClip;
			
			for (var i:int = 0; i < renderersCount; i++)
			{
				targetRenderer = _renderers[i] as MovieClip;
				trace("GFX - i:", i , targetRenderer.name);
			}
		}*/
		
		override protected function populateData():void
		{
			super.populateData();
			
			if (!_renderers || !_renderers.length)
			{
				return;
			}
			
			var listLen:int = _data.length;
			
			for (var i:int = 0; i < listLen; i++ )
			{
				var targetData:Object = _data[i];
				var targetRenderer:SlotSkillSocket = getRendererById(targetData.slotId);
				if (targetRenderer)
				{
					targetData.gridSize = 1;
					targetRenderer.data	= targetData;
				}
			}
		}
		
		override protected function cleanupRenderers():void
		{
			var renderersCount:int = _renderers.length;
			
			for (var i:int = 0; i < renderersCount; i++)
			{
				var targetRenderer:SlotSkillSocket = _renderers[i] as SlotSkillSocket;
				if (targetRenderer)
				{
					targetRenderer.cleanup();
				}
			}
		}
		
		public function hasSkillWithType(skillType:int):Boolean
		{
			var renderersCount:int = _renderers.length;
			
			for (var i:int = 0; i < renderersCount; ++i)
			{
				var targetRenderer:SlotSkillSocket = _renderers[i] as SlotSkillSocket;
				if (targetRenderer && targetRenderer.data && targetRenderer.data.skillType == skillType)
				{
					return true;
				}
			}
			
			return false;
		}
		
		protected function getRendererById(slotId:int):SlotSkillSocket
		{
			var len:int = _renderers.length;
			var curRenderer:SlotSkillSocket;
			
			for (var i:int = 0; i < len; i++)
			{
				curRenderer = _renderers[i] as SlotSkillSocket;
				if (curRenderer && curRenderer.slotId == slotId)
				{
					return curRenderer;
				}
			}
			return null;
		}
		
		public function updateSpecificData(value:Object):void
		{
			var targetRenderer:SlotSkillSocket = getRendererById(value.slotId);
			
			if (targetRenderer)
			{
				value.gridSize = 1;
				targetRenderer.data	= value;
			}
		}
		
		public function clearSkillSlot(slotId:int):void
		{
			var dataRef:Object;
			var targetRenderer:SlotSkillSocket = getRendererById(slotId);
			
			if (targetRenderer && targetRenderer.data)
			{
				dataRef = targetRenderer.data;
				
				dataRef.id = 0; //Empty
				dataRef.skillTypeId = 0;
				dataRef.skillType = 0;
				dataRef.skillPath = SlotSkillSocket.NULL_SKILL;
				dataRef.maxLevel = 0;
				dataRef.iconPath = "";
				dataRef.color = 0;
				dataRef.isEquipped = false;
				
				targetRenderer.data = dataRef;
			}
		}
		
		public function get slotContainer():MovieClip {	return _slotContainer; }
		public function set slotContainer(value:MovieClip):void
		{
			if (_slotContainer != value && value != null)
			{
				_slotContainer = value;
				
				initRenderers();
				populateData();
			}
		}
		
		override protected function getSlotsContainer():DisplayObjectContainer
		{
			return _slotContainer;
		}
		
		override public function toString():String
		{
			return "SlotsListSkillSockets [" + this.name+"]";
		}
		
	}
}
