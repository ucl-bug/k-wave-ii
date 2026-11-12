/**
 * @file      OutputStreamContainer.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file defining the output stream container.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      27 August    2017, 08:58 (created) \n
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

#ifndef OUTPUT_STREAM_CONTAINER_H
#define OUTPUT_STREAM_CONTAINER_H

#include <map>

#include <Containers/MatrixContainer.h>
#include <OutputStreams/BaseOutputStream.h>
#include <Utils/DimensionSizes.h>

/**
 * @class   OutputStreamContainer
 * @brief   A container for output streams.
 * @details The output stream container maintains matrices used to sample data. These may or may not require some
 *          scratch place or reuse temp matrices.
 */
class OutputStreamContainer
{
  public:
    /**
      * @enum    OutputStreamIdx
      * @brief   Output streams identifiers in k-Wave.
      * @details Output streams identifiers in k-Wave.
      */
    enum class OutputStreamIdx
    {
      /// Pressure time series.
      kPressureRaw,
      /// Velocity x time series.
      kVelocityXRaw,
      /// Velocity y time series.
      kVelocityYRaw,
      /// Velocity z time series.
      kVelocityZRaw,
      /// Non staggered velocity x time series.
      kVelocityXNonStaggeredRaw,
      /// Non staggered velocity y time series.
      kVelocityYNonStaggeredRaw,
      /// Non staggered velocity z time series.
      kVelocityZNonStaggeredRaw,

      /// RMS of pressure over sensor mask.
      kPressureRms,
      /// Max of pressure over sensor mask.
      kPressureMax,
      /// Min of pressure over sensor mask.
      kPressureMin,
      /// Max of pressure over all domain.
      kPressureMaxAll,
      /// Min of pressure over all domain.
      kPressureMinAll,

      /// RMS of velocity x over sensor mask.
      kVelocityXRms,
      /// RMS of velocity y over sensor mask.
      kVelocityYRms,
      /// RMS of velocity z over sensor mask.
      kVelocityZRms,
      /// Max of velocity x over sensor mask.
      kVelocityXMax,
      /// Max of velocity y over sensor mask.
      kVelocityYMax,
      /// Max of velocity z over sensor mask.
      kVelocityZMax,
      /// Min of velocity x over sensor mask.
      kVelocityXMin,
      /// Min of velocity y over sensor mask.
      kVelocityYMin,
      /// Min of velocity z over sensor mask.
      kVelocityZMin,

      /// Max of velocity x over all domain.
      kVelocityXMaxAll,
      /// Max of velocity y over all domain.
      kVelocityYMaxAll,
      /// Max of velocity z over all domain.
      kVelocityZMaxAll,
      /// Min of velocity x over all domain.
      kVelocityXMinAll,
      /// Min of velocity y over all domain.
      kVelocityYMinAll,
      /// Min of velocity z over all domain.
      kVelocityZMinAll,

      /// Pressure in the last time step - not in the container but flushed directly from the corresponding matrix.
      kFinalPressure,
      /// Velocity in the last time step in x - not in the container but flushed directly from the corresponding matrix.
      kFinalVelocityX,
      /// Velocity in the last time step in y - not in the container but flushed directly from the corresponding matrix.
      kFinalVelocityY,
      /// Velocity in the last time step in z - not in the container but flushed directly from the corresponding matrix.
      kFinalVelocityZ,
    };// end of OutputStreamIdx


    /// Constructor.
    OutputStreamContainer();
    /// Copy constructor not allowed.
    OutputStreamContainer(const OutputStreamContainer&) = delete;
    /// Destructor.
    ~OutputStreamContainer();

    /// Operator = not allowed.
    OutputStreamContainer& operator=(OutputStreamContainer&) = delete;

    /**
     * @brief  Operator [].
     * @param  [in] outputStreamIdx - output stream identifier.
     * @return An element of the container.
     */
    BaseOutputStream& operator[](const OutputStreamIdx outputStreamIdx)
    {
      return (*(mContainer[outputStreamIdx]));
    };

    /**
     * @brief   Add all streams in the simulation to the container based on the simulation parameters.
     * @details Please note, the matrix container has to be populated before calling this routine.
     * @param   [in] matrixContainer - Matrix container to link the steams with sampled matrices and sensor masks.
     */
    void init(const MatrixContainer& matrixContainer);

    /// Create all streams - opens the datasets.
    void createStreams();
    /// Reopen streams after checkpoint file (datasets).
    void reopenStreams();

    /// Sample all streams.
    void sampleStreams();
    /// Post-process all streams and flush them to the file.
    void postProcessStreams();
    /// Checkpoint streams.
    void checkpointStreams();

    /// Close all streams.
    void closeStreams();
    /// Free all streams - destroy them.
    void freeStreams();

    /**
     * @brief  Get the dataset name of the stream in the HDF5 file.
     * @param  [in] streamIdx - Stream identifier.
     * @return Stream name.
     */
    static const std::string& getStreamHdf5Name(const OutputStreamIdx streamIdx)
    {
      return sOutputStreamHdf5Names[streamIdx];
    }

  protected:
    /**
     * @brief Add a new output stream into the container.
     * @param [in] streamIdx        - Stream identifier.
     * @param [in] matrixContainer  - Name of the HDF5 dataset or group.
     * @param [in] sampledMatrixIdx - Code id of the matrix.
     * @param [in] reduceOp         - Reduction operator.
     * @param [in] present          - Is the stream present?
     * @param [in] bufferToReuse    - Buffer to reuse.
     */
    void addOutputStream(const OutputStreamIdx                  streamIdx,
                         const MatrixContainer&                 matrixContainer,
                         const MatrixContainer::MatrixIdx       sampledMatrixIdx,
                         const BaseOutputStream::ReduceOperator reduceOp,
                         const bool                             present       = true,
                         float*                                 bufferToReuse = nullptr);

    /**
     * @brief Add a new whole domain output stream into the container.
     * @param [in] streamIdx        - Stream identifier.
     * @param [in] matrixContainer  - Name of the HDF5 dataset or group.
     * @param [in] sampledMatrixIdx - Code id of the matrix.
     * @param [in] reduceOp         - Reduction operator.
     * @param [in] present          - Is the stream present?
     */
    void addWholeDomainOutputStream(const OutputStreamIdx                  streamIdx,
                                    const MatrixContainer&                 matrixContainer,
                                    const MatrixContainer::MatrixIdx       sampledMatrixIdx,
                                    const BaseOutputStream::ReduceOperator reduceOp,
                                    const bool                             present = true);

  private:
    /// Container holding the names of all possible streams present in the output file.
    static std::map<OutputStreamIdx, MatrixName> sOutputStreamHdf5Names;
    /// Map with output streams.
    std::map<OutputStreamIdx, BaseOutputStream*> mContainer;
}; // end of OutputStreamContainer
//----------------------------------------------------------------------------------------------------------------------

#endif	/* OUTPUT_STREAM_CONTAINER_H */
