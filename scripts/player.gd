class_name Player
extends Area2D
## Jogador: anda célula a célula por Tween. A célula lógica atualiza ao fim do passo.

signal push_requested(from: Vector2i, dir: Vector2i)
signal died

const STEP_TIME := 0.15
## Direção -> sufixo das animações (idle_<x> / walk_<x>). Trocar o sprite só muda o SpriteFrames.
const DIR_NAMES := {
	Vector2i.UP: "up",
	Vector2i.DOWN: "down",
	Vector2i.LEFT: "left",
	Vector2i.RIGHT: "right",
}
const INPUTS := [
	["move_up", Vector2i.UP],
	["move_down", Vector2i.DOWN],
	["move_left", Vector2i.LEFT],
	["move_right", Vector2i.RIGHT],
]

var grid: Grid
var cell := Vector2i.ZERO
var facing := Vector2i.DOWN
var moving := false

var _tween: Tween

@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	_play("idle")


func place(c: Vector2i) -> void:
	if _tween:
		_tween.kill()
		_tween = null
	cell = c
	position = Grid.cell_to_world(c)
	moving = false
	_play("idle")


func try_move(dir: Vector2i) -> bool:
	if moving:
		return false
	facing = dir
	if grid == null or not grid.is_free(cell + dir):
		_play("idle")
		return false
	moving = true
	_play("walk")
	var target := cell + dir
	_tween = create_tween()
	_tween.tween_property(self, "position", Grid.cell_to_world(target), STEP_TIME)
	_tween.finished.connect(_on_step_done.bind(target))
	return true


func _on_step_done(target: Vector2i) -> void:
	cell = target
	moving = false
	_tween = null


func _physics_process(_delta: float) -> void:
	if moving:
		return
	for pair in INPUTS:
		if Input.is_action_pressed(pair[0]):
			try_move(pair[1])
			break
	if not moving:
		_play("idle")
		if Input.is_action_just_pressed("push"):
			push_requested.emit(cell, facing)


func _play(kind: String) -> void:
	var anim := "%s_%s" % [kind, DIR_NAMES[facing]]
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)
