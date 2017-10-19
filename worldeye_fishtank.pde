PMatrix3D projection, modelview, modelviewInv, camera, cameraInv, projmodelview,m;

float theta, phi;
float cameraX, cameraY, cameraZ;

PShape obj;
PShader point_shader, lineShader, fisheyeShader, fisheyeShader_2, fisheyePsShader, antiFisheyeShader;
PGraphics canvas;
PGraphics output;
PImage img;

boolean useFishEye = true;

void setup() {
  size(640, 480, P3D);
  //fullScreen(P3D,2);
  obj = loadShape("../data/objFiles/obama_face.obj");
  obj.scale(2);
  canvas = createGraphics(width-160, height, P3D);
  output = createGraphics(width-160, height, P2D);
  // プロジェクション行列
  projection = ((PGraphicsOpenGL)g).projection.get();
  // モデルビュー行列
  modelview = ((PGraphicsOpenGL)g).modelview.get();
  // モデルビュー行列の逆行列
  modelviewInv = ((PGraphicsOpenGL)g).modelviewInv.get();
  // ビュー行列
  camera = ((PGraphicsOpenGL)g).camera.get();
  // ビュー行列の逆行列
  cameraInv = ((PGraphicsOpenGL)g).cameraInv.get();
  // プロジェクション行列とモデルビュー行列を乗算した行列
  projmodelview = ((PGraphicsOpenGL)g).projmodelview.get();

  camera.print();
  modelview.print();
  projection.print();
  projmodelview.print();
  
  m = new PMatrix3D(
    1.0,0.0,0.0,0.0,
    0.0,1.0,0.0,0.0,
    0.0,0.0,1.0,0.0,
    0.0,0.0,0.0,1.0
  );
  
  //シェーダの設定
  point_shader = loadShader("fragment.glsl","convert.glsl");
  point_shader.set("MVP",m);
  lineShader = loadShader("linefrag.glsl", "linevert.glsl");
  
  fisheyeShader = loadShader("fisheye.glsl");
  fisheyeShader.set("aperture", 180.0);
  
  fisheyeShader_2 = loadShader("fisheye_2.glsl");
  fisheyeShader_2.set("aperture", 180.0);
  fisheyeShader_2.set("width",(float)canvas.width);
  fisheyeShader_2.set("height",(float)canvas.height);
  fisheyeShader_2.set("radius",(float)canvas.height/2);
  
  fisheyePsShader = loadShader("fisheye_ps.glsl");
  antiFisheyeShader = loadShader("anti_fisheye_fragment.glsl","anti_fisheye_vertex.glsl");
}

