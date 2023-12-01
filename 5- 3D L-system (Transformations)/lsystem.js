// Base pattern for the L-system (a simple string to start with)
let basePattern = "F";
// Current pattern that will evolve over time, starting with the base pattern
let currentPattern = basePattern;
// Length of each segment in the L-system's visual representation
let segmentLength = 100;
// Angle for rotation used in the L-system's rules
let rotationAngle;

// Configuration 1 for the L-system rules
// Each letter represents a command or a series of commands
// This config transforms 'F' into a more complex string
let patternConfig1 = {
  "F": "F+F-[F-F]-F+F"  // 'F' is replaced by this string in the pattern
};

// Configuration 2 for the L-system rules
// Here 'F' follows a different transformation rule
let patternConfig2 = {
  "F": "F[+F]F[-F]F"  // 'F' is replaced by this string in the pattern
};

// Configuration 3 for the L-system rules
// This config introduces more complexity to the transformation of 'F'
let patternConfig3 = {
  "F": "F[-F][+F][--F][---F]F"  // 'F' is replaced by this string in the pattern
};

// Configuration 4 for the L-system rules
// This is the most complex config, involving two symbols: 'F' and 'X'
// Both 'F' and 'X' have their specific transformation rules
let patternConfig4 = {
  "F": "FF+[+FF+F-XF]-[-FF-F+XF]",  // 'F' is replaced by this string in the pattern
  "X": "F[+X][-X]F"  // 'X' is replaced by this string in the pattern
};

let activeRules = patternConfig1;

function setup() {
  createCanvas(680, 480, WEBGL);
  background(0);
  rotationAngle = radians(25); 
  
  let config1Btn = createButton('1');
  config1Btn.mousePressed(() => switchConfig(1));
  
  let config2Btn = createButton('2');
  config2Btn.mousePressed(() => switchConfig(2));
  
  let config3Btn = createButton('3');
  config3Btn.mousePressed(() => switchConfig(3));

  let config4Btn = createButton('4 misc.');
  config4Btn.mousePressed(() => switchConfig(4));
  
  let clearButton = createButton('<-');
  clearButton.mousePressed(clearDrawing);
}

function switchConfig(confNumber){
  if(confNumber == 1){activeRules = patternConfig1; regeneratePattern();}
  else if(confNumber == 2){activeRules = patternConfig2; regeneratePattern();}
  else if(confNumber == 3){activeRules = patternConfig3; regeneratePattern();}
  else if(confNumber == 4){activeRules = patternConfig4; regeneratePattern();}
}

function regeneratePattern() {
  segmentLength *= 0.5;
  let newPattern = "";
  for (let i = 0; i < currentPattern.length; i++) {
    let currentChar = currentPattern.charAt(i);
    let ruleFound = false;
    for (let rule in activeRules) {
      if (currentChar == rule) {
        ruleFound = true;
        newPattern += activeRules[rule];
      }
    }
    if (!ruleFound) {
      newPattern += currentChar;
    }
  }
  currentPattern = newPattern;
}

function draw() {
  background(0);
  orbitControl();
  translate(0, height/2);
  strokeWeight(2);
  stroke(140, 180, 50);

  for (let i = 0; i < currentPattern.length; i++) {
    let currentChar = currentPattern.charAt(i);
    if (currentChar == "F") {
      line(0, -segmentLength, 0, 0, 0, 0);
      
      line(0, -segmentLength, -segmentLength/2, 0, 0, 0);
      line(0, -segmentLength, segmentLength/2, 0, 0, 0);
      
      line(-segmentLength/2, -segmentLength, 0, 0, 0, 0);
      line(segmentLength/2, -segmentLength, 0, 0, 0, 0);
      
      translate(0, -segmentLength, 0);
    } else if (currentChar == "+") {
      rotate(rotationAngle);
    } else if (currentChar == "-") {
      rotate(-rotationAngle);
    } else if (currentChar == "[") {
      push();
    } else if (currentChar == "]") {
      pop();
    } else if (currentChar == "X") {
      push();
      translate(0, -segmentLength);
      fill(255, 120, 225);
      noStroke();
      for (let j = 0; j < 6; j++) {
        ellipse(0, 0, 10, 60);
        rotate(PI / 4);
      }
      pop();
    }
  }
}

function clearDrawing(){
  background(0);
  currentPattern = basePattern;
  segmentLength = 100;
  draw();
}
