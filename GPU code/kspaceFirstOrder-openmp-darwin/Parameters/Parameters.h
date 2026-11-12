/**
 * @file      Parameters.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file containing the parameters of the simulation.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      08 December  2011, 16:34 (created) \n
 *            11 February  2020, 14:49 (revised)
 *
 * @copyright Copyright (C) 2011 - 2020 SC\@FIT Research Group, Brno University of Technology, Brno, CZ.
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

#ifndef PARAMETERS_H
#define PARAMETERS_H

#include <string>

#include <Parameters/CommandLineParameters.h>
#include <Utils/DimensionSizes.h>
#include <Utils/TimeMeasure.h>
#include <Hdf5/Hdf5File.h>
#include <Hdf5/Hdf5FileHeader.h>

/**
 * @class   Parameters
 * @brief   Class storing all parameters of the simulation.
 * @details Class storing all parameters of the simulation including the command line parameters, simulation flags read
 *          from the input flag and several scalar constants for homogeneous medium such as sound speed or acoustic
 *          density.
 *
 * @warning This is a singleton class.
 */
class Parameters
{
  public:
    /**
     * @enum    SensorMaskType
     * @brief   Sensor mask type (linear or cuboid corners).
     * @details The values correspond to those defined in the HDF5 files.
     */
    enum class SensorMaskType
    {
      /// Linear sensor mask.
      kIndex   = 0,
      /// Cuboid corners sensor mask.
      kCorners = 1
    };

    /**
     * @enum    SourceMode
     * @brief   Source mode (Dirichlet, additive, additive-no-correction).
     * @details The values correspond to those defined in the HDF5 file.
     */
    enum class SourceMode
    {
      /// Dirichlet source condition.
      kDirichlet            = 0,
      /// Additive-no-correction source condition.
      kAdditiveNoCorrection = 1,
      /// Additive source condition.
      kAdditive             = 2
    };

    /**
     * @enum    SimulationDimension
     * @brief   What is the simulation dimensionality.
     * @details What is the simulation dimensionality.
     */
    enum class SimulationDimension
    {
      /// 2D simulation.
      k2D,
      /// 3D simulation.
      k3D
    };

    /**
     * @enum    AbsorptionType
     * @brief   Medium absorption type.
     * @details For normal medium, all three types are allowed, however, for the AS medium
     *          the power law is not admissible. The values correspond to those defined in the HDF5 file.
     */
    enum class AbsorptionType
    {
      /// No absorption.
      kLossless = 0,
      /// Power law absorption.
      kPowerLaw = 1,
      /// Stokes absorption.
      kStokes   = 2
    };

    /**
     * @enum    ParameterNameIdx
     * @brief   Parameter identifers of scalar flags and values in the HDF5 files.
     * @details These flags are used as keys for the map holding parameter names in the file.
     */
    enum class ParameterNameIdx
    {
      /// Actual time index.
      kTimeIndex,
      /// Number of grid points in the x dimension.
      kNx,
      /// Number of grid points in the y dimension.
      kNy,
      /// Number of grid points in the z dimension.
      kNz,
      /// Number of time steps.
      kNt,

      /// Time step size.
      kDt,
      /// Spatial displacement in x.
      kDx,
      /// Spatial displacement in y.
      kDy,
      /// Spatial displacement in z.
      kDz,

      /// Reference sound speed.
      kCRef,
      /// Homogeneous sound speed.
      kC0,

      /// Homogeneous medium density.
      kRho0,
      /// Homogeneous medium density on staggered grid in x direction.
      kRho0Sgx,
      /// Homogeneous medium density on staggered grid in y direction.
      kRho0Sgy,
      /// Homogeneous medium density on staggered grid in z direction.
      kRho0Sgz,

      /// Nonlinear coefficient for homogenous medium.
      kBOnA,
      /// Alpha absorption coefficient.
      kAlphaCoeff,
      /// Alpha power value for the absorption law.
      kAlphaPower,

      /// Depth of the perfectly matched layer in x.
      kPmlXSize,
      /// Depth of the perfectly matched layer in y.
      kPmlYSize,
      /// Depth of the perfectly matched layer in z.
      kPmlZSize,

