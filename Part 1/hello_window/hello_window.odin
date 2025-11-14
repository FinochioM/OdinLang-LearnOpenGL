package main

import gl "vendor:OpenGL"
import "vendor:glfw"
import "core:fmt"
import "core:c"

PROGRAM_NAME : cstring : "Hello Window"
GL_MAJOR_VERSION : c.int : 3
GL_MINOR_VERSION : c.int : 3

main :: proc() {
    if glfw.Init() != glfw.TRUE {
        fmt.println("Failed to initialize GLFW.")
        return
    }

    defer glfw.Terminate()

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    _window := glfw.CreateWindow(800, 600, PROGRAM_NAME, nil, nil)

    defer glfw.DestroyWindow(_window)

    if _window == nil {
        // We do not terminate the window here because we return, so the program exits the scope of "main" and it automatically runs the defer DestroyWindow.
        fmt.println("Failed to create GLFW window.")
        return
    }

    glfw.MakeContextCurrent(_window)

    glfw.SetFramebufferSizeCallback(_window, size_callback)

    gl.load_up_to(int(GL_MAJOR_VERSION), int(GL_MINOR_VERSION), glfw.gl_set_proc_address)

    for (!glfw.WindowShouldClose(_window)) {
        // input
        process_input(_window)

        // render
        gl.ClearColor(0.2, 0.3, 0.3, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        glfw.PollEvents()
        glfw.SwapBuffers((_window))
    }
}

process_input :: proc(window: glfw.WindowHandle) {
    if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
        glfw.SetWindowShouldClose(window, true)
    }
}

size_callback :: proc "c"(window: glfw.WindowHandle, width, height: i32) {
    gl.Viewport(0, 0, width, height)
}