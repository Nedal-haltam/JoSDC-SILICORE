/*
int x = 10;
int y = x + 200; // 210
int z = ((x >> 2) + y << 3) - 1 + 2 + x; // 1707
int w = (y << 2) + 1; // 841
int special = ((x + 97) << ((108 - 97))) + (110) - 111 + (117 - 100); // 219152

for (int i = 0; i < 10; i++)
{
    x = x + 1
}

exit(0 - y);
*/

int x = 1;
int y = 10;
for (int i = 0; i < 10; i = i + 1)
{
    y = y + 1;
    x = x + 1;
}
exit(42);
