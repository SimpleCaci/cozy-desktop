using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

// A small, rebuildable button. The scripts remain readable beside the program.
static class Launcher {
    [STAThread]
    static int Main(string[] args) {
        try {
            string mode = args.Length == 0 ? "Toggle" : args[0];
            if (args.Length > 1 || !(mode == "Toggle" || mode == "Auto" || mode == "Day" || mode == "Night"))
                throw new ArgumentException("Use Day, Night, Auto, or Toggle.");
            string root = Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, ".."));
            string script = Path.Combine(root, "scripts", "Set-Theme.ps1");
            if (!File.Exists(script)) throw new FileNotFoundException("Keep the program in the bin folder beside scripts.", script);
            var start = new ProcessStartInfo {
                FileName = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), @"WindowsPowerShell\v1.0\powershell.exe"),
                Arguments = "-NoProfile -NonInteractive -STA -ExecutionPolicy Bypass -File \"" + script + "\" -Mode " + mode,
                UseShellExecute = false,
                CreateNoWindow = true,
                RedirectStandardError = true
            };
            using (var process = Process.Start(start)) {
                string error = process.StandardError.ReadToEnd();
                process.WaitForExit();
                if (process.ExitCode != 0) throw new Exception(error);
            }
            return 0;
        } catch (Exception e) {
            MessageBox.Show(e.Message, "Cozy Desktop", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
    }
}
