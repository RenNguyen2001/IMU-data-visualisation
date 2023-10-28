//creating a simple program to represent one joint
import processing.opengl.*;
import processing.serial.*;

Serial port;
String serialData;
String[][] serialStrings = new String[5][3];  //5 fingers, 3 values (the joint angles)

float grid = 400;

color WHITE = #FFFFFF;
color RED = #FF0000;
color BLUE = #0000FF;
color GREEN = #00FF00;
color BLACK = #000000;

class imuData{
    float[] angle = new float[3];
}

imuData[] imuGlobalObj = new imuData[5];


void setup(){
    for(char i = 0; i < 5; i++)
    {
        imuGlobalObj[i] = new imuData();
    }
    
    //size(900,900);  //setup2D
    size(900,900,P3D);   //setup3D
    //serialSetup();
    
}


void serialSetup(){
    for(char j = 0; j < 5; j++)
    {
    for(char i = 0; i < 3; i++)
        {
        serialStrings[j][i] = "h";  //initialising the values so it doesn't become Null
        }
    }   
  
    port = new Serial(this, "COM10", 120000);  port.bufferUntil('\n');
}

void draw(){
    //drawFinger3d(width/2, height/2);
    //camera(mouseX, height/2, (height/2) / tan(PI/6), mouseX, height/2, 0, 0, 1, 0);
    //drawFingerFunc2D();
    draw3DExample(mouseX, mouseY);
    
}

void drawFingerFunc2D(){
    getSerialData();
    
    background(15,20,30);

    //drawFinger2D(imuGlobalObj[0].angle, width/2, height/2, RED);
    drawFinger2D(imuGlobalObj[1].angle, width/2, height/2, GREEN);
    //drawFinger2D(imuGlobalObj[2].angle, width/2, height/2, WHITE);
    drawFinger2D(imuGlobalObj[3].angle, width/2, height/2, BLUE);
    drawFinger2D(imuGlobalObj[4].angle, width/2, height/2, BLACK);
}

void drawFinger2D(float jointAng[], float x, float y, int colour){
    char fingerLen = 100, fingerWid = 10;
    float[] angleSum = new float[3];

    angleSum[0] = radians(jointAng[2]);
    angleSum[1] = radians(jointAng[2] + jointAng[1]);
    angleSum[2] = radians(jointAng[2] + jointAng[1] + jointAng[0]);
    
    //drawing the palm/hand
    push();
    fill(colour);
    translate(x-fingerLen, y);
    rotate(0);
    rect(0,0,fingerLen,fingerWid);
    rectMode(CORNER);
    pop();

    for(char i = 0; i < 2; i++)
    {
        push();
        fill(colour);
        translate(x, y);
        rotate(angleSum[i]);
        rect(0,0,fingerLen,fingerWid);
        rectMode(CORNER);
        pop();

        x = x + fingerLen*cos(angleSum[i]);
        y = y + fingerLen*sin(angleSum[i]);
    }

    push();
    fill(colour);
    translate(x, y);
    rotate(angleSum[2]);
    rect(0,0,fingerLen,fingerWid);
    rectMode(CORNER);
    pop();

    println(jointAng);
}

void drawFinger3d(float x, float y){
    char fingerLen = 100, fingerWid = 10;
    float[] angleSum = new float[3];
    float[] jointAng = new float[3];


    jointAng[0] = 45;   jointAng[1] = 45;   jointAng[2] = 45;

    angleSum[0] = jointAng[2];
    angleSum[1] = jointAng[2] + jointAng[1];
    angleSum[2] = jointAng[2] + jointAng[1] + jointAng[0];
    
    background(100);

    //drawing the palm/hand
    push();
    translate(x-fingerLen, y,0);
    rotateShape(0,0,0);
    stroke(255);
    noFill();
    rect(0,0,fingerLen,fingerWid);
    rectMode(CORNER);
    pop();

    int i = 0;
    push();
    translate(x, y,0);
    rotateShape(0,0,angleSum[i]);
    stroke(255);
    noFill();
    rect(0,0,fingerLen,fingerWid);
    rectMode(CORNER);
    pop();

    x = x + fingerLen*cos(radians(angleSum[i]));
    y = y + fingerLen*sin(radians(angleSum[i]));

    i = 1;
    push();
    translate(x, y,0);
    rotateShape(0,0,angleSum[i]);
    stroke(255);
    noFill();
    rect(0,0,fingerLen,fingerWid);
    rectMode(CORNER);
    pop();

}

void draw3DExample(float x, float y){
    char fingerLen = 100, fingerWid = 10;
    float[] angleSum = new float[3];
    float[] jointAng = new float[3];

    jointAng[0] = 45;   jointAng[1] = 45;   jointAng[2] = 45;

    angleSum[0] = jointAng[2];
    angleSum[1] = jointAng[2] + jointAng[1];
    angleSum[2] = jointAng[2] + jointAng[1] + jointAng[0];

    background(0);

    push();
    translate(x-fingerLen, y, 0);
    stroke(255);
    rotateX(radians(45));
    rotateY(radians(0));
    noFill();
    box(fingerLen,fingerLen/4,fingerWid);
    rectMode(CORNER);
    pop();

    int i = 0;
    push();
    translate(x, y, 0);
    stroke(255);
    rotateX(radians(45));
    rotateY(radians(90));
    noFill();
    shapeMode(CORNER);
    box(fingerLen,fingerLen/4,fingerWid);
    
    pop();

    push();
    translate(x, y, 0);
    stroke(255);
    rotateX(radians(45));
    rotateY(radians(45));
    noFill();
    shapeMode(CORNER);
    box(fingerLen,fingerLen/4,fingerWid);
    
    pop();
}


void getSerialData(){
  if( port.available() > 0) // If data is available,
  { 
    serialData = port.readStringUntil('\n');         // read the entire string until the newline
    String[] receiveVar = new String[4];
    int indexNo;
    //splitting the string
    receiveVar = split(serialData, " ");  // index 0 finger strip num, 1 jointAng1(tip), 2 jointAng2(mid), 3 jointAng3(base) 
    indexNo = int(receiveVar[0]);  println(indexNo);

    //storing the values into an imu object
    for(char i = 0; i < 3; i++)
    {
        imuGlobalObj[indexNo].angle[i] = parseFloat(receiveVar[i+1]);   //println(imuGlobalObj[indexNo].angle[i]);
    }
    port.clear();
  }
}

void rotateShape(float xAng, float yAng, float zAng){
    rotateX(radians(xAng)); rotateY(radians(yAng)); rotateZ(radians(zAng));
}