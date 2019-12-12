source .env
for SVC in `grep db_name: *yaml | sed -e 's/.*db_name: //g'`
do
    echo $SVC
    curl -X PUT -u $DB_USER:$DB_PASSWORD http://localhost:5984/$SVC
done
