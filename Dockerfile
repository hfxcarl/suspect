#!/usr/bin/env -S docker build . --tag=openmrslab/hfxcarlos:v1.0.2 --network=host --file


## 1) - build docker image
## docker build -t openmrslab/hfxcarlos:v1.0.2 --file Dockerfile . 
## 2) -- run docker image
## docker run -p 8888:8888 --name notebook -v ./workdir:/home/jovyan/work -v ~/work/dempster/2022_GluEP/FSL_MRS_Analysis:/home/jovyan/data \
##    -v ~/OneDriveDalUni/PBIL/GE_Orchestra_SDK-2.1.1-20221109/orchestra-sdk-2.1-1.python:~/work/orchestra \
##    -e JUPYTER_ENABLE_LAB=yes --env-file .env -it openmrslab/hfxcarlos:v1.0.2

FROM jupyter/scipy-notebook:f3079808ca8c

## 
## base-image = https://github.com/jupyter/docker-stacks/blob/main/images/docker-stacks-foundation/Dockerfile
## 


LABEL maintainer="Carl Helmick <chelmick@dal.ca>"

## switch to root user
USER root

# cmake is used to build niftyreg
# gnupg2 is necessary to add the neurodebian apt-key to install fsl
# libxml2 and libxslt1 are for Tarquin
RUN apt-get update \
    && apt-get install -y curl wget tree git cmake gnupg2 libxml2-dev libxslt1-dev

## this seems to be important to prevent adding the key (below) failing sometimes
## https://github.com/f-secure-foundry/usbarmory-debian-base_image/issues/9#issuecomment-451635505
#RUN mkdir ~/.gnupg
#RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

RUN curl -sSL http://neuro.debian.net/lists/focal.us-nh.full | tee /etc/apt/sources.list.d/neurodebian.sources.list \
  && export GNUPGHOME="$(mktemp -d)" \
  && echo "disable-ipv6" >> ${GNUPGHOME}/dirmngr.conf \
  && (apt-key adv --homedir $GNUPGHOME --recv-keys --keyserver hkp://pgpkeys.eu 0xA5D32F012649A5A9 \
  || { curl -sSL http://neuro.debian.net/_static/neuro.debian.net.asc | apt-key add -; } ) \
  && apt-get update \
  && apt-get install -y git-annex-standalone git \
  && rm -rf /tmp/*


# install fsl-5
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install fsl-core \
    # Run configuration script for normal usage
    && echo ". /etc/fsl/5.0/fsl.sh" >> /home/$NB_USER/.bashrc
# Configure environment
ENV FSLDIR=/usr/share/fsl/5.0/
ENV FSLOUTPUTTYPE=NIFTI_GZ
ENV PATH=$PATH:/usr/lib/fsl/5.0
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/fsl/5.0

RUN apt-get install -y gcc-8 g++-8 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 8 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 8

RUN mkdir /opt/niftyreg-src && \
    mkdir /opt/niftyreg-build && \
    git clone https://github.com/KCL-BMEIS/niftyreg.git /opt/niftyreg-src
    #git clone https://cmiclab.cs.ucl.ac.uk/mmodat/niftyreg.git /opt/niftyreg-src
WORKDIR /opt/niftyreg-build
RUN PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && \
    cmake -D CMAKE_BUILD_TYPE=Release /opt/niftyreg-src && \
    make && \
    make install && \
    PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/fsl/5.0

# install tarquin
RUN wget --quiet https://sourceforge.net/projects/tarquin/files/TARQUIN_4.3.10/TARQUIN_Linux_4.3.10.tar.gz/download -O /tmp/tarquin.tar.gz && \
    mkdir /etc/tarquin && \
    tar -zxvf /tmp/tarquin.tar.gz -C /etc/tarquin --strip-components=1
ENV PATH /etc/tarquin:$PATH


# Switch back to jovyan
USER $NB_USER
WORKDIR /home/$NB_USER/work

## install LCModel
WORKDIR /home/$NB_USER/
RUN wget -qO- http://s-provencher.com/pub/LCModel/programs/lcm-64.tar | tar -xv -C $HOME
RUN tar xzf $HOME/lcm-core.tar.gz -C $HOME
RUN mkdir  -p  $HOME/.lcmodel/profiles/1
#RUN mv  $HOME/.lcmodel/gui-defaults      $HOME/.lcmodel/profiles/1/
#RUN mv  $HOME/.lcmodel/control-defaults  $HOME/.lcmodel/profiles/1/
RUN touch $HOME/.lcmodel/license
RUN rm -f $HOME/install-lcmodel $HOME/.uninstall-lcmodel $HOME/lcm-core.tar.gz $HOME/lcm-64.tar
COPY ./basis-sets /home/$NB_USER/.lcmodel/basis-sets


# copy the examples directory in to the notebook root and change the owner
COPY ./examples /home/$NB_USER/work/examples/
COPY ./siemens.py /home/$NB_USER/work/


RUN conda update -n base conda
RUN conda install pip
RUN pip install --upgrade pip
RUN pip install pyx 
RUN pip install nipype
RUN pip install pydicom
RUN pip install pylcmodel==0.3.3

## install fsl_mrs spec2nii
## from conda-forge:
##RUN conda install -c conda-forge -c defaults \
##              -c https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/public/
# from git
RUN git clone --recurse-submodules https://git.fmrib.ox.ac.uk/fsl/fsl_mrs.git && \
    cd ./fsl_mrs/ && \
    pip install .

## install suspect
RUN git clone https://github.com/hfxcarl/suspect.git && \
    cd ./suspect/ && pip install
##RUN git clone https://github.com/openmrslab/suspect.git /home/$NB_USER/suspect && \
##    pip install suspect==0.4.4

## define path where orchestra library will be mapped into
##   eg:  docker run -v ~/code/GE/orchestra-sdk-2.1.1.python:/home/joyvan/work/orchestra -it <container> 
ENV PYTHONPATH=/home/$NB_USER/work/orchestra

## we create a Python2 environment which is necessary for pygamma
#RUN conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 ipython ipykernel kernda backports.functools_lru_cache && \
#    conda clean -tipsy
#USER root
## Create a global kernelspec in the image and modify it so that it properly activates
## the python2 conda environment.
##RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install && \
#    $CONDA_DIR/envs/python2/bin/kernda -o -y /usr/local/share/jupyter/kernels/python2/kernel.json
#USER $NB_USER
#RUN /bin/bash -c "source activate python2 && pip install pygamma"

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}
WORKDIR "${HOME}"
