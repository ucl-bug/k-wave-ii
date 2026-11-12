/**
 * @file      Parameters.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file containing parameters of the simulation.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      09 August    2012, 13:39 (created) \n
 *            11 February  2020, 14:49 (revised)
 *
 * @copyright Copyright (C) 2012 - 2020 SC\@FIT Research Group, Brno University of Technology, Brno.
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

#ifdef _OPENMP
  #include <omp.h>
#endif

#ifdef __APPLE__
  #include <sys/sysctl.h>
  #include <string>
#endif

#include <exception>
#include <stdexcept>
#include <limits>

#include <fftw3.h>

#include <Parameters/Parameters.h>
#include <Logger/Logger.h>
#include <MatrixClasses/IndexMatrix.h>

using std::ios;
using std::string;

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Initialization ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Initialization of static map with parameter names.
 */
std::map<Parameters::ParameterNameIdx, MatrixName> Parameters::sParameterHdf5Names
{
  {Parameters::ParameterNameIdx::kTimeIndex,                 "t_index"},
  {Parameters::ParameterNameIdx::kNx,                        "Nx"},
  {Parameters::ParameterNameIdx::kNy,                        "Ny"},
  {Parameters::ParameterNameIdx::kNz,                        "Nz"},
  {Parameters::ParameterNameIdx::kNt,                        "Nt"},

  {Parameters::ParameterNameIdx::kDt,                        "dt"},
  {Parameters::ParameterNameIdx::kDx,                        "dx"},
  {Parameters::ParameterNameIdx::kDy,                        "dy"},
  {Parameters::ParameterNameIdx::kDz,                        "dz"},

  {Parameters::ParameterNameIdx::kCRef,                      "c_ref"},
  {Parameters::ParameterNameIdx::kC0,                        "c0"},

  {Parameters::ParameterNameIdx::kRho0,                      "rho0"},
  {Parameters::ParameterNameIdx::kRho0Sgx,                   "rho0_sgx"},
  {Parameters::ParameterNameIdx::kRho0Sgy,                   "rho0_sgy"},
  {Parameters::ParameterNameIdx::kRho0Sgz,                   "rho0_sgz"},

  {Parameters::ParameterNameIdx::kBOnA,                      "BonA"},
  {Parameters::ParameterNameIdx::kAlphaCoeff,                "alpha_coeff"},
  {Parameters::ParameterNameIdx::kAlphaPower,                "alpha_power"},

  {Parameters::ParameterNameIdx::kPmlXSize,                  "pml_x_size"},
  {Parameters::ParameterNameIdx::kPmlYSize,                  "pml_y_size"},
  {Parameters::ParameterNameIdx::kPmlZSize,                  "pml_z_size"},

  {Parameters::ParameterNameIdx::kPmlXAlpha,                 "pml_x_alpha"},
  {Parameters::ParameterNameIdx::kPmlYAlpha,                 "pml_y_alpha"},
  {Parameters::ParameterNameIdx::kPmlZAlpha,                 "pml_z_alpha"},

  {Parameters::ParameterNameIdx::kAxisymmetricFlag,          "axisymmetric_flag"},
  {Parameters::ParameterNameIdx::kNonUniformGridFlag,        "nonuniform_grid_flag"},
  {Parameters::ParameterNameIdx::kAbsorbingFlag,             "absorbing_flag"},
  {Parameters::ParameterNameIdx::kNonLinearFlag,             "nonlinear_flag"},

  {Parameters::ParameterNameIdx::kPressureSourceFlag,        "p_source_flag"},
  {Parameters::ParameterNameIdx::kInitialPressureSourceFlag, "p0_source_flag"},
  {Parameters::ParameterNameIdx::kTransducerSourceFlag,      "transducer_source_flag"},

  {Parameters::ParameterNameIdx::kVelocityXSourceFlag,       "ux_source_flag"},
  {Parameters::ParameterNameIdx::kVelocityYSourceFlag,       "uy_source_flag"},
  {Parameters::ParameterNameIdx::kVelocityZSourceFlag,       "uz_source_flag"},

  {Parameters::ParameterNameIdx::kPressureSourceMode,        "p_source_mode"},
  {Parameters::ParameterNameIdx::kPressureSourceMany,        "p_source_many"},
  {Parameters::ParameterNameIdx::kVelocitySourceMode,        "u_source_mode"},
  {Parameters::ParameterNameIdx::kVelocitySourceMany,        "u_source_many"},

  {Parameters::ParameterNameIdx::kTransducerSourceInput,     "transducer_source_input"},
  {Parameters::ParameterNameIdx::kPressureSourceIndex,       "p_source_index"},
  {Parameters::ParameterNameIdx::kVelocitySourceIndex,       "u_source_index"},

  {Parameters::ParameterNameIdx::kSensorMaskType,            "sensor_mask_type"},
  {Parameters::ParameterNameIdx::kSensorMaskIndex,           "sensor_mask_index"},
  {Parameters::ParameterNameIdx::kSensorMaskCorners,         "sensor_mask_corners"},
};// end of sParameterHdf5Names
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//---------------------------------------------------- Variables -----------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

// Initialization of the singleton instance flag
bool Parameters::sParametersInstanceFlag   = false;

// Initialization of the instance
Parameters* Parameters::sPrametersInstance = nullptr;

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Public methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Destructor.
 */
