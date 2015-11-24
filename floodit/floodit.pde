import android.app.Activity;
import android.content.res.AssetFileDescriptor;
import android.content.Context;
import android.media.MediaPlayer;
import android.media.SoundPool;
import android.media.AudioManager;

MediaPlayer bgm;
SoundPool soundPool;
HashMap<Object, Object> soundPoolMap;
Activity act;
Context cont;
AssetFileDescriptor music, sound1, sound2;
PFont font;
Table csv;

int w, h;            // width and height of window
float ow, oh;          // original height and width for scaling
float rw, rh;          // width scaling coefficient, height scaling coefficient
int s1, s2;          // a variable to hold index of sound in soundPool
int hp;              // a variable to keep track of currency
float fingerPress;     // a variable to keep track of pressing animation
int fingerOffset;    // a variable to smooth things after cutscene
float cutscene;        // a variable to keep track of cutscene animations
color lastColor;     // color to display on cutscene
float[] sShake;        // screenshake on cutscene. [0] determines X direction, [1] determines X movement, [2] determines Y direction, [3] determines Y movement
int gameState;       // a variable to keep track of states.
int highScore;       // we obtain this from a stored value with jStorage
int score;
float substep;
int step;
int doorMode;
int currentMode;
int tutLevel;
int levelsCompleted;

ArrayList<Pcle> pcles =  new ArrayList<Pcle>();

// Color assignments
color C1 = color(255);
color C2 = color(204);
color C3 = color(153);
color C4 = color(102);
color C5 = color(51);
color C6 = color(0);

color[] colors = {C1, C2, C3, C4, C5, C6};      // 1D array of 6 colors
color[][] cArray;    // 2D array of colors
boolean[][] sArray;  // 2D array of true/false switches
                     // true/false stands for on/off
color lastC2;

boolean end;
int floodCounter, wallCounter, endMode, explosionCounter, explosionSeqCounter, endSceneIntroCounter;
float xcoord, ycoord;
float bubble1x, bubble2x, bubble3x, bubble1y, bubble2y, bubble3y;
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

void setup() {
  frameRate(30);
  end = false;
  endSceneIntroCounter = 15;
  floodCounter = 0;
  wallCounter = 0;
  explosionCounter = 0;
  explosionSeqCounter = 26;
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
  act = this.getActivity();
  cont = act.getApplicationContext();
  try {
    bgm = new MediaPlayer();    
    music = cont.getAssets().openFd("DarkMystery.mp3");    
    sound1 = cont.getAssets().openFd("door.mp3");
    sound2 = cont.getAssets().openFd("sfx.mp3");
    bgm.setDataSource(music.getFileDescriptor());  
    bgm.prepare();  
    initSounds(cont);
  }
  catch(IOException e)
  {
    println("File did not load");
  }
  bgm.setLooping(true);
  bgm.start();
  levelsCompleted = 0;
  //int b, i, j;
  //color c;
  //noCursor();
  fingerOffset = 0;
  cArray = new int[6][6];
  sArray = new boolean[6][6];
  sShake = new float[4];
  font = createFont("Play-Regular.ttf", 32);
  textFont(font);
  try {
    csv = new Table(new File(sketchPath("") + "data.csv"));
    highScore = csv.getInt(0,0);
  }
  catch (Exception e) {
    csv = new Table();  
    csv.addRow();
    String[] s = {Integer.toString(score)};
    csv.setRow(0, s);
  }
}  

