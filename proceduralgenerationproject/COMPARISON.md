# Srovnání algoritmů procedurálního generování dungeonů

Tento dokument srovnává pět metod procedurálního generování dungeonů
implementovaných v projektu ProceduralGenerationProject (Godot 4).

---

## 1. Přehledová tabulka

| Algoritmus | Typ | Časová složitost | Prostorová složitost | Konektivita | Styl dungeonu | Pokrytí podlahou | Výhody | Nevýhody |
|---|---|---|---|---|---|---|---|---|
| Náhodné místnosti | Umísťování | O(n·m) | O(W·H) | Zaručena (chodby) | Čtvercové místnosti + chodby | ~25–40 % | Jednoduchý, předvídatelný, čitelný | Místnosti mohou být příliš rozložené, plýtvá místem |
| BSP (dělení prostoru) | Stromové dělení | O(W·H·d) | O(W·H + 2^d) | Zaručena (L-chodby) | Hierarchické místnosti | ~35–55 % | Vyvážené rozložení, vždy vyplní celou mapu | Místnosti mohou být příliš podobné, stromová struktura je viditelná |
| Bludišťový DFS | Prohledávání do hloubky | O(W·H) | O(W·H) | Dokonalá (právě 1 cesta) | Husté bludiště bez slepých uliček | ~60–75 % | Perfektní bludiště, 100% průchozí | Klaustrof­obické, těžko orientovatelné pro hráče |
| Opilcova procházka | Náhodná procházka | O(W·H) amortizovaně | O(W·H) | Zaručena (cesta chůze) | Organické, klikaté chodby + pokoje | ~30–40 % | Organický vzhled, jednoduché na implementaci | Nerovnoměrné, může mít úzké hrdlo |
| Buněčný automat | Simulace | O(W·H·k) | O(W·H) | Nezaručena | Organické jeskyně | ~45–55 % | Nejpřirozenější vzhled, variabilní výstup | Mohou vzniknout izolované kapsy |

*d = počet úrovní dělení (BSP), k = počet simulačních kroků (Buněčný automat)*

---

## 2. Algoritmy podrobně

### 2.1 Náhodné místnosti (Random Rooms)

**Soubor:** `dungeons/algorithms/rooms_generator.gd`

**Popis:**  
Nejjednodušší a nejintuitivnější metoda. Algoritmus opakovaně zkouší umístit
obdélníkové místnosti na náhodné místo v mapě. Pokud se nová místnost nepřekrývá
s žádnou existující (ani se 1 dlaždice mezerou), je přijata. Každá nová místnost
je poté spojena s předchozí L-shaped chodbou o šířce 2 dlaždice.

**Jak funguje:**
1. Pokus o umístění místnosti (náhodné rozměry 8–16, náhodná poloha).
2. Test překrytí s existujícími místnostmi (s 1dlaž­dicovým okrajem).
3. Pokud OK: vyrytí podlahy, propojení s předchozí místností chodbou.
4. Opakovat až do 10 místností nebo 100 pokusů.
5. Přidání zdí kolem všech podlah.

**Výhody:**
- Velmi jednoduchý kód, snadno pochopitelný.
- Jasná, čitelná struktura dungeonu pro hráče.
- Snadno se rozšiřuje (různé typy místností, speciální místnosti).
- Deterministické propojení zaručuje průchodnost.

**Nevýhody:**
- Místnosti mohou být od sebe vzdálené, chodby pak velmi dlouhé.
- Na malých mapách může selhat umísťování (překrytí).
- Neorganický, "čtvercový" vzhled.

**Doporučená velikost mapy:** 40×40 a více.

---

### 2.2 Binární dělení prostoru (Binary Space Partitioning – BSP)

**Soubor:** `dungeons/algorithms/bsp_generator.gd`

**Popis:**  
Algoritmus rekurzivně dělí celou plochu mapy na stále menší obdélníky
(větve binárního stromu). Listy stromu (nejmenší nedělitelné oblasti)
každý dostanou jednu místnost s náhodným okrajem. Všechna sourozenecká
dvojice větví jsou spojena L-shaped chodbou, čímž je zaručena plná
konektivita.

