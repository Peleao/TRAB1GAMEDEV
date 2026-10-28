extends "res://tests/test_base.gd"

func _grid() -> Grid:
	var lines := PackedStringArray()
	for y in Grid.ROWS:
		var l := ""
		for x in Grid.COLS:
			l += "."
		lines.append(l)
	lines[7] = "......P......"
	lines[8] = "......#......"
	return Grid.from_layout(lines)


func _player(g: Grid) -> Player:
	var p: Player = load("res://scenes/player.tscn").instantiate()
	tree.root.add_child(p)
	p.grid = g
	return p


func test_place() -> void:
	var p := _player(_grid())
	p.place(Vector2i(5, 5))
	assert_eq(p.cell, Vector2i(5, 5), "cell")
	assert_eq(p.position, Grid.cell_to_world(Vector2i(5, 5)), "position")
	assert_eq(p.moving, false, "moving")
	p.free()


func test_move_livre() -> void:
	var p := _player(_grid())
	p.place(Vector2i(5, 5))
	assert_eq(p.try_move(Vector2i.RIGHT), true, "devolve true")
	assert_eq(p.moving, true, "moving")
	assert_eq(p.cell, Vector2i(5, 5), "cell ainda na origem")
	assert_eq(p.get_node("Sprite").animation, &"walk_right", "anim walk_right")
	await tree.create_timer(Player.STEP_TIME + 0.1).timeout
	assert_eq(p.cell, Vector2i(6, 5), "cell no destino")
	assert_eq(p.position, Grid.cell_to_world(Vector2i(6, 5)), "position no destino")
	assert_eq(p.moving, false, "moving fim")
	p.free()


func test_move_contra_gelo() -> void:
	var g := _grid()
	var p := _player(g)
	p.place(g.player_start)
	var pos := p.position
	assert_eq(p.try_move(Vector2i.DOWN), false, "bloqueado")
	assert_eq(p.cell, g.player_start, "cell igual")
	assert_eq(p.position, pos, "position igual")
	assert_eq(p.facing, Vector2i.DOWN, "facing")
	assert_eq(p.moving, false, "moving")
	p.free()


func test_move_contra_borda() -> void:
	var p := _player(_grid())
	p.place(Vector2i(0, 0))
	assert_eq(p.try_move(Vector2i.LEFT), false, "esquerda")
	assert_eq(p.try_move(Vector2i.UP), false, "cima")
	assert_eq(p.get_node("Sprite").animation, &"idle_up", "idle_up")
	assert_eq(p.cell, Vector2i(0, 0), "cell")
	p.free()


func test_move_enquanto_moving() -> void:
	var p := _player(_grid())
	p.place(Vector2i(5, 5))
	p.try_move(Vector2i.RIGHT)
	assert_eq(p.try_move(Vector2i.DOWN), false, "ignora")
	await tree.create_timer(Player.STEP_TIME + 0.1).timeout
	assert_eq(p.cell, Vector2i(6, 5), "destino não mudou")
	p.free()


func test_frames() -> void:
	var p := _player(_grid())
	var sf: SpriteFrames = p.get_node("Sprite").sprite_frames
	for d in ["up", "down", "left", "right"]:
		assert_true(sf.has_animation("idle_" + d), "idle_" + d)
		assert_true(sf.has_animation("walk_" + d), "walk_" + d)
	p.free()


func test_sinais() -> void:
	var p := _player(_grid())
	assert_true(p.has_signal("push_requested"), "push_requested")
	assert_true(p.has_signal("died"), "died")
	for s in p.get_signal_list():
		if s["name"] == "push_requested":
			assert_eq(s["args"].size(), 2, "2 argumentos")
	p.free()


func test_arena_cria_jogador() -> void:
	var arena: Arena = load("res://scenes/arena.tscn").instantiate()
	tree.root.add_child(arena)
	assert_true(arena.player != null, "player existe")
	assert_eq(arena.player.cell, arena.grid.player_start, "cell inicial")
	assert_true(arena.player.grid == arena.grid, "grid do player")
	arena.load_level(arena.level_path)
	var n := arena.get_children().filter(func(c): return c is Player).size()
	assert_eq(n, 1, "um só Player")
	assert_eq(arena.player.cell, arena.grid.player_start, "cell após recarga")
	arena.free()
