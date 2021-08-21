extends Resource
class_name Item

export(String) var name
export(Texture) var texture
export(int) var amount = 1
export(int) var stackLimit
export(float) var damageMultiplier
export(int) var damageType
export(int) var level
export(String) var model
export(float) var burningSpeed
export(float) var smeltingSpeed
export(bool) var buildable
export(Resource) var smeltingProduct
