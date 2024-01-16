WORK_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
DIST_PATH = $(WORK_DIR)dist

DIST_DEV_ENV_CTL = $(DIST_PATH)/devenvctl
DEV_ENV_LIST = \
oidc \
samltester \
nfv-kibana \
cda-tls \
nfv510 \
nfv500 \

.PHONY: devenvctl clean clean-devenvctl devenvctl-scripts $(DEV_ENV_LIST) devenvctl-misc

devenvctl: clean-devenvctl devenvctl-scripts $(DEV_ENV_LIST) devenvctl-misc
	@echo 'devenvctl' built to $(DIST_DEV_ENV_CTL)/
	
devenvctl-scripts: clean-devenvctl
	mkdir $(DIST_DEV_ENV_CTL)
	cp $(WORK_DIR)bin/functions $(WORK_DIR)bin/devenvctl.sh $(DIST_DEV_ENV_CTL)/
	mkdir $(DIST_DEV_ENV_CTL)/devenv
	cp -r $(WORK_DIR)bin/devenv/libs $(DIST_DEV_ENV_CTL)/devenv/
	cp $(WORK_DIR)bin/devenv/default.* $(DIST_DEV_ENV_CTL)/devenv/

$(DEV_ENV_LIST): 
	[ -d $(WORK_DIR)bin/devenv/res-$@ ] && cp -r $(WORK_DIR)bin/devenv/res-$@ $(DIST_DEV_ENV_CTL)/devenv/ || :
	[ -e $(WORK_DIR)bin/devenv/devenv-$@.script ] && cp $(WORK_DIR)bin/devenv/devenv-$@.script $(DIST_DEV_ENV_CTL)/devenv/ || :
	[ -e $(WORK_DIR)bin/devenv/devenv-$@.yml ] && cp $(WORK_DIR)bin/devenv/devenv-$@.yml $(DIST_DEV_ENV_CTL)/devenv/ || :
	[ -e $(WORK_DIR)bin/devenv/docker-compose-$@.yml ] && cp $(WORK_DIR)bin/devenv/docker-compose-$@.yml $(DIST_DEV_ENV_CTL)/devenv/ || :

devenvctl-misc: devenvctl-scripts
	cp $(WORK_DIR)docs/devenvctl.md $(DIST_DEV_ENV_CTL)/README.md
	mkdir $(DIST_DEV_ENV_CTL)/res
	cp -r $(WORK_DIR)docs/res/devenvctl-* $(DIST_DEV_ENV_CTL)/res/

clean-devenvctl: 
	rm -rf $(DIST_DEV_ENV_CTL)
	
clean: 
	rm -rf $(DIST_PATH)/*
	