package red.game.witcher3.menus.character_menu
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.TextEvent;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import flash.text.TextField;
	import red.core.constants.KeyCode;
	import red.core.data.InputAxisData;
	import red.core.events.GameEvent;
	import red.core.utils.InputUtils;
	import red.game.witcher3.controls.AdvancedTabListItem;
	import red.game.witcher3.controls.W3Button;
	import red.game.witcher3.events.ControllerChangeEvent;
	import red.game.witcher3.interfaces.IDragTarget;
	import red.game.witcher3.interfaces.IBaseSlot;
	import red.game.witcher3.managers.InputFeedbackManager;
	import red.game.witcher3.managers.InputManager;
	import red.game.witcher3.modules.CollapsableTabbedListModule;
	import red.game.witcher3.modules.TabbedScrollingListModule;
	import red.game.witcher3.slots.SlotBase;
	import red.game.witcher3.slots.SlotDragAvatar;
	import red.game.witcher3.slots.SlotInventoryGrid;
	import red.game.witcher3.slots.SlotSkillGrid;
	import red.game.witcher3.slots.SlotSkillMutagen;
	import red.game.witcher3.slots.SlotSkillSocket;
	import red.game.witcher3.slots.SlotsListGrid;
	import red.game.witcher3.slots.SlotsTransferManager;
	import red.game.witcher3.utils.CommonUtils;
	import red.game.witcher3.utils.scrollbar.ScrollBar;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.Button;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.ui.InputDetails;
	import scaleform.clik.constants.InputValue;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.FocusManager;
	import scaleform.clik.managers.FocusHandler;
	import flash.display.Shape;
	import red.core.events.GestureEventEx;
	import flash.events.Event;
	
	public class CharacterSkillsGridModule extends UIComponent
	{
		public static const EVENT_SELECTED_SKILL_TAPPED : String = "EVENT_SELECTED_SKILL_TAPPED";
		//CLIPS
		public var m_00topleftAnchor : MovieClip;

		public var m_spawnedSkills : Vector.<SlotSkillGrid>;
		public var m_dependencyLines : Vector.<DisplayObject>;

		//Gap between skill slot sockets
		public var m_gapX : int = 46;
		public var m_gapY : int = 8;

		public var m_scaleX : Number = 1;
		public var m_scaleY : Number = 1;

		private var selectedRendererIdx : int = -1;

		private var data : DataProvider;

		private static const REF_SOCKET_WIDTH : Number = 64;
		private static const REF_SOCKET_HEIGHT : Number = 64;
		private static const REF_SOCKET_WIDTH_SELECTIONLESS : Number = 64;
		private static const REF_SOCKET_HEIGHT_SELECTIONLESS : Number = 64;

		public static const TabIndex_Sword 		: int = 0;
		public static const TabIndex_Signs 		: int = 1;
		public static const TabIndex_Alchemy 	: int = 2;
		public static const TabIndex_Perks 		: int = 3;
		public static const TabIndex_Mutagens 	: int = 4;

		protected static const MAGNITUDE_DEAD_ZONE:Number = .75;
		protected static const MAGNITUDE_DEC_DEAD_ZONE:Number = .1;
		protected static const MAGNITUDE_TIME_DELTA:Number = .5;
		protected static const MAGNITUDE_CHARGE = 15;

		private static const SKILL_OBJECT : String = "SlotSkillGridRef"

		private static const GRID_X_DIVIDE : Number = 3;
		private static const GRID_Y_DIVIDE : Number = 3;

		private var m_lineContainer : MovieClip;
		private var m_lastSelectedSkill : SlotSkillGrid;
		private var m_lastSelectedSkillName : String = "";

		private var prevMagnitude:Number = 0;

		private var posOverrideArray : Array;
		private var lineOverrideArray : Array;

		private var curTabIndex : int;

		public function CharacterSkillsGridModule()
		{
			m_spawnedSkills = new Vector.<SlotSkillGrid>();
			m_dependencyLines = new Vector.<DisplayObject>();
			focusable = true;
		}
		
		protected override function configUI():void
		{
			super.configUI();

			m_lineContainer = new MovieClip();
			addChildAt(m_lineContainer, 0);

			dispatchEvent(new GameEvent(GameEvent.REGISTER, "on.skill.selected", [Hax_OnSkillSelectedUpdate]));
			dispatchEvent(new GameEvent(GameEvent.REGISTER, "skill.tree.line.override", [onGotLineOverrideArray]));
			dispatchEvent(new GameEvent(GameEvent.REGISTER, "skill.tree.pos.override", [onGotPosOverrideArray]));
			createDefaultLineOverrideArray();
			createDefaultPositionOverrideArray();
		}

		protected function createDefaultLineOverrideArray()
		{
			lineOverrideArray = [];
			//Right side
			lineOverrideArray.push({main: "perk_30", dep: "perk_38", logic: "corMidHor"});
			lineOverrideArray.push({main: "perk_38", dep: "perk_30", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_30", dep: "perk_34", logic: "corMidHor"});
			lineOverrideArray.push({main: "perk_34", dep: "perk_30", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_43", dep: "perk_34", logic: "corMidHor"});
			lineOverrideArray.push({main: "perk_34", dep: "perk_43", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_43", dep: "perk_33", logic: "corMidHor"});
			lineOverrideArray.push({main: "perk_33", dep: "perk_43", logic: "midCorHor"});
			
			//Left side
			lineOverrideArray.push({main: "perk_35", dep: "perk_31", logic: "corMidHor"});
			lineOverrideArray.push({main: "perk_31", dep: "perk_35", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_35", dep: "perk_41", logic: "corMidHor"});
			lineOverrideArray.push({main: "perk_41", dep: "perk_35", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_37", dep: "perk_41", logic: "corMidHor"});
			lineOverrideArray.push({main: "perk_41", dep: "perk_37", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_37", dep: "perk_44", logic: "corMidHor"});
			lineOverrideArray.push({main: "perk_44", dep: "perk_37", logic: "midCorHor"});

			//Center
			lineOverrideArray.push({main: "perk_31", dep: "perk_26", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_31", dep: "perk_25", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_41", dep: "perk_25", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_41", dep: "perk_24", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_44", dep: "perk_24", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_44", dep: "perk_27", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_38", dep: "perk_26", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_38", dep: "perk_25", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_34", dep: "perk_25", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_34", dep: "perk_24", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_33", dep: "perk_24", logic: "midCorHor"});
			lineOverrideArray.push({main: "perk_33", dep: "perk_27", logic: "midCorHor"});
		}

		protected function createDefaultPositionOverrideArray()
		{
			posOverrideArray = [];
			posOverrideArray.push({skill: "perk_31", row: 7.5});
			posOverrideArray.push({skill: "perk_38", row: 7.5});

			posOverrideArray.push({skill: "perk_41", row: 12.5});
			posOverrideArray.push({skill: "perk_34", row: 12.5});
					
			posOverrideArray.push({skill: "perk_44", row: 17.5});
			posOverrideArray.push({skill: "perk_33", row: 17.5});
		}

		protected function onGotLineOverrideArray(dataArray:Array)
		{
			lineOverrideArray = dataArray;
		}

		protected function onGotPosOverrideArray(dataArray:Array)
		{
			posOverrideArray = dataArray;
		}

		protected function getLineOverride(mainName:String,depName:String):String
		{
			for(var i : int = 0; i < lineOverrideArray.length; i++)
			{
				var obj : Object = lineOverrideArray[i];
				if(obj.main == mainName && obj.dep == depName)
					return obj.logic;
			}
			return "0";
		}

		protected function Hax_OnSkillSelectedUpdate()
		{
			InputFeedbackManager.updateButtons(this);
		}

		public function clearObjects() : void
		{
			for(var i : int = m_dependencyLines.length - 1; i >= 0; i--)
			{
				m_lineContainer.removeChild(m_dependencyLines[i]);
			}
			for(i = m_spawnedSkills.length - 1; i >= 0; i--)
			{
				m_spawnedSkills[i].onDie();
				removeChild(m_spawnedSkills[i]);
			}
			m_dependencyLines.length = 0;
			m_spawnedSkills.length = 0;
		}

		public function getDependentSkillObject(name:String) : SlotSkillGrid
		{
			for(var i : int = 0; i < m_spawnedSkills.length; i++)
			{
				var l_Data : Object = m_spawnedSkills[i].data;

				if(l_Data.abilityName == name)
					return m_spawnedSkills[i];
			}
			return null;
		}

		public function spawnLineBetweenPoints(aX : Number, aY : Number, bX : Number, bY : Number, color:uint) : void
		{
			var thickness:Number = 1;

			var line : Shape = new Shape();

			m_lineContainer. addChild(line);
			line.graphics.lineStyle(thickness, color);
			line.graphics.moveTo(aX, aY);
			line.graphics.lineTo(bX, bY);

			m_dependencyLines.push(line);
		}

		public function spawnLineBetweenObjects(main : SlotSkillGrid, dep : SlotSkillGrid, logic : String = "0"):void
		{
			var diffX : Number = main.x - dep.x;
			var diffY : Number = main.y - dep.y;

			var aX : Number, aY : Number, bX : Number, bY : Number;
			var pX : Number = 0, pY : Number = 0;
			var depMidX = dep.x + REF_SOCKET_WIDTH_SELECTIONLESS / 2;
			var depMidY = dep.y + REF_SOCKET_HEIGHT_SELECTIONLESS / 2;
			var mainMidX = main.x + REF_SOCKET_WIDTH_SELECTIONLESS / 2;
			var mainMidY = main.y + REF_SOCKET_HEIGHT_SELECTIONLESS / 2;

			aX = mainMidX; aY = mainMidY; bX = depMidX; bY = depMidY;

			if(logic == "0")
			{
				if (diffX != 0)
				{
					bX = depMidX + REF_SOCKET_WIDTH_SELECTIONLESS / 2 * diffX / Math.abs(diffX);
					aX = mainMidX - REF_SOCKET_WIDTH_SELECTIONLESS / 2 * diffX / Math.abs(diffX);
				}
				if (diffY != 0)
				{
					bY = depMidY + REF_SOCKET_HEIGHT_SELECTIONLESS / 2 * diffY / Math.abs(diffY);
					aY = mainMidY - REF_SOCKET_HEIGHT_SELECTIONLESS / 2 * diffY / Math.abs(diffY);
				}
			}
			else if (logic == "corMidHor") // main corner -> dependency middle horizontally
			{
				if (diffX != 0)
				{
					bX = depMidX + REF_SOCKET_WIDTH_SELECTIONLESS / 2 * diffX / Math.abs(diffX);
					aX = mainMidX - REF_SOCKET_WIDTH_SELECTIONLESS / 2 * diffX / Math.abs(diffX);
				}
				if (diffY != 0)
				{
					aY = mainMidY - REF_SOCKET_HEIGHT_SELECTIONLESS / 2 * diffY / Math.abs(diffY);
				}
			}
			if(logic == "midCorHor")  // main middle -> dependency corner horizontally
			{
				if (diffX != 0)
				{
					bX = depMidX + REF_SOCKET_WIDTH_SELECTIONLESS / 2 * diffX / Math.abs(diffX);
					aX = mainMidX - REF_SOCKET_WIDTH_SELECTIONLESS / 2 * diffX / Math.abs(diffX);
				}
				if (diffY != 0)
				{
					bY = depMidY + REF_SOCKET_HEIGHT_SELECTIONLESS / 2 * diffY / Math.abs(diffY);
				}
			}

			var depAvailable : Boolean = true;

			if(dep.data.hasOwnProperty("isUsingSkillDependency") && dep.data.isUsingSkillDependency)
				depAvailable = dep.data.level > 0;

			var color:uint = depAvailable ? 0xFFFFFFFF : 0xFF333333;

			if(main.data.level > 0 && dep.data.level > 0)
			{
				switch(main.data.color)
				{
					case "SC_Red": color = 0xFFC60000; break;
					case "SC_Green": color = 0xFF4A9000; break;
					case "SC_Blue": color = 0xFF0049C6; break;
					case "SC_Yellow": color = 0xFFB27100; break;
				}
			}

			var dX : Number = bX - aX;
			var dY : Number = bY - aY;
			var len : Number = Math.sqrt(dX * dX + dY * dY);
			pX = -dY / len;
			pY = dX / len;

			var d : Number = 3; // distance between lines
			var oX : Number = pX * d / 2;
			var oY : Number = pY * d / 2;

			spawnLineBetweenPoints(aX - oX, aY - oY, bX - oX, bY - oY, color);
			spawnLineBetweenPoints(aX + oX, aY + oY, bX + oX, bY + oY, color);
		}

		public function spawnDependenciesLines(data:Object):void
		{
			if(!data.hasOwnProperty(("abilityName")))
				return;

			var main : SlotSkillGrid = getDependentSkillObject(data.abilityName);

			if(!main)
				return;

			for(var j : int = 0; j < data.skillDependencyRequirements.length; j++)
			{
				var sdr : Object = data.skillDependencyRequirements[j];

				if(sdr.hasOwnProperty(("name")))
				{
					var dep : SlotSkillGrid = getDependentSkillObject(sdr.name);

					var logic : String = getLineOverride(data.abilityName, dep.data.abilityName);
					if(dep)
					{
						spawnLineBetweenObjects(main, dep, logic);
					}
				}
			}
		}

		public function spawnDependenciesLinesForEach(dataArray:Array):void
		{
			for(var i : int = 0; i < dataArray.length; i++)
			{
				spawnDependenciesLines(dataArray[i]);
			}
		}

		public function isDataForTheSameItems(dataArray:Array):Boolean
		{
			if(dataArray.length != m_spawnedSkills.length)
				return false;
			
			for(var i : int = 0; i < dataArray.length; i++)
			{
				var socket : SlotSkillGrid = m_spawnedSkills[i];

				if(socket.data.iconPath != dataArray[i].iconPath)
					return false;
			}

			return true;
		}

		public function updateDataArray(dataArray:Array):void
		{
			for(var i : int = 0; i < dataArray.length; i++)
			{
				var socket : SlotSkillGrid = m_spawnedSkills[i];
				var data : Object = dataArray[i];

				socket.data = data;
				socket.validateNow();
				socket.updateIconAlpha();
			}

			//deleting only dependency lines
			for(i = m_dependencyLines.length - 1; i >= 0; i--)
			{
				m_lineContainer.removeChild(m_dependencyLines[i]);
			}
			m_dependencyLines.length = 0;
			
			//to respawn them
			spawnDependenciesLinesForEach(dataArray);

			data = dataArray;
		}

		public function replacePositionsInDataArray(dataArray:Array):Array
		{
			for(var i : int = 0; i < dataArray.length; i++)
			{
				for(var j : int = 0; j < posOverrideArray.length; j++)
				{
					var obj : Object = posOverrideArray[j];

					if(dataArray[i].abilityName == obj.skill)
					{
						if(obj.hasOwnProperty("row"))
							dataArray[i].gridRow = obj.row;
						if(obj.hasOwnProperty("column"))
							dataArray[i].gridColumn = obj.column;
					}
				}
			}

			return dataArray;
		}

		public function setCurrentTabIndex(index:int):void
		{
			curTabIndex = index;
		}

		public function setDataArray(dataArray:Array):void
		{
			if(isDataForTheSameItems(dataArray))
			{
				updateDataArray(dataArray);
				return;
			}
			clearObjects();
			dataArray = replacePositionsInDataArray(dataArray);

			var socketClass : Class = getDefinitionByName(SKILL_OBJECT) as Class;
			var oldSkillFound : Boolean = false;

			for(var i : int = 0; i < dataArray.length; i++)
			{
				var data : Object = dataArray[i];

				var socket : SlotSkillGrid = new socketClass() as SlotSkillGrid;

				var gridX : Number = 0;
				var gridY : Number = i;

				if(data.hasOwnProperty(("gridRow")))
					gridX = data.gridColumn;
				if(data.hasOwnProperty(("gridColumn")))
					gridY = data.gridRow;

				addChild(socket);

				socket.owner = this;

				socket.x = (REF_SOCKET_WIDTH + m_gapX) * gridX / GRID_X_DIVIDE;
				socket.y = (REF_SOCKET_HEIGHT + m_gapY) * gridY / GRID_Y_DIVIDE;

				socket.data = data;
				socket.addEventListener(MouseEvent.CLICK, onRendererClicked);
				socket.addEventListener(GestureEventEx.GESTURE_TAP, onRendererTapped, false, 0, true );
				m_spawnedSkills.push(socket);

				if(socket.data.abilityName == m_lastSelectedSkillName)
				{
					setSelectedRenderer(socket);
					oldSkillFound = true;
				}
			}

			//selecting default
			//if(m_spawnedSkills.length > 0)
			//	setSelectedRenderer(m_spawnedSkills[0]);
			if(!oldSkillFound)
			{
				m_lastSelectedSkillName = "";
				m_lastSelectedSkill = null;
			}

			spawnDependenciesLinesForEach(dataArray);

			data = dataArray;
		}

		override public function set focused(value:Number):void
		{
			if (value == _focused || !_focusable) { return; }
            _focused = value;

			if(value)
			{
				setSelectedRenderer(getSelectedRenderer() as SlotSkillGrid);
			}

			if (Extensions.isScaleform)
			{
				if (_focused > 0)
				{
					FocusManager.setFocus(this, 0);
					FocusHandler.getInstance().setFocus( this );
					if ( getSelectedRenderer() && enabled)
					{
						// TODO: Use context manager for this
						(getSelectedRenderer() as SlotBase).showTooltip();
					}
				}
			}
			else
			{
				if (stage != null && _focused > 0)
				{
                    stage.focus = this;
                }
			}
		}

		private function setSelectedRenderer(socket : SlotSkillGrid):void
		{
			trace( "CharacterSkillsGridModule::setSelectedRenderer : ", socket, socket.data, socket.data.hasOwnProperty("id") );

			if(socket && socket.data)
			{
				if(socket.data.hasOwnProperty("id")) 
				{
					var curRenderer : SlotSkillGrid = getSelectedRenderer();
					if(curRenderer)
					{
						curRenderer.selected = false;
					}
					selectedRendererIdx = socket.data.id;
					socket.selected = true;

					m_lastSelectedSkill = socket;
					m_lastSelectedSkillName = socket.data.abilityName;

					trace( "CharacterSkillsGridModule::setSelectedRenderer - DISPATCH " );
					dispatchEvent( new GameEvent( GameEvent.CALL, "OnSetSelectedRenderer", [socket.data.id]));
					dispatchEvent( new ListEvent( ListEvent.INDEX_CHANGE, true, false,  socket.data.id, -1, -1, socket, this.data ) );
				}
			}
		}

		public function getSelectedRenderer() : SlotSkillGrid
		{
			for(var i : int = 0; i < m_spawnedSkills.length; i++)
			{
				var socket : SlotSkillGrid = m_spawnedSkills[i];

				if(socket && socket.data 
				&& socket.data.hasOwnProperty("id")
				&& socket.data.id == selectedRendererIdx)
				{
					return socket;
				}
			}
			return null;
		}

		private function onRendererTapped(event:Event):void
		{
			var currentTapped : SlotSkillGrid = event.currentTarget as SlotSkillGrid;
			var currentSelected : IBaseSlot = getSelectedRenderer() as IBaseSlot;
			var tapTwiceEvent : Event = null;

			trace( "CharacterSkillsGridModule::onRendererTapped : ", currentTapped, currentSelected );
			if ( currentSelected != null && currentTapped == currentSelected )
			{
				tapTwiceEvent = new Event( EVENT_SELECTED_SKILL_TAPPED );
				dispatchEvent( tapTwiceEvent );
				trace( "CharacterSkillsGridModule::onRendererTapped ---------- TWICE: " );
			}

			if( currentTapped )
			{
				setSelectedRenderer( currentTapped );
				dispatchItemClickEvent( currentTapped );
				focused = 1;
			}
		}

		private function onRendererClicked(event:Event):void
		{
			var socket : SlotSkillGrid = event.currentTarget as SlotSkillGrid;

			if(socket)
			{
				setSelectedRenderer(socket);
				dispatchItemClickEvent(socket);
				focused = 1;

			}
		}

		public function dispatchItemClickEvent(targetRenderer:IBaseSlot):void
		{
			if (focused < 1) focused = 1;
			
			var clickEvent:ListEvent = new ListEvent(ListEvent.ITEM_CLICK, true);
			clickEvent.itemData = targetRenderer.data as Object;
			clickEvent.index = targetRenderer.index;
			clickEvent.itemRenderer = targetRenderer;
			
			dispatchEvent(clickEvent);
		}


				
		override public function set enabled(value:Boolean):void
		{
			// disable renderers and hide tooltips first
			var len:int = m_spawnedSkills.length;
			for (var i:int = 0; i < len; i++ )
			{
				m_spawnedSkills[i].enabled = value;
			}
			
			super.enabled = value;
			//applySelectionContext();
		}

		public var allowSimpleNavDPad:Boolean = true;

		private function canGoUp(current:SlotSkillGrid)
		{
			if(!current)
				return true;
			for(var i : int = 0; i < m_spawnedSkills.length; i++)
			{
				if(m_spawnedSkills[i].data.gridRow < current.data.gridRow)
					return true;
			}
			return false;
		}

		private function canGoDown(current:SlotSkillGrid)
		{
			if(!current)
				return true;
			for(var i : int = 0; i < m_spawnedSkills.length; i++)
			{
				if(m_spawnedSkills[i].data.gridRow > current.data.gridRow)
					return true;
			}
			return false;
		}

		private function canGoLeft(current:SlotSkillGrid)
		{
			if(!current)
				return true;
			for(var i : int = 0; i < m_spawnedSkills.length; i++)
			{
				if(m_spawnedSkills[i].data.gridColumn < current.data.gridColumn)
					return true;
			}
			return false;
		}

		private function canGoRight(current:SlotSkillGrid)
		{
			if(!current)
				return true;
			for(var i : int = 0; i < m_spawnedSkills.length; i++)
			{
				if(m_spawnedSkills[i].data.gridColumn > current.data.gridColumn)
					return true;
			}
			return false;
		}

		private function angleDelta(a:Number, b:Number):Number
		{
			var d : Number = Math.abs(a - b);
			if(d > Math.PI)
				d = 2*Math.PI - d;
			return d;
		}

		private function getGeneralAngle(_from:SlotSkillGrid, _to:SlotSkillGrid):Number
		{
			var ea:Object = _from.data;
			var eb:Object = _to.data;

			var ax:Number = ea.gridColumn;
			var ay:Number = ea.gridRow;

			var bx:Number = eb.gridColumn;
			var by:Number = eb.gridRow;

			var dx:Number = bx - ax;
			var dy:Number = by - ay;

			if(dx > 0 && Math.abs(dy) < 0.001) return 0;
			if(dx > 0 && dy > 0) return Math.PI / 4;
			if(Math.abs(dx) < 0.001 && dy > 0) return Math.PI / 2;
			if(dx < 0 && dy > 0) return 3 * Math.PI / 4;
			if(dx < 0 && Math.abs(dy) < 0.001) return Math.PI;
			if(dx < 0 && dy < 0) return -3 * Math.PI / 4;
			if(Math.abs(dx) < 0.001 && dy < 0) return -Math.PI / 2;
			if(dx > 0 && dy < 0) return -Math.PI / 4;

			return 0;
		}

		protected function getRendererByAbilityName(abilityName : String) : SlotSkillGrid
		{
			for(var i : int = 0; i < m_spawnedSkills.length; i++)
			{
				if(m_spawnedSkills[i].data.abilityName == abilityName)
					return m_spawnedSkills[i];
			}
			return null;
		} 

		protected function doSurvivalTabOverrideNavigation(event:InputEvent) : Boolean
		{
			var current:SlotSkillGrid = getSelectedRenderer();
			var target : SlotSkillGrid;

			if(current.data.abilityName == "perk_23")
			{
				if(event.details.navEquivalent == NavigationCode.LEFT)
				{
					target = getRendererByAbilityName("perk_40");

					if(target)
					{
						setSelectedRenderer(target);
						event.handled = true;
						return true;
					}
				}
				else if(event.details.navEquivalent == NavigationCode.RIGHT)
				{
					target = getRendererByAbilityName("perk_42");

					if(target)
					{
						setSelectedRenderer(target);
						event.handled = true;
						return true;
					}
				}
			}
			if(current.data.abilityName == "perk_28")
			{
				if(event.details.navEquivalent == NavigationCode.LEFT)
				{
					target = getRendererByAbilityName("perk_39");

					if(target)
					{
						setSelectedRenderer(target);
						event.handled = true;
						return true;
					}
				}
				else if(event.details.navEquivalent == NavigationCode.RIGHT)
				{
					target = getRendererByAbilityName("perk_32");

					if(target)
					{
						setSelectedRenderer(target);
						event.handled = true;
						return true;
					}
				}
			}
			return false;
		}

		public function navigateBasedOnDirection(direction : Number, event:InputEvent)
		{
			var maxDistance : Number = 3;

			var currentRow : Number = -1;
			var currentColumn : Number = -1;

			var current:SlotSkillGrid = getSelectedRenderer();

			if(current)
			{
				currentRow = current.data.gridRow / GRID_Y_DIVIDE;
				currentColumn = current.data.gridColumn / GRID_X_DIVIDE;

				/*if(m_lastSelectedSkill)
				{
					currentRow += (m_lastSelectedSkill.data.gridRow - currentRow) / 50;
					currentColumn += (m_lastSelectedSkill.data.gridColumn - currentColumn) / 50;
				}*/
			}
			else if (m_spawnedSkills.length > 0)
			{
				current = m_spawnedSkills[0];
			}

			var indexes : Vector.<int> = new Vector.<int>;
			for(var i : int = 0; i < m_spawnedSkills.length; i++)
			{
				if(current == m_spawnedSkills[i])
					continue;

				var obj:Object = m_spawnedSkills[i].data;

				var x:Number = obj.gridColumn / GRID_X_DIVIDE - currentColumn;
				var y:Number = obj.gridRow / GRID_Y_DIVIDE - currentRow;

				if(curTabIndex == TabIndex_Perks && x*x > 1)
					continue;

				var distSquared:Number = x*x + y*y;

				if(distSquared > maxDistance * maxDistance )
					continue;

				var angle:Number = Math.atan2(y,x);
				var delta:Number = angleDelta(angle, direction);

				if(delta >= Math.PI/3) //within 60 degrees
					continue;

				indexes.push(i);
			}

			if(indexes.length > 0)
			{
				if(indexes.length > 1)
					indexes.sort(function(a:int, b:int):Number
					{
						var ea:SlotSkillGrid = m_spawnedSkills[a];
						var eb:SlotSkillGrid = m_spawnedSkills[b];

						var ax:Number = ea.data.gridColumn / GRID_X_DIVIDE - currentColumn;
						var ay:Number = ea.data.gridRow / GRID_Y_DIVIDE - currentRow;

						var bx:Number = eb.data.gridColumn / GRID_X_DIVIDE - currentColumn;
						var by:Number = eb.data.gridRow / GRID_Y_DIVIDE - currentRow;

						var distA:Number = ax*ax + ay*ay;
						var distB:Number = bx*bx + by*by;

						var angleA:Number = getGeneralAngle(current, ea);
						var angleB:Number = getGeneralAngle(current, eb);

						var deltaA:Number = angleDelta(angleA, direction);
						var deltaB:Number = angleDelta(angleB, direction);

						if(deltaA == deltaB)
							return distA - distB;

						return deltaA - deltaB;
					});

				var bestIndex:int = indexes[0];
				setSelectedRenderer( m_spawnedSkills[bestIndex] );
				event.handled = true;
			}
		}

		var lastJoystickTime : Number = 0;
		static const JOYSTICK_WAIT_TIME_MS : Number = 300;

		private function canDoJoystickAction():Boolean
		{
			var now:Number = new Date().time;
			return now - lastJoystickTime > JOYSTICK_WAIT_TIME_MS;
		}

		private function updateJoystickTimer():void
		{
			var now:Number = new Date().time;
			lastJoystickTime = now;
		}

		public function handleInputNavSimple(event:InputEvent):void
		{
			if (event.handled)
			{
				return;
			}
			
			var details:InputDetails = event.details;
			CommonUtils.fixupKeyCode( details );
			
			// #J don't use this information but keep it in mind for the next time we get a static navigation code to skew the haduken in its favor
			/*if (details.code == KeyCode.PAD_LEFT_STICK_AXIS)
			{
				_lastLeftAxisX = details.value.xvalue;
				_lastLeftAxisY = details.value.yvalue;
				return;
			}*/
			
			var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
			
			// #J start wierd hack to avoid dpad
			// {
			
			CommonUtils.convertWASDCodeToNavEquivalent(details);
			var navCommand:String = (details.fromJoystick || allowSimpleNavDPad) ? details.navEquivalent : NavigationCode.INVALID;
			if (!allowSimpleNavDPad)
			{
				switch (details.code)
				{
					case KeyCode.W:
					case KeyCode.UP:
						navCommand = NavigationCode.UP;
						break;
					case KeyCode.S:
					case KeyCode.DOWN:
						navCommand = NavigationCode.DOWN;
						break;
					case KeyCode.A:
					case KeyCode.LEFT:
						navCommand = NavigationCode.LEFT;
						break;
					case KeyCode.D:
					case KeyCode.RIGHT:
						navCommand = NavigationCode.RIGHT;
						break;
				}
			}

			var current:SlotSkillGrid = getSelectedRenderer();

			var direction : Number = 0;

			if (details.code == KeyCode.PAD_LEFT_STICK_AXIS )
			{
				var axisData : InputAxisData = InputAxisData(details.value);
				var magnitude : Number = InputUtils.getMagnitude( axisData.xvalue, axisData.yvalue );

				prevMagnitude = magnitude;
				
				if (magnitude < MAGNITUDE_DEAD_ZONE)
				{
					return;
				}

				if ( prevMagnitude > magnitude && Math.abs(prevMagnitude - magnitude) > 0.0005 )
				{
					return;
				}
				if(canDoJoystickAction())
				{
					direction = Math.atan2(-axisData.yvalue,axisData.xvalue);
					navigateBasedOnDirection(direction, event);
					if(event.handled)
						updateJoystickTimer();
				}
			}
			else if(keyPress && details.fromJoystick == false && (
				(navCommand ==  NavigationCode.UP && canGoUp(current)) ||
				(navCommand ==  NavigationCode.DOWN && canGoDown(current)) ||
				(navCommand ==  NavigationCode.LEFT && canGoLeft(current)) ||
				(navCommand ==  NavigationCode.RIGHT && canGoRight(current))
			))
			{
				switch(navCommand)
				{
					case NavigationCode.RIGHT: direction = 0; break;
					case NavigationCode.DOWN: direction = Math.PI / 2; break;
					case NavigationCode.LEFT: direction = Math.PI; break;
					case NavigationCode.UP: direction = -Math.PI / 2; break;
				}
				if(curTabIndex == TabIndex_Perks)
				{
					doSurvivalTabOverrideNavigation(event);
				}
				if(!event.handled)
					navigateBasedOnDirection(direction, event);
			}
			else if (keyPress && details.fromJoystick == false &&
			(navCommand ==  NavigationCode.LEFT && !canGoLeft(current)))
			{
				event.handled = true; //no accidental skip to the tab controller
			}

					
			if((keyPress || details.code == KeyCode.PAD_LEFT_STICK_AXIS) && !event.handled && 
			(navCommand == NavigationCode.UP || navCommand == NavigationCode.RIGHT || details.code == KeyCode.PAD_LEFT_STICK_AXIS))
			{
				if(current && ((details.code == KeyCode.PAD_LEFT_STICK_AXIS && details.fromJoystick && canDoJoystickAction()) || !details.fromJoystick))
				{
					m_lastSelectedSkill = current as SlotSkillGrid;
					m_lastSelectedSkillName = (current as SlotSkillGrid).data.abilityName;
					current.selected = false;
					selectedRendererIdx = -1;
					updateJoystickTimer();
				}
				else
				{
					if(current)
						event.handled = true;
				}
			}

			
			if (!event.handled)
			{
				if (!getSelectedRenderer())
				{
					return;
				}

				/*if (filterKeyCodeFunction != null && filterNavCodeFunction != null)
				{
					if ( !filterKeyCodeFunction(event.details.code) || !filterNavCodeFunction(event.details.navEquivalent) )
					{
						return;
					}
				}*/
				
				var curRenderer:SlotBase = getSelectedRenderer() as SlotBase;
				if (curRenderer && !curRenderer.isEmpty())
				{
					curRenderer.executeAction(details.code, event);
				}
			}
		}

		public function setActiveSelectionEnabled(allowed : Boolean):void
		{
			for (var i : int = 0; i < m_spawnedSkills.length; ++i)
			{
				var currentSlotItem : SlotBase = m_spawnedSkills[i] as SlotBase;
				
				if (currentSlotItem)
				{
					currentSlotItem.activeSelectionEnabled = allowed;
				}
			}
			if(allowed) {
				selectDefault();
				updateJoystickTimer();
			}
		}

		public function onGetActive():void
		{
			selectDefault();
		}

		private function selectDefault():void
		{
			if(m_lastSelectedSkill)
				setSelectedRenderer(m_lastSelectedSkill);
			else
			{
				var closestIndex : int = -1;
				var closestDiff : int = 0;
				for(var i : int = 0; i < m_spawnedSkills.length; i++)
				{
					var x =	m_spawnedSkills[i].data.gridColumn;
					var y = m_spawnedSkills[i].data.gridRow * 2; //*2 so horizontality is closer
					var diff = x*x + y*y;
					if(closestIndex == -1 || diff < closestDiff)
					{
						closestIndex = i;
						closestDiff = diff;
					}
				}
				if(closestIndex != -1)
					setSelectedRenderer(m_spawnedSkills[closestIndex]);
			}
		}
		
	}
}
