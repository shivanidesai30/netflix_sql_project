# Netflix Movies and TV Shows: Data Analysis Using SQL

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
```
## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*) AS total_content
FROM netflix
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT
    type,
    rating
FROM 
(
    SELECT
        type,
        rating,
        COUNT(*),
        RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY 1, 2
) AS t1
WHERE ranking = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE 
    type = 'Movie'
    AND release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country,
    COUNT(*) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT 
    title,
    CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS duration_minutes
FROM netflix
WHERE 
    type = 'Movie'
    AND duration IS NOT NULL
ORDER BY duration_minutes DESC
LIMIT 1;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *,
    CAST(TRIM(SPLIT_PART(date_added, ',', 2)) AS INTEGER) AS year_added
FROM netflix
WHERE date_added IS NOT NULL
    AND CAST(TRIM(SPLIT_PART(date_added, ',', 2)) AS INTEGER) >= EXTRACT(YEAR FROM CURRENT_DATE) - 5
ORDER BY year_added DESC;
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT 
    *,
    CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS num_seasons
FROM netflix
WHERE 
    type = 'TV Show'
    AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5
ORDER BY num_seasons;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY genre
ORDER BY total_content DESC;
```

**Objective:** Count the number of content items in each genre.

### 10. Analyze the Number of Netflix Titles Released per Year Involving India

```sql
SELECT
    release_year,
    COUNT(*) AS total_releases
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY release_year
ORDER BY total_releases DESC, release_year
LIMIT 5;
```

**Objective:** Return the top 5 years with the highest content releases involving India as a production country.

### 11. List All Movies that are Documentaries

```sql
SELECT *
FROM netflix
WHERE 
    type = 'Movie'
    AND listed_in ILIKE '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT *
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT
    release_year,
    COUNT(*) AS total_movies
FROM netflix
WHERE
    type = 'Movie'
    AND casts ILIKE '%Salman Khan%'
    AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10
GROUP BY release_year
ORDER BY release_year DESC;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT
    actor_name,
    COUNT(*) AS movies_in_india
FROM (
    SELECT
        TRIM(actor) AS actor_name
    FROM netflix,
        UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor
    WHERE country ILIKE '%India%'
        AND type = 'Movie'
        AND casts IS NOT NULL
) AS actor_list
GROUP BY actor_name
ORDER BY movies_in_india DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
SELECT 
    COUNT(*) AS total_content,
    CASE
        WHEN description ~* '\mkill(s|ing)?\M'
            OR description ~* '\mviolenc(e|ent)?\M' THEN 'Bad'
        ELSE 'Good'
    END AS content_rating
FROM netflix
GROUP BY content_rating;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

### 16. Which Genres Tend to Have Longer Movies on Average?

```sql
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
    ROUND(AVG(CAST(SPLIT_PART(duration, ' ', 1) AS NUMERIC)), 2) AS avg_duration_minutes
FROM netflix
WHERE 
    type = 'Movie'
    AND duration IS NOT NULL
GROUP BY genre
ORDER BY avg_duration_minutes DESC
LIMIT 10;
```

**Objective:** Identify which genres have the longest average movie duration.

### 17. Which Actors Appear Most Frequently in Multiple Genres?

```sql
SELECT 
    actor_name, 
    COUNT(DISTINCT genre) AS genre_count
FROM (
    SELECT 
        TRIM(actor) AS actor_name,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
    FROM netflix,
        UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor
    WHERE casts IS NOT NULL
        AND listed_in IS NOT NULL
) AS t
WHERE actor_name IS NOT NULL 
    AND actor_name <> ''
GROUP BY actor_name
ORDER BY genre_count DESC
LIMIT 10;
```

**Objective:** Find actors with the most diverse genre appearances.

### 18. How Has Netflix Content Evolved Over Time in Terms of Type?

```sql
SELECT 
    release_year,
    type,
    COUNT(*) AS total_content
FROM netflix
WHERE release_year IS NOT NULL
GROUP BY release_year, type
ORDER BY release_year, type;
```

**Objective:** Analyze the trend of Movies vs TV Shows releases over the years.

### 19. Which Countries Produce the Longest Movies on Average?

```sql
SELECT
    TRIM(country_name) AS country,
    ROUND(AVG(CAST(SPLIT_PART(duration, ' ', 1) AS NUMERIC)), 2) AS avg_movie_duration_in_minutes,
    STRING_AGG(DISTINCT TRIM(genre), ', ') AS common_genres
FROM netflix,
    LATERAL UNNEST(STRING_TO_ARRAY(country, ',')) AS country_name,
    LATERAL UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
WHERE 
    type = 'Movie'
    AND duration IS NOT NULL
    AND country IS NOT NULL
GROUP BY country_name
ORDER BY avg_movie_duration_in_minutes DESC
LIMIT 10;
```

**Objective:** Identify countries with the longest average movie durations and their common genres.

### 20. Which Actors Appear Most Often in "Bad" Content in the U.S.?

```sql
SELECT
    actor_name,
    COUNT(*) AS bad_content_count
FROM (
    SELECT
        TRIM(actor) AS actor_name,
        CASE
            WHEN description ~* '\mkill(s|ing)?\M'
                OR description ~* '\mviolenc(e|ent)?\M' THEN 'Bad'
            ELSE 'Good'
        END AS content_rating,
        TRIM(country_name) AS country_name
    FROM netflix,
        LATERAL UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
        LATERAL UNNEST(STRING_TO_ARRAY(country, ',')) AS country_name
    WHERE casts IS NOT NULL
        AND country IS NOT NULL
) AS actor_list
WHERE content_rating = 'Bad'
    AND country_name = 'United States'
GROUP BY actor_name
ORDER BY bad_content_count DESC
LIMIT 10;
```

**Objective:** Identify actors who frequently appear in content with violent themes in the United States.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.
- **Genre Analysis:** Certain genres tend to have longer average movie durations, indicating different storytelling formats.
- **Actor Insights:** Analysis of actor appearances across genres and content types reveals casting patterns in different markets.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

## Author - Shivani

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

- **LinkedIn**: ![Connect with me professionally!](www.linkedin.com/in/shivanidesai111)
- **GitHub**: [https://github.com/shivanidesai30]

Thank you for your support, and I look forward to connecting with you!
