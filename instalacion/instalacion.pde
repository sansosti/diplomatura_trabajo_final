// Basado en 'Particles', de Daniel Shiffman.
import processing.sound.*;
import java.io.FileWriter;

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

final String nombreArchivoEnv = "env.ini";
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


void setup() {
  fullScreen(P2D, 2); 
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

void cargarConfig() {
  
  boolean configLeida = leerArchivoConfig(dataPath(nombreArchivoLastConfig));
  
  if (!configLeida) {
    configLeida = leerArchivoConfig(dataPath(nombreArchivoConfig));
  }
  
  leerArchivoConfig(dataPath(nombreArchivoEnv));
}

boolean leerArchivoConfig(String filename)
{ 
  File file = new File(filename);
  
  if (!file.exists()) {
    //printAndLog("No puedo cargar configuracion de " + filename);
    return false;
  }
  
  printAndLog("Cargando configuracion de " + filename);
  
  String[] lines = loadStrings(filename);
  
  return parseConfigLines(lines);
}

boolean parseConfigLines(String[] lines)
{
   boolean resultado = true;
   
   for (int i = 0 ; i < lines.length; i++) {
     String linea = trim(lines[i]);

     if (linea.indexOf("#") == 0) {
       //printAndLog("Comentario: linea ignorada");
       continue;
     }
     
     String[] list = split(linea,configLineVarValueSep);

     if (list.length < 2) {
       //printAndLog("No se encontraron los 2 items: linea ignorada");
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
     

     
     //printAndLog("Valores encontrados: Var: '" + varName + "' - Value: " + value);
          
     String prefijoMensajeOK = "OK => ";
     
     if (varName.equals("CANT_PARTICULAS")) {
       CANT_PARTICULAS = int(value);
       printAndLog(prefijoMensajeOK + varName + ": " + CANT_PARTICULAS);
     } else if (varName.equals("MAX_MUERTAS")) {
       MAX_MUERTAS = int(value);
       printAndLog(prefijoMensajeOK + varName + ": " + MAX_MUERTAS);
     } else if (varName.equals("INDICE_CAMARA")) {
       INDICE_CAMARA = int(value);
       printAndLog(prefijoMensajeOK + varName + ": " + INDICE_CAMARA);      
     } else if (varName.equals("DEFAULT_UMBRAL")) {
       DEFAULT_UMBRAL = int(value);
       printAndLog(prefijoMensajeOK + varName + ": " + DEFAULT_UMBRAL);
     } else if (varName.equals("OFFSET_PUNTO_REF")) {
       OFFSET_PUNTO_REF = int(value);
       printAndLog(prefijoMensajeOK + varName + ": " + OFFSET_PUNTO_REF);
     } else if (varName.equals("SENTIDO")) {
       int valor = int(value);
       if ((valor != IZQUIERDA) && (valor != DERECHA)) {
         printAndLog("ERROR: valor invalido para " + varName + ": " + valor);
       } else {
         SENTIDO = valor;
         printAndLog(prefijoMensajeOK + varName + ": " + SENTIDO);
       }
     } else if (varName.equals("UMBRAL_RECOMPENSA")) {
       UMBRAL_RECOMPENSA = int(value);
       printAndLog(prefijoMensajeOK + varName + ": " + UMBRAL_RECOMPENSA);
     } else if (varName.equals("NOMBRE_CAMARA")) {
       NOMBRE_CAMARA = value;
       printAndLog(prefijoMensajeOK + varName + ": " + NOMBRE_CAMARA);
     } else if (varName.equals("CHICHARRA")) {
       String filename = dataPath(value);
       File file = new File(filename);
       if (!file.exists()) {
         printAndLog("ERROR: archivo no encontrado. " + filename);
       } else {
         archivoSonidoChicharra = value;
         printAndLog(prefijoMensajeOK + varName + ": " + archivoSonidoChicharra);
       }  
     } else if (varName.equals("RECOMPENSA")) {
       String filename = dataPath(value);
       File file = new File(filename);
       if (!file.exists()) {
         printAndLog("ERROR: archivo no encontrado. " + filename);
       } else {
         archivoSonidoRecompensa = value;
         printAndLog(prefijoMensajeOK + varName + ": " + archivoSonidoRecompensa);
       }  
     } else if (varName.equals("URL")) {
       URL = value;
       printAndLog(prefijoMensajeOK + varName + ": " + URL);
     }  else {
       printAndLog("No asigne nada desde la config. varName: '" + varName + "'");
     }
   }
   
   return resultado;
}

void guardarConfig()
{
  printAndLog("Guardando la config");
  
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

  //lineas.append("");
  //lineas.append("# URL para descontar");
  //lineas.append("URL" + configLineVarValueSep + URL);
  
  saveStrings(dataPath(nombreArchivoLastConfig), lineas.array());
  
  printAndLog("Config guardada en "+dataPath(nombreArchivoLastConfig)); 
}

void draw () {
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
      text("Frame rate: " + int(frameRate), 10, TEXT_SIZE+2);
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
      printAndLog("Audio Chicharra detenido");
    }
    if (sonidoRecompensa.isPlaying()) {
      sonidoRecompensa.stop();
      printAndLog("Audio Recompensa detenido");
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
          printAndLog("Audio Recompensa iniciado");
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
        printAndLog("Audio Chicharra iniciado");
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
    text("Frame rate: " + int(frameRate), 0, 0);
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

void mostrarAyuda() {
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


void dibujarCountourEscalado(Contour contour)
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

void mostrarPuntosRef(ArrayList<PVector> puntosRef)
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

void descontar() {
  printAndLog("Descontando: " + URL);
  
  JSONObject json = loadJSONObject(URL);
  JSONObject valor = json.getJSONObject("value");
  
  printAndLog(json.toString());
  /*
  printAndLog("id: " + valor.getString("_id"));  
  printAndLog("value: " + valor.getInt("value"));
  */  
}

void printAndLog(String linea)
{
  println(linea);
  log(linea);
}

void log(String linea)
{
  FileWriter output = null;
  try {
    output = new FileWriter(dataPath("instalacion.log"), true); //the true will append the new data
    String timestamp = "[ " + year() + "/" + nf(month(),2) + "/" + nf(day(),2) + " " + nf(hour(),2) + ":" + nf(minute(),2) + ":" + nf(second(),2) + " ]";
    output.write(timestamp + "\t" + linea + "\n");
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

void keyPressed(){
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
