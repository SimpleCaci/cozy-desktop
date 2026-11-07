using System;
using System.Runtime.InteropServices;

namespace KittyDesktop
{
    [StructLayout(LayoutKind.Sequential)]
    public struct Rect
    {
        public int Left, Top, Right, Bottom;
    }

    // COM methods must retain their native vtable order.
    [ComImport, Guid("B92B56A9-8B55-4E14-9A89-0199BBB6F93B")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IDesktopWallpaper
    {
        void SetWallpaper([MarshalAs(UnmanagedType.LPWStr)] string monitorID,
            [MarshalAs(UnmanagedType.LPWStr)] string wallpaper);
        void GetWallpaper([MarshalAs(UnmanagedType.LPWStr)] string monitorID,
            [MarshalAs(UnmanagedType.LPWStr)] out string wallpaper);
        void GetMonitorDevicePathAt(uint monitorIndex,
            [MarshalAs(UnmanagedType.LPWStr)] out string monitorID);
        void GetMonitorDevicePathCount(out uint count);
        void GetMonitorRECT([MarshalAs(UnmanagedType.LPWStr)] string monitorID, out Rect displayRect);
        void SetBackgroundColor(uint color);
        void GetBackgroundColor(out uint color);
        void SetPosition(int position);
        void GetPosition(out int position);
    }

    public class Monitor
    {
        public string Id, Wallpaper;
        public int X, Y, Width, Height;
    }

    public static class Native
    {
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint msg, IntPtr wParam,
            string lParam, uint flags, uint timeout, out IntPtr result);

        [DllImport("shell32.dll")]
        public static extern void SHChangeNotify(uint eventId, uint flags, IntPtr item1, IntPtr item2);

        [DllImport("shell32.dll")]
        private static extern int SHGetKnownFolderPath(
            [MarshalAs(UnmanagedType.LPStruct)] Guid id, uint flags, IntPtr token, out IntPtr path);

        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern bool SystemParametersInfo(uint action, uint param, IntPtr data, uint flags);

        public static string KnownFolder(string id)
        {
            IntPtr path;
            // KF_FLAG_DONT_VERIFY: let the caller skip optional folders that do not exist.
            int result = SHGetKnownFolderPath(new Guid(id), 0x4000, IntPtr.Zero, out path);
            if (result != 0) Marshal.ThrowExceptionForHR(result);
            try { return Marshal.PtrToStringUni(path); }
            finally { Marshal.FreeCoTaskMem(path); }
        }

        public static IDesktopWallpaper Create()
        {
            return (IDesktopWallpaper)Activator.CreateInstance(Type.GetTypeFromCLSID(
                new Guid("C2CF3110-460E-4FC1-B9D0-8A1C0C9CC4BD")));
        }

        public static Monitor[] Inspect()
        {
            var desktop = Create();
            try
            {
                uint count;
                desktop.GetMonitorDevicePathCount(out count);
                var monitors = new Monitor[count];
                for (uint index = 0; index < count; index++)
                {
                    string id, wallpaper;
                    Rect rect;
                    desktop.GetMonitorDevicePathAt(index, out id);
                    desktop.GetMonitorRECT(id, out rect);
                    desktop.GetWallpaper(id, out wallpaper);
                    monitors[index] = new Monitor
                    {
                        Id = id, Wallpaper = wallpaper, X = rect.Left, Y = rect.Top,
                        Width = rect.Right - rect.Left, Height = rect.Bottom - rect.Top
                    };
                }
                return monitors;
            }
            finally { Marshal.ReleaseComObject(desktop); }
        }

        public static int GetPosition()
        {
            var desktop = Create();
            try
            {
                int position;
                desktop.GetPosition(out position);
                return position;
            }
            finally { Marshal.ReleaseComObject(desktop); }
        }

        public static void Apply(string id, string path)
        {
            var desktop = Create();
            try { desktop.SetWallpaper(id, path); }
            finally { Marshal.ReleaseComObject(desktop); }
        }

        public static void Position(int mode)
        {
            var desktop = Create();
            try { desktop.SetPosition(mode); }
            finally { Marshal.ReleaseComObject(desktop); }
        }

        public static void Refresh()
        {
            IntPtr result;
            SendMessageTimeout(new IntPtr(0xffff), 0x1a, IntPtr.Zero,
                "ImmersiveColorSet", 2, 1000, out result);
            SHChangeNotify(0x08000000, 0, IntPtr.Zero, IntPtr.Zero);
        }
    }
}
