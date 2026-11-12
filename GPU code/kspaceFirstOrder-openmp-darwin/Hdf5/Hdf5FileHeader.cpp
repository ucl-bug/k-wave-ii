/**
 * @file      Hdf5FileHeader.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation of the class responsible for working with file headers.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      24 August    2017, 09:51 (created) \n
 *            11 February  2020, 14:34 (revised)
 *
 * @copyright Copyright (C) 2017 - 2020 SC\@FIT Research Group, Brno University of Technology, Brno, CZ.
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

#include <iostream>
#include <stdexcept>
#include <ctime>

// Linux build
#ifdef __linux__
  #include <unistd.h>
#endif

// Windows 64 build
#ifdef _WIN64
  #include<Winsock2.h>
  #pragma comment(lib, "Ws2_32.lib")
#endif

// Unix-like systems (Linux and macOS)
#if defined(__linux__) || defined(__APPLE__)
  #include <unistd.h>
#endif

#include <Hdf5/Hdf5FileHeader.h>
#include <Parameters/Parameters.h>
#include <Logger/Logger.h>

using std::string;
using std::ios;

/// Shortcut for file header items
using FHI = Hdf5FileHeader::FileHeaderItems;

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Initialization ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Initialization of the current file version
 */
const  Hdf5FileHeader::FileVersion Hdf5FileHeader::kCurrentFileVersion = Hdf5FileHeader::FileVersion::kVersion12;

/**
 * Initialization of static map with header attribute names.
 */
std::map<Hdf5FileHeader::FileHeaderItems, std::string> Hdf5FileHeader::sHeaderNames
{
  {Hdf5FileHeader::FileHeaderItems::kCreatedBy             , "created_by"},
  {Hdf5FileHeader::FileHeaderItems::kCreationDate          , "creation_date"},
  {Hdf5FileHeader::FileHeaderItems::kFileDescription       , "file_description"},
  {Hdf5FileHeader::FileHeaderItems::kMajorVersion          , "major_version"},
  {Hdf5FileHeader::FileHeaderItems::kMinorVersion          , "minor_version"},
  {Hdf5FileHeader::FileHeaderItems::kFileType              , "file_type"},

  {Hdf5FileHeader::FileHeaderItems::kHostName              , "host_names"},
  {Hdf5FileHeader::FileHeaderItems::kNumberOfCores         , "number_of_cpu_cores"},
  {Hdf5FileHeader::FileHeaderItems::kTotalMemoryConsumption, "total_memory_in_use"},
  {Hdf5FileHeader::FileHeaderItems::kPeakMemoryConsumption , "peak_core_memory_in_use"},

  {Hdf5FileHeader::FileHeaderItems::kTotalExecutionTime    , "total_execution_time"},
  {Hdf5FileHeader::FileHeaderItems::kDataLoadTime          , "data_loading_phase_execution_time"},
  {Hdf5FileHeader::FileHeaderItems::kPreProcessingTime     , "pre-processing_phase_execution_time"},
  {Hdf5FileHeader::FileHeaderItems::kSimulationTime        , "simulation_phase_execution_time"},
  {Hdf5FileHeader::FileHeaderItems::kPostProcessingTime    , "post-processing_phase_execution_time"}
};// end of sHeaderNames
//----------------------------------------------------------------------------------------------------------------------

/**
 * Initialization of static map with file types.
 */
std::map<Hdf5FileHeader::FileType, std::string> Hdf5FileHeader::sFileTypesNames
{
  {Hdf5FileHeader::FileType::kInput     , "input"},
  {Hdf5FileHeader::FileType::kOutput    , "output"},
  {Hdf5FileHeader::FileType::kCheckpoint, "checkpoint"},
  {Hdf5FileHeader::FileType::kUnknown   , "unknown"}
};// end of sHeaderNames
//----------------------------------------------------------------------------------------------------------------------

/**
 * Initialization of file version names
 */
