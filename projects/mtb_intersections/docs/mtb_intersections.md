# MTB Intersections - Detailed Documentation

## Scenario Overview

In this scenario, participants drive through a busy urban environment with multiple intersections where they encounter motorcycles and traffic light situations. The scenario tests driver decision-making, safety compliance, and behavioral responses during car-motorbike interactions in realistic urban traffic conditions.

Throughout the drive, participants face critical decisions at 8 different intersections, each presenting unique challenges for safe and legal driving behavior.

📄 [View Scenario Diagram (PDF)](docs/scenario_diagram.pdf)

## Intersection Details

### Motorbike Give-Way Intersections

| Intersection | Description | Measurement |
|--------------|-------------|-------------|
| **Int_1** | Option to give way to motorcycle | 0 = did not wait, 1 = gave way |
| **Int_2** | Option to give way to motorcycle | 0 = did not wait, 1 = gave way |
| **Int_4** | Option to give way to motorcycle | 0 = did not wait, 1 = gave way |
| **Int_7** | Option to give way to motorcycle | 0 = did not wait, 1 = gave way |
| **Int_10** | Option to give way to motorcycle | 0 = did not wait, 1 = gave way |
| **Int_15** | Option to give way to motorcycle | 0 = did not wait, 1 = gave way |

### Traffic Light Intersections

| Intersection | Description | Measurement |
|--------------|-------------|-------------|
| **Int_6** | Lights turn amber as driver approaches | 0 = ran light, >0 = stopped |
| **Int_14** | Lights turn amber as driver approaches | 0 = ran light, >0 = stopped |

## Export Channel Outcome Variables

| Variable | Description |
|----------|-------------|
| `time` | Time elapsed in the scenario (0.05 second intervals) |
| `[71 (Driver/Driver Speed)].ExportChannel-val` | Driver speed in km/h |
| `[73 (Driver/Headway Distance)].ExportChannel-val` | Following distance from car behind (active only during certain sections) |
| `[74 (Driver/Driver Lane Lateral Shift)].ExportChannel-val` | Lateral shift in lane (used to calculate SDLP) |
| `[77 (Driver/Lane Number)].ExportChannel-val` | Current lane number |
| `[78 (Driver/Int_1)].ExportChannel-val` | Intersection 1 behavior (motorbike give-way) |
| `[79 (Driver/Int_2)].ExportChannel-val` | Intersection 2 behavior (motorbike give-way) |
| `[80 (Driver/Int_4)].ExportChannel-val` | Intersection 4 behavior (motorbike give-way) |
| `[81 (Driver/Int_6)].ExportChannel-val` | Intersection 6 behavior (amber light) |
| `[82 (Driver/Int_7)].ExportChannel-val` | Intersection 7 behavior (motorbike give-way) |
| `[83 (Driver/Int_10)].ExportChannel-val` | Intersection 10 behavior (motorbike give-way) |
| `[84 (Driver/Int_14)].ExportChannel-val` | Intersection 14 behavior (amber light) |
| `[85 (Driver/Int_15)].ExportChannel-val` | Intersection 15 behavior (motorbike give-way) |
| `[86 (Driver/Time Headway)].ExportChannel-val` | Time headway in seconds (active only during certain sections) |
| `[88 (Driver/Distance to Intersection)].ExportChannel-val` | Distance to upcoming intersection |

## Key Research Questions

- How often do drivers give way to motorcycles at intersections?
- What factors influence traffic light compliance vs. running amber lights?
- How does urban driving affect lateral stability and speed control?
- Are there individual differences in intersection behavior patterns?
- How does the presence of motorcycles affect following behavior?

## Quick Start Guide

### 1. Setup

