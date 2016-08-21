# THE FOLLOWING VARIABLES CAN BE MODIFIED TO YOUR NEEDS
#
# name of build directory
BUILD_DIR = build
# yes/no build mex files
BUILDMEX = yes
# yes/no build documentation (requires fkHelp toolbox)
BUILDDOC = yes
# command line options for matlab
MATLABOPTIONS = -nosplash -nodesktop
# matlab binary
MATLABBIN = matlab
# documentation path
DOCPATH = html
#destination path for export target
DEST = .

# DO NOT CHANGE THE FOLLOWING VARIABLES
#
# set shell to bash (needed for brace expansion as used in mkdir in build target)
SHELL=/bin/bash
# toolbox name
RPM_NAME=$(shell sed -e '/^Name: */!d; s///;q' *.spec)
# toolbox version, release number and release date
RPM_VER=$(shell sed -e '/^Version: */!d; s///;q' $(RPM_NAME).spec)
RPM_REL=$(shell sed -e '/^Release: */!d; s///;q' $(RPM_NAME).spec)
RELDATE=$(shell date +%d-%b-%Y)
# computer architecture (for creating rpm)
MWLARCH=$(shell sed -e '/^BuildArch: */!d; s///;q' $(RPM_NAME).spec)
# matlab command (leave empty)
MATLABCOMMAND = 
BUILDDOCCMD = 
BUILDMEXCMD = 

# construct matlab command
ifeq ($(BUILDDOC),yes)
BUILDDOCCMD = generate_help('.','$(RPM_NAME)'),quit
endif

ifeq ($(BUILDMEX),yes)
BUILDMEXCMD = makesources,
endif

MATLABCOMMAND = p=pwd;cd('~');startup;cd(p);$(BUILDMEXCMD)$(BUILDDOCCMD)

PKGNAME = $(RPM_NAME)-$(RPM_VER)-$(RPM_REL).$(MWLARCH)

FINDARGS = -mindepth 1 \! -type d \! -path \*build/* \! -path \*/.* \! -name \\\#*\\\# \! -name \*~

clean: 
	rm -rf build
	rm -f *.tar.gz
	rm -f *.zip
	rm -f *.rpm

# if you have other file types / directories that need to be included,
# add lines below to copy these to the build directory
build:
	mkdir -p $(BUILD_DIR)/$(RPM_NAME)/{$(DOCPATH),private}
	cp -f --parents `find . $(FINDARGS)` $(BUILD_DIR)/$(RPM_NAME)
	cd $(BUILD_DIR)/$(RPM_NAME) ; \
	sed -i -e "s/VERSIONNUMBER/$(RPM_VER).$(RPM_REL)/g" Contents.m ; \
	sed -i -e "s/RELEASEDATE/$(RELDATE)/g" Contents.m ; \

# build sources and documentation
mex: build
	cd $(BUILD_DIR)/$(RPM_NAME) ; \
	if test -n "$(MATLABCOMMAND)"; then $(MATLABBIN) $(MATLABOPTIONS) -r "$(MATLABCOMMAND)"; fi ;\
	if test "$(BUILDDOC)" = "yes"; then sed -i -e "s/VERSIONNUMBER/$(RPM_VER)-$(RPM_REL)/g" $(DOCPATH)/$(RPM_NAME)_product_page.html ; fi ;\
	if test "$(BUILDDOC)" = "yes"; then sed -i -e "s/RELEASEDATE/$(RELDATE)/g" $(DOCPATH)/$(RPM_NAME)_product_page.html ; fi

# create tarball
tar: mex
	cd $(BUILD_DIR) ; \
	tar czvf $(PKGNAME).tar.gz $(RPM_NAME) ; \
	mv -f $(PKGNAME).tar.gz ..

# create zip
zip: mex
	cd $(BUILD_DIR) ; \
	zip -r $(PKGNAME).zip $(RPM_NAME) ; \
	mv -f $(PKGNAME).zip ..

# create rpm
# you will want to add 'export RPMBASE=~/rpm' or somesuch to your .bashrc file
rpm: tar
	cp -f $(PKGNAME).tar.gz $(RPMBASE)/SOURCES/ ;\
	rpmbuild -bb $(RPM_NAME).spec ;\
	cp $(RPMBASE)/RPMS/$(MWLARCH)/$(PKGNAME).rpm . 

export: clean mex
	rm -rf $(DEST)/$(RPM_NAME)
	cp -rf $(BUILD_DIR)/$(RPM_NAME) $(DEST)
	rm -rf $(BUILD_DIR)