/**
 * @file      Hdf5File.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file containing a class managing HDF5 files.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      27 July      2012, 14:14 (created) \n
 *            18 February  2020, 15:30 (revised)
 *
 * @section   HDF5File HDF5 File Structure
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

#ifndef HDF5_FILE_H
#define HDF5_FILE_H

#include <hdf5.h>
#include <hdf5_hl.h>
#include <map>

#include <Utils/DimensionSizes.h>

/// Datatype of dataset names in the HDF5 files.
using MatrixName = std::string;

/**
 * @class Hdf5File
 * @brief Class wrapping the HDF5 routines.
 *
 * This class is responsible for working with HDF5 files. It offers routines to manage files (create, open, close)
 * as well as creating, reading and modifying the contents (groups and datasets).
 */
class Hdf5File
{
  public:
    /**
     * @enum    MatrixDataType
     * @brief   HDF5 matrix data type (float or uint64).
     * @details HDF5 matrix data type (float or uint64).
     */
    enum class MatrixDataType
    {
      /// The matrix is stored in floating point 32b wide format.
      kFloat = 0,
      /// The matrix is stored in fixed point point 64b wide format.
      kIndex = 1
    };

    /**
     * @enum    MatrixDomainType
     * @brief   HDF5 Matrix domain type (real or complex).
     * @details HDF5 Matrix domain type (real or complex).
     */
    enum class MatrixDomainType
    {
      /// The matrix is defined on real domain.
      kReal    = 0,
      /// The matrix is defined on complex domain.
      kComplex = 1
    };

    /// Constructor of the class.
    Hdf5File();
    /// Copy constructor not allowed.
    Hdf5File(const Hdf5File&) = delete;
    /// Destructor.
    virtual ~Hdf5File();

    /// Operator = not allowed.
    Hdf5File& operator=(const Hdf5File&) = delete;

    //------------------------------------------- Basic file operations ----------------------------------------------//
    /**
     * @brief   Create the HDF5 file.
     * @details The file is always created in a read write mode, by default, overwriting an old file of the same name.
     *          Other HDF5 flags are set to default.
     *
     * @param [in] fileName - File name.
     * @param [in] flags    - How to create the file, by default overwrite existing file.
     * @throw ios:failure   - If error happened (file is open or cannot be created).
     */
    void create(const std::string& fileName,
                unsigned int       flags = H5F_ACC_TRUNC);
    /**
     * @brief   Open the HDF5 file.
     * @details The file is opened in read only mode by default. Other HDF5 flags are set to default.
     *
     * @param [in] fileName - File name
     * @param [in] flags    - Open mode, by default read only.
     * @throw ios:failure   - If error happened (file not found, file is not an HDF5 file, file is already open).
     *
     */
    void open(const std::string& fileName,
              unsigned int       flags  = H5F_ACC_RDONLY);
    /**
     * @brief   Is the file opened?
     * @details Is the file opened?
     * @return  true - If the file is opened.
     */
    bool isOpen() const { return mFile != H5I_BADID; };
    /**
     * @brief   Can I access the file.
     * @details Can the code access the file, e.g., does it exist, do we have enough privileges, etc.
     *
     * @param  [in] fileName - Name of the file.
     * @return true          - If it is possible to access the file.
     */
    static bool canAccess(const std::string& fileName);
    /**
     * @brief Close the HDF5 file.
     * @throw ios::failure - If an error happens.
     */
    void close();

    //--------------------------------------------- Group manipulators -----------------------------------------------//
    /**
     * @brief   Create an HDF5 group at a specified place in the file tree.
     * @details Other HDF5 flags are set to default.
     *
     * @param [in] parentGroup  - Where to link the group at.
     * @param [in] groupName    - Group name.
     * @return A handle to the new group.
     * @throw ios::failure      - If error happens.
     */
    hid_t createGroup(const hid_t       parentGroup,
                      const MatrixName& groupName);
    /**
     * @brief   Open an HDF5 group at a specified place in the file tree.
     * @details Other HDF5 flags are set to default.
     *
     * @param [in] parentGroup - Parent group.
     * @param [in] groupName   - Group name.
     * @return A handle to the group.
     * @throw ios::failure     - If error happens.
     */
    hid_t openGroup(const hid_t       parentGroup,
                    const MatrixName& groupName);
    /**
     * @brief Close a group.
     * @param [in] group - Group to close.
     */
    void closeGroup(const hid_t group);
    /**
     * @brief   Get handle to the root group of the file.
     * @details Get handle to the root group of the file.
     * @return  Handle to the root group.
     */
    hid_t getRootGroup() const { return mFile; };

