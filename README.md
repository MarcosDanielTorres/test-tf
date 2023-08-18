<h1 align="center">
  <img src="images/logo.jpg" alt="Skybox Logo" width=200 />
</h1>


## Index
- [**Introduction**](#introduction)
- [**Structure**](#structure)
- [**Getting Started**](#getting-started)
- [**Usage**](#usage)
- [**Design Considerations**](#design-considerations)
- [**Screenshots**](#screenshots)
# Introduction
This repository corresponds to the challenge Skybox provided for the DevOps Engineer position.


The cluster has been set up using [Terraform], the [Terraform Provider for Docker], and bash for shell scripting. It can be scaled up horizontally with the help of a Load Balancer implemented through [Nginx], which uses round-robin and weighted round-robin algorithms to route traffic. It also supports stop, starts, delete, and status commands.

## Structure
-  `src/`: This directory includes the source code used to create the "cluster" script. The structure was established by running "bashly init" since the script was developed with its aid.
-  `template/`: In this folder, you'll find templates for creating the load balancer and web services. Once you open it, you'll notice a string that reads "REPLACEME". Keep this in mind as it will be useful when installing the cluster later on.
-  `build/`: 
-  `main.tf`: The entry point of terraform. It reads the values from the `build/` folder in order to generate the corresponding infraestructure.
-  `cluster`: Script generated using Bashly. It's been created using the files under `src/`

## Getting Started

1. Install [Terraform].
2. Install [Docker].
3. Clone the project: `git clone https://github.com/MarcosDanielTorres/skybox-challenge`
4. Run `terraform init`
5. Before running the cluster, the load balancer alwasy runs on port 8080 and the web-services run in ports 8000-8000 + n. Please ensure you have the required ports available.
6. To set up the cluster, simply run the command `./cluster install`. If you wish to specify the number of nodes to deploy, you may do so optionally (the default is 2). You should, preferably, only use the cluster script to manage the infrastructure.
7. After step number 5. If you encounter an error about the docker provider when `terraform apply` is running. You might need to specify the host of the docker provider under:
```
main.tf
provider "docker"{
  host = "...COMPLETE HERE..."
}
```
It may be useful to run `docker context ls`. (sometimes the host line can be empty, it will depend on the type of docker installation, in my case I use docker-desktop and it messed up for me on Linux but not on Windows.)

8. After step 6 just go to `localhost:8080` and optionally run `docker ps` to check the infrastructure.
   
9. If you want to explore the bash script. Go to `src/` folder. There, you will find the different variations of the `cluster` script. Bashly basically lets you modularize the creation of the script and when you run bashly generate it generates one single file (the cluster script in this case).

10. Running ./cluster --help gives you a list of all possible commands. But to sum them up:
  -  ./cluster install 4        Installs 4 web services and a load balancer. The load balancer is always included, making a total of 5 containers.
  -  ./cluster stop             The command "stop" will halt all containers currently in operation within the cluster.
  -  ./cluster start            This command will initiate all containers that are currently stopped within the cluster.
  -  ./cluster status           It displays details on the running containers' status.
  -  ./cluster delete           Removes all created resources.
### Optional step:
The `cluster` is a script created using [Bashly]. If you wish to regenerate the script you need to have `bashly` installed. Please refer to the official documentation for details. `bashly generate` creates the script named `cluster`.


## Design Considerations
Some of the design decisions to solve the challenge are briefly detailed.

I didn't use docker-compose because the instructions said that I needed to use the [Terraform Provider for Docker] which is the same it's used in the official documentation. This provider doesn't have the ability to incorporate docker-compose. If I had used docker-compose the networking component may have been easier. But still, the docker-compose.yml must have been created dynamically and I figured doing this was not the point of the challenge. So I went with creating multiple docker containers all running inside a network called `skybox-network` to be able to communicate (having everything on the `bridge` as it is by default in Docker, doesn't work for communicating using the name of the container inside `nginx.conf`).

Every web service run inside a nginx container with its custom index.html file. To make this happen I've created a template folder where I stored templates for different images. When I run `./cluster install n` the script creates n folders corresponding to each web service inside the `build/` folder. Doing this allows me to have different versions for each microservice if needs be, so every service can have a different Dockerfile that defines it.
Please check the `templates/` folder, in there you can see (in some of the files) a string called "REPLACEME" that will later get replaced when running `./cluster install n`.

I have decided to use Nginx for both the balancer and the web services. Nginx by default uses round-robin as requested in the instructions. 

Following below is the basic configuration of the load balancer:
```
http {
    upstream all {
        REPLACEME
    }

    server {
        listen 8080;
        location / {
            proxy_pass http://all/;
        }
    }
}

events {}
```

After `./cluster install n`:
```
http {
    upstream all {
        server skybox-ws-1 weight=3;
        server skybox-ws-2;
        server skybox-ws-3;
    }

    server {
        listen 8080;
        location / {
            proxy_pass http://all/;
        }
    }
}

events {}
```


If you navigate to `src/` you can find the different variations of the `cluster` script.



## Screenshots
Please, go to `images/` where you can find screenshots of the application running with 5 nodes (./cluster install 5)




[Terraform]: https://nodejs.org
[Docker]: https://www.docker.com/
[Nginx]: https://www.nginx.com
[Bashly]: https://bashly.dannyb.co
[Terraform Provider for Docker]: https://github.com/kreuzwerker/terraform-provider-docker