Parameters::~Parameters()
{
  sParametersInstanceFlag = false;
  if (sPrametersInstance)
  {
    delete sPrametersInstance;
  }
  sPrametersInstance = nullptr;
};
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get instance of singleton class.
 */
Parameters& Parameters::getInstance()
{
  if(!sParametersInstanceFlag)
  {
    sPrametersInstance = new Parameters();
    sParametersInstanceFlag = true;
    return *sPrametersInstance;
  }
  else
  {
    return *sPrametersInstance;
  }
}// end of getInstance()
//----------------------------------------------------------------------------------------------------------------------

/**
 * Parse command line and read scalar values from the input file to initialize the class and the simulation.
 */
void Parameters::init(int argc, char** argv)
{
  mCommandLineParameters.parseCommandLine(argc, argv);

  if (getGitHash() != "")
  {
    Logger::log(Logger::LogLevel::kFull, kOutFmtGitHashLeft, getGitHash().c_str());
    Logger::log(Logger::LogLevel::kFull, kOutFmtSeparator);
  }
  if (mCommandLineParameters.isPrintVersionOnly())
  {
    return;
  }

  Logger::log(Logger::LogLevel::kBasic, kOutFmtReadingConfiguration);
  readScalarsFromInputFile();

  if (mCommandLineParameters.isBenchmarkEnabled())
  {
    mNt = mCommandLineParameters.getBenchmarkTimeStepsCount();
  }

  if ((mCommandLineParameters.getSamplingStartTimeIndex() >= mNt) ||
      (mCommandLineParameters.getSamplingStartTimeIndex() < 0))
  {
    throw std::invalid_argument(Logger::formatMessage(kErrFmtIllegalSamplingStartTimeStep, 1l, mNt));
  }

  // Checkpoint by number of time steps
  if (mCommandLineParameters.getCheckpointTimeSteps() > 0)
  {
    mTimeStepsToCheckpoint = mCommandLineParameters.getCheckpointTimeSteps();
  }

  Logger::log(Logger::LogLevel::kBasic, kOutFmtDone);
}// end of init
//----------------------------------------------------------------------------------------------------------------------

/**
 * Print parameters of the simulation based in the actual level of verbosity. For 2D simulations, all flags not found
 * in the input file left at default values.
 */
void Parameters::printSimulatoinSetup()
{
  // In full version, print out file format version
  Logger::log(Logger::LogLevel::kFull, kOutFmtFileVersion, getFileHeader().getFileVersionName().c_str());

  Logger::log(Logger::LogLevel::kBasic, kOutFmtNumberOfThreads,    getNumberOfThreads());
  Logger::log(Logger::LogLevel::kBasic, kOutFmtProcessorNameRight, getProcessorName().c_str());

  Logger::log(Logger::LogLevel::kBasic, kOutFmtSimulationDetailsTitle);

  const string domainsSizes = (isSimulation3D()) ? Logger::formatMessage(kOutFmt3DDomainSizeFormat,
                                                                         getFullDimensionSizes().nx,
                                                                         getFullDimensionSizes().ny,
                                                                         getFullDimensionSizes().nz)
                                                 : Logger::formatMessage(kOutFmt2DDomainSizeFormat,
                                                                         getFullDimensionSizes().nx,
                                                                         getFullDimensionSizes().ny);

  // Print simulation size
  Logger::log(Logger::LogLevel::kBasic, kOutFmtDomainSize, domainsSizes.c_str());

  //---------------------------------------------- Print out medium type -----------------------------------------------
  if (isSimulationAS())
  {
    Logger::log(Logger::LogLevel::kBasic, kOutFmtMediumTypeAS);
  }
  else
  {
    if (isSimulation2D())
    {
      Logger::log(Logger::LogLevel::kBasic, kOutFmtMediumType2D);
    }
    if (isSimulation3D())
    {
      Logger::log(Logger::LogLevel::kBasic, kOutFmtMediumType3D);
    }
  }

  Logger::log(Logger::LogLevel::kBasic, kOutFmtSimulatoinLenght, getNt());

  // Print command line parameters without output flags.
  mCommandLineParameters.printComandlineParamers();

  // Print medium properties
  printMediumProperties();

  // Print source info
  printSourceInfo();

  // Print sensor info
  printSensorInfo();
}// end of printSimulatoinSetup
//----------------------------------------------------------------------------------------------------------------------

/**
 * Read scalar values from the input HDF5 file. 2D medium can be normal or axisymmetric but 3D only normal.
 */
