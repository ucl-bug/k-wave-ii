/**
 * @file      Hdf5File.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file containing a class managing HDF5 files.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      27 July      2012, 14:14 (created) \n
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

#include <iostream>
#include <stdexcept>
#include <ctime>

// Linux and macOS build
#if defined(__linux__) || defined(__APPLE__)
  #include <unistd.h>
#endif

// Windows 64 build
#ifdef _WIN64
  #include <io.h>
#endif

#include <Hdf5/Hdf5File.h>
#include <Parameters/Parameters.h>
#include <Logger/Logger.h>

using std::ios;
using std::string;

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Initialization ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//


const string Hdf5File::kMatrixDomainTypeName = "domain_type";
const string Hdf5File::kMatrixDataTypeName   = "data_type";

/**
 * Initialization of static map with data type names.
 */
std::map<Hdf5File::MatrixDataType, std::string> Hdf5File::sMatrixDataTypeNames
{
  {Hdf5File::MatrixDataType::kFloat, "float"},
  {Hdf5File::MatrixDataType::kIndex, "long"},
};// end of sMatrixDataTypeNames
//----------------------------------------------------------------------------------------------------------------------

/**
 * Initialization of static map with domain type names.
 */
std::map<Hdf5File::MatrixDomainType, std::string> Hdf5File::sMatrixDomainTypeNames
{
  {Hdf5File::MatrixDomainType::kReal,    "real"},
  {Hdf5File::MatrixDomainType::kComplex, "complex"},
};// end of sMatrixDomainTypeNames
//----------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Public methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Constructor.
 */
Hdf5File::Hdf5File()
  : mFile(H5I_BADID),
    mFileName("")
{

}// end of constructor
//----------------------------------------------------------------------------------------------------------------------

/**
 * Destructor.
 */
Hdf5File::~Hdf5File()
{
  if (isOpen()) close();
}//end of destructor
//----------------------------------------------------------------------------------------------------------------------

/**
 * Create the HDF5 file.
 */
void Hdf5File::create(const string& fileName,
                      unsigned int  flags)
{
  // File is opened
  if (isOpen())
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotRecreateFile, fileName.c_str()));
  }

  // Create a new file using default properties.
  mFileName = fileName;

  mFile = H5Fcreate(fileName.c_str(), flags, H5P_DEFAULT, H5P_DEFAULT);

  if (mFile < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotCreateFile, fileName.c_str()));
  }
}// end of create
//----------------------------------------------------------------------------------------------------------------------

/**
 * Open the HDF5 file.
 */
void Hdf5File::open(const string& fileName,
                    unsigned int  flags)
{
  const char* cFileName = fileName.c_str();

  if (isOpen())
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotReopenFile, cFileName));
  };

  mFileName = fileName;

  if (H5Fis_hdf5(cFileName) == 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtNotHdf5File, cFileName));
  }

  mFile = H5Fopen(cFileName, flags, H5P_DEFAULT);

  if (mFile < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtFileNotOpen, cFileName));
  }
}// end of open
//----------------------------------------------------------------------------------------------------------------------

/**
 * Can I access the file.
 */
bool Hdf5File::canAccess(const string& fileName)
{
  #ifdef __linux__
    return (access(fileName.c_str(), F_OK) == 0);
  #endif

  #ifdef _WIN64
    return (_access_s(fileName.c_str(), 0) == 0);
  #endif

  #ifdef __APPLE__
    return (access(fileName.c_str(), F_OK) == 0);
  #endif
}// end of canAccess
//----------------------------------------------------------------------------------------------------------------------

/**
 * Close the HDF5 file.
 */
void Hdf5File::close()
{
  // Terminate access to the file.
  herr_t status = H5Fclose(mFile);

  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotCloseFile, mFileName.c_str()));
  }

  mFileName = "";
  mFile     = H5I_BADID;
}// end of close
//----------------------------------------------------------------------------------------------------------------------

/**
 * Create a HDF5 group at a specified place in the file tree.
 */
hid_t Hdf5File::createGroup(const hid_t       parentGroup,
                            const MatrixName& groupName)
{
  hid_t group = H5Gcreate(parentGroup, groupName.c_str(), H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

  if (group == H5I_INVALID_HID)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotCreateGroup, groupName.c_str(), mFileName.c_str()));
  }

  return group;
}// end of createGroup
//----------------------------------------------------------------------------------------------------------------------

