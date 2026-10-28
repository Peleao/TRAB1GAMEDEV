# BASE — projeto, arena em grade e jogador

**Objetivo:** projeto Godot rodando com a arena de blocos em grade (TileMapLayer) e o jogador andando em 4 direções, célula a célula, animado.
**Depende de:** nada
**Pode rodar em paralelo com:** nada (cria a base de todas)
**Passa pelo ux-ui:** sim, leve — tamanho de janela, escala e legibilidade da arena (a sessão chama o `ux-ui` antes do pacote 2)

## Contratos (valem para GELO e INIM)

- Grade: `const COLS := 13`, `const ROWS := 15`, `const CELL := 64` (px) em `scripts/grid.gd` (`class_name Grid`, RefCounted, sem cena).
- Viewport base 832 × 1024 (64 px de HUD no topo + 15 × 64); janela 624 × 768; stretch `canvas_items`, aspect `keep`.
- `Grid`:
  - `enum Cell { EMPTY, WALL, ICE }` — WALL é a borda (fora da área 13×15 tudo é WALL).
  - `func get_cell(c: Vector2i) -> Cell`, `func set_cell(c: Vector2i, v: Cell) -> void`
  - `func in_bounds(c: Vector2i) -> bool`, `func is_free(c: Vector2i) -> bool` (EMPTY e dentro)
  - `static func cell_to_world(c: Vector2i) -> Vector2` (centro da célula, já com o deslocamento do HUD), `static func world_to_cell(p: Vector2) -> Vector2i`
  - `static func from_layout(lines: PackedStringArray) -> Grid` — `#` gelo, `.` vazio, `P` início do jogador, `E` início de inimigo; guarda `player_start: Vector2i` e `enemy_starts: Array[Vector2i]`.
- Layout da fase: `levels/level_01.txt` (15 linhas × 13 colunas), desenho nosso.
- Cena `scenes/arena.tscn` com `scripts/arena.gd` (`class_name Arena`, Node2D): tem `var grid: Grid`, desenha o chão e a borda num `TileMapLayer` (`$Floor`) e expõe `signal cell_changed(c: Vector2i)`.
- Jogador: `scenes/player.tscn` / `scripts/player.gd` (`class_name Player`, CharacterBody2D ou Area2D), `var cell: Vector2i`, `const STEP_TIME := 0.15`, anda por Tween entre centros de célula; enquanto anda, ignora input. Ação de empurrar: tecla espaço, `signal push_requested(from: Vector2i, dir: Vector2i)` (GELO trata). `signal died`.
- Input map: `move_up/down/left/right` (setas + WASD), `push` (espaço), `restart` (R).

## Pacotes

1. Projeto e grade — `project.godot`, `.gitignore` do Godot, `scripts/grid.gd`, `tests/run_tests.gd`, `tests/test_base.gd`, `tests/test_grid.gd`, `levels/level_01.txt` — testes: from_layout, borda é WALL, is_free, cell_to_world/world_to_cell ida e volta.
2. Arena e assets — baixar Kenney **Sokoban** (CC0) para `assets/kenney/sokoban/`, `scenes/arena.tscn`, `scripts/arena.gd`, `scenes/main.tscn` (cena principal) — teste: arena carrega o layout e a grade bate com o arquivo.
3. Jogador — `scenes/player.tscn`, `scripts/player.gd`, AnimatedSprite2D com andar nas 4 direções e parado — testes: movimento bloqueado por gelo/borda, célula atualiza após o passo.

## Critérios de aceite

- [x] F5 abre a arena 13×15 com borda e blocos de gelo do `level_01.txt`.
- [x] Setas/WASD movem o jogador uma célula por vez, com animação na direção certa; não atravessa gelo nem borda.
- [x] Testes passam no comando do `CLAUDE.md`.

## Plano de tela (ux-ui) e decisões

- Divisa HUD/arena: faixa de parede de 12 px no rodapé do HUD (HUD #1B2333 de 0 a 52 px por cima da linha de parede y=-1). Escolha da pessoa (opção B).
- Chão claro; gelo azul-claro com contorno; jogador em cor quente. Escolha da pessoa (chão claro).
- Filtro de textura linear; clear color #1B2333 (barras ao maximizar).
- Janela 624×768; em tela menor (ex.: 1366×768 com barra de tarefas) `scripts/window_fit.gd` reduz a janela mantendo 832:1024 e centraliza.
- Sprites PROVISÓRIOS nossos em `assets/placeholder/` (download do Kenney Sokoban bloqueado em modo automático). Troca: caminhos em `assets/tilesets/arena_tileset.tres`, `assets/sprites/player_frames.tres` e `Arena.ICE_TEXTURE`.

## Riscos

- Templates/versão do Godot divergentes → usar só o 4.7.2 de `tools/godot`.
- Import de assets não roda em headless no worktree → rodar `--import` antes dos testes.

## Comandos

Ver `CLAUDE.md` (testes e import).
