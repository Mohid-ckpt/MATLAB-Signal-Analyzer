# MATLAB Signal Analyzer CLI

## Overview

MATLAB Signal Analyzer CLI is a command-line interface (CLI) application built in MATLAB for performing various signal analysis tasks. It allows users to load, generate, analyze, and transform signals directly from the MATLAB command window. This project serves as a portfolio piece demonstrating MATLAB programming, signal processing fundamentals, and CLI application development.

## Features

*   **Signal Input:**
    *   Load signals from `.mat`, `.csv`, `.txt`, and `.wav` files.
    *   Generate common waveforms: Sine, Square, Sawtooth, Gaussian Noise with user-defined parameters.
*   **Time-Domain Analysis:**
    *   Plot signal waveform.
    *   Calculate and display statistics: Mean, RMS, Peak, Peak-to-Peak, Variance, Standard Deviation.
*   **Frequency-Domain Analysis:**
    *   Compute and plot Fast Fourier Transform (FFT) magnitude.
    *   Compute and plot Power Spectral Density (PSD) using Welch's method.
    *   Selectable windowing functions (Rectangular, Hann, Hamming, Blackman).
*   **Time-Frequency Analysis:**
    *   Display spectrograms with configurable window length and overlap.
*   **Signal Transformations:**
    *   **Normalization:** Min-Max ([0,1], [-1,1]), Z-score.
    *   **Resampling:** Change signal sampling rate.
    *   **Differentiation & Integration:** Approximate derivatives and integrals.
    *   **Analytic Signal:** Compute via Hilbert transform to find envelope, instantaneous phase/frequency.
    *   **Full FFT/IFFT:** Transform signal to/from complex frequency domain.
*   **Utilities:**
    *   Save generated plots to image files (PNG).
    *   Clear all open figures.
    *   Interactive menu-driven interface.
 ## Code Structure

*   `SignalAnalyzer_CLI.m`: The main script containing the primary CLI loop and calls to various functional modules.
*   `apply_transformations_menu.m`: Handles the transformations sub-menu and calls individual transformation functions.
*   Other `.m` files for specific functionalities (e.g., loading, generation, display).

## Future Enhancements (Potential)

*   Develop a GUI version using MATLAB App Designer.
*   Add more advanced signal processing features (e.g., filter design and application).
*   Support for more file formats.
*   Implement basic classification or feature extraction tasks.
*   More robust error handling and input validation.

## License

This project is licensed under the [MIT License](LICENSE).
