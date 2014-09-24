import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

AudioInput microphone;
final float CLAP_LEVEL = 0.1f; // loudness threshold from 0 to 1
float lastMicLevel = 0.0f;
FFT fft;
float lastClap = 0.0f;

AudioPlayer sound;
AudioPlayer countDown;
Minim minim; 
Minim minim2;  

float timeToWait; 
float timeBegan; 
boolean isPaused; 

boolean started =false;

void letsRoll() {
  if (started)
    return;
  started = true;

  timeToWait = 5000; 
  timeBegan = millis();

  countDown.play(); 
  sound.loop(); 
  sound.pause(); 


  isPaused = true;

  println ("wait for: " + timeToWait);
}

void setup() {
  minim = new Minim(this);
  microphone = minim.getLineIn(Minim.MONO, 4096, 44100);
  fft = new FFT(microphone.left.size(), 44100);
  minim2 = new Minim(this); 
  sound = minim.loadFile("track.mp3");
  countDown = minim2.loadFile("countDown.mp3"); 
}

void onClap() {
  //  println("Clap");
  if (millis() - lastClap <= 750) {
    println("Double clap!");
    letsRoll();
  }
  lastClap = millis();
  //  println(millis());
  //  println("You clapped!");
}

void draw() {

  if ((millis() - timeBegan) >= timeToWait && started) {
    if (isPaused) {
      sound.loop(); 
      isPaused = false;
    }
    else {
      sound.pause();
      isPaused = true;
    }
    timeToWait = random (5000, 15000); 
    timeBegan = millis();
    println ("wait for: " + timeToWait);
  }

  float currentMicLevel = microphone.mix.level();
  if (currentMicLevel >= CLAP_LEVEL && currentMicLevel > lastMicLevel)
  {
    fft.forward(microphone.left);
    int max = fft.specSize();
    int sum = 0;
    for (int i = max / 2; i < max; i++) {
      sum += fft.getBand(i);
    }

    if (sum > 50) {
      onClap();
    }
  }
  lastMicLevel = currentMicLevel;
}

