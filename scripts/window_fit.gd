extends Node
## Reduz a janela, mantendo a proporção 832:1024, se a tela útil for pequena demais.

const WINDOW_SIZE := Vector2i(624, 768)
const TITLE_MARGIN := 40


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var mode := DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		return
	var screen := DisplayServer.window_get_current_screen()
	var usable := DisplayServer.screen_get_usable_rect(screen)
	var avail_h := usable.size.y - TITLE_MARGIN
	if usable.size.x >= WINDOW_SIZE.x and avail_h >= WINDOW_SIZE.y:
		return
	var scale := minf(float(usable.size.x) / WINDOW_SIZE.x, float(avail_h) / WINDOW_SIZE.y)
	var size := Vector2i((Vector2(WINDOW_SIZE) * scale).floor())
	DisplayServer.window_set_size(size)
	DisplayServer.window_set_position(usable.position + Vector2i(
			(usable.size.x - size.x) / 2, TITLE_MARGIN + (avail_h - size.y) / 2))
