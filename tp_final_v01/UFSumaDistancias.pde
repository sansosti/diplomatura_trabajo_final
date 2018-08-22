class UFSumaDistancias extends UserFeedbackOSCAndSound 
{
  
  int totalContours;
  float distanciaTotal;
  
  UFSumaDistancias(PApplet theParent, Sensor ASensor) {
    super(theParent, ASensor);    
  }
  
  String getNombre() {
    return "Suma de Distancias";
  }
  
  /**
    1. Si no hay ningún Contour => silencio
    2. Si hay uno sólo => sonido placentero
    3. Si hay más de uno, calcula la frecuencia de acuerdo la suma de las 
      distancias de los contours. (Del centro de cada contour al centro 
      del siguiente). 
      A mayor distancia, más alta frecuencia (menos placentero).
  */
  void update() {
    ArrayList<Contour> contours = sensor.getContours();
    
    if (contours == null) {
      freq = 0.0;
      modo = MODO_SILENCIO;
      return;
    }
       
    ArrayList<Point> centros = new ArrayList<Point>(); 
   
    for (Contour contour : contours) {          
      Rectangle BoundingBox = contour.getBoundingBox();      
      centros.add(new Point(BoundingBox.x + BoundingBox.width/2,BoundingBox.y + BoundingBox.height/2));      
    }    
    
    distanciaTotal = 0.0;
    totalContours = contours.size();
    
    for (int i=0; i < centros.size(); i++) {
      Point centro = centros.get(i);
      if (i+1 < centros.size()) {
          distanciaTotal += centro.distance(centros.get(i+1));          
      }
    }
    
    if (contours.size() == 0 ) {
      freq = 0.0;
      modo = MODO_SILENCIO;
    } else if (contours.size() == 1) {
      modo = MODO_FILE;
      /*
      freq = 220; // 'la' central
      modo = MODO_OSC;
      */
    } else {
      freq = map(distanciaTotal, 0, sensor.ancho()+sensor.alto(), MIN_FREQ, MAX_FREQ);
      modo = MODO_OSC;
    }       
    
    super.update();
  }
  
  void displayCustomLegend() {
    
    displayLegendDiv();
    
    text("Contours: " + totalContours,0,currentPosY+=POS_Y_STEP);
    text("Distancia: " + distanciaTotal,0,currentPosY+=POS_Y_STEP);
    
  }
}
