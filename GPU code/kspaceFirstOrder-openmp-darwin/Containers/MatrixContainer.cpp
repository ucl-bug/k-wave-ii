/**
 * @file      MatrixContainer.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file containing the matrix container.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      12 July      2012, 10:27 (created) \n
 *            11 February  2020, 14:31 (revised)
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

#include <stdexcept>

#include <Containers/MatrixContainer.h>
#include <Parameters/Parameters.h>
#include <Logger/Logger.h>

#include <MatrixClasses/RealMatrix.h>
#include <MatrixClasses/ComplexMatrix.h>
#include <MatrixClasses/FftwComplexMatrix.h>
#include <MatrixClasses/FftwRealMatrix.h>
#include <MatrixClasses/IndexMatrix.h>
//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Initialization ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Initialization of the static map with matrix names in the HDF5 files.
 */
std::map<MatrixContainer::MatrixIdx, MatrixName> MatrixContainer::sMatrixHdf5Names
{
  {MatrixIdx::kKappa,                     "kappa_r"},
  {MatrixIdx::kSourceKappa,               "source_kappa_r"},
  {MatrixIdx::kC2,                        "c0"},
  {MatrixIdx::kP,                         "p"},

  {MatrixIdx::kRhoX,                      "rhox"},
  {MatrixIdx::kRhoY,                      "rhoy"},
  {MatrixIdx::kRhoZ,                      "rhoz"},

  {MatrixIdx::kUxSgx,                     "ux_sgx"},
  {MatrixIdx::kUySgy,                     "uy_sgy"},
  {MatrixIdx::kUzSgz,                     "uz_sgz"},

  {MatrixIdx::kDuxdx,                     "duxdx"},
  {MatrixIdx::kDuydy,                     "duydy"},
  {MatrixIdx::kDuzdz,                     "duzdz"},

  {MatrixIdx::kRho0,                      "rho0"},
  {MatrixIdx::kDtRho0Sgx,                 "rho0_sgx"},
  {MatrixIdx::kDtRho0Sgy,                 "rho0_sgy"},
  {MatrixIdx::kDtRho0Sgz,                 "rho0_sgz"},

  {MatrixIdx::kDdxKShiftPosR,             "ddx_k_shift_pos_r"},
  {MatrixIdx::kDdxKShiftNegR,             "ddx_k_shift_neg_r"},
  {MatrixIdx::kDdyKShiftPos,              "ddy_k_shift_pos"},
  {MatrixIdx::kDdyKShiftNeg,              "ddy_k_shift_neg"},
  {MatrixIdx::kDdzKShiftPos,              "ddz_k_shift_pos"},
  {MatrixIdx::kDdzKShiftNeg,              "ddz_k_shift_neg"},

  {MatrixIdx::kDdyKWswa,                  "ddy_k_wswa"},
  {MatrixIdx::kDdyKHahs,                  "ddy_k_hahs"},
  {MatrixIdx::kYVecSg,                    "y_vec_sg"},

  {MatrixIdx::kPmlXSgx,                   "pml_x_sgx"},
  {MatrixIdx::kPmlYSgy,                   "pml_y_sgy"},
  {MatrixIdx::kPmlZSgz,                   "pml_z_sgz"},

  {MatrixIdx::kPmlX,                      "pml_x"},
  {MatrixIdx::kPmlY,                      "pml_y"},
  {MatrixIdx::kPmlZ,                      "pml_z"},

  {MatrixIdx::kBOnA,                      "BonA"},
  {MatrixIdx::kAbsorbTau,                 "absorb_tau"},
  {MatrixIdx::kAbsorbEta,                 "absorb_eta"},
  {MatrixIdx::kAbsorbNabla1,              "absorb_nabla1_r"},
  {MatrixIdx::kAbsorbNabla2,              "absorb_nabla2_r"},

  {MatrixIdx::kSensorMaskIndex,            "sensor_mask_index"},
  {MatrixIdx::kSensorMaskCorners,          "sensor_mask_corners"},

  {MatrixIdx::kInitialPressureSourceInput, "p0_source_input"},

  {MatrixIdx::kPressureSourceIndex,        "p_source_index"},
  {MatrixIdx::kVelocitySourceIndex,        "u_source_index"},

  {MatrixIdx::kPressureSourceInput,        "p_source_input"},
  {MatrixIdx::kTransducerSourceInput,      "transducer_source_input"},
  {MatrixIdx::kVelocityXSourceInput,       "ux_source_input"},
  {MatrixIdx::kVelocityYSourceInput,       "uy_source_input"},
  {MatrixIdx::kVelocityZSourceInput,       "uz_source_input"},
  {MatrixIdx::kDelayMask,                  "delay_mask"},

  {MatrixIdx::kDxudxn,                     "dxudxn"},
  {MatrixIdx::kDyudyn,                     "dyudyn"},
  {MatrixIdx::kDzudzn,                     "dzudzn"},

  {MatrixIdx::kDxudxnSgx,                  "dxudxn_sgx"},
  {MatrixIdx::kDyudynSgy,                  "dyudyn_sgy"},
  {MatrixIdx::kDzudznSgz,                  "dzudzn_sgz"},

  {MatrixIdx::kUxShifted,                  "ux_shifted"},
  {MatrixIdx::kUyShifted,                  "uy_shifted"},
  {MatrixIdx::kUzShifted,                  "uz_shifted"},

  {MatrixIdx::kXShiftNegR,                 "x_shift_neg_r"},
  {MatrixIdx::kYShiftNegR,                 "y_shift_neg_r"},
  {MatrixIdx::kZShiftNegR,                 "z_shift_neg_r"},

  {MatrixIdx::kTemp1RealND,                "Temp_1_RSND"},
  {MatrixIdx::kTemp2RealND,                "Temp_2_RSND"},
   // This matrix is in special cases used to preload alpha_coeff to calculate absorb tau
  {MatrixIdx::kTemp3RealND,                "alpha_coeff"},

  {MatrixIdx::kTempFftwX,                  "FFTW_X_temp"},
  {MatrixIdx::kTempFftwY,                  "FFTW_Y_temp"},
  {MatrixIdx::kTempFftwZ,                  "FFTW_Z_temp"},
  {MatrixIdx::kTempFftwShift,              "FFTW_shift_temp"},
};// end of sMatrixHdf5Names
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------- Public methods --------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Constructor.
 */