void Parameters::readScalarsFromInputFile()
{
  using PI = Parameters::ParameterNameIdx;

  DimensionSizes scalarSizes(1, 1, 1);

  if (!mInputFile.isOpen())
  {
    // Open file -- exceptions handled in main
    mInputFile.open(mCommandLineParameters.getInputFileName());
  }

  mFileHeader.readHeaderFromInputFile(mInputFile);

  // Check file type
  if (mFileHeader.getFileType() != Hdf5FileHeader::FileType::kInput)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtBadInputFileFormat, getInputFileName().c_str()));
  }

  // Check file version
  if (!mFileHeader.checkFileVersion())
  {
    throw ios::failure(Logger::formatMessage(kErrFmtBadFileVersion,
                                             mFileHeader.getFileVersionName().c_str(),
                                             getInputFileName().c_str(),
                                             mFileHeader.getCurrentFileVersionName().c_str()));
  }

  const hid_t rootGroup = mInputFile.getRootGroup();

  //------------------------------------------------ Lambda helpers --------------------------------------------------//

  // Lambda to read a scalar the output file for size_t.
  // We need two function since C++-11 doesn't allow lambda overloading
  auto readIntValue = [this, rootGroup](ParameterNameIdx paramIdx, bool present = true) -> size_t
  {
    size_t value = 0l;
    if (present)
    {
      mInputFile.readScalarValue(rootGroup, sParameterHdf5Names[paramIdx], value);
    }
    return value;
  };// end of readIntValue

  // Lambda to read a scalar the output file for float.
  auto readFloatValue = [this, rootGroup](ParameterNameIdx paramIdx, bool present = true) -> float
  {
    float value = 0.0f;
    if (present)
    {
      mInputFile.readScalarValue(rootGroup, sParameterHdf5Names[paramIdx], value);
    }
    return value;
  };// end of readFloatValue

  // Lambda function to decide whether the matrix is scalar or not.
  auto isScalar = [this, rootGroup, scalarSizes](ParameterNameIdx paramIdx) -> bool
  {
   return (mInputFile.getDatasetDimensionSizes(rootGroup, sParameterHdf5Names[paramIdx]) == scalarSizes);
  }; // end of isScalar

  //--------------------------------------------Grid and PML parameters ----------------------------------------------//
  // Read dimension sizes
  const size_t x = readIntValue(PI::kNx);
  const size_t y = readIntValue(PI::kNy);
  const size_t z = readIntValue(PI::kNz);

  mFullDimensionSizes    = DimensionSizes(x, y, z);
  mReducedDimensionSizes = DimensionSizes(((x / 2) + 1), y, z);

  // Is the simulation axisymmetric?
  // Supported from file version 1.2
  if (mFileHeader.getFileVersion() == Hdf5FileHeader::FileVersion::kVersion12)
  {
    mAxisymmetricFlag = (bool(readIntValue(PI::kAxisymmetricFlag)) && mFullDimensionSizes.is2D());
  }

  // Simulation time
  mNt = readIntValue(PI::kNt);

  // Grid definition
  mDt = readFloatValue(PI::kDt);
  mDx = readFloatValue(PI::kDx);
  mDy = readFloatValue(PI::kDy);
  mDz = readFloatValue(PI::kDz, isSimulation3D());

  mCRef = readFloatValue(PI::kCRef);

  mPmlXSize  = readIntValue(PI::kPmlXSize);
  mPmlYSize  = readIntValue(PI::kPmlYSize);
  mPmlZSize  = readIntValue(PI::kPmlZSize, isSimulation3D());

  mPmlXAlpha = readFloatValue(PI::kPmlXAlpha);
  mPmlYAlpha = readFloatValue(PI::kPmlYAlpha);
  mPmlZAlpha = readFloatValue(PI::kPmlZAlpha, isSimulation3D());

  //----------------------------------------- Medium flags and parameters --------------------------------------------//
  mNonUniformGridFlag = readIntValue(PI::kNonUniformGridFlag);
  mNonLinearFlag      = readIntValue(PI::kNonLinearFlag);

  if (mNonLinearFlag)
  {
    mBOnAScalarFlag   = isScalar(PI::kBOnA);
    mBOnAScalar       = (mBOnAScalarFlag) ? readFloatValue(PI::kBOnA)  : 0.0f;
  }

  mC0ScalarFlag       = isScalar(PI::kC0);
  mC0Scalar           = (mC0ScalarFlag)   ? readFloatValue(PI::kC0)    : 0.0f;

  mRho0ScalarFlag     = isScalar(PI::kRho0);
  mRho0Scalar         = (mRho0ScalarFlag) ? readFloatValue(PI::kRho0)    : 0.0f;
  mRho0SgxScalar      = (mRho0ScalarFlag) ? readFloatValue(PI::kRho0Sgx) : 0.0f;
  mRho0SgyScalar      = (mRho0ScalarFlag) ? readFloatValue(PI::kRho0Sgy) : 0.0f;
  mRho0SgzScalar      = (mRho0ScalarFlag) ? readFloatValue(PI::kRho0Sgz, isSimulation3D()) : 0.0f;


  // Absorption
  const size_t absorbingFlagNumercValue = readIntValue(PI::kAbsorbingFlag);

  // Unknown absorption type
  if (absorbingFlagNumercValue > size_t(AbsorptionType::kStokes))
  {
    throw ios::failure(kErrFmtUnknownAbsorptionType);
  }

  mAbsorbingFlag = static_cast<AbsorptionType>(absorbingFlagNumercValue);

  // Unsupported absorption type
  if (isSimulationAS() && (mAbsorbingFlag == AbsorptionType::kPowerLaw))
  {
    throw ios::failure(kErrFmtPowerLawAbsorptionNotSupportedForAS);
  }

  // Read PowerLaw and Stokes absorption coefficients
  if (mAbsorbingFlag != AbsorptionType::kLossless)
  {
    mAlphaPower = readFloatValue(PI::kAlphaPower);
    if (mAlphaPower == 1.0f)
    {
      throw std::invalid_argument(kErrFmtIllegalAlphaPowerValue);
    }

    mAlphaCoeffScalarFlag = isScalar(PI::kAlphaCoeff);
    mAlphaCoeffScalar     = (mAlphaCoeffScalarFlag) ? readFloatValue(PI::kAlphaCoeff) : 0.0f;
  }

  //---------------------------------------------------- Sensors -----------------------------------------------------//
  // If the file is of version 1.0, there must be a sensor mask index (backward compatibility)
  if (mFileHeader.getFileVersion() == Hdf5FileHeader::FileVersion::kVersion10)
  {
    mSensorMaskIndexSize = mInputFile.getDatasetSize(rootGroup, sParameterHdf5Names[PI::kSensorMaskIndex]);

    //if -u_non_staggered_raw enabled, throw an error - not supported
    if (getStoreVelocityNonStaggeredRawFlag())
    {
      throw ios::failure(kErrFmtNonStaggeredVelocityNotSupportedFileVersion);
    }
  }// version 1.0

  // This is version 1.1 or 1.2
  if (mFileHeader.getFileVersion() >= Hdf5FileHeader::FileVersion::kVersion11)
  {
    // Read sensor mask type as a size_t value to enum
    const size_t sensorMaskTypeNumericValue = readIntValue(PI::kSensorMaskType);

    // Convert the size_t value to enum
    switch (sensorMaskTypeNumericValue)
    {
      case 0:
      {
        mSensorMaskType = SensorMaskType::kIndex;
        break;
      }
      case 1:
      {
        mSensorMaskType = SensorMaskType::kCorners;
        break;
      }
      default:
      {
        throw ios::failure(kErrFmtBadSensorMaskType);
        break;
      }
    }//case

    // Read the input mask size
    switch (mSensorMaskType)
    {
      case SensorMaskType::kIndex:
      {
        mSensorMaskIndexSize = mInputFile.getDatasetSize(rootGroup, sParameterHdf5Names[PI::kSensorMaskIndex]);
        break;
      }
      case SensorMaskType::kCorners:
      {
        // mask dimensions are [6, N, 1] - I want to know N
        mSensorMaskCornersSize = mInputFile.getDatasetDimensionSizes(rootGroup,
                                                                     sParameterHdf5Names[PI::kSensorMaskCorners]
                                                                    ).ny;
        break;
      }
    }// switch
  }// version 1.1

  //---------------------------------------------------- Sources -----------------------------------------------------//
  mInitialPressureSourceFlag = readIntValue(PI::kInitialPressureSourceFlag);
  mPressureSourceFlag        = readIntValue(PI::kPressureSourceFlag);

  mTransducerSourceFlag      = readIntValue(PI::kTransducerSourceFlag);

  mVelocityXSourceFlag       = readIntValue(PI::kVelocityXSourceFlag);
  mVelocityYSourceFlag       = readIntValue(PI::kVelocityYSourceFlag);
  mVelocityZSourceFlag       = readIntValue(PI::kVelocityZSourceFlag, isSimulation3D());

  // Source sizes.
  mTransducerSourceInputSize = (mTransducerSourceFlag)
                                  ? mInputFile.getDatasetSize(rootGroup,sParameterHdf5Names[PI::kTransducerSourceInput])
                                  : 0l;

  // In 2D, mVelocityZSourceFlag is always 0
  if ((mTransducerSourceFlag > 0) || (mVelocityXSourceFlag > 0) ||
      (mVelocityYSourceFlag > 0)  || (mVelocityZSourceFlag > 0))
  {
    mVelocitySourceIndexSize = mInputFile.getDatasetSize(rootGroup, sParameterHdf5Names[PI::kVelocitySourceIndex]);
  }

  // Convert the size_t value to enum
  auto getSourceMode = [](size_t sourceModeNumericValue, const string& errorMessage) -> SourceMode
  {
    switch (sourceModeNumericValue)
    {
      case 0:
      {
        return  SourceMode::kDirichlet;
      }
      case 1:
      {
        return SourceMode::kAdditiveNoCorrection;
      }
      case 2:
      {
        return SourceMode::kAdditive;
      }
      default:
      {
        throw ios::failure(errorMessage);
      }
    }// case
  };// end of getSourceMode

  // Velocity source flags
  if ((mVelocityXSourceFlag > 0) || (mVelocityYSourceFlag > 0) || (mVelocityZSourceFlag > 0))
  {
    mVelocitySourceMany = readIntValue(PI::kVelocitySourceMany);
    mVelocitySourceMode = getSourceMode(readIntValue(PI::kVelocitySourceMode), kErrFmtBadVelocitySourceMode);
  }
  else
  {
    mVelocitySourceMany = 0;
    mVelocitySourceMode = SourceMode::kDirichlet;
  }

  // Pressure source flags
  if (mPressureSourceFlag != 0)
  {
    mPressureSourceMany = readIntValue(PI::kPressureSourceMany);
    // Convert the size_t value to enum
    mPressureSourceMode = getSourceMode(readIntValue(PI::kPressureSourceMode), kErrFmtBadPressureSourceMode);

    mPressureSourceIndexSize = mInputFile.getDatasetSize(rootGroup, sParameterHdf5Names[PI::kPressureSourceIndex]);
  }
  else
  {
    mPressureSourceMode = SourceMode::kDirichlet;
    mPressureSourceMany = 0;
    mPressureSourceIndexSize = 0;
  }
}// end of readScalarsFromInputFile
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write scalars into the output HDF5 file.
 */
