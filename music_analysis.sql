-- --------------------------------------------------SQL PROJECT - MUSIC STORE DATA ANALYSIS-------------------------------------------------------------------


-- ----------------------------------------------------------->QUESTIONS SET 1-EASY<----------------------------------------------------------------------------


-- Q1. Who is the Senior Most Employee Based on job title?
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;
-- Explanation: This query arranges employees by their job level in descending order and selects the top one. It helps identify the 
-- employee with the highest seniority in the company.



-- Q2. Which countries have the most Invoices? 
SELECT COUNT(*) AS most_invoices,billing_country
 FROM invoice
 GROUP BY billing_country
 ORDER BY most_invoices DESC;
 -- Explanation: This query counts invoices for each country, groups them, and sorts by count in descending order.
 -- It reveals which countries have the highest number of sales transactions.


 
-- Q3. What are top 3 values of total invoice? 
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;
-- Explanation: This query sorts all invoices based on their total amount and retrieves the top three. 
-- It highlights the biggest sales recorded in the dataset.



-- Q4.Which city has the best customers? We would like to throw a promotional Music 
-- Festival in the city we made the most money. Write a query that returns one city that 
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice totals?
SELECT billing_city,SUM(total) AS country_total
FROM invoice
GROUP BY billing_city
ORDER BY country_total DESC ;
-- Explanation: This query groups invoices by city, calculates the total revenue per city, and orders them by the sum.
-- It identifies which city brings the most business value.




-- Q5.Who is the best customer? The customer who has spent the most money will be 
-- declared the best customer. Write a query that returns the person who has spent the most money?
SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) AS  total FROM customer 
JOIN invoice ON customer.customer_id= invoice.customer_id 
GROUP BY customer.customer_id, customer.first_name, customer.last_name
ORDER BY total DESC;
-- Explanation: This query joins customer and invoice data, sums the total spending per customer, and orders the results by
-- amount spent. It determines who the top-spending customer is.




-- ----------------------------------------------------------->QUESTIONS SET 2-MODERATE<----------------------------------------------------------------------------


-- Q1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
-- Return your list ordered alphabetically by email starting with A?
SELECT DISTINCT first_name , last_name ,email 
FROM customer
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice.invoice_id
WHERE track_id IN(
SELECT track_id FROM track
JOIN genre ON track.genre_id=genre.genre_id
WHERE genre.name LIKE 'Rock')
ORDER BY email;
-- Explanation: This query finds customers who purchased rock music by joining related tables. It returns unique rock music 
-- listeners, ordered alphabetically by their email.



-- Q2.Let's invite the artists who have written the most rock music in our dataset. Write a query that
-- returns the Artist name and total track count of the top 10 rock bands?
SELECT artist.artist_id, artist.name , COUNT(artist.artist_id) AS number_of_songs FROM track
JOIN album ON album.album_id=track.album_id
JOIN artist ON artist.artist_id=album.artist_id
JOIN genre ON genre.genre_id=track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC
LIMIT 10;
-- Explanation: This query identifies artists with the highest number of rock tracks by joining multiple tables and counting songs. 
-- It lists the top 10 most prolific rock artists.



-- Q3.Return all the track names that have a song length longer than the average song length. Return the Name
-- and Milliseconds for each track. Order by the song length with the longest songs listed first?
SELECT name,milliseconds FROM track
WHERE milliseconds >(
SELECT AVG(milliseconds) as Avg_track_length
FROM track)
ORDER BY milliseconds DESC;
-- Explanation: This query calculates the average song length and returns tracks longer than that average. It helps identify songs 
-- that are above average in duration.




-- ----------------------------------------------------------->QUESTIONS SET 3-ADVANCE<----------------------------------------------------------------------------


-- Q1.Find how much amount spent by each customer on artists? Write a query to return customer name
-- artist name and total spent?
WITH  best_selling_artist AS (
SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
FROM invoice_line
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
GROUP BY artist.artist_id , artist.name
ORDER BY total_sales DESC
LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name , bsa.artist_name,
SUM(il.unit_price*il.quantity) AS Amount_spent
FROM invoice AS i 
JOIN customer AS c ON c.customer_id = i.customer_id
JOIN invoice_line AS il ON il.invoice_id= i.invoice_id
JOIN track AS t ON t.track_id= il.track_id
JOIN album AS alb ON alb.album_id= t.album_id
JOIN best_selling_artist AS bsa ON bsa.artist_id= alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY Amount_spent DESC;
-- Explanation: This query first finds the best-selling artist and then computes how much each customer spent on that artist. 
-- It gives insights into customer spending behavior on popular artists.



-- Q2.We want to find out the most popular music Genre for each country. We determine the most popular
-- genre as the genre with the highest amount of purchases. Write a query that returns each country
-- along with the top Genre. For countries where the maximum number of purchases is shared return all Genres?
WITH country_genre_purchases AS (
    SELECT c.country, g.name AS genre_name, g.genre_id,COUNT(il.quantity) AS total_purchases
    FROM invoice_line il
    JOIN invoice i ON il.invoice_id = i.invoice_id
    JOIN customer c ON c.customer_id = i.customer_id
    JOIN track t ON t.track_id = il.track_id
    JOIN genre g ON g.genre_id = t.genre_id
    GROUP BY c.country,g.name,g.genre_id 
),
popular_genre AS (
    SELECT * ,DENSE_RANK() OVER(PARTITION BY country ORDER BY total_purchases DESC )
    AS RowNo FROM country_genre_purchases
)
SELECT country,genre_name AS 'Most Popular Genre',total_purchases AS 'Total Tracks Purchased'
FROM popular_genre WHERE RowNo = 1 
ORDER BY country ASC,total_purchases DESC;
-- Explanation: This query ranks genres in each country based on total purchases using a window function. 
-- It identifies the most preferred genre(s) in every country.



-- Q3.Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent.
-- For countries where the top amount spent is shared, provide all customers who spent this amount 
WITH customer_with_country AS (
SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_Spending,
ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
FROM invoice
JOIN customer ON customer.customer_id= invoice.customer_id
GROUP BY customer.customer_id,first_name,last_name,billing_country
ORDER BY billing_country ASC , total_Spending DESC)
SELECT * FROM customer_with_country WHERE RowNo <= 1;
-- Explanation: This query calculates total spending by customers per country and ranks them using ROW_NUMBER(). 
-- It highlights the top spender from each country.

















 