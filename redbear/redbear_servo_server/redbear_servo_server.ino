#if defined(ARDUINO) 
SYSTEM_MODE(SEMI_AUTOMATIC); 
#endif

// your network name also called SSID
extern const char ssid[];
// your network password
extern const char password[];

// UDP Port used for two way communication
unsigned int localPort = 8888;
Servo myservo1;  // create servo object to control a servo
Servo myservo2;  // create servo object to control a servo
char packetBuffer[255]; //buffer to hold incoming packet
char  ReplyBuffer[] = "acknowledged";       // a string to send back

// An UDP instance to let us send and receive packets over UDP
UDP Udp;
void printWifiStatus();

void setup() {
    myservo1.attach(D8);  // attaches the servo on pin 8 to the servo object
    myservo2.attach(D0);  // attaches the servo on pin 7 to the servo object
  //Initialize serial and wait for port to open:
  Serial.begin(115200);

  // attempt to connect to Wifi network:
  Serial.print("Attempting to connect to Network named: ");
  // print the network name (SSID);
  Serial.println(ssid); 
  
  // Connect to WPA/WPA2 network. Change this line if using open or WEP network:
  WiFi.on();
  WiFi.useDynamicIP();
  WiFi.setCredentials(ssid,password);
  WiFi.connect();
  
  while ( WiFi.connecting()) {
    // print dots while we wait to connect
    Serial.print(".");
    delay(300);
  }
  
  Serial.println("\nYou're connected to the network");
  Serial.println("Waiting for an ip address");
  
  while (WiFi.localIP() == INADDR_NONE) {
    // print dots while we wait for an ip addresss
    Serial.print(".");
    delay(300);
  }

  Serial.println("\nIP Address obtained");
  printWifiStatus();

  Serial.println("\nWaiting for a connection from a client...");
  Udp.begin(localPort);
  

  
}

// CHECK IF IP IS READY
boolean IPready = false;

void loop() {
  //Serial.println(WiFi.localIP());
   if(WiFi.localIP() && IPready==false){
  Serial.println(WiFi.localIP());
  IPready = true;
}
   // if there's data available, read a packet
  int packetSize = Udp.parsePacket();
  if (packetSize) {
    Serial.print("Received packet of size ");
    Serial.println(packetSize);
    Serial.print("From ");
    IPAddress remoteIp = Udp.remoteIP();
    Serial.print(remoteIp);
    Serial.print(", port ");
    Serial.println(Udp.remotePort());

    // read the packet into packetBufffer
    int len = Udp.read(packetBuffer, 255);
    if (len > 0) packetBuffer[len] = 0;
    Serial.println("Contents:");

    String item = "123123";
  char * pch;
  pch = strtok (packetBuffer,",");

 int n = 0;
 int servoValue[2];
  
  while (pch != NULL)
  {
    servoValue[n]=atoi(pch);
    n++;
    pch = strtok (NULL, ",");
  }
  
Serial.println(servoValue[0]);
Serial.println(servoValue[1]);

    for(int k=0; k<len; k++){
     // Serial.println(packetBuffer[k]);
      item = String(packetBuffer[k]);
      //Serial.println(item==",");
//      if()
//      {
//        
//      }
//      else{
//        
//      }
      // Serial.println( packetBuffer[k] );
       
//       if(packetBuffer[k]==","){
//
//        Serial.println( "-" );
//       }
      }
      char rotation[3] = {packetBuffer[0],packetBuffer[1],packetBuffer[2]};
      int rotate = atoi(rotation);
     // Serial.println( rotate );
      myservo1.write(servoValue[0]); 
      myservo2.write(servoValue[1]); 
//      Serial.println(item.toInt());
//      unsigned long highWord = packetBuffer[41];
    //  Serial.println( Udp.parseInt()  );
    //Serial.println( (int)item );

    // send a reply, to the IP address and port that sent us the packet we received
    Udp.beginPacket(Udp.remoteIP(), Udp.remotePort());
    Udp.write(ReplyBuffer);
    Udp.endPacket();
  }
}


void printWifiStatus() {
  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  // print your WiFi IP address:
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);

  // print the received signal strength:
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.print(rssi);
  Serial.println(" dBm");
}
