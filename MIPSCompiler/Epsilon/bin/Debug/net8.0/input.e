



#define SIZE 12
#define COPY122 for (int ci = 0; ci < SIZE; ci = ci + 1) { for (int cj = 0; cj < SIZE; cj = cj + 1) { grid2[ci][cj] = grid[ci][cj]; } }
#define COPY221 for (int ci = 0; ci < SIZE; ci = ci + 1) { for (int cj = 0; cj < SIZE; cj = cj + 1) { grid[ci][cj] = grid2[ci][cj]; } }

cleanstack;

int grid[SIZE][SIZE];
int grid2[SIZE][SIZE];

#define glider_size 5
#define blinker_size 3
int glider_index[glider_size][2] = {{1, 2}, {2, 3}, {3, 1}, {3, 2}, {3, 3}};
int blinker_index[blinker_size][2] = {{2, 8}, {2, 9}, {2, 10}};

//int glider_index[glider_size][2] = {{1, 2}, {2, 3}, {3, 1}, {3, 2}, {3, 3}};
//int blinker_index[blinker_size][2] = {{3, 7}, {3, 8}, {3, 9}};

for (int i = 0; i < glider_size; i = i + 1)
{
    grid[glider_index[i][0]][glider_index[i][1]] = 1;
}

for (int i = 0; i < blinker_size; i = i + 1)
{
    grid[blinker_index[i][0]][blinker_index[i][1]] = 1;
}

// the number of iterations is modified after copying the instruction initialization from the RealTimeCAS to the 
// D:\GitHub Repos\JoSDC-SILICORE\SSOOO\Instruction Queue\code.txt
#define iters 1000

for (int iter = 0; iter < 1; iter = iter + 1)
{
    COPY122
    for (int i = 0; i < SIZE; i = i + 1)
    {
        for (int j = 0; j < SIZE; j = j + 1)
        {
            int live = 0;
            for (int dx = i - 1; dx < i + 2; dx = dx + 1)
            {
                for (int dy = j - 1; dy < j + 2; dy = dy + 1)
                {
                    if ((dx != i) | (dy != j))
                    {
                        int indexx = dx;
                        int indexy = dy;
                        if (dx == -1)
                            indexx = SIZE - 1;
                        else if (dx == SIZE)
                            indexx = 0;
                        if (dy == -1)
                            indexy = SIZE - 1;
                        else if (dy == SIZE)
                            indexy = 0;
                        
                        if (grid[indexx][indexy])
                            live = live + 1;
                    }
                }
            }
            if (grid[i][j])
            {
                if ((live != 2) & (live != 3))
                    grid2[i][j] = 0;
            }
            else
            {
                if (live == 3)
                    grid2[i][j] = 1;
            }
        }
    }
    COPY221
}