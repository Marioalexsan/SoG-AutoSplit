# Documentation

This is a very basic documentation document to record key ideas for the autosplit script.

The data in here might be inaccurate.

## TOC

* [General Information](#general-information)
* [1.0a](#10a)
  * [1.0a Offsets](#10a-offsets)

## General Information

Secrets of Grindea uses .NET Framework 4.0 and XNA. This means that .NET specific techniques need to be used to retrieve information in memory.

Cheat Engine can be used to retrieve offsets to fields in classes. There is also a hacky utility built into the [ModBagman mod tool](https://github.com/Marioalexsan/ModBagman) that logs offsets at runtime.

The script uses a signature scan within `SoG.Program.Main(string[] args)` to grab a pointer to the `Game1` instance. Currently, the only known method to craft this signature scan is by inspecting the method using CheatEngine.

Currently, there is little information on how reliable these methods are, since the .NET runtime can potentially relocate objects when doing garbage collection. Additionally, race conditions and inconsistent data might be possible, given that we inspect the memory of another application.

## Updating AutoSplitter Flags

Resources needed: 
-	[ILSpy](https://github.com/icsharpcode/ILSpy/releases), a decompilation tool for .NET: 
-	[Visual Studio Code](https://code.visualstudio.com/), a versatile text editor

To browse through decompiled game code:
- Open ILSpy
- Go to File -> Open, select Secrets of Grindea.exe and click "Open"
  - For Steam: `C:\Program Files (x86)\Steam\steamapps\common\SecretsOfGrindea\`
- Select Secrets of Grindea.exe in the assembly list
- Go to File -> Save Code, and save the project to a new folder
- Open the folder with Visual Studio Code
- Search for the `FlagCodex.cs` file using the Search bar, and browse through the game's flags
- Search flags through all files by using Ctrl + Shift + F and entering a search term, such as `_MainStory_FirstCutscene`

Opening `FlagCodex.cs` will open the full list of all the flags triggered during the game. Find the ones you want, and note the integer associated to them. This can be straightforward, but you may have to be creative (e.g. the flag associated to beating Marino 1 is `_MainStory_PostFlyingTemple_MarinoDefeated`, and the integer associated to it is 103. However, as there is no Zhamla defeated tag, you have to settle for `_MainStory_EndGame_TrueEndingSeen`). 

For completeness, here is a table with the main types of potentially useful flags:

| Type      | Description                                         |
| --------- | --------------------------------------------------- |
| MainStory | Triggered during the main story line                |
| SideQuest | Triggered during side quests                        |
| Chest     | Triggered when opening a chest                      |
| Puzzle    | Triggered after solving a puzzle                    |
| Map       | Triggered when solving a treasure map               |
| Event     | Triggered by a specific in-game event               |
| ReadBook  | Triggered after reading a book for the first time   |
| Roguelike | Arcade related tags                                 |
## 1.0a

### 1.0a Offsets

`Game1` in the code blocks represents the `Game1` instance pointer.

`(0xABCD) => field` represents an offset and pointer dereference to obtain the given value, starting from the previous value.

#### inArcadeRun

```
Game1
  (0x170) => xGameSessionData 
  (0x2C) => xRogueLikeSessionData
  (0x129) => bInRun 
```

#### arcadeFloor

```
Game1
  (0x170) => xGameSessionData 
  (0x2C) => xRogueLikeSessionData
  (0xB4) => bInRun 
```

#### gameMode

```
Game1
  (0x160) => xStateMaster
  (0x24) => enGameMode
```

#### gameState

```
Game1
  (0x160) => xStateMaster
  (0x14) => enGameMode
```

#### zoningState

```
Game1
  (0x154) => xLevelMaster
  (0x14) => xZoningHelper
  (0x20) => iZoningStateProgress
```

#### inCutscene

```
Game1
  (0x164) => xCutsceneMaster
  (0x18) => bInCutscene
```

#### currentCutscene

```
Game1
  (0x164) => xCutsceneMaster
  (0x10) => xActiveCutscene
  (0x40) => enID
```

#### flagCount

```
Game1
  (0x170) => xGameSessionData
  (0xC) => henActiveFlags
  (0x14) => m_count
```

#### questList

```
Game1
  (0x11C) => xLocalPlayer
  (0x38) => xJournalInfo
  (0x4) => xQuestLog
  (0x4) => lxCompletedQuests
```

#### questDoneList

```
Game1
  (0x11C) => xLocalPlayer
  (0x38) => xJournalInfo
  (0x4) => xQuestLog
  (0x8) => lxCompletedQuests
```

#### HashSet\<FlagCodex.FlagID\>.m_count

*This is a .NET 4.0 implementation detail*

```
HashSet<FlagCodex.FlagID>
  (0x14) => m_count
```

#### HashSet\<FlagCodex.FlagID\>.m_slots

*This is a .NET 4.0 implementation detail*

```
HashSet<FlagCodex.FlagID>
  (0x8) => m_slots
```

#### List\<Quest\>._size

*This is a .NET 4.0 implementation detail*

```
List<Quest>
  (0xC) => _size
```

#### List\<Quest\>._items

*This is a .NET 4.0 implementation detail*

```
List<Quest>
  (0x4) => _items
```

#### Quest.enQuestID

```
Quest
  (0x24) => enQuestID
```

#### Quest.lxObjectives

```
Quest
  (0x18) => lxObjectives
```

#### QuestObjective.bFinished

```
QuestObjective
  (0x1C as bool) => bFinished
```

#### Array\<T\>.item\[index\]

*This is a .NET 4.0 implementation detail*

*Array size (int) should be at 0x4*

```
Array<T>
  (0x8 + 0x8 + index * (0x8 + sizeof(T)) as T) => item
```