std::map<Hdf5FileHeader::FileVersion, Hdf5FileHeader::FileVersionNames> Hdf5FileHeader::sFileVersionNames
{
  {Hdf5FileHeader::FileVersion::kVersion10, Hdf5FileHeader::FileVersionNames {"1", "0"} },
  {Hdf5FileHeader::FileVersion::kVersion11, Hdf5FileHeader::FileVersionNames {"1", "1"} },
  {Hdf5FileHeader::FileVersion::kVersion12, Hdf5FileHeader::FileVersionNames {"1", "2"} },
};// end of sFileVersionNames
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Public methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Constructor.
 */
Hdf5FileHeader::Hdf5FileHeader()
  : mHeaderValues()
{

}// end of constructor
//----------------------------------------------------------------------------------------------------------------------

/**
 * Copy constructor.
 */
Hdf5FileHeader::Hdf5FileHeader(const Hdf5FileHeader& src)
  : mHeaderValues(src.mHeaderValues)
{

}// end of copy constructor
//----------------------------------------------------------------------------------------------------------------------

/**
 * Destructor.
 */
Hdf5FileHeader::~Hdf5FileHeader()
{
  mHeaderValues.clear();
}// end of destructor
//----------------------------------------------------------------------------------------------------------------------

/**
 * Assignment operator.
 */
Hdf5FileHeader& Hdf5FileHeader::operator=(const Hdf5FileHeader& src)
{
  if (this != &src)
  {
    mHeaderValues.clear();
    mHeaderValues = src.mHeaderValues;
  }

  return *this;
}// end of operator=
//----------------------------------------------------------------------------------------------------------------------

/**
 * Read header from the input file.
 */
void Hdf5FileHeader::readHeaderFromInputFile(Hdf5File& inputFile)
{
  // Get file root handle
  hid_t rootGroup = inputFile.getRootGroup();

  // Shortcut to read an item.
  auto readItem = [this, &inputFile, &rootGroup](FHI item)
  {
    mHeaderValues[item] = inputFile.readStringAttribute(rootGroup, "/", sHeaderNames[item]);
  };// readItem

  // Read file type
  readItem(FHI::kFileType);

  if (getFileType() == FileType::kInput)
  {
    readItem(FHI::kCreatedBy);
    readItem(FHI::kCreationDate);
    readItem(FHI::kFileDescription);
    readItem(FHI::kMajorVersion);
    readItem(FHI::kMinorVersion);
  }
  else
  {
    throw ios::failure(kErrFmtBadInputFileType);
  }
}// end of readHeaderFromInputFile
//----------------------------------------------------------------------------------------------------------------------

/**
 * Read header from output file (necessary for checkpoint-restart).
 */
void Hdf5FileHeader::readHeaderFromOutputFile(Hdf5File& outputFile)
{
  // Get file root handle
  hid_t rootGroup = outputFile.getRootGroup();

  // Shortcut to read an item.
  auto readItem = [this, &outputFile, &rootGroup](FHI item)
  {
    mHeaderValues[item] = outputFile.readStringAttribute(rootGroup, "/", sHeaderNames[item]);
  };// readItem

  readItem(FHI::kFileType);

  if (getFileType() == FileType::kOutput)
  {
    readItem(FHI::kTotalExecutionTime);
    readItem(FHI::kDataLoadTime);
    readItem(FHI::kPreProcessingTime);
    readItem(FHI::kSimulationTime);
    readItem(FHI::kPostProcessingTime);
  }
  else
  {
    throw ios::failure(kErrFmtBadOutputFileType);
  }
}// end of readHeaderFromOutputFile
//----------------------------------------------------------------------------------------------------------------------

/**
 * Read the file header form the checkpoint file.
 */
void Hdf5FileHeader::readHeaderFromCheckpointFile(Hdf5File& checkpointFile)
{
  // Get file root handle
  hid_t rootGroup = checkpointFile.getRootGroup();

  // Shortcut to read an item.
  auto readItem = [this, &checkpointFile, &rootGroup](FHI item)
  {
    mHeaderValues[item] = checkpointFile.readStringAttribute(rootGroup,"/", sHeaderNames[item]);
  };// readItem

  // Read file type
  readItem(FHI::kFileType);

  if (getFileType() == FileType::kCheckpoint)
  {
    readItem(FHI::kCreatedBy);
    readItem(FHI::kCreationDate);
    readItem(FHI::kFileDescription);
    readItem(FHI::kMajorVersion);
    readItem(FHI::kMinorVersion);
  }
  else
  {
    throw ios::failure(kErrFmtBadCheckpointFileType);
  }
}// end of readHeaderFromCheckpointFile
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write header into the output file.
 */