void mousePressed() {
  if (gameState == 0 || gameState == 2) {
    //if (mouseX.between(130,205) && mouseY.between(185,215)){
    if(mouseX>rw*130 && mouseX<rw*205 && mouseY>rh*185 && mouseY<rh*215) {
      switchMode();
      for(int i = 0; i < cArray.length; i++) {
        for(int j = 0; j < cArray[i].length; j++) {
          int b = int(random(6));
          color c = colors[b];
          cArray[i][j] = c;
          sArray[i][j] = false;
        }
      }
      gameState = 1;
      score = 0;
      // set just the top left block to 'true'
      sArray[0][0] = true;
    }
    
    //if (mouseX.between(130,205) && mouseY.between(255,285)){
    if(mouseX>rw*130 && mouseX<rw*205 && mouseY>rh*255 && mouseY<rh*285) {
      C1 = color(255);
      C2 = color(204);
      C3 = color(153);
      C4 = color(102);
      C5 = color(51);
      for(int i = 0; i < cArray.length; i++) {
        for(int j = 0; j < cArray[i].length; j++) {
          int b = int(random(6));
          color c = colors[b];
          cArray[i][j] = c;
          sArray[i][j] = false;
        }
      }
      // set just the top left block to 'true'
      sArray[0][0] = true;
      tutLevel = 0;
      gameState = 3;
    }
  }
  if (gameState == 3) {
    //if (mouseX.between(130,205) && mouseY.between(375,450) && tutLevel == 1){gameState = 0;}
    if(mouseX>rw*130 && mouseX<rw*205 && mouseY>rh*375 && mouseY<rh*450 && tutLevel == 1) {gameState = 0;}
    fingerPress = 30;
    playSound(cont, 2);
    //if (tutLevel == 0 && mouseX.between(95,245) && mouseY.between(95,245)) {
    if(tutLevel == 0 && mouseX>rw*95 && mouseX<rw*245 && mouseY>rh*95 && mouseY<rh*245) {
      color f;  //color c, f;   
      playSound(cont, 2);
      f = get(mouseX, mouseY);
        
      int xpos = 0;
      int ypos = 0;
      int target = cArray[0][0];
    
      cArray[0][0] = f;      
      // always set the top left box to the new color c
      sArray[0][0] = true;
      // Boolean flag of top left box is always true
      // in other words, it's the root of the tree
      
      
      /* Here we are looping through the 2-dimensional array of color values 
         called cArray */
      for(xpos = 0; xpos < cArray.length; xpos++) {
        for(ypos = 0; ypos < cArray.length; ypos++) {
          /* If we are at cArray[0][0] (top left square, don't do anything 
             because sArray, the corresponding array of booleans, is already
             true at this index from initialization */ 
          if ((xpos == 0) && (ypos == 0)) {
          }
          /* Now check to see if the color value at the current index does NOT
             match the value of target and if so don't do anything */
          else if(cArray[xpos][ypos] != target) {
          }
          /* If color value at index DOES match target (fallthrough condition from 
             conditional above, run CheckNeighbor function below. If CheckNeighbor
             evaluates to true, update the cell to the current color f (the color
             that was clicked on) and it's boolean value to true. */
          else if(checkNeighbor(xpos, ypos) == true) {
              cArray[xpos][ypos] = f;
              sArray[xpos][ypos] = true;
          }
        }
      }
    }
  }
  if (gameState == 1) {
    fingerPress = 30;
    if (dist(mouseX,mouseY,rw*53,rh*395) < rw*40) {
      if(doorMode == 2) 
      {
        substep += round(hp/2);
        step = floor(substep);
      }
      else { step += round(hp/2); }
      hp = 0;
    }
    //if (cutscene >= 0 && mouseX.between(95,245) && mouseY.between(95,245)) {
    if(cutscene >= 0 && mouseX>rw*95 && mouseX<rw*245 && mouseY>rh*95 && mouseY<rh*245) {
      color f; //color c, f;   
      playSound(cont, 2);
      f = get(mouseX, mouseY);
      
      if ((doorMode == 0 || doorMode == 1) && f != cArray[0][0]) {step -= 1;}
        
      int xpos = 0;
      int ypos = 0;
      int target = cArray[0][0];
    
      cArray[0][0] = f;      
      // always set the top left box to the new color c
      sArray[0][0] = true;
      // Boolean flag of top left box is always true
      // in other words, it's the root of the tree
      
      
      /* Here we are looping through the 2-dimensional array of color values 
         called cArray */
      for(xpos = 0; xpos < cArray.length; xpos++) {
        for(ypos = 0; ypos < cArray.length; ypos++) {
          /* If we are at cArray[0][0] (top left square, don't do anything 
             because sArray, the corresponding array of booleans, is already
             true at this index from initialization */ 
          if ((xpos == 0) && (ypos == 0)) {
          }
          /* Now check to see if the color value at the current index does NOT
             match the value of target and if so don't do anything */
          else if(cArray[xpos][ypos] != target) {
          }
          /* If color value at index DOES match target (fallthrough condition from 
             conditional above, run CheckNeighbor function below. If CheckNeighbor
             evaluates to true, update the cell to the current color f (the color
             that was clicked on) and it's boolean value to true. */
          else if(checkNeighbor(xpos, ypos) == true) {
              cArray[xpos][ypos] = f;
              sArray[xpos][ypos] = true;
          }
        }
      }
    }
  }
}

