/* 
 * Secrets of Grindea AutoSplitter
 *	written by Marioalexsan
 *
 * Part of this code was taken from:
 *	https://raw.githubusercontent.com/Underscore76/SDV-AutoSplit/master/sdv-script.asl
 *	https://raw.githubusercontent.com/PrototypeAlpha/AmnesiaASL/master/AmnesiaTDD.asl
 *	https://raw.githubusercontent.com/jbzdarkid/Autosplitters/master/LiveSplit.FEZ.asl
 *
 * Big thanks to Ero and other folks from the Speedrun Tool Development Discord server
*/

// Code Graveyard

	//vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.GamePtr, 0x164)) { Name = "GameSessionData" });
	//vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.GamePtr, 0x164, 0x02C)) { Name = "RoguelikeSessionData" });
	//vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.GamePtr, 0x148)) { Name = "LevelMaster" });
	//vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.GamePtr, 0x158)) { Name = "CutsceneMaster" });
	//vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.GamePtr, 0x154)) { Name = "StateMaster" });
	//vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.GamePtr, 0x164, 0x00C)) { Name = "ActiveFlagsHashSet" });

// Code Graveyard End

state("Secrets Of Grindea") {}

startup
{
	var flagDict = new Dictionary<int, string> {
		{10, "Black Ferrets I"},
		{18, "Giga Slime"},
		{27, "Phaseman"},
		{36, "The Sentry"},
		{38, "GUN-D4M"},
		{103, "Marino I"},
		{117, "Toy Factory"},
		{151, "Summer & Autumn"},
		{153, "Season Hydras"},
		{167, "Winter"},
		{174, "Festival Start"},
		{171, "Festival Over"},
		{250, "Red Spinsect Sequence"},
		{251, "Power Flower"},
		{350, "Cursed Priestess"},
		{395, "Giant Thorn-Worm"},
		{432, "Zhamla"},
		{434, "Mimic"},
		{510, "Marino II"},
		{526, "Sol-Gem"},
		{658, "Captain Bones"},
		{682, "Evil Eye"},
		{701, "Luke"}
	};
	
	var flagTooltips = new Dictionary<int, string> {
		{10, "Splits after defeating the Black Ferrets in Pillar Mountains"},
		{18, "Splits after defeating the Giga Slime during The Collector's Exam"},
		{27, "Splits after defeating Phaseman in Flying Fortress\nPS: The actual split happens after picking up the Phase Ability"},
		{36, "Splits after defeating The Sentry in Flying Fortress"},
		{38, "Splits after defeating GUN-D4M in Flying Fortress"},
		{103, "Splits after defeating Marino in front of his Mansion"},
		{117, "Splits after completing the Toy Factory in Seasonne"},
		{151, "Splits after defeating Summer & Autumn in Temple of Seasons"},
		{153, "Splits after defeating Season Hydras in Temple of Seasons"},
		{167, "Splits after defeating Winter in Temple of Seasons"},
		{174, "Splits after initiating the Festival"},
		{171, "Splits after completing the Festival"},
		{250, "Splits after completing the Red Spinsect Sequence in Mount Bloom"},
		{251, "Splits after defeating Power Flower in Mount Bloom"},
		{350, "Splits after defeating Cursed Priestess in Tai Ming"},
		{395, "Splits after defeating the Giant Thorn-Worms in Tai Ming"},
		{432, "Splits after defeating Zhamla in Tai Ming"},
		{434, "Splits after defeating Mimic in Tai Ming\nPS: The actual split happens after opening Mimic and getting the Crown"},
		{510, "Splits after defeating Marino in Dragonbone Dunes"},
		{526, "Splits after defeating Sol-Gem in Dragonbone Dunes"},
		{658, "Splits after defeating Captain Bones in Lost Ship"},
		{682, "Splits after defeating Evil Eye in Lost Ship"},
		{701, "Splits after defeating Luke in Lost Ship"}
	};

	// Load Removal
	settings.Add("removeLoad", true, "Remove Load Time");
		settings.SetToolTip("removeLoad", "The Timer will freeze during Content Load.");
	
	settings.Add("cutsceneIsLoad", true, "Consider Cutscenes as Loading", "removeLoad");
		settings.SetToolTip("cutsceneIsLoad", "The Timer will not progress during Cutscenes\nThis includes Boss Fight intros, Challenge intros, Floor Results in Arcade, etc.");
	
	// Automatic Resets
	settings.Add("storyResets", false, "Autoreset Story Runs upon Quit");
		settings.SetToolTip("storyResets", "Run will reset if you exit to Main Menu\nIf Disabled, the Timer will freeze while on the Main Menu\nPS: Don't use if you rely on Save Reloads in your run");
	
	settings.Add("arcadeResets", false, "Autoreset Arcade Runs upon Run End");
		settings.SetToolTip("arcadeResets", "Run will reset if you go back to Arcadia (\"Floor 0\")");
	
	// Story Splitting
	settings.Add("story", true, "Enable Story Splitting");
		settings.SetToolTip("story", "Enables splitting for Story Mode.");
	
	foreach (var flag in flagDict)
	{
		// Adds a split
		settings.Add("flag" + flag.Key, true, flag.Value, "story");
			settings.SetToolTip("flag" + flag.Key, flagTooltips[flag.Key]);
	}
}

