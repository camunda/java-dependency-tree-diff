#!/bin/bash

set -e
# let script stop when one of the commands fails (e.g. one of the Maven builds)

apt update && apt -y install git ruby bundler
bundle install --gemfile=/Gemfile

git config --global --add safe.directory /github/workspace
git fetch



if [[ $(git diff origin/$GITHUB_BASE_REF HEAD --name-only | grep pom.xml$ | wc -c) -ne 0 ]]; then
    # Pin version of NodeJS to 14.X
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
    apt update

    apt install -y nodejs rsync

    cd /github/workspace

    mvn -T 16C dependency:list -DoutputAbsoluteArtifactFilename=true -DoutputFile=dependencies.txt -Dsort=true -DexcludeGroupIds=org.camunda.bpm,org.camunda.bpm.dmn,org.camunda.bpm.model,org.camunda.feel -DincludeScopes=="compile|provided|runtime|test" -U
    find . -name 'dependencies.txt' -exec rsync -R \{\} /pr \;

    git checkout -f origin/$GITHUB_BASE_REF
    mvn -T 16C dependency:list -DoutputAbsoluteArtifactFilename=true -DoutputFile=dependencies.txt -Dsort=true -DexcludeGroupIds=org.camunda.bpm,org.camunda.bpm.dmn,org.camunda.bpm.model,org.camunda.feel -DincludeScopes=="compile|provided|runtime|test" -U

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
