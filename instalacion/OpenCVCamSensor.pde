import java.awt.*;
import processing.video.*;

abstract class OpenCVCamSensor extends OpenCVSensor {
  
  Capture cam;
    
  OpenCVCamSensor(PApplet theParent, int indiceCamara) {
    super();
       
    String[] cameras = Capture.list();
  
    if (cameras.length == 0) {
      println("No hay camaras disponibles para la captura.");
      exit();
    } else {
      println("Camaras disponibles:");
      printArray(cameras);
      println("Usando camara: " + indiceCamara);
      cam = new Capture(theParent, cameras[indiceCamara]);
      cam.start();     
    }
    
    while (!cam.available()) {
      println("Esperando cámara...");
      delay(500);
    }
    println("Cámara lista");
    cam.read();
    
    initOpenCV(theParent, cam.width, cam.height);
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