      /// Perfectly matched layer attenuation in x.
      kPmlXAlpha,
      /// Perfectly matched layer attenuation in y.
      kPmlYAlpha,
      /// Perfectly matched layer attenuation in z.
      kPmlZAlpha,

      /// Axisymmetric flag.
      kAxisymmetricFlag,
      /// Nonuniform grid flag.
      kNonUniformGridFlag,
      /// Absorbing flag.
      kAbsorbingFlag,
      /// Nonlinear flag.
      kNonLinearFlag,

      /// Pressure source flag.
      kPressureSourceFlag,
      /// Initial pressure source flag (p0).
      kInitialPressureSourceFlag,
      /// Transducer source flag.
      kTransducerSourceFlag,

      /// Velocity in x source flag.
      kVelocityXSourceFlag,
      /// Velocity in y source flag.
      kVelocityYSourceFlag,
      /// Velocity in z source flag.
      kVelocityZSourceFlag,

      /// Pressure source mode.
      kPressureSourceMode,
      /// Pressure source many flag.
      kPressureSourceMany,
      /// Velocity source mode.
      kVelocitySourceMode,
      /// Velocity source many flag.
      kVelocitySourceMany,

      /// Transducer source input matrix.
      kTransducerSourceInput,
      /// Pressure source index matrix.
      kPressureSourceIndex,
      /// Velocity source index matrix.
      kVelocitySourceIndex,

      /// Sensor mask type
      kSensorMaskType,
      /// Index sensor mask
      kSensorMaskIndex,
      /// Cuboid corners sensor mask
      kSensorMaskCorners,
    };// end of ParameterNameIdx

    /// Copy constructor not allowed.
    Parameters(const Parameters&) = delete;
    /// Destructor.
    ~Parameters();
    /// Operator = not allowed.
    Parameters& operator=(const Parameters&) = delete;

    /**
     * @brief  Get instance of the singleton class.
     * @return The only instance of the class.
     */
    static Parameters& getInstance();

    /**
     * @brief   Parse command line and read scalar values from the input file.
     * @details The routine also opens the input file and leave it open for further use.

     * @param   [in] argc - Number of command line parameters.
     * @param   [in] argv - Command line parameters.
     *
     * @throw   std::invalid_argument - If sampling is supposed to start out of the simulation time span.
     * @throw   ios:failure - If the output file is closed.
     * @throw   exit when the parameters are not set correctly.s
     */
    void init(int argc, char** argv);

    /// Print the simulation setup (all parameters).
    void printSimulatoinSetup();

    /**
     * @brief  Shall the code print version and exit?
     * @return true if the flag is set.
     */
    bool isPrintVersionOnly() const { return mCommandLineParameters.isPrintVersionOnly(); };

    /**
     * @brief   Read scalar values from the input HDF5 file.
     *
     * @throw   ios:failure           - If the file cannot be open or is of a wrong type or version.
     * @throw   std::invalid_argument - If some values are not correct or not supported.
     * @warning The file is opened in this routine and left open for further use.
     */
    void readScalarsFromInputFile();
    /**
     * @brief   Write scalar values into the output HDF5 file.
     * @throw   ios:failure - If the output file is closed.
     * @warning The file is expected to be open.
     */
    void writeScalarsToOutputFile();

    /**
     * @brief  Get git hash of the code.
     * @return Git hash compiled in using -D parameter.
     */
    std::string getGitHash()           const;

    /**
     * @brief  Get number of CPU threads to use.
     * @return Number of CPU threads to use.
     */
    size_t getNumberOfThreads()        const { return mCommandLineParameters.getNumberOfThreads(); };

    /**
     * @brief  Get the name of the processor used.
     * @return Name of the processor.
     */
    std::string getProcessorName()     const;

    /**
     * @brief  Get compression level.
     * @return Compression level value for output and checkpoint files.
     */
    size_t getCompressionLevel()       const { return mCommandLineParameters.getCompressionLevel(); };

    /**
     * @brief  Get progress print interval.
     * @return How often to print progress.
     */
    size_t getProgressPrintInterval()  const { return mCommandLineParameters.getProgressPrintInterval(); };


