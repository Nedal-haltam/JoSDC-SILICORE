using System;
using System.IO;
using System.Numerics;
using System.Runtime.CompilerServices;
using System.Text;
using Raylib_cs;
using static System.Runtime.InteropServices.JavaScript.JSType;
using static Raylib_cs.Raylib;
using Color = Raylib_cs.Color;
using Rectangle = Raylib_cs.Rectangle;

Mode m = Mode.drawing;
Color BrushColor = Color.White;
const int BS = 5; // small mode
const int RS = 5; // big mode
const int CHARW = 6;
const int CHARH = 8;
Rectangle boundary;
bool small = false;
int rectsize = (small) ? 1 : RS;
int brushsize = (small) ? BS : 0;
bool capital = false;

main();
return;


int limit(int val, int lo, int hi) => (val <= lo) ? lo : ((val >= hi) ? hi : val);
List<List<Cell>> InitGrid(Rectangle boundary)
{
    Color BackColor = Color.Black;
    List<List<Cell>> grid = [];
    int gap = (small) ? 0 : 0;
    for (int i = 0; i < boundary.Height; i++)
    {
        List<Cell> rects = [];
        for (int j = 0; j < boundary.Width; j++)
        {
            Rectangle rec = new(boundary.X + j * rectsize, boundary.Y + i * rectsize, rectsize - gap, rectsize - gap);
            rects.Add(new Cell(rec, BackColor));
        }
        grid.Add(rects);
    }
    return grid;
}
void UpdateGrid_drawing(ref List<List<Cell>> grid, int delta)
{
    if (m != Mode.drawing)
    {
        for (int i = 0; i < grid.Count; i++)
        {
            for (int j = 0; j < grid[0].Count; j++)
            {
                DrawRectangleRec(grid[i][j].rect, grid[i][j].color);
            }
        }
        return;
    }
    for (int i = 0; i < grid.Count; i++)
    {
        for (int j = 0; j < grid[0].Count; j++)
        {
            Vector2 center = new(j, i);
            bool mousebtnL = IsMouseButtonDown(MouseButton.Left);
            bool mousebtnR = IsMouseButtonDown(MouseButton.Right);
            Color c = (mousebtnL) ? BrushColor : Color.Black;
            if ((mousebtnL || mousebtnR) && CheckCollisionPointRec(GetMousePosition(), grid[i][j].rect))
            {
                Cell temp = grid[i][j];
                temp.drawn = mousebtnL;
                temp.color = c;
                grid[i][j] = temp;
                for (int dy = i - delta; dy < i + delta; dy++)
                {
                    for (int dx = j - delta; dx < j + delta; dx++)
                    {
                        Vector2 currpoint = new(dx, dy);
                        int indexy = limit((int)currpoint.Y, 0, grid.Count - 1);
                        int indexx = limit((int)currpoint.X, 0, grid[0].Count - 1);
                        if (mousebtnL && grid[indexy][indexx].drawn)
                            continue;
                        if (CheckCollisionPointCircle(currpoint, center, delta))
                        {
                            Cell temp2 = grid[indexy][indexx];
                            temp2.drawn = mousebtnL;
                            temp2.color = c;
                            grid[indexy][indexx] = temp2;
                        }
                    }
                }
            }
            DrawRectangleRec(grid[i][j].rect, grid[i][j].color);
        }
    }
}
void RevertBrush()
{
    small = !small;
    if (small)
    {
        rectsize = 1;
        brushsize = BS;
    }
    else
    {
        rectsize = RS;
        brushsize = 0;
    }
}
void ResetGrid(Rectangle boundary, ref List<List<Cell>> grid)
{
    grid.Clear();
    grid = InitGrid(boundary);
}
void FlipMode(ref List<List<Cell>> grid)
{
    RevertBrush();
    boundary.Width = (small) ? boundary.Width * RS : boundary.Width / RS;
    boundary.Height = (small) ? boundary.Height * RS : boundary.Height / RS;
    ResetGrid(boundary, ref grid);
}
List<List<List<byte>>> ExtractRGB(ref List<List<Color>> grid)
{
    List<List<byte>> R = [];
    List<List<byte>> G = [];
    List<List<byte>> B = [];

    for (int i = 0; i < grid.Count; i++)
    {
        List<byte> tempR = [];
        List<byte> tempG = [];
        List<byte> tempB = [];
        for (int j = 0; j < grid[0].Count; j++)
        {
            tempR.Add(grid[i][j].R);
            tempG.Add(grid[i][j].G);
            tempB.Add(grid[i][j].B);
        }
        R.Add(tempR);
        G.Add(tempG);
        B.Add(tempB);
    }
    return [R, G, B];
}
StringBuilder GenerateValuesparam(List<List<byte>> gen, int MemWidth)
{
    StringBuilder code = new();
    int width = (gen.Count > 0) ? gen[0].Count : 0;
    int height = gen.Count;

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            string val = (gen[i][j] > 0) ? $"{Math.Pow(2, MemWidth / 3) - 1}" : "0";
            code.Append($"{MemWidth / 3}'d{val}");
            if (!(i == height - 1 && j == width - 1)) code.Append(", ");
        }
        code.Append('\n');
    }

    return code;
}
void GenerateVcode(string variable, List<List<byte>> gen, int MemWidth, ref StringBuilder code)
{
    code.Append(variable);
    code.Append(GenerateValuesparam(gen, MemWidth) + " };\n");
}
int GetColorVal(byte val, int width)
{
    int maxval = (int)Math.Pow(2, width) - 1;

    return val * maxval / byte.MaxValue;
}
bool IsValidKey(KeyboardKey key)
{
    return (KeyboardKey.A <= key && key <= KeyboardKey.Z) ||
           (KeyboardKey.Zero <= key && key <= KeyboardKey.Nine) ||
           key == KeyboardKey.Equal || key == KeyboardKey.Space;
}
List<List<Color>> GetChar(int width, int height, char c)
{
    string filename;
    if (char.IsDigit(c))
    {
        filename = $"Num{c - 48}";
    }
    else if (c == '=')
    {
        filename = "equal";
    }
    else if (c == ' ')
    {
        filename = "space";
    }
    else
    {
        filename = (char.IsAsciiLetterLower(c)) ? $"{c}" : $"cap{c}";
    }
    string char_path = $".\\characters\\CharacterMap12\\{filename}.mif";
    return MIF2Grid(char_path);
}
void _DrawText(Rectangle boundary, ref List<List<Cell>> grid, string text)
{
    if (text.Length == 0) return;
    float small_displayrectsize = (small) ? RS : 1.0f;
    //List<List<Cell>> newgridcolor = InitGrid(boundary);

    for (int c = 0; c < text.Length; c++)
    {
        List<List<Color>> Char = GetChar(CHARW, CHARH, text[c]);

        for (int i = 0; i < Char.Count; i++)
        {
            for (int j = 0; j < Char[0].Count; j++)
            {
                int indexy = ((c / 21) * Char.Count + i);
                int indexx = (c * Char[0].Count + j);
                int indexygrid = (indexy + (int)boundary.Y) % (int)boundary.Height;
                int indexxgrid = (indexx + (int)boundary.X) % (int)boundary.Width;
                Cell temp = grid[indexygrid][indexxgrid];
                temp.color = Char[i][j];
                grid[indexygrid][indexxgrid] = temp;
            }
        }
    }
}
List<List<Color>> GetGridColor(ref List<List<Cell>> grid)
{
    List<List<Color>> gridc = [];
    for (int i = 0; i < grid.Count; i++)
    {
        List<Color> ray = [];
        for (int j = 0; j < grid[0].Count; j++)
        {
            ray.Add(grid[i][j].color);
        }
        gridc.Add(ray);
    }
    return gridc;
}
(int, int) GetResolution(int Count)
{
    int width = 640;
    int height = 480;
    if (Count == 307200)
    {
        width = 640;
        height = 480;
    }
    else if (Count == 3072)
    {
        width = 64;
        height = 48;
    }
    else if (Count == 76800)
    {
        width = 320;
        height = 240;
    }
    else if (Count == 768)
    {
        width = 32;
        height = 24;
    }
    else if (Count == 4800)
    {
        width = 60;
        height = 80;
    }
    else if (Count == 48)
    {
        width = 6;
        height = 8;
    }
    else if (Count == 12288)
    {
        width = 128;
        height = 96;
    }
    return (width, height);
}
List<List<Color>> MIF2Grid(string load_path)
{
    List<List<Color>> grid = [];
    string MIFile = File.ReadAllText(load_path);
    List<string> data = [.. MIFile.Split('\n')];
    string MemWidths = data[0].Split(' ')[2];
    int MemWidth = Convert.ToInt32(MemWidths[..^2]) / 3;
    data = data[8..(data.Count - 1)];
    int colorsize = (MemWidth == 8) ? 2 : 1;
    int addr = 0;
    (int width, int height) = GetResolution(data.Count);
    for (int i = 0; i < height; i++)
    {
        List<Color> row = [];
        for (int j = 0; j < width; j++)
        {
            string exp = data[addr].Split(' ').ToList()[2];
            string val = exp[..(exp.Length - 1)];
            int b = Convert.ToInt32(val[(0)..(1 * colorsize)], 16);
            int g = Convert.ToInt32(val[(1 * colorsize)..(2 * colorsize)], 16);
            int r = Convert.ToInt32(val[(2 * colorsize)..(3 * colorsize)], 16);

            Color c = new(r * byte.MaxValue / ((int)Math.Pow(2, MemWidth) - 1),
                          g * byte.MaxValue / ((int)Math.Pow(2, MemWidth) - 1),
                          b * byte.MaxValue / ((int)Math.Pow(2, MemWidth) - 1));

            row.Add(c);
            addr++;
        }
        grid.Add(row);
    }
    return grid;
}
void VGAG(ref List<List<Color>> grid, string file_path, int MemWidth)
{
    List<List<List<byte>>> gen = ExtractRGB(ref grid);
    int width = (gen[0].Count > 0) ? gen[0][0].Count : 0;// we multiplied with the rect ratio
    int height = gen[0].Count;                          // we multiplied with the rect ratio
    int addr = 0;
    int padding = MemWidth / 3 / 4; // for every color (3) / for every hex digit (4)
    StringBuilder vals = new();
    string head = $"WIDTH = {MemWidth};\r\nDEPTH = {height * width};\r\n\r\nADDRESS_RADIX = HEX;\r\nDATA_RADIX = HEX;\r\n\r\nCONTENT BEGIN";
    string tail = "END;";
    vals.Append(head + "\n\n");

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            // we divided by the rect ratio
            string r = Convert.ToString(GetColorVal(gen[0][i][j], MemWidth / 3), 16).ToUpper().PadLeft(padding, '0');
            string g = Convert.ToString(GetColorVal(gen[1][i][j], MemWidth / 3), 16).ToUpper().PadLeft(padding, '0');
            string b = Convert.ToString(GetColorVal(gen[2][i][j], MemWidth / 3), 16).ToUpper().PadLeft(padding, '0');
            string val = b + g + r;
            vals.Append($"{Convert.ToString(addr++, 16)} : {val};\n");
        }
    }
    vals.Append(tail);

    File.WriteAllText(file_path, vals.ToString());
}
List<List<List<Color>>> ParseMap(string path, int Wper, int Hper, int N)
{
    List<List<Color>> temp = MIF2Grid(path);

    List<List<List<Color>>> ret = [];
    int charcount = 0;
    for (int cy = 0; cy < temp.Count / Hper; cy++)
    {
        for (int cx = 0; cx < temp[0].Count / Wper; cx++)
        {
            List<List<Color>> curr_char = [];
            for (int i = 0; i < Hper; i++)
            {
                List<Color> tmp = [];
                for (int j = 0; j < Wper; j++)
                {
                    tmp.Add(temp[(cy * Hper + i)][(cx * Wper + j)]);
                }
                curr_char.Add(tmp);
            }
            ret.Add(curr_char);
            charcount++;
            if (charcount == N) return ret;
        }
    }
    return ret;
}
void ParseChars(string path, int Wper, int Hper, int N)
{
    List<List<List<Color>>> CharMap = ParseMap(path, Wper, Hper, N);
    char c = 'a';
    for (int i = 0; i < 26; i++)
    {
        List<List<Color>> CapLet = CharMap[i];
        List<List<Color>> SmallLet = CharMap[i + 26];
        VGAG(ref CapLet, $".\\characters\\CharacterMap12\\cap{c}.mif", 12);
        VGAG(ref SmallLet, $".\\characters\\CharacterMap12\\{c}.mif", 12);
        VGAG(ref CapLet, $".\\characters\\CharacterMap24\\cap{c}.mif", 24);
        VGAG(ref SmallLet, $".\\characters\\CharacterMap24\\{c}.mif", 24);
        c++;
    }
}
void ParseNumsAndSpecial(string path, int Wper, int Hper, int N)
{
    List<List<List<Color>>> NumMap = ParseMap(path, Wper, Hper, N);

    for (int i = 0; i < 10; i++)
    {
        List<List<Color>> Num = NumMap[i];
        VGAG(ref Num, $".\\characters\\CharacterMap12\\Num{i}.mif", 12);
        VGAG(ref Num, $".\\characters\\CharacterMap24\\Num{i}.mif", 24);
    }

    List<List<Color>> temp = NumMap[10];
    VGAG(ref temp, $".\\characters\\CharacterMap12\\equal.mif", 12);
    VGAG(ref temp, $".\\characters\\CharacterMap24\\equal.mif", 24);
}
void ParseNumsAndSpecialInOneMIF(string path, int Wper, int Hper, int N)
{
    string destpath = "D:\\quartus\\Quartus_Projects\\DE2115_DE10LITE_VGA\\CharMem.mif"; // CharMem.mif
    List<List<List<Color>>> NumMap = ParseMap(path, Wper, Hper, N);
    List<List<Color>> destmap = [];
    for (int i = 0; i < 10; i++)
    {
        List<List<Color>> Num = NumMap[i];
        for (int j = 0; j < Num.Count; j++)
        {
            List<Color> temp = [];
            for (int k = 0; k < Num[0].Count; k++)
            {
                temp.Add(Num[j][k]);
            }
            destmap.Add(temp);
        }
    }
    VGAG(ref destmap, destpath, 24);
}
List<List<T>> RescaleGrid<T>(List<List<T>> grid, float factor)
{
    List<List<T>> ret = [];
    for (int i = 0; i < grid.Count * factor; i++)
    {
        List<T> temp = [];
        for (int j = 0; j < grid[0].Count * factor; j++)
        {
            temp.Add(grid[(int)(i / factor)][(int)(j / factor)]);
        }
        ret.Add(temp);
    }
    return ret;
}

