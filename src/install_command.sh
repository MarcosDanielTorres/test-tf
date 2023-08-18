# Gets the value of the argument, if no argument was supplied defaults to 2
eval "nodes=(${args[nodes]})"

# Creates the required folders where container specific info is going to go.
mkdir -p build/load_balancer
mkdir -p build/web-servers

# Copy contents of the load_balancer's template to the build folder
cp -r templates/load_balancer/* build/load_balancer

# When it defaults to two go with 3 to 1
if [ "$nodes" = "2" ];
then
   sed -i "s/REPLACEME/server skybox-ws-1 weight=3;\n\tREPLACEME/g" build/load_balancer/nginx.conf
   sed -i "s/REPLACEME/server skybox-ws-2;/g" build/load_balancer/nginx.conf
fi

for i in $(seq $nodes);
do
   echo "Configuring node number: $i ..."
   eval ws=ws-${i}
   mkdir -p build/web-servers/$ws
   cp templates/web-server/* build/web-servers/$ws
   sed -i "s/REPLACEME/$ws/g" build/web-servers/$ws/index.html 


   if [ "$nodes" != "2" ];
   then
       echo "Adding entry in load balancer"
       sed -i "s/REPLACEME/server skybox-$ws;\n\tREPLACEME/g" build/load_balancer/nginx.conf
   fi
done

echo "Nodes configuration has finished successfully!"

# Cleanup
sed -i "s/REPLACEME//g" build/load_balancer/nginx.conf


terraform apply -var size=$nodes
