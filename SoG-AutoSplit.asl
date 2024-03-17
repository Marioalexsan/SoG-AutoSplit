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

startup
{
	Func<string, string, KeyValuePair<string, string>> MakePair = (a, b) => new KeyValuePair<string, string>(a, b);
	
	/// === Script Data === ///
	
	// flagX splits on a story flag trigger. Algorithm used scans for the latest flag added.
	// questXobjY splits when completing the quest X's objective Y
	
	var storyBossSplits = new Dictionary<string, KeyValuePair<string, string>> {
		{"flag10", MakePair("Black Ferrets I", "Defeat the Black Ferrets in Pillar Mountains.")},
		{"flag18", MakePair("Giga Slime", "Defeat the Giga Slime during The Collector's Exam.")},
		{"flag27", MakePair("Phaseman", "Defeat Phaseman in Flying Fortress and pick up his ability.")},
		{"flag36", MakePair("The Sentry", "Defeat The Sentry in Flying Fortress.")},
		{"flag38", MakePair("GUN-D4M", "Defeat GUN-D4M in Flying Fortress.")},
		{"flag103", MakePair("Marino I", "Defeat Marino in front of his Mansion.")},
		{"flag117", MakePair("Toy Factory", "Defeat the Toy Factory in Seasonne.")},
		{"flag151", MakePair("Summer & Autumn", "Defeat Summer & Autumn in Temple of Seasons.")},
		{"flag153", MakePair("Season Hydras", "Defeat Season Hydras in Temple of Seasons.")},
		{"flag167", MakePair("Winter", "Defeat Winter in Temple of Seasons.")},
		{"flag174", MakePair("Festival Start", "Begin the Festival.")},
		{"flag171", MakePair("Festival Over", "Complete the Festival.")},
		{"flag250", MakePair("Red Spinsect Sequence", "Complete the Red Spinsect Sequence in Mount Bloom.")},
		{"flag251", MakePair("Power Flower", "Defeat Power Flower in Mount Bloom.")},
		{"flag350", MakePair("Cursed Priestess", "Defeat Cursed Priestess in Tai Ming.")},
		{"flag389", MakePair("Giant Thorn-Worm", "Defeat the Giant Thorn-Worms in Tai Ming, and obtain the Emblem of Valor.")},
		{"flag432", MakePair("Zhamla", "Defeat Zhamla in Tai Ming.")},
		{"flag434", MakePair("Mimic", "Defeat Mimic in Tai Ming, and get the Crown.")},
		{"flag510", MakePair("Marino II", "Defeat Marino in Dragonbone Dunes.")},
		{"flag526", MakePair("Sol-Gem", "Defeat Sol-Gem in Dragonbone Dunes.")},
		{"flag658", MakePair("Captain Bones", "Defeat Captain Bones in Lost Ship.")},
		{"flag682", MakePair("Evil Eye", "Defeat Evil Eye in Lost Ship.")},
		{"flag699", MakePair("Luke", "Defeat Luke in Lost Ship.")},
		{"flag823", MakePair("Puzzle floor reached", "Reach the puzzle floor in the Tower.")},
		{"flag824", MakePair("Puzzle floor beaten", "Beat the puzzle floor in the Tower.")},
		{"flag825", MakePair("Top of the tower reached ", "Reach the top floor in the Tower.")},
		{"flag834", MakePair("Dad", "Defeat Dad in the Tower.")},
		{"flag804", MakePair("Bishop (optional)", "Defeat Bishop in the void realm.")},
		{"flag15007", MakePair("Living Rune Block (optional)", "Defeat Living Rune Block in one of Seasonne's caves.")},
		{"quest10011_obj0", MakePair("Bossling (optional)", "Defeat Bossling as part of the quest \"Goblin Grinch\".")},
		{"quest10034_obj1", MakePair("Shruboss (optional)", "Defeat Shruboss and complete the quest \"Bloomy Barn Brawl\".")},
		{"quest10035_obj4", MakePair("Remedi (optional)", "Defeat Remedi as part of the quest \"The Remedy\".")},
		{"quest10032_obj0", MakePair("Furious Giga Slime (optional)", "Defeat FGS as part of the quest \"One Measly Slime\".")},
		{"quest10033_obj1", MakePair("Elder Boars (optional)", "Defeat the Elder Boars as part of the quest \"Sponsored Contest\".")}
	};
	
	vars.versionedScenes = new Dictionary<string, Dictionary<int, int[]>> {
		{"0.890b", new Dictionary<int, int[]> {
			{1, new int[] {10082, 10084, 10086, 10088, 10090}}, 
			{2, new int[] {10199}}
		}},
		{"0.920a", new Dictionary<int, int[]> {
			{1, new int[] {10082, 10084, 10086, 10088, 10090}},
			{2, new int[] {10200}}
		}},
	};
	
	var cutsceneExclusions = new Dictionary<int, KeyValuePair<string, string>> {
		{1, MakePair("Exclude Festival Games", "Festival games will not stop time during their \"active\" part.")},
		{2, MakePair("Exclude Shield Training", "Dad's shielding section in \"Startington?\" will not stop time.")}
	};
	
	/// === Settings === ///
	
	settings.Add("removeLoad", true, "Remove Load Time");
	settings.SetToolTip("removeLoad", "The Timer will freeze during Content Load.");
	
	settings.Add("cutsceneIsLoad", true, "Consider Cutscenes as Loading", "removeLoad");
	settings.SetToolTip("cutsceneIsLoad", "The Timer will not progress during Cutscenes\nThis includes Boss Fight intros, Challenge intros, Floor Results in Arcade, etc.");
	
	foreach (var what in cutsceneExclusions) {
		settings.Add("cs" + what.Key, true, what.Value.Key, "cutsceneIsLoad");
		settings.SetToolTip("cs" + what.Key, what.Value.Value);
	}
	
	settings.Add("storyResets", false, "Autoreset Story Runs upon Quit");
	settings.SetToolTip("storyResets", "Run will reset if you exit to Main Menu.\nDo not use this if you rely on Save Reloads in your run.");
	
	settings.Add("arcadeResets", false, "Autoreset Arcade Runs upon Run End");
	settings.SetToolTip("arcadeResets", "Run will reset if you go back to Arcadia (\"Floor 0\").");
	
	settings.Add("story", true, "Story Boss Splits");
	settings.SetToolTip("story", "Uncheck to disable all boss splitting.");
	
	vars.splits = new Dictionary<string, HashSet<string>> {
		{"flags", new HashSet<string>()},
		{"objectives", new HashSet<string>()}
	};
	
	foreach (var split in storyBossSplits) {
		settings.Add(split.Key, !split.Value.Key.EndsWith("(optional)"), split.Value.Key, "story");
		settings.SetToolTip(split.Key, split.Value.Value);
		
		if (split.Key.StartsWith("flag")) {
			vars.splits["flags"].Add(split.Key);
		}
		else if (split.Key.StartsWith("quest")) {
			vars.splits["objectives"].Add(split.Key);
		}
	}
	
	/// === Runtime Stuff === ///
	
	vars.completedFlags = new HashSet<ushort>();
	vars.completedObjectives = new HashSet<string>();
	vars.excludedCutscenes = new HashSet<int>();
	vars.runInit = false;
	vars.theGame = null;
	
	vars.timerStart = (EventHandler) ((s, e) => {
        vars.completedFlags.Clear();
		vars.completedObjectives.Clear();
		vars.excludedCutscenes.Clear();
		vars.runInit = false;
	});
	
	timer.OnStart += vars.timerStart;
}

