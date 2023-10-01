UK_ROOT ?= $(PWD)/workdir/unikraft
UK_LIBS ?= $(PWD)/workdir/libs
UK_BUILD ?= $(PWD)/workdir/build
LIBS := $(UK_LIBS)/musl:$(UK_LIBS)/lwip:$(UK_LIBS)/python3:$(UK_LIBS)/compiler-rt

all:
	@$(MAKE) -C $(UK_ROOT) A=$(PWD) O=$(UK_BUILD) L=$(LIBS)

$(MAKECMDGOALS):
	@$(MAKE) -C $(UK_ROOT) A=$(PWD) O=$(UK_BUILD) L=$(LIBS) $(MAKECMDGOALS)
