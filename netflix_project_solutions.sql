-- Netflix Project

CREATE TABLE netflix
(
	show_id VARCHAR(6),
	type	VARCHAR(10),
	title	VARCHAR(150),
	director VARCHAR(208),
	casts	VARCHAR(1000),
	country	VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating	VARCHAR(10),
	duration VARCHAR(20),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);


-- 15 Business Problems


-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*) AS total_content
FROM netflix
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows

SELECT
	type,
	rating
FROM 
(
	SELECT
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
GROUP BY 1, 2
) AS t1
WHERE ranking = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE 
	type = 'Movie'
	AND
	release_year = 2020;
	

-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country,
    COUNT(*) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- 5. Identify the longest movie

SELECT 
	title,
	CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS duration_minutes
FROM netflix
WHERE 
	type = 'Movie'
	AND
	duration IS NOT NULL
ORDER BY duration_minutes DESC
LIMIT 1;


-- 6. Find content added in the last 5 years

SELECT *,
       CAST(TRIM(SPLIT_PART(date_added, ',', 2)) AS INTEGER) AS year_added
FROM netflix
WHERE date_added IS NOT NULL
  AND CAST(TRIM(SPLIT_PART(date_added, ',', 2)) AS INTEGER) >= EXTRACT(YEAR FROM CURRENT_DATE) - 5
ORDER BY year_added DESC;


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix
WHERE 
	director ILIKE '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons

SELECT 
	*,
	CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS num_seasons
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5
ORDER BY num_seasons;
	

-- 9. Count the number of content items in each genre

SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
	COUNT(*) AS total_content
FROM netflix
GROUP BY genre
ORDER BY total_content DESC;


-- 10. Analyze the number of Netflix titles released per year that involve India as a production country, accounting for titles with multiple listed countries.
-- return top 5 year with highest total content release!

SELECT
	release_year,
	COUNT(*) AS total_releases
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY release_year
ORDER BY total_releases DESC, release_year
LIMIT 5;


-- 11. List all movies that are documentaries

SELECT *
FROM netflix
WHERE 
	type = 'Movie'
	AND
	listed_in ILIKE '%Documentaries%';


-- 12. Find all content without a director

SELECT *
FROM netflix
WHERE director IS NULL;


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

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


-- 14. Find the top 10 actors who have appeared in the highest number of movies released in India.

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


-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

SELECT COUNT(*) AS total_content,
    CASE
        WHEN description ~* '\mkill(s|ing)?\M'
          OR description ~* '\mviolenc(e|ent)?\M' THEN 'Bad'
        ELSE 'Good'
    END AS content_rating
FROM netflix
GROUP BY content_rating;


-- 16. Which genres tend to have longer movies on average?

SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
    ROUND(AVG(CAST(SPLIT_PART(duration, ' ', 1) AS NUMERIC)), 2) AS avg_duration_minutes
FROM netflix
WHERE 
	type = 'Movie'
	AND 
	duration IS NOT NULL
GROUP BY genre
ORDER BY avg_duration_minutes DESC
LIMIT 10;


-- 17. Which actors appear most frequently in multiple genres?

SELECT 
	actor_name, 
	COUNT(DISTINCT genre) AS genre_count
FROM (
    SELECT TRIM(actor) AS actor_name,
           TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
    FROM netflix,
         UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor
    WHERE casts IS NOT NULL
      AND listed_in IS NOT NULL
) AS t
WHERE 
	actor_name IS NOT NULL 
	AND 
	actor_name <> ''
GROUP BY actor_name
ORDER BY genre_count DESC
LIMIT 10;


-- 18. How has Netflix content evolved over time in terms of type?

SELECT 
	   release_year,
       type,
       COUNT(*) AS total_content
FROM netflix
WHERE release_year IS NOT NULL
GROUP BY release_year, type
ORDER BY release_year, type;


-- 19. Which countries produce the longest movies on average, 
-- and what genres are most common there?

SELECT
    TRIM(country_name) AS country,
    ROUND(AVG(CAST(SPLIT_PART(duration, ' ', 1) AS NUMERIC)), 2) AS avg_movie_duration_in_minutes,
    STRING_AGG(DISTINCT TRIM(genre), ', ') AS common_genres
FROM netflix,
     LATERAL UNNEST(STRING_TO_ARRAY(country, ',')) AS country_name,
     LATERAL UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
WHERE 
	type = 'Movie'
    AND 
	duration IS NOT NULL
  	AND 
	country IS NOT NULL
GROUP BY country_name
ORDER BY avg_movie_duration_in_minutes DESC
LIMIT 10;


-- Which actors appear most often in “Bad” content (movies/TV shows with violence or killing)
-- in the U.S.?

SELECT
    actor_name,
    COUNT(*) AS bad_content_count
FROM (
    SELECT
        TRIM(actor) AS actor_name,
        CASE
            WHEN 
				description ~* '\mkill(s|ing)?\M'
                OR 
				description ~* '\mviolenc(e|ent)?\M' THEN 'Bad'
            ELSE 'Good'
        END AS content_rating,
        TRIM(country_name) AS country_name
    FROM netflix,
         LATERAL UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
         LATERAL UNNEST(STRING_TO_ARRAY(country, ',')) AS country_name
    WHERE 
		casts IS NOT NULL
      	AND 
		country IS NOT NULL
) AS actor_list
WHERE content_rating = 'Bad'
  AND country_name = 'United States'
GROUP BY actor_name
ORDER BY bad_content_count DESC
LIMIT 10;
