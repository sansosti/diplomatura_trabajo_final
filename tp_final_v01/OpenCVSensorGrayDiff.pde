class OpenCVSensorGrayDiff extends OpenCVSensor {

   
  PImage fondo, grayDiff;
  
  int minContourArea = 4000;
  int tramos = 3;
  
  final int AREA_STEP = 1000;  
  
  OpenCVSensorGrayDiff(PApplet theParent, int ancho, int alto) {
    super(theParent, ancho, alto);
    
    fondo = null;
    grayDiff = null;

  }
  
  String getNombre() {
    return "Gray Diff";
  }  
  
  boolean update(PImage img) {
    if (!super.update(img)) {
      return false;
    }
    
    if (fondo == null) {
      fondo = new PImage(img.width, img.height);
      fondo = img.get();
      //fondo.filter(GRAY);
    }
    
    opencv.loadImage(img);
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
      Rectangle BoundingBox = contour.getBoundingBox();

      stroke(0, 255, 0);
      strokeWeight(1);      
      rect(BoundingBox.x, BoundingBox.y, BoundingBox.width, BoundingBox.height);
      text((int)area,BoundingBox.x, BoundingBox.y);
      
      centros.add(new Point(BoundingBox.x + BoundingBox.width/2,BoundingBox.y + BoundingBox.height/2));
      
      /*
      strokeWeight(1);
      stroke(0, 255, 0);
      beginShape();
      for (PVector point : contour.getPolygonApproximation().getPoints()) {
        vertex(point.x, point.y);
      }
      endShape();
      */
    }
        
    /*
    centros = new ArrayList<Point>();
    centros.add(new Point(10,10));
    centros.add(new Point(200,100));
    */
    
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
      
      /*
      for (int j=i+1; j < centros.size(); j++) {
        noFill();
        Point otroCentro = centros.get(j);
        //multibezier(centro,otroCentro,tramos);
        /*
        Point control1 = new Point(centro.x-100,centro.y+50);        
        Point control2 = new Point(otroCentro.x+100,otroCentro.y-50);
        bezier(centro.x,centro.y,control1.x,control1.y,control2.x,control2.y,otroCentro.x,otroCentro.y);
        ///
        
        /*
        stroke(255, 0, 0);
        line(centro.x,centro.y,otroCentro.x,otroCentro.y);
        //
      }   
      */
    }   
  }
  
  void displayCustomLegend() {     
    
    text("Min. Area (+/- para cambiar) : " + minContourArea,0,currentPosY+=POS_Y_STEP);   
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
  
  PImage getFondo() {
    return fondo;
  }
  
  void resetFondo() {
    fondo = null;
  }
  
  void keyPressed() {
    super.keyPressed();
    
    if(key == '+') {
      minContourArea = minContourArea + AREA_STEP;
      //tramos++;
    }
    
    if(key == '-') {
      minContourArea = minContourArea - AREA_STEP;
      /*
      tramos--;
      if (tramos < 1 ) {
        tramos = 1;
      }
      */
    }  
    
    if (key == ' ') {
      resetFondo();
    }    
  }
    
}
