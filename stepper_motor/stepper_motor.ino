// Define stepper motor connections and steps per revolution:
#define dirPin 2
#define stepPin 3
#define stepsPerRevolution 200

#define finished 8

//int count = 0;
int condition = 0;

void setup() {

   // For Serial
  Serial.begin(9600);
  
  // Declare pins as output:
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  
  pinMode(finished, INPUT);
}

void loop() {

condition = digitalRead(finished);
//Serial.println(condition);

String message = "," + String(condition) ;
  Serial.print(message);

// Set the spinning direction clockwise:
  digitalWrite(dirPin, HIGH);

  // Spin the stepper motor 5 revolutions fast:
  for (int i = 0; i <  stepsPerRevolution; i++)
  {
    // These four lines result in 1 step:
    digitalWrite(stepPin, HIGH);
    delayMicroseconds(2000); 
    
    digitalWrite(stepPin, LOW);
    delayMicroseconds(2000);
  }
}
//
//void BLUETOOTH_message(int status){
////   Serial.flush();
//  String message = "@" + x + String(status) +"@";
//  Serial.print(message);
//}
