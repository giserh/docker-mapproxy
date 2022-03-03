FROM debian:11
LABEL maintainer="Brian Wilson <brian@wildsong.biz>"
LABEL version="1.2"
LABEL biz.wildsong.name="mapproxy"

# These ARGs can be overridden with "docker-compose build"
# Look in the docker-compose.yml file.
#
ARG VIRTUAL_HOST=host.example.com
ARG VIRTUAL_PORT=8080
ARG LETSENCRYPT_HOST=host.example.com
ARG LETSENCRYPT_EMAIL=webmaster@example.com

#ENV CONDA="/opt/conda"
ENV CONDA="/root/miniconda3"
ENV PROJ_LIB="${CONDA}/root/miniconda3/share/proj"
ENV MAPPROXY_BASE="/srv/mapproxy"

RUN apt-get update && apt-get install wget build-essential -y

WORKDIR /root
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    sh ./Miniconda3-latest-Linux-x86_64.sh -b
ENV PATH=${CONDA}/bin/:${PATH}
COPY requirements.txt ./
# This will upgrade conda, so the fact that the base image is old does not matter
RUN conda config --add channels conda-forge &&\
    conda install -y --file requirements.txt

RUN conda install -y git &&\
    git clone https://github.com/mapproxy/mapproxy.git &&\
    cd mapproxy && python setup.py install

WORKDIR $MAPPROXY_BASE
COPY log.ini .

VOLUME $MAPPROXY_BASE/cache
EXPOSE $VIRTUAL_PORT

# Get the PROJ datum files
ADD https://download.osgeo.org/proj/proj-datumgrid-latest.zip $PROJ_LIB
# You might need to add other datumgrid files for your region
ADD https://download.osgeo.org/proj/proj-datumgrid-north-america-latest.zip $PROJ_LIB
# You don't have to unzip, ADD does that now.

WORKDIR $MAPPROXY_BASE
COPY start_mapproxy.py .
COPY start_mapproxy.sh .
RUN chmod 755 start_mapproxy.sh

# Make these settings available in the image environment
ENV VIRTUAL_HOST ${VIRTUAL_HOST}
ENV VIRTUAL_PORT ${VIRTUAL_PORT}
ENV LETSENCRYPT_HOST ${LETSENCRYPT_HOST}
ENV LETSENCRYPT_EMAIL $[LETSENCRYPT_EMAIL}

# Start a waitress WSGI server
# You have to add an argument to specify the config
# as a CMD in the docker-compose file.
ENTRYPOINT ["python3", "start_mapproxy.py", "log.ini"]
