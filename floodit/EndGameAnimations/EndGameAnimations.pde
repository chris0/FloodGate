boolean end;
int cutscene;
int step;
float w, h, ow, oh, rw, rh;
float[] sShake;
color[][] cArray;    // 2D array of colors
// Color assignments
color C1 = color(255);
color C2 = color(204);
color C3 = color(153);
color C4 = color(102);
color C5 = color(51);
color C6 = color(0);
color lastC2, lastColor;
color[] colors = {C1, C2, C3, C4, C5, C6};      // 1D array of 6 colors
PImage agent;

public void settings()
{
  size(displayWidth, int(1.24*displayWidth), P2D);
  w=displayWidth; h=int(1.24*displayWidth);
  orientation(PORTRAIT);
  ow=340.0; oh=420.0;    // original width, height: 340x420
  rw=w/ow; rh=h/oh;  // ratio original/screen width, height
}

void setup()
{
  frameRate(30);
  end = false;
  step = 0;
  cutscene = 0;
  cArray = new int[6][6];
      for(int i = 0; i < cArray.length; i++) {
    for(int j = 0; j < cArray[i].length; j++) {
      int b = int(random(6));
      color c = colors[b];
      cArray[i][j] = c;
    }
  }  
  lastC2 = C2;
  lastColor = cArray[0][0];  
  sShake = new float[4];
  sShake[0] = 0;
  sShake[1] = 0;
  sShake[2] = 0;
  sShake[3] = 0;
  agent = loadImage("secretagent.png");
}

void draw()
{
  cutsceneAnim();
  endAnimFlood();
}

void cutsceneAnim() {
  if(end == false)
    background(C2);
  fill(C2);
  stroke(30);
  strokeWeight(1);
  
  beginShape();
    vertex(rw*(0),rh*(380));
    vertex(rw*(130),rh*(200));
    vertex(rw*(210),rh*(200));
    vertex(rw*(340),rh*(380));
    vertex(rw*(0),rh*(380));
  endShape();
  
  beginShape();
    vertex(rw*(0),rh*(0));
    vertex(rw*(130),rh*(100));
    vertex(rw*(210),rh*(100));
    vertex(rw*(340),rh*(0));
    vertex(rw*(0),rh*(0));
  endShape();
  
  rectMode(CORNER);
  fill(lastC2);
  stroke(lastC2);
  rect(0,rh*(381),rw*340,rh*100);
  stroke(30);  
    
  line(rw*(130),rh*(200),rw*(130),rh*(100));
  line(rw*(210),rh*(200),rw*(210),rh*(100));
  line(rw*(170),rh*(200),rw*(170),rh*(100));
 
  noFill();
  rectMode(CENTER);
  rect(w/2,3*h/8,rw*2*cArray.length+2,rh*2*cArray.length+2);
  rectMode(CORNER);
  
  for(int i = 0; i < cArray.length; i++) {
    for(int j = 0; j < cArray[i].length; j++) {
      int n = cArray[i][j];
      stroke(n);
      fill(n);
      rect(rw*(i*2+(ow/2-2*cArray.length/2)), rh*(j*2+(3*oh/8-2*cArray.length/2)), rw*2, rh*2);
    }
  }
  
  image(agent, 13*w/32, 3*h/8, agent.width/3, agent.height/3);
}

void endAnimFlood()
{
  if(end == true)
  {
    rectMode(CORNERS);
    stroke(#00FFFF, 100);
    fill(#00FFFF, 100);
    beginShape();
      vertex(rw*(0),rh*380-rh*cutscene);
      vertex(rw*(130),rh*(200-cutscene/4));
      vertex(rw*(210),rh*(200-cutscene/4));
      vertex(rw*(340),rh*380-rh*cutscene);
      vertex(rw*(0),rh*380-rh*cutscene);
    endShape();    
    rect(0, rh*380-rh*cutscene, w, rh*380);
    if(cutscene<381)
      cutscene += 4;
  }
}

void mousePressed()
{
  if(end == false)
    end = true;
  else
  {
    end = false;
    cutscene = 0;
  }
  println("end: " + end);
}