class_name SoundEffect2D extends AudioStreamPlayer2D

func play_random(rng: RandomNumberGenerator, std: float) -> void:
	var pitch: float = rng.randfn(0.0, std)
	pitch = 2 ** pitch
	pitch_scale = pitch
	play()
