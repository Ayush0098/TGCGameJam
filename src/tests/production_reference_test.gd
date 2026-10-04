extends RefCounted
## Runtime asset availability and animation cancellation; no simulator outcomes here.

const ACTOR = preload("res://scenes/character_actor.tscn")
const GALLERY = preload("res://scenes/production_reference.tscn")


func run(check: Callable) -> bool:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/reference_manifest.json"))
	check.call(ResourceLoader.exists(manifest.background), "Reference painting imports as a runtime texture")
	for thought in manifest.thoughts:
		check.call(ResourceLoader.exists(manifest.thoughts[thought]), "%s thought icon exists" % thought)
	var tree := Engine.get_main_loop() as SceneTree
	for id in manifest.characters:
		var actor = ACTOR.instantiate()
		tree.root.add_child(actor)
		check.call(actor.configure(id), "%s cutout rig configures" % id)
		var all_textures := true
		for part in actor._parts.values():
			all_textures = all_textures and part.get_child(0).texture != null
		for expression in manifest.characters[id].expressions:
			actor.set_expression(expression)
			all_textures = all_textures and actor._face.texture != null
		check.call(all_textures, "%s parts and every expression load" % id)
		check.call(actor._parts.values().all(func(part): return part.z_index + actor._visual.z_index > 0), "%s back limbs draw above painted scenery" % id)
		actor.position = Vector2(100, 200)
		for action in manifest.characters[id].animations:
			actor.play_action(action, 2.0)
			actor.animation_player.advance(0.4)
			check.call(actor.position == Vector2(100, 200), "%s %s animation leaves simulation position untouched" % [id, action])
			actor.stop()
			var reset: bool = actor._visual.position == -actor.anchor and actor._visual.rotation == 0 and actor._visual.scale == Vector2.ONE and actor._visual.modulate == Color.WHITE
			for name in actor._parts:
				reset = reset and actor._parts[name].position == actor._rest[name] and actor._parts[name].rotation == 0 and actor._parts[name].scale == Vector2.ONE
			check.call(reset and not actor.animation_player.is_playing(), "%s %s cancels to rest pose" % [id, action])
		actor.play_action("run", 1.0, true)
		check.call(not actor.animation_player.is_playing() and actor._visual.position == -actor.anchor, "%s reduced motion avoids movement tracks" % id)
		check.call(not actor.configure("missing"), "Unknown art ID is rejected")
		actor.free()
	var cues: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest.dialogue))
	for cue in cues.cues:
		var audio: AudioStream = load(cue.audio)
		check.call(audio != null and absf(audio.get_length() - cue.duration_seconds) < 0.1 and not cue.text.is_empty(), "%s voice duration and subtitle match packaged cue" % cue.id)
	var gallery = GALLERY.instantiate()
	tree.root.add_child(gallery)
	check.call(gallery._cues.size() == 3 and gallery._voice_buttons.all(func(button): return not button.disabled), "Gallery exposes all three recorded auditions")
	gallery._actors.boss.play_action("run")
	gallery._actors.dog.play_action("run")
	gallery._motion.button_pressed = true
	check.call(gallery._actors.values().all(func(actor): return not actor.animation_player.is_playing()), "Gallery reduced motion stops both characters")
	# Dummy headless audio has no mixer; actual playback is exercised in the browser.
	gallery._active_cue = "boss_reaction"
	gallery._voice.stream = load(gallery._cues.boss_reaction.audio)
	gallery._update_subtitle()
	check.call("Boss:" in gallery._subtitle.text, "Audition subtitle uses the recorded cue's actual speaker")
	gallery._active_cue = "narrator_intro"
	gallery._update_subtitle()
	check.call("Narrator:" in gallery._subtitle.text and "Boss:" not in gallery._subtitle.text, "Replacing the active cue replaces its subtitle")
	gallery._reset()
	check.call(gallery._active_cue.is_empty() and gallery._voice.stream == null and not gallery._voice.playing, "Reset cancels voice and clears the audio stream")
	gallery.free()
	return true
