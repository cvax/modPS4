package red.game.witcher3.menus.overlay
{
	import com.gskinner.motion.easing.Exponential;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import red.core.constants.KeyCode;
	import red.core.events.GameEvent;
	import red.game.witcher3.constants.CommonConstants;
	import red.game.witcher3.controls.InputFeedbackButton;
	import red.game.witcher3.utils.CommonUtils;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.controls.UILoader;
	import scaleform.clik.core.UIComponent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.clik.ui.InputDetails;
	import red.core.CoreComponent;
	import flash.events.IOErrorEvent;
	import flash.events.GestureEvent;
	import red.core.events.GestureEventEx;
	import flash.events.Event;

	/**
	 * Full screen tutorial hint; used in popup_tutorial.fla
	 * @author Getsevich Yaroslav
	 */
	public class TutorialOverlay extends UIComponent
	{
		protected static const OVER_ANIM_OFFSET_X:Number = -50;
		protected static const OVER_ANIM_DURATION:Number = 0.5;
		
		protected static const BLOCK_PADDING:Number = 10;
		protected static const EDGE_PADDING:Number = 10;
		protected static const BUTTONS_TOP_PADDING:Number = 50;
		protected static const BUTTONS_PADDING:Number = 10;
		protected static const GRADIENT_PADDING:Number = 130;
		
		public var txtTitle			:TextField;
		public var txtDescription	:TextField;
		public var btnAccept		:InputFeedbackButton;
		public var btnGlossary		:InputFeedbackButton;
		public var topDelemiter		:Sprite;
		public var mcBackground		:Sprite;
		
		protected var _data:Object;
		protected var _imageLoader:UILoader;
		
		protected var _container:Sprite;

		public function TutorialOverlay()
		{
			_container = new Sprite();
			addChild(_container);
			_container.addChild(txtTitle);
			_container.addChild(topDelemiter);
			_container.addChild(txtDescription);
			_container.addChild(btnAccept);
			_container.addChild(btnGlossary);
						
			btnGlossary.label = "[[panel_title_glossary]]";
			btnGlossary.clickable = false;
			btnGlossary.setDataFromStage(NavigationCode.GAMEPAD_BACK, -1, -1, 1000);
			btnGlossary.addEventListener( GestureEventEx.GESTURE_TAP, handleGlossaryTap, false, 0, true );
			cleanup();
		}

		public function get data():Object { return _data }
		public function set data(value:Object):void
		{
			trace("TutorialOverlay::data");

			var waitImageLoading:Boolean = false;

			cleanup();
			_data = value;

			//TODO remove when journal builded
			if(_data.scriptTag == "PlaystyleDualGrip" && _data.imagePath == "")
			{					
				_data.imagePath = "textures/glossary/tutorials/playstile-alert.png";
			}

			// image
			if (_data.imagePath)
			{
				// #Y not sure that we need it, disabled for now
				waitImageLoading = true;
				loadImage(_data.imagePath);
			}

			// buttons visibility

			if (_data.enableGlossaryLink)
			{
				btnGlossary.visible = true;
				btnGlossary.holdCallback = handleGlossaryLink;
			}
			else
			{
				btnGlossary.visible = false;
				btnGlossary.holdCallback = null;
			}

			if(txtTitle)
			{
				txtTitle.htmlText = CommonUtils.toUpperCaseSafe(_data.messageTitle);
				trace("TutorialOverlay::data - title : ", _data.messageTitle );
			}

			if(txtDescription)
			{
				txtDescription.htmlText =  CommonUtils.fixFontStyleTags(_data.messageText);
				trace("TutorialOverlay::data - text : ", _data.messageText );
			}

			if ( CoreComponent.isArabicAligmentMode )
			{
				txtDescription.htmlText = "<p align=\"right\">" + _data.messageText + "</p>";				
			}

			if (!waitImageLoading)
			{
				alignContent();
			}
		}

		private function alignContent():void
		{
			var safeRect:Rectangle = CommonUtils.getScreenRect();
			var safePadding:Number = safeRect.width * .05;

			var messageCenter:Number;
			var centralLine:Number;
			var backgroundWidth:Number;
			var buttonsWidth:Number;

			// if (_data.scriptTag == 'TutorialDualGripStyleAlert')
			// {				
			// 	btnAccept.visible = false;
			// }

			if(_data.enableAcceptButton)
			{	
				btnAccept.visible = true;
				btnAccept.label = "[[panel_continue]]";
				btnAccept.clickable = false;
				btnAccept.setDataFromStage(NavigationCode.GAMEPAD_A, KeyCode.SPACE);
				btnAccept.addEventListener( GestureEventEx.GESTURE_TAP, handleAcceptTap, false, 0, true );		
			}
			else
			{
				btnAccept.visible = false;
			}

			if (btnAccept.visible && btnGlossary.visible)
			{
				buttonsWidth = btnAccept.getViewWidth() + btnGlossary.getViewWidth() + BUTTONS_PADDING;
			}
			else
			{
				buttonsWidth = btnGlossary.getViewWidth();
			}
			
			messageCenter = Math.max(txtDescription.width / 2, buttonsWidth / 2);
			centralLine = safePadding + EDGE_PADDING + messageCenter;
			backgroundWidth = centralLine + messageCenter + GRADIENT_PADDING;

			mcBackground.width = backgroundWidth;

			txtTitle.width = txtTitle.textWidth + CommonConstants.SAFE_TEXT_PADDING;			

			txtDescription.height = txtDescription.textHeight + CommonConstants.SAFE_TEXT_PADDING;

			topDelemiter.x = centralLine;
			txtTitle.x = centralLine - (txtTitle.width / 2 ) ;
 
			var format:TextFormat = new TextFormat();
			if ( CoreComponent.isArabicAligmentMode )
			{
				txtDescription.x = centralLine - txtDescription.textWidth / 2 - (txtDescription.width - txtDescription.textWidth);

				format.font = "$NormalFont";
			}
			else
			{
				txtDescription.x = centralLine - txtDescription.textWidth / 2;

				format.font = "$BoldFont";
			}

			txtTitle.setTextFormat(format);			

			// buttons alignment

			btnAccept.y =  btnGlossary.y = (txtDescription.y + txtDescription.height + BUTTONS_TOP_PADDING);
			if (btnGlossary.visible)
			{
				btnAccept.x = centralLine - buttonsWidth / 2;
				btnGlossary.x = btnAccept.x + btnAccept.getViewWidth() + BUTTONS_PADDING;
			}
			else
			{
				btnAccept.x = centralLine - btnAccept.getViewWidth() / 2;
			}

			if(_imageLoader)
			{
				_imageLoader.y += txtDescription.height + BLOCK_PADDING + 400;
				_imageLoader.x += 80;
			}

			// container
			_container.y = safeRect.y + (safeRect.height - _container.height) / 2
		}

		private function cleanup():void
		{
			txtTitle.htmlText = "";
			txtDescription.htmlText = "";
			btnGlossary.visible = false;
			if (_imageLoader)
			{
				_imageLoader.unload();
				removeChild(_imageLoader);
			}
		}

		private function loadImage(imagePath:String):void
		{
			if (_imageLoader)
			{
				_imageLoader.unload();
				removeChild(_imageLoader);
			}
			_imageLoader = new UILoader();
			_imageLoader.maintainAspectRatio = true;
			_imageLoader.autoSize = true;
			_imageLoader.source = "img://" + imagePath;
			_imageLoader.x = txtDescription.x;
			_imageLoader.y = txtDescription.y + txtDescription.height
			_imageLoader.addEventListener(Event.COMPLETE, handleImageLoaded, false, 0, true);
			_imageLoader.addEventListener(IOErrorEvent.IO_ERROR, handleImageLoadinfFailed, false, 0, true);
			addChild(_imageLoader);
		}

		private function handleImageLoadinfFailed(event:IOErrorEvent):void
		{
			trace("TutorialDebug handleImageLoadinfFailed");
			removeChild(_imageLoader);
			alignContent();
		}

		private function handleImageLoaded(event:Event):void
		{
			trace("TutorialDebug handleImageLoaded");
			alignContent();
		}

		private function handleGlossaryLink():void
		{
			if (_data && visible && parent.visible)
			{
				dispatchEvent( new GameEvent( GameEvent.CALL, 'OnGotoGlossary' ) );
			}
		}

		protected function handleGlossaryTap(event:GestureEvent) : void
		{
			trace("TutorialOverlay - handleGlossaryTap");
			handleGlossaryLink();
		}
		
		protected function hide()
		{
			var animProps:Object = { ease:Exponential.easeOut, onComplete:handleOverlayHidden } ;
			var animValues:Object = { x: OVER_ANIM_OFFSET_X, alpha: 0 };
			GTweener.removeTweens(this);
			GTweener.to(this, OVER_ANIM_DURATION, animValues, animProps);
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnStartHiding' ) );
		}

		public function proccedInput(event:InputEvent, useDownEvent:Boolean = false):void
		{
			var details    : InputDetails = event.details;
			var isEnable   : Boolean = _data && visible && parent.visible;
			var isKeyUp    : Boolean = details.value == (useDownEvent ? InputValue.KEY_DOWN : InputValue.KEY_UP);
			var isKeyValid : Boolean = details.navEquivalent == NavigationCode.GAMEPAD_A || details.navEquivalent == NavigationCode.GAMEPAD_B;
			
			if (isEnable && isKeyUp && isKeyValid && btnAccept.visible) 
			{
				hide();
			}
		}

		protected function handleAcceptTap(event:GestureEvent) : void
		{
			trace("TutorialOverlay - handleAcceptTap");
			hide();
		}

		protected function handleOverlayHidden(tweenInst:GTween):void
		{
			dispatchEvent( new GameEvent( GameEvent.CALL, 'OnHideTimer' ) );
		}
		
	}
}