/**
 * Open a HDF5 group at a specified place in the file tree.
 */
hid_t Hdf5File::openGroup(const hid_t       parentGroup,
                          const MatrixName& groupName)
{
  hid_t group = H5Gopen(parentGroup, groupName.c_str(), H5P_DEFAULT);

  if (group == H5I_INVALID_HID)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotOpenGroup, groupName.c_str(), mFileName.c_str()));
  }

  return group;
}// end of openGroup
//----------------------------------------------------------------------------------------------------------------------

/**
 * Close a group.
 */
void Hdf5File::closeGroup(const hid_t group)
{
  H5Gclose(group);
}// end of closeGroup
//----------------------------------------------------------------------------------------------------------------------

/**
 * Create dataset at a specified place in the file tree.
 */
hid_t Hdf5File::createDataset(const hid_t                    parentGroup,
                              const MatrixName&              datasetName,
                              const DimensionSizes&          dimensionSizes,
                              const DimensionSizes&          chunkSizes,
                              const Hdf5File::MatrixDataType matrixDataType,
                              const size_t                   compressionLevel)
{
  const int rank = (dimensionSizes.is4D()) ? 4 : 3;

  hsize_t dims [4];
  hsize_t chunk[4];

  // 4D dataset
  if (dimensionSizes.is4D())
  { // 4D dataset
    dims[0] = dimensionSizes.nt;
    dims[1] = dimensionSizes.nz;
    dims[2] = dimensionSizes.ny;
    dims[3] = dimensionSizes.nx;

    chunk[0] = chunkSizes.nt;
    chunk[1] = chunkSizes.nz;
    chunk[2] = chunkSizes.ny;
    chunk[3] = chunkSizes.nx;
  }
  else
  { // 3D dataset
    dims[0] = dimensionSizes.nz;
    dims[1] = dimensionSizes.ny;
    dims[2] = dimensionSizes.nx;

    chunk[0] = chunkSizes.nz;
    chunk[1] = chunkSizes.ny;
    chunk[2] = chunkSizes.nx;
  }

  hid_t  propertyList;
  herr_t status;

  hid_t dataspace = H5Screate_simple(rank, dims, nullptr);

  // Set chunk size
  propertyList = H5Pcreate(H5P_DATASET_CREATE);

  status = H5Pset_chunk(propertyList, rank, chunk);
  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotOpenDataset, mFileName.c_str(), datasetName.c_str()));
  }

  // Set compression level
  status = H5Pset_deflate(propertyList, static_cast<unsigned int>(compressionLevel));
  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotSetCompression,
                                             mFileName.c_str(),
                                             datasetName.c_str(),
                                             compressionLevel));
  }

  const hid_t datasetType = (matrixDataType == MatrixDataType::kFloat) ? H5T_NATIVE_FLOAT : H5T_STD_U64LE;

  // Create dataset
  hid_t dataset = H5Dcreate(parentGroup,
                            datasetName.c_str(),
                            datasetType,
                            dataspace,
                            H5P_DEFAULT,
                            propertyList,
                            H5P_DEFAULT);

  if (dataset == H5I_INVALID_HID)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotOpenDataset, mFileName.c_str(), datasetName.c_str()));
  }

  H5Pclose(propertyList);

  return dataset;
}// end of createDataset
//----------------------------------------------------------------------------------------------------------------------

/**
 * Open a dataset at a specified place in the file tree.
 */
hid_t Hdf5File::openDataset(const hid_t       parentGroup,
                            const MatrixName& datasetName)
{
  // Open dataset
  hid_t dataset = H5Dopen(parentGroup, datasetName.c_str(), H5P_DEFAULT);

  if (dataset == H5I_INVALID_HID)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotOpenDataset, mFileName.c_str(), datasetName.c_str()));
  }

  return dataset;
}// end of openDataset
//----------------------------------------------------------------------------------------------------------------------

/**
 * Close dataset.
 */
void  Hdf5File::closeDataset(const hid_t dataset)
{
  H5Dclose(dataset);
}// end of closeDataset
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write a hyperslab into the dataset, float version.
 */
