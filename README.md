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
├── R/                   # functions for data processing and vizualisation
├── scripts/             # Data processing and analysis scripts
├── results/             # Output files, figures, and tables
├── LICENSE 
└── README.md            # Project overview and instructions
```

## 🛠️ Installation

- Prerequisites are R (>= 4.4.3)
1. Open project in Rstudio
2. Restore R environment using `renv`
```r
install.packages("renv")
renv::restore()
```
3. Download data from the [One Drive data repository](https://1sfu-my.sharepoint.com/:f:/r/personal/mia29_sfu_ca/Documents/pss_model_comparison_data?csf=1&web=1&e=jOAY5K) (ask Mike Irvine for access)
4. Copy data into the folder [data/raw/](./data/raw/)

## 👥 Contributors

| Name                 | Role                                       | Affiliation    |
| -------------------- | ------------------------------------------ | -------------- |
| Mike Irvine             | Analysis        | BCCDC/SFU                 | 

*To add your name and role, please submit a pull request or contact the repository maintainer*

## 📄 License

This project is licensed under GNU GPL v2.0. See [LICENSE](./LICENSE) for details.

## 📚 References
