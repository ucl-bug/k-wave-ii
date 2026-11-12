/**
 * @file      ErrorMessagesLinux.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file containing linux specific error messages.
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

#ifndef ERROR_MESSAGES_LINUX_H
#define ERROR_MESSAGES_LINUX_H

/**
 * @brief   Datatype for error messages.
 * @details Datatype for error messages.
 */
using ErrorMessage = const std::string;

/// Error message header.
ErrorMessage kErrFmtHead
  = "┌───────────────────────────────────────────────────────────────┐\n"
    "│            !!! K-Wave experienced a fatal error !!!           │\n"
    "├───────────────────────────────────────────────────────────────┤\n";

/// Error message tailer.
ErrorMessage kErrFmtTail
  = "├───────────────────────────────────────────────────────────────┤\n"
    "│                      Execution terminated                     │\n"
    "└───────────────────────────────────────────────────────────────┘\n";

#endif /* ERROR_MESSAGES_LINUX_H */
