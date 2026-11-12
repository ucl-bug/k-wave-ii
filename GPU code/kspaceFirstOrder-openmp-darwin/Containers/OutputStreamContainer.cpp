/**
 * @file      OutputStreamContainer.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file for the output stream container.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      27 August    2017, 08:59 (created) \n
 *            11 February  2020, 14:31 (revised)
 *
 * @copyright Copyright (C) 2017 - 2020 SC\@FIT Research Group, Brno University of Technology, Brno, CZ.
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

#include <Parameters/Parameters.h>
#include <Containers/OutputStreamContainer.h>

#include <OutputStreams/BaseOutputStream.h>
#include <OutputStreams/IndexOutputStream.h>
#include <OutputStreams/CuboidOutputStream.h>
#include <OutputStreams/WholeDomainOutputStream.h>

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Initialization ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Initialization of static map with matrix names.
 */
std::map<OutputStreamContainer::OutputStreamIdx, MatrixName> OutputStreamContainer::sOutputStreamHdf5Names
{
  {OutputStreamIdx::kPressureRaw,              "p"},
  {OutputStreamIdx::kPressureRms,              "p_rms"},
  {OutputStreamIdx::kPressureMax,              "p_max"},
  {OutputStreamIdx::kPressureMin,              "p_min"},
  {OutputStreamIdx::kPressureMaxAll,           "p_max_all"},
  {OutputStreamIdx::kPressureMinAll,           "p_min_all"},

  {OutputStreamIdx::kVelocityXRaw,             "ux"},
  {OutputStreamIdx::kVelocityYRaw,             "uy"},
  {OutputStreamIdx::kVelocityZRaw,             "uz"},

  {OutputStreamIdx::kVelocityXNonStaggeredRaw, "ux_non_staggered"},
  {OutputStreamIdx::kVelocityYNonStaggeredRaw, "uy_non_staggered"},
  {OutputStreamIdx::kVelocityZNonStaggeredRaw, "uz_non_staggered"},

  {OutputStreamIdx::kVelocityXRms,             "ux_rms"},
  {OutputStreamIdx::kVelocityYRms,             "uy_rms"},
  {OutputStreamIdx::kVelocityZRms,             "uz_rms"},

  {OutputStreamIdx::kVelocityXMax,             "ux_max"},
  {OutputStreamIdx::kVelocityYMax,             "uy_max"},
  {OutputStreamIdx::kVelocityZMax,             "uz_max"},

  {OutputStreamIdx::kVelocityXMin,             "ux_min"},
  {OutputStreamIdx::kVelocityYMin,             "uy_min"},
  {OutputStreamIdx::kVelocityZMin,             "uz_min"},

  {OutputStreamIdx::kVelocityXMaxAll,          "ux_max_all"},
  {OutputStreamIdx::kVelocityYMaxAll,          "uy_max_all"},
  {OutputStreamIdx::kVelocityZMaxAll,          "uz_max_all"},

  {OutputStreamIdx::kVelocityXMinAll,          "ux_min_all"},
  {OutputStreamIdx::kVelocityYMinAll,          "uy_min_all"},
  {OutputStreamIdx::kVelocityZMinAll,          "uz_min_all"},

  {OutputStreamIdx::kFinalPressure,            "p_final"},
  {OutputStreamIdx::kFinalVelocityX,           "ux_final"},
  {OutputStreamIdx::kFinalVelocityY,           "uy_final"},
  {OutputStreamIdx::kFinalVelocityZ,           "uz_final"},
};// end of sOutputStreamHdf5Names
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------- Public methods --------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Default constructor.
 */
OutputStreamContainer::OutputStreamContainer()
  : mContainer()
{

}// end of OutputStreamContainer
//----------------------------------------------------------------------------------------------------------------------

/**
 * Destructor.
 */
OutputStreamContainer::~OutputStreamContainer()
{
  mContainer.clear();
}// end of ~OutputStreamContainer
//----------------------------------------------------------------------------------------------------------------------

/**
 * Add all streams in the simulation to the container, set all streams records here!
 */
