package red.game.witcher3.menus.overlay
{
	import flash.display.MovieClip;
    import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextField;
    import flash.utils.getDefinitionByName;

	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.constants.CommonConstants;
    import red.game.witcher3.controls.W3ScrollingList;
    import red.game.witcher3.controls.W3UILoader;
	import red.game.witcher3.managers.InputManager;
    import red.game.witcher3.menus.modmenu.ModImageData;
	import red.game.witcher3.menus.modmenu.VerificationModPreview;

	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.ScrollBar;
    import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
    import scaleform.clik.events.ListEvent;
    import scaleform.clik.interfaces.IListItemRenderer;
	import scaleform.clik.ui.InputDetails;

	/**
	 * ...
	 * @author Lilla Toma
	 */
	public class ModVerificationPopup extends BasePopup
	{
		private static const HEIGHT_PADDING: Number = 10;
		private static const INPUT_PADDING: Number = 10;
		private static const FINAL_HEIGHT_PADDING: Number = 40;
        private static const MOD_PREVIEW_GAP : Number = 5;
        private static const MAX_RENDERERS = 5;
		
		public var txtMessage:TextField;
		public var txtTitle:TextField;
        public var txtReason:TextField
		public var txtAction:TextField;
		public var textBorder:MovieClip;
		private var curHeight:Number;
		private var curWidth: Number;
		public var mcHeader: MovieClip;
		public var mcInputBackground: MovieClip;
		public var mcBackground: MovieClip;
        public var mcModList	: W3ScrollingList;
        public var mcScrollbar 				: ScrollBar;

		protected var _lastMouseOveredItem:int = -1;
		public var _lastMoveWasMouse:Boolean = true;
        private var renderers : Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>();
		
        private var rendererHeight:Number = 0;

		public function ModVerificationPopup()
		{
			mcModList.itemRendererName = "VerificationModPreview";
		}

        override protected function configUI():void
        {
            super.configUI();

            mcModList.addEventListener(ListEvent.INDEX_CHANGE, onOptionSelectionChanged);
			mcModList.addEventListener( ListEvent.ITEM_CLICK, onItemClicked, false, 0, true ); 
			mcModList.ShowRenderers(true);
			mcModList.scrollBar = mcScrollbar;
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
        }

		override protected function populateData():void
		{	
			txtMessage.htmlText = _data.TextContent;
			txtMessage.height = txtMessage.textHeight + CommonConstants.SAFE_TEXT_PADDING;
			txtTitle.htmlText = CommonUtils.toUpperCaseSafe( _data.TextTitle );
			if(txtReason)
				txtReason.visible = false;
            //txtReason.htmlText = _data.TextReason;
			if(txtAction)
			{
				txtAction.visible = true;
				if(_data.TextAction)
					txtAction.htmlText = _data.TextAction;
				else
					txtAction.visible = false;
			}
			if (txtTitle.text == "")
			{
				txtMessage.y = 16.85;
                //txtReason.y = 60;
				mcHeader.visible = false;
			}

			//txtReason.y = txtMessage.y + txtMessage.textHeight + HEIGHT_PADDING;
			setupPage(_data.ModList, 10, txtMessage.y + txtMessage.textHeight + HEIGHT_PADDING);
			mcScrollbar.y = txtMessage.y + txtMessage.textHeight + HEIGHT_PADDING;
            mcScrollbar.height = rendererHeight * renderers.length;

			if(renderers.length > 0)
			{
				curWidth = 20 + renderers[0].width;
				if(_data.ModList.length > MAX_RENDERERS)
					curWidth += mcScrollbar.width + 20;
				mcScrollbar.x = 20 + renderers[0].width + 5;
				mcBackground.width = curWidth;
				mcHeader.width = curWidth - 2;
				txtTitle.width = curWidth - 4;

				var prevMessageHeight : Number = txtMessage.textHeight;
				txtMessage.width = curWidth - 100;
				for(var i : int = 0; i < renderers.length; i++)
					renderers[i].y += txtMessage.textHeight - prevMessageHeight;


				//txtReason.width = curWidth - 100;
				txtMessage.x = (mcBackground.width - txtMessage.width) / 2;
				txtTitle.x = (mcBackground.width - txtTitle.width) / 2;
				//txtReason.x = (mcBackground.width - txtReason.width) / 2;
				mcInpuFeedback.x = curWidth - (curWidth - mcInpuFeedback.width) / 2
			}
			else
			{
				curWidth = mcBackground.width;
			}

			curHeight = txtMessage.y + txtMessage.textHeight + rendererHeight * renderers.length + HEIGHT_PADDING * 2;

			if(txtAction && _data.TextAction)
			{
				txtAction.y = txtMessage.y + txtMessage.textHeight + 2 * HEIGHT_PADDING + rendererHeight * renderers.length;
				txtAction.width = curWidth - 100;
				txtAction.x = (mcBackground.width - txtAction.width) / 2;
				curHeight += txtAction.textHeight + HEIGHT_PADDING;
				txtAction.height = txtAction.textHeight + 7;
			}

			//curHeight -= 50;
			
			mcBackground.height = curHeight + FINAL_HEIGHT_PADDING;
			mcInputBackground.y  = mcBackground.height - mcInputBackground.height / 2;
			mcInpuFeedback.y = mcInputBackground.y + mcInputBackground.height / 2;
			mcInpuFeedback.handleSetupButtons(_data.ButtonsList);
			mcInputBackground.x = mcBackground.width / 2;
			mcInputBackground.width = mcInpuFeedback.buttonsContainer.width + INPUT_PADDING;

			// calling super at end because it only handles positioning and now we have correct sizes
			if(parent is OverlayPanel)
				super.populateData();
			else
			{
				this.x = (1920 - mcBackground.width) / 2;
				this.y = (1080 - mcBackground.height) / 2;
			}
			mcInpuFeedback.clearHotkeys();
		}


        protected function updateData(modList:Array)
		{
			trace("ModVerificationPopup - UPDATEDATA");

			mcModList.dataProvider = new DataProvider(modList);
			trace("GFX - dataprovider length", mcModList.dataProvider.length);
			mcModList.validateNow();
		}

		protected function setupPage(modList:Array, startX:Number, startY:Number)
		{
			trace("ModVerificationPopup - SETUPPAGE", modList.length);
			//clearPage();

			renderers = new Vector.<IListItemRenderer>();
			for( var i : int = 0; i < modList.length && i < MAX_RENDERERS; i++)
			{
				var classRef:Class = getDefinitionByName("VerificationModPreview") as Class;
				var modPreview:VerificationModPreview = new classRef() as VerificationModPreview;
                //modPreview.menuName = menuName;
				trace("JIFIX element", i);
				addChild(modPreview);
				modPreview.x = startX;
				modPreview.y = startY + i * (modPreview.height + MOD_PREVIEW_GAP);
                rendererHeight = modPreview.height + MOD_PREVIEW_GAP;
				if(!modList[i].UGCAllowed)
				{
					modPreview.y -= i * 40;
					rendererHeight -= 40;
				}
				//modPreview.setData(modList[i]);
				renderers.push(modPreview);
			}
			mcModList.itemRendererList = renderers;
			updateData(modList);
			mcModList.selectedIndex = 0;
			mcModList.ShowRenderers(true);
			mcModList.validateNow();
			highlightSelectedRenderer();

			trace("ModVerificationPopup - SETUPPAGE END!", modList.length);
		}

		private function deselectAllPreviews()
		{
			for( var i : int = 0; i < renderers.length; i++)
			{
				(renderers[i] as VerificationModPreview).deselect();
			}
		}

        public function onItemClicked(event : ListEvent):void
		{
			var item : VerificationModPreview;
			item = event.itemRenderer as VerificationModPreview;

			if (!item.bSelected) {

				deselectAllPreviews();
				item.onSelect();

				_lastMouseOveredItem = mcModList.getRenderers().indexOf(item);
				//setupCheckboxHitForSelectedRenderer();
			}
		}

		public function get lastMoveWasMouse():Boolean { return _lastMoveWasMouse; }
		public function set lastMoveWasMouse(value:Boolean):void
		{
			_lastMoveWasMouse = value;
			
			if (_lastMoveWasMouse)
			{
				if (_lastMouseOveredItem != -1)
				{
					mcModList.selectedIndex = _lastMouseOveredItem;
				}
			}
			else
			{
				if (mcModList.selectedIndex == -1)
				{
					mcModList.selectedIndex = 0;
				}
			}
		}

		function onOptionSelectionChanged(e:ListEvent):void
		{

		}

		
		private function handleScroll(e:Event) : void
		{
			mcModList.validateNow();
			
			if (_lastMouseOveredItem != -1 && lastMoveWasMouse)
			{
				var currentTarget:VerificationModPreview  = mcModList.getRendererAt(_lastMouseOveredItem) as VerificationModPreview;
				
				if (currentTarget)
				{
					mcModList.selectedIndex = currentTarget.index;
					mcModList.validateNow();
				}
			}
		}

		override public function handleInput(event:InputEvent):void
		{
			super.handleInput(event);
			if (event.handled || !visible)
			{
				return;
			}

			var details:InputDetails = event.details;

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var hold:Boolean = details.value == InputValue.KEY_HOLD;
			var keyUp:Boolean = details.value == InputValue.KEY_UP;

			if(details.navEquivalent == NavigationCode.DOWN && (keyDown || hold))
			{
				if(mcModList.selectedIndex < mcModList.dataProvider.length - 1)
				{
					mcModList.selectedIndex++;
					mcModList.validateNow();
					highlightSelectedRenderer();
					event.handled = true;
				}
			}
			else if (details.navEquivalent == NavigationCode.UP && (keyDown || hold))
			{
				if(mcModList.selectedIndex > 0)
				{
					mcModList.selectedIndex--;
					mcModList.validateNow();
					highlightSelectedRenderer();
					event.handled = true;
				}
			}

			if ( !event.handled )
			{
				var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();

                if(((isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y) ||		// Y on switch
					(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X) ||		// X on other platforms
					details.code == KeyCode.SPACE) &&
					details.value == InputValue.KEY_UP)
                {
					var selectedRenderer:VerificationModPreview = null;
					var firstIndex:int = mcModList.getRenderers()[0].index;
					selectedRenderer = mcModList.getRendererAt(mcModList.selectedIndex - firstIndex) as VerificationModPreview;
					if(selectedRenderer)
					{
						selectedRenderer.onEnabledChange();
						//mcModList.dataProvider[mcModList.selectedIndex].enabled = !mcModList.dataProvider[mcModList.selectedIndex].enabled;
					}
                }
			}
		}

		protected function highlightSelectedRenderer()
		{
			var selectedIndex:int = mcModList.selectedIndex;
			var selectedRenderer:VerificationModPreview = null;

			if(mcModList.getRenderers().length > 0)
			{
				var firstIndex:int = mcModList.getRenderers()[0].index;
				selectedRenderer = mcModList.getRendererAt(selectedIndex - firstIndex) as VerificationModPreview;
				_lastMouseOveredItem = selectedIndex - firstIndex;
			}
			if(selectedRenderer != null)
			{
				deselectAllPreviews();
				selectedRenderer.onSelect();
			}
		}
	}

}