MatrixContainer::MatrixContainer()
  : mContainer()
{

}// end of Constructor.
//----------------------------------------------------------------------------------------------------------------------

/**
 * Destructor.
 * No need for virtual destructor (no polymorphism).
 */
MatrixContainer::~MatrixContainer()
{
  mContainer.clear();
}// end of ~MatrixContainer
//----------------------------------------------------------------------------------------------------------------------

/**
 * This function creates the list of matrices being used in the simulation. It is done based on the
 * simulation parameters, type and the dimensionality. All matrices records are created here.
 */
void MatrixContainer::init()
{
  using MT = MatrixRecord::MatrixType;
  using MI = MatrixContainer::MatrixIdx;

  const Parameters& params   = Parameters::getInstance();

  DimensionSizes fullDims    = params.getFullDimensionSizes();
  DimensionSizes reducedDims = params.getReducedDimensionSizes();

  const bool isSimulation3D  = params.isSimulation3D();
  const bool isSimulationAS  = params.isSimulationAS();

  constexpr bool kLoad         = true;
  constexpr bool kNoLoad       = false;
  constexpr bool kCheckpoint   = true;
  constexpr bool kNoCheckpoint = false;

  // Lambda routine to add a new matrix into the container. By default the matrix is always added into the container.
  auto addMatrix = [this](MI              matrixIdx,
                          MT              matrixType,
                          DimensionSizes  dimensionSizes,
                          bool            load,
                          bool            checkpoint,
                          bool            present = true)
  {
    // Do not allocate the matrix if the simulation is not 3D and the matrix holds third dimension.
    if (present)
    {
      mContainer[matrixIdx] = MatrixRecord(matrixType, dimensionSizes, load, checkpoint, sMatrixHdf5Names[matrixIdx]);
    }
  };// end of addMatrix

  //--------------------------------------------- Allocate all matrices ----------------------------------------------//

  addMatrix(MI::kKappa, MT::kReal, reducedDims, kNoLoad, kNoCheckpoint);

  if (!params.getC0ScalarFlag())
  {
    addMatrix(MI::kC2,  MT::kReal, fullDims,      kLoad, kNoCheckpoint);
  }

  addMatrix(MI::kP,     MT::kReal, fullDims,    kNoLoad,   kCheckpoint);

  addMatrix(MI::kRhoX,  MT::kReal, fullDims,    kNoLoad,   kCheckpoint);
  addMatrix(MI::kRhoY,  MT::kReal, fullDims,    kNoLoad,   kCheckpoint);
  addMatrix(MI::kRhoZ,  MT::kReal, fullDims,    kNoLoad,   kCheckpoint, isSimulation3D);

  addMatrix(MI::kUxSgx, MT::kReal, fullDims,    kNoLoad,   kCheckpoint);
  addMatrix(MI::kUySgy, MT::kReal, fullDims,    kNoLoad,   kCheckpoint);
  addMatrix(MI::kUzSgz, MT::kReal, fullDims,    kNoLoad,   kCheckpoint, isSimulation3D);

  addMatrix(MI::kDuxdx, MT::kReal, fullDims,    kNoLoad,   kCheckpoint);
  addMatrix(MI::kDuydy, MT::kReal, fullDims,    kNoLoad,   kCheckpoint);
  addMatrix(MI::kDuzdz, MT::kReal, fullDims,    kNoLoad,   kCheckpoint, isSimulation3D);

  if (!params.getRho0ScalarFlag())
  {
    addMatrix(MI::kRho0,         MT::kReal, fullDims,  kLoad, kNoCheckpoint);
    addMatrix(MI::kDtRho0Sgx,    MT::kReal, fullDims,  kLoad, kNoCheckpoint);
    addMatrix(MI::kDtRho0Sgy,    MT::kReal, fullDims,  kLoad, kNoCheckpoint);
    addMatrix(MI::kDtRho0Sgz,    MT::kReal, fullDims,  kLoad, kNoCheckpoint, isSimulation3D);
  }

  // Derivative operators are now generated, if they appear in the input file, they are ignored.
  addMatrix(MI::kDdxKShiftPosR,  MT::kComplex, DimensionSizes(reducedDims.nx, 1, 1), kNoLoad, kNoCheckpoint);
  addMatrix(MI::kDdxKShiftNegR,  MT::kComplex, DimensionSizes(reducedDims.nx ,1, 1), kNoLoad, kNoCheckpoint);

  if (isSimulationAS)
  { // Axisymmetric coordinates
    addMatrix(MI::kDdyKWswa,     MT::kReal, DimensionSizes(1, reducedDims.ny, 1), kNoLoad, kNoCheckpoint);
    addMatrix(MI::kDdyKHahs,     MT::kReal, DimensionSizes(1, reducedDims.ny, 1), kNoLoad, kNoCheckpoint);
    addMatrix(MI::kYVecSg ,      MT::kReal, DimensionSizes(1, reducedDims.ny, 1), kNoLoad, kNoCheckpoint);
  }
  else
  { // Normal coordinates
    addMatrix(MI::kDdyKShiftPos, MT::kComplex, DimensionSizes(1, reducedDims.ny, 1), kNoLoad, kNoCheckpoint);
    addMatrix(MI::kDdyKShiftNeg, MT::kComplex, DimensionSizes(1, reducedDims.ny, 1), kNoLoad, kNoCheckpoint);

    addMatrix(MI::kDdzKShiftPos, MT::kComplex, DimensionSizes(1, 1, reducedDims.nz),
              kNoLoad, kNoCheckpoint, isSimulation3D);
    addMatrix(MI::kDdzKShiftNeg, MT::kComplex, DimensionSizes(1, 1, reducedDims.nz),
              kNoLoad, kNoCheckpoint, isSimulation3D);
  }// k-space variables

  // Pml variables
  addMatrix(MI::kPmlXSgx, MT::kReal, DimensionSizes(fullDims.nx, 1, 1), kNoLoad, kNoCheckpoint);
  addMatrix(MI::kPmlYSgy, MT::kReal, DimensionSizes(1, fullDims.ny, 1), kNoLoad, kNoCheckpoint);
  addMatrix(MI::kPmlZSgz, MT::kReal, DimensionSizes(1, 1, fullDims.nz), kNoLoad, kNoCheckpoint, isSimulation3D);

  addMatrix(MI::kPmlX,    MT::kReal, DimensionSizes(fullDims.nx, 1, 1), kNoLoad, kNoCheckpoint);
  addMatrix(MI::kPmlY,    MT::kReal, DimensionSizes(1, fullDims.ny, 1), kNoLoad, kNoCheckpoint);
  addMatrix(MI::kPmlZ,    MT::kReal, DimensionSizes(1, 1, fullDims.nz), kNoLoad, kNoCheckpoint, isSimulation3D);

  // B on A is heterogeneous
  if (params.getNonLinearFlag() && !params.getBOnAScalarFlag())
  {
    addMatrix(MI::kBOnA, MT::kReal, fullDims, kLoad, kNoCheckpoint);
  }

  // Set absorption matrices
  if (params.getAbsorbingFlag() == Parameters::AbsorptionType::kPowerLaw)
  {
    if (!((params.getC0ScalarFlag()) && (params.getAlphaCoeffScalarFlag())))
    {
      addMatrix(MI::kAbsorbTau,  MT::kReal, fullDims   , kNoLoad, kNoCheckpoint);
      addMatrix(MI::kAbsorbEta,  MT::kReal, fullDims   , kNoLoad, kNoCheckpoint);
    }

    addMatrix(MI::kAbsorbNabla1, MT::kReal, reducedDims, kNoLoad, kNoCheckpoint);
    addMatrix(MI::kAbsorbNabla2, MT::kReal, reducedDims, kNoLoad, kNoCheckpoint);
  }
  else if (params.getAbsorbingFlag() == Parameters::AbsorptionType::kStokes)
  {
    if (!((params.getC0ScalarFlag()) && (params.getAlphaCoeffScalarFlag())))
    {
      addMatrix(MI::kAbsorbTau,  MT::kReal, fullDims   , kNoLoad, kNoCheckpoint);
    }
  }// Absorption

  //---------------------------------- Nonlinear grid - not used in this release -------------------------------------//
   if (params.getNonUniformGridFlag()!= 0)
  {
    addMatrix(MI::kDxudxn,    MT::kReal, DimensionSizes(fullDims.nx, 1, 1), kLoad, kNoCheckpoint);
    addMatrix(MI::kDyudyn,    MT::kReal, DimensionSizes(1, fullDims.ny, 1), kLoad, kNoCheckpoint);
    addMatrix(MI::kDzudzn,    MT::kReal, DimensionSizes(1 ,1, fullDims.nz), kLoad, kNoCheckpoint, isSimulation3D);

    addMatrix(MI::kDxudxnSgx, MT::kReal, DimensionSizes(fullDims.nx, 1, 1), kLoad, kNoCheckpoint);
    addMatrix(MI::kDyudynSgy, MT::kReal, DimensionSizes(1, fullDims.ny, 1), kLoad, kNoCheckpoint);
    addMatrix(MI::kDzudznSgz, MT::kReal, DimensionSizes(1 ,1, fullDims.nz), kLoad, kNoCheckpoint, isSimulation3D);
  }

  //--------------------------------------------------- Sensors ------------------------------------------------------//
  // Linear sensor mask
  if (params.getSensorMaskType() == Parameters::SensorMaskType::kIndex)
  {
    addMatrix(MI::kSensorMaskIndex, MT::kIndex,
              DimensionSizes(params.getSensorMaskIndexSize(), 1, 1),
              kLoad, kNoCheckpoint);
  }

  // Cuboid sensor mask
  if (params.getSensorMaskType() == Parameters::SensorMaskType::kCorners)
  {
    addMatrix(MI::kSensorMaskCorners, MT::kIndex,
              DimensionSizes(6 ,params.getSensorMaskCornersSize(), 1),
              kLoad, kNoCheckpoint);
  }

  //--------------------------------------------------- Sources ------------------------------------------------------//
  // if p0 source flag
  if (params.getInitialPressureSourceFlag() == 1)
  {
    addMatrix(MI::kInitialPressureSourceInput, MT::kReal,fullDims, kLoad, kNoCheckpoint);
  }

  // Velocity source index
  if ((params.getTransducerSourceFlag() != 0) ||
      (params.getVelocityXSourceFlag() != 0)  ||
      (params.getVelocityYSourceFlag() != 0)  ||
      (params.getVelocityZSourceFlag() != 0))
  {
    addMatrix(MI::kVelocitySourceIndex, MT::kIndex,
              DimensionSizes(1 ,1, params.getVelocitySourceIndexSize()),
              kLoad, kNoCheckpoint);
  }

  // Transducer source flag defined
  if (params.getTransducerSourceFlag() != 0)
  {
    addMatrix(MI::kDelayMask,             MT::kIndex,DimensionSizes(1 ,1, params.getVelocitySourceIndexSize()),
              kLoad, kNoCheckpoint);
    addMatrix(MI::kTransducerSourceInput, MT::kReal ,DimensionSizes(1 ,1, params.getTransducerSourceInputSize()),
              kLoad, kNoCheckpoint);
  }

  // Pressure source
  if (params.getPressureSourceFlag() != 0)
  {
    if (params.getPressureSourceMany() == 0)
    { // 1D case
      addMatrix(MI::kPressureSourceInput, MT::kReal,
                DimensionSizes(1 ,1, params.getPressureSourceFlag()),
                kLoad, kNoCheckpoint);
    }
    else
    { // 2D case
     addMatrix(MI::kPressureSourceInput,  MT::kReal,
               DimensionSizes(1 ,params.getPressureSourceIndexSize(), params.getPressureSourceFlag()),
               kLoad, kNoCheckpoint);
    }

    addMatrix(MI::kPressureSourceIndex,   MT::kIndex,
              DimensionSizes(1 ,1, params.getPressureSourceIndexSize()),
              kLoad, kNoCheckpoint);
  }


  // Velocity source
  if (params.getVelocityXSourceFlag() != 0)
  {
    if (params.getVelocitySourceMany() == 0)
    { // 1D
      addMatrix(MI::kVelocityXSourceInput, MT::kReal,
                DimensionSizes(1 ,1, params.getVelocityXSourceFlag()),
                kLoad, kNoCheckpoint);
    }
    else
    { // 2D
      addMatrix(MI::kVelocityXSourceInput, MT::kReal,
                DimensionSizes(1 ,params.getVelocitySourceIndexSize(), params.getVelocityXSourceFlag()),
                kLoad, kNoCheckpoint);
    }
  }// ux_source_input


  if (params.getVelocityYSourceFlag() != 0)
  {
    if (params.getVelocitySourceMany() == 0)
    { // 1D
      addMatrix(MI::kVelocityYSourceInput, MT::kReal,
                DimensionSizes(1 ,1, params.getVelocityYSourceFlag()),
                kLoad, kNoCheckpoint);
    }
    else
    { // 2D
      addMatrix(MI::kVelocityYSourceInput, MT::kReal,
                DimensionSizes(1 ,params.getVelocitySourceIndexSize(), params.getVelocityYSourceFlag()),
                kLoad, kNoCheckpoint);
    }
  }// uy_source_input

  if (isSimulation3D)
  {
    if (params.getVelocityZSourceFlag() != 0)
    {
      if (params.getVelocitySourceMany() == 0)
      { // 1D
        addMatrix(MI::kVelocityZSourceInput, MT::kReal,
                  DimensionSizes(1 ,1, params.getVelocityZSourceFlag()),
                  kLoad, kNoCheckpoint);
      }
      else
      { // 2D
        addMatrix(MI::kVelocityZSourceInput, MT::kReal,
                  DimensionSizes(1 ,params.getVelocitySourceIndexSize(), params.getVelocityZSourceFlag()),
                  kLoad, kNoCheckpoint);
      }
    }// uz_source_input
  }

  // Add sourceKappa
  if (((params.getVelocitySourceMode() == Parameters::SourceMode::kAdditive) ||
       (params.getPressureSourceMode() == Parameters::SourceMode::kAdditive)) &&
      (params.getPressureSourceFlag()  ||
       params.getVelocityXSourceFlag() || params.getVelocityYSourceFlag() || params.getVelocityZSourceFlag()))
  {
    addMatrix(MI::kSourceKappa, MT::kReal, reducedDims, kNoLoad, kNoCheckpoint);
  }

  //-------------------------------------------- Non staggered velocity ----------------------------------------------//
  if (params.getStoreVelocityNonStaggeredRawFlag())
  {
    DimensionSizes shiftDims = fullDims;

    const size_t nxR = fullDims.nx / 2 + 1;
    const size_t nyR = fullDims.ny / 2 + 1;
    const size_t nzR = (isSimulation3D) ? fullDims.nz / 2 + 1 : 1;

    const size_t xCutSize = nxR         * fullDims.ny * fullDims.nz;
    const size_t yCutSize = fullDims.nx * nyR         * fullDims.nz;
    const size_t zCutSize = (isSimulation3D) ? fullDims.nx * fullDims.ny * nzR : 1;

    if ((xCutSize >= yCutSize) && (xCutSize >= zCutSize))
    { // X cut is the biggest
      shiftDims.nx = nxR;
    }
    else if ((yCutSize >= xCutSize) && (yCutSize >= zCutSize))
    { // Y cut is the biggest
      shiftDims.ny = nyR;
    }
    else if ((zCutSize >= xCutSize) && (zCutSize >= yCutSize))
    { // Z cut is the biggest
      shiftDims.nz = nzR;
    }
    else
    { //all are the same
      shiftDims.nx = nxR;
    }

    addMatrix(MI::kTempFftwShift, MT::kFftwComplex, shiftDims, kNoLoad, kNoCheckpoint);

    // these three are necessary only for u_non_staggered calculation now
    addMatrix(MI::kUxShifted,  MT::kReal, fullDims, kNoLoad, kNoCheckpoint);
    addMatrix(MI::kUyShifted,  MT::kReal, fullDims, kNoLoad, kNoCheckpoint);
    addMatrix(MI::kUzShifted,  MT::kReal, fullDims, kNoLoad, kNoCheckpoint, isSimulation3D);

    // shifts from the input file
    addMatrix(MI::kXShiftNegR, MT::kComplex, DimensionSizes(nxR, 1, 1), kNoLoad, kNoCheckpoint);
    addMatrix(MI::kYShiftNegR, MT::kComplex, DimensionSizes(1, nyR, 1), kNoLoad, kNoCheckpoint);
    addMatrix(MI::kZShiftNegR, MT::kComplex, DimensionSizes(1, 1, nzR), kNoLoad, kNoCheckpoint, isSimulation3D);

  }// u_non_staggered

  //----------------------------------------------- Temporary matrices -----------------------------------------------//

  // For axisymmetric code the temp real matrices also support R2R FFTs.
  MT tempRealMatrixType = (isSimulationAS) ? MT::kFftwReal : MT::kReal;

  addMatrix(MI::kTemp1RealND, tempRealMatrixType, fullDims, kNoLoad, kNoCheckpoint);
  // This one is necessary for absorption
  addMatrix(MI::kTemp2RealND, tempRealMatrixType, fullDims, kNoLoad, kNoCheckpoint);

  // This matrix used to load alphaCoeff for absorbTau pre-calculation
  if ((params.getAbsorbingFlag() != Parameters::AbsorptionType::kLossless) &&
      (!params.getAlphaCoeffScalarFlag()))
  {
    // This special case has to be done using the se method since the AlphaCoeffName has no matrix
    addMatrix(MI::kTemp3RealND, tempRealMatrixType, fullDims,   kLoad, kNoCheckpoint);
  }
  else
  {
    addMatrix(MI::kTemp3RealND, tempRealMatrixType, fullDims, kNoLoad, kNoCheckpoint);
  }

  addMatrix(MI::kTempFftwX, MT::kFftwComplex, reducedDims, kNoLoad, kNoCheckpoint);
  addMatrix(MI::kTempFftwY, MT::kFftwComplex, reducedDims, kNoLoad, kNoCheckpoint);
  addMatrix(MI::kTempFftwZ, MT::kFftwComplex, reducedDims, kNoLoad, kNoCheckpoint, isSimulation3D);
}// end of init
//----------------------------------------------------------------------------------------------------------------------

