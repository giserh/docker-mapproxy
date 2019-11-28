import waitress
from mapproxy.wsgiapp import make_wsgi_app
application = make_wsgi_app('/srv/mapproxy/config/mapproxy.yaml')

if __name__ == "__main__":
    waitress.serve(application, threads=16, host='0.0.0.0', port=8080)
