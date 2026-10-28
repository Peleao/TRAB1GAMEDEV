# INIM — inimigos, pontuação, vitória e derrota

**Objetivo:** inimigos andam sozinhos pela grade e tiram vida ao tocar; bloco deslizando esmaga inimigos; novos inimigos nascem após cada eliminação; pontos e vidas no HUD; vitória (todos eliminados) ou derrota (sem vidas).
**Depende de:** GELO
**Pode rodar em paralelo com:** nada
**Passa pelo ux-ui:** sim — HUD (pontos, vidas) e telas de vitória/derrota

## Contratos

- `scenes/enemy.tscn` / `scripts/enemy.gd` (`class_name Enemy`, Area2D + AnimatedSprite2D): `var cell: Vector2i`, `const STEP_TIME := 0.3`, IA simples: anda até travar e escolhe nova direção livre, preferindo a que aproxima do jogador; `signal died(points: int)`; `func crush() -> void`.
- Colisão jogador × inimigo por Area2D → `Player.died`.
- Bloco deslizando (Arena.block_sliding) que entra na célula de um inimigo o arrasta e esmaga ao parar: 400 pontos por inimigo, ×2 a cada inimigo extra no mesmo empurrão.
- Geração de inimigos (`scripts/enemy_spawner.gd`, `class_name EnemySpawner`, RefCounted testável): `const TOTAL_ENEMIES := 8`, `const MAX_ON_FIELD := 3`. Começa com 3 nos `enemy_starts`; cada inimigo eliminado faz nascer um novo (após 1 s) numa célula livre longe do jogador, até esgotar o total. `func remaining() -> int` (no campo + a nascer).
- `scripts/game.gd` (`class_name Game`, em `scenes/main.tscn`): `var score: int`, `var lives := 3`, `signal score_changed(score: int)`, `signal lives_changed(lives: int)`, `signal game_over(won: bool)`. Vitória: `remaining() == 0` (todos os inimigos eliminados). Derrota: vidas = 0. R reinicia.
- Sprites de inimigo: pacote Kenney CC0 escolhido pela sessão, em `assets/kenney/<pacote>/`.

## Pacotes

1. Movimento do inimigo — `scripts/enemy.gd`, `scenes/enemy.tscn`, `tests/test_enemy.gd` — testes: nunca entra em gelo/borda, muda de direção ao travar.
2. Esmagar, gerar e pontuar — `scripts/arena.gd`, `scripts/enemy_spawner.gd`, `scripts/game.gd`, `tests/test_score.gd`, `tests/test_spawner.gd` — testes: esmagar soma 400, dois no mesmo empurrão somam 1200, eliminação gera novo inimigo até o total, nunca mais de 3 no campo, vitória só quando `remaining() == 0`.
3. HUD e fim de jogo — `scenes/hud.tscn`, `scripts/hud.gd`, `scenes/main.tscn` — teste manual + teste de sinais.

## Critérios de aceite

- [ ] Inimigos andam pela arena sem atravessar gelo.
- [ ] Encostar num inimigo tira uma vida e reposiciona o jogador.
- [ ] Bloco deslizando esmaga inimigos e soma pontos no HUD.
- [ ] Cada inimigo eliminado faz nascer outro até completar 8; nunca mais de 3 ao mesmo tempo.
- [ ] Todos os 8 eliminados → tela de vitória; sem vidas → derrota; R reinicia.
- [ ] Testes passam.

## Riscos

- Inimigo e bloco disputando a mesma célula → a reserva de célula do GELO vale também para inimigos.

## Comandos

Ver `CLAUDE.md`.