/* CheckkNeighbor checks to see if any of a cell's 4 adjacent neighbors have 
   a value of true. A neighbor must have a value of true for the cell to change
   color, since the color must be connected to the tree of cells that are connected
   to the root (the upper left cell). */
boolean checkNeighbor(int xpos, int ypos) {
  if( (xpos > 0) && (sArray[xpos - 1][ypos]) == true) {
    return true;
  }
  if( (ypos > 0) && (sArray[xpos][ypos - 1]) == true ) {
    return true;
  }
  if( (xpos < sArray.length - 1) && (sArray[xpos + 1][ypos] == true) ) {
    return true;
  }
  if( (ypos < sArray.length - 1) && (sArray[xpos][ypos + 1] == true) ) {
    return true;
  }
  return false;
}

void draw() {
  if(end == true)
  {
    endBegin();
  }
  if(end == false)
  {
    textSize(int(rh*14));  
    if (gameState == 3) {
        background(225);
        if (tutLevel == 0) {
          fill(30);
          textAlign(CENTER);
          textSize(int(rh*35));
          text("Floodgate Dungeon",w/2,rh*30);
          textSize(int(rh*20));
          text("How To Play",w/2,rh*60);
          textSize(int(rh*15));
          text("Click on a block.",w/2,rh*270);
          text("The top-left block with change into that color.",w/2,rh*300);
          text("All blocks connected to the top-left block will",w/2,rh*315);
          text("also change to that color.",w/2,rh*330);
          text("Turn all blocks to the same color to proceed.",w/2,rh*345);
          textAlign(LEFT);
          strokeWeight(1);
          fill(0);
          stroke(0);
          rect(rw*90,rh*90,rw*160,rh*160);
          for(int i = 0; i < cArray.length; i++) {
            for(int j = 0; j < cArray[i].length; j++) {
              int n = cArray[i][j];
              // color c = colors[n];
              stroke(n);
              fill(n);
              rect(rw*(i*25+95), rh*(j*25+95), rw*25, rh*25);
            }
          }
          int helpAllCheck = 0;
          for(int i = 0; i < cArray.length; i++) {
            for(int j = 0; j < cArray[i].length; j++) {
              if (cArray[i][j] == cArray[0][0]) {
                helpAllCheck += 1;
              }
            }
          } 
          if (helpAllCheck >= 36) {
            tutLevel = 1;
          }
        }
        
        if (tutLevel == 1) {
          fill(30);
          textSize(int(rh*35));
          textAlign(CENTER);
          text("Floodgate Dungeon",w/2,rh*30);
          textSize(int(rh*20));
          text("How To Play",w/2,rh*60);
          textSize(int(rh*15));
          text("Not bad!",w/2,rh*85);
          text("White/yellow doors have limited turns.",w/2,rh*100);
          text("Red doors limited seconds.",w/2,rh*115);
          text("In your left hand is a H4CKP4D.",w/2,rh*160);
          text("When you have excess turns they are converted",w/2,rh*175);
          text("into H4CKPO1NTS. H4CKPO1NTS can be used",w/2,rh*190);
          text("to add turns or seconds to unlock the door.",w/2,rh*205);
          text("Press the circular button to use it.",w/2,rh*220);
          text("Yellow doors give 2x H4POINTS!",w/2,rh*235);
          fill(225);
          translate(rw*80,rh*(430 + fingerOffset));
          strokeWeight(rw*30);
          stroke(150);
          line(-rw*100,-rh*140,0,-rh*150);
          line(rw*0,-rh*95,rw*30,-rh*100);
          stroke(0);
          strokeWeight(5);
          rotate(10/57.3);
          rect(0,0,-rw*100,-rh*130);
          stroke(30);
          fill(30);
          strokeWeight(1);
          beginShape();
            vertex(rw*150,0);
            vertex(rw*170,-rh*20);
            vertex(rw*170,-rh*20);
            vertex(rw*150,0);
          endShape();
          textAlign(LEFT);
          textSize(int(rh*14));
          text("  H4CKP4D", -rw*90,-rh*110); 
          textSize(int(rh*13));
          text("H4CKP01NTS", -rw*90,-rh*70); 
          fill(225);
          ellipse(-rw*50,-rh*25,rw*40,rh*40);
          textSize(int(rh*13));
          fill(30);
          text("+ " + round(hp/2), -rw*60,-rh*22); 
          rotate(-10/57.3);
          strokeWeight(rw*30);
          stroke(150);
          line(rw*30,-rh*100,rw*30,-rh*100);
          line(rw*30,-rh*70,rw*15,-rh*60);
          translate(-rw*80,-rh*430 - fingerOffset);
          strokeWeight(1);
          fill(30);
          textSize(int(rh*30));
          text("Done",rw*132,rh*400);
          fill(0,0);
          rect(rw*130,rh*375,rw*75,rh*30);
        }
    }
  
    if (gameState == 0 || gameState == 2) {
      background(225);
      fill(30);
      textSize(int(rh*30));
      text("Start",rw*135,rh*210);
      text("Help",rw*136,rh*280);
      textSize(int(rh*35));
      text("Floodgate Dungeon",rw*15,rh*150);
      strokeWeight(1);
      fill(0,0);
      rect(rw*130,rh*185,rw*75,rh*30);
      rect(rw*130,rh*255,rw*75,rh*30);
      fill(30);
      textSize(int(rh*20));
      text("High score: " + highScore,rw*110,rh*390);
    }
    
    if (gameState == 2) {
      fill(30);
      textSize(int(rh*20));
      text("Score: " + score,rw*140,rh*370);
    }
      
    if (gameState == 1) {
      textSize(int(rh*14));
      background(C2);
      if (cutscene > 0) {
        cutsceneAnim();
        cutscene -= 2;
      } else {
        stroke(30);
        strokeWeight(1);
        fill(30);
        if (doorMode == 2) {
          substep -= 1/frameRate;
          step = floor(substep);
        }
        if (fingerOffset > 0) {fingerOffset -= (500/60);}
        if (fingerOffset < 0) {fingerOffset = 0;}
        rect(rw*90,rh*90,rw*160,rh*160);
        rect(rw*165,0,rw*10,rh*400);
        rect(0,rh*395,rw*340,rh*10);
        rect(rw*100,rh*60,rw*140,rh*30);  
        fill(C1);
        rect(rw*105,rh*65,rw*130,rh*20);  
        fill(30);
        text(round(step),rw*165,rh*82);
        for(int i = 0; i < cArray.length; i++) {
          for(int j = 0; j < cArray[i].length; j++) {
            int n = cArray[i][j];
            //color c = colors[n];
            stroke(n);
            fill(n);
            rect(i*rw*25+rw*95, j*rh*25+rh*95, rw*25, rh*25);
          }
        }
      }
      fill(225);
      translate(rw*80,rh*(430 + fingerOffset));
      strokeWeight(rw*30);
      stroke(150);
      line(-rw*100,-rh*140,0,-rh*150);
      stroke(0);
      strokeWeight(5);
      rotate(10/57.3);
      rect(0,0,-rw*100,-rh*130);
      stroke(30);
      fill(30);
      strokeWeight(1);
      beginShape();
        vertex(rw*150,0);
        vertex(rw*170,-rh*20);
        vertex(rw*170,-rh*20);
        vertex(rw*150,0);
      endShape();
      textSize(int(rh*14));
      text("  H4CKP4D", -rw*90,-rh*110); 
      textSize(int(rh*13));
      text(hp + "H4CKP01NTS", -rw*90,-rh*70); 
      fill(225);
      ellipse(-rw*50,-rh*25,rw*40,rh*40);
      textSize(int(rh*13));
      fill(30);
      text("+ " + round(hp/2), -rw*60,-rh*22); 
      rotate(-10/57.3);
      strokeWeight(rw*30);
      stroke(150);
      line(0,-rh*95,rw*30,-rh*100);
      line(rw*30,-rh*100,rw*30,-rh*100);
      line(rw*30,-rh*70,rw*15,-rh*60);
      translate(-rw*80,-rh*(430 - fingerOffset));
      strokeWeight(1);
      checkEndGame();
  
      for (int i=pcles.size()-1; i>=0; i--) {
        Pcle p = pcles.get(i);
        p.update();
        if (p.fa < 0) {pcles.remove(i);}
      }
      //text(mouseX + "," + mouseY,mouseX,mouseY);
    }    
  }
}

