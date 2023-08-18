containers=$(docker ps -qf "name=^skybox")


if [ "${containers}" ]
then
    echo "Stopping containers..."
    docker stop $containers
else
    echo "No containers found"
fi

