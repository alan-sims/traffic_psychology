# Close Following Rural Tailgating

## Scenario Overview

In this scenario, the participant drives along a rural road with one lane in each direction, separated by a double white line (no overtaking allowed). The road has a baseline speed limit of 100km/h, but drops to 60km/h when passing through a small township in the middle of the scenario.

Throughout the drive, there are various cars traveling below the speed limit, creating opportunities for the participant to engage in tailgating behavior. Since overtaking is not allowed due to the double white lines, participants must decide whether to follow closely behind slower vehicles or maintain safe following distances.

## Traffic Behavior

The scenario includes multiple slower vehicles that travel below the posted speed limits:
- Cars traveling at 80-90km/h in 100km/h zones
- Cars traveling at 50km/h in the 60km/h township section
- These slower vehicles create frustration and tailgating opportunities

We will analyze how participants respond to these slower vehicles, particularly their following distances, speed choices, and lateral movement patterns.

## Drive Sections

| Section | Description |
|---------|-------------|
| 0 | Warm-up period (0-200m) - allows participants to reach comfortable speed |
| 1 | Rural road 100km/h with slow cars present |
| 2 | Township section 60km/h with slow cars present |
| 3 | Rural road 100km/h (return to highway speed) with slow cars present |

## Export Channel Outcome Variables

| Variable | Description |
|----------|-------------|
| `time` | Time elapsed in the scenario (0.05 second intervals) |
| `[03 (Driver/Driver Speed)].ExportChannel-val` | Driver speed in km/h |
| `[05 (Driver/Headway Distance)].ExportChannel-val` | Distance (in metres) behind the car in front |
| `[06 (Driver/Driver Lane Lateral Shift)].ExportChannel-val` | Lateral shift in the lane |
| `[10 (Driver/Braking)].ExportChannel-val` | The pressure applied to the brake pedal |
| `[12 (Driver/Time Headway)].ExportChannel-val` | The time in seconds that participant is from the car in front |
| `[17 (Driver/Drive Section)].ExportChannel-val` | The section of the drive |
| `[00].VehicleUpdate-roadInfo-roadAbscissa.0` | The distance (in metres) that the person is along that section of road |
| `[00].VehicleUpdate-roadInfo-laneId.0` | The ID of the lane that the participant is in |

## Key Tailgating Metrics

This scenario focuses on measuring:
- **Headway Distance**: How close the participant follows slower vehicles
- **Time Headway**: Following time in seconds (critical safety measure)
- **Close Following Events**: Instances where time headway < 2 seconds
- **Very Close Following**: Instances where time headway < 1 second  
- **Brake Events**: Frequency of braking due to close following situations
- **Speed Variations**: How participants adjust speed when encountering slow vehicles

## Research Questions

- How do participants respond to slower vehicles when overtaking is not possible?
- What following distances do participants maintain behind slow cars?
- Do participants engage in aggressive tailgating to pressure slower drivers?
- How does the rural environment and no-overtaking rule affect tailgating behavior?
- Are there differences in tailgating behavior between 100km/h and 60km/h sections?

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
git clone https://github.com/alan-sims/close_following.git
cd close_following
```

#### Option B: Download ZIP (Alternative)
If you don't have Git:
1. Go to the GitHub repository page: [your-github-repo-url]
2. Click the green "Code" button
3. Select "Download ZIP"
4. Extract the ZIP file to your desired location
5. Rename the folder to `close_following` if needed

#### Opening the Project
1. Open RStudio or Positron IDE
2. Go to File → Open Project (or File → Open Project in New Session)
3. Navigate to the `close_following` folder
4. Click on `close-following.Rproj` and select "Open"

#### Install Required Packages
Once the project is open, run this in the R console:
```r
install.packages(c("tidyverse", "readr"))
```

### 2. Data File Naming Convention
Your CSV files must follow this naming pattern:
```
Close_Following_Rural_Tailgaiting-DD_MM_YYYY-HHhMMmSSs_PPPP.csv
```

Where:
- `DD_MM_YYYY` = Date (e.g., 25_06_2025)
- `HHhMMmSSs` = Time (e.g., 15h23m26s) 
- `PPPP` = 4-digit participant ID (e.g., 1234)

**Example:** `Close_Following_Rural_Tailgaiting-25_06_2025-15h23m26s_1234.csv`

### 3. Organize Your Data
Place your CSV files in the appropriate folder:
```
data/raw/rural/tailgating/
├── Close_Following_Rural_Tailgaiting-25_06_2025-15h23m26s_1234.csv
├── Close_Following_Rural_Tailgaiting-26_06_2025-11h45m12s_1235.csv
└── Close_Following_Rural_Tailgaiting-27_06_2025-16h18m33s_1236.csv
```

### 4. Run the Analysis

#### For a Single File:
```r
source("R/rural/tailgating/rural_tailgating.R")

