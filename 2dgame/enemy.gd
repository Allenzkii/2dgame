extends CharacterBody2D

var speed = 40
var player_chase = false
var player = null
var is_dead = false

var knockback_velocity = Vector2.ZERO
var knockback_force = 400
var knockback_decay = 800

var health = 100
var player_inattack_zone = false
var can_take_damage = true

func _physics_process(delta):
	deal_with_damage()
	knockback(delta)
	
	if player_chase:
		position += (player.position - position)/speed
		$AnimatedSprite2D.play("walk")
		move_and_collide(Vector2(0,0))
		
		if(player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("idle")
		

func enemy():
	pass

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false

func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage == true and not is_dead:
			health = health - 40
			$Take_dmg_cooldown.start()
			can_take_damage = false
			print("Monster health ", health)
			if health <= 0:
				$AnimatedSprite2D.play("dead")
				self.queue_free()
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
