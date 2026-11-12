/**
 * @file      FftwRealMatrix.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file containing the class that implements various DTT using the FFTW interface.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      15 March     2019, 16:58 (created) \n
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

#ifndef FFTW_REAL_MATRIX_H
#define FFTW_REAL_MATRIX_H

#include <fftw3.h>

#include <MatrixClasses/RealMatrix.h>

/**
 * @class   FftwRealMatrix
 * @brief   Class implementing 1D Real-To-Real transforms using FFTW interface.
 * @details Class implementing 1D Real-To-Real transforms along the X dimension on the 2D data.
 *
 */
class FftwRealMatrix : public RealMatrix
{
  public:
    /**
     * @enum    TransformKind
     * @brief   Different kinds of Real-to-Real transforms as defined in FFTW library.
     * @details All used kinds of Real-to-Real transforms in this code. The enum relies on the FFTW kind ordering
     *          in interval [3 - 10].
     */
    enum class TransformKind
    {
      /// DCT-I calculates FFTW REDFT00 transform, not used.
      kDct1 = FFTW_REDFT00,
      /// DCT-II calculates FFTW REDFT10 transform.
      kDct2 = FFTW_REDFT10,
      /// DCT-III calculates FFTW REDFT01 transform.
      kDct3 = FFTW_REDFT01,
      /// DCT-IV calculates FFTW REDFT11 transform.
      kDct4 = FFTW_REDFT11,

      /// DST-I calculates FFTW RODFT00 transform, not used.
      kDst1 = FFTW_RODFT00,
      /// DST-II calculates FFTW RODFT10 transform, not used.
      kDst2 = FFTW_RODFT10,
      /// DST-III calculates FFTW RODFT01 transform, not used.
      kDst3 = FFTW_RODFT01,
      /// DST-IV calculates FFTW RODFT11 transform.
      kDst4 = FFTW_RODFT11
    }; // end of TransformKind

    /// Default constructor not allowed for public.
    FftwRealMatrix() = delete;
    /**
     * @brief Constructor, inherited from RealMatrix.
     * @param [in] dimensionSizes - Dimension sizes of the matrix.
     */
    FftwRealMatrix(const DimensionSizes& dimensionSizes);
    /// Copy constructor not allowed for public.
    FftwRealMatrix(const FftwRealMatrix&) = delete;

    /// Destructor.
    virtual ~FftwRealMatrix() override;

    /// Operator = not allowed for public.
    FftwRealMatrix& operator=(const FftwRealMatrix&) = delete;

    /**
    * @brief Create FFTW plans for 1D Real-to-Real transforms over the Y dimension used for WSWA symmetry.
    * @param [in] inMatrix      - Input matrix serving as scratch place for planning.
    * @throw std::runtime_error - If the plan can't be created.
    *
    * @warning Unless FFTW_ESTIMATE flag is specified, the content of the inMatrix is destroyed!
    */
    void createPlans1DY(RealMatrix& inMatrix);

    /**
     * @brief Compute forward out-of-place 1D R2R transforms of a given kind on 2D domain over the Y dimension.
     * @param [in] kind     - Kind of the transform.
     * @param [in] inMatrix - Input matrix.
     *
     * @throw std::runtime_error - If the plan is not valid.
     */
    void computeForwardR2RFft1DY(const TransformKind kind,
                                 RealMatrix&         inMatrix);

    /**
     * @brief Compute inverse out-of-place 1D R2R transforms of a given kind on 2D domain over the Y dimension.
     * @param [in]  kind      - Kind of the transform.
     * @param [out] outMatrix - Output matrix.
     *
     * @throw std::runtime_error - If the plan is not valid.
     */
    void computeInverseR2RFft1DY(const TransformKind kind,
                                 RealMatrix&         outMatrix);

    /**
     * @brief Compute in-place 1D R2R transforms of a given kind on 2D domain over the Y dimension.
     * @param [in] kind - Kind of the transform.
     *
     * @throw std::runtime_error - If the plan is not valid.
     */
    void computeR2RFft1DY(const TransformKind kind);

  protected:
    /// FFTW plan flag.
    static const unsigned kFftMeasureFlag  = FFTW_MEASURE;

    /// Map with FFTW plans for the 1D Real-to-Real transforms on 2D matrix, in-palace.
    std::map<TransformKind, fftwf_plan> mInPlaceR2RPlans1DY;
    /// Map with FFTW plans for the 1D Real-to-Real transforms on 2D matrix, out-of-place.
    std::map<TransformKind, fftwf_plan> mOutPlaceR2RPlans1DY;

  private:

};// end of FftwRealMatrix
//----------------------------------------------------------------------------------------------------------------------
#endif /* FFTW_REAL_MATRIX_H */
