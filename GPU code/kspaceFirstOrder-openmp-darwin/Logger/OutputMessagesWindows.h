/**
 * @file      OutputMessagesWindows.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file containing all windows specific messages going to the standard output.
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

#ifndef OUTPUT_MESSAGES_WINDOWS_H
#define OUTPUT_MESSAGES_WINDOWS_H

/**
 * @brief   Datatype for output messages.
 * @details Datatype for output messages.
 */
using OutputMessage = const std::string;

//------------------------------------------- Windows visual style ---------------------------------------------------//
/// Output message - vertical line.
OutputMessage kOutFmtVerticalLine
  = "|";
/// Output message - new line.
OutputMessage kOutFmtNewLine
  = "\n";
/// Output message - end of line.
OutputMessage kOutFmtEol = kOutFmtVerticalLine + kOutFmtNewLine;

/// Output message - first separator.
OutputMessage kOutFmtFirstSeparator
  = "+---------------------------------------------------------------+\n";
/// Output message - separator.
OutputMessage kOutFmtSeparator
  = "+---------------------------------------------------------------+\n";
/// Output message -last separator.
OutputMessage kOutFmtLastSeparator
  = "+---------------------------------------------------------------+\n";

//----------------------------------------------------- Headers ------------------------------------------------------//
/// Output message.
OutputMessage kOutFmtSimulationDetailsTitle
  = "+---------------------------------------------------------------+\n"
    "|                      Simulation details                       |\n"
    "+---------------------------------------------------------------+\n";
/// Output message.
OutputMessage kOutFmtInitializationHeader
  = "+---------------------------------------------------------------+\n"
    "|                        Initialization                         |\n"
    "+---------------------------------------------------------------+\n";
/// Output message.
OutputMessage kOutFmtMediumDetails
  = "+---------------------------------------------------------------+\n"
    "|                        Medium details                         |\n"
    "+---------------------------------------------------------------+\n";
/// Output message.
OutputMessage kOutFmtSources
  = "+---------------------------------------------------------------+\n"
    "|                        Source details                         |\n"
    "+---------------------------------------------------------------+\n";
/// Output message.
OutputMessage kOutFmtSensors
  = "+---------------------------------------------------------------+\n"
    "|                        Sensor details                         |\n"
    "+---------------------------------------------------------------+\n";
/// Output message.
OutputMessage kOutFmtCompResourcesHeader
  = "+---------------------------------------------------------------+\n"
    "|                    Computational resources                    |\n"
    "+---------------------------------------------------------------+\n";
/// Output message.
OutputMessage kOutFmtSimulationHeader
  = "+---------------------------------------------------------------+\n"
    "|                          Simulation                           |\n"
    "+----------+----------------+--------------+--------------------+\n"
    "| Progress |  Elapsed time  |  Time to go  |  Est. finish time  |\n"
    "+----------+----------------+--------------+--------------------+\n";
/// Output message.
OutputMessage kOutFmtSimulationProgress
  = "|    %2li%c   |    %9.3fs  |  %9.3fs  |  %02i/%02i/%02i %02i:%02i:%02i |\n";
///Output message.
OutputMessage kOutFmtSimulationEndSeparator
  = "+----------+----------------+--------------+--------------------+\n";
///Output message.
OutputMessage kOutFmtSimulatoinFinalSeparator
  = "+----------+----------------+--------------+--------------------+\n";
/// Output message.
OutputMessage kOutFmtCheckpointHeader
  = "+---------------------------------------------------------------+\n"
    "|                         Checkpointing                         |\n"
    "+---------------------------------------------------------------+\n";
/// Output message.
OutputMessage kOutFmtSummaryHeader
  = "+---------------------------------------------------------------+\n"
    "|                            Summary                            |\n"
    "+---------------------------------------------------------------+\n";
/// Output message.
OutputMessage kOutFmtEndOfSimulation
  = "+---------------------------------------------------------------+\n"
    "|                       End of computation                      |\n"
    "+---------------------------------------------------------------+\n";

//------------------------------------------------ Print code version ------------------------------------------------//
/// Print version output message.
OutputMessage kOutFmtBuildNoDataTime
  = "|                       Build information                       |\n"
    "+---------------------------------------------------------------+\n"
    "| Build number:     kspaceFirstOrder v2.17                      |\n"
    "| Build date:       %*.*s                                 |\n"
    "| Build time:       %*.*s                                    |\n";

