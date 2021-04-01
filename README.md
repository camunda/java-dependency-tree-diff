## GitHub Action: java-dependency-tree-diff

### Setup

Add the following workflow to your GitHub repository under `.github/workflows/main.yml` to enable the action:

```yaml
name: Java Dependency Tree Diff

on: [pull_request]

jobs:
    build:
      runs-on: ubuntu-latest
      steps:
      - uses: actions/checkout@v2.3.4
        with:
          ref: ${{ github.event.pull_request.head.sha }}
      - uses: tasso94/java-dependency-tree-diff
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### License

The source files in this repository are made available under the [Apache License Version 2.0](./LICENSE).