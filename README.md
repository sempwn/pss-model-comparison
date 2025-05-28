# PSS Model Comparison
[![Study Protocol](https://img.shields.io/badge/OSF-Study%20Protocol-blue)](https://osf.io/kju2p)

## Overview

This repository supports the **Model Comparison Study** outlined in the protocol: [https://osf.io/kju2p](https://osf.io/kju2p). The goal of this project is to systematically analyze and compare outputs two models to evaluate the impact of PSS on the number of opioid overdose-related deaths within BC from the inception of the program (March 2020) until December 2022. 

## Folder Structure

```
pss-model-comparison/
├── data/                # Raw and processed
│ ├── raw/ # Submitted model outputs
│ └── processed/ # Harmonized and cleaned data
├── analysis/            
├── scripts/             # Data processing and analysis scripts
├── results/             # Output files, figures, and tables
├── LICENSE 
└── README.md            # Project overview and instructions
```

## 🛠️ Installation

- Prerequisites are R (>= XX)
1. Open project in Rstudio
2. Restore R environment using `renv`
```r
install.packages("renv")
renv::restore()
```

## 👥 Contributors

| Name                 | Role                                       | Affiliation    |
| -------------------- | ------------------------------------------ | -------------- |
| Mike Irvine             | Analysis        | BCCDC/SFU                 | 

*To add your name and role, please submit a pull request or contact the repository maintainer*

## 📄 License

This project is licensed under GNU GPL v2.0. See [LICENSE](./LICENSE) for details.

## 📚 References