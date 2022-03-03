# docker-mapproxy

## What this is

MapProxy in Docker is used to build a cascading WMS with several
services hosted remotely. The included configuration works with a
public server located in Oregon.

The tiles are cached in a tile store; I've switched from using CouchDB
to SQLite. There is now only one container, so there are never any
connection problems. The CouchDB code is still hanging around,
should anyone want to revive it.

This version of the project uses either Docker Compose (for testing)
or Docker Swarm (for production). As I only do small projects I have
generally given up on Docker Swarm as too complicated for my needs.

The docker-compose.yml will set up a single container, containing mapproxy.

The docker-compose-couchdb.yml file (which might not work any more)
will set up both MapProxy and CouchDB
docker containers and link them together over a private docker network.

ArcGIS servers refuse to connect to unencrypted WMS services (HTTP).
I get around this by running MapProxy behind an nginx server. The
Dockerfile.mapproxy and Docker Compose files here work with the proxy
described in my github repository Wildsong/proxy.

## Build

You can build locally but Github Actions will build and push an image to Docker Hub. Skip ahead.

First customize a .env file, then build an image.

```bash
cp sample.env .env
emacs .env
docker buildx build -t wildsong/mapproxy .
```

### Note on git version

There's a bug in 1.12 mapproxy so the Dockerfile pulls
newer source from git.
To see the bug, do this in python 3.8 (it won't affect older pythons).

    import mapproxy.compat.modules
    mapproxy.compat.modules.__dir__()

The output should show the 'escape' function is available, but fails
in the released 1.12.  I plan on using the released package at 1.13,
when it comes out.

## Configure

The default in the example is to use multiple services. That's defined
in the files globals.yaml, city-aerials.yaml and county-aerials.yaml.

The next version will use a separate mapproxy container for each service.

You can edit the start_mapproxy.py and use mapproxy.yaml if you want a
single service only.

### Check this project's config

```bash
docker-compose config
```

## How to run it

These commands work,

```bash
docker-compose up
```

or

```bash
docker stack deploy -c docker-compose.yml mapproxy
```

### Set up CouchDB

I am not using CouchDB right now, this is here should I switch back to it.

The "deploy" command will bring up mapproxy and couchdb, but the first
time it starts you will have to tell couchdb that this is a
single-node set up so that it will create its system databases.
You do this in Fauxton, see Admin section below.

I have not been able to get authentication working which means
I am forced to run CouchDB 2,x, which has "party mode" with no admin
password. At 3.0 party mode is gone, as a security measure. If you don't
configure it CouchDB will log this message and die.  I will eventually
set it in docker-compose.yaml via environment settings,
and you have to customize your .env file.

    *************************************************************
    ERROR: CouchDB 3.0+ will no longer run in "Admin Party"
           mode. You *MUST* specify an admin user and
	   password, either via your own .ini file mapped
    	   into the container at /opt/couchdb/etc/local.ini
    	   or inside /opt/couchdb/etc/local.d, or with
    	   "-e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password"
           to set it via "docker run".
    *************************************************************

### Run CouchDB standalone

I had to do this because my configuration was wrong and the deploy command
kept cycling it endlessly. So I used this to test it.

    docker run -it --rm -e COUCHDB_USER=${DB_USER} -e COUCHDB_PASSWORD=${DB_PASSWORD} -v db_data:/opt/couchdb/data -p 5984:5984 couchdb:latest

### Admin and creating databases

You can use Fauxton to see the setup and make adjustments,

    http://localhost:5984/_utils/#/setup

Click "Configure a single node". This will also create the _users database,
silencing that annoying message in the logs.

You can create databases for couchdb to work with the example
mapproxy.yaml file, you can do this through Fauxton or if you want to
try out REST, use curl commands like this for instance (see also
create_databases.sh)

    for SVC in `grep db_name: *yaml | sed -e 's/.*db_name: //g'` ; do
      curl -X PUT http://localhost:5984/$SVC
    done
    
If you start the components running and don't have the databases set
up, you will get errors logged from the database container when
MapProxy tries to send tiles to CouchDB.  You can create them anytime
and the errors will stop; that is, it won't hurt anything to start
everything running before creating the databases. (There is no reason
to start the database first, create the databases, and then start
MapProxy.)

## Use a tile package from ArcGIS Pro

In Pro, use the geoprocessing tool "Create Map Tile Package". This
will create a file with a "tpkx" extension.

You have to unzip it (it's just a .zip archive with a different
extension.) and then copy the files into the volume called
mapproxy_cache. Then you have to set up a configuration file for
it. My sample config file is "bulletin78_79.yaml" and there are some
tips there on how to do the unzip step straight into the Docker
volume.

## How to seed the cache

NOTE, I have not done much testing in this area yet.

Edit the seed.yaml in config to match your requirements. It's set up
for the osip2018 example.  (You need to edit the copy that's in the
Docker volume. In my case as root I edit
/home/docker/volumes/mapproxy_files/_data/seed.yaml.)

Start a shell connection to the running docker for mapproxy.

```bash
docker exec -it mapproxy bash
```

Run the seed command. (The "-c 4" says use 4 processes)

```bash
cd config
mapproxy-seed -c 4 -f mapproxy.yaml -s seed.yaml
```

On Linux you could run it in background.

There are some other potentially useful options such as --continue
and --progress-file. RTFM: https://mapproxy.org/docs/nightly/seed.html

It might make sense to run the seed process in a separate container,
there's no reason it has to be in the same one with mapproxy. Since
it's storing tiles into couch_db it does not even have to run on the
same server.

## Updating the configuration

The configuration files are mounted from the config/ directory.
    
I suppose you need to restart MapProxy to get it to reread the change.

```bash
docker-compose restart
```

or

```bash
docker stack rm mapproxy
docker stack deploy -c docker-compose.yml mapproxy
```

If you are using CouchDB remember to empty the appropriate cache
database(s) in CouchDB so that they will get new data.

## Credits

There are other Docker projects built for MapProxy. I wanted one that
could be ported to Windows (Docker for Windows). I am not there yet.
I also wanted to be able to spin up the MapProxy/CouchDB combination
easily.

Links to some of the code I use

* MapProxy https://mapproxy.org
* CouchDB https://couchdb.apache.org
* Conda https://anaconda.org (I use a version of miniconda)
* Waitress https://github.com/Pylons/waitress

## TO DO LIST

2020-Aug-29

I have a docker-compose set up running that works for 24-48 hours and then suddenly,
it stops resolving couchdb so the data connection fails and it's dead. Rather than
wrestle with it I have switched to SQLite. I have implemented a healthcheck too.

As of 2020-Aug-19

I am stuck at couchdb 2.3.x because user/pass keeps mapproxy out in 3.x
FIGURE OUT AUTH, mapproxy has to send credentials to couchdb,
or stop using couch I suppose. :-(

I stopped working on a Windows Server version because it was just
easier to get a Debian container running. We have the best IT staff in
the world here in Clatsop County.

TODO: Currently you must manually create databases to hold the tiles.
Maybe I should automate it?

TODO: Show how to use MapProxy and CouchDB on different servers. (SWARM!)

TODO: Configure a separate container for each service instead of using the
mapproxy multiple service feature. EG

Currently I have 3 services visible all in one container, 

* https://mapproxy.wildsong.biz/bulletin
* https://mapproxy.wildsong.biz/aerials
* https://mapproxy.wildsong.biz/lidar

Instead those should be in separate containers so that I can work on
them independently.  To do this I have to figure out the nginx
changes. This will help a lot at CC anyway since I have limited access
to DNS.

First time start, create the databases, see
https://docs.couchdb.org/en/stable/setup/single-node.html

```bash
curl -X PUT http://127.0.0.1:5984/_users
curl -X PUT http://127.0.0.1:5984/_replicator
curl -X PUT http://127.0.0.1:5984/_global_changes
```

Admin accounts go into a text file called local.ini not a database, see
https://docs.couchdb.org/en/stable/config/auth.html#config-admins