    //-------------------------------------------- Dataset manipulators ----------------------------------------------//
    /**
     * @brief   Create a float HDF5 dataset at a specified place in the file tree (3D/4D).
     * @details Other HDF5 flags are set to default.
     *
     * @param [in] parentGroup      - Parent group id.
     * @param [in] datasetName      - Dataset name.
     * @param [in] dimensionSizes   - Dimension sizes.
     * @param [in] chunkSizes       - Chunk sizes.
     * @param [in] matrixDataType   - Matrix data type
     * @param [in] compressionLevel - Compression level.
     * @return A handle to the new dataset.
     * @throw  ios::failure         - If error happens.
     */
    hid_t createDataset(const hid_t           parentGroup,
                        const MatrixName&     datasetName,
                        const DimensionSizes& dimensionSizes,
                        const DimensionSizes& chunkSizes,
                        const MatrixDataType  matrixDataType,
                        const size_t          compressionLevel);
    /**
     * @brief   Open a dataset at a specified place in the file tree.
     * @details Other HDF5 flags are set to default.
     *
     * @param [in] parentGroup - Parent group id (can be the file id for root).
     * @param [in] datasetName - Dataset name.
     * @return A handle to open dataset.
     * @throw ios::failure     - If error happens.
     */
    hid_t openDataset(const hid_t       parentGroup,
                      const MatrixName& datasetName);
    /**
     * @brief Close dataset.
     * @param [in] dataset - Dataset to close.
     */
    void  closeDataset(const hid_t dataset);

    //---------------------------------------- Dataset Read/Write operations -----------------------------------------//
    /**
     * @brief Write a hyperslab into the dataset.
     *
     * @tparam     T         - Data type to be written.
     * @param [in] dataset   - Dataset id.
     * @param [in] position  - Position in the dataset.
     * @param [in] size      - Size of the hyperslab.
     * @param [in] data      - Data to be written.
     * @throw ios::failure   - If error happens.
     * @warning Limited to float and size_t data types.
     */
    template<class T>
    void writeHyperSlab(const hid_t           dataset,
                        const DimensionSizes& position,
                        const DimensionSizes& size,
                        const T*              data);
    /**
     * @brief   Write a cuboid selected within the matrixData into a hyperslab.
     * @details The routine writes a 3D cuboid into a 4D dataset (only intended for output raw time series).
     *
     * @param [in] dataset           - Dataset to write MatrixData into.
     * @param [in] hyperslabPosition - Position in the dataset (hyperslab) - may be 3D/4D.
     * @param [in] cuboidPosition    - Position of the cuboid in MatrixData (what to sample) - must be 3D.
     * @param [in] cuboidSize        - Cuboid size (size of data being sampled) - must by 3D.
     * @param [in] matrixDimensions  - Size of the original matrix (the sampled one).
     * @param [in] matrixData        - C array of matrix data.
     * @throw ios::failure           - If error happens.
     */
    void writeCuboidToHyperSlab(const hid_t           dataset,
                                const DimensionSizes& hyperslabPosition,
                                const DimensionSizes& cuboidPosition,
                                const DimensionSizes& cuboidSize,
                                const DimensionSizes& matrixDimensions,
                                const float*          matrixData);
    /**
     * @brief   Write sensor data selected by the sensor mask.
     * @details The routine picks elements from the MatixData based on the sensor mask and stores them into a single
     *          hyperslab of size [Nsens, 1, 1].
     *
     * @param [in] dataset           - Dataset to write MatrixData into.
     * @param [in] hyperslabPosition - 3D position in the dataset (hyperslab).
     * @param [in] indexSensorSize   - Size of the index based sensor mask.
     * @param [in] indexSensorData   - Index based sensor mask.
     * @param [in] matrixDimensions  - Size of the sampled matrix.
     * @param [in] matrixData        - Matrix data.
     * @warning Very slow at this version of HDF5 for orthogonal planes-> DO NOT USE.
     * @throw ios::failure           - If error happens.
     */
    void writeSensorByMaskToHyperSlab(const hid_t           dataset,
                                      const DimensionSizes& hyperslabPosition,
                                      const size_t          indexSensorSize,
                                      const size_t*         indexSensorData,
                                      const DimensionSizes& matrixDimensions,
                                      const float*          matrixData);
    /**
     * @brief   Write a scalar value at a specified place in the file tree.
     * @details No chunks and no compression is used.
     *
     * @tparam     T           - Data type to be written.
     * @param [in] parentGroup - Where to link the scalar dataset.
     * @param [in] datasetName - HDF5 dataset name.
     * @param [in] value       - data to be written.
     * @throw ios::failure     - If error happens.
     * @warning Limited to float and size_t data types.
     */
    template<class T>
    void writeScalarValue(const hid_t       parentGroup,
                          const MatrixName& datasetName,
                          const T           value);

    /**
     * @brief Read a scalar value at a specified place in the file tree.
     *
     * @tparam      T           - Data type to be written.
     * @param [in]  parentGroup - Where to link the scalar dataset.
     * @param [in]  datasetName - HDF5 dataset name.
     * @param [out] value       - Data to be read.
     * @throw ios::failure      - If error happens.
     * @warning Limited to float and size_t data types.
     */
    template<class T>
    void readScalarValue(const hid_t       parentGroup,
                         const MatrixName& datasetName,
                         T&                value);
    /**
     * @brief Read data from the dataset at a specified place in the file tree.
     *
     * @tparam      T              - Data type to be written.
     * @param [in]  parentGroup    - Where is the dataset situated.
     * @param [in]  datasetName    - Dataset name.
     * @param [in]  dimensionSizes - Dimension sizes.
     * @param [out] data           - Pointer to data.
     * @throw ios::failure         - If error happens.
     */
    template<class T>
    void readCompleteDataset(const hid_t           parentGroup,
                             const MatrixName&     datasetName,
                             const DimensionSizes& dimensionSizes,
                             T*                    data);

