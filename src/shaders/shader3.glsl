uniform highp sampler2D u_image;
uniform highp vec2 u_singleStepOffset;
uniform highp float u_denoiseLevel;
varying highp vec2 v_texCoord;
void main(){
    highp float sigma = (10.0 + u_denoiseLevel * u_denoiseLevel * 7.0);
    sigma = sigma / 255.0;
    sigma = sigma / 255.0;
    mediump vec2 blurCoordinates;
    highp float sum = 0.0;
    highp float squa_sum = 0.0;
    if(u_denoiseLevel < 0.2){
        return;
    }

    const highp vec3 yuvVec = vec3(0.256789, 0.504129, 0.097906);
    const highp float offset = 0.0625;

    blurCoordinates = v_texCoord.xy + u_singleStepOffset * vec2(-${parseInt(winSize/2)}.0, -${parseInt(winSize/2)}.0);
    mediump float originy = blurCoordinates.y;

    for(int row = 0; row < ${winSize}; row++) {
        highp float tsum = 0.0;
        highp float tsqua_sum = 0.0;
        for(int col = 0; col < ${winSize}; col++) {
            highp float tex = dot(texture2D(u_image, blurCoordinates).rgb, yuvVec) + offset;
            tsum += tex;
            tsqua_sum += tex * tex;
            blurCoordinates.y += u_singleStepOffset.y;
        }
        blurCoordinates.x += u_singleStepOffset.x;
        blurCoordinates.y = originy;
        sum += tsum / ${winSize}.0;
        squa_sum += tsqua_sum / ${winSize}.0;
    }

    highp float mean = sum / ${winSize}.0;
    highp float var = squa_sum / ${winSize}.0 - mean * mean;
    highp float ratio = var / (var + sigma);

    gl_FragColor.g = ratio;
    gl_FragColor.b = mean * (1.0 - ratio);
}