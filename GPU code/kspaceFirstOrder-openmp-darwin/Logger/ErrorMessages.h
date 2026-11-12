/**
 * @file      ErrorMessages.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file containing error messages common for both linux and windows versions. The specific error
 *            messages are in separate files ErrorMessagesLinux.h and ErrorMessagesWindows.h
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      30 August    2017, 11:39 (created) \n
 *            11 February  2020, 14:41 (revised)
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

#ifndef ERROR_MESSAGES_H
#define ERROR_MESSAGES_H

// Linux build.
#ifdef __linux__
  #include <Logger/ErrorMessagesLinux.h>
#elif _WIN64 // Windows build.
  #include <Logger/ErrorMessagesWindows.h>
#elif __APPLE__
  #include <Logger/ErrorMessagesLinux.h>
#endif



//--------------------------------------------------------------------------------------------------------------------//
//-------------------------------- Common error messages for both Linux and Windows ----------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/// Delimiters for linux and windows paths.
ErrorMessage kErrFmtPathDelimiters
  = "/\\_,.:-| ()[]{}";
/// Error message.
ErrorMessage  kErrFmtOutOfMemory
  = "Error: Not enough memory to run the simulation.";
/// Error message.
ErrorMessage  kErrFmtUnknownError
  = "Error: An unknown error happened. ";

//----------------------------------------------- HDF5 error messages ------------------------------------------------//
/// HDF5 error message.
ErrorMessage kErrFmtCannotCreateFile
  = "Error: Cannot create file %s.";
/// HDF5 error message.
ErrorMessage kErrFmtCannotRecreateFile
  = "Error: Cannot recreate file %s, it's already opened.";
/// HDF5 error message.
ErrorMessage kErrFmtCannotReopenFile
  = "Error: Cannot reopen file %s, it's already opened.";
/// HDF5 error message.
ErrorMessage kErrFmtCannotCloseFile
  = "Error: Cannot close file %s.";
/// HDF5 error message.
ErrorMessage kErrFmtCannotWriteDataset
  = "Error: Cannot write into dataset %s.";
/// HDF5 error message.
ErrorMessage kErrFmtCannotReadDataset
  = "Error: Cannot read from dataset %s.";
/// HDF5 error message.
ErrorMessage kErrFmtBadDimensionSizes
  = "Error: Dataset %s has wrong dimension sizes.";
/// HDF5 error message.
ErrorMessage kErrFmtFileNotOpen
  = "Error: File %s was not found or cannot be opened.";
/// HDF5 error message.
ErrorMessage kErrFmtNotHdf5File
  = "Error: File %s is not a valid HDF5 file.";
/// HDF5 error message.
ErrorMessage kErrFmtCannotOpenDataset
  = "Error: Cannot open dataset %s in file %s.";
/// HDF5 error message.
ErrorMessage kErrFmtCannotSetCompression
  = "Error: Cannot set compression level [%ld] in dataset %s, file %s.";
/// HDF5 error message.
ErrorMessage kErrFmtBadAttributeValue
  = "Error: Invalid attribute value: [%s,%s] = %s.";
/// HDF5 error message.
ErrorMessage kErrFmtCannotWriteAttribute
  = "Error: Cannot write into attribute %s in dataset %s.";
/// HDF5 error message.
ErrorMessage kErrFmtCannotReadAttribute
  = "Error: Cannot read from attribute %s in dataset %s.";
/// HDF5 error message.
ErrorMessage kErrFmtCannotCreateGroup
  = "Error: Cannot create group %s in file %s.";
/// HDF5 error message.
ErrorMessage kErrFmtCannotOpenGroup
  = "Error: Cannot open group %s in file %s.";
/// HDF5 error message.
ErrorMessage kErrFmtBadInputFileType
  = "Error: Invalid format of the input file";
/// HDF5 error message.
ErrorMessage kErrFmtBadOutputFileType
  = "Error: Invalid format of the output file.";
/// HDF5 error message.
ErrorMessage kErrFmtBadCheckpointFileType
  = "Error: Invalid format of the checkpoint file.";

//------------------------------------------------- Matrix Classes ---------------------------------------------------//
/// Matrix class error message.
ErrorMessage  kErrFmtMatrixNotFloat
  = "Error: Matrix %s does not have correct data type, expected is single precision floating point.";
/// Matrix class error message.
ErrorMessage  kErrFmtMatrixNotIndex
  = "Error: Matrix %s does not have correct data type, expected unsigned 64b long.";
/// Matrix class error message.
ErrorMessage  kErrFmtMatrixNotReal
  = "Error: Matrix %s does not have correct domain type, expected is real.";
/// Matrix class error message.
ErrorMessage  kErrFmtMatrixNotComplex
  = "Error: Matrix %s does not have correct domain type, expected is complex.";

//------------------------------------------------ Matrix Container --------------------------------------------------//
/// Matrix container error message.
ErrorMessage  kErrFmtBadMatrixType
  = "Error: Matrix %s cannot be created due to unknown type. [File, Line] : [%s,%d].";

/// Matrix container error message.
ErrorMessage  kErrFmtRelocationError
  = "Error: Matrix %s is being reallocated in matrix container.";

//-------------------------------------------- Command line Parameters -----------------------------------------------//
/// Command line parameters error message.
ErrorMessage kErrFmtNoProgressPrintInterval
  = "Error: Invalid progress print interval.";
/// Command line parameters error message.
ErrorMessage kErrFmtInvalidNumberOfThreads
  = "Error: Invalid number of CPU threads.";
/// Command line parameters error message.
ErrorMessage kErrFmtNoCompressionLevel
  = "Error: Invalid compression level.";
/// Command line parameters error message.
ErrorMessage kErrFmtNoSamplingStartTimeStep
  = "Error: Invalid sampling start time step.";
/// Command line parameters error message.
ErrorMessage kErrFmtNoBenchmarkTimeStep
  = "Error: Invalid number of time step for benchmark.";
/// Command line parameters error message.
ErrorMessage kErrFmtNoVerboseLevel
  = "Error: Invalid verbose level.";

/// Command line parameters error message.
ErrorMessage kErrFmtNoInputFile
  = "Error: Input file was not specified.";
/// Command line parameters error message.
ErrorMessage kErrFmtNoOutputFile
  = "Error: Output file was not specified.";
/// Command line parameters error message.
ErrorMessage kErrFmtNoCheckpointFile
  = "Error: Checkpoint file was not specified.";
/// Command line parameters error message.
ErrorMessage kErrFmtNoCheckpointInterval
  = "Error: Checkpoint interval was not specified.";
/// Command line parameters error message.
ErrorMessage kErrFmtNoCheckpointTimeSteps
  = "Error: Checkpoint time steps were not specified.";
/// Command line parameters error message.
ErrorMessage kErrFmtNoCheckpointIntervalOrTimeSteps
  = "Error: No checkpoint interval or time steps were specified.";
/// Command line parameter error message.
ErrorMessage kErrFmtUnknownParameter
  = "Error: Unknown command line parameter.";
/// Command line parameter error message.
ErrorMessage kErrFmtUnknownParameterOrArgument
  = "Error: Unknown command line parameter or missing argument.";
/// Command line parameters error message.
ErrorMessage kErrFmtIllegalSamplingStartTimeStep
  = "Error: The beginning of data sampling is out of the simulation time span <%zu, %zu>.";

/// Command line parameters error message.
ErrorMessage kErrFmtBadInputFileFormat
  = "Error: Invalid input file %s format.";
/// Command line parameters error message.
ErrorMessage kErrFmtBadFileVersion
  = "Error: Invalid file version %s of file %s (expected %s).";
/// Command line parameters error message.
ErrorMessage kErrFmtBadSensorMaskType
  = "Error: The sensor mask type specified in the input file is not supported.";
/// Command line parameters error message.
ErrorMessage kErrFmtNonStaggeredVelocityNotSupportedFileVersion
  = "Error: --u_non_staggered_raw is not supported with input files of version 1.0.";
/// Command line parameters error message.
ErrorMessage kErrFmtBadVelocitySourceMode
  = "Error: The velocity source mode type specified in the input file is not supported.";
/// Command line parameters error message.
ErrorMessage kErrFmtBadPressureSourceMode
  = "Error: The pressure source mode specified in the input file is not supported.";
/// Parameter error message.
ErrorMessage kErrFmtUnknownAbsorptionType
  = "Error: Unknown absorption type.";
/// Parameter error message.
ErrorMessage kErrFmtPowerLawAbsorptionNotSupportedForAS
  = "Error: Power law absorption is not supported for axisymmetric medium.";
/// Parameters error message.
ErrorMessage kErrFmtIllegalAlphaPowerValue
  = "Error: Illegal value of alpha_power (may not equal to 1.0).";

//--------------------------------------------- KSpaceFirstOrderSolver -----------------------------------------------//
/// KSpaceFirstOrderSolver error message.
ErrorMessage kErrFmtBadCheckpointFileFormat
  = "Error: Invalid checkpoint file %s format.";
/// KSpaceFirstOrderSolver error message.
ErrorMessage kErrFmtBadOutputFileFormat
  = "Error: Invalid output file %s format.";
/// KSpaceFirstOrderSolver error message.
ErrorMessage kErrFmtCheckpointDimensionsMismatch
  = "Error: Checkpoint file dimensions [%ld, %ld, %ld] don't match the simulation "
    "dimensions [%ld, %ld, %ld].";
/// KSpaceFirstOrderSolver error message.
ErrorMessage kErrFmtOutputDimensionsMismatch
  = "Error: Output file dimensions [%ld, %ld, %ld] don't match the simulation "
    "dimensions [%ld, %ld, %ld].";

//-------------------------------------------------- FFTW errors -----------------------------------------------------//
/// FFTW error message.
ErrorMessage kErrFmtCreateR2CFftPlanND
  = "Error: Cannot create plan for ND real-to-complex FFT.";
/// FFTW error message.
ErrorMessage kErrFmtCreateC2RFftPlanND
  = "Error: Cannot create plan for ND complex-to-real FFT.";
/// FFTW error message.
ErrorMessage kErrFmtCreateR2CFftPlan1DX
  = "Error: Cannot create plan for 1D real-to-complex FFT in x direction.";
/// FFTW error message.
ErrorMessage kErrFmtCreateR2CFftPlan1DY
  = "Error: Cannot create plan for 1D real-to-complex FFT in y direction.";
/// FFTW error message.
ErrorMessage kErrFmtCreateR2CFftPlan1DZ
  = "Error: Cannot create plan for 1D real-to-complex FFT in z direction.";
/// FFTW error message.
ErrorMessage kErrFmtCreateC2RFftPlan1DX
  = "Error: Cannot create plan for 1D complex-to-real FFT in x direction.";
/// FFTW error message.
ErrorMessage kErrFmtCreateC2RFftPlan1DY
  = "Error: Cannot create plan for 1D complex-to-real FFT in y direction.";
/// FFTW error message.
ErrorMessage kErrFmtCreateC2RFftPlan1DZ
  = "Error: Cannot create plan for 1D complex-to-real FFT in z direction.";
/// FFTW error message.
ErrorMessage kErrFmtCreateR2RFftPlan1D
  = "Error: Cannot create plan 1D real-to-real FFT of kind %d in y direction.";

/// FFTW error message.
ErrorMessage kErrFmtCannotCallR2CFftPlan1DZfor2D
  = "Error: Cannot call 1D real-to-complex FFT in z direction in 2D simulations.";
/// FFTW error message.
ErrorMessage kErrFmtCannotCallC2RFftPlan1DZfor2D
  = "Error: Cannot call 1D complex-to-real FFT in z direction in 2D simulations.";

/// FFTW error message.
ErrorMessage kErrFmtDestroyR2CFftPlanND
  = "Error: Cannot destroy plan for ND real-to-complex FFT.";
/// FFTW error message.
ErrorMessage kErrFmtDestroyC2RFftPlanND
  = "Error: Cannot destroy plan for ND complex-to-real FFT.";
/// FFTW error message.
ErrorMessage kErrFmtDestroyR2CFftPlan1DX
  = "Error: Cannot destroy plan for 1D real-to-complex FFT in x direction.";
/// FFTW error message.
ErrorMessage kErrFmtDestroyR2CFftPlan1DY
  = "Error: Cannot destroy plan for 1D real-to-complex FFT in y direction.";
/// FFTW error message.
ErrorMessage kErrFmtDestroyR2CFftPlan1DZ
  = "Error: Cannot destroy plan for 1D real-to-complex FFT in z direction.";
/// FFTW error message.
ErrorMessage kErrFmtDestroyC2RFftPlan1DX
  = "Error: Cannot destroy plan for 1D complex-to-real FFT in x direction.";
/// FFTW error message.
ErrorMessage kErrFmtDestroyC2RFftPlan1DY
  = "Error: Cannot destroy plan for 1D complex-to-real FFT in y direction.";
/// FFTW error message.
ErrorMessage kErrFmtDestroyC2RFftPlan1DZ
  = "Error: Cannot destroy plan for 1D complex-to-real FFT in z direction.";

/// FFTW error message.
ErrorMessage kErrFmtExecuteR2CFftPlanND
  = "Error: Cannot execute ND real-to-complex FFT.";
/// FFTW error message.
ErrorMessage kErrFmtExecuteC2RFftPlanND
  = "Error: Cannot execute ND complex-to-real FFT.";
/// FFTW error message.
ErrorMessage kErrFmtExecuteR2CFftPlan1DX
  = "Error: Cannot execute 1D real-to-complex FFT in x direction.";
/// FFTW error message.
ErrorMessage kErrFmtExecuteR2CFftPlan1DY
  = "Error: Cannot execute 1D real-to-complex FFT in y direction.";
/// FFTW error message.
ErrorMessage kErrFmtExecuteR2CFftPlan1DZ
  = "Error: Cannot execute 1D real-to-complex FFT in z direction.";
/// FFTW error message.
ErrorMessage kErrFmtExecuteC2RFftPlan1DX
  = "Error: Cannot execute 1D complex-to-real FFT in x direction.";
/// FFTW error message.
ErrorMessage kErrFmtExecuteC2RFftPlan1DY
  = "Error: Cannot execute 1D complex-to-real FFT in y direction.";
/// FFTW error message.
ErrorMessage kErrFmtExecuteC2RFftPlan1DZ
  = "Error: Cannot execute complex-to-real FFT in z direction.";
/// FFTW error message.
ErrorMessage kErrFmtExecuteR2RFftPlan1D
  = "Error: Cannot execute real-to-real FFT of kind %d in y direction.";

/// FFTW error message.
ErrorMessage kErrFmtFftWisdomNotExported
  = "Warning: Cannot export FFTW wisdom.";
/// FFTW error message.
ErrorMessage ErrFmtFftWisdomNotImported
  = "Warning: Cannot export FFTW wisdom.";

#endif /* ERROR_MESSAGES_H */
