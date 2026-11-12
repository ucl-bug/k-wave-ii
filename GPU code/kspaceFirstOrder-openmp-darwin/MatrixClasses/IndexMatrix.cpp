/**
 * @file      IndexMatrix.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file containing the class for 64b integer index matrices.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      26 July      2011, 15:16 (created) \n
 *            11 February  2020, 14:43 (revised)
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

#include <MatrixClasses/IndexMatrix.h>
#include <Logger/Logger.h>

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Public methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Constructor allocating memory.
 */
IndexMatrix::IndexMatrix(const DimensionSizes& dimensionSizes)
  : BaseIndexMatrix()
{
  initDimensions(dimensionSizes);
  allocateMemory();
}// end of IndexMatrix
//----------------------------------------------------------------------------------------------------------------------

/**
 * Destructor.
 */
IndexMatrix::~IndexMatrix()
{
  freeMemory();
}// end of ~IndexMatrix
//----------------------------------------------------------------------------------------------------------------------

/**
 * Read data from HDF5 file (only from the root group).
 */
void IndexMatrix::readData(Hdf5File&         file,
                           const MatrixName& matrixName)
{
  // Check the datatype
  if (file.readMatrixDataType(file.getRootGroup(), matrixName) != Hdf5File::MatrixDataType::kIndex)
  {
    throw std::ios::failure(Logger::formatMessage(kErrFmtMatrixNotIndex, matrixName.c_str()));
  }

  // Check the domain type
  if (file.readMatrixDomainType(file.getRootGroup(), matrixName) != Hdf5File::MatrixDomainType::kReal)
  {
    throw std::ios::failure(Logger::formatMessage(kErrFmtMatrixNotReal,matrixName.c_str()));
  }

  // Read data
  file.readCompleteDataset(file.getRootGroup(), matrixName, mDimensionSizes, mData);
}// end of readData
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write data to HDF5 file.
 */
void IndexMatrix::writeData(Hdf5File&         file,
                            const MatrixName& matrixName,
                            const size_t      compressionLevel)
{
  // Set chunks - may be necessary for long index based sensor masks
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

  // Create dataset and write a slab
  hid_t dataset = file.createDataset(file.getRootGroup(),
                                     matrixName,
                                     mDimensionSizes,
                                     chunks,
                                     Hdf5File::MatrixDataType::kIndex,
                                     compressionLevel);

  // Write at position [0,0,0].
  file.writeHyperSlab(dataset, DimensionSizes(0, 0, 0), mDimensionSizes, mData);

  file.closeDataset(dataset);

  // Write data and domain types
  file.writeMatrixDataType(file.getRootGroup(),   matrixName, Hdf5File::MatrixDataType::kIndex);
  file.writeMatrixDomainType(file.getRootGroup(), matrixName, Hdf5File::MatrixDomainType::kReal);
}// end of writeData
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get the top left corner of the index-th cuboid.\n
 * Cuboids are stored as 6-tuples (two 3D coordinates). This gives the first three coordinates.
 */
DimensionSizes IndexMatrix::getTopLeftCorner(const size_t& index) const
{
  size_t x =  mData[6 * index    ];
  size_t y =  mData[6 * index + 1];
  size_t z =  mData[6 * index + 2];

  return DimensionSizes(x, y, z);
}// end of getTopLeftCorner
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get the top bottom right of the index-th cuboid. \n
 * Cuboids are stored as 6-tuples (two 3D coordinates). This gives the first three coordinates.
 */
DimensionSizes IndexMatrix::getBottomRightCorner(const size_t& index) const
{
  size_t x =  mData[6 * index + 3];
  size_t y =  mData[6 * index + 4];
  size_t z =  mData[6 * index + 5];

  return DimensionSizes(x, y, z);
}// end of GetBottomRightCorner
//----------------------------------------------------------------------------------------------------------------------

/**
 * Recompute indeces, MATLAB -> C++.
 */
void IndexMatrix::recomputeIndicesToCPP()
{
  #pragma omp parallel for simd schedule(simd:static)
  for (size_t i = 0; i < mSize; i++)
  {
    mData[i]--;
  }
}// end of recomputeIndicesToCPP
//----------------------------------------------------------------------------------------------------------------------

/**
 * Recompute indeces, C++ -> MATLAB.
 */
void IndexMatrix::recomputeIndicesToMatlab()
{
  #pragma omp parallel for simd schedule(simd:static)
  for (size_t i = 0; i < mSize; i++)
  {
    mData[i]++;
  }
}// end of recomputeIndicesToMatlab
//----------------------------------------------------------------------------------------------------------------------

/**
 * Get total number of elements in all cuboids to be able to allocate output file.
 */
size_t IndexMatrix::getSizeOfAllCuboids() const
{
  size_t elementSum = 0;
  for (size_t cuboidIdx = 0; cuboidIdx < mDimensionSizes.ny; cuboidIdx++)
  {
    elementSum += (getBottomRightCorner(cuboidIdx) - getTopLeftCorner(cuboidIdx)).nElements();
  }

  return elementSum;
}// end of getSizeOfAllCuboids
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
void IndexMatrix::initDimensions(const DimensionSizes& dimensionSizes)
{
  mDimensionSizes = dimensionSizes;

  mSize = dimensionSizes.nx * dimensionSizes.ny * dimensionSizes.nz;
  mCapacity = mSize;
}// end of initDimensions
//----------------------------------------------------------------------------------------------------------------------
