
#define SIZE1D 5
int arr[SIZE1D] = { 444, 33, 5, 6, 1 };
for (int i = 0; i < SIZE1D - 1; i = i + 1) {

    int min_idx = i;

    for (int j = i + 1; j < SIZE1D; j = j + 1) {
        if (arr[j] < arr[min_idx]) {
            min_idx = j; 
        }
    }
    
    int temp = arr[i];
    arr[i] = arr[min_idx];
    arr[min_idx] = temp;
    // arr[i]       = arr[i] ^ arr[min_idx];
    // arr[min_idx] = arr[i] ^ arr[min_idx];
    // arr[i]       = arr[i] ^ arr[min_idx];
}


#define SIZE2D 3

int arr2d[SIZE2D][SIZE2D];
int count = 1;
for (int i = 0; i < SIZE2D; i = i + 1)
{
    for (int j = 0; j < SIZE2D; j = j + 1)
    {
        arr2d[i][j] = count;
        count = count + 1;
    }
}