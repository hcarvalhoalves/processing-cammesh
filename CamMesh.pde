import processing.video.*;
import megamu.mesh.*;

Capture video;
PImage buffer;
int[] lastFrame;

Delaunay mesh;
float[][] points;

boolean renderMesh = false;
float threshold = 0.25;
float maxDistance;

void setup() {
  size(512, 400);
  
  background(0, 0, 0);
  fill(255, 255, 255);
  stroke(255, 255, 255);
  
  hint(ENABLE_NATIVE_FONTS);
  textFont(loadFont("Menlo-Bold-12.vlw"));
  
  video = new Capture(this, 512, 400);
  buffer = new PImage(video.width, video.height);
  lastFrame = new int[video.width * video.height];
  maxDistance = dist(0, 0, video.width, video.height);
}

void draw() {
  if (video.available()) {
    video.read();
    video.filter(GRAY);
    set(0, 0, video);

    buffer.pixels = video.pixels;    
    buffer.pixels = getPixelEdges(getDifference(buffer.pixels, lastFrame));
    buffer.filter(THRESHOLD, threshold);
    if (!renderMesh) {
      blend(buffer, 0, 0, video.width, video.height, 0, 0, video.width, video.height, ADD);
    }

    if (renderMesh) {
      points = getPoints(buffer.pixels);
      mesh = new Delaunay(points);
      float[][] edges = mesh.getEdges();
      for(int i=0; i<edges.length; i++) {
      	float sx = edges[i][0];
      	float sy = edges[i][1];
      	float ex = edges[i][2];
      	float ey = edges[i][3];
        float distance = dist(sx, sy, ex, ey);
        if (distance < maxDistance/4) {
          float strokeAlpha = norm(distance, 0, maxDistance/8);
          stroke(255, 255, 255, 255 - (255*strokeAlpha));
      	  line(sx, sy, ex, ey);
        }
      }    
    }
    
    text("FPS: " + frameRate, 5, 15);
    text("Threshold (+/-): " + threshold, 5, 35);
    text("Render Mesh (M): " + renderMesh, 5, 55);
  }
}

void keyPressed() {
  if (key == 'm') renderMesh = !renderMesh;
  if (key == 's') save("screenshot-" + millis() + ".png");
  if (key == '=') threshold += 0.05;
  if (key == '-') threshold -= 0.05;
  threshold = constrain(threshold, 0.1, 0.9);
}
