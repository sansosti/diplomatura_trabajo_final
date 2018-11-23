// Basado en 'Particles', de Daniel Shiffman.

import processing.sound.*;

ParticleSystem ps;

PImage fondo;

int muertas = 0;

ArrayList<PVector> puntosRef;

float anguloInc = 0.01;

float angulo = 0;

int anchoBanda = 100;

int MAX_MUERTAS = 5000;

int PUNTOS_REF_COUNT = 5;

int CENTRO_DEL_CAMINO;

int MARGEN_MUERTE = 20;

int UMBRAL_DE_INICIO = 50;

float k = 10;

int margen = 150;
  
PVector origenDeParticulas;

PVector puntoRecompensa;

final int INDICE_CAMARA = 15; 

final int DEFAULT_UMBRAL = 50;

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

final int SENTIDO = DERECHA;

boolean yaMori = false;

Sensor sensor;

SoundFile file;

void setup() {
  fullScreen(P2D, 2); 
  //size(640,480,P2D);
  
  orientation(LANDSCAPE);
  
  origenDeParticulas = new PVector((SENTIDO == IZQUIERDA)?width-margen:margen,height/2);
  
  puntoRecompensa = origenDeParticulas.copy();
  
  fondo = loadImage((SENTIDO == IZQUIERDA)?"beckett.jpg":"beckett-derecha.jpg");
  fondo.loadPixels();
  
  ps = new ParticleSystem(10000);

  // Writing to the depth buffer is disabled to avoid rendering
  // artifacts due to the fact that the particles are semi-transparent
  // but not z-sorted.
  hint(DISABLE_DEPTH_MASK);
  
  CENTRO_DEL_CAMINO = height/2;
  
  sensor = new OpenCVCamSensorGrayDiff(this, INDICE_CAMARA);
  
  helpStartTime = millis();
  
  file = new SoundFile(this, "coin_short.wav");
} 

