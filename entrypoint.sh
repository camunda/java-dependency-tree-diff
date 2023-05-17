#!/bin/bash

set -e
# let script stop when one of the commands fails (e.g. one of the Maven builds)

git fetch

apt update && apt -y install ruby bundler
bundle install --gemfile=/Gemfile

if [[ $(git diff origin/$GITHUB_BASE_REF HEAD --name-only | grep pom.xml$ | wc -c) -ne 0 ]]; then
    # installing nodejs 14.x and config xlts registry is required for platform-ee build
    # consider splitting 'enterprise' branch if this step is unnecessary for the other repositories
    # so far only rpa-bridge-ee is the other repository that uses the branch
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt update && \
    apt install -y nodejs rsync
    npm set @xlts.dev:registry https://${XLTS_REGISTRY}/
    npm set //${XLTS_REGISTRY}/:_authToken ${XLTS_AUTH_TOKEN}

    cd /github/workspace
    
    mvn -T 16C -s /maven-settings.xml dependency:list -DoutputAbsoluteArtifactFilename=true -DoutputFile=dependencies.txt -Dsort=true -DexcludeGroupIds=org.camunda.bpm,org.camunda.bpm.dmn,org.camunda.bpm.model,org.camunda.feel -DincludeScopes="compile|provided|runtime|test" -U
    find . -name 'dependencies.txt' -exec rsync -R \{\} /pr \;

    git checkout -f origin/$GITHUB_BASE_REF
    mvn -T 16C -s /maven-settings.xml dependency:list -DoutputAbsoluteArtifactFilename=true -DoutputFile=dependencies.txt -Dsort=true -DexcludeGroupIds=org.camunda.bpm,org.camunda.bpm.dmn,org.camunda.bpm.model,org.camunda.feel -DincludeScopes="compile|provided|runtime|test" -U

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
