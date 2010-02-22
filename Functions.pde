float[][] kernel = { 
  { -1, -1, -1},
  { -1,  5, -1},
  { -1, -1, -1}, 
};

int[] getPixelEdges(int[] img) {
  for (int y = 1; y < video.height-1; y++) {
    for (int x = 1; x < video.width-1; x++) {
      float sum = 0;
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          // Calculate the adjacent pixel for this kernel point
          int pos = (y + ky)*video.width + (x + kx);
          // Multiply adjacent pixels based on the kernel values
          // Use Red channel, normally it's the best channel for webcams
          sum += kernel[ky+1][kx+1] * ((img[pos] >> 16) & 0xFF);
        }
      }
      // For this pixel in the new image, set the gray value
      // based on the sum from the kernel
      img[y*video.width + x] = color(sum);
    }
  }
  return img;
}

int[] getDifference(int[] frame, int[] lastFrame) {
    int[] diff = new int[frame.length];
    for (int i = 0; i < frame.length; i++) {
      color currColor = frame[i];
      color prevColor = lastFrame[i];
      int currR = (currColor >> 16) & 0xFF;
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;
      int prevR = (prevColor >> 16) & 0xFF;
      int prevG = (prevColor >> 8) & 0xFF;
      int prevB = prevColor & 0xFF;
      int diffR = abs(currR - prevR);
      int diffG = abs(currG - prevG);
      int diffB = abs(currB - prevB);
      diff[i] = 0xff000000 | (diffR << 16) | (diffG << 8) | diffB;
      lastFrame[i] = currColor;
    }
    return diff;
}

float[][] getPoints(int[] img) {
  int numPoints = 0;
  for (int y = 1; y < video.height-1; y++) {
    for (int x = 1; x < video.width-1; x++) {
      if (((img[y*video.width + x] >> 16) & 0xFF) > 0) numPoints++;
    }
  }

  float[][] points = new float[numPoints][2];
  int i = 0;
  for (int y = 1; y < video.height-1; y++) {
    for (int x = 1; x < video.width-1; x++) {
      if (((img[y*video.width + x] >> 16) & 0xFF) > 0) {
        float[] p = {x, y};
        points[i] = p;
        i++;
      }
    }
  }
  return points;
}
