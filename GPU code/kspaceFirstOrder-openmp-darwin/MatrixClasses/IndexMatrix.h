/**
 * @file      IndexMatrix.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file containing the class for 64b integer index matrices.
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

#ifndef INDEX_MATRIX_H
#define INDEX_MATRIX_H

#include <MatrixClasses/BaseIndexMatrix.h>
#include <Utils/DimensionSizes.h>

/**
 * @class   IndexMatrix
 * @brief   The class for 64b unsigned integers (indices). It is used for linear and cuboid corners masks to get the
 *          address of sampled voxels.
 *
 * @details The class for 64b unsigned integers (indices). It is used for linear and cuboid corners masks to get the
 *          get the address of sampled voxels.
 */
class IndexMatrix : public BaseIndexMatrix
{
  public:
    /// Default constructor not allowed.
    IndexMatrix() = delete;
    /**
     * @brief Constructor.
     * @param [in] dimensionSizes - Dimension sizes of the matrix.
     */
    IndexMatrix(const DimensionSizes& dimensionSizes);
    /// Copy constructor not allowed.
    IndexMatrix(const IndexMatrix&) = delete;
    /// Destructor.
    virtual ~IndexMatrix() override;

    /// Operator = is not allowed.
    IndexMatrix& operator=(const IndexMatrix&) = delete;

    /**
     * @brief Read matrix from HDF5 file.
     * @param [in] file       - Handle to the HDF5 file.
     * @param [in] matrixName - HDF5 dataset name to read from.
     * @throw ios::failure    - If error occurred.
     */
    virtual void readData(Hdf5File&         file,
                          const MatrixName& matrixName) override;
    /**
     * @brief Write data into HDF5 file.
     * @param [in] file             - Handle to the HDF5 file.
     * @param [in] matrixName       - HDF5 dataset name to write to.
     * @param [in] compressionLevel - Compression level for the HDF5 dataset.
     * @throw ios::failure          - If an error occurred.
     */
    virtual void writeData(Hdf5File&         file,
                           const MatrixName& matrixName,
                           const size_t      compressionLevel) override;

    /**
     * @brief   Operator [].
     * @details This operator is not used in the code due to persisting performance issues with vectorization.
     * @param   [in] index - 1D index into the matrix.
     * @return  An element of the matrix.
     */
    inline size_t&       operator[](const size_t& index)       { return mData[index]; };
    /**
     * @brief   Operator [], constant version.
     * @details This operator is not used in the code due to persisting performance issues with vectorization.
     * @param   [in] index - 1D index into the matrix.
     * @return  An element of the matrix.
     */
    inline const size_t& operator[](const size_t& index) const { return mData[index]; };

    /**
     * @brief  Get the top left corner of the index-th cuboid.
     * @param  [in] index - Index of the cuboid.
     * @return The top left corner.
     */
    DimensionSizes getTopLeftCorner(const size_t& index)     const;
    /**
     * @brief  Get the top bottom right of the index-th cuboid.
     * @param  [in] index - Index of the cuboid.
     * @return The bottom right corner.
     */
    DimensionSizes getBottomRightCorner(const size_t& index) const;

    ///  Recompute indices MATALAB->C++.
    void recomputeIndicesToCPP();
    ///  Recompute indices C++ -> MATLAB.
    void recomputeIndicesToMatlab();

   /**
    * @brief  Get total number of elements in all cuboids to be able to allocate output file.
    * @return Total sampled grid points.
    */
    size_t getSizeOfAllCuboids() const;

  protected:

  private:
    /// Init dimension.
    void initDimensions(const DimensionSizes& dimensionSizes);
    /// Number of elements to get 8MB block of data.
    static constexpr size_t kChunkSize1D8MB   = 1024 * 1024; //(8MB)
    /// Number of elements to get 1MB block of data.
    static constexpr size_t kChunkSize1D1MB   =  128 * 1024; //(1MB)
    /// Number of elements to get 256KB block of data.
    static constexpr size_t kChunkSize1D128kB =   16 * 1024; //(128KB)
};// end of IndexMatrix
//----------------------------------------------------------------------------------------------------------------------
#endif /* INDEX_MATRIX_H */
