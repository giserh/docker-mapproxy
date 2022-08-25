import sys
import waitress
import os
from logging.config import fileConfig

logfile = sys.argv[1]

try:
    config  = sys.argv[2]
except:
    raise Exception("Config not found on command line.")
if not os.path.exists(config):
    raise Exception("Missing config file or directory")
multiservice = os.path.isdir(config)

fileConfig(logfile, {'here': os.path.dirname(__file__)})

if os.path.isdir(config):
    # The config is a directory, so
    # the MapProxy will start as a multi service
    # note that reloader option is not available here
    from mapproxy.multiapp import make_wsgi_app
    application = make_wsgi_app(config, allow_listing = True)
else:
    # For a simple service,
    # config should be a mapproxy.yaml file.
    from mapproxy.wsgiapp import make_wsgi_app
    application = make_wsgi_app(config, reloader = True)

waitress.serve(application, threads=16, host='0.0.0.0', port=8080)
