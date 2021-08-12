extends Resource
class_name Recipe

export(Resource) var product
export(String) var description

export(Array, Resource) var ingredients = []
export(Array, int) var ingredientAmounts = []