    /**
     * @brief  Is checkpoint enabled?
     * @return true if checkpointing is enabled.
     */
    bool   isCheckpointEnabled()       const { return mCommandLineParameters.isCheckpointEnabled(); };

    /**
     * @brief  Is time to checkpoint?
     * @param  [in] timer - A copy of timer measuring elapsed time from the beginning
     * @return true - if the elapsed time in this leg has exceeded the specified interval, or the simulation has
     *         executed a predefined number of time steps.
     */
     bool  isTimeToCheckpoint(TimeMeasure timer) const;

    //---------------------------------------------------- Files -----------------------------------------------------//
    /**
     * @brief  Get input file handle.
     * @return Handle to the input file.
     */
    Hdf5File& getInputFile()                 { return mInputFile; };
    /**
     * @brief  Get output file handle.
     * @return Handle to the output file.
     */
    Hdf5File& getOutputFile()                { return mOutputFile; };
    /**
     * @brief  Get checkpoint file handle.
     * @return Handle to the checkpoint file.
     */
    Hdf5File& getCheckpointFile()            { return mCheckpointFile; };
    /**
     * @brief  Get file header handle.
     * @return Handle to the file header.
     */
    Hdf5FileHeader& getFileHeader()          { return mFileHeader; };

    /**
     * @brief  Get input file name.
     * @return Input file name.
     */
    const std::string& getInputFileName()      const { return mCommandLineParameters.getInputFileName(); };
    /**
     * @brief  Get output file name.
     * @return Output file name.
     */
    const std::string& getOutputFileName()     const { return mCommandLineParameters.getOutputFileName(); };
    /**
     * @brief  Get checkpoint file name.
     * @return Checkpoint file name.
     */
    const std::string& getCheckpointFileName() const { return mCommandLineParameters.getCheckpointFileName(); };

    //-------------------------------------------- Simulation dimensions ---------------------------------------------//
    /**
     * @brief  Get full dimension sizes of the simulation (real classes).
     * @return Dimension sizes of 3D real matrices.
     */
    DimensionSizes getFullDimensionSizes()     const { return mFullDimensionSizes;  };
    /**
     * @brief  Get reduced dimension sizes of the simulation (complex classes).
     * @return Dimension sizes of reduced complex 3D matrices.
     */
    DimensionSizes getReducedDimensionSizes()  const { return mReducedDimensionSizes; };

    /**
     * @brief  Get the HDF5 dataset name of Nx.
     * @return Hdf5 dataset name.
     */
    const std::string& getNxHdf5Name()         const { return sParameterHdf5Names[ParameterNameIdx::kNx]; };
    /**
     * @brief  Get the HDF5 dataset name of Ny.
     * @return Hdf5 dataset name.
     */
    const std::string& getNyHdf5Name()         const { return sParameterHdf5Names[ParameterNameIdx::kNy]; };
    /**
     * @brief  Get the HDF5 dataset name of Nz.
     * @return Hdf5 dataset name.
     */
    const std::string& getNzHdf5Name()         const { return sParameterHdf5Names[ParameterNameIdx::kNz]; };

    /**
     * @brief  Is simulation 2D and axisymmetric?
     * @return true if the simulation is axisymmetric.
     */
    bool isSimulationAS()                      const { return mAxisymmetricFlag; };
    /**
     * @brief  Is the simulation executed in two dimensions, not axisymmetric?
     * @return true if the simulation space is 2D.
     */
    bool isSimulation2D()                      const { return mFullDimensionSizes.is2D(); };
    /**
     * @brief  Is the simulation executed in three dimensions.
     * @return true if the simulation space is 3D.
     */
    bool isSimulation3D()                      const { return !isSimulation2D(); }
    /**
     * @brief  Return the number of dimensions for the current simulations.
     * @return Number of dimensions.
     */
    SimulationDimension getSimulationDimension() const
    {
      return (isSimulation3D()) ? SimulationDimension::k3D : SimulationDimension::k2D;
    };

