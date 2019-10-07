extends "res://Scripts/Prefab_Scripts/MapEntity.gd"

var friendlies = []
var enemies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	#position += Vector2(0, 100)
	randomize()
	GameManager.connect("gameplay_tick", self, "gameplay_tick")

func start_combat(combatents):
	for combatent in combatents:
		enter_combat(combatent)

func enter_combat(character):
	if character.type == GameManager.ENTITY_TYPE.GOBLIN or character.type == GameManager.ENTITY_TYPE.PLAYER:
		friendlies.append(character)
	else:
		enemies.append(character)
	character.hide()

func leave_combat(character):
	friendlies.erase(character)
	enemies.erase(character)
	if character.type != GameManager.ENTITY_TYPE.PLAYER:
		if character.health <= 0:
			character.die()
		else:
			character.finish_job()
	character.show()

func combat_over():
	for combatent in friendlies:
		leave_combat(combatent)
	for combatent in enemies:
		leave_combat(combatent)
	queue_free()

func gameplay_tick():
	if friendlies.size() < 1 or enemies.size() < 1:
		combat_over()
		return
	
	var friendlyDamage = 0
	var enemyDamage = 0
	
	for combatent in friendlies:
		friendlyDamage += randi()%(combatent.strength+1)+1
	for combatent in enemies:
		enemyDamage = randi()%(combatent.strength+1)+1

	print(String(friendlies.size()) + " - " + String(friendlyDamage) + " VS " + String(enemyDamage))
	assign_damage(friendlyDamage, enemyDamage)

func assign_damage(friendlyDamage, enemyDamage):
	#FRIENDLIES
	var perUnitDamage = enemyDamage/friendlies.size()
	friendlies[0].health -= enemyDamage%friendlies.size()
	for combatent in friendlies:
		combatent.health -= enemyDamage
		print(combatent.health)
		if combatent.health <= 0:
			leave_combat(combatent)
	#ENEMIES
	perUnitDamage = friendlyDamage/enemies.size()
	enemies[0].health -= friendlyDamage%enemies.size()
	for combatent in enemies:
		combatent.health -= friendlyDamage
		if combatent.health <= 0:
			leave_combat(combatent)