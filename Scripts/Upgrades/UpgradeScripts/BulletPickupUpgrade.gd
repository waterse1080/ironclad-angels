class_name BulletPickupUpgrade
extends BaseUpgrade

func on_fire_add(bullet: ProtoBullet, player: Player, _is_support: bool = false):
	var pickup_area = PickupBox.new()
	pickup_area.player = player
	pickup_area.collision_layer = 2
	pickup_area.scale.x = player.body.pickup_collider.scale.x
	pickup_area.scale.y = player.body.pickup_collider.scale.y
	
	var collider = CollisionShape2D.new()
	collider.shape = CapsuleShape2D.new()
	collider.position = bullet.collision_shape.position
	pickup_area.add_child(collider)
	bullet.add_child(pickup_area)
	
	bullet.bullet_destroyed.connect(pickup_area.queue_free)
