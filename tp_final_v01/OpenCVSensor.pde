import java.awt.*;

abstract class OpenCVSensor extends Sensor {
  
  OpenCV opencv;
  
  int umbral = DEFAULT_UMBRAL;
    
  OpenCVSensor(PApplet theParent, int ancho, int alto) {
    super();
    
    opencv = new OpenCV(theParent, ancho, alto);   
    
    snapshot = null;
    fondo = null;    
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
