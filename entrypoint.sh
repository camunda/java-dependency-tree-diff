#!/bin/bash

git pull

apt update && apt -y install ruby
gem install octokit

if [[ $(git diff origin/master HEAD --name-only | grep pom.xml$ | wc -c) -ne 0 ]]; then
    apt install -y nodejs npm rsync

    cd /github/workspace

    mvn clean package -DskipTests -Dskip-third-party-bom=false -Dthird-party-bom-scopes="compile|provided|runtime|test"
    find . -name 'dependencies.txt' -exec rsync -R \{\} /pr \;

    git checkout -f origin/master
    mvn clean package -DskipTests -Dskip-third-party-bom=false -Dthird-party-bom-scopes="compile|provided|runtime|test"
    find . -name 'dependencies.txt' -exec rsync -R \{\} /master \;

    echo -e "<details><summary>Dependency Tree Diff</summary><p>\n" >/github/workspace/dep-tree-diff.txt
    echo "\`\`\`diff" >>/github/workspace/dep-tree-diff.txt
    diff -r /master /pr >>/github/workspace/dep-tree-diff.txt
    echo "\`\`\`" >>/github/workspace/dep-tree-diff.txt
    echo "</p></details>" >>/github/workspace/dep-tree-diff.txt

    ruby /add-comment.rb dep-tree-diff.txt
else
    ruby /add-comment.rb
fi