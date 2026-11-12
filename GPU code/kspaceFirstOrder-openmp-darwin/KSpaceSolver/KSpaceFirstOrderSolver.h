/**
 * @file      KSpaceFirstOrderSolver.h
 *
 * @author    Jiri Jaros \n
 *            Faculty of Information Technology \n
 *            Brno University of Technology \n
 *            jarosjir@fit.vutbr.cz
 *
 * @brief     The header file containing the main class of the project responsible for the entire simulation.
 *
 * @version   kspaceFirstOrder 2.17
 *
 * @date      12 July      2012, 10:27 (created)\n
 *            11 February  2020, 14:34 (revised)
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

#ifndef KSPACE_FIRST_ORDER_SOLVER_H
#define KSPACE_FIRST_ORDER_SOLVER_H

#include <functional>

#include <Parameters/Parameters.h>

#include <Containers/MatrixContainer.h>
#include <Containers/OutputStreamContainer.h>

#include <MatrixClasses/RealMatrix.h>
#include <MatrixClasses/ComplexMatrix.h>
#include <MatrixClasses/IndexMatrix.h>
#include <MatrixClasses/FftwComplexMatrix.h>
#include <MatrixClasses/FftwRealMatrix.h>

#include <OutputStreams/BaseOutputStream.h>
#include <Utils/TimeMeasure.h>

/**
 * @class   KSpaceFirstOrderSolver
 * @brief   Class responsible for solving the ultrasound propagation in fluid medium.
 * @details The simulation is based on the k-space first order method. The solver supports 2D normal and AS medium, and
 *          3D normal medium. This class maintain the whole k-wave (implements the time loop).
 */
class KSpaceFirstOrderSolver
{
  public:
    /// Constructor.
    KSpaceFirstOrderSolver();
    /// Copy constructor not allowed for public.
    KSpaceFirstOrderSolver(const KSpaceFirstOrderSolver&) = delete;
    /// Destructor.
    virtual ~KSpaceFirstOrderSolver();
    /// Operator = not allowed for public.
    KSpaceFirstOrderSolver& operator=(const KSpaceFirstOrderSolver&) = delete;

    /// Memory allocation.
    virtual void allocateMemory();
    /// Memory deallocation.
    virtual void freeMemory();

    /**
     * @brief   Load simulation data.
     * @details If checkpointing is enabled, this may include reading data from checkpoint and output files.
     */
    virtual void loadInputData();

    /**
     * @brief   This method computes the simulation.
     * @details It first initializes FFTs, then runs the pre-processing phase, continues through the simulation time
     *          loop and applies post-process on the data.
     */
    virtual void compute();

    /**
     * @brief  Get memory usage in MB.
     * @return Memory usage in MB.
     */
    size_t getMemoryUsage() const;

    /**
     * @brief  Get expected disk space usage in MB.
     * @return Expected disk usage by the output file in MB.
     */
    size_t getFileUsage();

    /**
     * @brief  Get code name - release code version.
     * @return Release code version.
     */
    std::string getCodeName() const;

    /// Print the code name and license.
    void   printFullCodeNameAndLicense() const;

    /**
     * @brief  Get total simulation time.
     * @return Total simulation time in seconds.
     */
    double getTotalTime()          const { return mTotalTime.getElapsedTime(); };
    /**
     * @brief  Get total simulation time accumulated over all legs.
     * @return Total execution time in seconds accumulated over all legs.
     */
    double getCumulatedTotalTime() const { return mTotalTime.getElapsedTimeOverAllLegs(); };

  protected:
    /**
     * @brief Check the output file has the correct format and version.
     * @throw ios::failure - If an error happens.
     */
    void checkOutputFile();
    /**
     * @brief Check the checkpoint file has the correct format and version.
     * @throw ios::failure - If an error happens.
     */
    void checkCheckpointFile();

    /// Read the header of the output file and sets the cumulative elapsed time from the first log.
    void readElapsedTimeFromOutputFile();

    /**
     * @brief  Was the loop interrupted to checkpoint?
     * @return true if the simulation has been interrupted.
     */
    bool isCheckpointInterruption() const;