template<class T>
void Hdf5File::writeHyperSlab(const hid_t           dataset,
                              const DimensionSizes& position,
                              const DimensionSizes& size,
                              const T*              data)
{
  herr_t status;
  hid_t filespace, memspace;

  // Get file space to find out number of dimensions
  filespace = H5Dget_space(dataset);
  const int rank = H5Sget_simple_extent_ndims(filespace);

  // Select sizes and positions, windows hack
  hsize_t nElement[4];
  hsize_t offset[4];

  // 3D dataset
  if (rank == 3)
  {
    nElement[0] = size.nz;
    nElement[1] = size.ny;
    nElement[2] = size.nx;

    offset[0] = position.nz;
    offset[1] = position.ny;
    offset[2] = position.nx;
  }
  else // 4D dataset
  {
    nElement[0] = size.nt;
    nElement[1] = size.nz;
    nElement[2] = size.ny;
    nElement[3] = size.nx;

    offset[0] = position.nt;
    offset[1] = position.nz;
    offset[2] = position.ny;
    offset[3] = position.nx;
  }

  // Select hyperslab
  status = H5Sselect_hyperslab(filespace, H5S_SELECT_SET, offset, nullptr, nElement, nullptr);
  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotWriteDataset, ""));
  }

  // Assign memspace
  memspace = H5Screate_simple(rank, nElement, nullptr);


  // Set status to error value to catch unknown data type.
  status = -1;
  // Write based on datatype
  if (std::is_same<T, size_t>())
  {
    status = H5Dwrite(dataset, H5T_STD_U64LE, memspace, filespace, H5P_DEFAULT, data);
  }
  if (std::is_same<T, float>())
  {
    status = H5Dwrite(dataset, H5T_NATIVE_FLOAT, memspace, filespace, H5P_DEFAULT, data);
  }

  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotWriteDataset, ""));
  }

  H5Sclose(memspace);
  H5Sclose(filespace);
}// end of writeHyperSlab
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write a hyperslab into the dataset, float version explicit instance.
 */
template
void Hdf5File::writeHyperSlab<float>(const hid_t           dataset,
                                     const DimensionSizes& position,
                                     const DimensionSizes& size,
                                     const float*          data);
//----------------------------------------------------------------------------------------------------------------------
/**
 * Write a hyperslab into the dataset, index version explicit instance.
 */
template
void Hdf5File::writeHyperSlab<size_t>(const hid_t           dataset,
                                      const DimensionSizes& position,
                                      const DimensionSizes& size,
                                      const size_t*         data);
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write a cuboid selected within the matrixData into a hyperslab.
 */
void Hdf5File::writeCuboidToHyperSlab(const hid_t           dataset,
                                      const DimensionSizes& hyperslabPosition,
                                      const DimensionSizes& cuboidPosition,
                                      const DimensionSizes& cuboidSize,
                                      const DimensionSizes& matrixDimensions,
                                      const float*          matrixData)
{
  herr_t status;
  hid_t  filespace, memspace;

  constexpr int rank = 4;

  // Select sizes and positions
  // The T here is always 1 (only one timestep)
  hsize_t slabSize[rank]        = {1, cuboidSize.nz, cuboidSize.ny, cuboidSize.nx};
  hsize_t offsetInDataset[rank] = {hyperslabPosition.nt,
                                   hyperslabPosition.nz,
                                   hyperslabPosition.ny,
                                   hyperslabPosition.nx};
  hsize_t offsetInMatrixData[]  = {cuboidPosition.nz,   cuboidPosition.ny,   cuboidPosition.nx};
  hsize_t matrixSize[]          = {matrixDimensions.nz, matrixDimensions.ny, matrixDimensions.nx};


  // Select hyperslab in the HDF5 dataset
  filespace = H5Dget_space(dataset);
  status    = H5Sselect_hyperslab(filespace, H5S_SELECT_SET, offsetInDataset, nullptr, slabSize, nullptr);
  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotWriteDataset, ""));
  }

  // Assign memspace and select the cuboid in the sampled matrix
  memspace = H5Screate_simple(3, matrixSize, nullptr);
  status   = H5Sselect_hyperslab(memspace,
                                 H5S_SELECT_SET,
                                 offsetInMatrixData,
                                 nullptr,
                                 slabSize + 1, // Slab size has to be 3D in this case (done by skipping the T dimension)
                                 nullptr);
  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotWriteDataset, ""));
  }

  // Write the data
  status = H5Dwrite(dataset, H5T_NATIVE_FLOAT, memspace, filespace, H5P_DEFAULT, matrixData);
  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotWriteDataset, ""));
  }

  // Close memspace and filespace
  H5Sclose(memspace);
  H5Sclose(filespace);
}// end of writeCuboidToHyperSlab
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write sensor data selected by the sensor mask.
 */
