extends Node

const PATH := "user://leaderboard.json"

# Each entry:
# { "name": String, "time": float }

func load_entries() -> Array[Dictionary]:
	if not FileAccess.file_exists(PATH):
		return []
	var f := FileAccess.open(PATH, FileAccess.READ)
	var txt := f.get_as_text()
	f.close()
	var data = JSON.parse_string(txt)
	if typeof(data) != TYPE_ARRAY:
		return []
	var out: Array[Dictionary] = []
	for item in data:
		if typeof(item) == TYPE_DICTIONARY:
			var d: Dictionary = item
			if d.has("name") and d.has("time"):
				out.append({"name": str(d["name"]), "time": float(d["time"])})
	return out

func save_entries(entries: Array[Dictionary]) -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(entries))
	f.close()

func add_entry(name: String, time: float) -> void:
	var entries := load_entries()
	entries.append({"name": name, "time": time})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("time", 999999.0)) < float(b.get("time", 999999.0))
	)
	save_entries(entries)
