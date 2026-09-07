// FemFit Deploy - non-UI core: repo discovery, config, preflight, git info,
// argument building and the child-process runner.
//
// Compiled with the .NET Framework 4 csc.exe (C# 5): no string interpolation,
// no ?., no nameof, no expression-bodied members. See build.ps1.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Threading;
using System.Web.Script.Serialization;

namespace FemFitDeploy
{
    /// <summary>Finds the repository root that owns scripts/distribute_android.ps1.</summary>
    public static class RepoLocator
    {
        public const string ScriptRelativePath = "scripts\\distribute_android.ps1";

        public static bool IsRepoRoot(string dir)
        {
            if (string.IsNullOrEmpty(dir) || !Directory.Exists(dir)) return false;
            return File.Exists(Path.Combine(dir, "pubspec.yaml"))
                && File.Exists(Path.Combine(dir, ScriptRelativePath));
        }

        /// <summary>Walks up from <paramref name="startDir"/> until a repo root is found; null if none.</summary>
        public static string WalkUp(string startDir)
        {
            if (string.IsNullOrEmpty(startDir)) return null;
            DirectoryInfo dir;
            try { dir = new DirectoryInfo(startDir); }
            catch (Exception) { return null; }
            while (dir != null)
            {
                if (IsRepoRoot(dir.FullName)) return dir.FullName;
                dir = dir.Parent;
            }
            return null;
        }

        /// <summary>Returns the value after a "--repo" argument, or null.</summary>
        public static string FromArgs(string[] args)
        {
            if (args == null) return null;
            for (int i = 0; i < args.Length - 1; i++)
            {
                if (string.Equals(args[i], "--repo", StringComparison.OrdinalIgnoreCase))
                {
                    return args[i + 1];
                }
            }
            return null;
        }

        /// <summary>--repo argument first, then walk up from the exe directory. Null if neither works.</summary>
        public static string Resolve(string[] args)
        {
            string fromArgs = FromArgs(args);
            if (fromArgs != null)
            {
                string full;
                try { full = Path.GetFullPath(fromArgs); }
                catch (Exception) { full = null; }
                if (IsRepoRoot(full)) return full;
                // Allow --repo to point somewhere inside the repo as well.
                string up = WalkUp(full);
                if (up != null) return up;
            }
            return WalkUp(AppDomain.CurrentDomain.BaseDirectory);
        }
    }

    /// <summary>The plain-string fields of distribution/android.json. Nothing secret lives there.</summary>
    public sealed class DeployConfig
    {
        public const string RelativePath = "distribution\\android.json";

        public string FirebaseAppId = "";
        public string TesterGroups = "";
        public string OptionalTesterGroups = "";
        public string Env = "";
        public string LoadError = null;

        public static DeployConfig Load(string root)
        {
            DeployConfig cfg = new DeployConfig();
            string path = Path.Combine(root, RelativePath);
            try
            {
                string json = File.ReadAllText(path);
                JavaScriptSerializer serializer = new JavaScriptSerializer();
                Dictionary<string, object> map = serializer.Deserialize<Dictionary<string, object>>(json);
                cfg.FirebaseAppId = ReadString(map, "firebaseAppId");
                cfg.TesterGroups = ReadString(map, "testerGroups");
                cfg.OptionalTesterGroups = ReadString(map, "optionalTesterGroups");
                cfg.Env = ReadString(map, "env");
            }
            catch (Exception ex)
            {
                cfg.LoadError = string.Format("Could not read {0}: {1}", path, ex.Message);
            }
            return cfg;
        }

        private static string ReadString(Dictionary<string, object> map, string key)
        {
            object value;
            if (map != null && map.TryGetValue(key, out value) && value != null)
            {
                return value.ToString().Trim();
            }
            return "";
        }

        /// <summary>Comma-separated Firebase group aliases for the CLI's --groups flag.</summary>
        public string GroupsFor(bool includeOptional)
        {
            List<string> groups = new List<string>();
            AppendGroups(groups, TesterGroups);
            if (includeOptional) AppendGroups(groups, OptionalTesterGroups);
            return string.Join(",", groups.ToArray());
        }

        private static void AppendGroups(List<string> target, string csv)
        {
            if (string.IsNullOrEmpty(csv)) return;
            foreach (string raw in csv.Split(','))
            {
                string g = raw.Trim();
                if (g.Length > 0 && !target.Contains(g)) target.Add(g);
            }
        }
    }

    /// <summary>Lists env/*.json names (without .json), excluding the *.secrets.json overlays.</summary>
    public static class EnvCatalog
    {
        public static List<string> List(string root)
        {
            List<string> names = new List<string>();
            string envDir = Path.Combine(root, "env");
            if (!Directory.Exists(envDir)) return names;
            foreach (string file in Directory.GetFiles(envDir, "*.json"))
            {
                string name = Path.GetFileName(file);
                if (name.EndsWith(".secrets.json", StringComparison.OrdinalIgnoreCase)) continue;
                names.Add(Path.GetFileNameWithoutExtension(name));
            }
            names.Sort(StringComparer.OrdinalIgnoreCase);
            return names;
        }
    }