void Hdf5File::writeSensorByMaskToHyperSlab(const hid_t           dataset,
                                            const DimensionSizes& hyperslabPosition,
                                            const size_t          indexSensorSize,
                                            const size_t*         indexSensorData,
                                            const DimensionSizes& matrixDimensions,
                                            const float*          matrixData)
{
  herr_t status;
  hid_t  filespace, memspace;

  constexpr int rank = 3;

  // Select sizes and positions
  // Only one timestep
  hsize_t slabSize[rank]        = {1, 1, indexSensorSize};
  hsize_t offsetInDataset[rank] = {hyperslabPosition.nz, hyperslabPosition.ny, hyperslabPosition.nx};

  // Treat as a 1D array
  hsize_t matrixSize = matrixDimensions.nz * matrixDimensions.ny * matrixDimensions.nx;


  // Select hyperslab in the HDF5 dataset
  filespace = H5Dget_space(dataset);
  status    = H5Sselect_hyperslab(filespace, H5S_SELECT_SET, offsetInDataset, nullptr, slabSize, nullptr);
  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotWriteDataset, ""));
  }

  // Assign 1D memspace and select the elements within the array
  memspace = H5Screate_simple(1, &matrixSize, nullptr);
  status   = H5Sselect_elements(memspace,
                                H5S_SELECT_SET,
                                indexSensorSize,
                               (hsize_t*) (indexSensorData));
  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotWriteDataset, ""));
  }

  // Write the data
  status = H5Dwrite(dataset, H5T_NATIVE_FLOAT, memspace, filespace, H5P_DEFAULT, matrixData);
  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotWriteDataset, ""));
  }

  // Close memspace and filespace
  H5Sclose(memspace);
  H5Sclose(filespace);
}// end of writeSensorByMaskToHyperSlab
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write a scalar value at a specified place in the file tree.
 */
template<class T>
void Hdf5File::writeScalarValue(const hid_t       parentGroup,
                                const MatrixName& datasetName,
                                const T           value)
{
  constexpr int rank = 3;
  const hsize_t dims[] = {1, 1, 1};

  hid_t  dataset   = H5I_INVALID_HID;
  hid_t  dataspace = H5I_INVALID_HID;
  hid_t  datatype  = H5I_INVALID_HID;
  herr_t status;

  if (std::is_same<T, float>())
  {
    datatype = H5T_NATIVE_FLOAT;
  }

  if (std::is_same<T, size_t>())
  {
    datatype = H5T_STD_U64LE;
  }

  const char* cDatasetName = datasetName.c_str();
  if (H5LTfind_dataset(parentGroup, cDatasetName) == 1)
  { // Dataset already exists (from previous simulation leg) open it
    dataset = openDataset(parentGroup,cDatasetName);
  }
  else
  { // Dataset does not exist yet -> create it
    dataspace = H5Screate_simple(rank, dims, nullptr);
    dataset   = H5Dcreate(parentGroup,
                          cDatasetName,
                          datatype,
                          dataspace,
                          H5P_DEFAULT,
                          H5P_DEFAULT,
                          H5P_DEFAULT);
  }

  // Was created correctly?
  if (dataset == H5I_INVALID_HID)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotWriteDataset, cDatasetName));
  }

  status = H5Dwrite(dataset, datatype, H5S_ALL, H5S_ALL, H5P_DEFAULT, &value);
  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotWriteDataset, cDatasetName));
  }

  if (std::is_same<T, float>())
  {
    writeMatrixDataType(parentGroup, datasetName, MatrixDataType::kFloat);
  }
  if (std::is_same<T, size_t>())
  {
    writeMatrixDataType(parentGroup, datasetName, MatrixDataType::kIndex);
  }
  writeMatrixDomainType(parentGroup, datasetName, MatrixDomainType::kReal);

}// end of writeScalarValue
//----------------------------------------------------------------------------------------------------------------------

/**
 *  Write a scalar value at a specified place in the file tree, float value explicit instance.
 */
template
void Hdf5File::writeScalarValue<float>
                               (const hid_t       parentGroup,
                                const MatrixName& datasetName,
                                const float       value);
//----------------------------------------------------------------------------------------------------------------------
/**
 * Write a scalar value at a specified place in the file tree, index value explicit instance.
 */
