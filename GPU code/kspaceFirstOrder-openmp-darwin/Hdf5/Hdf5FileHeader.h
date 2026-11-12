/**
 * @file      Hdf5FileHeader.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file containing the class processing file headers.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      24 August    2017, 09:51 (created) \n
 *            11 February  2020, 14:34 (revised)
 *
 * @section   Hdf5FileHeader HDF5 File Header Structure
 *
 * The header includes following information
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
 * \verbatim
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

#ifndef HDF5_FILE_HEADER_H
#define HDF5_FILE_HEADER_H

#include <map>

#include <Hdf5/Hdf5File.h>
#include <Utils/DimensionSizes.h>

/**
 * @class   Hdf5FileHeader
 * @brief   Class for HDF5 file header.
 * @details This class manages all information that can be stored in the input output or checkpoint file header.
 */
class Hdf5FileHeader
{
  public:
    /**
     * @enum    FileHeaderItems
     * @brief   List of all header items.
     * @details List of all header items.
     */
    enum class FileHeaderItems
    {
      /// Code that created the file.
      kCreatedBy,
      /// When the file was created.
      kCreationDate,
      /// Description of the file (e.g. simulation).
      kFileDescription,
      /// Major file version.
      kMajorVersion,
      /// Minor file version.
      kMinorVersion,
      /// File type.
      kFileType,
      /// Machines the code were executed on.
      kHostName,
      /// Total amount of memory consumed by the code.
      kTotalMemoryConsumption,
      /// Peak memory consumption (by process).
      kPeakMemoryConsumption,
      /// Total execution time.
      kTotalExecutionTime,
      /// Time to load data in.
      kDataLoadTime,
      /// Time to preprocess data.
      kPreProcessingTime,
      /// Simulation time.
      kSimulationTime,
      /// Time to postprocess data.
      kPostProcessingTime,
      /// Number of cores the simulation was executed.
      kNumberOfCores
    };

    /**
     * @enum    FileType
     * @brief   HDF5 file type.
     * @details HDF5 file type.
     */
    enum class FileType
    {
      /// Input file.
      kInput,
      /// Output file.
      kOutput,
      /// Checkpoint file.
      kCheckpoint,
      /// Unknown file.
      kUnknown
    };

    /**
     * @enum    FileVersion
     * @brief   HDF5 file version.
     * @details HDF5 file version.
     */
    enum class FileVersion : size_t
    {
      /// Version 1.0.
      kVersion10      = 0,
      /// Version 1.1.
      kVersion11      = 1,
      /// Version 1.2.
      kVersion12      = 2,
      /// Version unknown.
      kVersionUnknown = 3
    };

    /// Constructor.
    Hdf5FileHeader();
    /**
     * @brief Copy constructor.
     * @param [in] src - Source object.
     */
    Hdf5FileHeader(const Hdf5FileHeader& src);
    /// Destructor.
    ~Hdf5FileHeader();
    /**
     * @brief Operator =.
     * @param[in] src - Assignment source.
     */
    Hdf5FileHeader& operator=(const Hdf5FileHeader& src);

    /**
     * @brief Read header from the input file.
     *
     * @param [in, out] inputFile - Input file handle.
     * @throw ios:failure         - If error happens.
     */
    void readHeaderFromInputFile(Hdf5File& inputFile);
    /**
     * @brief   Read header from the output file (necessary for checkpoint-restart).
     * @details Read only execution times (the others are read from the input file, or calculated based on the very last
     *          leg of the simulation). This function is called only if checkpoint-restart is enabled.
     *
     * @param [in, out] outputFile - Output file handle.
     * @throw ios:failure          - If error happens.
     */
    void readHeaderFromOutputFile(Hdf5File& outputFile);
    /**
     * @brief   Read the file header form the checkpoint file.
     * @details We need the header to verify the file version and type.
     *
     * @param [in, out] checkpointFile - Checkpoint file handle.
     * @throw ios:failure              - If error happens.
     */
    void readHeaderFromCheckpointFile(Hdf5File& checkpointFile);

