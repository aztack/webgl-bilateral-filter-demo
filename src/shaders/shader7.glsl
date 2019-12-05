uniform sampler2D u_image;
uniform mediump vec2 u_singleStepOffset;
uniform highp float u_denoiseLevel;
varying mediump vec2 v_texCoord;
void main() {
    mediump vec2 blurCoordinates;
    highp float sum_a = 0.0;
    highp float sum_b = 0.0;
    if(u_denoiseLevel < 0.2){
        return;
    }
    blurCoordinates.y = v_texCoord.y + u_singleStepOffset.y *  (-${parseInt(winSize/2)}.0);
    blurCoordinates.x = v_texCoord.x;
    highp float tsum_a = 0.0;
    highp float tsum_b = 0.0;
    for(int col = 0; col < ${winSize}; col++) {
        highp vec2 tex = texture2D(u_image, blurCoordinates).gb;
        tsum_a += tex.x;
        tsum_b += tex.y;
        blurCoordinates.y += u_singleStepOffset.y;
    }
    gl_FragColor.g = tsum_a / ${winSize}.0;
    gl_FragColor.b = tsum_b / ${winSize}.0;
}