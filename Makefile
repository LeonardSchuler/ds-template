.PHONY: all clean conda-env deployment describe-env install-services pre-commit start-services stop-services test rm-conda-env


CONDABASEDIR = $(shell conda info --base)
CONDAENVFILENAME = environment.yml


CONDAENVNAME := $(shell grep name $(CONDAENVFILENAME) | head -n 1 | cut -d " " -f 2)
CONDAENVBINDIR = $(CONDABASEDIR)/envs/$(CONDAENVNAME)/bin

SERVICES ?= https://github.com/LeonardSchuler/docker-compose-airflow

# $(CONDAENV) for using the variable

all : conda-env pre-commit .activate_conda_env .env install-services


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

install-services: clean
	mkdir .deployment
	for SERVICE in $(SERVICES); do \
		echo "Installing $$SERVICE"; \
		cd .deployment/ && git clone $$SERVICE; \
	done

start-services:
	for SERVICE in $(shell ls -d .deployment/*/); do \
		echo "Starting $$SERVICE"; \
		cd $$SERVICE  && make start; \
	done

stop-services:
	for SERVICE in $(shell ls -d .deployment/*/); do \
		echo "Stopping $$SERVICE"; \
		cd $$SERVICE  && make stop; \
	done

clean-services: stop-services
	for SERVICE in $(shell ls -d .deployment/*/); do \
		echo "Delete data of $$SERVICE"; \
		cd $$SERVICE  && make clean; \
	done

clean:
	sudo rm -fR .deployment
