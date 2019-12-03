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

# Instead of using ADD to download the zip files I were to copy the gz
# files into the local folder then I could use the "ADD file.gz" instead
# of "ADD url" and it would do the uncompress for me, skipping this
# step.  But that would require several extra installation steps.

RUN conda install -c conda-forge unzip
ADD https://download.osgeo.org/proj/proj-datumgrid-latest.zip datumgrid.zip
# You might need to add other datumgrid files for your region
ADD https://download.osgeo.org/proj/proj-datumgrid-north-america-latest.zip datumgrid-na.zip

ENV PROJ_LIB /opt/conda/share/proj
WORKDIR $PROJ_LIB
RUN for z in /tmp/datum*.zip; do unzip -o $z; done

ENV MAPPROXY_DATA /srv/mapproxy
WORKDIR $MAPPROXY_DATA
RUN mkdir -p $MAPPROXY_DATA/cache_data && mkdir -p $MAPPROXY_DATA/config
WORKDIR $MAPPROXY_DATA
COPY mapproxy.yaml config
COPY start_mapproxy.py .

VOLUME $MAPPROXY_DATA

# Start a waitress WSGI server, set the port as desired.
# Make sure it matches the VIRTUAL_PORT setting in docker-compose.yml if you use that.
EXPOSE 8080
CMD python3 start_mapproxy.py "${MAPPROXY_DATA}/config/mapproxy.yaml" 8080