void checkEndGame() {
  int allCheck = 0;
  for(int i = 0; i < cArray.length; i++) {
    for(int j = 0; j < cArray[i].length; j++) {
      if (cArray[i][j] == cArray[0][0]) {
        allCheck += 1;
      }
    }
  } 
  if (allCheck >= 36) {
    if (doorMode == 1 || doorMode == 2) {hp += round(step);} else {hp += round(step/2);}
    lastColor = cArray[0][0];
    levelsCompleted += 1;
    score += levelsCompleted;
    cutscene = 300;
    playSound(cont, 1);  // door sound
    sShake[0] = 0;
    sShake[1] = 0;
    sShake[2] = 0;
    sShake[3] = 0;
    switchMode();
    for(int i = 0; i < cArray.length; i++) {
      for(int j = 0; j < cArray[i].length; j++) {
        int b = int(random(6));
        color c = colors[b];
        cArray[i][j] = c;
        sArray[i][j] = false;
      }
    }
    sArray[0][0] = true; 
  }
  if(step <= 0 && allCheck < 36) {
    score += hp;
    hp = 0;
    levelsCompleted = 0;
    if(score > highScore) 
    { 
      highScore = score;
      String[] s = {Integer.toString(score)};
      csv.setRow(0, s);
      try {
        csv.save(new File(sketchPath("") + "data.csv"), "csv");
      }
      catch(IOException iox) {
        println("Failed to write file." + iox.getMessage());  
      }
    }
    end = true;
    //gameState = 2;
  }
}

