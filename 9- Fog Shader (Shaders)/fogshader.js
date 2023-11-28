let fogFarSlider;
let fogNearValueLabel;
let fogFarValueLabel;
let customShader;
let texture;
let fogNearSlider;

// Preload the shader, and the texture.
function preload() {
  texture = loadImage("https://cdn.pixabay.com/photo/2016/06/02/02/33/triangles-1430105_640.png");
}

// Setup the shader, create the geometry, load the texture, and initialize values.
function setup() {
  createCanvas(640, 480, WEBGL);
  customShader = createShader(vert, frag);
  shader(customShader);
  customShader.setUniform("tex0", texture);


  /**
   * Create sliders to control the fog parameters.
   */
  fogNearSlider = createSlider(0, 1, 0.7, 0.001);
  fogFarSlider = createSlider(0, 1, 0.9, 0.001);
  fogNearSlider.position(60, height + 17);
  fogFarSlider.position(60, height + 57);
  fogNearSlider.input(updateFogNear);
  fogFarSlider.input(updateFogFar);


  // fog near and far labels
  const fogNearText = createP('fogNear: ');
  fogNearText.position(0, height);
  fogNearValueLabel = createP(fogNearSlider.value());
  fogNearValueLabel.position(200, height);

  const fogFarText = createP('fogFar: ');
  fogFarText.position(0, height + 40);
  fogFarValueLabel = createP(fogFarSlider.value());
  fogFarValueLabel.position(200, height + 40);

  customShader.setUniform("tex0", texture);
  customShader.setUniform("fogNear", fogNearSlider.value());
  customShader.setUniform("fogFar", fogFarSlider.value());
  customShader.setUniform("fogColor", [0.7, 0.8, 0.9, 1]);

  /**
   * The camera is positioned such that the plane is centered in the canvas.
   */
  const camX = -width * 0.5 + 10;
  const camY = height * 0.5 - 240;
  const camZ = ((height / 2.0) / tan(PI * 30.0 / 180.0) - 30) * 0.65;

  // Move the camera away from the plane by half the height of the canvas to get a perspective view.
  camera(camX, camY, camZ);
}

function draw() {
  background(204, 230, 255);

  customShader.setUniform("fogNear", fogNearSlider.value());
  customShader.setUniform("fogFar", fogFarSlider.value());

  fogNearValueLabel.html(nf(fogNearSlider.value(), 1, 3));
  fogFarValueLabel.html(nf(fogFarSlider.value(), 1, 3));

  const cubes = 40;
  for (let i = 0; i <= cubes; ++i) {
    push();
    translate(i * 180 - (270), 0, 0);
    const angle = frameCount * 0.01 - i * 0.1;
    rotateY(-angle);
    rotateX(angle);  
    customShader.setUniform("tex0", texture);
    noStroke();
    box(100);
    pop();
  }
}

// Update the shader uniforms
function updateFogFar() {
  customShader.setUniform('fogFar', fogFarSlider.value());
}

function updateFogNear() {
  customShader.setUniform('fogNear', fogNearSlider.value());
}


// The shader code, #ifdef GL_ES is needed on WebGL 1.0 shaders.
const vert = `
#ifdef GL_ES
precision mediump float;
#endif

attribute vec3 aPosition;
attribute vec2 aTexCoord;
varying vec2 vTexCoord;
uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;

precision mediump float;
uniform sampler2D texture;
uniform float fogNear;
uniform float fogFar;
uniform vec3 fogColor;
varying float vFogDepth;

void main() {
  vTexCoord = aTexCoord;
  gl_Position = uProjectionMatrix * uModelViewMatrix * vec4(aPosition, 1.0);
  vFogDepth = (gl_Position.z / gl_Position.w);
}
`;

const frag = `
#ifdef GL_ES
precision mediump float;
#endif

uniform float fogNear;
uniform float fogFar;
uniform vec3 fogColor;
uniform sampler2D tex0;
varying vec2 vTexCoord;
varying float vFogDepth;

void main() {
  vec3 color = texture2D(tex0, vTexCoord).rgb;
  float fogFactor = smoothstep(fogNear, fogFar, vFogDepth);
  vec3 finalColor = mix(color, fogColor, fogFactor);

  gl_FragColor = vec4(finalColor, 1.0);
}
`;
