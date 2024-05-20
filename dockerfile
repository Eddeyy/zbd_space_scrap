FROM postgres:latest

ENV POSTGRES_PASSWORD skibidi

ENV POSTGRES_DB scrap

COPY init.sh /usr/local/bin/

ENTRYPOINT ["init.sh"]