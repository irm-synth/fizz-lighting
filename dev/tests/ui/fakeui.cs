using System;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;

namespace FakeUI
{
    // ---------- enums used by the script ----------
    public enum DialogResult { None = 0, OK = 1, Cancel = 2, Abort = 3, Retry = 4, Ignore = 5, Yes = 6, No = 7 }
    public enum MouseButtons { None = 0, Left = 1048576, Right = 2097152, Middle = 4194304 }
    public enum SmoothingMode { Default, HighSpeed, HighQuality, None, AntiAlias }
    public enum TextRenderingHint { SystemDefault, SingleBitPerPixelGridFit, SingleBitPerPixel, AntiAliasGridFit, AntiAlias, ClearTypeGridFit }
    public enum StringAlignment { Near, Center, Far }
    public enum StringTrimming { None, Character, Word, EllipsisCharacter, EllipsisWord, EllipsisPath }
    [Flags] public enum StringFormatFlags { DirectionRightToLeft = 1, DirectionVertical = 2, NoWrap = 4096 }

    // ---------- GDI+ stand-ins ----------
    public class Font { public string Name; public float Size; public Font(string n, float s) { Name = n; Size = s; } }
    public class Brush : IDisposable { public virtual void Dispose() { } }
    public class SolidBrush : Brush { public Color Color; public SolidBrush(Color c) { Color = c; } }
    public class Pen : IDisposable { public Color Color; public float Width; public Pen(Color c, float w) { Color = c; Width = w; } public void Dispose() { } }
    public class StringFormat : IDisposable
    {
        public StringAlignment Alignment; public StringAlignment LineAlignment; public StringTrimming Trimming; public StringFormatFlags FormatFlags;
        public void Dispose() { }
    }
    public class GraphicsPath : IDisposable
    {
        public int Arcs = 0; public bool Closed = false;
        public void AddArc(float x, float y, float w, float h, float start, float sweep) { Arcs++; }
        public void CloseFigure() { Closed = true; }
        public void Dispose() { }
    }
    public class Graphics
    {
        public SmoothingMode SmoothingMode; public TextRenderingHint TextRenderingHint;
        public int Fills, Draws, Strings, Rects;
        public void FillPath(Brush b, GraphicsPath p) { if (b == null || p == null) throw new ArgumentNullException(); Fills++; }
        public void DrawPath(Pen pen, GraphicsPath p) { if (pen == null || p == null) throw new ArgumentNullException(); Draws++; }
        public void DrawString(string s, Font f, Brush b, RectangleF r, StringFormat sf) { if (f == null || b == null || sf == null) throw new ArgumentNullException(); Strings++; }
        public void FillRectangle(Brush b, int x, int y, int w, int h) { Rects++; }
    }

    // ---------- events ----------
    public class MouseEventArgs : EventArgs
    {
        public int X, Y; public MouseButtons Button;
        public MouseEventArgs(MouseButtons b, int clicks, int x, int y, int delta) { Button = b; X = x; Y = y; }
    }
    public delegate void MouseEventHandler(object sender, MouseEventArgs e);
    public class PaintEventArgs : EventArgs { public Graphics Graphics; public PaintEventArgs(Graphics g) { Graphics = g; } }
    public delegate void PaintEventHandler(object sender, PaintEventArgs e);

    // ---------- host (lets the test steer dialogs) ----------
    public static class Host
    {
        public static DialogResult MessageBoxResult = DialogResult.OK;
        public static List<string> MessageBoxes = new List<string>();
        public static Color NextColor = Color.Blue;
        public static DialogResult ColorResult = DialogResult.OK;
        public static string NextFile = "";
        public static DialogResult FileResult = DialogResult.OK;
        public static Delegate DialogHook;         // invoked for modal child dialogs: (form)
        public static Delegate AfterShown;         // invoked after the main form's Shown event: ()
        public static MouseButtons ButtonsDown = MouseButtons.None;
        public static string Clipboard = "";
    }

