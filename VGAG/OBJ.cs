using Raylib_cs;
using static Raylib_cs.Raylib;
using Color = Raylib_cs.Color;
using Rectangle = Raylib_cs.Rectangle;

enum Mode
{
    writing, drawing
}

struct Cell
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
