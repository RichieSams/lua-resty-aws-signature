default: build

ifeq ($(OS),Windows_NT)
export VERSION?=$(shell git describe --tags 2> nul || echo 0.0.0)
else
export VERSION?=$(shell git describe --tags 2>/dev/null || echo 0.0.0)
endif

.PHONY: dist.ini


###############################################################
# Unit / functional testing
###############################################################

TEST_FILES = $(wildcard t/*.t)

test: $(TEST_FILES)
	prove $^


###############################################################
# Creating OPM Package and publishing
###############################################################

build: dist.ini
	opm build

populate_opmrc:
	@printf "github_account=RichieSams\ngithub_token=$(GITHUB_TOKEN)\nupload_server=https://opm.openresty.org\ndownload_server=https://opm.openresty.org\n" > ~/.opmrc

dist.ini:
	@envsubst < dist.ini.tmpl > dist.ini

publish:
	opm upload


###############################################################
# Miscellaneous
###############################################################

clean:
	opm clean dist
