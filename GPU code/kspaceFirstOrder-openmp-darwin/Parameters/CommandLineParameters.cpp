/**
 * @file      CommandLineParameters.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file containing command line parameters.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      29 August    2012, 11:25 (created) \n
 *            11 February  2020, 14:49 (revised)
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

// Linux build
#if  defined(__linux__) || defined(__APPLE__)
  #include <getopt.h>
#endif

// Windows build
#ifdef _WIN64
  #include <GetoptWin64/Getopt.h>
#endif

#ifdef _OPENMP
  #include <omp.h>
#endif

#include <cstring>
#include <stdexcept>

#include <Logger/Logger.h>
#include <Parameters/CommandLineParameters.h>

using std::string;

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Public methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Print usage.
 */
void CommandLineParameters::printUsage()
{
  Logger::log(Logger::LogLevel::kBasic, kOutFmtUsagePart1);

  #ifdef _OPENMP
    Logger::log(Logger::LogLevel::kBasic, kOutFmtUsageThreads, getDefaultNumberOfThreads());
  #endif

  Logger::log(Logger::LogLevel::kBasic, kOutFmtUsagePart2, kDefaultProgressPrintInterval, kDefaultCompressionLevel);
}// end of printUsage
//----------------------------------------------------------------------------------------------------------------------

/**
 * Print out command line parameters.
 */
void CommandLineParameters::printComandlineParamers()
{
  Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSeparator);

  // Shortcut to format file name
  auto formatFileName = [](const string& fileName) -> string
  {
    return Logger::wordWrapString(kOutFmtInputFile + fileName, kErrFmtPathDelimiters, 15).c_str();
  };// formatFileName

  Logger::log(Logger::LogLevel::kAdvanced, formatFileName(mInputFileName));

  Logger::log(Logger::LogLevel::kAdvanced, formatFileName(mOutputFileName));

  if (isCheckpointEnabled())
  {
    Logger::log(Logger::LogLevel::kAdvanced, formatFileName(mCheckpointFileName));
  }

  Logger::log(Logger::LogLevel::kAdvanced, kOutFmtSeparator);

  if (isCheckpointEnabled() && (mCheckpointInterval > 0))
  {
    Logger::log(Logger::LogLevel::kAdvanced, kOutFmtCheckpointInterval, mCheckpointInterval);
  }
  if (isCheckpointEnabled() && (mCheckpointTimeSteps > 0))
  {
    Logger::log(Logger::LogLevel::kAdvanced, kOutFmtCheckpointTimeSteps, mCheckpointTimeSteps);
  }

  Logger::log(Logger::LogLevel::kAdvanced, kOutFmtCompressionLevel, mCompressionLevel);

  Logger::log(Logger::LogLevel::kFull,     kOutFmtPrintProgressIntrerval, mProgressPrintInterval);

  if (mBenchmarkFlag)
  {
    Logger::log(Logger::LogLevel::kFull, kOutFmtBenchmarkTimeStep, mBenchmarkTimeStepCount);
  }

  if (mCopySensorMaskFlag)
  {
    Logger::log(Logger::LogLevel::kAdvanced, kOutFmtCopySensorMask);
  }
}// end of printComandlineParamers
//----------------------------------------------------------------------------------------------------------------------

/**
 * Parse command line.
 */
