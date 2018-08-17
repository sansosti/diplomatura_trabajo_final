class UFPitchSumaDistancias extends UserFeedbackPitch 
{  
  ArrayList<Contour> contours;
  ArrayList<Point> centros;
  int cercanos[];
  
  float distanciaBase, distanciaTotal;
  
  UFPitchSumaDistancias(PApplet theParent, OpenCVSensor ASensor) {
    super(theParent, ASensor);  
    
    distanciaBase = sensor.ancho()+sensor.alto();
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
     contours = sensor.getContours();
    
    if (contours == null) {
      return 0.f;
    }
       
    centros = new ArrayList<Point>();
   
    for (Contour contour : contours) {          
      Rectangle BoundingBox = contour.getBoundingBox();      
      centros.add(new Point(BoundingBox.x + BoundingBox.width/2,BoundingBox.y + BoundingBox.height/2));      
    }    
    
    cercanos = new int[centros.size()];
    
    distanciaTotal = 0.0;
    
    for (int i=0; i < centros.size(); i++) {
      double minDistancia = 0.0;
      cercanos[i] = i;
      // Distancia al más cercano
      for (int j=0; j < centros.size(); j++) {
        if (i==j) {
          continue;
        }
        double distancia = centros.get(i).distance(centros.get(j));
        if ((minDistancia == 0.0) || (distancia < minDistancia)) {
            minDistancia = distancia;
            cercanos[i] = j;
        }
      }
      
      distanciaTotal += minDistancia;          
    }
     
    if (contours.size() == 0 ) {
      return 0.f;
    } else if (contours.size() == 1) {
      return 1.f;
    } else {
      return min(map(distanciaTotal, 0, distanciaBase, MAX_RATE, MIN_RATE),1.f);
    }       
    
  }
  
  void displayCustomLegend() {
    
    super.displayCustomLegend();
    
    displayLegendDiv();
    
    text("Contours: " + contours.size(),0,currentPosY+=POS_Y_STEP);
    text("Distancia: " + String.format("%4.0f",distanciaTotal) + " (" + String.format("%2.0f", (distanciaTotal/distanciaBase)*100.0) + "% de " + round(distanciaBase) + ")",0,currentPosY+=POS_Y_STEP);
    text("Distancia Base: " + round(distanciaBase),0,currentPosY+=POS_Y_STEP);
    
  }
  
  void display() {
       
    for (Contour contour : contours) {
      noFill();
           
      // Blob           
      stroke(255, 0, 0);
      strokeWeight(1);
      contour.draw();
      
      // Box
      Rectangle BoundingBox = contour.getBoundingBox();
      stroke(0, 255, 0);
      strokeWeight(1);      
      rect(BoundingBox.x, BoundingBox.y, BoundingBox.width, BoundingBox.height);
    }
           
    // Centros unidos
    for (int i=0; i < centros.size(); i++) {
      Point centro = centros.get(i);
      stroke(0, 255, 0);
      strokeWeight(1); 
      fill(0,255,0);
      ellipse(centro.x,centro.y,10,10);
      
      Point centroCercano = centros.get(cercanos[i]);
      line(centro.x,centro.y,centroCercano.x,centroCercano.y);
    }   
  }  
}
