---
name: Bug Report
about: Report a bug or unexpected behavior
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description

<!-- A clear and concise description of what the bug is -->

## Steps to Reproduce

1.
2.
3.
4.

## Expected Behavior

<!-- What you expected to happen -->

## Actual Behavior

<!-- What actually happened -->

## Environment

- **OS:** <!-- e.g., Ubuntu 22.04, macOS 13.0, Windows 11 with WSL2 -->
- **Docker Version:** <!-- Output of `docker --version` -->
- **Docker Compose Version:** <!-- Output of `docker compose version` -->
- **Service(s) Affected:** <!-- e.g., MySQL, Redis, etc. -->

## Configuration

<!-- Share relevant configuration (with sensitive data removed) -->

**docker-compose.override.yml excerpt:**
```yaml
# Paste relevant section here
```

**.env excerpt:**
```bash
# Paste relevant variables here (REMOVE PASSWORDS!)
```

## Logs

<!-- Include relevant logs -->

```bash
# Output of: docker compose logs service-name
```

## Additional Context

<!-- Any other context, screenshots, or information -->

## Attempted Solutions

<!-- What have you already tried to fix this? -->

- [ ] Checked [TROUBLESHOOTING.md](../TROUBLESHOOTING.md)
- [ ] Searched existing issues
- [ ] Validated configuration with `docker compose config`
- [ ] Tried restarting services
- [ ] Tried with fresh setup
