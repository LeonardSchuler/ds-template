Consider changing the name of the environment in the environment.yml file before continuing.

1. Create the .env file, setup the conda environment and install the pre-commit hooks using
````
make
````
2. Activate your environment using
````bash
. .env
````


# Local deployment
````
docker-compose up
````
creates a Postgres container and an Airflow Webserver container.

## Resource Usage
I tested the resource usage on an Intel(R) Core(TM) i3-5005U CPU with a frequency of 2.00GHz under Kubuntu 18.04 LTS and kernel 4.15.0-121-generic.
After restarting the computer and starting the containers using
````
make airflow
````
I observed the following resource usage:
- The runnign containers use 400MiB of RAM
- An additional chromium tab for the webserver UI uses an additional 500 MiB of RAM
- 1 of my 4 cores runs at 100% usage
