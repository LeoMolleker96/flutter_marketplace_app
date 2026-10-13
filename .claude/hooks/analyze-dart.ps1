# PostToolUse hook: after Claude edits a .dart file, analyze that file with the
# pinned SDK (FVM) and feed any problems back to Claude.
#
# Why a script and not a model: lint and layer-level mistakes are deterministic,
# so a tool finds them for free and never misses one. The architecture-reviewer
# agent is for the judgement calls a script cannot make.
#
# Contract: the hook receives JSON on stdin. Exit 0 = fine. Exit 2 = stderr is
# shown to Claude so it can react.

$payload = [Console]::In.ReadToEnd() | ConvertFrom-Json
$path = $payload.tool_input.file_path

# Only Dart sources; generated files are noisy and not hand-edited.
if (-not $path -or $path -notlike '*.dart') { exit 0 }
if ($path -like '*.g.dart') { exit 0 }
if (-not (Test-Path $path)) { exit 0 }

$output = & fvm dart analyze $path 2>&1 | Out-String

if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine("dart analyze found problems in ${path}:`n$output")
    exit 2
}

exit 0
