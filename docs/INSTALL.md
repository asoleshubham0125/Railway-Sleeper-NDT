# Installation Guide

This guide will help you set up the **Bottom-Scanning Ultrasonic NDT System for Railway Sleeper Blocks** MATLAB simulation on your local machine.

---

## 1. System Requirements
- **Operating System:** Windows 10/11, macOS, or Linux
- **MATLAB:** R2021a or later (tested on R2023b)
- **Toolboxes:**
  - [k-Wave MATLAB Toolbox](http://www.k-wave.org/) (for acoustic wave simulations)

---

## 2. Clone the Repository
```bash
git clone https://github.com/asoleshubham0125/Railway-Sleeper-NDT.git
cd Railway-Sleeper-NDT
```
 
## 3. Install Dependencies
- **MATLAB**
- Install MATLAB from MathWorks.
- Ensure your license includes access to external toolboxes.

- **k-Wave Toolbox**
- Download the latest version from:[k-Wave MATLAB Toolbox](http://www.k-wave.org/)
- Extract the folder to a location on your PC.
- In MATLAB, add the k-Wave folder to your MATLAB path:

```matlab
addpath(genpath('path/to/k-Wave-toolbox'))
savepath
```


