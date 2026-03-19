---
name: flake-summary
description: Finds the list of failing Gardener components related to a given prow.gardener.cloud job representing a failed flaky test.
license: Apache-2.0
compatibility: Requires access to the internet.
allowed-tools: Bash(git:*) Bash(curl:*) Bash(jq:*) Bash(grep:*) Bash(python3:*) Bash(gh:*)
metadata:
  author: Gardener Team
  version: "0.1.0"
---

# Flake Summary

## Purpose

This skill generates a summerized report for a given flaky test by analzing and extracting data from prow.gardener.cloud failed jobs. The following list outlines the basic rules that apply to the generated report:

## Process

1. Find the Gardener component that is relevant for the failing flake test.
2. Extract and list the key error messages from the provided prow.gardener.cloud CI job.
3. List merged Pull Requests in https://github.com/gardener/gardener that are related to the component from Step 1. The pull requests should not be older than a month from the initial date of the prow.gardener.cloud job start.
4. List additional Gardener components that are related to the test and may have effect on it.

## Report structure

```markdown
# [Report Title]

## Summary
[One-paragraph overview of the key findings]

## Related Test cases

[
  Table of the releated test case that cause the flake.
  Include test name, test description and location in the github.com/gardener/gardener repository.
  Use the following table structure:

  |  Name | Description | Reference     |
  |-------|-------------|---------------|
]

## Related Gardener Components

[
  Table of the related Gardener components with name, purpose and effect columns.
  Use the following table structure:

  |  Name | Purpose | Effect     |
  |-------|---------|------------|
]

## Related Pull Requests

[
  Table of merged pull requests in github.com/gardener/gardener that are related to the primary component.
  Pull requests must have a descending order by `mergedAt` date.
  Pull requests must be merged no longer than a month from the prow job execution.
]

## References

[
  Links to all referrences used in the report.
  Links to https://gardener.cloud documentation related to the extracted components.
]
```

## Constraints

- Strictly follow the provided Report Structure and do not include additional sections.
- All `markdown` tables must be with equal width. Use the widest table and adjust the smaller ones to match it's width.

## Core capabilities

- Parse logs from prow.gardener.cloud and extract Gardener component details.
- Look up https://github.com/gardener/gardener merged Pull Requests for changes related to specific Gardener component.
- Find relations between Gardener components and explain components affect each other.
- Ability to sort Pull Requests by their `Merged Date` value.

## Output format

- Use `Markdown` format and follow Google's style guide: https://google.github.io/styleguide/docguide/style.html.
- Use proper `json` or `yaml` formatting when reporting manifest snippets.
- Use proper `Golang` formatting when reporting source code snippets.
  - Provide complete runnable code examples with comments on each key step.
- Use code blocks with language annotations when reporting snippets.
