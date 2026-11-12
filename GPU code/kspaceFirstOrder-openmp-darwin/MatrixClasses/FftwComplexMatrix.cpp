/**
 * @file      FftwComplexMatrix.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file containing the class that implements various FFT using the FFTW interface.
 *
 * @version   kspaceFirstOrder2.17
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

#include <stdexcept>

#include <MatrixClasses/FftwComplexMatrix.h>
#include <MatrixClasses/RealMatrix.h>

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
FftwComplexMatrix::FftwComplexMatrix(const DimensionSizes& dimensionSizes)
  : ComplexMatrix(dimensionSizes),
    mR2CFftPlanND(nullptr),  mC2RFftPlanND(nullptr),
    mR2CFftPlan1DX(nullptr), mR2CFftPlan1DY(nullptr), mR2CFftPlan1DZ(nullptr),
    mC2RFftPlan1DX(nullptr), mC2RFftPlan1DY(nullptr), mC2RFftPlan1DZ(nullptr)
{
}// end of FftwComplexMatrix
//----------------------------------------------------------------------------------------------------------------------

/**
 * Destructor.
 */
FftwComplexMatrix::~FftwComplexMatrix()
{
  // free 3D plans
  if (mR2CFftPlanND)  fftwf_destroy_plan(mR2CFftPlanND);
  if (mC2RFftPlanND)  fftwf_destroy_plan(mC2RFftPlanND);

  //free 1D plans.
  if (mR2CFftPlan1DX) fftwf_destroy_plan(mR2CFftPlan1DX);
  if (mR2CFftPlan1DY) fftwf_destroy_plan(mR2CFftPlan1DY);
  if (mR2CFftPlan1DZ) fftwf_destroy_plan(mR2CFftPlan1DZ);

  if (mC2RFftPlan1DX) fftwf_destroy_plan(mC2RFftPlan1DX);
  if (mC2RFftPlan1DY) fftwf_destroy_plan(mC2RFftPlan1DY);
  if (mC2RFftPlan1DZ) fftwf_destroy_plan(mC2RFftPlan1DZ);

  mR2CFftPlanND = nullptr;
  mC2RFftPlanND = nullptr;

  mR2CFftPlan1DX = nullptr;
  mR2CFftPlan1DY = nullptr;
  mR2CFftPlan1DZ = nullptr;

  mC2RFftPlan1DX = nullptr;
  mC2RFftPlan1DY = nullptr;
  mC2RFftPlan1DZ = nullptr;

  // Memory for the data will be freed by ~ComplexMatrix

}// end of ~FftwComplexMatrix
//----------------------------------------------------------------------------------------------------------------------

/**
 * Create an FFTW plan for 2D/3D Real-to-Complex transform.
 */
void FftwComplexMatrix::createR2CFftPlanND(RealMatrix& inMatrix)
{
  if (Parameters::getInstance().isSimulation3D())
  {
    mR2CFftPlanND = fftwf_plan_dft_r2c_3d(inMatrix.getDimensionSizes().nz,
                                          inMatrix.getDimensionSizes().ny,
                                          inMatrix.getDimensionSizes().nx,
                                          inMatrix.getData(),
                                          reinterpret_cast<fftwf_complex*>(mData),
                                          kFftMeasureFlag);
  }
  else if (Parameters::getInstance().isSimulation2D())
  {
    mR2CFftPlanND = fftwf_plan_dft_r2c_2d(inMatrix.getDimensionSizes().ny,
                                          inMatrix.getDimensionSizes().nx,
                                          inMatrix.getData(),
                                          reinterpret_cast<fftwf_complex*>(mData),
                                          kFftMeasureFlag);
  }

  if (!mR2CFftPlanND)
  {
    throw std::runtime_error(kErrFmtCreateR2CFftPlanND);
  }
}// end of createR2CFftPlanND
//----------------------------------------------------------------------------------------------------------------------

/**
 * Create an FFTW plan for 2D/3D Complex-to-Real transform.
 */
