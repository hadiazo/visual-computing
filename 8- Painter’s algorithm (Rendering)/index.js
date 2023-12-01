let graphicsContext, observerCamera, depthComparator, geometricShapes = [], isZBufferEnabled = true;

function setup() {
  createCanvas(640, 480, WEBGL);
  observerCamera = createCamera();
  
  graphicsContext = this._renderer.GL;

  for (let i = -2; i < 2; i++) {
    for (let j = -2; j < 2; j++) {
      for (let k = -2; k < 2; k++) {
        generatePyramid(75*i, 75*j, 75*k);
      }
    }
  }
  
  depthComparator = (shapeA, shapeB) => {
    const distanceA = dist(shapeA.vertex1.x, shapeA.vertex1.y, shapeA.vertex1.z, observerCamera.eyeX, observerCamera.eyeY, observerCamera.eyeZ);
    const distanceB = dist(shapeB.vertex1.x, shapeB.vertex1.y, shapeB.vertex1.z, observerCamera.eyeX, observerCamera.eyeY, observerCamera.eyeZ);
  
    return distanceB - distanceA;
  };

  noStroke();
}

function draw() {
  background(0);
  orbitControl();
  
  geometricShapes.sort(depthComparator);
  geometricShapes.forEach(shape => shape.display());
}

function keyPressed() {
  if (key === ' '){
    isZBufferEnabled = !isZBufferEnabled;
    if (isZBufferEnabled) {
      graphicsContext.enable(graphicsContext.DEPTH_TEST);
    } else {
      graphicsContext.disable(graphicsContext.DEPTH_TEST);
    }
  }
}

function generatePyramid(x, y, z) {
  let vertex1 = createVector(x + random(75), y + random(75), z);
  let vertex2 = createVector(x + 10 + random(75), y + 10 + random(75), z);
  let vertex3 = createVector(x + random(75), y + 10 + random(75), z);
  let vertex4 = createVector(x + random(75), y + random(75), z + 1 + random(75));

  let face1 = new PyramidSide(vertex1, vertex2, vertex3);
  let face2 = new PyramidSide(vertex1, vertex2, vertex4);
  let face3 = new PyramidSide(vertex1, vertex3, vertex4);
  let face4 = new PyramidSide(vertex2, vertex4, vertex3);

  geometricShapes.push(face1, face2, face3, face4);
}

class PyramidSide {
  constructor(vertex1, vertex2, vertex3) {
    this.vertex1 = vertex1;
    this.vertex2 = vertex2;
    this.vertex3 = vertex3;
    this.color = color(random(255/2), random(255), random((255/3) + 255/2))
  }
  
  display() {
    fill(this.color);
    beginShape();
    vertex(this.vertex1.x, this.vertex1.y, this.vertex1.z);
    vertex(this.vertex2.x, this.vertex2.y, this.vertex2.z);
    vertex(this.vertex3.x, this.vertex3.y, this.vertex3.z);
    endShape(CLOSE);
  }
}
