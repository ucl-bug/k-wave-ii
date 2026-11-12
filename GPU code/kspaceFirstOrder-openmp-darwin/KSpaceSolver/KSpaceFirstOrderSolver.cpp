/**
 * @file      KSpaceFirstOrderSolver.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file containing the main class of the project responsible for the entire simulation.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      12 July      2012, 10:27 (created) \n
 *            11 February  2020, 14:34 (revised)
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

// Unix-like systems (Linux and macOS)
#ifdef defined(__linux__) || defined(__APPLE__)
  #include <sys/resource.h>
#elif _WIN64 // Windows build
  #define _USE_MATH_DEFINES
  #include <Windows.h>
  #include <Psapi.h>
  #pragma comment(lib, "Psapi.lib")
#endif

#ifdef _OPENMP
  #include <omp.h>
#endif

//#include <immintrin.h>
#include <cmath>
#include <ctime>
#include <limits>

#include <KSpaceSolver/KSpaceFirstOrderSolver.h>
#include <Containers/MatrixContainer.h>
#include <Containers/OutputStreamContainer.h>

#include <MatrixClasses/FftwComplexMatrix.h>
#include <Logger/Logger.h>

using std::ios;
/// Shortcut for Simulation dimensions.
using SD = Parameters::SimulationDimension;
/// Shortcut for Matrix id in the container.
using MI = MatrixContainer::MatrixIdx;
/// Shortcut for Output stream id in the container.
using OI = OutputStreamContainer::OutputStreamIdx;

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Initialization ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Initialization of the static map with header attribute names.
 * If c0 is heterogeneous, absorption must be heterogeneous as well (3rd cases).
 * Not all cases are used at this moment.
 */
