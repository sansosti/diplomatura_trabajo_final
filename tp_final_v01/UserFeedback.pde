abstract class UserFeedback
{
  PApplet parent;
  Sensor sensor;

  int currentPosY;
  
  abstract String getNombre();  
  abstract void displayCustomLegend();  
  
  UserFeedback(PApplet theParent, Sensor ASensor) {
    parent = theParent;
    sensor = ASensor;
  }
   
  void update() {
  }
  
  void display() {
  }
  
  void output() {      
  }
  
  void keyPressed() {
  }

  void displayLegend() {
        
    currentPosY = 0;
      
    pushStyle();
            
    fill(255, 0, 0);
    text("Feedback: " + getNombre(),0,currentPosY+=POS_Y_STEP);
    
    currentPosY+=5;
        
    displayCustomLegend();
    
    popStyle();
  }  
  
  void displayLegendDiv() {
    text("------------------",0,currentPosY+=POS_Y_STEP);
  }
}
