import processing.sound.*;
SinOsc osc;
SoundFile file;

final int MIN_AUDIBLE_FREQ = 50;

final int MIN_FREQ = 0;
final int MAX_FREQ = 2000;

final int MODO_SILENCIO = 0;
final int MODO_OSC = 1;
final int MODO_FILE = 2;

final String[] modoNames = {"Silencio","OSC","File"};

abstract class UserFeedback
{
  PApplet parent;
  OpenCVSensor sensor;
  float freq = 0;
  boolean isOSCPlaying = false;
  boolean isFilePlaying = false;
  
  float totalContourArea = 0;
  
  int currentPosY;
  
  int modo = MODO_SILENCIO;
  
  int playStack = 0;

  abstract String getNombre();  
  abstract void displayCustomLegend();  
  abstract void customUpdate();
  
  UserFeedback(PApplet theParent, OpenCVSensor ASensor) {
    parent = theParent;
    sensor = ASensor;
    
    osc = new SinOsc(parent);
    file = new SoundFile(parent, "coin.mp3");
    //file = new SoundFile(parent, "coin_short.wav");
    
  }
   
  void update() {
    customUpdate();
    
    if (modo == MODO_OSC) {
      osc.freq(freq);
    }
  }
    
  void output() {
    
    switch (modo) {
        case MODO_OSC:
              if (freq < MIN_AUDIBLE_FREQ) {
                toggleOSC(false);
              } else {
                toggleOSC(true);
              };
              toggleFile(false);
              break;
        case MODO_FILE:
              toggleOSC(false);
              toggleFile(true);
              break;
        case MODO_SILENCIO:
              toggleOSC(false);
              toggleFile(false);
              break;
    }
    
  }
  
  void toggleOSC(boolean play) {
    if (play == isOSCPlaying) {
      return;
    }
    
    if (play) {
      osc.play();
    } else {
      osc.stop();
    }  
    
    isOSCPlaying = play;
    
  }
 
  void toggleFile(boolean play) {

    if (play) {
      if (!isFilePlaying) {
        file.loop();
        //file.amp(1.0);
        playStack++;
        isFilePlaying = true;
      }
    } else {
      if (isFilePlaying) {
        file.stop();
        //file.amp(0);
        playStack--;
        isFilePlaying = false;
      }
    }  
 
  }
  
  void displayLegend() {
   
    String OSCMessage = (isOSCPlaying?"Playing":"Stopped");
    String FileMessage = (isFilePlaying?"Playing":"Stopped");
      
    currentPosY = 0;
    
    int anchoBarra = sensor.ancho() - 20;
    int altoBarra = 20;
    
    pushStyle();
            
    fill(255, 0, 0);
    text("Feedback: " + getNombre(),0,currentPosY+=POS_Y_STEP);
    
    currentPosY+=5;
    
    stroke(255,255,255);
    noFill();
    rect(0,currentPosY,anchoBarra,20);
    fill(255,255,255);
    rect(0,currentPosY,map(freq,MIN_FREQ,MAX_FREQ,0,anchoBarra),altoBarra);
    
    currentPosY+=altoBarra;
    
    stroke(0,255,0);
    fill(0,255,0);
    text("Freq: " + freq,0,currentPosY+=POS_Y_STEP);
    text("Estado OSC: " + OSCMessage,0,currentPosY+=POS_Y_STEP);
    text("Estado File: " + FileMessage,0,currentPosY+=POS_Y_STEP);
    text("Modo: " + modoNames[modo],0,currentPosY+=POS_Y_STEP);
    text("PlayStack: " + playStack,0,currentPosY+=POS_Y_STEP);
    
    displayCustomLegend();
    
    popStyle();
  }  
  
  void displayLegendDiv() {
    text("------------------",0,currentPosY+=POS_Y_STEP);
  }
}
