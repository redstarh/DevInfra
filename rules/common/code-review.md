# Code Review Standards

## Review Severity Levels

| Level | Meaning | Action |
|-------|---------|--------|
| CRITICAL | Security vulnerability or data loss risk | **BLOCK** - Must fix |
| HIGH | Bug or significant quality issue | **WARN** - Should fix |
| MEDIUM | Maintainability concern | **INFO** - Consider fixing |
| LOW | Style or minor suggestion | **NOTE** - Optional |

## Security Review Triggers

Use security-reviewer agent when touching:
- Authentication/authorization code
- User input handling or database queries
- External API calls or file system operations
- Cryptographic or payment code

## Approval Criteria

- **Approve**: No CRITICAL or HIGH issues
- **Block**: CRITICAL issues found
