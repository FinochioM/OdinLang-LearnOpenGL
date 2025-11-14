package main

import gl "vendor:OpenGL"
import "vendor:glfw"
import "core:fmt"
import "core:c"
import "core:os"
import "core:strings"

PROGRAM_NAME : cstring : "Hello Triangle"
GL_MAJOR_VERSION : c.int : 3
GL_MINOR_VERSION : c.int : 3

main :: proc() {
    // Read shader files
    vertex, ok_vertex := os.read_entire_file("Exercises/hello_triangle_3/vertex.vert")
    if !ok_vertex {
        fmt.println("Could not read Vertex Shader file.")
        return
    }
    vertexShaderSource := strings.clone_to_cstring(string(vertex), context.allocator)

    fragment_orange, ok_fragment_orange := os.read_entire_file("Exercises/hello_triangle_3/fragment_orange.frag")
    if !ok_fragment_orange {
        fmt.println("Could not read Fragment Orange Shader file.")
        return
    }
    fragmentOrangeShaderSource := strings.clone_to_cstring(string(fragment_orange), context.allocator)

    fragment_yellow, ok_fragment_yellow := os.read_entire_file("Exercises/hello_triangle_3/fragment_yellow.frag")
    if !ok_fragment_yellow {
        fmt.println("Could not read Fragment Yellow Shader file.")
        return
    }
    fragmentYellowShaderSource := strings.clone_to_cstring(string(fragment_yellow), context.allocator)

    if !glfw.Init(){
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

    // SHADER
    success : i32
    infoLog : [255]u8

    vertexShader : u32 = gl.CreateShader(gl.VERTEX_SHADER)
    gl.ShaderSource(vertexShader, 1, &vertexShaderSource, nil)
    gl.CompileShader(vertexShader)

    gl.GetShaderiv(vertexShader, gl.COMPILE_STATUS, &success)
    if success == 0 {
        gl.GetShaderInfoLog(vertexShader, 255, nil, &infoLog[0])
        fmt.println("ERROR::SHADER::VERTEX::COMPILATION_FAILED ", infoLog)
        return
    }

    fragmentShaderOrange : u32 = gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(fragmentShaderOrange, 1, &fragmentOrangeShaderSource, nil)
    gl.CompileShader(fragmentShaderOrange)

    gl.GetShaderiv(fragmentShaderOrange, gl.COMPILE_STATUS, &success)
    if success == 0 {
        gl.GetShaderInfoLog(fragmentShaderOrange, 255, nil, &infoLog[0])
        fmt.println("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED ", infoLog)
        return
    }

    fragmentShaderYellow : u32 = gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(fragmentShaderYellow, 1, &fragmentYellowShaderSource, nil)
    gl.CompileShader(fragmentShaderYellow)

    gl.GetShaderiv(fragmentShaderYellow, gl.COMPILE_STATUS, &success)
    if success == 0 {
        gl.GetShaderInfoLog(fragmentShaderYellow, 255, nil, &infoLog[0])
        fmt.println("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED ", infoLog)
        return
    }

    shaderProgramOrange : u32 = gl.CreateProgram()
    gl.AttachShader(shaderProgramOrange, vertexShader)
    gl.AttachShader(shaderProgramOrange, fragmentShaderOrange)
    gl.LinkProgram(shaderProgramOrange)

    gl.GetProgramiv(shaderProgramOrange, gl.LINK_STATUS, &success)
    if success == 0 {
        gl.GetProgramInfoLog(shaderProgramOrange, 255, nil, &infoLog[0])
        fmt.println("ERROR::SHADER_PROGRAM::LINKING_FAILED")
        return
    }

    shaderProgramYellow : u32 = gl.CreateProgram()
    gl.AttachShader(shaderProgramYellow, vertexShader)
    gl.AttachShader(shaderProgramYellow, fragmentShaderYellow)
    gl.LinkProgram(shaderProgramYellow)

    gl.GetProgramiv(shaderProgramYellow, gl.LINK_STATUS, &success)
    if success == 0 {
        gl.GetProgramInfoLog(shaderProgramYellow, 255, nil, &infoLog[0])
        fmt.println("ERROR::SHADER_PROGRAM::LINKING_FAILED")
        return
    }

    gl.DeleteShader(vertexShader)
    gl.DeleteShader(fragmentShaderOrange)
    gl.DeleteShader(fragmentShaderYellow)

    // VERTEX DATA

    vertices_1 := [9]f32 {
        0.2, 0.5, 0.0,
        0.5, -0.5, 0.0,
        0.2, -0.5, 0.0,
    }

    vertices_2 := [9]f32 {
        -0.2, 0.5, 0.0,
        -0.5, -0.5, 0.0,
        -0.2, -0.5, 0.0,
    }

    VBO_1, VAO_1, VBO_2, VAO_2 : u32
    gl.GenVertexArrays(1, &VAO_1)
    gl.GenBuffers(1, &VBO_1)
    gl.GenVertexArrays(1, &VAO_2)
    gl.GenBuffers(1, &VBO_2)

    // Bind for first triangle
    gl.BindVertexArray(VAO_1)

    gl.BindBuffer(gl.ARRAY_BUFFER, VBO_1)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices_1), &vertices_1, gl.STATIC_DRAW) // size_of([9]f32) -> 9 * size_of(f32) -> 9 * 4 = 36 bytes

    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    // Bind for second triangle
    gl.BindVertexArray(VAO_2)

    gl.BindBuffer(gl.ARRAY_BUFFER, VBO_2)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices_2), &vertices_2, gl.STATIC_DRAW)  // size_of([9]f32) -> 9 * size_of(f32) -> 9 * 4 = 36 bytes

    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    gl.BindBuffer(gl.ARRAY_BUFFER, 0)
    gl.BindVertexArray(0)

    defer gl.DeleteVertexArrays(1, &VAO_1)
    defer gl.DeleteBuffers(1, &VBO_1)
    defer gl.DeleteVertexArrays(2, &VAO_2)
    defer gl.DeleteBuffers(2, &VBO_2)
    defer gl.DeleteProgram(shaderProgramOrange)
    defer gl.DeleteProgram(shaderProgramYellow)

    for (!glfw.WindowShouldClose(_window)) {
        // input
        process_input(_window)

        // render
        gl.ClearColor(0.2, 0.3, 0.3, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.UseProgram(shaderProgramOrange)
        gl.BindVertexArray(VAO_1)
        gl.DrawArrays(gl.TRIANGLES, 0, 3)
        gl.UseProgram(shaderProgramYellow)
        gl.BindVertexArray(VAO_2)
        gl.DrawArrays(gl.TRIANGLES, 0, 3)

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