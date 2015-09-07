// Colorspace converters

final int getR(color c) { return (c & 0xff0000) >> 16; }
final int getG(color c) { return (c & 0xff00) >> 8; }
final int getB(color c) { return c & 0xff; }

// normalized versions
final float getNR(color c) { return ((c & 0xff0000) >> 16)/255.0; }
final float getNG(color c) { return ((c & 0xff00) >> 8)/255.0; }
final float getNB(color c) { return (c & 0xff)/255.0; }

color blendRGB(color c, int r, int g, int b) {
  return (c & 0xff000000) | ( constrain(r,0,255) << 16) | ( constrain(g,0,255) << 8 ) | (constrain(b,0,255));
}

// XYZ ranges
final static float RANGE_X = 100.0 * (0.4124+0.3576+0.1805);
final static float RANGE_Y = 100.0;
final static float RANGE_Z = 100.0 * (0.0193+0.1192+0.9505);

float correctionxyz(float n) {
  return (n > 0.04045 ? pow((n + 0.055) / 1.055, 2.4) : n / 12.92) * 100.0;
}

PVector _toXYZ(PVector c) {
  float r = correctionxyz(c.x);
  float g = correctionxyz(c.y);
  float b = correctionxyz(c.z);
  return new PVector(r * 0.4124 + g * 0.3576 + b * 0.1805,
                     r * 0.2126 + g * 0.7152 + b * 0.0722,
                     r * 0.0193 + g * 0.1192 + b * 0.9505);
}

color toXYZ(color c) {
  PVector xyz = _toXYZ(new PVector(getNR(c),getNG(c),getNB(c)));
  return blendRGB(c,
         (int)map(xyz.x,0,RANGE_X,0,255),
         (int)map(xyz.y,0,RANGE_Y,0,255),
         (int)map(xyz.z,0,RANGE_Z,0,255));
}

final static float corrratio = 1.0/2.4;
float recorrectionxyz(float n) {
  return n > 0.0031308 ? 1.055 * pow(n, corrratio) - 0.055 : 12.92 * n;
}

PVector _fromXYZ(PVector xyz) {
  xyz.div(100.0);
  
  float r = recorrectionxyz(xyz.x * 3.2406 + xyz.y * -1.5372 + xyz.z * -0.4986);
  float g = recorrectionxyz(xyz.x * -0.9689 + xyz.y * 1.8758 + xyz.z * 0.0415);
  float b = recorrectionxyz(xyz.x * 0.0557 + xyz.y * -0.2040 + xyz.z * 1.0570);
  
  return new PVector(r,g,b);
}

color fromXYZ(color c) {
  float r = map(getR(c),0,255,0,RANGE_X);
  float g = map(getG(c),0,255,0,RANGE_Y);
  float b = map(getB(c),0,255,0,RANGE_Z);
  
  PVector v = _fromXYZ(new PVector(r,g,b));
  v.mult(255.0);
  
  return blendRGB(c,(int)v.x,(int)v.y,(int)v.z);
}

color toCMY(color c) {
  return blendRGB(c, 255-getR(c), 255-getG(c), 255-getB(c));
}

color fromCMY(color c) {
  return toCMY(c);
}

color fromOHTA(color c) {
  int I1 = getR(c);
  float I2 = map(getG(c),0,255,-127.5,127.5);
  float I3 = map(getB(c),0,255,-127.5,127.5);
  
  int R = (int)(I1+1.00000*I2-0.66668*I3);
  int G = (int)(I1+1.33333*I3);
  int B = (int)(I1-1.00000*I2-0.66668*I3);
  
  return blendRGB(c,R,G,B);
}

color toOHTA(color c) {
  int R = getR(c);
  int G = getG(c);
  int B = getB(c);
 
  int I1 = (int)(0.33333*R+0.33334*G+0.33333*B);
  int I2 = (int)map(0.50000*R-0.50000*B,-127.5,127.5,0,255);
  int I3 = (int)map(-0.25000*R+0.50000*G-0.25000*B,-127.5,127.5,0,255);
    
  return blendRGB(c,I1,I2,I3);  
}