    public sealed class PreflightItem
    {
        public string Label;
        public bool Passed;
        public bool Blocking;
        public string Detail;

        public PreflightItem(string label, bool passed, bool blocking, string detail)
        {
            Label = label; Passed = passed; Blocking = blocking; Detail = detail;
        }
    }

    /// <summary>Mirrors the refusals in scripts/distribute_android.ps1 so the GUI can say no before the script does.</summary>
    public static class PreflightChecker
    {
        public static List<PreflightItem> Run(string root, string env, DeployConfig cfg)
        {
            List<PreflightItem> items = new List<PreflightItem>();

            string keyProps = Path.Combine(root, "android\\key.properties");
            items.Add(new PreflightItem("android/key.properties present (release signing)",
                File.Exists(keyProps), true,
                File.Exists(keyProps) ? "" : "Run scripts/create_upload_keystore.ps1 first; the build would be debug-signed."));

            string firebase = PathSearch.Find(new string[] { "firebase.cmd", "firebase.exe", "firebase" });
            items.Add(new PreflightItem("firebase CLI on PATH", firebase != null, true,
                firebase != null ? firebase : "npm install -g firebase-tools ; firebase login"));

            string flutter = PathSearch.Find(new string[] { "flutter.bat", "flutter.exe", "flutter" });
            items.Add(new PreflightItem("flutter on PATH", flutter != null, true,
                flutter != null ? flutter : "Flutter SDK bin directory is not on PATH."));

            bool hasAppId = !string.IsNullOrEmpty(cfg.FirebaseAppId);
            items.Add(new PreflightItem("firebaseAppId set in distribution/android.json", hasAppId, true,
                hasAppId ? cfg.FirebaseAppId : (cfg.LoadError ?? "Fill in firebaseAppId (Firebase console > Project settings > Your apps).")));

            bool hasGroups = cfg.GroupsFor(false).Length > 0;
            items.Add(new PreflightItem("testerGroups set in distribution/android.json", hasGroups, true,
                hasGroups ? cfg.GroupsFor(false) : "testerGroups is empty; nobody would receive the build."));

            if (!string.IsNullOrEmpty(env))
            {
                string envFile = Path.Combine(root, "env\\" + env + ".json");
                items.Add(new PreflightItem(string.Format("env/{0}.json present", env), File.Exists(envFile), true,
                    File.Exists(envFile) ? "" : "The script refuses to build without it."));

                string secretsFile = Path.Combine(root, "env\\" + env + ".secrets.json");
                items.Add(new PreflightItem(string.Format("env/{0}.secrets.json present (optional)", env),
                    File.Exists(secretsFile), false,
                    File.Exists(secretsFile)
                        ? "Overlay will be applied (contents are never read by this tool)."
                        : "Warning only: this build will use Open Food Facts only (no FatSecret) and route suggestions will show their setup card."));
            }

            return items;
        }

        public static bool AllBlockingPassed(List<PreflightItem> items)
        {
            foreach (PreflightItem item in items)
            {
                if (item.Blocking && !item.Passed) return false;
            }
            return true;
        }
    }

    public static class PathSearch
    {
        /// <summary>Returns the full path of the first candidate name found in any PATH directory, or null.</summary>
        public static string Find(string[] candidateNames)
        {
            string pathVar = Environment.GetEnvironmentVariable("PATH") ?? "";
            foreach (string rawDir in pathVar.Split(';'))
            {
                string dir = rawDir.Trim().Trim('"');
                if (dir.Length == 0) continue;
                foreach (string name in candidateNames)
                {
                    string candidate;
                    try { candidate = Path.Combine(dir, name); }
                    catch (Exception) { continue; }
                    if (File.Exists(candidate)) return candidate;
                }
            }
            return null;
        }
    }

    /// <summary>Best-effort git lookups for the default release notes. Never throws.</summary>
    public static class GitInfo
    {
        public static string DefaultNotes(string root, string env)
        {
            string sha = Run(root, "rev-parse --short HEAD");
            string subject = Run(root, "log -1 --pretty=%s");
            if (sha == null)
            {
                return string.Format("{0} build", env);
            }
            if (string.IsNullOrEmpty(subject)) subject = "(no subject)";
            return string.Format("{0} build {1} - {2}", env, sha, subject);
        }

