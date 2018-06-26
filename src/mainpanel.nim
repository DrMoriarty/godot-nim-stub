# Copyright 2017 Xored Software, Inc.

import godot
import scene_tree, resource_loader, packed_scene, panel, global_constants,
       input_event_mouse_button

gdobj MainPanel of Panel:
  method ready*() =
    print("Main panel is ready")
    setProcessInput(true)

  method input*(event: InputEvent) =
    print("Main panel have input")
    if event of InputEventMouseButton:
      print("Main panel have mouse pressed")
      let ev = event as InputEventMouseButton
      if ev.buttonIndex == BUTTON_LEFT:
        print("Main panel have left mouse button pressed")
        getTree().setInputAsHandled()
        let scene = load("res://scene.tscn") as PackedScene
        getTree().root.addChild(scene.instance())
        queueFree()
        print("We are changed the scene")
        setProcessInput(false)
