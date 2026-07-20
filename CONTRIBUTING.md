# Contributing to Oss Island

Thanks for helping build an open, local-first coding-agent companion.

## Before opening a pull request

1. Open an issue for new features or protocol changes so the behavior can be agreed before implementation.
2. Keep the app local-only by default. New network access requires explicit user control, documentation, and a threat-model update.
3. Do not copy proprietary code, assets, sounds, copywriting, or visual trade dress from other products.
4. Keep adapter-specific behavior outside the core session model where practical.

## Development

```bash
./scripts/bootstrap.sh
swift run OssIsland
```

Before submitting:

```bash
swift run OssIslandCoreChecks
./scripts/build-app.sh
```

Include a short manual test note for user-interface changes. Pull requests should be focused, explain the user impact, and update the README or roadmap when behavior changes.

## Event protocol changes

Treat event fields as a public API. Prefer additive, optional fields. Protocol changes must include:

- an example event;
- migration or compatibility behavior;
- privacy and security impact;
- updated core checks.

By contributing, you agree that your contribution is licensed under the MIT License.