        private static string Run(string root, string arguments)
        {
            try
            {
                ProcessStartInfo psi = new ProcessStartInfo("git", arguments);
                psi.WorkingDirectory = root;
                psi.UseShellExecute = false;
                psi.RedirectStandardOutput = true;
                psi.RedirectStandardError = true;
                psi.CreateNoWindow = true;
                using (Process p = Process.Start(psi))
                {
                    string output = p.StandardOutput.ReadToEnd();
                    p.StandardError.ReadToEnd();
                    if (!p.WaitForExit(10000)) { try { p.Kill(); } catch (Exception) { } return null; }
                    if (p.ExitCode != 0) return null;
                    return output.Trim();
                }
            }
            catch (Exception)
            {
                return null; // git missing or not a repo
            }
        }
    }

    /// <summary>Builds the exact powershell.exe argument string; the script is never reimplemented here.</summary>
    public static class DeployArguments
    {
        public const string PowerShellExe = "powershell.exe";

        public static string SanitiseNotes(string notes)
        {
            if (notes == null) return "";
            string s = notes.Replace("\"", "'").Replace("\r\n", " ").Replace('\n', ' ').Replace('\r', ' ').Replace('\t', ' ');
            while (s.Contains("  ")) s = s.Replace("  ", " ");
            return s.Trim();
        }

        public static string SanitiseToken(string value)
        {
            // env names and group aliases: strip anything that could break out of the argument.
            if (value == null) return "";
            StringBuilder sb = new StringBuilder();
            foreach (char c in value)
            {
                if (char.IsLetterOrDigit(c) || c == '-' || c == '_' || c == ',' || c == '.') sb.Append(c);
            }
            return sb.ToString();
        }

        public static string Build(string root, string env, string groups, string notes, bool skipBuild)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("-NoProfile -ExecutionPolicy Bypass -File \"");
            sb.Append(Path.Combine(root, RepoLocator.ScriptRelativePath));
            sb.Append("\"");
            sb.Append(" -Env ").Append(SanitiseToken(env));
            sb.Append(" -Groups \"").Append(SanitiseToken(groups)).Append("\"");
            sb.Append(" -Notes \"").Append(SanitiseNotes(notes)).Append("\"");
            if (skipBuild) sb.Append(" -SkipBuild");
            return sb.ToString();
        }
    }

    /// <summary>Runs one child process with redirected stdout/stderr; callbacks fire on worker threads.</summary>
    public sealed class ProcessRunner
    {
        private Process _process;
        private readonly object _lock = new object();

        public bool IsRunning
        {
            get
            {
                lock (_lock)
                {
                    if (_process == null) return false;
                    try { return !_process.HasExited; }
                    catch (Exception) { return false; }
                }
            }
        }

        /// <param name="onLine">(line, isStderr) - called from a background thread.</param>
        /// <param name="onExit">exit code - called from a background thread after all output is drained.</param>
        public void Start(string fileName, string arguments, string workingDirectory,
            Action<string, bool> onLine, Action<int> onExit)
        {
            ProcessStartInfo psi = new ProcessStartInfo(fileName, arguments);
            psi.WorkingDirectory = workingDirectory;
            psi.UseShellExecute = false;
            psi.RedirectStandardOutput = true;
            psi.RedirectStandardError = true;
            psi.RedirectStandardInput = true;
            psi.CreateNoWindow = true;
            psi.StandardOutputEncoding = Encoding.UTF8;
            psi.StandardErrorEncoding = Encoding.UTF8;

            Process p = new Process();
            p.StartInfo = psi;
            p.OutputDataReceived += delegate(object sender, DataReceivedEventArgs e)
            {
                if (e.Data != null) onLine(e.Data, false);
            };
            p.ErrorDataReceived += delegate(object sender, DataReceivedEventArgs e)
            {
                if (e.Data != null) onLine(e.Data, true);
            };

            lock (_lock) { _process = p; }
            p.Start();
            p.StandardInput.Close(); // nothing will ever answer a prompt; make reads fail fast
            p.BeginOutputReadLine();
            p.BeginErrorReadLine();

            Thread waiter = new Thread(delegate()
            {
                int code;
                try
                {
                    p.WaitForExit(); // no timeout => also waits for async output to drain
                    code = p.ExitCode;
                }
                catch (Exception)
                {
                    code = -1;
                }
                lock (_lock) { if (_process == p) _process = null; }
                onExit(code);
            });
            waiter.IsBackground = true;
            waiter.Start();
        }

        /// <summary>Kills the whole tree (powershell -> flutter/gradle/firebase) via taskkill.</summary>
        public void Cancel()
        {
            int pid;
            lock (_lock)
            {
                if (_process == null) return;
                try { pid = _process.Id; } catch (Exception) { return; }
            }
            try
            {
                ProcessStartInfo psi = new ProcessStartInfo("taskkill", string.Format("/T /F /PID {0}", pid));
                psi.UseShellExecute = false;
                psi.CreateNoWindow = true;
                using (Process killer = Process.Start(psi)) { killer.WaitForExit(15000); }
            }
            catch (Exception)
            {
                try { lock (_lock) { if (_process != null) _process.Kill(); } } catch (Exception) { }
            }
        }
    }
}
