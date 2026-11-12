/**
 * @file      BaseIndexMatrix.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file containing the base class for index matrices (based on the size_t datatype).
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      26 July      2011, 12:17 (created) \n
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

#ifndef BASE_INDEX_MATRIX_H
#define BASE_INDEX_MATRIX_H

#include <MatrixClasses/BaseMatrix.h>
#include <Utils/DimensionSizes.h>

/**
 * @class   BaseIndexMatrix
 * @brief   Abstract base class for index based matrices defining basic interface.
 *          Higher dimensional matrices stored as 1D arrays, row-major order.

 * @details Abstract base class for index based matrices defining basic interface. Higher
 *          dimensional matrices stored as 1D arrays, row-major order. The I/O is done via HDF5 files.
 */
class BaseIndexMatrix : public BaseMatrix
{
  public:
    /// Default constructor.
    BaseIndexMatrix();
    /// Copy constructor not allowed.
    BaseIndexMatrix(const BaseIndexMatrix&) = delete;
    /// Destructor.
    virtual ~BaseIndexMatrix() override = default;

    /// Operator = not allowed.
    BaseIndexMatrix& operator=(const BaseIndexMatrix&) = delete;

    /**
     * @brief  Get dimension sizes of the matrix.
     * @return Dimension sizes of the matrix.
     */
    virtual const DimensionSizes& getDimensionSizes() const override { return mDimensionSizes; };

    /**
     * @brief  Size of the matrix.
     * @return Number of elements.
     */
    virtual size_t size()                             const override { return mSize; };
    /**
     * @brief  The capacity of the matrix (this may differ from size due to padding, etc.).
     * @return Capacity of the currently allocated storage.
     */
    virtual size_t capacity()                         const override { return mCapacity; };

    /**
     * @brief  Get raw data out of the class (for direct kernel access).
     * @return Mutable matrix data.
     */
    virtual size_t*       getData()       { return mData; };
    /**
     * @brief  Get raw data out of the class (for direct kernel access), const version.
     * @return Immutable matrix data.
     */
    virtual const size_t* getData() const { return mData; };

    /// Zero all elements of the matrix (NUMA first touch).
    virtual void zeroMatrix();

  protected:
   /**
    * @brief Aligned memory allocation with zeroing.
    * @throw std::bad_alloc - If there's not enough memory.
    */
    virtual void allocateMemory();
    /// Memory deallocation.
    virtual void freeMemory();

    /// Dimension sizes.
    DimensionSizes mDimensionSizes;

    /// Total number of elements.
    size_t mSize;
    /// Total number of allocated elements (in terms of size_t).
    size_t mCapacity;

    /// Raw matrix data.
    size_t* mData;

  private:

};// end of BaseIndexMatrix
//----------------------------------------------------------------------------------------------------------------------

#endif /* BASE_INDEX_MATRIX_H */
