import class CInputManager
{
	public final function GetLastUsedGamepadType() : EInputDeviceType
	{
		var deviceName:name = GetLastUsedDeviceName();
		
		switch (deviceName)
		{
			case 'xpad':
				// modPS4++
				// return IDT_Xbox1;
				return IDT_PS4;
				// modPS4--
				break;
			case 'ps4pad':
				return IDT_PS4;
				break;
			case 'ps5pad':
				return IDT_PS5;
				break;
			case 'steampad':
				// modPS4++
				// return IDT_Steam;
				return IDT_PS4;
				// modPS4--
				break;
			case 'switch2pad':
				return IDT_Switch2;
				break;
			case 'switch2mouser':
				return IDT_Switch2_Mouser;
				break;
			case 'keyboardmouse':
				return IDT_KeyboardMouse;
				break;
			case 'tablet':
				return IDT_Tablet;
				break;
			default:
				return IDT_Unknown;
				break;
		}
		
		return IDT_Unknown;
	}
}