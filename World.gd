extends Spatial


const chunkSize : int = 64
const chunkAmount : int = 16

var noise : OpenSimplexNoise
var chunks = {}

var ready = true
var maxs = 0

func _process(_delta):
	var start = OS.get_ticks_msec()
	updateChunks()
	cleanUpChunks()
	resetChunks()
	ready = true
	var end = OS.get_ticks_msec()
	if end - start > maxs:
		maxs = end - start
		print(end - start)
	
func _ready():
	noise = OpenSimplexNoise.new()
	noise.seed = 0
	noise.period = 120
	
func addChunk(x, z):
	var key : String = str(x) + "," + str(z)
	
	if chunks.has(key) or !ready:
		return
	
	ready = false
	loadChunk(x, z)
	
func loadChunk(x, z):
	var chunk : Chunk = Chunk.new(noise, x * chunkSize, z * chunkSize, chunkSize)
	chunk.translation = Vector3(x * chunkSize, 0, z * chunkSize)
	
	loadDone(chunk)
	
func loadDone(chunk):
	call_deferred("add_child", chunk)
	var key : String = str(chunk.x / chunkSize) + "," + str(chunk.z / chunkSize)
	chunks[key] = chunk
	
func getChunk(x, z):
	var key : String = str(x) + "," + str(z)
	
	if chunks.has(key):
		return chunks.get(key)
		
	return null
	
func updateChunks():
	var playerPosition = $Player.translation
	# warning-ignore:integer_division
	var playerX = int(playerPosition.x) / chunkSize
	# warning-ignore:integer_division
	var playerZ = int(playerPosition.z) / chunkSize
	
	for x in range(playerX - chunkAmount * 0.5, playerX + chunkAmount * 0.5):
		for z in range(playerZ - chunkAmount * 0.5, playerZ + chunkAmount * 0.5):
			addChunk(x, z)
			var chunk = getChunk(x, z)
			if chunk != null:
				chunk.shouldRemove = false
	
func cleanUpChunks():
	for key in chunks:
		var chunk = chunks[key]
		if chunk.shouldRemove:
			chunk.queue_free()
			chunks.erase(key)
	
func resetChunks():
	for key in chunks:
		chunks[key].shouldRemove = true
