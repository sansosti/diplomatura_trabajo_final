class UFContourAreaRatio extends UserFeedback 
{
  
  UFContourAreaRatio(PApplet theParent, OpenCVSensor ASensor) {
    super(theParent, ASensor);    
  }
  
  String getNombre() {
    return "ContourArea Ratio";
  }
  
  /**
    Calcula la frecuencia de acuerdo al 'ratio' entre el área total de todos los contours
    y el área total del sensor.
    
    A más área de contours, más alta frecuencia
  */
  void customUpdate() {
    ArrayList<Contour> contours = sensor.getContours();
    
    if (contours == null) {
      freq = 0.0;
      modo = MODO_SILENCIO;
      return;
    }
    
    totalContourArea = 0;
    for (Contour contour : contours) {
      totalContourArea += contour.area();
    }
    
    freq = map(totalContourArea, 0, sensor.ancho()*sensor.alto(), MIN_FREQ, MAX_FREQ);
    
    if (freq < MIN_AUDIBLE_FREQ) {
      modo = MODO_SILENCIO;
    } else {
      modo = MODO_OSC;
    }
  }
  
  void displayCustomLegend() {
    
    displayLegendDiv();
    
    text("ContourArea: " + totalContourArea,0,currentPosY+=POS_Y_STEP);
    text("TotalArea: " + sensor.ancho()*sensor.alto(),0,currentPosY+=POS_Y_STEP);
    text("ContourArea/TotalArea: " + (totalContourArea>0?totalContourArea/(sensor.ancho()*sensor.alto()):0), 0,currentPosY+=POS_Y_STEP);
    
  }
}
