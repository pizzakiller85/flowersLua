function love.conf(t)
    t.identity = "FlowerAnimation"
    t.version = "11.4"
    
    t.window.title = "Flower in the Wind"
    t.window.icon = nil
    t.window.width = 1600
    t.window.height = 600
    t.window.minwidth = 1600
    t.window.minheight = 600
    t.window.resizable = true
    t.window.fullscreen = true
    t.window.fullscreentype = "desktop"
    t.window.vsync = true
    t.window.msaa = 0
    t.window.depth = nil
    t.window.stencil = nil
    t.window.display = 1
    t.window.highdpi = false
    t.window.usedpiscale = true
    t.window.x = nil
    t.window.y = nil
    
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true
end


