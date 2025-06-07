extends CharacterBody2D

@onready var castle = $"../castle"
const speed = 50
var castle_chase = true

var player = null
var is_hurt = false
var is_dead = false
var enemy_attack_cooldown = true

var knockback_velocity = Vector2.ZERO
var knockback_force = 250
var knockback_decay = 600

var health = 100
var player_inattack_zone = false
var castle_inattack_zone = false
var can_take_damage = true

	
func _physics_process(delta):
	
	deal_with_damage()
	knockback(delta)
	
	if is_dead or is_hurt:
		return
		
	if castle_chase:
		if castle_inattack_zone:
			enemy_attack()
		elif player_inattack_zone:
			enemy_attack()
		else:
			position += (castle.global_position - global_position).normalized() * speed * delta
			$AnimatedSprite2D.play("walk")
			
		move_and_collide(Vector2(0,0))
		
		if(castle.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("idle")
		

func enemy():
	pass

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("castle"):
		castle_inattack_zone = true
		
	elif body.has_method("player"):
		player_inattack_zone = true
		player = body
		print("it detect the player")

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false
		player = null
	elif body.has_method("castle"):
		castle_inattack_zone = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("castle"):
		castle = body
		castle_chase = true
	elif body.has_method("player"):
		player = body
		print("Player detected!")

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("castle"):
		castle = null
		castle_chase = false
	elif body.has_method("player"):
		player = null

func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage == true and not is_dead and player != null:
			hurt()
			health = health - 40
			$Take_dmg_cooldown.start()
			can_take_damage = false
			print("Monster health ", health)
			apply_knockback(player.global_position)
			
			
			if health <= 0:
				is_dead = true
				$AnimatedSprite2D.play("death") 
				$death_timer.start()

func knockback(delta):
	if knockback_velocity.length() > 0.1:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	
func apply_knockback(from_position: Vector2) -> void:
	var direction: Vector2 = (global_position - from_position).normalized()
	knockback_velocity = direction * knockback_force
	
func _on_take_dmg_cooldown_timeout() -> void:
	can_take_damage =true

func _on_death_timer_timeout() -> void:
	self.queue_free()

func hurt():
	is_hurt = true
	$AnimatedSprite2D.play("hurt")
	$hurt_timer.start()

func _on_hurt_timer_timeout() -> void:
	is_hurt = false

func enemy_attack():
	if enemy_attack_cooldown and not is_dead and not is_hurt:
		$AnimatedSprite2D.play("attack2")
		
		if castle_inattack_zone and castle != null and castle.has_method("take_damage_castle"):
			castle.take_damage_castle(20)
			print("Enemy attacking castle!")
			
		elif player_inattack_zone and player != null and player.has_method("take_damage"):
			player.take_damage(20)
			print("Enemy attacking player!")
			
		enemy_attack_cooldown = false
		$attack_timer.start()

func _on_attack_timer_timeout() -> void:
	enemy_attack_cooldown = true
