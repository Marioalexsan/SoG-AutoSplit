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

state("Secrets Of Grindea") {}

// Note: double check the enum values for cutscenes if a new stable update comes
// Note: the current information is for 0.890b

startup
{
	// ---------------------------------- //
	// Split and Game Time related code
	// ---------------------------------- //
	
	vars.completedFlags = new HashSet<ushort>();
	vars.excludedCutscenes = new HashSet<int>();
	vars.hasBuiltCutscenes = false;
	
	vars.timerStart = (EventHandler) ((s, e) => {
        vars.completedFlags.Clear();
		vars.excludedCutscenes.Clear();
		vars.hasBuiltCutscenes = false;
		});
	timer.OnStart += vars.timerStart;

	// ---------------------------------- //
	// Dictionary Setup
	// Splits, Excluded Cutscenes, etc.
	// ---------------------------------- //
	
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
		{389, "Giant Thorn-Worm"},
		{432, "Zhamla"},
		{434, "Mimic"},
		{510, "Marino II"},
		{526, "Sol-Gem"},
		{658, "Captain Bones"},
		{682, "Evil Eye"},
		{699, "Luke"}
	};
	
	var flagTooltips = new Dictionary<int, string> {
		{10, "Splits after defeating the Black Ferrets in Pillar Mountains."},
		{18, "Splits after defeating the Giga Slime during The Collector's Exam."},
		{27, "Splits after defeating Phaseman in Flying Fortress.\nPS: The actual split happens after picking up the Phase Ability."},
		{36, "Splits after defeating The Sentry in Flying Fortress."},
		{38, "Splits after defeating GUN-D4M in Flying Fortress."},
		{103, "Splits after defeating Marino in front of his Mansion."},
		{117, "Splits after completing the Toy Factory in Seasonne."},
		{151, "Splits after defeating Summer & Autumn in Temple of Seasons."},
		{153, "Splits after defeating Season Hydras in Temple of Seasons."},
		{167, "Splits after defeating Winter in Temple of Seasons."},
		{174, "Splits after initiating the Festival."},
		{171, "Splits after completing the Festival."},
		{250, "Splits after completing the Red Spinsect Sequence in Mount Bloom."},
		{251, "Splits after defeating Power Flower in Mount Bloom."},
		{350, "Splits after defeating Cursed Priestess in Tai Ming."},
		{389, "Splits after defeating the Giant Thorn-Worms in Tai Ming.\nPS: The actual split happens after obtaining the Emblem of Valor."},
		{432, "Splits after defeating Zhamla in Tai Ming."},
		{434, "Splits after defeating Mimic in Tai Ming.\nPS: The actual split happens after opening Mimic and getting the Crown."},
		{510, "Splits after defeating Marino in Dragonbone Dunes."},
		{526, "Splits after defeating Sol-Gem in Dragonbone Dunes."},
		{658, "Splits after defeating Captain Bones in Lost Ship."},
		{682, "Splits after defeating Evil Eye in Lost Ship."},
		{699, "Splits after defeating Luke in Lost Ship."}
	};
	
	vars.csGroups = new Dictionary<int, int[]> {
		{1, new int[]{ // Festival - Interactive part of festival game cutscenes
			10082, 10084, 10086, 10088, 10090
		}},
		{2, new int[]{ // Spookington - Shield Training
			10199
		}}
	};
	
	var csDict = new Dictionary<int, string> {
		{1, "Exclude Festival Games"},
		{2, "Exclude Shield Training"}
	};
	
	var csTooltips = new Dictionary<int, string> {
		{1, "Festival Game Cutscenes will not stop time during their interactive part.\nThis includes the Strength, Running and Fishing Games."},
		{2, "The Shield Training Cutscene in Spookington will not stop time."}
	};
	
	// ----------------------------------------------------- //
	// Settings
	// Load Removal, Cutscene Removal, Splits, Resets, etc.
	// ----------------------------------------------------- //

	settings.Add("removeLoad", true, "Remove Load Time");
		settings.SetToolTip("removeLoad", "The Timer will freeze during Content Load.");
	
	settings.Add("cutsceneIsLoad", true, "Consider Cutscenes as Loading", "removeLoad");
		settings.SetToolTip("cutsceneIsLoad", "The Timer will not progress during Cutscenes\nThis includes Boss Fight intros, Challenge intros, Floor Results in Arcade, etc.");
	
	foreach (var cs in csDict)
	{
		settings.Add("cs" + cs.Key, true, cs.Value, "cutsceneIsLoad"); // Adds a cutscene exclusion
			settings.SetToolTip("cs" + cs.Key, csTooltips[cs.Key]);
	}
	
	settings.Add("storyResets", false, "Autoreset Story Runs upon Quit");
		settings.SetToolTip("storyResets", "Run will reset if you exit to Main Menu.\nPS: Don't use if you rely on Save Reloads in your run.");
	
	settings.Add("arcadeResets", false, "Autoreset Arcade Runs upon Run End");
		settings.SetToolTip("arcadeResets", "Run will reset if you go back to Arcadia (\"Floor 0\").");
	
	settings.Add("story", true, "Enable Story Splitting");
		settings.SetToolTip("story", "Enables splitting for Story Mode.");
	
	foreach (var flag in flagDict)
	{
		settings.Add("flag" + flag.Key, true, flag.Value, "story"); // Adds a split
			settings.SetToolTip("flag" + flag.Key, flagTooltips[flag.Key]);
	}
}

