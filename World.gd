extends Spatial


const chunkSize: int = 64
const chunkAmount: int = 16

var terrainNoise: OpenSimplexNoise
var objectNoise: OpenSimplexNoise
var chunks: Dictionary = {}

var ready: bool = true

func _process(_delta) -> void:
	updateChunks()
	cleanUpChunks()
	resetChunks()
	ready = true
	
func _ready() -> void:
	terrainNoise = OpenSimplexNoise.new()
	terrainNoise.seed = 0
	terrainNoise.period = 140
	terrainNoise.octaves = 2
	objectNoise = OpenSimplexNoise.new()
	objectNoise.seed = terrainNoise.seed
	objectNoise.period = 1
	objectNoise.octaves = 3
	
func addChunk(x: int, z: int) -> void:
	var key: String = str(x) + "," + str(z)
	
	if chunks.has(key) or !ready:
		return
	
	ready = false
	loadChunk(x, z)
	
func loadChunk(x: int, z: int) -> void:
	var chunk: Chunk = Chunk.new(terrainNoise, objectNoise, x * chunkSize, z * chunkSize, chunkSize)
	chunk.translation = Vector3(x * chunkSize, 0, z * chunkSize)
	
	loadDone(chunk)
	
func loadDone(chunk: Chunk) -> void:
	call_deferred("add_child", chunk)
	# warning-ignore:integer_division
	# warning-ignore:integer_division
	var key: String = str(chunk.x / chunkSize) + "," + str(chunk.z / chunkSize)
	chunks[key] = chunk
	
func getChunk(x: int, z: int):
	var key: String = str(x) + "," + str(z)
	
	if chunks.has(key):
		return chunks.get(key)
		
	return null
	
func updateChunks() -> void:
	var playerPosition: Vector3 = $Player.translation
	# warning-ignore:integer_division
	var playerX: int = int(playerPosition.x) / chunkSize
	# warning-ignore:integer_division
	var playerZ: int = int(playerPosition.z) / chunkSize
	
	for x in range(playerX - chunkAmount * 0.5, playerX + chunkAmount * 0.5):
		for z in range(playerZ - chunkAmount * 0.5, playerZ + chunkAmount * 0.5):
			addChunk(x, z)
			var chunk: Chunk = getChunk(x, z)
			if chunk != null:
				chunk.shouldRemove = false
	
func cleanUpChunks() -> void:
	for key in chunks:
		var chunk: Chunk = chunks[key]
		if chunk.shouldRemove:
			chunk.queue_free()
			# warning-ignore:return_value_discarded
			chunks.erase(key)
	
func resetChunks() -> void:
	for key in chunks:
		chunks[key].shouldRemove = true
