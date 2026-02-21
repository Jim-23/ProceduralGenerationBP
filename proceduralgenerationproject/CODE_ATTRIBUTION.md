# Původ kódu, inspirace a použití AI

Tento soubor slouží jako stručný „audit“ původu kódu pro potřeby akademické integrity.
Cíl: aby bylo jasné, co je vlastní implementace, co je pouze inspirace (myšlenka/algoritmus) a co případně pochází z konkrétního zdroje.

## 1) Prohlášení

- Autor projektu: **[DOPLŇ JMÉNO]**
- Datum/kurz: **[DOPLŇ]**
- Prohlášení o kódu:
  - Algoritmy jsou obecně známé (Random Rooms, BSP, DFS maze/backtracker, Drunkard’s Walk, Cellular Automata).
  - Implementace v tomto repozitáři je **vlastní**, průběžně psaná a sjednocená do společného formátu mapy (`Array` řádků s hodnotami `EMPTY/FLOOR/WALL`).
  - Kód nebyl přímo kopírován (copy/paste) z žádného repozitáře; inspirací byly algoritmické popisy (viz tabulka níže).
  - Části týkající se Godot-specifické integrace (TileMapLayer, Camera2D, AnimationPlayer, CharacterBody2D) jsou vlastní implementací s oporou v oficiální dokumentaci Godotu.

## 2) Použití generativní AI

- [x] Použil jsem AI k návrhům úprav a část kódu byla vygenerována nebo navržena.
- [x] Vygenerovaný kód jsem vždy zkontroloval, pochopil a integroval do projektu.
- [x] AI jsem používal k: **debugging kamery a zoomu, návrhu logiky spawnu mincí, opravě pickup animace (Area2D + CollisionShape2D), WASD input, camera limit logice**
- Nástroje: **GitHub Copilot (model: Claude Sonnet 4.6) – použit jako interaktivní asistent v VS Code**

### Konkrétní části, kde AI generovala nebo navrhovala kód:

| Funkce / oblast | Soubor | Co AI navrhla |
|---|---|---|
| `_update_camera_limits()` | `scripts/main.gd` | logika `limit_left/top/right/bottom` na základě `tile_size * map_size` |
| `_place_coins_on_floor()` | `scripts/main.gd` | shuffle + `randi_range` + instantiate loop + `_spawned_coins` cleanup |
| `_on_body_entered()` | `scripts/coin.gd` | `monitoring = false`, `set_deferred("disabled", true)`, guard `CharacterBody2D` |
| zoom setter | `scripts/player.gd` | `reset_smoothing()` + `force_update_scroll()` po změně zoomu |
| WASD input | `scripts/player.gd` | návrh custom input akcí místo `ui_*` |

## 3) Tabulka původu

> Algoritmy jsou obecně známé – níže jsou uvedeny kanonické zdroje popisující jejich logiku,
> nikoli repozitáře, ze kterých by byl kód převzat.

| Soubor | Stav | Inspirace / zdroje (URL) | Poznámky k úpravám |
|---|---|---|---|
| `scripts/main.gd` | vlastní | Godot docs: [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html), [Camera2D](https://docs.godotengine.org/en/stable/classes/class_camera2d.html); Brackeys: [First 2D Game](https://github.com/Brackeys/first-game-in-godot) | Vlastní struktura scény, UI, měření času, animované vykreslení po řádcích, spawn hráče a mincí; camera limits a coin placement navrženy s pomocí AI |
| `scripts/player.gd` | vlastní | Godot docs: [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html); Brackeys: [First 2D Game](https://github.com/Brackeys/first-game-in-godot) | Pohyb `get_vector`, flip sprite; zoom přes setter proměnnou; WASD input akce; oprava zoomu s pomocí AI |
| `scripts/coin.gd` | vlastní | Godot docs: [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html), [AnimationPlayer](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html) | Signál `body_entered`, spuštění pickup animace; guard + disable collision navrženy s pomocí AI |
| `dungeons/algorithms/rooms_generator.gd` | vlastní / inspirováno | RogueBasin: [Dungeon-Building Algorithm](https://www.roguebasin.com/index.php/Dungeon-Building_Algorithm) | Vlastní implementace: náhodné obdélníky s testem překrytí, L-chodba šíře 2, sdílené tile konstanty |
| `dungeons/algorithms/bsp_generator.gd` | vlastní / inspirováno | RogueBasin: [Basic BSP Dungeon generation](https://www.roguebasin.com/index.php/Basic_BSP_Dungeon_generation); TutorialsPlus: [BSP Trees for Game Maps](https://gamedevelopment.tutsplus.com/tutorials/how-to-use-bsp-trees-to-generate-game-maps--gamedev-12268) | Vlastní implementace: rekurzivní třída `Branch`, padding místností, L-chodba mezi středy; 3 úrovně dělení |
| `dungeons/algorithms/maze_generator.gd` | vlastní / inspirováno | Jamis Buck: [Recursive Backtracker](https://weblog.jamisbuck.org/2010/12/27/maze-generation-recursive-backtracker.html) | Vlastní implementace: buňkový grid jako `Dictionary`, DFS zásobník, převod buněk (2×2 floor + 1px gap) na tiles |
| `dungeons/algorithms/drunken_generator.gd` | vlastní / inspirováno | RogueBasin: [Random Walk Cave Generation](https://www.roguebasin.com/index.php/Random_Walk_Cave_Generation) | Vlastní implementace: cílové pokrytí 35 %, střídání 2×2 chodby a 3×3 místností, garantovaný spawn prostor |
| `dungeons/algorithms/cellular_generator.gd` | vlastní / inspirováno | RogueBasin: [Cellular Automata cave generation](https://www.roguebasin.com/index.php/Cellular_Automata_Method_for_Generating_Random_Cave-Like_Levels) | Vlastní implementace: 45% fill, 5 kroků simulace, pravidlo ≥4 floor sousedů → floor |

## 4) Přímo převzatý kód

Žádný blok kódu nebyl celý zkopírován z externího repozitáře. Viz sekce 2 pro části navržené AI.

## 5) Assety (zdroj + licence)

- Zdroj: https://pixel-poem.itch.io/dungeon-assetpuck
- Licence (dle stránky):
  - "This asset pack can be used in free and commercial projects. You can modify it to suit your own needs."