void switchMode() {
  lastC2 = C2;
  doorMode = int(random(3));
  endMode = doorMode;
  C6 = color(0);
  switch(doorMode) {
  case 0:
    if(levelsCompleted<4) { step = round(random(14-levelsCompleted,19-levelsCompleted)); }
    else { step = round(random(10, 15)); }
    C1 = color(255);
    C2 = color(204);
    C3 = color(153);
    C4 = color(102);
    C5 = color(51);
    break;
  
  case 1:
    if(levelsCompleted<4) { step = round(random(16-levelsCompleted, 21-levelsCompleted)); }
    else { step = round(random(12, 16)); }
    C1 = color(255,255,0);
    C2 = color(204,204,0);
    C3 = color(153,153,0);
    C4 = color(102,102,0);
    C5 = color(51,51,0);
    break;
  
  case 2:
    if(levelsCompleted<4) { substep = round(random(10-levelsCompleted, 15-levelsCompleted)); }
    else { substep = round(random(6, 11)); }
    step = floor(substep);
    C1 = color(255,0,0);
    C2 = color(204,0,0);
    C3 = color(153,0,0);
    C4 = color(102,0,0);
    C5 = color(51,0,0);
    break;
  }
  //colors = {C1, C2, C3, C4, C5, C6;}
}