KSpaceFirstOrderSolver::ComputeMainLoopImp KSpaceFirstOrderSolver::sComputeMainLoopImp
{
  //  3D cases          SD  rho0   bOnA   c0     alpha
  {std::make_tuple(SD::k3D, true,  true,  true,  true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, true,  true,  true , true >},
  {std::make_tuple(SD::k3D, true,  true,  true,  false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, true,  true,  true , false>},
  {std::make_tuple(SD::k3D, true,  true,  false, true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, true,  true,  false, false>},
  {std::make_tuple(SD::k3D, true,  true,  false, false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, true,  true,  false, false>},

  {std::make_tuple(SD::k3D, true,  false, true,  true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, true,  false, true , true >},
  {std::make_tuple(SD::k3D, true,  false, true,  false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, true,  false, true , false>},
  {std::make_tuple(SD::k3D, true,  false, false, true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, true,  false, false, false>},
  {std::make_tuple(SD::k3D, true,  false, false, false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, true,  false, false, false>},

  {std::make_tuple(SD::k3D, false, true,  true,  true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, false, true,  true,  true >},
  {std::make_tuple(SD::k3D, false, true,  true,  false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, false, true,  true,  false>},
  {std::make_tuple(SD::k3D, false, true,  false, true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, false, true,  false, false>},
  {std::make_tuple(SD::k3D, false, true,  false, false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, false, true,  false, false>},

  {std::make_tuple(SD::k3D, false, false, true,  true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, false, false, true , true >},
  {std::make_tuple(SD::k3D, false, false, true,  false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, false, false, true , false>},
  {std::make_tuple(SD::k3D, false, false, false, true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, false, false, false, false>},
  {std::make_tuple(SD::k3D, false, false, false, false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k3D, false, false, false, false>},


  //  2D cases          SD  rho0   bOnA   c0     alpha
  {std::make_tuple(SD::k2D, true,  true,  true,  true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, true,  true,  true,  true >},
  {std::make_tuple(SD::k2D, true,  true,  true,  false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, true,  true,  true,  false>},
  {std::make_tuple(SD::k2D, true,  true,  false, true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, true,  true,  false, false>},
  {std::make_tuple(SD::k2D, true,  true,  false, false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, true,  true,  false, false>},

  {std::make_tuple(SD::k2D, true,  false, true,  true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, true,  false, true,  true >},
  {std::make_tuple(SD::k2D, true,  false, true,  false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, true,  false, true,  false>},
  {std::make_tuple(SD::k2D, true,  false, false, true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, true,  false, false, false>},
  {std::make_tuple(SD::k2D, true,  false, false, false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, true,  false, false, false>},

  {std::make_tuple(SD::k2D, false, true,  true,  true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, false, true,  true,  true >},
  {std::make_tuple(SD::k2D, false, true,  true,  false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, false, true,  true,  false>},
  {std::make_tuple(SD::k2D, false, true,  false, true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, false, true,  false, false>},
  {std::make_tuple(SD::k2D, false, true,  false, false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, false, true,  false, false>},

  {std::make_tuple(SD::k2D, false, false, true,  true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, false, false, true,  true >},
  {std::make_tuple(SD::k2D, false, false, true,  false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, false, false, true,  false>},
  {std::make_tuple(SD::k2D, false, false, false, true ),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, false, false, false, false>},
  {std::make_tuple(SD::k2D, false, false, false, false),
                   &KSpaceFirstOrderSolver::computeMainLoop<SD::k2D, false, false, false, false>}
};

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Public methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Constructor of the class.
 */
KSpaceFirstOrderSolver::KSpaceFirstOrderSolver()
  : mMatrixContainer(),
    mOutputStreamContainer(),
    mParameters(Parameters::getInstance()),
    mActPercent(0l),
    mTotalTime(), mPreProcessingTime(), mDataLoadTime(), mSimulationTime(), mPostProcessingTime(), mIterationTime()
{
  mTotalTime.start();

  // Switch off default HDF5 error messages
  H5Eset_auto(H5E_DEFAULT, NULL, NULL);
}// end of KSpaceFirstOrderSolver
//----------------------------------------------------------------------------------------------------------------------

/**
 * Destructor of the class.
 */
KSpaceFirstOrderSolver::~KSpaceFirstOrderSolver()
{
  freeMemory();
}// end of ~KSpaceFirstOrderSolver
//----------------------------------------------------------------------------------------------------------------------

/**
 * The method allocates the matrix container, creates all matrices and creates all output streams.
 * The memory for output stream is not allocated since the size of the masks is not known.
 */
void KSpaceFirstOrderSolver::allocateMemory()
{
  Logger::log(Logger::LogLevel::kBasic, kOutFmtMemoryAllocation);
  Logger::flush(Logger::LogLevel::kBasic);

  // Add matrices into the container and create all matrices
  mMatrixContainer.init();
  mMatrixContainer.createMatrices();

  // Add output streams into container
  mOutputStreamContainer.init(mMatrixContainer);

  Logger::log(Logger::LogLevel::kBasic, kOutFmtDone);
}// end of allocateMemory
//----------------------------------------------------------------------------------------------------------------------

/**
 * The method frees all memory allocated by the class.
 */
void KSpaceFirstOrderSolver::freeMemory()
{
  mMatrixContainer.freeMatrices();
  mOutputStreamContainer.freeStreams();
}// end of freeMemory
//----------------------------------------------------------------------------------------------------------------------

/**
 * Load data from the input file provided by the Parameter class and create the output time series streams.
 * If checkpointing is enabled, this may include reading data from checkpoint and output files.
 */
void KSpaceFirstOrderSolver::loadInputData()
{
  // Load data from disk
  Logger::log(Logger::LogLevel::kBasic, kOutFmtDataLoading);
  Logger::flush(Logger::LogLevel::kBasic);
  // Start timer
  mDataLoadTime.start();

  // Get handles
  Hdf5File& inputFile      = mParameters.getInputFile(); // file is opened (in Parameters)
  Hdf5File& outputFile     = mParameters.getOutputFile();
  Hdf5File& checkpointFile = mParameters.getCheckpointFile();

  // Load data from disk
  Logger::log(Logger::LogLevel::kFull, kOutFmtNoDone);
  Logger::log(Logger::LogLevel::kFull, kOutFmtReadingInputFile);
  Logger::flush(Logger::LogLevel::kFull);

  // Load data from the input file
  mMatrixContainer.loadDataFromInputFile();

  // Close the input file since we don't need it anymore.
  inputFile.close();

  Logger::log(Logger::LogLevel::kFull, kOutFmtDone);

  // Recover from the checkpoint if it is enabled and the checkpoint file exists.
  bool recoverFromCheckpoint = (mParameters.isCheckpointEnabled() &&
                                Hdf5File::canAccess(mParameters.getCheckpointFileName()));

  if (recoverFromCheckpoint)
  {
    //--------------------------------------- Recovery from checkpoint file ------------------------------------------//
    Logger::log(Logger::LogLevel::kFull, kOutFmtReadingCheckpointFile);
    Logger::flush(Logger::LogLevel::kFull);

    // Open checkpoint file
    checkpointFile.open(mParameters.getCheckpointFileName());
    // Check the checkpoint file
    checkCheckpointFile();

    // Read the actual value of t_index
    size_t checkpointedTimeIndex;
    checkpointFile.readScalarValue(checkpointFile.getRootGroup(),
                                   mParameters.getTimeIndexHdf5Name(),
                                   checkpointedTimeIndex);
    mParameters.setTimeIndex(checkpointedTimeIndex);

    // Read necessary matrices from the checkpoint file
    mMatrixContainer.loadDataFromCheckpointFile();
    // Close checkpoint file, not needed any more.
    checkpointFile.close();

    Logger::log(Logger::LogLevel::kFull, kOutFmtDone);


    // Read data from the output file
    Logger::log(Logger::LogLevel::kFull, kOutFmtReadingOutputFile);
    Logger::flush(Logger::LogLevel::kFull);

    // Reopen output file for RW access
    outputFile.open(mParameters.getOutputFileName(), H5F_ACC_RDWR);
    // Read file header of the output file
    mParameters.getFileHeader().readHeaderFromOutputFile(outputFile);
    // Check the output file
    checkOutputFile();
    // Restore elapsed time
    readElapsedTimeFromOutputFile();
    // Reopen steams to store data again.
    mOutputStreamContainer.reopenStreams();

    Logger::log(Logger::LogLevel::kFull, kOutFmtDone);
  }
  else
  { //------------------------------------ First round of multi-leg simulation ---------------------------------------//
    // Create the output file
    Logger::log(Logger::LogLevel::kFull, kOutFmtCreatingOutputFile);
    Logger::flush(Logger::LogLevel::kFull);

    outputFile.create(mParameters.getOutputFileName());
    Logger::log(Logger::LogLevel::kFull, kOutFmtDone);

    // Create the steams, link them with the sampled matrices, however DO NOT allocate memory!
    mOutputStreamContainer.createStreams();
  }

  // Stop timer
  mDataLoadTime.stop();
  if (Logger::getLevel() != Logger::LogLevel::kFull)
  {
    Logger::log(Logger::LogLevel::kBasic, kOutFmtDone);
  }

  // Print out loading time
  Logger::log(Logger::LogLevel::kBasic, kOutFmtElapsedTime, mDataLoadTime.getElapsedTime());
}// end of loadInputData
//----------------------------------------------------------------------------------------------------------------------

/**
 * Run the simulation.
 */
void KSpaceFirstOrderSolver::compute()
{
  // FFT initialization and preprocessing
  try
  {
    mPreProcessingTime.start();

    // Initialize all used FFTW plans
    initializeFftwPlans();

    // Preprocessing phase generating necessary variables
    if (mParameters.isSimulation3D())
    {
      preProcessing<SD::k3D>();
    }
    else
    {
      preProcessing<SD::k2D>();
    }

    mPreProcessingTime.stop();
  }
  catch (const std::exception& e)
  {
    Logger::log(Logger::LogLevel::kBasic, kOutFmtFailed);
    Logger::log(Logger::LogLevel::kBasic, kOutFmtLastSeparator);

    Logger::errorAndTerminate(Logger::wordWrapString(e.what(),kErrFmtPathDelimiters, 9));
  }

  // Logger header for simulation
  Logger::log(Logger::LogLevel::kBasic, kOutFmtElapsedTime, mPreProcessingTime.getElapsedTime());

  // Memory and disk space
  Logger::log(Logger::LogLevel::kBasic, kOutFmtCompResourcesHeader);
  Logger::log(Logger::LogLevel::kBasic, kOutFmtCurrentMemory,   getMemoryUsage());
  Logger::log(Logger::LogLevel::kBasic, kOutFmtOutputFileUsage, getFileUsage());

  // Main simulation loop
  try
  {
    mSimulationTime.start();

    // Invoke a specific version of computeMainLoop
    sComputeMainLoopImp[std::make_tuple(mParameters.getSimulationDimension(),
                                        mParameters.getRho0ScalarFlag(),
                                        mParameters.getBOnAScalarFlag(),
                                        mParameters.getC0ScalarFlag(),
                                        mParameters.getAlphaCoeffScalarFlag())](*this);

    mSimulationTime.stop();

    Logger::log(Logger::LogLevel::kBasic,kOutFmtSimulationEndSeparator);
  }
  catch (const std::exception& e)
  {
    Logger::log(Logger::LogLevel::kBasic, kOutFmtSimulatoinFinalSeparator);
    Logger::errorAndTerminate(Logger::wordWrapString(e.what(),kErrFmtPathDelimiters, 9));
  }

  // Post processing phase
  mPostProcessingTime.start();

  try
  {
    if (isCheckpointInterruption())
    { // Checkpoint
      Logger::log(Logger::LogLevel::kBasic, kOutFmtElapsedTime, mSimulationTime.getElapsedTime());
      Logger::log(Logger::LogLevel::kBasic, kOutFmtCheckpointCompletedTimeSteps, mParameters.getTimeIndex());
      Logger::log(Logger::LogLevel::kBasic, kOutFmtCheckpointHeader);
      Logger::log(Logger::LogLevel::kBasic, kOutFmtCreatingCheckpoint);
      Logger::flush(Logger::LogLevel::kBasic);

      if (Logger::getLevel() == Logger::LogLevel::kFull)
      {
        Logger::log(Logger::LogLevel::kBasic, kOutFmtNoDone);
      }

      writeCheckpointData();

      if (Logger::getLevel() != Logger::LogLevel::kFull)
      {
        Logger::log(Logger::LogLevel::kBasic, kOutFmtDone);
      }
    }
    else
    { // Finish
      Logger::log(Logger::LogLevel::kBasic, kOutFmtElapsedTime, mSimulationTime.getElapsedTime());
      Logger::log(Logger::LogLevel::kBasic, kOutFmtSeparator);
      Logger::log(Logger::LogLevel::kBasic, kOutFmtPostProcessing);
      Logger::flush(Logger::LogLevel::kBasic);

      postProcessing();

      // If checkpointing is enabled and the checkpoint file already exists, delete it
      if (mParameters.isCheckpointEnabled())
      {
        std::remove(mParameters.getCheckpointFileName().c_str());
        mParameters.deleteStoredWisdom();
      }
      Logger::log(Logger::LogLevel::kBasic, kOutFmtDone);
    }
  }
  catch (const std::exception &e)
  {
    Logger::log(Logger::LogLevel::kBasic, kOutFmtFailed);
    Logger::log(Logger::LogLevel::kBasic, kOutFmtLastSeparator);

    Logger::errorAndTerminate(Logger::wordWrapString(e.what(), kErrFmtPathDelimiters,9));
  }
  mPostProcessingTime.stop();

  // Final data written
  try
  {
    writeOutputDataInfo();
    mParameters.getOutputFile().close();

    Logger::log(Logger::LogLevel::kBasic, kOutFmtElapsedTime, mPostProcessingTime.getElapsedTime());
    }
  catch (const std::exception &e)
  {
    Logger::log(Logger::LogLevel::kBasic, kOutFmtLastSeparator);
    Logger::errorAndTerminate(Logger::wordWrapString(e.what(), kErrFmtPathDelimiters, 9));
  }
}// end of compute
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get peak memory usage.
 */
size_t KSpaceFirstOrderSolver::getMemoryUsage() const
{
  // Linux build
  #ifdef __linux__
    struct rusage memUsage;
    getrusage(RUSAGE_SELF, &memUsage);

    return memUsage.ru_maxrss >> 10;
  #endif

  // Windows build
  #ifdef _WIN64
    HANDLE hProcess;
    PROCESS_MEMORY_COUNTERS pmc;

    hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,
                           FALSE,
                           GetCurrentProcessId());

    GetProcessMemoryInfo(hProcess, &pmc, sizeof(pmc));
    CloseHandle(hProcess);

    return pmc.PeakWorkingSetSize >> 20;
  #endif
// Unix-like systems (Linux and macOS)
#if defined(__linux__) || defined(__APPLE__)
  struct rusage memUsage;
  getrusage(RUSAGE_SELF, &memUsage);
  return memUsage.ru_maxrss >> 10;
#endif
}// end of getMemoryUsage
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get expected output file usage in MB.
 */
size_t KSpaceFirstOrderSolver::getFileUsage()
{
  // Accumulator
  size_t fileUsage = 0;

  // Sensor sizes and time steps sampled
  const size_t sensorMaskSize = (mParameters.getSensorMaskType() == Parameters::SensorMaskType::kIndex)
                                   ? mParameters.getSensorMaskIndexSize()
                                   : getIndexMatrix(MI::kSensorMaskCorners).getSizeOfAllCuboids();
  const size_t domainSize     = mParameters.getFullDimensionSizes().nElements();
  const size_t sampledSteps   = mParameters.getNt() - mParameters.getSamplingStartTimeIndex();

  // Time series
  if (mParameters.getStorePressureRawFlag())
  {
    fileUsage += sensorMaskSize * sampledSteps;
  }

  if (mParameters.getStoreVelocityRawFlag())
  {
    fileUsage += 3 * sensorMaskSize * sampledSteps;
  }

  if (mParameters.getStoreVelocityNonStaggeredRawFlag())
  {
    fileUsage += 3 * sensorMaskSize * sampledSteps;
  }

  // Aggregated pressure
  if (mParameters.getStorePressureRmsFlag())
  {
    fileUsage += sensorMaskSize;
  }
  if (mParameters.getStorePressureMaxFlag())
  {
    fileUsage += sensorMaskSize;
  }
  if (mParameters.getStorePressureMinFlag())
  {
    fileUsage += sensorMaskSize;
  }

  if (mParameters.getStorePressureMaxAllFlag())
  {
    fileUsage += domainSize;
  }
  if (mParameters.getStorePressureMinAllFlag())
  {
    fileUsage += domainSize;
  }
  if (mParameters.getStorePressureFinalAllFlag())
  {
    fileUsage += domainSize;
  }

  // Aggregated velocities
  if (mParameters.getStoreVelocityRmsFlag())
  {
    fileUsage += 3 * sensorMaskSize;
  }
  if (mParameters.getStoreVelocityMaxFlag())
  {
    fileUsage += 3 * sensorMaskSize;
  }
  if (mParameters.getStoreVelocityMinFlag())
  {
    fileUsage += 3 * sensorMaskSize;
  }

  if (mParameters.getStoreVelocityMaxAllFlag())
  {
    fileUsage += 3 * domainSize;
  }
  if (mParameters.getStoreVelocityMinAllFlag())
  {
    fileUsage += 3 * domainSize;
  }
  if (mParameters.getStoreVelocityFinalAllFlag())
  {
    fileUsage += 3 * domainSize;
  }

  // Sensor mask
  if (mParameters.getCopySensorMaskFlag())
  {
    // 2x due to the size_t data type
    fileUsage = (mParameters.getSensorMaskType() == Parameters::SensorMaskType::kIndex)
                   ? fileUsage + 2 * sensorMaskSize
                   : fileUsage + 2 * mParameters.getSensorMaskCornersSize() * 6;
  }

  return float(fileUsage) / float(1024 * 1024 / 4);

}// end of getFileUsage
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get release code version.
 */
std::string KSpaceFirstOrderSolver::getCodeName() const
{
  return kOutFmtKWaveVersion;
}// end of getCodeName
//----------------------------------------------------------------------------------------------------------------------

/**
 * Print full code name and the license.
 */
void KSpaceFirstOrderSolver::printFullCodeNameAndLicense() const
{
  Logger::log(Logger::LogLevel::kBasic, kOutFmtBuildNoDataTime, 10, 11, __DATE__, 8, 8, __TIME__);

  if (mParameters.getGitHash() != "")
  {
    Logger::log(Logger::LogLevel::kBasic, kOutFmtVersionGitHash, mParameters.getGitHash().c_str());
  }
  Logger::log(Logger::LogLevel::kBasic, kOutFmtSeparator);

  // OS detection
  #ifdef __linux__
    Logger::log(Logger::LogLevel::kBasic, kOutFmtLinuxBuild);
  #elif __APPLE__
    Logger::log(Logger::LogLevel::kBasic, kOutFmtMacOsBuild);
  #elif _WIN32
    Logger::log(Logger::LogLevel::kBasic, kOutFmtWindowsBuild);
  #endif

  // Compiler detections
  #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))
    Logger::log(Logger::LogLevel::kBasic, kOutFmtGnuCompiler, __VERSION__);
  #endif
  #ifdef __INTEL_COMPILER
    Logger::log(Logger::LogLevel::kBasic, kOutFmtIntelCompiler, __INTEL_COMPILER);
  #endif
  #ifdef _MSC_VER
	Logger::log(Logger::LogLevel::kBasic, kOutFmtVisualStudioCompiler, _MSC_VER);
  #endif

  // CPU detection
  Logger::log(Logger::LogLevel::kBasic, kOutFmtProcessorNameLeft, mParameters.getProcessorName().c_str());

  // Default branch instruction set detection.
  #if (defined (__AVX512F__))
    Logger::log(Logger::LogLevel::kBasic, kOutFmtAVX512);
  #elif (defined (__AVX2__))
    Logger::log(Logger::LogLevel::kBasic, kOutFmtAVX2);
  #elif (defined (__AVX__))
    Logger::log(Logger::LogLevel::kBasic, kOutFmtAVX);
  #elif (defined (__SSE4_2__))
    Logger::log(Logger::LogLevel::kBasic, kOutFmtSSE42);
  #elif (defined (__SSE4_1__))
    Logger::log(Logger::LogLevel::kBasic, kOutFmtSSE41);
  #elif (defined (__SSE3__))
    Logger::log(Logger::LogLevel::kBasic, kOutFmtSSE3);
  #elif (defined (__SSE2__))
    Logger::log(Logger::LogLevel::kBasic, kOutFmtSSE2);
  #endif

  // Print license
  Logger::log(Logger::LogLevel::kBasic, kOutFmtLicense);
}// end of printFullCodeNameAndLicense
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Protected methods -------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Check the output file has the correct format and version.
 */
void KSpaceFirstOrderSolver::checkOutputFile()
{
  // The header has already been read
  Hdf5FileHeader& fileHeader = mParameters.getFileHeader();
  Hdf5File&       outputFile = mParameters.getOutputFile();

  // Check file type
  if (fileHeader.getFileType() != Hdf5FileHeader::FileType::kOutput)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtBadOutputFileFormat, mParameters.getOutputFileName().c_str()));
  }

  // Check file version
  if (!fileHeader.checkFileVersion())
  {
    throw ios::failure(Logger::formatMessage(kErrFmtBadFileVersion,
                                             fileHeader.getFileVersionName().c_str(),
                                             mParameters.getOutputFileName().c_str(),
                                             fileHeader.getCurrentFileVersionName().c_str()));
  }

  // Check dimension sizes
  DimensionSizes outputDimSizes;
  outputFile.readScalarValue(outputFile.getRootGroup(), mParameters.getNxHdf5Name(), outputDimSizes.nx);
  outputFile.readScalarValue(outputFile.getRootGroup(), mParameters.getNyHdf5Name(), outputDimSizes.ny);
  outputFile.readScalarValue(outputFile.getRootGroup(), mParameters.getNzHdf5Name(), outputDimSizes.nz);

  if (mParameters.getFullDimensionSizes() != outputDimSizes)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtOutputDimensionsMismatch,
                                             outputDimSizes.nx,
                                             outputDimSizes.ny,
                                             outputDimSizes.nz,
                                             mParameters.getFullDimensionSizes().nx,
                                             mParameters.getFullDimensionSizes().ny,
                                             mParameters.getFullDimensionSizes().nz));
  }
}// end of checkOutputFile
//----------------------------------------------------------------------------------------------------------------------

/**
 * Check the checkpoint file has the correct format and version.
 */
void KSpaceFirstOrderSolver::checkCheckpointFile()
{
  // Read the header and check the file version
  Hdf5FileHeader fileHeader;
  Hdf5File&      checkpointFile = mParameters.getCheckpointFile();

  fileHeader.readHeaderFromCheckpointFile(checkpointFile);

  // Check file type
  if (fileHeader.getFileType() != Hdf5FileHeader::FileType::kCheckpoint)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtBadCheckpointFileFormat,
                                             mParameters.getCheckpointFileName().c_str()));
  }

  // Check file version
  if (!fileHeader.checkFileVersion())
  {
    throw ios::failure(Logger::formatMessage(kErrFmtBadFileVersion,
                                             fileHeader.getFileVersionName().c_str(),
                                             mParameters.getCheckpointFileName().c_str(),
                                             fileHeader.getCurrentFileVersionName().c_str()));
  }

  // Check dimension sizes
  DimensionSizes checkpointDimSizes;
  checkpointFile.readScalarValue(checkpointFile.getRootGroup(), mParameters.getNxHdf5Name(), checkpointDimSizes.nx);
  checkpointFile.readScalarValue(checkpointFile.getRootGroup(), mParameters.getNyHdf5Name(), checkpointDimSizes.ny);
  checkpointFile.readScalarValue(checkpointFile.getRootGroup(), mParameters.getNzHdf5Name(), checkpointDimSizes.nz);

  if (mParameters.getFullDimensionSizes() != checkpointDimSizes)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCheckpointDimensionsMismatch,
                                             checkpointDimSizes.nx,
                                             checkpointDimSizes.ny,
                                             checkpointDimSizes.nz,
                                             mParameters.getFullDimensionSizes().nx,
                                             mParameters.getFullDimensionSizes().ny,
                                             mParameters.getFullDimensionSizes().nz));
  }
}// end of checkCheckpointFile
//----------------------------------------------------------------------------------------------------------------------

/**
 * Restore cumulated elapsed time from the output file.
 */
void KSpaceFirstOrderSolver::readElapsedTimeFromOutputFile()
{
  double totalTime, dataLoadTime, preProcessingTime, simulationTime, postProcessingTime;

  // Get execution times stored in the output file header
  mParameters.getFileHeader().getExecutionTimes(totalTime,
                                                dataLoadTime,
                                                preProcessingTime,
                                                simulationTime,
                                                postProcessingTime);

  mTotalTime.SetElapsedTimeOverPreviousLegs(totalTime);
  mDataLoadTime.SetElapsedTimeOverPreviousLegs(dataLoadTime);
  mPreProcessingTime.SetElapsedTimeOverPreviousLegs(preProcessingTime);
  mSimulationTime.SetElapsedTimeOverPreviousLegs(simulationTime);
  mPostProcessingTime.SetElapsedTimeOverPreviousLegs(postProcessingTime);

}// end of readElapsedTimeFromOutputFile
//----------------------------------------------------------------------------------------------------------------------

/**
 * Was the loop interrupted to checkpoint?
 */
bool KSpaceFirstOrderSolver::isCheckpointInterruption() const
{
  return (mParameters.getTimeIndex() != mParameters.getNt());
}// end of isCheckpointInterruption
//----------------------------------------------------------------------------------------------------------------------

/**
 * Initialize FFTW plans.
 */
void KSpaceFirstOrderSolver::initializeFftwPlans()
{
  // Initialization of FFTW library
  #ifdef _OPENMP
    fftwf_init_threads();
    fftwf_plan_with_nthreads(mParameters.getNumberOfThreads());
  #endif

  // Shall we recover from previous state - if checkpointing is enabled and the checkpoint file exists
  bool recoverFromPrevState = (mParameters.isCheckpointEnabled() &&
                               Hdf5File::canAccess(mParameters.getCheckpointFileName()));

  // If the GCC compiler with FFTW is used, try to import wisdom
  #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))
    // Import system wide wisdom
    fftwf_import_system_wisdom();

    if (recoverFromPrevState)
    {
      Logger::log(Logger::LogLevel::kFull, kOutFmtLoadingFftwWisdom);
      Logger::flush(Logger::LogLevel::kFull);
      // Import FFTW wisdom
      try
      {
        // Try to find the wisdom in the file that has the same name as the checkpoint file (different extension)
        mParameters.importWisdom();
        Logger::log(Logger::LogLevel::kFull, kOutFmtDone);
      }
      catch (const std::runtime_error& e)
      {
        Logger::log(Logger::LogLevel::kFull, kOutFmtFailed);
      }
    }
  #endif

  Logger::log(Logger::LogLevel::kBasic, kOutFmtFftPlans);
  Logger::flush(Logger::LogLevel::kBasic);

  // Use p matrix to plan FFTs. This matrix is rewritten!
  RealMatrix& p = getRealMatrix(MI::kP);

  if (mParameters.isSimulationAS())
  { // Axisymmetric coordinates, create R2R transforms in y direction, and R2C and C2R in x direction.
    getTemp1FftwRealND().createPlans1DY(p);
    getTemp2FftwRealND().createPlans1DY(p);

    getTempFftwX().createR2CFftPlan1DX(p);
    getTempFftwX().createC2RFftPlan1DX(p);

    getTempFftwY().createC2RFftPlan1DX(p);
    getTempFftwY().createR2CFftPlan1DX(p);
  }
  else
  { // Normal coordinates, create ND R2C and CR transforms.
    // Create real to complex plans
    getTempFftwX().createR2CFftPlanND(p);
    getTempFftwY().createR2CFftPlanND(p);
    if (mParameters.isSimulation3D())
    {
      getTempFftwZ().createR2CFftPlanND(p);
    }

    // Create real to complex plans
    getTempFftwX().createC2RFftPlanND(p);
    getTempFftwY().createC2RFftPlanND(p);
    if (mParameters.isSimulation3D())
    {
      getTempFftwZ().createC2RFftPlanND(p);
    }
  }

  // If necessary, create 1D shift plans.
  // In this case, the matrix has a bit bigger dimensions to be able to store shifted matrices.
  if (Parameters::getInstance().getStoreVelocityNonStaggeredRawFlag())
  {
    // X shifts
    getTempFftwShift().createR2CFftPlan1DX(getRealMatrix(MI::kUxShifted));
    getTempFftwShift().createC2RFftPlan1DX(getRealMatrix(MI::kUxShifted));

    // Y shifts
    getTempFftwShift().createR2CFftPlan1DY(getRealMatrix(MI::kUyShifted));
    getTempFftwShift().createC2RFftPlan1DY(getRealMatrix(MI::kUyShifted));

    // Z shifts
    if (mParameters.isSimulation3D())
    {
      getTempFftwShift().createR2CFftPlan1DZ(getRealMatrix(MI::kUzShifted));
      getTempFftwShift().createC2RFftPlan1DZ(getRealMatrix(MI::kUzShifted));
    }
  }// end u_non_staggered

  Logger::log(Logger::LogLevel::kBasic, kOutFmtDone);
}// end of initializeFftwPlans
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute pre-processing phase.
 */
template<SD simulationDimension>
void KSpaceFirstOrderSolver::preProcessing()
{
  Logger::log(Logger::LogLevel::kBasic,kOutFmtPreProcessing);
  Logger::flush(Logger::LogLevel::kBasic);

  // Get the correct sensor mask and recompute indices
  if (mParameters.getSensorMaskType() == Parameters::SensorMaskType::kIndex)
  {
    getIndexMatrix(MI::kSensorMaskIndex).recomputeIndicesToCPP();
  }

  if (mParameters.getSensorMaskType() == Parameters::SensorMaskType::kCorners)
  {
    getIndexMatrix(MI::kSensorMaskCorners).recomputeIndicesToCPP();
  }

  if ((mParameters.getTransducerSourceFlag() != 0) ||
      (mParameters.getVelocityXSourceFlag() != 0)  ||
      (mParameters.getVelocityYSourceFlag() != 0)  ||
      (mParameters.getVelocityZSourceFlag() != 0)
     )
  {
    getIndexMatrix(MI::kVelocitySourceIndex).recomputeIndicesToCPP();
  }

  if (mParameters.getTransducerSourceFlag() != 0)
  {
    getIndexMatrix(MI::kDelayMask).recomputeIndicesToCPP();
  }

  if (mParameters.getPressureSourceFlag() != 0)
  {
    getIndexMatrix(MI::kPressureSourceIndex).recomputeIndicesToCPP();
  }

  // Compute dt / rho0_sg...
  if (!mParameters.getRho0ScalarFlag())
  { // Non-uniform grid cannot be pre-calculated :-(
    // rho is a matrix
    if (mParameters.getNonUniformGridFlag())
    {
      generateInitialDenisty<simulationDimension>();
    }
    else
    {
      getRealMatrix(MI::kDtRho0Sgx).scalarDividedBy(mParameters.getDt());
      getRealMatrix(MI::kDtRho0Sgy).scalarDividedBy(mParameters.getDt());
      if (simulationDimension == SD::k3D)
      {
        getRealMatrix(MI::kDtRho0Sgz).scalarDividedBy(mParameters.getDt());
      }
    }
  }

  // Generate constant matrices
  if (mParameters.isSimulationAS())
  { // Axisymmetric medium
    generateDerivativeOperatorsAS();
    generateKappaAS();

    if (mParameters.getAbsorbingFlag() == Parameters::AbsorptionType::kStokes)
    {
      generateTau();
    }
  }
  else
  { // Normal medium
    // Generate shift variables
    generateDerivativeOperators();

    // Generate absorption variables and kappa
    switch (mParameters.getAbsorbingFlag())
    {
      case Parameters::AbsorptionType::kLossless:
      {
        generateKappa();
        break;
      }
      case Parameters::AbsorptionType::kPowerLaw:
      {
        generateKappaAndNablas();
        generateTauAndEta();
        break;
      }
      case Parameters::AbsorptionType::kStokes:
      {
        generateKappa();
        generateTau();
        break;
      }
    }
  }

  // Generate sourceKappa
  if (((mParameters.getVelocitySourceMode() == Parameters::SourceMode::kAdditive) ||
       (mParameters.getPressureSourceMode() == Parameters::SourceMode::kAdditive)) &&
      (mParameters.getPressureSourceFlag()  ||
       mParameters.getVelocityXSourceFlag() ||
       mParameters.getVelocityYSourceFlag() ||
       mParameters.getVelocityZSourceFlag()))
  {
    if (mParameters.isSimulationAS())
    { // Axisymmetric medium
      generateSourceKappaAS();
    }
    else
    { // Normal medium
      generateSourceKappa();
    }
  }

  // Non-staggered shift variables
  if (mParameters.getStoreVelocityNonStaggeredRawFlag())
  {
    generateNonStaggeredShiftVariables();
  }

  // Generate PML
  generatePml();

  // Calculate c^2. It has to be after kappa gen... because of c modification
  generateC2();

  Logger::log(Logger::LogLevel::kBasic, kOutFmtDone);
}// end of preProcessing
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute the main time loop of KSpaceFirstOrder solver.
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag,
         bool bOnAScalarFlag,
         bool c0ScalarFlag,
         bool alphaCoefScalarFlag>
void KSpaceFirstOrderSolver::computeMainLoop()
{
  mActPercent = 0;
  // Set the actual progress percentage to correspond the time index after recovery
  if (mParameters.getTimeIndex() > 0)
  {
    mActPercent = (100 * mParameters.getTimeIndex()) / mParameters.getNt();
  }

  // Progress header
  Logger::log(Logger::LogLevel::kBasic,kOutFmtSimulationHeader);

  mIterationTime.start();

  // Execute main loop
  while ((mParameters.getTimeIndex() < mParameters.getNt()) &&
         (!mParameters.isTimeToCheckpoint(mTotalTime)))
  {
    const size_t timeIndex = mParameters.getTimeIndex();

    // Compute pressure gradient
    if (mParameters.isSimulationAS())
    { // Axisymmetric medium
      computePressureGradientAS();
    }
    else
    { // Normal medium
      computePressureGradient<simulationDimension>();
    }

    // Compute velocity
    computeVelocity<simulationDimension, rho0ScalarFlag>();

    // Add in the velocity source term
    addVelocitySource();

    // Add in the transducer source term (t = t1) to ux
    if (mParameters.getTransducerSourceFlag() > timeIndex)
    {
      // Transducer source is added only to the x component of the particle velocity
      addTransducerSource();
    }

    // Compute gradient of velocity
    if (mParameters.isSimulationAS())
    {
      computeVelocityGradientAS();
    }
    else
    {
      computeVelocityGradient<simulationDimension>();
    }

    // Compute density
    if (mParameters.getNonLinearFlag())
    {
      computeDensityNonliner<simulationDimension, rho0ScalarFlag>();
    }
    else
    {
      computeDensityLinear<simulationDimension, rho0ScalarFlag>();
    }

    // Add in the source pressure term
    addPressureSource<simulationDimension>();

    // Compute new pressure
    computePressure<simulationDimension, rho0ScalarFlag, bOnAScalarFlag, c0ScalarFlag, alphaCoefScalarFlag>();

    // Calculate initial pressure
    if ((timeIndex == 0) && (mParameters.getInitialPressureSourceFlag() == 1))
    {
      addInitialPressureSource<simulationDimension, rho0ScalarFlag, c0ScalarFlag>();
    }

    storeSensorData();
    printStatistics();

    mParameters.incrementTimeIndex();
  }// Time loop
}// end of computeMainLoop
//----------------------------------------------------------------------------------------------------------------------

/**
 * Post processing the quantities, closing the output streams and storing the sensor mask.
 */
void KSpaceFirstOrderSolver::postProcessing()
{
  if (mParameters.getStorePressureFinalAllFlag())
  {
    getRealMatrix(MI::kP).writeData(mParameters.getOutputFile(),
                                    mOutputStreamContainer.getStreamHdf5Name(OI::kFinalPressure),
                                    mParameters.getCompressionLevel());
  }// p_final

  if (mParameters.getStoreVelocityFinalAllFlag())
  {
    getRealMatrix(MI::kUxSgx).writeData(mParameters.getOutputFile(),
                                        mOutputStreamContainer.getStreamHdf5Name(OI::kFinalVelocityX),
                                        mParameters.getCompressionLevel());
    getRealMatrix(MI::kUySgy).writeData(mParameters.getOutputFile(),
                                        mOutputStreamContainer.getStreamHdf5Name(OI::kFinalVelocityY),
                                        mParameters.getCompressionLevel());
    if (mParameters.isSimulation3D())
    {
      getRealMatrix(MI::kUzSgz).writeData(mParameters.getOutputFile(),
                                          mOutputStreamContainer.getStreamHdf5Name(OI::kFinalVelocityZ),
                                          mParameters.getCompressionLevel());
    }
  }// u_final

  // Apply post-processing and close
  mOutputStreamContainer.postProcessStreams();
  mOutputStreamContainer.closeStreams();


  // Store sensor mask if wanted
  if (mParameters.getCopySensorMaskFlag())
  {
    if (mParameters.getSensorMaskType() == Parameters::SensorMaskType::kIndex)
    {
      IndexMatrix& sensorMask = getIndexMatrix(MI::kSensorMaskIndex);

      sensorMask.recomputeIndicesToMatlab();
      sensorMask.writeData(mParameters.getOutputFile(),
                           mMatrixContainer.getMatrixHdf5Name(MI::kSensorMaskIndex),
                           mParameters.getCompressionLevel());
    }

    if (mParameters.getSensorMaskType() == Parameters::SensorMaskType::kCorners)
    {
      IndexMatrix& sensorMask = getIndexMatrix(MI::kSensorMaskCorners);

      sensorMask.recomputeIndicesToMatlab();
      sensorMask.writeData(mParameters.getOutputFile(),
                           mMatrixContainer.getMatrixHdf5Name(MI::kSensorMaskCorners),
                           mParameters.getCompressionLevel());
    }
  }
}// end of postProcessing
//----------------------------------------------------------------------------------------------------------------------

/**
 * Store sensor data.
 */
void KSpaceFirstOrderSolver::storeSensorData()
{
  // Unless the time for sampling has come, exit.
  if (mParameters.getTimeIndex() >= mParameters.getSamplingStartTimeIndex())
  {
    if (mParameters.getStoreVelocityNonStaggeredRawFlag())
    {
      if (mParameters.isSimulation3D())
      {
        computeShiftedVelocity<SD::k3D>();
      }
      else
      {
        computeShiftedVelocity<SD::k2D>();
      }
    }
    mOutputStreamContainer.sampleStreams();
  }
}// end of storeSensorData
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write statistics and the header into the output file.
 */
void KSpaceFirstOrderSolver::writeOutputDataInfo()
{
  // Write timeIndex into the output file
  mParameters.getOutputFile().writeScalarValue(mParameters.getOutputFile().getRootGroup(),
                                               mParameters.getTimeIndexHdf5Name(),
                                               mParameters.getTimeIndex());

  // Write scalars
  mParameters.writeScalarsToOutputFile();
  Hdf5FileHeader& fileHeader = mParameters.getFileHeader();

  // Write File header
  fileHeader.setCodeName(getCodeName());
  fileHeader.setMajorFileVersion();
  fileHeader.setMinorFileVersion();
  fileHeader.setActualCreationTime();
  fileHeader.setFileType(Hdf5FileHeader::FileType::kOutput);
  fileHeader.setHostInfo();

  fileHeader.setMemoryConsumption(getMemoryUsage());

  // Stop total timer here
  mTotalTime.stop();
  fileHeader.setExecutionTimes(mTotalTime.getElapsedTimeOverAllLegs(),
                               mDataLoadTime.getElapsedTimeOverAllLegs(),
                               mPreProcessingTime.getElapsedTimeOverAllLegs(),
                               mSimulationTime.getElapsedTimeOverAllLegs(),
                               mPostProcessingTime.getElapsedTimeOverAllLegs());

  fileHeader.setNumberOfCores();
  fileHeader.writeHeaderToOutputFile(mParameters.getOutputFile());
}// end of writeOutputDataInfo
//----------------------------------------------------------------------------------------------------------------------

/**
 * Save checkpoint data into the checkpoint file, flush aggregated outputs into the output file.
 */
void KSpaceFirstOrderSolver::writeCheckpointData()
{
  #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))
     Logger::log(Logger::LogLevel::kFull, kOutFmtStoringFftwWisdom);
     Logger::flush(Logger::LogLevel::kFull);
    // export FFTW wisdom
     try
     {
       mParameters.exportWisdom();
       Logger::log(Logger::LogLevel::kFull, kOutFmtDone);
     }
     catch (const std::runtime_error& e)
     {
       Logger::log(Logger::LogLevel::kFull, kOutFmtFailed);
     }
  #endif

  // Create checkpoint file
  Hdf5File& checkpointFile = mParameters.getCheckpointFile();
  // If it happens and the file is opened (from the recovery, close it)
  if (checkpointFile.isOpen())
  {
    checkpointFile.close();
  }

  Logger::log(Logger::LogLevel::kFull, kOutFmtStoringCheckpointData);
  Logger::flush(Logger::LogLevel::kFull);

  // Create the new file (overwrite the old one)
  checkpointFile.create(mParameters.getCheckpointFileName());

  //------------------------------------------------ Store Matrices --------------------------------------------------//
  // Store all necessary matrices in checkpoint file
  mMatrixContainer.storeDataIntoCheckpointFile();

  // Write t_index
  checkpointFile.writeScalarValue(checkpointFile.getRootGroup(),
                                  mParameters.getTimeIndexHdf5Name(),
                                  mParameters.getTimeIndex());

  // Store basic dimension sizes (Nx, Ny, Nz) - Nt is not necessary
  checkpointFile.writeScalarValue(checkpointFile.getRootGroup(),
                                  mParameters.getNxHdf5Name(),
                                  mParameters.getFullDimensionSizes().nx);
  checkpointFile.writeScalarValue(checkpointFile.getRootGroup(),
                                  mParameters.getNyHdf5Name(),
                                  mParameters.getFullDimensionSizes().ny);
  checkpointFile.writeScalarValue(checkpointFile.getRootGroup(),
                                  mParameters.getNzHdf5Name(),
                                  mParameters.getFullDimensionSizes().nz);

  // Write checkpoint file header
  Hdf5FileHeader fileHeader = mParameters.getFileHeader();

  fileHeader.setFileType(Hdf5FileHeader::FileType::kCheckpoint);
  fileHeader.setCodeName(getCodeName());
  fileHeader.setActualCreationTime();

  fileHeader.writeHeaderToCheckpointFile(checkpointFile);

  // Close the checkpoint file
  checkpointFile.close();
  Logger::log(Logger::LogLevel::kFull, kOutFmtDone);

  // Checkpoint output streams only if necessary (t_index > start_index), we're here one step ahead!
  if (mParameters.getTimeIndex() > mParameters.getSamplingStartTimeIndex())
  {
    Logger::log(Logger::LogLevel::kFull,kOutFmtStoringSensorData);
    Logger::flush(Logger::LogLevel::kFull);

    mOutputStreamContainer.checkpointStreams();

    Logger::log(Logger::LogLevel::kFull, kOutFmtDone);
  }

  mOutputStreamContainer.closeStreams();
}// end of writeCheckpointData
//----------------------------------------------------------------------------------------------------------------------

/**
 * Print progress statistics.
 */
void KSpaceFirstOrderSolver::printStatistics()
{
  const size_t nt        = mParameters.getNt();
  const size_t timeIndex = mParameters.getTimeIndex();

  if (timeIndex > (mActPercent * nt * 0.01f))
  {
    mActPercent += mParameters.getProgressPrintInterval();

    mIterationTime.stop();

    const double elTime         = mIterationTime.getElapsedTime();
    const double elTimeWithLegs = mIterationTime.getElapsedTime() + mSimulationTime.getElapsedTimeOverPreviousLegs();
    const double toGo           = ((elTimeWithLegs / double((timeIndex + 1)) * nt)) - elTimeWithLegs;

    struct tm* current = nullptr;
    time_t now;

    time(&now);
    now += toGo;
    current = localtime(&now);

    Logger::log(Logger::LogLevel::kBasic,
                kOutFmtSimulationProgress,
                size_t(((timeIndex) / (nt * 0.01f))),'%',
                elTime, toGo,
                current->tm_mday, current->tm_mon+1, current->tm_year-100,
                current->tm_hour, current->tm_min, current->tm_sec);
    Logger::flush(Logger::LogLevel::kBasic);
  }
}// end of printStatistics
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute gradient of pressure, normal medium.
 */
template<SD simulationDimension>
void KSpaceFirstOrderSolver::computePressureGradient()
{
  const DimensionSizes& reducedDimensionSizes= mParameters.getReducedDimensionSizes();

  const float divider = 1.0f / float(mParameters.getFullDimensionSizes().nElements());

  const FloatComplex* ddxKShiftPos = getComplexData(MI::kDdxKShiftPosR);
  const FloatComplex* ddyKShiftPos = getComplexData(MI::kDdyKShiftPos);
  const FloatComplex* ddzKShiftPos = getComplexData(MI::kDdzKShiftPos, simulationDimension == SD::k3D);

  const float*  kappa = getRealData(MI::kKappa);

  FloatComplex* ifftX = getComplexData(MI::kTempFftwX);
  FloatComplex* ifftY = getComplexData(MI::kTempFftwY);
  FloatComplex* ifftZ = getComplexData(MI::kTempFftwZ, simulationDimension == SD::k3D);

  // Compute FFT of pressure
  getTempFftwX().computeR2CFftND(getRealMatrix(MI::kP));

  #pragma omp parallel for schedule(static) if (simulationDimension == SD::k3D)
  for (size_t z = 0; z < reducedDimensionSizes.nz; z++)
  {
    #pragma omp parallel for schedule(static) if (simulationDimension == SD::k2D)
    for (size_t y = 0; y < reducedDimensionSizes.ny; y++)
    {
      #pragma omp simd
      for (size_t x = 0; x < reducedDimensionSizes.nx;  x++)
      {
        const size_t i = get1DIndex(z, y, x, reducedDimensionSizes);

        const FloatComplex eKappa = ifftX[i] * kappa[i] * divider;

        ifftX[i] = eKappa * ddxKShiftPos[x];
        ifftY[i] = eKappa * ddyKShiftPos[y];
        if (simulationDimension == SD::k3D)
        {
          ifftZ[i] = eKappa * ddzKShiftPos[z];
        }
      }// x
    }// y
  }// z

  getTempFftwX().computeC2RFftND(getTemp1RealND());
  getTempFftwY().computeC2RFftND(getTemp2RealND());
  if (simulationDimension == SD::k3D)
  {
    getTempFftwZ().computeC2RFftND(getTemp3RealND());
  }
}// end of computePressureGradient
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute gradient of pressure, axisymmetric medium.
 */
void KSpaceFirstOrderSolver::computePressureGradientAS()
{
  // Shortcut for transform kind.
  using TK = FftwRealMatrix::TransformKind;

  const DimensionSizes& reducedDimensionSizes = mParameters.getReducedDimensionSizes();

  // DCT and DST of type 2,3,4 uses scaling factor 2 * Ny, the FFT adds Nx, yielding 2 * Ny * Nx
  const float divider = 1.0f / (2.0f * float(mParameters.getFullDimensionSizes().nElements()));

  const FloatComplex* ddxKShiftPos = getComplexData(MI::kDdxKShiftPosR);
  const float*        ddyKWswa     = getRealData(MI::kDdyKWswa);
  const float*        kappa        = getRealData(MI::kKappa);

  FloatComplex* ifftX = getComplexData(MI::kTempFftwX);
  FloatComplex* ifftY = getComplexData(MI::kTempFftwY);

  // p_k = fft(dtt1D(p, DCT3, 2), [], 1);
  getTemp1FftwRealND().computeForwardR2RFft1DY(TK::kDct3, getRealMatrix(MI::kP));
  getTempFftwX().computeR2CFft1DX(getTemp1FftwRealND());

  #pragma omp parallel for schedule(static)
  for (size_t y = 0; y < reducedDimensionSizes.ny; y++)
  {
   #pragma omp simd
    for (size_t x = 0; x < reducedDimensionSizes.nx; x++)
    {
      const size_t i = get1DIndex(y, x, reducedDimensionSizes);

      const FloatComplex eKappa = ifftX[i] * kappa[i] * divider;

      ifftX[i] = eKappa * ddxKShiftPos[x];
      ifftY[i] = eKappa * ddyKWswa[y];
    }// x
  }// y

  // Inverse FFT
  getTempFftwX().computeC2RFft1DX(getTemp1FftwRealND());
  getTempFftwY().computeC2RFft1DX(getTemp2FftwRealND());

  /// Inverse DCT, in-place
  getTemp1FftwRealND().computeR2RFft1DY(TK::kDct2);
  getTemp2FftwRealND().computeR2RFft1DY(TK::kDst4);

}// computePressureGradientAS
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute new values of acoustic velocity in all used dimensions (UxSgx, UySgy, UzSgz).
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag>
void KSpaceFirstOrderSolver::computeVelocity()
{
  if (mParameters.getNonUniformGridFlag())
  {
    // Not used in the code now
    computeVelocityHomogeneousNonuniform<simulationDimension>();
  }
  else
  {
    computeVelocityUniform<simulationDimension, rho0ScalarFlag>();
  }
}// end of computeVelocity
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute acoustic velocity for homogeneous medium and a uniform grid.
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag>
void KSpaceFirstOrderSolver::computeVelocityUniform()
{
  const DimensionSizes& dimensionSizes = mParameters.getFullDimensionSizes();

  const float  dtRho0SgxScalar = (rho0ScalarFlag) ? mParameters.getDtRho0SgxScalar() : 0.0f;
  const float  dtRho0SgyScalar = (rho0ScalarFlag) ? mParameters.getDtRho0SgyScalar() : 0.0f;

  const float* dtRho0SgxMatrix = (rho0ScalarFlag) ? nullptr : getRealData(MI::kDtRho0Sgx);
  const float* dtRho0SgyMatrix = (rho0ScalarFlag) ? nullptr : getRealData(MI::kDtRho0Sgy);

  const float* ifftX = getRealData(MI::kTemp1RealND);
  const float* ifftY = getRealData(MI::kTemp2RealND);

  const float* pmlX  = getRealData(MI::kPmlXSgx);
  const float* pmlY  = getRealData(MI::kPmlYSgy);

  float* uxSgx = getRealData(MI::kUxSgx);
  float* uySgy = getRealData(MI::kUySgy);

  // Long loops are replicated for every dimension to save SIMD registers
  #pragma omp parallel for schedule(static) if (simulationDimension == SD::k3D)
  for (size_t z = 0; z < dimensionSizes.nz; z++)
  {
    #pragma omp parallel for schedule(static) if (simulationDimension == SD::k2D)
    for (size_t y = 0; y < dimensionSizes.ny; y++)
    {
      #pragma omp simd
      for (size_t x = 0; x < dimensionSizes.nx; x++)
      {
        const size_t i = get1DIndex(z, y, x, dimensionSizes);
        const float dtRho0Sgx = (rho0ScalarFlag) ? dtRho0SgxScalar : dtRho0SgxMatrix[i];

        uxSgx[i] = (uxSgx[i] * pmlX[x] - dtRho0Sgx * ifftX[i]) * pmlX[x];
      }// x
    }// y
  }// z

  #pragma omp parallel for schedule(static) if (simulationDimension == SD::k3D)
  for (size_t z = 0; z < dimensionSizes.nz; z++)
  {
    #pragma omp parallel for schedule(static) if (simulationDimension == SD::k2D)
    for (size_t y = 0; y < dimensionSizes.ny; y++)
    {
      #pragma omp simd
      for (size_t x = 0; x < dimensionSizes.nx; x++)
      {
        const size_t i = get1DIndex(z, y, x, dimensionSizes);
        const float dtRho0Sgy = (rho0ScalarFlag) ? dtRho0SgyScalar : dtRho0SgyMatrix[i];

        uySgy[i] = (uySgy[i] * pmlY[y] - dtRho0Sgy * ifftY[i]) * pmlY[y];
      }// x
    }// y
  }// z

  if (simulationDimension == SD::k3D)
  {
    const float  dtRho0SgzScalar = (rho0ScalarFlag) ? mParameters.getDtRho0SgzScalar(): 0.0f;
    const float* dtRho0SgzMatrix = (rho0ScalarFlag) ? nullptr : getRealData(MI::kDtRho0Sgz);

    const float* ifftZ = getRealData(MI::kTemp3RealND);
    const float* pmlZ  = getRealData(MI::kPmlZSgz);

    float* uzSgz = getRealData(MI::kUzSgz);

    #pragma omp parallel for schedule(static)
    for (size_t z = 0; z < dimensionSizes.nz; z++)
    {
      for (size_t y = 0; y < dimensionSizes.ny; y++)
      {
        #pragma omp simd
        for (size_t x = 0; x < dimensionSizes.nx; x++)
        {
          const size_t i = get1DIndex(z, y, x, dimensionSizes);
          const float dtRho0Sgz = (rho0ScalarFlag) ? dtRho0SgzScalar : dtRho0SgzMatrix[i];

          uzSgz[i] = (uzSgz[i] * pmlZ[z] - dtRho0Sgz * ifftZ[i]) * pmlZ[z];
        }// x
      }// y
    }// z
  }// k3D
}// end of computeVelocityUniform
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute acoustic velocity for homogenous medium and nonuniform grid.
 */
template<SD simulationDimension>
void KSpaceFirstOrderSolver::computeVelocityHomogeneousNonuniform()
{
  const DimensionSizes& dimensionSizes = mParameters.getFullDimensionSizes();

  const float dtRho0Sgx  = mParameters.getDtRho0SgxScalar();
  const float dtRho0Sgy  = mParameters.getDtRho0SgyScalar();
  const float dtRho0Sgz  = (simulationDimension == SD::k3D) ? mParameters.getDtRho0SgzScalar(): 1.0f;

  const float* dxudxnSgx = getRealData(MI::kDxudxnSgx);
  const float* dyudynSgy = getRealData(MI::kDyudynSgy);
  const float* dzudznSgz = getRealData(MI::kDzudznSgz, simulationDimension == SD::k3D);

  const float* ifftX = getRealData(MI::kTemp1RealND);
  const float* ifftY = getRealData(MI::kTemp2RealND);
  const float* ifftZ = getRealData(MI::kTemp3RealND, simulationDimension == SD::k3D);

  const float* pmlX  = getRealData(MI::kPmlXSgx);
  const float* pmlY  = getRealData(MI::kPmlYSgy);
  const float* pmlZ  = getRealData(MI::kPmlZSgz, simulationDimension == SD::k3D);

  float* uxSgx = getRealData(MI::kUxSgx);
  float* uySgy = getRealData(MI::kUySgy);
  float* uzSgz = getRealData(MI::kUzSgz, simulationDimension == SD::k3D);

  // Long loops are replicated for every dimension to save SIMD registers
  #pragma omp parallel for schedule(static) if (simulationDimension == SD::k3D)
  for (size_t z = 0; z < dimensionSizes.nz; z++)
  {
    #pragma omp parallel for schedule(static) if (simulationDimension == SD::k2D)
    for (size_t y = 0; y < dimensionSizes.ny; y++)
    {
      #pragma omp simd
      for (size_t x = 0; x < dimensionSizes.nx; x++)
      {
        const size_t i = get1DIndex(z, y, x, dimensionSizes);

        uxSgx[i] = (uxSgx[i] * pmlX[x] - (dtRho0Sgx * dxudxnSgx[x] * ifftX[i])) * pmlX[x];
      }// x
    }// y
  }// z

  #pragma omp parallel for schedule(static) if (simulationDimension == SD::k3D)
  for (size_t z = 0; z < dimensionSizes.nz; z++)
  {
    #pragma omp parallel for schedule(static) if (simulationDimension == SD::k2D)
    for (size_t y = 0; y < dimensionSizes.ny; y++)
    {
      #pragma omp simd
      for (size_t x = 0; x < dimensionSizes.nx; x++)
      {
        const size_t i = get1DIndex(z, y, x, dimensionSizes);

        uySgy[i] = (uySgy[i] * pmlY[y] - (dtRho0Sgy * dyudynSgy[y] * ifftY[i])) * pmlY[y];
      }// x
    }// y
  }// z

  if (simulationDimension == SD::k3D)
  {
    #pragma omp parallel for schedule(static)
    for (size_t z = 0; z < dimensionSizes.nz; z++)
    {
      for (size_t y = 0; y < dimensionSizes.ny; y++)
      {
        #pragma omp simd
        for (size_t x = 0; x < dimensionSizes.nx; x++)
        {
          const size_t i = get1DIndex(z, y, x, dimensionSizes);

          uzSgz[i] = (uzSgz[i] * pmlZ[z] - (dtRho0Sgz * dzudznSgz[z] * ifftZ[i])) * pmlZ[z];
        }// x
      }// y
    }// z
  }// k3D
}// end of computeVelocityHomogeneousNonuniform
//----------------------------------------------------------------------------------------------------------------------

/**
 * Calculated shifted velocities.
 */
template<SD simulationDimension>
void KSpaceFirstOrderSolver::computeShiftedVelocity()
{
  // Sizes of frequency spaces
  DimensionSizes xShiftDims    = mParameters.getFullDimensionSizes();
                 xShiftDims.nx = xShiftDims.nx / 2 + 1;

  DimensionSizes yShiftDims    = mParameters.getFullDimensionSizes();
                 yShiftDims.ny = yShiftDims.ny / 2 + 1;

  // This remains 1 for 2D simulation
  DimensionSizes zShiftDims    = mParameters.getFullDimensionSizes();
                 zShiftDims.nz = (simulationDimension == SD::k3D) ? zShiftDims.nz / 2 + 1 : 1;

  // Normalization constants for FFTs
  const float dividerX = 1.0f / float(mParameters.getFullDimensionSizes().nx);
  const float dividerY = 1.0f / float(mParameters.getFullDimensionSizes().ny);
  // This remains 1 for 2D simulation
  const float dividerZ = 1.0f / float(mParameters.getFullDimensionSizes().nz);

  const FloatComplex* xShiftNegR  = getComplexData(MI::kXShiftNegR);
  const FloatComplex* yShiftNegR  = getComplexData(MI::kYShiftNegR);
  const FloatComplex* zShiftNegR  = getComplexData(MI::kZShiftNegR, simulationDimension == SD::k3D);

  FloatComplex* tempFftShift      = getComplexData(MI::kTempFftwShift);

  // ux_shifted
  getTempFftwShift().computeR2CFft1DX(getRealMatrix(MI::kUxSgx));

  #pragma omp parallel for schedule(static) if (simulationDimension == SD::k3D)
  for (size_t z = 0; z < xShiftDims.nz; z++)
  {
    #pragma omp parallel for schedule(static) if (simulationDimension == SD::k2D)
    for (size_t y = 0; y < xShiftDims.ny; y++)
    {
      #pragma omp simd
      for (size_t x = 0; x < xShiftDims.nx; x++)
      {
        const size_t i = get1DIndex(z, y, x, xShiftDims);

        tempFftShift[i] = tempFftShift[i] * xShiftNegR[x] * dividerX;
      }// x
    }// y
  }// z
  getTempFftwShift().computeC2RFft1DX(getRealMatrix(MI::kUxShifted));


  // uy shifted
  getTempFftwShift().computeR2CFft1DY(getRealMatrix(MI::kUySgy));

  #pragma omp parallel for schedule(static) if (simulationDimension == SD::k3D)
  for (size_t z = 0; z < yShiftDims.nz; z++)
  {
    #pragma omp parallel for schedule(static) if (simulationDimension == SD::k2D)
    for (size_t y = 0; y < yShiftDims.ny; y++)
    {
      #pragma omp simd
      for (size_t x = 0; x < yShiftDims.nx; x++)
      {
        const size_t i = get1DIndex(z, y, x, yShiftDims);

        tempFftShift[i] = (tempFftShift[i] * yShiftNegR[y]) * dividerY;
      }// x
    }// y
  }// z
  getTempFftwShift().computeC2RFft1DY(getRealMatrix(MI::kUyShifted));

  // uz_shifted
  if (simulationDimension == SD::k3D)
  {
    getTempFftwShift().computeR2CFft1DZ(getRealMatrix(MI::kUzSgz));

    #pragma omp parallel for schedule(static)
    for (size_t z = 0; z < zShiftDims.nz; z++)
    {
      for (size_t y = 0; y < zShiftDims.ny; y++)
      {
        #pragma omp simd
        for (size_t x = 0; x < zShiftDims.nx; x++)
        {
          const size_t i = get1DIndex(z, y, x, zShiftDims);

          tempFftShift[i] = (tempFftShift[i] * zShiftNegR[z]) * dividerZ;
        }// x
      }// y
    }// z
    getTempFftwShift().computeC2RFft1DZ(getRealMatrix(MI::kUzShifted));
  }
}// end of computeShiftedVelocity
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute new gradient of velocity (duxdx, duydy, duzdz).
 */
template<SD simulationDimension>
void KSpaceFirstOrderSolver::computeVelocityGradient()
{
  const DimensionSizes& reducedDimensionSizes = mParameters.getReducedDimensionSizes();

  const float divider = 1.0f / float(mParameters.getFullDimensionSizes().nElements());

  const FloatComplex* ddxKShiftNeg = getComplexData(MI::kDdxKShiftNegR);
  const FloatComplex* ddyKShiftNeg = getComplexData(MI::kDdyKShiftNeg);
  const FloatComplex* ddzKShiftNeg = getComplexData(MI::kDdzKShiftNeg, simulationDimension == SD::k3D);

  const float*  kappa    = getRealData(MI::kKappa);

  FloatComplex* tempFftX = getComplexData(MI::kTempFftwX);
  FloatComplex* tempFftY = getComplexData(MI::kTempFftwY);
  FloatComplex* tempFftZ = getComplexData(MI::kTempFftwZ, simulationDimension == SD::k3D);

  // Forward FFTs
  getTempFftwX().computeR2CFftND(getRealMatrix(MI::kUxSgx));
  getTempFftwY().computeR2CFftND(getRealMatrix(MI::kUySgy));
  if (simulationDimension == SD::k3D)
  {
    getTempFftwZ().computeR2CFftND(getRealMatrix(MI::kUzSgz));
  }

  // Kernels
  #pragma omp parallel for schedule(static) if (simulationDimension == SD::k3D)
  for (size_t z = 0; z < reducedDimensionSizes.nz; z++)
  {
    #pragma omp parallel for schedule(static) if (simulationDimension == SD::k2D)
    for (size_t y = 0; y < reducedDimensionSizes.ny; y++)
    {
      #pragma omp simd
      for (size_t x = 0; x < reducedDimensionSizes.nx; x++)
      {
        const size_t i = get1DIndex(z, y, x, reducedDimensionSizes);
        const float  eKappa = divider * kappa[i];

        tempFftX[i] *=  ddxKShiftNeg[x] * eKappa;
        tempFftY[i] *=  ddyKShiftNeg[y] * eKappa;
        if (simulationDimension == SD::k3D)
        {
          tempFftZ[i] *=  ddzKShiftNeg[z] * eKappa;
        }
      }// x
    }// y
  }// z

  // Inverse FFTs
  getTempFftwX().computeC2RFftND(getRealMatrix(MI::kDuxdx));
  getTempFftwY().computeC2RFftND(getRealMatrix(MI::kDuydy));
  if (simulationDimension == SD::k3D)
  {
    getTempFftwZ().computeC2RFftND(getRealMatrix(MI::kDuzdz));
  }

  //------------------------------------------------ Nonuniform grid -------------------------------------------------//
  if (mParameters.getNonUniformGridFlag() != 0)
  {
    const DimensionSizes& dimensionSizes = mParameters.getFullDimensionSizes();

    const float* duxdxn = getRealData(MI::kDxudxn);
    const float* duydyn = getRealData(MI::kDyudyn);
    const float* duzdzn = getRealData(MI::kDzudzn, simulationDimension == SD::k3D);

    float* duxdx = getRealData(MI::kDuxdx);
    float* duydy = getRealData(MI::kDuydy);
    float* duzdz = getRealData(MI::kDuzdz, simulationDimension == SD::k3D);

    #pragma omp parallel for schedule(static) if (simulationDimension == SD::k3D)
    for (size_t z = 0; z < dimensionSizes.nz; z++)
    {
      #pragma omp parallel for schedule(static) if (simulationDimension == SD::k2D)
      for (size_t y = 0; y < dimensionSizes.ny; y++)
      {
        #pragma omp simd
        for (size_t x = 0; x < dimensionSizes.nx; x++)
        {
          const size_t i = get1DIndex(z, y, x, dimensionSizes);

          duxdx[i] *= duxdxn[x];
          duydy[i] *= duydyn[y];
          if (simulationDimension == SD::k3D)
          {
            duzdz[i] *= duzdzn[z];
          }
        }// x
      }// y
    }// z
 }// nonlinear
}// end of computeVelocityGradient
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute new values for duxdx, duydy, duzdz, axisymmetric code, WSWA symmetry.
 */
void  KSpaceFirstOrderSolver::computeVelocityGradientAS()
{
  // Shortcut for transform kind.
  using TK = FftwRealMatrix::TransformKind;

  const DimensionSizes& dimensionSizes        = mParameters.getFullDimensionSizes();
  const DimensionSizes& reducedDimensionSizes = mParameters.getReducedDimensionSizes();

  const float divider = 1.0f / (2.0f * float(dimensionSizes.nElements()));

  const FloatComplex* ddxKShiftNeg = getComplexData(MI::kDdxKShiftNegR);

  const float*  kappa    = getRealData(MI::kKappa);
  const float*  uySgy    = getRealData(MI::kUySgy);
  const float*  yVecSg   = getRealData(MI::kYVecSg);
  const float*  ddyKHahs = getRealData(MI::kDdyKHahs);

  FloatComplex* tempFftX = getComplexData(MI::kTempFftwX);
  FloatComplex* tempFftY = getComplexData(MI::kTempFftwY);

  //------------------------------------------------------------------------------------------------------------------//
  //duxdx = dtt1D(real(ifft(
  //                        kappa .* bsxfun(@times, ddx_k_shift_neg,
  //                        fft(dtt1D(ux_sgx, DCT3, 2), [], 1)) ..., [], 1)), DCT2, 2) ./ M;

  getTemp1FftwRealND().computeForwardR2RFft1DY(TK::kDct3, getRealMatrix(MI::kUxSgx));
  getTempFftwX().computeR2CFft1DX(getTemp1FftwRealND());

  #pragma omp parallel for schedule(static)
  for (size_t y = 0; y < reducedDimensionSizes.ny; y++)
  {
    #pragma omp simd
    for (size_t x = 0; x < reducedDimensionSizes.nx; x++)
    {
      const size_t i = get1DIndex(y, x, reducedDimensionSizes);

      tempFftX[i] *= ddxKShiftNeg[x] * divider * kappa[i];
    }// x
  }// y

  getTempFftwX().computeC2RFft1DX(getTemp1FftwRealND());
  getTemp1FftwRealND().computeInverseR2RFft1DY(TK::kDct2, getRealMatrix(MI::kDuxdx));

  //------------------------------------------------------------------------------------------------------------------//
  // duydy = dtt1D(real(ifft(kappa .* (...
  //                      bsxfun(@times, ddy_k_hahs, fft(dtt1D(uy_sgy, DST4, 2), [], 1)) + ...
  //                      fft(dtt1D(bsxfun(@times, 1./y_vec_sg, uy_sgy), DCT4, 2), [], 1) ...
  //                      ), [], 1)), DCT2, 2) ./ M;

  // fft(dtt1D(uy_sgy, DST4, 2), [], 1))
  getTemp1FftwRealND().computeForwardR2RFft1DY(TK::kDst4, getRealMatrix(MI::kUySgy));
  getTempFftwX().computeR2CFft1DX(getTemp1FftwRealND());


  // fft(dtt1D(bsxfun(@times, 1./y_vec_sg, uy_sgy), DCT4, 2), [], 1)
  float* uyDivYVec = getRealData(MI::kTemp2RealND);

  #pragma omp parallel for schedule(static)
  for (size_t y = 0; y < dimensionSizes.ny; y++)
  {
    #pragma omp simd
    for (size_t x = 0; x < dimensionSizes.nx; x++)
    {
      const size_t i = get1DIndex(y, x, dimensionSizes);
      // yVecSg holds the inverse value
      uyDivYVec[i] = uySgy[i] * yVecSg[y];
    }// x
  }// y

  // temp2FftwReal is the same as uyDivYVec
  getTemp2FftwRealND().computeR2RFft1DY(TK::kDct4);
  getTempFftwY().computeR2CFft1DX(getTemp2FftwRealND());

  // tempFftwX() = kappa .* (bsxfun(@times, ddy_k_hahs, tempFftwX()) + tempFftwY())
  #pragma omp parallel for schedule(static)
  for (size_t y = 0; y < reducedDimensionSizes.ny; y++)
  {
    #pragma omp simd
    for (size_t x = 0; x < reducedDimensionSizes.nx; x++)
    {
      const size_t i = get1DIndex(y, x, reducedDimensionSizes);

      tempFftX[i] =  divider * kappa[i] * (ddyKHahs[y] * tempFftX[i] + tempFftY[i]);
    }// x
  }// y

  getTempFftwX().computeC2RFft1DX(getTemp1FftwRealND());
  getTemp1FftwRealND().computeInverseR2RFft1DY(TK::kDct2, getRealMatrix(MI::kDuydy));

  //------------------------------------------------- Non linear grid ------------------------------------------------//
  if (mParameters.getNonUniformGridFlag() != 0)
  {
    const float* duxdxn = getRealData(MI::kDxudxn);
    const float* duydyn = getRealData(MI::kDyudyn);

    float* duxdx = getRealData(MI::kDuxdx);
    float* duydy = getRealData(MI::kDuydy);

    #pragma omp parallel for schedule(static)
    for (size_t y = 0; y < dimensionSizes.ny; y++)
    {
      #pragma omp simd
      for (size_t x = 0; x < dimensionSizes.nx; x++)
      {
        const size_t i = get1DIndex(y, x, dimensionSizes);
        duxdx[i] *= duxdxn[x];
        duydy[i] *= duydyn[y];
      }// x
    }// y
  }// nonlinear
}// end of computeVelocityGradientAS
//----------------------------------------------------------------------------------------------------------------------

/**
 * Calculate new values of acoustic density for nonlinear case (rhoX, rhoy and rhoZ).
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag>
void KSpaceFirstOrderSolver::computeDensityNonliner()
{
  const DimensionSizes& dimensionSizes = mParameters.getFullDimensionSizes();

  const float dt  = mParameters.getDt();

  const float* pmlX  = getRealData(MI::kPmlX);
  const float* pmlY  = getRealData(MI::kPmlY);
  const float* pmlZ  = getRealData(MI::kPmlZ, simulationDimension == SD::k3D);

  const float* duxdx = getRealData(MI::kDuxdx);
  const float* duydy = getRealData(MI::kDuydy);
  const float* duzdz = getRealData(MI::kDuzdz, simulationDimension == SD::k3D);

  const float  rho0Scalar = (rho0ScalarFlag) ? mParameters.getRho0Scalar() : 0.0f;
  const float* rho0Matrix = (rho0ScalarFlag) ? nullptr : getRealData(MI::kRho0);

  float* rhoX  = getRealData(MI::kRhoX);
  float* rhoY  = getRealData(MI::kRhoY);
  float* rhoZ  = getRealData(MI::kRhoZ, simulationDimension == SD::k3D);

  #pragma omp parallel for schedule(static) if (simulationDimension == SD::k3D)
  for (size_t z = 0; z < dimensionSizes.nz; z++)
  {
    #pragma omp parallel for schedule(static) if (simulationDimension == SD::k2D)
    for (size_t y = 0; y < dimensionSizes.ny; y++)
    {
      #pragma omp simd
      for (size_t x = 0; x < dimensionSizes.nx; x++)
      {
        const size_t i = get1DIndex(z, y, x, dimensionSizes);

        const float rho0      = (rho0ScalarFlag) ? rho0Scalar : rho0Matrix[i];
        // 3D and 2D summation
        const float sumRhos   = (simulationDimension == SD::k3D) ? (rhoX[i] + rhoY[i] + rhoZ[i])
                                                                 : (rhoX[i] + rhoY[i]);
        const float sumRhosDt = (2.0f * sumRhos + rho0) * dt;

        rhoX[i] = pmlX[x] * ((pmlX[x] * rhoX[i]) - sumRhosDt * duxdx[i]);
        rhoY[i] = pmlY[y] * ((pmlY[y] * rhoY[i]) - sumRhosDt * duydy[i]);
        if (simulationDimension == SD::k3D)
        {
          rhoZ[i] = pmlZ[z] * ((pmlZ[z] * rhoZ[i]) - sumRhosDt * duzdz[i]);
        }
      }// x
    }// y
  }// z
}// end of computeDensityNonliner
//----------------------------------------------------------------------------------------------------------------------

/**
 * Calculate new values of acoustic density for linear case (rhoX, rhoy and rhoZ).
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag>
void KSpaceFirstOrderSolver::computeDensityLinear()
{
  const DimensionSizes& dimensionSizes = mParameters.getFullDimensionSizes();

  const float dt = mParameters.getDt();

  const float* pmlX  = getRealData(MI::kPmlX);
  const float* pmlY  = getRealData(MI::kPmlY);
  const float* pmlZ  = getRealData(MI::kPmlZ, simulationDimension == SD::k3D);

  const float* duxdx = getRealData(MI::kDuxdx);
  const float* duydy = getRealData(MI::kDuydy);
  const float* duzdz = getRealData(MI::kDuzdz, simulationDimension == SD::k3D);

  const float  dtRho0Scalar = (rho0ScalarFlag) ? dt * mParameters.getRho0Scalar() : 0.0f;
  const float* rho0Matrix   = (rho0ScalarFlag) ? nullptr : getRealData(MI::kRho0);

  float* rhoX  = getRealData(MI::kRhoX);
  float* rhoY  = getRealData(MI::kRhoY);
  float* rhoZ  = getRealData(MI::kRhoZ, simulationDimension == SD::k3D);

  #pragma omp parallel for schedule(static) if (simulationDimension == SD::k3D)
  for (size_t z = 0; z < dimensionSizes.nz; z++)
  {
    #pragma omp parallel for schedule(static) if (simulationDimension == SD::k2D)
    for (size_t y = 0; y < dimensionSizes.ny; y++)
    {
      #pragma omp simd
      for (size_t x = 0; x < dimensionSizes.nx; x++)
      {
        const size_t i     = get1DIndex(z, y, x, dimensionSizes);

        const float dtRho0 = (rho0ScalarFlag) ? dtRho0Scalar : dt * rho0Matrix[i];

        rhoX[i] = pmlX[x] * (((pmlX[x] * rhoX[i]) - (dtRho0 * duxdx[i])));
        rhoY[i] = pmlY[y] * (((pmlY[y] * rhoY[i]) - (dtRho0 * duydy[i])));
        if (simulationDimension == SD::k3D)
        {
          rhoZ[i] = pmlZ[z] * (((pmlZ[z] * rhoZ[i]) - (dtRho0 * duzdz[i])));
        }
      }// x
    }// y
  }// z
}// end of computeDensityLinear
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute acoustic pressure for normal medium.
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag,
         bool bOnAScalarFlag,
         bool c0ScalarFlag,
         bool alphaCoefScalarFlag>
void KSpaceFirstOrderSolver::computePressure()
{
  if (mParameters.getNonLinearFlag())
  { // Nonlinear propagation
    switch (mParameters.getAbsorbingFlag())
    {
      case Parameters::AbsorptionType::kLossless:
      {
        sumPressureTermsNonlinearLossless<simulationDimension, rho0ScalarFlag, bOnAScalarFlag, c0ScalarFlag>();
        break;
      }
      case Parameters::AbsorptionType::kPowerLaw:
      {
        computePressureNonlinearPowerLaw<simulationDimension,
                                         rho0ScalarFlag,
                                         bOnAScalarFlag,
                                         c0ScalarFlag,
                                         alphaCoefScalarFlag>();
        break;
      }
      case Parameters::AbsorptionType::kStokes:
      {
        sumPressureTermsNonlinearStokes<simulationDimension,
                                        rho0ScalarFlag,
                                        bOnAScalarFlag,
                                        c0ScalarFlag,
                                        alphaCoefScalarFlag>();
        break;
      }
    }
  }
  else
  { // Linear propagation
    switch (mParameters.getAbsorbingFlag())
    {
      case Parameters::AbsorptionType::kLossless:
      {
        sumPressureTermsLinearLossless<simulationDimension, c0ScalarFlag>();
        break;
      }
      case Parameters::AbsorptionType::kPowerLaw:
      {
        computePressureLinearPowerLaw<simulationDimension, rho0ScalarFlag, c0ScalarFlag, alphaCoefScalarFlag>();
        break;
      }
      case Parameters::AbsorptionType::kStokes:
      {
        sumPressureTermsLinearStokes<simulationDimension, rho0ScalarFlag, c0ScalarFlag, alphaCoefScalarFlag>();
        break;
      }
    }
  }
}// end of computePressure
//----------------------------------------------------------------------------------------------------------------------

/**
 * Sum sub-terms to calculate new pressure in nonlinear lossless case.
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag,
         bool bOnAScalarFlag,
         bool c0ScalarFlag>
void KSpaceFirstOrderSolver::sumPressureTermsNonlinearLossless()
{
  const size_t nElements = mParameters.getFullDimensionSizes().nElements();

  const float* rhoX = getRealData(MI::kRhoX);
  const float* rhoY = getRealData(MI::kRhoY);
  const float* rhoZ = getRealData(MI::kRhoZ, simulationDimension == SD::k3D);

  const float  c2Scalar   = (c0ScalarFlag) ? mParameters.getC2Scalar() : 0.0f;
  const float* c2Matrix   = (c0ScalarFlag) ? nullptr : getRealData(MI::kC2);

  const float  bOnAScalar = (bOnAScalarFlag) ? mParameters.getBOnAScalar(): 0.0f;
  const float* bOnAMatrix = (bOnAScalarFlag) ? nullptr : getRealData(MI::kBOnA);

  const float  rho0Scalar = (rho0ScalarFlag) ? mParameters.getRho0Scalar() : 0.0f;
  const float* rho0Matrix = (rho0ScalarFlag) ? nullptr : getRealData(MI::kRho0);

  float* p = getRealData(MI::kP);

  #pragma omp parallel for simd schedule(simd:static) \
          aligned(rhoX, rhoY, rhoZ, c2Matrix, bOnAMatrix, rho0Matrix, p : kDataAlignment)
  for (size_t i = 0; i < nElements; i++)
  {
    const float c2   = (c0ScalarFlag)   ? c2Scalar   : c2Matrix[i];
    const float bOnA = (bOnAScalarFlag) ? bOnAScalar : bOnAMatrix[i];
    const float rho0 = (rho0ScalarFlag) ? rho0Scalar : rho0Matrix[i];

    const float sumDensity = (simulationDimension == SD::k3D) ? (rhoX[i] + rhoY[i] + rhoZ[i]) : (rhoX[i] + rhoY[i]);

    p[i] = c2 * (sumDensity + (bOnA * (sumDensity * sumDensity) / (2.0f * rho0)));
  }
}// end of sumPressureTermsNonlinearLossless
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute acoustic pressure for non-linear power law absorbing case.
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag,
         bool bOnAScalarFlag,
         bool c0ScalarFlag,
         bool alphaCoefScalarFlag>
void KSpaceFirstOrderSolver::computePressureNonlinearPowerLaw()
{
  RealMatrix& densitySum         = getTemp1RealND();
  RealMatrix& nonlinearTerm      = getTemp2RealND();
  RealMatrix& velocitGradientSum = getTemp3RealND();

  // Reusing the temp variables
  RealMatrix& absorbTauTerm = velocitGradientSum;
  RealMatrix& absorbEtaTerm = densitySum;

  // Compute nonlinear pressure term
  computePressureTermsNonlinearPowerLaw<simulationDimension, rho0ScalarFlag, bOnAScalarFlag>
                                       (densitySum, nonlinearTerm, velocitGradientSum);

  // ifftn(absorb_nabla1 * fftn (rho0 * (duxdx+duydy+duzdz))
  getTempFftwX().computeR2CFftND(velocitGradientSum);
  getTempFftwY().computeR2CFftND(densitySum);

  computePowerLawAbsorbtionTerm(getTempFftwX(), getTempFftwY());

  getTempFftwX().computeC2RFftND(absorbTauTerm);
  getTempFftwY().computeC2RFftND(absorbEtaTerm);

  sumPressureTermsNonlinearPowerLaw<c0ScalarFlag, alphaCoefScalarFlag>(absorbTauTerm, absorbEtaTerm, nonlinearTerm);
}// end of computePressureNonlinearPowerLaw
//----------------------------------------------------------------------------------------------------------------------

/**
 * Sum sub-terms to calculate new pressure with stokes absorption in nonlinear case.
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag,
         bool bOnAScalarFlag,
         bool c0ScalarFlag,
         bool absorbTauScalarFlag>
void KSpaceFirstOrderSolver::sumPressureTermsNonlinearStokes()
{
  const size_t nElements = mParameters.getFullDimensionSizes().nElements();

  const float* rhoX  = getRealData(MI::kRhoX);
  const float* rhoY  = getRealData(MI::kRhoY);
  const float* rhoZ  = getRealData(MI::kRhoZ, simulationDimension == SD::k3D);

  const float* duxdx = getRealData(MI::kDuxdx);
  const float* duydy = getRealData(MI::kDuydy);
  const float* duzdz = getRealData(MI::kDuzdz, simulationDimension == SD::k3D);

  const float  c2Scalar        = (c0ScalarFlag)        ? mParameters.getC2Scalar() : 0.0f;
  const float* c2Matrix        = (c0ScalarFlag)        ? nullptr : getRealData(MI::kC2);

  const float  rho0Scalar      = (rho0ScalarFlag)      ? mParameters.getRho0Scalar() : 0.0f;
  const float* rho0Matrix      = (rho0ScalarFlag)      ? nullptr : getRealData(MI::kRho0);

  const float  bOnAScalar      = (bOnAScalarFlag)      ? mParameters.getBOnAScalar() : 0.0f;
  const float* bOnAMatrix      = (bOnAScalarFlag)      ? nullptr : getRealData(MI::kBOnA);

  const float  absorbTauScalar = (absorbTauScalarFlag) ? mParameters.getAbsorbTauScalar() : 0.0f;
  const float* absorbTauMatrix = (absorbTauScalarFlag) ? nullptr : getRealData(MI::kAbsorbTau);

  float* p = getRealData(MI::kP);

  #pragma omp parallel for simd schedule(simd:static) \
          aligned(rhoX, rhoY, rhoZ, duxdx, duydy, duzdz, \
                  c2Matrix, rho0Matrix, bOnAMatrix, absorbTauMatrix, p : kDataAlignment)
  for (size_t i = 0; i < nElements; i++)
  {
    const float c2        = (c0ScalarFlag)        ? c2Scalar        : c2Matrix[i];
    const float rho0      = (rho0ScalarFlag)      ? rho0Scalar      : rho0Matrix[i];
    const float bOnA      = (bOnAScalarFlag)      ? bOnAScalar      : bOnAMatrix[i];
    const float absorbTau = (absorbTauScalarFlag) ? absorbTauScalar : absorbTauMatrix[i];

    const float rhoSum = (simulationDimension == SD::k3D) ? rhoX[i]  + rhoY[i]  + rhoZ[i]  : rhoX[i]  + rhoY[i];
    const float duSum  = (simulationDimension == SD::k3D) ? duxdx[i] + duydy[i] + duzdz[i] : duxdx[i] + duydy[i];

    p[i] = c2 * (rhoSum + absorbTau * rho0 * duSum + ((bOnA * rhoSum * rhoSum) / (2.0f * rho0)));
  }
}// end of sumPressureTermsNonlinearStokes
//----------------------------------------------------------------------------------------------------------------------

/**
 * Sum sub-terms to calculate new pressure in linear lossless case.
 */
template<SD   simulationDimension,
         bool c0ScalarFlag>
void KSpaceFirstOrderSolver::sumPressureTermsLinearLossless()
{
  const size_t nElements = mParameters.getFullDimensionSizes().nElements();

  const float* rhoX = getRealData(MI::kRhoX);
  const float* rhoY = getRealData(MI::kRhoY);
  const float* rhoZ = getRealData(MI::kRhoZ, simulationDimension == SD::k3D);

  const float  c2Scalar = (c0ScalarFlag) ? mParameters.getC2Scalar() : 0.0f;
  const float* c2Matrix = (c0ScalarFlag) ? nullptr : getRealData(MI::kC2);

  float* p  = getRealData(MI::kP);

  #pragma omp parallel for simd schedule(simd:static) aligned(rhoX, rhoY, rhoZ, c2Matrix, p : kDataAlignment)
  for (size_t i = 0; i < nElements; i++)
  {
    const float c2      = (c0ScalarFlag) ?  c2Scalar : c2Matrix[i];

    const float sumRhos = (simulationDimension == SD::k3D) ? (rhoX[i] + rhoY[i] + rhoZ[i]) : (rhoX[i] + rhoY[i]);

    p[i] = c2 * sumRhos;
  }
}// end of sumPressureTermsLinearLossless
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute new p for linear power law absorbing case, normal medium.
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag,
         bool c0ScalarFlag,
         bool alphaCoefScalarFlag>
void KSpaceFirstOrderSolver::computePressureLinearPowerLaw()
{
  RealMatrix& densitySum           = getTemp1RealND();
  RealMatrix& velocityGradientTerm = getTemp2RealND();

  RealMatrix& absorbTauTerm        = getTemp2RealND();
  RealMatrix& absorbEtaTerm        = getTemp3RealND();

  computePressureTermsLinearPowerLaw<simulationDimension, rho0ScalarFlag>(densitySum, velocityGradientTerm);

  // ifftn ( absorb_nabla1 * fftn (rho0 * (duxdx+duydy+duzdz))

  getTempFftwX().computeR2CFftND(velocityGradientTerm);
  getTempFftwY().computeR2CFftND(densitySum);

  computePowerLawAbsorbtionTerm(getTempFftwX(), getTempFftwY());

  getTempFftwX().computeC2RFftND(absorbTauTerm);
  getTempFftwY().computeC2RFftND(absorbEtaTerm);

  sumPressureTermsLinear<c0ScalarFlag, alphaCoefScalarFlag>(absorbTauTerm, absorbEtaTerm, densitySum);
}// end of computePressureLinearPowerLaw
//----------------------------------------------------------------------------------------------------------------------

/**
 * Sum sub-terms to calculate new pressure with stokes absorption in linear case.
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag,
         bool c0ScalarFlag,
         bool absorbTauScalarFlag>
void KSpaceFirstOrderSolver::sumPressureTermsLinearStokes()
{
  const size_t nElements = mParameters.getFullDimensionSizes().nElements();

  const float* rhoX  = getRealData(MI::kRhoX);
  const float* rhoY  = getRealData(MI::kRhoY);
  const float* rhoZ  = getRealData(MI::kRhoZ, simulationDimension == SD::k3D);

  const float* duxdx = getRealData(MI::kDuxdx);
  const float* duydy = getRealData(MI::kDuydy);
  const float* duzdz = getRealData(MI::kDuzdz, simulationDimension == SD::k3D);

  const float  c2Scalar        = (c0ScalarFlag)        ? mParameters.getC2Scalar() : 0.0f;
  const float* c2Matrix        = (c0ScalarFlag)        ? nullptr : getRealData(MI::kC2);

  const float  rho0Scalar      = (rho0ScalarFlag)      ? mParameters.getRho0Scalar() : 0.0f;
  const float* rho0Matrix      = (rho0ScalarFlag)      ? nullptr : getRealData(MI::kRho0);

  const float  absorbTauScalar = (absorbTauScalarFlag) ? mParameters.getAbsorbTauScalar() : 0.0f;
  const float* absorbTauMatrix = (absorbTauScalarFlag) ? nullptr : getRealData(MI::kAbsorbTau);

  float* p = getRealData(MI::kP);

  #pragma omp parallel for simd schedule(simd:static) \
          aligned(rhoX, rhoY, rhoZ, duxdx, duydy, duzdz, c2Matrix, rho0Matrix, absorbTauMatrix, p : kDataAlignment)
  for (size_t i = 0; i < nElements; i++)
  {
    const float c2        = (c0ScalarFlag)        ? c2Scalar        : c2Matrix[i];
    const float rho0      = (rho0ScalarFlag)      ? rho0Scalar      : rho0Matrix[i];
    const float absorbTau = (absorbTauScalarFlag) ? absorbTauScalar : absorbTauMatrix[i];

    const float rhoSum = (simulationDimension == SD::k3D) ? rhoX[i]  + rhoY[i]  + rhoZ[i]  : rhoX[i]  + rhoY[i];
    const float duSum  = (simulationDimension == SD::k3D) ? duxdx[i] + duydy[i] + duzdz[i] : duxdx[i] + duydy[i];

    p[i] = c2 * (rhoSum + absorbTau * rho0 * duSum);
  }
}// end of sumPressureTermsLinearStokes
//----------------------------------------------------------------------------------------------------------------------

/**
 * Calculate three temporary sums in the new pressure formula for non-linear power law absorbing case.
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag,
         bool bOnAScalarFlag>
void KSpaceFirstOrderSolver::computePressureTermsNonlinearPowerLaw(RealMatrix& densitySum,
                                                                   RealMatrix& nonlinearTerm,
                                                                   RealMatrix& velocityGradientSum)
{
  const size_t nElements = mParameters.getFullDimensionSizes().nElements();

  const float* rhoX = getRealData(MI::kRhoX);
  const float* rhoY = getRealData(MI::kRhoY);
  const float* rhoZ = getRealData(MI::kRhoZ, simulationDimension == SD::k3D);

  const float* duxdx = getRealData(MI::kDuxdx);
  const float* duydy = getRealData(MI::kDuydy);
  const float* duzdz = getRealData(MI::kDuzdz, simulationDimension == SD::k3D);

  const float  bOnAScalar     = (bOnAScalarFlag) ? mParameters.getBOnAScalar() : 0.0f;
  const float* bOnAMatrix     = (bOnAScalarFlag) ? nullptr : getRealData(MI::kBOnA);

  const float  rho0Scalar     = (rho0ScalarFlag) ? mParameters.getRho0Scalar() : 0.0f;
  const float* rho0Matrix     = (rho0ScalarFlag) ? nullptr : getRealData(MI::kRho0);

  // Pointer to raw data of the output matrices
  float* pDensitySum          = densitySum.getData();
  float* pNonlinearTerm       = nonlinearTerm.getData();
  float* pVelocityGradientSum = velocityGradientSum.getData();

  #pragma omp parallel for simd schedule(simd:static) \
          aligned(rhoX, rhoY, rhoZ, duxdx, duydy, duzdz, bOnAMatrix, rho0Matrix, \
                  pDensitySum, pNonlinearTerm, pVelocityGradientSum : kDataAlignment)
  for (size_t i = 0; i < nElements ; i++)
  {
    const float rhoSum = (simulationDimension == SD::k3D) ? (rhoX[i]  + rhoY[i]  + rhoZ[i])  : (rhoX[i]  + rhoY[i]);
    const float duSum  = (simulationDimension == SD::k3D) ? (duxdx[i] + duydy[i] + duzdz[i]) : (duxdx[i] + duydy[i]);

    const float bOnA   = (bOnAScalarFlag) ? bOnAScalar : bOnAMatrix[i];
    const float rho0   = (rho0ScalarFlag) ? rho0Scalar : rho0Matrix[i];

    pDensitySum[i]          = rhoSum;
    pNonlinearTerm[i]       = (bOnA * rhoSum * rhoSum) / (2.0f * rho0) + rhoSum;
    pVelocityGradientSum[i] = rho0 * duSum;
  }
}// end of computePressureTermsNonlinearPowerLaw
//----------------------------------------------------------------------------------------------------------------------

/**
 * Calculate two temporary sums in the new pressure formula, linear absorbing case.
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag>
void KSpaceFirstOrderSolver::computePressureTermsLinearPowerLaw(RealMatrix& densitySum,
                                                                RealMatrix& velocityGradientSum)
{
  const size_t size = mParameters.getFullDimensionSizes().nElements();

  const float* rhoX = getRealData(MI::kRhoX);
  const float* rhoY = getRealData(MI::kRhoY);
  const float* rhoZ = getRealData(MI::kRhoZ, simulationDimension == SD::k3D);

  const float* duxdx = getRealData(MI::kDuxdx);
  const float* duydy = getRealData(MI::kDuydy);
  const float* duzdz = getRealData(MI::kDuzdz, simulationDimension == SD::k3D);

  const float  rho0Scalar = (rho0ScalarFlag) ? mParameters.getRho0Scalar() : 0.0f;
  const float* rho0Matrix = (rho0ScalarFlag) ? nullptr : getRealData(MI::kRho0);

  float* pDensitySum          = densitySum.getData();
  float* pVelocityGradientSum = velocityGradientSum.getData();

  #pragma omp parallel for simd schedule(simd:static) aligned(rhoX, rhoY, rhoZ,pDensitySum : kDataAlignment)
  for (size_t i = 0; i < size; i++)
  {
    pDensitySum[i] = (simulationDimension == SD::k3D) ? (rhoX[i] + rhoY[i] + rhoZ[i]) : (rhoX[i] + rhoY[i]);
  }

  #pragma omp parallel for simd schedule(simd:static) \
          aligned (duxdx, duydy, duzdz, rho0Matrix, pVelocityGradientSum : kDataAlignment)
  for (size_t i = 0; i < size; i++)
  {
    const float rho0  = (rho0ScalarFlag) ? rho0Scalar : rho0Matrix[i];
    const float duSum = (simulationDimension == SD::k3D) ? (duxdx[i] + duydy[i] + duzdz[i]) : (duxdx[i] + duydy[i]);

    pVelocityGradientSum[i] = rho0 * duSum;
  }
}// end of computePressureTermsLinearPowerLaw
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute absorbing term with abosrbNabla1 and absorbNabla2.
 */
void KSpaceFirstOrderSolver::computePowerLawAbsorbtionTerm(FftwComplexMatrix& fftPart1,
                                                           FftwComplexMatrix& fftPart2)
{
  const size_t nElements    = mParameters.getReducedDimensionSizes().nElements();

  const float* absorbNabla1 = getRealData(MI::kAbsorbNabla1);
  const float* absorbNabla2 = getRealData(MI::kAbsorbNabla2);

  FloatComplex* pFftPart1 = fftPart1.getComplexData();
  FloatComplex* pFftPart2 = fftPart2.getComplexData();

  #pragma omp parallel for simd schedule(simd:static) \
          aligned(absorbNabla1, absorbNabla2, pFftPart1, pFftPart2 : kDataAlignment)
  for (size_t i = 0; i < nElements; i++)
  {
    pFftPart1[i] *= absorbNabla1[i];
    pFftPart2[i] *= absorbNabla2[i];
  }
}// end of computePowerLawAbsorbtionTerm
//----------------------------------------------------------------------------------------------------------------------

/**
 * Sum sub-terms after FFTs to calculate new pressure in the non-linear power law absorption case.
 */
template<bool c0ScalarFlag,
         bool tauAndEtaScalarFlag>
void KSpaceFirstOrderSolver::sumPressureTermsNonlinearPowerLaw(const RealMatrix& absorbTauTerm,
                                                               const RealMatrix& absorbEtaTerm,
                                                               const RealMatrix& nonlinearTerm)
{
  const size_t nElements = mParameters.getFullDimensionSizes().nElements();
  const float  divider   = 1.0f / float(nElements);

  const float  c2Scalar  = (c0ScalarFlag) ? mParameters.getC2Scalar() : 0.0f;
  const float* c2Matrix  = (c0ScalarFlag) ? nullptr : getRealData(MI::kC2);

  const float  absorbTauScalar = (tauAndEtaScalarFlag) ? mParameters.getAbsorbTauScalar() : 0.0f;
  const float* absorbTauMatrix = (tauAndEtaScalarFlag) ? nullptr : getRealData(MI::kAbsorbTau);

  const float  absorbEtaScalar = (tauAndEtaScalarFlag) ? mParameters.getAbsorbEtaScalar() : 0.0f;
  const float* absorbEtaMatrix = (tauAndEtaScalarFlag) ? nullptr : getRealData(MI::kAbsorbEta);

  const float* pAbsorbTauTerm  = absorbTauTerm.getData();
  const float* pAbsorbEtaTerm  = absorbEtaTerm.getData();
  const float* bOnA            = nonlinearTerm.getData();

  float* p = getRealData(MI::kP);

  #pragma omp parallel for simd schedule(simd:static) \
          aligned(c2Matrix, absorbTauMatrix, absorbEtaMatrix, pAbsorbTauTerm, pAbsorbEtaTerm, bOnA, p : kDataAlignment)
  for (size_t i = 0; i < nElements; i++)
  {
    const float c2        = (c0ScalarFlag) ?        c2Scalar        : c2Matrix[i];
    const float absorbTau = (tauAndEtaScalarFlag) ? absorbTauScalar : absorbTauMatrix[i];
    const float absorbEta = (tauAndEtaScalarFlag) ? absorbEtaScalar : absorbEtaMatrix[i];

    p[i] = c2 * (bOnA[i] + (divider * ((pAbsorbTauTerm[i] * absorbTau) - (pAbsorbEtaTerm[i] * absorbEta))));
  }
}// end of sumPressureTermsNonlinearPowerLaw
//----------------------------------------------------------------------------------------------------------------------

/**
 * Sum sub-terms after FFTs to calculate new pressure in linear case.
 */
template<bool c0ScalarFlag,
         bool tauAndEtaScalarFlag>
void KSpaceFirstOrderSolver::sumPressureTermsLinear(const RealMatrix& absorbTauTerm,
                                                    const RealMatrix& absorbEtaTerm,
                                                    const RealMatrix& densitySum)
{
  const size_t nElements = mParameters.getFullDimensionSizes().nElements();
  const float  divider = 1.0f / float(nElements);

  const float  c2Scalar = (c0ScalarFlag) ? mParameters.getC2Scalar() : 0.0f;
  const float* c2Matrix = (c0ScalarFlag) ? nullptr : getRealData(MI::kC2);

  const float  absorbTauScalar = (tauAndEtaScalarFlag) ? mParameters.getAbsorbTauScalar() : 0.0f;
  const float* absorbTauMatrix = (tauAndEtaScalarFlag) ? nullptr : getRealData(MI::kAbsorbTau);

  const float  absorbEtaScalar = (tauAndEtaScalarFlag) ? mParameters.getAbsorbEtaScalar() : 0.0f;
  const float* absorbEtaMatrix = (tauAndEtaScalarFlag) ? nullptr : getRealData(MI::kAbsorbEta);

  const float* pAbsorbTauTerm  = absorbTauTerm.getData();
  const float* pAbsorbEtaTerm  = absorbEtaTerm.getData();
  const float* pDenistySum     = densitySum.getData();

  float* p = getRealData(MI::kP);

  #pragma omp parallel for simd schedule(simd:static) \
          aligned(c2Matrix, absorbTauMatrix, absorbEtaMatrix, \
                  pAbsorbTauTerm, pAbsorbEtaTerm, pDenistySum, p : kDataAlignment)
  for (size_t i = 0; i < nElements; i++)
  {
    const float c2        = (c0ScalarFlag) ?        c2Scalar        : c2Matrix[i];
    const float absorbTau = (tauAndEtaScalarFlag) ? absorbTauScalar : absorbTauMatrix[i];
    const float absorbEta = (tauAndEtaScalarFlag) ? absorbEtaScalar : absorbEtaMatrix[i];

    p[i] = c2 * (pDenistySum[i] + (divider * ((pAbsorbTauTerm[i] * absorbTau) - (pAbsorbEtaTerm[i] * absorbEta))));
  }
}// end of sumPressureTermsLinear
//----------------------------------------------------------------------------------------------------------------------

/**
 * Add in pressure source.
 */
template<SD simulationDimension>
void KSpaceFirstOrderSolver::addPressureSource()
{
  const size_t timeIndex = mParameters.getTimeIndex();

  if (mParameters.getPressureSourceFlag() > timeIndex)
  {
    const bool   isManyFlag  = (mParameters.getPressureSourceMany() != 0);
    const size_t sourceSize  = getIndexMatrix(MI::kPressureSourceIndex).size();
    const size_t index2D     = (isManyFlag) ? timeIndex * sourceSize : timeIndex;

    const float*  sourceInput = getRealData(MI::kPressureSourceInput);
    const size_t* sourceIndex = getIndexData(MI::kPressureSourceIndex);

    float* rhox = getRealData(MI::kRhoX);
    float* rhoy = getRealData(MI::kRhoY);
    float* rhoz = getRealData(MI::kRhoZ, simulationDimension == SD::k3D);

    // Different pressure sources
    switch (mParameters.getPressureSourceMode())
    {
      case Parameters::SourceMode::kDirichlet:
      {
        #pragma omp parallel for schedule(static) if (sourceSize > 16384)
        for (size_t i = 0; i < sourceSize; i++)
        {
          const size_t signalIndex = (isManyFlag) ? index2D + i : index2D;

          rhox[sourceIndex[i]] = sourceInput[signalIndex];
          rhoy[sourceIndex[i]] = sourceInput[signalIndex];
          if (simulationDimension == SD::k3D)
          {
            rhoz[sourceIndex[i]] = sourceInput[signalIndex];
          }
        }
        break;
      }

      case Parameters::SourceMode::kAdditiveNoCorrection:
      {
        #pragma omp parallel for schedule(static) if (sourceSize > 16384)
        for (size_t i = 0; i < sourceSize; i++)
        {
          const size_t signalIndex = (isManyFlag) ? index2D + i : index2D;

          rhox[sourceIndex[i]] += sourceInput[signalIndex];
          rhoy[sourceIndex[i]] += sourceInput[signalIndex];
          if (simulationDimension == SD::k3D)
          {
            rhoz[sourceIndex[i]] += sourceInput[signalIndex];
          }
        }
        break;
      }

      case Parameters::SourceMode::kAdditive:
      { // temp matrix for additive source
        // Shortcut for transform kind.
        using TK = FftwRealMatrix::TransformKind;

        RealMatrix&        scaledSource = getTemp1RealND();
        FftwComplexMatrix& fftMatrix    = getTempFftwX();

        const size_t  nElementsFull    = mParameters.getFullDimensionSizes().nElements();
        const size_t  nElementsReduced = mParameters.getReducedDimensionSizes().nElements();
        const float   divider          = (mParameters.isSimulationAS()) ? 1.0f / float(nElementsFull * 2)
                                                                        : 1.0f / float(nElementsFull);

        float*        pScaledSource = getRealData(MI::kTemp1RealND);
        float*        pSourceKappa  = getRealData(MI::kSourceKappa);
        FloatComplex* pFftMatrix    = getComplexData(MI::kTempFftwX);

        // Clear scaledSource the matrix
        scaledSource.zeroMatrix();

        // source_mat(p_source_pos_index) = source.p(p_source_sig_index, t_index);
        #pragma omp parallel for schedule(static)
        for (size_t i = 0; i < sourceSize; i++)
        {
          const size_t signalIndex = (isManyFlag) ? index2D + i : index2D;

          pScaledSource[sourceIndex[i]] = sourceInput[signalIndex];
        }

        // Forward transform
        if (mParameters.isSimulationAS())
        { // Axisymmetric medium, WSWA symmetry: fft(dtt1D(source_mat, DCT3, 2), [], 1)
          // This holds pScaledSource
          getTemp1FftwRealND().computeR2RFft1DY(TK::kDct3);
          fftMatrix.computeR2CFft1DX(getTemp1FftwRealND());
        }
        else
        { // Normal medium: fftn(source_mat)
          fftMatrix.computeR2CFftND(scaledSource);
        }

        // Scaling in Fourier space
        #pragma omp parallel for simd schedule(simd:static)
        for (size_t i = 0; i < nElementsReduced ; i++)
        {
          pFftMatrix[i] *= divider * pSourceKappa[i];
        }

        // Inverse transform
        if (mParameters.isSimulationAS())
        { // Axisymmetric medium, WSWA symmetry: dtt1D(real(ifft(source_mat), [], 1)), DCT2, 2)
          // This holds pScaledSource
          fftMatrix.computeC2RFft1DX(getTemp1FftwRealND());
          getTemp1FftwRealND().computeR2RFft1DY(TK::kDct2);
        }
        else
        { // Normal medium: ifftn(source_mat)
          fftMatrix.computeC2RFftND(scaledSource);
        }

        // Add the source values to the existing field values
        #pragma omp parallel for simd schedule(simd: static)
        for (size_t i = 0; i < nElementsFull; i++)
        {
          rhox[i] += pScaledSource[i];
          rhoy[i] += pScaledSource[i];
          if (simulationDimension == SD::k3D)
          {
            rhoz[i] += pScaledSource[i];
          }
        }
        break;
      }

      default:
      {
        break;
      }
    }// switch
  }// if do at all
}// end of addPressureSource
//----------------------------------------------------------------------------------------------------------------------

/**
 * Add transducer data source to velocity x component.
 */
void KSpaceFirstOrderSolver::addTransducerSource()
{
  const size_t timeIndex  = mParameters.getTimeIndex();
  const size_t sourceSize = getIndexMatrix(MI::kVelocitySourceIndex).size();

  const size_t* velocitySourceIndex   = getIndexData(MI::kVelocitySourceIndex);
  const size_t* delayMask             = getIndexData(MI::kDelayMask);
  const float*  transducerSourceInput = getRealData(MI::kTransducerSourceInput);

  float* uxSgx = getRealData(MI::kUxSgx);

  #pragma omp parallel for schedule(static) if (sourceSize > 16384)
  for (size_t i = 0; i < sourceSize; i++)
  {
    uxSgx[velocitySourceIndex[i]] += transducerSourceInput[delayMask[i] + timeIndex];
  }
}// end of addTransducerSource
//----------------------------------------------------------------------------------------------------------------------

/**
 * Add u source to the particle velocity.
 */
void KSpaceFirstOrderSolver::addVelocitySource()
{
  const size_t timeIndex = mParameters.getTimeIndex();

  if (mParameters.getVelocityXSourceFlag() > timeIndex)
  {
    computeVelocitySourceTerm(getRealMatrix(MI::kUxSgx),
                              getRealMatrix(MI::kVelocityXSourceInput),
                              getIndexMatrix(MI::kVelocitySourceIndex));
  }

  if (mParameters.getVelocityYSourceFlag() > timeIndex)
  {
    computeVelocitySourceTerm(getRealMatrix(MI::kUySgy),
                              getRealMatrix(MI::kVelocityYSourceInput),
                              getIndexMatrix(MI::kVelocitySourceIndex));
  }

  if (mParameters.isSimulation3D())
  {
    if (mParameters.getVelocityZSourceFlag() > timeIndex)
    {
      computeVelocitySourceTerm(getRealMatrix(MI::kUzSgz),
                                getRealMatrix(MI::kVelocityZSourceInput),
                                getIndexMatrix(MI::kVelocitySourceIndex));
    }
  }
}// end of addVelocitySource
//----------------------------------------------------------------------------------------------------------------------

/**
 * Add in velocity source terms.
 */
void KSpaceFirstOrderSolver::computeVelocitySourceTerm(RealMatrix&        velocityMatrix,
                                                       const RealMatrix&  velocitySourceInput,
                                                       const IndexMatrix& velocitySourceIndex)
{
  // Shortcut for transform kind.
  using TK = FftwRealMatrix::TransformKind;

  const size_t timeIndex  = mParameters.getTimeIndex();

  const bool   isManyFlag = (mParameters.getVelocitySourceMany() != 0);
  const size_t sourceSize = velocitySourceIndex.size();
  const size_t index2D    = (isManyFlag) ? timeIndex * sourceSize : timeIndex;

  const float*  sourceInput = velocitySourceInput.getData();
  const size_t* sourceIndex = velocitySourceIndex.getData();

  float* pVelocityMatrix = velocityMatrix.getData();

  switch (mParameters.getVelocitySourceMode())
  {
    case Parameters::SourceMode::kDirichlet:
    {
      #pragma omp parallel for schedule(static) if (sourceSize > 16384)
      for (size_t i = 0; i < sourceSize; i++)
      {
        const size_t signalIndex = (isManyFlag) ? index2D + i : index2D;

        pVelocityMatrix[sourceIndex[i]] = sourceInput[signalIndex];
      }
      break;
    }

    case Parameters::SourceMode::kAdditiveNoCorrection:
    {
      #pragma omp parallel for schedule(static) if (sourceSize > 16384)
      for (size_t i = 0; i < sourceSize; i++)
      {
        const size_t signalIndex = (isManyFlag) ? index2D + i : index2D;

        pVelocityMatrix[sourceIndex[i]] += sourceInput[signalIndex];
      }
      break;
    }

    case Parameters::SourceMode::kAdditive:
    {
      // Temp matrix for additive source
      RealMatrix&        scaledSource = getTemp1RealND();
      FftwComplexMatrix& fftMatrix    = getTempFftwX();

      const size_t  nElementsFull    = mParameters.getFullDimensionSizes().nElements();
      const size_t  nElementsReduced = mParameters.getReducedDimensionSizes().nElements();
      const float   divider          = (mParameters.isSimulationAS()) ? 1.0f / float(nElementsFull * 2)
                                                                      : 1.0f / float(nElementsFull);
      float*        pScaledSource = getRealData(MI::kTemp1RealND);
      float*        pSourceKappa  = getRealData(MI::kSourceKappa);
      FloatComplex* pFftMatrix    = getComplexData(MI::kTempFftwX);

      // Clear scaledSource the matrix
      scaledSource.zeroMatrix();

      // source_mat(u_source_pos_index) = source.u(u_source_sig_index, t_index);
      #pragma omp parallel for schedule(static)
      for (size_t i = 0; i < sourceSize; i++)
      {
        const size_t signalIndex = (isManyFlag) ? index2D + i : index2D;

        pScaledSource[sourceIndex[i]] = sourceInput[signalIndex];
      }

      // Forward transform
      if (mParameters.isSimulationAS())
      { // Axisymmetric medium, WSWA symmetry: fft(dtt1D(source_mat, DCT3, 2), [], 1) for x-source
        //                                     fft(dtt1D(source_mat, DST4, 2), [], 1) for y-source
        // temp1 matrix holds pScaledSource
        if (&velocityMatrix == &getRealMatrix(MI::kUxSgx))
        { // x-source
          getTemp1FftwRealND().computeR2RFft1DY(TK::kDct3);
        }
        if (&velocityMatrix == &getRealMatrix(MI::kUySgy))
        { // y - source
          getTemp1FftwRealND().computeR2RFft1DY(TK::kDst4);
        }

        fftMatrix.computeR2CFft1DX(getTemp1FftwRealND());
      }
      else
      { // Normal medium: fftn(source_mat)
        fftMatrix.computeR2CFftND(scaledSource);
      }

      #pragma omp parallel for simd schedule(simd:static)
      for (size_t i = 0; i < nElementsReduced; i++)
      {
        pFftMatrix[i] *= divider * pSourceKappa[i];
      }

      // Inverse transform
      if (mParameters.isSimulationAS())
      { // Axisymmetric medium, WSWA symmetry: dtt1D(real(ifft(source_mat), [], 1)), DCT2, 2) for x-source
        //                                     dtt1D(real(ifft(source_mat), [], 1)), DST4, 2) for y-source
        fftMatrix.computeC2RFft1DX(getTemp1FftwRealND());

        if (&velocityMatrix == &getRealMatrix(MI::kUxSgx))
        {  // x-source
          getTemp1FftwRealND().computeR2RFft1DY(TK::kDct2);
        }
        if (&velocityMatrix == &getRealMatrix(MI::kUySgy))
        {  // y-source
          getTemp1FftwRealND().computeR2RFft1DY(TK::kDst4);
        }
      }
      else
      { // Normal medium: ifftn(source_mat)
      fftMatrix.computeC2RFftND(scaledSource);
      }

      // Add the source values to the existing field values
      #pragma omp parallel for simd schedule(simd:static)
      for (size_t i = 0; i < nElementsFull; i++)
      {
        pVelocityMatrix[i] += pScaledSource[i];
      }

      break;
    }

    default:
    {
      break;
    }
  }// end of switch
}// end of computeVelocitySourceTerm
//----------------------------------------------------------------------------------------------------------------------

/**
 * Calculate p0 source when necessary.
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag,
         bool c0ScalarFlag>
void KSpaceFirstOrderSolver::addInitialPressureSource()
{
  const size_t nElements        = mParameters.getFullDimensionSizes().nElements();
  const float  dimScalingFactor = (simulationDimension == SD::k3D) ? 3.0f : 2.0f;

  const float* sourceInput = getRealData(MI::kInitialPressureSourceInput);

  const float  c2Scalar    = (c0ScalarFlag) ? mParameters.getC2Scalar() : 0.0f;
  const float* c2Matrix    = (c0ScalarFlag) ? nullptr : getRealData(MI::kC2);

  float* rhoX = getRealData(MI::kRhoX);
  float* rhoY = getRealData(MI::kRhoY);
  float* rhoZ = getRealData(MI::kRhoZ, simulationDimension == SD::k3D);

  getRealMatrix(MI::kP).copyData(getRealMatrix(MI::kInitialPressureSourceInput));

  #pragma omp parallel for simd schedule(simd:static)
  for (size_t i = 0; i < nElements; i++)
  {
    const float tmp = sourceInput[i] / (dimScalingFactor * ((c0ScalarFlag) ? c2Scalar : c2Matrix[i]));

    rhoX[i] = tmp;
    rhoY[i] = tmp;
    if (simulationDimension == SD::k3D)
    {
      rhoZ[i] = tmp;
    }
  }

  // Compute pressure gradient
  if (mParameters.isSimulationAS())
  { // Axisymmetric medium
    computePressureGradientAS();
  }
  else
  {
    computePressureGradient<simulationDimension>();
  }

  // Compute initial velocity
  if (mParameters.getNonUniformGridFlag())
  { // Non-uniform grid, homogeneous case,
    computeInitialVelocityHomogeneousNonuniform<simulationDimension>();
  }
  else
  {
    computeInitialVelocityUniform<simulationDimension, rho0ScalarFlag>();
  }
}// end of addInitialPressureSource
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute acoustic velocity for initial pressure problem.
 */
template<SD   simulationDimension,
         bool rho0ScalarFlag>
void KSpaceFirstOrderSolver::computeInitialVelocityUniform()
{
  const size_t nElements = mParameters.getFullDimensionSizes().nElements();

  const float  dtRho0SgxScalar = (rho0ScalarFlag) ? 0.5f * mParameters.getDtRho0SgxScalar() : 0.0f;
  const float  dtRho0SgyScalar = (rho0ScalarFlag) ? 0.5f * mParameters.getDtRho0SgyScalar() : 0.0f;

  const float* dtRho0SgxMatrix = (rho0ScalarFlag) ? nullptr : getRealData(MI::kDtRho0Sgx);
  const float* dtRho0SgyMatrix = (rho0ScalarFlag) ? nullptr : getRealData(MI::kDtRho0Sgy);

  const float* dpdxSgx = getRealData(MI::kTemp1RealND);
  const float* dpdySgy = getRealData(MI::kTemp2RealND);

  float* uxSgx = getRealData(MI::kUxSgx);
  float* uySgy = getRealData(MI::kUySgy);

  // x and y dimensions
  #pragma omp parallel for simd schedule(simd:static) \
          aligned(dtRho0SgxMatrix, dtRho0SgyMatrix, dpdxSgx, dpdySgy, uxSgx, uySgy : kDataAlignment)
  for (size_t i = 0; i < nElements; i++)
  {
    const float dtRho0Sgx = (rho0ScalarFlag) ? dtRho0SgxScalar : 0.5f * dtRho0SgxMatrix[i];
    const float dtRho0Sgy = (rho0ScalarFlag) ? dtRho0SgyScalar : 0.5f * dtRho0SgyMatrix[i];

    uxSgx[i] = dpdxSgx[i] * dtRho0Sgx;
    uySgy[i] = dpdySgy[i] * dtRho0Sgy;
  }

  // z dimension if needed
  if (simulationDimension == SD::k3D)
  {
    const float  dtRho0SgzScalar = (rho0ScalarFlag) ? 0.5f * mParameters.getDtRho0SgzScalar() : 0.0f;
    const float* dtRho0SgzMatrix = (rho0ScalarFlag) ? nullptr : getRealData(MI::kDtRho0Sgz);

    const float* dpdzSgz = getRealData(MI::kTemp3RealND);

    float* uzSgz = getRealData(MI::kUzSgz);

    #pragma omp parallel for simd schedule(simd:static) aligned(dtRho0SgzMatrix, dpdzSgz, uzSgz : kDataAlignment)
    for (size_t i = 0; i < nElements; i++)
    {
      const float dtRho0Sgz = (rho0ScalarFlag) ? dtRho0SgzScalar : 0.5f * dtRho0SgzMatrix[i];

      uzSgz[i] = dpdzSgz[i] * dtRho0Sgz;
    }
  }// z
}// end of computeInitialVelocityUniform
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute acoustic velocity for initial pressure problem, homogenous medium, nonuniform grid.
 */
template<SD simulationDimension>
void KSpaceFirstOrderSolver::computeInitialVelocityHomogeneousNonuniform()
{
  const DimensionSizes& dimensionSizes = mParameters.getFullDimensionSizes();

  const float dtRho0Sgx  = 0.5f * mParameters.getDtRho0SgxScalar();
  const float dtRho0Sgy  = 0.5f * mParameters.getDtRho0SgyScalar();
  const float dtRho0Sgz  = (simulationDimension == SD::k3D) ? 0.5f * mParameters.getDtRho0SgzScalar() : 0.0f;

  const float* dxudxnSgx = getRealData(MI::kDxudxnSgx);
  const float* dyudynSgy = getRealData(MI::kDyudynSgy);
  const float* dzudznSgz = getRealData(MI::kDzudznSgz, simulationDimension == SD::k3D);

  const float* dpdxSgx   = getRealData(MI::kTemp1RealND);
  const float* dpdySgy   = getRealData(MI::kTemp2RealND);
  const float* dpdzSgz   = getRealData(MI::kTemp3RealND, simulationDimension == SD::k3D);

  float* uxSgx = getRealData(MI::kUxSgx);
  float* uySgy = getRealData(MI::kUySgy);
  float* uzSgz = getRealData(MI::kUzSgz, simulationDimension == SD::k3D);

  #pragma omp parallel for schedule(static) if (simulationDimension == SD::k3D)
  for (size_t z = 0; z < dimensionSizes.nz; z++)
  {
    #pragma omp parallel for schedule(static) if (simulationDimension == SD::k2D)
    for (size_t y = 0; y < dimensionSizes.ny; y++)
    {
      #pragma omp simd
      for (size_t x = 0; x < dimensionSizes.nx; x++)
      {
        const size_t i = get1DIndex(z, y, x, dimensionSizes);

        uxSgx[i] = dpdxSgx[i] * dtRho0Sgx * dxudxnSgx[x];
        uySgy[i] = dpdySgy[i] * dtRho0Sgy * dyudynSgy[y];
        if ((simulationDimension == SD::k3D))
        {
          uzSgz[i] = dpdzSgz[i] * dtRho0Sgz * dzudznSgz[z];
        }
      }// x
    }// y
  }// z
}// end of computeInitialVelocityHomogeneousNonuniform
//----------------------------------------------------------------------------------------------------------------------

/**
 * Prepare dt./ rho0  for non-uniform grid.
 */
template<SD simulationDimension>
void KSpaceFirstOrderSolver::generateInitialDenisty()
{
  const DimensionSizes& dimensionSizes = mParameters.getFullDimensionSizes();

  const float dt = mParameters.getDt();

  const float* duxdxnSgx = getRealData(MI::kDxudxnSgx);
  const float* duydynSgy = getRealData(MI::kDyudynSgy);
  const float* duzdznSgz = getRealData(MI::kDzudznSgz, simulationDimension == SD::k3D);

  float* dtRho0Sgx = getRealData(MI::kDtRho0Sgx);
  float* dtRho0Sgy = getRealData(MI::kDtRho0Sgy);
  float* dtRho0Sgz = getRealData(MI::kDtRho0Sgz, simulationDimension == SD::k3D);

  #pragma omp parallel for schedule(static) if (simulationDimension == SD::k3D)
  for (size_t z = 0; z < dimensionSizes.nz; z++)
  {
    #pragma omp parallel for schedule(static) if (simulationDimension == SD::k2D)
    for (size_t y = 0; y < dimensionSizes.ny; y++)
    {
      #pragma omp simd
      for (size_t x = 0; x < dimensionSizes.nx; x++)
      {
        const size_t i = get1DIndex(z, y, x, dimensionSizes);

        dtRho0Sgx[i] = (dt * duxdxnSgx[x]) / dtRho0Sgx[i];
        dtRho0Sgy[i] = (dt * duydynSgy[y]) / dtRho0Sgy[i];
        if (simulationDimension == SD::k3D)
        {
          dtRho0Sgz[i] = (dt * duzdznSgz[z]) / dtRho0Sgz[i];
        }
      }// x
    }// y
  }// z
}// end of generateInitialDenisty
//----------------------------------------------------------------------------------------------------------------------

/**
 * Generate kappa matrix for lossless medium.
 * For 2D simulation, the zPart == 0.
 */
void KSpaceFirstOrderSolver::generateKappa()
{
  const DimensionSizes& reducedDimensionSizes = mParameters.getReducedDimensionSizes();

  const float dx2Rec = 1.0f / (mParameters.getDx() * mParameters.getDx());
  const float dy2Rec = 1.0f / (mParameters.getDy() * mParameters.getDy());
  // For 2D simulation set dz to 0
  const float dz2Rec = (mParameters.isSimulation3D()) ? 1.0f / (mParameters.getDz() * mParameters.getDz()) : 0.0f;

  const float cRefDtPi = mParameters.getCRef() * mParameters.getDt() * float(M_PI);

  const float nxRec = 1.0f / float(mParameters.getFullDimensionSizes().nx);
  const float nyRec = 1.0f / float(mParameters.getFullDimensionSizes().ny);
  // For 2D simulation, nzRec remains 1
  const float nzRec = 1.0f / float(mParameters.getFullDimensionSizes().nz);

  float* kappa = getRealData(MI::kKappa);

  // Generate wave number in given direction
  auto kPart = [](float i, float sizeRec, float dispRec)
  {
    float k = 0.5f - fabs(0.5f - i * sizeRec);
    return (k * k) * dispRec;
  };// end of kPart

  #pragma omp parallel for schedule(static) if (mParameters.isSimulation3D())
  for (size_t z = 0; z < reducedDimensionSizes.nz; z++)
  {
    const float kz = kPart(float(z), nzRec, dz2Rec);

    #pragma omp parallel for schedule(static) if (mParameters.isSimulation2D())
    for (size_t y = 0; y < reducedDimensionSizes.ny; y++)
    {
      const float ky = kPart(float(y), nyRec, dy2Rec);

      #pragma omp simd
      for (size_t x = 0; x < reducedDimensionSizes.nx; x++)
      {
        const size_t i = get1DIndex(z, y, x, reducedDimensionSizes);

        const float kx = kPart(float(x), nxRec, dx2Rec);
        const float k  = cRefDtPi * sqrt(kx + ky + kz);

        // kappa element
        kappa[i] = (k == 0.0f) ? 1.0f : sin(k) / k;
      }// x
    }// y
  }// z
}// end of generateKappa
//----------------------------------------------------------------------------------------------------------------------

/**
 * Generate kappa matrix for axisymmetric media.
 */
void KSpaceFirstOrderSolver::generateKappaAS()
{
  const DimensionSizes& reducedDimensionSizes = mParameters.getReducedDimensionSizes();

  const float cRefDt = mParameters.getCRef() * mParameters.getDt() * 0.5f;

  const float nxRec  = 1.0f / float(mParameters.getFullDimensionSizes().nx);
  // Condensed version of 1/ (nx * 2 * pi)
  const float pi2Dx  = 2.0f * float(M_PI) / (mParameters.getDx());
  // Condensed version of (2 * pi) / (2 * dy * nx)
  const float piDyM  = float(M_PI) / (mParameters.getDy() * float(mParameters.getFullDimensionSizes().ny));

  float* kappa = getRealData(MI::kKappa);

  #pragma omp parallel for schedule(static)
  for (size_t y = 0; y < reducedDimensionSizes.ny; y++)
  {
    const float ky = (float(y) + 0.5f) * piDyM;

    #pragma omp simd
    for (size_t x = 0; x < reducedDimensionSizes.nx; x++)
    {
      const size_t i = get1DIndex(y, x, reducedDimensionSizes);

      const float kx = (0.5f - fabs(0.5f - float(x) * nxRec)) * pi2Dx;
      const float k  = cRefDt * sqrt(ky * ky + kx * kx);

      // kappa element
      kappa[i] = (k == 0.0f) ? 1.0f : sin(k) / k;
    }// x
  }// y
}// end of generateKappaAS
//----------------------------------------------------------------------------------------------------------------------

/**
 * Generate derivative operators for normal medium (dd{x,y,z}_k_shift_pos, dd{x,y,z}_k_shift_neg)
 */
void KSpaceFirstOrderSolver::generateDerivativeOperators()
{
  const DimensionSizes& reducedDimensionSizes = mParameters.getReducedDimensionSizes();
  const DimensionSizes& dimensionSizes        = mParameters.getFullDimensionSizes();

  constexpr FloatComplex imagUnit = FloatComplex(0, 1);
  constexpr FloatComplex posExp   = FloatComplex(0, 1);
  constexpr FloatComplex negExp   = FloatComplex(0,-1);
  constexpr float        pi2      = 2.0f * float(M_PI);

  const float dx = mParameters.getDx();
  const float dy = mParameters.getDy();
  const float dz = (mParameters.isSimulation3D()) ? mParameters.getDz() : 0.0f;

  FloatComplex* ddxKShiftPos = getComplexData(MI::kDdxKShiftPosR);
  FloatComplex* ddyKShiftPos = getComplexData(MI::kDdyKShiftPos);
  FloatComplex* ddzKShiftPos = getComplexData(MI::kDdzKShiftPos, mParameters.isSimulation3D());

  FloatComplex* ddxKShiftNeg = getComplexData(MI::kDdxKShiftNegR);
  FloatComplex* ddyKShiftNeg = getComplexData(MI::kDdyKShiftNeg);
  FloatComplex* ddzKShiftNeg = getComplexData(MI::kDdzKShiftNeg, mParameters.isSimulation3D());

  // Calculate ifft shift
  auto iFftShift = [](ptrdiff_t i, ptrdiff_t size)
  {
    return (i + (size / 2)) % size - (size / 2);
  };// end of iFftShift

  // Calculation done sequentially because the size of the arrays are small < 512
  // Moreover, there's a bug in Intel compiler under windows generating clobbered data.
  // ddxKShiftPos, ddxKShiftPos
  for (size_t i = 0; i < reducedDimensionSizes.nx; i++)
  {
    const ptrdiff_t shift    = iFftShift(i, dimensionSizes.nx);
    const float     kx       = (pi2 / dx) * (float(shift) / float(dimensionSizes.nx));
    const float     exponent = kx * dx * 0.5f;

    ddxKShiftPos[i] = imagUnit * kx * std::exp(posExp * exponent);
    ddxKShiftNeg[i] = imagUnit * kx * std::exp(negExp * exponent);
  }

  // ddyKShiftPos, ddyKShiftPos
  for (size_t i = 0; i < dimensionSizes.ny; i++)
  {
    const ptrdiff_t shift    = iFftShift(i, dimensionSizes.ny);
    const float     ky       = (pi2 / dy) * (float(shift) / float(dimensionSizes.ny));
    const float     exponent = ky * dy * 0.5f;

    ddyKShiftPos[i] = imagUnit * ky * std::exp(posExp * exponent);
    ddyKShiftNeg[i] = imagUnit * ky * std::exp(negExp * exponent);
  }

  // ddzKShiftPos, ddzKShiftNeg
  if (mParameters.isSimulation3D())
  {
    for (size_t i = 0; i < dimensionSizes.nz; i++)
    {
      const ptrdiff_t shift    = iFftShift(i, dimensionSizes.nz);
      const float     kz       = (pi2 / dz) * (float(shift) / float(dimensionSizes.nz));
      const float     exponent = kz * dz * 0.5f;

      ddzKShiftPos[i] = imagUnit * kz * std::exp(posExp * exponent);
      ddzKShiftNeg[i] = imagUnit * kz * std::exp(negExp * exponent);
    }
  }
}// end of generateDerivativeOperators
//----------------------------------------------------------------------------------------------------------------------

/**
 * Generate derivative operators for normal medium (dd{x,y,z}_k_shift_pos, dd{x,y,z}_k_shift_neg)
 */
void KSpaceFirstOrderSolver::generateDerivativeOperatorsAS()
{
  const DimensionSizes&  reducedDimensionSizes = mParameters.getReducedDimensionSizes();
  const DimensionSizes&  dimensionSizes        = mParameters.getFullDimensionSizes();

  constexpr FloatComplex imagUnit = FloatComplex(0, 1);
  constexpr FloatComplex posExp   = FloatComplex(0, 1);
  constexpr FloatComplex negExp   = FloatComplex(0,-1);
  constexpr float        pi2      = 2.0f * float(M_PI);

  const float dx     = mParameters.getDx();
  const float dy     = mParameters.getDy();
  // Condensed version of 2 * pi / (2 * dy * ny)
  const float dyMRec = float(M_PI) / (dy * float(dimensionSizes.ny));

  FloatComplex* ddxKShiftPos = getComplexData(MI::kDdxKShiftPosR);
  FloatComplex* ddxKShiftNeg = getComplexData(MI::kDdxKShiftNegR);

  float* ddyKHahs = getRealData(MI::kDdyKHahs);
  float* ddyKWswa = getRealData(MI::kDdyKWswa);
  float* yVecSg   = getRealData(MI::kYVecSg);

  // Calculate ifft shift
  auto iFftShift = [](ptrdiff_t i, ptrdiff_t size)
  {
    return (i + (size / 2)) % size - (size / 2);
  };// end of iFftShift

  // Calculation done sequentially because the size of the arrays are small < 512
  // Moreover, there's a bug in Intel compiler under windows generating clobbered data.
  // ddxKShiftPos. ddxKShiftPos
  for (size_t i = 0; i < reducedDimensionSizes.nx; i++)
  {
    const ptrdiff_t shift    = iFftShift(i, dimensionSizes.nx);
    const float     kx       = (pi2 / dx) * (float(shift) / float(dimensionSizes.nx));

    const float     exponent = kx * dx * 0.5f;

    ddxKShiftPos[i] = imagUnit * kx * std::exp(posExp * exponent);
    ddxKShiftNeg[i] = imagUnit * kx * std::exp(negExp * exponent);
  }

  // Calculate ddyKHahs, ddyKWswa, yVecSg
  for (size_t y = 0; y < reducedDimensionSizes.ny; y++)
  {
    const float ky = (float(y) + 0.5f) * dyMRec;

    ddyKHahs[y] =  ky;
    ddyKWswa[y] = -ky;
    yVecSg[y]   = 1.0f / ((float(y) + 0.5f) * dy);
  }
}// end of generateDerivativeOperatorsAS
//----------------------------------------------------------------------------------------------------------------------

/**
 * Generate sourceKappa matrix for additive sources.
 * For 2D simulation, the zPart == 0.
 */
void KSpaceFirstOrderSolver::generateSourceKappa()
{
  const DimensionSizes& reducedDimensionSizes = mParameters.getReducedDimensionSizes();

  const float dx2Rec = 1.0f / (mParameters.getDx() * mParameters.getDx());
  const float dy2Rec = 1.0f / (mParameters.getDy() * mParameters.getDy());
  const float dz2Rec = (mParameters.isSimulation3D()) ? 1.0f / (mParameters.getDz() * mParameters.getDz()) : 0.0f;

  const float cRefDtPi = mParameters.getCRef() * mParameters.getDt() * float(M_PI);

  const float nxRec = 1.0f / float(mParameters.getFullDimensionSizes().nx);
  const float nyRec = 1.0f / float(mParameters.getFullDimensionSizes().ny);
  const float nzRec = 1.0f / float(mParameters.getFullDimensionSizes().nz);

  float* sourceKappa = getRealData(MI::kSourceKappa);

  // Generate wave number in a given direction
  auto kPart = [](float i, float sizeRec, float dispRec)
  {
    float k = 0.5f - fabs(0.5f - i * sizeRec);
    return (k * k) * dispRec;
  };// end of kPart

  #pragma omp parallel for schedule(static) if (mParameters.isSimulation3D())
  for (size_t z = 0; z < reducedDimensionSizes.nz; z++)
  {
    const float kz = kPart(float(z), nzRec, dz2Rec);

    #pragma omp parallel for schedule(static) if (mParameters.isSimulation2D())
    for (size_t y = 0; y < reducedDimensionSizes.ny; y++)
    {
      const float ky = kPart(float(y), nyRec, dy2Rec);

      #pragma omp simd
      for (size_t x = 0; x < reducedDimensionSizes.nx; x++)
      {
        const size_t i = get1DIndex(z, y, x, reducedDimensionSizes);

        const float kx = kPart(float(x), nxRec, dx2Rec);

        // sourceKappa element
        sourceKappa[i] = cos(cRefDtPi * sqrt(kx + ky + kz));
      }// x
    }// y
  }// z
}// end of generateSourceKappa
//----------------------------------------------------------------------------------------------------------------------

/**
 * Generate sourceKappa matrix for additive sources, axisymmetric code.
 */
void KSpaceFirstOrderSolver::generateSourceKappaAS()
{
  const DimensionSizes& reducedDimensionSizes = mParameters.getReducedDimensionSizes();

  const float cRefDt = mParameters.getCRef() * mParameters.getDt() * 0.5f;

  const float nxRec  = 1.0f / float(mParameters.getFullDimensionSizes().nx);
  // Condensed version of 1/ (nx * 2 * pi)
  const float pi2Dx  = 2.0f * float(M_PI) / (mParameters.getDx());
  // Condensed version of (2 * pi) / (2 * dy * nx)
  const float piDyM  = float(M_PI) / (mParameters.getDy() * float(mParameters.getFullDimensionSizes().ny));

  float* sourceKappa = getRealData(MI::kSourceKappa);

  #pragma omp parallel for schedule(static)
  for (size_t y = 0; y < reducedDimensionSizes.ny; y++)
  {
    const float ky  = (float(y) + 0.5f) * piDyM;

    #pragma omp simd
    for (size_t x = 0; x < reducedDimensionSizes.nx; x++)
    {
      const size_t i = get1DIndex(y, x, reducedDimensionSizes);

      const float kx = (0.5f - fabs(0.5f - float(x) * nxRec)) * pi2Dx;
      const float k  = cRefDt * sqrt(ky * ky + kx * kx);

      // sourceKappa element
      sourceKappa[i] = cos(k);
    }// x
  }// y
}// end of generateSourceKappaAS
//----------------------------------------------------------------------------------------------------------------------

/**
 * Generate kappa matrix, absorbNabla1, absorbNabla2 for absorbing medium.
 * For the 2D simulation the zPart == 0
 */
void KSpaceFirstOrderSolver::generateKappaAndNablas()
{
  const DimensionSizes& reducedDimensionSizes = mParameters.getReducedDimensionSizes();

  const float dxSqRec    = 1.0f / (mParameters.getDx() * mParameters.getDx());
  const float dySqRec    = 1.0f / (mParameters.getDy() * mParameters.getDy());
  const float dzSqRec    = (mParameters.isSimulation3D()) ? 1.0f / (mParameters.getDz() * mParameters.getDz()) : 0.0f;

  const float cRefDt2    = mParameters.getCRef() * mParameters.getDt() * 0.5f;
  const float pi2        = float(M_PI) * 2.0f;

  const size_t nx        = mParameters.getFullDimensionSizes().nx;
  const size_t ny        = mParameters.getFullDimensionSizes().ny;
  const size_t nz        = mParameters.getFullDimensionSizes().nz;

  const float nxRec      = 1.0f / float(nx);
  const float nyRec      = 1.0f / float(ny);
  const float nzRec      = 1.0f / float(nz);

  const float alphaPower = mParameters.getAlphaPower();

  float* kappa           = getRealData(MI::kKappa);
  float* absorbNabla1    = getRealData(MI::kAbsorbNabla1);
  float* absorbNabla2    = getRealData(MI::kAbsorbNabla2);

  // Generated wave number in a given direction
  auto kPart = [](float i, float sizeRec, float dispRec)
  {
    float k = 0.5f - fabs(0.5f - i * sizeRec);
    return (k * k) * dispRec;
  };// end of kPart

  #pragma omp parallel for schedule(static) if (mParameters.isSimulation3D())
  for (size_t z = 0; z < reducedDimensionSizes.nz; z++)
  {
    const float kz = kPart(float(z), nzRec, dzSqRec);

    #pragma omp parallel for schedule(static) if (mParameters.isSimulation2D())
    for (size_t y = 0; y < reducedDimensionSizes.ny; y++)
    {
      const float ky = kPart(float(y), nyRec, dySqRec);

      #pragma omp simd
      for (size_t x = 0; x < reducedDimensionSizes.nx; x++)
      {
        const float kx    = kPart(float(x), nxRec, dxSqRec);
        const float k     = pi2 * sqrt(kx + ky + kz);
        const float cRefK = cRefDt2 * k;

        const size_t i  = get1DIndex(z, y, x, reducedDimensionSizes);

        kappa[i]        = (cRefK == 0.0f) ? 1.0f : sin(cRefK) / cRefK;

        absorbNabla1[i] = pow(k, alphaPower - 2.0f);
        absorbNabla2[i] = pow(k, alphaPower - 1.0f);

        if (absorbNabla1[i] ==  std::numeric_limits<float>::infinity()) absorbNabla1[i] = 0.0f;
        if (absorbNabla2[i] ==  std::numeric_limits<float>::infinity()) absorbNabla2[i] = 0.0f;
      }// x
    }// y
  }// z
}// end of generateKappaAndNablas
//----------------------------------------------------------------------------------------------------------------------

/**
 * Generate absorbTau and absorbEta in for heterogenous medium.
 */
void KSpaceFirstOrderSolver::generateTauAndEta()
{
  if ((mParameters.getAlphaCoeffScalarFlag()) && (mParameters.getC0ScalarFlag()))
  { // Scalar values
    const float alphaPower       = mParameters.getAlphaPower();
    const float tanPi2AlphaPower = tan(float(M_PI_2) * alphaPower);
    const float alphaNeperCoeff  = (100.0f * pow(1.0e-6f / (2.0f * float(M_PI)), alphaPower)) /
                                   (20.0f * float(M_LOG10E));

    const float alphaCoeff2      = 2.0f * mParameters.getAlphaCoeffScalar() * alphaNeperCoeff;

    mParameters.setAbsorbTauScalar((-alphaCoeff2) * pow(mParameters.getC0Scalar(), alphaPower - 1.0f));
    mParameters.setAbsorbEtaScalar(  alphaCoeff2  * pow(mParameters.getC0Scalar(), alphaPower) * tanPi2AlphaPower);
  }
  else
  { // Matrix values
    const DimensionSizes& dimensionSizes = mParameters.getFullDimensionSizes();

    const bool   alphaCoeffScalarFlag = mParameters.getAlphaCoeffScalarFlag();
    const float  alphaCoeffScalar     = (alphaCoeffScalarFlag) ? mParameters.getAlphaCoeffScalar() : 0.0f;
    // temp3 matrix holds alpha coeff matrix (used only once).
    const float* alphaCoeffMatrix     = (alphaCoeffScalarFlag) ? nullptr : getRealData(MI::kTemp3RealND);

    const float  alphaPower       = mParameters.getAlphaPower();
    const float  tanPi2AlphaPower = tan(float(M_PI_2) * alphaPower);

    const bool   c0ScalarFlag = mParameters.getC0ScalarFlag();
    const float  c0Scalar     = (c0ScalarFlag) ? mParameters.getC0Scalar() : 0.0f;
    // Here c2 still holds just c0!
    const float* cOMatrix     = (c0ScalarFlag) ? nullptr : getRealData(MI::kC2);

    // alpha = 100 * alpha .* (1e-6 / (2 * pi)).^y ./
    //                        (20 * log10(exp(1)));
    const float alphaNeperCoeff = (100.0f * pow(1.0e-6f / (2.0f * float(M_PI)), alphaPower)) /
                                  (20.0f * float(M_LOG10E));

    float* absorbTau = getRealData(MI::kAbsorbTau);
    float* absorbEta = getRealData(MI::kAbsorbEta);

    #pragma omp parallel for schedule(static) if (mParameters.isSimulation3D())
    for (size_t z = 0; z < dimensionSizes.nz; z++)
    {
      #pragma omp parallel for schedule(static) if (mParameters.isSimulation2D())
      for (size_t y = 0; y < dimensionSizes.ny; y++)
      {
        #pragma omp simd
        for (size_t x = 0; x < dimensionSizes.nx; x++)
        {
          const size_t i = get1DIndex(z, y, x, dimensionSizes);

          const float alphaCoeff2 = 2.0f * alphaNeperCoeff *
                                    ((alphaCoeffScalarFlag) ? alphaCoeffScalar : alphaCoeffMatrix[i]);

          absorbTau[i] = (-alphaCoeff2) * pow(((c0ScalarFlag) ? c0Scalar : cOMatrix[i]), alphaPower - 1.0f);
          absorbEta[i] =   alphaCoeff2  * pow(((c0ScalarFlag) ? c0Scalar : cOMatrix[i]), alphaPower) * tanPi2AlphaPower;
        }// x
      }// y
    }// z
  }// matrix
}// end of generateTauAndEta
//----------------------------------------------------------------------------------------------------------------------

/**
 * Generate absorbTau for heterogenous medium with stokes absorption.
 */
void KSpaceFirstOrderSolver::generateTau()
{
  if ((mParameters.getAlphaCoeffScalarFlag()) && (mParameters.getC0ScalarFlag()))
  { // Scalar values
    const float alphaPower       = mParameters.getAlphaPower();
    const float alphaNeperCoeff  = (100.0f * pow(1.0e-6f / (2.0f * float(M_PI)), alphaPower)) /
                                   (20.0f * float(M_LOG10E));

    const float alphaCoeff2      = 2.0f * mParameters.getAlphaCoeffScalar() * alphaNeperCoeff;

    mParameters.setAbsorbTauScalar((-alphaCoeff2) * pow(mParameters.getC0Scalar(), alphaPower - 1.0f));
  }
  else
  { // Matrix values
    const DimensionSizes& dimensionSizes = mParameters.getFullDimensionSizes();

    const bool   alphaCoeffScalarFlag = mParameters.getAlphaCoeffScalarFlag();
    const float  alphaCoeffScalar     = (alphaCoeffScalarFlag) ? mParameters.getAlphaCoeffScalar() : 0.0f;
    // temp3 matrix holds alpha coeff matrix (used only once).
    const float* alphaCoeffMatrix     = (alphaCoeffScalarFlag) ? nullptr : getRealData(MI::kTemp3RealND);

    const bool   c0ScalarFlag = mParameters.getC0ScalarFlag();
    const float  c0Scalar     = (c0ScalarFlag) ? mParameters.getC0Scalar() : 0.0f;
    // Here c2 still holds just c0!
    const float* cOMatrix     = (c0ScalarFlag) ? nullptr : getRealData(MI::kC2);

    const float  alphaPower   = mParameters.getAlphaPower();

    // alpha = 100 * alpha .* (1e-6 / (2 * pi)).^y ./
    //                        (20 * log10(exp(1)));
    const float alphaNeperCoeff = (100.0f * pow(1.0e-6f / (2.0f * float(M_PI)), alphaPower)) /
                                  (20.0f * float(M_LOG10E));

    float* absorbTau = getRealData(MI::kAbsorbTau);

    #pragma omp parallel for schedule(static) if (mParameters.isSimulation3D())
    for (size_t z = 0; z < dimensionSizes.nz; z++)
    {
      #pragma omp parallel for schedule(static) if (mParameters.isSimulation2D())
      for (size_t y = 0; y < dimensionSizes.ny; y++)
      {
        #pragma omp simd
        for (size_t x = 0; x < dimensionSizes.nx; x++)
        {
          const size_t i = get1DIndex(z, y, x, dimensionSizes);

          const float alphaCoeff2 = 2.0f * alphaNeperCoeff *
                                    ((alphaCoeffScalarFlag) ? alphaCoeffScalar : alphaCoeffMatrix[i]);

          absorbTau[i] = (-alphaCoeff2) * pow(((c0ScalarFlag) ? c0Scalar : cOMatrix[i]), alphaPower - 1.0f);
        }// x
      }// y
    }// z
  }// matrix
}// end of generateTau
//----------------------------------------------------------------------------------------------------------------------

/**
 * Generate shift variables for non-staggered velocity sampling (x_shift_neg_r, y_shift_neg_r, z_shift_neg_r).
 */
void KSpaceFirstOrderSolver::generateNonStaggeredShiftVariables()
{
  const DimensionSizes dimensionSizes = mParameters.getFullDimensionSizes();
  const DimensionSizes shiftDimensions(dimensionSizes.nx / 2 + 1,
                                       dimensionSizes.ny / 2 + 1,
                                       dimensionSizes.nz / 2 + 1);

  constexpr FloatComplex negExp = FloatComplex(0,-1);
  constexpr float        pi2    = 2.0f * float(M_PI);

  const float dx = mParameters.getDx();
  const float dy = mParameters.getDy();
  const float dz = mParameters.getDz();

  FloatComplex* xShiftNeg = getComplexData(MI::kXShiftNegR);
  FloatComplex* yShiftNeg = getComplexData(MI::kYShiftNegR);
  FloatComplex* zShiftNeg = getComplexData(MI::kZShiftNegR, mParameters.isSimulation3D());

  // Calculate ifft shift
  auto iFftShift = [](ptrdiff_t i, ptrdiff_t size)
  {
    return (i + (size / 2)) % size - (size / 2);
  };// end of iFftShift

  // Calculation done sequentially because the size of the arrays are small < 512
  // Moreover, there's a bug in Intel compiler under windows generating clobbered data.
  // xShiftNeg - No SIMD due to Intel Compiler bug under Windows
  for (size_t i = 0; i < shiftDimensions.nx; i++)
  {
    const ptrdiff_t shift = iFftShift(i, dimensionSizes.nx);
    const float     kx    = (pi2 / dx) * (float(shift) / float(dimensionSizes.nx));

    xShiftNeg[i] = std::exp(negExp * kx * dx * 0.5f);
  }

  // yShiftNeg
  for (size_t i = 0; i < shiftDimensions.ny; i++)
  {
    const ptrdiff_t shift = iFftShift(i, dimensionSizes.ny);
    const float     ky    = (pi2 / dy) * (float(shift) / float(dimensionSizes.ny));

    yShiftNeg[i] = std::exp(negExp * ky * dy * 0.5f);
  }

  // zShiftNeg
  if (mParameters.isSimulation3D())
  {
    for (size_t i = 0; i < shiftDimensions.nz; i++)
    {
      const ptrdiff_t shift = iFftShift(i, dimensionSizes.nz);
      const float     kz    = (pi2 / dz) * (float(shift) / float(dimensionSizes.nz));

      zShiftNeg[i] = std::exp(negExp * kz * dz * 0.5f);
    }
  }
}// end of generateNonStaggeredShiftVariables
//----------------------------------------------------------------------------------------------------------------------

/**
 * Generate PML and staggered PML.
 */
void KSpaceFirstOrderSolver::generatePml()
{
  const DimensionSizes dimensionSizes = mParameters.getFullDimensionSizes();

  const float pmlXAlpha = mParameters.getPmlXAlpha();
  const float pmlYAlpha = mParameters.getPmlYAlpha();

  const size_t pmlXSize = mParameters.getPmlXSize();
  const size_t pmlYSize = mParameters.getPmlYSize();

  const float  cRefDx   = mParameters.getCRef() / mParameters.getDx();
  const float  cRefDy   = mParameters.getCRef() / mParameters.getDy();

  const float  dt2      = mParameters.getDt() * 0.5f;

  float* pmlX    = getRealData(MI::kPmlX);
  float* pmlY    = getRealData(MI::kPmlY);

  float* pmlXSgx = getRealData(MI::kPmlXSgx);
  float* pmlYSgy = getRealData(MI::kPmlYSgy);

  // Init arrays
  auto initPml = [](float* pml, float* pmlSg, size_t size)
  {
    for (size_t i = 0; i < size; i++)
    {
      pml[i]   = 1.0f;
      pmlSg[i] = 1.0f;
    }
  };// end of initPml

  // Calculate left value of PML exponent, for staggered use i + 0.5f, i shifted by -1 (Matlab indexing).
  auto pmlLeft = [dt2](float i, float cRef, float pmlAlpha, float pmlSize)
  {
    return exp(-dt2 * pmlAlpha * cRef * pow((i - pmlSize) / (-pmlSize), 4));
  };// end of pmlLeft.

  // Calculate right value of PML exponent, for staggered use i + 0.5f, i shifted by +1 (Matlab indexing).
  auto pmlRight = [dt2](float i, float cRef, float pmlAlpha, float pmlSize)
  {
    return exp(-dt2 * pmlAlpha * cRef * pow((i + 1.0f)/ pmlSize, 4));
  };// end of pmlRight.


  // PML in x dimension
  initPml(pmlX, pmlXSgx, dimensionSizes.nx);

  // Too difficult for SIMD
  for (size_t i = 0; i < pmlXSize; i++)
  {
    pmlX[i]    = pmlLeft(float(i),        cRefDx, pmlXAlpha, pmlXSize);
    pmlXSgx[i] = pmlLeft(float(i) + 0.5f, cRefDx, pmlXAlpha, pmlXSize);

    const size_t iR = dimensionSizes.nx - pmlXSize + i;

    pmlX[iR]    = pmlRight(float(i),        cRefDx, pmlXAlpha, pmlXSize);
    pmlXSgx[iR] = pmlRight(float(i) + 0.5f, cRefDx, pmlXAlpha, pmlXSize);
  }

  // PML in y dimension
  initPml(pmlY, pmlYSgy, dimensionSizes.ny);

  // Too difficult for SIMD
  for (size_t i = 0; i < pmlYSize; i++)
  {
    if (!mParameters.isSimulationAS())
    { // for axisymmetric code the PML is only on the outer side
      pmlY[i]    = pmlLeft(float(i),        cRefDy, pmlYAlpha, pmlYSize);
      pmlYSgy[i] = pmlLeft(float(i) + 0.5f, cRefDy, pmlYAlpha, pmlYSize);
    }

    const size_t iR = dimensionSizes.ny - pmlYSize + i;

    pmlY[iR]    = pmlRight(float(i),        cRefDy, pmlYAlpha, pmlYSize);
    pmlYSgy[iR] = pmlRight(float(i) + 0.5f, cRefDy, pmlYAlpha, pmlYSize);
  }

  // PML in z dimension
  if (mParameters.isSimulation3D())
  {
    const float  pmlZAlpha = mParameters.getPmlZAlpha();
    const size_t pmlZSize  = mParameters.getPmlZSize();
    const float  cRefDz    = mParameters.getCRef() / mParameters.getDz();

    float* pmlZ    = getRealData(MI::kPmlZ);
    float* pmlZSgz = getRealData(MI::kPmlZSgz);

    initPml(pmlZ, pmlZSgz, dimensionSizes.nz);

    // Too difficult for SIMD
    for (size_t i = 0; i < pmlZSize; i++)
    {
      pmlZ[i]    = pmlLeft(float(i)       , cRefDz, pmlZAlpha, pmlZSize);
      pmlZSgz[i] = pmlLeft(float(i) + 0.5f, cRefDz, pmlZAlpha, pmlZSize);

      const size_t iR = dimensionSizes.nz - pmlZSize + i;

      pmlZ[iR]    = pmlRight(float(i),        cRefDz, pmlZAlpha, pmlZSize);
      pmlZSgz[iR] = pmlRight(float(i) + 0.5f, cRefDz, pmlZAlpha, pmlZSize);
    }
  }
}// end of generatePml
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute c^2.
 */
void KSpaceFirstOrderSolver::generateC2()
{
  if (!mParameters.getC0ScalarFlag())
  { // Matrix values
    const size_t nElements = mParameters.getFullDimensionSizes().nElements();

    float* c2 = getRealData(MI::kC2);

    #pragma omp parallel for simd schedule(simd:static) aligned(c2 : kDataAlignment)
    for (size_t i = 0; i < nElements; i++)
    {
      c2[i] = c2[i] * c2[i];
    }
  }// matrix
}// generateC2
//----------------------------------------------------------------------------------------------------------------------

#pragma omp declare simd
inline size_t KSpaceFirstOrderSolver::get1DIndex(const size_t          z,
                                                 const size_t          y,
                                                 const size_t          x,
                                                 const DimensionSizes& dimensionSizes) const
{
  return (z * dimensionSizes.ny + y) * dimensionSizes.nx + x;
}// end of get1DIndex
//----------------------------------------------------------------------------------------------------------------------

#pragma omp declare simd
inline size_t KSpaceFirstOrderSolver::get1DIndex(const size_t          y,
                                                 const size_t          x,
                                                 const DimensionSizes& dimensionSizes) const
{
  return y * dimensionSizes.nx + x;
}// end of get1DIndex
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Private methods --------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//
