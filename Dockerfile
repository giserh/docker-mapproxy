FROM python:3-slim-stretch
LABEL maintainer="Brian Wilson <brian@wildsong.biz>"

RUN apt-get -y update &&\
    apt-get install -y git libproj12 libgeos-c1v5

# First let's grab all the easy-to-install dependencies
WORKDIR /tmp
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

RUN pip install git+https://github.com/mapproxy/mapproxy.git@master

RUN mkdir -p /srv/mapproxy/cache_data && mkdir -p /srv/mapproxy/config

WORKDIR /srv/mapproxy
COPY mapproxy.yaml config
COPY start_mapproxy.py .

VOLUME /srv/mapproxy
EXPOSE 8080
CMD python start_mapproxy.py

#CMD gunicorn -k gthread --user=1337 --group=1337 --chdir /srv/mapproxy --threads=16 --workers=1 -b :80 config:application --no-sendfile --access-logfile '-' --error-logfile '-'