## Mapproxy

Mapproxy is a service to proxy and cache WMS map services.

(Actually it does **a lot more than that**. See the link under "Thanks")

## How to run Mapproxy in Docker.

```bash
docker run -d --name=mapproxy \
-p 8080:8080 \
-v ./config:/srv/mapproxy/config:ro -v cache:/srv/mapproxy/cache \
wildsong/mapproxy:latest /srv/mapproxy/config/services
```

## Project status 2022-03-02

I added the Github Action today to build and push to Docker Hub, 
let's see how that goes.

## Github repository

See the repository at https://github.com/Wildsong/docker-mapproxy

## Author

Brian Wilson [bwilson@wildsong.biz](mailto:brian@wildsong.biz)

## Thanks

Of course to the [Mapproxy](https://mapproxy.org) team first of all.

This Docker image is pushed from a Github action via the modern convenience of mr-smithers-excellent/docker-build-push.

This README is uploaded from Github README.docker.md via the marvel of peter-evans/dockerhub-description.
