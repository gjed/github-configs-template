## 1. Module Terraform Refactor

- [x] 1.1 Add `config_path` variable to `terraform/variables.tf` with description and type `string`
- [x] 1.2 Replace `${path.module}/../config` with `var.config_path` in `terraform/yaml-config.tf`
      (all occurrences including `webhook_dir` and the hardcoded paths in `check` block error message)
- [x] 1.3 Remove the `provider "github"` block from `terraform/main.tf`
- [x] 1.4 Pass `read_delay_ms` and `write_delay_ms` from module variables to the provider configuration
      in the consumer example (not the module itself — provider is consumer-side)
- [x] 1.5 Run `terraform validate` in `terraform/` to confirm module is syntactically valid
- [x] 1.6 Run `terraform fmt` on all modified files

## 2. Module Outputs

- [x] 2.1 Verify `organization` output is already exposed in `terraform/outputs.tf` (it is — confirm
      no changes needed)
- [x] 2.2 Confirm all outputs listed in the spec (`repositories`, `repository_count`, `organization`,
      `subscription_tier`, `subscription_warnings`, `duplicate_key_warnings`) are present

## 3. Consumer Example

- [x] 3.1 Create `examples/consumer/` directory structure:
  - `main.tf` — provider block + module call with `config_path`
  - `outputs.tf` — pass-through of key module outputs
  - `backend.tf.example` — commented-out backend block with usage notes
  - `Makefile` — optional shortcuts for plan/apply
- [x] 3.2 Create stub config files under `examples/consumer/config/`:
  - `config.yml` — org name, subscription placeholder
  - `group/base.yml` — minimal group example
  - `repository/example.yml` — one example repository
  - `ruleset/` — empty or minimal stub
- [x] 3.3 Write `examples/consumer/README.md` explaining how to use the example

## 4. Script Updates

- [x] 4.1 Add `--module-path` flag to `onboard-repos.sh`; default to `""` (direct layout)
- [x] 4.2 Update the `terraform import` command in `onboard-repos.sh` to prepend `${MODULE_PATH}`
      to the resource address when set
- [x] 4.3 Add `--module-path` flag to `offboard-repos.sh`; update `terraform state rm` similarly
- [x] 4.4 Add `--module-path` flag to `offboard-repos.sh --list` to scope state listing correctly
- [x] 4.5 Test scripts against both direct layout (no flag) and wrapped layout (with flag) scenarios

## 5. Migration Helper

- [x] 5.1 Create `scripts/migrate-state.sh` that:
  - Lists current `module.repositories[*]` state paths
  - Generates `terraform state mv` commands from direct to wrapped paths
  - Includes a `--dry-run` mode that prints commands without executing

## 6. Documentation

- [x] 6.1 Update `README.md` with a "Using as a Module" section covering:
  - Required and optional variables (table)
  - All outputs (table)
  - Complete consumer `main.tf` example
  - `config_path` static-string constraint note
  - Migration guide for existing forks
- [x] 6.2 Ensure `terraform/` directory `README.md` (if any) or inline comments are updated to
      reflect that `config_path` is now an input variable

## 7. Validation

- [x] 7.1 Run `terraform validate` from `examples/consumer/` with a test org name
- [x] 7.2 Run `pre-commit run --all-files` and resolve any issues
- [x] 7.3 Run `python scripts/validate-config.py` against `examples/consumer/config/`

## 8. Release

- [x] 8.1 Create PR with all changes; ensure CI passes
- [x] 8.2 After merge, tag `v1.0.0` on `main`

**Dependencies:**

- Tasks 1–2 can run in parallel.
- Task 3 depends on Task 1 being complete (need the final variable name confirmed).
- Tasks 4 and 5 are independent of 1–3.
- Task 6 can proceed in parallel with 1–5.
- Task 7 depends on Tasks 1–6 all being complete.
- Task 8 depends on Task 7.
