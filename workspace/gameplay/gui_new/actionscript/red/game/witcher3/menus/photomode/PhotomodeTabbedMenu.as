package red.game.witcher3.menus.photomode 
{
	import flash.display.MovieClip;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	import flash.utils.getDefinitionByName;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.controls.ButtonBar;
	import scaleform.clik.events.IndexEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.interfaces.IDataProvider;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import red.game.witcher3.managers.InputManager;
	import scaleform.clik.controls.Button;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import scaleform.clik.interfaces.IListItemRenderer;
	import red.game.witcher3.controls.W3ScrollingList;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.constants.EInputDeviceType;
	import flash.events.Event;
	
	public class PhotomodeTabbedMenu extends UIComponent
	{
		public var m_buttonBar : ButtonBar;
		public var m_content : W3ScrollingList;

		private var m_bigTabBar : PhotomodeTabRenderer;
		
		public var m_contentItem1 : PhotomodeMenuElement;
		public var m_contentItem2 : PhotomodeMenuElement;
		public var m_contentItem3 : PhotomodeMenuElement;
		public var m_contentItem4 : PhotomodeMenuElement;
		public var m_contentItem5 : PhotomodeMenuElement;
		public var m_contentItem6 : PhotomodeMenuElement;

		// public var mc_tabbedBackground : MovieClip;

		private var m_cachedData : DataProvider;
		
		override protected function configUI():void
		{
			super.configUI();
			
			m_content.dataProvider = new DataProvider();
			m_content.removeEventListener(InputEvent.INPUT, m_content.handleInput);	
			
			m_buttonBar.addEventListener(IndexEvent.INDEX_CHANGE, onTabChange);		
			
			this.removeEventListener(InputEvent.INPUT, handleInput);
			stage.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
			dispatchEvent( new GameEvent( GameEvent.REGISTER, "photomode.override.elements", [onOverrideElements] ) );
			m_content.scrollBar.addEventListener( Event.SCROLL, handleScroll, false, 1, true) ;

			m_contentItem1.addEventListener("PM_ELEM_SETDATA", handleContentItemChanged);

			m_buttonBar.unbindInputs();

		 	// if(mc_tabbedBackground)
			// 	mc_tabbedBackground.visible(false);
		}

		public function onUpdateParam( param : Object ):void 
		{
			var elems:* = 
			([m_contentItem1, m_contentItem2, m_contentItem3, m_contentItem4, m_contentItem5, m_contentItem6]);


			var id : uint = param.id;
			var value : Number = param.value;


			var tabsData : DataProvider = m_buttonBar.dataProvider as DataProvider;
			for(var i : int = 0; i < tabsData.length; i++)
			{
				var tabModel : Object = tabsData[i];
				for(var j : int = 0; j < tabModel.data.length; j++)
				{
					var elemData : Object = tabModel.data[j];
					
					if(elemData.data.rendererType == "slider" || elemData.data.rendererType == "selector" || elemData.data.rendererType == "colorSlider") 
					{
						if(elemData.sliderData.id == id) 
						{
							elemData.sliderData.currentValue = value;
						}
					}
					else 
					{
						if(elemData.data.args.id == id) 
						{
						}
					}					
				}
			}		

			// call photomode element param update because we removed the individual key listener
			for(var z : int = 0; z < elems.length; z++) {
				if(elems[z]) //it can be uninited
					elems[z].onUpdateParam(param);			
			}
			//m_slider.value = value;
		}

		//array of changes needed to be pushed, because link only updates once per frame
		public function /*WS*/ onOverrideElements(data:Array):void
		{
			for(var i : int = 0; i < data.length; i++)
				onOverrideElement(data[i]);

			reloadCurrentTab();
		}

		public function onOverrideElement(data:Object):void
		{
			var item : Object = data.item;
			var dataObj : Object = { data: item }; 
			var id : uint = data.id;

			if(item.rendererType == "slider" || item.rendererType == "selector" || item.rendererType == "colorSlider") {
				var sliderModel : PhotomodeSliderDataModel = new PhotomodeSliderDataModel();
				sliderModel.setDataModel.apply(sliderModel, item.args);
				dataObj["sliderData"] = sliderModel;
			}

			var tabsData : DataProvider = m_buttonBar.dataProvider as DataProvider;
			for(var i : int = 0; i < tabsData.length; i++)
			{
				var tabModel : Object = tabsData[i];
				for(var j : int = 0; j < tabModel.data.length; j++)
				{
					var elemData : Object = tabModel.data[j];
					
					if(elemData.data.rendererType == "slider" || elemData.data.rendererType == "selector" || elemData.data.rendererType == "colorSlider"  ) 
					{
						if(elemData.sliderData.id == id) 
						{
							tabModel.data[j] = dataObj;
							break;
						}
					}
					else 
					{
						if(elemData.data.args.id == id) 
						{
							tabModel.data[j] = dataObj;
							break;
						}
					}
				}
			}
		}
		
		public function setTabs(data:DataProvider):void
		{
			var totalWidth = 800;
			var tabCount = data.length;

			if(tabCount > 0 && !m_bigTabBar) {
				m_buttonBar.buttonWidth = totalWidth / tabCount;
				var classRef:Class = getDefinitionByName("PhotomodeTabRendererBig") as Class;
				m_bigTabBar = new classRef() as PhotomodeTabRenderer;
				this.addChild(m_bigTabBar);
				m_bigTabBar.y = m_buttonBar.y - m_bigTabBar.height - 5;
				m_bigTabBar.x = m_buttonBar.x;

				m_bigTabBar.m_containsTitle = true;
				m_bigTabBar.m_resize = false;
			}

			m_buttonBar.dataProvider = data;
			m_buttonBar.selectedIndex = 0;
			m_buttonBar.validateNow();

			analyzeCurrentTabForHints();

			m_cachedData = data;
		}

		private function removeTabHints():void
		{
			var menu : PhotomodeMenu = parent as PhotomodeMenu;

			if(menu)
			{
				menu.removeHintArea("multiple");
				menu.removeHintArea("changeValue");
				menu.removeHintArea("saver");
			}
		}
		
		private function analyzeCurrentTabForHints():void
		{
			removeTabHints();

			var menu : PhotomodeMenu = parent as PhotomodeMenu;

			if(!menu)
				return;

			var data : DataProvider = m_content.dataProvider as DataProvider;

			if(data)
			{
				if(data.length > 1)
					menu.addHintArea("multiple");

				for(var i : int = 0; i < data.length; i++)
				{
					var elem : Object = data[i];

					if(elem.data.rendererType == "slider" || elem.data.rendererType == "selector" || elem.data.rendererType == "colorSlider")  
						menu.addHintArea("changeValue");
					else if(elem.data.rendererType == "saver")
						menu.addHintArea("saver");
				}
			}
		}

		private function reloadCurrentTab():void
		{
			var dataProvider = m_content.dataProvider as IDataProvider;
			
			if (dataProvider == null)
				return;

			var previousSelectedElement : int = m_content.selectedIndex;
			var previousSelectedTab : int = m_buttonBar.selectedIndex;
			var previousScrollPosition : Number = m_content.scrollPosition;

			//#LT: hacky, but i need the whole flow to retrigger here.
			m_buttonBar.selectedIndex = m_buttonBar.selectedIndex == 0 ? 1 : 0;
			m_buttonBar.validateNow();
			m_buttonBar.selectedIndex = previousSelectedTab;
			m_buttonBar.validateNow();
			
			//and this is to restore the last selected element to make it feel seemless
			m_content.selectedIndex = previousSelectedElement;
			m_content.scrollPosition = previousScrollPosition;
			m_content.validateNow();
			repositonElements();
		}

		private function onTabChange(event:IndexEvent):void 
		{
			if (event.data == null)
				return;
			
			var dataProvider = event.data.data as IDataProvider;
			
			if (dataProvider == null)
				return;

			setAllowValueChangeEvents(false);
			
			m_content.dataProvider = dataProvider;
			m_content.selectedIndex = 0;
			m_content.validateNow();

			analyzeCurrentTabForHints();

			//cleaning up locked focus
			stage.focus = null;

			if(m_bigTabBar)
			{
				m_bigTabBar.data = event.data;
				m_bigTabBar.selected = true;
				m_bigTabBar.forceUpdateData(event.data);
			}
			repositonElements();

			dispatchEvent( new GameEvent( GameEvent.CALL, "OnPhotomodeTabChanged", [event.index] ) );
		}

		private var m_lockHeld : Boolean = false;
		private var m_holdTime : int;

		private static const HOLD_NEEDED : int = 2000;

		public function getLockPercentage():Number
		{
			if(!m_lockHeld)
				return 0;

			var passed = (getTimer() - m_holdTime)

			return 100 * passed / HOLD_NEEDED;
		}


		private function executeLockCamera():void
		{
			m_lockHeld = false;
			dispatchEvent( new GameEvent( GameEvent.CALL, "OnSwapLockCamera" ) );

			var menu : PhotomodeMenu = parent as PhotomodeMenu;

			if(!menu)
				return;

			menu.swapLockCamera();
		}

		private var execCameraTimeoutValid : Boolean = false;
		private var execCameraTimeoutId : uint = 0;
		private function handleLockCamera(event:InputEvent):void
		{
			var details:InputDetails = event.details;

			var keyDown:Boolean = details.value == InputValue.KEY_DOWN;
			var keyHold:Boolean = details.value == InputValue.KEY_HOLD; 
			var keyUp:Boolean = details.value == InputValue.KEY_UP; 

			if(keyDown)
			{
				m_lockHeld = true;
				m_holdTime = getTimer();
				execCameraTimeoutId = setTimeout(executeLockCamera, HOLD_NEEDED);
				execCameraTimeoutValid = true;
			}
			else if (keyUp)
			{
				m_lockHeld = false;
				if(execCameraTimeoutValid) 
				{
					clearTimeout(execCameraTimeoutId);
					execCameraTimeoutValid = false;
				}
			}
		}
		
		public override function handleInput(event:InputEvent):void 
		{
			var details:InputDetails = event.details;
			
			var keyDown:Boolean = details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD; //#B should be also hold here
			var isSwitchPlatform : Boolean = InputManager.getInstance().isSwitchPlatform();
			var isSwitch2Mouser:Boolean = InputManager.getInstance().gamepadType == EInputDeviceType.IDT_Switch2_Mouser;
				
			//this needs to check for keyup and keydown too
			if(details.code == KeyCode.T ||
				(isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_X) ||		// X on switch
				(!isSwitchPlatform && details.navEquivalent == NavigationCode.GAMEPAD_Y))		// Y on other platforms
			{
				handleLockCamera(event);
			}

			if(!visible || (parent && !parent.visible))
				return;
			
			var validButtonPressed : Boolean = true;

			if(keyDown)
			{
				switch (details.code) 
				{
				case KeyCode.Q:
				case KeyCode.PAD_LEFT_SHOULDER:
					if (!isSwitch2Mouser)
					{
						m_buttonBar.selectedIndex = m_buttonBar.selectedIndex == 0 ? 0 : m_buttonBar.selectedIndex - 1;
					}
					break;
				case KeyCode.E:
				case KeyCode.PAD_RIGHT_SHOULDER:
					if (!isSwitch2Mouser)
					{
						m_buttonBar.selectedIndex = m_buttonBar.selectedIndex == m_buttonBar.dataProvider.length - 1 ? m_buttonBar.selectedIndex : m_buttonBar.selectedIndex + 1;
					}
					break;
				case KeyCode.PAD_DIGIT_DOWN:
					m_content.selectedIndex = m_content.selectedIndex == m_content.dataProvider.length - 1 ? m_content.selectedIndex : m_content.selectedIndex + 1;
					break;
				case KeyCode.DOWN:
					if (InputManager.getInstance().isGamepad())
						break;
					m_content.selectedIndex = m_content.selectedIndex == m_content.dataProvider.length - 1 ? m_content.selectedIndex : m_content.selectedIndex + 1;
					break;
				case KeyCode.PAD_DIGIT_UP:
					m_content.selectedIndex = m_content.selectedIndex == 0 ? 0 : m_content.selectedIndex - 1;
					break;
				case KeyCode.UP:
					if (InputManager.getInstance().isGamepad())
						break;
					m_content.selectedIndex = m_content.selectedIndex == 0 ? 0 : m_content.selectedIndex - 1;
					break;
				default:
					validButtonPressed = false;
					break;
				}
			}
			if(validButtonPressed)
			{
				m_content.validateNow();
				setAllowValueChangeEvents(false);
				//repositonElements();
			}
		}

		private function handleScroll(e:Event) : void
		{
			setAllowValueChangeEvents(false);
			m_content.validateNow();
			setTimeout(repositonElements, 1)
		}		

		private function handleContentItemChanged(e:Event):void
		{
			//delay, because this is only the 1st element, and the other elements update after it, but we cannot assume how many are active, only that the first is
			setTimeout(repositonElements, 1)
		}

		public function repositonElements(): void
		{	
			var data : DataProvider = m_content.dataProvider as DataProvider;
			var elementList : Vector.<IListItemRenderer> = m_content.getRenderers();

			var trackY : Number = 57;

			var elem : PhotomodeMenuElement;
			var photomodeRenderer : PhotomodeRenderer;
			var elemdata : Object ;

			if(data)
			{
				for(var i : int = 0; i < elementList.length; i++)
				{
				 	elem = elementList[i] as PhotomodeMenuElement;
					photomodeRenderer = elem.GetPhotoModeRenderer();
					
					if(!photomodeRenderer)
						break;

					elemdata = photomodeRenderer.data;
				
					if(elemdata.data.rendererType == "charSlotSelector"  )
					{
						elem.y = trackY;
						trackY += 135;
					}
					else if(elemdata.data.rendererType == "propsSlotSelector" )
					{
						elem.y = trackY;
						trackY += 190;
					}
					else if(elemdata.data.rendererType == "lightSlotSelector" )
					{
						elem.y = trackY;
						trackY += 135;
					}
					else
					{
						elem.y = trackY;
						trackY += 60;
					}
				}
			}

			m_content.validateNow();

			//extra
			//setAllowValueChangeEvents(true);
		}

		protected function setAllowValueChangeEvents(value : Boolean)
		{
			m_contentItem1.setAllowValueChangeEvent(value);
			m_contentItem2.setAllowValueChangeEvent(value);
			m_contentItem3.setAllowValueChangeEvent(value);
			m_contentItem4.setAllowValueChangeEvent(value);
			m_contentItem5.setAllowValueChangeEvent(value);
		}
	}
}