#==========================================================================================
# Project: ym-fortran
# File   : Makefile
#==========================================================================================

PROJECT         := ym-fortran

SRC_DIR         := src
TEST_DIR        := test
BUILD_ROOT      := build

COMPILER        ?= gfortran
COMPILER_FAMILY ?= $(COMPILER)
BUILD_TYPE      ?= debug
PRECISION       ?= double
OPENMP          ?= no

BUILD_DIR       := $(BUILD_ROOT)/$(COMPILER)/$(BUILD_TYPE)/$(PRECISION)
OBJ_DIR         := $(BUILD_DIR)/obj
MOD_DIR         := $(BUILD_DIR)/mod
TEST_BIN_DIR    := $(BUILD_DIR)/test

#------------------------------------------------------------------------------------------
# Sources
#------------------------------------------------------------------------------------------

MODULE_OBJECTS := \
   $(OBJ_DIR)/parameters.o \
   $(OBJ_DIR)/error.o \
   $(OBJ_DIR)/strings.o \
   $(OBJ_DIR)/lattice.o

TEST_NAMES       := test_parameters test_error test_strings test_lattice
TEST_OBJECTS     := $(addprefix $(OBJ_DIR)/,$(addsuffix .o,$(TEST_NAMES)))
TEST_EXECUTABLES := $(addprefix $(TEST_BIN_DIR)/,$(TEST_NAMES))

#------------------------------------------------------------------------------------------
# Compiler families
#------------------------------------------------------------------------------------------

ifneq ($(filter gfortran gnu,$(COMPILER_FAMILY)),)
   DEFAULT_FC            := gfortran
   MODULE_OUTPUT_OPTION  := -J$(MOD_DIR)
   MODULE_INCLUDE_OPTION := -I$(MOD_DIR)
   PREPROCESS_FLAG       := -cpp
   COMMON_FLAGS          := -std=f2018 -Wall -Wextra -Wpedantic -Wimplicit-interface
   DEBUG_FLAGS           := -O0 -g -fcheck=all -fbacktrace \
                            -ffpe-trap=invalid,zero,overflow
   RELEASE_FLAGS         := -O3
   OPENMP_FLAG           := -fopenmp

else ifneq ($(filter ifx intel,$(COMPILER_FAMILY)),)
   DEFAULT_FC            := ifx
   MODULE_OUTPUT_OPTION  := -module $(MOD_DIR)
   MODULE_INCLUDE_OPTION := -I$(MOD_DIR)
   PREPROCESS_FLAG       := -fpp
   COMMON_FLAGS          := -stand f18 -warn all
   DEBUG_FLAGS           := -O0 -g -traceback -check all -fpe0
   RELEASE_FLAGS         := -O3
   OPENMP_FLAG           := -qopenmp

else ifneq ($(filter nvfortran nvidia,$(COMPILER_FAMILY)),)
   DEFAULT_FC            := nvfortran
   MODULE_OUTPUT_OPTION  := -module $(MOD_DIR)
   MODULE_INCLUDE_OPTION := -I$(MOD_DIR)
   PREPROCESS_FLAG       := -Mpreprocess
   COMMON_FLAGS          := -Mdclchk -Minform=warn
   DEBUG_FLAGS           := -O0 -g -Mbounds -Mchkptr -Mchkstk -Ktrap=divz,inv,ovf
   RELEASE_FLAGS         := -O3
   OPENMP_FLAG           := -mp

else
   DEFAULT_FC            := $(COMPILER)
   MODULE_OUTPUT_OPTION  ?= -J$(MOD_DIR)
   MODULE_INCLUDE_OPTION ?= -I$(MOD_DIR)
   PREPROCESS_FLAG       ?= -cpp
   COMMON_FLAGS          ?=
   DEBUG_FLAGS           ?= -O0 -g
   RELEASE_FLAGS         ?= -O3
   OPENMP_FLAG           ?=
endif

# GNU make supplies FC=f77 as a built-in default. Replace only that default.
ifneq ($(filter default undefined,$(origin FC)),)
   FC := $(DEFAULT_FC)
endif

ifeq ($(BUILD_TYPE),debug)
   DEFAULT_FFLAGS := $(COMMON_FLAGS) $(DEBUG_FLAGS)
else ifeq ($(BUILD_TYPE),release)
   DEFAULT_FFLAGS := $(COMMON_FLAGS) $(RELEASE_FLAGS)
else
   $(error BUILD_TYPE must be 'debug' or 'release'; received '$(BUILD_TYPE)')
