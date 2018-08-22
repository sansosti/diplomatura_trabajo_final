import java.awt.*;
import processing.video.*;

abstract class OpenCVCamSensor extends OpenCVSensor {
  
  Capture cam;
    
  OpenCVCamSensor(PApplet theParent, int ancho, int alto, int indiceCamara) {
    super(theParent, ancho, alto);
       
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
    if (!super.update()) {
      return false;
    }
    
    if (cam.available()) {
      cam.read();
    }
    
    if (cam.width <= 0 || cam.height <= 0) {
        return false;
    };
       
    snapshot = cam;
    
    return true;
  }       
}
