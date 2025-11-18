package main

import gl "vendor:OpenGL"
import "vendor:glfw"
import stb "vendor:stb/image"
import "core:fmt"
import "core:c"

PROGRAM_NAME : cstring : "Hello Triangle"
GL_MAJOR_VERSION : c.int : 3
GL_MINOR_VERSION : c.int : 3

main :: proc() {
    if !glfw.Init() {
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

    // Shader Class
    shaderID : Shader = LoadShader("Part1/Exercises/textures_3/vertex.vert", "Part1/Exercises/textures_3/fragment.frag")

    // VERTEX DATA

    // values around the middle, built a new rectangle from the texture coordinates, so it draws the texture with those new coordinates inside the rectangle.
    vertices := [32]f32 {
        0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 0.65, 1.0, // top right - 0
        0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 0.65, 0.0, // bot right - 1
        -0.5, -0.5, 0.0, 0.0, 0.0, 1.0, 0.45, 0.0, // bot left - 2
        -0.5, 0.5, 0.0, 1.0, 1.0, 0.0, 0.45, 1.0, // top left - 3
    }

    indices := [6]i32 {
        0, 1, 3,
        1, 2, 3
    }

    
    VBO, VAO, EBO : u32
    gl.GenVertexArrays(1, &VAO)
    gl.GenBuffers(1, &VBO)
    gl.GenBuffers(1, &EBO)

    gl.BindVertexArray(VAO)

    gl.BindBuffer(gl.ARRAY_BUFFER, VBO)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indices), &indices, gl.STATIC_DRAW)

    // position data the frist 3 indices of the array.
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 3 * size_of(f32))
    gl.EnableVertexAttribArray(1)

    gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, 8 * size_of(f32), 6 * size_of(f32))
    gl.EnableVertexAttribArray(2)

    gl.BindBuffer(gl.ARRAY_BUFFER, 0)

    gl.BindVertexArray(0)

    defer gl.DeleteVertexArrays(1, &VAO)
    defer gl.DeleteBuffers(1, &VBO)
    defer Destroy(shaderID)

    texture1, texture2 : u32

    // Texture 1 loading    
    gl.GenTextures(1, &texture1)
    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, texture1)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

    width1, height1, nrChannels1 : i32
    stb.set_flip_vertically_on_load(1)
    data1 := stb.load("Part1/Exercises/textures_3/brick.jpg", &width1, &height1, &nrChannels1, 0)

    if data1 != nil {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width1, height1, 0, gl.RGB, gl.UNSIGNED_BYTE, data1)
        gl.GenerateMipmap(gl.TEXTURE_2D)
    } else {
        fmt.println("ERROR::TEXTURE::LOADING::Could not load the texture.")
        return
    }
    stb.image_free(data1)

    // Texture 2 loading
    gl.GenTextures(1, &texture2)
    gl.ActiveTexture(gl.TEXTURE1)
    gl.BindTexture(gl.TEXTURE_2D, texture2)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

    width2, height2, nrChannels2 : i32
    stb.set_flip_vertically_on_load(1)
    data2 := stb.load("Part1/Exercises/textures_3/background.png", &width2, &height2, &nrChannels2, 0)

    if data2 != nil {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width2, height2, 0, gl.RGBA, gl.UNSIGNED_BYTE, data2)
        gl.GenerateMipmap(gl.TEXTURE_2D)
    } else {
        fmt.println("ERROR::TEXTURE::LOADING::Could not load the texture.")
        return
    }

    stb.image_free(data2)


    UseProgram(shaderID)
    SetInt(shaderID, "texture1", 0)
    SetInt(shaderID, "texture2", 1)

    for (!glfw.WindowShouldClose(_window)) {
        // input
        process_input(_window)

        // render
        gl.ClearColor(0.2, 0.3, 0.3, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        UseProgram(shaderID)
        
        gl.ActiveTexture(gl.TEXTURE0)
        gl.BindTexture(gl.TEXTURE_2D, texture1)
        gl.ActiveTexture(gl.TEXTURE1)
        gl.BindTexture(gl.TEXTURE_2D, texture2)

        gl.BindVertexArray(VAO)
        gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)

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