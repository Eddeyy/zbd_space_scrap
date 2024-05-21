FROM postgres:latest

ENV POSTGRES_PASSWORD skibidi

ENV POSTGRES_DB scrap

COPY init.sh /usr/local/bin/

RUN apt-get update && apt-get install -y curl
RUN apt-get -y install postgresql-16-cron
RUN echo "shared_preload_libraries='pg_cron'" >> /usr/share/postgresql/postgresql.conf.sample
RUN echo "cron.database_name='scrap'" >> /usr/share/postgresql/postgresql.conf.sample

ENTRYPOINT ["init.sh"]