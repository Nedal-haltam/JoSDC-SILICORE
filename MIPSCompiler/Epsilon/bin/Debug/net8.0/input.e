




int x = (1 + 2) + 3 + (4 + 5 + 6);
// the line above will generate this assembly code without `constant folding` optimization technique
// see below the new code generated
/*
.text
main:
ADDI $sp, $zero, 50
ADDI $1, $zero, 6
SW $1, 0($sp)
ADDI $sp, $sp, -1
ADDI $1, $zero, 5
SW $1, 0($sp)
ADDI $sp, $sp, -1
ADDI $1, $zero, 4
SW $1, 0($sp)
ADDI $sp, $sp, -1
ADDI $1, $zero, 3
SW $1, 0($sp)
ADDI $sp, $sp, -1
ADDI $1, $zero, 2
SW $1, 0($sp)
ADDI $sp, $sp, -1
ADDI $1, $zero, 1
SW $1, 0($sp)
ADDI $sp, $sp, -1
ADDI $sp, $sp, 1
LW $1, 0($sp)
ADDI $sp, $sp, 1
LW $2, 0($sp)
ADD $1, $1, $2
SW $1, 0($sp)
ADDI $sp, $sp, -1
ADDI $sp, $sp, 1
LW $1, 0($sp)
ADDI $sp, $sp, 1
LW $2, 0($sp)
ADD $1, $1, $2
SW $1, 0($sp)
ADDI $sp, $sp, -1
ADDI $sp, $sp, 1
LW $1, 0($sp)
ADDI $sp, $sp, 1
LW $2, 0($sp)
ADD $1, $1, $2
SW $1, 0($sp)
ADDI $sp, $sp, -1
ADDI $sp, $sp, 1
LW $1, 0($sp)
ADDI $sp, $sp, 1
LW $2, 0($sp)
ADD $1, $1, $2
SW $1, 0($sp)
ADDI $sp, $sp, -1
ADDI $sp, $sp, 1
LW $1, 0($sp)
ADDI $sp, $sp, 1
LW $2, 0($sp)
ADD $1, $1, $2
SW $1, 0($sp)
ADDI $sp, $sp, -1
*/
// with `constant folding` optimization technique
/*
.text
main:
ADDI $sp, $zero, 50
ADDI $1, $zero, 21
SW $1, 0($sp)
ADDI $sp, $sp, -1
*/


/*
#define SIZE 4

int grid[SIZE][SIZE];
int grid2[SIZE][SIZE];
grid[0][1] = 1;
grid[1][1] = 1;
grid[2][1] = 1;

#define COPY122 for (int ci = 0; ci < SIZE; ci = ci + 1) { for (int cj = 0; cj < SIZE; cj = cj + 1) { grid2[ci][cj] = grid[ci][cj]; } }
#define COPY221 for (int ci = 0; ci < SIZE; ci = ci + 1) { for (int cj = 0; cj < SIZE; cj = cj + 1) { grid[ci][cj] = grid2[ci][cj]; } }
#define IS 3

for (int iter = 0; iter < IS; iter = iter + 1)
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
                        if (dx == (0 - 1))
                            indexx = SIZE - 1;
                        else if (dx == SIZE)
                            indexx = 0;
                        if (dy == (0 - 1))
                            indexy = SIZE - 1;
                        else if (dy == SIZE)
                            indexy = 0;
                        
                        if (grid[indexx][indexy])
                            live = live + 1;
                    }
                }
            }
            if (grid[i][j] == 1)
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
*/


