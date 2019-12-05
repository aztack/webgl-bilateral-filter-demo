attribute vec2 a_position;
attribute vec2 a_texCoord;

uniform float u_flipY;

varying vec2 v_texCoord;

void main() {
   vec2 zeroToTwo = a_position * 2.0;
   vec2 clipSpace = zeroToTwo - 1.0;

   gl_Position = vec4(clipSpace * vec2(1, u_flipY), 0, 1);
   v_texCoord = a_texCoord;
}