void Parameters::writeScalarsToOutputFile()
{
  using PI = Parameters::ParameterNameIdx;

  const hid_t rootGroup = mOutputFile.getRootGroup();

  // Lambda to write a scalar the output file for size_t.
  // We need two function since C++-11 doesn't allow lambda overloading
  auto writeIntValue = [this, rootGroup](ParameterNameIdx paramIdx, size_t value, bool present = true)
  {
    if (present)
    {
      mOutputFile.writeScalarValue(rootGroup, sParameterHdf5Names[paramIdx], value);
    }
  };// end of writeIntValue

  // Lambda to write a scalar the output file for float.
  auto writeFloatValue = [this, rootGroup](ParameterNameIdx paramIdx, float value, bool present = true)
  {
    if (present)
    {
      mOutputFile.writeScalarValue(rootGroup, sParameterHdf5Names[paramIdx], value);
    }
  };// end of writeFloatValue

  //------------------------------------------------------------------------------------------------------------------//

  // Write dimension sizes (Z is always written to distinguish 2D and 3D simulations)
  writeIntValue(PI::kNx, mFullDimensionSizes.nx);
  writeIntValue(PI::kNy, mFullDimensionSizes.ny);
  writeIntValue(PI::kNz, mFullDimensionSizes.nz);

  writeIntValue(PI::kAxisymmetricFlag, size_t(mAxisymmetricFlag));

  writeIntValue(PI::kNt,     mNt);

  writeFloatValue(PI::kDt,   mDt);
  writeFloatValue(PI::kDx,   mDx);
  writeFloatValue(PI::kDy,   mDy);
  writeFloatValue(PI::kDz,   mDz, isSimulation3D());

  writeFloatValue(PI::kCRef, mCRef);

  writeIntValue(PI::kPmlXSize, mPmlXSize);
  writeIntValue(PI::kPmlYSize, mPmlYSize);
  writeIntValue(PI::kPmlZSize, mPmlZSize, isSimulation3D());

  writeFloatValue(PI::kPmlXAlpha, mPmlXAlpha);
  writeFloatValue(PI::kPmlYAlpha, mPmlYAlpha);
  writeFloatValue(PI::kPmlZAlpha, mPmlZAlpha, isSimulation3D());

  writeIntValue(PI::kPressureSourceFlag,        mPressureSourceFlag);
  writeIntValue(PI::kInitialPressureSourceFlag, mInitialPressureSourceFlag);

  writeIntValue(PI::kTransducerSourceFlag,  mTransducerSourceFlag);

  writeIntValue(PI::kVelocityXSourceFlag,   mVelocityXSourceFlag);
  writeIntValue(PI::kVelocityYSourceFlag,   mVelocityYSourceFlag);
  writeIntValue(PI::kVelocityZSourceFlag,   mVelocityZSourceFlag, isSimulation3D());

  writeIntValue(PI::kNonUniformGridFlag,    mNonUniformGridFlag);
  writeIntValue(PI::kAbsorbingFlag,         size_t(mAbsorbingFlag));
  writeIntValue(PI::kNonLinearFlag,         mNonLinearFlag);

  // Velocity source flags.
  if ((mVelocityXSourceFlag > 0) || (mVelocityYSourceFlag > 0) || (mVelocityZSourceFlag > 0))
  {
    writeIntValue(PI::kVelocitySourceMany, mVelocitySourceMany);
    writeIntValue(PI::kVelocitySourceMode, size_t(mVelocitySourceMode));
  }

  // Pressure source flags.
  if (mPressureSourceFlag != 0)
  {
    writeIntValue(PI::kPressureSourceMany, mPressureSourceMany);
    writeIntValue(PI::kPressureSourceMode, size_t(mPressureSourceMode));
  }

  // If copy sensor mask, then copy the mask type
  if (getCopySensorMaskFlag())
  {
    size_t sensorMaskTypeNumericValue = 0;

    switch (mSensorMaskType)
    {
      case SensorMaskType::kIndex:
      {
        sensorMaskTypeNumericValue = 0;
        break;
      }
      case SensorMaskType::kCorners:
      {
        sensorMaskTypeNumericValue = 1;
        break;
      }
    }// switch

    writeIntValue(PI::kSensorMaskType, sensorMaskTypeNumericValue);
  }
}// end of writeScalarsToOutputFile
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get GitHash of the code
 */
