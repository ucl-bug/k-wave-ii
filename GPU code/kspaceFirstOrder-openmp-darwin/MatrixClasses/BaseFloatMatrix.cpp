/**
 * @file      BaseFloatMatrix.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file containing the base class for single precisions floating point numbers (floats).
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      11 July      2011, 12:13 (created) \n
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
#ifdef __x86_64__
  #include <immintrin.h>
#else
  #include "sse2neon.h"
#endif
#include <assert.h>

#include <MatrixClasses/BaseFloatMatrix.h>
#include <Utils/DimensionSizes.h>

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Public methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Default constructor.
 */
BaseFloatMatrix::BaseFloatMatrix()
  : BaseMatrix(),
    mDimensionSizes(),
    mSize(0),
    mCapacity(0),
    mData(nullptr)
{

}// end of BaseFloatMatrix
//----------------------------------------------------------------------------------------------------------------------

/**
 * Copy data from another matrix with same size.
 */
void BaseFloatMatrix::copyData(const BaseFloatMatrix& src)
{
  const float* srcData = src.getData();

  #pragma omp parallel for simd schedule(simd:static) firstprivate(srcData)
  for (size_t i = 0; i < mCapacity; i++)
  {
    mData[i] = srcData[i];
  }
}// end of copyData
//----------------------------------------------------------------------------------------------------------------------

/**
 * Zero all allocated elements in parallel for NUMA first touch.
 */
void BaseFloatMatrix::zeroMatrix()
{
  #pragma omp parallel for simd schedule(simd:static)
  for (size_t i = 0; i < mCapacity; i++)
  {
    mData[i] = 0.0f;
  }
}// end of zeroMatrix
//----------------------------------------------------------------------------------------------------------------------

/**
 * Calculate matrix = scalar / matrix.
 */
void BaseFloatMatrix::scalarDividedBy(const float scalar)
{
  #pragma omp parallel for simd schedule(simd:static) firstprivate(scalar)
  for (size_t i = 0; i < mCapacity; i++)
  {
    mData[i] = scalar / mData[i];
  }
}// end of scalarDividedBy
//----------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Protected methods -------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Memory allocation based on the capacity and aligned at kDataAlignment
 */
void BaseFloatMatrix::allocateMemory()
{
  // No memory allocated before this function
  assert(mData == nullptr);

  mData = (float*) _mm_malloc(mCapacity * sizeof(float), kDataAlignment);

  if (!mData)
  {
    throw std::bad_alloc();
  }

  zeroMatrix();
}// end of allocateMemory
//----------------------------------------------------------------------------------------------------------------------

/**
 * Free memory.
 */
void BaseFloatMatrix::freeMemory()
{
  if (mData)
  {
    _mm_free(mData);
  }

  mData = nullptr;
}// end of freeMemory
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Private methods --------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//
