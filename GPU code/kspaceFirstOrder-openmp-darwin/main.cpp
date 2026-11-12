/**
 * @file      main.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The main file of kspaceFirstOrder-OMP.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      11 July      2012, 10:57 (created) \n
 *            18 February  2020, 15:29 (revised)
 *
 * @mainpage  kspaceFirstOrder-OMP
 *
 * @section   Overview 1 Overview
 *
 * k-Wave is an open source MATLAB toolbox designed for the time-domain simulation of propagating acoustic waves in 1D,
 * 2D, or 3D. The toolbox has a wide range of functionality, but at its heart is an advanced numerical model that can
 * account for both linear or nonlinear wave propagation, an arbitrary distribution of heterogeneous material
 * parameters, and power law acoustic absorption. See the [k-Wave website](http://www.k-wave.org) for further details.
 *
 * This project is a part of the k-Wave toolbox accelerating 2D/3D simulations using an optimized C++ implementation
 * to run small to moderate grid sizes (e.g., 128x128 to 10,000x10,000 in 2D or 64x64x64 to 512x512x512 in 3D) on
 * systems with shared memory. 2D simulations can be carried out in both normal and axisymmetric coordinate systems.
 *
 * Compiled binaries of the C++ code for x86 architectures are available from the [k-Wave downloads page]
 * (http://www.k-wave.org/download). Both 64-bit Linux (Ubuntu / Debian) and 64-bit Windows versions are provided.
 * This Doxygen documentation was created based on the Linux version and provides details on the implementation of the
 * C++ code.
 *
 *
 * @section   Compilation 2 Compilation
 *
 * The source codes of <tt>kspaceFirstOrder-OMP</tt> are written using the C++-11 standard and use the OpenMP 4.0, FFTW
 * 3.3.8 or MKL 11, and HDF5 1.10.x libraries. There are a variety of different C++ compilers that can be used to
 * compile the source codes. The minimum requirements are the GNU C++ compiler 6.0 or the Intel C++ compiler 2018.
 * However, we recommend using either the GNU C++ compiler version 8.3 and newer, or the Intel C++ compiler version 2019
 * and newer. Please note that Visual Studio compilers do not support the OpenMP 4.0 standard and cannot be used to
 * compile this code. Also be aware the Intel compiler 2018 has an MKL bug which produces incorrect results when AVX2 is
 * enabled. The codes can be compiled on 64-bit Linux and Windows. 32-bit systems are not supported due to the
 * memory requirements even for small simulations.
 *
 * This section describes the compilation procedure using GNU and Intel compilers on Linux. (Windows users are
 * encouraged to download the Visual Studio 2017 project and compile it using the Intel Compiler from within Visual
 * Studio.)
 *
 * Before compiling the code, it is necessary to install a C++ compiler and several libraries. The GNU C/C++ compiler is
 * usually part of Linux distributions and distributed as open source. It can be downloaded from the [GNU website]
 * (http://gcc.gnu.org/) if necessary.
 * The Intel compiler can be downloaded from the [Intel website] (https://software.intel.com/en-us/parallel-studio-xe).
 * This package also includes the Intel MKL (Math Kernel Library) library that contains the fast Fourier transform
 * (FFT). The Intel compiler is only free for non-commercial and open-source use.
 *
 * The code also relies on several libraries that are to be installed before compiling:
 * \li HDF5 library - Mandatory I/O library, [version 1.8.x](https://portal.hdfgroup.org/display/support/HDF5+1.8.21)
 *                    or [version 1.10.x](https://www.hdfgroup.org/downloads/hdf5/source-code/).
 * \li FFTW library - Optional library for FFT, [version 3.3.x](http://www.fftw.org/).
 * \li MKL library  - Optional library for FFT, [version 2018 or higher]
 * (http://software.intel.com/en-us/intel-composer-xe/).
 *
 * Although it is possible to use any combination of the FFT library and the compiler, the best performance is observed
 * when using the GNU compiler and FFTW, or the Intel compiler and Intel MKL.
 *
 *
 * <b>2.1 The HDF5 library installation procedure</b>
 *
 * 1. Download the 64-bit HDF5 library [package for your platform]
 * (https://www.hdfgroup.org/downloads/hdf5/source-code/). Please keep in mind that versions 1.10.x
 * may not be fully compatible with older versions of MATLAB, especially when compression is enabled. In such a case,
 * please download [version 1.8.x](https://portal.hdfgroup.org/display/support/HDF5+1.8.21).
 *
 * 2. Configure the HDF5 distribution. Enable the high-level library and specify an installation folder by typing:
\verbatim
  ./configure --enable-hl --prefix=folder_to_install
\endverbatim
 * 3. Make the HDF5 library by typing:
\verbatim
  make -j
\endverbatim
 * 4. Install the HDF5 library by typing:
\verbatim
  make install
\endverbatim
 *
 *
 * <b>2.2 The FFTW library installation procedure</b>
 *
 * 1. Download the FFTW library [package for your platform](http://www.fftw.org/download.html).
 *
 * 2. Configure the FFTW distribution. Enable OpenMP support, the desired SIMD instruction set, single precision
 * floating point arithmetic, and specify an installation folder:
\verbatim
  ./configure --enable-single --enable-avx --enable-openmp --enable-shared --prefix=folder_to_install
\endverbatim
 *    If you intend to use the FFTW library (and the C++ code) only on a selected machine and want to get the best
 *    possible performance, you may also add processor specific optimizations and the AVX2 or AVX-512 instructions set.
 *    Note, the compiled binary code is then not likely to be portable on different CPUs. The AVX version will work on
 *    Intel Sandy Bridge and newer, AVX2 on Intel Haswell and newer, and AVX-512 on Skylake SP and newer processors.
\verbatim
  ./configure --enable-single --enable-avx2 --enable-openmp  --enable-shared --with-gcc-arch=native \
              --prefix=folder_to_install
\endverbatim
 *    More information about the installation and customization can be found at [here]
 *    (http://www.fftw.org/fftw3_doc/Installation-and-Customization.html).
 * 3. Make the FFTW library by typing:
\verbatim
  make -j
\endverbatim
 * 4. Install the FFTW library by typing:
\verbatim
  make install
\endverbatim
 *
 *
 * <b>2.3 The Intel Compiler and MKL installation procedure</b>
 *
 * 1. Download the Intel Composer XE package for [your platform](https://software.intel.com/en-us/mkl/choose-download).
 *
 * 2. Run the installation script and follow the procedure by typing:
\verbatim
  ./install.sh
\endverbatim
 *
 *
 * <b>2.4 Compiling the C++ code on Linux</b>
 *
 * After the libraries and the compiler have been installed, you are ready to compile the
 * <tt>kspaceFirstOrder-OMP</tt> code.
 *
 * 1. Open Makefile.
 *
 * 2. The Makefile supports code compilation under GNU compiler with FFTW, or Intel compiler with MKL. Uncomment
 *    the desired compiler by removing the character `<tt>#</tt>'. The GNU compiler is default since it is usually
 *    available on all Linux distributions. Intel compiler, however, produces a faster code but has to be downloaded
 *    from the Intel's website.
\verbatim
   COMPILER = GNU
  #COMPILER = Intel
\endverbatim
 *
 * 3. Select how to link the libraries. Static linking is preferred as it may be a bit faster, however, on some systems
 *   (e.g., HPC clusters) it may be better to use dynamic linking and use the system specific libraries at runtime.
\verbatim
   LINKING = STATIC
  #LINKING = DYNAMIC
\endverbatim
 *
 * 4. Set the installation paths of the libraries (an example is shown below). Zlib and Szip may be required if the
 *    compression is switched on. If using EasyBuild and Lmod (Environment Module System) to manage your software,
 *    please load appropriate modules before running make. The makefile will set the paths automatically.
\verbatim
  MKL_DIR  = $(EBROOTMKL)
  FFT_DIR  = $(EBROOTFFTW)
  HDF5_DIR = $(EBROOTHDF5)
  ZLIB_DIR = $(EBROOTZLIB)
  SZIP_DIR = $(EBROOTSZIP)
\endverbatim
 *
 * 5. Select the instruction set and the CPU architecture.
 *    For users who will only use the binary on the same machine as compiled, the best choice is
 *    <tt>CPU_ARCH = native</tt>. If you are about to run the same binary on different machines or you want to
 *    cross-compile the code, you are free to use any of the possible choices, where AVX is the most general but
 *    slowest and AVX512 is the most recent instruction set and (most likely) the fastest. The fat binary
 *    compiles the code for all architectures, however, can only be used with the Intel compiler.
\verbatim
   CPU_ARCH = native
  #CPU_ARCH = AVX
  #CPU_ARCH = AVX2
  #CPU_ARCH = AVX512
  #CPU_ARCH = FAT_BIN
 \endverbatim
 *
 * 6. Close the makefile and compile the source code by typing:
\verbatim
  make -j
\endverbatim
 * If you want to clean the distribution, type:
\verbatim
  make clean
\endverbatim
 *
 *
 * @section   Parameters 3 Command Line Parameters
 *
 * The C++ code requires two mandatory parameters and accepts a few optional parameters and flags. Ill parameters,
 * bad simulation files, and runtime errors such as out-of-memory problems, lead to an exception followed by an error
 * message shown and execution termination.
 *
 * The mandatory parameters <tt>-i</tt> and <tt>-o</tt> specify the input and output file. The file names respect the
 * path conventions for the particular operating system. If any of the files are not specified, or cannot be found or
 * created, an error message is shown and the code terminates.
 *
 * The <tt>-t</tt> parameter sets the number of CPU threads to be used. If this parameter is not specified, the code
 * first
 * checks the <tt>OMP_NUM_THREADS</tt> variable. If it is not defined, the code uses the number of logical processor
 * cores. If the system support hyper-threading, it is recommended to use only half the number threads to prevent cache
 * overloading. If possible, enable thread binding and placement using export <tt>OMP_PROC_BIND</tt> and
 * <tt>OMP_PLACES</tt> variables.
 *
 * The <tt>-r</tt> parameter specifies how often information about the simulation progress is printed out to the command
 * line. By default, the C++ code prints out the progress of the simulation, the elapsed time, and the estimated time of
 * completion in intervals corresponding to 5% of the total number of times steps.
 *
 * The <tt>-c</tt> parameter specifies the compression level used by the ZIP library to reduce the size of the output
 * file. The actual compression rate is highly dependent on the shape of the sensor mask and the range of stored
 * quantities and may be computationally expensive. In general, the output data is very hard to compress, and using
 * higher compression levels can greatly increase the time to save data while not having a large impact on the final
 * file size. For this reason, compression is disabled by default.
 *
 * The <tt>\--benchmark</tt> parameter enables the total length of simulation (i.e., the number of time steps) to be
 * overwritten by setting a new number of time steps to simulate. This is particularly useful for performance evaluation
 * and benchmarking. As the code performance is relatively stable, 50-100 time steps is usually enough to predict the
 * simulation duration. This parameter can also be used to quickly check the simulation is set up correctly.
 *
 * The <tt>\--verbose</tt> parameter enables three different levels of verbosity to be selected. For routine
 * simulations, the verbose level of 0 (the default) is usually sufficient. For more information about the simulation,
 * checking the parameters of the simulation, code version, CPU used, file paths, and debugging running scripts, verbose
 * levels 1 and 2 may be very useful.
 *
 * The <tt>-h</tt> and <tt>\--help</tt> parameters print all the parameters of the C++ code. The <tt>\--version </tt>
 * parameter reports detailed information about the code useful for debugging and bug reports. It prints out the
 * internal version, the build date and time, the git hash allowing us to track the version of the source code, the
 * operating system, the compiler name, and version and the instruction set used.
 *
 * For jobs that are expected to run for a very long time, it may be useful to  checkpoint and restart the execution.
 * One motivation is the wall clock limit per task on clusters where jobs must fit within a given time span (e.g., 24
 * hours). The second motivation is a level of fault-tolerance where the state of the simulation can be backed up after
 * a predefined period. To enable checkpoint-restart, the user is asked to specify a file to store the actual state
 * of the simulation by  <tt>\--checkpoint_file</tt> and the period in seconds after which the simulation will be
 * interrupted by <tt>\--checkpoint_interval</tt>.  When running on a cluster, please allocate enough time for the
 * checkpoint procedure which may take a non-negligible amount of time (7 matrices have to be stored in the checkpoint
 * file and all aggregated quantities flushed into the output file).
 * Alternatively, the user can specify the number of time steps by <tt>\--checkpoint_timesteps</tt> after which the
 * simulation is interrupted. The time step interval is calculated from the beginning of current leg, not from the
 * beginning of the whole simulation. The user can combine both approaches, seconds and time steps. In this case, the
 * first condition met triggers the checkpoint.
 * Please note, that the checkpoint file name and path is not checked at the beginning of the simulation, but at the
 * time the code starts checkpointing. Thus make sure the file path is correctly specified (otherwise you might not
 * find out the simulation crashed until after the first leg of the simulation finishes). The rationale behind this is
 * that to keep as high level of fault tolerance as possible, the checkpoint file should be touched only when really
 * necessary.
 *
 * When controlling a multi-leg simulation by a script loop, the parameters of the code remain the same in all legs.
 * The first leg of the simulation creates a checkpoint file while the last one deletes it. If the checkpoint file is
 * not found, the simulation starts from the beginning. In order to find out how many steps have been finished, please
 * open the output file and read the variable <tt>t_index</tt> and compare it with <tt>Nt</tt> (e.g., by the h5dump
 * command).
 *
 *
 * The remaining flags specify the output quantities to be recorded during the simulation and stored on disk analogous
 * to the <tt>sensor.record</tt> input in the MATLAB code. If the <tt>-p</tt> or <tt>\--p\_raw</tt> flags are set (these
 * are equivalent), time series of the acoustic pressure at the grid points specified by the sensor mask are recorded.
 * If the  <tt>\--p_rms</tt>, <tt>\--p_max</tt>, <tt>\--p_min</tt> flags are set, the root mean square, maximum and
 * minimum values of the pressure at the grid points specified by the sensor mask are recorded. If the
 * <tt>\--p_final</tt> flag is set, the values for the entire acoustic pressure field at the final time step of the
 * simulation is stored (this will always include the PML, regardless of the setting for <tt> 'PMLInside'</tt> used in
 * the MATLAB code). The flags <tt>\--p_max_all</tt> and <tt>\--p_min_all</tt> calculate the maximum and
 * minimum values over the  entire acoustic pressure field, regardless of the shape of the sensor mask. Flags to record
 * the acoustic particle velocity are defined in an analogous fashion. For accurate calculation of the vector acoustic
 * intensity, the particle velocity has to be shifted onto the same grid as the acoustic pressure. This can be done by
 * using the <tt>\--u_non_staggered_raw</tt> output flag. This first shifts the particle velocity and then samples the
 * grid points specified by the sensor mask. Since the shift operation requires additional FFTs, the impact on the
 * simulation time may be significant. Please note, the shift is done only in the spatial dimensions. The temporal shift
 * has to be done manually after the simulation finishes.  See the k-Wave manual for more details about the staggered
 * grid.
 *
 * Any combination of the <tt>p</tt> and <tt>u</tt> flags is admissible. If no output flag is set, a time-series for the
 * acoustic pressure is recorded. If it is not necessary to collect the output quantities over the entire simulation
 * duration, the starting time step when the collection begins can be specified using the -s parameter.  Note, the index
 * for the first time step is 1 (this follows the MATLAB indexing convention).
 *
 * The <tt>\--copy_sensor_mask</tt> flag will copy the sensor from the input file to the output file at the end of the
 * simulation. This helps in post-processing and visualization of the outputs.
 *
 * The list of all command line parameters are summarized below.
 *
\verbatim
┌───────────────────────────────────────────────────────────────┐
│                  kspaceFirstOrder3D-OMP v1.3                  │
├───────────────────────────────────────────────────────────────┤
│                             Usage                             │
├───────────────────────────────────────────────────────────────┤
│                     Mandatory parameters                      │
├───────────────────────────────────────────────────────────────┤
│ -i <file_name>                │ HDF5 input file               │
│ -o <file_name>                │ HDF5 output file              │
├───────────────────────────────┴───────────────────────────────┤
│                      Optional parameters                      │
├───────────────────────────────┬───────────────────────────────┤
│ -t <num_threads>              │ Number of CPU threads         │
│                               │  (default =  4)               │
│ -r <interval_in_%>            │ Progress print interval       │
│                               │   (default =  5%)             │
│ -c <compression_level>        │ Compression level <0,9>       │
│                               │   (default = 0)               │
│ --benchmark <time_steps>      │ Run only a specified number   │
│                               │   of time steps               │
│ --verbose <level>             │ Level of verbosity <0,2>      │
│                               │   0 - basic, 1 - advanced,    │
│                               │   2 - full                    │
│                               │   (default = basic)           │
│ -h, --help                    │ Print help                    │
│ --version                     │ Print version and build info  │
├───────────────────────────────┼───────────────────────────────┤
│ --checkpoint_file <file_name> │ HDF5 Checkpoint file          │
│ --checkpoint_interval <sec>   │ Checkpoint after a given      │
│                               │   number of seconds           │
│ --checkpoint_timesteps <step> │ Checkpoint after a given      │
│                               │   number of time steps        │
├───────────────────────────────┴───────────────────────────────┤
│                          Output flags                         │
├───────────────────────────────┬───────────────────────────────┤
│ -p                            │ Store acoustic pressure       │
│                               │   (default output flag)       │
│                               │   (the same as --p_raw)       │
│ --p_raw                       │ Store raw time series of p    │
│ --p_rms                       │ Store rms of p                │
│ --p_max                       │ Store max of p                │
│ --p_min                       │ Store min of p                │
│ --p_max_all                   │ Store max of p (whole domain) │
│ --p_min_all                   │ Store min of p (whole domain) │
│ --p_final                     │ Store final pressure field    │
├───────────────────────────────┼───────────────────────────────┤
│ -u                            │ Store ux, uy, uz              │
│                               │    (the same as --u_raw)      │
│ --u_raw                       │ Store raw time series of      │
│                               │    ux, uy, uz                 │
│ --u_non_staggered_raw         │ Store non-staggered raw time  │
│                               │   series of ux, uy, uz        │
│ --u_rms                       │ Store rms of ux, uy, uz       │
│ --u_max                       │ Store max of ux, uy, uz       │
│ --u_min                       │ Store min of ux, uy, uz       │
│ --u_max_all                   │ Store max of ux, uy, uz       │
│                               │   (whole domain)              │
│ --u_min_all                   │ Store min of ux, uy, uz       │
│                               │   (whole domain)              │
│ --u_final                     │ Store final acoustic velocity │
├───────────────────────────────┼───────────────────────────────┤
│ -s <time_step>                │ When data collection begins   │
│                               │   (default = 1)               │
│ --copy_sensor_mask            │ Copy sensor mask to the       │
│                               │    output file                │
└───────────────────────────────┴───────────────────────────────┘
\endverbatim
 *
 *
 * @section   HDF5Files 4 HDF5 File Structure
 *
 * The C++ code has been designed as a standalone application supporting both 2D, 3D and axisymmetric simulations which
 * are not dependent on MATLAB libraries or a MEX interface. This is of particular importance when using servers and
 * supercomputers without MATLAB support. For this reason, simulation data must be transferred between the C++ code and
 * MATLAB using external input and output files. These files are stored using the [Hierarchical Data Format HDF5]
 * (http://www.hdfgroup.org/HDF5/). This is a data model, library, and file format for storing and managing data. It
 * supports a variety of datatypes, and is designed for flexible and efficient I/O and for high volume and complex data.
 * The HDF5 technology suite includes tools and applications for managing, manipulating, viewing, and analysing data in
 * the HDF5 format.
 *
 *
 * Each HDF5 file is a container for storing a variety of scientific data and is composed of two primary types of
 * objects: groups and datasets. An HDF5 group is a structure containing zero or more HDF5 objects, together with
 * supporting metadata. An HDF5 group can be seen as a disk folder. An HDF5 dataset is a multidimensional array of data
 * elements, together with supporting metadata. An HDF5 dataset can be seen as a disk file. Any HDF5 group or dataset
 * may also have an associated attribute list. An HDF5 attribute is a user-defined HDF5 structure that provides extra
 * information about an HDF5 object. More information can be obtained from the [HDF5 documentation]
 * (https://portal.hdfgroup.org/display/HDF5/HDF5).
 *
 *
 * kspaceFirstOrder-OMP v1.3 uses a new file format of version 1.2, which adds support for an axisymmetric coordinate
 * system and removes the definition of derivative and shift operators, as well as the PML. These variables are instead
 * generated in the preprocessing phase and make the file structure simpler. The code is happy to work with all previous
 * file versions (1.0 and 1.1), however, some features will not be supported. Namely, the cuboid sensor mask, and
 * <tt>u_non_staggered_raw</tt> are not supported in version 1.0, and axisymmetric simulations are not supported in
 * version 1.1. When running from the C++ code using the MATLAB k-Wave Toolbox v1.3, the files will always be written in
 * file format version 1.2. The output file is always written in version 1.2.
 *
 *
 * All datasets in the HDF5 files are stored as multi-dimensional datasets in row-major order. When working from within
 * Matlab, the data is automatically rotated from column-major to row-major. For the sake of simplicity, we will present
 * the dataset dimensions in a more natural column-major order <tt>(Nx, Ny, Nz)</tt>, ignoring that the data is
 * physically stored as <tt>(Nz, Ny, Nx)</tt>.
 *
 * The HDF5 input file for the C++ simulation code contains a file header with a brief description of the simulation
 * stored in string attributes, and the root group <tt>'/'</tt> which stores all the simulation properties in the form
 * of 3D datasets irrespective of whether the simulation is in 2D or 3D. In the case of 2D simulation, Nz equals to 1.
 * A complete list of input datasets is  given below.
 *
 * The HDF5 checkpoint file contains the same file header as the input file and the root group <tt>'/'</tt> with a few
 * datasets which capture the actual simulation state. The HDF5 output file contains a file header with the simulation
 * description as well as performance statistics, such as the simulation time and memory consumption, stored in string
 * attributes.
 *
 * The results of the simulation are stored in the root group <tt>'/'</tt> in the form of 3D or 4D datasets. If a linear
 * sensor mask is used, all output quantities are stored as datasets in the root group. If a cuboid corners sensor mask
 * is used, the sampled quantities form private groups containing datasets on per cuboid basis.
 *
\verbatim
+----------------------------------------------------------------------------------------------------------------------+
|                                           Input File / Checkpoint File Header                                        |
+----------------------------------------------------------------------------------------------------------------------+
| created_by                              Short description of the tool that created this file                         |
| creation_date                           Date when the file was created                                               |
| file_description                        Short description of the content of the file (e.g. simulation name)          |
| file_type                               Type of the file (input)                                                     |
| major_version                           Major version of the file definition (1)                                     |
| minor_version                           Minor version of the file definition (2)                                     |
+----------------------------------------------------------------------------------------------------------------------+
\endverbatim
 *
 *
\verbatim
+----------------------------------------------------------------------------------------------------------------------+
|                                                    Output File Header                                                |
+----------------------------------------------------------------------------------------------------------------------+
| created_by                              Short description of the tool that created this file                         |
| creation_date                           Date when the file was created                                               |
| file_description                        Short description of the content of the file (e.g. simulation name)          |
| file_type                               Type of the file (output)                                                    |
| major_version                           Major version of the file definition (1)                                     |
| minor_version                           Minor version of the file definition (2)                                     |
+----------------------------------------------------------------------------------------------------------------------+
| host_names                              List of hosts (computer names, CPUs, GPUs) the simulation was executed on    |
| number_of_cpu_cores                     Number of CPU cores used for the simulation                                  |
| data_loading_phase_execution_time       Time taken to load data from the file                                        |
| pre-processing_phase_execution_time     Time taken to pre-process data                                               |
| simulation_phase_execution_time         Time taken to run the simulation                                             |
| post-processing_phase_execution_time    Time taken to complete the post-processing phase                             |
| total_execution_time                    Total execution time                                                         |
| peak_core_memory_in_use                 Peak memory required per core during the simulation                          |
| total_memory_in_use                     Peak memory in use                                                           |
+----------------------------------------------------------------------------------------------------------------------+
\endverbatim
 *
 *
 * The input and checkpoint files store all quantities as three dimensional datasets stored in row-major order. If the
 * simulation is 2D, Nz equals to 1. In order to support scalars and 1D and 2D arrays, the unused dimensions are
 * set to 1. For example, scalar variables are stored with a dimension size of <tt>(1,1,1)</tt>, 1D vectors oriented in
 * y-direction are stored with a dimension size of <tt>(1, Ny, 1)</tt>, and so on. If the dataset stores a complex
 * variable, the real and imaginary parts are stored in an interleaved layout and the lowest used dimension size is
 * doubled (i.e., Nx for a 3D matrix, Ny for a 1D vector oriented in the y-direction). The datasets are physically
 * stored using either the <tt>'H5T_IEEE_F32LE'</tt> or <tt>'H5T_STD_U64LE'</tt> data type for floating point or
 * integer based datasets, respectively. All the datasets are stored under the root group.
 *
 * The output file of version 1.0 could only store recorded quantities as 3D datasets under the root group. However,
 * from version 1.1 on which supports a cuboid corner sensor mask, the sampled quantities may be laid out as 4D
 * quantities stored under specific groups. The dimensions are always <tt>(Nx, Ny, Nz, Nt)</tt>, with every sampled
 * cuboid stored as a distinct dataset, and the datasets grouped under a group named by the quantity stored. This makes
 * the file clearly readable and easy to parse.
 *
 * In order to enable compression and more efficient data processing, big datasets are not stored as monolithic blocks
 * but broken into chunks that may be compressed by the ZIP library and stored separately. The chunk size is defined
 * as follows:
 *
 * \li <tt> (1M elements, 1, 1)     </tt> in the case of 1D variables - index sensor mask (8MB blocks).
 * \li <tt> (Nx, Ny, 1)             </tt> in the case of 3D variables (one 2D slab).
 * \li <tt> (Nx, Ny, Nz, 1)         </tt> in the case of 4D variables (one time step).
 * \li <tt> (N_sensor_points, 1, 1) </tt> in the case of the output time series (one time step of the simulation).
 *
 * All datasets have two attributes that specify the content of the dataset. The <tt>'data_type'</tt> attribute
 * specifies the data type of the dataset. The admissible values are either <tt>'float'</tt> or <tt>'long'</tt>. The
 * <tt>'domain_type'</tt> attribute specifies the domain of the dataset. The admissible values are either <tt>'real'
 * </tt> for the real domain or <tt>'complex'</tt> for the complex domain. The C++ code reads these attributes and
 * checks their values.
 *
 *
\verbatim
+----------------------------------------------------------------------------------------------------------------------+
|                                                   Input File Datasets                                                |
+----------------------------------------------------------------------------------------------------------------------+
| Name                        Size             Data type     Domain Type    Condition of Presence                      |
+----------------------------------------------------------------------------------------------------------------------+
| 1. Simulation Flags                                                                                                  |
+----------------------------------------------------------------------------------------------------------------------+
| ux_source_flag              (1, 1, 1)        long          real                                                      |
| uy_source_flag              (1, 1, 1)        long          real                                                      |
| uz_source_flag              (1, 1, 1)        long          real           Nz > 1                                     |
| p_source_flag               (1, 1, 1)        long          real                                                      |
| p0_source_flag              (1, 1, 1)        long          real                                                      |
| transducer_source_flag      (1, 1, 1)        long          real                                                      |
| nonuniform_grid_flag        (1, 1, 1)        long          real           must be set to 0                           |
| nonlinear_flag              (1, 1, 1)        long          real                                                      |
| absorbing_flag              (1, 1, 1)        long          real                                                      |
| axisymmetric_flag           (1, 1, 1)        long          real           file_ver == 1.2                            |
+----------------------------------------------------------------------------------------------------------------------+
| 2. Grid Properties                                                                                                   |
+----------------------------------------------------------------------------------------------------------------------+
| Nx                          (1, 1, 1)        long          real                                                      |
| Ny                          (1, 1, 1)        long          real                                                      |
| Nz                          (1, 1, 1)        long          real                                                      |
| Nt                          (1, 1, 1)        long          real                                                      |
| dt                          (1, 1, 1)        float         real                                                      |
| dx                          (1, 1, 1)        float         real                                                      |
| dy                          (1, 1, 1)        float         real                                                      |
| dz                          (1, 1, 1)        float         real           Nz > 1                                     |
+----------------------------------------------------------------------------------------------------------------------+
| 3. Medium Properties                                                                                                 |
+----------------------------------------------------------------------------------------------------------------------+
| 3.1 Regular Medium Properties                                                                                        |
| rho0                        (Nx, Ny, Nz)     float         real           heterogenous                               |
|                             (1, 1, 1)        float         real           homogenous                                 |
| rho0_sgx                    (Nx, Ny, Nz)     float         real           heterogenous                               |
|                             (1, 1, 1)        float         real           homogenous                                 |
| rho0_sgy                    (Nx, Ny, Nz)     float         real           heterogenous                               |
|                             (1, 1, 1)        float         real           homogenous                                 |
| rho0_sgz                    (Nx, Ny, Nz)     float         real           Nz > 1 and heterogenous                    |
|                             (1, 1, 1)        float         real           Nz > 1 and homogenous                      |
| c0                          (Nx, Ny, Nz)     float         real           heterogenous                               |
|                             (1, 1, 1)        float         real           homogenous                                 |
| c_ref                       (1, 1, 1)        float         real                                                      |
|                                                                                                                      |
| 3.2 Nonlinear Medium Properties (defined if (nonlinear_flag == 1))                                                   |
| BonA                        (Nx, Ny, Nz)     float         real           heterogenous                               |
|                             (1, 1, 1)        float         real           homogenous                                 |
|                                                                                                                      |
| 3.3 Absorbing Medium Properties (defined if (absorbing_flag == 1))                                                   |
| alpha_coef                  (Nx, Ny, Nz)     float         real           heterogenous                               |
|                             (1, 1, 1)        float         real           homogenous                                 |
| alpha_power                 (1, 1, 1)        float         real                                                      |
+----------------------------------------------------------------------------------------------------------------------+
| 4. Sensor Variables                                                                                                  |
+----------------------------------------------------------------------------------------------------------------------+
| sensor_mask_type            (1, 1, 1)        long          real           file_ver > 1.0                             |
|                                                                           (0 = index, 1 = corners)                   |
| sensor_mask_index           (Nsens, 1, 1)    long          real           file_ver == 1.0 always,                    |
|                                                                           file_ver > 1.0 and sensor_mask_type == 0   |
| sensor_mask_corners         (Ncubes, 6, 1)   long          real           file_ver > 1.0 and sensor_mask_type == 1   |
+----------------------------------------------------------------------------------------------------------------------+
| 5 Source Properties                                                                                                  |
+----------------------------------------------------------------------------------------------------------------------+
| 5.1 Velocity Source Terms (defined if (ux_source_flag == 1 || uy_source_flag == 1 || uz_source_flag == 1))           |
| u_source_mode               (1, 1, 1)          long        real                                                      |
| u_source_many               (1, 1, 1)          long        real                                                      |
| u_source_index              (Nsrc, 1, 1)       long        real                                                      |
| ux_source_input             (1, Nt_src, 1)     float       real           u_source_many == 0                         |
|                             (Nsrc, Nt_src, 1)  float       real           u_source_many == 1                         |
| uy_source_input             (1, Nt_src,  1)    float       real           u_source_many == 0                         |
|                             (Nsrc, Nt_src, 1)  float       real           u_source_many == 1                         |
| uz_source_input             (1, Nt_src, 1)     float       real           Nz > 1 and u_source_many == 0              |
|                             (Nt_src, Nsrc, 1)  float       real           Nz > 1 and u_source_many == 1              |
|                                                                                                                      |
| 5.2 Pressure Source Terms (defined if (p_source_flag == 1))                                                          |
| p_source_mode               (1, 1, 1)          long        real                                                      |
| p_source_many               (1, 1, 1)          long        real                                                      |
| p_source_index              (Nsrc, 1, 1)       long        real                                                      |
| p_source_input              (Nsrc, Nt_src, 1)  float       real           p_source_many == 1                         |
|                             (1, Nt_src, 1)     float       real           p_source_many == 0                         |
|                                                                                                                      |
| 5.3 Transducer Source Terms (defined if (transducer_source_flag == 1))                                               |
| u_source_index              (Nsrc, 1, 1)       long        real                                                      |
| transducer_source_input     (Nt_src, 1, 1)     float       real                                                      |
| delay_mask                  (Nsrc, 1, 1)       float       real                                                      |
|                                                                                                                      |
| 5.4 IVP Source Terms (defined if ( p0_source_flag == 1))                                                             |
| p0_source_input             (Nx, Ny, Nz)       float       real                                                      |
+----------------------------------------------------------------------------------------------------------------------+
| 6. K-space and Shift Variables defined if (file version < 1.2)                                                       |
+----------------------------------------------------------------------------------------------------------------------+
| ddx_k_shift_pos_r           (Nx/2 + 1, 1, 1)  float        complex                                                   |
| ddx_k_shift_neg_r           (Nx/2 + 1, 1, 1)  float        complex                                                   |
| ddy_k_shift_pos             (1, Ny, 1)        float        complex                                                   |
| ddy_k_shift_neg             (1, Ny, 1)        float        complex                                                   |
| ddz_k_shift_pos             (1, 1, Nz)        float        complex        Nz > 1                                     |
| ddz_k_shift_neg             (1, 1, Nz)        float        complex        Nz > 1                                     |
| x_shift_neg_r               (Nx/2 + 1, 1, 1)  float        complex        file_ver > 1.0                             |
| y_shift_neg_r               (1, Ny/2 + 1, 1)  float        complex        file_ver > 1.0                             |
| z_shift_neg_r               (1, 1, Nz/2)      float        complex        Nz > 1 and file_ver > 1.0                  |
+----------------------------------------------------------------------------------------------------------------------+
| 7. PML Variables                                                                                                     |
+----------------------------------------------------------------------------------------------------------------------+
| pml_x_size                  (1, 1, 1)       long           real                                                      |
| pml_y_size                  (1, 1, 1)       long           real                                                      |
| pml_z_size                  (1, 1, 1)       long           real           Nz > 1                                     |
| pml_x_alpha                 (1, 1, 1)       float          real                                                      |
| pml_y_alpha                 (1, 1, 1)       float          real                                                      |
| pml_z_alpha                 (1, 1, 1)       float          real           Nz > 1                                     |
|                                                                                                                      |
| pml_x                       (Nx, 1, 1)      float          real           file_ver < 1.2                             |
| pml_x_sgx                   (Nx, 1, 1)      float          real           file_ver < 1.2                             |
| pml_y                       (1, Ny, 1)      float          real           file_ver < 1.2                             |
| pml_y_sgy                   (1, Ny, 1)      float          real           file_ver < 1.2                             |
| pml_z                       (1, 1, Nz)      float          real           Nz > 1 and file_ver < 1.2                  |
| pml_z_sgz                   (1, 1, Nz)      float          real           Nz > 1 and file_ver < 1.2                  |
+----------------------------------------------------------------------------------------------------------------------+
\endverbatim
*
*
\verbatim
+----------------------------------------------------------------------------------------------------------------------+
|                                            Checkpoint File Datasets                                                  |
+----------------------------------------------------------------------------------------------------------------------+
| Name                        Size            Data type      Domain Type    Condition of Presence                      |
+----------------------------------------------------------------------------------------------------------------------+
| 1. Grid Properties                                                                                                   |
+----------------------------------------------------------------------------------------------------------------------+
| Nx                          (1, 1, 1)       long           real                                                      |
| Ny                          (1, 1, 1)       long           real                                                      |
| Nz                          (1, 1, 1)       long           real                                                      |
| t_index                     (1, 1, 1)       long           real                                                      |
+----------------------------------------------------------------------------------------------------------------------+
|  2. Simulation State                                                                                                 |
+----------------------------------------------------------------------------------------------------------------------+
| p                           (Nx, Ny, Nz)    float          real                                                      |
| ux_sgx                      (Nx, Ny, Nz)    float          real                                                      |
| uy_sgy                      (Nx, Ny, Nz)    float          real                                                      |
| uz_sgz                      (Nx, Ny, Nz)    float          real           Nz > 1                                     |
| rhox                        (Nx, Ny, Nz)    float          real                                                      |
| rhoy                        (Nx, Ny, Nz)    float          real                                                      |
| rhoz                        (Nx, Ny, Nz)    float          real           Nz > 1                                     |
+----------------------------------------------------------------------------------------------------------------------+
\endverbatim
*
*
\verbatim
+----------------------------------------------------------------------------------------------------------------------+
|                                                 Output File Datasets                                                 |
+----------------------------------------------------------------------------------------------------------------------+
| Name                        Size            Data type      Domain Type    Condition of Presence                      |
+----------------------------------------------------------------------------------------------------------------------+
| 1. Simulation Flags                                                                                                  |
+----------------------------------------------------------------------------------------------------------------------+
| ux_source_flag              (1, 1, 1)       long           real                                                      |
| uy_source_flag              (1, 1, 1)       long           real                                                      |
| uz_source_flag              (1, 1, 1)       long           real           Nz > 1                                     |
| p_source_flag               (1, 1, 1)       long           real                                                      |
| p0_source_flag              (1, 1, 1)       long           real                                                      |
| transducer_source_flag      (1, 1, 1)       long           real                                                      |
| nonuniform_grid_flag        (1, 1, 1)       long           real                                                      |
| nonlinear_flag              (1, 1, 1)       long           real                                                      |
| absorbing_flag              (1, 1, 1)       long           real                                                      |
| axisymmetric_flag           (1, 1, 1)       long           real           file_ver == 1.2                            |
| u_source_mode               (1, 1, 1)       long           real           if u_source                                |
| u_source_many               (1, 1, 1)       long           real           if u_source                                |
| p_source_mode               (1, 1, 1)       long           real           if p_source                                |
| p_source_many               (1, 1, 1)       long           real           if p_source                                |
+----------------------------------------------------------------------------------------------------------------------+
| 2. Grid Properties                                                                                                   |
+----------------------------------------------------------------------------------------------------------------------+
| Nx                          (1, 1, 1)       long           real                                                      |
| Ny                          (1, 1, 1)       long           real                                                      |
| Nz                          (1, 1, 1)       long           real                                                      |
| Nt                          (1, 1, 1)       long           real                                                      |
| t_index                     (1, 1, 1)       long           real                                                      |
| dt                          (1, 1, 1)       float          real                                                      |
| dx                          (1, 1, 1)       float          real                                                      |
| dy                          (1, 1, 1)       float          real                                                      |
| dz                          (1, 1, 1)       float          real           Nz > 1                                     |
+----------------------------------------------------------------------------------------------------------------------+
| 3. PML Variables                                                                                                     |
+----------------------------------------------------------------------------------------------------------------------+
| pml_x_size                  (1, 1, 1)       long           real                                                      |
| pml_y_size                  (1, 1, 1)       long           real                                                      |
| pml_z_size                  (1, 1, 1)       long           real           Nz > 1                                     |
| pml_x_alpha                 (1, 1, 1)       float          real                                                      |
| pml_y_alpha                 (1, 1, 1)       float          real                                                      |
| pml_z_alpha                 (1, 1, 1)       float          real           Nz > 1                                     |
|                                                                                                                      |
+----------------------------------------------------------------------------------------------------------------------+
| 4. Sensor Variables (present if --copy_sensor_mask and file version > 1.0)                                           |
+----------------------------------------------------------------------------------------------------------------------+
| sensor_mask_type            (1, 1, 1)       long           real           --copy_sensor_mask                         |
| sensor_mask_index           (Nsens, 1, 1)   long           real           and sensor_mask_type == 0                  |
| sensor_mask_corners         (Ncubes, 6, 1)  long           real           and sensor_mask_type == 1                  |
+----------------------------------------------------------------------------------------------------------------------+
| 5a. Simulation Results: if sensor_mask_type == 0 (index), or File version == 1.0                                     |
+----------------------------------------------------------------------------------------------------------------------+
| p                           (Nsens, Nt - s, 1) float       real           -p or --p_raw                              |
| p_rms                       (Nsens, 1, 1)      float       real           --p_rms                                    |
| p_max                       (Nsens, 1, 1)      float       real           --p_max                                    |
| p_min                       (Nsens, 1, 1)      float       real           --p_min                                    |
| p_max_all                   (Nx, Ny, Nz)       float       real           --p_max_all                                |
| p_min_all                   (Nx, Ny, Nz)       float       real           --p_min_all                                |
| p_final                     (Nx, Ny, Nz)       float       real           --p_final                                  |
|                                                                                                                      |
| ux                          (Nsens, Nt - s, 1) float       real           -u or --u_raw                              |
| uy                          (Nsens, Nt - s, 1) float       real           -u or --u_raw                              |
| uz                          (Nsens, Nt - s, 1) float       real           -u or --u_raw and Nz > 1                   |
|                                                                                                                      |
| ux_non_staggered            (Nsens, Nt - s, 1) float       real           --u_non_staggered_raw                      |
| uy_non_staggered            (Nsens, Nt - s, 1) float       real           --u_non_staggered_raw                      |
| uz_non_staggered            (Nsens, Nt - s, 1) float       real           --u_non_staggered_raw                      |
|                                                                                       and Nz > 1                     |
|                                                                                                                      |
| ux_rms                      (Nsens, 1, 1)      float       real           --u_rms                                    |
| uy_rms                      (Nsens, 1, 1)      float       real           --u_rms                                    |
| uz_rms                      (Nsens, 1, 1)      float       real           --u_rms     and Nz > 1                     |
|                                                                                                                      |
| ux_max                      (Nsens, 1, 1)      float       real           --u_max                                    |
| uy_max                      (Nsens, 1, 1)      float       real           --u_max                                    |
| uz_max                      (Nsens, 1, 1)      float       real           --u_max     and Nz > 1                     |
|                                                                                                                      |
| ux_min                      (Nsens, 1, 1)      float       real           --u_min                                    |
| uy_min                      (Nsens, 1, 1)      float       real           --u_min                                    |
| uz_min                      (Nsens, 1, 1)      float       real           --u_min     and Nz > 1                     |
|                                                                                                                      |
| ux_max_all                  (Nx, Ny, Nz)       float       real           --u_max_all                                |
| uy_max_all                  (Nx, Ny, Nz)       float       real           --u_max_all                                |
| uz_max_all                  (Nx, Ny, Nz)       float       real           --u_max_all and Nz > 1                     |
|                                                                                                                      |
| ux_min_all                  (Nx, Ny, Nz)       float       real           --u_min_all                                |
| uy_min_all                  (Nx, Ny, Nz)       float       real           --u_min_all                                |
| uz_min_all                  (Nx, Ny, Nz)       float       real           --u_min_all and Nz > 1                     |
|                                                                                                                      |
| ux_final                    (Nx, Ny, Nz)       float       real           --u_final                                  |
| uy_final                    (Nx, Ny, Nz)       float       real           --u_final                                  |
| uz_final                    (Nx, Ny, Nz)       float       real           --u_final   and Nz > 1                     |
+----------------------------------------------------------------------------------------------------------------------+
| 5b. Simulation Results: if sensor_mask_type == 1 (corners) and file version > 1.0                                    |
+----------------------------------------------------------------------------------------------------------------------+
| /p                          group of datasets, one per cuboid             -p or --p_raw                              |
| /p/1                        (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
| /p/2                        (Cx, Cy, Cz, Nt-s) float       real             2nd sampled cuboid, etc.                 |
|                                                                                                                      |
| /p_rms                      group of datasets, one per cuboid             --p_rms                                    |
| /p_rms/1                    (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
|                                                                                                                      |
| /p_max                      group of datasets, one per cuboid             --p_max                                    |
| /p_max/1                    (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
|                                                                                                                      |
| /p_min                      group of datasets, one per cuboid             --p_min                                    |
| /p_min/1                    (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
|                                                                                                                      |
| p_max_all                   (Nx, Ny, Nz)       float       real           --p_max_all                                |
| p_min_all                   (Nx, Ny, Nz)       float       real           --p_min_all                                |
| p_final                     (Nx, Ny, Nz)       float       real           --p_final                                  |
|                                                                                                                      |
|                                                                                                                      |
| /ux                         group of datasets, one per cuboid             -u or --u_raw                              |
| /ux/1                       (Cx, Cy, Cz, Nt-s) float       real              1st sampled cuboid                      |
| /uy                         group of datasets, one per cuboid             -u or --u_raw                              |
| /uy/1                       (Cx, Cy, Cz, Nt-s) float       real              1st sampled cuboid                      |
| /uz                         group of datasets, one per cuboid             -u or --u_raw         and Nz > 1           |
| /uz/1                       (Cx, Cy, Cz, Nt-s) float       real              1st sampled cuboid                      |
|                                                                                                                      |
| /ux_non_staggered           group of datasets, one per cuboid             --u_non_staggered_raw                      |
| /ux_non_staggered/1         (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
| /uy_non_staggered           group of datasets, one per cuboid             --u_non_staggered_raw                      |
| /uy_non_staggered/1         (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
| /uz_non_staggered           group of datasets, one per cuboid             --u_non_staggered_raw and Nz > 1           |
| /uz_non_staggered/1         (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
|                                                                                                                      |
| /ux_rms                     group of datasets, one per cuboid             --u_rms                                    |
| /ux_rms/1                   (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
| /uy_rms                     group of datasets, one per cuboid             --u_rms                                    |
| /uy_rms/1                   (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
| /uz_rms                     group of datasets, one per cuboid             --u_rms               and Nz > 1           |
| /uy_rms/1                   (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
|                                                                                                                      |
| /ux_max                     group of datasets, one per cuboid             --u_max                                    |
| /ux_max/1                   (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
| /uy_max                     group of datasets, one per cuboid             --u_max                                    |
| /ux_max/1                   (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
| /uz_max                     group of datasets, one per cuboid             --u_max               and Nz > 1           |
| /ux_max/1                   (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
|                                                                                                                      |
| /ux_min                     group of datasets, one per cuboid             --u_min                                    |
| /ux_min/1                   (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
| /uy_min                     group of datasets, one per cuboid             --u_min                                    |
| /ux_min/1                   (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
| /uz_min                     group of datasets, one per cuboid             --u_min               and Nz > 1           |
| /ux_min/1                   (Cx, Cy, Cz, Nt-s) float       real             1st sampled cuboid                       |
|                                                                                                                      |
| ux_max_all                  (Nx, Ny, Nz)       float       real           --u_max_all                                |
| uy_max_all                  (Nx, Ny, Nz)       float       real           --u_max_all                                |
| uz_max_all                  (Nx, Ny, Nz)       float       real           --u_max_all           and Nz > 1           |
|                                                                                                                      |
| ux_min_all                  (Nx, Ny, Nz)       float       real           --u_min_all                                |
| uy_min_all                  (Nx, Ny, Nz)       float       real           --u_min_all                                |
| uz_min_all                  (Nx, Ny, Nz)       float       real           --u_min_all           and Nz > 1           |
|                                                                                                                      |
| ux_final                    (Nx, Ny, Nz)       float       real           --u_final                                  |
| uy_final                    (Nx, Ny, Nz)       float       real           --u_final                                  |
| uz_final                    (Nx, Ny, Nz)       float       real           --u_final             and Nz > 1           |
+----------------------------------------------------------------------------------------------------------------------+
\endverbatim
 *
 *
 * @copyright Copyright (C) 2012 - 2020 SC\@FIT Research Group, Brno University of Technology, Brno, CZ.
 *
 * This file is part of the C++ extension of the [k-Wave Toolbox](http://www.k-wave.org).
 *
 * k-Wave is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * k-Wave is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for
 * more details.
 *
 * You should have received a copy of the GNU Lesser General Public License along with k-Wave.
 * If not, see [http://www.gnu.org/licenses/](http://www.gnu.org/licenses/).
 */

