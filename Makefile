PYTHON=python3

PYTHON_ENV_ROOT=envs
PYTHON_PACKAGING_VENV=$(PYTHON_ENV_ROOT)/$(PYTHON)-packaging-env
PYTHON_TESTING_ENV=$(PYTHON_ENV_ROOT)/$(PYTHON)-qa-env

.PHONY: clean

# packaging environment #######################################################
$(PYTHON_PACKAGING_VENV)/.created: REQUIREMENTS.packaging.txt
	rm -rf $(PYTHON_PACKAGING_VENV) && \
	$(PYTHON) -m venv $(PYTHON_PACKAGING_VENV) && \
	. $(PYTHON_PACKAGING_VENV)/bin/activate && \
	pip install --upgrade pip && \
	pip install -r REQUIREMENTS.packaging.txt
	date > $(PYTHON_PACKAGING_VENV)/.created

packaging-env: $(PYTHON_PACKAGING_VENV)/.created

sdist: packaging-env
	. $(PYTHON_PACKAGING_VENV)/bin/activate && \
	rm -rf dist *.egg-info && \
	./setup.py sdist

_release: sdist
	. $(PYTHON_PACKAGING_VENV)/bin/activate && \
	twine upload dist/*

# helper ######################################################################
clean:
	rm -rf $(PYTHON_ENV_ROOT)

envs: env packaging-env

# testing #####################################################################
$(PYTHON_TESTING_ENV)/.created: REQUIREMENTS.qa.txt
	rm -rf $(PYTHON_TESTING_ENV) && \
	$(PYTHON) -m venv $(PYTHON_TESTING_ENV) && \
	. $(PYTHON_TESTING_ENV)/bin/activate && \
	pip install pip --upgrade && \
	pip install -r ./REQUIREMENTS.qa.txt && \
	date > $(PYTHON_TESTING_ENV)/.created

qa: $(PYTHON_TESTING_ENV)/.created
	. $(PYTHON_TESTING_ENV)/bin/activate && \
	black --check --diff . && \
	flake8

