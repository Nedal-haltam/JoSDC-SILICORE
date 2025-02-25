using System;
using System.IO;
using System.Numerics;
using System.Text;
using Raylib_cs;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TextBox;
using static Raylib_cs.Raylib;
using Color = Raylib_cs.Color;
using Rectangle = Raylib_cs.Rectangle;


namespace VGAG
{
    public static class clsVGAG
    {

        enum Mode
        {
            writing, drawing
        }

        class Cell
        {
            public Rectangle rect;
            public Color color;
            
            public bool drawn;
            public Cell()
            {
                rect = new Rectangle();
                color = Color.Black;
                drawn = false;
            }

            public Cell(Rectangle rect, Color color)
            {
                this.rect = rect;
                this.color = color;
            }
        }

        static Mode m = Mode.drawing;
        static Color BrushColor = Color.White;
        const int BS = 5; // small mode
        const int RS = 5; // big mode
        const int CHARW = 6;
        const int CHARH = 8;
        const char SPECIAL_CHAR = '`';
        static int DelayBackSpace = 0;
        static int CursorDelay = 0;
        static bool displaycursor = true;
        static Rectangle boundary;
        static bool small = false;
        static int rectsize = (small) ? 1 : RS;
        static int brushsize = (small) ? BS : 0;
        static bool capital = false;


