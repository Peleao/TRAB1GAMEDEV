extends "res://tests/test_base.gd"

func _layout() -> PackedStringArray:
	var lines := PackedStringArray()
	for y in 15:
		lines.append(".............")
	lines[0] = "P#.........E#"
	lines[14] = "E............"
	return lines


func test_from_layout() -> void:
	var g := Grid.from_layout(_layout())
	assert_eq(g.get_cell(Vector2i(0, 0)), Grid.Cell.EMPTY, "P é vazio")
	assert_eq(g.get_cell(Vector2i(1, 0)), Grid.Cell.ICE, "gelo")
	assert_eq(g.get_cell(Vector2i(11, 0)), Grid.Cell.EMPTY, "E é vazio")
	assert_eq(g.get_cell(Vector2i(12, 0)), Grid.Cell.ICE, "gelo")
	assert_eq(g.get_cell(Vector2i(5, 5)), Grid.Cell.EMPTY, "vazio")
	assert_eq(g.player_start, Vector2i(0, 0), "player_start")
	assert_eq(g.enemy_starts.size(), 2, "2 inimigos")
	assert_eq(g.enemy_starts[0], Vector2i(11, 0), "ordem 1")
	assert_eq(g.enemy_starts[1], Vector2i(0, 14), "ordem 2")


func test_from_layout_ignora_fim_e_cr() -> void:
	var l := _layout()
	l[0] += "\r"
	l.append("")
	var g := Grid.from_layout(l)
	assert_eq(g.get_cell(Vector2i(1, 0)), Grid.Cell.ICE, "gelo com CR")
	assert_eq(g.player_start, Vector2i(0, 0), "player_start")


func test_borda() -> void:
	var g := Grid.from_layout(_layout())
	for c in [Vector2i(-1, 0), Vector2i(13, 0), Vector2i(0, -1), Vector2i(0, 15), Vector2i(100, 100)]:
		assert_eq(g.get_cell(c), Grid.Cell.WALL, "fora é WALL %s" % c)
		assert_true(not g.in_bounds(c), "fora de limites %s" % c)
	assert_true(g.in_bounds(Vector2i(0, 0)), "0,0 dentro")
	assert_true(g.in_bounds(Vector2i(12, 14)), "12,14 dentro")


func test_is_free() -> void:
	var g := Grid.from_layout(_layout())
	assert_true(g.is_free(Vector2i(5, 5)), "vazio livre")
	assert_true(not g.is_free(Vector2i(1, 0)), "gelo não livre")
	assert_true(not g.is_free(Vector2i(-1, 0)), "fora não livre")
	assert_true(g.is_free(g.player_start), "P livre")
	assert_true(g.is_free(g.enemy_starts[0]), "E livre")


func test_set_cell() -> void:
	var g := Grid.from_layout(_layout())
	g.set_cell(Vector2i(5, 5), Grid.Cell.ICE)
	assert_eq(g.get_cell(Vector2i(5, 5)), Grid.Cell.ICE, "set dentro")
	g.set_cell(Vector2i(-1, 5), Grid.Cell.ICE)
	g.set_cell(Vector2i(13, 5), Grid.Cell.ICE)
	assert_eq(g.get_cell(Vector2i(-1, 5)), Grid.Cell.WALL, "fora segue WALL")
	assert_eq(g.get_cell(Vector2i(0, 5)), Grid.Cell.EMPTY, "vizinho intacto")
	assert_eq(g.get_cell(Vector2i(12, 5)), Grid.Cell.EMPTY, "vizinho intacto 2")


func test_conversao() -> void:
	assert_eq(Grid.cell_to_world(Vector2i(0, 0)), Vector2(32, 96), "0,0")
	assert_eq(Grid.cell_to_world(Vector2i(12, 14)), Vector2(800, 992), "12,14")
	for y in Grid.ROWS:
		for x in Grid.COLS:
			var c := Vector2i(x, y)
			assert_eq(Grid.world_to_cell(Grid.cell_to_world(c)), c, "ida e volta %s" % c)
	assert_eq(Grid.world_to_cell(Vector2(0, 64)), Vector2i(0, 0), "origem")
	assert_eq(Grid.world_to_cell(Vector2(-1, 64)), Vector2i(-1, 0), "x negativo")
	assert_eq(Grid.world_to_cell(Vector2(5, 10)), Vector2i(0, -1), "HUD")


func test_level_01() -> void:
	var lines := FileAccess.get_file_as_string("res://levels/level_01.txt").split("\n")
	while lines[-1] == "":
		lines.remove_at(lines.size() - 1)
	assert_eq(lines.size(), 15, "15 linhas")
	for l in lines:
		assert_eq(l.length(), 13, "13 colunas")
	var g := Grid.load_layout("res://levels/level_01.txt")
	assert_eq(g.enemy_starts.size(), 3, "3 inimigos")
	var dirs := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var n := 0
	for d in dirs:
		if g.is_free(g.player_start + d):
			n += 1
	assert_true(n >= 2, "P com >=2 vizinhos livres")
	for e in g.enemy_starts:
		var m := 0
		for d in dirs:
			if g.is_free(e + d):
				m += 1
		assert_true(m >= 1, "E %s com vizinho livre" % e)


func test_input_map() -> void:
	for a in ["move_up", "move_down", "move_left", "move_right", "push", "restart"]:
		assert_true(InputMap.has_action(a), "ação " + a)
