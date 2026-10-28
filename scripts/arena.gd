class_name Arena
extends Node2D
## Arena: carrega o layout na Grid, desenha chão/borda no TileMapLayer e mostra os blocos de gelo.

signal cell_changed(c: Vector2i)

const SRC_FLOOR := 0
const SRC_WALL := 1
const PLAYER_SCENE := preload("res://scenes/player.tscn")
const ICE_TEXTURE := preload("res://assets/placeholder/ice.png")

@export var level_path := "res://levels/level_01.txt"

var grid: Grid
var blocks: Dictionary = {}  # Vector2i -> Node2D
var player: Player

@onready var floor_layer: TileMapLayer = $Floor
@onready var blocks_root: Node2D = $Blocks


func _ready() -> void:
	load_level(level_path)


func load_level(path: String) -> void:
	grid = Grid.load_layout(path)
	_draw_floor()
	_rebuild_blocks()
	if player == null:
		player = PLAYER_SCENE.instantiate()
		add_child(player)
	player.grid = grid
	player.place(grid.player_start)


func _draw_floor() -> void:
	floor_layer.clear()
	for y in range(-1, Grid.ROWS + 1):
		for x in range(-1, Grid.COLS + 1):
			var c := Vector2i(x, y)
			floor_layer.set_cell(c, SRC_FLOOR if grid.in_bounds(c) else SRC_WALL, Vector2i.ZERO)


func _rebuild_blocks() -> void:
	for b in blocks_root.get_children():
		blocks_root.remove_child(b)
		b.queue_free()
	blocks.clear()
	for y in Grid.ROWS:
		for x in Grid.COLS:
			var c := Vector2i(x, y)
			if grid.get_cell(c) == Grid.Cell.ICE:
				var b := _make_block(c)
				blocks_root.add_child(b)
				blocks[c] = b


func _make_block(c: Vector2i) -> Node2D:
	var s := Sprite2D.new()
	s.texture = ICE_TEXTURE
	s.position = Grid.cell_to_world(c)
	return s