#include <exception>

#ifdef _OPENMP
  #include <omp.h>
#endif

#include <KSpaceSolver/KSpaceFirstOrderSolver.h>
#include <Logger/Logger.h>

using std::string;

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Global methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * The main function of the kspaceFirstOrder-OMP.
 *
 * @param [in] argc - Number of command line parameters.
 * @param [in] argv - Command line parameters.
 * @return EXIT_SUCCESS - If the simulation completed correctly.
 */
int main(int argc, char** argv)
{
  // Create k-Space solver
  KSpaceFirstOrderSolver kSpaceSolver;

  // Print header
  Logger::log(Logger::LogLevel::kBasic, kOutFmtFirstSeparator);
  Logger::log(Logger::LogLevel::kBasic, kOutFmtCodeName, kSpaceSolver.getCodeName().c_str());
  Logger::log(Logger::LogLevel::kBasic, kOutFmtSeparator);

  // Create parameters and parse command line
  Parameters& parameters = Parameters::getInstance();

  //-------------------------------------------- Initialize simulation -----------------------------------------------//
  try
  {
    // Initialize parameters by parsing the command line and reading input file scalars
    parameters.init(argc, argv);

    // When we know the GPU, we can print out the code version
    if (parameters.isPrintVersionOnly())
    {
      kSpaceSolver.printFullCodeNameAndLicense();
      return EXIT_SUCCESS;
    }
  }
  catch (const std::exception& e)
  {
    Logger::log(Logger::LogLevel::kBasic, kOutFmtFailed);
    Logger::log(Logger::LogLevel::kBasic, kOutFmtLastSeparator);
    Logger::errorAndTerminate(Logger::wordWrapString(e.what(),kErrFmtPathDelimiters, 9));
  }

  // Set number of threads
  #ifdef _OPENMP
    omp_set_num_threads(parameters.getNumberOfThreads());
  #endif

  // Print simulation setup
  parameters.printSimulatoinSetup();

  Logger::log(Logger::LogLevel::kBasic, kOutFmtInitializationHeader);

  //------------------------------------------------ Allocate memory -------------------------------------------------//
  try
  {
    kSpaceSolver.allocateMemory();
  }
  catch (const std::bad_alloc& e)
  {
    Logger::log(Logger::LogLevel::kBasic, kOutFmtFailed);
    Logger::log(Logger::LogLevel::kBasic, kOutFmtLastSeparator);
    // 9 = Indentation of Error:
    Logger::errorAndTerminate(Logger::wordWrapString(kErrFmtOutOfMemory," ", 9));
  }
  catch (const std::exception& e)
  {
    Logger::log(Logger::LogLevel::kBasic, kOutFmtFailed);
    Logger::log(Logger::LogLevel::kBasic, kOutFmtLastSeparator);

    const string errorMessage = string(kErrFmtUnknownError) + e.what();
    Logger::errorAndTerminate(Logger::wordWrapString(errorMessage, kErrFmtPathDelimiters, 9));
  }

  //------------------------------------------------ Load input data -------------------------------------------------//
  try
  {
    kSpaceSolver.loadInputData();
  }
  catch (const std::ios::failure& e)
  {
    Logger::log(Logger::LogLevel::kBasic, kOutFmtFailed);
    Logger::log(Logger::LogLevel::kBasic, kOutFmtLastSeparator);
    // 9 = Indentation of Error:
    Logger::errorAndTerminate(Logger::wordWrapString(e.what(), kErrFmtPathDelimiters, 9));
  }
  catch (const std::exception& e)
  {
    Logger::log(Logger::LogLevel::kBasic, kOutFmtFailed);
    Logger::log(Logger::LogLevel::kBasic, kOutFmtLastSeparator);

    const string errorMessage = string(kErrFmtUnknownError) + e.what();
    Logger::errorAndTerminate(Logger::wordWrapString(errorMessage, kErrFmtPathDelimiters, 9));
  }

  // Did we recover from checkpoint?
  if (parameters.getTimeIndex() > 0)
  {
    Logger::log(Logger::LogLevel::kBasic, kOutFmtSeparator);
    Logger::log(Logger::LogLevel::kBasic, kOutFmtRecoveredFrom, parameters.getTimeIndex());
  }

  //-------------------------------------------------- Simulation ----------------------------------------------------//
  Logger::log(Logger::LogLevel::kBasic, kOutFmtSeparator);
  // Exception are caught inside due to different log formats
  kSpaceSolver.compute();

  //----------------------------------------------------- Summary ----------------------------------------------------//
  Logger::log(Logger::LogLevel::kBasic, kOutFmtSummaryHeader);
  Logger::log(Logger::LogLevel::kBasic, kOutFmtMemoryUsage, kSpaceSolver.getMemoryUsage());

  Logger::log(Logger::LogLevel::kBasic, kOutFmtSeparator);

  // Elapsed Time time
  if (kSpaceSolver.getCumulatedTotalTime() != kSpaceSolver.getTotalTime())
  {
    Logger::log(Logger::LogLevel::kBasic, kOutFmtLegExecutionTime, kSpaceSolver.getTotalTime());
  }
  Logger::log(Logger::LogLevel::kBasic, kOutFmtTotalExecutionTime, kSpaceSolver.getCumulatedTotalTime());

  Logger::log(Logger::LogLevel::kBasic, kOutFmtEndOfSimulation);

  return EXIT_SUCCESS;
}// end of main
//----------------------------------------------------------------------------------------------------------------------
