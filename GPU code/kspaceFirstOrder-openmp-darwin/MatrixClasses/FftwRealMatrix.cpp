/**
 * @file      FftwRealMatrix.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file containing the class that implements various FFT using the FFTW interface.
 *
 * @version   kspaceFirstOrder3D 2.17
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

#include <stdexcept>
#include <array>

#if (defined(__INTEL_COMPILER))
  #include <mkl.h>
#endif

#include <MatrixClasses/FftwRealMatrix.h>

#include <Parameters/Parameters.h>
#include <Logger/Logger.h>

//--------------------------------------------------------------------------------------------------------------------//
//---------------------------------------------------- Constants -----------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Public methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Constructor.
 */
FftwRealMatrix::FftwRealMatrix(const DimensionSizes& dimensionSizes)
  : RealMatrix(dimensionSizes),
    mInPlaceR2RPlans1DY(),
    mOutPlaceR2RPlans1DY()
{

}// end of FftwRealMatrix
//----------------------------------------------------------------------------------------------------------------------

/**
 * Destructor.
 */
FftwRealMatrix::~FftwRealMatrix()
{
  // Delete all created fftw plans
  for (auto& kind : mInPlaceR2RPlans1DY)
  {
    if (kind.second != nullptr)
    {
      fftwf_destroy_plan(kind.second);
    }
  }

  // Delete all created fftw plans
  for (auto& kind : mOutPlaceR2RPlans1DY)
  {
    if (kind.second != nullptr)
    {
      fftwf_destroy_plan(kind.second);
    }
  }

  mInPlaceR2RPlans1DY.clear();
  mOutPlaceR2RPlans1DY.clear();

  // Memory for the data will be freed by ~RealMatrix
}// end of ~FftwRealMatrix
//----------------------------------------------------------------------------------------------------------------------

/**
 * Create FFTW plans for 1D Real-to-Real transforms.
 */
void FftwRealMatrix::createPlans1DY(RealMatrix& inMatrix)
{
  // The FFTW uses here 32b interface although it is internally 64b, it doesn't mind since the size of 1
  // domain will never be bigger than 2^31 - however it it not a clear solution :)
  const int nx  = static_cast<int>(inMatrix.getDimensionSizes().nx);
  const int ny  = static_cast<int>(inMatrix.getDimensionSizes().ny);

  constexpr int rank = 1;
  int howManyRank = 1;

  // 1D FFT definition - over the y axis.
  fftw_iodim dims[rank];
  // How many transforms in every dimension.
  fftw_iodim howManyDims[1];

  // GNU compiler + FFTW
  #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))

    dims[0].is = nx;
    dims[0].n  = ny;
    dims[0].os = nx;

    howManyDims[0].is = 1;
    howManyDims[0].n  = nx;
    howManyDims[0].os = 1;
  #endif

  // Intel Compiler + MKL
  #if (defined(__INTEL_COMPILER))
    dims[0].is = 1;
    dims[0].n  = ny;
    dims[0].os = 1;

    // MKL does not support how many ranks above 0.
    howManyRank = 0;

    // Set MKL number of threads for transposition
    mkl_set_num_threads(Parameters::getInstance().getNumberOfThreads());
    // Execute R2R FFT by a single thread, run multiple FFTW in parallel.
    fftwf_plan_with_nthreads(1);
  #endif

  const std::array<TransformKind, 4> usedTransforms
  {
    TransformKind::kDct2,
    TransformKind::kDct3,
    TransformKind::kDct4,
    TransformKind::kDst4
  };

  for (const auto kind : usedTransforms)
  {
    fftwf_r2r_kind fftwKind = static_cast<fftwf_r2r_kind>(kind);

    mInPlaceR2RPlans1DY[kind] =  fftwf_plan_guru_r2r(rank,             // 1D FFT rank
                                                     dims,             // 1D FFT dimensions of y
                                                     howManyRank,      // How many in x and z
                                                     howManyDims,      // Dims and strides in x and z
                                                     mData,            // Input data
                                                     mData,            // Output data
                                                     &fftwKind,        // FftwKind
                                                     kFftMeasureFlag); // Flags

    // If the plan could not be created, throw an error.
    if (!mInPlaceR2RPlans1DY[kind])
    {
      throw std::runtime_error(Logger::formatMessage(kErrFmtCreateR2RFftPlan1D, kind));
    }

    // MKL version do not use out-of-place r2r transforms
    #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))
      mOutPlaceR2RPlans1DY[kind] =  fftwf_plan_guru_r2r(rank,               // 1D FFT rank
                                                        dims,               // 1D FFT dimensions of y
                                                        howManyRank,        // How many in x and z
                                                        howManyDims,        // Dims and strides in x and z
                                                        inMatrix.getData(), // Input data
                                                        mData,              // Output data
                                                        &fftwKind,          // FftwKind
                                                        kFftMeasureFlag);   // Flags

      // If the plan could not be created, throw an error.
      if (!mOutPlaceR2RPlans1DY[kind])
      {
        throw std::runtime_error(Logger::formatMessage(kErrFmtCreateR2RFftPlan1D, kind));
      }
    #endif
  }

  // Intel Compiler + MKL
  #if (defined(__INTEL_COMPILER))
    // Set the number of FFTW threads to the default value
    fftwf_plan_with_nthreads(Parameters::getInstance().getNumberOfThreads());
  #endif
}// end of createPlans1DY
//----------------------------------------------------------------------------------------------------------------------