shutdown
{
    timer.OnStart -= vars.timerStart;
}

init
{
	// ------------------------------------------ //
	// Version Setup, and SoG.Game1 detection
	// ------------------------------------------ //
	
	switch (modules.First().ModuleMemorySize) {
		case 0xB62000: version = "0.890b"; break;
		default: 	   version = "Unknown"; break;
	}
	
	IntPtr functionPtr = IntPtr.Zero;
	foreach(var page in game.MemoryPages()) 
	{
		var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize); // Sigscans for code in Program.Main
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
	
	// ----------- //
	// Watchers
	// ----------- //
	
	vars.inArcadeRun	 = new MemoryWatcher<bool>(new DeepPointer((IntPtr)vars.gamePtr, 0x164, 0x2C, 0x118));
	vars.arcadeFloor	 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x164, 0x2C, 0xB4));
	vars.gameMode		 = new MemoryWatcher<byte>(new DeepPointer((IntPtr)vars.gamePtr, 0x154, 0x20));
	vars.gameState		 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x154, 0x14));
	vars.zoningState	 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x148, 0x14, 0x20));
	vars.inCutscene		 = new MemoryWatcher<bool>(new DeepPointer((IntPtr)vars.gamePtr, 0x158, 0x18));
	vars.currentCutscene = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x158, 0x10, 0x40)); // Highly version dependent
	vars.flagCount		 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x164, 0xC, 0x18));
	
	vars.watcherUpdater = new MemoryWatcherList() {
		vars.inArcadeRun, vars.arcadeFloor, vars.gameMode, vars.gameState, vars.zoningState,
		vars.inCutscene, vars.currentCutscene, vars.flagCount
	};
	
	timer.CurrentTimingMethod = TimingMethod.GameTime;
}

update
{
	vars.watcherUpdater.UpdateAll(game);
	
	// Initializes excluded cutscenes array
	// Couldn't put this in startup due to settings dependency
	if (!vars.hasBuiltCutscenes)
	{
		vars.hasBuiltCutscenes = true;
		foreach (var csGroup in vars.csGroups)
		{
			if(settings["cs" + csGroup.Key.ToString()])
			{
				foreach (var cs in csGroup.Value)
				{
					vars.excludedCutscenes.Add(cs);
				}
			}
		}
	}
}

start
{
	return
		vars.gameMode.Current == 0 && vars.gameState.Current == 2 ||
		vars.inArcadeRun.Current && vars.arcadeFloor.Current == 1;
}

split
{
	if (vars.gameMode.Current == 0 && vars.flagCount.Old != 0 && vars.flagCount.Old < vars.flagCount.Current) {
		ushort flagAtIndex;
		new DeepPointer((IntPtr)vars.gamePtr, 0x164, 0xC, 0x8, 0x4 + vars.flagCount.Current * 0xC).Deref<ushort>(game, out flagAtIndex);
		if (settings["flag" + flagAtIndex.ToString()] && !vars.completedFlags.Contains(flagAtIndex)) {
			vars.completedFlags.Add(flagAtIndex);
			return true;
		}
		return false;
	}

	return vars.inArcadeRun.Current && vars.arcadeFloor.Changed && vars.arcadeFloor.Current > vars.arcadeFloor.Old;
}

reset
{
	return
		settings["storyResets"] && vars.gameState.Changed && vars.gameState.Current == 1 ||
		settings["arcadeResets"] && vars.inArcadeRun.Changed && !vars.inArcadeRun.Current;
}

isLoading
{
	bool doCutsceneCheck = settings["cutsceneIsLoad"] && vars.inCutscene.Current;
	bool inCutscene = doCutsceneCheck && !vars.excludedCutscenes.Contains(vars.currentCutscene.Current);
	
	return 
		settings["removeLoad"] && (vars.gameState.Current == 1 || vars.zoningState.Current != 0 || inCutscene);
}
