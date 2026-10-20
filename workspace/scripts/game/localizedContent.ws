function GetPadFileName(type : string) : string
{
	var platformPrefix:string;
	var deviceType : EInputDeviceType = theInput.GetLastUsedGamepadType();
	
	// modPS4++
	// if( deviceType == IDT_PS4 || deviceType == IDT_PS5 )
	if(theInput.UsesPlaystationPadScript() || deviceType == IDT_PS4 || deviceType == IDT_PS5 || deviceType == IDT_Unknown)
	// modPS4--
	{
		
		switch(type)
		{
			case "LS" :					return "ICO_PlayS_L3";
			case "RS" :					return "ICO_PlayS_R3";
			case "LS_Thumb"	:			return "ICO_PlayS_L3_hold";
			case "RS_Thumb"	:			return "ICO_PlayS_R3_hold";
			case "RS_PRESS"	:			return "ICO_PlayS_R3_hold";
			case "LS_Up_Down" : 		return "ICO_PlayS_L3_scroll";			
			case "LS_LeftRight" : 		return "ICO_PlayS_L3_tabs";
			case "RS_UpDown" : 	  		return "ICO_PlayS_R3_scroll";
			case "RS_LeftRight" : 		return "ICO_PlayS_R3_tabs";
			case "RS_Up" : 				return "ICO_PlayS_R3_up";
			case "RS_Down" : 			return "ICO_PlayS_R3_down";
			case "LS_Up" : 				return "ICO_PlayS_L3_up";
			case "Cross_Right" : 		return "ICO_PlayS_dpad_right";
			case "Cross_Left" : 		return "ICO_PlayS_dpad_left";
			case "Cross_Up" : 			return "ICO_PlayS_dpad_up";
			case "Cross_Down" : 		return "ICO_PlayS_dpad_down";
			case "Cross_LeftRight" :  	return "ICO_PlayS_dpad_left_right";
			case "Cross_UpDown" :  		return "ICO_PlayS_dpad_up_down";
			case "Back" : 				return "ICO_PlayS_Share";
			case "Start" : 				return "ICO_PlayS_Touchpad";
			case "RT" : 				return "ICO_PlayS_R2";
			case "LT" : 				return "ICO_PlayS_L2";
			case "LB" : 				return "ICO_PlayS_L1";
			case "RB" : 				return "ICO_PlayS_R1";
			case "A" : 					return "ICO_PlayS_X";
			case "B" : 					return "ICO_PlayS_Circle";
			case "X" : 					return "ICO_PlayS_Square";
			case "Y" : 					return "ICO_PlayS_Triangle";
			case "TouchPad" :			return "ICO_PlayS_Touchpad";
		}
	}
	else if (deviceType == IDT_Switch2 || deviceType == IDT_Switch2_Mouser)
	{
		switch(type)
		{
			case "LS" :					return "ICO_Switch_L3";
			case "RS" :					return "ICO_Switch_R3";
			case "LS_Thumb"	:			return "ICO_Switch_L3_hold";
			case "RS_Thumb"	:			return "ICO_Switch_R3_hold";
			case "RS_PRESS"	:			return "ICO_Switch_R3_hold";
			case "LS_Up_Down" : 		return "ICO_Switch_L3_scroll";			
			case "LS_LeftRight" : 		return "ICO_Switch_L3_tabs";
			case "RS_UpDown" : 	  		return "ICO_Switch_R3_scroll";
			case "RS_LeftRight" : 		return "ICO_Switch_R3_tabs";
			case "RS_Up" : 				return "ICO_Switch_R3_up";
			case "RS_Down" : 			return "ICO_Switch_R3_down";
			case "LS_Up" : 				return "ICO_Switch_L3_up";
			case "Cross_Right" : 		return "ICO_Switch_dpad_right";
			case "Cross_Left" : 		return "ICO_Switch_dpad_left";
			case "Cross_Up" : 			return "ICO_Switch_dpad_up";
			case "Cross_Down" : 		return "ICO_Switch_dpad_down";
			case "Cross_LeftRight" :  	return "ICO_Switch_dpad_left_right";
			case "Cross_UpDown" :  		return "ICO_Switch_dpad_up_down";
			case "Back" : 				return "ICO_Switch_Touchpad";
			case "Start" : 				return "ICO_Switch_Options";
			case "RT" : 				return "ICO_Switch_R2";
			case "LT" : 				return "ICO_Switch_L2";
			case "LB" : 				return "ICO_Switch_L1";
			case "RB" : 				return "ICO_Switch_R1";
			case "A" : 					return "ICO_Switch_X";
			case "B" : 					return "ICO_Switch_Circle";
			case "X" : 					return "ICO_Switch_Square";
			case "Y" : 					return "ICO_Switch_Triangle";
			case "TouchPad" :			return "ICO_Switch_Touchpad";
		}
	}
	else
	{
		if (deviceType == IDT_Steam)
		{
			platformPrefix = "_Steam_";
		}
		else
		{
			platformPrefix = "_Xbox_";
		}
		
		switch(type)
		{
			case "LS" :					return "ICO" + platformPrefix + "L";
			case "RS" :					return "ICO" + platformPrefix + "R";
			case "LS_Thumb"	:			return "ICO" + platformPrefix + "L_hold";
			case "RS_Thumb"	:			return "ICO" + platformPrefix + "R_hold";
			case "RS_PRESS"	:			return "ICO" + platformPrefix + "R_hold";
			case "LS_Up_Down" : 		return "ICO" + platformPrefix + "L_scroll";
			case "LS_LeftRight" : 		return "ICO" + platformPrefix + "L_tabs";
			case "RS_UpDown" : 		    return "ICO" + platformPrefix + "R_scroll";
			case "RS_LeftRight" :		return "ICO" + platformPrefix + "R_tabs";
			case "RS_Up" : 				return "ICO" + platformPrefix + "R_up";
			case "RS_Down" : 			return "ICO" + platformPrefix + "R_down";
			case "LS_Up" : 				return "ICO" + platformPrefix + "L_up";
			case "Cross_Right" : 		return "ICO" + platformPrefix + "dpad_right";
			case "Cross_Left" : 		return "ICO" + platformPrefix + "dpad_left";
			case "Cross_Up" : 			return "ICO" + platformPrefix + "dpad_up";
			case "Cross_Down" : 		return "ICO" + platformPrefix + "dpad_down";
			case "Cross_LeftRight" :  	return "ICO" + platformPrefix + "dpad_left_right";
			case "Cross_UpDown" :  		return "ICO" + platformPrefix + "dpad_up_down";
			case "Back" : 				return "ICO" + platformPrefix + "Back";
			case "Start" : 				return "ICO" + platformPrefix + "Start";
			case "RT" : 				return "ICO" + platformPrefix + "RT";
			case "LT" : 				return "ICO" + platformPrefix + "LT";
			case "LB" : 				return "ICO" + platformPrefix + "LB";
			case "RB" : 				return "ICO" + platformPrefix + "RB";
			case "A" : 					return "ICO" + platformPrefix + "A";
			case "B" : 					return "ICO" + platformPrefix + "B";
			case "X" : 					return "ICO" + platformPrefix + "X";
			case "Y" : 					return "ICO" + platformPrefix + "Y";
		}
	}
	
	return "";
}