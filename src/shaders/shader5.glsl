uniform sampler2D u_image;
uniform sampler2D u_originImage;
uniform highp float u_denoiseLevel;
varying mediump vec2 v_texCoord;
uniform sampler2D lighten_lut;

uniform mediump float skin_he_max;
uniform mediump float skin_he_min;
uniform mediump float skin_hc_max;
uniform mediump float skin_hc_min;
uniform mediump float skin_hc_axis;
uniform mediump float facts_rotate_c;
uniform mediump float facts_rotate_le;
uniform mediump float facts_rotate_ge;

uniform mediump float light;
uniform mediump float redness;
const mediump float threshold1 = 0.30196; //77.0/255.0;
const mediump float threshold2 = 0.49804; //127.0/255.0;
const mediump float threshold3 = 0.52157; //133.0/255.0;
const mediump float threshold4 = 0.67843; //173.0/255.0;
const highp float gfskin_he_max = 2.42601;//139.0/180*3.141593;
const highp float gfskin_he_min = 1.65806;//95.0/180*3.141593;
const highp float gfskin_hc_max = 2.35619;//135.0/180*3.141593;
const highp float gfskin_hc_min = 1.83260;//105.0/180*3.141593;
const highp float gfskin_hc_axis = 2.09440;//120.0/180*3.141593;

void main(){
  highp float gamma = u_denoiseLevel / 10.0;

  highp vec2 mean_gf = texture2D(u_image, v_texCoord).gb;

  const highp mat3 yuvMat = mat3(0.256789, 0.504129, 0.097906,
                           -0.148223, -0.290992, 0.439215,
                           0.439215, -0.367789, -0.071426);
  const highp mat3 rgbMat = mat3(1.164383,  0.000000,  1.596027,
                            1.164383, -0.391762, -0.812968,
                            1.164383,  2.017232,  0.000000);
  const highp vec3 offset = vec3(0.0625, 0.500, 0.500);

  highp vec3 yuv = texture2D(u_originImage, v_texCoord).rgb * yuvMat + offset;

  mediump float a = 0.8;
  mediump vec2 lutCoordinate;

  highp float originY = yuv.x;
  highp float originU = yuv.y;
  highp float originV = yuv.z;

  //if(originU < 0.5 && originV > 0.5 && (redness > 0.05 || gamma > 0.02))
  if(originU < 0.50 && originU >= 0.30 && originV > 0.52 && originV < 0.68)
  //if(originU <= 0.53 && originU >= 0.33 && originV >= 0.53 && originV <= 0.66 && (redness > 0.05 || gamma > 0.02))
  {
    highp float i_utmp = 0.5 - originU;
    highp float i_vtmp = originV - 0.5;

    highp float i_uhued;
    highp float i_vhued;
    highp float i_oriangle;
    highp float i_rotangle;
    highp float i_tempsin;
    highp float i_tempcos;
    int en_hue = 1;
    int rotate_type = 0;

    mediump float op_skin = 1.0;

    if (i_vtmp <= i_utmp)
      i_oriangle = 3.141593 - atan(i_vtmp / i_utmp);
    else
      i_oriangle = 3.141593 / 2.0 + atan(i_utmp / i_vtmp);

    if(redness > 0.05) {
      if((i_oriangle < skin_he_max) && (i_oriangle > skin_he_min)) {
        if (i_oriangle < skin_hc_axis) {
          if(i_oriangle >= skin_hc_min) {
            rotate_type = 1;
            i_rotangle = (skin_hc_axis - i_oriangle) * (facts_rotate_c * op_skin);
            a = 0.8;
          } else {
            rotate_type = 1;
            i_rotangle = (i_oriangle - skin_he_min) * (facts_rotate_le * op_skin);
            a = (i_oriangle - skin_he_min) / (skin_hc_min - skin_he_min) * 0.8;
          }
        } else {
          if (i_oriangle <= skin_hc_max) {
            rotate_type = 2;
            i_rotangle = (i_oriangle - skin_hc_axis) * (facts_rotate_c * op_skin);
            a = 0.8;
          } else {
            rotate_type = 2;
            i_rotangle = (skin_he_max - i_oriangle) * (facts_rotate_ge * op_skin);
            a = (skin_he_max - i_oriangle) / (skin_he_max - skin_hc_max) * 0.8;
          }
        }
        if (rotate_type > 0 && i_rotangle > 0.01) {
          i_tempsin = sin(i_rotangle);
          i_tempcos = cos(i_rotangle);
          i_utmp = -i_utmp;
          //counter clockwise rotation
          if (rotate_type == 1) {
            i_uhued = i_utmp * i_tempcos - i_vtmp * i_tempsin + 0.5;
            i_vhued = i_utmp * i_tempsin + i_vtmp * i_tempcos + 0.5;
          }
          else { //clockwise rotation
            i_uhued = i_utmp * i_tempcos + i_vtmp * i_tempsin + 0.5;
            i_vhued = i_vtmp * i_tempcos - i_utmp * i_tempsin+0.5;
          }

          yuv.y = clamp(i_uhued, 0.0, 1.0);
          yuv.z = clamp(i_vhued, 0.0, 1.0);
        }

      }
    }

    //smooth merge
    if((i_oriangle < gfskin_he_max) && (i_oriangle > gfskin_he_min) && gamma > 0.02) {
      a = 0.8 * gamma;
      mediump float a1 = 0.8 * gamma;
      if(gamma < 0.6)
        a1 = 0.8;
      else
        a1 = 0.95;

      if (i_oriangle < gfskin_hc_axis) {
        if(i_oriangle >= gfskin_hc_min) {
          a = 0.8 * a1;
        } else {
          a = (i_oriangle - gfskin_he_min) / (gfskin_hc_min - gfskin_he_min) * 0.8 * a1;
        }
      } else {
        if (i_oriangle <= gfskin_hc_max) {
          a = 0.8 * a1;
        } else {
          a = (gfskin_he_max - i_oriangle) / (gfskin_he_max - gfskin_hc_max) * 0.8 * a1;
        }
      }
      if(originY < 0.375)
        a = a * 0.3;

      yuv.x = originY * mean_gf.x + mean_gf.y;
      yuv.x = mix(originY, yuv.x, a);
    }
  }

  lutCoordinate = vec2(yuv.x, 0.0);

  yuv.x = mix(yuv.x, texture2D(lighten_lut, lutCoordinate).r, light);
  yuv.x = clamp(yuv.x, 0.0, 1.0);

  if(light > 0.6){
    yuv.y = clamp(yuv.y + (light - 0.6) * 0.118, 0.0, 1.0);
    yuv.z = clamp(yuv.z - (light - 0.6) * 0.059, 0.0, 1.0);
  }

  gl_FragColor = vec4((yuv - offset) * rgbMat, 1.0);
}