    /// Initialize FFTW plans.
    void initializeFftwPlans();
    /**
     * @brief   Compute pre-processing phase.
     * @details Initialize all indices, pre-compute constants such as c^2, rho0Sgx * dt  and create kappa, derivative
     *          and shift operators, PML, absorbEta, absorbTau, absorbNabla1, absorbNabla2  matrices.
     * @tparam  simulationDimension - Dimensionality of the simulation.
     */
    template<Parameters::SimulationDimension simulationDimension>
    void preProcessing();
    /**
     * @brief  Compute the main time loop of the k-space first order solver.
     *
     * @tparam simulationDimension - Dimensionality of the simulation.
     * @tparam rho0ScalarFlag      - Is density homogeneous?
     * @tparam bOnAScalarFlag      - Is nonlinearity homogenous?
     * @tparam c0ScalarFlag        - Is sound speed homogeneous?
     * @tparam alphaCoefScalarFlag - Is absorption homogeneous?
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag,
             bool                            bOnAScalarFlag,
             bool                            c0ScalarFlag,
             bool                            alphaCoefScalarFlag>
    void computeMainLoop();
    /// Post processing and closing the output streams.
    void postProcessing();

    /// Store sensor data.
    void storeSensorData();
    /// Write statistics and header into the output file.
    void writeOutputDataInfo();
    /// Write checkpoint data and flush aggregated outputs into the output file.
    void writeCheckpointData();

    /// Print progress statistics.
    void printStatistics();

    //----------------------------------------- Compute pressure gradient --------------------------------------------//
    /**
     * @brief   Compute pressure gradient for normal medium.
     * @details Results dp/dx, dp/dy and dp/dz are stored in kTemp1RealND, kTemp1RealND and kTemp1RealND.
     *
     * @tparam  simulationDimension - Dimensionality of the simulation.
     *
     * <b>Matlab code:</b> \code
     *  p_k = fft(dtt1D(p, DCT3, 2), [], 1);
     *  kTemp1RealND = ifftn(bsxfun(\@times, ddx_k_shift_pos, kappa .* fftn(p_k))
     *  kTemp2RealND = ifftn(bsxfun(\@times, ddy_k_shift_pos, kappa .* fftn(p_k))
     *  kTemp3RealND = ifftn(bsxfun(\@times, ddz_k_shift_pos, kappa .* fftn(p_k))
     * \endcode
     */
    template<Parameters::SimulationDimension simulationDimension>
    void computePressureGradient();
    /**
     * @brief   Compute pressure gradient for axisymmetric medium, WSWA symmetry.
     * @details Results dp/dx and dp/dy are stored in kTemp1RealND and kTemp1RealND.
     *
     * <b>Matlab code:</b> \code
     *  p_k = fft(dtt1D(p, DCT3, 2), [], 1);
     *
     *  kTemp1RealND = dtt1D(real(ifft(bsxfun(@times, ddx_k_shift_pos, kappa .* p_k), [], 1)), DCT2, 2) ./ M;
     *  kTemp2RealND = dtt1D(real(ifft(bsxfun(@times, ddy_k_wswa, kappa .* p_k), [], 1)), DST4, 2) ./ M;
     * \endcode
     *
     */
    void computePressureGradientAS();

    //---------------------------------------------- Compute velocity ------------------------------------------------//
    /**
     * @brief   Compute new values of acoustic velocity in all used dimensions (UxSgx, UySgy, UzSgz).
     * @details This routine is used in both normal and axisymmetric medium. The pressure gradients p_k or
     *          dpdx_sgx and dpdy_sgy on staggered grids are stored in kTemp1RealND, kTemp2RealND, kTemp3RealND
     *          variables.
     *
     * @tparam  simulationDimension - Dimensionality of the simulation.
     * @tparam  rho0ScalarFlag      - Is density homogeneous?
     *
     * <b>Matlab code:</b> \code
     *  ux_sgx = bsxfun(@times, pml_x_sgx, bsxfun(@times, pml_x_sgx, ux_sgx) - dt .* rho0_sgx_inv .* kTemp1RealND);
     *  uy_sgy = bsxfun(@times, pml_y_sgy, bsxfun(@times, pml_y_sgy, uy_sgy) - dt .* rho0_sgy_inv .* kTemp2RealND);
     *  uz_sgz = bsxfun(@times, pml_z_sgz, bsxfun(@times, pml_z_sgz, uz_sgz) - dt .* rho0_sgz_inv .* kTemp3RealND);
     * \endcode
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag>
    void computeVelocity();

    /**
     * @brief  Compute acoustic velocity on uniform grid.
     *
     * @tparam simulationDimension - Dimensionality of the simulation.
     * @tparam rho0ScalarFlag      - Is density homogeneous?
     *
     * <b> Matlab code: </b> \code
     *  ux_sgx = bsxfun(@times, pml_x_sgx, bsxfun(@times, pml_x_sgx, ux_sgx) - dt .* rho0_sgx_inv .* kTemp1RealND)
     *  uy_sgy = bsxfun(@times, pml_y_sgy, bsxfun(@times, pml_y_sgy, uy_sgy) - dt .* rho0_sgy_inv .* kTemp1Rea2ND)
     *  uz_sgz = bsxfun(@times, pml_z_sgz, bsxfun(@times, pml_z_sgz, uz_sgz) - dt .* rho0_sgz_inv .* kTemp1Rea3ND)
     *\endcode
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag>
    void computeVelocityUniform();
    /**
     * @brief  Compute acoustic velocity for homogenous medium and nonuniform grid.
     * @tparam simulationDimension - Dimensionality of the simulation.
     *
     * <b> Matlab code: </b> \code
     *  ux_sgx = bsxfun(@times, pml_x_sgx, bsxfun(@times, pml_x_sgx, ux_sgx)  ...
     *                  - dt .* rho0_sgx_inv .* dxudxnSgx.* kTemp1RealND)
     *  uy_sgy = bsxfun(@times, pml_y_sgy, bsxfun(@times, pml_y_sgy, uy_sgy) ...
     *                  - dt .* rho0_sgy_inv .* dyudynSgy.* kTemp2RealND)
     *  uz_sgz = bsxfun(@times, pml_z_sgz, bsxfun(@times, pml_z_sgz, uz_sgz)
     *                  - dt .* rho0_sgz_inv .* dzudznSgz.* kTemp3RealND)
     *\endcode
     */
    template<Parameters::SimulationDimension simulationDimension>
    void computeVelocityHomogeneousNonuniform();

