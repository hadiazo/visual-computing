
// Array of fish images
PImage[] fishImages = new PImage[3];
PImage[] flippedFishImages = new PImage[3];
PImage vegetation;
// Empty array of fish
ArrayList<Fish> fish = new ArrayList<Fish>();
ArrayList<FoodSource> foodSources = new ArrayList<FoodSource>();

// Constants
int Y_AXIS = 1;
int X_AXIS = 2;
color b1, b2, c1, c2;

void setup(){
    size(800, 600);
    // cyan background color
    background(0, 55, 155);
    noStroke();
    frameRate(30);
    imageMode(CENTER);
    loadFishImages();
    // Load vegetation images
    vegetation = loadImage("vegetation1.png");
    // Create a new food source at the center of the screen with yellow color
    new FoodSource(width/2, height/2, color(255, 255, 0));
}

void draw(){
    // Animate the background color
    tidalWave();
    // Draw the vegetation background at the bottom of the screen
    // animate the vegetation tint
    tint(255, map(sin(millis() * 0.001), -1, 1, 55, 155));
    image(vegetation, width/2, height - 100, width, 205);
    // set the tint back to white
    tint(255, 255);

    fill(255);
    ellipse(mouseX, mouseY, 20, 20);

    // Update and display all food sources
    for(int i = 0; i < foodSources.size(); i++){
        FoodSource fs = foodSources.get(i);
        fs.update();
        fs.display();
    }

    // Update and display all fish
    for(int i = 0; i < fish.size(); i++){
        Fish f = fish.get(i);
        // Calculate the force on the fish from all food sources
        for(int j = 0; j < foodSources.size(); j++){
            FoodSource fs = foodSources.get(j);
            PVector force = fs.calculateForce(f).mult(0.001);
            PVector inRange = PVector.sub(fs.position, f.position);
            //Debug
            //println("Distance: " + inRange.mag() + "Hunger: " + f.hunger + "Food Amount: " + fs.foodAmount);
            if (inRange.mag() < f.hunger){
                if (f.eatFood()){
                    fs.reduceFood();
                }
            }
            f.applyForce(force);
        }

        f.update();
        f.display();
    }

    

    // If fish array is empty, display a message function
    checkFish();
    
}

void loadFishImages(){
    fishImages[0] = loadImage("fish1.png");
    fishImages[1] = loadImage("fish2.png");
    fishImages[2] = loadImage("fish3.png");

    // Flip the fish images horizontally
    flippedFishImages[0] = loadImage("fish1flipped.png");
    flippedFishImages[1] = loadImage("fish2flipped.png");
    flippedFishImages[2] = loadImage("fish3flipped.png");
}

void mousePressed(){
    // Create a new fish at the mouse position with a random image
    int fishIndex = int(random(0, 3));
    new Fish(mouseX, mouseY, new PVector(0, 0), new PVector(0.1, 0), 1, 25, fishIndex);
}

void tidalWave(){
    // Animate the gradient background color
    float r = map(sin(millis() * 0.001), -1, 1, 0, 15);
    float g = map(sin(millis() * 0.0001), -1, 1, 55, 80);
    float b = map(sin(millis() * 0.0003), -1, 1, 105, 155);
    setGradient(0, 0, width, height, color(r, g, b), color(r, g -25, b-25), 1);
}

void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

  noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  }  
  else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}

void checkFish(){
    if (fish.size() == 0){
        fill(255);
        textSize(32);
        textAlign(CENTER);
        // there are no fish, click to add a new fish
        text("There are no fish, click to add a new fish", width/2, height/2);
    }
}

class Fish{
    // Define properties of the fish such as Hunger, Libido, Fear, etc.
    PVector position;
    PVector velocity = new PVector(1, 0);
    PVector acceleration = new PVector(1, 0);
    PImage fishImage;
    float maxSpeed = 10;
    float size =25;
    float life = 100;
    float hunger = 100;
    float libido = 100;
    float fear = 100;
    int fishIndex;
    boolean isAlive = true;

    float nextBehaviourChange;
    float nextLifeReduction;
    float nextGrowth;
    float nextBite;
    // Constructor
    Fish(float x, float y, PVector velocity, PVector acceleration, float maxSpeed, float size, int fishIndex ){
        position = new PVector(x, y);
        this.velocity = velocity;
        this.acceleration = acceleration;
        this.maxSpeed = maxSpeed;
        this.size = size;
        this.fishIndex = fishIndex;
        fishImage = fishImages[fishIndex];



        // Add the fish to the array of fish
        fish.add(this);

    }
  // Draw the fish
    void display(){
        // Draw the fish
        tint(255, map(sin(millis() * 0.001), -1, 1, 155, 225));
        image(fishImage, position.x, position.y, size, size);
    }

    void update(){

        // Update the position in x and y based on the velocity
        position.x += velocity.x;
        position.y += velocity.y;
        // Update the velocity based on the acceleration
        velocity.x += acceleration.x;
        velocity.y += acceleration.y;
        
        // clamp the velocity magnitude to the max speed
        velocity.limit(maxSpeed);

        checkEdges();
        checkDirection();
        changeBehaviour();
        grow();
        reduceLife();
    }

    void checkEdges(){
        // Check if the fish is off the screen and if so, change set the velocity to 0 and change acceleration (invert the direction)
        if(position.x > width || position.x < 0){
            velocity.x = 0;
            acceleration.x *= -0.5;
            nextBehaviourChange = 0;
        }
        if(position.y > height || position.y < 0){
            velocity.y = 0;
            acceleration.y *= -0.5;
            nextBehaviourChange = 0;
        }
        if (position.x > width){
            position.x = width;
        }
        if (position.x < 0){
            position.x = 0;
        }
        if (position.y > height){
            position.y = height;
        }
        if (position.y < 0){
            position.y = 0;
        }
    }