void OutputStreamContainer::init(const MatrixContainer& matrixContainer)
{
  Parameters& params = Parameters::getInstance();

  // Shortcuts for long data types
  using OI = OutputStreamIdx;
  using MI = MatrixContainer::MatrixIdx;
  using RO = BaseOutputStream::ReduceOperator;

  const      bool isSimulation3D = params.isSimulation3D();
  // Stream present always
  constexpr  bool kAlways        = true;

  float* tempBuffX = matrixContainer.getMatrix<RealMatrix>(MI::kTemp1RealND).getData();
  float* tempBuffY = matrixContainer.getMatrix<RealMatrix>(MI::kTemp2RealND).getData();
  float* tempBuffZ = (isSimulation3D) ? matrixContainer.getMatrix<RealMatrix>(MI::kTemp3RealND).getData() : nullptr;

  //-------------------------------------------------- pressure ------------------------------------------------------//
  if (params.getStorePressureRawFlag())
  {
    addOutputStream(OI::kPressureRaw, matrixContainer, MI::kP, RO::kNone, kAlways, tempBuffX);
  }

  if (params.getStorePressureRmsFlag())
  {
    addOutputStream(OI::kPressureRms, matrixContainer, MI::kP, RO::kRms);
  }

  if (params.getStorePressureMaxFlag())
  {
    addOutputStream(OI::kPressureMax, matrixContainer, MI::kP, RO::kMax);
  }

  if (params.getStorePressureMinFlag())
  {
    addOutputStream(OI::kPressureMin, matrixContainer, MI::kP, RO::kMin);
  }

  if (params.getStorePressureMaxAllFlag())
  {
    addWholeDomainOutputStream(OI::kPressureMaxAll, matrixContainer, MI::kP, RO::kMax);
  }

  if (params.getStorePressureMinAllFlag())
  {
    addWholeDomainOutputStream(OI::kPressureMinAll, matrixContainer, MI::kP, RO::kMin);
  }

  //-------------------------------------------------- velocity ------------------------------------------------------//
  if (params.getStoreVelocityRawFlag())
  {
    addOutputStream(OI::kVelocityXRaw, matrixContainer, MI::kUxSgx, RO::kNone, kAlways, tempBuffX);
    addOutputStream(OI::kVelocityYRaw, matrixContainer, MI::kUySgy, RO::kNone, kAlways, tempBuffY);
    addOutputStream(OI::kVelocityZRaw, matrixContainer, MI::kUzSgz, RO::kNone, isSimulation3D, tempBuffZ);
  }

  if (params.getStoreVelocityNonStaggeredRawFlag())
  {
    addOutputStream(OI::kVelocityXNonStaggeredRaw, matrixContainer, MI::kUxShifted, RO::kNone, kAlways, tempBuffX);
    addOutputStream(OI::kVelocityYNonStaggeredRaw, matrixContainer, MI::kUyShifted, RO::kNone, kAlways, tempBuffY);
    addOutputStream(OI::kVelocityZNonStaggeredRaw, matrixContainer, MI::kUzShifted, RO::kNone, isSimulation3D,
                    tempBuffZ);
  }

  if (params.getStoreVelocityRmsFlag())
  {
    addOutputStream(OI::kVelocityXRms, matrixContainer, MI::kUxSgx, RO::kRms);
    addOutputStream(OI::kVelocityYRms, matrixContainer, MI::kUySgy, RO::kRms);
    addOutputStream(OI::kVelocityZRms, matrixContainer, MI::kUzSgz, RO::kRms, isSimulation3D);
  }

  if (params.getStoreVelocityMaxFlag())
  {
    addOutputStream(OI::kVelocityXMax, matrixContainer, MI::kUxSgx, RO::kMax);
    addOutputStream(OI::kVelocityYMax, matrixContainer, MI::kUySgy, RO::kMax);
    addOutputStream(OI::kVelocityZMax, matrixContainer, MI::kUzSgz, RO::kMax, isSimulation3D);
  }

  if (params.getStoreVelocityMinFlag())
  {
    addOutputStream(OI::kVelocityXMin, matrixContainer, MI::kUxSgx, RO::kMin);
    addOutputStream(OI::kVelocityYMin, matrixContainer, MI::kUySgy, RO::kMin);
    addOutputStream(OI::kVelocityZMin, matrixContainer, MI::kUzSgz, RO::kMin, isSimulation3D);
  }

  if (params.getStoreVelocityMaxAllFlag())
  {
    addWholeDomainOutputStream(OI::kVelocityXMaxAll, matrixContainer, MI::kUxSgx, RO::kMax);
    addWholeDomainOutputStream(OI::kVelocityYMaxAll, matrixContainer, MI::kUySgy, RO::kMax);
    addWholeDomainOutputStream(OI::kVelocityZMaxAll, matrixContainer, MI::kUzSgz, RO::kMax, isSimulation3D);
  }

  if (params.getStoreVelocityMinAllFlag())
  {
    addWholeDomainOutputStream(OI::kVelocityXMinAll, matrixContainer, MI::kUxSgx, RO::kMin);
    addWholeDomainOutputStream(OI::kVelocityYMinAll, matrixContainer, MI::kUySgy, RO::kMin);
    addWholeDomainOutputStream(OI::kVelocityZMinAll, matrixContainer, MI::kUzSgz, RO::kMin, isSimulation3D);
  }
}// end of init
//----------------------------------------------------------------------------------------------------------------------

