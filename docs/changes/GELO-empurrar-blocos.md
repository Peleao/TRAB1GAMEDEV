# GELO — empurrar e quebrar blocos de gelo

**Objetivo:** o jogador empurra o bloco de gelo à frente; o bloco desliza célula a célula até bater em algo; se já estiver encostado em algo, quebra.
**Depende de:** BASE
**Pode rodar em paralelo com:** nada
**Passa pelo ux-ui:** não

## Contratos

- `scenes/ice_block.tscn` / `scripts/ice_block.gd` (`class_name IceBlock`, Area2D com CollisionShape2D): `var cell: Vector2i`, `const SLIDE_TIME_PER_CELL := 0.05`, `signal stopped(cell: Vector2i)`, `func slide_to(target: Vector2i) -> void` (Tween), `func shatter() -> void` (animação de quebra + `queue_free`).
- Em `Grid`: `func slide_target(from: Vector2i, dir: Vector2i) -> Vector2i` — última célula livre na direção; igual a `from` se a vizinha já está ocupada.
- Em `Arena`: `func push(from: Vector2i, dir: Vector2i) -> void` ligado a `Player.push_requested`. O bloco é `from + dir`. Se `slide_target == bloco` → `shatter`; senão a grade marca EMPTY na origem durante o deslize e ICE no destino ao parar. `signal block_sliding(block: IceBlock, dir: Vector2i)` (INIM usa para esmagar).
- Durante o deslize a célula de destino fica reservada (ninguém entra).

## Pacotes

1. Regra de deslize na grade — `scripts/grid.gd`, `tests/test_slide.gd` — testes: desliza até a borda, para antes de outro gelo, alvo == origem quando bloqueado.
2. Bloco e empurrão — `scenes/ice_block.tscn`, `scripts/ice_block.gd`, `scripts/arena.gd`, `scripts/player.gd` — testes: push move o bloco na grade; push em bloco encostado o remove; empurrar vazio não faz nada.

## Critérios de aceite

- [ ] Espaço com gelo à frente faz o bloco deslizar até bater, com movimento suave.
- [ ] Bloco encostado em gelo ou borda quebra com animação.
- [ ] Testes passam.

## Riscos

- Estado da grade fora de sincronia com o nó durante o Tween → grade é a fonte da verdade; nó só anima.

## Comandos

Ver `CLAUDE.md`.
