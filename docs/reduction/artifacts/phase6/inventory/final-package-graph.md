# Final Retained Package Graph

```text
extensions/cli -> core
extensions/cli -> config-yaml, openai-adapters, terminal-security
core -> config-types, config-yaml, fetch, llm-info, openai-adapters,
        terminal-security
```

The graph is reconciled from retained manifests and the fixed immutable
install/build order. `config-types` and `llm-info` remain Keep items even
where bundle input evidence is absent: they remain declared/build
dependencies and cannot be removed by implication.
