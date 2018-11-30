import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.sound.*; 
import java.io.FileWriter; 
import java.awt.*; 
import processing.video.*; 
import java.awt.*; 
import gab.opencv.*; 
import java.awt.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class instalacion extends PApplet {

// Basado en 'Particles', de Daniel Shiffman.



ParticleSystem ps;

final int IZQUIERDA = 0;
final int DERECHA = 1;

/**
  Variables configurables
*/
int CANT_PARTICULAS = 10000;
int MAX_MUERTAS = 25000;
int INDICE_CAMARA = 15; 
String NOMBRE_CAMARA = ""; 
int DEFAULT_UMBRAL = 40;// 50;
int OFFSET_PUNTO_REF = 10;
int SENTIDO = DERECHA;
int UMBRAL_RECOMPENSA = 100;

String archivoSonidoChicharra = "alarma_submarino.wav";
String archivoSonidoRecompensa = "krapp.wav";

String URL = "";

/**
  Otras Variables
*/  
final String configLineVarValueSep = "=";

final String nombreArchivoEnv = ".env";
final String nombreArchivoConfig = "config.ini";
final String nombreArchivoLastConfig = "last_config.ini";

PImage fondo;

int muertas = 0;

ArrayList<PVector> puntosRef;
ArrayList<PVector> puntosRefVirtuales;

int anchoBanda = 100;
int CENTRO_DEL_CAMINO;
int MARGEN_MUERTE = 20;
int UMBRAL_DE_INICIO = 50;

int margen = 150;
  
PVector origenDeParticulas;
PVector puntoRecompensa;

final int TEXT_SIZE = 48;
final int POS_Y_STEP = TEXT_SIZE+3;

boolean debugMode = false;
boolean calibrationMode = false;
int anchoImagenDebug = 320;
int helpStartTime;
int helpDuration = 10; // Duracion de la leyenda de ayuda, en segundos
boolean blobDebugMode = false;
boolean mostrarPuntos = false;
boolean mostrarFrameRate = false;

final String imagenesFondo[] = { "beckett_izquierda.jpg", "beckett_derecha.jpg" };

boolean yaMori = false;
boolean yaGane = false;

Sensor sensor;

SoundFile sonidoChicharra;
SoundFile sonidoRecompensa;

boolean cambioLaConfig = false;


public void setup() {
   
  //size(640,480,P2D);
  
  cargarConfig();
  
  origenDeParticulas = new PVector((SENTIDO == IZQUIERDA)?width-margen:margen,height/2);   
  puntoRecompensa = origenDeParticulas.copy();
  
  fondo = loadImage(imagenesFondo[SENTIDO]);
  fondo.loadPixels();
  
  ps = new ParticleSystem(CANT_PARTICULAS);

  // Writing to the depth buffer is disabled to avoid rendering
  // artifacts due to the fact that the particles are semi-transparent
  // but not z-sorted.
  hint(DISABLE_DEPTH_MASK);
  
  CENTRO_DEL_CAMINO = height/2;
  
  sensor = new OpenCVCamSensorGrayDiff(this, INDICE_CAMARA, NOMBRE_CAMARA);
  
  helpStartTime = millis();
  
  sonidoChicharra = new SoundFile(this, archivoSonidoChicharra);
  sonidoRecompensa = new SoundFile(this, archivoSonidoRecompensa);
} 

public void cargarConfig() {
  
  boolean configLeida = leerArchivoConfig(dataPath(nombreArchivoLastConfig));
  
  if (!configLeida) {
    configLeida = leerArchivoConfig(dataPath(nombreArchivoConfig));
  }
  
  leerArchivoConfig(dataPath(nombreArchivoEnv));
}

public boolean leerArchivoConfig(String filename)
{ 
  File file = new File(filename);
  
  if (!file.exists()) {
    //println("No puedo cargar configuracion de " + filename);
    return false;
  }
  
  println("Cargando configuracion de " + filename);
  
  String[] lines = loadStrings(filename);
  
  return parseConfigLines(lines);
}

public boolean parseConfigLines(String[] lines)
{
   boolean resultado = true;
   
   for (int i = 0 ; i < lines.length; i++) {
     String linea = trim(lines[i]);

     if (linea.indexOf("#") == 0) {
       //println("Comentario: linea ignorada");
       continue;
     }
     
     String[] list = split(linea,configLineVarValueSep);

     if (list.length < 2) {
       //println("No se encontraron los 2 items: linea ignorada");
       continue;
     }

     String varName = (trim(list[0])).toUpperCase();
     
     // Rearmar 'value' en caso de que incluya al separador
     String value = "";
     String sep = "";
     for (int s=1; s < list.length; s++) {
       value += sep + list[s];
       sep = configLineVarValueSep;
     }
     value = trim(value);
     

     
     //println("Valores encontrados: Var: '" + varName + "' - Value: " + value);
          
     String prefijoMensajeOK = "OK => ";
     
     if (varName.equals("CANT_PARTICULAS")) {
       CANT_PARTICULAS = PApplet.parseInt(value);
       println(prefijoMensajeOK + varName + ": " + CANT_PARTICULAS);
     } else if (varName.equals("MAX_MUERTAS")) {
       MAX_MUERTAS = PApplet.parseInt(value);
       println(prefijoMensajeOK + varName + ": " + MAX_MUERTAS);
     } else if (varName.equals("INDICE_CAMARA")) {
       INDICE_CAMARA = PApplet.parseInt(value);
       println(prefijoMensajeOK + varName + ": " + INDICE_CAMARA);      
     } else if (varName.equals("DEFAULT_UMBRAL")) {
       DEFAULT_UMBRAL = PApplet.parseInt(value);
       println(prefijoMensajeOK + varName + ": " + DEFAULT_UMBRAL);
     } else if (varName.equals("OFFSET_PUNTO_REF")) {
       OFFSET_PUNTO_REF = PApplet.parseInt(value);
       println(prefijoMensajeOK + varName + ": " + OFFSET_PUNTO_REF);
     } else if (varName.equals("SENTIDO")) {
       int valor = PApplet.parseInt(value);
       if ((valor != IZQUIERDA) && (valor != DERECHA)) {
         println("ERROR: valor invalido para " + varName + ": " + valor);
       } else {
         SENTIDO = valor;
         println(prefijoMensajeOK + varName + ": " + SENTIDO);
       }
     } else if (varName.equals("UMBRAL_RECOMPENSA")) {
       UMBRAL_RECOMPENSA = PApplet.parseInt(value);
       println(prefijoMensajeOK + varName + ": " + UMBRAL_RECOMPENSA);
     } else if (varName.equals("NOMBRE_CAMARA")) {
       NOMBRE_CAMARA = value;
       println(prefijoMensajeOK + varName + ": " + NOMBRE_CAMARA);
     } else if (varName.equals("CHICHARRA")) {
       String filename = dataPath(value);
       File file = new File(filename);
       if (!file.exists()) {
         println("ERROR: archivo no encontrado. " + filename);
       } else {
         archivoSonidoChicharra = value;
         println(prefijoMensajeOK + varName + ": " + archivoSonidoChicharra);
       }  
     } else if (varName.equals("RECOMPENSA")) {
       String filename = dataPath(value);
       File file = new File(filename);
       if (!file.exists()) {
         println("ERROR: archivo no encontrado. " + filename);
       } else {
         archivoSonidoRecompensa = value;
         println(prefijoMensajeOK + varName + ": " + archivoSonidoRecompensa);
       }  
     } else if (varName.equals("URL")) {
       URL = value;
       println(prefijoMensajeOK + varName + ": " + URL);
     }  else {
       println("No asigne nada desde la config. varName: '" + varName + "'");
     }
   }
   
   return resultado;
}

public void guardarConfig()
{
  println("Guardando la config");
  
  StringList lineas;
  lineas = new StringList();
  
  lineas.append("###################################################");
  lineas.append("# Archivo de configuracion generado automaticamente");
  lineas.append("###################################################");
  lineas.append("");
  lineas.append("# General");
  lineas.append("CANT_PARTICULAS" + configLineVarValueSep + CANT_PARTICULAS);
  lineas.append("MAX_MUERTAS" + configLineVarValueSep + MAX_MUERTAS);
  lineas.append("DEFAULT_UMBRAL" + configLineVarValueSep + ((OpenCVSensor)sensor).umbral());
  lineas.append("SENTIDO" + configLineVarValueSep + SENTIDO);
  lineas.append("UMBRAL_RECOMPENSA" + configLineVarValueSep + UMBRAL_RECOMPENSA);

  lineas.append("");
  lineas.append("# Camara");
  lineas.append("# NOMBRE_CAMARA tiene prioridad respecto de INDICE_CAMARA.");
  lineas.append("# INDICE_CAMARA se utiliza solo si NOMBRE_CAMARA no esta definido.");
  lineas.append("NOMBRE_CAMARA" + configLineVarValueSep + ((OpenCVCamSensor)sensor).nombreCamara());
  lineas.append("INDICE_CAMARA" + configLineVarValueSep + INDICE_CAMARA);
  
  lineas.append("");
  lineas.append("# Archivos de sonido");
  lineas.append("CHICHARRA" + configLineVarValueSep + archivoSonidoChicharra);
  lineas.append("RECOMPENSA" + configLineVarValueSep + archivoSonidoRecompensa);

  lineas.append("");
  lineas.append("# URL para descontar");
  lineas.append("URL" + configLineVarValueSep + URL);
  
  saveStrings(dataPath(nombreArchivoLastConfig), lineas.array());
  
  println("Config guardada en "+dataPath(nombreArchivoLastConfig)); 
}

public void draw () {
  background(0);
  
  sensor.update();
  
  /**
    Calibracion camara
  */
  if (calibrationMode) {
    PImage snapshot = sensor.getSnapshot().get();
    if (snapshot != null) {
      image(snapshot,0,0,width,height);
      textSize(TEXT_SIZE);
      text("Frame rate: " + PApplet.parseInt(frameRate), 10, TEXT_SIZE+2);
    }  
  }  

  /**
    Obtener Blobs y PuntosRef
  */
  puntosRef = new ArrayList<PVector>();
  puntosRefVirtuales = new ArrayList<PVector>();
  //puntosRef.add(new PVector(mouseX,mouseY)); 
  ArrayList<Contour> contours = sensor.getContours();
  
  if ((contours != null) && (contours.size() != 0)) {
    for (Contour contour : contours) {          
       Rectangle BoundingBox = contour.getBoundingBox();      
       PVector puntoRef = new PVector(BoundingBox.x + ((SENTIDO == IZQUIERDA)?BoundingBox.width+OFFSET_PUNTO_REF:-OFFSET_PUNTO_REF),BoundingBox.y + BoundingBox.height/2);
       // Convertir puntoRef del sistema de coord de la cámara al de la pantalla
       puntoRef.x = puntoRef.x * (width/sensor.ancho());
       puntoRef.y = puntoRef.y * (height/sensor.alto());
       puntosRef.add(puntoRef);
       
       float slice = sensor.ancho()/5;
       float currSlice = slice;
       while (currSlice < BoundingBox.width) {
         PVector puntoRefVirtual = new PVector(BoundingBox.x + ((SENTIDO == IZQUIERDA)?BoundingBox.width - currSlice:currSlice),BoundingBox.y + BoundingBox.height/2);
         puntoRefVirtual.x = puntoRefVirtual.x * (width/sensor.ancho());
         puntoRefVirtual.y = puntoRefVirtual.y * (height/sensor.alto());
         
         puntosRefVirtuales.add(puntoRefVirtual);
         puntosRef.add(puntoRefVirtual);
         
         currSlice += slice;
       }
       
    }     
  }  

  /**
    Blob debug
  */  
  if (blobDebugMode) {
      textSize(TEXT_SIZE);
      int y = TEXT_SIZE;
      text("Mostrando blobs", 10, y);
      text("Blobs Encontrados : " + (contours != null?contours.size():0), 10, y+=TEXT_SIZE);
      if ((contours != null) && (contours.size() != 0)) {          
        for (Contour contour : contours) {          
           dibujarCountourEscalado(contour);
        } 
      }      
  }  
  
  if (blobDebugMode || mostrarPuntos) {
    mostrarPuntosRef(puntosRef);
  }
  
  if ((contours == null) || (contours.size() == 0)) {
    /**
      No hay blobs: reset
    */
    muertas = 0;
    yaMori = false;
    yaGane = false;
    if (sonidoChicharra.isPlaying()) {
      sonidoChicharra.stop();
      println("Audio Chicharra detenido");
    }
    if (sonidoRecompensa.isPlaying()) {
      sonidoRecompensa.stop();
      println("Audio Recompensa detenido");
    }
  } else {
    /**
      ¿Llegaron al punto de recompensa?
    */
    if (!yaMori) {
      if (!yaGane) {
        for (PVector puntoRef: puntosRef) {
          float dist = puntoRecompensa.dist(puntoRef);
          if (dist < UMBRAL_RECOMPENSA) {
            yaGane = true;
            break;
          }
        }
        if (yaGane) {
          sonidoRecompensa.loop();
          println("Audio Recompensa iniciado");
        }
      }
    }
  }
  
  /**
    Actualizar Particulas
  */
  if (!calibrationMode) {
    ps.update();
    ps.display();
  }    
     
  /** 
    Barra de muertas
  */  
  if (!yaGane) {
    int margenBarra = 120;
    PVector esquinaBarra = new PVector(margenBarra/2,height-50); 
    int altoBarra = 10;
    int anchoBarra = width-margenBarra;
    
    rectMode(CORNER);
    rect(esquinaBarra.x,esquinaBarra.y,anchoBarra,altoBarra);
    
    fill(255,0,0);
    float progreso = map(min(muertas,MAX_MUERTAS),0,MAX_MUERTAS,0,anchoBarra); 
    int rellenoX = (int)((SENTIDO==IZQUIERDA)?esquinaBarra.x:esquinaBarra.x+anchoBarra-progreso);
    rect(rellenoX,esquinaBarra.y,progreso,altoBarra);

    fill(255); 
    /**
      Actualizar yaMori, e iniciar chicharra si es necesario
    */
    if (!yaMori) {
      yaMori = (muertas >= MAX_MUERTAS);
      if (yaMori) {
        sonidoChicharra.loop();
        println("Audio Chicharra iniciado");
        thread("descontar");
      }
    }   
  }
  
  if (debugMode || mostrarFrameRate) {
    pushMatrix();
    pushStyle();
    fill(255);
    //textSize(16);    
    translate(10,200);
    textSize(TEXT_SIZE);
    int y = 0;
    text("Frame rate: " + PApplet.parseInt(frameRate), 0, 0);
    //text("Muertas: " + muertas, 0, y+=TEXT_SIZE+2);
    popStyle();
    popMatrix();
  }
  
  if (debugMode) {
    pushMatrix(); 
    translate(10,(TEXT_SIZE+2)*10);
    sensor.displayLegend();
    popMatrix();   
  }
  
  /**
    Mostrar Ayuda
  */
  if ((millis() - helpStartTime) < (helpDuration*1000)) {
    mostrarAyuda();
  }
  
  if (URL == "") {
    pushStyle();
    fill(255,0,0);
    textSize(TEXT_SIZE+10);
    text("¡URL no especificado! No puedo descontar.",10,300);
    popStyle();
  }
}

public void mostrarAyuda() {
  pushMatrix();
  pushStyle();
  
  translate(10,20);
  fill(0,255,0);
  int x=0;
  int y=0;
  int step=TEXT_SIZE+2;
  textSize(TEXT_SIZE);
  text("(f): mostrar frame rate",x,y+=step);
  text("(c): calibrar camara",x,y+=step);
  text("(b): mostrar blobs",x,y+=step);
  text("(p): mostrar puntos",x,y+=step);
  text("(d): modo debug",x,y+=step);
  text("(s): capturar frame",x,y+=step);
  y+=step;
  text("(h): esta ayuda (desaparece en " + (int)(((helpDuration*1000) - (millis() - helpStartTime)) / 1000) + " segundos)",x,y+=step);
  
  popStyle();
  popMatrix();
}


public void dibujarCountourEscalado(Contour contour)
{
  pushStyle();
  noFill();
  
  // Blob
  stroke(0, 255, 0);
  
  pushMatrix();
  strokeWeight(1);    
  scale(width/sensor.ancho(),height/sensor.alto());
  contour.draw();
  popMatrix();
  
  
  // Centro
   Rectangle BoundingBox = contour.getBoundingBox();      
   PVector centroBlob = new PVector(BoundingBox.x + BoundingBox.width/2,BoundingBox.y + BoundingBox.height/2);
   // Convertir PVector del sistema de coord de la cámara al de la pantalla
   centroBlob.x = centroBlob.x * (width/sensor.ancho());
   centroBlob.y = centroBlob.y * (height/sensor.alto());

   stroke(0,255,0);
   noFill();
   int largoLinea = 10;
   // Cruz
   line(centroBlob.x-(largoLinea/2),centroBlob.y,centroBlob.x+(largoLinea/2),centroBlob.y);
   line(centroBlob.x,centroBlob.y-(largoLinea/2),centroBlob.x,centroBlob.y+(largoLinea/2));

   popStyle();
}

public void mostrarPuntosRef(ArrayList<PVector> puntosRef)
{
  for (PVector puntoRef : puntosRef) { 
    pushStyle();
    stroke(255);
    fill(255);
    ellipse((int)puntoRef.x,(int)puntoRef.y,20,20);  
    popStyle();
  }
  
  for (PVector puntoRefVirtual : puntosRefVirtuales) { 
    pushStyle();
    strokeWeight(2);
    stroke(255);
    fill(0);
    ellipse((int)puntoRefVirtual.x,(int)puntoRefVirtual.y,20,20);  
    popStyle();
  }  
  
  // Area de Recompensa
  pushStyle();
  noFill();
  strokeWeight(1);
  stroke(255);
  ellipseMode(RADIUS);
  ellipse((int)puntoRecompensa.x,(int)puntoRecompensa.y,UMBRAL_RECOMPENSA,UMBRAL_RECOMPENSA);
  popStyle();
}

public void descontar() {
  println("Descontando: " + URL);
  
  JSONObject json = loadJSONObject(URL);
  JSONObject valor = json.getJSONObject("value");
  
  println("Respuesta: " + json);
  /*
  println("id: " + valor.getString("_id"));  
  println("value: " + valor.getInt("value"));
  */
  log(json.toString());  
}

public void log(String linea)
{
  FileWriter output = null;
  try {
    output = new FileWriter(dataPath("descuentos.log"), true); //the true will append the new data
    output.write(linea + "\n");
  }
  catch (IOException e) {
    println("No puedo abrir log");
    e.printStackTrace();
  }
  finally {
    if (output != null) {
      try {
        output.close();
      } catch (IOException e) {
        println("Error al cerrar log");
      }
    }
  }  
}

public void keyPressed(){
    sensor.keyPressed();
    
    if ((key == 's') || (key == 'S')) {
      saveFrame("frames/captura-######.png");
    }
             
    if ((key == 'd') || (key == 'D')) {
      debugMode = !debugMode;
    }
    
    if ((key == 'c') || (key == 'C')) {
      calibrationMode = !calibrationMode;
    }
    
    if ((key == 'b') || (key == 'B')) {
      blobDebugMode = !blobDebugMode;
    }   
    
    if ((key == 'h') || (key == 'H')) {
      helpStartTime = millis();
    }
    
    if ((key == 'p') || (key == 'P')) {
      mostrarPuntos = !mostrarPuntos;
    }
    
    if ((key == 'f') || (key == 'F')) {
      mostrarFrameRate = !mostrarFrameRate;
    }    
    /*
    if ((key == 'u') || (key == 'U')) {
      thread("descontar");
    } 
    */
    
    if (cambioLaConfig) {
      guardarConfig();
      cambioLaConfig = false;
    }
}  



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
    
  public String nombreCamara() {
    return camaraElegida;
  }
  public boolean update() {
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
class OpenCVCamSensorGrayDiff extends OpenCVCamSensor {
   
  PImage grayDiff;

  int tramos = 3;
     
  OpenCVCamSensorGrayDiff(PApplet theParent, int indiceCamara, String nombreCamara) {
    super(theParent, indiceCamara, nombreCamara);
    
    grayDiff = null;

  }
  
  public String getNombre() {
    return "Gray Diff";
  }  
  
  public boolean update() {
    if (!super.update() || (snapshot == null)) {
      return false;
    }
    
    if (fondo == null) {
      fondo = new PImage(snapshot.width, snapshot.height);
      fondo = snapshot.get();
      //fondo.filter(GRAY);
    }
    
    opencv.loadImage(snapshot);
    //opencv.gray();
    opencv.diff(fondo);
    opencv.threshold(umbral);
    opencv.dilate();
    opencv.erode();
    
    grayDiff = opencv.getSnapshot();
    
    /**
      Sólo considero 'countours' con un área mayor a minContourArea
    */
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
  
  public void display() {
    image(grayDiff, 0, 0);
   
   /* ArrayList<Point> centros = new ArrayList<Point>(); 
   
    for (Contour contour : contours) {
      noFill();
      
      float area = contour.area();
      
      stroke(255, 0, 0);
      strokeWeight(3);
      contour.draw();
   */   
      /*
      Rectangle BoundingBox = contour.getBoundingBox();

      stroke(0, 255, 0);
      strokeWeight(1);      
      rect(BoundingBox.x, BoundingBox.y, BoundingBox.width, BoundingBox.height);
      text((int)area,BoundingBox.x, BoundingBox.y);
      
      centros.add(new Point(BoundingBox.x + BoundingBox.width/2,BoundingBox.y + BoundingBox.height/2));
      */
    //}

    /*
    for (int i=0; i < centros.size(); i++) {
      Point centro = centros.get(i);
      stroke(0, 255, 0);
      strokeWeight(1); 
      fill(0,255,0);
      ellipse(centro.x,centro.y,10,10);
      
      if (i+1 < centros.size()) {
        Point otroCentro = centros.get(i+1);
        stroke(255, 0, 0);
        line(centro.x,centro.y,otroCentro.x,otroCentro.y);
      }      
    } 
    */
  }
  
  public void displayCustomLegend() {     
    super.displayCustomLegend();
    
    text("<espacio> para recargar el fondo",0,currentPosY+=POS_Y_STEP);
    
  }
  
  public void multibezier(Point inicio, Point fin,int tramos)
  {
    float tramoAnchoX = (fin.x - inicio.x) / tramos;
    float tramoAnchoY = (fin.y - inicio.y) / tramos;
    
    text(tramoAnchoX + ":" + tramoAnchoY,10,250);
    
    Point inicioTramo = inicio;
    
    for (int i=0; i<tramos; i++) {
      Point finTramo = new Point((int)(inicioTramo.x+tramoAnchoX),(int)(inicioTramo.y+tramoAnchoY));
      
      Point control1 = new Point(inicioTramo.x-100,inicioTramo.y+50);        
      Point control2 = new Point(finTramo.x+100,finTramo.y-50);
      noFill();
      stroke(0, 255, 0);
      bezier(inicioTramo.x,inicioTramo.y,control1.x,control1.y,control2.x,control2.y,finTramo.x,finTramo.y);
      /*
      fill(255,0,0);
      stroke(0, 255, 0);
      ellipse(finTramo.x,finTramo.y,10,10);
      text(i,finTramo.x,finTramo.y);
      */
      inicioTramo = finTramo;
    }
  }  
   
  public void resetFondo() {
    fondo = null;
  }
  
  public void keyPressed() {
    super.keyPressed();
      
    if (key == ' ') {
      resetFondo();
    }    
  }
    
}



abstract class OpenCVSensor extends Sensor {
  
  OpenCV opencv;
  
  int umbral = DEFAULT_UMBRAL;
    
  OpenCVSensor() {
    super();
   
    snapshot = null;
    fondo = null;    
  }
  
  public void initOpenCV(PApplet theParent, int ancho, int alto) {
    opencv = new OpenCV(theParent, ancho, alto);       
  }
      
  public int ancho() {
    return opencv.width;
  }

  public int alto() {
    return opencv.height;
  }
  
  public int umbral() {
    return umbral;
  }
   
  public void displayCustomLegend() {     
    text("Umbral (t/r para cambiar): "+ umbral,0,currentPosY+=POS_Y_STEP);
  }
  
  public void keyPressed() {
    super.keyPressed();
    
    if(key == 't') {
      umbral = umbral + 10;
      if (umbral > 255) {
        umbral = 255;
      }
      cambioLaConfig = true;
    }
    
    if(key == 'r') {
      umbral = umbral - 10;
      if (umbral < 0) {
        umbral = 0;
      }
      cambioLaConfig = true;
    }    
  }    
}
class Particle {

 
  PVector velocity;
  PVector pos;
  float lifespan = 255;
  
  PShape part;
  float partSize;
  
  PVector gravity = new PVector(((SENTIDO == IZQUIERDA)?-1:1)*0.1f,0);
  
  PVector vientoLateral = new PVector(0,0.1f);
  
  boolean muertaContada = false;

  Particle() {
    pos = new PVector(0,0);
    //partSize = random(10,60);
    partSize = 5;
    part = createShape();
    part.beginShape(QUAD);
    part.noStroke();
    part.normal(0, 0, 1);
    part.vertex(-partSize/2, -partSize/2);
    part.vertex(+partSize/2, -partSize/2);
    part.vertex(+partSize/2, +partSize/2);
    part.vertex(-partSize/2, +partSize/2);
    part.endShape();
    
    renacer();
    lifespan = random(255);
  }

  public PShape getShape() {
    return part;
  }
  
  public void renacer() {
    renacerEn(origenDeParticulas.x,origenDeParticulas.y);
  }
  public void renacerEn(float x, float y) {
    float a = random(TWO_PI);
    float speed = random(0.5f,4);
    velocity = new PVector(cos(a), sin(a));
    velocity.mult(speed);
    lifespan = 255;   
    part.resetMatrix();
    part.translate(x, y);
    pos.x = x;
    pos.y = y;
    
    muertaContada = false;
  }
  
  public boolean isDead() {
    if (lifespan < 0) {
     return true;
    } else {
     return false;
    } 
  }
  

  public void update() {
    if (isDead()) {
      renacer();
    }
    lifespan = lifespan - 1;

    float prev_pos_x = pos.x;
    
    //rebotar(mouseX,mouseY);
    //rebotar(mouseX-100,mouseY);
    float maxPuntoRef_x = ((SENTIDO == IZQUIERDA)?0:10000);
    for (PVector puntoRef : puntosRef) {
      rebotar((int)puntoRef.x,(int)puntoRef.y);
      
      if (
          ((SENTIDO == IZQUIERDA) && (puntoRef.x > maxPuntoRef_x))
          ||
          ((SENTIDO == DERECHA) && (puntoRef.x < maxPuntoRef_x))
          ){
        maxPuntoRef_x = puntoRef.x;
      }
    }
    
    velocity.add(gravity);
    
    //part.texture(fondo);
    //part.setTint(color(255,lifespan));
    pos.x += velocity.x;
    pos.y += velocity.y;
    
    boolean pasoElUmbral = (SENTIDO == IZQUIERDA)?(maxPuntoRef_x > UMBRAL_DE_INICIO):(maxPuntoRef_x < width - UMBRAL_DE_INICIO);
    boolean aMorir = (SENTIDO == IZQUIERDA)?(pos.x < maxPuntoRef_x - MARGEN_MUERTE):(pos.x > maxPuntoRef_x + MARGEN_MUERTE);
    
    if ( !muertaContada && pasoElUmbral && aMorir && (pos.x > 0) && (pos.y >= CENTRO_DEL_CAMINO-anchoBanda/2)  && (pos.y < CENTRO_DEL_CAMINO+anchoBanda/2)) {
    //if ( !muertaContada && (pos.x > width)) {  
      muertas++;
      muertaContada = true;
    }
    
    if (!yaGane) {
      if (!muertaContada) {
        int i = (int) map(pos.x,0,width,0,fondo.width-1);
        int j = (int) map(pos.y,0,height,0,fondo.height-1);
        //part.setFill(fondo.get(i,j));
        int pixel_index = j*fondo.width+i;
        if ((pixel_index >=0) && (pixel_index < fondo.pixels.length)) {
          part.setFill(fondo.pixels[pixel_index]);
        }
      } else {
        part.setFill(color(255,0,0));
        //part.setTint(color(255,0,0,lifespan));
      }
    } else {
      float max = 1;
      /*
      int verde = (int)(255*map(pos.dist(origenDeParticulas),0,width,max,0));
      int azul  = (int)(255*map(pos.dist(origenDeParticulas),0,width,0,max));
      */
      int azul = (int)map(255-lifespan,0,255,100,255);
      int verde  = (int)map(lifespan,0,255,100,255);
      part.setFill(color(0,verde,azul));
    }

    part.translate(velocity.x, velocity.y);

  }
  
  private void rebotar(int x, int y)
  {
    // Compute a vector that points from location to mouse
    PVector ref = new PVector(x,y);
    float dist = ref.dist(pos);
    
    if (dist < 100) {
      PVector acceleration = PVector.sub(pos,ref);
      // Set magnitude of acceleration
      acceleration.setMag(1.1f);
      velocity.add(acceleration);
    }
    
    //if (pos.x < mouseX) {
     if ((SENTIDO == IZQUIERDA)?pos.x < x:pos.x > x) {
      if (pos.y > height/2) {
        velocity.sub(vientoLateral);
      } else {
        velocity.add(vientoLateral);
      };
    }
  }
}
class ParticleSystem {
  ArrayList<Particle> particles;

  PShape particleShape;

  ParticleSystem(int n) {
    particles = new ArrayList<Particle>();
    particleShape = createShape(PShape.GROUP);

    for (int i = 0; i < n; i++) {
      Particle p = new Particle();
      particles.add(p);
      particleShape.addChild(p.getShape());
    }
  }

  public void update() {
    for (Particle p : particles) {
      p.update();
    }
  }

  public void display() {
    shape(particleShape);
  }
}


abstract class Sensor {
  
  final int POS_Y_INICIAL = 5;
  
  PImage snapshot, fondo;
  ArrayList<Contour> contours; 
   
  int currentPosY;
  
  int minContourArea = 5000; 
  final int AREA_STEP = 1000;
  
  public abstract String getNombre();
  public abstract void display();
  public abstract int ancho();
  public abstract int alto();

  Sensor() {
    snapshot = null;
    fondo = null;
  }
    
  public boolean update() {
    return true;
  }
  
  public PImage getFondo() {
    return fondo;
  }

  public PImage getSnapshot() {
    return snapshot;
  }
  
  public ArrayList<Contour> getContours() {
    return contours;
  }
    
  public void displayCustomLegend() {

  }
  
  public void displayLegend() {
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
  
  public void keyPressed() {
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
  public void settings() {  fullScreen(P2D, 2); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--hide-stop", "instalacion" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
