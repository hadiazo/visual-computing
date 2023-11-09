
// Array of fish images
PImage[] fishImages = new PImage[3];
PImage[] flippedFishImages = new PImage[3];
PImage[] sharkImages = new PImage[1];
PImage[] flippedSharkImages = new PImage[1];

PImage vegetation;
// Empty array of fish
ArrayList<Fish> fish = new ArrayList<Fish>();
ArrayList<Fish> fertileFish = new ArrayList<Fish>();
ArrayList<FoodSource> foodSources = new ArrayList<FoodSource>();
ArrayList<Shark> sharks = new ArrayList<Shark>();
ArrayList<Shark> fertileSharks = new ArrayList<Shark>();

// Constants
int Y_AXIS = 1;
int X_AXIS = 2;
color b1, b2, c1, c2;

void setup(){
    size(1920, 1040);
    // cyan background color
    background(0, 55, 155);
    noStroke();
    frameRate(30);
    imageMode(CENTER);
    loadFishImages();
    // Load vegetation images
    vegetation = loadImage("vegetation1.png");
    // Create 2 new  random food source at the botoom of the screen with yellow color
    new FoodSource(width/2 - random(0,width/2) , height/2, 100, color(100, 255, 55));
    new FoodSource(width/2 + random(0,width/2) , height/2, 100, color(100, 255, 55));
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
                // reduce the force if the fish is close to the food source
                force.mult(0.1);
                // also reduce current aceeleration and velocity
                f.velocity.mult(0.5);
                f.acceleration.mult(0.1);
                if (f.eatFood()){
                    fs.reduceFood();
                }
            }
            f.applyForce(force);
        }

        // Calculate the attraction of fertile fish
        for(int j = 0; j < fertileFish.size(); j++){
            Fish ff = fertileFish.get(j);
            if (ff != f){
                f.calculateAttraction(ff);
            // If in range and fertile, reduce the libido current acceleration and velocity
            PVector inRange = PVector.sub(ff.position, f.position);
            if (inRange.mag() < (ff.size)){
                f.velocity.mult(0.95);
                f.acceleration.mult(0.95);
                // If the fish is fertile and in range, mate
                if (f.isFertile && ff.isFertile && (inRange.mag() < ff.size * 0.5)){
                    f.velocity.mult(0.1);
                    f.acceleration.mult(0.5);
                    // Create a new fish at the position of the current fish with a random image of the parents
                    // random between 2 parents
                    // If the fish index is the same create 2 new fish
                    if (f.fishIndex == ff.fishIndex){
                        new Fish(f.position.x, f.position.y, new PVector(0, 0), new PVector(-0.1, 0.5), 4, 25, f.fishIndex);
                        new Fish(f.position.x, f.position.y, new PVector(0, 0), new PVector(0.1, 0.5), 4, 25, ff.fishIndex);
                    } else {
                        int fishIndex = int(random(f.fishIndex, ff.fishIndex));
                    new Fish(f.position.x, f.position.y, new PVector(0, 0), new PVector(0.0, 0.5), 4, 25, fishIndex);
                    }
                    // Reduce the size of the fish
                    f.size -= 25;
                    ff.size -= 25;
                    // Reduce the libido of the fish
                    f.libido -= 100;
                    ff.libido -= 100;
                    // Increase the hunger of the fish
                    f.hunger += 20;
                    ff.hunger += 20;
                    // Remove the fish from the array of fertile fish
                    fertileFish.remove(f);
                    fertileFish.remove(ff);
                }
            }
            }
        }

        // Calculate the repulsion of sharks
        for (int j = 0; j < sharks.size(); j++){

            Shark s = sharks.get(j);
            PVector repulsion = s.calculateRepulsion(f).mult(100);
            f.applyForce(repulsion);

            // If in range eat the fish reduce hunger and increase size
            PVector inRange = PVector.sub(s.position, f.position);
            if (inRange.mag() < s.size){
                // probabilitic chance of eating the fish based in hunger and size
                if (random(0, 100) < (s.hunger * f.size * 0.01)){
                    // eat the fish
                    f.life = 0;
                    // remove the fish from the array of fish
                    fish.remove(f);
                    s.eatFood(f);
                }
            }

            PVector force = f.calculateAttraction(s).mult(0.001);
            s.applyForce(force);
        }

        f.update();
        f.display();
    }

    // Update and display all sharks
    for(int i = 0; i < sharks.size(); i++){
        Shark s = sharks.get(i);

        s.update();
        s.display();
    }

    // Calculate the attraction of fertile sharks
    for(int i = 0; i < fertileSharks.size(); i++){
        Shark fs = fertileSharks.get(i);
        for(int j = 0; j < fertileSharks.size(); j++){
            Shark ff = fertileSharks.get(j);
            if (ff != fs){
                fs.calculateAttraction(ff);
                // If in range and fertile, reduce the libido current acceleration and velocity
                PVector inRange = PVector.sub(ff.position, fs.position);
                if (inRange.mag() < (ff.size)){
                    fs.velocity.mult(0.95);
                    fs.acceleration.mult(0.95);
                    // If the shark is fertile and in range, mate
                    if (fs.isFertile && ff.isFertile && (inRange.mag() < ff.size * 0.5)){
                        fs.velocity.mult(0.1);
                        fs.acceleration.mult(0.5);
                        // Create a new shark at the position of the current shark with a random image of the parents
                        new Shark(fs.position.x, fs.position.y, new PVector(0, 0), new PVector(0.0, 0.5), 3, 25, 0);

                        // Reduce the size of the shark
                        fs.size -= 25;
                        ff.size -= 25;
                        // Reduce the libido of the shark
                        fs.libido -= 100;
                        ff.libido -= 100;
                        // Increase the hunger of the shark
                        fs.hunger += 20;
                        ff.hunger += 20;
                        // Remove the shark from the array of fertile sharks
                        fertileSharks.remove(fs);
                        fertileSharks.remove(ff);
                    }
                }
            }
        }
    }

    // If fish array is empty, display a message function
    checkFish();
    // If sharks array is empty, display a message function
    checkSharks();
}

