# CS823 Assignment 1 — Classical and Temporal Planning (PDDL)

This project implements both classical and temporal planning models for a package delivery scenario, completed as part of the MSc module **CS823: Reasoning for Intelligent Agents** at the University of Strathclyde.

---

## Problem Statement

The goal is to model and solve a package delivery problem using PDDL.  
Two planning models are developed:

- **Classical planning** (non-durative actions, no time constraints)
- **Temporal planning** (durative actions, time windows, concurrency)

The domain includes drivers, vans, packages, and connected locations.

---

## Dataset / Environment Description

There is no dataset; instead, the environment is defined using:

- Locations and route connections  
- Drivers and vans  
- Packages  
- Predicates describing positions, capacities, and states  
- Actions for walking, boarding, driving, loading, unloading, etc.

---

## Approach / Architecture

### Classical Planning
- Designed `domain_classical.pddl` with non-durative actions:
  - `walk`
  - `board_van`
  - `unboard_van`
  - `drive_van`
  - `load_package`
  - `unload_package`
- Logical constraints ensure:
  - Drivers must be at the same location as vans/packages
  - Vans must have capacity
  - Packages can only be loaded/unloaded when conditions are met

### Temporal Planning
- Extended the classical domain with **durative actions**
- Added:
  - Action durations
  - Temporal constraints
  - Concurrency where appropriate
  - Time windows for deliveries

---

## Key Techniques

- Classical STRIPS-style planning  
- Temporal planning with durative actions  
- Logical modelling of agents and resources  
- Plan validation and testing  
- Understanding concurrency and time windows  

---

## Results

### Classical Plan (Unit Test)
A valid plan was generated:
0.00000: (walk driver1 loc1 loc2) [0.00100] 0.00100: (board_van van1 driver1 loc2) [0.00100] 0.00200: (load_package van1 driver1 pack1 loc2) [0.00100] 0.00300: (drive_van van1 driver1 loc2 loc1) [0.00100] 0.00400: (unload_package van1 driver1 pack1 loc1) [0.00100] 0.00500: (drive_van van1 driver1 loc1 loc2) [0.00100] 0.00600: (unboard_van van1 driver1 loc2) [0.00100] 0.00700: (walk driver1 loc2 loc1) [0.00100]


More results are available in `/results/`.

---

## What I Learned

- How to design complete PDDL domains and problems  
- Differences between classical and temporal planning  
- How durative actions introduce concurrency and timing complexity  
- How to test and validate plans using automated planners  

---
