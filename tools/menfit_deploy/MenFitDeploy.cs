// MenFit Deploy - WinForms front end for scripts/distribute_android.ps1.
// Double-click the exe, pick env/notes/groups, press Deploy.
//
// Compiled with the .NET Framework 4 csc.exe (C# 5). See build.ps1 and README.md.

using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;

namespace MenFitDeploy
{
    public sealed class MainForm : Form
    {
        private readonly string _root;
        private readonly DeployConfig _config;
        private readonly ProcessRunner _runner = new ProcessRunner();

        private Label _rootLabel;
        private ComboBox _envBox;
        private TextBox _notesBox;
        private CheckBox _optionalGroupBox;
        private CheckBox _skipBuildBox;
        private RichTextBox _preflightBox;
        private Button _deployButton;
        private Button _cancelButton;
        private RichTextBox _logBox;
        private Label _statusLabel;
        private bool _preflightOk;

        public MainForm(string root)
        {
            _root = root;
            _config = DeployConfig.Load(root);
            BuildLayout();
            PopulateFromConfig();
            RefreshPreflight();
        }

        // ---- layout -------------------------------------------------------

        private void BuildLayout()
        {
            Text = "MenFit Deploy";
            MinimumSize = new Size(720, 640);
            Size = new Size(860, 760);
            StartPosition = FormStartPosition.CenterScreen;
            Font = new Font("Segoe UI", 9f);
            AutoScaleMode = AutoScaleMode.Font;

            TableLayoutPanel grid = new TableLayoutPanel();
            grid.Dock = DockStyle.Fill;
            grid.Padding = new Padding(10);
            grid.ColumnCount = 2;
            grid.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 130));
            grid.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

            int row = 0;
            _rootLabel = new Label();
            _rootLabel.Text = _root;
            _rootLabel.AutoEllipsis = true;
            _rootLabel.Dock = DockStyle.Fill;
            _rootLabel.TextAlign = ContentAlignment.MiddleLeft;
            AddRow(grid, row++, "Repo root", _rootLabel, 26);

            _envBox = new ComboBox();
            _envBox.DropDownStyle = ComboBoxStyle.DropDownList;
            _envBox.Width = 200;
            _envBox.SelectedIndexChanged += delegate { RefreshPreflight(); };
            AddRow(grid, row++, "Environment", _envBox, 30);

            _notesBox = new TextBox();
            _notesBox.Multiline = true;
            _notesBox.ScrollBars = ScrollBars.Vertical;
            _notesBox.Dock = DockStyle.Fill;
            AddRow(grid, row++, "Release notes", _notesBox, 70);

            FlowLayoutPanel options = new FlowLayoutPanel();
            options.FlowDirection = FlowDirection.TopDown;
            options.Dock = DockStyle.Fill;
            options.AutoSize = true;
            _optionalGroupBox = new CheckBox();
            _optionalGroupBox.AutoSize = true;
            _optionalGroupBox.CheckedChanged += delegate { UpdateStatusLine(); };
            _skipBuildBox = new CheckBox();
            _skipBuildBox.Text = "Skip build (re-upload last APK)";
            _skipBuildBox.AutoSize = true;
            _skipBuildBox.CheckedChanged += delegate { UpdateStatusLine(); };
            options.Controls.Add(_optionalGroupBox);
            options.Controls.Add(_skipBuildBox);
            AddRow(grid, row++, "Options", options, 56);

            _preflightBox = new RichTextBox();
            _preflightBox.ReadOnly = true;
            _preflightBox.BackColor = SystemColors.Control;
            _preflightBox.BorderStyle = BorderStyle.FixedSingle;
            _preflightBox.Dock = DockStyle.Fill;
            _preflightBox.Font = new Font("Consolas", 9f);
            _preflightBox.DetectUrls = false;
            AddRow(grid, row++, "Preflight", _preflightBox, 150);

            FlowLayoutPanel buttons = new FlowLayoutPanel();
            buttons.FlowDirection = FlowDirection.LeftToRight;
            buttons.Dock = DockStyle.Fill;
            _deployButton = new Button();
            _deployButton.Text = "Deploy";
            _deployButton.Width = 110;
            _deployButton.Height = 30;
            _deployButton.Enabled = false;
            _deployButton.Click += delegate { OnDeployClicked(); };
            _cancelButton = new Button();
            _cancelButton.Text = "Cancel";
            _cancelButton.Width = 110;
            _cancelButton.Height = 30;
            _cancelButton.Enabled = false;
            _cancelButton.Click += delegate { OnCancelClicked(); };
            Button refresh = new Button();
            refresh.Text = "Re-check";
            refresh.Width = 110;
            refresh.Height = 30;
            refresh.Click += delegate { RefreshPreflight(); };
            _statusLabel = new Label();
            _statusLabel.AutoSize = true;
            _statusLabel.Margin = new Padding(12, 8, 0, 0);
            buttons.Controls.Add(_deployButton);
            buttons.Controls.Add(_cancelButton);
            buttons.Controls.Add(refresh);
            buttons.Controls.Add(_statusLabel);
            AddRow(grid, row++, "", buttons, 40);

