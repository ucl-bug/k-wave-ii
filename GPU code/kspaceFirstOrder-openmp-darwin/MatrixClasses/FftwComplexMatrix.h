/**
 * @file      FftwComplexMatrix.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file containing the class that implements various FFT using the FFTW interface.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      09 August    2011, 13:10 (created) \n
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

#ifndef FFTW_COMPLEX_MATRIX_H
#define FFTW_COMPLEX_MATRIX_H

#include <fftw3.h>

#include <MatrixClasses/ComplexMatrix.h>

/**
 * @class   FftwComplexMatrix
 * @brief   Class implementing ND and 1D Real-To-Complex and Complex-To-Real transforms using the FFTW interface.
 * @details Class implementing a single ND (3D, 2D) and many 1D Real-To-Complex and Complex-To-Real transforms
 *          using the FFTW interface.
 * \li If the matrix is 3D, the ND transform is 3D and the batch of 1D goes over the second and third dimension.
 * \li If the matrix is 2D, the ND transform is 2D and the batch of 1D goes over the second dimension.
 */
class FftwComplexMatrix : public ComplexMatrix
{
  public:
    /// Default constructor not allowed for public.
    FftwComplexMatrix() = delete;
    /**
     * @brief Constructor, inherited from ComplexMatrix.
     * @param [in] dimensionSizes - Dimension sizes of the matrix.
     */
    FftwComplexMatrix(const DimensionSizes& dimensionSizes);
    /// Copy constructor not allowed for public.
    FftwComplexMatrix(const FftwComplexMatrix&) = delete;

    /// Destructor.
    virtual ~FftwComplexMatrix() override;

    /// Operator= not allowed for public.
    FftwComplexMatrix& operator= (const FftwComplexMatrix&) = delete;

    //-------------------------------------------- ND planning routines ----------------------------------------------//
    /**
     * @brief Create FFTW plan for ND (2D/3D) Real-to-Complex transform.
     * @param [in] inMatrix      - Input matrix serving as scratch place for planning.
     * @throw std::runtime_error - If the plan can't be created.
     *
     * @warning Unless FFTW_ESTIMATE flag is specified, the content of the inMatrix is destroyed!
     */
    void createR2CFftPlanND(RealMatrix& inMatrix);
    /**
     * @brief Create FFTW plan for ND (2D/3D) Complex-to-Real transform.
     * @param [in] outMatrix     - Output matrix serving as scratch place for planning.
     * @throw std::runtime_error - If the plan can't be created.
     *
     * @warning Unless FFTW_ESTIMATE flag is specified, the content of the outMatrix is destroyed!
     */
    void createC2RFftPlanND(RealMatrix& outMatrix);

    //-------------------------------------------- 1D planning routines ----------------------------------------------//
    /**
     * @brief Create an FFTW plan for 1D Real-to-Complex transform in the x dimension.
     *
     * There are two versions of this routine for GCC + FFTW and ICPC + MKL, otherwise it will not build! \n
     * The FFTW version processes the whole matrix at one while the MKL slab by slab.
     *
     * This routine can be used for both 2D and 3D simulations.
     *
     * @param   [in,out] inMatrix  - Input matrix serving as scratch place for planning.
     * @throw   std::runtime_error - If the plan can't be created.
     *
     * @warning Unless FFTW_ESTIMATE flag is specified, the content of the inMatrix is destroyed!
     */
    void createR2CFftPlan1DX(RealMatrix& inMatrix);
    /**
     * @brief Create an FFTW plan for 1D Real-to-Complex transform in the y dimension.
     *
     * There are two versions of this routine for GCC + FFTW and ICPC + MKL, otherwise it will not build! \n
     * The FFTW version processes the whole matrix at one while the MKL slab by slab.
     *
     * This routine can be used for both 2D and 3D simulations.
     *
     * @param   [in,out] inMatrix  - Input matrix serving as scratch place for planning.
     * @throw   std::runtime_error - If the plan can't be created.
     *
     * @warning Unless FFTW_ESTIMATE flag is specified, the content of the inMatrix is destroyed!
     * @warning The FFTW matrix must be able to store 2 * (nx * (ny /2 + 1) * nz) elements - possibly more than
     *          reduced dims!
     */
    void createR2CFftPlan1DY(RealMatrix& inMatrix);
    /**
     * @brief Create an FFTW plan for 1D Real-to-Complex transform in the z dimension.
     *
     * There are two versions of this routine for GCC + FFTW and ICPC + MKL, otherwise it will not build! \n
     * The FFTW version processes the whole matrix at one while the MKL slab by slab.
     *
     * This routine can only be used for both 3D simulations.
     *
     * @param   [in,out] inMatrix  - Input matrix serving as scratch place for planning.
     * @throw   std::runtime_error - If the plan can't be created.
     *
     * @warning Unless FFTW_ESTIMATE flag is specified, the content of the inMatrix is destroyed!
     * @warning The FFTW matrix must be able to store 2 * (nx * by * (nz / 2 + 1)) elements - possibly more than
     *          reduced dims!
     */
    void createR2CFftPlan1DZ(RealMatrix& inMatrix);

