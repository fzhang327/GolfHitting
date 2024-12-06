#include <PID_v1_bc.h>
 
#include <AFMotor.h>
 
// Motor definition
AF_DCMotor motor0(1, MOTOR12_1KHZ);
AF_DCMotor motor1(2, MOTOR12_1KHZ);
AF_DCMotor motor2(3, MOTOR34_1KHZ);
AF_DCMotor motor3(4, MOTOR34_1KHZ);
 
// PID variables Kp, Ki, Kd
double setpoint2=752, input2, output2;
double setpoint3=500, input3, output3;
double setpoint0=303, input0, output0;
double setpoint1=500, input1, output1;    
 
int threshold = 15;  
 
PID pid0(&input3, &output0, &setpoint0, 1.0, 1.5, 1.0, DIRECT);
PID pid1(&input0, &output1, &setpoint1, 1.0, 1.5, 1.0, DIRECT);
PID pid2(&input2, &output2, &setpoint2, 1.0, 1.5, 1.0, DIRECT);
PID pid3(&input1, &output3, &setpoint3, 1.0, 1.5, 1.0, DIRECT);
 
void setup() {
// Initialize serial communication
Serial.begin(115200);
 
// input0 = analogRead(A0);
// input1 = analogRead(A1);
// input2 = analogRead(A2);
// input3 = analogRead(A3);
 
// Serial.println("  ");
// Serial.print(" Input 0: ");
// Serial.print(input0);
// Serial.print(" Input 1: ");
// Serial.print(input1);
// Serial.print(" Input 2: ");
// Serial.print(input2);
// Serial.print(" Input 3: ");
// Serial.println(input3);
 
motor0.setSpeed(255);
motor1.setSpeed(255);
motor2.setSpeed(255);
motor3.setSpeed(255);
 
// motor3.run(BACKWARD); delay(1000);
// motor3.run(RELEASE);delay(500);
 
// input0 = analogRead(A0);
// input1 = analogRead(A1);
// input2 = analogRead(A2);
// input3 = analogRead(A3);
 
// Serial.println(" Input 0: ");
// Serial.println(input0);
// Serial.println(" Input 1: ");
// Serial.println(input1);
// Serial.println(" Input 2: ");
// Serial.println(input2);
// Serial.println(" Input 3: ");
// Serial.println(input3);
 
// Initialize PID controllers for both motors
pid0.SetMode(AUTOMATIC);
pid0.SetOutputLimits(0, 55);
 
pid1.SetMode(AUTOMATIC);
pid1.SetOutputLimits(0, 55);
 
pid2.SetMode(AUTOMATIC);
pid2.SetOutputLimits(0, 55);
 
pid3.SetMode(AUTOMATIC);
pid3.SetOutputLimits(0, 55);
}
 
void loop() {
 
 
 
 
input0 = analogRead(A0);
// Serial.print(" Input 0: ");
// Serial.println(input0);
 
input1 = analogRead(A4);
// Serial.print(" Input 1: ");
// Serial.println(input1);
 
input2 = analogRead(A2);
// Serial.print(" Input 2: ");
// Serial.println(input2);
 
input3 = analogRead(A3);
// Serial.print(" Input 3: ");
// Serial.println(input3);
 
 
 
// Check for serial input to update setpoints
if (Serial.available() > 0) {
  String data = Serial.readStringUntil('\n');
  // Assuming serial input is in the format: "setpoint1,setpoint2,setpoint3,setpoint4"
  int firstComma = data.indexOf(',');
  int secondComma = data.indexOf(',', firstComma + 1);
  int thirdComma = data.indexOf(',', secondComma + 1);
 
  if (firstComma > 0 && secondComma > firstComma && thirdComma > secondComma) {
    setpoint2 = data.substring(0, firstComma).toDouble();               // First value is for motor 1
    setpoint3 = data.substring(firstComma + 1, secondComma).toDouble(); // Second value is for motor 2
    setpoint0 = data.substring(secondComma + 1, thirdComma).toDouble(); // Third value is for motor 3
    setpoint1 = data.substring(thirdComma + 1).toDouble();              // Fourth value is for motor 4
  }
}
 
// Bang-bang controller
// joint 2
if (abs(input0 - setpoint0) <= threshold) {
  motor1.run(RELEASE); // Stop the motor if within the threshold
} else if (input0 < setpoint0) {
  motor1.run(FORWARD);
} else {
  motor1.run(BACKWARD);
}
Serial.print(" Joint 2: ");
Serial.print(input0);
Serial.println();
// // joint 3
if (abs(input1 - setpoint1) <= threshold) {
  motor3.run(RELEASE); // Stop the motor if within the threshold
} else if (input1 < setpoint1) {
  motor3.run(BACKWARD);
} else {
  motor3.run(FORWARD);
}
Serial.print(" Joint 3 ");
Serial.print(input1);
Serial.println();
// joint 0
if (abs(input2 - setpoint2) <= threshold) {
  motor2.run(RELEASE); // Stop the motor if within the threshold
} else if (input2 < setpoint2) {
  motor2.run(FORWARD);
} else {
  motor2.run(BACKWARD);
}
Serial.print(" Joint 0: ");
Serial.print(input2);
Serial.println();
// joint 1
if (abs(input3 - setpoint3) <= threshold) {
  motor0.run(RELEASE); // Stop the motor if within the threshold
} else if (input3 < setpoint3) {
  motor0.run(BACKWARD);
} else {
  motor0.run(FORWARD);
}
Serial.print(" Joint 1: ");
Serial.print(input3);
Serial.println();
// // Add a delay to prevent overwhelming the serial monitor
// delay(50);
}