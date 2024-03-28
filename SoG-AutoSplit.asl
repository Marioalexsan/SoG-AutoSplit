/* 
 * Secrets of Grindea AutoSplitter
 *	written by Marioalexsan
 *  with contributions from 3ps1l0n
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
  var scriptVersion = "1.0.1";
  print("SoG-AutoSplit.asl version: " + scriptVersion);

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
    {"flag829", MakePair("Cataclysm Zhamla (optional)", "Defeat the cataclysm in the tower, and watch the true ending.")},
    {"flag15007", MakePair("Living Rune Block (optional)", "Defeat Living Rune Block in one of Seasonne's caves.")},
    {"quest10011_obj0", MakePair("Bossling (optional)", "Defeat Bossling as part of the quest \"Goblin Grinch\".")},
    {"quest10034_obj1", MakePair("Shruboss (optional)", "Defeat Shruboss and complete the quest \"Bloomy Barn Brawl\".")},
    {"quest10035_obj4", MakePair("Remedi (optional)", "Defeat Remedi as part of the quest \"The Remedy\".")},
    {"quest10032_obj0", MakePair("Furious Giga Slime (optional)", "Defeat FGS as part of the quest \"One Measly Slime\".")},
    {"quest10033_obj1", MakePair("Elder Boars (optional)", "Defeat the Elder Boars as part of the quest \"Sponsored Contest\".")}
  };
  
  vars.versionedScenes = new Dictionary<string, Dictionary<int, int[]>> {
    {"1.01a", new Dictionary<int, int[]> {
      {1, new int[] {10082, 10084, 10086, 10088, 10090}}, 
      {2, new int[] {10200}}
    }}
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
  var moduleSize = modules.First().ModuleMemorySize;
  version = "Unknown";

  if (moduleSize == 14778368)
    version = "1.01a";

  print("Module size: " + moduleSize + " | Detected version: " + version);
  
  /*** Find the Game1 instance ***/

  IntPtr functionPtr = IntPtr.Zero;
  
  SigScanTarget scanTarget = null;

  if (version == "1.01a")
  {
    scanTarget = new SigScanTarget(2,
      "8D 15 ?? ?? ?? ??", // lea edx, [Game1 instance]
      "E8 ?? ?? ?? ??",    // call (somewhere, dunno)
      "89 7D CC"           // mov [ebp-34], edi
    );
  }
  else
  {
    // Use a fallback
    print("This version has no proper Game1 scanner available.");
    scanTarget = new SigScanTarget(2,
      "8D 15 ?? ?? ?? ??", // lea edx, [Game1 instance]
      "E8 ?? ?? ?? ??",    // call (somewhere, dunno)
      "89 7D CC"           // mov [ebp-34], edi
    );
  }
  
  foreach (var page in game.MemoryPages())
  {
    var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
    functionPtr = scanner.Scan(scanTarget);
    
    if (functionPtr != IntPtr.Zero)
      break;
  }
  
  if (functionPtr == IntPtr.Zero)
    throw new Exception("Signature scan failed! Can't read memory as a result...");
  
  vars.gamePtr = (IntPtr)memory.ReadValue<int>(functionPtr);

  print("Found Game1 instance at 0x" + vars.gamePtr.ToString("X"));
  
  // ================ //
  // === Watchers === //
  // ================ //
  
  switch (version) {
    case "1.01a":
    default:
      vars.inArcadeRun     = new MemoryWatcher<bool>(new DeepPointer(vars.gamePtr, 0x170, 0x2C, 0x129));
      vars.arcadeFloor     = new MemoryWatcher<int >(new DeepPointer(vars.gamePtr, 0x170, 0x2C, 0xB4));
      vars.gameMode        = new MemoryWatcher<byte>(new DeepPointer(vars.gamePtr, 0x160, 0x24));
      vars.gameState       = new MemoryWatcher<int >(new DeepPointer(vars.gamePtr, 0x160, 0x14));
      vars.zoningState     = new MemoryWatcher<int >(new DeepPointer(vars.gamePtr, 0x154, 0x14, 0x20));
      vars.inCutscene      = new MemoryWatcher<bool>(new DeepPointer(vars.gamePtr, 0x164, 0x18));
      vars.currentCutscene = new MemoryWatcher<int >(new DeepPointer(vars.gamePtr, 0x164, 0x10, 0x40));
      vars.flagCount       = new MemoryWatcher<int >(new DeepPointer(vars.gamePtr, 0x170, 0xC, 0x14));
      vars.flagSet         = new MemoryWatcher<int >(new DeepPointer(vars.gamePtr, 0x170, 0xC));
      vars.questList       = new MemoryWatcher<int >(new DeepPointer(vars.gamePtr, 0x11C, 0x38, 0x4, 0x4));
      vars.doneQuestList   = new MemoryWatcher<int >(new DeepPointer(vars.gamePtr, 0x11C, 0x34, 0x4, 0x8));

      vars.objectListSize   = (Func<int, int>)((int listAddr) => new DeepPointer((IntPtr)listAddr + 0xC).Deref<int>(game));
      vars.objectListItemAt = (Func<int, int, int>)((int listAddr, int index) => new DeepPointer((IntPtr)listAddr + 0x4, 0x8 + index * 0x4).Deref<int>(game));

      vars.flagHashSetSize   = (Func<int, int>)((int setAddr) => new DeepPointer((IntPtr)setAddr + 0x14).Deref<int>(game));
      vars.flagHashSetItemAt = (Func<int, int, ushort>)((int setAddr, int index) => new DeepPointer((IntPtr)setAddr + 0x8, 0x8 + 0x8 + index * 0xC).Deref<ushort>(game));

      vars.questGetID = (Func<int, ushort>)((int questAddr) => new DeepPointer((IntPtr)questAddr + 0x24).Deref<ushort>(game));
      vars.questGetObjectives = (Func<int, int>)((int questAddr) => new DeepPointer((IntPtr)questAddr + 0x18).Deref<int>(game));

      vars.questObjectiveGetFinished = (Func<int, bool>)((int questObjective) => new DeepPointer((IntPtr)questObjective + 0x1C).Deref<bool>(game));
    break;
  }

  vars.watcherUpdater = new MemoryWatcherList() {
    vars.inArcadeRun, vars.arcadeFloor, vars.gameMode, vars.gameState, vars.zoningState,
    vars.inCutscene, vars.currentCutscene, vars.flagCount, vars.flagSet, vars.questList, vars.doneQuestList
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
  if (vars.gameMode.Current == 0) {
    
    // Story flagX splits
    // Read the most recent flag if flag count increased. Split if the flag is tracked.
    // TODO Improve this algorithm to reduce flag loss?
    
    if (vars.flagCount.Old != 0 && vars.flagCount.Old < vars.flagCount.Current) {
      ushort flagAtIndex = vars.flagHashSetItemAt(vars.flagSet.Current, vars.flagCount.Current - 1);
      print("Got new flag " + flagAtIndex);
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
    
    int questCount = vars.objectListSize(vars.questList.Current);

    for (int index = 0; index < questCount; index++) {
      int questAddr = vars.objectListItemAt(vars.questList.Current, index);
      ushort ID = vars.questGetID(questAddr);
      
      if (objTracked.ContainsKey(ID)) {
        int objectiveList = vars.questGetObjectives(questAddr);
        int objectiveCount = vars.objectListSize(objectiveList);
        
        if (objTracked[ID] < objectiveCount) {
          int objectiveAddr = vars.objectListItemAt(objectiveList, index);
          bool finished = vars.questObjectiveGetFinished(objectiveAddr);
          
          if (finished) {
            vars.completedObjectives.Add("quest" + ID + "_obj" + objTracked[ID]);
            print("Quest split via objective, ID=" + ID + ", Obj=" + objTracked[ID]);
            return true;
          }
        }
      }
    }
    
    // Search through completed quests
    
    int doneQuestCount = vars.objectListSize(vars.doneQuestList.Current);
    
    for (int index = 0; index < doneQuestCount; index++) {
      int questAddr = vars.objectListItemAt(vars.doneQuestList, index);
      ushort ID = vars.questGetID(questAddr);
      
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