    /**
     * @brief  Compute shifted velocities for --u_non_staggered flag.
     * @tparam simulationDimension - Dimensionality of the simulation.
     *
     * <b>Matlab code:</b> \code
     *  ux_shifted = real(ifft(bsxfun(\@times, x_shift_neg, fft(ux_sgx, [], 1)), [], 1));
     *  uy_shifted = real(ifft(bsxfun(\@times, y_shift_neg, fft(uy_sgy, [], 2)), [], 2));
     *  uz_shifted = real(ifft(bsxfun(\@times, z_shift_neg, fft(uz_sgz, [], 3)), [], 3));
     * \endcode
     */
    template<Parameters::SimulationDimension simulationDimension>
    void computeShiftedVelocity();

    //----------------------------------------- Compute velocity gradient --------------------------------------------//
    /**
     * @brief  Compute new values of acoustic velocity gradients.
     * @tparam simulationDimension - Dimensionality of the simulation.
     *
     * <b>Matlab code:</b> \code
     *  duxdx = real(ifftn( bsxfun(@times, ddx_k_shift_neg, kappa .* fftn(ux_sgx)) ));
     *  duydy = real(ifftn( bsxfun(@times, ddy_k_shift_neg, kappa .* fftn(uy_sgy)) ));
     *  duzdz = real(ifftn( bsxfun(@times, ddz_k_shift_neg, kappa .* fftn(uz_sgz)) ));
     * \endcode
     */
    template<Parameters::SimulationDimension simulationDimension>
    void computeVelocityGradient();
    /**
     * @brief  Compute new values of acoustic velocity gradients, axisymmetric medium, WSWA case symmetry.
     *
     * <b>Matlab code:</b> \code
     *  duxdx = dtt1D(real(ifft(...
     *                kappa .* bsxfun(@times, ddx_k_shift_neg, fft(dtt1D(ux_sgx, DCT3, 2), [], 1)) ...
     *                , [], 1)), DCT2, 2) ./ M;
     *
     *  duydy = dtt1D(real(ifft(kappa .* (...
     *                bsxfun(@times, ddy_k_hahs, fft(dtt1D(uy_sgy, DST4, 2), [], 1)) + ...
     *                fft(dtt1D(bsxfun(@times, 1./y_vec_sg, uy_sgy), DCT4, 2), [], 1) ...
     *                ), [], 1)), DCT2, 2) ./ M;
     * \endcode
     */
    void computeVelocityGradientAS();

