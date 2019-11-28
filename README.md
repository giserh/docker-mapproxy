# docker-mapproxy

This is a good way to test MapProxy but probably not good in productions
since MapProxy is a WSGI app; you should probably run it directly in nginx.

## What this is

We're running MapProxy in Docker so that we can build a cascading WMS
with several servces hosted remotely and have them cache here in a
volume mapproxy_data/cache_data.

"Cascading" means one service can have several layers each living in a different remote place.

I plan to use couchdb as the tile store. The docker-compose.yml file will set up both mapproxy
and couchdb dockers and link them together over a private docker network called 'couchdb_net'.

## Build

    docker build -t wildsong/mapproxy .

or if you prefer

    docker-compose build

## Configure

### Set up .env

Copy sample.env to .env and edit it with your own information.

### Make a volume.

   docker volume create --name=mapproxy_data

Copy example files into the volume.
That is, copy the files from mapproxy-docker/examples/config/* to the new volume.

Edit the configuration files.
The docker will store its files in the cache_data subdirectory.

### Check this project's config

   docker-compose config

## How to run it

   docker-compose up

### Set up CouchDB

The "up" command will bring up mapproxy and couchdb, but you have to tell couchdb
that this is a single-node set up so that it will create its system databases.

    http://localhost:5984/_utils#setup

(Of course, substitute the appropriate value for localhost.) You get a page
where all you need do is click "Configure a single node". While you are in there
set the admin user and password.




