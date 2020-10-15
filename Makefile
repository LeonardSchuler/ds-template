.PHONY: all conda-env describe-env pre-commit test rm-conda-env rm-airflow airflow stop-airflow


CONDABASEDIR = $(shell conda info --base)
CONDAENVFILENAME = environment.yml


CONDAENVNAME := $(shell grep name $(CONDAENVFILENAME) | head -n 1 | cut -d " " -f 2)
CONDAENVBINDIR = $(CONDABASEDIR)/envs/$(CONDAENVNAME)/bin

# $(CONDAENV) for using the variable

all : conda-env pre-commit .activate_conda_env .env .local_deployment airflow

conda-env: .activate_conda_env
	conda env remove -n $(CONDAENVNAME)
	conda env create -f $(CONDAENVFILENAME)
	echo "Activate your environment using: $$ . .activate_conda_env"

rm-conda-env:
	conda env remove -n $(CONDAENVNAME)

describe-conda-env:
	echo Environment name: $(CONDAENVNAME)
	echo Environment specification found in: $(CONDAENVFILENAME)
	echo "Activate your environment using: $$ . .activate_conda_env"

pre-commit:
	$(CONDAENVBINDIR)/pre-commit install
	$(CONDAENVBINDIR)/pre-commit autoupdate

.activate_conda_env:
	echo "conda activate $(CONDAENVNAME)" >> .activate_conda_env

.env:
	mkdir -p ENV/local
	touch ENV/local/.env
	ln -s ENV/local/.env .env

.local_deployment:
	mkdir .local_deployment/
	mkdir -p .local_deployment/airflow/logs
	mkdir -p .local_deployment/postgres/data
	chmod -vR 700 .local_deployment/airflow
	chmod -vR 700 .local_deployment/postgres
	# 50000 is the default user in the airflow image and 999 the postgres user
	sudo chown -vR 50000:50000 .local_deployment/airflow && sudo chown -vR 999:999 .local_deployment/postgres

rm-airflow:
	sudo rm -vfR .local_deployment

airflow: .local_deployment
	docker-compose up -d

stop-airflow:
	docker-compose down