string Parameters::getGitHash() const
{
#if (defined (__KWAVE_GIT_HASH__))
  return string(__KWAVE_GIT_HASH__);
#else
  return "";
#endif
}// end of getGitHash
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get the name of the processor used.
 * This routine was inspired by this project [https://gist.github.com/9prady9/a5e1e8bdbc9dc58b3349].
 */
std::string Parameters::getProcessorName() const
{
  std::string processorName = "";

  #ifdef __APPLE__
    char buffer[256];
    size_t bufferSize = sizeof(buffer);

    // Query the processor name using sysctl
    if (sysctlbyname("machdep.cpu.brand_string", buffer, &bufferSize, nullptr, 0) == 0) {
      return std::string(buffer);
    }
    return "Unknown MacOS Processor";
  #else
    // Processor registry
    using ProcessorRegistry = unsigned int[4];
    ProcessorRegistry regs{0 ,0, 0, 0};
    auto cpuid = [](unsigned int funcId, unsigned int subFuncId, ProcessorRegistry& regs)
    {
      // Linux build
      #ifdef __linux__
        asm volatile
          ("cpuid"
            : "=a" (regs[0]),
              "=b" (regs[1]),
              "=c" (regs[2]),
              "=d" (regs[3])
          : "a" (funcId), "c" (subFuncId)
        );
      // ECX is set to zero for CPUID function 4
      #endif

      // Windows build
      #ifdef _WIN64
        __cpuidex((int*)(regs), int(funcId), int(subFuncId));
      #endif
    };

    // Get processor brand string
    // This seems to be working for both Intel & AMD vendors
    for (unsigned int i = 0x80000002; i < 0x80000005; i++)
    {
      cpuid(i, 0, regs);
      processorName += std::string((const char*)&regs[0], 4);
      processorName += std::string((const char*)&regs[1], 4);
      processorName += std::string((const char*)&regs[2], 4);
      processorName += std::string((const char*)&regs[3], 4);
    }

    // Remove leading spaces
    processorName.erase(0, processorName.find_first_not_of(" \t\n"));
    return processorName;
  #endif
}//end of getProcessorName
//----------------------------------------------------------------------------------------------------------------------

/**
 * Is time to checkpoint?
 */
bool Parameters::isTimeToCheckpoint(TimeMeasure timer) const
{
  timer.stop();

  const auto checkpointInterval = mCommandLineParameters.getCheckpointInterval();

  return (isCheckpointEnabled() &&
          ((mTimeStepsToCheckpoint == 0) ||
           (( checkpointInterval > 0) && (timer.getElapsedTime() > float(checkpointInterval)))
          )
         );
}// end of isTimeToCheckpoint
//----------------------------------------------------------------------------------------------------------------------

/**
 * Increment simulation time step and decrement steps to checkpoint.
 */
void Parameters::incrementTimeIndex()
{
  mTimeIndex++;
  mTimeStepsToCheckpoint--;
 }// end of incrementTimeIndex
//----------------------------------------------------------------------------------------------------------------------

/**
 * Export wisdom to the file.
 */
void Parameters::exportWisdom()
{
  #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))
    int success = fftwf_export_wisdom_to_filename(getWisdomFileName().c_str());
    if (success == 0)
    {
      throw std::runtime_error(kErrFmtFftWisdomNotExported);
    }
  #endif
}// end of exportWisdom
//----------------------------------------------------------------------------------------------------------------------

/**
 * Import wisdom from the file.
 */
void Parameters::importWisdom()
{
  #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))
    int success = fftwf_import_wisdom_from_filename(getWisdomFileName().c_str());
    if (success == 0)
    {
      // print out a warning!
      throw std::runtime_error(ErrFmtFftWisdomNotImported);
    }
  #endif
}// end of importWisdom
//----------------------------------------------------------------------------------------------------------------------

/**
 * Delete stored wisdom (delete the file).
 */
void Parameters::deleteStoredWisdom()
{
  std::remove(getWisdomFileName().c_str());
}// end of deleteStoredWisdom
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Protected methods -------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Get Wisdom file name (derive it form the checkpoint filename).
 */
std::string Parameters::getWisdomFileName()
{
  std::string fileName = getCheckpointFileName();
  fileName.erase(fileName.find_last_of("."), std::string::npos);

  fileName.append(".");
  fileName.append(kFftWisdomFileExtension);

  return fileName;
}// end of getWisdomFileName
//----------------------------------------------------------------------------------------------------------------------

/**
 * Print information about medium.
 */
void Parameters::printMediumProperties()
{
  Logger::log(Logger::LogLevel::kAdvanced, kOutFmtMediumDetails);

  Logger::log(Logger::LogLevel::kAdvanced,
              kOutFmtWavePropagation,
              getNonLinearFlag() ? kOutFmtAbsorbtionTypeNonLinear.c_str() : kOutFmtAbsorbtionTypeLinear.c_str());

  switch (getAbsorbingFlag())
  {
    case AbsorptionType::kLossless :
    {
      Logger::log(Logger::LogLevel::kAdvanced, kOutFmtAbsorbtionType,  kOutFmtAbsorbtionLossless.c_str());
      break;
    }
    case AbsorptionType::kPowerLaw :
    {
      Logger::log(Logger::LogLevel::kAdvanced, kOutFmtAbsorbtionType, kOutFmtAbsorbtionPowerLaw.c_str());
      break;
    }
    case AbsorptionType::kStokes :
    {
      Logger::log(Logger::LogLevel::kAdvanced, kOutFmtAbsorbtionType, kOutFmtAbsorbtionStokes.c_str());
      break;
    }
  }

  if (getC0ScalarFlag())
  {
    Logger::log(Logger::LogLevel::kAdvanced, kOutFmtMediumParameters, kOutFmtMediumParametersHomegeneous.c_str());
  }
  else
  {
    if ((getNonLinearFlag() && getBOnAScalarFlag()) ||
        ((getAbsorbingFlag() != AbsorptionType::kLossless) && getAlphaCoeffScalarFlag()))
    {
      Logger::log(Logger::LogLevel::kAdvanced,
                  kOutFmtMediumParameters,
                  kOutFmtMediumParametersHeterogeneousC0andRho0.c_str());
    }
    else
    {
      Logger::log(Logger::LogLevel::kAdvanced, kOutFmtMediumParameters, kOutFmtMediumParametersHeterogeneous.c_str());
    }
  }
}// end of printMediumProperties
//----------------------------------------------------------------------------------------------------------------------

/**
 * Print information about sources.
 */
void Parameters::printSourceInfo()
{
  // Lambda function to convert the number of float elements to MB.
  auto floatToMB = [](size_t size) -> float
  {
    return (size / float(1024 * 1024 / 4));
  };

  // Lambda function to convert the number of size_t elements to MB.
  auto maskToMB = [](size_t size) -> float
  {
    return (size / float(1024 * 1024 / 8));
  };

  // Lambda function to convert source mode to string.
  auto getSourceModeText = [](SourceMode sourceMode) -> std::string
  {
    switch (sourceMode)
    {
      case SourceMode::kDirichlet:
      {
        return kOutFmtSourceModeDirichlet;
      }
      case SourceMode::kAdditiveNoCorrection:
      {
        return kOutFmtSourceModeAdditiveNoCorrection;
      }
      case SourceMode::kAdditive:
      {
        return kOutFmtSourceModeAdditive;
      }
      default:
      {
        return kOutFmtSourceModeDirichlet;
      }
    }
  };// end of getSourceNodeText

  // Print out the information about pressure and velocity sources.
  auto printTimeVaryingSourceInfo = [=](size_t        sourceFlag,
                                        size_t        sourceMany,
                                        SourceMode    sourceMode,
                                        size_t        indexSize,
                                        const string& sourceName)
  {
    Logger::log(Logger::LogLevel::kAdvanced, sourceName);
    // Type
    Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSourceType,
                sourceMany ? kOutFmtSourceTypeMany.c_str() : kOutFmtSourceTypeSingle.c_str());
    // Mode
    Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSourceMode, getSourceModeText(sourceMode).c_str());
    // size = sensor mask + signal size
    const float sensorSize =  maskToMB(indexSize) +
                              ((sourceMany) ? floatToMB(indexSize * sourceFlag) : floatToMB(sourceFlag));

    Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSourceMemoryUsage.c_str(), sensorSize);
  }; //end of printTimeVaryingSourceInfo


  Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSources);
  if (getInitialPressureSourceFlag())
  {
    Logger::log(Logger::LogLevel::kAdvanced, kOutFmtInitialPressureSource);
    Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSourceMemoryUsage.c_str(), floatToMB(mFullDimensionSizes.nElements()));
  }

  if (getPressureSourceFlag())
  {
    printTimeVaryingSourceInfo(getPressureSourceFlag(),
                               getPressureSourceMany(),
                               getPressureSourceMode(),
                               getPressureSourceIndexSize(),
                               kOutFmtPressureSource);
  }

  if (getVelocityXSourceFlag())
  {
    printTimeVaryingSourceInfo(getVelocityXSourceFlag(),
                               getVelocitySourceMany(),
                               getVelocitySourceMode(),
                               getVelocitySourceIndexSize(),
                               kOutFmtVelocityXSource);
  }

  if (getVelocityYSourceFlag())
  {
    printTimeVaryingSourceInfo(getVelocityYSourceFlag(),
                               getVelocitySourceMany(),
                               getVelocitySourceMode(),
                               getVelocitySourceIndexSize(),
                               kOutFmtVelocityYSource);
  }

  if (getVelocityZSourceFlag())
  {
    printTimeVaryingSourceInfo(getVelocityZSourceFlag(),
                               getVelocitySourceMany(),
                               getVelocitySourceMode(),
                               getVelocitySourceIndexSize(),
                               kOutFmtVelocityZSource);
  }

