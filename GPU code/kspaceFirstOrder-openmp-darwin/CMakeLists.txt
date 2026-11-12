cmake_minimum_required(VERSION 3.20)

project(kspaceFirstOrderOMP LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(kspaceFirstOrder-OMP main.cpp)
foreach(dir IN ITEMS Containers Hdf5 KSpaceSolver Logger MatrixClasses OutputStreams Parameters)
    add_subdirectory(${dir})
endforeach()

set(COMMON_FLOAT_FLAGS -O3 -fno-fast-math -ffp-contract=fast -fno-finite-math-only -fno-strict-aliasing)

# TODO: create a better way to find homebrew
set(HOMEBREW_PREFIX /opt/homebrew)
if(NOT EXISTS "${HOMEBREW_PREFIX}/opt/hdf5")
    set(HOMEBREW_PREFIX /usr/local)
endif()

set(_include_dirs
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${HOMEBREW_PREFIX}/opt/hdf5/include
    ${HOMEBREW_PREFIX}/opt/fftw/include
    ${HOMEBREW_PREFIX}/opt/zlib/include
    ${HOMEBREW_PREFIX}/opt/libomp/include
)

set(_lib_dirs
    ${HOMEBREW_PREFIX}/opt/hdf5/lib
    ${HOMEBREW_PREFIX}/opt/fftw/lib
    ${HOMEBREW_PREFIX}/opt/zlib/lib
    ${HOMEBREW_PREFIX}/opt/libomp/lib
)

target_include_directories(kspaceFirstOrder-OMP PRIVATE ${_include_dirs})
target_link_directories(kspaceFirstOrder-OMP PRIVATE ${_lib_dirs})
target_link_libraries(kspaceFirstOrder-OMP PRIVATE fftw3f fftw3f_omp hdf5 hdf5_hl z omp m)

set(CPU_FLAGS -m64 -mtune=native)

target_compile_options(kspaceFirstOrder-OMP PRIVATE ${COMMON_FLOAT_FLAGS} ${CPU_FLAGS} -g -Wall -Xpreprocessor -fopenmp)
target_link_options(kspaceFirstOrder-OMP PRIVATE ${COMMON_FLOAT_FLAGS} ${CPU_FLAGS} -g -Xpreprocessor -fopenmp)

set_target_properties(kspaceFirstOrder-OMP PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
    BUILD_RPATH "${_lib_dirs}"
    INSTALL_RPATH "${_lib_dirs}"
)
