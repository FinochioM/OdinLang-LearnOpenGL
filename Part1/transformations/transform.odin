package main

import "core:c"
import ln "core:math/linalg"
import "core:math"

translate :: proc(m: ln.Matrix4x4f32, v: ln.Vector3f32) -> ln.Matrix4x4f32 {
    t := ln.Matrix4x4f32(1.0) // identity
    t[3][0] = v.x
    t[3][1] = v.y
    t[3][2] = v.z
    return m * t
}

rotate :: proc(m: ln.Matrix4x4f32, angle: f32, axis: ln.Vector3f32) -> ln.Matrix4x4f32 {
    a := ln.normalize(axis)
    c := math.cos(angle)
    s := math.sin(angle)
    oc := 1 - c

    r := ln.Matrix4x4f32(1.0)

    r[0][0] = c + a.x*a.x*oc
    r[0][1] = a.x*a.y*oc - a.z*s
    r[0][2] = a.x*a.z*oc + a.y*s

    r[1][0] = a.y*a.x*oc + a.z*s
    r[1][1] = c + a.y*a.y*oc
    r[1][2] = a.y*a.z*oc - a.x*s

    r[2][0] = a.z*a.x*oc - a.y*s
    r[2][1] = a.z*a.y*oc + a.x*s
    r[2][2] = c + a.z*a.z*oc

    return m * r
}

value_ptr :: proc(m: ^ln.Matrix4x4f32) -> ^f32 {
    return transmute(^f32)m
}