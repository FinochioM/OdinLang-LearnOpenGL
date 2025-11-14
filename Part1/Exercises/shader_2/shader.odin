package main

import gl "vendor:OpenGL"
import "core:strings"
import "core:fmt"
import "core:os"
import "core:c"

Shader :: struct {
    ID : u32,
}

LoadShader :: proc(vertexPath: string, fragmentPath: string) -> Shader {
    success : i32
    infoLog : [255]u8

    // Reading files
    vertex_bytes, ok_vertex := os.read_entire_file(vertexPath)

    if !ok_vertex {
        fmt.println("ERROR::SHADER::READING::Could not read the Vertex Shader file.")
        return Shader{}
    }
    vertexShaderSource := strings.clone_to_cstring(string(vertex_bytes), context.allocator)

    fragment_bytes, ok_fragment := os.read_entire_file(fragmentPath)

    if !ok_fragment {
        fmt.println("ERROR::SHADER::READING::Could not read the Fragment Shader file.")
        return Shader{}
    }
    fragmentShaderSource := strings.clone_to_cstring(string(fragment_bytes), context.allocator)

    // Compilation
    vertexShader : u32 = gl.CreateShader(gl.VERTEX_SHADER)
    gl.ShaderSource(vertexShader, 1, &vertexShaderSource, nil)
    gl.CompileShader(vertexShader)

    gl.GetShaderiv(vertexShader, gl.COMPILE_STATUS, &success)
    if success == 0 {
        gl.GetShaderInfoLog(vertexShader, 255, nil, &infoLog[0])
        fmt.println("ERROR::SHADER::VERTEX::COMPILATION_FAILED ", infoLog)
        gl.DeleteShader(vertexShader)
        return Shader{}
    }

    fragmentShader : u32 = gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(fragmentShader, 1, &fragmentShaderSource, nil)
    gl.CompileShader(fragmentShader)

    gl.GetShaderiv(fragmentShader, gl.COMPILE_STATUS, &success)
    if success == 0 {
        gl.GetShaderInfoLog(fragmentShader, 255, nil, &infoLog[0])
        fmt.println("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED ", infoLog)
        gl.DeleteShader(vertexShader)
        gl.DeleteShader(fragmentShader)
        return Shader{}
    }

    shaderProgram : u32 = gl.CreateProgram();
    gl.AttachShader(shaderProgram, vertexShader)
    gl.AttachShader(shaderProgram, fragmentShader)
    gl.LinkProgram(shaderProgram)

    gl.GetProgramiv(shaderProgram, gl.LINK_STATUS, &success)
    if success == 0 {
        gl.GetProgramInfoLog(shaderProgram, 255, nil, &infoLog[0])
        fmt.println("ERROR::SHADER_PROGRAM::LINKING_FAILED", infoLog)
        gl.DeleteShader(vertexShader)
        gl.DeleteShader(fragmentShader)
        gl.DeleteProgram(shaderProgram)
        return Shader{}
    }

    gl.DeleteShader(vertexShader)
    gl.DeleteShader(fragmentShader)

    free(cast(rawptr)vertexShaderSource, context.allocator)
    free(cast(rawptr)fragmentShaderSource, context.allocator)

    return Shader{ID = shaderProgram}
}

UseProgram :: proc(sh: Shader) {
    gl.UseProgram(sh.ID)
}

Destroy :: proc (sh: Shader) {
    gl.DeleteProgram(sh.ID)
}

SetBool :: proc(sh: Shader, name: string, value: bool) {
    cname := strings.clone_to_cstring(name, context.allocator)
    loc := gl.GetUniformLocation(sh.ID, cname)
    gl.Uniform1i(loc, i32(value))
}

SetFloat :: proc(sh: Shader, name: string, value: f32) {
    cname := strings.clone_to_cstring(name, context.allocator)
    loc := gl.GetUniformLocation(sh.ID, cname)
    gl.Uniform1f(loc, value)
}

SetInt :: proc(sh: Shader, name: string, value: i32) {
    cname := strings.clone_to_cstring(name, context.allocator)
    loc := gl.GetUniformLocation(sh.ID, cname)
    gl.Uniform1i(loc, value)
}