/**
 * Create all streams.
 */
void OutputStreamContainer::createStreams()
{
  for (const auto& it : mContainer)
  {
    if (it.second)
    {
      it.second->create();
    }
  }
}// end of createStreams
//----------------------------------------------------------------------------------------------------------------------

/**
 * Reopen all streams after restarting from checkpoint.
 */
void OutputStreamContainer::reopenStreams()
{
  for (const auto& it : mContainer)
  {
    if (it.second)
    {
      it.second->reopen();
    }
  }
}// end of reopenStreams
//----------------------------------------------------------------------------------------------------------------------

/**
 * Sample all streams.
 */
void OutputStreamContainer::sampleStreams()
{
  for (const auto& it : mContainer)
  {
    if (it.second)
    {
      it.second->sample();
    }
  }
}// end of sampleStreams
//----------------------------------------------------------------------------------------------------------------------

/**
 * Checkpoint streams without post-processing (flush to the file).
 */
void OutputStreamContainer::checkpointStreams()
{
  for (const auto& it : mContainer)
  {
    if (it.second)
    {
      it.second->checkpoint();
    }
  }
}// end of checkpointStreams
//----------------------------------------------------------------------------------------------------------------------

/**
 * Post-process all streams and flush them to the file.
 */
void OutputStreamContainer::postProcessStreams()
{
  for (const auto& it : mContainer)
  {
    if (it.second)
    {
      it.second->postProcess();
    }
  }
}// end of postProcessStreams
//----------------------------------------------------------------------------------------------------------------------

/**
 * Close all streams (apply post-processing if necessary, flush data and close).
 */
void OutputStreamContainer::closeStreams()
{
  for (const auto& it : mContainer)
  {
    if (it.second)
    {
      it.second->close();
    }
  }
}// end of closeStreams
//----------------------------------------------------------------------------------------------------------------------

/**
 *  Free all streams - destroy them.
 */
void OutputStreamContainer::freeStreams()
{
  for (auto& it : mContainer)
  {
    if (it.second)
    {
      delete it.second;
      it.second = nullptr;
    }
  }
  mContainer.clear();
}// end of freeStreams
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------ Protected methods -------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Add a new output stream into the container.
 */
void OutputStreamContainer::addOutputStream(const OutputStreamIdx                  streamIdx,
                                            const MatrixContainer&                 matrixContainer,
                                            const MatrixContainer::MatrixIdx       sampledMatrixIdx,
                                            const BaseOutputStream::ReduceOperator reduceOp,
                                            const bool                             present,
                                            float*                                 bufferToReuse)
{
  using MI = MatrixContainer::MatrixIdx;

  Parameters& params = Parameters::getInstance();

  if (present)
  {
    if (params.getSensorMaskType() == Parameters::SensorMaskType::kIndex)
    {
      mContainer[streamIdx] = new IndexOutputStream(params.getOutputFile(),
                                                    sOutputStreamHdf5Names[streamIdx],
                                                    matrixContainer.getMatrix<RealMatrix>(sampledMatrixIdx),
                                                    matrixContainer.getMatrix<IndexMatrix>(MI::kSensorMaskIndex),
                                                    reduceOp,
                                                    bufferToReuse);
    }
    else
    {
      mContainer[streamIdx] = new CuboidOutputStream(params.getOutputFile(),
                                                     sOutputStreamHdf5Names[streamIdx],
                                                     matrixContainer.getMatrix<RealMatrix>(sampledMatrixIdx),
                                                     matrixContainer.getMatrix<IndexMatrix>(MI::kSensorMaskCorners),
                                                     reduceOp,
                                                     bufferToReuse);
    }
  }
}// end of addOutputStream
//----------------------------------------------------------------------------------------------------------------------

/**
 * Add a new output stream into the container.
 */
void OutputStreamContainer::addWholeDomainOutputStream(const OutputStreamIdx                  streamIdx,
                                                       const MatrixContainer&                 matrixContainer,
                                                       const MatrixContainer::MatrixIdx       sampledMatrixIdx,
                                                       const BaseOutputStream::ReduceOperator reduceOp,
                                                       const bool                             present)
{
  Parameters& params = Parameters::getInstance();

  if (present)
  {
    mContainer[streamIdx] = new WholeDomainOutputStream(params.getOutputFile(),
                                                        sOutputStreamHdf5Names[streamIdx],
                                                        matrixContainer.getMatrix<RealMatrix>(sampledMatrixIdx),
                                                        reduceOp);
  }
}// end of addWholeDomainOutputStream
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Private methods --------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//