void FftwComplexMatrix::createC2RFftPlanND(RealMatrix& outMatrix)
{
  if (Parameters::getInstance().isSimulation3D())
  {
    mC2RFftPlanND = fftwf_plan_dft_c2r_3d(outMatrix.getDimensionSizes().nz,
                                          outMatrix.getDimensionSizes().ny,
                                          outMatrix.getDimensionSizes().nx,
                                          reinterpret_cast<fftwf_complex*>(mData),
                                          outMatrix.getData(),
                                          kFftMeasureFlag);
  }
  else if (Parameters::getInstance().isSimulation2D())
  {
    mC2RFftPlanND = fftwf_plan_dft_c2r_2d(outMatrix.getDimensionSizes().ny,
                                          outMatrix.getDimensionSizes().nx,
                                          reinterpret_cast<fftwf_complex*>(mData),
                                          outMatrix.getData(),
                                          kFftMeasureFlag);
  }

  if (!mC2RFftPlanND)
  {
    throw std::runtime_error(kErrFmtCreateC2RFftPlanND);
  }
}//end of createC2RFftPlanND
//----------------------------------------------------------------------------------------------------------------------

/**
 * Create an FFTW plan for 1D Real-to-Complex transform in the x dimension.
 */
void FftwComplexMatrix::createR2CFftPlan1DX(RealMatrix& inMatrix)
{
  // The FFTW uses here 32b interface although it is internally 64b, it doesn't mind since the size of 1
  // domain will never be bigger than 2^31 - however it it not a clear solution :)
  const int nx  = static_cast<int>(inMatrix.getDimensionSizes().nx);
  const int ny  = static_cast<int>(inMatrix.getDimensionSizes().ny);
  const int nz  = static_cast<int>(inMatrix.getDimensionSizes().nz);
  const int nxR = ((nx / 2) + 1);

  // 1D fft rank and sizes
  const int  rank = 1;
  fftw_iodim dims[1];

  dims[0].is = 1;
  dims[0].n  = nx;
  dims[0].os = 1;

  // Default value
  int        howManyRank = 0;
  // Can fit both 3D and 2D simulations
  fftw_iodim howManyDims[2];

  // Set dimensions for 3D simulations
  if (Parameters::getInstance().isSimulation3D())
  {
    // GNU Compiler + FFTW does it all at once
    #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER)) || defined(__APPLE__)
      // How FFTs we need to perform - Z * Y
      howManyRank = 2;
      // z dim
      howManyDims[0].is = nx * ny;
      howManyDims[0].n  = nz;
      howManyDims[0].os = nxR * ny;

      // y dim
      howManyDims[1].is = nx;
      howManyDims[1].n  = ny;
      howManyDims[1].os = nxR;
    #endif

    // Intel Compiler + MKL does it slab by slab
    #if (defined(__INTEL_COMPILER))
      howManyRank = 1;
      // y dim
      howManyDims[0].is = nx;
      howManyDims[0].n  = ny;
      howManyDims[0].os = nxR;
    #endif
  }
  // Set dimensions for 2D simulations
  else if (Parameters::getInstance().isSimulation2D())
  {
    // How FFTs we need to perform - Y
    howManyRank = 1;

    // y dim
    howManyDims[0].is = nx;
    howManyDims[0].n  = ny;
    howManyDims[0].os = nxR;
  }

  mR2CFftPlan1DX = fftwf_plan_guru_dft_r2c(rank,                                    // 1D FFT rank
                                           dims,                                    // 1D FFT dimensions of x
                                           howManyRank,                             // How many in y and z
                                           howManyDims,                             // Dims and strides in y and z
                                           inMatrix.getData(),                      // Input data
                                           reinterpret_cast<fftwf_complex*>(mData), // Output data
                                           kFftMeasureFlag);                        // Flags

  if (!mR2CFftPlan1DX)
  {
    throw std::runtime_error(kErrFmtCreateR2CFftPlan1DX);
  }
}// end of createR2CFftPlan1DX
//----------------------------------------------------------------------------------------------------------------------

/**
 * Create an FFTW plan for 1D Real-to-Complex transform in the y dimension.
 */
