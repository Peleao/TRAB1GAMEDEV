extends SceneTree
## Roda todo res://tests/test_*.gd (exceto test_base.gd). Cada método test_* é um teste.
## Testes que precisam de nós usam `tree` (var tree: SceneTree, preenchida pelo runner).
## Erro de script em tempo de execução durante um teste conta como falha (via Logger).


class ScriptErrorCounter extends Logger:
	var count := 0
	var last := ""

	func _log_error(_function: String, file: String, line: int, code: String, rationale: String,
			_editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		if error_type == ERROR_TYPE_SCRIPT:
			count += 1
			last = "%s (%s:%d)" % [rationale if rationale != "" else code, file, line]


func _initialize() -> void:
	await process_frame
	var errors := ScriptErrorCounter.new()
	OS.add_logger(errors)
	var total := 0
	var ok := 0
	var files: Array[String] = []
	for f in DirAccess.get_files_at("res://tests"):
		if f.begins_with("test_") and f.ends_with(".gd") and f != "test_base.gd":
			files.append(f)
	files.sort()
	for f in files:
		var script = load("res://tests/" + f)
		if script == null or not script.can_instantiate():
			print("FAIL: %s não carregou" % f)
			total += 1
			continue
		var inst = script.new()
		inst.tree = self
		for m in inst.get_method_list():
			var name: String = m["name"]
			if not name.begins_with("test_"):
				continue
			total += 1
			inst.current = name
			inst.failures.clear()
			var errors_before := errors.count
			await inst.call(name)
			if errors.count > errors_before:
				inst.failures.append("%s — erro de script: %s" % [name, errors.last])
			if inst.failures.is_empty():
				ok += 1
			else:
				for msg in inst.failures:
					print("FAIL: %s::%s" % [f, msg])
	print("PASS: %d/%d" % [ok, total])
	quit(0 if ok == total else 1)
