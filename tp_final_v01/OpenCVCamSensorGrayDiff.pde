class OpenCVCamSensorGrayDiff extends OpenCVCamSensor {
   
  PImage grayDiff;

  int tramos = 3;
     
  OpenCVCamSensorGrayDiff(PApplet theParent, int ancho, int alto, int indiceCamara) {
    super(theParent, ancho, alto, indiceCamara);
    
    grayDiff = null;

  }
  
  String getNombre() {
    return "Gray Diff";
  }  
  
  boolean update() {
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
  
  void display() {
    image(grayDiff, 0, 0);
   
    ArrayList<Point> centros = new ArrayList<Point>(); 
   
    for (Contour contour : contours) {
      noFill();
      
      float area = contour.area();
      
      stroke(255, 0, 0);
      strokeWeight(3);
      contour.draw();
      /*
      Rectangle BoundingBox = contour.getBoundingBox();

      stroke(0, 255, 0);
      strokeWeight(1);      
      rect(BoundingBox.x, BoundingBox.y, BoundingBox.width, BoundingBox.height);
      text((int)area,BoundingBox.x, BoundingBox.y);
      
      centros.add(new Point(BoundingBox.x + BoundingBox.width/2,BoundingBox.y + BoundingBox.height/2));
      */
    }

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
  
  void displayCustomLegend() {     
    super.displayCustomLegend();
    
    text("<espacio> para recargar el fondo",0,currentPosY+=POS_Y_STEP);
    
  }
  
  void multibezier(Point inicio, Point fin,int tramos)
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
   
  void resetFondo() {
    fondo = null;
  }
  
  void keyPressed() {
    super.keyPressed();
      
    if (key == ' ') {
      resetFondo();
    }    
  }
    
}
