extends Spatial


const chunkSize : int = 64
const chunkAmount : int = 16

var noise : OpenSimplexNoise
var chunks = {}
var unreadyChunks = {}
var count = 0

func _process(_delta):
	if count > 127:
		$Player.brr = true
	updateChunks()
	cleanUpChunks()
	resetChunks()
	
func _ready():
	noise = OpenSimplexNoise.new()
	noise.seed = 0
	noise.period = 150
	
func addChunk(x, z):
	var key : String = str(x) + "," + str(z)
	
	noise.octaves = 4
	if chunks.has(key) or unreadyChunks.has(key):
		return
	
	loadChunk(x, z)
	unreadyChunks[key] = 1
	
func loadChunk(x, z):
	count += 1
	
	var chunk : Chunk = Chunk.new(noise, x * chunkSize, z * chunkSize, chunkSize)
	chunk.translation = Vector3(x * chunkSize, 0, z * chunkSize)
	
	loadDone(chunk)
	
func loadDone(chunk):
	add_child(chunk)
	var key : String = str(chunk.x / chunkSize) + "," + str(chunk.z / chunkSize)
	chunks[key] = chunk
	unreadyChunks.erase(key)
	
func getChunk(x, z):
	var key : String = str(x) + "," + str(z)
	
	if chunks.has(key):
		return chunks.get(key)
		
	return null
	
func updateChunks():
	var playerPosition = $Player.translation
	var playerX = float(playerPosition.x) / chunkSize
	var playerZ = float(playerPosition.z) / chunkSize
	
	for x in range(playerX - chunkAmount * 0.5, playerX + chunkAmount * 0.5):
		for z in range(playerZ - chunkAmount * 0.5, playerX + chunkAmount * 0.5):
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