shutdown
{
	timer.OnStart -= vars.timerStart;
}

init
{
	// === Version Setup, and SoG.Game1 detection ===//
	
	switch (modules.First().ModuleMemorySize) {
		case 0xB62000: version = "0.890b"; break;
		case 0xC3E000: version = "0.920a"; break;
		default: 	   version = "Unknown"; break;
	}
	print("Module size: " + modules.First().ModuleMemorySize + " My version: " + version);
	
	IntPtr functionPtr = IntPtr.Zero;
	
	foreach (var page in game.MemoryPages()) {
		var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize); 
		functionPtr = scanner.Scan(new SigScanTarget(2,
			"8D 15 ?? ?? ?? ??", 	// lea edx, [Game1 instance]
			"E8 ?? ?? ?? ??", 		// call (somewhere, dunno)
			"89 7D D4" 				// mov [ebp-2C], edi
		));
		
		if(functionPtr != IntPtr.Zero) break;
	}
	
	if (functionPtr == IntPtr.Zero)
		throw new Exception("Signature scan failed! Can't read memory as a result...");
	
	vars.gamePtr = memory.ReadValue<int>(functionPtr);
	
	// === Watchers === //
	
	switch (version) {
		case "0.890b":
			vars.inArcadeRun	 = new MemoryWatcher<bool>(new DeepPointer((IntPtr)vars.gamePtr, 0x164, 0x2C, 0x118));
			vars.arcadeFloor	 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x164, 0x2C, 0xB4));
			vars.gameMode		 = new MemoryWatcher<byte>(new DeepPointer((IntPtr)vars.gamePtr, 0x154, 0x20));
			vars.gameState		 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x154, 0x14));
			vars.zoningState	 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x148, 0x14, 0x20));
			vars.inCutscene		 = new MemoryWatcher<bool>(new DeepPointer((IntPtr)vars.gamePtr, 0x158, 0x18));
			vars.currentCutscene = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x158, 0x10, 0x40));
			vars.flagCount		 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x164, 0xC, 0x18));
			vars.questList		 = null;
			vars.doneQuestList 	 = null;
			
			vars.gameSessionOffset 	 	= 0x164;
			vars.objectiveListOffset 	= -1337420; // Offset of lxObjectives in Quest
			vars.objectiveFinishOffset 	= -1337420; // Offset of bFinished in QuestObjective
		break;
		case "0.920a":
		default:
			// Game Session Data: 0x168, State Master: 0x158, Cutscene Control: 0x15C, Local Player: 0x114
			vars.inArcadeRun	 = new MemoryWatcher<bool>(new DeepPointer((IntPtr)vars.gamePtr, 0x168, 0x2C, 0x118));
			vars.arcadeFloor	 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x168, 0x2C, 0xB4));
			vars.gameMode		 = new MemoryWatcher<byte>(new DeepPointer((IntPtr)vars.gamePtr, 0x158, 0x20));
			vars.gameState		 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x158, 0x14));
			vars.zoningState	 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x14C, 0x14, 0x20));
			vars.inCutscene		 = new MemoryWatcher<bool>(new DeepPointer((IntPtr)vars.gamePtr, 0x15C, 0x18));
			vars.currentCutscene = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x15C, 0x10, 0x40));
			vars.flagCount		 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x168, 0xC, 0x18));
			vars.questList		 = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x114, 0x34, 0x4, 0x4));
			vars.doneQuestList   = new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.gamePtr, 0x114, 0x34, 0x4, 0x8));
			
			vars.gameSessionOffset  	= 0x168;
			vars.objectiveListOffset 	= 0x18;
			vars.objectiveFinishOffset 	= 0x1C;
		break;
	}
	
	vars.watcherUpdater = new MemoryWatcherList() {
		vars.inArcadeRun, vars.arcadeFloor, vars.gameMode, vars.gameState, vars.zoningState,
		vars.inCutscene, vars.currentCutscene, vars.flagCount, vars.questList, vars.doneQuestList
	};
	
	timer.CurrentTimingMethod = TimingMethod.GameTime;
}

