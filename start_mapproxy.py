import sys
import waitress
import os.path
from logging.config import fileConfig

logfile = sys.argv[1]
config  = sys.argv[2]

fileConfig(logfile, {'here': os.path.dirname(__file__)})

try:
    myport = sys.argv[3]
except:
    myport=8080

# This version starts the multi service, config should be a directory.
from mapproxy.multiapp import make_wsgi_app
application = make_wsgi_app(config, allow_listing = True)

# This version starts just one, config should be a mapproxy.yaml file.
#from mapproxy.wsgiapp import make_wsgi_app
#application = make_wsgi_app(config, allow_listing = True)

waitress.serve(application, threads=16, host='0.0.0.0', port=myport)
