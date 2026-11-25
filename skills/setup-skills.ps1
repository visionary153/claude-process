# Claude Code 전역 스킬 설치 스크립트
# 사용법: PowerShell에서 .\setup-skills.ps1
# 스킬은 CLAUDE_CONFIG_DIR(없으면 ~\.claude)의 skills 폴더에 설치된다.

# 설치할 스킬 목록: 출처 저장소별로 스킬 이름을 나열한다.
$SkillSources = @(
    @{ Repo = 'vercel-labs/agent-browser'; Skills = @('agent-browser') },
    @{ Repo = 'anthropics/skills'; Skills = @('frontend-design', 'webapp-testing') },
    @{ Repo = 'vercel-labs/agent-skills'; Skills = @('vercel-react-best-practices') }
)

# 스킬 외에 별도 CLI가 필요한 npm 패키지
$GlobalNpmPackages = @('agent-browser')

function Invoke-Step {
    param([string]$Title, [scriptblock]$Command)
    Write-Host "`n==> $Title" -ForegroundColor Cyan
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "실패: $Title (exit code $LASTEXITCODE)"
    }
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw 'npm을 찾을 수 없습니다. Node.js를 먼저 설치하세요.'
}

$ConfigDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }
Write-Host "스킬 설치 위치: $ConfigDir\skills" -ForegroundColor Yellow

foreach ($Package in $GlobalNpmPackages) {
    Invoke-Step "npm 전역 설치: $Package" { npm install -g $Package }
}

# npm 전역 설치 직후에는 현재 세션 PATH에서 명령을 못 찾을 수 있어 npx로 실행한다.
Invoke-Step 'agent-browser용 Chrome 다운로드' { npx -y agent-browser install }

foreach ($Source in $SkillSources) {
    $SkillArgs = $Source.Skills | ForEach-Object { '--skill', $_ }
    Invoke-Step "스킬 설치: $($Source.Repo) ($($Source.Skills -join ', '))" {
        npx -y skills add $Source.Repo @SkillArgs -g -a claude-code -y
    }
}

# webapp-testing 스킬은 Python Playwright로 동작한다. Python이 없으면 안내만 한다.
# Windows에는 실행되지 않는 Microsoft Store용 python 별칭이 있어, 실제 실행 여부로 판단한다.
$PythonReady = $false
if (Get-Command python -ErrorAction SilentlyContinue) {
    python --version *> $null
    $PythonReady = ($LASTEXITCODE -eq 0)
}
if ($PythonReady) {
    Invoke-Step 'Python Playwright 설치 (webapp-testing용)' { python -m pip install playwright }
    Invoke-Step 'Playwright Chromium 설치' { python -m playwright install chromium }
} else {
    Write-Host "`n[건너뜀] Python이 없어 webapp-testing 준비를 생략합니다. Python 설치 후 다시 실행하세요." -ForegroundColor Yellow
}

Write-Host "`n완료. Claude Code를 새로 열고 /skills 로 목록을 확인하세요." -ForegroundColor Green
