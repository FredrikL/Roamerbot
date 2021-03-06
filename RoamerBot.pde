#include <AFMotor.h>
#include <Servo.h>
/*
Motor layout
^
34
21
*/

/* Misc global stuff*/
Servo pingServo;
AF_DCMotor motor1(1, MOTOR12_64KHZ);
AF_DCMotor motor2(2, MOTOR12_64KHZ);
AF_DCMotor motor3(3, MOTOR12_64KHZ);
AF_DCMotor motor4(4, MOTOR12_64KHZ);
const int pingPin = 2;
int pos = 90; // servo position - forward

/* sensor result */
long distance, range, result;

void setup()
{
  Serial.begin(9600);
  
  pingServo.attach(10);
  pingServo.write(90);
  
  motor1.setSpeed(150);
  motor2.setSpeed(150);
  motor3.setSpeed(150);
  motor4.setSpeed(150);
}

long mesure_range()
{
  // sometimes we get odd vaules, to avoid do 3x readings and return average
  long result = mesure_range_singel() + mesure_range_singel() +mesure_range_singel();
  return result / 3;
}

long mesure_range_singel()
{
  // Ripped code from http://www.arduino.cc/en/Tutorial/Ping
  // The PING))) is triggered by a HIGH pulse of 2 or more microseconds.
  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
  pinMode(pingPin, OUTPUT);
  digitalWrite(pingPin, LOW);
  delayMicroseconds(2);
  digitalWrite(pingPin, HIGH);
  delayMicroseconds(5);
  digitalWrite(pingPin, LOW);
  
  // The same pin is used to read the signal from the PING))): a HIGH
  // pulse whose duration is the time (in microseconds) from the sending
  // of the ping to the reception of its echo off of an object.
  pinMode(pingPin, INPUT);
  long duration = pulseIn(pingPin, HIGH);  
  long cm =duration / 29 / 2;
  
 Serial.print("Range: ");
  Serial.print(cm);
  Serial.print("cm");
  Serial.println();
  
  return cm;
}

void forward()
{
  Serial.println("forward");
  motor1.run(FORWARD);
  motor2.run(FORWARD);
  motor3.run(FORWARD);
  motor4.run(FORWARD);
}

void backward()
{
  Serial.println("back");
  motor1.run(BACKWARD);
  motor2.run(BACKWARD);
  motor3.run(BACKWARD);
  motor4.run(BACKWARD);
}

void stop()
{
  motor1.run(RELEASE);
  motor2.run(RELEASE);
  motor3.run(RELEASE);
  motor4.run(RELEASE);
}

void left()
{
  Serial.println("left");
  motor1.run(FORWARD);
  motor2.run(RELEASE);
  motor3.run(RELEASE);
  motor4.run(FORWARD);
}

void right()
{
  Serial.println("right");
  motor1.run(RELEASE);
  motor2.run(FORWARD);
  motor3.run(FORWARD);
  motor4.run(RELEASE);
}

void loop()
{
  range = mesure_range();
  Serial.print("Range: ");
  Serial.print(range);
  Serial.print("cm");
  Serial.println();
  if(range > 70)
  {
    Serial.print("Forward!");
    forward();
  }
  else 
  { 
    // mesure range left/right
    pingServo.write(45);
    delay(400);
    long range_left = mesure_range();
    pingServo.write(135);
    delay(400);
    long range_right = mesure_range();
    pingServo.write(90);
    if(range_left < 50 & range_right < 50)
    {
      backward();
      delay(2000);
      result = random(2);
      if(result == 1)
      {
        left();
        delay(1000);
      }
      else{
        right();
        delay(1000);
      }
    }
    else
    {
      if(range_left > range_right)
      {
        left();
        delay(1500);
      }
      else
      {
        right();
        delay(1500);
      }
    }
  }
  
  delay(150);
}
