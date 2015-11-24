boolean end;
int floodCounter, wallCounter, step, endMode, explosionCounter, explosionSeqCounter;
float w, h, ow, oh, rw, rh, xcoord, ycoord;
float bubble1x, bubble2x, bubble3x, bubble1y, bubble2y, bubble3y;
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
PImage player, playerBurnt; 
PImage[] explodeImg;

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
  endMode = 0;
  step = 0;
  floodCounter = 0;
  wallCounter = 0;
  explosionCounter = 0;
  explosionSeqCounter = 26;
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
  player = loadImage("player.png");
  playerBurnt = loadImage("playerburnt.png");
  explodeImg = new PImage[9]; 
  explodeImg[0] = loadImage("explosion1.png");
  explodeImg[1] = loadImage("explosion2.png");
  explodeImg[2] = loadImage("explosion3.png");
  explodeImg[3] = loadImage("explosion4.png");
  explodeImg[4] = loadImage("explosion5.png");
  explodeImg[5] = loadImage("explosion6.png");
  explodeImg[6] = loadImage("explosion7.png");
  explodeImg[7] = loadImage("explosion8.png");
  explodeImg[8] = loadImage("explosion9.png");
  bubble1x = w/2-rw*17;
  bubble1y = h/2-rh*44;
}

void draw()
{
  endBegin();
  endAnimFlood();
  endAnimWalls();
  endAnimExplosions();
}

void endBegin() {
  if(end == false || (end == true && endMode == 2))
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
  imageMode(CORNER);
  if(explosionSeqCounter>=26)
    image(player, 13*w/32, 3*h/8, rw*player.width/7, rh*player.height/7);
  else
    image(playerBurnt, 13*w/32, 3*h/8, rw*player.width/7, rh*player.height/7);
}

void endAnimFlood()
{
  if(end == true && endMode == 0)
  {
    rectMode(CORNERS);
    stroke(#00FFFF, 100);
    fill(#00FFFF, 100);
    beginShape();
      vertex(rw*(0),rh*380-rh*floodCounter);
      vertex(rw*(130),rh*(200-floodCounter/4));
      vertex(rw*(210),rh*(200-floodCounter/4));
      vertex(rw*(340),rh*380-rh*floodCounter);
      vertex(rw*(0),rh*380-rh*floodCounter);
    endShape();      
    rect(0, rh*380-rh*floodCounter, w, rh*380);
    if(floodCounter<381)
      floodCounter += 8;
  }
}

void endAnimExplosions()
{
  if(end == true && endMode == 2)
  {
    if(explosionSeqCounter > 0)
    { 
      if(explosionSeqCounter%3 == 0)
        explosionCounter++;
      explosion(w/2, 3*h/8, explosionCounter);  
      explosionSeqCounter--;  
    }
  }
}

void endAnimWalls()
{
  if(end == true && endMode == 1)
  {
    background(C2);    
    fill(C2);
    stroke(30);
    strokeWeight(1);
 
    beginShape();
      vertex(rw*wallCounter,rh*(380));
      vertex(rw*(130+wallCounter/4),rh*(200));
      vertex(rw*(210-wallCounter/4),rh*(200));
      vertex(rw*(340-wallCounter),rh*(380));
      vertex(rw*wallCounter,rh*(380));
    endShape();
  
    beginShape();
      vertex(rw*wallCounter,rh*(0));
      vertex(rw*(130+wallCounter/4),rh*(100));
      vertex(rw*(210-wallCounter/4),rh*(100));
      vertex(rw*(340-wallCounter),rh*(0));
      vertex(rw*wallCounter,rh*(0));
    endShape();
    
    if(130+wallCounter/4 < 210-wallCounter/4)
    {
      line(rw*(130+wallCounter/4),rh*(200),rw*(130+wallCounter/4),rh*(100));
      line(rw*(210-wallCounter/4),rh*(200),rw*(210-wallCounter/4),rh*(100));
      line(rw*(170),rh*(200),rw*(170),rh*(100));
    }
    
    if(rw*player.width/7>rw*(210-wallCounter/4)-rw*(130+wallCounter/4))
    {
      imageMode(CORNER);
      image(player, (13*w/32)+rw*wallCounter/10+wallCounter/4, 3*h/8, rw*(210-wallCounter/4)-rw*(130+wallCounter/4), rw*player.height/7);  
    }
    else
    {
      imageMode(CORNER);
      image(player, (13*w/32)+rw*wallCounter/10+wallCounter/4, 3*h/8, rw*player.width/7, rh*player.height/7);  
    }
    
    for(int i = 0; i < cArray.length; i++) {
      for(int j = 0; j < cArray[i].length; j++) {
        int n = cArray[i][j];
        stroke(n);
        fill(n);
        rect(rw*(i*2+(ow/2-2*cArray.length/2)), rh*(j*2+(3*oh/8-2*cArray.length/2)), rw*2, rh*2);
      }
    }    
    
    stroke(30);  
    noFill();
    rectMode(CENTER);
    rect(w/2,3*h/8,rw*2*cArray.length+2,rh*2*cArray.length+2);
    rectMode(CORNER);     
        
    fill(30);    
    line(rw*wallCounter,0,rw*wallCounter,h);
    line(rw*(340-wallCounter),0,rw*(340-wallCounter),h);
    fill(C2);
    rect(0,0,rw*wallCounter,rh*380);
    rect(rw*(340-wallCounter),0,w,rh*380);
  
    rectMode(CORNER);
    fill(lastC2);
    stroke(lastC2);
    rect(0,rh*(381),rw*340,rh*100);
  }

  if(wallCounter < 340-wallCounter)
    if(rw*player.width/7>rw*(210-wallCounter/4)-rw*(130+wallCounter/4))
      wallCounter += 20;
    else
      wallCounter += 4;
}

void mousePressed()
{
  if(end == false)
  {
    end = true;
    xcoord = random(rw*(ow/2-40), rw*(ow/2+40));
    ycoord = random(rh*(oh/2-50), rh*(oh/2+50));
  }
  else
  {
    end = false;
    floodCounter = 0;
    wallCounter = 0;
    if(endMode == 0)
      endMode = 1;
    else if(endMode == 1)
      endMode = 2;
    else
    {
      endMode = 0;
      explosionSeqCounter = 26;
      explosionCounter = 0;
    }
  }
  println("end: " + end);
}

void explosion(float x, float y, int counter)
{
  fill(50);
  rectMode(CENTER);
  rect(w/2,3*h/8,rw*2*cArray.length+2,rh*2*cArray.length+2);       
  float xsize = rw*explodeImg[counter].width+counter*10*rw;
  float ysize = rh*explodeImg[counter].height+counter*10*rh;
  imageMode(CENTER);
  image(explodeImg[counter], x, y, xsize, ysize);
}