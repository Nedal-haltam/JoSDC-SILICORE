/*
string metasyntactic_vars_PlusNedal[] = {
    "foobar", "foo", "bar", "baz", "qux", "quux", "corge", "grault", "garply", "waldo", "fred", "plugh", "xyzzy", "thud", "nedal"
}
int special = ((x + 97) << ((108 - 97))) + (110) - 111 + (117 - 100); // 219152
*/ 



#define SIZE1D 5
int arr[SIZE1D] = { 444, 33, 5, 6, 1 };

for (int i = 0; i < SIZE1D - 1; i = i + 1) {

    int min_idx = i;

    for (int j = i + 1; j < SIZE1D; j = j + 1) {
        if (arr[j] < arr[min_idx]) {
            min_idx = j; 
        }
    }
    
    if (i != min_idx)
    {
        arr[i]       = arr[i] ^ arr[min_idx];
        arr[min_idx] = arr[i] ^ arr[min_idx];
        arr[i]       = arr[i] ^ arr[min_idx];
    }
}