    /**
     * @brief  Get total number of time steps.
     * @return Total number of time steps.
     */
    size_t  getNt()                            const { return mNt; };
    /**
     * @brief  Get actual simulation time step.
     * @return Actual time step.
     */
    size_t  getTimeIndex()                     const { return mTimeIndex; };
    /**
     * @brief  Get the HDF5 dataset name of TimeIndex.
     * @return Hdf5 dataset name.
     */
    const std::string& getTimeIndexHdf5Name()  const { return sParameterHdf5Names[ParameterNameIdx::kTimeIndex]; };

    /**
     * @brief Set simulation time step - should be used only when recovering from checkpoint.
     * @param [in] timeIndex - Actual time step.
     */
    void setTimeIndex(const size_t timeIndex)        { mTimeIndex = timeIndex; };
    /// Increment simulation time step and decrement steps to checkpoint.
    void incrementTimeIndex();

    //-----------------------------------------------FFTW Wisdom -----------------------------------------------------//
    /**
     * @brief   Export FFTW wisdom to the file.
     * @details This routine exports wisdom of all FFTW plans, if compiled with FFTW.
     */
    void exportWisdom();
    /**
     * @brief   Import FFTW wisdom from the file.
     * @details This routine imports wisdom of all FFTW plans, if compiled with FFTW.
     */
    void importWisdom();
    /// Delete the wisdom file.
    void deleteStoredWisdom();

    //----------------------------------------------- Grid parameters ------------------------------------------------//
    /**
     * @brief  Get time step size.
     * @return dt value.
     */
    float getDt() const { return mDt; };
    /**
     * @brief  Get spatial displacement in x.
     * @return dx value.
     */
    float getDx() const { return mDx; };
    /**
     * @brief  Get spatial displacement in y.
     * @return dy value.
     */
    float getDy() const { return mDy; };
    /**
     * @brief  Get spatial displacement in z.
     * @return dz value
     */
    float getDz() const { return mDz; };

    //------------------------------------------- Sound speed and density --------------------------------------------//
    /**
     * @brief  Get reference sound speed.
     * @return Reference sound speed.
     */
    float  getCRef()            const { return mCRef; };
    /**
     * @brief  Is sound speed in the medium homogeneous (scalar value)?
     * @return true if scalar.
     */
    bool   getC0ScalarFlag()    const { return mC0ScalarFlag; };
    /**
     * @brief  Get scalar value of sound speed.
     * @return Sound speed.
     */
    float  getC0Scalar()        const { return mC0Scalar; };
    /**
     * @brief  Get scalar value of sound speed squared.
     * @return Sound speed.
     */
    float  getC2Scalar()        const { return mC0Scalar * mC0Scalar; };

    /**
     * @brief  Is density in the medium homogeneous (scalar value)?
     * @return true if scalar.
     */
    bool   getRho0ScalarFlag()  const { return mRho0ScalarFlag; };
    /**
     * @brief  Get value of homogeneous medium density.
     * @return Density.
     */
    float  getRho0Scalar()      const { return mRho0Scalar; };
    /**
     * @brief  Get value of homogeneous medium density on staggered grid in x direction.
     * @return Staggered density.
     */
    float  getRho0SgxScalar()   const { return mRho0SgxScalar; };
    /**
     * @brief  Get value of dt / rho0Sgx.
     * @return Staggered density.
     */
    float  getDtRho0SgxScalar() const { return mDt / mRho0SgxScalar; };
    /**
     * @brief  Get value of homogeneous medium density on staggered grid in y direction.
     * @return Staggered density.
     */
    float  getRho0SgyScalar()   const { return mRho0SgyScalar; };
    /**
     * @brief  Get value of dt / rho0Sgy.
     * @return Staggered density.
     */
    float  getDtRho0SgyScalar() const { return mDt / mRho0SgyScalar; };
    /**
     * @brief  Get value of homogeneous medium density on staggered grid in z direction.
     * @return Staggered density.
     */
    float  getRho0SgzScalar()   const { return mRho0SgzScalar; };
    /**
     * @brief  Get value of dt / rho0Sgz.
     * @return Staggered density.
     */
    float  getDtRho0SgzScalar() const { return mDt / mRho0SgzScalar; };