    public static class Application
    {
        public static void EnableVisualStyles() { }
        public static void DoEvents() { }
    }
    public static class Cursors { public static object WaitCursor = "wait"; public static object Default = "default"; }
    public static class Clipboard { public static void SetText(string s) { Host.Clipboard = s; } }
    public static class MessageBox
    {
        public static DialogResult Show(string text) { Host.MessageBoxes.Add(text); return Host.MessageBoxResult; }
        public static DialogResult Show(string text, string caption, object buttons, object icon) { Host.MessageBoxes.Add(caption + ": " + text); return Host.MessageBoxResult; }
    }

    // ---------- controls ----------
    public class ControlCollection : IEnumerable
    {
        public List<Control> Items = new List<Control>();
        public void Add(Control c) { if (c == null) throw new ArgumentNullException("c"); Items.Add(c); }
        public void Remove(Control c) { Items.Remove(c); }
        public int Count { get { return Items.Count; } }
        public IEnumerator GetEnumerator() { return Items.GetEnumerator(); }
    }

    public class FlatButtonAppearance { public int BorderSize; public Color BorderColor; }

    public class Control : IDisposable
    {
        public Point Location; public Size Size; public string Text = "";
        public Font Font; public Color ForeColor, BackColor;
        public bool Visible = true, Enabled = true, TabStop = true;
        public object Tag, Cursor, FlatStyle, TextAlign, Padding;
        public ControlCollection Controls = new ControlCollection();
        public int InvalidateCount = 0;
        protected bool DoubleBuffered { get; set; }
        public int Width { get { return Size.Width; } }
        public int Height { get { return Size.Height; } }
        public static MouseButtons MouseButtons { get { return Host.ButtonsDown; } }

        public event EventHandler Click;
        public event EventHandler MouseLeave;
        public event MouseEventHandler MouseUp;
        public event MouseEventHandler MouseMove;
        public event PaintEventHandler Paint;

        public void Invalidate() { InvalidateCount++; }
        public virtual void Dispose() { }
        public void FireClick() { if (Click != null) Click(this, EventArgs.Empty); }
        public void FireMouseUp(int x, int y, MouseButtons b) { if (MouseUp != null) MouseUp(this, new MouseEventArgs(b, 1, x, y, 0)); }
        public void FireMouseMove(int x, int y) { if (MouseMove != null) MouseMove(this, new MouseEventArgs(MouseButtons.None, 0, x, y, 0)); }
        public void FireMouseLeave() { if (MouseLeave != null) MouseLeave(this, EventArgs.Empty); }
        public void FirePaint(Graphics g) { if (Paint != null) Paint(this, new PaintEventArgs(g)); }
    }

