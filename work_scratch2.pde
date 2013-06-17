

import beads.*;
import com.alderstone.multitouch.mac.touchpad.*;
import java.util.Observer;
import java.util.Observable;


Touchpad touchpad;
AudioContext ac;


PowerSpectrum ps;

color fore = color(255, 255, 255);
color back = color(0, 0, 0);
float j=0;
SamplePlayer sp1;
float i=0;
Gain sampleGain;
Glide gainValue;
float l;
Glide rateValue;
float p;
float v=1;
float q;
float z;
float m=1;
float b=1;
void setup()
{
  noCursor();
  size(800, 600);
  touchpad = new Touchpad(width, height);
  p=1;
  z=1;
  ac = new AudioContext(); 
  try {  
    // initialize the SamplePlayer
    //the name of your song here
    sp1 = new SamplePlayer(ac, new Sample(sketchPath("") + "yoursong"));
  }
  catch(Exception e)
  {
    // if there is an error, show an error message (at the bottom of the processing window)
    println("Exception while attempting to load sample!");
    e.printStackTrace(); // then print a technical description of the error
    exit(); // and exit the program
  }

  // note that we want to play the sample multiple times
  sp1.setKillOnEnd(false);

  rateValue = new Glide(ac, 1, 30); // initialize our rateValue Glide object
  sp1.setRate(rateValue); // connect it to the SamplePlayer

  // as usual, we create a gain that will control the volume of our sample player
  gainValue = new Glide(ac, 0.0, 30);
  sampleGain = new Gain(ac, 1, gainValue);
  sampleGain.addInput(sp1);

  ac.out.addInput(sampleGain); // connect the Gain to the AudioContext
  // in this block of code, we build an analysis chain
  // the ShortFrameSegmenter breaks the audio into short, descrete chunks
  ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
  sfs.addInput(ac.out);

  // FFT stands for Fast Fourier Transform
  // all you really need to know about the FFT is that it lets you see what frequencies are present in a sound
  // the waveform we usually look at when we see a sound displayed graphically is time domain sound data
  // the FFT transforms that into frequency domain data
  FFT fft = new FFT();
  sfs.addListener(fft); // connect the FFT object to the ShortFrameSegmenter

  ps = new PowerSpectrum(); // the PowerSpectrum pulls the Amplitude information from the FFT calculation (essentially)
  fft.addListener(ps); // connect the PowerSpectrum to the FFT

  ac.out.addDependent(sfs);

  ac.start(); // begin audio processing

  background(0); // set the background to black
  stroke(255);

  sp1.setPosition(000); // set the start position to the beginning
  sp1.start(); // play the audio file
}

// although we're not drawing to the screen, we need to have a draw function
// in order to wait for mousePressed events
void draw()
{
  //if (keyPressed == true) {
  // v=1;
  //} else {v=0;}
  float halfHeight = height / 2.0;
  fill(0, 0, 0, 5);
  rect( 0, 0, width, height );
  fill( 0, 53, 255);
  touchpad.draw();
  gainValue.setValue(v); // set the gain based on mouse position along the Y-axis
  if ((p==1)) {
    if (z == 1) {
      z=1;
    } 
    else if (z > 1) { 
      z=z*(6/10);
    }
    else if (z<1 ) {
      z=z+abs(z-1)*4/10;
    }
    m=z*b;
  } 
  else if (z > 4) {
    m=4*b;
  }  
  else if (z < -4) {
    m=-4*b;
  }
  else {
    m=z*b;
  }
  rateValue.setValue(m);

  strokeWeight(2);
  stroke(255);
  // the getFeatures() function is a key part of the Beads analysis library
  // it returns an array of floats
  // how this array of floats is defined (1 dimension, 2 dimensions ... etc) is based on the calling unit generator
  // in this case, the PowerSpectrum returns an array with the power of 256 spectral bands
  float[] features = ps.getFeatures(); // get the data from the PowerSpectrum object

  // if any features are returned
  if (features != null)
  {
    // for each x coordinate in the Processing window
    pushMatrix();
    translate(+width/2, + height/2);
    rotate(radians(i));
    // draw a vertical line corresponding to the frequency represented by this x-position
    for (int r=20; r<2*height/5;r=r+40) {
      if (z>=0) {
        int featureIndex = (r* features.length) / width; // figure out which featureIndex corresponds to this x-position
        int barHeight = Math.min((int)(features[featureIndex] * width), width - 1); // calculate the bar height for this feature
        line(0, r, 0, r+barHeight/16); // draw on screen
      } 
      else {
        line(0, r, 0, r+1);
      }
    }
    popMatrix();
    i=i+m;
    if (i>360) {
      i=0;
    }
  }
}
void keyPressed () {

  if ( keyCode==38) {
    b=b+0.01;
  }  
  if ( keyCode==40) {
    b=b-0.01;
  }
}




class Touchpad implements Observer {

  private static final int MAX_FINGER_BLOBS = 20;

  private int width, height;

  TouchpadObservable tpo;

  Finger blobs[] = new Finger[MAX_FINGER_BLOBS];


  public Touchpad(int width, int height) {	
    this.width = width;
    this.height=height;
    tpo = TouchpadObservable.getInstance();
    tpo.addObserver(this);
  }

  // Multitouch update event 
  public void  update( Observable obj, Object arg ) {
    // The event 'arg' is of type: com.alderstone.multitouch.mac.touchpad.Finger
    Finger f = (Finger) arg;
    int id = f.getID();
    if (id <= MAX_FINGER_BLOBS)
      blobs[id-1]= f;
  }	

  public void update() {
  }
  public void draw() {
    q=0;

    for (int i=0; i<MAX_FINGER_BLOBS;i++) {
      Finger f = blobs[i];

      if (f != null && f.getState() == FingerState.PRESSED) {

        z=-((height * (1-f.getY()))-l)/6;
        l=(height * (1-f.getY()));



        q=q+1;
        int x     = (int) (width  * (f.getX()));
        int y     = (int) (height * (1-f.getY()));
        int xsize = (int) (10*f.getSize() * (f.getMajorAxis()/2));
        int ysize = (int) (10*f.getSize() * (f.getMinorAxis()/2));
        int ang   = f.getAngle();
      }

      if (q!=0) {
        p=0;
      }
      else {
        p=1;
      }
    }
  }
}











