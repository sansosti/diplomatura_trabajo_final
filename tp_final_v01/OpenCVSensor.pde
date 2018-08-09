class OpenCVSensor {
  
  OpenCV opencv;
  ArrayList<Contour> contours; 
  
  int umbral = DEFAULT_UMBRAL;
  
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