endif

ifeq ($(PRECISION),single)
   PRECISION_CPPFLAGS := -DSINGLE
else ifeq ($(PRECISION),double)
   PRECISION_CPPFLAGS :=
else ifeq ($(PRECISION),quad)
   PRECISION_CPPFLAGS := -DQUAD
else
   $(error PRECISION must be 'single', 'double', or 'quad'; received '$(PRECISION)')
endif

ifeq ($(OPENMP),yes)
   PARALLEL_FLAGS := $(OPENMP_FLAG)
else ifeq ($(OPENMP),no)
   PARALLEL_FLAGS :=
else
   $(error OPENMP must be 'yes' or 'no'; received '$(OPENMP)')
endif

FFLAGS       ?= $(DEFAULT_FFLAGS)
EXTRA_FFLAGS ?=
CPPFLAGS     ?=
LDFLAGS      ?=
LDLIBS       ?=

COMPILE_FLAGS := $(CPPFLAGS) $(PRECISION_CPPFLAGS) $(FFLAGS) \
                 $(EXTRA_FFLAGS) $(PARALLEL_FLAGS)
LINK_FLAGS    := $(LDFLAGS) $(PARALLEL_FLAGS)

#------------------------------------------------------------------------------------------
# Targets
#------------------------------------------------------------------------------------------

.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

.PHONY: all modules tests test test-parameters test-error test-strings test-lattice \
        test-precisions test-compilers dirs info help clean clean-compiler distclean

all: modules

modules: $(MODULE_OBJECTS)

tests: $(TEST_EXECUTABLES)

test: tests
	@echo "Running parameter tests"
	@$(TEST_BIN_DIR)/test_parameters
	@echo "Running string tests"
	@$(TEST_BIN_DIR)/test_strings
	@echo "Running error tests"
	@$(TEST_DIR)/run_error_tests.sh $(TEST_BIN_DIR)/test_error
	@echo "Running lattice tests"
	@$(TEST_BIN_DIR)/test_lattice 

test-parameters: $(TEST_BIN_DIR)/test_parameters
	@$<

test-strings: $(TEST_BIN_DIR)/test_strings
	@$<

test-error: $(TEST_BIN_DIR)/test_error
	@$(TEST_DIR)/run_error_tests.sh $<

test-lattice: $(TEST_BIN_DIR)/test_lattice
	@$< 

test-precisions:
	@set -e; \
	for precision in single double quad; do \
	   echo "============================================================"; \
	   echo "Testing $(COMPILER) with $$precision precision"; \
	   echo "============================================================"; \
	   $(MAKE) --no-print-directory \
	      COMPILER=$(COMPILER) COMPILER_FAMILY=$(COMPILER_FAMILY) FC='$(FC)' \
	      BUILD_TYPE=$(BUILD_TYPE) PRECISION=$$precision test; \
	done

test-compilers:
	@set -e; \
	for compiler in gfortran ifx nvfortran; do \
	   if command -v $$compiler >/dev/null 2>&1; then \
	      echo "============================================================"; \
	      echo "Testing with $$compiler"; \
	      echo "============================================================"; \
	      $(MAKE) --no-print-directory \
	         COMPILER=$$compiler COMPILER_FAMILY=$$compiler \
	         BUILD_TYPE=debug PRECISION=double test; \
	   else \
	      echo "SKIP: $$compiler is not available in PATH"; \
	   fi; \
	done

dirs:
	@mkdir -p $(OBJ_DIR) $(MOD_DIR) $(TEST_BIN_DIR)

info:
	@echo "Project          : $(PROJECT)"
	@echo "Compiler label   : $(COMPILER)"
	@echo "Compiler family  : $(COMPILER_FAMILY)"
	@echo "Fortran compiler : $(FC)"
	@echo "Build type       : $(BUILD_TYPE)"
	@echo "Precision        : $(PRECISION)"
	@echo "OpenMP           : $(OPENMP)"
	@echo "Build directory  : $(BUILD_DIR)"
	@echo "Module directory : $(MOD_DIR)"
	@echo "FFLAGS           : $(FFLAGS) $(EXTRA_FFLAGS) $(PARALLEL_FLAGS)"
	@echo "CPPFLAGS         : $(CPPFLAGS) $(PRECISION_CPPFLAGS)"
	@echo "LDFLAGS          : $(LINK_FLAGS)"
	@echo "LDLIBS           : $(LDLIBS)"

