//final int INDICE_CAMARA = 3;
final int INDICE_CAMARA = 18;
  
final int ALTO = 400;
final int ANCHO = 640;
final int DEFAULT_UMBRAL = 50;

final int MARGEN = 10;
final int POS_Y_STEP = 15;

UserFeedback uf;
Sensor sensor;

/*
void settings() {
  size((ANCHO+MARGEN)*4, (ALTO+MARGEN)*4);
}
*/

void setup() {
  fullScreen();

  //sensor = new OpenCVSensorBackgroundSustraction(this, ANCHO, ALTO, INDICE_CAMARA);
  sensor = new OpenCVSensorGrayDiff(this, ANCHO, ALTO, INDICE_CAMARA);
  //sensor = new KinectSensor(this, ANCHO, ALTO);
 
  uf = new UFPitchSumaDistancias(this, sensor);
}

void draw() {
  background(0,0,0);

  sensor.update();  
  uf.update();

  // Obtener y dibujar 'snapshot'
  PImage snapshot = sensor.getSnapshot();
  
  if (snapshot == null) {
    return;
  }
  
  image(snapshot, 0, 0);

  // Obtener y dibujar 'fondo', si existe  
  PImage fondo = sensor.getFondo();
  
  if (fondo != null) {
    image(fondo,sensor.ancho() + MARGEN,0);
  } 
 
  // Display gráfico del Sensor 
  pushMatrix(); 
  translate(0,sensor.alto() + MARGEN);
  sensor.display();
  popMatrix();
  
  // Display gráfico del UserFeedback (NO es el feedback, eso sería el 'output') 
  pushMatrix(); 
  translate(0,sensor.alto() + MARGEN);
  uf.display();
  popMatrix();

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
  
  // Hace output del Feedback
  uf.output();
}

void keyPressed(){
    sensor.keyPressed();
    uf.keyPressed();
    
    if(key == 's') {
      saveFrame("captura-######.png");
    }
}  
