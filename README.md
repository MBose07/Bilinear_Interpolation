# Bilinear Interpolation Hardware Implementation

## Overview

This project implements **bilinear interpolation** for image resizing using a hardware-oriented design approach. The system computes interpolated RGB pixel values for output coordinates by mapping them to fractional input coordinates and applying the bilinear interpolation formula efficiently.

The design focuses on **resource optimization** and **cost reduction** while maintaining correct interpolation functionality.

---

## Bilinear Interpolation

For an output pixel located at fractional input coordinates:

[
(x, y) = (i + a,; j + b)
]

the interpolated pixel value is computed as:

[
(1-a)(1-b)p_{00} + (1-a)b,p_{01} + a(1-b)p_{10} + ab,p_{11}
]

where:

* (p_{00}, p_{01}, p_{10}, p_{11}) are neighboring pixels
* (a, b) are fractional components of the mapped input coordinate

---

## Design Methodology

The implementation is divided into the following stages:

### 1. Scaling Ratio Calculation

* Compute:

  * `W_in / W_out`
  * `H_in / H_out`
* Two multicycle division modules operate in parallel.
* After ratio computation, the FSM transitions to processing mode.

### 2. Output Coordinate Iteration

* The system iterates through each output pixel coordinate sequentially.
* RGB values are computed independently for every coordinate.

### 3. Fractional Coordinate Generation

* Output coordinates are mapped back to input space.
* Each coordinate is decomposed into:

  * Integer part (pixel index)
  * Fractional part (interpolation weights)

### 4. Optimized Interpolation Computation

Instead of directly implementing all multiplications in:

[
(1-a)(1-b)p_{00} + (1-a)b p_{01} + a(1-b)p_{10} + ab p_{11}
]

the expression is algebraically expanded.

Observation:

* Only the term (a \times b) must be explicitly computed.
* Remaining operations reduce to simpler multiplications.
* Intermediate results are reused across computations.

This significantly reduces arithmetic hardware usage.

### 5. Transform Module

A transform module computes interpolated pixel values at `(x_out, y_out)` using a **4-stage pipeline**.

The pipeline is introduced primarily to:

* **Reduce hardware cost**
* **Lower the number of multiplication modules required**
