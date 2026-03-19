# CS823 Assignment 1 — Classical and Temporal Planning (PDDL)

This project implements both classical and temporal planning models for a package delivery workflow.  
It was developed as part of the MSc module CS823: Reasoning for Intelligent Agents at the University of Strathclyde.

The work demonstrates domain modelling, action design, temporal reasoning, and plan generation using PDDL.

---

## Problem Overview

The planning scenario models a logistics environment involving:

- Drivers who can walk, board vans, unboard vans, and operate vehicles  
- Vans that move between connected locations  
- Packages that must be picked up, transported, and delivered  
- A network of connected locations  
- (Temporal model only) fuel levels, fuel stations, distances, and time windows  

Two domains are implemented:

- Classical domain (STRIPS actions, no durations)  
- Temporal domain (durative actions, numeric fluents, fuel constraints, and delivery deadlines)

---

## Environment Description

### Object Types
- driver  
- van  
- package  
- location  

### Key Predicates (Classical and Temporal)

Package-related:
- package-in-van  
- package-at-location  
- package-at-destination  
- is-package-ready  
- is-package-delivered  

Van-related:
- van-at-location  
- is-van-available  
- is-van-empty  

Driver-related:
- driver-at-location  
- driver-in-van  
- is-driver-available  
- is-driver-tasked  
- is-driver-unboarded-van  
- driver-can-walk  

Connectivity:
- connects l1 l2  

Temporal-only additions:
- fuel-station l  
- (van-fuel-level v)  
- (van-fuel-consumption-rate v)  
- (location-distance from to)

---

## Classical Planning Domain

The classical domain (domain_classical.pddl) defines the following actions:

1. walk-driver  
2. driver-board-van  
3. driver-unboard-van  
4. drive-van  
5. load-package  
6. unload-package  

These actions use instantaneous effects and logical preconditions.

---

## Temporal Planning Domain

The temporal domain (domain_temporal.pddl) extends the classical model with:

- Durative actions  
- Numeric fluents (fuel, distance)  
- Over-all, at-start, and at-end conditions  
- Fuel consumption and refuelling  
- Distance-based travel time  
- Delivery time windows using "within" constraints  

Durative actions include:

- walk-driver  
- driver-board-van  
- driver-unboard-van  
- drive-van  
- load-package  
- unload-package  
- refuel-van  

---

## Problem Files

### Classical Problem (problem_classical.pddl)

Defines:

- Four locations: amritsar, jandiala, rayya, mehta  
- Two vans: van1, van2  
- Two drivers: driver1, driver2  
- Four packages (pkg1 and pkg2 used)  

Initial state includes connectivity, driver and van positions, package locations, availability, and readiness.

Goal state requires:

- pkg1 delivered to amritsar  
- pkg2 delivered to mehta  
- vans returned to original locations  
- drivers returned to original locations  

---

### Temporal Problem (problem_temporal.pddl)

Extends the classical problem with:

- Fuel levels  
- Fuel consumption rates  
- Distances between locations  
- Fuel stations at amritsar and rayya  

Temporal constraints:

- pkg1 delivered within 20 time units  
- pkg2 delivered within 16 time units  

---

## Modelling Challenge: Handling Unsupported Negative Preconditions

A key challenge in this assignment was that the planner used did not support negative preconditions inside action precondition blocks.  
For example, conditions such as:

(not (driver-in-van d v))  
(not (package-in-van p v))

could not be used directly.

To address this, the domain was redesigned using explicit state-tracking predicates that encode the "negative" information without requiring negation. Examples include:

- driver-can-walk  
- is-driver-unboarded-van  
- is-van-empty  

Actions update these predicates in their effects so that mutually exclusive states are always represented explicitly.  
This approach preserved correctness while remaining compatible with the planner's restrictions.

---

## Key Techniques Demonstrated

- STRIPS-style classical planning  
- Temporal planning with durative actions  
- Numeric fluents (fuel, distance)  
- Time-window constraints using "within"  
- Resource modelling (drivers, vans, packages)  
- Plan validation and debugging  
- Modelling concurrency and over-all conditions  

---

## What I Learned

- How to design complete PDDL domains and problem files  
- How classical and temporal planning differ in modelling complexity  
- How durative actions introduce concurrency and numeric reasoning  
- How to incorporate fuel, distance, and time windows into planning  
- How to debug invalid plans and refine domain constraints  
- How planners interpret over-all vs. start/end conditions  