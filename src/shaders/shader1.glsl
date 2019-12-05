uniform highp sampler2D u_image;
varying highp vec2 v_texCoord;
void main(){
  gl_FragColor = texture2D(u_image, v_texCoord).rgba;
}