/**
 * @file      BaseMatrix.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file of the common ancestor of all matrix classes. A pure abstract class.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      11 July      2012, 11:34 (created) \n
 *            11 February  2020, 14:43 (revised)
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

#ifndef BASE_MATRIX_H
#define BASE_MATRIX_H

#include <string>
#include <Utils/DimensionSizes.h>
#include <Hdf5/Hdf5File.h>


/**
 * @class BaseMatrix
 * @brief Abstract base class. The common ancestor defining the common interface and allowing derived classes to be
 *        allocated, freed and loaded from the file using the Matrix container.
 *
 * @details Abstract base class. The common ancestor defining the common interface and allowing derived classes to be
 *          allocated, freed and loaded from the file using the Matrix container. The I/O is done via HDF5 files.
 */
class BaseMatrix
{
  public:
    /// Default constructor.
    BaseMatrix() = default;
    /// Copy constructor not allowed.
    BaseMatrix(const BaseMatrix&) = delete;
    /// Destructor.
    virtual ~BaseMatrix() = default;

    /// Operator = not allowed.
    BaseMatrix& operator=(const BaseMatrix&) = delete;

    /**
     * @brief  Get dimension sizes of the matrix.
     * @return Dimension sizes of the matrix.
     */
    virtual const DimensionSizes& getDimensionSizes() const = 0;
    /**
     * @brief  Size of the matrix.
     * @return Number of elements.
     */
    virtual size_t size()     const = 0;
    /**
     * @brief  The capacity of the matrix (this may differ from size due to padding, etc.).
     * @return Capacity of the currently allocated storage.
     */
    virtual size_t capacity() const = 0;

    /**
     * @brief Read matrix from HDF5 file.
     * @param [in] file       - Handle to the HDF5 file.
     * @param [in] matrixName - HDF5 dataset name to read from.
     */
    virtual void readData(Hdf5File&         file,
                          const MatrixName& matrixName) = 0;
    /**
     * @brief Write data into HDF5 file.
     * @param [in] file             - Handle to the HDF5 file.
     * @param [in] matrixName       - HDF5 dataset name to write to.
     * @param [in] compressionLevel - Compression level for the HDF5 dataset.
     */
    virtual void writeData(Hdf5File&         file,
                           const MatrixName& matrixName,
                           const size_t      compressionLevel) = 0;
};// end of BaseMatrix
//----------------------------------------------------------------------------------------------------------------------

#endif /* BASE_MATRIX_H */
