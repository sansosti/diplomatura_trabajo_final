import processing.video.*;

/*
import org.openkinect.freenect.*;
import org.openkinect.processing.*;

// LIMITE FONDO

abstract class KinectSensor extends Sensor {
  
  OpenCV opencv;
  Kinect kinect;

  // Depth image
  PImage depthImg, diffImg;
  
  // Which pixels do we care about?
  // These thresholds can also be found with a variaty of methods
  float minDepth =  996;
  float maxDepth = 2493;
  
  // What is the kinect's angle
  float angle;

  KinectSensor(PApplet theParent, int ancho, int alto) {
    super();
    
    opencv = new OpenCV(theParent, ancho, alto); 
    
    kinect = new Kinect(this);
    kinect.initDepth();
    angle = kinect.getTilt();
  
    // Blank image
    depthImg = new PImage(kinect.width, kinect.height);
    
    diffImg = null;
  }
  
  boolean update() {
           
    snapshot = kinect.getDepthImage();
    
    // Threshold the depth image
    int[] rawDepth = kinect.getRawDepth();
    for (int i=0; i < rawDepth.length; i++) {
      if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
        depthImg.pixels[i] = color(255);
      } else {
        depthImg.pixels[i] = color(0);
      }
    }
  
    // Draw the thresholded image
    depthImg.updatePixels();
    
    opencv.loadImage(depthImg);
    opencv.dilate();
    opencv.erode();
    
    diffImg = opencv.getSnapshot();
    
    //  Sólo considero 'countours' con un área mayor a minContourArea

    contours = opencv.findContours(false,true);  
    
    for (int i=0; i < contours.size();) {
      
      float area = contours.get(i).area();
      
      if (area < minContourArea) {
        contours.remove(i);
      } else {
        i++;
      }
    }    
    return true;    
  }
  
  void display() {
    image(diffImg, 0, 0);
      
    for (Contour contour : contours) {
      noFill();
      
      float area = contour.area();
      
      stroke(255, 0, 0);
      strokeWeight(3);
      contour.draw();
    }   
  }
   
  String getNombre() {
    return "Kinect";
  }    
  
  int ancho() {
    return kinect.width;
  }

  int alto() {
    return kinect.height;
  }  
  
  void displayCustomLegend() {     
    super.displayCustomLegend();
    
    text("TILT : " + angle,0,currentPosY+=POS_Y_STEP);   
    text("THRESHOLD: [" + minDepth + ", " + maxDepth + "]",0,currentPosY+=POS_Y_STEP);   
  }  
}
*/
