help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

update: ## Performs an upgrade of Nextcloud
	ansible-playbook -i inventory/hosts setup.yml --tags=update
