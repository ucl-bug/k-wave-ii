/**
 * @file      RealMatrix.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file containing the class for real matrices.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      11 July      2011, 10:30 (created) \n
 *            11 February  2020, 14:45 (revised)
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

#include <MatrixClasses/RealMatrix.h>
#include <MatrixClasses/ComplexMatrix.h>
#include <Logger/Logger.h>

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Public methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Constructor.
 */
RealMatrix::RealMatrix(const DimensionSizes& dimensionSizes)
  : BaseFloatMatrix()
{
  initDimensions(dimensionSizes);
  allocateMemory();
}// end of RealMatrix
//----------------------------------------------------------------------------------------------------------------------

/**
 * Destructor.
 */
RealMatrix::~RealMatrix()
{
  freeMemory();
}// end of ~RealMatrix
//----------------------------------------------------------------------------------------------------------------------

/**
 * Read data data from HDF5 file (only from the root group).
 */
void RealMatrix::readData(Hdf5File&         file,
                          const MatrixName& matrixName)
{
  // Test matrix datatype
  if (file.readMatrixDataType(file.getRootGroup(), matrixName) != Hdf5File::MatrixDataType::kFloat)
  {
    throw std::ios::failure(Logger::formatMessage(kErrFmtMatrixNotFloat, matrixName.c_str()));
  }

  // Read matrix domain type
  if (file.readMatrixDomainType(file.getRootGroup(), matrixName) != Hdf5File::MatrixDomainType::kReal)
  {
    throw std::ios::failure(Logger::formatMessage(kErrFmtMatrixNotReal, matrixName.c_str()));
  }

  // Read matrix
  file.readCompleteDataset(file.getRootGroup(), matrixName, mDimensionSizes, mData);
}// end of readData
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write data to HDF5 file (only from the root group).
 */
void RealMatrix::writeData(Hdf5File&         file,
                           const MatrixName& matrixName,
                           const size_t      compressionLevel)
{
  DimensionSizes chunks = mDimensionSizes;
  chunks.nz = 1;

  // 1D matrices - chunk sizes were empirically set.
  if ((mDimensionSizes.ny == 1) && (mDimensionSizes.nz == 1))
  {
    if (mDimensionSizes.nx > 4 * kChunkSize1D8MB)
    { // Chunk = 8MB for big matrices (> 32MB).
      chunks.nx = kChunkSize1D8MB;
    }
    else if (mDimensionSizes.nx > 4 * kChunkSize1D1MB)
    { // Chunk = 1MB for big matrices (> 4 - 32MB).
      chunks.nx = kChunkSize1D1MB;
    }
    else if (mDimensionSizes.nx > 4 * kChunkSize1D128kB)
    { // Chunk = 128kB for big matrices (< 1MB).
      chunks.nx = kChunkSize1D128kB;
    }
  }

  hid_t dataset = file.createDataset(file.getRootGroup(),
                                     matrixName,
                                     mDimensionSizes,
                                     chunks,
                                     Hdf5File::MatrixDataType::kFloat,
                                     compressionLevel);

  // Write at position [0,0,0].
  file.writeHyperSlab(dataset, DimensionSizes(0, 0, 0), mDimensionSizes, mData);

  file.closeDataset(dataset);

  // Write data and domain type
  file.writeMatrixDataType  (file.getRootGroup(), matrixName, Hdf5File::MatrixDataType::kFloat);
  file.writeMatrixDomainType(file.getRootGroup(), matrixName, Hdf5File::MatrixDomainType::kReal);
}// end of writeData
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Protected methods -------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Private methods --------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Set necessary dimensions and auxiliary variables.
 */
void RealMatrix::initDimensions(const DimensionSizes& dimensionSizes)
{
  mDimensionSizes = dimensionSizes;

  mSize     = dimensionSizes.nx * dimensionSizes.ny * dimensionSizes.nz;
  mCapacity = mSize;
}// end of initDimensions
//----------------------------------------------------------------------------------------------------------------------
