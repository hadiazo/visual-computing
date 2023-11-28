// WebGL context and camera
let graphicsContext, observer;

// Function to compare distances for sorting
let compareDistance;

// Array to store geometric shapes
let geometricShapes = [];

// Flag to enable or disable the Z-buffer
let zBufferEnabled = true;

// Class representing a triangular face of a pyramid
class TriangularFace {
  constructor(v1, v2, v3) {
    this.v1 = v1; // Vertex 1
    this.v2 = v2; // Vertex 2
    this.v3 = v3; // Vertex 3
    // Assign a random color to the face
    this.color = color(random(255), random(255), random(255));
  }

  // Render function to draw the triangular face
  render() {
    fill(this.color); // Set the color
    beginShape();
    // Define the vertices of the triangle
    vertex(this.v1.x, this.v1.y, this.v1.z);
    vertex(this.v2.x, this.v2.y, this.v2.z);
    vertex(this.v3.x, this.v3.y, this.v3.z);
    endShape(CLOSE); // Close the shape
  }
}

// Setup function: initializes the canvas, camera, and pyramids
function initialize() {
  createCanvas(640, 480, WEBGL); // Create a WebGL canvas
  observer = createCamera(); // Create a camera

  graphicsContext = this._renderer.GL; // Get the WebGL context

  // Generate pyramids at different positions
  for (let i = -2; i < 2; i++) {
    for (let j = -2; j < 2; j++) {
      for (let k = -2; k < 2; k++) {
        constructPyramid(75 * i, 75 * j, 75 * k);
      }
    }
  }

  // Comparator for sorting shapes based on distance to camera
  compareDistance = (a, b) => {
    // Calculate distance of each shape from the camera
    const distA = dist(a.v1.x, a.v1.y, a.v1.z, observer.eyeX, observer.eyeY, observer.eyeZ);
    const distB = dist(b.v1.x, b.v1.y, b.v1.z, observer.eyeX, observer.eyeY, observer.eyeZ);
    return distB - distA; // Sort in descending order
  };

  noStroke(); // Disable drawing outlines
}

// Function to create a pyramid at a given position
function constructPyramid(x, y, z) {
  // Create vertices for the pyramid
  let vertex1 = createVector(x + random(75), y + random(75), z);
  let vertex2 = createVector(x + 10 + random(75), y + 10 + random(75), z);
  let vertex3 = createVector(x + random(75), y + 10 + random(75), z);
  let vertex4 = createVector(x + random(75), y + random(75), z + 1 + random(75));

  // Create faces for the pyramid and add them to the shapes array
  let face1 = new TriangularFace(vertex1, vertex2, vertex3);
  let face2 = new TriangularFace(vertex1, vertex2, vertex4);
  let face3 = new TriangularFace(vertex1, vertex3, vertex4);
  let face4 = new TriangularFace(vertex2, vertex4, vertex3);
  geometricShapes.push(face1, face2, face3, face4);
}

// Draw function: renders the scene
function renderLoop() {
  background(0); // Set the background color
  orbitControl(); // Enable orbit controls for the camera

  // Sort shapes based on their distance to the camera
  geometricShapes.sort(compareDistance);

  // Render each shape
  geometricShapes.forEach(shape => shape.render());
}

// Function to toggle the Z-buffer when the spacebar is pressed
function toggleZBuffer() {
  if (key === ' ') {
    zBufferEnabled = !zBufferEnabled;
    if (zBufferEnabled) {
      graphicsContext.enable(graphicsContext.DEPTH_TEST); // Enable Z-buffer
    } else {
      graphicsContext.disable(graphicsContext.DEPTH_TEST); // Disable Z-buffer
    }
  }
}
