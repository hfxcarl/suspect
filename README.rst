suspect
-------

============ =================
Travis CI    |build_status|
Coveralls    |coverage_status|
Code Climate |code_climate|
============ =================

.. |build_status| image:: https://travis-ci.org/openmrslab/suspect.svg?branch=master
    :target: https://travis-ci.org/openmrslab/suspect

.. |coverage_status| image:: https://coveralls.io/repos/github/openmrslab/suspect/badge.svg?branch=master
    :target: https://coveralls.io/github/openmrslab/suspect?branch=master

.. |code_climate| image:: https://codeclimate.com/github/openmrslab/suspect/badges/gpa.svg
   :target: https://codeclimate.com/github/openmrslab/suspect

Suspect is a Python package for processing MR spectroscopy data. It supports reading data from most common formats (with more on the way) and many different algorithms for core processing steps. Suspect allows researchers to build custom data processing scripts from reliable, modular building blocks and easily share their techniques with other labs around the world.

Installation
^^^^^^^^^^^^

Suspect itself is a pure Python package and is easy to install with `pip`_. However it does depend on various other packages, some of which are not so easy to install.

1. Obtain Python and the SciPy stack:

   Suspect requires Python 3 and makes heavy use of numpy and other parts of the Scientific Python stack. The easiest way to obtain this, along with a large number of other useful scientific packages, is to download the free Anaconda_ package. Alternatively check here_ for other ways to install these core packages.

2. Install suspect

   ``pip install suspect`` will automatically download and install the latest version of suspect, along with all remaining other dependencies.

.. _pip: https://pip.pypa.io/en/stable/
.. _pydicom: https://pydicom.readthedocs.io/en/stable/index.html
.. _Anaconda: https://www.continuum.io/downloads
.. _here: http://www.scipy.org/install.html


Install from Source (highly recommended)
```git clone https://github.com/hfxcarl/suspect.git && \
       cd suspect/ && pip install .```

## Build docker image
`docker build -t openmrslab/hfxcarlos:v1.0.2 --file Dockerfile . `

## Run docker image
`
echo "" >>docker-env.txt
docker run -p 8888:8888 --name notebook -v ./workdir:/home/jovyan/work -v ~/work/dempster/2022_GluEP/FSL_MRS_Analysis:/home/jovyan/data \
    -v ~/OneDriveDalUni/PBIL/GE_Orchestra_SDK-2.1.1-20221109/orchestra-sdk-2.1-1.python:/home/jovyan/work/orchestra \
    -e JUPYTER_ENABLE_LAB=yes --env-file docker-env.txt -it openmrslab/hfxcarlos:v1.0.2
`


Getting Started
^^^^^^^^^^^^^^^

Suspect is still a young package and we are working hard to get useful examples out there. Documentation for the project is available at http://suspect.readthedocs.io/en/latest/

Contributing
^^^^^^^^^^^^

If you are interested in helping out with any part of suspect or the OpenMRSLab project, we would love to hear from you.

License
^^^^^^^

Suspect is released under the MIT license