    //---------------------------------------------- Compute density -------------------------------------------------//
    /**
     * @brief  Compute new values of acoustic density for nonlinear case.
     *
     * @tparam simulationDimension - Dimensionality of the simulation.
     * @tparam rho0ScalarFlag      - Is density homogeneous?
     *
     * <b>Matlab code:</b> \code
     *  rho0_plus_rho = 2 .* (rhox + rhoy + rhoz) + rho0;
     *  rhox = bsxfun(@times, pml_x, bsxfun(@times, pml_x, rhox) - dt .* rho0_plus_rho .* duxdx);
     *  rhoy = bsxfun(@times, pml_y, bsxfun(@times, pml_y, rhoy) - dt .* rho0_plus_rho .* duydy);
     *  rhoz = bsxfun(@times, pml_z, bsxfun(@times, pml_z, rhoz) - dt .* rho0_plus_rho .* duzdz);
     * \endcode
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag>
    void computeDensityNonliner();
    /**
     * @brief  Compute new values of acoustic density for linear case.
     *
     * @tparam simulationDimension - Dimensionality of the simulation.
     * @tparam rho0ScalarFlag      - Is density homogeneous?
     *
     * <b>Matlab code:</b> \code
     *  rhox = bsxfun(@times, pml_x, bsxfun(@times, pml_x, rhox) - dt .* rho0 .* duxdx);
     *  rhoy = bsxfun(@times, pml_y, bsxfun(@times, pml_y, rhoy) - dt .* rho0 .* duydy);
     *  rhoz = bsxfun(@times, pml_z, bsxfun(@times, pml_z, rhoz) - dt .* rho0 .* duzdz);
     * \endcode
     *
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag>
    void computeDensityLinear();

    //---------------------------------------------- Compute pressure ------------------------------------------------//
    /**
     * @brief  Compute acoustic pressure.
     *
     * @tparam simulationDimension - Dimensionality of the simulation.
     * @tparam rho0ScalarFlag      - Is density homogeneous?
     * @tparam bOnAScalarFlag      - Is nonlinearity homogenous?
     * @tparam c0ScalarFlag        - Is sound speed homogeneous?
     * @tparam alphaCoefScalarFlag - Is absorption homogeneous?
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag,
             bool                            bOnAScalarFlag,
             bool                            c0ScalarFlag,
             bool                            alphaCoefScalarFlag>
    void computePressure();

    /**
     * @brief  Sum sub-terms to calculate new pressure in nonlinear lossless case.
     *
     * @tparam simulationDimension - Dimensionality of the simulation.
     * @tparam rho0ScalarFlag      - Is density homogeneous?
     * @tparam c0ScalarFlag        - Is sound speed homogeneous?
     * @tparam OnAScalarFlag       - Is nonlinearity homogeneous?
     *
     * <b>Matlab code:</b> \code
     *  p = c.^2 .* (rhox + rhoy + rhoz + medium.BonA .* (rhox + rhoy + rhoz).^2 ./ (2 .* rho0));
     *\endcode
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag,
             bool                            bOnAScalarFlag,
             bool                            c0ScalarFlag>
    void sumPressureTermsNonlinearLossless();
    /**
     * @brief  Compute acoustic pressure for nonlinear power law absorbing case, normal medium.
     *
     * @tparam simulationDimension - Dimensionality of the simulation.
     * @tparam rho0ScalarFlag      - Is density homogeneous?
     * @tparam bOnAScalarFlag      - Is nonlinearity homogenous?
     * @tparam c0ScalarFlag        - Is sound speed homogeneous?
     * @tparam alphaCoefScalarFlag - Is absorption homogeneous?
     *
     * <b>Matlab code:</b> \code
     *  p = c.^2 .* (...
     *      (rhox + rhoy + rhoz) ...
     *       + absorb_tau .* real(ifftn( absorb_nabla1 .* fftn(rho0 .* (duxdx + duydy + duzdz)) ))...
     *       - absorb_eta .* real(ifftn( absorb_nabla2 .* fftn(rhox + rhoy + rhoz) ))...
     *       + medium.BonA .*(rhox + rhoy + rhoz).^2 ./ (2 .* rho0) ...
     *      );
     * \endcode
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag,
             bool                            bOnAScalarFlag,
             bool                            c0ScalarFlag,
             bool                            alphaCoefScalarFlag>
    void computePressureNonlinearPowerLaw();
    /**
     * @brief  Sum sub-terms to calculate new pressure with stokes absorption in nonlinear case.
     *
     * @tparam simulationDimension - Dimensionality of the simulation.
     * @tparam rho0ScalarFlag      - Is density homogeneous?
     * @tparam bOnAScalarFlag      - Is nonlinearity homogeneous?
     * @tparam c0ScalarFlag        - Is sound speed homogeneous?
     * @tparam absorbTauScalarFlag - Is absorbTau homogeneous?
     *
     * <b>Matlab code:</b> \code
     *  case 'stokes'
     *    p = c0.^2 .* ( ...
     *          (rhox + rhoy + rhoz) ...
     *          + absorb_tau .* rho0 .* (duxdx + duydy) ...
     *          + medium.BonA .* (rhox + rhoy).^2 ./ (2 .* rho0) ...
     *         );
     * \endcode
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag,
             bool                            bOnAScalarFlag,
             bool                            c0ScalarFlag,
             bool                            absorbTauScalarFlag>
    void sumPressureTermsNonlinearStokes();

    /**
     * @brief  Sum sub-terms to calculate new pressure in linear lossless case.
     *
     * @tparam simulationDimension - Dimensionality of the simulation.
     * @tparam c0ScalarFlag        - Is sound speed homogeneous?
     *
     * <b>Matlab code:</b> \code
     *  p = c.^2 .* (rhox + rhoy + rhoz);
     * \endcode
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            c0ScalarFlag>
    void sumPressureTermsLinearLossless();
    /**
     * @brief  Compute acoustic pressure for linear power law absorbing case, normal medium.
     *
     * @tparam simulationDimension - Dimensionality of the simulation.
     * @tparam rho0ScalarFlag      - Is density homogeneous?
     * @tparam c0ScalarFlag        - Is sound speed homogeneous?
     * @tparam alphaCoefScalarFlag - Is absorption homogeneous?
     *
     * <b>Matlab code:</b> \code
     *  p = c.^2 .* ((rhox + rhoy + rhoz) ...
     *               + absorb_tau .* real(ifftn( absorb_nabla1 .* fftn(rho0 .* (duxdx + duydy + duzdz)) )) ...
     *               - absorb_eta .* real(ifftn( absorb_nabla2 .* fftn(rhox + rhoy + rhoz) )) ...
     *                );
     *\endcode
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag,
             bool                            c0ScalarFlag,
             bool                            alphaCoefScalarFlag>
    void computePressureLinearPowerLaw();
    /**
     * @brief  Sum sub-terms to calculate new pressure with stokes absorption in linear case.
     *
     * @tparam simulationDimension - Dimensionality of the simulation.
     * @tparam rho0ScalarFlag      - Is density homogeneous?
     * @tparam c0ScalarFlag        - Is sound speed homogeneous?
     * @tparam absorbTauScalarFlag - Is absorbTau homogeneous?
     *
     * <b>Matlab code:</b> \code*
     *  p = c.^2 .* ((rhox + rhoy + rhoz) + absorb_tau .* rho0 .* (duxdx + duydy + duzdz));
     * \endcode
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag,
             bool                            c0ScalarFlag,
             bool                            absorbTauScalarFlag>
    void sumPressureTermsLinearStokes();

    /**
     * @brief  Compute three temporary sums before taking FFTs in the power law absorption during the nonlinear
     *         calculation of new pressure.
     *
     * @tparam simulationDimension      - Dimensionality of the simulation.
     * @tparam rho0ScalarFlag           - Is density homogeneous?
     * @tparam bOnAScalarFlag           - Is nonlinearity homogenous?
     *
     * @param [out] densitySum          - rhoX + rhoY + rhoZ
     * @param [out] nonlinearTerm       - BOnA + densitySum ^2 / 2 * rho0
     * @param [out] velocityGradientSum - rho0* (duxdx + duydy + duzdz)
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag,
             bool                            bOnAScalarFlag>
    void computePressureTermsNonlinearPowerLaw(RealMatrix& densitySum,
                                               RealMatrix& nonlinearTerm,
                                               RealMatrix& velocityGradientSum);
    /**
     * @brief  Compute two temporary sums before taking the FFT in the power law absorption during the linear
     *         calculation of new pressure.
     *
     * @tparam simulationDimension      - Dimensionality of the simulation.
     * @tparam rho0ScalarFlag           - Is density homogeneous?
     *
     * @param [out] densitySum          - rhoxSgx + rhoySgy + rhozSgz
     * @param [out] velocityGradientSum - rho0* (duxdx + duydy + duzdz)
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag>
    void computePressureTermsLinearPowerLaw(RealMatrix& densitySum,
                                            RealMatrix& velocityGradientSum);

    /**
     * @brief Compute power law absorbing term with abosrbNabla1 and absorbNabla2.
     *
     * @param [in,out] fftPart1 - fftPart1 = absorbNabla1 .* fftPart1
     * @param [in,out] fftPart2 - fftPart1 = absorbNabla1 .* fftPart2
     */
    void computePowerLawAbsorbtionTerm(FftwComplexMatrix& fftPart1,
                                       FftwComplexMatrix& fftPart2);
    /**
     * @brief  Sum sub-terms after FFTs to calculate new pressure in the nonlinear power law absorption case.
     *
     * @tparam c0ScalarFlag        - Is sound speed homogeneous?
     * @tparam tauAndEtaScalarFlag - Are absorbTau and absorbEta scalars?
     *
     * @param [in] absorbTauTerm   - tau component.
     * @param [in] absorbEtaTerm   - eta component  of the pressure term.
     * @param [in] nonlinearTerm   - rho0 * (duxdx + duydy + duzdz)
     */
    template<bool c0ScalarFlag,
             bool tauAndEtaScalarFlag>
    void sumPressureTermsNonlinearPowerLaw(const RealMatrix& absorbTauTerm,
                                           const RealMatrix& absorbEtaTerm,
                                           const RealMatrix& nonlinearTerm);
    /**
     * @brief  Sum sub-terms after FFTs to calculate new pressure in linear case.
     *
     * @tparam c0ScalarFlag        - Is sound speed homogeneous?
     * @tparam tauAndEtaScalarFlag - Are absorbTau and absorbEeta homogeneous?
     *
     * @param [in] absorbTauTerm   - tau component.
     * @param [in] absorbEtaTerm   - eta component  of the pressure term.
     * @param [in] densitySum      - Sum of three components of density (rhoXSgx + rhoYSgy + rhoZSgx).
     */
    template<bool c0ScalarFlag,
             bool tauAndEtaScalarFlag>
    void sumPressureTermsLinear(const RealMatrix& absorbTauTerm,
                                const RealMatrix& absorbEtaTerm,
                                const RealMatrix& densitySum);