        static int limit(int val, int lo, int hi) => (val <= lo) ? lo : ((val >= hi) ? hi : val);
        static List<List<Cell>> InitGrid(Rectangle boundary)
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
        static void UpdateGrid_drawing(ref List<List<Cell>> grid, int delta)
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
                        grid[i][j].drawn = mousebtnL;
                        grid[i][j].color = c;
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
                                    grid[indexy][indexx].drawn = mousebtnL;
                                    grid[indexy][indexx].color = c;
                                }
                            }
                        }
                    }
                    DrawRectangleRec(grid[i][j].rect, grid[i][j].color);
                }
            }
        }
        static void RevertBrush()
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
        static void ResetGrid(Rectangle boundary, ref List<List<Cell>> grid)
        {
            grid.Clear();
            grid = InitGrid(boundary);
        }
        static void FlipMode(ref List<List<Cell>> grid)
        {
            RevertBrush();
            boundary.Width = (small) ? boundary.Width * RS : boundary.Width / RS;
            boundary.Height = (small) ? boundary.Height * RS : boundary.Height / RS;
            ResetGrid(boundary, ref grid);
        }
        static List<List<List<byte>>> ExtractRGB(ref List<List<Color>> grid)
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
        static StringBuilder GenerateValuesparam(List<List<byte>> gen, int MemWidth)
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
        static void GenerateVcode(string variable, List<List<byte>> gen, int MemWidth, ref StringBuilder code)
        {
            code.Append(variable);
            code.Append(GenerateValuesparam(gen, MemWidth) + " };\n");
        }
        static int GetColorVal(byte val, int width)
        {
            int maxval = (int)Math.Pow(2, width) - 1;

            return val * maxval / byte.MaxValue;
        }
        static bool IsValidKey(KeyboardKey key)
        {
            return (KeyboardKey.A <= key && key <= KeyboardKey.Z) ||
                   (KeyboardKey.Zero <= key && key <= KeyboardKey.Nine) ||
                   key == KeyboardKey.Equal || key == KeyboardKey.Space;
        }
        static List<List<Color>> GetChar(int width, int height, char c)
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
            else if (c == '|')
            {
                filename = "cursor";
            }
            else
            {
                filename = (char.IsAsciiLetterLower(c)) ? $"{c}" : $"cap{c}";
            }
            string char_path = $".\\characters\\CharacterMap12\\{filename}.mif";
            return MIF2Grid(char_path);
        }

        static void AddCharToGrid(ref List<List<Cell>> grid, List<List<Color>> Char, Rectangle TextBoundary, int index)
        {
            for (int i = 0; i < Char.Count; i++)
            {
                for (int j = 0; j < Char[0].Count; j++)
                {
                    int indexy = ((index / (int)(TextBoundary.Width / CHARW)) * Char.Count + i);
                    int indexx = (index * Char[0].Count + j);
                    int indexygrid = (indexy + (int)TextBoundary.Y) % (int)TextBoundary.Height;
                    int indexxgrid = (indexx + (int)TextBoundary.X) % (int)TextBoundary.Width;
                    grid[indexygrid][indexxgrid].color = Char[i][j];
                }
            }
        }

        static void RemoveCharFromGrid(ref List<List<Cell>> grid, List<List<Color>> Char, Rectangle TextBoundary, int index)
        {
            for (int i = 0; i < Char.Count; i++)
            {
                for (int j = 0; j < Char[0].Count; j++)
                {
                    int indexy = ((index / (int)(TextBoundary.Width / CHARW)) * Char.Count + i);
                    int indexx = (index * Char[0].Count + j);
                    int indexygrid = (indexy + (int)TextBoundary.Y) % (int)TextBoundary.Height;
                    int indexxgrid = (indexx + (int)TextBoundary.X) % (int)TextBoundary.Width;
                    grid[indexygrid][indexxgrid].color = Color.Black;
                }
            }
        }


        static void _DrawText(Rectangle TextBoundary, ref List<List<Cell>> grid, string text)
        {

            if (text.Length == 0) return;
            float small_displayrectsize = (small) ? RS : 1.0f;
            List<List<Color>> Char;

            for (int i = 0; i < text.Length; i++)
            {
                Char = GetChar(CHARW, CHARH, (text[i] == SPECIAL_CHAR) ? ' ' : text[i]);
                AddCharToGrid(ref grid, Char, TextBoundary, i);
            }
        }
        static List<List<Color>> GetGridColor(ref List<List<Cell>> grid)
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
        static (int, int) GetResolution(int Count)
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
        static List<List<Color>> MIF2Grid(string load_path)
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
        static void VGAG(ref List<List<Color>> grid, string file_path, int MemWidth)
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
        static List<List<List<Color>>> ParseMap(string path, int Wper, int Hper, int N)
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
                    if (charcount == N) 
                        return ret;
                }
            }
            return ret;
        }
        static void ParseChars(string source_path, int Wper, int Hper, int N)
        {
            List<List<List<Color>>> CharMap = ParseMap(source_path, Wper, Hper, N);
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
        static void ParseNumsAndSpecial(string source_path, int Wper, int Hper, int N)
        {
            List<List<List<Color>>> NumMap = ParseMap(source_path, Wper, Hper, N);

            for (int i = 0; i < 10; i++)
            {
                List<List<Color>> Num = NumMap[i];
                VGAG(ref Num, $".\\characters\\CharacterMap12\\Num{i}.mif", 12);
                VGAG(ref Num, $".\\characters\\CharacterMap24\\Num{i}.mif", 24);
            }

            List<List<Color>> temp = NumMap[10];
            VGAG(ref temp, $".\\characters\\CharacterMap12\\equal.mif", 12);
            VGAG(ref temp, $".\\characters\\CharacterMap24\\equal.mif", 24);

            temp = NumMap[11];
            VGAG(ref temp, $".\\characters\\CharacterMap12\\cursor.mif", 12);
            VGAG(ref temp, $".\\characters\\CharacterMap24\\cursor.mif", 24);
        }
        static List<List<List<Color>>> GetCharsInOneFile(string source_path, int Wper, int Hper, int N)
        {
            List<List<List<Color>>> map = [];
            char c = 'a';
            for (int i = 0; i < 26; i++)
            {
                List<List<Color>> CapLet = GetChar(CHARW, CHARH, c);
                map.Add(CapLet);
                c++;
            }
            c = 'A';
            for (int i = 0; i < 26; i++)
            {
                List<List<Color>> SmallLet = GetChar(CHARW, CHARH, c);
                map.Add(SmallLet);
                c++;
            }
            return map;
        }
        static void ParseAllInOneFile(string source_path1, int N1, string source_path2, int N2, string dest_path, int Wper, int Hper)
        {
            List<List<List<List<Color>>>> maps = [
                ParseMap(source_path2, Wper, Hper, N2),
                //GetCharsInOneFile(source_path2, Wper, Hper, N2),
                ParseMap(source_path1, Wper, Hper, N1),
                ];
            List<List<Color>> destmap = [];
            for (int i = 0; i < maps.Count; i++)
            {
                for (int j = 0; j < maps[i].Count; j++)
                {
                    List<List<Color>> map = maps[i][j];
                    for (int k = 0; k < map.Count; k++)
                    {
                        destmap.Add(map[k]);    
                    }
                }
            }
            VGAG(ref destmap, dest_path, 12);
        }
        static List<List<T>> RescaleGrid<T>(List<List<T>> grid, float factor)
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



        static void FillGrid(ref List<List<Cell>> grid, Color c)
        {
            for (int i = 0; i < grid.Count; i++)
            {
                for (int j = 0; j < grid[0].Count; j++)
                {
                    grid[i][j].color = c;
                }
            }
        }

        static void ParseMaps()
        {
            string AlphabetMap = "D:\\GitHub Repos\\JoSDC-SILICORE\\VGAG(Desktop)\\VGAG\\bin\\Debug\\net8.0-windows\\characters\\AlphabetMap.mif";
            ParseChars(AlphabetMap, CHARW, CHARH, 26 * 2); // AlphabetMap.mif

            string NumbersAndSpecial = "D:\\GitHub Repos\\JoSDC-SILICORE\\VGAG(Desktop)\\VGAG\\bin\\Debug\\net8.0-windows\\characters\\NumbersAndSpecial.mif"; // NumbersAndSpecial.mif
            ParseNumsAndSpecial(NumbersAndSpecial, CHARW, CHARH, 12); // NumbersAndSpecial.mif
            
            string CharMem = "D:\\GitHub Repos\\JoSDC-SILICORE\\VGAG(Desktop)\\VGAG\\bin\\Debug\\net8.0-windows\\characters\\CharMem.mif"; // CharMem.mif;
            ParseAllInOneFile(NumbersAndSpecial, 13, AlphabetMap, 52, CharMem, CHARW, CHARH);
        }
        static int getindex(int a, int b)
        {
            return ((a % b) + b) % b;
        }
        static List<List<Cell>> getcopy(List<List<Cell>> src)
        {
            List<List<Cell>> ret = [];
            for (int i = 0; i < src.Count; i++)
            {
                List<Cell> temp = [];
                for (int j = 0; j < src[0].Count; j++)
                {
                    temp.Add(new(src[i][j].rect, src[i][j].color));
                }
                ret.Add(temp);
            }
            return ret;
        }
        static void GOL(ref List<List<Cell>> grid)
        {
            Random random = new Random();
            List<List<Cell>> grid2 = [];
            if (IsKeyPressed(KeyboardKey.R))
            {
                for (int i = 0; i < grid.Count; i++)
                {
                    for (int j = 0; j < grid[0].Count; j++)
                    {
                        grid[i][j].color = (random.Next(10) < 2) ? Color.White : Color.Black;
                    }
                }
            }
            BeginDrawing();
            ClearBackground(Color.Pink);
            grid2 = getcopy(grid);
            for (int i = 0; i < grid.Count; i++)
            {
                for (int j = 0; j < grid[0].Count; j++)
                {
                    int live = 0;
                    for (int dx = i - 1; dx <= i + 1; dx++)
                    {
                        for (int dy = j - 1; dy <= j + 1; dy++)
                        {
                            if (dx == i && dy == j) continue;
                            if (grid[getindex(dx, grid.Count)][getindex(dy, grid[0].Count)].color.Equals(Color.White))
                                live++;
                        }
                    }

                    if (grid[i][j].color.Equals(Color.White))
                    {
                        if (!(live == 2 || live == 3))
                            grid2[i][j].color = Color.Black;
                    }
                    else
                    {
                        if (live == 3)
                            grid2[i][j].color = Color.White;
                    }
                }
            }
            grid = getcopy(grid2);
            UpdateGrid_drawing(ref grid, brushsize);
            EndDrawing();
        }
        unsafe public static void main()
        {
            
            int w = 800; // for the application
            int h = 600; // for the application
            int commdiv = 1;
            int OrigW = 640 / commdiv; // for the screen to display on
            int OrigH = 480 / commdiv; // for the screen to display on
            string text = "";


            SetConfigFlags(ConfigFlags.AlwaysRunWindow);
            InitWindow(w, h, "VGAG");
            SetTargetFPS(30); // maximum FPS

            int x = (w / 2 - (OrigW) / 2);
            int y = (h / 2 - (OrigH) / 2);
            int bw = (OrigW) / rectsize;
            int bh = (OrigH) / rectsize;

            Rectangle TextBoundary = new()
            {
                X = 0,
                Y = 0,
                Width = CHARW * (bw / CHARW),
                Height = CHARH * (bh / CHARH)
            }; // the TextBoundary specs are square wise, like the character map
            boundary = new(x, y, bw, bh);
            List<List<Cell>> grid = InitGrid(boundary);
            List<int> newlines = new List<int>();
            bool changed = false;
            bool IterateGOL = false;
            while (!WindowShouldClose())
            {
                if (IsKeyPressed(KeyboardKey.C) && m != Mode.writing) IterateGOL = !IterateGOL;
                if (IterateGOL)
                {
                    GOL(ref grid);
                    continue;
                }
                if (IsKeyPressed(KeyboardKey.G))
                {
                    ParseMaps();
                }
                bool Ctrl = IsKeyDown(KeyboardKey.LeftControl) || IsKeyDown(KeyboardKey.RightControl);
                string FPS = GetFPS().ToString();
                DrawText($"FPS: {FPS}\nText Shown: {text}", 0, 0, 20, Color.White);

                if (CursorDelay++ % 30 == 0)
                {
                    displaycursor = !displaycursor;
                    changed = true;
                }
                if (IsKeyDown(KeyboardKey.Backspace))
                {
                    DelayBackSpace++;
                }
                else
                    DelayBackSpace = 0;

                if (Ctrl)
                {
                    if (IsKeyPressed(KeyboardKey.D) && m != Mode.writing) // Delete
                    {
                        FillGrid(ref grid, Color.Black);
                    }
                    else if (IsKeyPressed(KeyboardKey.F)) // Flip
                    {
                        FlipMode(ref grid);
                        changed = true;
                    }
                    else if (IsKeyPressed(KeyboardKey.M))
                    {
                        if (m == Mode.drawing)
                        {
                            m = Mode.writing;
                            text = text.Remove(0);
                            FillGrid(ref grid, Color.Black);
                        }
                        else if (m == Mode.writing)
                        {
                            m = Mode.drawing;
                            text = text.Remove(0);
                            FillGrid(ref grid, Color.Black);
                        }
                    }
                    if (IsKeyPressed(KeyboardKey.S))
                    {
                        SaveFileDialog fileDialog = new SaveFileDialog();
                        fileDialog.AddExtension = true;
                        fileDialog.DefaultExt = "mif";
                        DialogResult dialogResult = fileDialog.ShowDialog();
                        if (dialogResult == DialogResult.OK)
                        {
                            string filepath = fileDialog.FileName;
                            if (m == Mode.writing)
                                RemoveCharFromGrid(ref grid, GetChar(CHARW, CHARH, ' '), TextBoundary, text.Length);
                            List<List<Color>> gridc = GetGridColor(ref grid);
                            VGAG(ref gridc, filepath, 12);
                        }

                    }
                }
                else
                {
                    KeyboardKey key = (KeyboardKey)GetKeyPressed();
                    if (m == Mode.writing)
                    {
                        // minus one to account for the cursor
                        int MaxChars = (int)(TextBoundary.Width * TextBoundary.Height * (1.0f / (CHARW * CHARH))) - 1;
                        if (key == KeyboardKey.CapsLock)
                        {
                            changed = true;
                            capital = !capital;
                        }

                        bool ContinueBackSpace = (DelayBackSpace >= 30 && DelayBackSpace % 9 == 0);
                        if (text.Length > 0 && (key == KeyboardKey.Backspace || ContinueBackSpace))
                        {
                            changed = true;
                            int i = text.Length - 1;
                            if (text[i] == SPECIAL_CHAR)
                            {
                                i -= newlines[^1];
                                newlines = newlines[..^1];
                                i++;
                            }

                            text = text[..^(text.Length - i)];
                            FillGrid(ref grid, Color.Black);
                            displaycursor = true;
                        }
                        else if (key == KeyboardKey.Enter)
                        {
                            changed = true;
                            int numberofchars = (int)(TextBoundary.Width / CHARW);
                            int count = numberofchars - (text.Length % numberofchars);
                            if (text.Length + count < MaxChars)
                            {
                                for (int i = 0; i < count; i++) text += SPECIAL_CHAR;
                                newlines.Add(count);
                            }
                        }
                        else if (text.Length < MaxChars && IsValidKey(key))
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
                                grid[i][j].color = gridc[i][j];
                            }
                        }
                    }
                    UnloadDroppedFiles(fpl);
                }


                BeginDrawing();
                ClearBackground(Color.DarkGray);

                if (m == Mode.writing)
                {
                    if (changed)
                    {
                        _DrawText(TextBoundary, ref grid, text);
                    }
                    if (displaycursor && !(Ctrl && IsKeyPressed(KeyboardKey.S)))
                    {
                        List<List<Color>> Char = GetChar(CHARW, CHARH, '|');
                        AddCharToGrid(ref grid, Char, TextBoundary, text.Length);
                    }
                    else
                    {
                        List<List<Color>> Char = GetChar(CHARW, CHARH, ' ');
                        AddCharToGrid(ref grid, Char, TextBoundary, text.Length);
                    }
                }
                UpdateGrid_drawing(ref grid, brushsize);

                EndDrawing();
                changed = false;
            }
            CloseWindow();
            return;
        }
    }
}