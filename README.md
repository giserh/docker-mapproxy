# docker-mapproxy

## What this is

We're running MapProxy in Docker so that we can build a cascading WMS
with several servces hosted remotely and have them cache here in a
volume mapproxy/cache_data.

"Cascading" means one service can have several layers each living in a different remote place.

## Configure

Make a volume and put the config files into it,
Make a folder called mapproxy here.
The docker will store its files there.
That way you can configure it.

   docker volume create --name=mapproxy_data

If it's empty the first time you start mapproxy it will write sample config files in there.

### Check the config

   docker-compose config

## How to run it

   docker-compose up

