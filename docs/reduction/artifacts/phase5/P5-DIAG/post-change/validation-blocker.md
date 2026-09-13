# P5-DIAG post-change validation blocker

## Fixed runner invocation

```text
/Users/brettcon/git/systems-orchestration/scripts/open-circuit-runner.sh \
  --hosts-file /Users/brettcon/git/hosts/ubuntu1-hosts.sh \
  --branch reduce/phase5-cli-core-validation \
  --phase5-validate
```

- Host reachability: passed on Ubuntu1 (`10.1.141.9`)
- Required runtime target: Node.js `24.19.0`
- Fixed runner mode: `--phase5-validate`
- Fixed runner revision: `ba52121cca51b7ce951320fdbee4902ebaec7ea1`
- Result: blocked before validation
- Runner exit: `1`

## Blocking evidence

The runner pulled through its fixed git operation and stopped because the
durable Phase 5 branch is local-only and has not been published:

```text
fatal: couldn't find remote ref reduce/phase5-cli-core-validation
status: blocked
blockers: remote git operation failed (exit 128)
```

No remote validation result is claimed for the post-change branch. The phase
executor did not push, create a PR, or substitute an arbitrary remote command.
The Git integration agent must publish the committed branch, then rerun the
same fixed `--phase5-validate` invocation on Ubuntu1.

The corrected runner's Phase 5 stale-reference scan is covered by its SDD
contract and TDD regression test. The correction requires one or more relative
path segments before `core`, so approved bare `core` package imports do not
block the profile.