    //------------------------------------------------ Add sources ---------------------------------------------------//
    /**
     * @brief  Add in pressure source.
     * @tparam simulationDimension - Dimensionality of the simulation.
     */
    template<Parameters::SimulationDimension simulationDimension>
    void addPressureSource();
    /// Add transducer data source to velocity x component.
    void addTransducerSource();
    /// Add in all velocity sources.
    void addVelocitySource();

    /**
     * @brief Add in velocity source terms.
     *
     * @param [in] velocityMatrix      - Velocity matrix to add the source in.
     * @param [in] velocitySourceInput - Source input to add.
     * @param [in] velocitySourceIndex - Source geometry index matrix.
     */
    void computeVelocitySourceTerm(RealMatrix&        velocityMatrix,
                                   const RealMatrix&  velocitySourceInput,
                                   const IndexMatrix& velocitySourceIndex);
    /**
     * @brief  Calculate initial pressure source.
     *
     * @tparam simulationDimension - Dimensionality of the simulation.
     * @tparam rho0ScalarFlag      - Is density homogeneous?
     * @tparam c0ScalarFlag        - Is sound speed homogeneous?
     *
     * <b>Matlab code:</b> \code
     *  p = source.p0;
     *  rhox = source.p0 ./ (3 .* c.^2);
     *  rhoy = source.p0 ./ (3 .* c.^2);
     *  rhoz = source.p0 ./ (3 .* c.^2);
     *
     *  ux_sgx = dt .* rho0_sgx_inv .* real(ifftn( bsxfun(@times, ddx_k_shift_pos, kappa .* fftn(p)) )) / 2;
     *  uy_sgy = dt .* rho0_sgy_inv .* real(ifftn( bsxfun(@times, ddy_k_shift_pos, kappa .* fftn(p)) )) / 2;
     *  uz_sgz = dt .* rho0_sgz_inv .* real(ifftn( bsxfun(@times, ddz_k_shift_pos, kappa .* fftn(p)) )) / 2;
     * \endcode
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag,
             bool                            c0ScalarFlag>
    void addInitialPressureSource();

    /**
     * @brief  Compute velocity for the initial pressure problem, uniform grid.
     *
     * @tparam simulationDimension - Dimensionality of the simulation.
     * @tparam rho0ScalarFlag      - Is density homogeneous?
     *
     * <b> Matlab code: </b> \code
     *  ux_sgx = dt ./ rho0_sgx .* ifft(ux_sgx).
     *  uy_sgy = dt ./ rho0_sgy .* ifft(uy_sgy).
     *  uz_sgz = dt ./ rho0_sgz .* ifft(uz_sgz).
     * \endcode
     */
    template<Parameters::SimulationDimension simulationDimension,
             bool                            rho0ScalarFlag>
    void computeInitialVelocityUniform();
    /**
     * @brief  Compute acoustic velocity for initial pressure problem, homogenous medium, nonuniform grid.
     * @tparam simulationDimension - Dimensionality of the simulation.
     *
     * <b> Matlab code: </b> \code
     *  ux_sgx = dt ./ rho0_sgx .* dxudxn_sgx .* ifft(ux_sgx)
     *  uy_sgy = dt ./ rho0_sgy .* dyudxn_sgy .* ifft(uy_sgy)
     *  uz_sgz = dt ./ rho0_sgz .* dzudzn_sgz .* ifft(uz_sgz)
     * \endcode
     */
    template<Parameters::SimulationDimension simulationDimension>
    void computeInitialVelocityHomogeneousNonuniform();

