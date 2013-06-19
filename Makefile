TEXTURE_PACKER = /Applications/TexturePacker.app/Contents/MacOS/TexturePacker
OSX_HOST = $(HOME)/moai-sdk/bin/osx/moai

ATLAS_DIR = atlas

SPRITE_SHEET_DIRS = $(wildcard img/**)
SPRITE_SHEETS_PNG = $(SPRITE_SHEET_DIRS:img/%=$(ATLAS_DIR)/%.png)
SPRITE_SHEETS_PNG_LUA = $(SPRITE_SHEETS_PNG:%.png=%.lua)
SPRITE_SHEETS = $(SPRITE_SHEETS_PNG) $(SPRITE_SHEETS_PNG_LUA)

define RUN_TEXTURE_PACKER
	$(TEXTURE_PACKER) \
		--sheet $(ATLAS_DIR)/$*.png \
		--texture-format png \
		--data $(ATLAS_DIR)/$*.lua \
		--format moai \
		--algorithm MaxRects \
		--max-width 4096 \
		--max-height 4096 \
		--size-constraints POT \
		--pack-mode Best \
		--trim-mode Trim \
		img/$*
endef

build: sheets

sheets: $(SPRITE_SHEETS)

run: build
	@cd lua && $(OSX_HOST) main.lua

.PHONY: run

clean:
	@rm -rf $(ATLAS_DIR)

$(ATLAS_DIR)/%.png $(ATLAS_DIR)/%.lua: img/%/*.png
	@$(call RUN_TEXTURE_PACKER)