/**
 * Create all matrix objects in the container.
 */
void MatrixContainer::createMatrices()
{
  using MatrixType = MatrixRecord::MatrixType;

  for (auto& it : mContainer)
  {
    if (it.second.matrixPtr != nullptr)
    { // the data is already allocated
      throw std::invalid_argument(Logger::formatMessage(kErrFmtRelocationError, it.second.matrixName.c_str()));
    }

    switch (it.second.matrixType)
    {
      case MatrixType::kReal:
      {
        it.second.matrixPtr = new RealMatrix(it.second.dimensionSizes);
        break;
      }

      case MatrixType::kComplex:
      {
        it.second.matrixPtr = new ComplexMatrix(it.second.dimensionSizes);
        break;
      }

      case MatrixType::kIndex:
      {
        it.second.matrixPtr = new IndexMatrix(it.second.dimensionSizes);
        break;
      }

      case MatrixType::kFftwComplex:
      {
        it.second.matrixPtr = new FftwComplexMatrix(it.second.dimensionSizes);
        break;
      }

      case MatrixType::kFftwReal:
      {
        it.second.matrixPtr = new FftwRealMatrix(it.second.dimensionSizes);
        break;
      }

      default:
      { // unknown matrix type
        throw std::invalid_argument(Logger::formatMessage(kErrFmtBadMatrixType, it.second.matrixName.c_str()));
        break;
      }
    }// switch
  }// end for
}// end of createMatrices
//----------------------------------------------------------------------------------------------------------------------

