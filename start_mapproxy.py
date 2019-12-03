import sys
import waitress
from mapproxy.wsgiapp import make_wsgi_app

configfile = sys.argv[1]
try:
    myport = sys.argv[2]
except:
    myport=8080

print("Starting mapproxy with config file=%s at port=%s" % (configfile, myport))
application = make_wsgi_app(configfile)
waitress.serve(application, threads=16, host='0.0.0.0', port=myport)