void loadFishImages(){
    fishImages[0] = loadImage("fish1.png");
    fishImages[1] = loadImage("fish2.png");
    fishImages[2] = loadImage("fish3.png");
    // Load Shark1
    sharkImages[0] = loadImage("shark1.png");

    // Flip the fish images horizontally
    flippedFishImages[0] = loadImage("fish1flipped.png");
    flippedFishImages[1] = loadImage("fish2flipped.png");
    flippedFishImages[2] = loadImage("fish3flipped.png");
    flippedSharkImages[0] = loadImage("shark1flipped.png");
}

void mousePressed(){
    // Create a new fish at the mouse position with a random image
    if (mouseButton == LEFT){
    int fishIndex = int(random(0, 3));
    new Fish(mouseX, mouseY, new PVector(0, 0), new PVector(0.1, 0), 4, 25, fishIndex);
    }
    // Create a new shark at the mouse position with a random image
    if (mouseButton == RIGHT){
    new Shark(mouseX, mouseY, new PVector(0, 0), new PVector(0.1, 0), 3, 25, 0);
    }
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
        textSize(44);
        textAlign(CENTER);
        // there are no fish, click to add a new fish in new line "LEFT click to add"
        text("There are no fish \n LEFT click to add" , width/4, height/2);
    }
}
void checkSharks(){
    if (sharks.size() == 0){
        fill(255);
        textSize(44);
        textAlign(CENTER);
        // there are no fish, click to add a new fish in new line "LEFT click to add"
        text("There are no sharks \n RIGHT click to add" , width*3/4, height/2);
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
    float hunger = 0;
    float libido = 0;
    float fear = 100;
    float imageRatio = 1;
    int fishIndex;
    boolean isAlive = true;
    boolean isFertile = false;

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
        // image ratio
        imageRatio = fishImage.width / fishImage.height;

        // Add the fish to the array of fish
        fish.add(this);

    }
  // Draw the fish
    void display(){
        // Draw the fish
        // If fertile, tint slightly red
        if (isFertile){
            tint(255, map(sin(millis() * 0.001), -1, 1, 155, 225), map(sin(millis() * 0.001), -1, 1, 155, 225));
        }
        else {
            tint(255, map(sin(millis() * 0.001), -1, 1, 155, 225));

        }
        image(fishImage, position.x, position.y, size*imageRatio, size);
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

    void senseFear(PVector dir){
        // if the shark direction is the opposite as the fish direction in both axis, increase the fear
        if (dir.x < 0 && velocity.x > 0 && dir.y < 0 && velocity.y > 0){
            fear += 1;
        }
        else if (dir.x < 0 && velocity.x > 0 && dir.y > 0 && velocity.y < 0){
            fear += 1;
        }
        else if (dir.x > 0 && velocity.x < 0 && dir.y < 0 && velocity.y > 0){
            fear += 1;
        }
        else if (dir.x > 0 && velocity.x < 0 && dir.y > 0 && velocity.y < 0){
            fear += 1;
        }
        else {
            fear -= 1;
        }
        // clamp the fear to 0 and 100
        fear = constrain(fear, 0, 100);
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
            // Debug hunger and life:
            if (hunger < 100){
                hunger += 1;
            }
            if (hunger > 80){
                life -= 2;
            }
            else if (hunger > 20){
                life -= 1;
            }
            if (life > 80){
                maxSpeed += 0.01;
            }
            else{
                maxSpeed -= 0.01;
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
            // Debug size, libido, hunger and life
            if (hunger < 80) {
                size += 1;
            } else if (hunger < 20){
                size += 2;
                // Increase the libido
                libido += 2;
            } else {
                size -= 1;
                // Decrease the libido
                libido -= 1;
            }
            if (libido < 0){
                libido = 0;
            }
            if (size > 100){
                size = 100;
            } else if (size > 75){
                // is fertile add to the array of fertile fish
                if (!fertileFish.contains(this)){
                    fertileFish.add(this);
                }
                isFertile = true;
            }
            else if (size < 25){
                size = 25;
            }
            else {
                // remove from the array of fertile fish
                if (fertileFish.contains(this)){
                    fertileFish.remove(this);
                }
                isFertile = false;
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

    // calculate the attraction of fertile fish
    void calculateAttraction(Fish f){
        PVector force = PVector.sub(f.position, position);

        float distance = force.mag();
        distance = constrain(distance, 25, 100);

        float strength = (f.libido * libido) / (distance * distance);

        force.normalize();
        force.mult(strength);
        applyForce(force);
    }

    // Calculate Force to attract a shark based on size
    PVector calculateAttraction(Shark s){
        PVector force = PVector.sub(position, s.position);

        float distance = force.mag();
        distance = constrain(distance, 25, 100);

        float strength = ((s.size * size * s.hunger * s.hunger) - 1000) / (distance * distance);

        force.normalize();
        force.mult(strength);
        return force;
    }
    
}

class Shark{
    // Define properties of the fish such as Hunger, Libido, Fear, etc.
    PVector position;
    PVector velocity = new PVector(1, 0);
    PVector acceleration = new PVector(1, 0);
    PImage sharkImage;
    float maxSpeed = 10;
    float size =25;
    float life = 100;
    float hunger = 0;
    float libido = 0;
    float imageRatio = 1;
    int sharkIndex;
    boolean isAlive = true;
    boolean isFertile = false;

    float nextBehaviourChange;
    float nextLifeReduction;
    float nextGrowth;
    float nextBite;
    // Constructor
    Shark(float x, float y, PVector velocity, PVector acceleration, float maxSpeed, float size, int sharkIndex ){
        position = new PVector(x, y);
        this.velocity = velocity;
        this.acceleration = acceleration;
        this.maxSpeed = maxSpeed;
        this.size = size;
        this.sharkIndex = sharkIndex;
        sharkImage = sharkImages[sharkIndex];
        
        // image ratio
        imageRatio = sharkImage.width / sharkImage.height;
        // Add the shark to the array of sharks
        sharks.add(this);
    }
    // Draw the shark
    void display(){
        // Draw the shark
        // If fertile, tint slightly red
        if (isFertile){
            tint(255, map(sin(millis() * 0.001), -1, 1, 155, 225), map(sin(millis() * 0.001), -1, 1, 155, 225));
        }
        else {
            tint(255, map(sin(millis() * 0.001), -1, 1, 155, 225));

        }
        image(sharkImage, position.x, position.y, size * imageRatio, size);
    }
    // Update the shark
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
        // Check if the shark is off the screen and if so, change set the velocity to 0 and change acceleration (invert the direction)
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
        // Check if the shark is facing the right direction and if not, change the direction
        if (velocity.x > 0){
            sharkImage = sharkImages[sharkIndex];
        }
        if (velocity.x < 0){
            sharkImage = flippedSharkImages[sharkIndex];
        }
    }
    void changeBehaviour(){
        // Change the behaviour of the shark based on the properties every 3 seconds
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
                acceleration.y += random(-0.02, 0.01);
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
                velocity.y += random(-0.2, 0.1);
            }
            // Change the next behaviour change time a random amount between 0.5 and 3 seconds
            nextBehaviourChange = millis() + random(500, 3000);
        }
    }
    // function to reduce the life of the shark every second
    void reduceLife(){
        if (millis() > nextLifeReduction){
            // Debug hunger and life:
            if (hunger < 100){
                hunger += 1;
            }
            if (hunger > 80){
                life -= 2;
            }
            else if (hunger > 20){
                life -= 1;
            }
            if (life > 80){
                maxSpeed += 0.01;
            }
            else{
                maxSpeed -= 0.01;
            }
            if (life <= 0){
                isAlive = false;
            }
            nextLifeReduction = millis() + 1000;
        }
        // Remove the shark from the array of sharks if it is dead
        if (!isAlive){
            sharks.remove(this);
        }
    }
    void grow(){
        if (millis() > nextGrowth){
            // Debug size, libido, hunger and life
            if (hunger < 80) {
                size += 1;
            } else if (hunger < 20){
                size += 2;
                // Increase the libido
                libido += 2;
                maxSpeed -= 0.1;
            } else {
                size -= 1;
                // Decrease the libido
                libido -= 1;
                maxSpeed += 0.1;
            }
            if (libido < 0){
                libido = 0;
            }
            if (size > 100){
                size = 100;
            } else if (size > 75){
                // is fertile add to the array of fertile sharks
                if (!fertileSharks.contains(this)){
                    fertileSharks.add(this);
                }
                isFertile = true;
            }
            else if (size < 25){
                size = 25;
            }
            else {
                // remove from the array of fertile fish
                if (fertileSharks.contains(this)){
                    fertileSharks.remove(this);
                }
                isFertile = false;
            }

            // add chance to spawn a new food source if the shark is fertile and hunger is low
            if (isFertile && hunger < 20){
                if (random(0, 100) < 10){
                    // reduce the speed of the shark
                    velocity.mult(0.5);
                    // and acceleration
                    acceleration.mult(0.5);
                    // random foodamount based 10 and size
                    float foodAmount = random(10, size);
                    // Reduce Size based on the food amount
                    size -= foodAmount * 0.2;
                    new FoodSource(position.x, position.y, foodAmount, color(100, 255, 55));
                }
            }
            nextGrowth = millis() + 1000;
        }
    }

    // calculate the attraction of fertile fish
    void calculateAttraction(Shark s){
        PVector force = PVector.sub(s.position, position);

        float distance = force.mag();
        distance = constrain(distance, 25, 100);

        float strength = (s.libido * libido) / (distance * distance);

        force.normalize();
        force.mult(strength);
        applyForce(force);
    }
    void applyForce(PVector force){
        PVector f = force.copy();
        // Constraint the force to 1
        f.limit(1);
        acceleration.add(f);
    }

    boolean eatFood(Fish f){
        // Wait 1 second before eating again
        if (millis() > nextBite && hunger > 0){
            hunger -= 10 * f.size;
            if (hunger < 0){
                hunger = 0;
            }
            nextBite = millis() + 2000;
            return true;
        }
        else {
            return false;
        }

    }

    // Calculate repulsion from fish
    PVector calculateRepulsion(Fish f){
        PVector force = PVector.sub(position, f.position);

        float distance = force.mag();
        distance = constrain(distance, 10, 250);
        // Velocity / distance
        PVector dir = velocity.copy();
        dir.normalize();
        if (distance < 250){
            f.senseFear(dir);
            float strength = (f.size * size * hunger * f.fear) / (distance * distance * distance * (f.hunger * f.hunger + 1));
            force.normalize();
            force.mult(-strength);

        } else {
            f.fear -= 1;
            // Clamp the fear to 0 and 100
            f.fear = constrain(f.fear, 0, 100);
            force.mult(0);
        }

        return force;
    }
}

class FoodSource{
    PVector position;
    PVector velocity = new PVector(1, 1);
    float freshness = 100;
    float foodAmount = 100;
    float nextFreshnessReduction;
    color foodColor = color(255, 0, 0);
    boolean isAlive = true;

    FoodSource(float x, float y, float f,color c){
        position = new PVector(x, y);
        foodAmount = f;
        foodColor = c;
        foodSources.add(this);
    }

    void display(){
        // Debug freshness
        color newFoodColor = color((freshness), 55 + (freshness * 2), 55);
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
        velocity.x += random(-0.02, 0.02);
        velocity.y += random(-0.05, 0.04);
    }

    void checkEdges(){
        // check edges and invert velocity
        if(position.x > width || position.x < 0){
            velocity.x *= -1;
        }
        if(position.y > height || position.y < 0){
            velocity.y *= -0.5;
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
