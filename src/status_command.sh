# Displays when the containers had been started
containers=$(docker ps -qf "name=^skybox")

if [ "${containers}" ];
then
    for container_id in $containers;
    do
        values=$(docker inspect $container_id | grep StartedAt)
        echo "Container $container_id: $values" 
    done
else
    echo "No container running"
fi