update
{
	vars.watcherUpdater.UpdateAll(game);
	
	// Putting this here solves some ASL shenanigans with init / start / startup
	if (!vars.runInit) {
		vars.runInit = true;
		
		foreach (var sceneGroup in vars.versionedScenes[version])
		{
			if(settings["cs" + sceneGroup.Key.ToString()]) {
				foreach (var scene in sceneGroup.Value)
					vars.excludedCutscenes.Add(scene);
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
	// To get list size:
	// new DeepPointer((IntPtr)listAddr, 0xC).Deref<int>(game)
	
	// To get a reference from a list:
	// new DeepPointer((IntPtr)listAddr, 0x4, 0x8 + index * 0x4).Deref<int>(game)
	
	if (vars.gameMode.Current == 0) {
		
		// Story flagX splits
		// Read the most recent flag if flag count increased. Split if the flag is tracked.
		// TODO Improve this algorithm to reduce flag loss?
		
		if (vars.flagCount.Old != 0 && vars.flagCount.Old < vars.flagCount.Current) {
			ushort flagAtIndex = new DeepPointer((IntPtr)vars.gamePtr, vars.gameSessionOffset, 0xC, 0x8, 0x4 + vars.flagCount.Current * 0xC).Deref<ushort>(game);
			if (settings["flag" + flagAtIndex.ToString()] && !vars.completedFlags.Contains(flagAtIndex)) {
				vars.completedFlags.Add(flagAtIndex);
				print("Split on flag " + flagAtIndex);
				return true;
			}
		}
		
		// Story questX_objY splits
		// Read through active quest list and retrieve any tracked ones. For each, check if the marked objective is finished.
		
		var objTracked = new Dictionary<ushort, int>();
		foreach (var split in vars.splits["objectives"]) {
			if (!settings[split]) continue;
			
			ushort ID = UInt16.Parse(split.Substring(5, split.IndexOf("_") - 5));
			int obj = Int32.Parse(split.Substring(split.IndexOf("_") + 4));
			if (!vars.completedObjectives.Contains(split) && (!objTracked.ContainsKey(ID) || objTracked[ID] > obj)) {
				objTracked[ID] = obj;
			}
		}
		
		// Search through active quests
		
		int questList = vars.questList.Current;
		int questCount = new DeepPointer((IntPtr)questList + 0xC).Deref<int>(game);
		
		for (int index = 0; index < questCount; index++) {
			int questAddr = new DeepPointer((IntPtr)questList + 0x4, 0x8 + index * 0x4).Deref<int>(game);
			ushort ID = new DeepPointer((IntPtr)questAddr + 0x24).Deref<ushort>(game);
			
			if (objTracked.ContainsKey(ID)) {
				int objectiveList = new DeepPointer((IntPtr)questAddr + 0x18).Deref<int>(game);
				int objectiveCount = new DeepPointer((IntPtr)objectiveList + 0xC).Deref<int>(game);
				
				if (objTracked[ID] < objectiveCount) {
					int objectiveAddr = new DeepPointer((IntPtr)objectiveList + 0x4, 0x8 + index * 0x4).Deref<int>(game);
					bool finished = new DeepPointer((IntPtr)objectiveAddr + 0x1C).Deref<bool>(game);
					
					if (finished) {
						vars.completedObjectives.Add("quest" + ID + "_obj" + objTracked[ID]);
						print("Quest split via objective, ID=" + ID + ", Obj=" + objTracked[ID]);
						return true;
					}
				}
			}
		}
		
		// Search through completed quests
		
		int doneQuestList = vars.doneQuestList.Current;
		int doneQuestCount = new DeepPointer((IntPtr)doneQuestList + 0xC).Deref<int>(game);
		
		for (int index = 0; index < doneQuestCount; index++) {
			int questAddr = new DeepPointer((IntPtr)doneQuestList + 0x4, 0x8 + index * 0x4).Deref<int>(game);
			ushort ID = new DeepPointer((IntPtr)questAddr + 0x24).Deref<ushort>(game);
			
			if (objTracked.ContainsKey(ID)) {
				vars.completedObjectives.Add("quest" + ID + "_obj" + objTracked[ID]);
				print("Quest split via completion, ID=" + ID + ", Obj=" + objTracked[ID]);
				return true;
			}
		}
		
		return false;
	}

	// Arcade floorX Splits
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
