class_name Vfx
extends AnimatedSprite2D
# One-shot sprite-sheet VFX (frames from the "VFX Free Pack" effect sheets).
# Usage: Vfx.spawn(get_tree().current_scene, preload("res://assets/VFX/hit.png"), 6, 5, 30, 30.0, global_position, 0.3)


static func spawn(parent: Node, sheet: Texture2D, h_frames: int, v_frames: int,
		frame_count: int, fps: float, pos: Vector2, fx_scale := 1.0) -> void:
	var sprite := Vfx.new()
	sprite.hframes = h_frames
	sprite.vframes = v_frames

	var frames := SpriteFrames.new()
	frames.add_animation("fx")
	frames.set_animation_speed("fx", fps)
	frames.set_animation_loop("fx", false)
	var frame_size := Vector2(sheet.get_width() / float(h_frames), sheet.get_height() / float(v_frames))
	for i in frame_count:
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		@warning_ignore("integer_division")
		atlas.region = Rect2(
			Vector2(i % h_frames, i / h_frames) * frame_size,
			frame_size
		)
		frames.add_frame("fx", atlas)
	sprite.sprite_frames = frames

	sprite.global_position = pos
	sprite.scale = Vector2.ONE * fx_scale
	sprite.z_index = 5
	parent.add_child(sprite)
	sprite.play("fx")
	sprite.animation_finished.connect(sprite.queue_free)
