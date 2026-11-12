/**
 * @file      ComplexMatrix.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file with the class for complex matrices.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      11 July      2011, 14:02 (created) \n
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

#include <MatrixClasses/ComplexMatrix.h>
#include <Logger/Logger.h>

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Public methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Constructor.
 */
ComplexMatrix::ComplexMatrix(const DimensionSizes& dimensionSizes)
  : BaseFloatMatrix()
{
  initDimensions(dimensionSizes);
  allocateMemory();
}// end of ComplexMatrix
//----------------------------------------------------------------------------------------------------------------------

/**
 * Destructor.
 */
ComplexMatrix::~ComplexMatrix()
{
  freeMemory();
}// end of ~ComplexMatrix
//----------------------------------------------------------------------------------------------------------------------

/**
 * Read data from HDF5 file (do some basic checks). Only from the root group.
 */
void ComplexMatrix::readData(Hdf5File&         file,
                             const MatrixName& matrixName)
{
  // Check data type
  if (file.readMatrixDataType(file.getRootGroup(), matrixName) != Hdf5File::MatrixDataType::kFloat)
  {
    throw std::ios::failure(Logger::formatMessage(kErrFmtMatrixNotFloat, matrixName.c_str()));
  }

  // Check domain type
  if (file.readMatrixDomainType(file.getRootGroup(), matrixName) != Hdf5File::MatrixDomainType::kComplex)
  {
    throw std::ios::failure(Logger::formatMessage(kErrFmtMatrixNotComplex, matrixName.c_str()));
  }

  // Initialize dimensions
  DimensionSizes complexDims = mDimensionSizes;
  complexDims.nx = 2 * complexDims.nx;

  // Read data from the file
  file.readCompleteDataset(file.getRootGroup(), matrixName, complexDims, mData);
}// end of readData
//----------------------------------------------------------------------------------------------------------------------

/**
 * Write data to HDF5 file (only from the root group).
 */
void ComplexMatrix::writeData(Hdf5File&         file,
                              const MatrixName& matrixName,
                              const size_t      compressionLevel)
{
  // Set dimensions and chunks
  DimensionSizes complexDims = mDimensionSizes;
  complexDims.nx = 2 * complexDims.nx;

  DimensionSizes chunks = complexDims;
  complexDims.nz = 1;

  // Create a dataset
  hid_t dataset = file.createDataset(file.getRootGroup(),
                                     matrixName,
                                     complexDims,
                                     chunks,
                                     Hdf5File::MatrixDataType::kFloat,
                                     compressionLevel);

  // Write write the matrix at once at position [0,0,0].
  file.writeHyperSlab(dataset, DimensionSizes(0, 0, 0), mDimensionSizes, mData);
  file.closeDataset(dataset);

 // Write data and domain type
  file.writeMatrixDataType(file.getRootGroup()  , matrixName, Hdf5File::MatrixDataType::kFloat);
  file.writeMatrixDomainType(file.getRootGroup(), matrixName, Hdf5File::MatrixDomainType::kComplex);
}// end of writeData
//----------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Protected methods -------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------- Private methods -------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Initialize matrix dimension sizes.
 */
void ComplexMatrix::initDimensions(const DimensionSizes& dimensionSizes)
{
  mDimensionSizes = dimensionSizes;

  mSize     = dimensionSizes.nx * dimensionSizes.ny * dimensionSizes.nz;

  // Compute actual necessary memory sizes
  mCapacity = 2 * mSize;
}// end of initDimensions
//----------------------------------------------------------------------------------------------------------------------