**Jak funguje:**
1. Kořen stromu = celá mapa (minus 1dlaž. okraj).
2. Každá větev se rozdělí horizontálně nebo vertikálně (podle delší strany)
   na dvě podvětve. Dělicí poměr: 35–65 %.
3. Rekurze pokračuje 3 úrovně → max 8 listů (místností).
4. Každý list dostane místnost s náhodným okrajem 2–3 dlaž.
5. Každý sourozenecký pár je spojen L-chodbou o šířce 2 dlaž.
6. Přidání zdí.

**Výhody:**
- Rovnoměrné pokrytí celé mapy.
- Zaručená konektivita díky stromové hierar­chii.
- Žádné překrytí místností (dělení to za­braňuje).
- Dobře škáluje s velikostí mapy.

**Nevýhody:**
- Místnosti jsou viditelně "symetrické" (stromová struktura je znát).
- Méně organický vzhled než jiné metody.
- Fixní počet místností daný hloubkou stromu.

**Doporučená velikost mapy:** 40×40 a více.

---

### 2.3 Bludišťový DFS – Rekurzivní backtracker (Maze)

**Soubor:** `dungeons/algorithms/maze_generator.gd`

**Popis:**  
Generátor perfektního bludiště pomocí prohledávání do hloubky (DFS).
Mapa je rozdělena na abstraktní "buňky" (každá zabírá oblast 2×2 dlaždic
+ 1 dlaž. mezera pro zeď). DFS začíná od buňky (0,0) a náhodně probourává
stěny mezi nenavštívenými sousedy. Výsledkem je perfektní bludiště:
každá buňka je dosažitelná a existuje právě jedna cesta mezi dvěma body.

**Jak funguje:**
1. Každá buňka má na začátku všechny 4 stěny.
2. DFS si vybere náhodného nenavštíveného souseda, probourá zeď
   a rekurzivně pokračuje.
3. Při slepé uličce se vrací po zásobníku.
4. Buňky se přeloží na dlaždice (2×2 podlaha + chodby v mezerách).
5. Přidání zdí.

**Výhody:**
- 100% konektivita zaručena matematicky.
- Jednoduchá a elegantní implementace.
- Žádné izolované oblasti, žádné smyčky (pokud nejsou záměrně přidány).
- Ideální pro "čisté" bludiště.

**Nevýhody:**
- Výsledek může být klaustrof­obický a matoucí pro hráče.
- Mnoho slepých uliček – obtížná orientace.
- Vizuálně monotónní (rovnoměrné chodby bez větších prostor).

**Doporučená velikost mapy:** 30×30 – 80×80.

---

### 2.4 Opilcova procházka (Drunkard's Walk)

**Soubor:** `dungeons/algorithms/drunken_generator.gd`

**Popis:**  
Algoritmus simuluje opilce, který náhodně prochází mapou a "vyrývá"
podlahu. Začíná ve středu mapy, každý krok se posune o 1 dlaž. v náhodném
kardinálním směru. Každých 15–25 kroků vytvoří malou místnost (3×3),
jinak vyrývá 2×2 chodbu. Pokračuje, dokud 35 % mapy není podlaha.

**Jak funguje:**
1. Výchozí bod: střed mapy, garantovaná 3×3 plocha podlahy.
2. Náhodný pohyb (N/E/S/W) s odrážením od okrajů.
3. Po 15–25 krocích: 3×3 místnost; jinak 2×2 chodba.
4. Konec po dosažení 35% pokrytí.
5. Přidání zdí.

**Výhody:**
- Velmi organický, přirozený vzhled.
- Jednoduchý algoritmus, snadno pochopitelný.
- Všechny části dungeonu jsou přirozeně propojeny (cesta chůze).
- Variabilní hustota – kombinace wider oblastí a úzkých chodeb.

**Nevýhody:**
- Nedeterministický tvar – nelze zaručit rovnoměrné pokrytí.
- Může vzniknout "úzké hrdlo" vedoucí k části dungeonu.
- Velké prázdné oblasti v rozích mapy.

**Doporučená velikost mapy:** 40×40 a více.

---

### 2.5 Buněčný automat – Jeskyně (Cellular Automata)

