# Makefile for macOS using Homebrew-installed libraries

# Compiler
CXX = g++

# C++ standard
CPP_STD = -std=c++11 -v

# Enable OpenMP
OPENMP = -Xpreprocessor -fopenmp

# Set CPU architecture
CPU_FLAGS = -m64 -mcpu=apple-m1 -mtune=native

# Use maximum optimization
OPT = -O3 -fno-fast-math -ffp-contract=fast -fno-finite-math-only -fno-strict-aliasing 

# Debug flags
DEBUG = -g -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize

# Profile flags
PROFILE = 

# C++ warning flags
WARNING = -Wall

# Include directories
HDF5_DIR = /opt/homebrew/opt/hdf5
FFT_DIR = /opt/homebrew/opt/fftw
ZLIB_DIR = /opt/homebrew/opt/zlib
LIBOMP_DIR = /opt/homebrew/opt/libomp

INCLUDES = -I$(HDF5_DIR)/include -I$(FFT_DIR)/include -I$(ZLIB_DIR)/include -I$(LIBOMP_DIR)/include -I.

# Library directories
LIB_PATHS = -L$(HDF5_DIR)/lib -L$(FFT_DIR)/lib -L$(ZLIB_DIR)/lib -L$(LIBOMP_DIR)/lib

# Compiler flags and header files directories
CXXFLAGS = $(CPU_FLAGS) $(OPT) $(DEBUG) $(WARNING) $(PROFILE) \
           $(OPENMP) $(CPP_STD)                               \
           $(GIT_HASH)                                        \
           $(INCLUDES)

# Linker flags and library files directories
LDFLAGS = $(CPU_FLAGS) $(OPT) $(DEBUG) $(WARNING) $(PROFILE) \
          $(OPENMP) $(CPP_STD)                              \
          $(LIB_PATHS)                                      \
          -Wl,-rpath,$(HDF5_DIR)/lib:$(FFT_DIR)/lib:$(ZLIB_DIR)/lib:$(LIBOMP_DIR)/lib

LDLIBS = -lfftw3f -lfftw3f_omp -lhdf5 -lhdf5_hl -lm -lz -lomp

# Target binary name
TARGET = kspaceFirstOrder-OMP

# Units to be compiled
DEPENDENCIES = main.o                                  \
               Containers/MatrixContainer.o            \
               Containers/OutputStreamContainer.o      \
               Hdf5/Hdf5File.o                         \
               Hdf5/Hdf5FileHeader.o                   \
               KSpaceSolver/KSpaceFirstOrderSolver.o   \
               Logger/Logger.o                         \
               MatrixClasses/BaseFloatMatrix.o         \
               MatrixClasses/BaseIndexMatrix.o         \
               MatrixClasses/ComplexMatrix.o           \
               MatrixClasses/FftwComplexMatrix.o       \
               MatrixClasses/FftwRealMatrix.o          \
               MatrixClasses/IndexMatrix.o             \
               MatrixClasses/RealMatrix.o              \
               OutputStreams/BaseOutputStream.o        \
               OutputStreams/IndexOutputStream.o       \
               OutputStreams/CuboidOutputStream.o      \
               OutputStreams/WholeDomainOutputStream.o \
               Parameters/CommandLineParameters.o      \
               Parameters/Parameters.o

# Build target
all: $(TARGET)

# Link target
$(TARGET): $(DEPENDENCIES)
	$(CXX) $(LDFLAGS) $(DEPENDENCIES) $(LDLIBS) -o $@

# Compile units
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -o $@ -c $<

# Clean repository
.PHONY: clean
clean:
	rm -f $(DEPENDENCIES) $(TARGET)