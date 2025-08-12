# MTB Intersection Distance Processing

## Overview

This R script processes driving simulation data from MTB (Motorbike) multitasking scenarios to extract intersection approach data. It transforms raw CSV files into time-series data showing which intersection participants are approaching and their distance from it.

## Features

- **Intersection Detection**: Automatically identifies 16 intersections (1-15 plus "END") based on distance patterns
- **Time-Series Processing**: Converts data to 60Hz time-series format 
- **Batch Processing**: Processes multiple participants automatically
- **Individual Output Files**: Creates separate CSV files for each participant
- **Visualization**: Includes plotting functions to visualize intersection approaches

## Data Structure

### Input Files
- **Location**: `projects/mtb_multitasking/data/raw/`
- **Format**: Tab-separated CSV files
- **Naming**: `MBInt-DD_MM_YYYY-HHhMMmSSs_PPPP.csv`
  - `DD_MM_YYYY`: Date (e.g., 29_07_2025)
  - `HHhMMmSSs`: Time (e.g., 11h10m06s)
  - `PPPP`: Participant ID (e.g., 4212)

### Output Files
- **Location**: `projects/mtb_multitasking/data/intersection_processed/`
- **Format**: Standard CSV files
- **Naming**: `intersections_[ParticipantID].csv`

## Output Columns

| Column | Description |
|--------|-------------|
| `participant_id` | 4-digit participant identifier |
| `date` | Date in DD/MM/YYYY format |
| `time` | Time in HH:MM:SS format |
| `filename` | Original source filename |
| `intersection_number` | Current intersection being approached (1-15, or "END") |
| `intersection_distance` | Distance to upcoming intersection (meters) |
| `speed` | Vehicle speed (km/h) |
| `lane_number` | Current lane ID |

## Intersection Sequence

The scenario contains 16 intersections in sequential order:
**1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10.5, 11, 12, 13, 14, 15**

After intersection 15, the column shows **"END"** indicating no more intersections ahead.

## Algorithm

### Intersection Detection Logic
1. **Distance Pattern Recognition**: Monitors `distance_to_intersection` values
2. **Intersection Crossing Detection**: Identifies when distance jumps >100 meters (indicating crossing)
3. **Sequential Assignment**: Assigns intersection numbers in order (1→2→3...→15→END)
4. **End Condition**: After intersection 15, all subsequent data marked as "END"

## Usage

### Prerequisites
```r
library(tidyverse)
```

```r
# Load the analysis functions (adjust file path as needed, the below one should be correect if you are working from projects/mtb_intersections repository)
source("R/mtb_intersection_approach.R")

# For single file analysis
result <- analyze_mtb_intersections("data/raw/MBInt-29_07_2025-11h10m06s_4212.csv") #or the name of whichever file you want to analyze

# For batch processing
summary <- process_mtb_intersection_approach_batch("data/raw/")
```

This will:
- Find all `MBInt*.csv` files in the input directory
- Process each file individually
- Create separate output files named `intersections_[ParticipantID].csv`
- Save to `projects/mtb_multitasking/data/intersection_processed/`

### Visualization
```r
# Create time-series plot showing intersection approaches
result <- process_mtb_intersection_data("projects/mtb_multitasking/data/raw/MBInt-29_07_2025-11h10m06s_4212.csv")

# Generate plot (code included in script)
# Shows:
# - Blue line: Distance to intersection (left y-axis)
# - Red line: Intersection number (right y-axis) 
# - Black labels: Intersection numbers above the line
```

## Functions

### Core Functions

#### `extract_mtb_participant_info(filename)`
Extracts participant ID, date, and time from filename.

#### `determine_intersection_number(distance_to_intersection)`
Determines which intersection is being approached based on distance patterns.

#### `process_mtb_intersection_data(file_path)`
Main processing function that transforms a single CSV file.

#### `process_mtb_intersection_batch(data_dir, output_dir)`
Batch processes multiple files and saves individual outputs.

### Plotting Functions
Included code creates dual y-axis time-series plots showing:
- Distance to intersection over time
- Current intersection number over time
- Intersection labels for easy identification

## Data Quality Notes

- **Sampling Rate**: 60Hz (60 data points per second)
- **Distance Threshold**: 100-meter jump indicates intersection crossing
- **Null Handling**: Converts "null" strings to proper NA values
- **Time Series**: Maintains chronological order throughout processing

## Output File Structure

Each output CSV contains time-series data for one participant:
```
participant_id,date,time,filename,intersection_number,intersection_distance,speed,lane_number
4212,29/07/2025,11:10:06,MBInt-29_07_2025-11h10m06s_4212.csv,1,245.3,45.2,101
4212,29/07/2025,11:10:06,MBInt-29_07_2025-11h10m06s_4212.csv,1,244.8,45.1,101
...
```

## Error Handling

The script includes robust error handling:
- **File Not Found**: Reports missing input files
- **Processing Errors**: Continues batch processing even if individual files fail
- **Directory Creation**: Automatically creates output directories
- **Data Validation**: Filters out invalid data points

## Troubleshooting

### Common Issues

**No output files created:**
- Check input directory path
- Verify CSV files follow naming convention
- Ensure write permissions for output directory

**Missing intersection numbers:**
- Check if `distance_to_intersection` column has valid data
- Verify distance values are reasonable (not all zeros/NAs)

**Plot not displaying:**
- Ensure ggplot2 is loaded
- Check that `result` dataset has been created
- Verify intersection_distance column has non-NA values

### File Locations
- **Input**: `projects/mtb_multitasking/data/raw/`
- **Output**: `projects/mtb_multitasking/data/intersection_processed/`
- **Script**: Save this code as `mtb_intersection_processing.R`

## Example Output Analysis

After processing, you can analyze intersection approach patterns:
```r
# Load processed data
data <- read_csv("projects/mtb_multitasking/data/intersection_processed/intersections_4212.csv")

# Count approaches by intersection
table(data$intersection_number)

# Average speed approaching each intersection
data %>%
  group_by(intersection_number) %>%
  summarise(avg_speed = mean(speed, na.rm = TRUE))
```

---

**Contact**: For questions or issues with this processing script, refer to the MTB multitasking research project documentation.