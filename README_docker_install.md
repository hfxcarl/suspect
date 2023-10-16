---
title: suspect in docker
---


## Build docker image
 
 `docker build -t openmrslab/hfxcarlos:v1.0.2 --file Dockerfile .`

## Run docker image
  
 `docker run -p 8888:8888 --name notebook -v ./workdir:/home/jovyan/work -v ~/project/data:/home/jovyan/data \ -v ~/project/tools/orchestra-sdk-2.1-1.python:/home/jovyan/work/orchestra \ -e JUPYTER_ENABLE_LAB=yes -it openmrslab/hfxcarlos:v1.0.2`


Install Suspect from Source (highly recommended)
  
 `git clone https://github.com/hfxcarl/suspect.git && cd ./suspect/ && pip install .`