    /**
     * @brief Write header into the output file.
     *
     * @param [in,out] outputFile - Output file handle.
     * @throw ios:failure         - If error happens.
     */
    void writeHeaderToOutputFile(Hdf5File& outputFile);
    /**
     * @brief Write header to the output file (only a subset of all possible fields are written).
     *
     * @param [in, out] checkpointFile - Checkpoint file handle.
     * @throw ios:failure              - If error happens.
     */
    void writeHeaderToCheckpointFile(Hdf5File& checkpointFile);

    /**
     * @brief Set code name.
     * @param [in] codeName - Code version.
     */
    void setCodeName(const std::string& codeName);

    /// Set creation time.
    void setActualCreationTime();

    /**
     * @brief  Get string representing of currently used file version.
     * @return Current file version used in the code in format Major.Minor.
     */
    static std::string getCurrentFileVersionName();

    /**
     * @brief  Get string representing of file version of the actually opened input file.
     * @return File version name of the input file in format Major.Minor.
     */
    std::string getFileVersionName();

    /// Set major file version.
    void setMajorFileVersion();
    /// Set minor file version.
    void setMinorFileVersion();

    /**
     * @brief  Get file version of the input file as an enum.
     * @return File version as an enum.
     */
    FileVersion getFileVersion();

    /**
     * @brief  Check major file version.
     * @return true - If the file version is supported.
     */
    bool checkFileVersion();

    /**
     * @brief  Get File type.
     * @return File type.
     */
    Hdf5FileHeader::FileType getFileType();
    /**
     * @brief Set File type.
     * @param [in] fileType - File type.
     */
    void setFileType(const Hdf5FileHeader::FileType fileType);

    /// Set host info.
    void setHostInfo();
    /**
     * @brief Set memory consumption.
     * @param [in] totalMemory - Total memory consumption.
     */
    void setMemoryConsumption(const size_t totalMemory);

    /**
     * @brief Set execution times in file header.
     *
     * @param [in] totalTime          - Total time.
     * @param [in] loadTime           - Time to load data.
     * @param [in] preProcessingTime  - Preprocessing time.
     * @param [in] simulationTime     - Simulation time.
     * @param [in] postprocessingTime - Post processing time.
     */
    void setExecutionTimes(const double totalTime,
                           const double loadTime,
                           const double preProcessingTime,
                           const double simulationTime,
                           const double postprocessingTime);
    /**
     * @brief Get execution times stored in the output file header.
     *
     * @param [out] totalTime          - Total time.
     * @param [out] loadTime           - Time to load data.
     * @param [out] preProcessingTime  - Preprocessing time.
     * @param [out] simulationTime     - Simulation time.
     * @param [out] postprocessingTime - Post processing time.
     */
    void getExecutionTimes(double& totalTime,
                           double& loadTime,
                           double& preProcessingTime,
                           double& simulationTime,
                           double& postprocessingTime);
    /// Set number of cores.
    void setNumberOfCores();

  protected:

  private:
    /**
     * @struct FileVersionNames
     * @brief  Structure holding the string representation of the file major and minor version.
     */
    struct FileVersionNames
    {
      /// String representation of the major version.
      std::string majorVersion;
      /// String representation of the minor version.
      std::string minorVersion;
    };

    /// Current file version. Cannot be initialized here due to g++ compiler problems.
    static const FileVersion  kCurrentFileVersion;

    /// Map for the header names.
    static std::map<FileHeaderItems, std::string>  sHeaderNames;
    /// Map for the file type names.
    static std::map<FileType, std::string>         sFileTypesNames;
    /// Map for the file type names.
    static std::map<FileVersion, FileVersionNames> sFileVersionNames;

    /// Map for the header values.
    std::map<FileHeaderItems, std::string>         mHeaderValues;
};// Hdf5FileHeader
//----------------------------------------------------------------------------------------------------------------------

#endif /* HDF5_FILE_HEADER_H */
