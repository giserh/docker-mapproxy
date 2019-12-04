import sys
import waitress
import os.path
from logging.config import fileConfig
from mapproxy.wsgiapp import make_wsgi_app

logfile    = sys.argv[1]
configfile = sys.argv[2]

fileConfig(logfile, {'here': os.path.dirname(__file__)})

try:
    myport = sys.argv[3]
except:
    myport=8080


application = make_wsgi_app(configfile)
waitress.serve(application, threads=16, host='0.0.0.0', port=myport)