/**
 * Free all matrix objects.
 */
void MatrixContainer::freeMatrices()
{
  for (auto& it : mContainer)
  {
    if (it.second.matrixPtr)
    {
      delete it.second.matrixPtr;
      it.second.matrixPtr = nullptr;
    }
  }
}// end of freeMatrices
//----------------------------------------------------------------------------------------------------------------------

/**
 * Load all marked matrices from the input HDF5 file.
 */
void MatrixContainer::loadDataFromInputFile()
{
  Hdf5File& inputFile = Parameters::getInstance().getInputFile();

  for (const auto& it : mContainer)
  {
    if (it.second.loadData)
    {
      it.second.matrixPtr->readData(inputFile, it.second.matrixName);
    }
  }
}// end of loadDataFromInputFile
//----------------------------------------------------------------------------------------------------------------------

/**
 * Load selected matrices from the checkpoint HDF5 file.
 */
void MatrixContainer::loadDataFromCheckpointFile()
{
  Hdf5File& checkpointFile = Parameters::getInstance().getCheckpointFile();

  for (const auto& it : mContainer)
  {
    if (it.second.checkpoint)
    {
      it.second.matrixPtr->readData(checkpointFile,it.second.matrixName);
    }
  }
}// end of loadDataFromCheckpointFile
//----------------------------------------------------------------------------------------------------------------------

/**
 * Store selected matrices into the checkpoint file.
 */
void MatrixContainer::storeDataIntoCheckpointFile()
{
  Hdf5File& checkpointFile = Parameters::getInstance().getCheckpointFile();
  auto compressionLevel    = Parameters::getInstance().getCompressionLevel();

  for (const auto& it : mContainer)
  {
    if (it.second.checkpoint)
    {
      it.second.matrixPtr->writeData(checkpointFile, it.second.matrixName, compressionLevel);
    }
  }
}// end of storeDataIntoCheckpointFile
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Protected methods -------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Private methods --------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//
