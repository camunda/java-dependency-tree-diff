FROM maven:3.6.3-jdk-8

ADD entrypoint.sh /entrypoint.sh
ADD add-comment.rb /add-comment.rb

RUN chmod u+x /entrypoint.sh && chmod u+x /add-comment.rb

ENTRYPOINT ["/entrypoint.sh"]