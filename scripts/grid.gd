class_name Grid
extends RefCounted
## Grade lógica da arena (sem cena). Fora da área COLS×ROWS tudo é WALL.

const COLS := 13
const ROWS := 15
const CELL := 64
const HUD_HEIGHT := 64

enum Cell { EMPTY, WALL, ICE }

var cells: Array = []
var player_start := Vector2i.ZERO
var enemy_starts: Array[Vector2i] = []


func _init() -> void:
	cells.resize(COLS * ROWS)
	cells.fill(Cell.EMPTY)


func in_bounds(c: Vector2i) -> bool:
	return c.x >= 0 and c.x < COLS and c.y >= 0 and c.y < ROWS


func get_cell(c: Vector2i) -> Cell:
	if not in_bounds(c):
		return Cell.WALL
	return cells[c.y * COLS + c.x]


func set_cell(c: Vector2i, v: Cell) -> void:
	if not in_bounds(c):
		return
	cells[c.y * COLS + c.x] = v


func is_free(c: Vector2i) -> bool:
	return in_bounds(c) and get_cell(c) == Cell.EMPTY


static func cell_to_world(c: Vector2i) -> Vector2:
	return Vector2(c.x * CELL + CELL / 2, HUD_HEIGHT + c.y * CELL + CELL / 2)


static func world_to_cell(p: Vector2) -> Vector2i:
	return Vector2i(floori(p.x / CELL), floori((p.y - HUD_HEIGHT) / CELL))


static func from_layout(lines: PackedStringArray) -> Grid:
	var rows: Array[String] = []
	for l in lines:
		rows.append(l.replace("\r", ""))
	while not rows.is_empty() and rows[-1] == "":
		rows.pop_back()
	var g := Grid.new()
	if rows.size() != ROWS:
		push_error("Layout deve ter %d linhas (tem %d)" % [ROWS, rows.size()])
	var players := 0
	for y in mini(rows.size(), ROWS):
		var line := rows[y]
		if line.length() != COLS:
			push_error("Linha %d deve ter %d colunas (tem %d)" % [y, COLS, line.length()])
		for x in mini(line.length(), COLS):
			var c := Vector2i(x, y)
			match line[x]:
				"#":
					g.set_cell(c, Cell.ICE)
				"P":
					g.player_start = c
					players += 1
				"E":
					g.enemy_starts.append(c)
	if players != 1:
		push_error("Layout deve ter exatamente um P (tem %d)" % players)
	return g


static func load_layout(path: String) -> Grid:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Não abriu o layout: " + path)
		return Grid.new()
	return from_layout(f.get_as_text().split("\n"))