**Soubor:** `dungeons/algorithms/cellular_generator.gd`

**Popis:**  
Metoda inspirovaná simulací Conwayovy "Hry života". Mapa je nejprve
náhodně naplněna (45 % podlaha). Poté proběhne 5 simulačních kroků.
V každém kroku se každé buňce přepočítá stav podle počtu sousedů­podlah:
≥ 4 sousedé → podlaha, jinak → prázdné.

**Jak funguje:**
1. Náhodné naplnění: 45 % buněk = podlaha.
2. 5× simulační krok: Moore-sousedství (8 buněk).
   Pravidlo: floor_sousedé ≥ 4 → floor, jinak empty.
3. Přidání zdí.

**Výhody:**
- Nejpřirozenější, organický vzhled ze všech metod.
- Velmi rychlý výpočet (O(W·H·k), konstantní k=5).
- Snadná variabilita (jiná pravděpodobnost naplnění → jiné jeskyně).
- Dobrý základ pro "přírodní" prostředí (jeskyně, podzemní řeky).

**Nevýhody:**
- Konektivita NENÍ zaručena – mohou vzniknout izolované kapsy.
- Větší mapy jsou potřeba pro smysluplnou jeskyni.
- Hůře předvídatelný výstup.

**Doporučená velikost mapy:** 60×60 a více.

---

## 3. Měření výkonu

### Metodika

V projektu je čas generování měřen **výhradně** pro samotný algorit­mický výpočet.
Vizuální vykreslování dlaždic a umísťování hráče jsou záměrně vyloučeny,
protože závisí na framerate enginu a nesouvisejí s efektivitou algoritmu.

```
t_start = Time.get_ticks_usec()
map = Algorithm.generate(width, height)
t_end   = Time.get_ticks_usec()
gen_ms  = (t_end - t_start) / 1000.0
```

Čas je zobrazen s přesností na 0,01 ms (`%.2f ms`).

### Očekávané výsledky (orientační, mapa 60×60)

| Algoritmus | Typický čas | Poznámka |
|---|---|---|
| Náhodné místnosti | < 1 ms | Závisí na počtu pokusů |
| BSP | < 1 ms | Lineární s počtem dlaždic |
| Bludiště DFS | 1–3 ms | Závisí na velikosti buněčné mřížky |
| Opilcova procházka | 2–10 ms | Závisí na délce procházky |
| Buněčný automat | 1–3 ms | 5 průchodů celou mapou |

### Vizuální zpoždění

Po změření a zobrazení času proběhne animovaný reveal: řádky dlaždic
se vykreslují s prodlevou 15 ms/řádek. Toto zpoždění **není zahrnuto**
v naměřeném čase a slouží pouze pro vizuální efekt.

---

## 4. Spawn hráče

### Problém kolizního offsetu

Kolizní tvar (`CollisionShape2D`) hráče je v `player.tscn` posunut
o `Vector2(49, 6)` oproti původu `CharacterBody2D`. Přímé nastavení
`player.global_position = tile_world` by umístilo TĚLO hráče na dlaž­dici,
ale KOLIZI cca 3 dlaž. doprava – do stěny.

**Oprava:**
```gdscript
const PLAYER_COLLISION_OFFSET := Vector2(49.0, 6.0)
player.global_position = tilemap.map_to_local(spawn_tile) - PLAYER_COLLISION_OFFSET
```

### Validace spawn pozice

Algoritmus hledá dlaž­dici, jejíž **okolí 3×3 (ofset −1 až +1)** je celé
podlaha. To zaručuje:
- Hráč nestojí na kraji místnosti u stěny.
- Dostatečný prostor pro pohyb po spawnu.
- Funguje pro všechny algoritmy včetně úzkých chodeb bludiště.

---

## 5. Původ kódu a akademická integrita

Tento dokument popisuje principy a srovnání algoritmů. Informace o původu kódu,
inspiracích a případném použití generativní AI je záměrně vedená zvlášť v:

- `CODE_ATTRIBUTION.md`

*Dokument vygenerován pro projekt ProceduralGenerationBP | Godot 4.4 | únor 2026*