void FftwComplexMatrix::createR2CFftPlan1DY(RealMatrix& inMatrix)
{
  // The FFTW uses here 32b interface although it is internally 64b, it doesn't mind
  // since the size of 1 domain will never be bigger than 2^31 - however it it not a clear solution :)
  const int nx  = static_cast<int>(inMatrix.getDimensionSizes().nx);
  const int ny  = static_cast<int>(inMatrix.getDimensionSizes().ny);
  const int nz  = static_cast<int>(inMatrix.getDimensionSizes().nz);
  const int nyR = ((ny / 2) + 1);

  // 1D FFT definition - over the ny axis
  const int  rank = 1;
  fftw_iodim dims[1];

  dims[0].is = nx;
  dims[0].n  = ny;
  dims[0].os = nx;

  int        howManyRank = 0;
  fftw_iodim howManyDims[2];

  if (Parameters::getInstance().isSimulation3D())
  {
    // GNU Compiler + FFTW does it all at once
    #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER)) || defined(__x86_64__)
      // How FFTs we need to perform - Z * X
      howManyRank = 2;

      // z dim
      howManyDims[0].is = nx * ny;
      howManyDims[0].n  = nz;
      howManyDims[0].os = nx * nyR;

      // x dim
      howManyDims[1].is = 1;
      howManyDims[1].n  = nx;
      howManyDims[1].os = 1;
    #endif

     // Intel Compiler + MKL does it slab by slab
    #if (defined(__INTEL_COMPILER))
      howManyRank = 1;

      // x dim
      howManyDims[0].is = 1;
      howManyDims[0].n  = nx;
      howManyDims[0].os = 1;
    #endif
  }
  // 2D simulation
  else if (Parameters::getInstance().isSimulation2D())
  {
    // How FFTs we need to perform - X
    howManyRank = 1;

    // x dim
    howManyDims[0].is = 1;
    howManyDims[0].n  = nx;
    howManyDims[0].os = 1;
  }

  mR2CFftPlan1DY = fftwf_plan_guru_dft_r2c(rank,                                    // 1D FFT rank
                                           dims,                                    // 1D FFT dimensions of y
                                           howManyRank,                             // How many in x and z
                                           howManyDims,                             // Dims and strides in x and z
                                           inMatrix.getData(),                      // Input data
                                           reinterpret_cast<fftwf_complex*>(mData), // Output data
                                           kFftMeasureFlag);                        // Flags

  if (!mR2CFftPlan1DY)
  {
    throw std::runtime_error(kErrFmtCreateR2CFftPlan1DY);
  }
}// end of createR2CFftPlan1DY
//----------------------------------------------------------------------------------------------------------------------

/**
 * Create an FFTW plan for 1D Real-to-Complex transform in the z dimension.
 */
void FftwComplexMatrix::createR2CFftPlan1DZ(RealMatrix& inMatrix)
{
  if (Parameters::getInstance().isSimulation3D())
  {
    // The FFTW uses here 32b interface although it is internally 64b, it doesn't mind
    // since the size of 1 domain will never be bigger than 2^31 - however it it not a clear solution :)
    const int nx = static_cast<int>(inMatrix.getDimensionSizes().nx);
    const int ny = static_cast<int>(inMatrix.getDimensionSizes().ny);
    const int nz = static_cast<int>(inMatrix.getDimensionSizes().nz);

    // 1D FFT definition - over the ny axis
    const int  rank = 1;
    fftw_iodim dims[1];

    dims[0].is = nx * ny;
    dims[0].n  = nz;
    dims[0].os = nx * ny;

    // GNU Compiler + FFTW
    #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER)) || defined(__APPLE__)
      // How FFTs we need to perform - Y * X
      const int  howManyRank = 2;
      fftw_iodim howManyDims[2];

      // y dim
      howManyDims[0].is = nx;
      howManyDims[0].n  = ny;
      howManyDims[0].os = nx;

      // x dim
      howManyDims[1].is = 1;
      howManyDims[1].n  = nx;
      howManyDims[1].os = 1;
    #endif

    // Intel Compiler + MKL does it slab by slab
    #if (defined(__INTEL_COMPILER))
      const int  howManyRank = 1;
      fftw_iodim howManyDims[1];

      // x dim
      howManyDims[0].is = 1;
      howManyDims[0].n  = nx;
      howManyDims[0].os = 1;
    #endif

    mR2CFftPlan1DZ = fftwf_plan_guru_dft_r2c(rank,                                    // 1D FFT rank
                                             dims,                                    // 1D FFT dimensions of z
                                             howManyRank,                             // How many in x and y
                                             howManyDims,                             // Dims and strides in x and y
                                             inMatrix.getData(),                      // Input data
                                             reinterpret_cast<fftwf_complex*>(mData), // Output data
                                             kFftMeasureFlag);                        // Flags

  }
  // 2D simulation - it does not make any sense to use this
  else if (Parameters::getInstance().isSimulation2D())
  {
    // Throw error when this routine is called for 2D simulations
    throw std::runtime_error(kErrFmtCannotCallR2CFftPlan1DZfor2D);
  }
  if (!mR2CFftPlan1DZ)
  {
    throw std::runtime_error(kErrFmtCreateR2CFftPlan1DZ);
  }
}// end of createR2CFftPlan1DZ
//----------------------------------------------------------------------------------------------------------------------