    //----------------------------------------- Absorption and nonlinearity ------------------------------------------//
    /**
     * @brief  Enable non uniform grid? - not implemented yet.
     * @return Non uniform flag.
     */
    size_t         getNonUniformGridFlag() const { return mNonUniformGridFlag; };
    /**
     * @brief  What kind of absorption is used?
     * @return Type of absorption (kLossless, kPowerLaw, kStokes).
     */
    AbsorptionType getAbsorbingFlag()      const { return mAbsorbingFlag; };
    /**
     * @brief  Is the wave propagation nonlinear?
     * @return 0 if the simulation is linear, 1 otherwise.
     */
    size_t         getNonLinearFlag()      const { return mNonLinearFlag; };

    /**
     * @brief  Is alpha absorption coefficient homogeneous (scalar value)?
     * @return true if scalar.
     */
    bool   getAlphaCoeffScalarFlag() const { return mAlphaCoeffScalarFlag; };
    /**
     * @brief  Get value of alpha absorption coefficient.
     * @return Alpha absorption coefficient.
     */
    float  getAlphaCoeffScalar()     const { return mAlphaCoeffScalar; };
    /**
     * @brief  Get alpha power value for the absorption law.
     * @return Alpha power value.
     */
    float  getAlphaPower()           const { return mAlphaPower; };
    /**
     * @brief  Get absorb eta coefficient for homogeneous medium (scalar value)?
     * @return Absorb eta coefficient.
     */
    float  getAbsorbEtaScalar()      const { return mAbsorbEtaScalar; };
    /**
     * @brief Set absorb eta coefficient for homogeneous medium (scalar value).
     * @param [in] absrobEta - New value for absorb eta.
     */
    void   setAbsorbEtaScalar(const float absrobEta) { mAbsorbEtaScalar = absrobEta; };
    /**
     * @brief  Get absorb tau coefficient for homogeneous medium.
     * @return Absorb tau coefficient.
     */
    float  getAbsorbTauScalar()      const { return mAbsorbTauScalar; };
    /**
     * @brief Set absorb tau coefficient for homogeneous medium (scalar value).
     * @param [in] absorbTau - New value for absorb tau.
     */
    void   setAbsorbTauScalar(const float absorbTau) { mAbsorbTauScalar = absorbTau; };

    /**
     * @brief  Is nonlinear coefficient homogeneous in the medium (scalar value)?
     * @return true if scalar.
     */
    bool   getBOnAScalarFlag()       const { return mBOnAScalarFlag; };
    /**
     * @brief  Get nonlinear coefficient for homogenous medium.
     * @return Nonlinear coefficient.
     */
    float  getBOnAScalar()           const { return mBOnAScalar; };

    //------------------------------------------ Perfectly matched layer ---------------------------------------------//
    /**
     * @brief  Get depth of the perfectly matched layer in x.
     * @return PML size in x.
     */
    size_t getPmlXSize()  const { return mPmlXSize; };
    /**
     * @brief  Get depth of the perfectly matched layer in y.
     * @return PML size in y.
     */
    size_t getPmlYSize()  const { return mPmlYSize; };
    /**
     * @brief  Get depth of the perfectly matched layer in z.
     * @return PML size in z.
     */
    size_t getPmlZSize()  const { return mPmlZSize; };

    /**
     * @brief  Get Perfectly matched layer attenuation in x, not implemented.
     * @return Attenuation for PML in x.
     */
    float  getPmlXAlpha() const { return mPmlXAlpha; };
    /**
     * @brief  Get Perfectly matched layer attenuation in y, not implemented.
     * @return Attenuation for PML in y.
     */
    float  getPmlYAlpha() const { return mPmlYAlpha; };
    /**
     * @brief  Get Perfectly matched layer attenuation in z , not implemented.
     * @return Attenuation for PML in z.
     */
    float  getPmlZAlpha() const { return mPmlZAlpha; };