void Hdf5FileHeader::writeHeaderToOutputFile(Hdf5File& outputFile)
{
  // Get file root handle
  hid_t rootGroup = outputFile.getRootGroup();

  for (const auto& it : sHeaderNames)
  {
    outputFile.writeStringAttribute(rootGroup,  "/", it.second, mHeaderValues[it.first]);
  }
}// end of writeHeaderToOutputFile
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write header to the output file (only a subset of all possible fields are written).
 */
void Hdf5FileHeader::writeHeaderToCheckpointFile(Hdf5File& checkpointFile)
{
  // Get file root handle
  hid_t rootGroup = checkpointFile.getRootGroup();

  // Shortcut to wrote an item.
  auto writeItem = [this, &checkpointFile, &rootGroup](FHI item)
  {
    checkpointFile.writeStringAttribute(rootGroup, "/", sHeaderNames [item], mHeaderValues[item]);
  };// readItem

  // Write header
  writeItem(FHI::kFileType);
  writeItem(FHI::kCreatedBy);
  writeItem(FHI::kCreationDate);
  writeItem(FHI::kFileDescription);
  writeItem(FHI::kMajorVersion);
  writeItem(FHI::kMinorVersion);
}// end of writeHeaderToCheckpointFile
//----------------------------------------------------------------------------------------------------------------------

/**
 * Set code name.
 */
void Hdf5FileHeader::setCodeName(const std::string& codeName)
{
  mHeaderValues[FileHeaderItems::kCreatedBy] = codeName;
};// end of setCodeName
//----------------------------------------------------------------------------------------------------------------------

/**
 * Set actual date and time.
 */
void Hdf5FileHeader::setActualCreationTime()
{
  struct tm* current;
  time_t now;
  time(&now);
  current = localtime(&now);

  mHeaderValues[FileHeaderItems::kCreationDate] = Logger::formatMessage("%02i/%02i/%02i, %02i:%02i:%02i",
                                                  current->tm_mday, current->tm_mon + 1, current->tm_year - 100,
                                                  current->tm_hour, current->tm_min, current->tm_sec);
}// end of setActualCreationTime
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get string representing of currently used file version.
 */
std::string Hdf5FileHeader::getCurrentFileVersionName()
{
  return sFileVersionNames[kCurrentFileVersion].majorVersion + '.' +
         sFileVersionNames[kCurrentFileVersion].minorVersion;
}// end of getCurrentFileVersionName
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get string representing of file version of the actually opened input file.
 */
std::string Hdf5FileHeader::getFileVersionName()
{
  return mHeaderValues[FileHeaderItems::kMajorVersion] + "."  + mHeaderValues[FileHeaderItems::kMinorVersion];
};// end of getFileVersionName
//----------------------------------------------------------------------------------------------------------------------

/**
 * Set major file version.
 */
void Hdf5FileHeader::setMajorFileVersion()
{
  mHeaderValues[FileHeaderItems::kMajorVersion] = sFileVersionNames[kCurrentFileVersion].majorVersion;
};// end of setMajorFileVersion
//----------------------------------------------------------------------------------------------------------------------

/**
 * Set minor file version.
 */
void Hdf5FileHeader::setMinorFileVersion()
{
  mHeaderValues[FileHeaderItems::kMinorVersion] = sFileVersionNames[kCurrentFileVersion].minorVersion;
};// end of setMinorFileVersion
//----------------------------------------------------------------------------------------------------------------------

/**
 * Check major file version.
 */
bool Hdf5FileHeader::checkFileVersion()
{
  return (size_t(getFileVersion()) <= size_t(kCurrentFileVersion));
};// end of checkFileVersion
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get file version as an enum.
 */
Hdf5FileHeader::FileVersion Hdf5FileHeader::getFileVersion()
{
  for (const auto& it : sFileVersionNames)
  {
    if ((it.second.majorVersion == mHeaderValues[FileHeaderItems::kMajorVersion]) &&
        (it.second.minorVersion == mHeaderValues[FileHeaderItems::kMinorVersion]))
    {
      return it.first;
    }
  }

  return FileVersion::kVersionUnknown;
}// end of getFileVersion
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get File type.
 */
