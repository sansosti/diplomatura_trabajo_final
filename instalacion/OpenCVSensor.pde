import java.awt.*;
import gab.opencv.*;

abstract class OpenCVSensor extends Sensor {
  
  OpenCV opencv;
  
  int umbral = DEFAULT_UMBRAL;
    
  OpenCVSensor() {
    super();
   
    snapshot = null;
    fondo = null;    
  }
  
  void initOpenCV(PApplet theParent, int ancho, int alto) {
    opencv = new OpenCV(theParent, ancho, alto);       
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
