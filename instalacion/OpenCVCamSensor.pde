import java.awt.*;
import processing.video.*;

abstract class OpenCVCamSensor extends OpenCVSensor {
  
  Capture cam;
  
  String camaraElegida;
    
  OpenCVCamSensor(PApplet theParent, int indiceCamara, String nombreCamara) {
    super();
       
    String[] cameras = Capture.list();
  
    if (cameras.length == 0) {
      printAndLog("No hay camaras disponibles para la captura.");
      exit();
    } else {
      printAndLog("Camaras disponibles:");
      //printArray(cameras);
      
      String listaCamaras = "";
      String sep = "";
      for (int i=0; i<cameras.length; i++) {
        listaCamaras += sep + "[" + i + "]:" + cameras[i];
        sep = "\n";
      }
      printAndLog(listaCamaras);
      
      camaraElegida = "";
      if (nombreCamara != "") {
        camaraElegida = nombreCamara;
        printAndLog("Camara seleccionada por nombre: " + nombreCamara);
      } else {
        camaraElegida = cameras[indiceCamara];
        printAndLog("Camara seleccionada por indice: " + indiceCamara);
      }
      printAndLog("Usando camara: " + camaraElegida);
      
      cam = new Capture(theParent, camaraElegida);
      cam.start();     
    }
    
    while (!cam.available()) {
      printAndLog("Esperando cámara...");
      delay(500);
    }
    printAndLog("Cámara lista");

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
