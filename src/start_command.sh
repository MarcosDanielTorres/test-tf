containers=$(docker ps -qaf "name=^skybox" -f "status=exited")
if [ "${containers}" ]
then
    echo "Starting containers... "
    docker start $containers 
else
    echo "No containers stopped found. Either run \`cluster install\` to setup the cluster or the containers are already running"
fi
