class CR4MenuBase extends CR4Menu
{
	protected function UpdateInputDeviceType():void
	{
		var deviceType : EInputDeviceType;
		
		if (m_fxSetGamepadType)
		{
			deviceType = theInput.GetLastUsedGamepadType();
			// modPS4++
			/* Necessary to ensure the initial splash screen videos have correct gamepad icons.
			Without this, the code change in inputManager.ws is sufficient to cover the whole game. */
			// if (deviceType == IDT_Unknown || deviceType == IDT_KeyboardMouse)
			if (deviceType == IDT_Unknown)
				deviceType = IDT_PS4;
			// modPS4--
			m_fxSetGamepadType.InvokeSelfOneArg( FlashArgUInt(deviceType) );
		}
	} 
}