#### Prerequisites
- **R** (version 4.0 or later): Download from [https://cran.r-project.org/](https://cran.r-project.org/)
- **RStudio** or **Positron IDE**: 
  - RStudio: [https://posit.co/download/rstudio-desktop/](https://posit.co/download/rstudio-desktop/)
  - Positron: [https://github.com/posit-dev/positron](https://github.com/posit-dev/positron)
- **Git** (optional but recommended): [https://git-scm.com/downloads](https://git-scm.com/downloads)

#### Option A: Using Git (Recommended)
If you have Git installed:
1. Open Terminal (Mac/Linux) or Command Prompt (Windows)
2. Navigate to where you want to save the project
3. Run these commands:
```bash
git clone https://github.com/alan-sims/traffic_psychology.git
cd traffic_psychology/projects/mtb_intersections
```

#### Option B: Download ZIP (Alternative)
If you don't have Git:
1. Go to the GitHub repository page: [your-github-repo-url]
2. Click the green "Code" button
3. Select "Download ZIP"
4. Extract the ZIP file to your desired location
5. Navigate to `projects/mtb_intersections/`

#### Opening the Project
1. Open RStudio or Positron IDE
2. Go to File → Open Project (or File → Open Project in New Session)
3. Navigate to the `mtb_intersections` folder
4. Click on `mtb_intersections.Rproj` and select "Open"

#### Install Required Packages
Once the project is open, run this in the R console:
```r
install.packages(c("tidyverse", "readr"))
```

### 2. Data File Naming Convention
Your CSV files must follow this naming pattern:
```
MBInt-DD_MM_YYYY-HHhMMmSSs_PPPP.csv
```

Where:
- `DD_MM_YYYY` = Date (e.g., 29_07_2025)
- `HHhMMmSSs` = Time (e.g., 11h10m06s) 
- `PPPP` = 4-digit participant ID (e.g., 4212)

**Example:** `MBInt-29_07_2025-11h10m06s_4212.csv`

### 3. Organize Your Data
Place your CSV files in the appropriate folder:
```
data/raw/
├── MBInt-29_07_2025-11h10m06s_4212.csv
├── MBInt-29_07_2025-12h14m15s_7508.csv
└── MBInt-29_07_2025-15h23m09s_7744.csv
```

### 4. Run the Analysis

#### For a Single File:
```r
# Load the analysis functions (adjust file path as needed, the below one should be correect if you are working from projects/mtb_intersections repository)
source("R/mtb_intersections.R")

# For single file analysis
result <- analyze_mtb_intersections("data/raw/MBInt-29_07_2025-11h10m06s_4212.csv") #or the name of whichever file you want to analyze
```

# For batch processing
summary <- process_mtb_intersections_batch("data/raw/")
```

This will:
- Process all CSV files in the folder
- Extract participant ID, date, and time from filenames
- Calculate driving and intersection metrics for each participant
- Create a summary CSV file at `output/mtb_intersections_summary.csv`

## Output

### Single File Analysis
The console will display:
- Total scenario duration and observations
- Average speed, speed range, and SDLP
- Average headway distance and time (when following vehicles)
- Intersection-by-intersection behavior results
- Overall compliance summary for motorbike and traffic light situations

### Batch Processing Summary CSV
The summary file contains these columns:
- `participant_id` - 4-digit participant number
- `date` - Date in DD/MM/YYYY format  
- `time` - Time in HH:MM:SS format
- `filename` - Original filename

**Driving metrics:**
- `avg_speed` - Average speed throughout scenario (km/h)
- `sd_speed` - Standard deviation of speed
- `min_speed` - Minimum speed recorded
- `max_speed` - Maximum speed recorded
- `sdlp` - Standard Deviation of Lateral Position (stability measure)
- `avg_headway_distance` - Average following distance when behind vehicles (m)
- `min_headway_distance` - Closest following distance (m)
- `avg_time_headway` - Average following time (s)
- `min_time_headway` - Shortest following time (s)

**Intersection behavior:**
- `int_1_gave_way` through `int_15_gave_way` - Motorbike give-way decisions
- `int_6_stopped_at_light`, `int_14_stopped_at_light` - Traffic light compliance

## Data Requirements

Your CSV files should contain tab-separated data with these columns:
- Time elapsed (0.05 second intervals)
- Driver speed (km/h)
- Headway distance (meters, with 99000 placeholders filtered out)
- Lane lateral shift  
- Lane number
- Intersection behavior variables (Int_1 through Int_15)
- Time headway (seconds, with unrealistic values filtered out)
- Distance to intersection

## Troubleshooting

**File not found errors:**
- Check that your file path is correct
- Ensure you're in the project directory (open the .Rproj file)
- Verify the file is in the `data/raw/` folder

**Parsing errors:**
- Verify your CSV file follows the expected tab-separated format
- Check that the filename follows the naming convention
- Ensure the file isn't corrupted or incomplete

**No files found:**
- Ensure CSV files are in the correct folder (`data/raw/`)
- Check that filenames start with "MBInt" and end with `.csv`
- Verify the naming pattern matches exactly

**Unrealistic headway values:**
- The analysis automatically filters out 99000 placeholder values
- If you see strange values, check the filtering thresholds in the code
- Headway distances >1000m and time headway >100s are excluded

**Missing intersection data:**
- Some intersections may not trigger for all participants
- This results in NA values in the summary
- Check the raw data to confirm intersection encounters occurred

## Project Structure
```
mtb_intersections/
├── R/
│   └── mtb_intersections.R       # Main analysis functions
├── data/raw/                    # Raw MTB CSV files (gitignored)
├── output/                      # Summary CSV files
├── docs/                        # Documentation
│   └── mtb_intersections.md     # This detailed guide
├── mtb_intersections.Rproj      # R project file
├── .gitignore                  # Git ignore rules
└── README.md                   # Project overview
```

## Advanced Usage

### Custom Analysis
```r
# Load the functions
source("R/mtb_intersections.R")

# Read data manually for custom analysis
data <- read_mtb_intersections_data("data/raw/MBInt-29_07_2025-11h10m06s_4212.csv")

# Calculate custom metrics
custom_metrics <- data %>%
  summarise(
    avg_speed_near_intersections = mean(speed[distance_to_intersection < 50], na.rm = TRUE),
    speed_variability_intersections = sd(speed[distance_to_intersection < 50], na.rm = TRUE)
  )
```

### Quality Checks
```r
# Check for data quality issues
summary_data <- process_mtb_intersections_batch("data/raw/")

# Flag participants with concerning patterns
risky_drivers <- summary_data %>%
  filter(
    (int_1_gave_way + int_2_gave_way + int_4_gave_way + 
     int_7_gave_way + int_10_gave_way + int_15_gave_way) < 2 |  # Low give-way compliance
    (int_6_stopped_at_light == 0 & int_14_stopped_at_light == 0) |  # Ran both lights
    avg_speed > 80 |  # Very high urban speeds
    sdlp > 0.6  # Very unstable lateral position
  )
```

Contact [Alan Sims](mailto:alan.sims@griffithuni.edu.au) for questions or to contribute additional analysis functions.