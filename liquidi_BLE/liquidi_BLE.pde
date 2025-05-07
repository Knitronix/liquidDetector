//PROCESSING
 
/*
Sensor orientation: corner 0,0
face up
0=top right
1=bottom right
2=bottom left
3=top left
 
face down
4=top right
5=bottom right
6=bottom left
7=top left
 
*/
int Orient = 7;
 
// Number of columns and rows in the grid
int cols = 1;
int rows = 4;
// Window dimension
int ScrDimX = 800;
int ScrDimY = 700;
 
int PixDimX;
int PixDimY;
int ScrDimMUX;
int ScrDimMUY;
 
int CicliInterpolazione = 0; //change this number for interpolation  cycles 0=no interpolation, 3 = max interpolation.
// Declare 2D array
//float[] myArray = new float[cols*rows];
int[] myArray = new int[cols*rows*int(pow(4,CicliInterpolazione))];
byte[] BuffArray = new byte[cols*rows];
 
// binary receive
int State; //-1 = waiting for 1 start pattern hAA
//-2 = waiting for 2 start pattern h55
//-3 = waiting for 1 end pattern hF0
//-4 = waiting fot 2 end pattern h0F
//>0 caracter to be received to fill the frame
 
int hAA = unhex("AA");
int h55 = unhex("55");
int hF0 = unhex("F0");
int h0F = unhex("0F");
 
int ArrIndex;
boolean exitloop;
int lastTime, now;
 
int vCols; //Visual Cols
int vRows; //Visual Rows
 
import processing.serial.*;
 
 
Serial myPort;
 
void setup() {
  vRows=rows;
  vCols=cols;
  for (int i = 1; i <= CicliInterpolazione; i++) {
    vRows=vRows*2-1;
    vCols=vCols*2-1;
  }
  if (Orient == 0 || Orient == 2 || Orient == 5 || Orient == 7){
    //size(ScrDimX, ScrDimY);
    surface.setSize(ScrDimX,ScrDimY);
    }
  else{
    //size(ScrDimY, ScrDimX);
    surface.setSize(ScrDimY,ScrDimX);
  }
  PixDimX=ScrDimX/vCols;
  PixDimY=ScrDimY/vRows;
  ScrDimMUX=ScrDimX-PixDimX;
  ScrDimMUY=ScrDimY-PixDimY;
  // List all the available serial ports
  println(Serial.list());
  // I know that the first port in the serial list on my mac
  // is always my  Arduino, so I open Serial.list()[0].
  // Open whatever port is the one you're using.
  //questa linea per seriale usb
  //myPort = new Serial(this, Serial.list()[0], 38400);
  //questa linea per seriale BT
  myPort = new Serial(this, Serial.list()[0], 9600);
 
 
//  myPort = new Serial(this, Serial.list()[0], 115200);
//  myPort = new Serial(this, Serial.list()[0], 9600);
//  myPort = new Serial(this, Serial.list()[1], 57600);
  // don't generate a serialEvent() unless you get a newline character:
  // myPort.bufferUntil('\n');
  State = -1; //waiting for 1 start pattern
  ArrIndex = 0;
  exitloop = false;
}
 
void draw() {
  int inByte=0;
  int valore;
 
  exitloop = false;
  while ((myPort.available() > 0) && !exitloop) {
    if (State < 0) {
      inByte = myPort.read();
      //println(inByte, State, myPort.available());
    }
    if (State == -1) {
      if (inByte == hAA ) {
        State = -2; //first pattern OK - Wait for the second
      }
    }
    else if (State == -2) {
      if (inByte == h55 ) {
        State = cols * rows; //second pattern OK - byte to get
      }
    }
    else if (State == -3) {
      if (inByte == hF0 ) {
        State = -4; //first pattern OK - Wait for the second
      }
      else
      {
        //print("-");
        ;
      }
    }
    else if (State == -4) {
      if (inByte == h0F ) {
        exitloop = true;
        now = millis();
        //println(now- lastTime);
        lastTime = now;
        State = -1; //wait for next frame
        ArrIndex = 0;
        println("vv");
        //esegue interpolazione
        for (int CI=0;CI<CicliInterpolazione; CI++) {
          Interpola(CI);
        }
        //show data on screen
        colorMode(HSB,350,300,255);
        strokeWeight(0);
        for (int i = 0; i < vRows; i++) {
          for (int j = 0; j < vCols; j++) {
            valore=myArray[(i*vCols)+j];
//modifica per gestione sensore acqua
//            if (valore > 50)
              if (valore > 90)
              valore=180; //celeste acqua
            else
              valore=255; //bianco
//Fine modifica per acqua
          
            if (valore<210) {
              stroke(valore,300,255);
              fill(valore,300,255);
            }
            else {
              stroke(valore,300+((210-valore)*8),255);
              fill(valore,300+((210-valore)*8),255);
            }
//             println("valori i=" + i + " j="+ j + "val=" +  int(myArray[(i*vCols)+j]));
            switch(Orient) {
            case 0:
              rect(j*PixDimX, ScrDimMUY-(i*PixDimY), PixDimX, PixDimY);
              break;
            case 1:
              rect(i*PixDimY, j*PixDimX, PixDimY, PixDimX);
              break;
            case 2:
              rect(ScrDimMUX-(j*PixDimX), i*PixDimY, PixDimX, PixDimY);
              break;
            case 3:
              rect(ScrDimMUY-(i*PixDimY), ScrDimMUX-(j*PixDimX),  PixDimY, PixDimX);
              break;
            case 4:
              rect(i*PixDimY, ScrDimMUX-(j*PixDimX), PixDimY, PixDimX);
              break;
            case 5:
              rect(j*PixDimX, i*PixDimY, PixDimX, PixDimY);
              break;
            case 6:
              rect(ScrDimMUY-(i*PixDimY), j*PixDimX, PixDimY, PixDimX);
              break;
            case 7:
              rect(ScrDimMUX-(j*PixDimX), ScrDimMUY-(i*PixDimY),  PixDimX, PixDimY);
              break;
            }
          }
        }
      }
    }
    if (State > 0) {
      if (myPort.available() >= State)    //wait for a complete frame
      {
        myPort.readBytes(BuffArray);
        for (int i = 0; i < State; i++){
          myArray[i]=int(BuffArray[i]);
//          myArray[i]= i*30; //per vedere arcobaleno
          print(myArray[i],',');
        }
        State = -3;
      }
      else {
        //print(".", myPort.available());
        exitloop = true;
      }
    }
  }
}
 
