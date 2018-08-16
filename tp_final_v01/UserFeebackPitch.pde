import ddf.minim.*;
import ddf.minim.ugens.*;

//final String AUDIO_FILE = "coin.mp3";
//final String AUDIO_FILE = "coin_short.wav";
final String UF_PITCH_AUDIO_FILE = "coin_short.mp3";

final float MAX_RATE = 0.96;
final float MIN_RATE = 0.7;

abstract class UserFeedbackPitch
{
  PApplet parent;
  OpenCVSensor sensor;
  
  float totalContourArea = 0;
  
  float rate = 0.f;
   
  int currentPosY;
  
  int modo = MODO_SILENCIO;
  
  int playStack = 0;
  
  Minim minim;
  AudioPlayer player;
  
  TickRate rateControl;
  FilePlayer filePlayer;
  AudioOutput out;

  abstract String getNombre();  
  abstract void displayCustomLegend();  
  abstract float getRate();
  
  UserFeedbackPitch(PApplet theParent, OpenCVSensor ASensor) {
    parent = theParent;
    sensor = ASensor;
  
    // create our Minim object for loading audio
    minim = new Minim(parent);
                                 
    // this opens the file and puts it in the "play" state.                           
    filePlayer = new FilePlayer( minim.loadFileStream(AUDIO_FILE) );
    // and then we'll tell the recording to loop indefinitely
    filePlayer.loop();
    
    // this creates a TickRate UGen with the default playback speed of 1.
    // ie, it will sound as if the file is patched directly to the output
    rateControl = new TickRate(rate);
    
    // get a line out from Minim. It's important that the file is the same audio format 
    // as our output (i.e. same sample rate, number of channels, etc).
    out = minim.getLineOut();
    
    // patch the file player through the TickRate to the output.
    filePlayer.patch(rateControl).patch(out);    
  
    rateControl.setInterpolation(true);
    
  }
   
  void update() {
    rate = getRate();
       
    rateControl.value.setLastValue(rate);
  }
  
  
    
  void output() {
    
  }
   
  void displayLegend() {
        
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
    rect(0,currentPosY,map(rate,0,1,0,anchoBarra),altoBarra);
    
    currentPosY+=altoBarra;
    
    stroke(0,255,0);
    fill(0,255,0);
    text("PlayStack: " + playStack,0,currentPosY+=POS_Y_STEP);
    text("TickRate.value: " + rateControl.value.getLastValue(),0,currentPosY+=POS_Y_STEP);
    text("isInterpolating?: " + (rateControl.isInterpolating()?"yes":"no"),0,currentPosY+=POS_Y_STEP);
    
    displayCustomLegend();
    
    popStyle();
  }  
  
  void displayLegendDiv() {
    text("------------------",0,currentPosY+=POS_Y_STEP);
  }
}
