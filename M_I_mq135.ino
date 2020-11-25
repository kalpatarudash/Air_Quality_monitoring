int gas_sensor= A0;
//#include<DHT.h>
#include<ESP8266WiFi.h>
#include<ESP8266HTTPClient.h>
WiFiClient client;
String apiKey = "M19TDIJTYRT3CXV5";     //  Enter your Write API key from ThingSpeak
 
const char *ssid =  "DASH_2.4G";     // replace with your wifi ssid and wpa2 key
const char *pass =  "9867745832abc";
const char* server = "api.thingspeak.com";


//#define DHTPIN 8     // what pin we're connected to
//#define DHTTYPE DHT11   // DHT 11  (AM2302)
//DHT dht(DHTPIN, DHT11);
//float hum;  //Stores humidity value
//float temp; //Stores temperature value


void setup() {
 //dht.begin();
 Serial.begin(115200);
  Serial.println("Connecting to ");
       Serial.println(ssid);
 
 
       WiFi.begin(ssid, pass);
 
      while (WiFi.status() != WL_CONNECTED) 
     {
            delay(500);
            Serial.print(".");
     }
      Serial.println("");
      Serial.println("WiFi connected");

}

void loop() {
 int sensorValue= analogRead(gas_sensor);
 
  if (client.connect(server,80))   //   "184.106.153.149" or api.thingspeak.com
                      {  
                            
                             String postStr = apiKey;
                             postStr +="&field1=";
                             postStr += String(sensorValue);
                             //postStr +="&field2=";
                             //postStr += String(hum);
                             //postStr +="&field3=";
                             //postStr +=String(temp);
                             postStr += "\r\n\r\n";
 
                             client.print("POST /update HTTP/1.1\n");
                             client.print("Host: api.thingspeak.com\n");
                             client.print("Connection: close\n");
                             client.print("X-THINGSPEAKAPIKEY: "+apiKey+"\n");
                             client.print("Content-Type: application/x-www-form-urlencoded\n");
                             client.print("Content-Length: ");
                             client.print(postStr.length());
                             client.print("\n\n");
                             client.print(postStr);
 
                             Serial.print("AirQua=");
                     Serial.print(sensorValue, DEC);               // prints the value read
                     Serial.println(" PPM");
                     //Read data and store it to variables hum and temp
   //hum = dht.readHumidity();
    //temp= dht.readTemperature();
   // Print temp and humidity values to serial monitor
    //Serial.print("Humidity: ");
    //Serial.print(hum);
    //Serial.print(" %, Temp: ");
    //Serial.print(temp);
    //Serial.println("celcius");
                     delay(1500);
                             
                        }
          client.stop();
 
          Serial.println("Waiting...");
  
  // thingspeak needs minimum 15 sec delay between updates
  delay(1000);
}
