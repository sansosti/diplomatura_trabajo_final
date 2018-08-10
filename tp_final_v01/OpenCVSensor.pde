abstract class OpenCVSensor {
  
  final int POS_Y_INICIAL = 5;
  
  OpenCV opencv;
  ArrayList<Contour> contours; 
  
  int umbral = DEFAULT_UMBRAL;
  
  int currentPosY;
  
  abstract String getNombre();
  abstract void displayCustomLegend();

 
  OpenCVSensor(PApplet theParent, int ancho, int alto) {
    opencv = new OpenCV(theParent, ancho, alto);    
  }
    
  boolean update(PImage img) {
    return (cam.width > 0 && cam.height > 0);
  }
  
  ArrayList<Contour> getContours() {
    return contours;
  }
  
  int ancho() {
    return opencv.width;
  }

  int alto() {
    return opencv.width;
  }
  
  void displayLegend() {
    currentPosY = POS_Y_INICIAL;      
    
    pushStyle();
    
    fill(255, 0, 0);
    text("Sensor: " + getNombre(),0,currentPosY+=POS_Y_STEP);
    fill(0, 255, 0);
    text("Contours: " + contours.size(),0,currentPosY+=POS_Y_STEP);
    text("Umbral (t/r para cambiar): "+ umbral,0,currentPosY+=POS_Y_STEP);
    
    displayCustomLegend();
    
    popStyle();
  }
  
  void keyPressed() {
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
