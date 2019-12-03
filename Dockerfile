FROM python:3.7
LABEL maintainer="Brian Wilson <brian@wildsong.biz>"

WORKDIR /tmp
COPY requirements.txt ./

# PIP section ----------------- on Windows we can't do this!
#RUN pip install --no-cache-dir -r requirements.txt
#
# Linux -- libproj13 is in buster, it was libproj12 in stretch
#RUN apt-get -y update && apt-get install -y git libproj13 libgeos-c1v5 &&\
#    pip install shapely
#
# Windows -- get a pip package for shapely with the binaries for GEOS and PROJ included
#ADD https://download.lfd.uci.edu/pythonlibs/t7epjj8p/Shapely-1.6.4.post2-cp38-cp38-win_amd64.whl Shapely.whl
#RUN pip install Shapely.whl
#
# Install mapproxy from git
#RUN pip install git+https://github.com/mapproxy/mapproxy.git@master

# CONDA section -------------- 
# Conda is great esp for Windows but the mapproxy package available there is 5 years out of date

# 64-bit Python 3.x on Linux
ADD https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh miniconda_install.sh
RUN sh miniconda_install.sh -b -p /usr/local/conda &&\

# 64-bit Python 3.x on Windows
#ADD https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe miniconda_install.exe
#RUN miniconda_install.exe

# Linux and Windows are the same from here on out, in theory.

RUN conda config --add channels conda-forge &&\
    conda install --file requirements.txt

#RUN conda install git &&\
#    git clone https://github.com/mapproxy/mapproxy.git &&\
#    cd mapproxy && python setup.py install

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