/**
 * Computer forward out-of-place 1D Real-to-Real transform.
 */
void FftwRealMatrix::computeForwardR2RFft1DY(const TransformKind kind,
                                             RealMatrix&         inMatrix)
{
  // GNU compiler + FFTW
  #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER)) || defined(__APPLE__)
    if (mOutPlaceR2RPlans1DY[kind])
    {
      fftwf_execute_r2r(mOutPlaceR2RPlans1DY[kind], inMatrix.getData(), mData);
    }
  #endif

  // Intel compiler + MKL
  #if (defined(__INTEL_COMPILER))
    if (mInPlaceR2RPlans1DY[kind])
    {
      // Transpose matrix
      mkl_somatcopy ('r', 't', mDimensionSizes.ny, mDimensionSizes.nx, 1.0f, inMatrix.getData(),
                               mDimensionSizes.nx, mData, mDimensionSizes.ny);

      //Intel Compiler + MKL
      #pragma omp parallel for schedule(static)
      for (size_t slab_id = 0; slab_id < mDimensionSizes.nx; slab_id++)
      {
        fftwf_execute_r2r(mInPlaceR2RPlans1DY[kind],
                          &mData[slab_id * mDimensionSizes.ny],
                          &mData[slab_id * mDimensionSizes.ny]);
      }

      mkl_simatcopy ('r', 't', mDimensionSizes.nx, mDimensionSizes.ny, 1.0f,
                        mData, mDimensionSizes.ny, mDimensionSizes.nx);
    }
  #endif
  else
  {
    throw std::runtime_error(Logger::formatMessage(kErrFmtExecuteR2RFftPlan1D, int(kind)));
  }
}// end of computeForwardR2RFft1DY
//----------------------------------------------------------------------------------------------------------------------

/**
 * Computer inverse out-of-place 1D Real-to-Real transform.
 */
void FftwRealMatrix::computeInverseR2RFft1DY(const TransformKind kind,
                                             RealMatrix&         outMatrix)
{
  // GNU compiler + FFTW
  #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER)) || defined(__APPLE__)
    if (mOutPlaceR2RPlans1DY[kind])
    {
      fftwf_execute_r2r(mOutPlaceR2RPlans1DY[kind], mData, outMatrix.getData());
    }
  #endif

  // Intel compiler + MKL
  #if (defined(__INTEL_COMPILER))
    if (mInPlaceR2RPlans1DY[kind])
    {
      // Transpose matrix
      mkl_simatcopy ('r', 't', mDimensionSizes.ny, mDimensionSizes.nx, 1.0f,
                        mData, mDimensionSizes.nx, mDimensionSizes.ny);

      //Intel Compiler + MKL
      #pragma omp parallel for schedule(static)
      for (size_t slab_id = 0; slab_id < mDimensionSizes.nx; slab_id++)
      {
        fftwf_execute_r2r(mInPlaceR2RPlans1DY[kind],
                          &mData[slab_id * mDimensionSizes.ny],
                          &mData[slab_id * mDimensionSizes.ny]);
      }

      mkl_somatcopy ('r', 't', mDimensionSizes.nx, mDimensionSizes.ny, 1.0f, mData,
                               mDimensionSizes.ny, outMatrix.getData(), mDimensionSizes.nx);
    }
  #endif
  else
  {
    throw std::runtime_error(Logger::formatMessage(kErrFmtExecuteR2RFftPlan1D, int(kind)));
  }
}// end of computeInverseR2RFft1DY
//----------------------------------------------------------------------------------------------------------------------

/**
 * Computer in-place 1D Real-to-Real transform.
 */
void FftwRealMatrix::computeR2RFft1DY(const TransformKind kind)
{
  if (mInPlaceR2RPlans1DY[kind])
  {
    // GNU compiler + FFTW
    #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))
      fftwf_execute_r2r(mInPlaceR2RPlans1DY[kind], mData, mData);
    #endif

    // Intel compiler + MKL
    #if (defined(__INTEL_COMPILER))
      // transpose matrix
      mkl_simatcopy ('r', 't', mDimensionSizes.ny, mDimensionSizes.nx, 1.0f,
                        mData, mDimensionSizes.nx, mDimensionSizes.ny);


      //Intel Compiler + MKL
      #pragma omp parallel for schedule(static)
      for (size_t slab_id = 0; slab_id < mDimensionSizes.nx; slab_id++)
      {
        fftwf_execute_r2r(mInPlaceR2RPlans1DY[kind],
                          &mData[slab_id * mDimensionSizes.ny],
                          &mData[slab_id * mDimensionSizes.ny]);
      }

      mkl_simatcopy ('r', 't', mDimensionSizes.nx, mDimensionSizes.ny, 1.0f, mData,
                               mDimensionSizes.ny, mDimensionSizes.nx);
    #endif
  }
  else
  {
    throw std::runtime_error(Logger::formatMessage(kErrFmtExecuteR2RFftPlan1D, int(kind)));
  }
}// end of computeR2RFft1DY
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Private methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//
