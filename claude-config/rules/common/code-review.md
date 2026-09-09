# Code Review Standards

> 리뷰 요청/수용 절차는 `superpowers:requesting-code-review` / `receiving-code-review`. 이 문서는 **심각도 판정 기준**만 정의한다.

## Review Severity Levels

| Level | superpowers 등급 | Meaning | Action |
|-------|-----------------|---------|--------|
| CRITICAL | Critical (Must Fix) | Security vulnerability or data loss risk | **BLOCK** - Must fix |
| HIGH | Important (Should Fix) | Bug or significant quality issue | **WARN** - Should fix |
| MEDIUM | Minor (Nice to Have) | Maintainability concern | **INFO** - Consider fixing |
| LOW | Minor (Nice to Have) | Style or minor suggestion | **NOTE** - Optional |

**등급 통일**: superpowers `code-reviewer.md` 템플릿은 3단계(Critical/Important/Minor)로 보고한다. 리뷰 결과를 위 4단계로 환산해 판정한다. `ReportFindings` 툴을 쓸 때는 위 4단계를 SoT로 삼는다.

## Security Review Triggers

Use security-reviewer agent when touching:
- Authentication/authorization code
- User input handling or database queries
- External API calls or file system operations
- Cryptographic or payment code

## Approval Criteria

- **Approve**: No CRITICAL or HIGH issues
- **Block**: CRITICAL issues found
