.PHONY: test
test: test-lint  ## Run test suite

.PHONY: test-lint  ## Run the linter
test-lint:
	$(_ANSIBLE_LINT) -f pep8 -c .config/ansible-lint.yaml

.PHONY: test-requirements
test-requirements:  ## Install requirements for test suite
	$(_PIP) install -r requirements-test.txt
