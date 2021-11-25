# Instructions: 
# 1) add a rule for your board to the bottom of this file
# 2) profit!

LFLAGS_NRF52=$(LFLAGS) template_nrf52.c -T ld.nrf52.basic

# NRF52 starts up with HFINT at 64Mhz
NRF52_CFLAGS=$(M4FH_FLAGS) -DNRF52 -DLITTLE_BIT=3200000 $(LFLAGS_NRF52) -lopencm3_nrf52

define RAWMakeBoard
	$(CC) -DPORT_LED1=$(1) -DPIN_LED1=$(2) \
		$(if $(5),-DPORT_LED2=$(5) -DPIN_LED2=$(6),) \
		$(3) -o $(OD)/nrf52/$(4)
endef


define MakeBoard
BOARDS_ELF+=$(OD)/nrf52/$(1).elf
BOARDS_BIN+=$(OD)/nrf52/$(1).bin
BOARDS_HEX+=$(OD)/nrf52/$(1).hex
$(OD)/nrf52/$(1).elf: template_nrf52.c libopencm3/lib/libopencm3_$(5).a
	@echo "  $(5) -> Creating $(OD)/nrf52/$(1).elf"
	$(call RAWMakeBoard,$(2),$(3),$(4),$(1).elf,$(6),$(7))
endef

define nrf52board
	$(call MakeBoard,$(1),$(2),$(3),$(NRF52_CFLAGS),nrf52,$(4),$(5))
endef

# NRF52 boards
$(eval $(call nrf52board,nrf52833-dk,GPIO,GPIO13,GPIO,GPIO14))
