class UFPitchSumaDistancias extends UserFeedbackPitch 
{
  
  int totalContours;
  float distanciaTotal;
  
  UFPitchSumaDistancias(PApplet theParent, OpenCVSensor ASensor) {
    super(theParent, ASensor);    
  }
  
  String getNombre() {
    return "Suma de Distancias - Pitch";
  }
  
  /**
    1. Si no hay ningún Contour => silencio
    2. Si hay uno sólo => sonido placentero
    3. Si hay más de uno, calcula la frecuencia de acuerdo la suma de las 
      distancias de los contours. (Del centro de cada contour al centro 
      del siguiente). 
      A mayor distancia, más alta frecuencia (menos placentero).
  */
 float getRate() {
    ArrayList<Contour> contours = sensor.getContours();
    
    if (contours == null) {
      return 0.f;
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
      return 0.f;
    } else if (contours.size() == 1) {
      return 1.f;
    } else {
      return min(map(distanciaTotal, sensor.ancho()+sensor.alto(), 0, MAX_RATE, MIN_RATE),1.f);
    }       
    

  }
  
  void displayCustomLegend() {
    
    displayLegendDiv();
    
    text("Contours: " + totalContours,0,currentPosY+=POS_Y_STEP);
    text("Distancia: " + distanciaTotal,0,currentPosY+=POS_Y_STEP);
    
  }
}