    /**
     * @brief  Calculate dt ./ rho0 for nonuniform grids.
     * @tparam simulationDimension - Dimensionality of the simulation.
     */
    template<Parameters::SimulationDimension simulationDimension>
    void generateInitialDenisty();

    //----------------------------------------- Generate constant matrices -------------------------------------------//
    /// Generate kappa matrix for lossless medium.
    void generateKappa();
    /// Generate kappa matrix and derivative operators for axisymmetric media.
    void generateKappaAS();

    /// Generate derivative operators for normal medium (dd{x,y,z}_k_shift_pos, dd{x,y,z}_k_shift_neg).
    void generateDerivativeOperators();
    /// Generate derivative operators for axisymmetric medium (ddx_k_shift_{pos,neg}, ddyKHahs, ddyKWswa, yVecSg).
    void generateDerivativeOperatorsAS();

    /// Generate sourceKappa matrix for additive sources.
    void generateSourceKappa();
    /// Generate sourceKappa matrix for additive sources for axisymmetric media.
    void generateSourceKappaAS();
    /// Generate kappa matrix, absorbNabla1, absorbNabla2 for absorbing medium.
    void generateKappaAndNablas();
    /// Generate absorbTau, absorbEta for heterogenous medium and power law absorption.
    void generateTauAndEta();
    /// Generate absorbTau for heterogenous medium and stokes absorption.
    void generateTau();
    /// Generate shift variables for non-staggered velocity sampling.
    void generateNonStaggeredShiftVariables();
    /// Generate PML and staggered PML.
    void generatePml();
    /// Generate square of velocity.
    void generateC2();

    //----------------------------------------------- Index routines -------------------------------------------------//
    /**
     * @brief Compute 1D index using 3 spatial coordinates and the size of the matrix.
     * @param [in] z              - z coordinate
     * @param [in] y              - y coordinate
     * @param [in] x              - x coordinate
     * @param [in] dimensionSizes - Size of the matrix.
     * @return
     */
    size_t get1DIndex(const size_t          z,
                      const size_t          y,
                      const size_t          x,
                      const DimensionSizes& dimensionSizes) const;
    /**
     * @brief Compute 1D index using 2 spatial coordinates and the size of the matrix.
     * @param [in] y              - y coordinate
     * @param [in] x              - x coordinate
     * @param [in] dimensionSizes - Size of the matrix.
     * @return
     */
    size_t get1DIndex(const size_t          y,
                      const size_t          x,
                      const DimensionSizes& dimensionSizes) const;