shutdown
{
}

init
{
	// Get Version
	switch (modules.First().ModuleMemorySize) {
		case 0xB62000: version = "0.890b"; break;
		default: 	   version = "Unknown"; break;
	}
	print("Game Version is " + version);
	
	// Get Game1 reference
	// Sigscans for code in Program.Main
	
	IntPtr functionPtr = IntPtr.Zero;
	foreach(var page in game.MemoryPages()) 
	{
		var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
		functionPtr = scanner.Scan(new SigScanTarget(2,
			"8D 15 ?? ?? ?? ??", // lea edx, [target]
			"E8 ?? ?? ?? ??", // call to God Knows Where
			"89 7D D4" // mov [ebp -2C], edi
		));
		
		if(functionPtr != IntPtr.Zero)
		{
			break;
		}
	}
	if (functionPtr == IntPtr.Zero)
	{
		throw new Exception("Couldn't find sigscan for SoG.Program.Main!");
	}
	vars.gamePtr = memory.ReadValue<int>(functionPtr);
	
	// Initialize watchers
	vars.inArcadeRun	 = new MemoryWatcher<bool>(new DeepPointer((IntPtr)vars.gamePtr, 0x164, 0x2C, 0x118));
	vars.arcadeFloor	 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x164, 0x2C, 0xB4));
	vars.gameMode		 = new MemoryWatcher<byte>(new DeepPointer((IntPtr)vars.gamePtr, 0x154, 0x20));
	vars.gameState		 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x154, 0x14));
	vars.levelLoaded	 = new MemoryWatcher<bool>(new DeepPointer((IntPtr)vars.gamePtr, 0x148, 0x38));
	vars.inCutscene		 = new MemoryWatcher<bool>(new DeepPointer((IntPtr)vars.gamePtr, 0x158, 0x18));
	vars.flagCount		 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x164, 0xC, 0x18));
	
	vars.watcherUpdater = new MemoryWatcherList() {
		vars.inArcadeRun, vars.arcadeFloor, vars.gameMode, vars.gameState, vars.levelLoaded, vars.inCutscene, vars.flagCount
	};
	
	timer.CurrentTimingMethod = TimingMethod.GameTime;
}

update
{
	vars.watcherUpdater.UpdateAll(game);
}

start
{
	return
		vars.gameMode.Current == 0 && vars.gameState.Current == 2 ||
		vars.inArcadeRun.Current && vars.arcadeFloor.Current == 1;
}

split
{
	if (vars.flagCount.Old < vars.flagCount.Current) {
		ushort flagAtIndex;
		new DeepPointer((IntPtr)vars.gamePtr, 0x164, 0xC, 0x8, 0x4 + vars.flagCount.Current * 0xC).Deref<ushort>(game, out flagAtIndex);
		return settings["flag" + flagAtIndex.ToString()];
	}

	return vars.inArcadeRun.Current && vars.arcadeFloor.Changed;
}

reset
{
	return
		settings["storyResets"] && vars.gameState.Changed && vars.gameState.Current == 1 ||
		settings["arcadeResets"] && vars.inArcadeRun.Changed && !vars.inArcadeRun.Current;
}

isLoading
{
	return settings["removeLoad"] && (!vars.levelLoaded.Current || settings["cutsceneIsLoad"] && vars.inCutscene.Current);
}