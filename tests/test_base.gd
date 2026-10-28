extends RefCounted
## Base dos testes. O runner define `tree` (SceneTree) e `current` (nome do teste em execução).

var tree: SceneTree
var current := ""
var failures: Array[String] = []


func assert_eq(a, b, msg := "") -> void:
	if typeof(a) != typeof(b) or a != b:
		failures.append("%s — %s (esperado %s, veio %s)" % [current, msg, str(b), str(a)])


func assert_true(c, msg := "") -> void:
	if not c:
		failures.append("%s — %s" % [current, msg])
