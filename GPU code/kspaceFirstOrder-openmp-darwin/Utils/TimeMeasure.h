/**
 * @file      TimeMeasure.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file for class providing time measurement.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      15 August    2012, 09:35 (created) \n
 *            11 February  2020, 14:50 (revised)
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

#ifndef TIME_MEASURE_H
#define TIME_MEASURE_H

#ifdef _OPENMP
  #include <omp.h>
#else
  #include <sys/time.h>
#endif

/**
 * @class   TimeMeasure
 * @brief   Class measuring elapsed time.
 * @details Class measuring elapsed time, even over multiple simulation legs.
 */
class TimeMeasure
{
  public:
    /// Default constructor.
    TimeMeasure()
      : mStartTime(0.0),
        mStopTime(0.0),
        mElapsedTimeOverPreviousLegs(0.0)
    { };

    /// Copy constructor.
    TimeMeasure(const TimeMeasure&) = default;

    /// Destructor.
    ~TimeMeasure() = default;

    /// Operator =.
    TimeMeasure& operator=(const TimeMeasure&) = default;

    /// Take start timestamp.
    void start()
    {
      #ifdef _OPENMP
        mStartTime = omp_get_wtime();
      #else
        timeval actTime;
        gettimeofday(&actTime, nullptr);
        mStartTime = actTime.tv_sec + actTime.tv_usec * 1.0e-6;
      #endif
    };

    /// Take stop timestamp.
    void stop()
    {
      #ifdef _OPENMP
        mStopTime = omp_get_wtime();
      #else
        timeval actTime;
        gettimeofday(&actTime, nullptr);
        mStopTime = actTime.tv_sec + actTime.tv_usec * 1.0e-6;
      #endif
    };

    /**
     * @brief  Get elapsed time.
     * @return Elapsed time between start and stop timestamps.
     */
    double getElapsedTime() const
    {
      return mStopTime - mStartTime;
    };

    /**
     * @brief  Get cumulated elapsed time over all simulation legs.
     * @return Elapsed time all (including this one) legs.
     */
    double getElapsedTimeOverAllLegs() const
    {
      return mElapsedTimeOverPreviousLegs + (mStopTime - mStartTime);
    };

    /**
     * @brief  Get time spent in previous legs.
     * @return Elapsed time over previous legs.
     */
    double getElapsedTimeOverPreviousLegs() const
    {
      return mElapsedTimeOverPreviousLegs;
    };

    /**
     * @brief Set elapsed time in previous legs of the simulation.
     * @param [in] elapsedTime - Elapsed time.
     */
    void SetElapsedTimeOverPreviousLegs(const double elapsedTime)
    {
      mElapsedTimeOverPreviousLegs = elapsedTime;
    }

  private:
    /// Start timestamp of the interval
    double mStartTime;
    /// Stop timestamp of the interval
    double mStopTime;
    /// Elapsed time in previous simulation legs
    double mElapsedTimeOverPreviousLegs;
};// end of TimeMeasure
//----------------------------------------------------------------------------------------------------------------------

#endif	/* TIME_MEASURE_H */