void finger() {
  if (fingerPress > 0) {fingerPress -= 1;}
  if (fingerPress < 0) {fingerPress = 0;}
  noFill();
  ellipse(mouseX, mouseY, rw*4, rw*4);
  fill(150);
  stroke(150);
  ellipse(mouseX+rw*30-(fingerPress - fingerOffset),mouseY+rh*30-(fingerPress - fingerOffset),rw*30,rh*30);
  ellipse(mouseX+rw*92-(fingerPress - fingerOffset),mouseY+rh*95-(fingerPress - fingerOffset),rw*30,rh*30);
  ellipse(mouseX+rw*112-(fingerPress - fingerOffset),mouseY+rh*86-(fingerPress - fingerOffset),rw*30,rh*30);
  ellipse(mouseX+rw*132-(fingerPress - fingerOffset),mouseY+rh*85-(fingerPress - fingerOffset),rw*30,rh*30);
  translate(mouseX+rw*39-(fingerPress - fingerOffset),mouseY+rh*79-(fingerPress - fingerOffset));
  rotate(1.1);
  rect(-rw*50,-rh*30,rw*100,rh*30);
  rect(rw*49,0,rw*550,-rh*100);
  fill(0);
  stroke(0);
  rect(rw*49,rh*5,rw*100,-rh*110);
  fill(150);
  stroke(150);
  // rect(49,0,50,-100);
  rotate(-1.1);
  translate(0 - (mouseX+rw*57-(fingerPress - fingerOffset)),0 - (mouseY+rh*79 - (fingerPress - fingerOffset)));
}

