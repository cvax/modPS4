# modPS4
Witcher 3 mod for showing PS4 game icons when using a DS3/DS4 controller on PC.  
[Nexusmods Page](http://www.nexusmods.com/witcher3/mods/1657?)

![Alt Text](https://staticdelivery.nexusmods.com/mods/952/images/1657-1-1465691575.png)

# Packing / Building the Mod
You will first need the Mod Kit to completely build this mod. If you wish to modify this mod's bundles, you will also need the Mod Editor. See [Instructions.txt](../master/Instructions.txt) for more info.

[Witcher 3 Mod Kit](http://www.nexusmods.com/witcher3/news/12625/?)  
[Sarcen's Mod Editor](https://drive.google.com/file/d/0B3axqSlhNHOOYmpkWk83TXRkZmM/view?usp=sharing)

There are build scripts provided in this repo. You will need to customize the paths inside BuildVariables.cmd to match your own computer's file structure before using them.

Variable | Description
--- | ---
GAMEPATH | path to your Witcher 3 install
WITCHERBASEDIR | path to where you uncooked the Witcher 3 files thru the Mod Kit
MODKITPATH | path to your Mod Kit install

Use the build script relevant to your current task.

Build | Description
--- | ---
[Full Build.bat](https://github.com/cvax/modPS4/blob/master/Full%20Build.bat) | Packages the bundles and scripts. Auto installs to Witcher 3
[Script Build.bat](https://github.com/cvax/modPS4/blob/master/Script%20Build.bat) | Only copies the scripts

# Changelog
v2.20
- Added: Witcher 3 v1.31 support

v2.10
- Added: Witcher 3 v1.22 support
- Added: Many, many, many CDPR controller/gamepad switching bugs fixed

v2.00
- Completely trashed the old approach of trying to modify redswf files. That approach had significant limitations.
- Improved: PS4 icons supported everywhere!
- Added: PS4 controller shown in "Controller Scheme" options menu!

v1.00
- Updated: Forked from TheLastWitcher's modPS4Icons v1.2.1 release
- Added: PS4 icons on Meditation screen
- Added: PS4 icons on "Quit to Main Menu" popup screen
- Added: PS4 icons on "Exit" popup screen
- Added: PS4 icons on Character stats screen
- Added: PS4 icons on inventory sorting popup screen
- Added: PS4 icons on Gwent screens
