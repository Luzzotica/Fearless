extends Spatial


func run():
	# Play our animations, hide the body, stop from moving
	$DeathParticles.emitting = true
	$DeathSound.play()
	$DeathTimer.start()


func _on_DeathTimer_timeout():
	queue_free()