    //-------------------------------------------------- Sources -----------------------------------------------------//
    /**
     * @brief  Get pressure source flag.
     * @return 0 if the source is disabled.
     * @return Length of the input signal in time steps.
     */
    size_t getPressureSourceFlag()        const { return mPressureSourceFlag; };
    /**
     * @brief  Get initial pressure source flag (p0).
     * @return 0 if the source is disabled, 1 otherwise.
     */
    size_t getInitialPressureSourceFlag() const { return mInitialPressureSourceFlag; };
    /**
     * @brief  Get transducer source flag.
     * @return 0 if the transducer is disabled.
     * @return Length of the input signal in time steps.
     */
    size_t getTransducerSourceFlag()      const { return mTransducerSourceFlag; };
    /**
     * @brief  Get velocity in x source flag.
     * @return 0 if the source is disabled.
     * @return Length of the input signal in time steps.
     */
    size_t getVelocityXSourceFlag()       const { return mVelocityXSourceFlag; };
    /**
     * @brief  Get velocity in y source flag.
     * @return 0 if the source is disabled.
     * @return Length of the input signal in time steps.
     */
    size_t getVelocityYSourceFlag()       const { return mVelocityYSourceFlag; };
    /**
     * @brief  Get velocity in z source flag.
     * @return 0 if the source is disabled.
     * @return Length of the input signal in time steps.
     */
    size_t getVelocityZSourceFlag()       const { return mVelocityZSourceFlag; };

    /**
     * @brief  Get spatial size of the pressure source.
     * @return Size of the pressure source in grid points.
     */
    size_t getPressureSourceIndexSize()   const { return mPressureSourceIndexSize; }
    /**
     * @brief  Get spatial size of the transducer source.
     * @return Size of the transducer source in grid points.
     */
    size_t getTransducerSourceInputSize() const { return mTransducerSourceInputSize; }
    /**
     * @brief  Get spatial size of the velocity source.
     * @return Size of the velocity source in grid points.
     */
    size_t getVelocitySourceIndexSize()   const { return mVelocitySourceIndexSize; }

    /**
     * @brief  Get pressure source mode.
     * @return Pressure source mode.
     */
    SourceMode getPressureSourceMode()    const { return mPressureSourceMode; };
    /**
     * @brief  Get number of time series in the pressure source.
     * @return Number of time series in the pressure source.
     */
    size_t getPressureSourceMany()        const { return mPressureSourceMany; };

    /**
     * @brief  Get velocity source mode.
     * @return Pressure source mode.
     */
    SourceMode getVelocitySourceMode()    const { return mVelocitySourceMode; };
    /**
     * @brief  Get number of time series in the velocity sources.
     * @return Number of time series in the velocity sources.
     */
    size_t  getVelocitySourceMany()       const { return mVelocitySourceMany; };

    //-------------------------------------------------- Sensors -----------------------------------------------------//
    /**
     * @brief  Get sensor mask type (linear or corners).
     * @return Sensor mask type.
     */
    SensorMaskType getSensorMaskType()    const { return mSensorMaskType; };
    /**
     * @brief  Get spatial size of the index sensor mask.
     * @return Number of grid points.
     */
    size_t getSensorMaskIndexSize()       const { return mSensorMaskIndexSize ;}
    /**
     * @brief  Get number of cuboids the sensor is composed of.
     * @return Number of cuboids.
     */
    size_t getSensorMaskCornersSize()     const { return mSensorMaskCornersSize; };
    /**
     * @brief  Get start time index when sensor data collection begins
     * @return When to start sampling data.
     */
    size_t getSamplingStartTimeIndex()    const { return mCommandLineParameters.getSamplingStartTimeIndex(); };

    /**
     * @brief  Is  -p or --p_raw specified at the command line?
     * @return true if the flag is set.
     */
    bool getStorePressureRawFlag()        const { return mCommandLineParameters.getStorePressureRawFlag(); };
    /**
     * @brief  Is --p_rms set?
     * @return true if the flag is set.
     */
    bool getStorePressureRmsFlag()        const { return mCommandLineParameters.getStorePressureRmsFlag(); };
    /**
     * @brief  Is --p_max set?
     * @return true if the flag is set.
     */
    bool getStorePressureMaxFlag()        const { return mCommandLineParameters.getStorePressureMaxFlag(); };
    /**
     * @brief  Is --p_min set?
     * @return true if the flag is set.
     */
    bool getStorePressureMinFlag()        const { return mCommandLineParameters.getStorePressureMinFlag(); };
    /**
     * @brief  Is --p_max_all set?
     * @return true if the flag is set.
     */
    bool getStorePressureMaxAllFlag()     const { return mCommandLineParameters.getStorePressureMaxAllFlag(); };
    /**
     * @brief  Is --p_min_all set?
     * @return true if the flag is set.
     */
    bool getStorePressureMinAllFlag()     const { return mCommandLineParameters.getStorePressureMinAllFlag(); };
    /**
     * @brief  Is --p_final set?
     * @return true if the flag is set.
     */
    bool getStorePressureFinalAllFlag()   const { return mCommandLineParameters.getStorePressureFinalAllFlag(); };


