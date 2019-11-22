all:

build:
	docker pull kartoza/mapproxy

run:
	docker run -d -t -p  8081:8080 -v ${PWD}/mapproxy:/mapproxy --name=mapproxy kartoza/mapproxy

clean:
	docker stop mapproxy
	docker rm mapproxy
