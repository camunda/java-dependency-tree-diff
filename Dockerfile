FROM maven:3.8.5-openjdk-17-slim

ADD entrypoint.sh /entrypoint.sh
ADD add-comment.rb /add-comment.rb
ADD Gemfile /Gemfile
ADD maven-settings.xml /maven-settings.xml

RUN chmod u+x /entrypoint.sh && chmod u+x /add-comment.rb

ENTRYPOINT ["/entrypoint.sh"]
