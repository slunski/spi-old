# sources and build location
#SDIR	= /usr/src
SDIR	= /home/sylwek/src/perl

# where to install 
#IDIR	= /usr/local
IDIR	= /opt/perl

##########################################

PARROT_BUILD_OPTS	= --prefix=$(IDIR) --optimize

RAKUDO_BUILD_OPTS	= --parrot-config=$(IDIR)/bin/parrot_config

##########################################

PARROT_REPOSITORY	= https://svn.parrot.org/parrot/trunk parrot
PARROT_GET_CMD		= svn checkout -r $(PARROT_REV_NEEDED) $(PARROT_REPOSITORY)

RAKUDO_REPOSITORY	= git://github.com/rakudo/rakudo.git
RAKUDO_GET_CMD		= git clone $(RAKUDO_REPOSITORY)

# End config varibles

################################################################################
# Additional vars

PARROT_REV_NEEDED	= `cd $(SDIR) ; cat PARROT_VER`

################################################################################
# Main targets

# 1a
# Gets and builds Rakudo and Parrot at once

all: parrot parrot-install rakudo rakudo-install


# 1b.
# Build Rakudo (and Parrot inside Rakudo)
# Best for quick hacks

fast: rakudo-get rakudo-gen


# 1c
# Build only parrot, newest version (svn HEAD)
# Can be imposible to building Rakudo with this

just-parrot: config-parrot-head parrot-get parrot-build


##################################################
# Install target for 1a

install: parrot-install rakudo-install


################################################################################
#  Helper targets aka real work

##################################################
# Gets and builds Parrot (suitable for newest Rakudo version)

parrot: config parrot-get parrot-build


parrot-get:
	echo ; \
	cd $(SDIR); \
	echo -n "Getting Parrot sources, version " ; \
	echo $(PARROT_REV_NEEDED) ; \
	echo ; \
	$(PARROT_GET_CMD)

parrot-build:
	echo ; \
	echo Building Parrot... ; \
	cd $(SDIR)/parrot ; \
	perl Configure.pl $(PARROT_BUILD_OPTS) ; \
	make

	
parrot-install:
	echo ; \
	echo Installing Parrot...  ; \
	echo ; \
	cd $(SDIR)/parrot ; \
	make install-dev


##################################################
# Builds Rakudo, Parrot required

rakudo: rakudo-get rakudo-build


rakudo-get:
	echo ; \
	echo Cloning Rakudo repository... ; \
	echo ; \
	cd $(SDIR) ; \
	$(RAKUDO_GET_CMD)


rakudo-build:
	echo ; \
	echo Building Rakudo... ; \
	echo ; \
	cd $(SDIR)/rakudo ; \
	perl Configure.pl $(RAKUDO_BUILD_OPTS) ; \
	make


rakudo-install:
	echo ; \
	echo Installing Rakudo into $(IDIR) ; \
	echo ; \
	cd $(SDIR)/rakudo ; \
	make install


rakudo-gen:
	echo ; \
	echo Compiling Rakudo with Parrot inside... ; \
	echo ; \
	cd $(SDIR)/rakudo ; \
	perl Configure.pl --gen-parrot ; \
	make


##################################################
# Helpers for main targets

config:
	echo ; \
	cd $(SDIR) ; \
	wget http://github.com/rakudo/rakudo/raw/master/build/PARROT_REVISION 2&> /dev/null ; \
	echo ; \
	echo -n "Parrot version needed by Rakudo: " ; \
	cat PARROT_REVISION | cut -d ' ' -f 1 | tee PARROT_VER ; \
	echo


config-parrot-head:
	echo ; \
	echo Parrot HEAD wished... ; \
	echo cd $(SDIR) ; \
	echo HEAD > PARROT_VER ; \
	echo ; \


##################################################
# Targets for testers

rakudo-test:
	echo ; \
	echo Testing Rakudo local tests... ; \
	echo ; \
	cd $(SDIR)/rakudo ; \
	make test

rakudo-spectest:
	echo ; \
	echo Testing Rakudo with official Perl6 test suite... ; \
	echo ; \
	cd $(SDIR)/rakudo ; \
	make spectest


##################################################
# Cleaners

clean: parrot-clean rakudo-clean

parrot-clean:
	echo ; \
	cd $(SDIR)/parrot; \
	make clean

rakudo-clean:
	echo ; \
	cd $(SDIR)/rakudo; \
	make clean

distclean: parrot-distclean rakudo-distclean config-distclean

config-distclean:
	echo ; \
	cd $(SDIR); \
	rm -f PARROT_REVISION ; \
	rm -f PARROT_VER ; \

parrot-distclean:
	echo ; \
	cd $(SDIR)/parrot && make distclean

rakudo-distclean:
	echo ; \
	cd $(SDIR)/rakudo && make distclean

wipe: parrot-wipe rakudo-wipe config-distclean

parrot-wipe:
	cd $(SDIR) ; \
	rm -fr rakudo/parrot 2>/dev/null ; \
	rm -fr rakudo/parrot_install 2>/dev/null ; \
	rm -fr parrot 2>/dev/null

rakudo-wipe:
	cd $(SDIR); \
	rm -fr rakudo


##################################################
# Misc stuff

packaging-intro:
	

checkinstall-parrot:
	cd $(SDIR)/parrot ; \
	checkinstall make install-dev

checkinstall-rakudo:
	cd $(SDIR)/rakudo ; \
	checkinstall make install

installwatch-parrot:
	cd $(SDIR)/parrot ; \
	installwatch -o $(SDIR)/parrot-install.log make install

installwatch-rakudo:
	cd $(SDIR)/rakudo ; \
	installwatch -o $(SDIR)/rakudo-install.log make install

##################################################
# Misc stuff



rakudo-diff:
	echo ; \
	git commit -m 'Your commit message' ; \
	git format-patch HEAD^

parrot-diff:
	echo ; \

rakudo-bug:
	echo ; \


parrot-bug:
	echo ; \


.SILENT: config rakudo-get parrot

