#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform mat4 texMatrix;

varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform float aperture;
uniform float cameraX, cameraY, cameraZ;
uniform float radius;
uniform float width;
uniform float height;

const float PI = 3.1415926535;

void main(void) {
  float theta = atan(cameraX, cameraZ);
  float phi = atan(cameraY, sqrt(cameraX*cameraX+cameraZ*cameraZ));
  float d = sqrt(cameraX*cameraX+cameraY*cameraY+cameraZ*cameraZ);
  float centerX = theta/(PI/2);
  float centerY = phi/(PI/2);
  vec2 pos = (2.0 * vertTexCoord.st - 1.0);
  float l = length(pos);
  if(l<=1.0){
    pos.s = pos.s-centerX;
    pos.t = pos.t-centerY;
    float len = length(pos);
    float phi = len*PI/2.0;
    float mag = d/(d-cos(phi));
    vec2 magCoord = vec2(pos.s*mag, pos.t*mag);
    vec2 _magCoord = vec2(0.5+0.5*magCoord.s,0.5+0.5*magCoord.t);
    gl_FragColor = texture2D(texture, _magCoord) * vertColor;
  }else{
    gl_FragColor = vec4(0, 0, 0, 1);
  }
  //x軸方向
  /*
  float theta = atan(cameraX, cameraZ);
  float phi = atan(cameraY, sqrt(cameraX*cameraX+cameraZ*cameraZ));
  float dxz = sqrt(cameraX*cameraX+cameraZ*cameraZ);
  float centerX = theta/(PI/2);
  vec2 pos = (2.0 * vertTexCoord.st - 1.0);
  float l = length(pos);
  if(l<=1.0){
    pos.s = pos.s-centerX;
    float len = length(pos);
    float phi = len*PI/2.0;
    float mag = dxz/(dxz-cos(phi));
    vec2 magCoord = vec2(pos.s*mag, pos.t*mag);
    vec2 _magCoord = vec2(0.5+0.5*magCoord.s,0.5+0.5*magCoord.t);
    gl_FragColor = texture2D(texture, _magCoord) * vertColor;
  }else{
    gl_FragColor = vec4(0, 0, 0, 1);
  }
  */
  //cameraZ = distanceと近似
  /*
  vec2 pos = (2.0 * vertTexCoord.st - 1.0);
  float l = length(pos);
  float d = cameraZ;
  if(l<=1.0){
    float phi = l*PI/2.0;
    float mag = d/(d-cos(phi));
    vec2 magCoord = vec2(pos.x*mag, pos.y*mag);
    vec2 _magCoord = vec2(0.5+0.5*magCoord.s,0.5+0.5*magCoord.t);
    gl_FragColor = texture2D(texture, _magCoord) * vertColor;
  }else{
    gl_FragColor = vec4(0, 0, 0, 1);
  }
  */
}