    public class Panel : Control { public object BorderStyle; }
    public class Label : Control { public bool AutoEllipsis; }
    public class Button : Control
    {
        public FlatButtonAppearance FlatAppearance = new FlatButtonAppearance();
        public DialogResult DialogResult;
    }
    public class CheckBox : Control
    {
        bool chk;
        public event EventHandler CheckedChanged;
        public bool Checked { get { return chk; } set { if (chk != value) { chk = value; if (CheckedChanged != null) CheckedChanged(this, EventArgs.Empty); } } }
    }
    public class ComboItems : IEnumerable
    {
        public List<object> List = new List<object>();
        public int Add(object o) { List.Add(o); return List.Count - 1; }
        public void Clear() { List.Clear(); }
        public int Count { get { return List.Count; } }
        public IEnumerator GetEnumerator() { return List.GetEnumerator(); }
    }
    public class ComboBox : Control
    {
        public ComboItems Items = new ComboItems();
        public object DropDownStyle;
        int sel = -1;
        public event EventHandler SelectedIndexChanged;
        public int SelectedIndex
        {
            get { return sel; }
            set { if (value < -1 || value >= Items.Count) throw new ArgumentOutOfRangeException("SelectedIndex"); if (sel != value) { sel = value; if (SelectedIndexChanged != null) SelectedIndexChanged(this, EventArgs.Empty); } }
        }
        public object SelectedItem { get { return (sel >= 0 && sel < Items.Count) ? Items.List[sel] : null; } }
    }
    public class TrackBar : Control
    {
        int v, mn, mx = 10;
        public object TickStyle; public bool AutoSize; public int TickFrequency;
        public event EventHandler ValueChanged;
        public int Minimum { get { return mn; } set { mn = value; } }
        public int Maximum { get { return mx; } set { mx = value; } }
        public int Value
        {
            get { return v; }
            set { if (value < mn || value > mx) throw new ArgumentOutOfRangeException("Value"); if (v != value) { v = value; if (ValueChanged != null) ValueChanged(this, EventArgs.Empty); } }
        }
    }
    public class TextBox : Control
    {
        public bool Multiline, ReadOnly; public object ScrollBars, BorderStyle;
        public void AppendText(string s) { Text += s; }
    }
    public class Form : Control
    {
        public object FormBorderStyle, StartPosition, AcceptButton, CancelButton;
        public bool MaximizeBox, MinimizeBox;
        public DialogResult DialogResult;
        Size client;
        public Size ClientSize { get { return client; } set { client = value; } }
        public event EventHandler Shown;
        public event EventHandler FormClosing;
        public bool IsMain;
        public DialogResult ShowDialog() { return ShowDialog(null); }
        public DialogResult ShowDialog(Form owner)
        {
            Visible = true;
            if (owner == null)
            {
                if (Shown != null) Shown(this, EventArgs.Empty);
                if (Host.AfterShown != null) Host.AfterShown.DynamicInvoke();
                if (FormClosing != null) FormClosing(this, EventArgs.Empty);
                return DialogResult.OK;
            }
            DialogResult = DialogResult.None;
            if (Host.DialogHook != null) Host.DialogHook.DynamicInvoke(this);
            return DialogResult == DialogResult.None ? DialogResult.Cancel : DialogResult;
        }
    }
    public class Timer : IDisposable
    {
        public int Interval; public bool Enabled;
        public event EventHandler Tick;
        public void Start() { Enabled = true; }
        public void Stop() { Enabled = false; }
        public void FireTick() { if (Tick != null) Tick(this, EventArgs.Empty); }
        public void Dispose() { }
    }
    public class ColorDialog
    {
        public bool FullOpen; public Color Color;
        public DialogResult ShowDialog() { if (Host.ColorResult == DialogResult.OK) Color = Host.NextColor; return Host.ColorResult; }
    }
    public class FileDialogBase
    {
        public string Title, Filter, InitialDirectory, FileName = "";
        public DialogResult ShowDialog() { if (Host.FileResult == DialogResult.OK) FileName = Host.NextFile; return Host.FileResult; }
    }
    public class OpenFileDialog : FileDialogBase { }
    public class SaveFileDialog : FileDialogBase { }

    public class ToolStripItem { public Color ForeColor, BackColor; public string Text = ""; public event EventHandler Click; public void FireClick() { if (Click != null) Click(this, EventArgs.Empty); } }
    public class ToolStripMenuItem : ToolStripItem
    {
        public bool CheckOnClick, Checked;
        public ToolStripMenuItem(string text) { Text = text; }
        public void FireUserClick() { if (CheckOnClick) Checked = !Checked; FireClick(); }
    }
    public class ToolStripSeparator : ToolStripItem { }
    public class ToolStripItems : IEnumerable
    {
        public List<object> List = new List<object>();
        public int Add(object o) { List.Add(o); return List.Count - 1; }
        public IEnumerator GetEnumerator() { return List.GetEnumerator(); }
    }
    public class ContextMenuStrip
    {
        public Color ForeColor, BackColor; public ToolStripItems Items = new ToolStripItems(); public int ShowCount;
        public void Show(Control c, int x, int y) { ShowCount++; }
    }
}
