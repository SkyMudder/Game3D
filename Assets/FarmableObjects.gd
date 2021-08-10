extends Node



func takeDamage(object):
	object.hp -= 100
	print(object.hp)
