int sizeCell = 8;
int cols = 600/sizeCell;
int rows = 600/sizeCell;
int [][] board = new int[cols][rows];
Button resButton;
Button clrButton;

void setup() {
  size(600,650);
  frameRate(24);
  PFont font = createFont("Arial", 16, true);
  resButton = new Button(200, 610, 100, 30, "Reset", 20, font);
  clrButton = new Button(400, 610, 100, 30, "Clear", 20, font);
  board = initializeRandomBoard(board);
}

void draw() {
  background(0);
  resButton.drawButton();
  clrButton.drawButton();
  int [][] next = new int[cols][rows];
  for (int i=1; i<cols-1; i++) {
    for (int j=1; j<rows-1; j++) {
      int neighbours = countNeighbours(i,j);
      next [i][j] = ruleOfLife(board[i][j], neighbours);
    }
  }
  if (mousePressed) {
    next = board;
  }
  board = next;
  drawBoard();
}

void mousePressed() {
  if (resButton.isPressed() == true) {
    board = initializeRandomBoard(board);
  }
  if (clrButton.isPressed() == true) {
    board = clearBoard(board);
  }
  if (mouseY <= rows*sizeCell) {
    int cellX = mouseX / sizeCell;
    int cellY = mouseY / sizeCell;
    board[cellX][cellY] = 1-board[cellX][cellY];
  }
}

void keyPressed() {
  if (key == '1') {
    board = drawConf1(board);
  }
  if (key == '2') {
    board = drawConf2(board);
  }
  if (key == '3') {
    board = drawConf3(board);
  }
}

int countNeighbours(int x, int y) {
  int neighbours = 0;
  for (int i=-1; i<=1; i++) {
    for (int j=-1; j<=1; j++) {
      neighbours += board[x+j][y+i];
    }
  }
  neighbours -= board[x][y];
  return neighbours;
}

int ruleOfLife(int status, int neighbours) {
  if (status == 1 && neighbours > 3) {
    return 0;
  } else if (status == 1 && neighbours < 2) {
    return 0;
  } else if (status == 0 && neighbours == 3) {
    return 1; 
  }
  return status;
}

void drawBoard() {
  for (int i=0; i<cols; i++) {
    for (int j=0; j<rows; j++) {
      if (board[i][j]==1) {
        fill(0);
      } else {
        fill(255);
      }
      rect(i*sizeCell, j*sizeCell, sizeCell, sizeCell);     
    }
  }
}
