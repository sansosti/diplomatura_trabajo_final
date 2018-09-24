//final int INDICE_CAMARA = 3;
final int INDICE_CAMARA = 18;
  
final int ALTO = 400;
final int ANCHO = 640;
final int DEFAULT_UMBRAL = 50;

final int MARGEN = 10;
final int POS_Y_STEP = 15;

UserFeedback uf;
Sensor sensor;

void settings() {
  size((ANCHO+MARGEN)*4, (ALTO+MARGEN)*4);
}

void setup() {
  //fullScreen();

  //sensor = new OpenCVSensorBackgroundSustraction(this, ANCHO, ALTO, INDICE_CAMARA);
  sensor = new OpenCVCamSensorGrayDiff(this, ANCHO, ALTO, INDICE_CAMARA);
  //sensor = new OpenCVKinectSensor(this);
 
  uf = new UFPitchSumaDistancias(this, sensor);
}

void draw() {
  background(0,0,0);

  sensor.update();  
  uf.update();

  // Imagen de la cámara en vivo (cuadrante 0,0)
  PImage snapshot = sensor.getSnapshot();
  if (snapshot == null) {
    return;
  }   
  image(snapshot, 0, 0);


  // Imagen de 'fondo', si existe (cuadrante 0,1)  
  PImage fondo = sensor.getFondo();
  if (fondo != null) {
    image(fondo,sensor.ancho() + MARGEN,0);
  } 
    
  // Cuadrante 1,0 
  pushMatrix(); 
  translate(0,sensor.alto() + MARGEN);
  // Display gráfico del Sensor
  sensor.display();
  // Display gráfico del UserFeedback (NO es el feedback, eso sería el 'output')
  uf.display();
  popMatrix();
  
  // Cuadrante 1,1
  // Mostrar Leyenda del Sensor
  pushMatrix(); 
  translate(sensor.ancho() + MARGEN, sensor.alto() + MARGEN);
  sensor.displayLegend();
  popMatrix();          
  // Mostrar Leyenda del Feedback
  pushMatrix(); 
  translate(sensor.ancho() + MARGEN, sensor.alto() + MARGEN + 200);
  uf.displayLegend();  
  popMatrix();
  
  // Hace output del Feedback (audio)
  uf.output();
}

void keyPressed(){
    sensor.keyPressed();
    uf.keyPressed();
    
    if(key == 's') {
      saveFrame("captura-######.png");
    }
}  
