//creating a simple program to represent one joint
import processing.opengl.*;
import processing.serial.*;

Serial port;
String serialData;
String[][] serialStrings = new String[5][3];  //5 fingers, 3 values (the joint angles)

float grid = 400;
float angGlobal = 0;

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
    serialSetup();

    frameRate(60);
    
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

    getSerialData();
    translate((width/2),(height/2),-100);  
    rotateX(radians(-45));    //rotating the entire finger
    rotateY(radians(angGlobal));    //rotating the entire finger
    background(0);
    //draw3DExample(imuGlobalObj[0].angle, 0);
    draw3DExample(imuGlobalObj[1].angle, 50);
    //draw3DExample(imuGlobalObj[2].angle, 100);
    draw3DExample(imuGlobalObj[3].angle, 150);
    draw3DExample(imuGlobalObj[4].angle, 200);
    
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


void draw3DExample(float jointAng[], float z){
    float x = 0, y = 0;
    char fingerLen = 100, fingerWid = 10;
    float[] xCenter = new float[4];
    float[] yCenter = new float[4];
    float[][] jointCoord = new float[4][2];
    float[] angleSum = new float[3];

    //jointAng[0] = 45;   jointAng[1] = 45;   jointAng[2] = 45;

    angleSum[0] = radians(jointAng[2]);
    angleSum[1] = radians(jointAng[2] + jointAng[1]);
    angleSum[2] = radians(jointAng[2] + jointAng[1] + jointAng[0]);

    //drawing the skeleton
    push();
        translate(x,y,z); 
        //first line
        push();
        stroke(255);
        line(x, y, 0, x + fingerLen, y, 0);
        translate(x,y);
        sphere(5);
        pop();

        //first center calculation
        xCenter[0] = x + (fingerLen/2);
        yCenter[0] = y;

        //first line center
        push();
        translate(xCenter[0], yCenter[0], 0);
        stroke(255);
        noFill();
        box(fingerLen,10,fingerWid);
        sphere(5);
        pop();

        // first-second line joint
        push();
        jointCoord[0][0] = x + fingerLen;
        jointCoord[0][1] = y;
        translate(jointCoord[0][0], jointCoord[0][1]);
        stroke(255);
        sphere(5);
        pop();

        
        for(char i = 1; i < 4; i++)
        {
            //line center
            push();
            xCenter[i] = jointCoord[i-1][0] + (fingerLen/2)*cos(angleSum[i-1]); 
            yCenter[i] = jointCoord[i-1][1] + (fingerLen/2)*sin(angleSum[i-1]); 
            translate(xCenter[i], yCenter[i]);
    
            rotateZ(angleSum[i-1]);
            stroke(255);
            noFill();
            box(fingerLen,10,fingerWid);
            sphere(5);
            pop();

            //end of line
            push();
            jointCoord[i][0] = jointCoord[i-1][0] + (fingerLen)*cos(angleSum[i-1]);
            jointCoord[i][1] = jointCoord[i-1][1] + (fingerLen)*sin(angleSum[i-1]);
            translate(jointCoord[i][0], jointCoord[i][1]);
            stroke(255);
            sphere(5);
            pop();

            //drawing the line
            push();
            stroke(255);
            line(jointCoord[i-1][0], jointCoord[i-1][1], 0, jointCoord[i][0], jointCoord[i][1], 0);
            pop();

        }
    pop();

}

void mouseMoved() {
    angGlobal++;
}


void getSerialData(){
  if( port.available() > 0) // If data is available,
  { 
    serialData = port.readStringUntil('\n');         // read the entire string until the newline
    String[] receiveVar = new String[4];
    int indexNo;
    //splitting the string
    receiveVar = split(serialData, " ");  // index 0 finger strip num, 1 jointAng1(tip), 2 jointAng2(mid), 3 jointAng3(base) 
    indexNo = int(receiveVar[0]);  //println(indexNo);

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