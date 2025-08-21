# MTB Filtering Analysis



## 📋 Project Overview



## 🏙️ Scenario Description



## 🔬 Research Questions


## 📊 Data Structure



## 🚀 Quick Start

### Prerequisites
- R (4.0+) with tidyverse
- RStudio or Positron IDE

### Running Analysis - Intersection Data

```r
# Load the analysis functions (adjust file path as needed, the below one should be correect if you are working from projects/mtb_intersections repository)
source("R/mtb_intersections.R")

# For single file analysis
result <- analyze_mtb_intersections("data/raw/MBInt-29_07_2025-11h10m06s_4212.csv")

# For batch processing
summary <- process_mtb_intersections_batch("data/raw/")
```

### Running Analysis - Intersection Approach
```r
# Load the analysis functions (adjust file path as needed, the below one should be correect if you are working from projects/mtb_intersections repository)
source("R/mtb_intersection_approach.R")

# For single file analysis
result <- analyze_mtb_intersections("data/raw/MBInt-29_07_2025-11h10m06s_4212.csv")

# For batch processing
summary <- process_mtb_intersection_approach_batch("data/raw/")
```

### Expected Data Format
```
MBInt-DD_MM_YYYY-HHhMMmSSs_PPPP.csv
```
**Example**: `MBInt-29_07_2025-11h10m06s_4212.csv`

## 📁 Project Structure

```
mtb_intersections/
├── R/
│   └── mtb_intersections.R       # Main analysis functions
├── data/raw/                    # Raw CSV files (excluded from git)
├── output/                      # Summary CSV files  
├── docs/                        # Documentation
│   └── mtb_intersections.md     # Detailed usage guide
├── mtb_intersections.Rproj      # R project file
├── .gitignore                  # Git ignore rules
└── README.md                   # This file
```

## 📈 Key Metrics Calculated

### Driving Behavior
- **Speed**: Average, SD, min, max throughout scenario
- **SDLP**: Standard Deviation of Lateral Position (stability indicator)
- **Following**: Headway distance and time when behind vehicles

### Intersection Behavior
- **Motorbike Give-Way**: Binary compliance at 6 intersections
- **Traffic Light**: Compliance vs. running amber lights

### Output Summary
- **Individual Analysis**: Detailed console output per participant
- **Batch Summary**: CSV file ready for statistical analysis
- **Compliance Metrics**: Safety and rule-following indicators

## 🎯 Usage Examples

### Single Participant Analysis
```r
# Analyze one driver's behavior
result <- analyze_mtb_intersections("data/raw/MBInt-29_07_2025-11h10m06s_4212.csv")

# View driving metrics
result$summary_metrics$avg_speed
result$summary_metrics$sdlp

# Check intersection compliance
result$summary_metrics$int_1_gave_way  # 1 = gave way, 0 = didn't wait
result$summary_metrics$int_6_stopped_at_light  # >0 = stopped, 0 = ran light
```

### Batch Processing
```r
# Process all participants
summary_data <- process_mtb_intersections_batch("data/raw/")

```

## 📄 Documentation

- **[Detailed Usage Guide](docs/mtb_intersections.md)**: Complete setup and analysis instructions
- **[Function Reference](R/mtb_intersections.R)**: Comprehensive code documentation
- **Troubleshooting**: Common issues and solutions

## 🤝 Contributing

This project follows lab coding standards:
- Use tidyverse conventions for data manipulation
- Include comprehensive error handling
- Document all functions thoroughly  
- Provide clear usage examples
- Filter unrealistic values (e.g., 99000 placeholders)

## 📧 Contact

Alan Sims - alan.sims@griffithuni.edu.au

**Repository**: https://github.com/alan-sims/traffic_psychology

---

*Part of the Traffic Psychology Lab research portfolio*
