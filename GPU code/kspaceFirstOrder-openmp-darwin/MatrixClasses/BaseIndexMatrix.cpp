/**
 * @file      BaseIndexMatrix.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file containing the base class for index matrices (based on the size_t datatype).
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      26 July      2011, 14:17 (created) \n
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

#include <MatrixClasses/BaseIndexMatrix.h>
#include <Utils/DimensionSizes.h>

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Public methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Default constructor.
 */
BaseIndexMatrix::BaseIndexMatrix()
  : BaseMatrix(),
    mDimensionSizes(),
    mSize(0),
    mCapacity(0),
    mData(nullptr)
{

}// end of BaseIndexMatrix
//----------------------------------------------------------------------------------------------------------------------

/**
 * Zero all allocated elements.
 */
void BaseIndexMatrix::zeroMatrix()
{
  #pragma omp parallel for simd schedule(simd:static)
  for (size_t i = 0; i < mCapacity; i++)
  {
    mData[i] = size_t(0);
  }
}// end of zeroMatrix
//----------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Protected methods -------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Memory allocation based on the capacity and aligned at kDataAlignment.
 */
void BaseIndexMatrix::allocateMemory()
{
  /* No memory allocated before this function*/
  assert(mData == nullptr);

  mData = (size_t*) _mm_malloc(mCapacity * sizeof (size_t), kDataAlignment);

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
void BaseIndexMatrix::freeMemory()
{
  if (mData)
  {
     _mm_free(mData);
  }

  mData = nullptr;
}// end of freeMemory
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Private methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//