/**
 * Create FFTW plan for Complex-to-Real transform in the x dimension.
 */
void FftwComplexMatrix::createC2RFftPlan1DX(RealMatrix& outMatrix)
{
  // The FFTW uses here 32b interface although it is internally 64b, it doesn't mind
  // since the size of 1 domain will never be bigger than 2^31 - however it it not a clear solution :)
  const int nx  = static_cast<int>(outMatrix.getDimensionSizes().nx);
  const int ny  = static_cast<int>(outMatrix.getDimensionSizes().ny);
  const int nz  = static_cast<int>(outMatrix.getDimensionSizes().nz);
  const int nxR = ((nx / 2) + 1);

  // 1D FFT definition - over the x axis
  const int  rank = 1;
  fftw_iodim dims[1];

  dims[0].is = 1;
  dims[0].n  = nx;
  dims[0].os = 1;

  int        howManyRank = 0;
  fftw_iodim howManyDims[2];

  // Set dimensions for 3D simulations
  if (Parameters::getInstance().isSimulation3D())
  {
    // GNU Compiler + FFTW
    #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER)) || defined(__APPLE__)
      // How FFTs we need to perform - Z * Y
      howManyRank = 2;

      // z dim
      howManyDims[0].is = nxR * ny;
      howManyDims[0].n  = nz;
      howManyDims[0].os = nx * ny;

      // y dim
      howManyDims[1].is = nxR;
      howManyDims[1].n  = ny;
      howManyDims[1].os = nx;
    #endif

    // Intel Compiler + MKL does it slab by slab
    #if (defined(__INTEL_COMPILER))
      howManyRank = 1;

      // y dim
      howManyDims[0].is = nxR;
      howManyDims[0].n  = ny;
      howManyDims[0].os = nx;
    #endif
  }
  // 2D simulation - it does not make any sense to use this
  else if (Parameters::getInstance().isSimulation2D())
  {
    // How FFTs we need to perform - X
    howManyRank = 1;

    // y dim
    howManyDims[0].is = nxR;
    howManyDims[0].n  = ny;
    howManyDims[0].os = nx;
  }

  mC2RFftPlan1DX = fftwf_plan_guru_dft_c2r(rank,                                    // 1D FFT rank
                                           dims,                                    // 1D FFT dimensions of x
                                           howManyRank,                             // how many in y and z
                                           howManyDims,                             // Dims and strides in y and z
                                           reinterpret_cast<fftwf_complex*>(mData), // input data
                                           outMatrix.getData(),                     // output data
                                           kFftMeasureFlag);                        // flags

  if (!mC2RFftPlan1DX)
  {
    throw std::runtime_error(kErrFmtCreateC2RFftPlan1DX);
  }
}// end of createC2RFftPlan1DX
//----------------------------------------------------------------------------------------------------------------------

 /**
  * Create FFTW plan for Complex-to-Real transform in the y dimension.
  */