/// Print version output message.
OutputMessage kOutFmtLicense
  = "+---------------------------------------------------------------+\n"
    "| Contact email:    jarosjir@fit.vutbr.cz                       |\n"
    "| Contact web:      http://www.k-wave.org                       |\n"
    "+---------------------------------------------------------------+\n"
    "| Copyright (C) 2011-2020 SC@FIT Research Group, BUT, Czech Rep |\n"
    "+---------------------------------------------------------------+\n";

//------------------------------------------------- Usage ------------------------------------------------------------//
/// Usage massage.
OutputMessage kOutFmtUsagePart1
  = "|                             Usage                             |\n"
     "+---------------------------------------------------------------+\n"
     "|                     Mandatory parameters                      |\n"
     "+---------------------------------------------------------------+\n"
     "| -i <file_name>                | HDF5 input file               |\n"
     "| -o <file_name>                | HDF5 output file              |\n"
     "+-------------------------------+-------------------------------+\n"
     "|                      Optional parameters                      |\n"
     "+-------------------------------+-------------------------------+\n";

/// Usage massage.
OutputMessage kOutFmtUsagePart2
  = "| -r <interval_in_%%>            | Progress print interval       |\n"
    "|                               |   (default = %2ld%%)             |\n"
    "| -c <compression_level>        | Compression level <0,9>       |\n"
    "|                               |   (default = %1ld)               |\n"
    "| --benchmark <time_steps>      | Run only a specified number   |\n"
    "|                               |   of time steps               |\n"
    "| --verbose <level>             | Level of verbosity <0,2>      |\n"
    "|                               |   0 - basic, 1 - advanced,    |\n"
    "|                               |   2 - full                    |\n"
    "|                               |   (default = basic)           |\n"
    "| -h, --help                    | Print help                    |\n"
    "| --version                     | Print version and build info  |\n"
    "+-------------------------------+-------------------------------+\n"
    "| --checkpoint_file <file_name> | HDF5 checkpoint file          |\n"
    "| --checkpoint_interval <sec>   | Checkpoint after a given      |\n"
    "|                               |   number of seconds           |\n"
    "| --checkpoint_timesteps <step> | Checkpoint after a given      |\n"
    "|                               |   number of time steps        |\n"
    "+-------------------------------+-------------------------------+\n"
    "|                          Output flags                         |\n"
    "+-------------------------------+-------------------------------+\n"
    "| -p                            | Store acoustic pressure       |\n"
    "|                               |   (default output flag)       |\n"
    "|                               |   (the same as --p_raw)       |\n"
    "| --p_raw                       | Store raw time series of p    |\n"
    "| --p_rms                       | Store rms of p                |\n"
    "| --p_max                       | Store max of p                |\n"
    "| --p_min                       | Store min of p                |\n"
    "| --p_max_all                   | Store max of p (whole domain) |\n"
    "| --p_min_all                   | Store min of p (whole domain) |\n"
    "| --p_final                     | Store final pressure field    |\n"
    "+-------------------------------+-------------------------------+\n"
    "| -u                            | Store ux, uy, uz              |\n"
    "|                               |    (the same as --u_raw)      |\n"
    "| --u_raw                       | Store raw time series of      |\n"
    "|                               |    ux, uy, uz                 |\n"
    "| --u_non_staggered_raw         | Store non-staggered raw time  |\n"
    "|                               |   series of ux, uy, uz        |\n"
    "| --u_rms                       | Store rms of ux, uy, uz       |\n"
    "| --u_max                       | Store max of ux, uy, uz       |\n"
    "| --u_min                       | Store min of ux, uy, uz       |\n"
    "| --u_max_all                   | Store max of ux, uy, uz       |\n"
    "|                               |   (whole domain)              |\n"
    "| --u_min_all                   | Store min of ux, uy, uz       |\n"
    "|                               |   (whole domain)              |\n"
    "| --u_final                     | Store final acoustic velocity |\n"
    "+-------------------------------+-------------------------------+\n"
    "| -s <time_step>                | When data collection begins   |\n"
    "|                               |   (default = 1)               |\n"
    "| --copy_sensor_mask            | Copy sensor mask to the       |\n"
    "|                               |    output file                |\n"
    "+-------------------------------+-------------------------------+\n";

/// Usage massage.
OutputMessage kOutFmtUsageThreads
  = "| -t <num_threads>              | Number of CPU threads         |\n"
    "|                               |  (default = %3d)              |\n";

#endif /* OUTPUT_MESSAGES_WINDOWS_H */
