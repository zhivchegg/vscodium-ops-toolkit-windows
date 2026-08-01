#requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$scriptDir = $PSScriptRoot
$settingsFile = Join-Path $scriptDir "data\user-data\User\settings.json"
$profileDir = Join-Path $scriptDir "msys64\etc\profile.d"
$runtimeSh = Join-Path $profileDir "runtime.sh"

function Write-TextFile {
    param([string]$Path, [string]$Content)
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Write-LinesFile {
    param([string]$Path, [string[]]$Lines)
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllLines($Path, $Lines, $utf8)
}

function Resolve-SettingsPath {
    param([string]$Val)
    if (-not $Val) { return $null }
    if ($Val -like '${execPath}*') {
        return [System.IO.Path]::GetFullPath((Join-Path $scriptDir ($Val -replace '\$\{execPath\}\\\.\.', '')))
    }
    return $Val
}

function Get-CurrentPythonPath {
    if (Test-Path $settingsFile) {
        try {
            $json = Get-Content $settingsFile -Raw | ConvertFrom-Json
            return Resolve-SettingsPath $json.'python.defaultInterpreterPath'
        } catch {}
    }
    return $null
}

function Get-CurrentJavaPath {
    if (Test-Path $settingsFile) {
        try {
            $json = Get-Content $settingsFile -Raw | ConvertFrom-Json
            return Resolve-SettingsPath $json.'java.jdt.ls.java.home'
        } catch {}
    }
    return $null
}

function ConvertTo-RelativePath {
    param([string]$FullPath)
    if (-not $FullPath) { return $null }
    try {
        $canonicalScriptDir = [System.IO.Path]::GetFullPath($scriptDir).TrimEnd('\')
        $canonicalFullPath = [System.IO.Path]::GetFullPath($FullPath)
        if ($canonicalFullPath.StartsWith($canonicalScriptDir + '\')) {
            $rel = $canonicalFullPath.Substring($canonicalScriptDir.Length)
            if ($rel.StartsWith('\')) { $rel = $rel.Substring(1) }
            return '${execPath}\..\' + $rel
        }
        return $canonicalFullPath
    } catch {
        return $FullPath
    }
}

function ConvertTo-MsysPath {
    param([string]$WinPath)
    if (-not $WinPath) { return $null }
    $drive = $WinPath.Substring(0, 1).ToLower()
    $rest = $WinPath.Substring(2) -replace '\\', '/'
    return "/$drive$rest"
}

function Test-Python {
    param([string]$Path)
    if (-not $Path -or -not (Test-Path $Path)) { return "Not found: $Path" }
    try {
        $out = & $Path --version 2>&1
        return "OK: $out"
    } catch {
        return "ERROR: $_"
    }
}

function Test-Java {
    param([string]$Path)
    if (-not $Path -or -not (Test-Path "$Path\bin\java.exe")) { return "Not found: $Path\bin\java.exe" }
    try {
        $out = & "$Path\bin\java.exe" -version 2>&1 | Select-Object -First 1
        return "OK: $out"
    } catch {
        return "ERROR: $_"
    }
}

function Get-RuntimeShLines {
    if (-not (Test-Path $runtimeSh)) { return @() }
    $raw = Get-Content $runtimeSh -Raw
    if ([string]::IsNullOrWhiteSpace($raw)) { return @() }
    return $raw -split '\r?\n'
}

function Save-Python {
    param([string]$Path)
    if (-not (Test-Path $Path)) { throw "File not found: $Path" }
    $ver = & $Path --version 2>&1

    # Update settings.json
    $json = @{}
    if (Test-Path $settingsFile) {
        $json = Get-Content $settingsFile -Raw | ConvertFrom-Json
    }
    $json | Add-Member -NotePropertyName 'python.defaultInterpreterPath' -NotePropertyValue (ConvertTo-RelativePath $Path) -Force
    Write-TextFile $settingsFile ($json | ConvertTo-Json -Depth 10)

    # Update runtime.sh
    if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
    $msysPath = ConvertTo-MsysPath $Path
    $dirPath = ConvertTo-MsysPath (Split-Path -Parent $Path)
    $scriptsPath = ConvertTo-MsysPath (Join-Path (Split-Path -Parent $Path) 'Scripts')
    if (-not (Test-Path $scriptsPath)) {
        $scriptsPath = "$dirPath/bin"
    }
    $lines = (Get-RuntimeShLines | Where-Object { $_ -notmatch '^export (PYTHON|PYTHONDONTWRITEBYTECODE|PYTHONIOENCODING|PATH=.*python)' -and $_ -notmatch '^# Python' -and $_ -notmatch '^alias (python3|py)=' }) -as [string[]]
    if (-not $lines) { $lines = @() }
    $lines += "# Python (configured $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
    $lines += "export PYTHON=`"$msysPath`""
    $lines += "export PYTHONDONTWRITEBYTECODE=1"
    $lines += "export PYTHONIOENCODING=UTF-8"
    $lines += "export PATH=`"$dirPath`":`"$scriptsPath`":`$PATH"
    $lines += "alias python3=`"$msysPath`""
    $lines += "alias py=`"$msysPath`""
    Write-LinesFile $runtimeSh $lines
}

function Save-Java {
    param([string]$Path)
    if (-not (Test-Path "$Path\bin\java.exe")) { throw "java.exe not found in $Path\bin" }
    $ver = & "$Path\bin\java.exe" -version 2>&1 | Select-Object -First 1

    # Update settings.json
    $json = @{}
    if (Test-Path $settingsFile) {
        $json = Get-Content $settingsFile -Raw | ConvertFrom-Json
    }
    $rel = ConvertTo-RelativePath $Path
    $json | Add-Member -NotePropertyName 'java.jdt.ls.java.home' -NotePropertyValue $rel -Force
    Write-TextFile $settingsFile ($json | ConvertTo-Json -Depth 10)

    # Update runtime.sh
    if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
    $msysPath = ConvertTo-MsysPath $Path
    $lines = (Get-RuntimeShLines | Where-Object { $_ -notmatch '^export (JAVA_HOME|JAVA_TOOL_OPTIONS|PATH=.*java)' -and $_ -notmatch '^# Java' }) -as [string[]]
    if (-not $lines) { $lines = @() }
    $lines += "# Java (configured $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
    $lines += "export JAVA_HOME=`"$msysPath`""
    $lines += "export JAVA_TOOL_OPTIONS=`"-Dfile.encoding=UTF-8`""
    $lines += "export PATH=`"$msysPath/bin`":`$PATH"
    Write-LinesFile $runtimeSh $lines
}

function Clear-Python {
    # Remove from settings.json
    if (Test-Path $settingsFile) {
        $json = Get-Content $settingsFile -Raw | ConvertFrom-Json
        $json.PSObject.Properties.Remove('python.defaultInterpreterPath')
        Write-TextFile $settingsFile ($json | ConvertTo-Json -Depth 10)
    }
    # Remove from runtime.sh
    if (Test-Path $runtimeSh) {
        $lines = (Get-RuntimeShLines | Where-Object { $_ -notmatch '^export (PYTHON|PYTHONDONTWRITEBYTECODE|PYTHONIOENCODING|PATH=.*python)' -and $_ -notmatch '^# Python' -and $_ -notmatch '^alias (python3|py)=' }) -as [string[]]
        if (-not $lines) { $lines = @() }
        Write-LinesFile $runtimeSh $lines
    }
}

function Clear-Java {
    # Remove from settings.json
    if (Test-Path $settingsFile) {
        $json = Get-Content $settingsFile -Raw | ConvertFrom-Json
        $json.PSObject.Properties.Remove('java.jdt.ls.java.home')
        Write-TextFile $settingsFile ($json | ConvertTo-Json -Depth 10)
    }
    # Remove from runtime.sh
    if (Test-Path $runtimeSh) {
        $lines = (Get-RuntimeShLines | Where-Object { $_ -notmatch '^export (JAVA_HOME|JAVA_TOOL_OPTIONS|PATH=.*java)' -and $_ -notmatch '^# Java' }) -as [string[]]
        if (-not $lines) { $lines = @() }
        Write-LinesFile $runtimeSh $lines
    }
}

# Build form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'VSCodium Ops Toolkit - Runtime Configuration'
$form.Size = New-Object System.Drawing.Size(620, 500)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

$y = 20
$labelWidth = 140
$textWidth = 320
$btnWidth = 90
$height = 24
$gap = 10

function New-Label {
    param($Text, $X, $Y, $W, $H)
    $l = New-Object System.Windows.Forms.Label
    $l.Text = $Text
    $l.Location = New-Object System.Drawing.Point($X, $Y)
    $l.Size = New-Object System.Drawing.Size($W, $H)
    return $l
}

function New-TextBox {
    param($X, $Y, $W, $H)
    $t = New-Object System.Windows.Forms.TextBox
    $t.Location = New-Object System.Drawing.Point($X, $Y)
    $t.Size = New-Object System.Drawing.Size($W, $H)
    $t.ReadOnly = $true
    return $t
}

function New-Button {
    param($Text, $X, $Y, $W, $H)
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $Text
    $b.Location = New-Object System.Drawing.Point($X, $Y)
    $b.Size = New-Object System.Drawing.Size($W, $H)
    return $b
}

# === Python section ===
$lblPyTitle = New-Label 'Python' 20 $y 100 $height
$lblPyTitle.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblPyTitle)
$y += 28

$currentPy = Get-CurrentPythonPath
$lblPyCurrent = New-Label "Current: $(if ($currentPy) { $currentPy } else { 'not configured' })" 20 $y 560 $height
$lblPyCurrent.ForeColor = if ($currentPy) { [System.Drawing.Color]::DarkGreen } else { [System.Drawing.Color]::Gray }
$form.Controls.Add($lblPyCurrent)
$y += 28

$lblPyHint = New-Label 'Укажите путь к файлу python.exe в папке с переносимым Python. Подготовьте Python на машине с интернетом, установите пакеты, скопируйте всю папку сюда, затем выберите python.exe.' 20 $y 560 32
$lblPyHint.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 8, [System.Drawing.FontStyle]::Italic)
$lblPyHint.ForeColor = [System.Drawing.Color]::DimGray
$lblPyHint.AutoSize = $false
$form.Controls.Add($lblPyHint)
$y += 34

$lblPy = New-Label 'python.exe:' 20 $y $labelWidth $height
$form.Controls.Add($lblPy)

$txtPy = New-TextBox (20 + $labelWidth) $y $textWidth $height
$txtPy.Text = if ($currentPy) { $currentPy } else { '' }
$form.Controls.Add($txtPy)

$btnPyBrowse = New-Button 'Browse...' (20 + $labelWidth + $textWidth + $gap) $y $btnWidth $height
$btnPyBrowse.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title = 'Select python.exe'
    $dlg.Filter = 'python.exe|python.exe|All files (*.*)|*.*'
    $dlg.InitialDirectory = 'C:\'
    if ($dlg.ShowDialog() -eq 'OK') { $txtPy.Text = $dlg.FileName }
})
$form.Controls.Add($btnPyBrowse)
$y += 34

$btnPyTest = New-Button 'Test' 20 $y 80 $height
$btnPyTest.Add_Click({
    $result = Test-Python $txtPy.Text
    [System.Windows.Forms.MessageBox]::Show($result, 'Python Test')
})
$form.Controls.Add($btnPyTest)

$btnPySave = New-Button 'Save' (20 + 90) $y 80 $height
$btnPySave.Add_Click({
    try {
        Save-Python $txtPy.Text
        $lblPyCurrent.Text = "Current: $($txtPy.Text)"
        $lblPyCurrent.ForeColor = [System.Drawing.Color]::DarkGreen
        [System.Windows.Forms.MessageBox]::Show('Python path saved.', 'Saved')
    } catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Error', 'OK', 'Error')
    }
})
$form.Controls.Add($btnPySave)

