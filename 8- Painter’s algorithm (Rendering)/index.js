let webGLContext, mainCamera, distanceComparator, pyramidFaces = [], isZBufferEnabled = true;

function setup() {
  createCanvas(640, 480, WEBGL); // Set up a canvas with 3D rendering
  mainCamera = createCamera();   // Create a camera for viewing the scene
  
  webGLContext = this._renderer.GL; // Get WebGL context for low-level operations

  // Create pyramids at different positions
  for (let i = -2; i < 2; i++) {
    for (let j = -2; j < 2; j++) {
      for (let k = -2; k < 2; k++) {
        createPyramid(75 * i, 75 * j, 75 * k);
      }
    }
  }
  
  // Comparator function to sort pyramid faces based on distance to camera
  distanceComparator = (faceA, faceB) => {
    // Calculate the distance from each face to the camera's position
    const distA = dist(faceA.p1.x, faceA.p1.y, faceA.p1.z, mainCamera.eyeX, mainCamera.eyeY, mainCamera.eyeZ);
    const distB = dist(faceB.p1.x, faceB.p1.y, faceB.p1.z, mainCamera.eyeX, mainCamera.eyeY, mainCamera.eyeZ);
    
    // Faces closer to the camera come first
    return distB - distA;
  };

  noStroke();
}

function draw() {
  background(0); // Clear the background
  orbitControl(); // Enable orbiting around the scene with mouse
  
  pyramidFaces.sort(distanceComparator); // Sort faces by distance to camera
  pyramidFaces.forEach(face => face.show()); // Display each face
}

function keyPressed() {
  // Toggle depth testing (Z-buffer) when spacebar is pressed
  if (key === ' '){
    isZBufferEnabled = !isZBufferEnabled;
    if (isZBufferEnabled) {
      webGLContext.enable(webGLContext.DEPTH_TEST);
    } else {
      webGLContext.disable(webGLContext.DEPTH_TEST);
    }
  }
}

function createPyramid(x, y, z) {
  // Create pyramid vertices
  let v1 = createVector(x + random(75), y + random(75), z);
  let v2 = createVector(x + 10 + random(75), y + 10 + random(75), z);
  let v3 = createVector(x + random(75), y + 10 + random(75), z);
  let v4 = createVector(x + random(75), y + random(75), z + 1 + random(75));

  // Create faces of the pyramid
  let face1 = new PyramidFace(v1, v2, v3);
  let face2 = new PyramidFace(v1, v2, v4);
  let face3 = new PyramidFace(v1, v3, v4);
  let face4 = new PyramidFace(v2, v4, v3);

  pyramidFaces.push(face1, face2, face3, face4); // Add faces to the list
}

class PyramidFace {
  constructor(vertex1, vertex2, vertex3) {
    this.p1 = vertex1; // First vertex of the face
    this.p2 = vertex2; // Second vertex of the face
    this.p3 = vertex3; // Third vertex of the face
    this.col = color(random(0), random(255), random(255/2)); // Random color for the face
  }
  
  show() {
    // Draw the face
    fill(this.col);
    beginShape();
    vertex(this.p1.x, this.p1.y, this.p1.z);
    vertex(this.p2.x, this.p2.y, this.p2.z);
    vertex(this.p3.x, this.p3.y, this.p3.z);
    endShape(CLOSE);
  }
}