            _logBox = new RichTextBox();
            _logBox.ReadOnly = true;
            _logBox.BackColor = Color.White;
            _logBox.Dock = DockStyle.Fill;
            _logBox.Font = new Font("Consolas", 9f);
            _logBox.DetectUrls = false;
            _logBox.WordWrap = false;
            _logBox.ScrollBars = RichTextBoxScrollBars.Both;
            grid.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            Label logLabel = MakeLabel("Log");
            grid.Controls.Add(logLabel, 0, row);
            grid.Controls.Add(_logBox, 1, row);
            row++;

            grid.RowCount = row;
            Controls.Add(grid);
            FormClosing += OnFormClosing;
        }

        private static Label MakeLabel(string text)
        {
            Label label = new Label();
            label.Text = text;
            label.AutoSize = false;
            label.Dock = DockStyle.Fill;
            label.TextAlign = ContentAlignment.TopLeft;
            label.Padding = new Padding(0, 6, 0, 0);
            return label;
        }

        private static void AddRow(TableLayoutPanel grid, int row, string caption, Control control, int height)
        {
            grid.RowStyles.Add(new RowStyle(SizeType.Absolute, height));
            grid.Controls.Add(MakeLabel(caption), 0, row);
            grid.Controls.Add(control, 1, row);
        }

        // ---- state ---------------------------------------------------------

        private void PopulateFromConfig()
        {
            List<string> envs = EnvCatalog.List(_root);
            foreach (string env in envs) _envBox.Items.Add(env);
            int idx = _envBox.Items.IndexOf(_config.Env);
            if (idx < 0 && _envBox.Items.Count > 0) idx = 0;
            if (idx >= 0) _envBox.SelectedIndex = idx;

            string mainGroups = _config.GroupsFor(false);
            string optional = string.IsNullOrEmpty(_config.OptionalTesterGroups) ? "(none configured)" : _config.OptionalTesterGroups;
            _optionalGroupBox.Text = string.Format("Also send to '{0}' group (unchecked = '{1}' only)", optional, mainGroups);
            _optionalGroupBox.Enabled = !string.IsNullOrEmpty(_config.OptionalTesterGroups);

            _notesBox.Text = GitInfo.DefaultNotes(_root, SelectedEnv());
            if (_config.LoadError != null) AppendLog(_config.LoadError, Color.DarkRed);
        }

        private string SelectedEnv()
        {
            return _envBox.SelectedItem == null ? "" : _envBox.SelectedItem.ToString();
        }

        private string SelectedGroups()
        {
            return _config.GroupsFor(_optionalGroupBox.Checked);
        }

        private void RefreshPreflight()
        {
            List<PreflightItem> items = PreflightChecker.Run(_root, SelectedEnv(), _config);
            _preflightBox.Clear();
            foreach (PreflightItem item in items)
            {
                string mark = item.Passed ? "[OK]  " : (item.Blocking ? "[FAIL]" : "[WARN]");
                Color color = item.Passed ? Color.DarkGreen : (item.Blocking ? Color.DarkRed : Color.DarkOrange);
                AppendColored(_preflightBox, mark + " " + item.Label + Environment.NewLine, color);
                if (!string.IsNullOrEmpty(item.Detail))
                {
                    AppendColored(_preflightBox, "       " + item.Detail + Environment.NewLine, Color.DimGray);
                }
            }
            _preflightOk = PreflightChecker.AllBlockingPassed(items);
            _deployButton.Enabled = _preflightOk && !_runner.IsRunning;
            UpdateStatusLine();
        }

        private void UpdateStatusLine()
        {
            if (_runner.IsRunning) return;
            _statusLabel.ForeColor = _preflightOk ? Color.DarkGreen : Color.DarkRed;
            _statusLabel.Text = _preflightOk
                ? string.Format("Ready: {0} -> groups {1}{2}", SelectedEnv(), SelectedGroups(), _skipBuildBox.Checked ? " (skip build)" : "")
                : "Blocked: fix the [FAIL] items above.";
        }

        private void SetBusy(bool busy)
        {
            _envBox.Enabled = !busy;
            _notesBox.Enabled = !busy;
            _optionalGroupBox.Enabled = !busy && !string.IsNullOrEmpty(_config.OptionalTesterGroups);
            _skipBuildBox.Enabled = !busy;
            _deployButton.Enabled = !busy && _preflightOk;
            _cancelButton.Enabled = busy;
            UseWaitCursor = busy;
        }

        // ---- deploy --------------------------------------------------------

        private void OnDeployClicked()
        {
            if (_runner.IsRunning) return;
            string env = SelectedEnv();
            string groups = SelectedGroups();
            string notes = DeployArguments.SanitiseNotes(_notesBox.Text);
            bool skipBuild = _skipBuildBox.Checked;

            string summary = string.Format(
                "Environment: {0}\nGroups: {1}\nSkip build: {2}\nRelease notes: {3}\n\n{4}",
                env, groups, skipBuild ? "yes (re-upload last APK)" : "no",
                notes.Length == 0 ? "(script default)" : notes,
                skipBuild ? "Upload the last built APK to Firebase App Distribution?"
                          : "Build the release APK and upload it to Firebase App Distribution?");
            DialogResult answer = MessageBox.Show(this, summary, "Confirm deploy",
                MessageBoxButtons.OKCancel, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2);
            if (answer != DialogResult.OK) return;

            string arguments = DeployArguments.Build(_root, env, groups, notes, skipBuild);
            _logBox.Clear();
            AppendLog(DeployArguments.PowerShellExe + " " + arguments, Color.DarkBlue);
            AppendLog("Working directory: " + _root, Color.DarkBlue);
            AppendLog("", Color.Black);

            SetBusy(true);
            _statusLabel.ForeColor = Color.DarkBlue;
            _statusLabel.Text = "Running... (started " + DateTime.Now.ToString("HH:mm:ss") + ")";
            try
            {
                _runner.Start(DeployArguments.PowerShellExe, arguments, _root, OnProcessLine, OnProcessExit);
            }
            catch (Exception ex)
            {
                AppendLog("Failed to start powershell.exe: " + ex.Message, Color.Red);
                SetBusy(false);
                UpdateStatusLine();
            }
        }

        private void OnCancelClicked()
        {
            if (!_runner.IsRunning) return;
            DialogResult answer = MessageBox.Show(this,
                "Kill the running build/upload? A half-finished upload leaves nothing behind in Firebase; a killed Gradle build may need a re-run.",
                "Cancel deploy", MessageBoxButtons.YesNo, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button2);
            if (answer != DialogResult.Yes) return;
            AppendLog("Cancelling (taskkill /T /F)...", Color.DarkOrange);
            _runner.Cancel();
        }

        private void OnProcessLine(string line, bool isStderr)
        {
            if (IsDisposed) return;
            try
            {
                BeginInvoke(new Action(delegate { AppendLog(line, isStderr ? Color.DarkRed : Color.Black); }));
            }
            catch (Exception) { /* form closed mid-run */ }
        }

        private void OnProcessExit(int exitCode)
        {
            if (IsDisposed) return;
            try
            {
                BeginInvoke(new Action(delegate
                {
                    bool ok = exitCode == 0;
                    AppendLog("", Color.Black);
                    AppendLog(string.Format("Exit code {0} - {1}", exitCode, ok ? "SUCCESS" : "FAILED"), ok ? Color.Green : Color.Red);
                    _statusLabel.ForeColor = ok ? Color.Green : Color.Red;
                    _statusLabel.Text = ok ? "Done: testers have been emailed." : string.Format("Failed with exit code {0}.", exitCode);
                    SetBusy(false);
                }));
            }
            catch (Exception) { }
        }

        private void OnFormClosing(object sender, FormClosingEventArgs e)
        {
            if (!_runner.IsRunning) return;
            DialogResult answer = MessageBox.Show(this, "A deploy is still running. Kill it and exit?",
                "MenFit Deploy", MessageBoxButtons.YesNo, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button2);
            if (answer == DialogResult.Yes) _runner.Cancel();
            else e.Cancel = true;
        }

        // ---- log helpers ---------------------------------------------------

        private void AppendLog(string line, Color color)
        {
            AppendColored(_logBox, line + Environment.NewLine, color);
            _logBox.SelectionStart = _logBox.TextLength;
            _logBox.ScrollToCaret();
        }

        private static void AppendColored(RichTextBox box, string text, Color color)
        {
            box.SelectionStart = box.TextLength;
            box.SelectionLength = 0;
            box.SelectionColor = color;
            box.AppendText(text);
            box.SelectionColor = box.ForeColor;
        }
    }

    /// <summary>--dry-run: resolve everything, print it, touch nothing.</summary>
    public static class DryRun
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool AttachConsole(int dwProcessId);
        private const int AttachParentProcess = -1;

        public static int Execute(string[] args, string root)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("MenFit Deploy dry run " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
            sb.AppendLine("exe:  " + Application.ExecutablePath);
            sb.AppendLine("root: " + (root ?? "(not found)"));
            int exitCode = 0;
            if (root == null)
            {
                sb.AppendLine("No repo root found: walk up from the exe directory or pass --repo <path>.");
                exitCode = 1;
            }
            else
            {
                DeployConfig cfg = DeployConfig.Load(root);
                if (cfg.LoadError != null) sb.AppendLine("config error: " + cfg.LoadError);
                sb.AppendLine("firebaseAppId:        " + cfg.FirebaseAppId);
                sb.AppendLine("testerGroups:         " + cfg.TesterGroups);
                sb.AppendLine("optionalTesterGroups: " + cfg.OptionalTesterGroups);
                sb.AppendLine("default env:          " + cfg.Env);
                sb.AppendLine("envs available:       " + string.Join(", ", EnvCatalog.List(root).ToArray()));
                sb.AppendLine("groups (checkbox off): " + cfg.GroupsFor(false));
                sb.AppendLine("groups (checkbox on):  " + cfg.GroupsFor(true));
                string notes = GitInfo.DefaultNotes(root, cfg.Env);
                sb.AppendLine("default notes:        " + notes);
                sb.AppendLine();
                sb.AppendLine("preflight:");
                foreach (PreflightItem item in PreflightChecker.Run(root, cfg.Env, cfg))
                {
                    sb.AppendLine(string.Format("  {0} {1}{2}", item.Passed ? "[OK]  " : (item.Blocking ? "[FAIL]" : "[WARN]"),
                        item.Label, string.IsNullOrEmpty(item.Detail) ? "" : " -- " + item.Detail));
                }
                sb.AppendLine();
                sb.AppendLine("command (checkbox off):");
                sb.AppendLine("  " + DeployArguments.PowerShellExe + " " + DeployArguments.Build(root, cfg.Env, cfg.GroupsFor(false), notes, false));
                sb.AppendLine("command (checkbox on, skip build):");
                sb.AppendLine("  " + DeployArguments.PowerShellExe + " " + DeployArguments.Build(root, cfg.Env, cfg.GroupsFor(true), notes, true));
            }

            string text = sb.ToString();
            string outFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "dry-run.txt");
            try { File.WriteAllText(outFile, text, new UTF8Encoding(false)); } catch (Exception) { }
            try
            {
                if (AttachConsole(AttachParentProcess))
                {
                    using (StreamWriter w = new StreamWriter(Console.OpenStandardOutput()))
                    {
                        w.WriteLine();
                        w.Write(text);
                        w.WriteLine("written to " + outFile);
                    }
                }
            }
            catch (Exception) { }
            return exitCode;
        }
    }

    public static class Program
    {
        [STAThread]
        public static int Main(string[] args)
        {
            bool dryRun = Array.Exists(args, delegate(string a) { return string.Equals(a, "--dry-run", StringComparison.OrdinalIgnoreCase); });
            string root = RepoLocator.Resolve(args);
            if (dryRun) return DryRun.Execute(args, root);

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            if (root == null)
            {
                MessageBox.Show("Could not find the MenFit repo (a folder with pubspec.yaml and scripts\\distribute_android.ps1) above this exe. Please pick the repo root.",
                    "MenFit Deploy", MessageBoxButtons.OK, MessageBoxIcon.Information);
                using (FolderBrowserDialog dialog = new FolderBrowserDialog())
                {
                    dialog.Description = "Select the MenFit repository root";
                    dialog.ShowNewFolderButton = false;
                    if (dialog.ShowDialog() != DialogResult.OK) return 2;
                    root = RepoLocator.IsRepoRoot(dialog.SelectedPath) ? dialog.SelectedPath : RepoLocator.WalkUp(dialog.SelectedPath);
                }
                if (root == null)
                {
                    MessageBox.Show("That folder is not the MenFit repo (no pubspec.yaml + scripts\\distribute_android.ps1).",
                        "MenFit Deploy", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return 2;
                }
            }

            Application.Run(new MainForm(root));
            return 0;
        }
    }
}
