# docker-mapproxy

There's a bug in 1.12 mapproxy so I have to install from git.
To see the bug, do this in python

    import mapproxy.compat.modules
    mapproxy.compat.modules.__dir__()

The output should show the 'escape' function but fails in the released 1.12

## What this is

We run MapProxy in Docker so that we can build a cascading WMS
with several services hosted remotely and have them cached here.

We use couchdb as the tile store; the current mapproxy.yaml
uses couchdb for now.

The docker-compose.yml file will set up both mapproxy and couchdb
docker containerss and link them together over a private docker
network called 'couchdb_net'.

## Build

We use the standard couchdb image but build our own mapproxy image
because we want maximum portability, as soon as the ink is dry here
we're going to add support for Docker For Windows.

    docker build -t wildsong/mapproxy .

or if you prefer

    docker-compose build

## Configure

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
use curl commands like this

    curl -X PUT http://localhost:5984/osip2018
    curl -X PUT http://localhost:5984/astoria2015

TODO: Add Windows support

TODO; Fauxton should be using the user/pass from .env but appears to ignore that and starts in admin party mode.
Maybe running in party mode is okay if I restrict access to the docker network? It qvetches in the log though
until you create a user.

TODO: Currently you must connect to Fauxton and create databases to hold the tiles.
I should automate it.

TODO: Add example using MapProxy without CouchDB.

TODO: Show how to use MapProxy and CouchDB on different servers.


