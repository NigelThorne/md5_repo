FROM octohost/ruby-2.0

ADD . /srv/www
RUN cd /srv/www; bundle install --deployment --without test development

EXPOSE 4000

CMD ["/usr/local/bin/foreman","start","-d","/srv/www"]