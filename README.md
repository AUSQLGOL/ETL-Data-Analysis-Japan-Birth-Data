# Japan Demographic Structural Decline Analysis (1899-2023)

## Overview

This project analyzes long-term birth trends in Japan using a structured
multi-layer PostgreSQL data pipeline and Power BI visualization layer.
The objective was to demonstrate production-style data engineering
workflow combined with executive-level analytical storytelling.

------------------------------------------------------------------------

## Architecture

![Data Pipeline Architecture]([resources/pipeline_architecture.png](https://github.com/AUSQLGOL/ETL-Data-Analysis-Japan-Birth-Data/blob/main/Resources/Data_Process_flowchart.png)

------------------------------------------------------------------------

## Data Engineering Process

### 1. Raw Layer

-   Ingested CSV with no assumptions (all TEXT columns)
-   Performed structural validation

### 2. Staging Layer

-   Converted columns to appropriate numeric types
-   Enforced primary key on year
-   Handled structural null values (fertility rate)

### 3. Analytics Layer

-   Created fact table with:
    -   Yearly absolute change (LAG window function)
    -   Year-over-year percentage change
    -   Decade aggregation
-   Prepared BI-ready dataset

------------------------------------------------------------------------

## Key Findings

-   Historical peak in 1949 (post-war baby boom).
-   \~73% decline in total births from peak to latest year.
-   Sustained structural demographic contraction from the 1980s onward.
-   Current fertility rate (1.20) remains below replacement level.

------------------------------------------------------------------------

## Technical Skills Demonstrated

-   PostgreSQL schema design
-   ETL layer separation (raw → staging → analytics)
-   SQL window functions (LAG)
-   Time-series analysis
-   Data modeling (fact table design)
-   Power BI KPI & dashboard development

------------------------------------------------------------------------

## Tools Used

-   PostgreSQL
-   Power BI
-   SQL (Window Functions, Aggregations)
-   GitHub for version control

------------------------------------------------------------------------

## Project Purpose

This project was designed to simulate a production-style data
engineering workflow, emphasizing clean data architecture,
transformation logic inside the database, and separation of concerns
between data processing and visualization layers.