void FftwComplexMatrix::createC2RFftPlan1DY(RealMatrix& outMatrix)
{
  // The FFTW uses here 32b interface although it is internally 64b, it doesn't mind
  // since the size of 1 domain will never be bigger than 2^31 - however it it not a clear solution :)
  const int nx  = static_cast<int>(outMatrix.getDimensionSizes().nx);
  const int ny  = static_cast<int>(outMatrix.getDimensionSizes().ny);
  const int nz  = static_cast<int>(outMatrix.getDimensionSizes().nz);
  const int nyR = ((ny / 2) + 1);

  // 1D FFT definition - over the y axis
  constexpr int rank = 1;

  fftw_iodim dims[rank];
  dims[0].is = nx;
  dims[0].n  = ny;
  dims[0].os = nx;

  int        howManyRank = 0;
  fftw_iodim howManyDims[2];

  // Set dimensions for 3D simulations
  if (Parameters::getInstance().isSimulation3D())
  {
    // GNU Compiler + FFTW
    #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))
      // How FFTs we need to perform - Z * X
      howManyRank = 2;

      // z dim
      howManyDims[0].is = nx * nyR;
      howManyDims[0].n  = nz;
      howManyDims[0].os = nx * ny;

      // x dim
      howManyDims[1].is = 1;
      howManyDims[1].n  = nx;
      howManyDims[1].os = 1;
    #endif

    // Intel Compiler + MKL does it slab by slab
    #if (defined(__INTEL_COMPILER))
      howManyRank = 1;

      // x dim
      howManyDims[0].is = 1;
      howManyDims[0].n  = nx;
      howManyDims[0].os = 1;
    #endif
  }
  // 2D simulation - it does not make any sense to use this
  else if (Parameters::getInstance().isSimulation2D())
  {
    howManyRank = 1;

    // x dim
    howManyDims[0].is = 1;
    howManyDims[0].n  = nx;
    howManyDims[0].os = 1;
  }

  mC2RFftPlan1DY = fftwf_plan_guru_dft_c2r(rank,                                    // 1D FFT rank
                                           dims,                                    // 1D FFT dimensions of y
                                           howManyRank,                             // How many in x and z
                                           howManyDims,                             // Dims and strides in x and z
                                           reinterpret_cast<fftwf_complex*>(mData), // Input data
                                           outMatrix.getData(),                     // Output data
                                           kFftMeasureFlag);                        // Flags

  if (!mC2RFftPlan1DY)
  {
    throw std::runtime_error(kErrFmtCreateC2RFftPlan1DY);
  }
}// end of createC2RFftPlan1DY
//----------------------------------------------------------------------------------------------------------------------

/**
 * Create FFTW plan for Complex-to-Real transform in the z dimension.
 */
void FftwComplexMatrix::createC2RFftPlan1DZ(RealMatrix& outMatrix)
{
  if (Parameters::getInstance().isSimulation3D())
  {
    // The FFTW uses here 32b interface although it is internally 64b, it doesn't mind
    // since the size of 1 domain will never be bigger than 2^31 - however it it not a clear solution :)
    const int nx   = static_cast<int> (outMatrix.getDimensionSizes().nx);
    const int ny   = static_cast<int> (outMatrix.getDimensionSizes().ny);
    const int nz   = static_cast<int> (outMatrix.getDimensionSizes().nz);

    // 1D FFT definition - over the z axis
    const int  rank = 1;
    fftw_iodim dims[1];

    dims[0].is = nx * ny;
    dims[0].n  = nz;
    dims[0].os = nx * ny;

    // GNU Compiler + FFTW
    #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER)) || defined(__APPLE__)
      // How FFTs we need to perform - Y * X
      const int  howManyRank = 2;
      fftw_iodim howManyDims[2];

      // y dim
      howManyDims[0].is = nx;
      howManyDims[0].n  = ny;
      howManyDims[0].os = nx;

      // x dim
      howManyDims[1].is = 1;
      howManyDims[1].n  = nx;
      howManyDims[1].os = 1;
    #endif

    // Intel Compiler + MKL does it slab by slab
    #if (defined(__INTEL_COMPILER))
      const int howManyRank = 1;
      fftw_iodim howManyDims[1];

      // x dim
      howManyDims[0].is = 1;
      howManyDims[0].n  = nx;
      howManyDims[0].os = 1;
    #endif

    mC2RFftPlan1DZ = fftwf_plan_guru_dft_c2r(rank,                                    // 1D FFT rank
                                             dims,                                    // 1D FFT dimensions of z
                                             howManyRank,                             // how many in x and y
                                             howManyDims,                             // Dims and strides in x and y
                                             reinterpret_cast<fftwf_complex*>(mData), // input data
                                             outMatrix.getData(),                     // output data
                                             kFftMeasureFlag);                        // flags
  }
  // 2D simulation - it does not make any sense to use this
  else if (Parameters::getInstance().isSimulation2D())
  {
    // Throw error when this routine is called for 2D simulations
    throw std::runtime_error(kErrFmtCannotCallC2RFftPlan1DZfor2D);
  }

  if (!mC2RFftPlan1DZ)
  {
    throw std::runtime_error(kErrFmtCreateC2RFftPlan1DZ);
  }
}// end of createC2RFftPlan1DZ
//----------------------------------------------------------------------------------------------------------------------