if (getTransducerSourceFlag())
  {
    Logger::log(Logger::LogLevel::kAdvanced, kOutFmtTransducerSource);
    // size = sensor mask + delay mask + signal size
    float sensorSize = maskToMB(2 * getVelocitySourceIndexSize()) + floatToMB(getTransducerSourceInputSize());

    Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSourceMemoryUsage.c_str(), sensorSize);
  }
}// end of printSourceInfo
//----------------------------------------------------------------------------------------------------------------------

/**
 * Print information about used sources.
 */
void Parameters::printSensorInfo()
{
  // Lambda function to convert the number of float elements to MB.
  auto floatToMB = [](size_t size) -> float
  {
    return (float(size) / float(1024 * 1024 / 4));
  };// end of floatToMB

  // Lambda to print sensor type
  auto printSensor = [floatToMB](bool sensorFlag, size_t sensorSize, const string& sensorName)
  {
    if (sensorFlag)
    {
      // Print the sensor name
      Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSensorName, sensorName.c_str());
      // Print sensor file size
      Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSensorFileUsage, floatToMB(sensorSize));
    }
  }; // end of printSensor


  // Print out the sensor info
  Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSensors);

  size_t aggregatedSensorSize = 0;
  const size_t nElements      = getFullDimensionSizes().nElements();
  const size_t sampledSteps   = getNt() - getSamplingStartTimeIndex();

  // Print sensor mask type
  if (getSensorMaskType() == SensorMaskType::kIndex)
  {
    Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSensorMaskIndex);
    // Get size of all sensors.
    aggregatedSensorSize = getSensorMaskIndexSize();
  }
  if (getSensorMaskType() == SensorMaskType::kCorners)
  {
    Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSensorMaskCuboid);

    // Here we have to read the cuboid sensor mask. It's not a good solution, but only feasible without code
    // refactoring.
    IndexMatrix sensorMaskCuboid(DimensionSizes(6 ,getSensorMaskCornersSize(), 1));
    sensorMaskCuboid.readData(mInputFile, sParameterHdf5Names[ParameterNameIdx::kSensorMaskCorners]);
    aggregatedSensorSize = sensorMaskCuboid.getSizeOfAllCuboids();
  }

  // Print starting time step
  Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSamplingStartsAt, getSamplingStartTimeIndex() + 1);
  Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSeparator);

  // Time series
  printSensor(getStorePressureRawFlag(),
              aggregatedSensorSize * sampledSteps,
              kOutFmtSensorPressureRaw.c_str());
  printSensor(getStoreVelocityRawFlag(),
              3 * aggregatedSensorSize * sampledSteps,
              kOutFmtSensorVelocityRaw.c_str());
  printSensor(getStoreVelocityNonStaggeredRawFlag(),
              3 * aggregatedSensorSize * sampledSteps,
              kOutFmtSensorVelocityNonStaggeredRaw.c_str());

  // Aggregated pressure quantities
  printSensor(getStorePressureRmsFlag(),      aggregatedSensorSize, kOutFmtSensorPressureRms.c_str());
  printSensor(getStorePressureMaxFlag(),      aggregatedSensorSize, kOutFmtSensorPressureMax.c_str());
  printSensor(getStorePressureMinFlag(),      aggregatedSensorSize, kOutFmtSensorPressureMin.c_str());
  printSensor(getStorePressureMaxAllFlag(),   nElements, kOutFmtSensorPressureMaxAll.c_str());
  printSensor(getStorePressureMinAllFlag(),   nElements, kOutFmtSensorPressureMinAll.c_str());
  printSensor(getStorePressureFinalAllFlag(), nElements, kOutFmtSensorPressureFinal.c_str());

  // Aggregated velocity quantities
  printSensor(getStoreVelocityRmsFlag(),      3 * aggregatedSensorSize, kOutFmtSensorVelocityRms.c_str());
  printSensor(getStoreVelocityMaxFlag(),      3 * aggregatedSensorSize, kOutFmtSensorVelocityMax.c_str());
  printSensor(getStoreVelocityMinFlag(),      3 * aggregatedSensorSize, kOutFmtSensorVelocityMin.c_str());
  printSensor(getStoreVelocityMaxAllFlag(),   3 * nElements, kOutFmtSensorVelocityMaxAll.c_str());
  printSensor(getStoreVelocityMinAllFlag(),   3 * nElements, kOutFmtSensorVelocityMinAll.c_str());
  printSensor(getStoreVelocityFinalAllFlag(), 3 * nElements, kOutFmtSensorVelocityFinal.c_str());
}// end of printSensorInfo
//----------------------------------------------------------------------------------------------------------------------

