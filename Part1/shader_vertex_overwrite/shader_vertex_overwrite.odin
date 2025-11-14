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
    vertex, ok_vertex := os.read_entire_file("Part1/shader_vertex_overwrite/vertex.vert")
    if !ok_vertex {
        fmt.println("Could not read Vertex Shader file.")
        return
    }
    vertexShaderSource := strings.clone_to_cstring(string(vertex), context.allocator)

    fragment, ok_fragment := os.read_entire_file("Part1/shader_vertex_overwrite/fragment.frag")
    if !ok_fragment {
        fmt.println("Could not read Fragment Shader file.")
        return
    }
    fragmentShaderSource := strings.clone_to_cstring(string(fragment), context.allocator)

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

    fragmentShader : u32 = gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(fragmentShader, 1, &fragmentShaderSource, nil)
    gl.CompileShader(fragmentShader)

    gl.GetShaderiv(fragmentShader,gl.COMPILE_STATUS, &success)
    if success == 0 {
        gl.GetShaderInfoLog(fragmentShader, 255, nil, &infoLog[0])
        fmt.println("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED ", infoLog)
        return
    }

    shaderProgram : u32 = gl.CreateProgram();
    gl.AttachShader(shaderProgram, vertexShader)
    gl.AttachShader(shaderProgram, fragmentShader)
    gl.LinkProgram(shaderProgram)

    gl.GetProgramiv(shaderProgram, gl.LINK_STATUS, &success)
    if success == 0 {
        gl.GetProgramInfoLog(shaderProgram, 255, nil, &infoLog[0])
        fmt.println("ERROR::SHADER_PROGRAM::LINKING_FAILED")
        return
    }

    gl.DeleteShader(vertexShader)
    gl.DeleteShader(fragmentShader)

    // VERTEX DATA

    vertices := [12]f32 {
        0.5, 0.5, 0.0, // top right - 0
        0.5, -0.5, 0.0, // bot right - 1
        -0.5, -0.5, 0.0, // bot left - 2
        -0.5, 0.5, 0.0, // top left - 3
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
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW) // size_of([12]f32) -> 12 * size_of(f32) -> 12 * 4 = 48 bytes

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indices), &indices, gl.STATIC_DRAW) // size_of([4]f32) -> 4 * size_of(f32) -> 4 * 4 = 16 bytes

    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    gl.BindBuffer(gl.ARRAY_BUFFER, 0)

    gl.BindVertexArray(0)

    defer gl.DeleteVertexArrays(1, &VAO)
    defer gl.DeleteBuffers(1, &VBO)
    defer gl.DeleteBuffers(1, &EBO)
    defer gl.DeleteProgram(shaderProgram)

    for (!glfw.WindowShouldClose(_window)) {
        // input
        process_input(_window)

        // render
        gl.ClearColor(0.2, 0.3, 0.3, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.UseProgram(shaderProgram)
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