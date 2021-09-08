#!/bin/bash

set -e
# let script stop when one of the commands fails (e.g. one of the Maven builds)

git fetch

apt update && apt -y install ruby
gem install octokit

if [[ $(git diff origin/$GITHUB_BASE_REF HEAD --name-only | grep pom.xml$ | wc -c) -ne 0 ]]; then
    apt install -y nodejs npm rsync

    cd /github/workspace

    mvn -T 16C clean package -DskipTests -Dskip-third-party-bom=false -Dthird-party-bom-scopes="compile|provided|runtime|test"
    find . -name 'dependencies.txt' -exec rsync -R \{\} /pr \;

    git checkout -f origin/$GITHUB_BASE_REF
    mvn -T 16C clean package -DskipTests -Dskip-third-party-bom=false -Dthird-party-bom-scopes="compile|provided|runtime|test"
    find . -name 'dependencies.txt' -exec rsync -R \{\} /base \;

    echo -e "<details><summary>Dependency Tree Diff</summary><p>\n" >/github/workspace/dep-tree-diff.txt
    echo "\`\`\`diff" >>/github/workspace/dep-tree-diff.txt

    diff -r /base /pr >>/github/workspace/dep-tree-diff.txt || :
    # || : => : is the null command that always succeeds; 
    # this way we can ignore the exit code of which is 1 in case the files differ

    echo "\`\`\`" >>/github/workspace/dep-tree-diff.txt
    echo "</p></details>" >>/github/workspace/dep-tree-diff.txt

    ruby /add-comment.rb dep-tree-diff.txt
else
    ruby /add-comment.rb
fi
