
using static Epsilon.Macros;


namespace Epsilon
{
    public static class Macros
    {
        public static void cout<T>(T str, params object[] args)
        {
            if (str == null) return;
            Console.WriteLine(str.ToString(), args);
        }
    }
    internal class Program
    {
        static void Main()
        {
            //int[] arr = { 4, 5, 3, 5, 6, 54, 3, 23, 5, 6,9, 12 };

            //for (int i = 0; i < 0; i++)
            //{
            //    for (int j = 0; j < arr.Length; j++)
            //    {
            //        if (arr[j] > arr[i])
            //        {
            //            (arr[i], arr[j]) = (arr[j], arr[i]);
            //        }
            //    }
            //}
            //foreach (var item in arr)
            //{
            //    cout(item.ToString());
            //}



            int x = 10;
            int y = 0;

            for (; x != 0; x--)
            {
                y = y + 1;
            }
            cout($"x = {x} , y = {y}");
        }
    }
}
