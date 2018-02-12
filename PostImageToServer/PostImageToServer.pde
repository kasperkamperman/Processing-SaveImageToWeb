import processing.video.*;

Capture cam;

PImage webcamFrame;
PImage webcamPicture;

String onScreenText;
PFont SourceCodePro;

// camera in the setup in combination with other code, sometimes gives a
// Waited for 5000s error: "java.lang.RuntimeException: Waited 5000ms for: <"...
// so we will do init in the draw loop
boolean cameraInitDone = false;

// one image per second
int minimalUploadInterval = 1000; 

boolean isImageUploading = false;
int lastImageUploadTime = 0; 

ImageUploader imageUploader;

public void setup() {
  size(1280,720,P2D);
  
  SourceCodePro = createFont("SourceCodePro-Regular.ttf",12);
  textFont(SourceCodePro);
  
  onScreenText = "Press space to take a picture and sent to server.";
}

void draw() {
  
  background(0);
 
  if(!cameraInitDone) {
    fill(255);
    onScreenText = "Waiting for the camera to initialize...";
    initCamera();
  }
  else {
    if (cam.available() == true) {
      cam.read();
      // store the frame in PImage webcamFrame
      // we can't acces the cam outside of the draw-loop
      webcamFrame = cam.get();
    }
    
    // keep the aspectratio correct based on the displayed width
    float aspectRatio = cam.height/(float)cam.width;
    int imageWidth = width/2;
    
    image(webcamFrame,0,0,imageWidth,aspectRatio*imageWidth);
    
    // show the picture (if it exist)
    if(webcamPicture!=null) {
      image(webcamPicture,imageWidth,0,imageWidth,aspectRatio*imageWidth);
    }
    
  }
  
  text(onScreenText,20,380,width-40,height-20);
  
  if(imageUploader!=null) {
    if(imageUploader.isDataAvailable()) {
      onScreenText = imageUploader.getDataString();
      isImageUploading = false;
    }
  }
 
}

void keyPressed() {
  // space-bar
  if(keyCode == 32) {
    startImageUpload();  
  }
}

void startImageUpload() {
  
  if(isImageUploading == false) {
    if((millis() - minimalUploadInterval) > lastImageUploadTime) {
      webcamPicture = webcamFrame.get();
      onScreenText = "The image will be sent to the server.";
      isImageUploading = true;
      
      imageUploader = new ImageUploader(webcamPicture);
    }
    else {
      onScreenText = "The image is sent to fast.";  
    }
  }
  else {
    onScreenText = "The image is still being stored.";
  }
          
}

void initCamera() { 
  
  // make sure the draw runs one time to display the "waiting" text
  if(frameCount<2) return;
  
   String[] cameras = Capture.list();

   if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
   } 
   else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[0]);
    
    // Start capturing the images from the camera
    cam.start();
    
    while(cam.available() != true) {
      delay(1);
    }
    
    cameraInitDone = true;
    onScreenText = "";
  }
   
}