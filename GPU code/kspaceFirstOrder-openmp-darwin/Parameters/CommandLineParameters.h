/**
 * @file      CommandLineParameters.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file containing command line parameters.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      29 August    2012, 11:25 (created) \n
 *            18 February  2020, 15:31 (revised)
 *
 * @section   Params Command Line Parameters
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
 * checks the `OMP_NUM_THREADS` variable. If it is not defined, the code uses the number of logical processor cores.
 * If the system support hyper-threading, it is recommended to use only half the number threads to prevent cache
 * overloading. If possible, enable thread binding and placement using export `OMP_PROC_BIND` and `OMP_PLACES`
 * variables.
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

#ifndef COMMAND_LINE_PARAMETERS_H
#define COMMAND_LINE_PARAMETERS_H

#include <string>

/**
 * @class   CommandLineParameters
 * @brief   The class to parse and store command line parameters.
 * @details The class to parse and store command line parameters.
 */
class CommandLineParameters
{
  public:
    /// Only Parameters can create this class.
    friend class Parameters;

    /// Copy constructor not allowed.
    CommandLineParameters(const CommandLineParameters&) = delete;

    /// Destructor.
    ~CommandLineParameters() = default;

    /// Operator = not allowed.
    CommandLineParameters& operator=(const CommandLineParameters&) = delete;

    /**
     * @brief  Get input file name.
     * @return Input file name.
     */
    const std::string& getInputFileName()      const { return mInputFileName; };
    /**
     * @brief  Get output file name.
     * @return Output file name.
     */
    const std::string& getOutputFileName()     const { return mOutputFileName; };
    /**
     * @brief  Get Checkpoint file name.
     * @return Checkpoint file name.
     */
    const std::string& getCheckpointFileName() const { return mCheckpointFileName; };

    /**
     * @brief  Get number of threads.
     * @return Number of CPU threads value.
     */
    size_t getNumberOfThreads()         const { return mNumberOfThreads; };

    /**
     * @brief  Get progress print interval.
     * @return How often to print progress.
     */
    size_t getProgressPrintInterval()   const { return mProgressPrintInterval; };

    /**
     * @brief  Get compression level.
     * @return Compression level value for output and checkpoint files.
     */
    size_t getCompressionLevel()        const { return mCompressionLevel; };

    /**
     * @brief  Is --benchmark set?
     * @return true if the flag is set.
     */
    bool   isBenchmarkEnabled()         const { return mBenchmarkFlag; };
    /**
     * @brief  Get benchmark time step count.
     * @return Number of time steps used to benchmark the code.
     */
    size_t getBenchmarkTimeStepsCount() const { return mBenchmarkTimeStepCount; };

    /**
     * @brief  Is checkpoint enabled?
     * @return true if checkpointing is enabled.
     */
    bool   isCheckpointEnabled()        const { return ((mCheckpointInterval > 0) || (mCheckpointTimeSteps > 0)); };
    /**
     * @brief  Get checkpoint interval.
     * @return Checkpoint interval in seconds.
     */
    size_t getCheckpointInterval()      const { return mCheckpointInterval; };
    /**
     * @brief  Get checkpoint interval in time steps.
     * @return Checkpoint interval in time steps.
     */
    size_t getCheckpointTimeSteps()     const { return mCheckpointTimeSteps; };

    /**
     * @brief  Is --version set?
     * @return true if the flag is set.
     */
    bool   isPrintVersionOnly()         const { return mPrintVersionFlag; };

    //------------------------------------------------ Output flags --------------------------------------------------//
    /**
     * @brief  Is --p_raw set?
     * @return true if the flag is set.
     */
    bool   getStorePressureRawFlag()      const { return mStorePressureRawFlag; };
    /**
     * @brief  Is --p_rms set?
     * @return true if the flag is set.
     */
    bool   getStorePressureRmsFlag()      const { return mStorePressureRmsFlag; };
    /**
     * @brief  Is --p_max set?
     * @return true if the flag is set.
     */
    bool   getStorePressureMaxFlag()      const { return mStorePressureMaxFlag; };
    /**
     * @brief  Is --p_min set?
     * @return true if the flag is set.
     */
    bool   getStorePressureMinFlag()      const { return mStorePressureMinFlag; };
    /**
     * @brief  Is --p_max_all set?
     * @return true if the flag is set.
     */
    bool   getStorePressureMaxAllFlag()   const { return mStorePressureMaxAllFlag; };
    /**
     * @brief  Is --p_min_all set?
     * @return true if the flag is set.
     */
    bool   getStorePressureMinAllFlag()   const { return mStorePressureMinAllFlag; };
    /**
     * @brief  Is --p_final set?
     * @return true if the flag is set.
     */
    bool   getStorePressureFinalAllFlag() const { return mStorePressureFinalAllFlag; };