    //---------------------------------------- Dataset sizes and dimensions ------------------------------------------//
    /**
     * @brief Get dimension sizes of the dataset at a specified place in the file tree.
     *
     * @param [in] parentGroup - Where the dataset is.
     * @param [in] datasetName - Dataset name.
     * @return Dimension sizes of the dataset.
     * @throw ios::failure     - If error happens.
     */
    DimensionSizes getDatasetDimensionSizes(const hid_t       parentGroup,
                                            const MatrixName& datasetName);
    /**
     * @brief Get number of dimensions of the dataset at a specified place in the file tree.
     *
     * @param [in] parentGroup - Where the dataset is.
     * @param [in] datasetName - Dataset name.
     * @return Number of dimensions.
     * @throw ios::failure     - If error happens.
     */
    size_t getDatasetNumberOfDimensions(const hid_t       parentGroup,
                                        const MatrixName& datasetName);
    /**
     * @brief Get dataset element count at a specified place in the file tree.
     *
     * @param [in] parentGroup - Where the dataset is.
     * @param [in] datasetName - Dataset name.
     * @return Number of elements.
     * @throw ios::failure     - If error happens.
     */
    size_t getDatasetSize(const hid_t       parentGroup,
                          const MatrixName& datasetName);

    //--------------------------------------- Attributes Read/Write operations ---------------------------------------//
    /**
     * @brief Write matrix data type into the dataset at a specified place in the file tree.
     *
     * @param [in] parentGroup    - Where the dataset is.
     * @param [in] datasetName    - Dataset name.
     * @param [in] matrixDataType - Matrix data type in the file.
     * @throw ios::failure        - If error happens.
     */
    void writeMatrixDataType (const hid_t           parentGroup,
                              const MatrixName&     datasetName,
                              const MatrixDataType& matrixDataType);
    /**
     * @brief  Write matrix domain type into the dataset at a specified place in the file tree.
     *
     * @param [in] parentGroup      - Where the dataset is.
     * @param [in] datasetName      - Dataset name.
     * @param [in] matrixDomainType - Matrix domain type.
     * @throw ios::failure          - If error happens.
     */
    void writeMatrixDomainType(const hid_t             parentGroup,
                               const MatrixName&       datasetName,
                               const MatrixDomainType& matrixDomainType);

    /**
     * @brief Read matrix data type from the dataset at a specified place in the file tree.
     *
     * @param [in] parentGroup - Where the dataset is.
     * @param [in] datasetName - Dataset name.
     * @return Matrix data type.
     * @throw ios::failure     - If error happens.
     */
    MatrixDataType   readMatrixDataType(const hid_t       parentGroup,
                                        const MatrixName& datasetName);
    /**
     * @brief Read matrix dataset domain type at a specified place in the file tree.
     *
     * @param [in] parentGroup - Where the dataset is.
     * @param [in] datasetName - Dataset name.
     * @return Matrix domain type.
     * @throw ios::failure      - If error happens.
     */
    MatrixDomainType readMatrixDomainType(const hid_t       parentGroup,
                                          const MatrixName& datasetName);

    /**
     * @brief Write string attribute into the dataset at a specified place in the file tree.
     *
     * @param [in] parentGroup   - Where the dataset is.
     * @param [in] datasetName   - Dataset name.
     * @param [in] attributeName - Attribute name.
     * @param [in] value         - Data to write.
     * @throw ios::failure       - If error happens.
     */
    void writeStringAttribute(const hid_t        parentGroup,
                              const MatrixName&  datasetName,
                              const MatrixName&  attributeName,
                              const std::string& value);
    /**
     * @brief Read string attribute from the dataset at a specified place in the file tree.
     *
     * @param [in] parentGroup   - Where the dataset is.
     * @param [in] datasetName   - Dataset name.
     * @param [in] attributeName - Attribute name.
     * @return Attribute value.
     * @throw ios::failure       - If error happens.
     */
    std::string readStringAttribute(const hid_t       parentGroup,
                                    const MatrixName& datasetName,
                                    const MatrixName& attributeName);

  protected:

  private:
    /// String representation of the Domain type in the HDF5 file.
    static const std::string kMatrixDomainTypeName;
    /// String representation of the Data type in the HDF5 file.
    static const std::string kMatrixDataTypeName;

    /// Map for data type names.
    static std::map<MatrixDataType, std::string>   sMatrixDataTypeNames;
    /// Map for domain type names.
    static std::map<MatrixDomainType, std::string> sMatrixDomainTypeNames;

    /// HDF file handle.
    hid_t  mFile;
    /// File name.
    std::string mFileName;
};// Hdf5File
//----------------------------------------------------------------------------------------------------------------------

#endif	/* HDF5_FILE_H */
