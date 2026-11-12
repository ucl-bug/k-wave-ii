/**
 * @file      Logger.cpp
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The implementation file containing a class responsible for printing out
 *            info and error messages (stdout, and stderr).
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      30 August    2017, 11:38 (created) \n
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

#include <string>
#include <sstream>

#include <Logger/Logger.h>

using std::string;

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Initialization ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/// static declaration of the LogLevel private field
Logger::LogLevel Logger::slogLevel = LogLevel::kBasic;

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Public methods ---------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Initialize or change logging level.
 */
void Logger::setLevel(const LogLevel actualLogLevel)
{
  slogLevel = actualLogLevel;
}// end of setLevel
//----------------------------------------------------------------------------------------------------------------------

/**
 * Log desired activity.
 */
void Logger::log(const LogLevel queryLevel,
                 const string&  message)
{
  if (queryLevel <= Logger::slogLevel)
  {
    std::cout << message;
  }
}// end of log
//----------------------------------------------------------------------------------------------------------------------

/**
 * Log an error.
 */
void Logger::error(const string& errorMessage)
{
  std::cerr << kErrFmtHead << errorMessage << kErrFmtTail;
}// end of error
//----------------------------------------------------------------------------------------------------------------------

/**
 * Log an error and terminate the execution.
 */
void Logger::errorAndTerminate(const string& errorMessage)
{
  error(errorMessage);

  exit(EXIT_FAILURE);
}// end of errorAndTerminate
//----------------------------------------------------------------------------------------------------------------------

/**
 * Flush logger, output messages only.
 */
void Logger::flush(const LogLevel queryLevel)
{
  if (queryLevel <= Logger::slogLevel)
  {
    std::cout.flush();
  }
}// end of flush
//----------------------------------------------------------------------------------------------------------------------

/**
 * Wrap the line based on delimiters and align it with the rest of the logger output.
 */
string Logger::wordWrapString(const string& inputString,
                              const string& delimiters,
                              const int     indentation,
                              const int     lineSize)
{
  std::istringstream textStream(inputString);
  string wrappedText;
  string word;
  string indentationString = kOutFmtVerticalLine;

  // Create indentation
  for (int i = 0; i < indentation - 1; i++)
  {
    indentationString += ' ';
  }

  wrappedText += kOutFmtVerticalLine + " ";
  int spaceLeft = lineSize - 2;

  // Until the text is empty
  while (textStream.good())
  {
    word = getWord(textStream, delimiters);
    if (spaceLeft < static_cast<int>(word.length()) + 3)
    { // Fill the end of the line
      for ( ; spaceLeft > 2; spaceLeft--)
      {
        wrappedText += " ";
      }
      wrappedText += " " + kOutFmtVerticalLine + "\n" + indentationString + word;
      spaceLeft = lineSize - (static_cast<int>(word.length()) + indentation);
    }
    else
    {
      // Add the word at the same line
      wrappedText += word;
      spaceLeft -= static_cast<int>(word.length());

      char c;
      if (textStream.get(c).good())
      {
        wrappedText += c;
        spaceLeft--;
      }
    }
  }

  // Fill the last line
  for ( ; spaceLeft > 2; spaceLeft--)
  {
    wrappedText += " ";
  }
  wrappedText += " "+ kOutFmtVerticalLine + "\n";

  return wrappedText;
}// end of wordWrapFileName
//----------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------//
//------------------------------------------------- Private methods --------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------//

/**
 * Extract a word from a string stream based on delimiters.
 */
string Logger::getWord(std::istringstream& textStream,
                       const string&       delimiters)
{
  string word = "";
  char c;

  while (textStream.get(c))
  {
    if (delimiters.find(c) != string::npos)
    {
      textStream.unget();
      break;
    }
    word += c;
  }

  return word;
}// end of getWord
//----------------------------------------------------------------------------------------------------------------------
