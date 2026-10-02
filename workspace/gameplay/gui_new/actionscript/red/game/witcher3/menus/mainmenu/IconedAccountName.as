package red.game.witcher3.menus.mainmenu
{
    import scaleform.clik.core.UIComponent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import red.game.witcher3.utils.CommonUtils;
    import flash.text.TextLineMetrics;

    public class IconedAccountName extends UIComponent
	{
        public var mcIcon : AccountIcon;
        public var tfName : TextField;

        public function IconedAccountName()
        {
        }

        override protected function configUI() : void
        {
            mcIcon.visible = false;

            tfName.autoSize = TextFieldAutoSize.LEFT;
            tfName.wordWrap = false;
            tfName.visible = false;
        }

        public function setData( icon : uint, name : String ) : void 
        {
            trace( "IconedAccountName::setData : ", icon, name );

            mcIcon.setData( icon );
            mcIcon.visible = true;

            var htmlText : String = CommonUtils.formatUserName( name );

            tfName.htmlText = htmlText;
            tfName.visible = true;

            visible = ( name != "" );

            trace( "IconedAccountName::setData2 : ", htmlText, visible, mcIcon.visible, tfName.visible );

            //layout
            mcIcon.x = 0;
            tfName.x = mcIcon.width + 8;

            var centerY : Number = height / 2.0;
            mcIcon.y = centerY - mcIcon.height / 2.0;
            tfName.y = centerY - tfName.height / 2.0;
        }

        public function measureWidth() : Number
        {
            trace( "IconedAccountName::measureWidth : ", width, width / scaleX, tfName.x + tfName.getLineMetrics(0).width );

            return tfName.x + tfName.getLineMetrics(0).width;
        }
    }
}