template
void Hdf5File::writeScalarValue<size_t>
                               (const hid_t       parentGroup,
                                const MatrixName& datasetName,
                                const size_t      value);
//----------------------------------------------------------------------------------------------------------------------

/**
 * Read a scalar value at a specified place in the file tree.
 */
template<class T>
void Hdf5File::readScalarValue(const hid_t       parentGroup,
                               const MatrixName& datasetName,
                               T&                value)
{
  readCompleteDataset(parentGroup, datasetName, DimensionSizes(1,1,1), &value);
}// end of readScalarValue
//----------------------------------------------------------------------------------------------------------------------

/**
 * Read a scalar value at a specified place in the file tree, float value, explicit instance.
 */
template
void Hdf5File::readScalarValue<float>
                             (const hid_t       parentGroup,
                              const MatrixName& datasetName,
                              float&            value);
//----------------------------------------------------------------------------------------------------------------------
/**
 * Read a scalar value at a specified place in the file tree, float value, explicit instance
 *
 */
template
void Hdf5File::readScalarValue<size_t>
                              (const hid_t       parentGroup,
                               const MatrixName& datasetName,
                               size_t&           value);
//----------------------------------------------------------------------------------------------------------------------

/**
 * Read data from the dataset at a specified place in the file tree.
 */
template<class T>
void Hdf5File::readCompleteDataset(const hid_t           parentGroup,
                                   const MatrixName&     datasetName,
                                   const DimensionSizes& dimensionSizes,
                                   T*                    data)
{
  const char* cDatasetName = datasetName.c_str();
  // Check Dimensions sizes
  if (getDatasetDimensionSizes(parentGroup, datasetName).nElements() != dimensionSizes.nElements())
  {
    throw ios::failure(Logger::formatMessage(kErrFmtBadDimensionSizes, cDatasetName));
  }

  herr_t status = -1;
  if (std::is_same<T, float>())
  {
    status = H5LTread_dataset(parentGroup, cDatasetName, H5T_NATIVE_FLOAT, data);
  }
  if (std::is_same<T, size_t>())
  {
    status = H5LTread_dataset(parentGroup, cDatasetName, H5T_STD_U64LE, data);
  }

  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotReadDataset, cDatasetName));
  }
}// end of readCompleteDataset
//----------------------------------------------------------------------------------------------------------------------

/**
 * Read data from the dataset at a specified place in the file tree, float version explicit instance.
 */
template
void Hdf5File::readCompleteDataset<float>
                                  (const hid_t           parentGroup,
                                   const MatrixName&     datasetName,
                                   const DimensionSizes& dimensionSizes,
                                   float*                data);
//----------------------------------------------------------------------------------------------------------------------
/**
 * Read data from the dataset at a specified place in the file tree, index version explicit instance.
 */
template
void Hdf5File::readCompleteDataset<size_t>
                                  (const hid_t           parentGroup,
                                   const MatrixName&     datasetName,
                                   const DimensionSizes& dimensionSizes,
                                   size_t*               data);
//----------------------------------------------------------------------------------------------------------------------

 /**
  * Get dimension sizes of the dataset at a specified place in the file tree.
  */
DimensionSizes Hdf5File::getDatasetDimensionSizes(const hid_t       parentGroup,
                                                  const MatrixName& datasetName)
{
  const size_t ndims = getDatasetNumberOfDimensions(parentGroup, datasetName);

  hsize_t dims[4] = {0, 0, 0, 0};

  herr_t status = H5LTget_dataset_info(parentGroup, datasetName.c_str(), dims, nullptr, nullptr);
  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotReadDataset, datasetName.c_str()));
  }

  if (ndims == 3)
  {
    return DimensionSizes(dims[2], dims[1], dims[0]);
  }
  else
  {
    return DimensionSizes(dims[3], dims[2], dims[1], dims[0]);
  }
}// end of getDatasetDimensionSizes
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get number of dimensions of the dataset at a specified place in the file tree.
 */
size_t Hdf5File::getDatasetNumberOfDimensions(const hid_t       parentGroup,
                                              const MatrixName& datasetName)
{
  int dims = 0;

  herr_t status = H5LTget_dataset_ndims(parentGroup, datasetName.c_str(), &dims);
  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotReadDataset, datasetName.c_str()));
  }

  return dims;
}// end of getDatasetNumberOfDimensions
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get dataset element count at a specified place in the file tree.
 */
