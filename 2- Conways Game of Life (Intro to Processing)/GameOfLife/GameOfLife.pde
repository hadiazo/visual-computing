//Board
int size = 8;
int cols = 600/size;
int rows = cols;
int [][] board = new int[cols][rows];
{
  for (int i=0; i<cols; i++) {
    for (int j=0; j<rows; j++) {
      board[i][j]=int(random(2)); //1=alive, 0=dead
    }
  }
}

//Screen
void setup() {
  size(600, 600);
  frameRate(24);
}

//Next
void draw() {
  background(0);
  
  int [][] next = new int[cols][rows];
  for (int i=1; i<cols-1; i++) {
    for (int j=1; j<rows-1; j++) {
      int neighbours = countNeighbours(i,j);
      next [i][j] = ruleOfLife(board[i][j], neighbours);
    }
  }
  board = next;
  drawBoard();
}

//Count number of neighbours
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

//Apply rules
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

//Draw board
void drawBoard() {
  for (int i=0; i<cols; i++) {
    for (int j=0; j<rows; j++) {
      if (board[i][j]==1) {
        fill(192);
      } else {
        fill(64);
      }
      rect(i*size, j*size, size, size);     
    }
  }
}
