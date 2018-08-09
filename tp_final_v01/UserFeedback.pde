import processing.sound.*;
SinOsc osc;

final int MIN_AUDIBLE_FREQ = 100;

final int MIN_FREQ = 0;
final int MAX_FREQ = 2000;

class UserFeedback
{
  PApplet parent;
  OpenCVSensor sensor;
  float freq = 0;
  boolean isPlaying = false;
  
  float totalContourArea = 0;
  
  UserFeedback(PApplet theParent, OpenCVSensor ASensor) {
    parent = theParent;
    sensor = ASensor;
    
    osc = new SinOsc(parent);
    //osc.play();    
  }
  
  void update() {
    ArrayList<Contour> contours = sensor.getContours();
    
    if (contours == null) {
      return;
    }
    
    totalContourArea = 0;
    for (Contour contour : contours) {
      totalContourArea += contour.area();
    }
    
    freq = map(totalContourArea, 0, sensor.ancho()*sensor.alto(), MIN_FREQ, MAX_FREQ);
    
    osc.freq(freq);
  }
  
  void display() {
    String message;
    
    if (freq < MIN_AUDIBLE_FREQ) {
      if (isPlaying) {
        osc.stop();
        isPlaying = false;        
      }
      message = "Stopped";
    } else {
      if (!isPlaying) {
        osc.play();
        isPlaying = true;
      }
      message = "Playing";
    }
    
    int y = 20;
    
    int anchoBarra = sensor.ancho() - 20;
    stroke(255,255,255);
    noFill();
    rect(20,y,anchoBarra,20);
    fill(255,255,255);
    rect(20,y,map(freq,MIN_FREQ,MAX_FREQ,0,anchoBarra),20);
    stroke(0,255,0);
    fill(0,255,0);
    y+=20;
    text("Freq: " + freq, 20, y+=20);
    text("Estado: " + message, 20, y+=20);
    text("ContourArea: " + totalContourArea, 20,y+=20);
    text("TotalArea: " + sensor.ancho()*sensor.alto(), 20,y+=20);
    text("ContourArea/TotalArea: " + (totalContourArea>0?totalContourArea/(sensor.ancho()*sensor.alto()):0), 20,y+=20);
  }
}
