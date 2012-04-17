/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
 
  This example code is in the public domain.
 */

#include <Servo.h>

#include <Max3421e.h>
#include <Usb.h>
#include <AndroidAccessory.h>

#define  LED         13

// right
const int xpin = A0;                  // x-axis of the accelerometer
const int ypin = A1;                  // y-axis
const int zpin = A2;                  // z-axis (only on 3-axis models)

// left
const int xpin2 = A3;                  // x-axis of the accelerometer
const int ypin2 = A4;                  // y-axis
const int zpin2 = A5;                  // z-axis (only on 3-axis models)

Servo servo;

// Define the number of samples to keep track of. The higher the number,
// the more the readings will be smoothed, but the slower the output will
// respond to the input. Using a constant rather than a normal variable lets
// use this value to determine the size of the readings array.
const int numReadings = 10;

int readings[6][numReadings];      // the readings from the analog input
int index = 0;                  // the index of the current reading
int i;
int total[6] = {0, 0, 0, 0, 0, 0};                  // the running total
int average[6] = {0, 0, 0, 0, 0, 0};                // the average
const int pin[6] = {xpin, ypin, zpin, xpin2, ypin2, zpin2};


// servo pattern
byte ptr = 0;
byte length = 4;
int values[] = {10,0,20,0};
rep = 0;

unsigned long previous;
int interval = 0;
boolean enabled = true;


AndroidAccessory acc("Open Accessories",
		     "ADKAlarm",
		     "ADK Alarm",
		     "1.0",
		     "http://brugtug.github.com/ADKAlarm",
		     "0000000012345679");

void setup() {             
	Serial.begin(9600);
	Serial.print("\r\nStart");
  
  	servo.attach(SERVO1);
	servo.write(10);

    for (index = 0; index < numReadings; index ++){
      for (i = 0; i < 6; i++){
        readings[i][index] = 0;
      }
    }
    acc.powerOn();

}

void loop() {
  
    byte err;
	byte idle;
	static byte count = 0;
	
	byte msg[2];
	
    byte accMsg[4];
        
        
	if (acc.isConnected()) {
  
		// read message from device
		if (index >= numReadings){
			int len = acc.read(msg, sizeof(msg), 1);	   
  
			if (len > 0) {
				// assumes only one command per packet
				if (msg[0] == 0x1) {
					enabled = (msg[1] == 1);                     		    				
            	} 
            }
		}
		

		int i;
		for (i = 0; i < 6; i++){
			// subtract the last reading:
			total[i]= total[i] - readings[i][index];         
			// read from the sensor:
			readings[i][index] = analogRead(pin[i]); 
			// add the reading to the total:
			total[i]= total[i] + readings[i][index];       
			// advance to the next position in the array:
			index = index + 1;                    
        
			// if we're at the end of the array...
			if (index >= numReadings){              
				// ...wrap around to the beginning:
				index = 0;                           
        
				// calculate the average:
				average[i] = total[i] / numReadings;         
				// send it to the computer as ASCII digits
				Serial.println(average[i]);  
				Serial.print("\t");      
			}
		}
          
          if (index == 0){
        	  Serial.println();             
        	  accMsg = {0x1, average[0] & 0xFF, (average[0] >>8 ) & 0xFF), average[1] & 0xFF, (average[1] >>8 ) & 0xFF), average[2] & 0xFF, (average[2] >>8 ) & 0xFF)};
        	  acc.write(accMsg, 7);
        	  accMsg = {0x2, average[3] & 0xFF, (average[3] >>8 ) & 0xFF), average[4] & 0xFF, (average[4] >>8 ) & 0xFF), average[5] & 0xFF, (average[5] >>8 ) & 0xFF)};
        	  acc.write(accMsg, 7);
          }
          
        
         if ( (millis() - previous >= interval))
          {
            previous = millis();
            patternCount = patternCount + 1;                     
            
            if (patternIndex == 1){ 
         
              if (first){
                servo.write(map(10, 0, 180, 0, 180));				
                first = false;
              } else {
               servo.write(map(100, 0, 180, 0, 180));				
               first = true;
             }
          } else if (patternIndex == 2) {
              if (first){
                servo.write(map(10, 0, 180, 0, 180));				
                first = false;
              } else {
               servo.write(map(20, 0, 180, 0, 180));				
               first = true;
             }
             
            
          } else {
            // don't do anything
          }
        }
  }
  
  void send16(int value) {
    // send both bytes
    Serial.print(value & 0xFF, BYTE);
    Serial.print((value >> 8) & 0xFF, BYTE);
  }
}
