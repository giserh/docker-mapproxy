#!env bash
#
# Read the database names from all the YAML files here,
# find database names, and create CouchDB databases for them.
# (If a database already exists, ignore it and press on.)

# Get username and password
source .env

for SVC in `grep db_name: *yaml | sed -e 's/.*db_name: //g'`
do
    echo $SVC
    curl -X PUT -u $DB_USER:$DB_PASSWORD http://localhost:5984/$SVC
done
