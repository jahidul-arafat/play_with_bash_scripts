#!/bin/bash
mailSentFileFlag="mail_sent"
recipients="jahidapon@gmail.com,jarafat@harriswebworks.com"
status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:9200/_cluster/health)
if [[ ( "$status_code" -ne 200 ) && ( ! -f ${mailSentFileFlag} ) ]] ; then
  echo "Elasticsearch is down. Status code $status_code" | mailx -s "Elasticsearch Monitor" "$recipients"
  echo "yeah"
  touch ${mailSentFileFlag}
else
  exit 0
fi