void draw () {
  background(0);
  
  boolean sensorUpdated = sensor.update();
  
  if (calibrationMode) {
    if (sensorUpdated) {
      PImage snapshot = sensor.getSnapshot().get();
      if (snapshot != null) {
        image(snapshot,0,0,width,height);
        text("Frame: " + frameCount, 10, 20);
      }
    }
    
    if (blobDebugMode) {
        text("Mostrando blobs", 10, 40);
        ArrayList<Contour> debugContours = sensor.getContours();
        text("Blobs Encontrados : " + (debugContours != null?debugContours.size():0), 10, 60);
        if ((debugContours != null) && (debugContours.size() != 0)) {          
          for (Contour contour : debugContours) {          
             dibujarCountourEscalado(contour);
             //contour.draw();
          }     
        }      
    }
    
    return;
  }  
  
  angulo+=anguloInc;
  
  puntosRef = new ArrayList<PVector>();
  /*
  puntosRef.add(new PVector(mouseX,mouseY));
  for (int i = 0; i<PUNTOS_REF_COUNT-1; i++) {
    //float newX = mouseX-(i+1)*150+(100*(i%2 == 0?cos(angulo):sin(angulo)));
    float newX = mouseX - (i+1)*100*(k/10);
    if (newX < 0) {
      break;
    }
    puntosRef.add(new PVector(newX,mouseY));
  }
  //puntosRef.add(new PVector(mouseX-150+(100*cos(angulo)),mouseY));
  //puntosRef.add(new PVector(mouseX-150-150+(100*sin(angulo)),mouseY));
  
  if (mouseX <= 10) {
    muertas = 0;
  }
  */
  
  ArrayList<Contour> contours = sensor.getContours();
  
  if ((contours == null) || (contours.size() == 0)) {
    muertas = 0;
    yaMori = false;
    if (file.isPlaying()) {
      file.stop();
      println("Audio detenido");
    }
  } else {
    for (Contour contour : contours) {          
       Rectangle BoundingBox = contour.getBoundingBox();      
       PVector puntoRef = new PVector(BoundingBox.x + ((SENTIDO == IZQUIERDA)?BoundingBox.width:0),BoundingBox.y + BoundingBox.height/2);
       // Convertir puntoRef del sistema de coord de la cámara al de la pantalla
       puntoRef.x = puntoRef.x * (width/sensor.ancho());
       puntoRef.y = puntoRef.y * (height/sensor.alto());
       puntosRef.add(puntoRef);
    }     
  }
  
  ps.update();
  ps.display();
   
  if (mostrarPuntos) {
    stroke(255);
    // Puntos Ref
    for (PVector puntoRef : puntosRef) {
        ellipse((int)puntoRef.x,(int)puntoRef.y,20,20);
    }
  }
  
  // Banda
  /*
  line(0,mouseY-anchoBanda/2,width,mouseY-anchoBanda/2);
  line(0,mouseY+anchoBanda/2,width,mouseY+anchoBanda/2);
  */
  if (puntosRef.size() > 0) {
    PVector ref = new PVector();
    ref = puntosRef.get(0).copy().sub(origenDeParticulas);
    float angulo = PVector.angleBetween(new PVector(ref.x,0),ref);
    
    if (debugMode) {
      pushMatrix();
      //translate(width/2,height/2);
      translate(origenDeParticulas.x,origenDeParticulas.y);
      line(0,0,ref.x,ref.y);
      popMatrix();
      
      //println(ref.x + "," + ref.y);
      pushMatrix();
      pushStyle();
      //rotate(-PI/2 + angulo);
      
      translate(origenDeParticulas.x,origenDeParticulas.y);
      rotate(angulo);
      
      stroke(0,255,0);
      line(0,0,0,100);
      
      /*
      line(0,CENTRO_DEL_CAMINO-anchoBanda/2,width,CENTRO_DEL_CAMINO-anchoBanda/2);
      line(0,CENTRO_DEL_CAMINO+anchoBanda/2,width,CENTRO_DEL_CAMINO+anchoBanda/2);
      */
      
      //line(0,origenDeParticulas.y-anchoBanda/2,origenDeParticulas.x,origenDeParticulas.y-anchoBanda/2);
      //line(0,origenDeParticulas.y+anchoBanda/2,origenDeParticulas.x,origenDeParticulas.y+anchoBanda/2);    
  
      //println(degrees(angulo));
      
      popStyle();
      popMatrix();
    }
  }
  
  // Barra de muertas
  int margenBarra = 120;
  PVector esquinaBarra = new PVector(margenBarra/2,height-50); 
  int altoBarra = 4;
  int anchoBarra = width-margenBarra;
  
  rectMode(CORNER);
  rect(esquinaBarra.x,esquinaBarra.y,anchoBarra,altoBarra);
  
  fill(255,0,0);
  float progreso = map(min(muertas,MAX_MUERTAS),0,MAX_MUERTAS,0,anchoBarra); 
  int rellenoX = (int)((SENTIDO==IZQUIERDA)?esquinaBarra.x:esquinaBarra.x+anchoBarra-progreso);
  rect(rellenoX,esquinaBarra.y,progreso,altoBarra);
  //rect(esquinaBarra.x,esquinaBarra.y,map(min(muertas,MAX_MUERTAS),0,MAX_MUERTAS,0,width-margenDerBarra),altoBarra);
  fill(255);
  
  if (!yaMori) {
    yaMori = (muertas >= MAX_MUERTAS);
    if (yaMori) {
      file.loop();
      println("Audio iniciado");
    }
  }
  
  if (yaMori) {
    fill(255);
    text("CHICHARRAAAA!!!!",esquinaBarra.x,esquinaBarra.y);
  }
  
  if (debugMode) {
    fill(255);
    //textSize(16);
    text("Frame rate: " + int(frameRate), 10, 20);
    text("Mouse (x,y): (" + mouseX + "," + mouseY + ")", 10, 40);
    text("Muertas: " + muertas, 10, 60);
    text("Angulo: " + degrees(angulo),10,80);
    
    pushMatrix(); 
    translate(0,300);
    sensor.displayLegend();
    popMatrix();
    
    // Imagen de 'fondo', si existe (cuadrante 0,1)  
    PImage fondo = sensor.getFondo();
    if (fondo != null) {
      image(fondo,0,400,anchoImagenDebug,((float)(anchoImagenDebug)*sensor.alto())/sensor.ancho());
    } 
    pushMatrix(); 
    translate(sensor.ancho(),400);
    sensor.display();
    popMatrix();
    
    // Rectángulo abarcado por la cámara
    noFill();
    stroke(0,255,0);
    rectMode(CENTER);
    rect(width/2,height/2,width-5, ((float)(width-5)*sensor.alto())/sensor.ancho());
  }
  
  
  if ((millis() - helpStartTime) < (helpDuration*1000)) {
    mostrarAyuda();
  }
  
  //saveFrame("frames/####.png");
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
   PVector puntoRef = new PVector(BoundingBox.x + ((SENTIDO==IZQUIERDA)?BoundingBox.width:0),BoundingBox.y + BoundingBox.height/2);
   // Convertir PVectors del sistema de coord de la cámara al de la pantalla
   centroBlob.x = centroBlob.x * (width/sensor.ancho());
   centroBlob.y = centroBlob.y * (height/sensor.alto());
   
   puntoRef.x = puntoRef.x * (width/sensor.ancho());
   puntoRef.y = puntoRef.y * (height/sensor.alto());
   
   
   stroke(0,255,0);
   noFill();
   rectMode(CENTER);
   rect((int)centroBlob.x,(int)centroBlob.y,20,20);
   rectMode(CORNER);
   
   noStroke();
   fill(255,0,0);
   ellipse((int)puntoRef.x,(int)puntoRef.y,20,20);
  
   popStyle();
}

void keyPressed(){
    sensor.keyPressed();
    
    if(key == 's') {
      saveFrame("captura-######.png");
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
