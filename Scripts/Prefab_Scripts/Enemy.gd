extends "res://Scripts/Prefab_Scripts/Character.gd"

signal request_job_target()
signal start_combat()

# goblin stats
export var gname = "ENEMY"

var currentJob = "wander"
var currentTarget = null

func _ready():
	._ready()
	randomize()
	type = GameManager.ENTITY_TYPE.ENEMY
	strength = 3
	health = 15
	yield(get_tree().create_timer(randf()*3+1), "timeout")
	start_job()

func join_clan():
	emit_signal("request_job_target", self, "join")
	start_specific_job("wander")

func determine_jobs():
	if check_for_combat():
		return "fight"
	else:
		return "attack"

func check_for_combat():
	if get_tree().get_nodes_in_group("combat_sites").size() > 0:
		return true
	return false
	
func check_for_construction():
	for site in get_tree().get_nodes_in_group("construction_sites"):
		if !site.is_at_capacity():
			return true
	return false

func start_job():
	print("START JOB")
	currentJob = determine_jobs()
	emit_signal("request_job_target", self, currentJob)

func start_specific_job(job):
	currentJob = job
	emit_signal("request_job_target", self, currentJob)

func handle_job(path, target):
	print(target)
	if target == null or path == null:
		finish_job()
		return
	
	currentTarget = target
	move(path)

func job_movement_done():
	print("JOB MOVEMENT DONE")
	call(currentJob)

func finish_job():
	currentJob = "idle"
	currentTarget = null
	yield(get_tree().create_timer(randf()*10+1), "timeout")
	start_job()

func is_this_current_target(target):
	if currentTarget == target:
		cancel_job()

func cancel_job():
	set_process(false)
	currentJob = "idle"
	currentTarget = null
	yield(get_tree().create_timer(randf()*3+1), "timeout")
	start_job()

func attack():
	emit_signal("start_combat", currentTarget, self)
	finish_job()

func fight():
	currentTarget.enter_combat(self)

func die():
	ResourceManager.update_resource(ResourceManager.Resource.POPULATION, -1)
	$MapEntity_Sprite.modulate = Color.red
	$AnimationPlayer.play("die")
	yield(get_tree().create_timer(3), "timeout")
	queue_free()

func move(newPath: PoolVector2Array):
	.move(newPath)
	$AnimationPlayer.play("waddle_knight")

func _process(delta):
	if !path:
		isMoving = false
		#$AnimationPlayer.stop()
		$Tween.interpolate_property($Knight, "offset", $MapEntity_Sprite.offset, 0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$Tween.interpolate_property($Knight, "rotation_degrees", $MapEntity_Sprite.rotation_degrees, 0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$Tween.interpolate_property($Knight/Sword, "offset", $MapEntity_Sprite.offset, 0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$Tween.interpolate_property($Knight/Sword, "rotation_degrees", $MapEntity_Sprite.rotation_degrees, 0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$Tween.interpolate_property($Knight/Helmet, "rotation_degrees", $MapEntity_Sprite.rotation_degrees, 0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$Tween.start()
		set_process(false)
		job_movement_done()
	if path.size() > 0:
		var d: float = position.distance_to(path[0])
		if d > 20:
			position = position.linear_interpolate(path[0], (speed * delta)/d)
		else:
			path.remove(0)

func get_details():
	return[str(health), str(strength), str(gname), currentJob]