/**
 * @file      OutputMessages.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file including output messages based on the operating system.
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

#ifndef OUTPUT_MESSAGES_H
#define OUTPUT_MESSAGES_H

// Windows build
#ifdef _WIN64
  #include <Logger/OutputMessagesWindows.h>
#elif __linux__ // Linux build
  #include <Logger/OutputMessagesLinux.h>
#elif __APPLE__
  #include <Logger/OutputMessagesLinux.h>
#endif




//------------------------------------------------- Common outputs ---------------------------------------------------//
/// Output message - Done with two spaces.
OutputMessage kOutFmtDone
  = "  Done " +  kOutFmtEol;
/// Output message - finish line without done.
OutputMessage kOutFmtNoDone
  = "       " + kOutFmtEol;
/// Output message - failed message.
OutputMessage kOutFmtFailed
  = "Failed " + kOutFmtEol;

//------------------------------------------------- Common outputs ---------------------------------------------------//
/// Output message.
OutputMessage kOutFmtCodeName
  = kOutFmtVerticalLine + "                   %s                   " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtKWaveVersion
  = "kspaceFirstOrder-OMP v1.3";

/// Output message.
OutputMessage kOutFmtGitHashLeft
  = kOutFmtVerticalLine + " Git hash:            %s " + kOutFmtEol;

/// Output message.
OutputMessage kOutFmtNumberOfThreads
  = kOutFmtVerticalLine + " Number of CPU threads:                              %9lu " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtProcessorNameRight
  = kOutFmtVerticalLine + " Processor name: %45.45s " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtProcessorNameLeft
  = kOutFmtVerticalLine + " Processor name:   %-43.43s " + kOutFmtEol;

/// Output message.
OutputMessage kOutFmtElapsedTime
  = kOutFmtVerticalLine + " Elapsed time:                                    %11.2fs " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtRecoveredFrom
  = kOutFmtVerticalLine + " Recovered from time step:                            %8ld " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtMemoryUsage
  = kOutFmtVerticalLine + " Peak memory in use:                                %8luMB " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtTotalExecutionTime
  = kOutFmtVerticalLine + " Total execution time:                               %8.2fs " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtLegExecutionTime
  = kOutFmtVerticalLine + " This leg execution time:                            %8.2fs " + kOutFmtEol;

/// Output message.
OutputMessage kOutFmtReadingConfiguration
  = kOutFmtVerticalLine + " Reading simulation configuration:                      ";
/// Output message.
OutputMessage kOutFmtDomainSize
  = kOutFmtVerticalLine + " Domain dimensions: %42s " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmt3DDomainSizeFormat
  = "%lu x %lu x %lu";
/// Output message.
OutputMessage kOutFmt2DDomainSizeFormat
  = "%lu x %lu";

/// Output message.
OutputMessage kOutFmtFftPlans
  = kOutFmtVerticalLine + " FFT plans creation:                                    ";
/// Output message.
OutputMessage kOutFmtPreProcessing
  = kOutFmtVerticalLine + " Pre-processing phase:                                  ";
/// Output message.
OutputMessage kOutFmtDataLoading
  = kOutFmtVerticalLine + " Data loading:                                          ";
/// Output message.
OutputMessage kOutFmtMemoryAllocation
  = kOutFmtVerticalLine + " Memory allocation:                                     ";
/// Output message.
OutputMessage kOutFmtCurrentMemory
  = kOutFmtVerticalLine + " Current host memory in use:                        %8luMB " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtOutputFileUsage
  = kOutFmtVerticalLine + " Expected output file size:                        %9luMB " + kOutFmtEol;

/// Output message.
OutputMessage kOutFmtCheckpointCompletedTimeSteps
  = kOutFmtVerticalLine + " Number of time steps completed:                    %10u " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtCreatingCheckpoint
  = kOutFmtVerticalLine + " Creating checkpoint:                                   ";
/// Output message.
OutputMessage kOutFmtPostProcessing
  = kOutFmtVerticalLine + " Sampled data post-processing:                          ";
/// Output message.
OutputMessage kOutFmtStoringCheckpointData
  = kOutFmtVerticalLine + " + Storing checkpoint data:                             ";
/// Output message.
OutputMessage kOutFmtStoringFftwWisdom
  = kOutFmtVerticalLine + " + Storing FFTW wisdom:                                 ";
/// Output message.
OutputMessage kOutFmtLoadingFftwWisdom
  = kOutFmtVerticalLine + " Loading FFTW wisdom:                                   ";
/// Output message.
OutputMessage kOutFmtStoringSensorData
  = kOutFmtVerticalLine + " + Storing sensor data:                                 ";
/// Output message.
OutputMessage kOutFmtReadingInputFile
  = kOutFmtVerticalLine + " + Reading input file:                                  ";
/// Output message.
OutputMessage kOutFmtReadingCheckpointFile
  = kOutFmtVerticalLine + " + Reading checkpoint file:                             ";
/// Output message.
OutputMessage kOutFmtReadingOutputFile
  = kOutFmtVerticalLine + " + Reading output file:                                 ";
/// Output message.
OutputMessage kOutFmtCreatingOutputFile
  = kOutFmtVerticalLine + " + Creating output file:                                ";

/// Output message.
OutputMessage kOutFmtInputFile
  = "Input file:  ";
/// Output message.
OutputMessage kOutFmtFileVersion
  = kOutFmtVerticalLine + " File format version:                                      %s " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtOutputFile
  = "Output file: ";
/// Output message.
OutputMessage kOutFmtCheckpointFile
  = "Check file:  ";
/// Output message.
OutputMessage kOutFmtCheckpointInterval
  = kOutFmtVerticalLine + " Checkpoint interval:                                %8lus " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtCheckpointTimeSteps
  = kOutFmtVerticalLine + " Checkpoint time steps:                               %8lu " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtCompressionLevel
  = kOutFmtVerticalLine + " Compression level:                                   %8lu " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtPrintProgressIntrerval
  = kOutFmtVerticalLine + " Print progress interval:                            %8lu%% " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtBenchmarkTimeStep
  = kOutFmtVerticalLine + " Benchmark time steps:                                %8lu " + kOutFmtEol;

/// Output message.
OutputMessage kOutFmtSamplingStartsAt
  = kOutFmtVerticalLine + " Sampling begins at time step:                        %8lu " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtCopySensorMask
  = kOutFmtVerticalLine + " Copy sensor mask to output file:                          Yes " + kOutFmtEol;

//------------------------------------------------ Print code version ------------------------------------------------//
/// Print version output message.
OutputMessage kOutFmtVersionGitHash
  = kOutFmtVerticalLine + " Git hash:         %s    " + kOutFmtEol;

/// Print version output message.
OutputMessage kOutFmtLinuxBuild
  = kOutFmtVerticalLine + " Operating system: Linux x64                                   " + kOutFmtEol;
/// Print version output message.
OutputMessage kOutFmtWindowsBuild
  = kOutFmtVerticalLine + " Operating system: Windows x64                                 " + kOutFmtEol;
/// Print version output message.
OutputMessage kOutFmtMacOsBuild
  = kOutFmtVerticalLine + " Operating system: Mac OS X x64                                " + kOutFmtEol;

/// Print version output message.
OutputMessage kOutFmtGnuCompiler
  = kOutFmtVerticalLine + " Compiler name:    GNU C++ %.19s                               " + kOutFmtEol;
/// Print version output message.
OutputMessage kOutFmtIntelCompiler
  = kOutFmtVerticalLine + " Compiler name:    Intel C++ %d                              " + kOutFmtEol;
/// Print version output message.
OutputMessage kOutFmtVisualStudioCompiler
  = kOutFmtVerticalLine + " Compiler name:    Visual Studio C++ %d                      " + kOutFmtEol;

/// Print version output message.
OutputMessage kOutFmtAVX512
  = kOutFmtVerticalLine + " Instruction set:  Intel AVX-512                               " + kOutFmtEol;
/// Print version output message.
OutputMessage kOutFmtAVX2
  = kOutFmtVerticalLine + " Instruction set:  Intel AVX 2                                 " + kOutFmtEol;
/// Print version output message.
OutputMessage kOutFmtAVX
  = kOutFmtVerticalLine + " Instruction set:  Intel AVX                                   " + kOutFmtEol;
/// Print version output message.
OutputMessage kOutFmtSSE42
  = kOutFmtVerticalLine + " Instruction set:  Intel SSE 4.2                               " + kOutFmtEol;
/// Print version output message.
OutputMessage kOutFmtSSE41
  = kOutFmtVerticalLine + " Instruction set:  Intel SSE 4.1                               " + kOutFmtEol;
/// Print version output message.
OutputMessage kOutFmtSSE3
  = kOutFmtVerticalLine + " Instruction set:  Intel SSE 3                                 " + kOutFmtEol;
/// Print version output message.
OutputMessage kOutFmtSSE2
  = kOutFmtVerticalLine + " Instruction set:  Intel SSE 2                                 " + kOutFmtEol;

//--------------------------------------------------- Medium types ---------------------------------------------------//
/// Output message - medium type.
OutputMessage kOutFmtMediumType2D
  = kOutFmtVerticalLine + " Medium type:                                               2D " + kOutFmtEol;
/// Output message - medium type.
OutputMessage kOutFmtMediumType3D
  = kOutFmtVerticalLine + " Medium type:                                               3D " + kOutFmtEol;
/// Output message - medium type.
OutputMessage kOutFmtMediumTypeAS
  = kOutFmtVerticalLine + " Medium type:                                               AS " + kOutFmtEol;

/// Output message - medium type.
OutputMessage kOutFmtWavePropagation
  = kOutFmtVerticalLine + " Wave propagation:                                   %9.9s " + kOutFmtEol;
/// Output message - medium type.
OutputMessage kOutFmtAbsorbtionType
  = kOutFmtVerticalLine + " Absorption type:                                    %9.9s " + kOutFmtEol;
/// Output message - medium type.
OutputMessage kOutFmtMediumParameters
  = kOutFmtVerticalLine + " Medium parameters:             %30.30s " + kOutFmtEol;

/// Output message - medium type.
OutputMessage kOutFmtAbsorbtionTypeLinear
  = "Linear";
/// Output message - medium type.
OutputMessage kOutFmtAbsorbtionTypeNonLinear
  = "Nonlinear";

/// Output message - medium type.
OutputMessage kOutFmtAbsorbtionLossless
  = "Lossless";
/// Output message - medium type.
OutputMessage kOutFmtAbsorbtionPowerLaw
  = "Power law";
/// Output message - medium type.
OutputMessage kOutFmtAbsorbtionStokes
  = "Stokes";

/// Output message - medium type.
OutputMessage kOutFmtMediumParametersHomegeneous
  = "Homogeneous";
/// Output message - medium type.
OutputMessage kOutFmtMediumParametersHeterogeneous
  = "Heterogeneous";
/// Output message - medium type.
OutputMessage kOutFmtMediumParametersHeterogeneousC0andRho0
  = "Heterogeneous (c0 and rho0)";

//--------------------------------------------------- Source types ---------------------------------------------------//
/// Output message - source type.
OutputMessage kOutFmtInitialPressureSource
  = kOutFmtVerticalLine + " Initial pressure source p0:                                   " + kOutFmtEol;
/// Output message - source type.
OutputMessage kOutFmtPressureSource
  = kOutFmtVerticalLine + " Pressure source:                                              " + kOutFmtEol;
/// Output message - source type.
OutputMessage kOutFmtVelocityXSource
  = kOutFmtVerticalLine + " Velocity source x:                                            " + kOutFmtEol;
/// Output message - source type.
OutputMessage kOutFmtVelocityYSource
  = kOutFmtVerticalLine + " Velocity source y:                                            " + kOutFmtEol;
/// Output message - source type.
OutputMessage kOutFmtVelocityZSource
  = kOutFmtVerticalLine + " Velocity source z:                                            " + kOutFmtEol;
/// Output message - source type.
OutputMessage kOutFmtTransducerSource
  = kOutFmtVerticalLine + " Transducer source:                                            " + kOutFmtEol;

/// Output message - source type.
OutputMessage kOutFmtSourceType
  = kOutFmtVerticalLine + " + Source type:                                         %6.6s " + kOutFmtEol;
/// Output message - source type.
OutputMessage kOutFmtSourceMode
  = kOutFmtVerticalLine + " + Source condition:           %31.31s " + kOutFmtEol;

/// Output message - source type.
OutputMessage kOutFmtSourceMemoryUsage
  = kOutFmtVerticalLine + " + Memory usage:                                   %9.2fMB " + kOutFmtEol;

/// Output message - source type.
OutputMessage kOutFmtSourceTypeSingle
  = "Single";
/// Output message - source type.
OutputMessage kOutFmtSourceTypeMany
  = "Many";
/// Output message - source type.
OutputMessage kOutFmtSourceModeDirichlet
  = "Dirichlet";
/// Output message - source type.
OutputMessage kOutFmtSourceModeAdditive
  = "Additive";
/// Output message - source type.
OutputMessage kOutFmtSourceModeAdditiveNoCorrection
  = "Additive (no source correction)";

//--------------------------------------------------- Sensor types ---------------------------------------------------//
/// Output message.
OutputMessage kOutFmtSensorName
  = kOutFmtVerticalLine + " %-32.32s                              " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtSensorFileUsage
  = kOutFmtVerticalLine + " + File usage:                                     %9.2fMB " + kOutFmtEol;

/// Output message.
OutputMessage kOutFmtSensorPressureRaw
  = "Pressure sensor p_raw";
/// Output message.
OutputMessage kOutFmtSensorPressureRms
  = "Pressure sensor p_rms";
/// Output message.
OutputMessage kOutFmtSensorPressureMax
  = "Pressure sensor p_max";
/// Output message.
OutputMessage kOutFmtSensorPressureMin
  = "Pressure sensor p_min";
/// Output message.
OutputMessage kOutFmtSensorPressureMaxAll
  = "Pressure sensor p_max_all";
/// Output message.
OutputMessage kOutFmtSensorPressureMinAll
  = "Pressure sensor p_min_all";
/// Output message.
OutputMessage kOutFmtSensorPressureFinal
  = "Pressure sensor p_final";

/// Output message.
OutputMessage kOutFmtSensorVelocityRaw
  = "Velocity sensor u_raw";
/// Output message.
OutputMessage kOutFmtSensorVelocityNonStaggeredRaw
  = "Velocity sensor u_non_staggered";
/// Output message.
OutputMessage kOutFmtSensorVelocityRms
  = "Velocity sensor u_rms";
/// Output message.
OutputMessage kOutFmtSensorVelocityMax
  = "Velocity sensor u_max";
/// Output message.
OutputMessage kOutFmtSensorVelocityMin
  = "Velocity sensor u_min";
/// Output message.
OutputMessage kOutFmtSensorVelocityMaxAll
  = "Velocity sensor u_max_all";
/// Output message.
OutputMessage kOutFmtSensorVelocityMinAll
  = "Velocity sensor u_min_all";
/// Output message.
OutputMessage kOutFmtSensorVelocityFinal
  = "Velocity sensor u_final";

/// Output message.
OutputMessage kOutFmtSimulatoinLenght
  = kOutFmtVerticalLine + " Simulation time steps:                              %9lu " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtSensorMaskIndex
  = kOutFmtVerticalLine + " Sensor mask type:                                       Index " + kOutFmtEol;
/// Output message.
OutputMessage kOutFmtSensorMaskCuboid
  = kOutFmtVerticalLine + " Sensor mask type:                                      Cuboid " + kOutFmtEol;

#endif /* OUTPUT_MESSAGES_H */
