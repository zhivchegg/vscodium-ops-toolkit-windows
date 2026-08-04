#requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$bundleDir = $PSScriptRoot

function MkLnk($ShortcutDir, $Name, $Target, $Icon) {
    $ws = New-Object -ComObject WScript.Shell
    $lnk = $ws.CreateShortcut((Join-Path $ShortcutDir $Name))
    $lnk.TargetPath = $Target
    $lnk.WorkingDirectory = $bundleDir
    $lnk.IconLocation = $Icon
    $lnk.WindowStyle = 1
    $lnk.Save()
}

function Create-Shortcuts($ShortcutDir) {
    if (-not (Test-Path $ShortcutDir)) {
        New-Item -ItemType Directory -Path $ShortcutDir -Force | Out-Null
    }
    MkLnk $ShortcutDir "VSCodium Ops Toolkit.lnk" (Join-Path $bundleDir "start-vscodium.cmd") (Join-Path $bundleDir "VSCodium.exe,0")
    MkLnk $ShortcutDir "MSYS2 Bash.lnk" (Join-Path $bundleDir "msys2-bash.cmd") (Join-Path $bundleDir "msys64\msys2.ico,0")
    MkLnk $ShortcutDir "Configure Runtime.lnk" (Join-Path $bundleDir "configure-runtime.cmd") (Join-Path $bundleDir "VSCodium.exe,0")
}

function Show-ShortcutForm {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "VSCodium Ops Toolkit - Shortcut Setup"
    $form.Size = New-Object System.Drawing.Size(620, 260)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Create shortcuts where?"
    $label.Location = New-Object System.Drawing.Point(20, 20)
    $label.Size = New-Object System.Drawing.Size(560, 24)
    $label.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($label)

    $txtDir = New-Object System.Windows.Forms.TextBox
    $txtDir.Location = New-Object System.Drawing.Point(20, 54)
    $txtDir.Size = New-Object System.Drawing.Size(450, 24)
    $txtDir.Text = $bundleDir
    $form.Controls.Add($txtDir)

    $btnBrowse = New-Object System.Windows.Forms.Button
    $btnBrowse.Text = "Browse..."
    $btnBrowse.Location = New-Object System.Drawing.Point(480, 54)
    $btnBrowse.Size = New-Object System.Drawing.Size(100, 24)
    $btnBrowse.Add_Click({
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg.Description = "Select shortcut folder"
        $dlg.RootFolder = "MyComputer"
        if ($dlg.ShowDialog() -eq "OK") { $txtDir.Text = $dlg.SelectedPath }
    })
    $form.Controls.Add($btnBrowse)

    $hint = New-Object System.Windows.Forms.Label
    $hint.Text = "Creates .lnk shortcuts (Windows does not allow pinning .cmd targets to taskbar)"
    $hint.Location = New-Object System.Drawing.Point(20, 90)
    $hint.Size = New-Object System.Drawing.Size(560, 24)
    $hint.ForeColor = [System.Drawing.Color]::DimGray
    $form.Controls.Add($hint)

    $btnCreate = New-Object System.Windows.Forms.Button
    $btnCreate.Text = "Create"
    $btnCreate.Location = New-Object System.Drawing.Point(20, 140)
    $btnCreate.Size = New-Object System.Drawing.Size(120, 30)
    $btnCreate.Add_Click({
        try {
            $dir = $txtDir.Text.Trim()
            if (-not $dir) { throw "Please specify a folder" }
            Create-Shortcuts $dir
            [System.Windows.Forms.MessageBox]::Show("Shortcuts created in:`n$dir", "Done")
        } catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error", "OK", "Error")
        }
    })
    $form.Controls.Add($btnCreate)

    $btnDesktop = New-Object System.Windows.Forms.Button
    $btnDesktop.Text = "Desktop"
    $btnDesktop.Location = New-Object System.Drawing.Point(155, 140)
    $btnDesktop.Size = New-Object System.Drawing.Size(120, 30)
    $btnDesktop.Add_Click({
        try {
            $dir = Join-Path $env:USERPROFILE "Desktop"
            Create-Shortcuts $dir
            [System.Windows.Forms.MessageBox]::Show("Shortcuts created on Desktop:`n$dir", "Done")
        } catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error", "OK", "Error")
        }
    })
    $form.Controls.Add($btnDesktop)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Location = New-Object System.Drawing.Point(290, 140)
    $btnCancel.Size = New-Object System.Drawing.Size(120, 30)
    $btnCancel.Add_Click({ $form.Close() })
    $form.Controls.Add($btnCancel)

    $form.AcceptButton = $btnCreate
    $form.CancelButton = $btnCancel
    [void]$form.ShowDialog()
}

if ($ShortcutDir) {
    Create-Shortcuts $ShortcutDir
    Write-Host "Done. Shortcuts created in $ShortcutDir."
} else {
    Show-ShortcutForm
}