$btnPyClear = New-Button 'Clear' (20 + 180) $y 80 $height
$btnPyClear.Add_Click({
    Clear-Python
    $txtPy.Text = ''
    $lblPyCurrent.Text = 'Current: not configured'
    $lblPyCurrent.ForeColor = [System.Drawing.Color]::Gray
    [System.Windows.Forms.MessageBox]::Show('Python configuration cleared.', 'Cleared')
})
$form.Controls.Add($btnPyClear)
$y += 26

$lblPyReq = New-Label 'Обязательные пакеты: debugpy, PyYAML, yamllint, requests, rich, python-dateutil, jinja2, pytz, click, httpie' 20 $y 560 28
$lblPyReq.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 8, [System.Drawing.FontStyle]::Italic)
$lblPyReq.ForeColor = [System.Drawing.Color]::DimGray
$lblPyReq.AutoSize = $false
$form.Controls.Add($lblPyReq)
$y += 44

# Separator
$sep1 = New-Object System.Windows.Forms.Label
$sep1.BorderStyle = 'Fixed3D'
$sep1.Location = New-Object System.Drawing.Point(20, $y)
$sep1.Size = New-Object System.Drawing.Size(560, 2)
$form.Controls.Add($sep1)
$y += 20

# === Java section ===
$lblJavaTitle = New-Label 'Java' 20 $y 100 $height
$lblJavaTitle.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblJavaTitle)
$y += 28

