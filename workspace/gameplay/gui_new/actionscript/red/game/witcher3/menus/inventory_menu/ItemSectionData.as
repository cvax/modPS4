package red.game.witcher3.menus.inventory_menu
{
	import flash.display.MovieClip;
	
	// red.game.witcher3.menus.inventory_menu.ItemSectionData
	public dynamic class ItemSectionData
	{
		public var id 	  : uint;
		public var label  : String;
		public var start  : uint;
		public var end    : uint;
		public var border : MovieClip;
		
		// Don't use parameterized constructor, as it will explode when instanced in witcherscript!!!!!
		// public function ItemSectionData(id : uint, start:uint, end:uint, label:String, border:MovieClip = null):void
		// {
		//		setData(id, start, end, label, border)
		// }

		public function setData(id : uint, start:uint, end:uint, label:String, border:MovieClip = null)
		{
			this.id = id;
			this.start = start;
			this.end = end;
			this.label = label;
			this.border = border;
		}
		
		public function toString():String
		{
			return "[ItemSectionData GROUP <" +id +"> :\"" + label + "\" ( " + start + " : " + end + " ) ]";
		}
	}
}