    /**
     * @brief  Is -u or --u_raw specified at the command line?
     * @return true if the flag is set.
     */
    bool getStoreVelocityRawFlag()        const { return mCommandLineParameters.getStoreVelocityRawFlag(); };
    /**
     * @brief  Is --u_non_staggered_raw set?
     * @return true if the flag is set.
     */
    bool getStoreVelocityNonStaggeredRawFlag () const
    {
      return mCommandLineParameters.getStoreVelocityNonStaggeredRawFlag();
    };
    /**
     * @brief  Is --u_rms set?
     * @return true if the flag is set.
     */
    bool getStoreVelocityRmsFlag()        const { return mCommandLineParameters.getStoreVelocityRmsFlag(); };
    /**
     * @brief  Is --u_max set?
     * @return true if the flag is set.
     */
    bool getStoreVelocityMaxFlag()        const { return mCommandLineParameters.getStoreVelocityMaxFlag(); };
    /**
     * @brief  Is --u_min set?
     * @return true if the flag is set.
     */
    bool getStoreVelocityMinFlag()        const { return mCommandLineParameters.getStoreVelocityMinFlag(); };
    /**
     * @brief  Is --u_max_all set?
     * @return true if the flag is set.
     */
    bool getStoreVelocityMaxAllFlag()     const { return mCommandLineParameters.getStoreVelocityMaxAllFlag(); };
    /**
     * @brief  Is --u_min set?
     * @return true if the flag is set.
     */
    bool getStoreVelocityMinAllFlag()     const { return mCommandLineParameters.getStoreVelocityMinAllFlag(); };
    /**
     * @brief  Is --u_final set?
     * @return true if the flag is set.
     */
    bool getStoreVelocityFinalAllFlag()   const { return mCommandLineParameters.getStoreVelocityFinalAllFlag(); };

    /**
     * @brief  Is --copy_mask set set?
     * @return true if the flag is set.
     */
    bool getCopySensorMaskFlag()          const { return mCommandLineParameters.getCopySensorMaskFlag(); };

  protected:

  private:
    /// Constructor not allowed for public.
    Parameters();

    /**
     * @brief  Get Wisdom file name (derive it form the checkpoint filename).
     * @return The filename for wisdom.
     */
    std::string getWisdomFileName();

    /// Print medium properties.
    void printMediumProperties();
    /// Print source info.
    void printSourceInfo();

    /**
     * @brief   Print source info.
     * @details In the case of cuboid corners sensor mask, the complete mask has to be read and parsed. The data will
     *          be thrown away after calculating the disk space and read again in the data loading phase.
     *          Fortunately, the sensor mask is supposed to be small.
     */
    void printSensorInfo();

    /// File extension of the FFTW wisdom file.
    const std::string     kFftWisdomFileExtension = "FFTW_Wisdom";

    /// Container holding all the names of all possible parameters present in the HDF5 files.
    static std::map<ParameterNameIdx, MatrixName> sParameterHdf5Names;

    /// Singleton flag.
    static bool           sParametersInstanceFlag;
    /// Singleton instance.
    static Parameters*    sPrametersInstance;

    /// Class with command line parameters
    CommandLineParameters mCommandLineParameters;

    /// Handle to the input HDF5 file.
    Hdf5File       mInputFile;
    /// Handle to the output HDF5 file.
    Hdf5File       mOutputFile;
    /// Handle to the checkpoint HDF5 file.
    Hdf5File       mCheckpointFile;

    /// Handle to the file header.
    Hdf5FileHeader mFileHeader;

    /// Full 3D dimension sizes.
    DimensionSizes mFullDimensionSizes;
    /// Reduced 3D dimension sizes.
    DimensionSizes mReducedDimensionSizes;

