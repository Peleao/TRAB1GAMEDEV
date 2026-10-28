# TRAB1GAMEDEV — protótipo de jogo de blocos de gelo (Godot 4)

Trabalho 1 de Game Dev. Jogo **original** do gênero arena-de-blocos: arena em grade, jogador em 4 direções, empurrar blocos de gelo (deslizam até bater; quebram se encostados), inimigos esmagados pelo bloco. Não é cópia de jogo existente: nome, personagens e fases são nossos.

- Engine: Godot 4.7.2 (GDScript). Editor fora do git em `E:/Projetos/TRAB1GAMEDEV/tools/godot/` (use o caminho absoluto, inclusive nos worktrees).
- Assets: só Kenney CC0 (kenney.nl), em `assets/kenney/<pacote>/`, com o `License.txt` do pacote. Créditos no `README.md`.
- Entrega: executável Linux em `build/` (commitado), repositório público no GitHub.
- Requisitos técnicos pedidos: TileMapLayer (tiles), AnimatedSprite2D (animação), colisões (Area2D/física), transformações (Tween/Transform2D).

## Comandos (modo silencioso)

```bash
GODOT="/e/Projetos/TRAB1GAMEDEV/tools/godot/Godot_v4.7.2-stable_win64_console.exe"
# importar assets (rodar uma vez após adicionar arquivos)
"$GODOT" --headless --path . --import >/dev/null 2>&1
# testes (saída: só falhas e o total; exit code != 0 se falhar)
"$GODOT" --headless --path . -s res://tests/run_tests.gd 2>&1 | grep -E "FAIL|PASS:|ERROR|SCRIPT ERROR"
# build Linux
"$GODOT" --headless --path . --export-release "Linux" build/gelo.x86_64 2>&1 | grep -iE "error|fail" ; ls build
```

## Testes

Sem addon: `tests/run_tests.gd` (extends SceneTree) roda todo `tests/test_*.gd`. Cada teste é um método `test_*` que devolve nada e usa `assert_eq(a, b, msg)` / `assert_true(c, msg)` de `tests/test_base.gd`. A lógica de grade fica em classes testáveis sem cena.

## Contratos

Ver `docs/changes/` — os contratos compartilhados estão em `BASE`.
