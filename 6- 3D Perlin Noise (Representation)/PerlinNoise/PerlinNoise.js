const globe = [];
let r;
const total = 25;
let angleX = 0;
let flying = 0;

function setup() {
  createCanvas(500, 500, WEBGL);
  fill(0, 50, 200, 128);
  strokeWeight(1);
  stroke(200);
  
  let yoff = flying;
  flying -= 0.1;

  for (let i = 0; i < total + 1; i++) {
    globe[i] = [];
    const lat = map(i, 0, total, 0, PI);
    let xoff = 0;
    for (let j = 0; j < total + 1; j++) {
      r = map(noise(xoff, yoff), 0, 1, 150, 400);
      const lon = map(j, 0, total, 0, TWO_PI);
      const x = r * sin(lat) * cos(lon);
      const y = r * sin(lat) * sin(lon);
      const z = r * cos(lat);
      globe[i][j] = createVector(x, y, z);
      xoff += 0.1;
    }
    yoff += 0.1;
  }
}

function draw() {
  background(51);
  rotateX(angleX);
  
  

  for (let i = 0; i < total; i++) {
    
    beginShape(TRIANGLE_STRIP);
    for (let j = 0; j < total + 1; j++) {
      const v1 = globe[i][j];
      vertex(v1.x, v1.y, v1.z);
      const v2 = globe[i + 1][j];
      vertex(v2.x, v2.y, v2.z);
      
    }
    
    endShape();
  }

  angleX += 0.005;
}
