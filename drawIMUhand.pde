//creating a simple program to represent one joint
import processing.opengl.*;
import processing.serial.*;

Serial port;
String serialData;
String[][] serialStrings = new String[5][3];  //5 fingers, 3 values (the joint angles)

float grid = 400;
int spinAngGlobal = 0, yawAngGlobal;

color WHITE = #FFFFFF;
color RED = #FF0000;
color BLUE = #0000FF;
color GREEN = #00FF00;
color YELLOW = #FFFF00;

class imuData{
    float[] jointAngle = new float[4];
    float yawAngle;
    float palmAngle;
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
    getSerialData();
    
    background(0);

    translate((width/2),(height/2),-100);
    rotateX(radians(imuGlobalObj[0].palmAngle));
    rotateY(radians(spinAngGlobal));

    push();
        push();
        translate(0,0,0);  
        //draw3DExample(imuGlobalObj[0],45, BLUE);
        pop();

        push();
        translate(0,0,50);  
        draw3DExample(imuGlobalObj[1],imuGlobalObj[1].yawAngle, WHITE);
        pop();

        push();
        translate(0,0,100);  
        draw3DExample(imuGlobalObj[2],imuGlobalObj[2].yawAngle, RED);
        pop();

        push();
        translate(0,0,150);  
        draw3DExample(imuGlobalObj[3],imuGlobalObj[3].yawAngle, GREEN);
        pop();

        push();
        translate(0,0,200);  
        draw3DExample(imuGlobalObj[4],imuGlobalObj[4].yawAngle, YELLOW);
        pop();
    pop();
    
}


void draw3DExample(imuData imuDataObj, float yawAng, int colour){
    float x = 0, y = 0, z = 0; 
    char fingerLen = 100, fingerWid = 10;
    float[] xCenter = new float[4];
    float[] yCenter = new float[4];
    float[][] jointCoord = new float[4][2];
    float[] angleSum = new float[3];

    //jointAng[0] = 45;   jointAng[1] = 45;   jointAng[2] = 45;
    angleSum[0] = radians(imuDataObj.jointAngle[2]);
    angleSum[1] = radians(imuDataObj.jointAngle[2] + imuDataObj.jointAngle[1]);
    angleSum[2] = radians(imuDataObj.jointAngle[2] + imuDataObj.jointAngle[1] + imuDataObj.jointAngle[0]);

    //drawing the skeleton
    push();
        translate(x,y,z); 
        rotateY(radians(yawAng));
        //first line
        push();
        stroke(colour);
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
        stroke(colour);
        noFill();
        box(fingerLen,10,fingerWid);
        sphere(5);
        pop();

        // first-second line joint
        push();
        jointCoord[0][0] = x + fingerLen;
        jointCoord[0][1] = y;
        translate(jointCoord[0][0], jointCoord[0][1]);
        stroke(colour);
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
            stroke(colour);
            noFill();
            box(fingerLen,10,fingerWid);
            sphere(5);
            pop();

            //end of line
            push();
            jointCoord[i][0] = jointCoord[i-1][0] + (fingerLen)*cos(angleSum[i-1]);
            jointCoord[i][1] = jointCoord[i-1][1] + (fingerLen)*sin(angleSum[i-1]);
            translate(jointCoord[i][0], jointCoord[i][1]);
            stroke(colour);
            sphere(5);
            pop();

            //drawing the line
            push();
            stroke(colour);
            line(jointCoord[i-1][0], jointCoord[i-1][1], 0, jointCoord[i][0], jointCoord[i][1], 0);
            pop();

        }
    pop();

}

void mouseMoved() {
    spinAngGlobal++;
}

void mouseDragged() {
    yawAngGlobal++;
}

void getSerialData(){
  if( port.available() > 0) // If data is available,
  { 
    serialData = port.readStringUntil('\n');         // read the entire string until the newline
    String[] receiveVar = new String[5];
    int indexNo;
    //splitting the string
    receiveVar = split(serialData, " ");  // index 0 finger strip num, 1 jointAng1(tip), 2 jointAng2(mid), 3 jointAng3(base), yaw
    indexNo = int(receiveVar[0]);  //println(indexNo);

    //storing the values into an imu object
    for(char i = 0; i < 3; i++)
    {
        imuGlobalObj[indexNo].jointAngle[i] = parseFloat(receiveVar[i+1]);   //println(imuGlobalObj[indexNo].jointAngle[i]);
    }

    imuGlobalObj[indexNo].yawAngle = parseFloat(receiveVar[4]);
    imuGlobalObj[indexNo].palmAngle = parseFloat(receiveVar[5]);
    port.clear();
  }
}

void rotateShape(float xAng, float yAng, float zAng){
    rotateX(radians(xAng)); rotateY(radians(yAng)); rotateZ(radians(zAng));
}