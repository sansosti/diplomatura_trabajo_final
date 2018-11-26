// Basado en 'Particles', de Daniel Shiffman.

import processing.sound.*;

ParticleSystem ps;

final int CANT_PARTICULAS = 10000;

PImage fondo;

int muertas = 0;

ArrayList<PVector> puntosRef;

ArrayList<PVector> puntosRefVirtuales;

int anchoBanda = 100;

int MAX_MUERTAS = 25000;

int PUNTOS_REF_COUNT = 5;

int CENTRO_DEL_CAMINO;

int MARGEN_MUERTE = 20;

int UMBRAL_DE_INICIO = 50;

float k = 10;

int margen = 150;
  
PVector origenDeParticulas;

PVector puntoRecompensa;

final int INDICE_CAMARA = 15; 

final int DEFAULT_UMBRAL = 40;// 50;

final int POS_Y_STEP = 15;

boolean debugMode = false;

boolean calibrationMode = false;

int anchoImagenDebug = 320;

int helpStartTime;

int helpDuration = 10; // Duracion de la leyenda de ayuda, en segundos

boolean blobDebugMode = false;

boolean mostrarPuntos = false;

final int IZQUIERDA = 0;

final int DERECHA = 1;

final String imagenesFondo[] = { "beckett.jpg", "beckett-derecha.jpg" };

final int SENTIDO = DERECHA;

final String archivoSonidoChicharra = "alarma_submarino.wav";

final String archivoSonidoRecompensa = "coin_short.wav";

boolean yaMori = false;

boolean yaGane = false;

int UMBRAL_RECOMPENSA = 100;

Sensor sensor;

SoundFile sonidoChicharra;

SoundFile sonidoRecompensa;

void setup() {
  fullScreen(P2D, 2); 
  //size(640,480,P2D);
   
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
  
  sensor = new OpenCVCamSensorGrayDiff(this, INDICE_CAMARA);
  
  helpStartTime = millis();
  
  sonidoChicharra = new SoundFile(this, archivoSonidoChicharra);
  sonidoRecompensa = new SoundFile(this, archivoSonidoRecompensa);
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
      text("Frame rate: " + int(frameRate), 10, 20);
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
       PVector puntoRef = new PVector(BoundingBox.x + ((SENTIDO == IZQUIERDA)?BoundingBox.width+50:-50),BoundingBox.y + BoundingBox.height/2);
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
      text("Mostrando blobs", 10, 40);
      text("Blobs Encontrados : " + (contours != null?contours.size():0), 10, 60);
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
    //rect(esquinaBarra.x,esquinaBarra.y,map(min(muertas,MAX_MUERTAS),0,MAX_MUERTAS,0,width-margenDerBarra),altoBarra);
    fill(255); 
    /**
      Actualizar yaMori, e iniciar chicharra si es necesario
    */
    if (!yaMori) {
      yaMori = (muertas >= MAX_MUERTAS);
      if (yaMori) {
        sonidoChicharra.loop();
        println("Audio Chicharra iniciado");
      }
    }
    
    if (yaMori) {
      fill(255);
      text("CHICHARRAAAA!!!!",esquinaBarra.x,esquinaBarra.y);
    }
  }
  
  if (debugMode) {
    pushMatrix();
    pushStyle();
    fill(255);
    //textSize(16);    
    translate(10,200);
    text("Frame rate: " + int(frameRate), 0, 0);
    text("Mouse (x,y): (" + mouseX + "," + mouseY + ")", 0, 20);
    text("Muertas: " + muertas, 0, 40);
    popStyle();
    popMatrix();
    
    pushMatrix(); 
    translate(10,260);
    sensor.displayLegend();
    popMatrix();   
  }
  
  /**
    Mostrar Ayuda
  */
  if ((millis() - helpStartTime) < (helpDuration*1000)) {
    mostrarAyuda();
  }
  
}

void mostrarAyuda() {
  pushMatrix();
  pushStyle();
  
  translate(10,20);
  fill(0,255,0);
  int x=0;
  int y=0;
  int step=20;
  text("(s): capturar frame",x,y+=step);
  text("(d): modo debug",x,y+=step);
  text("(c): calibrar camara",x,y+=step);
  text("(b): debug blobs",x,y+=step);
  text("(p): mostrar puntos",x,y+=step);
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
  /**
    Copia y modificación del método Contour.draw() https://github.com/atduskgreg/opencv-processing/blob/master/src/gab/opencv/Contour.java
    ya que el método original (y el arreglo de puntos) es privado 
  */
  /*
  ArrayList<PVector> puntos = contour.getPoints();
  
  strokeWeight(1);
  this.beginShape();
  for (PVector p : puntos) {
    this.vertex(p.x * (width/sensor.ancho()), p.y * (height/sensor.alto()));
  }
  this.endShape(PConstants.CLOSE);
  */
  
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
   /*
   rectMode(CENTER);
   rect((int)centroBlob.x,(int)centroBlob.y,10,10);
   rectMode(CORNER);
   */
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

void keyPressed(){
    sensor.keyPressed();
    
    if(key == 's') {
      saveFrame("frames/captura-######.png");
    }
    
    if (key == 'a') {
      k--;
    }
    
    if (key == 'z') {
      k++;
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
}  
