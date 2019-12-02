import waitress
from mapproxy.wsgiapp import make_wsgi_app
application = make_wsgi_app('/srv/mapproxy/config/mapproxy.yaml')

if __name__ == "__main__":
    import sys
    try:
        myport=sys.argv[1]
    except:
        myport=8080
    waitress.serve(application, threads=16, host='0.0.0.0', port=myport)