    //--------------------------------------- Getters for temporary matrices -----------------------------------------//
    /**
     * @brief  Get the first real 2D/3D temporary matrix. This matrix share memory with temp1FftRealND.
     * @return Temporary real 2D/3D matrix.
     */
    RealMatrix& getTemp1RealND()
    {
      return mMatrixContainer.getMatrix<RealMatrix>(MatrixContainer::MatrixIdx::kTemp1RealND);
    };
    /**
     * @brief  Get the second real 2D/3D temporary matrix. This matrix share memory with temp2FftRealND.
     * @return Temporary real 2D/3D matrix.
     */
    RealMatrix& getTemp2RealND()
    {
      return mMatrixContainer.getMatrix<RealMatrix>(MatrixContainer::MatrixIdx::kTemp2RealND);
    };
    /**
     * @brief  Get the third real 3D temporary matrix. This matrix is only present for 3D simulations,
     * @return Temporary real 3D matrix.
     */
    RealMatrix& getTemp3RealND()
    {
      return mMatrixContainer.getMatrix<RealMatrix>(MatrixContainer::MatrixIdx::kTemp3RealND);
    };

    /**
     * @brief  Get the first temporary matrix for R2R fft. This matrix share memory with temp1RealND.
     * @return Temporary real 2D matrix for axisymmetric code.
     */
    FftwRealMatrix& getTemp1FftwRealND()
    {
      return mMatrixContainer.getMatrix<FftwRealMatrix>(MatrixContainer::MatrixIdx::kTemp1RealND);
    };
    /**
     * @brief  Get the second temporary matrix for R2R fft. This matrix share memory with temp2RealND.
     * @return Temporary real 2D matrix for axisymmetric code.
     */
    FftwRealMatrix& getTemp2FftwRealND()
    {
      return mMatrixContainer.getMatrix<FftwRealMatrix>(MatrixContainer::MatrixIdx::kTemp2RealND);
    };

    /**
     * @brief  Get temporary matrix for 1D fft in x.
     * @return Temporary complex 3D matrix.
     */
    FftwComplexMatrix& getTempFftwX()
    {
      return mMatrixContainer.getMatrix<FftwComplexMatrix>(MatrixContainer::MatrixIdx::kTempFftwX);
    };
    /**
     * @brief  Get temporary matrix for 1D fft in y.
     * @return Temporary complex 3D matrix.
     */
    FftwComplexMatrix& getTempFftwY()
    {
      return mMatrixContainer.getMatrix<FftwComplexMatrix>(MatrixContainer::MatrixIdx::kTempFftwY);
    };
    /**
     * @brief  Get temporary matrix for 1D fft in z.
     * @return Temporary complex 3D matrix.
     */
    FftwComplexMatrix& getTempFftwZ()
    {
      return mMatrixContainer.getMatrix<FftwComplexMatrix>(MatrixContainer::MatrixIdx::kTempFftwZ);
    };
    /**
     * @brief  Get temporary matrix for fft shift.
     * @return Temporary complex 3D matrix.
     */
    FftwComplexMatrix& getTempFftwShift()
    {
      return mMatrixContainer.getMatrix<FftwComplexMatrix>(MatrixContainer::MatrixIdx::kTempFftwShift);
    };

    //------------------------------------ Getters for real and index matrices ---------------------------------------//
    /**
     * @brief  Get real matrix from the matrix container.
     * @param  [in] matrixIdx - Matrix id in the container.
     * @return Reference to the real matrix.
     */
    RealMatrix& getRealMatrix(const MatrixContainer::MatrixIdx matrixIdx)
    {
      return mMatrixContainer.getMatrix<RealMatrix>(matrixIdx);
    }
    /**
     * @brief  Get real matrix from the container, const version.
     * @param  [in] matrixIdx - Matrix id in the container.
     * @return Reference to the real matrix.
     */
    const RealMatrix& getRealMatrix(const MatrixContainer::MatrixIdx matrixIdx) const
    {
      return mMatrixContainer.getMatrix<RealMatrix>(matrixIdx);
    }

    /**
     * @brief  Get index matrix from the matrix container.
     * @param  [in] matrixIdx - Matrix id in the container.
     * @return Reference to the index matrix.
     */
    IndexMatrix& getIndexMatrix(const MatrixContainer::MatrixIdx matrixIdx)
    {
      return mMatrixContainer.getMatrix<IndexMatrix>(matrixIdx);
    }
    /**
     * @brief  Get index matrix from the container, const version.
     * @param  [in] matrixIdx - Matrix id in the container.
     * @return Reference to the index matrix.
     */
    const IndexMatrix& getIndexMatrix(const MatrixContainer::MatrixIdx matrixIdx) const
    {
      return mMatrixContainer.getMatrix<IndexMatrix>(matrixIdx);
    }

