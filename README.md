## GitHub Action: java-dependency-tree-diff

### Setup

Add the following workflow to your GitHub repository under `.github/workflows/main.yml` to enable the action:

```yaml
name: Java Dependency Tree Diff

on:
  pull_request:
    types: [ labeled ]

jobs:
    build:
      runs-on: ubuntu-latest
      if: ${{ github.event.label.name == 'java-dependency-tree' }}
      steps:
      - uses: actions/checkout@v2.3.4
        with:
          ref: ${{ github.event.pull_request.head.sha }}
      - uses: camunda/java-dependency-tree-diff@main
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### License

The source files in this repository are made available under the [Apache License Version 2.0](./LICENSE).
