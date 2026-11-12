/**
 * @file      BaseOutputStream.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file of the class saving RealMatrix data into the output HDF5 file.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      11 July      2012, 10:30 (created) \n
 *            11 February  2020, 14:48 (revised)
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

#include <cmath>
#ifdef __x86_64__
#include <immintrin.h>
#else
#include "sse2neon.h"
#endif
#include <limits>

// Windows build needs to undefine macro MINMAX to support std::limits
#ifdef _WIN64
  #ifndef NOMINMAX
    # define NOMINMAX
  #endif

  #include <windows.h>
#endif

#include <OutputStreams/BaseOutputStream.h>
#include <Parameters/Parameters.h>

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Public methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Constructor - there is no sensor mask by default!
 */
BaseOutputStream::BaseOutputStream(Hdf5File&            file,
                                   const MatrixName&    rootObjectName,
                                   const RealMatrix&    sourceMatrix,
                                   const ReduceOperator reduceOp,
                                   float*               bufferToReuse)
  : mFile(file),
    mRootObjectName(rootObjectName),
    mSourceMatrix(sourceMatrix),
    mReduceOp(reduceOp),
    mBufferReuse(bufferToReuse != nullptr),
    mBufferSize(0),
    mStoreBuffer(bufferToReuse)
{

}// end of BaseOutputStream
//----------------------------------------------------------------------------------------------------------------------

/**
 * Apply post-processing on the buffer. It supposes the elements are independent.
 */
void BaseOutputStream::postProcess()
{
  switch (mReduceOp)
  {
    case ReduceOperator::kNone:
    {
      // Do nothing
      break;
    }

    case ReduceOperator::kRms:
    {
      const float scalingCoeff = 1.0f / (Parameters::getInstance().getNt() -
                                         Parameters::getInstance().getSamplingStartTimeIndex());

      #pragma omp parallel for simd schedule(simd:static)
      for (size_t i = 0; i < mBufferSize; i++)
      {
        mStoreBuffer[i] = sqrt(mStoreBuffer[i] * scalingCoeff);
      }
      break;
    }

    case ReduceOperator::kMax:
    {
      // Do nothing
      break;
    }

    case ReduceOperator::kMin:
    {
      // Do nothing
      break;
    }
  }// switch
}// end of postProcess
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Protected methods -------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Allocate memory using a proper memory alignment.
 */
void BaseOutputStream::allocateMemory()
{
  mStoreBuffer = (float*) _mm_malloc(mBufferSize * sizeof(float), kDataAlignment);

  if (!mStoreBuffer)
  {
    throw std::bad_alloc();
  }

  // We need different initialization for different reduction ops.
  switch (mReduceOp)
  {
    case ReduceOperator::kNone:
    {
      // Zero the matrix
      #pragma omp parallel for simd schedule(simd:static)
      for (size_t i = 0; i < mBufferSize; i++)
      {
        mStoreBuffer[i] = 0.0f;
      }
      break;
    }// kNone

    case ReduceOperator::kRms:
    {
      // Zero the matrix
      #pragma omp parallel for simd schedule(simd:static)
      for (size_t i = 0; i < mBufferSize; i++)
      {
        mStoreBuffer[i] = 0.0f;
      }
      break;
    }// kRms

    case ReduceOperator::kMax:
    {
      // Set the values to the highest negative float value
      #pragma omp parallel for simd schedule(simd:static)
      for (size_t i = 0; i < mBufferSize; i++)
      {
        mStoreBuffer[i] = -1.0f * std::numeric_limits<float>::max();
      }
      break;
    }// kMax

    case ReduceOperator::kMin:
    {
      // Set the values to the highest float value
      #pragma omp parallel for simd schedule(simd:static)
      for (size_t i = 0; i < mBufferSize; i++)
      {
        mStoreBuffer[i] = std::numeric_limits<float>::max();
      }
      break;
    }//kMin
  }// switch
}// end of allocateMemory
//----------------------------------------------------------------------------------------------------------------------

/**
 * Free memory.
 */
void BaseOutputStream::freeMemory()
{
  if (mStoreBuffer)
  {
    _mm_free(mStoreBuffer);
    mStoreBuffer = nullptr;
  }
}// end of freeMemory
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Private methods --------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//