    //----------------------------- Getters for raw real, complex and index matrix data ------------------------------//
    /**
     * @brief  Get the pointer to raw matrix data of ComplexMatrix.
     * @param  [in] matrixIdx - Matrix id in the container.
     * @param  [in] present   - Is the matrix present in the container?
     * @return Pointer to raw data or nullptr if the matrix is not in the container.
     */
    FloatComplex* getComplexData(const MatrixContainer::MatrixIdx matrixIdx,
                                 const bool                       present = true)
    {
      return (present) ? mMatrixContainer.getMatrix<ComplexMatrix>(matrixIdx).getComplexData() : nullptr;
    }

    /**
     * @brief  Get the pointer to raw matrix data of ComplexMatrix, const version.
     * @param  [in] matrixIdx - Matrix id in the container.
     * @param  [in] present   - Is the matrix present in the container?
     * @return Pointer to raw data or nullptr if the matrix is not in the container.
     */
    const FloatComplex* getComplexData(const MatrixContainer::MatrixIdx matrixIdx,
                                       const bool                       present = true) const
    {
      return (present) ? mMatrixContainer.getMatrix<ComplexMatrix>(matrixIdx).getComplexData() : nullptr;
    }

    /**
     * @brief  Get the pointer to raw matrix data of ComplexMatrix.
     * @param  [in] matrixIdx - Matrix id in the container.
     * @param  [in] present   - Is the matrix present in the container?
     * @return Pointer to raw data or nullptr if the matrix is not in the container.
     */
    float* getRealData(const MatrixContainer::MatrixIdx matrixIdx,
                       const bool                       present = true)
    {
      return (present) ? mMatrixContainer.getMatrix<RealMatrix>(matrixIdx).getData() : nullptr;
    }
    /**
     * @brief  Get the pointer to raw matrix data of RealMatrix, const version.
     * @param  [in] matrixIdx - Matrix id in the container.
     * @param  [in] present   - Is the matrix present in the container?
     * @return Pointer to raw data or nullptr if the matrix is not in the container.
     */
    const float* getRealData(const MatrixContainer::MatrixIdx matrixIdx,
                             const bool                       present = true) const
    {
      return (present) ? mMatrixContainer.getMatrix<RealMatrix>(matrixIdx).getData() : nullptr;
    }

    /**
     * @brief  Get the pointer to raw matrix data of IndexMatrix.
     * @param  [in] matrixIdx - Matrix id in the container.
     * @param  [in] present   - Is the matrix present in the container?
     * @return Pointer to raw data or nullptr if the matrix is not in the container.
     */
    size_t* getIndexData(const MatrixContainer::MatrixIdx matrixIdx,
                         const bool                       present = true)
    {
      return (present) ? mMatrixContainer.getMatrix<IndexMatrix>(matrixIdx).getData() : nullptr;
    }

    /**
     * @brief  Get the pointer to raw matrix data of IndexMatrix, const version.
     * @param  [in] matrixIdx - Matrix id in the container.
     * @param  [in] present   - Is the matrix present in the container?
     * @return Pointer to raw data or nullptr if the matrix is not in the container.
     */
    const size_t* getIndexData(const MatrixContainer::MatrixIdx matrixIdx,
                               const bool                       present = true) const
    {
      return (present) ? mMatrixContainer.getMatrix<IndexMatrix>(matrixIdx).getData() : nullptr;
    }

  private:
    /// Pointer to computeMainLoop method.
    using ComputeMainLoopFnc = std::function<void(KSpaceFirstOrderSolver&)>;
    /**
     * @brief Map with possible implementations of the ComputeMainLoop.
     *
     * The key is a tuple composed of
     * [Parameters::SimulationDimension, rho0ScalarFlag, bOnAScalarFlag, c0ScalarFlag, alphaCoefScalarFlag]
     */
    using ComputeMainLoopImp = std::map<std::tuple<Parameters::SimulationDimension, bool, bool, bool, bool>,
                                        ComputeMainLoopFnc>;

    /// Map with different implementations of ComputeMainLoop.
    static ComputeMainLoopImp sComputeMainLoopImp;

    /// Matrix container with all the matrix classes.
    MatrixContainer       mMatrixContainer;
    /// Output stream container.
    OutputStreamContainer mOutputStreamContainer;
    /// Global parameters of the simulation.
    Parameters&           mParameters;

    /// Percentage of the simulation done.
    size_t                mActPercent;

    /// Total time of the simulation.
    TimeMeasure mTotalTime;
    /// Pre-processing time of the simulation.
    TimeMeasure mPreProcessingTime;
    /// Data load time of the simulation.
    TimeMeasure mDataLoadTime;
    /// Simulation time of the simulation.
    TimeMeasure mSimulationTime;
    /// Post-processing time of the simulation.
    TimeMeasure mPostProcessingTime;
    /// Iteration time of the simulation.
    TimeMeasure mIterationTime;
};// end of KSpaceFirstOrderSolver
//----------------------------------------------------------------------------------------------------------------------

#endif /* KSPACE_FIRST_ORDER_SOLVER_H */
