#version 300 es
precision highp float;

// attributes (webGL 2: 'in') recieves data from a buffer
layout(location = 0) in vec3 aPos;

// varyings (webGL 2: 'out') pass data to the fragment shader
out vec3 vPos;

// uniforms contain shared vertex data from the CPU
uniform float uTime;
uniform vec2 uAngle;

void main() {
  vPos = aPos;
  gl_Position = vec4(aPos, 1.);
}
