using System;
using System.Runtime.InteropServices;
namespace KittyDesktop {
 [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left, Top, Right, Bottom; }
 [ComImport, Guid("B92B56A9-8B55-4E14-9A89-0199BBB6F93B"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
 public interface IDesktopWallpaper {
   void SetWallpaper([MarshalAs(UnmanagedType.LPWStr)] string monitorID,[MarshalAs(UnmanagedType.LPWStr)] string wallpaper);
   void GetWallpaper([MarshalAs(UnmanagedType.LPWStr)] string monitorID,[MarshalAs(UnmanagedType.LPWStr)] out string wallpaper);
   void GetMonitorDevicePathAt(uint monitorIndex,[MarshalAs(UnmanagedType.LPWStr)] out string monitorID);
   void GetMonitorDevicePathCount(out uint count);
   void GetMonitorRECT([MarshalAs(UnmanagedType.LPWStr)] string monitorID,out Rect displayRect);
   void SetBackgroundColor(uint color);
   void GetBackgroundColor(out uint color);
   void SetPosition(int position);
   void GetPosition(out int position);
 }
 public class Monitor { public string Id, Wallpaper; public int X,Y,Width,Height; }
 public static class Native {
   [DllImport("user32.dll",CharSet=CharSet.Unicode,SetLastError=true)] public static extern IntPtr SendMessageTimeout(IntPtr hWnd,uint msg,IntPtr wParam,string lParam,uint flags,uint timeout,out IntPtr result);
   [DllImport("shell32.dll")] public static extern void SHChangeNotify(uint eventId,uint flags,IntPtr item1,IntPtr item2);
   [DllImport("shell32.dll")] private static extern int SHGetKnownFolderPath([MarshalAs(UnmanagedType.LPStruct)] Guid id,uint flags,IntPtr token,out IntPtr path); public static string KnownFolder(string id){IntPtr path;int hr=SHGetKnownFolderPath(new Guid(id),0x4000,IntPtr.Zero,out path);if(hr!=0)Marshal.ThrowExceptionForHR(hr);try{return Marshal.PtrToStringUni(path);}finally{Marshal.FreeCoTaskMem(path);}} public static IDesktopWallpaper Create() {return (IDesktopWallpaper)Activator.CreateInstance(Type.GetTypeFromCLSID(new Guid("C2CF3110-460E-4FC1-B9D0-8A1C0C9CC4BD")));}
   public static Monitor[] Inspect() {var d=Create();try{ uint n;d.GetMonitorDevicePathCount(out n);var a=new Monitor[n];for(uint i=0;i<n;i++){string id,p;Rect r;d.GetMonitorDevicePathAt(i,out id);d.GetMonitorRECT(id,out r);d.GetWallpaper(id,out p);a[i]=new Monitor{Id=id,Wallpaper=p,X=r.Left,Y=r.Top,Width=r.Right-r.Left,Height=r.Bottom-r.Top};}return a;}finally{Marshal.ReleaseComObject(d);}}
   [DllImport("user32.dll",CharSet=CharSet.Unicode,SetLastError=true)] public static extern bool SystemParametersInfo(uint action,uint param,IntPtr data,uint flags); public static int GetPosition(){var d=Create();try{int p;d.GetPosition(out p);return p;}finally{Marshal.ReleaseComObject(d);}} public static void Apply(string id,string path){var d=Create();try{d.SetWallpaper(id,path);}finally{Marshal.ReleaseComObject(d);}} public static void Position(int mode){var d=Create();try{d.SetPosition(mode);}finally{Marshal.ReleaseComObject(d);}} public static void Refresh(){IntPtr result;SendMessageTimeout(new IntPtr(0xffff),0x1a,IntPtr.Zero,"ImmersiveColorSet",2,1000,out result);SHChangeNotify(0x08000000,0,IntPtr.Zero,IntPtr.Zero);}
 }
}