/**
 * Computer forward out-of place ND (2D/3D) Real-to-Complex transform.
 */
void FftwComplexMatrix::computeR2CFftND(RealMatrix& inMatrix)
{
  if (mR2CFftPlanND)
  {
    fftwf_execute_dft_r2c(mR2CFftPlanND, inMatrix.getData(), reinterpret_cast<fftwf_complex*>(mData));
  }
  else
  {
    throw std::runtime_error(kErrFmtExecuteR2CFftPlanND);
  }
}// end of computeR2CFftND
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute inverse out-of-place ND (2D/3D) Complex to Real transform.
 */
void FftwComplexMatrix::computeC2RFftND(RealMatrix & outMatrix)
{
  if (mC2RFftPlanND)
  {
    fftwf_execute_dft_c2r(mC2RFftPlanND, reinterpret_cast<fftwf_complex*>(mData), outMatrix.getData());
  }
  else
  {
    throw std::runtime_error(kErrFmtExecuteC2RFftPlanND);
  }
}// end of computeC2RFftND
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute 1D out-of-place Real-to-Complex transform in the x dimension.
 */
void FftwComplexMatrix::computeR2CFft1DX(RealMatrix& inMatrix)
{
  // This will work for both 2D and 3D simulations because of Nz = 1 for 2D cases.
  if (mR2CFftPlan1DX)
  {
    // GNU Compiler + FFTW
    #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))
      fftwf_execute_dft_r2c(mR2CFftPlan1DX,
                            inMatrix.getData(),
                            reinterpret_cast<fftwf_complex*>(mData));
    #endif

    // Intel Compiler + MKL
    #if (defined(__INTEL_COMPILER))
      const DimensionSizes dims = Parameters::getInstance().getFullDimensionSizes();
      for (size_t slab_id = 0; slab_id < dims.nz; slab_id++)
      {
        fftwf_execute_dft_r2c(mR2CFftPlan1DX,
                              &inMatrix.getData()[slab_id * dims.nx * dims.ny],
                              (fftwf_complex *) &mData[slab_id * 2 * (dims.nx / 2 + 1) * dims.ny]);
      }
    #endif
  }
  else
  {
    throw std::runtime_error(kErrFmtExecuteR2CFftPlan1DX);
  }
}// end of computeR2CFft1DX
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute 1D out-of-place Real-to-Complex transform in the Y dimension.
 */
void FftwComplexMatrix::computeR2CFft1DY(RealMatrix& inMatrix)
{
  // This will work for both 2D and 3D simulations because of Nz = 1 for 2D cases.
  if (mR2CFftPlan1DY)
  {
    // GNU Compiler + FFTW
    #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))
      fftwf_execute_dft_r2c(mR2CFftPlan1DY,
                            inMatrix.getData(),
                            reinterpret_cast<fftwf_complex*>(mData));
    #endif

    // Intel Compiler + MKL
    #if (defined(__INTEL_COMPILER))
      const DimensionSizes dims = Parameters::getInstance().getFullDimensionSizes();
      for (size_t slab_id = 0; slab_id < dims.nz; slab_id++)
      {
        fftwf_execute_dft_r2c(mR2CFftPlan1DY,
                              &inMatrix.getData()[slab_id * dims.nx * dims.ny],
                              (fftwf_complex *) &mData[slab_id * dims.nx * 2 * (dims.ny / 2 + 1)]);
      }
    #endif
  }
  else
  {
    throw std::runtime_error(kErrFmtExecuteR2CFftPlan1DY);
  }
}// end of computeR2CFft1DY
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute 1D out-of-place Real-to-Complex transform in the z dimension.
 */
void FftwComplexMatrix::computeR2CFft1DZ(RealMatrix& inMatrix)
{
  // This throws an error if called for 2D  simulations since the plan is not created.
  if (mR2CFftPlan1DZ)
  {
    // GNU Compiler + FFTW
    #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))
      fftwf_execute_dft_r2c(mR2CFftPlan1DZ,
                            inMatrix.getData(),
                            reinterpret_cast<fftwf_complex*>(mData));
    #endif

    // Intel Compiler + MKL
    #if (defined(__INTEL_COMPILER))
      const DimensionSizes dims = Parameters::getInstance().getFullDimensionSizes();
      for (size_t slab_id = 0; slab_id < dims.ny; slab_id++)
      {
        fftwf_execute_dft_r2c(mR2CFftPlan1DZ,
                              &inMatrix.getData()[slab_id * dims.nx],
                              (fftwf_complex *) &mData[slab_id * 2 * dims.nx]);
      }
    #endif
  }
  else
  {
    throw std::runtime_error(kErrFmtExecuteR2CFftPlan1DZ);
  }
}// end of computeR2CFft1DZ
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute 1D out-of-place Complex-to-Real transform in the x dimension.
 */
