extends GPUParticles2D

func _ready():
	# Configure basic properties
	set_emitting(true)
	amount = 1000  # Number of particles
	lifetime = 1.0  # Lifetime of each particle
	one_shot = true  # Set to true for a burst effect

	# Create a custom process material
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	material.spread = 360  # Spread particles in all directions
	material.emission_energy = 1.0
	material.emission_restart_rate = 0.1

	# Assign the material to the particle system
	process_material = material

	# Start emitting particles
	restart()
