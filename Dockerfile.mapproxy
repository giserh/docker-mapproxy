FROM continuumio/miniconda3
LABEL maintainer="Brian Wilson <brian@wildsong.biz>"
LABEL version="1.0"
LABEL biz.wildsong.name="mapproxy"

# Because of the continuumio base image, the installation will go into /opt/conda

ENV PROJ_LIB /opt/conda/share/proj
ENV MAPPROXY_BASE   /srv/mapproxy

WORKDIR /tmp
COPY requirements.txt ./

# This will upgrade conda, so the fact that the base image is old does not matter
RUN conda config --add channels conda-forge &&\
    conda install --file requirements.txt

RUN conda install git &&\
    git clone https://github.com/mapproxy/mapproxy.git &&\
    cd mapproxy && python setup.py install

# Maybe someday I'll be able to download and unzip in one step.
RUN conda install -c conda-forge unzip
ADD https://download.osgeo.org/proj/proj-datumgrid-latest.zip $PROJ_LIB
#ADD proj-datumgrid-latest.tar.gz $PROJ_LIB/
# You might need to add other datumgrid files for your region
ADD https://download.osgeo.org/proj/proj-datumgrid-north-america-latest.zip $PROJ_LIB
#ADD proj-datumgrid-north-america-latest.tar.gz $PROJ_LIB/
WORKDIR $PROJ_LIB
RUN for z in *.zip; do unzip -o $z && rm -f $z; done

WORKDIR $MAPPROXY_BASE
COPY start_mapproxy.py .
COPY log.ini .

# We normally use couch_db to store tiles but this folder is available too.
# This just creates the cache folder, which we hopefully never use
RUN mkdir -p $MAPPROXY_BASE/cache_data

WORKDIR $MAPPROXY_BASE/config
COPY globals.yaml .
COPY seed.yaml .

WORKDIR $MAPPROXY_BASE/config/services
COPY city-aerials.yaml .
COPY county-aerials.yaml .
COPY lidar.yaml .

VOLUME $MAPPROXY_BASE/config

# Start a waitress WSGI server, set the port as desired.
# Make sure it matches the VIRTUAL_PORT setting in docker-compose.yml if you use that.
WORKDIR $MAPPROXY_BASE
EXPOSE 8080
CMD python3 start_mapproxy.py $MAPPROXY_BASE/log.ini $MAPPROXY_BASE/config/services 8080
