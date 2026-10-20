class CR4PopupBase extends CR4Popup
{
	protected function UpdateInputDeviceType():void
	{
		var deviceType : EInputDeviceType;
		
		if (m_fxSetGamepadType)
		{
			deviceType = theInput.GetLastUsedGamepadType();
			// modPS4++
			/* Necessary to fix CDPR bug in selecting correct gamepad type */
			// if (deviceType == IDT_Unknown || deviceType == IDT_KeyboardMouse)
			if (deviceType == IDT_Unknown)
				deviceType = IDT_PS4;
			// modPS4--
			m_fxSetGamepadType.InvokeSelfOneArg( FlashArgUInt(deviceType) );
		}
	}
}