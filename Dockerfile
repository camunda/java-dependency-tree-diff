FROM maven:3.6.3-jdk-11

ADD entrypoint.sh /entrypoint.sh
ADD add-comment.rb /add-comment.rb
ADD Gemfile /Gemfile
ADD maven-settings.xml /maven-settings.xml

RUN chmod u+x /entrypoint.sh && chmod u+x /add-comment.rb

ENTRYPOINT ["/entrypoint.sh"]
