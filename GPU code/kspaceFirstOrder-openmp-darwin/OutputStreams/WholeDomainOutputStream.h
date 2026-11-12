/**
 * @file      WholeDomainOutputStream.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file of the class saving whole RealMatrix into the output HDF5 file, e.g., p_max_all.
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

#ifndef WHOLE_DOMAIN_OUTPUT_STREAM_H
#define WHOLE_DOMAIN_OUTPUT_STREAM_H

#include <OutputStreams/BaseOutputStream.h>

/**
 * @class   WholeDomainOutputStream
 * @brief   Output stream for quantities sampled in the whole domain.
 * @details Output stream for quantities sampled in the whole domain. The data is stored in a single dataset
 *          (aggregated quantities only).
 */
class WholeDomainOutputStream : public BaseOutputStream
{
  public:
    /// Default constructor not allowed.
    WholeDomainOutputStream() = delete;

    /**
     * @brief The constructor links the HDF5 dataset, source (sampled matrix) and the reduction operator together.
     * @param [in] file          - HDF5 file to write the output to.
     * @param [in] datasetName   - HDF5 dataset name.
     * @param [in] sourceMatrix  - Source matrix to be sampled.
     * @param [in] reduceOp      - Reduction operator.
     * @param [in] bufferToReuse - An external buffer can be used to line up the grid points.
     */
    WholeDomainOutputStream(Hdf5File&            file,
                            const MatrixName&    datasetName,
                            const RealMatrix&    sourceMatrix,
                            const ReduceOperator reduceOp,
                            float*               bufferToReuse = nullptr);

    /// Copy constructor not allowed.
    WholeDomainOutputStream(const WholeDomainOutputStream&) = delete;

    /// Destructor.
    virtual ~WholeDomainOutputStream() override;

    /// Operator = not allowed.
    WholeDomainOutputStream& operator=(const WholeDomainOutputStream&) = delete;

    /// Create a HDF5 stream, allocate data for it and open the dataset.
    virtual void create()      override;

    /// Reopen the output stream after restart and reload data.
    virtual void reopen()      override;

    /// Sample all grid points into a buffer and apply reduction, or flush to disk.
    virtual void sample()      override;

    /// Apply post-processing on the buffer and flush it to the file.
    virtual void postProcess() override;

    /// Checkpoint the stream.
    virtual void checkpoint()  override;

    /// Close stream (apply post-processing if necessary, flush data and close).
    virtual void close()       override;

  protected:
    /// Flush the buffer to the file.
    virtual void flushBufferToFile();

    /// Handle to a HDF5 dataset.
    hid_t  mDataset;

    /// Time step to store (N/A for aggregated).
    size_t mSampledTimeStep;
};// end of WholeDomainOutputStream
//----------------------------------------------------------------------------------------------------------------------

#endif /* WHOLE_DOMAIN_OUTPUT_STREAM_H */
