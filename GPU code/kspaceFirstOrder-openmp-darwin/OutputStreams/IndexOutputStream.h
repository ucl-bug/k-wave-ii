/**
 * @file      IndexOutputStream.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file of the class responsible for storing output quantities based on the
 *            index sensor mask into the output HDF5 file.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      26 August    2017, 16:55 (created) \n
 *            11 February  2020, 14:48 (revised)
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

#ifndef INDEX_OUTPUT_STREAM_H
#define INDEX_OUTPUT_STREAM_H

#include <OutputStreams/BaseOutputStream.h>

/**
 * @class   IndexOutputStream
 * @brief   Output stream for quantities sampled by an index sensor mask.
 * @details Output stream for quantities sampled by an index sensor mask. This class writes data to a single dataset in a
 *          root group of the HDF5 file (time-series as well as aggregations).
 */
class IndexOutputStream : public BaseOutputStream
{
  public:
    /// Default constructor not allowed.
    IndexOutputStream() = delete;
    /**
     * @brief Constructor.
     *
     * @details The Constructor links the HDF5 dataset, source (sampled matrix), sensor mask and the reduction operator
     *          together. The constructor DOES NOT allocate memory because the size of the sensor mask is not known at
     *          the time the instance of the class is being created.
     *
     * @param [in] file          - HDF5 file to write the output to.
     * @param [in] datasetName   - HDF5 dataset name. Index based sensor data is stored in a single dataset.
     * @param [in] sourceMatrix  - Source real matrix to be sampled.
     * @param [in] sensorMask    - Index sensor mask.
     * @param [in] reduceOp      - Reduction operator.
     * @param [in] bufferToReuse - An external buffer can be used to line up the grid points.
     */
    IndexOutputStream(Hdf5File&            file,
                      const MatrixName&    datasetName,
                      const RealMatrix&    sourceMatrix,
                      const IndexMatrix&   sensorMask,
                      const ReduceOperator reduceOp,
                      float*               bufferToReuse = nullptr);

    /// Copy constructor not allowed.
    IndexOutputStream(const IndexOutputStream&) = delete;

    /// Destructor.
    virtual ~IndexOutputStream() override;

    /// Operator = not allowed.
    IndexOutputStream& operator=(const IndexOutputStream&) = delete;

    /// Create a HDF5 stream, allocate data for it and open the dataset.
    virtual void create()      override;

    /// Reopen the output stream after restart and reload data.
    virtual void reopen()      override;

    /// Sample grid points, line them up in the buffer, if necessary a reduce operator is applied.
    virtual void sample()      override;

    /// Apply post-processing on the buffer and flush it to the file.
    virtual void postProcess() override;

    /// Checkpoint the stream.
    virtual void checkpoint()  override;

    /// Close stream.
    virtual void close()       override;

  protected:
    /// Flush the buffer to the file.
    virtual void flushBufferToFile();

    /// Sensor mask to sample data.
    const IndexMatrix& mSensorMask;

    /// Handle to a HDF5 dataset.
    hid_t  mDataset;

    /// Time step to store (N/A for aggregated).
    size_t mSampledTimeStep;
};// end of IndexOutputStream
//----------------------------------------------------------------------------------------------------------------------

#endif /* INDEX_OUTPUT_STREAM_H */
