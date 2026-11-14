class_name Vfx
extends Sprite2D
# One-shot sprite-sheet VFX (frames from the "VFX Free Pack" effect sheets).
# Steps the sheet region manually, so it works with plain Sprite2D.
# Usage: Vfx.spawn(get_tree().current_scene, preload("res://assets/VFX/hit.png"), 6, 5, 30, 30.0, global_position, 0.3)

var _h_frames := 0
var _v_frames := 0
var _frame_count := 0
var _fps := 30.0
var _frame_size := Vector2.ZERO
var _time := 0.0


static func spawn(parent: Node, sheet: Texture2D, h_frames: int, v_frames: int,
		frame_count: int, fps: float, pos: Vector2, fx_scale := 1.0,
		jitter_rotation := true) -> Vfx:
	var sprite := Vfx.new()
	sprite.texture = sheet
	sprite._h_frames = h_frames
	sprite._v_frames = v_frames
	sprite._frame_count = frame_count
	sprite._fps = fps
	sprite._frame_size = Vector2(
		sheet.get_width() / float(h_frames),
		sheet.get_height() / float(v_frames)
	)
	sprite.region_enabled = true
	sprite.region_rect = Rect2(Vector2.ZERO, sprite._frame_size)
	sprite.position = pos
	sprite.scale = Vector2.ONE * fx_scale
	sprite.z_index = 5
	# Additive blending: the effect glows over the scene instead of looking
	# like a pasted rectangle with hard edges.
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	sprite.material = mat
	if jitter_rotation:
		sprite.rotation = randf_range(0.0, TAU)
	parent.add_child(sprite)
	return sprite


func _process(delta: float) -> void:
	_time += delta
	var frame := int(_time * _fps)
	if frame >= _frame_count:
		queue_free()
		return
	@warning_ignore("integer_division")
	region_rect = Rect2(
		Vector2(frame % _h_frames, frame / _h_frames) * _frame_size,
		_frame_size
	)
