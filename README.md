![main_logo](images/main_logo.jpg)

# Traffic Psychology Lab - Code Repository

This repository serves as the central code backup and collaboration hub for all traffic psychology research projects conducted by our lab. We focus on understanding driver behavior, decision-making, and safety across various traffic scenarios.

## 🚗 Current Projects

### Active Research
- **[Close Following Behavior Analysis](projects/close_following/)** - Comprehensive analysis of tailgating behavior across highway vs rural environments and different following roles

### Project Status
- ✅ Close Following: Complete analysis framework with 4 scenarios
- 🔄 Future projects will be added as they develop

## 📁 Repository Structure

```
traffic_psychology/
├── README.md                     # This file - lab overview
├── images/                       # Lab-wide resources and logos
├── projects/                     # Individual research projects
│   └── close_following/         # Complete self-contained projects
│       ├── R/                   # Analysis scripts and functions
│       ├── data/                # Data structure (raw data excluded)
│       ├── docs/                # Project documentation
│       ├── output/              # Results and summary files
│       └── README.md            # Project-specific documentation
└── shared/                      # Shared resources (future)
    ├── R/                       # Common analysis functions
    └── templates/               # Project templates
```

## 🚀 Getting Started

### For New Lab Members
1. **Clone the repository:**
   ```bash
   git clone https://github.com/alan-sims/traffic_psychology.git
   cd traffic_psychology
   ```

2. **Navigate to a specific project:**
   ```bash
   cd projects/close_following
   ```

3. **Open in RStudio/Positron:**
   - Open the `.Rproj` file in your chosen IDE
   - Follow the project-specific README instructions

### For New Projects
1. Create a new directory: `projects/your_project_name/`
2. Follow the established project structure
3. Include comprehensive documentation
4. Add your project to this README

## 🔬 Research Focus Areas

- **Driver Behavior Analysis** - Understanding how drivers respond to various traffic conditions
- **Close Following Dynamics** - Tailgating behavior across different road environments
- **Traffic Safety** - Identifying risk factors and safety interventions
- **Driving Simulation** - Controlled studies of driver responses

## 📊 Data Standards

- **Sampling Rate:** 0.05-second intervals (20 Hz) for driving simulation data
- **File Formats:** Tab-separated CSV with standardized column naming
- **Documentation:** Each dataset requires comprehensive metadata
- **Privacy:** Raw participant data excluded from repository

## 🤝 Contributing

### Code Standards
- Use descriptive variable names and functions
- Include comprehensive comments
- Follow tidyverse conventions for R code
- Document all analysis steps

### Project Requirements
- Self-contained project structure
- Clear README with setup instructions
- Comprehensive documentation
- Reproducible analysis pipeline

### Collaboration Workflow
1. Create feature branches for new development
2. Use descriptive commit messages
3. Update documentation alongside code changes
4. Submit pull requests for review

## 📈 Lab Impact

This repository enables:
- **Reproducible Research** - All analysis code version controlled
- **Knowledge Sharing** - Standardized approaches across projects  
- **Collaboration** - Easy onboarding for new researchers
- **Code Backup** - Centralized storage of all lab code
- **Quality Assurance** - Peer review of analysis methods

## 📞 Contact

**Lab Lead:** Alan Sims - [alan.sims@griffithuni.edu.au](mailto:alan.sims@griffithuni.edu.au)

**Repository:** https://github.com/alan-sims/traffic_psychology

---

*This repository represents the collective research efforts of our traffic psychology lab. All code is developed following open science principles and reproducible research practices.*