    /// Is the simulation axisymmetric?
    bool   mAxisymmetricFlag;

    /// Total number of time steps.
    size_t mNt;
    /// Actual time index (time step of the simulation).
    size_t mTimeIndex;
    /// How many timesteps to interruption. This index set after the simulation starts and decrements every time step.
    size_t mTimeStepsToCheckpoint;

    /// Time step size.
    float mDt;
    /// Spatial displacement in x.
    float mDx;
    /// Spatial displacement in y.
    float mDy;
    /// Spatial displacement in z.
    float mDz;

    /// Reference sound speed.
    float mCRef;
    /// Is sound speed in the medium homogeneous?
    bool  mC0ScalarFlag;
    /// Scalar value of sound speed.
    float mC0Scalar;

    /// Is density in the medium homogeneous?
    bool  mRho0ScalarFlag;
    /// Homogeneous medium density.
    float mRho0Scalar;
    /// Homogeneous medium density on staggered grid in x direction.
    float mRho0SgxScalar;
    ///  Homogeneous medium density on staggered grid in y direction.
    float mRho0SgyScalar;
    ///  Homogeneous medium density on staggered grid in z direction.
    float mRho0SgzScalar;

    /// Enable non uniform grid?
    size_t         mNonUniformGridFlag;
    /// Is the simulation absrobing or lossless?
    AbsorptionType mAbsorbingFlag;
    /// Is the wave propagation nonlinear?
    size_t         mNonLinearFlag;

    /// Is alpha absorption coefficient homogeneous?
    bool  mAlphaCoeffScalarFlag;
    /// Alpha absorption coefficient.
    float mAlphaCoeffScalar;
    /// Alpha power value for the absorption law.
    float mAlphaPower;

    /// Absorb eta coefficient for homogeneous medium.
    float mAbsorbEtaScalar;
    /// Absorb tau coefficient for homogeneous medium.
    float mAbsorbTauScalar;

    /// Is nonlinear coefficient homogeneous in the medium?
    bool  mBOnAScalarFlag;
    /// Nonlinear coefficient for homogenous medium.
    float mBOnAScalar;

    /// Depth of the perfectly matched layer in x.
    size_t mPmlXSize;
    /// Depth of the perfectly matched layer in y.
    size_t mPmlYSize;
    /// Depth of the perfectly matched layer in z.
    size_t mPmlZSize;

    /// Perfectly matched layer attenuation in x.
    float mPmlXAlpha;
    /// Perfectly matched layer attenuation in y.
    float mPmlYAlpha;
    /// Perfectly matched layer attenuation in z.
    float mPmlZAlpha;

    /// Pressure source flag.
    size_t mPressureSourceFlag;
    /// Initial pressure source flag (p0).
    size_t mInitialPressureSourceFlag;
    /// Transducer source flag.
    size_t mTransducerSourceFlag;

    /// Velocity in x source flag.
    size_t mVelocityXSourceFlag;
    /// Velocity in y source flag.
    size_t mVelocityYSourceFlag;
    /// Velocity in z source flag.
    size_t mVelocityZSourceFlag;

    /// Spatial size of the pressure source.
    size_t mPressureSourceIndexSize;
    /// Spatial size of the transducer source.
    size_t mTransducerSourceInputSize;
    /// Spatial size of the velocity source.
    size_t mVelocitySourceIndexSize;

    /// Pressure source mode.
    SourceMode mPressureSourceMode;
    /// Number of time series in the pressure source.
    size_t     mPressureSourceMany;

    /// Velocity source mode.
    SourceMode mVelocitySourceMode;
    /// Number of time series in the velocity sources.
    size_t     mVelocitySourceMany;

    /// Sensor mask type (index / corners).
    SensorMaskType mSensorMaskType;
    /// How many elements there are in the linear mask.
    size_t         mSensorMaskIndexSize;
    /// Sensor_mask_corners_size - how many cuboids are in the mask.
    size_t         mSensorMaskCornersSize;
}; // end of Parameters
//----------------------------------------------------------------------------------------------------------------------
#endif	/* PARAMETERS_H */
