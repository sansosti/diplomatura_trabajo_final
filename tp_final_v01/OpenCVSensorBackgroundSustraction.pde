import gab.opencv.*;

final int HISTORY = 5;
final int N_MIXTURES = 3;
final double BACKGROUND_RATIO = 0.5;

class OpenCVSensorBackgroundSustraction extends OpenCVSensor {

  OpenCVSensorBackgroundSustraction(PApplet theParent, int ancho, int alto) {
    super(theParent, ancho, alto);
        
    opencv.startBackgroundSubtraction(HISTORY, N_MIXTURES, BACKGROUND_RATIO);

  }
  
  String getNombre() {
    return "Background Sustraction";
  }
  
  boolean update(PImage img) {
    if (!super.update(img)) {
      return false;
    }
    
    opencv.loadImage(img);
  //opencv.threshold(umbral);    
   opencv.updateBackground();
   opencv.dilate();
   opencv.erode();
   
   contours = opencv.findContours();
   
   return true;
  }
  
  void display() {    
    for (Contour contour : contours) {
      noFill();
      //stroke(255, 0, 0);
      //strokeWeight(3);
      //contour.draw();
      
      strokeWeight(1);
      stroke(0, 255, 0);
      beginShape();
      for (PVector point : contour.getPolygonApproximation().getPoints()) {
        vertex(point.x, point.y);
      }
      endShape();
    }
  }
  
  void displayCustomLegend() {
  }
  
}
