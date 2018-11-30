import java.awt.*;
import processing.video.*;

abstract class OpenCVCamSensor extends OpenCVSensor {
  
  Capture cam;
  
  String camaraElegida;
    
  OpenCVCamSensor(PApplet theParent, int indiceCamara, String nombreCamara) {
    super();
       
    String[] cameras = Capture.list();
  
    if (cameras.length == 0) {
      println("No hay camaras disponibles para la captura.");
      exit();
    } else {
      println("Camaras disponibles:");
      printArray(cameras);
      camaraElegida = "";
      if (nombreCamara != "") {
        camaraElegida = nombreCamara;
        println("Camara seleccionada por nombre: " + nombreCamara);
      } else {
        camaraElegida = cameras[indiceCamara];
        println("Camara seleccionada por indice: " + indiceCamara);
      }
      println("Usando camara: " + camaraElegida);
      
      cam = new Capture(theParent, camaraElegida);
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
    
  String nombreCamara() {
    return camaraElegida;
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