// TODO: -better UI (or usage (e.g. colors)), so we can draw beautiful things
unsafe void main()
{
    //ParseChars("", CHARW, CHARH, 26 * 2); // AlphabetMap.mif
    //ParseNumsAndSpecial("", CHARW, CHARH, 11); // NumbersAndSpecial.mif
    //ParseNumsAndSpecialInOneMIF("D:\\JoSDC Comp Folder\\OUR's\\VGAG\\bin\\Debug\\net8.0\\characters\\NumbersAndSpecial.mif", CHARW, CHARH, 11); // NumbersAndSpecial.mif

    int w = 800; // for the application
    int h = 600; // for the application
    int commdiv = 1;
    int OrigW = 640 / commdiv; // for the screen to display on
    int OrigH = 480 / commdiv; // for the screen to display on
    string text = "";
    

    SetConfigFlags(ConfigFlags.AlwaysRunWindow);
    InitWindow(w, h, "VGAG");
    SetTargetFPS(0); // maximum FPS

    int x = (w / 2 - (OrigW) / 2);
    int y = (h / 2 - (OrigH) / 2);
    int bw = (OrigW) / rectsize;
    int bh = (OrigH) / rectsize;

    Rectangle TextBoundary = new()
    {
        X = 0,
        Y = 0,
        Width = CHARW * 21,
        Height = CHARH * 6
    }; // the TextBoundary specs are square wise, like the character map
    boundary = new(x, y, bw, bh);
    List<List<Cell>> grid = InitGrid(boundary);

    bool changed = false;
    while (!WindowShouldClose())
    {
        bool Ctrl = IsKeyDown(KeyboardKey.LeftControl) || IsKeyDown(KeyboardKey.RightControl);
        string FPS = GetFPS().ToString();
        DrawText($"FPS: {FPS}\nText Shown: {text}", 0, 0, 20, Color.White);
        if (Ctrl)
        {
            if (IsKeyPressed(KeyboardKey.D) && m != Mode.writing) // Delete
            {
                ResetGrid(boundary, ref grid);
            }
            else if (IsKeyPressed(KeyboardKey.F)) // Flip
            {
                FlipMode(ref grid);
            }
            else if (IsKeyPressed(KeyboardKey.M))
            {
                if (m == Mode.drawing)
                {
                    m = Mode.writing;
                    text = text.Remove(0);
                    ResetGrid(boundary, ref grid);
                }
                else if (m == Mode.writing)
                {
                    m = Mode.drawing;
                    text = text.Remove(0);
                    ResetGrid(boundary, ref grid);
                }
            }
            if (IsKeyPressed(KeyboardKey.S))
            {
                string path = GetClipboardText_();
                path = path.Replace("\"", "");
                List<List<Color>> gridc = GetGridColor(ref grid);
                VGAG(ref gridc, path, 12);
            }
        }
        else
        {
            KeyboardKey key = (KeyboardKey)GetKeyPressed();
            if (m == Mode.writing)
            {
                if (key == KeyboardKey.Backspace && text.Length > 0)
                {
                    changed = true;
                    text = text[..^1];
                    grid = InitGrid(boundary);
                }
                else if (key == KeyboardKey.CapsLock)
                {
                    changed = true;
                    capital = !capital;
                }
                if (key == KeyboardKey.Enter) // TODO: implement a real newline don't just fill it with spaces, you lazy
                {
                    changed = true;
                    int count = 21 - (text.Length % 21);
                    for (int i = 0; i < count; i++) text += " ";
                }
                else if (IsValidKey(key))
                {
                    changed = true;
                    char car = (char)key;
                    text += (capital) ? car.ToString().ToUpper() : car.ToString().ToLower();
                }
            }
        }

        if (IsFileDropped() && m == Mode.drawing)
        {
            FilePathList fpl = LoadDroppedFiles();
            if (fpl.Count > 0)
            {
                string load_path = "";
                byte* pathbytes = fpl.Paths[0];
                int b = 0;
                while (pathbytes[b] != '\0')
                {
                    load_path += (char)pathbytes[b++];
                }
                List<List<Color>> gridc = MIF2Grid(load_path);
                float f = (small && gridc.Count * gridc[0].Count < 307200) ? rectsize : 1;
                gridc = RescaleGrid(gridc, f);

                boundary.X = (w / 2 - (gridc[0].Count * rectsize) / 2);
                boundary.Y = (h / 2 - (gridc.Count * rectsize) / 2);
                boundary.Width = gridc[0].Count;
                boundary.Height = gridc.Count;
                grid = InitGrid(boundary);
                for (int i = 0; i < grid.Count; i++)
                {
                    for (int j = 0; j < grid[0].Count; j++)
                    {
                        Cell temp = grid[i][j];
                        temp.color = gridc[i][j];
                        grid[i][j] = temp;
                    }
                }
            }
            UnloadDroppedFiles(fpl);
        }


        BeginDrawing();
        ClearBackground(Color.DarkGray);

        if (m == Mode.writing && changed)
        {
            _DrawText(TextBoundary, ref grid, text);
        }
        UpdateGrid_drawing(ref grid, brushsize);

        EndDrawing();
        changed = false;
    }
    CloseWindow();
    return;
}