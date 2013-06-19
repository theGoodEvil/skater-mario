OSX_HOST = $(HOME)/moai-sdk/bin/osx/moai

run:
	@cd lua && $(OSX_HOST) main.lua

.PHONY: run