file_path <- "data/raw/rural/tailgating/Close_Following_Rural_Tailgaiting-25_06_2025-15h23m26s_1234.csv"
results <- analyze_rural_tailgating(file_path)
```

#### For Multiple Files (Batch Processing):
```r
source("R/rural/tailgating/rural_tailgating.R")

# Process all files in the folder
summary_data <- process_rural_tailgating_batch("data/raw/rural/tailgating/")
```

This will:
- Process all CSV files in the folder
- Extract participant ID, date, and time from filenames
- Calculate tailgating metrics for each participant across all 4 sections
- Create a summary CSV file at `output/rural_tailgating_summary.csv`

## Output

### Single File Analysis
The console will display:
- Duration and observations for each section
- Average speed by drive section (0-3)
- Standard Deviation of Lateral Position (SDLP) by section
- Headway distance and time headway metrics
- Close following event counts (< 2s and < 1s)
- Braking events by section
- Crash detection results

### Batch Processing Summary CSV
The summary file contains these columns:
- `participant_id` - 4-digit participant number
- `date` - Date in DD/MM/YYYY format
- `time` - Time in HH:MM:SS format
- `filename` - Original filename

**Section-wise metrics (for sections 0-3):**
- `avg_speed_section_X` - Average speed (km/h) for each section
- `sdlp_section_X` - Standard Deviation of Lateral Position for each section
- `total_braking_events_section_X` - Number of brake applications in each section
- `avg_headway_distance_section_X` - Average following distance (m) in each section
- `min_headway_distance_section_X` - Minimum following distance (m) in each section
- `avg_time_headway_section_X` - Average following time (s) in each section
- `min_time_headway_section_X` - Minimum following time (s) in each section
- `close_following_events_section_X` - Number of times headway < 2s in each section
- `very_close_following_section_X` - Number of times headway < 1s in each section
- `potential_crashes_section_X` - Detected potential crash events in each section

## Data Requirements

Your CSV files should contain tab-separated data with these columns:
- Time elapsed (0.05 second intervals)
- Driver speed (km/h)
- Headway distance (metres)
- Lane lateral shift
- Braking pressure
- Time headway (seconds)
- Drive section number (0-3)
- Road distance
- Lane ID

## Interpretation Guide

### Tailgating Behavior Indicators

**Safe Following:**
- Time headway > 3 seconds
- Headway distance > 60 meters at 100km/h (> 30m at 60km/h)
- Low frequency of close following events
- Stable lateral position (low SDLP)

**Moderate Tailgating:**
- Time headway 1-3 seconds
- Some close following events (< 2s)
- Occasional braking due to following too closely
- Slightly increased lateral movement

**Aggressive Tailgating:**
- Time headway < 1 second frequently
- High frequency of very close following events
- Frequent braking due to close following
- High SDLP indicating frustration/lateral movement
- Minimum headway distances < 20 meters

### Section-Specific Expectations

**Section 0 (Warm-up)**: Variable behavior as participants adjust

**Section 1 (Rural 100km/h)**: Baseline tailgating behavior behind slow cars

**Section 2 (Township 60km/h)**: Different following patterns due to lower speeds

**Section 3 (Rural 100km/h)**: Return to higher speeds, potential for more aggressive tailgating

### Key Comparisons

**Rural vs Highway**: Compare with highway tailgating to see if road type affects following behavior

**Speed Limit Effects**: Compare sections 1&3 (100km/h) vs section 2 (60km/h) for speed-dependent following

**Individual Differences**: Identify participants who consistently tailgate vs those who maintain safe distances

## Troubleshooting

**File not found errors:**
- Check that your file path is correct
- Ensure you're in the project directory (open the .Rproj file)

**Parsing errors:**
- Verify your CSV file follows the expected tab-separated format
- Check that the filename follows the naming convention

**No files found:**
- Ensure CSV files are in the correct folder (`data/raw/rural/tailgating/`)
- Check that filenames contain "Rural_Tailgaiting" and end with `.csv`

**Missing headway data:**
- If headway values are all NA, participant may not have been following any vehicles
- Check the raw data to confirm vehicles were present in front of participant

**"No valid data" in safety metrics:**
- This indicates missing headway or braking data
- Check your data source and export settings

## Project Structure
```
close_following/
├── R/rural/tailgating/
│   └── rural_tailgating.R            # Analysis functions
├── data/raw/rural/tailgating/        # Place your CSV files here
├── output/                           # Summary files created here
├── docs/                             # Documentation
├── close-following.Rproj             # R project file
└── README.md                         # Project overview
```

## Next Steps
This completes the analysis framework for all four driving scenarios:
- Highway being tailgated ✓
- Highway tailgating ✓
- Rural being tailgated ✓
- Rural tailgating ✓

The framework now supports comprehensive analysis of close following behavior across different road types (highway vs rural) and following roles (tailgating vs being tailgated).

Contact Alan Sims - alan.sims@griffithuni.edu.au for questions or to contribute.