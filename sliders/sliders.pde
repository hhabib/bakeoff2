import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import controlP5.*;


//these are variables you should probably leave alone
int index = 0;
int trialCount = 8; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;

float bx;
float by;
boolean overBox = false;
boolean locked = false;
float xOffset = 0.0; 
float yOffset = 0.0; 

boolean hasCenterCorrect;
boolean hasRotationCorrect;
boolean hasSizeCorrect;

// Slider variables
ControlP5 cp5;
Slider abc;

// Color palette
color transparent     = color(0, 0);

color white           = color(238);
color whitetrans      = color(238, 70);

color darkgray        = color(32);

color black           = color(0, 150);
color blacktrans      = color(0, 100);
color blacklightrans  = color(0, 50);

color red             = color(166, 43, 12);

color blue            = color(0, 64, 133);
color bluetrans       = color(0, 64, 133, 120);
color brightblue      = color(26, 136, 255);
color brightbluetrans = color(26, 136, 255, 120);

color green           = color(0, 255, 0);
color greentrans      = color(68, 163, 0, 120);

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

float inchesToPixels(float inch)
{
  return inch*screenPPI;
}

void setup() {
  size(700,700); 
  bx = 0;
  by = 0;
  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.2f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);
  cp5 = new ControlP5(this);

  //don't change this! 
  border = inchesToPixels(.2f); //padding of 0.2 inches
  
  //instantiate sliders for controls
  // add a vertical slider
  cp5.addSlider("screenRotation")
     .setPosition(18,50)
     .setRange(-90,90)
     ;
     
  cp5.addSlider("screenZ")
     .setPosition(18,75)
     .setRange(0,inchesToPixels(3f))
     ;
  

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    t.z = ((j%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0" 
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}

void drawTargetSquare() 
{
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  Target t = targets.get(trialIndex);
  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  rotate(radians(t.rotation));
  fill(255,0,0,191);
  rect(0, 0, t.z, t.z);
  fill(160);
  ellipse(0, 0, 15, 15);

  drawTargetCrossHairs();

  popMatrix();
}

boolean mouseOverCursor() 
{
  float dx = Math.abs(screenTransX - ((mouseX - width/2) - bx));
  float dy = Math.abs(screenTransY - ((mouseY - width/2) - by));
  float r  = screenZ/2;
  
  if (dx <= r && dy <= screenZ) {
    return true;
  }
  return false;
}

void drawCursorCrossHairs()
{
  if (checkOriginOverlap()) {
    fill(green);
  } else {
    fill(bluetrans);
  }
  strokeWeight(1);
  ellipse(bx, by, 15, 15);

  float x1 = bx - screenZ/2;
  float y1 = by;
  float x2 = bx + screenZ/2;
  float y2 = by;
  float x3 = bx;
  float y3 = by - screenZ/2;
  float x4 = bx;
  float y4 = by + screenZ/2;

  stroke(bluetrans);
  if (checkRotation()) {
    stroke(green);
  } 
  strokeWeight(5f);
  line(x1, y1, x2, y2);
  line(x3, y3, x4, y4);

}

void drawTargetCrossHairs()
{
  Target t = targets.get(trialIndex);

  float x1 = 0 - t.z/2;
  float y1 = 0;
  float x2 = 0 + t.z/2;
  float y2 = 0;
  float x3 = 0;
  float y3 = 0 - t.z/2;
  float x4 = 0;
  float y4 = 0 + t.z/2;

  stroke(bluetrans);
  if (checkRotation()) {
    stroke(brightblue);
  } 
  strokeWeight(5f);
  line(x1, y1, x2, y2);
  line(x3, y3, x4, y4);
}

void drawCursorSquare()
{
  
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(screenTransX,screenTransY);
  rotate(radians(screenRotation));
  strokeWeight(1f);

  // Test if the cursor is over the box 
  if (mouseOverCursor()) {
    overBox = true;  
    if(!locked) {
      stroke(255, 255, 255);
    } 
  } else {
    stroke(153);
    overBox = false;
  }
  if (checkSize()) {
    strokeWeight(5f);
    stroke(green);
  }

  fill(whitetrans);
  rect(bx,by, screenZ, screenZ);

  drawCursorCrossHairs();
  popMatrix();

}

void draw() 
{
  background(60); //background is dark grey
  fill(200);
  noStroke();
  
  
  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    cp5.remove("screenRotation");
    cp5.remove("screenZ");
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchesToPixels(.2f)*4);
    return;
  }
  
  //===========DRAW TARGET SQUARE=================
  drawTargetSquare();

  //===========DRAW CURSOR SQUARE=================
  drawCursorSquare();
  //println("target=", t.x, t.y, t.z);
  //println("cursor=", screenTransX, screenTransY, screenZ);

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{
  fill(brightblue);
  text("Next", 32, 125, 46, 48);
}

void slider(float rotation) {
  screenRotation += rotation;
  println("a slider event. adding rotation of "+rotation);
}

void mousePressed()
{
    if (startTime == 0) //start time on the instant of the first user click
    {
      startTime = millis();
      println("time started!");
    }
    if(overBox) { 
      locked = true; 
      fill(255, 255, 255);
    } else {
      locked = false;
    }
    xOffset = mouseX-screenTransX; 
    yOffset = mouseY-screenTransY; 
}

void mouseDragged() {
  if(locked) {
    screenTransX = mouseX-xOffset; 
    screenTransY = mouseY-yOffset;

  }
}

void mouseReleased()
{
  // check to see if user selected next button
  if (mouseX <= 50 && mouseY <= 120 && mouseY > 95)
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    //and move on to next trial
    trialIndex++;
    
    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }

  locked = false;
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Target t = targets.get(trialIndex); 
  boolean closeDist = dist(t.x,t.y,screenTransX,screenTransY)<inchesToPixels(.05f); //has to be within .1"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
  boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"  
  
  println("Close Enough Distance: " + closeDist + " (cursor X/Y = " + t.x + "/" + t.y + ", target X/Y = " + bx + "/" + by +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(t.rotation,screenRotation)+")");
  println("Close Enough Z: " +  closeZ + " (cursor Z = " + t.z + ", target Z = " + screenZ +")");
  boolean success = false;
  if ( closeDist && closeRotation && closeZ) {
    success = true;
  };  
  return success;
}
public boolean checkRotation()
{
  Target t = targets.get(trialIndex);
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
  if (closeRotation) {
    return true;
  }
  return false;
}

public boolean checkOriginOverlap()
{
  Target t = targets.get(trialIndex); 
  boolean closeDist = dist(t.x,t.y,screenTransX,screenTransY)<inchesToPixels(.05f); //has to be within .1"
  // println(t.x,t.y,screenTransX,screenTransY);
  // println(mouseX,mouseY);
  if (closeDist) {
    return true;
  }
  return false;

}

public boolean checkSize()
{
  Target t = targets.get(trialIndex); 
  boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"  
  // println(t.x,t.y,screenTransX,screenTransY);
  // println(mouseX,mouseY);
  if (closeZ) {
    return true;
  }
  return false;

}

//utility function I include
double calculateDifferenceBetweenAngles(float a1, float a2)
  {
     double diff=abs(a1-a2);
      diff%=90;
      if (diff>45)
        return 90-diff;
      else
        return diff;
 }
