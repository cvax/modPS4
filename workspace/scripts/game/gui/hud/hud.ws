class CR4ScriptedHud extends CR4Hud
{
	protected function UpdateInputDeviceType():void
	{
		var deviceType : EInputDeviceType;
		
		if (m_fxSetGamepadType)
		{
			deviceType = theInput.GetLastUsedGamepadType();
			// modPS4++
			/* Unsure if necessary, but added just in case. */
			// if (deviceType == IDT_Unknown || deviceType == IDT_KeyboardMouse)
			if (deviceType == IDT_Unknown)
				deviceType = IDT_PS4;
			// modPS4--
			m_fxSetGamepadType.InvokeSelfOneArg( FlashArgUInt(deviceType) );
		}
	}
}