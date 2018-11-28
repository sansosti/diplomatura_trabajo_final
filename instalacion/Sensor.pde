import java.awt.*;

abstract class Sensor {
  
  final int POS_Y_INICIAL = 5;
  
  PImage snapshot, fondo;
  ArrayList<Contour> contours; 
   
  int currentPosY;
  
  int minContourArea = 5000; 
  final int AREA_STEP = 1000;
  
  abstract String getNombre();
  abstract void display();
  abstract int ancho();
  abstract int alto();

  Sensor() {
    snapshot = null;
    fondo = null;
  }
    
  boolean update() {
    return true;
  }
  
  PImage getFondo() {
    return fondo;
  }

  PImage getSnapshot() {
    return snapshot;
  }
  
  ArrayList<Contour> getContours() {
    return contours;
  }
    
  void displayCustomLegend() {

  }
  
  void displayLegend() {
    currentPosY = POS_Y_INICIAL;      
    
    pushStyle();
    
    fill(255, 0, 0);
    text("Sensor: " + getNombre(),0,currentPosY+=POS_Y_STEP);
    fill(0, 255, 0);
    text("Contours: " + contours.size(),0,currentPosY+=POS_Y_STEP);
    text("Min. Area (+/- para cambiar) : " + minContourArea,0,currentPosY+=POS_Y_STEP);   
    
    displayCustomLegend();
    
    popStyle();
  }
  
  void keyPressed() {
    if(key == '+') {
      minContourArea = minContourArea + AREA_STEP;
      cambioLaConfig = true;
    }
    
    if(key == '-') {
      minContourArea = minContourArea - AREA_STEP;
      cambioLaConfig = true;
    }       
  }
  
}