void draw() {
  /*draw3d model*/
  canvas.beginDraw();
  canvas.noStroke();
  canvas.background(0);
  canvas.lights();
  
  m = new PMatrix3D(
    1.0,0.0,0.0,0.0,
    0.0,1.0,0.0,0.0,
    0.0,0.0,1.0,0.0,
    0.0,0.0,0.0,1.0
  );
  point_shader.set("MVP",m);
  //canvas.shader(point_shader, POINTS);
  //canvas.shader(lineShader, LINES);
  float cameraX = canvas.width/2.00 * 1.0; //360
  float cameraY = canvas.height/2.00 * 1.0; //240
  float cameraZ = (canvas.height/2)*3.0;
  fisheyeShader_2.set("cameraX", (cameraX-canvas.width/2.0)/(canvas.height/2.0));
  fisheyeShader_2.set("cameraY", (canvas.height/2.0-cameraY)/(canvas.height/2.0));
  fisheyeShader_2.set("cameraZ", (cameraZ/(canvas.height/2.0)));
  float distance = sqrt(sq((cameraX-width/2))+sq(cameraY-height/2)+sq(cameraZ));
  float fov = 2 * atan(height/(2*distance));
  float aspect = float(canvas.width)/float(canvas.height);
  if (cameraZ>0) {
    theta = atan((cameraX-width/2)/cameraZ);
  } else if (cameraZ<0) {
    theta = atan((cameraX-width/2)/cameraZ) + PI;
  } else {
    if (cameraX-width/2>0) {
      theta = PI/2;
    } else {
      theta = -PI/2;
    }
  }
  //カメラ位置の設定
  canvas.camera(cameraX, cameraY, cameraZ, canvas.width/2, height/2, 0, 0.0, 1.0, 0.0);
  canvas.perspective(fov,aspect,height/10,height*10);
  
  canvas.pushMatrix();
  canvas.translate(canvas.width/2, canvas.height/2, 0);
  canvas.pushMatrix();
  //canvas.rotateY(frameCount * 0.01);
  //canvas.rotateX(3.14);
  canvas.pointLight(204, 204, 204, 1000, 1000, 1000);
  canvas.translate(0,-75,0);
  //モデルの描画
  canvas.shape(obj);
  canvas.popMatrix();
  //球体の設置
  canvas.fill(255,0,0);
  canvas.sphere(50);
  canvas.pushMatrix();
  canvas.translate(-200, 0, 0);
  canvas.fill(0,255,0);
  canvas.sphere(50);
  canvas.popMatrix();
  canvas.pushMatrix();
  canvas.translate(200, 0, 0);
  canvas.fill(0,0,255);
  canvas.sphere(50);
  canvas.popMatrix();
  canvas.pushMatrix();
  canvas.translate(0, 200, 0);
  canvas.fill(255,255,0);
  canvas.sphere(50);
  canvas.popMatrix();
  canvas.pushMatrix();
  canvas.translate(0, -200, 0);
  canvas.fill(0,255,255);
  canvas.sphere(50);
  canvas.popMatrix();
  canvas.pushMatrix();
  canvas.translate(0, 0, 200);
  canvas.fill(255,0,255);
  canvas.sphere(50);
  canvas.popMatrix();
  canvas.pushMatrix();
  canvas.translate(0, 0, -200);
  canvas.fill(255,255,255);
  canvas.sphere(50);
  canvas.popMatrix();
  /*
  for (int i=0; i<=4; i++) {
    canvas.pushMatrix();
    canvas.translate(120*(i-2), 0, 0);
    canvas.fill(i*60,255,255);
    canvas.sphere(2);
    canvas.popMatrix();
  }
  
  float ang = acos(1/sqrt(3));
  canvas.pushMatrix();
  canvas.translate(240*sin(ang), 0, 240*cos(ang));
  canvas.fill(255,255,255);
  canvas.sphere(5);
  canvas.popMatrix();
  
  for (int j=0; j<=4; j++) {
    canvas.pushMatrix();
    canvas.translate(0,120*(j-2), 0);
    canvas.fill(255,j*60,255);
    canvas.sphere(2);
    canvas.popMatrix();
  }
  for (int k=0; k<=4; k++) {
    canvas.pushMatrix();
    //canvas.stroke(127*i, 127*j, 127*k);
    canvas.translate(0, 0, 120*(k-2));
    canvas.fill(255,255,60*k);
    canvas.sphere(2);
    canvas.popMatrix();
  }
  */
  //格子の描画
  int lineNum = 8;
  for(int i=1;i<lineNum;i++){
    float x=60*i-height/2;
    float y=sqrt(240*240-x*x);
    canvas.strokeWeight(2);
    canvas.stroke(255,0,0);
    canvas.line(0,x,-240,0,x,240);
    canvas.line(0,-240,x,0,240,x);
    canvas.stroke(0,255,0);
    canvas.line(x,0,-240,x,0,240);
    canvas.line(-240,0,x,240,0,x);
    canvas.stroke(0,0,255);
    canvas.line(x,-240,0,x,240,0);
    canvas.line(-240,x,0,240,x,0);
  }
  /*
  //xyz=0平面上に円の描画
  pushMatrix();
  canvas.blendMode(ADD);
  canvas.fill(200,0,0,200);
  canvas.ellipse(0,0,480,480);
  popMatrix();
  pushMatrix();
  canvas.rotateY(HALF_PI);
  canvas.fill(0,200,0,200);
  canvas.ellipse(0,0,480,480);
  popMatrix();
  pushMatrix();
  canvas.rotateX(HALF_PI);
  canvas.fill(0,0,200,200);
  canvas.ellipse(0,0,480,480);
  popMatrix();
  */
  canvas.popMatrix();
  canvas.endDraw();
  
  //PVector test = deformation(new PVector(320,240),new PVector(cameraX,cameraY,cameraZ));
  //println(test.x+","+test.y);
  if(useFishEye){
    shader(fisheyeShader_2);
  }
  /*
  output.beginDraw();
  output.image(canvas,0,0,width-160,height);
  output.endDraw();
  */
  //shader(antiFisheyeShader);
  //output.beginDraw();
  //output.image(canvas,0,0,width,height);
  //output.endDraw();
  background(0);
  image(canvas,80,0,width-160,height);
  //image(output, 0, 0, width, height);
  
  /*
  for(int i=width/2;i<width;i++){
    for(int j=0;j<height;j++){
      PVector coordinate = deformation(new PVector(i,j),new PVector(cameraX,cameraY,cameraZ));
      set((int)coordinate.x,(int)coordinate.y,get(i,j));
    }
  }
  for(int i=width/2;i>=0;i--){
    for(int j=0;j<height;j++){
      PVector coordinate = deformation(new PVector(i,j),new PVector(cameraX,cameraY,cameraZ));
      set((int)coordinate.x,(int)coordinate.y,get(i,j));
    }
  }
  */
  //output.endDraw();
  //image(output, 0, 0, width, height);
  
  noFill();
  stroke(255);
  //ellipse(width/2,height/2,240,240);
  ellipse(width/2,height/2,480,480);
}

void mousePressed() {
  if (useFishEye) {
    useFishEye = false;
    resetShader();
  } else {
    useFishEye = true;
  }
}


PVector deformation(PVector coord, PVector eye_pos){
  if(coord.x==width/2){
    return coord;
  } 
  float distance = eye_pos.z;
  PVector coord_centered = new PVector(coord.x-width/2,coord.y-height/2);
  float A = sq(distance/coord_centered.x)+1;
  float B = -2.0*sq(distance)/coord_centered.x;
  float C = sq(distance)-sq(height/2);
  float crossx;
  if(coord_centered.x>0){
    crossx = (-B-sqrt(sq(B)-4.0*A*C))/(2.0*A);
  }else{
    crossx = (-B+sqrt(sq(B)-4.0*A*C))/(2.0*A);
  }
  float crossz = distance-distance*crossx/coord_centered.x;
  float the = atan(crossx/crossz);
  return new PVector(the/(PI/2)*(height/2)+width/2,coord.y);
}