void Interpola(int Ciclo) {
  int cCols; //contatore colonne
  int cRows; //contatore righe
  int bCols; //numero colonne array grande
  int bRows; //numero righe array grande
  int OldCols; //numero colonne array piccolo
  int OldRows; //numero righe array piccolo
 
  OldRows=rows;
  OldCols=cols;
  for (int i = 1; i <= Ciclo; i++) {
    OldRows=OldRows*2-1;
    OldCols=OldCols*2-1;
  }
  bRows=OldRows*2-1;
  bCols=OldCols*2-1;
 
  int pArr;
  int pArrBig;
  int a,b,c,d;
 
  //allarga i punti intervallandoli partendo dalla fine dell'array
   pArr=OldRows*OldCols-1;
   pArrBig=bRows*bCols-1;
 
 
   while (pArrBig>=0 ){
     //copia una riga con valori
     cCols=OldCols;
     while (cCols>0 ){
       myArray[pArrBig]=myArray[pArr];
       if (pArr!=0){
         myArray[pArr]=0;
       }
       pArr--;
       pArrBig=pArrBig-2;
       cCols--;
     }
     //salta una riga vuota
     pArrBig=pArrBig - bCols + 1;
   }
 
   //first interpolation step (X interpolation)
    pArrBig=bCols+1;
    cRows=1;
    while (cRows<bRows-1){
      cCols=1;
      while (cCols<bCols-1){
        a=myArray[pArrBig-bCols-1];
        b=myArray[pArrBig-bCols+1];
        c=myArray[pArrBig+bCols-1];
        d=myArray[pArrBig+bCols+1];
        myArray[pArrBig]=(a+b+c+d)/4;
        pArrBig=pArrBig+2;
        cCols=cCols+2;
      }
      cRows=cRows+2;
      pArrBig=pArrBig+bCols+1;
    }
 
   //border cell interpolation (| interpolation)
    //prima riga
    pArrBig=0;
    cCols=0;
    while (cCols<bCols-2){
      a=myArray[pArrBig];
      b=myArray[pArrBig+2];
      myArray[pArrBig+1]=(a+b)/2;
      pArrBig=pArrBig+2;
      cCols=cCols+2;
    }
 
  //ultima riga
    pArrBig=(bRows-1)*(bCols);
    cCols=0;
    while (cCols<bCols-2){
      a=myArray[pArrBig];
      b=myArray[pArrBig+2];
      myArray[pArrBig+1]=(a+b)/2;
      pArrBig=pArrBig+2;
      cCols=cCols+2;
    }
 
     //prima colonna
    pArrBig=bCols;
    cRows=1;
    while (cRows<bRows-1){
      a=myArray[pArrBig-bCols];
      b=myArray[pArrBig+bCols];
      myArray[pArrBig]=(a+b)/2;
      pArrBig=pArrBig+bCols*2;
      cRows=cRows+2;
    }
     //ultima colonna
    pArrBig=bCols*2-1;
    cRows=1;
    while (cRows<bRows-1){
      a=myArray[pArrBig-bCols];
      b=myArray[pArrBig+bCols];
      myArray[pArrBig]=(a+b)/2;
      pArrBig=pArrBig+bCols*2;
      cRows=cRows+2;
    }
 
    //second interpolation step (+ interpolation) even rows
    pArrBig=bCols+2;
    cRows=1;
    while (cRows<bRows-1){
      cCols=2;
      while (cCols<bCols-2){
        a=myArray[pArrBig-bCols];
        b=myArray[pArrBig-1];
        c=myArray[pArrBig+1];
        d=myArray[pArrBig+bCols];
        myArray[pArrBig]=(a+b+c+d)/4;
        pArrBig=pArrBig+2;
        cCols=cCols+2;
      }
      cRows=cRows+2;
      pArrBig=pArrBig+bCols+3;
    }
 
  //second interpolation step (+ interpolation) odd rows
    pArrBig=bCols*2+1;
    cRows=2;
    while (cRows<bRows-1){
      cCols=1;
      while (cCols<bCols-1){
        a=myArray[pArrBig-bCols];
        b=myArray[pArrBig-1];
        c=myArray[pArrBig+1];
        d=myArray[pArrBig+bCols];
        myArray[pArrBig]=(a+b+c+d)/4;
        pArrBig=pArrBig+2;
        cCols=cCols+2;
      }
      cRows=cRows+2;
      pArrBig=pArrBig+bCols+1;
    }
}