void CommandLineParameters::parseCommandLine(int argc, char** argv)
{
  #ifdef _OPENMP
    const char* shortOpts = "i:o:r:c:t:puhs:";
  #else
    const char* shortOpts = "i:o:r:c:puhs:";
  #endif

  // Enum with all parameter names. When adding other switches, the value shall not collide with ASCII codes of short
  // options.
  // Enum class can't be used here due to missing conversion implicit conversion to int in C++-11.
  enum Swithces
  {
    kHelp                    = 'h',
    kInputFileName           = 'i',
    kOutputFileName          = 'o',
    kPrintProgressInterval   = 'r',
    kNumberOfThreads         = 't',
    kCompressionLevel        = 'c',
    kSamplingStartIndex      = 's',

    kBenchmark               =  1,
    kCopySensorMask          =  2,
    kCheckpointFile          =  3,
    kCheckpointInterval      =  4,
    kCheckpointTimesteps     =  5,
    kVerbose                 =  6,
    kVersion                 =  7,

    kPressureRaw             = 'p',
    kPressureRms             =  10,
    kPressureMax             =  11,
    kPressureMin             =  12,
    kPressureMaxAll          =  13,
    kPressureMinAll          =  14,
    kPressureFinal           =  15,

    kVelocityRaw             = 'u',
    kVelocityRms             =  20,
    kVelocityMax             =  21,
    kVelocityMin             =  22,
    kVelocityMaxAll          =  23,
    kVelocityMinAll          =  24,
    kVelocityFinal           =  25,
    kVelocityNonStaggeredRaw =  26
  };

  // Long parameters
  const struct option longOpts[] =
  {
    {"benchmark",            required_argument, nullptr, kBenchmark},
    {"copy_sensor_mask",     no_argument,       nullptr, kCopySensorMask},
    {"checkpoint_file"    ,  required_argument, nullptr, kCheckpointFile},
    {"checkpoint_interval",  required_argument, nullptr, kCheckpointInterval},
    {"checkpoint_timesteps", required_argument, nullptr, kCheckpointTimesteps},
    {"help",                 no_argument,       nullptr, kHelp},
    {"verbose",              required_argument, nullptr, kVerbose},
    {"version",              no_argument,       nullptr, kVersion},

    {"p_raw",                no_argument,       nullptr, kPressureRaw},
    {"p_rms",                no_argument,       nullptr, kPressureRms},
    {"p_max",                no_argument,       nullptr, kPressureMax},
    {"p_min",                no_argument,       nullptr, kPressureMin},
    {"p_max_all",            no_argument,       nullptr, kPressureMaxAll},
    {"p_min_all",            no_argument,       nullptr, kPressureMinAll},
    {"p_final",              no_argument,       nullptr, kPressureFinal},

    {"u_raw",                no_argument,       nullptr, kVelocityRaw},
    {"u_rms",                no_argument,       nullptr, kVelocityRms},
    {"u_max",                no_argument,       nullptr, kVelocityMax},
    {"u_min",                no_argument,       nullptr, kVelocityMin},
    {"u_max_all",            no_argument,       nullptr, kVelocityMaxAll},
    {"u_min_all",            no_argument,       nullptr, kVelocityMinAll},
    {"u_final",              no_argument,       nullptr, kVelocityFinal},
    {"u_non_staggered_raw",  no_argument,       nullptr, kVelocityNonStaggeredRaw},

    {nullptr,                no_argument,       nullptr, 0  }
  };

  // All optional arguments are in fact requested. This was chosen to prevent getopt error messages and provide custom
  // error handling.
  opterr = 0;

  int  opt;
  int  longIndex = -1;
  bool checkpointFlag = false;

  // Shortcut to print usage, error message and exit
  auto reportError = [this](const string& message)
  {
    constexpr int kErrorLineIndent = 9;

    printUsage();
    Logger::errorAndTerminate(Logger::wordWrapString(message, " ", kErrorLineIndent));
  }; // end of reportError


  // Short parameters
  while ((opt = getopt_long(argc, argv, shortOpts, longOpts, &longIndex)) != -1)
  {
    switch (opt)
    {
      case kHelp:
      {
        printUsage();
        exit(EXIT_SUCCESS);
      }

      case kInputFileName:
      {
        // Test if the file was correctly entered (if not, getopt could eat the following parameter)
        if ((optarg != nullptr) &&
            ((strlen(optarg) > 0) && (optarg[0] != '-')))
        {
          mInputFileName = optarg;
        }
        else
        {
          reportError(kErrFmtNoInputFile);
        }
        break;
      }

      case kOutputFileName:
      {
        // Test if the wile was correctly entered (if not, getopt could eat the following parameter)
        if ((optarg != nullptr) &&
            ((strlen(optarg) > 0) && (optarg[0] != '-')))
        {
          mOutputFileName = optarg;
        }
        else
        {
          reportError(kErrFmtNoOutputFile);
        }
        break;
      }

      case kPrintProgressInterval:
      {
        try
        {
          int convertedValue = std::stoi(optarg);
          if ((convertedValue < 1) || (convertedValue > 100))
          {
            throw std::invalid_argument("-r");
          }
          mProgressPrintInterval = std::stoll(optarg);
        }
        catch (...)
        {
          reportError(kErrFmtNoProgressPrintInterval);
        }
        break;
      }

    #ifdef _OPENMP
      case kNumberOfThreads:
      {
        try
        {
          if (std::stoi(optarg) < 1)
          {
            throw std::invalid_argument("-t");
          }
          mNumberOfThreads = std::stoll(optarg);
        }
        catch (...)
        {
          reportError(kErrFmtInvalidNumberOfThreads);
        }
        break;
      }
    #endif

      case kCompressionLevel:
      {
        try
        {
          int covertedValue = std::stoi(optarg);
          if ((covertedValue < 0) || (covertedValue > 9))
          {
            throw std::invalid_argument("-c");
          }
          mCompressionLevel = std::stoll(optarg);
        }
        catch (...)
        {
          reportError(kErrFmtNoCompressionLevel);
        }
        break;
      }

      case kSamplingStartIndex:
      {
        try
        {
          if (std::stoll(optarg) < 1)
          {
            throw std::invalid_argument("-s");
          }
          mSamplingStartTimeStep = std::stoll(optarg) - 1;
        }
        catch (...)
        {
          reportError(kErrFmtNoSamplingStartTimeStep);
        }
        break;
      }

      case kBenchmark:
      {
        try
        {
          mBenchmarkFlag = true;
          if (std::stoll(optarg) <= 0)
          {
            throw std::invalid_argument("benchmark");
          }
          mBenchmarkTimeStepCount = std::stoll(optarg);
        }
        catch (...)
        {
          reportError(kErrFmtNoBenchmarkTimeStep);
        }
        break;
      }

      case kCopySensorMask:
      {
        mCopySensorMaskFlag = true;
        break;
      }

      case kCheckpointFile:
      {
        checkpointFlag = true;
        // Test if the wile was correctly entered (if not, getopt could eat the following parameter)
        if ((optarg != NULL) &&
            ((strlen(optarg) > 0) && (optarg[0] != '-')))
        {
          mCheckpointFileName = optarg;
        }
        else
        {
          reportError(kErrFmtNoCheckpointFile);
        }
        break;
      }

      case kCheckpointInterval:
      {
        try
        {
          checkpointFlag = true;
          if (std::stoll(optarg) <= 0)
          {
           throw std::invalid_argument("checkpoint_interval");
          }
          mCheckpointInterval = std::stoll(optarg);
        }
        catch (...)
        {
          reportError(kErrFmtNoCheckpointInterval);
        }
        break;
      }

      case kCheckpointTimesteps:
      {
        try
        {
          checkpointFlag = true;
          if (std::stoll(optarg) <= 0)
          {
           throw std::invalid_argument("checkpoint_timesteps");
          }
          mCheckpointTimeSteps = std::stoll(optarg);
        }
        catch (...)
        {
          reportError(kErrFmtNoCheckpointTimeSteps);
        }
        break;
      }

      case kVerbose:
      {
        try
        {
          int verboseLevel = std::stoi(optarg);
          if ((verboseLevel < 0) || (verboseLevel > 2))
          {
            throw std::invalid_argument("verbose");
          }
          Logger::setLevel(static_cast<Logger::LogLevel> (verboseLevel));
        }
        catch (...)
        {
          reportError(kErrFmtNoVerboseLevel);
        }
        break;
      }

      case kVersion:
      {
        mPrintVersionFlag = true;
        break;
      }

      case kPressureRaw:
      {
        mStorePressureRawFlag = true;
        break;
      }

      case kPressureRms:
      {
        mStorePressureRmsFlag = true;
        break;
      }

      case kPressureMax:
      {
        mStorePressureMaxFlag = true;
        break;
      }

      case kPressureMin:
      {
        mStorePressureMinFlag = true;
        break;
      }

      case kPressureMaxAll:
      {
        mStorePressureMaxAllFlag = true;
        break;
      }

      case kPressureMinAll:
      {
        mStorePressureMinAllFlag = true;
        break;
      }

      case kPressureFinal:
      {
        mStorePressureFinalAllFlag = true;
        break;
      }

      case kVelocityRaw:
      {
        mStoreVelocityRawFlag = true;
        break;
      }

      case kVelocityRms:
      {
        mStoreVelocityRmsFlag = true;
        break;
      }

      case kVelocityMax:
      {
        mStoreVelocityMaxFlag = true;
        break;
      }

      case kVelocityMin:
      {
        mStoreVelocityMinFlag = true;
        break;
      }

      case kVelocityMaxAll:
      {
        mStoreVelocityMaxAllFlag = true;
        break;
      }

      case kVelocityMinAll:
      {
        mStoreVelocityMinAllFlag = true;
        break;
      }

      case kVelocityFinal:
      {
        mStoreVelocityFinalAllFlag = true;
        break;
      }

      case kVelocityNonStaggeredRaw:
      {
        mStoreVelocityNonStaggeredRawFlag = true;
        break;
      }

      // Unknown parameter or a missing mandatory argument
      case ':':
      case '?':
      {
        switch (optopt)
        {
          case kInputFileName:
          {
            reportError(kErrFmtNoInputFile);
            break;
          }

          case kOutputFileName:
          {
            reportError(kErrFmtNoOutputFile);
            break;
          }

          case kPrintProgressInterval:
          {
            reportError(kErrFmtNoProgressPrintInterval);
            break;
          }

        #ifdef _OPENMP
          case kNumberOfThreads:
          {
            reportError(kErrFmtInvalidNumberOfThreads);
            break;
          }
        #endif

          case kCompressionLevel:
          {
            reportError(kErrFmtNoCompressionLevel);
            break;
          }

          case kSamplingStartIndex:
          {
            reportError(kErrFmtNoSamplingStartTimeStep);
            break;
          }

          case kBenchmark:
          {
            reportError(kErrFmtNoBenchmarkTimeStep);
            break;
          }

          case kCheckpointFile:
          {
            reportError(kErrFmtNoCheckpointFile);
            break;
          }

          case kCheckpointInterval:
          {
            reportError(kErrFmtNoCheckpointInterval);
            break;
          }

          case kCheckpointTimesteps:
          {
            reportError(kErrFmtNoCheckpointTimeSteps);
            break;
          }

          case kVerbose:
          {
            reportError(kErrFmtNoVerboseLevel);
            break;
          }

          default :
          {
            reportError(kErrFmtUnknownParameterOrArgument);
            break;
          }
        }
      }

      default:
      {
        reportError(kErrFmtUnknownParameter);
        break;
      }
    }
  }

  if (mPrintVersionFlag) return;

  // Post checks
  if (mInputFileName == "")
  {
    reportError(kErrFmtNoInputFile);
  }

  if (mOutputFileName == "")
  {
    reportError(kErrFmtNoOutputFile);
  }

  if (checkpointFlag)
  {
    if (mCheckpointFileName == "")
    {
      reportError(kErrFmtNoCheckpointFile);
    }

    if ((mCheckpointInterval <= 0) && (mCheckpointTimeSteps <= 0))
    {
      reportError(kErrFmtNoCheckpointIntervalOrTimeSteps);
    }
  }

  // Set a default flag if necessary
  if (!(mStorePressureRawFlag    || mStorePressureRmsFlag    || mStorePressureMaxFlag      || mStorePressureMinFlag ||
        mStorePressureMaxAllFlag || mStorePressureMinAllFlag || mStorePressureFinalAllFlag ||
        mStoreVelocityRawFlag    || mStoreVelocityNonStaggeredRawFlag                      ||
        mStoreVelocityRmsFlag    || mStoreVelocityMaxFlag    || mStoreVelocityMinFlag      ||
        mStoreVelocityMaxAllFlag || mStoreVelocityMinAllFlag || mStoreVelocityFinalAllFlag ))
  {
    mStorePressureRawFlag = true;
  }
}// end of parseCommandLine
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Protected methods -------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Constructor.
 */
