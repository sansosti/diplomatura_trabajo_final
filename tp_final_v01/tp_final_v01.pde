//import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import processing.sound.*;

final int ALTO = 360;
final int ANCHO = 640;
final int DEFAULT_UMBRAL = 80;

final int MARGEN = 10;
final int POS_Y_STEP = 15;

UserFeedback uf;

Capture cam;
OpenCVSensorBackgroundSustraction sBGSus;
OpenCVSensorGrayDiff sGrayDiff;

PImage fondo;

/*
void settings() {
  size((ANCHO+MARGEN)*4, (ALTO+MARGEN)*4);
}
*/

void setup() {
  fullScreen();
  
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("No hay camaras disponibles para la captura.");
    exit();
  } else {
    println("Camaras disponibles:");
    printArray(cameras);
    //noLoop();  
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[18]);
    //cam = new Capture(this, cameras[3]);
    cam.start();     
  }     
  
  sBGSus = new OpenCVSensorBackgroundSustraction(this, ANCHO, ALTO);
  
  sGrayDiff = new OpenCVSensorGrayDiff(this, ANCHO, ALTO);
 
  uf = new UserFeedback(this, sGrayDiff);
}

void captureEvent(Capture cam) {
  cam.read();
}

void draw() {
  background(0,0,0);

  cam.filter(GRAY);
  
  sBGSus.update(cam);
  sGrayDiff.update(cam);  
  uf.update();
  
  image(cam, 0, 0);
  if(cam.width <= 0 || cam.height <= 0) {
    return;
  }
  
  fondo = sGrayDiff.getFondo();
  
  if (fondo != null) {
    image(fondo,cam.width + MARGEN,0);
  } 
 
  
  pushMatrix(); 
  translate(0,cam.height + MARGEN);
  //sBGSus.display();
  uf.display();
  popMatrix();
  
  pushMatrix(); 
  translate(cam.width + MARGEN, cam.height + MARGEN);
  sGrayDiff.display();
  popMatrix();          
 
}

void keyPressed(){
    sBGSus.keyPressed();
    sGrayDiff.keyPressed();
}  