$currentJava = Get-CurrentJavaPath
$lblJavaCurrent = New-Label "Current: $(if ($currentJava) { $currentJava } else { 'not configured' })" 20 $y 560 $height
$lblJavaCurrent.ForeColor = if ($currentJava) { [System.Drawing.Color]::DarkGreen } else { [System.Drawing.Color]::Gray }
$form.Controls.Add($lblJavaCurrent)
$y += 28

$lblJavaHint = New-Label 'Скопируйте папку portable JDK сюда, затем выберите папку, внутри которой находится bin\java.exe (это JAVA_HOME).' 20 $y 560 32
$lblJavaHint.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 8, [System.Drawing.FontStyle]::Italic)
$lblJavaHint.ForeColor = [System.Drawing.Color]::DimGray
$lblJavaHint.AutoSize = $false
$form.Controls.Add($lblJavaHint)
$y += 34

$lblJava = New-Label 'Java home:' 20 $y $labelWidth $height
$form.Controls.Add($lblJava)

$txtJava = New-TextBox (20 + $labelWidth) $y $textWidth $height
$txtJava.Text = if ($currentJava) { $currentJava } else { '' }
$form.Controls.Add($txtJava)

$btnJavaBrowse = New-Button 'Browse...' (20 + $labelWidth + $textWidth + $gap) $y $btnWidth $height
$btnJavaBrowse.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = 'Select Java home folder (containing bin\java.exe)'
    $dlg.RootFolder = 'MyComputer'
    if ($dlg.ShowDialog() -eq 'OK') { $txtJava.Text = $dlg.SelectedPath }
})
$form.Controls.Add($btnJavaBrowse)
$y += 26

