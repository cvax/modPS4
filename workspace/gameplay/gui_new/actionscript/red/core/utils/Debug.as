
package red.core.utils
{
	public class Debug
	{
		public static function Assert(bAssert:Boolean, msg:String = "Assertion failed!")
		{
			if (!bAssert)
			{
				throw new Error( msg );
			}
		}
    }
}