/***********************************************************************
/**
/***********************************************************************
/** Copyright © 2014 CDProjektRed
/** Author : 	Bartosz Bigaj
/***********************************************************************/

package red.game.witcher3.menus.glossary
{
	import red.core.events.GameEvent;
	import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.menus.common.JournalRewardModule;
	import scaleform.clik.events.ListEvent;
	import red.game.witcher3.managers.InputFeedbackManager;
	import scaleform.clik.constants.NavigationCode;
	import red.core.constants.KeyCode;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import red.game.witcher3.managers.InputManager;
	import com.gskinner.motion.GTweener;

	
	public class GlossarySubListModule extends JournalRewardModule
	{
		/********************************************************************************************************************
			ART CLIPS
		/ ******************************************************************************************************************/
		
		public var mcLoader : W3UILoader;
		
		/********************************************************************************************************************
			PRIVATE VARIABLES
		/ ******************************************************************************************************************/
		private var m_imagePath : String;
		/********************************************************************************************************************
			PRIVATE CONSTANTS
		/ ******************************************************************************************************************/
		/********************************************************************************************************************
			INITIALIZATION
		/ ******************************************************************************************************************/
		
		public function GlossarySubListModule()
		{
			super();
			mcRewards.titleString = "[[panel_glossary_recommended]]";
			dataBindingKey = "glossary.bestiary.sublist";
			mcRewards.dataBindingKeyReward = "glossary.bestiary.sublist.items";
			mcRewards.activeSelectionVisible = false;
		}
		
		protected override function configUI():void
		{
			dispatchEvent( new GameEvent( GameEvent.REGISTER, dataBindingKey+'.image', [handleSetImage]));
			super.configUI();
			
			mcRewards.visible = true;
			mcRewards.addEventListener( ListEvent.INDEX_CHANGE, onGridListItemChange, false, 0, true );

			stage.addEventListener(InputEvent.INPUT, handleInputNavigate, false, 5, true);
		}
		
		override public function set focused(value:Number):void 
		{
			super.focused = value;
			
			mcRewards.activeSelectionVisible = value;
			//mcRewards.mcRewardGrid.
		}

		override public function toString() : String
		{
			return "[W3 GlossarySubListModule]"
		}
		
		/********************************************************************************************************************
			PRIVATE FUNCTIONS
		/ ******************************************************************************************************************/
		
		public function handleSetImage( value : String ) : void
		{
			handleDataChanged();
			mcLoader.source = "img://textures/journal/bestiary/" + value;
			m_imagePath = value;
		}

		private function onGridListItemChange( event : ListEvent ):void
		{
			var name : String = event.itemData.itemName;
		}

		private function handleInputNavigate(event:InputEvent):void
		{	
			var details:InputDetails = event.details;

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD; //#LT should also be hold here
			var keyUp:Boolean = details.value == InputValue.KEY_UP;
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
		}

		
        private function customEase(ratio: Number, unused1: Number, unused2: Number, unused3: Number):Number
        {
            return ratio;
        }
	}
}