$btnJavaTest = New-Button 'Test' 20 $y 80 $height
$btnJavaTest.Add_Click({
    $result = Test-Java $txtJava.Text
    [System.Windows.Forms.MessageBox]::Show($result, 'Java Test')
})
$form.Controls.Add($btnJavaTest)

$btnJavaSave = New-Button 'Save' (20 + 90) $y 80 $height
$btnJavaSave.Add_Click({
    try {
        Save-Java $txtJava.Text
        $lblJavaCurrent.Text = "Current: $($txtJava.Text)"
        $lblJavaCurrent.ForeColor = [System.Drawing.Color]::DarkGreen
        [System.Windows.Forms.MessageBox]::Show('Java path saved.', 'Saved')
    } catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Error', 'OK', 'Error')
    }
})
$form.Controls.Add($btnJavaSave)

$btnJavaClear = New-Button 'Clear' (20 + 180) $y 80 $height
$btnJavaClear.Add_Click({
    Clear-Java
    $txtJava.Text = ''
    $lblJavaCurrent.Text = 'Current: not configured'
    $lblJavaCurrent.ForeColor = [System.Drawing.Color]::Gray
    [System.Windows.Forms.MessageBox]::Show('Java configuration cleared.', 'Cleared')
})
$form.Controls.Add($btnJavaClear)
$y += 55

# Footer
$sep2 = New-Object System.Windows.Forms.Label
$sep2.BorderStyle = 'Fixed3D'
$sep2.Location = New-Object System.Drawing.Point(20, $y)
$sep2.Size = New-Object System.Drawing.Size(560, 2)
$form.Controls.Add($sep2)
$y += 15

$lblNote = New-Label 'После сохранения перезапустите VSCodium через start-vscodium.cmd.' 20 $y 560 $height
$lblNote.ForeColor = [System.Drawing.Color]::DarkBlue
$form.Controls.Add($lblNote)
$y += 32

$btnClose = New-Button 'Close' 490 $y $btnWidth $height
$btnClose.Add_Click({ $form.Close() })
$form.Controls.Add($btnClose)

# Run GUI only when script is executed directly (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    [void]$form.ShowDialog()
}