    /**
     * @brief  Is --u_raw set?
     * @return true if the flag is set.
     */
    bool   getStoreVelocityRawFlag()             const { return mStoreVelocityRawFlag; };
    /**
     * @brief  Is --u_non_staggered_raw set?
     * @return true if the flag is set.
     */
    bool   getStoreVelocityNonStaggeredRawFlag() const { return mStoreVelocityNonStaggeredRawFlag; };
    /**
     * @brief  Is --u_rms set?
     * @return true if the flag is set.
     */
    bool   getStoreVelocityRmsFlag()             const { return mStoreVelocityRmsFlag; };
    /**
     * @brief  Is --u_max set?
     * @return true if the flag is set.
     */
    bool   getStoreVelocityMaxFlag()             const { return mStoreVelocityMaxFlag; };
    /**
     * @brief  Is --u_min set?
     * @return true if the flag is set.
     */
    bool   getStoreVelocityMinFlag()             const { return mStoreVelocityMinFlag; };
    /**
     * @brief  Is --u_max_all set?
     * @return true if the flag is set.
     */
    bool   getStoreVelocityMaxAllFlag()          const { return mStoreVelocityMaxAllFlag; };
    /**
     * @brief  Is --u_min set?
     * @return true if the flag is set.
     */
    bool   getStoreVelocityMinAllFlag()          const { return mStoreVelocityMinAllFlag; };
    /**
     * @brief  Is --u_final set?
     * @return true if the flag is set.
     */
    bool   getStoreVelocityFinalAllFlag()        const { return mStoreVelocityFinalAllFlag; };
    /**
     * @brief  Is --copy_mask set set?
     * @return true if the flag is set.
     */
    bool   getCopySensorMaskFlag()               const { return mCopySensorMaskFlag; };

    /**
     * @brief  Get the time step/index when the sensor data collection begins.
     * @return When to start sampling data.
     */
    size_t getSamplingStartTimeIndex()           const { return mSamplingStartTimeStep; };


    /// Print usage of the code.
    void printUsage();
    /// Print setup command line parameters.
    void printComandlineParamers();

    /**
     * @brief Parse command line parameters.
     * @param [in, out] argc - number of command line parameters.
     * @param [in, out] argv - command line parameters.
     *
     * @throw call exit when error in command line.
     */
    void parseCommandLine(int argc, char** argv);

  protected:

  private:
    /// Default constructor - only friend class can create an instance.
    CommandLineParameters();

    /**
     * @brief  Get default number of threads.
     * @return The number of threads set by the OMP_NUM_THREADS environmental variable if set, or the number of
     *         logical processor cores.
     */
    static size_t getDefaultNumberOfThreads();

    /// Default compression level.
    static constexpr size_t kDefaultCompressionLevel      = 0;
    /// Default progress print interval.
    static constexpr size_t kDefaultProgressPrintInterval = 5;

    /// Input file name.
    std::string mInputFileName;
    /// Output file name.
    std::string mOutputFileName;
    /// Checkpoint file name.
    std::string mCheckpointFileName;

    /// Number of CPU threads value.
    size_t mNumberOfThreads;
    /// Progress interval value.
    size_t mProgressPrintInterval;
    /// Compression level value for output and checkpoint files.
    size_t mCompressionLevel;

    /// BenchmarkFlag value.
    bool   mBenchmarkFlag;
    /// Number of time steps used to benchmark the code.
    size_t mBenchmarkTimeStepCount;
    /// Checkpoint interval in seconds.
    size_t mCheckpointInterval;
    /// Checkpoint interval in time steps.
    size_t mCheckpointTimeSteps;

    /// Print version of the code and exit.
    bool mPrintVersionFlag;

    /// Store raw time-series of pressure over the sensor mask?
    bool mStorePressureRawFlag;
    /// Store RMS of pressure over the the sensor mask?
    bool mStorePressureRmsFlag;
    /// Store maximum of pressure over the sensor mask?
    bool mStorePressureMaxFlag;
    /// Store minimum of pressure over the sensor mask?
    bool mStorePressureMinFlag;
    /// Store maximum of pressure over the whole domain?
    bool mStorePressureMaxAllFlag;
    /// Store minimum of pressure over the whole domain?
    bool mStorePressureMinAllFlag;
    /// Store pressure in the final time step over the whole domain?
    bool mStorePressureFinalAllFlag;

    /// Store raw time-series of velocity over the sensor mask?
    bool mStoreVelocityRawFlag;
    /// Store un staggered raw time-series of velocity over the sensor mask?
    bool mStoreVelocityNonStaggeredRawFlag;
    /// Store RMS of velocity over the the sensor mask?
    bool mStoreVelocityRmsFlag;
    /// Store maximum of velocity over the sensor mask?
    bool mStoreVelocityMaxFlag;
    /// Store minimum of velocity over the sensor mask?
    bool mStoreVelocityMinFlag;
    /// Store maximum of velocity over the whole domain?
    bool mStoreVelocityMaxAllFlag;
    /// Store minimum of velocity over the whole domain?
    bool mStoreVelocityMinAllFlag;
    /// Store velocity in the final time step over the whole domain?
    bool mStoreVelocityFinalAllFlag;

    /// Copy sensor mask to the output file.
    bool   mCopySensorMaskFlag;
    /// StartTimeStep value.
    size_t mSamplingStartTimeStep;
};// end of class CommandLineParameters
//----------------------------------------------------------------------------------------------------------------------

#endif /* COMMAND_LINE_PARAMETERS_H */