Hdf5FileHeader::FileType  Hdf5FileHeader::getFileType()
{
  for (const auto &it : sFileTypesNames)
  {
    if (it.second == mHeaderValues[FileHeaderItems::kFileType])
    {
      return it.first;
    }
  }

  return Hdf5FileHeader::FileType::kUnknown;
}// end of getFileType
//----------------------------------------------------------------------------------------------------------------------

/**
 * Set File type.
 */
void Hdf5FileHeader::setFileType(const Hdf5FileHeader::FileType fileType)
{
  mHeaderValues[FileHeaderItems::kFileType] = sFileTypesNames[fileType];
}// end of setFileType
//----------------------------------------------------------------------------------------------------------------------

/**
 * Set host and the processor name.
 */
void Hdf5FileHeader::setHostInfo()
{
  char hostName[256];

// Unix-like systems (Linux and macOS)
#if defined(__linux__) || defined(__APPLE__)
  gethostname(hostName, 256);
#endif

  // Windows build
  #ifdef _WIN64
    WSADATA wsaData;
    WSAStartup(MAKEWORD(2, 2), &wsaData);
    gethostname(hostName, 256);
    WSACleanup();
  #endif

  mHeaderValues[FileHeaderItems::kHostName]
          = Logger::formatMessage("%s (%s)", hostName, Parameters::getInstance().getProcessorName().c_str());
}// end of setHostName
//----------------------------------------------------------------------------------------------------------------------

/**
 * Set memory consumption.
 */
void Hdf5FileHeader::setMemoryConsumption(const size_t totalMemory)
{
  mHeaderValues[FileHeaderItems::kTotalMemoryConsumption] = Logger::formatMessage("%ld MB", totalMemory);

  mHeaderValues[FileHeaderItems::kPeakMemoryConsumption]
          = Logger::formatMessage("%ld MB", totalMemory / Parameters::getInstance().getNumberOfThreads());

}// end of setMemoryConsumption
//----------------------------------------------------------------------------------------------------------------------

/**
 * Set execution times in file header.
 */
void Hdf5FileHeader::setExecutionTimes(const double totalTime,
                                       const double loadTime,
                                       const double preProcessingTime,
                                       const double simulationTime,
                                       const double postprocessingTime)
{
  // Shortcut to write time into header
  auto writeTime = [this](FHI item, double executionTime)
  {
    mHeaderValues[item] = Logger::formatMessage("%8.2fs", executionTime);
  };// writeTime

  writeTime(FHI::kTotalExecutionTime, totalTime);
  writeTime(FHI::kDataLoadTime,       loadTime);
  writeTime(FHI::kPreProcessingTime,  preProcessingTime);
  writeTime(FHI::kSimulationTime,     simulationTime);
  writeTime(FHI::kPostProcessingTime, postprocessingTime);
}// end of setExecutionTimes
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get execution times stored in the output file header.
 */
void Hdf5FileHeader::getExecutionTimes(double& totalTime,
                                       double& loadTime,
                                       double& preProcessingTime,
                                       double& simulationTime,
                                       double& postprocessingTime)
{
  auto readTime = [this](FHI item) -> double
  {
    return std::stof(mHeaderValues[item]);
  };

  totalTime          = readTime(FHI::kTotalExecutionTime);
  loadTime           = readTime(FHI::kDataLoadTime);
  preProcessingTime  = readTime(FHI::kPreProcessingTime);
  simulationTime     = readTime(FHI::kSimulationTime);
  postprocessingTime = readTime(FHI::kPostProcessingTime);
}// end of getExecutionTimes
//----------------------------------------------------------------------------------------------------------------------

/**
 * Set Number of cores.
 */
void Hdf5FileHeader::setNumberOfCores()
{
  mHeaderValues[FileHeaderItems::kNumberOfCores]
          = Logger::formatMessage("%ld", Parameters::getInstance().getNumberOfThreads());
}// end of setNumberOfCores
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Protected methods ------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//


//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Private methods --------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//
