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

# OPM doesn't currently have a native function to do local installs
# So we have to hack it ourselves
# See: https://github.com/openresty/opm/issues/39
install_locally:
	opm install openresty/lua-resty-string
	opm install jkeys089/lua-resty-hmac
	cp lib/resty/* /usr/local/openresty/lualib/resty/

TEST_FILES = $(wildcard t/*.t)

test: install_locally
	prove $(TEST_FILES)


###############################################################
# Creating OPM Package and publishing
###############################################################

build: dist.ini
	opm build

populate_opmrc:
	@printf "github_account=RichieSams\ngithub_token=$(OPM_PUBLISH_TOKEN)\nupload_server=https://opm.openresty.org\ndownload_server=https://opm.openresty.org\n" > ~/.opmrc

dist.ini:
	@envsubst < dist.ini.tmpl > dist.ini

publish: dist.ini
	opm upload


###############################################################
# Miscellaneous
###############################################################

clean:
	opm clean dist