void cutsceneAnim() {
  if (cutscene > 200) {
    strokeWeight(2);
    fill(C2);
    stroke(30);
    fingerOffset += 5;
    
    beginShape();
      vertex(0,rh*380);
      vertex(rw*130,rh*200);
      vertex(rw*210,rh*200);
      vertex(rw*340,rh*380);
      vertex(0,rh*380);
    endShape();
    
    beginShape();
      vertex(0,0);
      vertex(rw*130,rh*100);
      vertex(rw*210,rh*100);
      vertex(rw*340,0);
      vertex(0,0);
    endShape();
    
    line(rw*130,rh*200,rw*130,rh*100);
    line(rw*210,rh*200,rw*210,rh*100);
    line(rw*170,rh*200,rw*170,rh*100);
     
    fill(lastC2);
    stroke(lastC2);
    rect(0,rh*381,rw*340,rh*100);
    stroke(30);
      
    fill(lastC2);
    rect(0,rh*(0 - (300 - cutscene)*4),rw*340,rh*400);
    fill(30);
    rect(rw*90,rh*(90 - (300 - cutscene)*4),rw*160,rh*160);
    rect(0,rh*(395 - (300 - cutscene)*4),rw*340,rh*10);
    fill(lastColor);
    rect(rw*95,rh*(95 - (300 - cutscene)*4),rw*150,rh*150);
    
    strokeWeight(15);
    stroke(0);
    line(rw*138,rh*(179 - (300 - cutscene)*4),rw*170,rh*(200 - (300 - cutscene)*4));
    line(rw*170,rh*(200 - (300 - cutscene)*4),rw*200,rh*(135 - (300 - cutscene)*4));
    
    strokeWeight(13);
    stroke(255);
    line(rw*138,rh*(179 - (300 - cutscene)*4),rw*170,rh*(200 - (300 - cutscene)*4));
    line(rw*170,rh*(200 - (300 - cutscene)*4),rw*200,rh*(135 - (300 - cutscene)*4));
  }
  
  if (cutscene <= 200) {
    
    if (sShake[0] == 0) {sShake[1] -= 0.9;}
    if (sShake[1] < -11.1 && sShake[0] == 0) {sShake[0] = 1;}
    if (sShake[0] == 1) {sShake[1] += 0.9;}
    if (sShake[1] > 11.1 && sShake[0] == 1) {sShake[0] = 0;}  
      
    if (sShake[2] == 0) {sShake[3] -= 1;}
    if (sShake[3] <= 0 && sShake[2] == 0) {sShake[2] = 1;}
    if (sShake[2] == 1) {sShake[3] += 1;}
    if (sShake[3] > 11 && sShake[2] == 1) {sShake[2] = 0;}  
      
    fill(C2);
    stroke(30);
    strokeWeight(10 - 9*(cutscene/200));
    
    beginShape();
      vertex(rw*(0 - (200 - cutscene) + sShake[1]),rh*(380 + (200 - cutscene) + sShake[3]));
      vertex(rw*(130 - (200 - cutscene) + sShake[1]),rh*(200 + (200 - cutscene) + sShake[3]));
      vertex(rw*(210 + (200 - cutscene) + sShake[1]),rh*(200 + (200 - cutscene) + sShake[3]));
      vertex(rw*(340 + (200 - cutscene) + sShake[1]),rh*(380 + (200 - cutscene) + sShake[3]));
      vertex(rw*(0 - (200 - cutscene) + sShake[1]),rh*(380 + (200 - cutscene) + sShake[3]));
    endShape();
    
    beginShape();
      vertex(rw*(0 - (200 - cutscene) + sShake[1]),rh*(0 - (200 - cutscene) + sShake[3]));
      vertex(rw*(130 - (200 - cutscene) + sShake[1]),rh*(100 - (200 - cutscene) + sShake[3]));
      vertex(rw*(210 + (200 - cutscene) + sShake[1]),rh*(100 - (200 - cutscene) + sShake[3]));
      vertex(rw*(340 + (200 - cutscene) + sShake[1]),rh*(0 - (200 - cutscene) + sShake[3]));
      vertex(rw*(0 - (200 - cutscene) + sShake[1]),rh*(0 - (200 - cutscene) + sShake[3]));
    endShape();
    
    fill(lastC2);
    stroke(lastC2);
    rect(0,rh*(381 + (200 - cutscene) + sShake[3]),rw*340,rh*100);
    stroke(30);  
      
    line(rw*(130 - (200 - cutscene) + sShake[1]),rh*(200 + (200 - cutscene) + sShake[3]),rw*(130 - (200 - cutscene) + sShake[1]),rh*(100 - (200 - cutscene) + sShake[3]));
    line(rw*(210 + (200 - cutscene) + sShake[1]),rh*(200 + (200 - cutscene) + sShake[3]),rw*(210 + (200 - cutscene) + sShake[1]),rh*(100 - (200 - cutscene) + sShake[3]));
    line(rw*(170 + sShake[1]),rh*(200 + (200 - cutscene) + sShake[3]),rw*(170 + sShake[1]),rh*(100 - (200 - cutscene) + sShake[3]));
    
    strokeWeight(1);
    fill(30);
    rect(rw*(90 + 80*(cutscene/200) + sShake[1]),rh*(90 + 80*(cutscene/200) + sShake[3]),rw*(160 - 160*(cutscene/200)),rh*(160 - 160*(cutscene/200)));
    rect(rw*(100 + 70*(cutscene/200) + sShake[1]),rh*(60 + 110*(cutscene/200) + sShake[3]),rw*(140 - 140*(cutscene/200)),rh*(30 - 30*(cutscene/200)));  
    fill(C1);
    rect(rw*(105 + 65*(cutscene/200) + sShake[1]),rh*(65 + 105*(cutscene/200) + sShake[3]),rw*(130 - 130*(cutscene/200)),rh*(20 - 20*(cutscene/200)));
    textSize(int(rh*(14 - 13*(cutscene/200))));
    fill(30);
    text(round(step),rw*(165 + 5*(cutscene/200) + sShake[1]),rh*(82 + 88*(cutscene/200) + sShake[3]));
    textSize(int(rh*14));
    
    for(int i = 0; i < cArray.length; i++) {
      for(int j = 0; j < cArray[i].length; j++) {
        int n = cArray[i][j];
        //float c = colors[n];
        stroke(n);
        fill(n);
        rect(rw*(i*(25 - 25*(cutscene/200))+(95 + 75*(cutscene/200)) + sShake[1]), rh*(j*(25 - 25*(cutscene/200))+(95 + 75*(cutscene/200)) + sShake[3]), rw*(25 - 25*(cutscene/200)), rh*(25 - 25*(cutscene/200)));
      }
    }
  }
}

