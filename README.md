# BP - Procedurální generování dungeonů ve 2D hrách

**Autor:** Jesse Sadowý  
**Vedoucí:** doc. RNDr. Jan Konečný, Ph.D.  
**Univerzita:** Katedra informatiky, PřF UP v Olomouci, 2026

## Implementované algoritmy

- **Rooms** — náhodné umístění místností a propojení chodbami
- **BSP** — Binary Space Partitioning (rekurzivní dělení prostoru)
- **Drunken Walk** — náhodná procházka s cílovým pokrytím 35 %
- **Cellular** — buněčné automaty (jeskynní struktury)
- **Maze** — generování bludiště (recursive backtracker / DFS)

## Požadavky

- [Godot Engine 4.6.X](https://godotengine.org/download/)
- Python 3.10+ (volitelné, pouze pro analýzu výsledků)

## Spuštění aplikace

1. Stáhněte nebo naklonujte repozitář:
   ```
   git clone https://github.com/Jim-23/ProceduralGenerationBP.git
   ```
2. Otevřete Godot Engine a zvolte **Import** → vyberte soubor `project.godot` ve složce `proceduralgenerationproject/`.
3. Spusttě projekt.

## Ovládání

- **W A S D** — pohyb hráče
- **Kolečko myši** — přiblížení / oddálení
- **Pravé tlačítko myši** - pohybování po mapě nezávisle na hráči
- **R** - focus zpět na hráče
- **Generate** — vygeneruje mapu na základě zvoleného algoritmu a rozměrů
- **Benchmark** — spustí automatizované měření všech algoritmů na pěti velikostech map (výsledky se uloží do `results.csv`)


## Analýza výsledků

Po spuštění benchmarku lze vygenerovat grafy pomocí skriptu `result_analyser.py`:

```
pip install -r requirements.txt
python result_analyser.py
```

Grafy budou uloženy do složky `plots/`.

## Struktura projektu

```
dungeons/algorithms/   — generovací algoritmy
scripts/               — herní logika (main, player, coin)
scenes/                — Godot scény
assets/                — grafické prostředky
plots/                 - grafy z analyzátoru
result_analyser.py     — Python skript pro analýzu dat
results.csv            — naměřená data z benchmarku
requirements.txt       - Požadované knihovny pro spuštění skriptu result_analyser.py
```
