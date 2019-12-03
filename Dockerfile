FROM continuumio/miniconda3
LABEL maintainer="Brian Wilson <brian@wildsong.biz>"

WORKDIR /tmp
COPY requirements.txt ./

# Because of the base image, the installation will go into /opt/conda

# This will upgrade conda, so the fact that the base image is old does not matter
RUN conda config --add channels conda-forge &&\
    conda install --file requirements.txt

RUN conda install git &&\
    git clone https://github.com/mapproxy/mapproxy.git &&\
    cd mapproxy && python setup.py install

RUN mkdir -p /srv/mapproxy/cache_data && mkdir -p /srv/mapproxy/config

WORKDIR /srv/mapproxy
COPY mapproxy.yaml config
COPY start_mapproxy.py .

VOLUME /srv/mapproxy

EXPOSE 8080
# Start a waitress WSGI server
CMD python3 start_mapproxy.py 8080

# The old way with gunicorn, which runs only on Linux.
#CMD gunicorn -k gthread --user=1337 --group=1337 --chdir /srv/mapproxy --threads=16 --workers=1 -b :80 config:application --no-sendfile --access-logfile '-' --error-logfile '-'

