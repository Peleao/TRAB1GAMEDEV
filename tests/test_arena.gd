extends "res://tests/test_base.gd"

func _new_arena() -> Arena:
	var arena: Arena = load("res://scenes/arena.tscn").instantiate()
	tree.root.add_child(arena)
	return arena


func _layout_lines() -> PackedStringArray:
	return FileAccess.get_file_as_string("res://levels/level_01.txt").split("\n")


func test_grid_bate_com_arquivo() -> void:
	var arena := _new_arena()
	assert_true(arena.grid != null, "grid criada")
	var lines := _layout_lines()
	for y in Grid.ROWS:
		for x in Grid.COLS:
			var esperado := Grid.Cell.ICE if lines[y][x] == "#" else Grid.Cell.EMPTY
			assert_eq(arena.grid.get_cell(Vector2i(x, y)), esperado, "célula %d,%d" % [x, y])
	arena.free()


func test_floor_e_borda() -> void:
	var arena := _new_arena()
	var floor_layer: TileMapLayer = arena.get_node("Floor")
	assert_eq(floor_layer.position, Vector2(0, Grid.HUD_HEIGHT), "posição do Floor")
	for y in range(-1, Grid.ROWS + 1):
		for x in range(-1, Grid.COLS + 1):
			var c := Vector2i(x, y)
			assert_true(floor_layer.get_cell_source_id(c) != -1, "tile em %s" % c)
	var dentro := floor_layer.get_cell_source_id(Vector2i(3, 3))
	var anel := floor_layer.get_cell_source_id(Vector2i(-1, -1))
	var dentro_a := floor_layer.get_cell_atlas_coords(Vector2i(3, 3))
	var anel_a := floor_layer.get_cell_atlas_coords(Vector2i(-1, -1))
	assert_true(dentro != anel or dentro_a != anel_a, "chão e parede diferentes")
	for c in [Vector2i(13, 5), Vector2i(5, 15), Vector2i(13, 15), Vector2i(-1, 15)]:
		assert_eq(floor_layer.get_cell_source_id(c), anel, "anel em %s" % c)
	arena.free()


func test_blocos() -> void:
	var arena := _new_arena()
	var n := FileAccess.get_file_as_string("res://levels/level_01.txt").count("#")
	assert_eq(arena.blocks.size(), n, "número de blocos")
	for c in arena.blocks:
		assert_eq(arena.blocks[c].position, Grid.cell_to_world(c), "posição do bloco %s" % c)
	arena.free()


func test_load_level_duas_vezes() -> void:
	var arena := _new_arena()
	var n: int = arena.blocks.size()
	arena.load_level(arena.level_path)
	assert_eq(arena.blocks.size(), n, "dict sem duplicar")
	assert_eq(arena.get_node("Blocks").get_children().filter(func(b): return not b.is_queued_for_deletion()).size(), n, "filhos sem duplicar")
	arena.free()


func test_main() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(main)
	assert_true(main.has_node("Arena"), "Arena")
	assert_true(main.has_node("HudBackground"), "HudBackground")
	assert_true(main.has_node("WindowFit"), "WindowFit")
	assert_eq(ProjectSettings.get_setting("application/run/main_scene"), "res://scenes/main.tscn", "main_scene")
	main.free()
