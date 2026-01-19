# Netflix Movies and TV Shows: Data Analysis using SQL

![Netflix Logo](https://github.com/shivanidesai30/netflix_sql_project/blob/main/Logonetflix.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows dataset using **SQL**. The goal is to extract actionable insights and answer various business questions related to content type, release trends, countries, genres, actors, and more.  

This README documents the **objectives, dataset, schema, business problems, SQL solutions, and key findings**.

---

## Objectives
- Analyze the distribution of content types (Movies vs TV Shows).  
- Identify the most common ratings for Movies and TV Shows.  
- Explore content by release year, country, and duration.  
- Investigate actors’ involvement in content, including regional and “Bad” content trends.  
- Categorize content based on keywords and genres.  
- Provide analytical insights that could inform content strategy and decision-making.

---

## Dataset
The dataset contains Netflix content metadata including title, director, cast, country, release year, duration, genre, and description.  

**Dataset Link:** [Netflix Movies and TV Shows Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

---

## Schema
```sql
CREATE TABLE netflix
(
    show_id      VARCHAR(6),
    type         VARCHAR(10),
    title        VARCHAR(150),
    director     VARCHAR(208),
    casts        VARCHAR(1000),
    country      VARCHAR(150),
    date_added   VARCHAR(50),
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(20),
    listed_in    VARCHAR(100),
    description  VARCHAR(250)
);