size_t Hdf5File::getDatasetSize(const hid_t       parentGroup,
                                const MatrixName& datasetName)
{
  hsize_t dims[3] = {0, 0, 0};

  herr_t status = H5LTget_dataset_info(parentGroup, datasetName.c_str(), dims, nullptr, nullptr);
  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotReadDataset, datasetName.c_str()));
  }

  return dims[0] * dims[1] * dims[2];
}// end of getDatasetSize
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write matrix data type into the dataset at a specified place in the file tree.
 */
void Hdf5File::writeMatrixDataType(const hid_t           parentGroup,
                                   const MatrixName&     datasetName,
                                   const MatrixDataType& matrixDataType)
{
  writeStringAttribute(parentGroup,
                       datasetName,
                       kMatrixDataTypeName,
                       sMatrixDataTypeNames[matrixDataType]);
}// end of writeMatrixDataType
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write matrix domain type into the dataset at a specified place in the file tree.
 */
void Hdf5File::writeMatrixDomainType(const hid_t             parentGroup,
                                     const MatrixName&       datasetName,
                                     const MatrixDomainType& matrixDomainType)
{
  writeStringAttribute(parentGroup,
                       datasetName,
                       kMatrixDomainTypeName,
                       sMatrixDomainTypeNames[matrixDomainType]);
}// end of writeMatrixDomainType
//----------------------------------------------------------------------------------------------------------------------

/**
 * Read matrix data type from the dataset at a specified place in the file tree.
 */
Hdf5File::MatrixDataType Hdf5File::readMatrixDataType(const hid_t       parentGroup,
                                                      const MatrixName& datasetName)
{
  const string paramValue = readStringAttribute(parentGroup, datasetName, kMatrixDataTypeName);

  for (const auto& item : sMatrixDataTypeNames)
  {
    if (item.second == paramValue)
    {
      return item.first;
    }
  }

  // paramValue not found
  throw ios::failure(Logger::formatMessage(kErrFmtBadAttributeValue,
                                           datasetName.c_str(),
                                           kMatrixDataTypeName.c_str(),
                                           paramValue.c_str()));

  // This will never be executed (just to prevent warning)
  return MatrixDataType::kFloat;
}// end of readMatrixDataType
//----------------------------------------------------------------------------------------------------------------------

/**
 * Read matrix dataset domain type at a specified place in the file tree.
 */
Hdf5File::MatrixDomainType Hdf5File::readMatrixDomainType(const hid_t       parentGroup,
                                                          const MatrixName& datasetName)
{
  const string paramValue = readStringAttribute(parentGroup, datasetName, kMatrixDomainTypeName);

  for (const auto& item : sMatrixDomainTypeNames)
  {
    if (item.second == paramValue)
    {
      return item.first;
    }
  }

  throw ios::failure(Logger::formatMessage(kErrFmtBadAttributeValue,
                                           datasetName.c_str(),
                                           kMatrixDomainTypeName.c_str(),
                                           paramValue.c_str()));

  // This line will never be executed (just to prevent warning)
  return MatrixDomainType::kReal;
}// end of readMatrixDomainType
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write string attribute at a specified place in the file tree.
 */
void Hdf5File::writeStringAttribute(const hid_t       parentGroup,
                                    const MatrixName& datasetName,
                                    const MatrixName& attributeName,
                                    const string&     value)
{
  herr_t status = H5LTset_attribute_string(parentGroup, datasetName.c_str(), attributeName.c_str(), value.c_str());
  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotWriteAttribute, attributeName.c_str(), datasetName.c_str()));
  }
}// end of writeIntAttribute
//----------------------------------------------------------------------------------------------------------------------

/**
 * Read string attribute  at a specified place in the file tree.
 */
string Hdf5File::readStringAttribute(const hid_t       parentGroup,
                                     const MatrixName& datasetName,
                                     const MatrixName& attributeName)
{
  char value[256] = "";
  herr_t status = H5LTget_attribute_string(parentGroup, datasetName.c_str(), attributeName.c_str(), value);

  if (status < 0)
  {
    throw ios::failure(Logger::formatMessage(kErrFmtCannotReadAttribute, attributeName.c_str(), datasetName.c_str()));
  }

  return string(value);
}// end of readIntAttribute
//----------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Protected methods ------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//


//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Private methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//