class Pcle {
  float x;
  float y;
  float vx;
  float vy;
  float r;
  float g;
  float b;
  float s;
  float a;
  float fa;
 
  Pcle(float ox, float oy, float or, float og, float ob, float oa, float os) 
  {
    x = ox;
    y = oy;
    r = or;
    g = og;
    b = ob;
    a = oa;
    s = os;
  }
  
  void update() {
    fa = a*((x - rw*250)/170);
    stroke(r,g,b,fa/2);
    fill(r,g,b,fa);
    rect(rw*(x - s/2),rh*(y - s/2),rw*s,rh*s);
    vx += rw*random(-1,1);
    vy -= rh*0.1;
    x += vx;
    y += vy;
  }
}

void initSounds(Context cont)
{
  soundPool = new SoundPool(2, AudioManager.STREAM_MUSIC, 100);
  soundPoolMap = new HashMap<Object, Object>(2);
  soundPoolMap.put(s1, soundPool.load(sound1, 1));
  soundPoolMap.put(s2, soundPool.load(sound2, 2));
}

void playSound(Context cont, int soundID)
{
  if(soundPool == null || soundPoolMap == null)
    initSounds(cont);
  soundPool.play(soundID, 1.0, 1.0, 1, 0, 1f);
}

boolean between(float pos, float min, float max)
{
  return pos>min && pos<max;
}

public void onDestroy()
{
  super.onDestroy();
  if(bgm != null)
  {
    bgm.release();
  }
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

void endBegin() {
  //if(end == false || (end == true && endMode == 2))
  background(C2);  
  if(endSceneIntroCounter > 0)
  {
    endSceneIntroCounter--;
  }
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

  beginShape();
    vertex(rw*(0),rh*(0));
    vertex(rw*(0),rh*(380));
    vertex(rw*(130), rh*(200));
    vertex(rw*(130), rh*(100));
    vertex(rw*(0), rh*(0));
  endShape();
  
  beginShape();
    vertex(rw*(340), rh*(0));
    vertex(rw*(340), rh*(380));
    vertex(rw*(210), rh*(200));
    vertex(rw*(210), rh*(100));
    vertex(rw*(340), rh*(0));
  endShape();

  rectMode(CORNER);
  rect(rw*(0), rh*(380), w, rh*(40));
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
  if(endSceneIntroCounter <= 0)
  {
    endAnimWalls();
    endAnimFlood();
    endAnimExplosions();        
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
    else
    {
      reset();  
    }
  }
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
    if(floodCounter<h)
      floodCounter += rh*3;
    else
      reset();
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
  {
    if(rw*player.width/7>rw*(210-wallCounter/4)-rw*(130+wallCounter/4))
      wallCounter += 20;
    else
      wallCounter += 4;
  }
  else
  {
    reset();  
  }
}

void reset()
{
    end = false;
    floodCounter = 0;
    wallCounter = 0;
    endSceneIntroCounter = 15;
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
    gameState = 2;
}