void FftwComplexMatrix::computeC2RFft1DX(RealMatrix& outMatrix)
{
  // This will work for both 2D and 3D simulations because of Nz = 1 for 2D cases.
  if (mC2RFftPlan1DX)
  {
    // GNU Compiler + FFTW
    #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))
      fftwf_execute_dft_c2r(mC2RFftPlan1DX,
                            reinterpret_cast<fftwf_complex*>(mData),
                            outMatrix.getData());
    #endif

    // Intel Compiler + MKL
    #if (defined(__INTEL_COMPILER))
      const DimensionSizes dims = Parameters::getInstance().getFullDimensionSizes();
      for (size_t slab_id = 0; slab_id < dims.nz; slab_id++)
      {
        fftwf_execute_dft_c2r(mC2RFftPlan1DX,
                              (fftwf_complex *) &mData[slab_id * 2 * (dims.nx / 2 + 1) * dims.ny],
                              &outMatrix.getData()[slab_id * dims.nx * dims.ny]);
      }
    #endif
  }
  else
  {
    throw std::runtime_error(kErrFmtExecuteC2RFftPlan1DX);
  }
}// end of computeR2CFft1DX
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute 1D out-of-place Complex-to-Real transform in the y dimension.
 */
void FftwComplexMatrix::computeC2RFft1DY(RealMatrix& outMatrix)
{
  // This will work for both 2D and 3D simulations because of Nz = 1 for 2D cases.
  if (mC2RFftPlan1DY)
  {
    // GNU Compiler + FFTW
    #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))
      fftwf_execute_dft_c2r(mC2RFftPlan1DY,
                            reinterpret_cast<fftwf_complex*>(mData),
                            outMatrix.getData());
    #endif

    // Intel Compiler + MKL
    #if (defined(__INTEL_COMPILER))
      const DimensionSizes dims = Parameters::getInstance().getFullDimensionSizes();
      for (size_t slab_id = 0; slab_id < dims.nz; slab_id++)
      {
        fftwf_execute_dft_c2r(mC2RFftPlan1DY,
                              (fftwf_complex *) &mData[slab_id * dims.nx * 2 * (dims.ny / 2 + 1)],
                              &outMatrix.getData()[slab_id * dims.nx * dims.ny]);
      }
    #endif
  }
  else
  {
    throw std::runtime_error(kErrFmtExecuteC2RFftPlan1DY);
  }
}// end of computeR2CFft1DY
//----------------------------------------------------------------------------------------------------------------------

/**
 * Compute 1D out-of-place Complex-to-Real transform in the Z dimension
 */
void FftwComplexMatrix::computeC2RFft1DZ(RealMatrix& outMatrix)
{
  // This throws an error if called for 2D  simulations since the plan is not created.
  if (mC2RFftPlan1DZ)
  {
    // GNU Compiler + FFTW
    #if (defined(__GNUC__) || defined(__GNUG__)) && !(defined(__clang__) || defined(__INTEL_COMPILER))
      fftwf_execute_dft_c2r(mC2RFftPlan1DZ,
                            reinterpret_cast<fftwf_complex*>(mData),
                            outMatrix.getData());
    #endif

    // Intel Compiler + MKL
    #if (defined(__INTEL_COMPILER))
      const DimensionSizes dims = Parameters::getInstance().getFullDimensionSizes();
      for (size_t slab_id = 0; slab_id < dims.ny; slab_id++)
      {
        fftwf_execute_dft_c2r(mC2RFftPlan1DZ,
                              (fftwf_complex *) &mData[slab_id * 2 * dims.nx ],
                              &outMatrix.getData()[slab_id * dims.nx]);
      }
    #endif
  }
  else
  {
    throw std::runtime_error(kErrFmtExecuteC2RFftPlan1DZ);
  }
}// end of computeR2CFft1DZ
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Protected methods -------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//


//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Private methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//