    /**
     * @brief Create FFTW plan for Complex-to-Real transform in the x dimension.
     *
     * There are two versions of this routine for GCC + FFTW and ICPC + MKL, otherwise it will not build! \n
     * The FFTW version processes the whole matrix at one while the MKL slab by slab.
     *
     * This routine can be used for both 2D and 3D simulations.
     *
     * @param   [in,out] outMatrix - Output matrix serving as scratch place for planning.
     * @throw   std::runtime_error - If the plan can't be created.
     *
     * @warning Unless FFTW_ESTIMATE flag is specified, the content of the outMatrix is destroyed!
     */
    void createC2RFftPlan1DX(RealMatrix& outMatrix);
    /**
     * @brief Create FFTW plan for Complex-to-Real transform in the y dimension.
     *
     * There are two versions of this routine for GCC + FFTW and ICPC + MKL, otherwise it will not build! \n
     * The FFTW version processes the whole matrix at one while the MKL slab by slab.
     *
     * This routine can be used for both 2D and 3D simulations.
     *
     * @param   [in,out] outMatrix - Output matrix serving as scratch place for planning.
     * @throw   std::runtime_error - If the plan can't be created.
     *
     * @warning Unless FFTW_ESTIMATE flag is specified, the content of the outMatrix is destroyed!
     */
    void createC2RFftPlan1DY(RealMatrix& outMatrix);
    /**
     * @brief Create FFTW plan for Complex-to-Real transform in the z dimension.
     *
     * There are two versions of this routine for GCC + FFTW and ICPC + MKL, otherwise it will not build! \n
     * The FFTW version processes the whole matrix at one while the MKL slab by slab.
     *
     * This routine can only be used for both 3D simulations.
     *
     * @param   [in,out] outMatrix - Output matrix serving as scratch place for planning.
     * @throw   std::runtime_error - If the plan can't be created.
     *
     * @warning Unless FFTW_ESTIMATE flag is specified, the content of the outMatrix is destroyed!
     */
    void createC2RFftPlan1DZ(RealMatrix& outMatrix);

    //--------------------------------------------- ND compute routines ----------------------------------------------//
    /**
     * @brief Compute forward out-of-place ND (2D/3D) Real-to-Complex transform.
     *
     * @param [in] inMatrix      - Input data for the forward FFT.
     * @throw std::runtime_error - If the plan is not valid.
     */
    void computeR2CFftND(RealMatrix& inMatrix);
    /**
     * @brief Compute forward out-of-place ND (2D/3D) Complex-to-Real FFT.
     *
     * @param [out] outMatrix    - Output of the inverse FFT.
     * @throw std::runtime_error - If the plan is not valid.
     */
    void computeC2RFftND(RealMatrix& outMatrix);

