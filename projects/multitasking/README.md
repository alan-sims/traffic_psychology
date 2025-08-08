# Multitasking Driving Study

Comprehensive analysis of driving performance during multitasking scenarios, examining how phone conversations and messaging affect driving behavior across multiple office-to-office trips in a simulated environment.

## 📋 Project Overview

This project studies how multitasking affects driving performance by comparing baseline driving with phone conversation and messaging tasks. Participants complete a series of drives between office locations while performing different secondary tasks, allowing analysis of multitasking effects on speed control, lane keeping, following behavior, and safety.

## 🗺️ Driving Route

![Multitasking Study Route](images/multitasking_map.png)

Participants complete three drives:
1. **Drive 1**: Home → Office 1 (baseline driving, ~8 minutes)
2. **Drive 2**: Office 1 → Office 2 with **Multi-task 1** (phone conversation + text messages, ~8 minutes)  
3. **Drive 3**: Office 2 → Office 1 with **Multi-task 2** (Teams conversation + Teams chat, ~8 minutes)

Each drive includes slower-moving lead vehicles to assess following behavior under different cognitive load conditions.

## 🔬 Research Questions

1. **Multitasking Effects**: How do phone conversations and messaging affect driving performance?
2. **Task Type Differences**: Do different communication platforms (phone vs Teams) have different impacts?
3. **Safety Implications**: Which multitasking conditions create the highest collision risk?
4. **Speed Management**: How does cognitive load affect speed coherence with traffic and speed limits?
5. **Lane Keeping**: Does multitasking increase lateral position variability (SDLP)?
6. **Following Behavior**: How does secondary task performance affect headway maintenance?

## 📊 Data Structure

- **Sampling Rate**: 0.05-second intervals (20 Hz)
- **File Format**: Tab-separated CSV with complex column names
- **Participants**: Multiple drivers across all three drive conditions
- **Metrics**: Speed, lateral position, braking, headway distance/time, collision detection

## 🚀 Quick Start

### Prerequisites
- R (4.0+) with tidyverse
- RStudio or Positron IDE

### Running Analysis

```r
# Open the R project
# File → Open Project → multitasking.Rproj

# Load the analysis functions
source("R/multitask_analysis.R")

# For single file analysis
result <- analyze_multitask_driving("data/raw/Drive 2 - Drive to Office 2 (Multi-task 1)-28_07_2025-08h51m07s_1234.csv")

# For batch processing
summary_data <- process_multitask_driving_batch("data/raw/")
```

### Expected Data Format
```
Drive [N] - [Description]-DD_MM_YYYY-HHhMMmSSs_PPPP.csv
```
**Examples**: 
- `Drive 1 - Drive from home to Office 1-28_07_2025-08h45m12s_1234.csv`
- `Drive 2 - Drive to Office 2 (Multi-task 1)-28_07_2025-08h51m07s_1234.csv`
- `Drive 3 - Drive to Office 1 (Multi-task 2)-28_07_2025-09h15m33s_1234.csv`

## 📁 Project Structure

```
multitasking/
├── R/
│   └── multitask_analysis.R      # Main analysis functions
├── data/raw/                     # Raw CSV files (excluded from git)
├── output/                       # Summary CSV files
├── images/
│   └── multitasking_map.png      # Route diagram
├── docs/                         # Documentation
│   └── multitasking.md          # Detailed usage guide
├── multitasking.Rproj           # R project file
├── .gitignore                   # Git ignore rules
└── README.md                    # This file
```

## 📈 Key Metrics Calculated

### Speed Behavior
- **Mean Speed**: Average speed by scenario section and speed limit zone
- **Speed Coherence**: How well driver follows speed limits (deviation-based score)
- **SD Speed**: Speed variability within speed limit sections

### Lane Keeping & Safety
- **SDLP**: Standard Deviation of Lateral Position (stability indicator)
- **Lane ID**: Primary lane used during drive
- **Collision Count**: Number of collisions during drive

### Following Behavior
- **Mean Headway Distance**: Average following distance (filters out 99900 "no car" values)
- **SD Headway Distance**: Variability in following distance
- **Mean TTC**: Time to collision (safety time)
- **SD TTC**: Variability in time to collision

### Braking Behavior
- **Brake Events**: Number of discrete braking episodes
- **Mean Brake Force**: Average force applied during braking
- **Max Brake Force**: Maximum braking force used

## 🎯 Drive Types

The analysis automatically categorizes drives based on filename:

1. **Home_to_Office1**: Baseline driving condition
2. **Office1_to_Office2_Multitask1**: Phone conversation + text messaging
3. **Office2_to_Office1_Multitask2**: Teams conversation + Teams chat

This allows for direct comparison of multitasking effects across different communication platforms and baseline performance.

## 🛣️ Scenario Sections

Each drive is divided into scenario sections corresponding to different speed limit zones and road types. Metrics are calculated separately for each section to capture:
- **Speed limit compliance** in different zones
- **Multitasking effects** across road complexities  
- **Following behavior** in various traffic conditions

## 🎯 Usage Examples

### Single Participant Analysis
```r
# Analyze one drive
result <- analyze_multitask_driving("data/raw/Drive 2 - Drive to Office 2 (Multi-task 1)-28_07_2025-08h51m07s_1234.csv")

# View driving metrics by section
result$mean_speed          # Speed by scenario section
result$speed_coherence     # Speed limit following
result$sdlp               # Lane keeping stability
result$collision_occurrence # Safety outcomes
```

### Batch Processing
```r
# Process all drives
summary_data <- process_multitask_driving_batch("data/raw/")

# View results
View(summary_data)

# Filter by drive type
baseline_drives <- summary_data %>% filter(drive_type == "Home_to_Office1")
multitask1_drives <- summary_data %>% filter(drive_type == "Office1_to_Office2_Multitask1")
multitask2_drives <- summary_data %>% filter(drive_type == "Office2_to_Office1_Multitask2")
```

## 📊 Output Summary

### Individual Analysis
- **Console Output**: Detailed section-by-section analysis per participant
- **Performance Metrics**: Speed, safety, and following behavior summaries
- **Drive Classification**: Automatic categorization of drive type

### Batch Summary
- **CSV Export**: Complete dataset ready for statistical analysis
- **All Participants**: Combined data across all drives and conditions
- **Section-Level Data**: Granular analysis by speed limit zones
- **Drive Comparison**: Easy filtering by baseline vs multitasking conditions

## 🔍 Data Quality Features

- **Realistic Value Filtering**: Excludes 99900 "no vehicle present" headway values
- **Error Handling**: Robust processing with detailed error reporting
- **Missing Data Management**: Appropriate handling of null values and edge cases
- **Validation**: Automatic checks for expected data format and structure

## 📄 Documentation

- **[Detailed Usage Guide](docs/multitasking.md)**: Complete setup and analysis instructions
- **[Function Reference](R/multitask_analysis.R)**: Comprehensive code documentation
- **Troubleshooting**: Common issues and solutions

## 🤝 Contributing

This project follows lab coding standards:
- Use tidyverse conventions for data manipulation
- Include comprehensive error handling
- Document all functions thoroughly
- Provide clear usage examples
- Filter unrealistic simulator values appropriately

## 📧 Contact

Alan Sims - alan.sims@griffithuni.edu.au

**Repository**: https://github.com/alan-sims/traffic_psychology

---

*Part of the Traffic Psychology Lab research portfolio*