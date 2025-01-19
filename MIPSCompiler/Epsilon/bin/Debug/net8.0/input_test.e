/*
string metasyntactic_vars_PlusNedal[] = {
    "foobar", "foo", "bar", "baz", "qux", "quux", "corge", "grault", "garply", "waldo", "fred", "plugh", "xyzzy", "thud", "nedal"
}
int special = ((x + 97) << ((108 - 97))) + (110) - 111 + (117 - 100); // 219152
*/ 

#define SIZE 5


// int arr[SIZE];
// arr[0] = 12;
// arr[1] = 3;
// arr[2] = 6;
// arr[3] = 0;
// arr[4] = 100;

 int arr[SIZE] = { 444, 33, 5, 6, 0 };

 for (int i = 0; i < SIZE - 1; i = i + 1) {
 
     int min_idx = i;
 
     for (int j = i + 1; j < SIZE; j = j + 1) {
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