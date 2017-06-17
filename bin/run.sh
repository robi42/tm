#!/bin/sh

CWD=`dirname "$0"`
JAVA_OPTS="-Xms128m -Xmx1024m"

export NODE_ENV="production"

(sleep 60 && open http://localhost:4000) &
echo "Opening browser window at localhost:4000 in one minute."

# Start frontend (in the background).
(cd ${CWD}/../src/frontend && npm start) &

# Start backend (as main process).
sh -c "java $JAVA_OPTS -jar $CWD/temp-munger.jar"