    void checkDirection(){
        // Check if the fish is facing the right direction and if not, change the direction
        if (velocity.x > 0){
            fishImage = fishImages[fishIndex];
        }
        if (velocity.x < 0){
            fishImage = flippedFishImages[fishIndex];
        }
    }

    void changeBehaviour(){
        // Change the behaviour of the fish based on the properties every 3 seconds
        if (millis() > nextBehaviourChange){
            // Change the acceleration additively, if the value is high tend to give random values closer to 0
            if (acceleration.x > 0.1){
                acceleration.x += random(-0.2, 0.01);
            }
            else if (acceleration.x < -0.1){
                acceleration.x += random(-0.01, 0.2);
            }
            else {
                acceleration.x += random(-0.05, 0.05);
            }
            // Y acceleration
            if (acceleration.y > 0.1){
                acceleration.y += random(-0.2, 0.01);
            }
            else if (acceleration.y < -0.1){
                acceleration.y += random(-0.01, 0.2);
            }
            else {
                acceleration.y += random(-0.01, 0.02);
            }

            // Change the velocity aditively
            if (velocity.x > 0.1){
                velocity.x += random(-0.2, 0.01);
            }
            else if (velocity.x < -0.1){
                velocity.x += random(-0.01, 0.2);
            }
            else {
                velocity.x += random(-0.05, 0.05);
            }
            // Y velocity
            if (velocity.y > 0.1){
                velocity.y += random(-0.2, 0.01);
            }
            else if (velocity.y < -0.1){
                velocity.y += random(-0.01, 0.2);
            }
            else {
                velocity.y += random(-0.05, 0.1);
            }
            
            // Change the next behaviour change time a random amount between 0.5 and 3 seconds
            nextBehaviourChange = millis() + random(500, 3000);
        }
    }
    // function to reduce the life of the fish every second
    void reduceLife(){
        if (millis() > nextLifeReduction){
            if (hunger < 100){
                hunger += 1;
            }
            if (hunger > 80){
                life -= 2;
            }
            else if (hunger > 20){
                life -= 1;
            }
            
            if (life < 0){
                isAlive = false;
            }
            nextLifeReduction = millis() + 1000;
        }
        // Remove the fish from the array of fish if it is dead
        if (!isAlive){
            fish.remove(this);
        }
    }

    void grow(){
        if (millis() > nextGrowth){
            if (hunger < 80) {
                size += 1;
            } else if (hunger < 20){
                size += 2;
            } else {
                size -= 1;
            }
            if (size > 100){
                size = 100;
            } else if (size > 75){
                // is fertile
                println("Fertile");
            }
            else if (size < 25){
                size = 25;
            }
            nextGrowth = millis() + 1000;
        }
    }

    boolean eatFood(){
        // Wait 1 second before eating again
        if (millis() > nextBite && hunger > 0){
            hunger -= 10;
            if (hunger < 0){
                hunger = 0;
            }
            nextBite = millis() + 1000;
            return true;
        }
        else {
            return false;
        }

    }

    void applyForce(PVector force){
        PVector f = force.copy();
        // Constraint the force to 1
        f.limit(1);
        f.div(hunger+1);
        acceleration.add(f);
    }
}

class FoodSource{
    PVector position;
    PVector velocity = new PVector(1, 0);
    float freshness = 100;
    float foodAmount = 100;
    float nextFreshnessReduction;
    color foodColor = color(255, 0, 0);
    boolean isAlive = true;

    FoodSource(float x, float y, color c){
        position = new PVector(x, y);
        foodColor = c;
        foodSources.add(this);
    }

    void display(){
        // Debug freshness
        color newFoodColor = color(55 + (freshness * 2), 55 + (freshness), 0);
        fill(newFoodColor);
        ellipse(position.x, position.y, foodAmount * 0.5, foodAmount * 0.5);
    }

    void update(){
        move();
        checkEdges();
        reduceFreshness();
    }

    void move(){
        // Update the position in x and y based on the velocity
        position.x += velocity.x;
        position.y += velocity.y;
        // Update the velocity based on random acceleration
        velocity.x += random(-0.1, 0.1);
        velocity.y += random(-0.1, 0.1);
    }

    void checkEdges(){
        // check edges and invert velocity
        if(position.x > width || position.x < 0){
            velocity.x *= -1;
        }
        if(position.y > height || position.y < 0){
            velocity.y *= -1;
        }
        if (position.x > width){
            position.x = width;
        }
        if (position.x < 0){
            position.x = 0;
        }
    }

    void reduceFood(){
        if (foodAmount > 0){
            foodAmount -= 1;
            if (foodAmount <= 0){
                isAlive = false;
            }
        }
        if (!isAlive){
            foodSources.remove(this);
        }
    }

    void reduceFreshness(){
        if (millis() > nextFreshnessReduction){
            nextFreshnessReduction = millis() + 1000;
            if (freshness > 0){
                freshness -= 1;
            }
            else {
                reduceFood();
            }
        }
    }

    PVector calculateForce(Fish f){
        PVector force = PVector.sub(position, f.position);

        float distance = force.mag();
        distance = constrain(distance, foodAmount * 0.5, 100 + foodAmount * 2);

        float strength = (foodAmount * freshness * f.hunger * f.hunger) / (distance * distance);

        force.normalize();
        force.mult(strength);
        return force;
    }
}
```
