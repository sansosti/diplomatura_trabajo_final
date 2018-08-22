import java.awt.*;
import processing.video.*;

abstract class OpenCVSensor extends Sensor {
  
  OpenCV opencv;
  Capture cam;
  
  int umbral = DEFAULT_UMBRAL;
    
  OpenCVSensor(PApplet theParent, int ancho, int alto, int indiceCamara) {
    super();
    
    opencv = new OpenCV(theParent, ancho, alto);   
    
    snapshot = null;
    fondo = null;
    
    String[] cameras = Capture.list();
  
    if (cameras.length == 0) {
      println("No hay camaras disponibles para la captura.");
      exit();
    } else {
      println("Camaras disponibles:");
      printArray(cameras);
      cam = new Capture(theParent, cameras[indiceCamara]);
      cam.start();     
    }
    
  }
    
  boolean update() {
    if (cam.available()) {
      cam.read();
    }
    
    if (cam.width <= 0 || cam.height <= 0) {
        return false;
    };
       
    snapshot = cam;
    
    return true;
  }
   
  int ancho() {
    return opencv.width;
  }

  int alto() {
    return opencv.height;
  }
   
  void displayCustomLegend() {     
    text("Umbral (t/r para cambiar): "+ umbral,0,currentPosY+=POS_Y_STEP);
  }
  
  void keyPressed() {
    super.keyPressed();
    
    if(key == 't') {
      umbral = umbral + 10;
      if (umbral > 255) umbral = 255;
    }
    
    if(key == 'r') {
      umbral = umbral - 10;
      if (umbral < 0) umbral = 0;
    }    
  }    
}
