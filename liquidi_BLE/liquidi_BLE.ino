//BEGINS ARDUINO SKETCH
//configurazione interfaccia seriale
 
//#define SerEnable
#define BTEnable
 
 
//gestione BT
#ifdef BTEnable
  #include <SoftwareSerial.h>
  #define Rxpin 9 // Tx per Bluetooth Rx per Arduino
  #define Txpin 8 // Rx per Bluetooth Tx per Arduino
  char  BluetoothBuffer;
  char  SerialBuffer;
  SoftwareSerial Bluetooth(Rxpin, Txpin);
#endif
 
const int Cols = 1; //Define cols number ( 1 >= Cols >= 16 )
const int Rows = 4; //Define rows number
 
const int Level = 1.0; //define amplitude of signal mapping
 
//declaration of the INPUT pins we will use; i is the position within the array;
//i = 0 corresponds to output 2 (questo commento mi sembra errato ??!!??)
//si devono dichiarare tanti canali analogici quante sono le colonne dichiarate sopra.
int Pin[]= {A0, A1, A2, A3};
 
//si devono dichiarare tante linee di IO digitali quante righe sono dichiarate sopra
//int dPin[] = {22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 18, 19, 20, 21}; //declaration of the OUTPUT pins we will use; i is the position within the array; i = 0 corresponds to output 2
//int dPin[] = {23, 25, 27, 29, 31, 33, 32, 30, 28, 26, 24, 22};   // Pins 22-37 used to supply current to sensor
int dPin[] = {23, 22, 25, 24}; //declaration of the OUTPUT pins we will use;
 
int i = 0;
int j = 0;
int k = 0;
int n = 0;
int m = 0;
int x = 0;
 
int sensorValue[Cols*Rows];
int msensorValue[Cols*Rows];
int mOffsetValue[Cols*Rows];
 
bool FirstLoop;
 
 
// Define various ADC prescaler
const unsigned char PS_16 = (1 << ADPS2);
const unsigned char PS_32 = (1 << ADPS2) | (1 << ADPS0);
const unsigned char PS_64 = (1 << ADPS2) | (1 << ADPS1);
const unsigned char PS_128 = (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
 
 
void setup() {
   FirstLoop = true;
   //FirstLoop = false;              //enter FirstLoop = false; to read values without offset
  for (int k = Cols*Rows-1; k >= 0 ; k--) {
pinMode(dPin[k], OUTPUT);             //declaration of pin[i] as an OUTPUT
}
 
for (j = 0; j >= Cols*Rows-1 ; j++) {
pinMode (Pin[i], INPUT);
}
//  Serial.begin(57600);   //turn serial on
// Serial.begin(115200);   //turn serial on
  Serial.begin(38400);   //turn serial on
//Serial.begin(9600);   //turn serial on
 
  // set up the ADC
  ADCSRA &= ~PS_128;  // remove bits set by Arduino library
 
  // you can choose a prescaler from above.
  // PS_16, PS_32, PS_64 or PS_128
  ADCSRA |= PS_32;    // set our own prescaler to 32
 
#ifdef BTEnable
    Bluetooth.begin(9600);
#endif
 
}
 
void loop(){
  int Media;
  
//Send start pattern
#ifdef SerEnable
  Serial.write( B10101010); //AA
  Serial.write( B01010101); //55
#endif
#ifdef BTEnable
  Bluetooth.write( B10101010); //AA
  Bluetooth.write( B01010101); //55
#endif
 
for (int i = Cols*Rows-1; i >= 0 ; i--) {
                                
  digitalWrite (dPin[i], HIGH); //turn row i on
  delay(5);
  sensorValue[i] = analogRead (Pin[i]) * Level; //read value column m, multiply by Level
  delay(5);
 if (sensorValue[i] < 600) {   // this is to eliminate noise
     sensorValue[i] = 0; 
   }
  msensorValue[i] = map (sensorValue[i], 0, 1024, 0, 255);    //map all values read to a new range from 0 to 255 to visualize on Processing sketch matrice liquidi
//msensorValue[i] = map (sensorValue[i], 550, 680, 255, 0);    //map all values read to a new range from 255 to 0
//msensorValue[i] = map (sensorValue[i], 550, 680, 0, 255);      // narrowing the input interval to 550 --> 680. Reversing mapping from 0 to 255. 638=29°C, 660=25°
//msensorValue[i] = map (sensorValue[i], 460, 580, 0, 255); in this example 580 is the lower limit on Processing. Decrease when minimum temperature decreases.  
// if (msensorValue[i] < 20) {   // this is to eliminate noise
//     msensorValue[i] = 0; 
//   }
// if (FirstLoop) {
//   mOffsetValue[i] = msensorValue[i];
// }
// else {
//   msensorValue[i] = msensorValue[i] - mOffsetValue[i];
//   if (msensorValue[i] < 0 ) {
//     msensorValue[i] = 0;
//   }
// }
  
#ifdef SerEnable
  Serial.write(msensorValue[i]); //invio valori a Processing
#endif
#ifdef BTEnable
  Bluetooth.write(msensorValue[i]); //invio valori a Processing
#endif
 
//Serial.println(msensorValue[i]); //lettura valori su monitor seriale in ASCII
 
  //this block below is to visualize number of sensor and reading in ASCII
  //Serial.print("A");
  //Serial.print(i);
  //Serial.print("=");
  //Serial.print(msensorValue[i]);
  //Serial.print(",");
 
  //END OF BLOCK
  digitalWrite (dPin[i], LOW); //turn row i off
}
delay(1000); //questo ritardo serve per leggere i valori sul monitor seriale
//Send end frame pattern
#ifdef SerEnable
  Serial.write( B11110000); //F0
  Serial.write( B00001111); //0F
#endif
#ifdef BTEnable
  Bluetooth.write( B11110000); //F0
  Bluetooth.write( B00001111); //0F
#endif
//Serial.println(); //this line is to visualize number of sensor and reading in ASCII
 
//if (FirstLoop) {
//Calculate average to calibrate offset cells
//  for (int x = 0; x < Cols*Rows ; x++) {
//    Media+=msensorValue[x];
//  }
//  Media = Media/(Cols*Rows);
//Calculate offset of each cell
//  for (int x = 0; x < Cols*Rows ; x++) {
//    mOffsetValue[x]= msensorValue[x] - Media;
//  }
//  FirstLoop = false;
//}
 
}
 
//ENDS ARDUINO SKETCH

