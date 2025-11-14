#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;

out vec3 ourColor;

void main() {
    gl_Position = vec4(aPos.x, -aPos.y, aPos.z, 1.0); // flip the value of the Y axis for the 3 vertices of the triangle.   
    ourColor = aColor;
}