help:
	@echo "Common commands:"
	@echo "  make"
	@echo "  make test"
	@echo "  make COMPILER=ifx BUILD_TYPE=release"
	@echo "  make COMPILER=nvfortran PRECISION=single test"
	@echo "  make test-precisions"
	@echo "  make test-compilers"
	@echo "  make info"
	@echo "  make clean"
	@echo "  make clean-compiler COMPILER=gfortran"
	@echo "  make distclean"
	@echo ""
	@echo "HPC wrapper example:"
	@echo "  make COMPILER=cluster-gnu COMPILER_FAMILY=gfortran FC=ftn BUILD_TYPE=release"

clean:
	@rm -rf $(BUILD_DIR)

clean-compiler:
	@rm -rf $(BUILD_ROOT)/$(COMPILER)

distclean:
	@rm -rf $(BUILD_ROOT)

#------------------------------------------------------------------------------------------
# Compilation rules
#------------------------------------------------------------------------------------------

# Preprocessed module source.
$(OBJ_DIR)/parameters.o: $(SRC_DIR)/parameters.F90 | dirs
	@echo "[$(COMPILER)/$(BUILD_TYPE)/$(PRECISION)] Compiling $<"
	$(FC) $(PREPROCESS_FLAG) $(COMPILE_FLAGS) \
	   $(MODULE_OUTPUT_OPTION) $(MODULE_INCLUDE_OPTION) -c $< -o $@

# Ordinary module sources.
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.f90 | dirs
	@echo "[$(COMPILER)/$(BUILD_TYPE)/$(PRECISION)] Compiling $<"
	$(FC) $(COMPILE_FLAGS) \
	   $(MODULE_OUTPUT_OPTION) $(MODULE_INCLUDE_OPTION) -c $< -o $@

# Preprocessed tests.
$(OBJ_DIR)/%.o: $(TEST_DIR)/%.F90 $(MODULE_OBJECTS) | dirs
	@echo "[$(COMPILER)/$(BUILD_TYPE)/$(PRECISION)] Compiling $<"
	$(FC) $(PREPROCESS_FLAG) $(COMPILE_FLAGS) \
	   $(MODULE_OUTPUT_OPTION) $(MODULE_INCLUDE_OPTION) -c $< -o $@

# Ordinary tests.
$(OBJ_DIR)/%.o: $(TEST_DIR)/%.f90 $(MODULE_OBJECTS) | dirs
	@echo "[$(COMPILER)/$(BUILD_TYPE)/$(PRECISION)] Compiling $<"
	$(FC) $(COMPILE_FLAGS) \
	   $(MODULE_OUTPUT_OPTION) $(MODULE_INCLUDE_OPTION) -c $< -o $@

$(TEST_BIN_DIR)/test_parameters: $(MODULE_OBJECTS) $(OBJ_DIR)/test_parameters.o | dirs
	@echo "[$(COMPILER)/$(BUILD_TYPE)/$(PRECISION)] Linking $@"
	$(FC) $(LINK_FLAGS) $^ $(LDLIBS) -o $@

$(TEST_BIN_DIR)/test_error: $(MODULE_OBJECTS) $(OBJ_DIR)/test_error.o | dirs
	@echo "[$(COMPILER)/$(BUILD_TYPE)/$(PRECISION)] Linking $@"
	$(FC) $(LINK_FLAGS) $^ $(LDLIBS) -o $@

$(TEST_BIN_DIR)/test_strings: $(MODULE_OBJECTS) $(OBJ_DIR)/test_strings.o | dirs
	@echo "[$(COMPILER)/$(BUILD_TYPE)/$(PRECISION)] Linking $@"
	$(FC) $(LINK_FLAGS) $^ $(LDLIBS) -o $@

$(TEST_BIN_DIR)/test_lattice: $(MODULE_OBJECTS) $(OBJ_DIR)/test_lattice.o | dirs
	@echo "[$(COMPILER)/$(BUILD_TYPE)/$(PRECISION)] Linking $@"
	$(FC) $(LINK_FLAGS) $^ $(LDLIBS) -o $@

#------------------------------------------------------------------------------------------
# Explicit Fortran module dependencies
#------------------------------------------------------------------------------------------

# Both utility modules currently depend on the common parameters module.
$(OBJ_DIR)/error.o:   $(OBJ_DIR)/parameters.o
$(OBJ_DIR)/strings.o: $(OBJ_DIR)/parameters.o
$(OBJ_DIR)/lattice.o: $(OBJ_DIR)/parameters.o $(OBJ_DIR)/error.o 
