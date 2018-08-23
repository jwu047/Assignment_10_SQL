USE sakila;
#1a: display first and last name in actor table
SELECT first_name, last_name FROM actor;
#1b: display first and last name in a single column in upper case
SELECT CONCAT(UPPER(first_name), ' ', UPPER(last_name)) AS 'Actor Name' FROM actor;

#2a: find ID, first and last name of actor for only 'Joe'
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'JOE';
#2b: actors with last name containing 'GEN'
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE '%GEN%'; 
#2c: actors with lat name containing the letter 'LI', order rows by last name and first name, in that order
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;
#2d: using IN, display country_id and country columns of the following:
#Afghanistan, Bangladesh, and China
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

#3a: Add middle_name column to table actor, place betwen first and last name columns
#Hint: specify the data
SELECT * FROM actor;
ALTER TABLE actor
ADD COLUMN midde_name VARCHAR(50) AFTER first_name;
#3b: some actors have long names, change the data type of middlename columns to blobs
ALTER TABLE actor 
MODIFY COLUMN middle_name BLOB;

#3c: delete the middle_name column
ALTER TABLE actor DROP COLUMN middle_name;

#4a: list last names of actors, and how many actors have that last name
SELECT last_name, COUNT(*) AS 'Count' FROM actor GROUP BY last_name;
#4b: list last names of actors and numbers of actors with that last name
# but only for names that are at least shared by two actors
SELECT last_name, COUNT(*) AS 'Count' FROM actor GROUP BY last_name
HAVING Count >= 2;
#4c: HARPO WILLIAMS accidentally entered in the actor table as GROUCHO WILLIAMS
UPDATE actor SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
#4d: GROUCHO was the correct name after all, if the first name of the actor 
# is currently HARPO change it to GROUCHO
UPDATE actor SET first_name = 'GROUCHO' 
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
DESCRIBE sakila.address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT a.first_name, a.last_name, b.address
FROM staff a LEFT JOIN address b ON a.address_id = b.address_id;
#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT a.first_name, a.last_name, SUM(b.amount) AS 'Total'
FROM staff a LEFT JOIN payment b ON a.staff_id = b.staff_id
GROUP BY a.first_name, a.last_name;
#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT a.title, COUNT(b.actor_id) AS 'Total'
FROM film a LEFT JOIN film_actor b ON a.film_id = b.film_id
GROUP BY a.title;
#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
### There are 2 copies of the film Hunchback Impossible in the inventory system.
#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT a.first_name, a.last_name, SUM(b.amount) AS 'Total'
FROM customer a LEFT JOIN payment b ON a.customer_id = b.customer_id
GROUP BY a.first_name, a.last_name 
ORDER BY a.last_name;


#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%')
AND language_id = (SELECT language_id FROM language WHERE name = 'English');

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor 
WHERE actor_id IN (SELECT actor_id FROM film_actor
WHERE film_id IN (SELECT film_id FROM film WHERE title = 'ALONE TRIP'));

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email FROM customer c
JOIN address a ON (c.address_id = a.address_id)
JOIN city cit ON (a.city_id=cit.city_id)
JOIN country cntry ON (cit.country_id=cntry.country_id);

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title FROM film f
JOIN film_category fc on (f.film_id = fc.film_id)
JOIN category c on (fc.category_id = c.category_id);

#7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(f.film_id) AS 'Count_of_Rented_Movies' FROM  film f
JOIN inventory i ON (f.film_id= i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
GROUP BY title ORDER BY Count_of_Rented_Movies DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) FROM payment p
JOIN staff s ON (p.staff_id=s.staff_id)
GROUP BY store_id;

#7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country FROM store s
JOIN address a ON (s.address_id=a.address_id)
JOIN city c ON (a.city_id=c.city_id)
JOIN country cntry ON (c.country_id=cntry.country_id);

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS "TopFive", SUM(p.amount) AS "Gross" FROM category c
JOIN film_category fc ON (c.category_id=fc.category_id)
JOIN inventory i ON (fc.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;


#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
SELECT c.name AS "TopFive", SUM(p.amount) AS "Gross" FROM category c
JOIN film_category fc ON (c.category_id=fc.category_id)
JOIN inventory i ON (fc.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;

#8b. How would you display the view that you created in 8a?
###SELECT * FROM TopFive;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
###DROP VIEW TopFive;