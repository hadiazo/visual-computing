int[][] initializeRandomBoard(int[][] board) {
  for (int i=0; i<board.length; i++) {
    for (int j=0; j<board[0].length; j++) {
      board[i][j] = int(random(2));
    }
  }
  return board;
}

int[][] clearBoard(int[][] board) {
  for (int i=0; i<board.length; i++) {
    for (int j=0; j<board[0].length; j++) {
      board[i][j] = 0;
    }
  }
  return board;
}

int[][] drawConf1(int[][] board) { //Press '1' key
  for (int i=0; i<board.length; i++) {
    for (int j=0; j<board[0].length; j++) {
      if (i == j || j == board.length-i) {
        board[i][j] = 1;
      } else {
        board[i][j] = 0; 
      }
    }
  }
  return board;
}

int[][] drawConf2(int[][] board) { //Press '2' key
  int count = 0;
  for (int i=0; i<board.length; i++) {
    for (int j=0; j<board[0].length; j++) {
      int mod = (count % 9)+1;
      if (i == board.length % mod) {
        board[i][j] = 1;
      } else {
        board[i][j] = 0; 
      }
    }
    count += 1;
  }
  return board;
}

int[][] drawConf3(int[][] board) { //Press '3' key
  for (int i=0; i<board.length; i++) {
    for (int j=0; j<board[0].length; j++) {
      if (j % 2 == 0) {
        board[i][j] = 1;
      } else {
        board[i][j] = 0; 
      }
    }
  }
  return board;
}
