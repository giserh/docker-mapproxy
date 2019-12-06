# docker-mapproxy

## What this is

MapProxy in Docker is used to build a cascading WMS with several
services hosted remotely. The included configuration works with a
public server located in Oregon.

The tiles are cached in a tile store; this project uses CouchDB for storage.

This version of the project uses Docker Compose; the next version will
use Docker Swarm instead, so that the containers can be on different
servers.

The docker-compose.yml file will set up both MapProxy and CouchDB
docker containerss and link them together over a private docker
network called 'couchdb_net'.

## Build

We use the standard couchdb image but build our own mapproxy image
because we want maximum portability, as soon as the ink is dry here
we're going to add support for Docker For Windows.

    docker build -t wildsong/mapproxy .

or if you prefer

    docker-compose build

### Note on git version

There's a bug in 1.12 mapproxy so the Dockerfile pulls newer source from git.
To see the bug, do this in python 3.8 (it won't affect older pythons).

    import mapproxy.compat.modules
    mapproxy.compat.modules.__dir__()

The output should show the 'escape' function is available, but fails
in the released 1.12.  I plan on using the released package at 1.13.

## Configure

The default in the example is to use multiple services. That's defined in the files
globals.yaml, city-aerials.yaml and county-aerials.yaml.

You can edit the start_mapproxy.py and use mapproxy.yaml if you want a
single service only.

### Set up .env

Copy sample.env to .env and edit it with your own information.

The first time you run, docker will create a mapproxy_files volume and
put the default mapproxy.yaml into it, under config/. Refer to the
mapproxy.org documentation on the files that could go in there.

I will put some sample files in examples/ for you.

### Check this project's config

   docker-compose config

## How to run it

The command

   docker-compose up

will start containers for MapProxy and CouchDB.

### Set up CouchDB

The "up" command will bring up mapproxy and couchdb, but you have to tell couchdb
that this is a single-node set up so that it will create its system databases.

Use Fauxton to see the setup and make adjustments

    http://localhost:5984/_utils#setup

(Of course, substitute the appropriate value for localhost.) You get a page
where all you need do is click "Configure a single node". While you are in there
set the admin user and password.

You will need to create two databases for couchdb to work with the example mapproxy.yaml file:
astoria2015 and osip2018. You can do this through Fauxton or if you want to try out REST,
use curl commands like this for instance

    for SVC in osip2018 naip2016 naip2009 naip2000 naip1995 astora2015; do
      curl -X PUT http://localhost:5984/$SVC

If you start the components running and don't have the databases set up, you will get
errors logged from the database container when MapProxy tries to send tiles to CouchDB.
You can create them anytime and the errors will stop; that is, it won't hurt anything
to start everything running before creating the databases. (There is no reason to start
the database first, create the databases, and then start MapProxy.)

## How to seed the cache

Edit the seed.yaml in config to match your requirements. It's set up for the osip2018 example.
(You need to edit the copy that's in the Docker volume. In my case as root I edit
/home/docker/volumes/mapproxy_files/_data/seed.yaml.)

Start a shell connection to the running docker for mapproxy.

   docker exec -it mapproxy bash

Run the seed command. (The "-c 4" says use 4 processes)

   cd config
   mapproxy-seed -c 4 -f mapproxy.yaml -s seed.yaml

On Linux you could run it in background.

There are some other potentially useful options such as --continue
and --progress-file. RTFM: https://mapproxy.org/docs/nightly/seed.html

I think it might make sense to run the seed process in a separate container,
there's no reason it has to be in the same one with mapproxy. Since it's
storing tiles into couch_db it does not even have to run on the same server.

## TO DO LIST

As of 2019-Dec-06

I was reading the "Production" section of the MapProxy docs and learned one of their
recommended setups is to use waitress as the server, which is what I do here, but that
they recommend putting waitress behind a web proxy, for example nginx or varnish.

I am looking into this more but yesterday I found that putting
waitress behind nginx prevented me from creating services in ArcGIS
Enterprise. (SHOWSTOPPER for me!) Just a warning. I will look at it again...

TODO: Add Windows support, I've had this in mind all along, should not be TOO hard... ha...
it's why I use miniconda as the base container and waitress instead of gunicorn as the server.

TODO; Fauxton should be using the user/pass from .env but appears to
ignore that and starts in admin party mode.  Maybe running in party
mode is okay if I restrict access to the docker network? It qvetches
in the log though until you create a user. Possibly the environment is
not set correctly on startup??

TODO: Currently you must manually create databases to hold the tiles.
Maybe I should automate it?

TODO: Add example using MapProxy without CouchDB.

TODO: Show how to use MapProxy and CouchDB on different servers. (SWARM!)

