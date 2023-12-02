class Button {
  private int x, y, w, h;
  private PFont font;
  private String label;
  private int fontSize;
  private int delay = 0, framesPassed = 0;
  
  public Button(int x, int y, int w, int h, String label, int fontSize, PFont font) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.font = font;
    this.fontSize = fontSize;
    this.label = label;
  }
  
  public void drawButton(){
    fill(255);
    stroke(0);
    rect(x, y, w, h);
    textFont(font, fontSize);
    noStroke();
    fill(0);
    text(label, x + 5, y + (h - fontSize) / 2 + (h / 2));
    
    if(framesPassed < delay) {
      framesPassed++;
    }
  }
  
  public void SetFrameDelay(int delay) {
    this.delay = delay;
  }
  
  public boolean isPressed() {    
    if(!mousePressed) {
      return false;
    }
    
    if(mouseX >= x && mouseX <= x + w) {
      if(mouseY >= y && mouseY <= y + (h)) {
        if(framesPassed == delay) {
          framesPassed = 0;
          return true;
        }
      }
    }
    
    return false;
  }
}