CommandLineParameters::CommandLineParameters()
  : mInputFileName(""), mOutputFileName (""), mCheckpointFileName(""),
    #ifdef _OPENMP
      mNumberOfThreads(getDefaultNumberOfThreads()),
    #else
      mNumberOfThreads(1),
    #endif

    mProgressPrintInterval(kDefaultProgressPrintInterval),
    mCompressionLevel(kDefaultCompressionLevel),
    mBenchmarkFlag (false), mBenchmarkTimeStepCount(0),
    mCheckpointInterval(0), mCheckpointTimeSteps(0),
    mPrintVersionFlag (false),
    // output flags
    mStorePressureRawFlag(false), mStorePressureRmsFlag(false),
    mStorePressureMaxFlag(false), mStorePressureMinFlag(false),
    mStorePressureMaxAllFlag(false), mStorePressureMinAllFlag(false), mStorePressureFinalAllFlag(false),
    mStoreVelocityRawFlag(false), mStoreVelocityNonStaggeredRawFlag(false),
    mStoreVelocityRmsFlag(false), mStoreVelocityMaxFlag(false), mStoreVelocityMinFlag(false),
    mStoreVelocityMaxAllFlag(false), mStoreVelocityMinAllFlag(false), mStoreVelocityFinalAllFlag(false),
    mCopySensorMaskFlag(false),
    mSamplingStartTimeStep(0)
{

}// end of constructor
//----------------------------------------------------------------------------------------------------------------------

/**
 * If -t is not used, let's check the environmental variable OMP_NUM_THREADS which may be set by the user or the PBS
 * scheduler. If it is set, let's use it, otherwise, set maximum number of processors.
 */
size_t CommandLineParameters::getDefaultNumberOfThreads()
{
  #ifdef _OPENMP
    // Set the variable to number of logical processors in the case the env variable is not set.
    size_t nThreads = omp_get_num_procs();

    // Try to read the environmental variable
    const char* envNumberOfThreads = std::getenv("OMP_NUM_THREADS");

    if (envNumberOfThreads != nullptr)
    {
      // If exists and can be converted to long, use it. Otherwise, do nothing.
      try
      {
        if (std::stoll(envNumberOfThreads) > 0)
        {
          nThreads = std::stoll(envNumberOfThreads);
        }
      }
      catch (...)
      {
        // Do nothing
      }
    }

    return nThreads;
  #else
    return 1;
  #endif

}// end of getDefaultNumberOfThreads
//----------------------------------------------------------------------------------------------------------------------
