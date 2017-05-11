import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;
// import UDP library
import hypermedia.net.*;

Kinect kinect;
ArrayList <SkeletonData> bodies;
UDP udp;  // define the UDP object
String[] ip = new String[4];
float[] servos = new float[2];

void setup()
{
  size(640, 480);
  background(0);
  kinect = new Kinect(this);
  smooth();
  bodies = new ArrayList<SkeletonData>();
  udp = new UDP( this, 6000 );
  udp.listen( true );
  ip[0] = "192.168.1.100";
  ip[1] = "192.168.1.103";
  ip[2] = "192.168.1.102";
  ip[3] = "192.168.1.101";
  
}

void draw()
{
  background(0);
  image(kinect.GetImage(), 320, 0, 320, 240);
  image(kinect.GetDepth(), 320, 240, 320, 240);
  image(kinect.GetMask(), 0, 240, 320, 240);
  for (int i=0; i<bodies.size (); i++) 
  {
    drawSkeleton(bodies.get(i));
    drawPosition(bodies.get(i));
    //println(bodies.get(i).skeletonPositionTrackingState[Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT]);
    // DETECT ARM MOTION
    if(bodies.get(i).skeletonPositionTrackingState[Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT]!= 0)
  {
      float shoulderC = bodies.get(i).skeletonPositions[Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER].y;
    float high = bodies.get(i).skeletonPositions[Kinect.NUI_SKELETON_POSITION_HIP_RIGHT].y;
    float w = bodies.get(i).skeletonPositions[Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT].y;
    servos[0] = Math.max(Math.min(((w-shoulderC)*100)/(high-shoulderC),100),0);
    //println(servos[0]);
  }
  // DETECT BODY ROTATION
  float shoulderL = bodies.get(i).skeletonPositions[Kinect.NUI_SKELETON_POSITION_HIP_LEFT].x;
  float shoulderR = bodies.get(i).skeletonPositions[Kinect.NUI_SKELETON_POSITION_HIP_RIGHT].x;
  float spine =  bodies.get(i).skeletonPositions[Kinect.NUI_SKELETON_POSITION_SPINE].x;
  float wristR = bodies.get(i).skeletonPositions[Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT].x;
  float wristL = bodies.get(i).skeletonPositions[Kinect.NUI_SKELETON_POSITION_WRIST_LEFT].x;
  float head = bodies.get(i).skeletonPositions[Kinect.NUI_SKELETON_POSITION_HEAD].x;
 
 if(shoulderL<wristL)
 {
   println("turning right");
   
    servos[1] = 180;
 }
 if(shoulderR>wristR)
 {
   
   println("turning left");
   servos[1] = 0;
 }
 if(shoulderL>wristL && shoulderR<wristR)
 {
  println("goto center");
  servos[1] = 90;
  }
  println(servos[1]);
  }
  // SEND DATA
  sendData();
}

void drawPosition(SkeletonData _s) 
{
  noStroke();
  fill(0, 100, 255);
  String s1 = str(_s.dwTrackingID);
  text(s1, _s.position.x*width/2, _s.position.y*height/2);
}

void drawSkeleton(SkeletonData _s) 
{
  // Body
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_HEAD, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
  Kinect.NUI_SKELETON_POSITION_SPINE);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, 
  Kinect.NUI_SKELETON_POSITION_SPINE);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_SPINE);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_SPINE, 
  Kinect.NUI_SKELETON_POSITION_HIP_CENTER);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_HIP_CENTER, 
  Kinect.NUI_SKELETON_POSITION_HIP_LEFT);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_HIP_CENTER, 
  Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_HIP_LEFT, 
  Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);

  // Left Arm
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, 
  Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT, 
  Kinect.NUI_SKELETON_POSITION_WRIST_LEFT);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_WRIST_LEFT, 
  Kinect.NUI_SKELETON_POSITION_HAND_LEFT);

  // Right Arm
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_HAND_RIGHT);

  // Left Leg
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_HIP_LEFT, 
  Kinect.NUI_SKELETON_POSITION_KNEE_LEFT);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_KNEE_LEFT, 
  Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT, 
  Kinect.NUI_SKELETON_POSITION_FOOT_LEFT);

  // Right Leg
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_HIP_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT);
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_FOOT_RIGHT);
}

void DrawBone(SkeletonData _s, int _j1, int _j2) 
{
  noFill();
  stroke(255, 255, 0);
  if(_j2==Kinect.NUI_SKELETON_POSITION_WRIST_LEFT)
  {
   // println(_s.skeletonPositions[_j2].y);
  }
  if (_s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED &&
    _s.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
    line(_s.skeletonPositions[_j1].x*width/2, 
    _s.skeletonPositions[_j1].y*height/2, 
    _s.skeletonPositions[_j2].x*width/2, 
    _s.skeletonPositions[_j2].y*height/2);
  }
}

void appearEvent(SkeletonData _s) 
{
  if (_s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(bodies) {
    bodies.add(_s);
  }
}

void disappearEvent(SkeletonData _s) 
{
  synchronized(bodies) {
    for (int i=bodies.size ()-1; i>=0; i--) 
    {
      if (_s.dwTrackingID == bodies.get(i).dwTrackingID) 
      {
        bodies.remove(i);
      }
    }
  }
}

void moveEvent(SkeletonData _b, SkeletonData _a) 
{
  if (_a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(bodies) {
    for (int i=bodies.size ()-1; i>=0; i--) 
    {
      if (_b.dwTrackingID == bodies.get(i).dwTrackingID) 
      {
        bodies.get(i).copy(_a);
        break;
      }
    }
  }
}
void sendData(){
    int port        = 8888;    // the destination port
    
    // formats the message for Pd
    String message1 = constrain(round(map( servos[0],0,100,0,180)),0,180)+"";
    String message2 = Float.toString(servos[1]);
    println(message2);
    // send the message
    for(int k=0;k<ip.length;k++)
    {
      udp.send( message1+","+message2, ip[k], port );
    }
    
 //udp.send( message2, ip2, port );

}