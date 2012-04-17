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

// input pin for button/contact
const int contactPin = 2;
const int ledPin = LED;

// variables will change:
int buttonState = 0;         // variable for reading the pushbutton status
boolean enabled = true;


AndroidAccessory acc("BruGTUG",
		     "ADKAlarm",
		     "ADK Alarm",
		     "1.0",
		     "http://brugtug.github.com/ADKAlarm",
		     "0000000012345679");

void setup() {             
    acc.powerOn();

}

void loop() {
  
    byte msg[2];
	      
    if (acc.isConnected()) {
    
      int len = acc.read(msg, sizeof(msg), 1);	   
  
      if (len > 0) {
	// assumes only one command per packet
        if (msg[0] == 0x1) {
	  enabled = (msg[1] == 1);                     		    				
        } 
      }
      
      // read the state of the pushbutton value:
      buttonState = digitalRead(contactPin);
      // check if the pushbutton is pressed.
      // if it is, the buttonState is HIGH:
      if (buttonState == HIGH) {     
        // turn LED on:    
        digitalWrite(ledPin, HIGH);       
        msg = {0x1, 0x1};
        acc.write(msg,2);
      } 
      else {
        // turn LED off:
        digitalWrite(ledPin, LOW); 
        msg = {0x1, 0x1};
        acc.write(msg,2);
      }		
  }
}
