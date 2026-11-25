# Claude Code 스킬

새 PC에서도 같은 스킬을 쓰기 위한 설치 스크립트.
`setup-skills.ps1`을 실행하면 아래 스킬을 전역으로 설치한다.

| 스킬 | 출처 | 용도 |
|---|---|---|
| agent-browser | vercel-labs/agent-browser | 헤드리스 브라우저 조작 (페이지 열기·클릭·스크린샷) |
| frontend-design | anthropics/skills | UI 디자인 품질 가이드 |
| webapp-testing | anthropics/skills | Playwright 기반 로컬 웹앱 테스트 |
| vercel-react-best-practices | vercel-labs/agent-skills | React/Next.js 성능 가이드 |

## 사전 준비

- Node.js (npm, npx)
- `CLAUDE_CONFIG_DIR` 환경 변수: 기존 PC와 같은 설정 폴더를 쓰려면 먼저 설정한다.
  ```powershell
  [Environment]::SetEnvironmentVariable('CLAUDE_CONFIG_DIR', "$env:USERPROFILE\.claude-Personal", 'User')
  ```
  설정하지 않으면 `~\.claude\skills`에 설치된다. 설정 후에는 터미널을 새로 연다.
- (선택) Python: webapp-testing 스킬에 필요. 없으면 해당 준비 단계만 건너뛴다.

## 실행

```powershell
.\setup-skills.ps1
```

실행 정책 때문에 막히면:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-skills.ps1
```

다시 실행하면 각 스킬이 최신 버전으로 덮어써진다.

## 스킬 추가·제거

`setup-skills.ps1` 상단의 `$SkillSources`에 저장소와 스킬 이름을 추가하거나 지운다.
스킬 외에 CLI가 필요한 경우 `$GlobalNpmPackages`에도 추가한다.
