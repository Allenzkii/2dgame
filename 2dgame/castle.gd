extends CharacterBody2D

var health = 100
var max_health = 100
var destroyed = false

func _physics_process(delta):
	pass

func castle():
	pass

func take_damage_castle(amount):
	if not destroyed:
		health -= amount
		print("Castle took damage! Health", health, "/", max_health)
		
		if health <= 0:
			health = 0
			destroy_castle()

func destroy_castle():
	destroyed = true
	print("Castle has been destroyed!")
