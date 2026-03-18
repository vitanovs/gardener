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

This skill generates a summerized report for a given flaky test by analzing and extracting data from prow.gardener.cloud failed jobs. The following list outlines the basic rules that apply to the generated report:

- The report should be in Markdown format and should follow the Google's style guide: https://google.github.io/styleguide/docguide/style.html
- The report should be a summary, __not__ a detailed root cause analysis.
- Use Markdown tables for listing items in the report.

## Summarisation process

1. Find the Gardener component that is relevant for the failing flake test.
2. Extract and list the key error messages from the provided prow.gardener.cloud CI job.
3. List merged Pull Requests in https://github.com/gardener/gardener that are related to the component from Step 1. The pull requests should not be older than a month from the initial date of the prow.gardener.cloud job start.
4. List additional Gardener components that are related to the test and may have effect on it.

## Report structure

```markdown
# [Report Title]

## Summary
[One-paragraph overview of the key findings]]

## Related Test cases

[Table of the releated test case that cause the flake]]

## Related Gardener Components

[Table of the related components with name, purpose and effect columns]

## Related Pull Requests

[Table of recently merged pull requests that change/update the related Gardener components, sorted by merged date]

## References

[Links to all referrences used in the report]
```
