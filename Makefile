.PHONY: all conda-env describe-env pre-commit test rm-conda-env


CONDABASEDIR = $(shell conda info --base)
CONDAENVFILENAME = environment.yml


CONDAENVNAME := $(shell grep name $(CONDAENVFILENAME) | head -n 1 | cut -d " " -f 2)
CONDAENVBINDIR = $(CONDABASEDIR)/envs/$(CONDAENVNAME)/bin

# $(CONDAENV) for using the variable

all : .env conda-env pre-commit

conda-env: .env
	conda env remove -n $(CONDAENVNAME)
	conda env create -f $(CONDAENVFILENAME)
	echo "Activate your environment using: $$ . .env"

rm-conda-env:
	conda env remove -n $(CONDAENVNAME)

describe-conda-env:
	echo Environment name: $(CONDAENVNAME)
	echo Environment specification found in: $(CONDAENVFILENAME)
	echo "Activate your environment using: $$ . .env"

pre-commit:
	$(CONDAENVBINDIR)/pre-commit install
	$(CONDAENVBINDIR)/pre-commit autoupdate

.env:
	echo "conda activate $(CONDAENVNAME)" >> .env
