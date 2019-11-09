== What this is

We're running MapProxy in Docker so that we can build a cascading WMS
with several servces hosted remotely and have them cache here in a
volume mapproxy/cache_data.

== Configure

Make a folder called mapproxy here.
The docker will store its files there.
That way you can configure it.

== How to run it

Build -- not strictly necessary, all it does is a pull

   make build

Run as a daemon

   make run

