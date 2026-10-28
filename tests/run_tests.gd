extends SceneTree
## Roda todo res://tests/test_*.gd (exceto test_base.gd). Cada método test_* é um teste.
## Testes que precisam de nós usam `tree` (var tree: SceneTree, preenchida pelo runner).

func _initialize() -> void:
	await process_frame
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
			await inst.call(name)
			if inst.failures.is_empty():
				ok += 1
			else:
				for msg in inst.failures:
					print("FAIL: %s::%s" % [f, msg])
	print("PASS: %d/%d" % [ok, total])
	quit(0 if ok == total else 1)