/**
 * Constructor.
 */
Parameters::Parameters()
  : mCommandLineParameters(),
    mInputFile(), mOutputFile(), mCheckpointFile(), mFileHeader(),
    mFullDimensionSizes(0,0,0), mReducedDimensionSizes(0,0,0),
    mAxisymmetricFlag(false),
    mNt(0), mTimeIndex(0), mTimeStepsToCheckpoint(std::numeric_limits<size_t>::max()),
    mDt(0.0f), mDx(0.0f), mDy(0.0f), mDz(0.0f),
    mCRef(0.0f), mC0ScalarFlag(false), mC0Scalar(0.0f),
    mRho0ScalarFlag(false), mRho0Scalar(0.0f),
    mRho0SgxScalar(0.0f),   mRho0SgyScalar(0.0f), mRho0SgzScalar(0.0f),
    mNonUniformGridFlag(0), mAbsorbingFlag(AbsorptionType::kLossless), mNonLinearFlag(0),
    mAlphaCoeffScalarFlag(false), mAlphaCoeffScalar(0.0f), mAlphaPower(0.0f),
    mAbsorbEtaScalar(0.0f), mAbsorbTauScalar(0.0f),
    mBOnAScalarFlag(false), mBOnAScalar (0.0f),
    mPmlXSize(0), mPmlYSize(0), mPmlZSize(0),
    mPmlXAlpha(0.0f), mPmlYAlpha(0.0f), mPmlZAlpha(0.0f),
    mPressureSourceFlag(0), mInitialPressureSourceFlag(0), mTransducerSourceFlag(0),
    mVelocityXSourceFlag(0), mVelocityYSourceFlag(0), mVelocityZSourceFlag(0),
    mPressureSourceIndexSize(0), mTransducerSourceInputSize(0),mVelocitySourceIndexSize(0),
    mPressureSourceMode(SourceMode::kDirichlet), mPressureSourceMany(0),
    mVelocitySourceMode(SourceMode::kDirichlet), mVelocitySourceMany(0),
    mSensorMaskType(SensorMaskType::kIndex), mSensorMaskIndexSize (0), mSensorMaskCornersSize(0)
{

}// end of Parameters
//----------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Private methods --------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//
