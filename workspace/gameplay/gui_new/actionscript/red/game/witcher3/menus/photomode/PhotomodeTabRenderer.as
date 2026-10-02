package red.game.witcher3.menus.photomode 
{
	import scaleform.clik.controls.Button;	
	import flash.display.MovieClip;

	public class PhotomodeTabRenderer extends Button
	{
		public var m_icon : MovieClip;
		public var m_background : MovieClip;

		public var m_containsTitle : Boolean = false;
		public var m_resize : Boolean = true;


		override protected function configUI():void 
		{
			constraintsDisabled = true;
			preventAutosizing = true;

            super.configUI();
		}

        protected override function updateText():void 
		{
			var totalWidth : Number = 800;

			if(!m_containsTitle)
				_label = "";

			super.updateText();

			var tabId : String = data.tabId;

            m_icon.gotoAndStop( tabId );
			m_icon.visible = true;

			const iconPadding : Number = 2;
			const displayBlockSize : Number = textField.textWidth + iconPadding + m_icon.width;

			if(m_resize)
				m_background.width = totalWidth / data.totalTabs;
			m_icon.x = m_background.width / 2 - displayBlockSize / 2;
			m_icon.alpha = _selected ? 1 : .6;
			textField.x = m_icon.x + m_icon.width + iconPadding;
			textField.width = textField.textWidth + 5;
        }

		public function forceUpdateData(_data:Object)
		{
			data = _data;
			_label = data.label;
			updateText();
		}
	}
}