    //--------------------------------------------- 1D compute routines ----------------------------------------------//
    /**
     * @brief Compute 1D out-of-place Real-to-Complex transform in the x dimension.
     *
     * There are two versions of this routine for GCC+FFTW and ICPC + MKL, otherwise it will not build!
     * The FFTW version processes the whole matrix at one while the MKL slab by slab.
     *
     * This routine can be used for both 2D and 3D simulations.
     *
     * @param [in] inMatrix      - Input matrix
     * @throw std::runtime_error - If the plan is not valid.
     */
    void computeR2CFft1DX(RealMatrix& inMatrix);
    /**
     * @brief Compute 1D out-of-place Real-to-Complex transform in the y dimension.
     *
     * There are two versions of this routine for GCC+FFTW and ICPC + MKL, otherwise it will not build!
     * The FFTW version processes the whole matrix at one while the MKL slab by slab.
     *
     * This routine can be used for both 2D and 3D simulations.
     *
     * @param [in] inMatrix      - Input matrix
     * @throw std::runtime_error - If the plan is not valid.
     */
    void computeR2CFft1DY(RealMatrix& inMatrix);
    /**
     * @brief Compute 1D out-of-place Real-to-Complex transform in the z dimension.
     *
     * There are two versions of this routine for GCC+FFTW and ICPC + MKL, otherwise it will not build!
     * The FFTW version processes the whole matrix at one while the MKL slab by slab.
     *
     * This routine can only be used for 3D simulations.
     *
     * @param [in] inMatrix      - Input matrix
     * @throw std::runtime_error - If the plan is not valid.
     */
    void computeR2CFft1DZ(RealMatrix& inMatrix);

    /**
     * @brief Compute 1D out-of-place Complex-to-Real transform in the x dimension.
     *
     * There are two versions of this routine for GCC+FFTW and ICPC + MKL, otherwise it will not build!
     * The FFTW version processes the whole matrix at one while the MKL slab by slab.
     *
     * This routine can be used for both 2D and 3D simulations.
     *
     * @param [out] outMatrix    - Output matrix
     * @throw std::runtime_error - If the plan is not valid.
     */
    void computeC2RFft1DX(RealMatrix& outMatrix);
    /**
     * @brief Compute 1D out-of-place Complex-to-Real transform in the y dimension.
     *
     * There are two versions of this routine for GCC+FFTW and ICPC + MKL, otherwise it will not build!
     * The FFTW version processes the whole matrix at one while the MKL slab by slab.
     *
     * This routine can be used for both 2D and 3D simulations.
     *
     * @param [out] outMatrix    - Output matrix
     * @throw std::runtime_error - If the plan is not valid.
     */
    void computeC2RFft1DY(RealMatrix& outMatrix);
    /**
     * @brief Compute 1D out-of-place Complex-to-Real transform in the z dimension.
     *
     * There are two versions of this routine for GCC+FFTW and ICPC + MKL, otherwise it will not build!
     * The FFTW version processes the whole matrix at one while the MKL slab by slab.
     *
     * This routine can only be used for 3D simulations.
     *
     * @param [out] outMatrix      Output matrix
     * @throw std::runtime_error - If the plan is not valid.
     */
    void computeC2RFft1DZ(RealMatrix& outMatrix);

  protected:
    /// FFTW plan flag.
    static const unsigned kFftMeasureFlag  = FFTW_MEASURE;

    /// FFTW plan for the 2D/3D Real-to-Complex transform.
    fftwf_plan mR2CFftPlanND;
    /// FFTW plan for the 2D/3D Complex-to-Real transform.
    fftwf_plan mC2RFftPlanND;

    /// FFTW plan for the 1D Real-to-Complex transform in the x dimension.
    fftwf_plan mR2CFftPlan1DX;
    /// FFTW plan for the 1D Real-to-Complex transform in the y dimension.
    fftwf_plan mR2CFftPlan1DY;
    /// FFTW plan for the 1D Real-to-Complex transform in the z dimension.
    fftwf_plan mR2CFftPlan1DZ;

    /// FFTW plan for the 1D Complex-to-Real transform in the x dimension.
    fftwf_plan mC2RFftPlan1DX;
    /// FFTW plan for the 1D Complex-to-Real transform in the y dimension.
    fftwf_plan mC2RFftPlan1DY;
    /// FFTW plan for the 1D Complex-to-Real transform in the z dimension.
    fftwf_plan mC2RFftPlan1DZ;

  private:

};// end of FftwComplexMatrix
//----------------------------------------------------------------------------------------------------------------------
#endif /* FFTW_COMPLEX_MATRIX_H */
