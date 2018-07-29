use sakila;
#1a. Display the first and last name of all actors from table actor.
select first_name,last_name from actor;
#1b Display the first and last name of each actor in a single column in upper case letters. name rwh colum
select UPPER(CONCAT(first_name," ",last_name)) as `rwh` FROM actor;
#2a You need to find the ID number,first name , and last name of an actor, of whom you know only the first name,"Joe" what is one query would you use to obtain this information?
select actor_id,first_name,last_name  from actor where first_name like "Joe%";
#2b Find all actors whos last name contain the letters GEN
select first_name,last_name from actor where last_name like "%GEN%";
#2C find all actors whose last names contain the letter LI. This tie, order the rows by last name and first name, in tht order
use sakila;
select last_name,first_name from actor where last_name like "%LI%" order by  last_name asc ,first_name asc;
#2d Using IN, DISPLAY THE country_id and country columns of the following contries;Afghanistan,Bangladesh ,and China
select country_id,country from country where country in('Afghanistan','Bangladesh','China');
#*3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` 
#and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor add column description BLOB;
show columns from sakila.actor;

# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table actor drop `description`;
show columns from sakila.actor;
#4a. List the last names of actors, as well as how many actors have that last name.
select last_name,count(last_name) as `Number of Last_name` from actor group by last_name;
#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name,count(last_name) as `Number of Last_name` from actor group by last_name having `Number of Last_name` >=2;
#4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
update actor set first_name='HARPO' WHERE first_name='GROUCHO' and last_name='WILLIAMS';
SELECT * FROM actor  WHERE last_name ='WILLIAMS';
#4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` 
#was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.


update actor set first_name='GROUCHO' WHERE first_name='HARPO' and last_name='WILLIAMS';
SELECT * FROM actor where last_name='WILLIAMS';
#5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

 # * Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>
select * from information_schema.TABLES where TABLE_NAME='address';
#6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select sf.first_name,sf.last_name , addr.address ,addr.address2 ,addr.district ,(select city.city from city  where city.city_id=addr.city_id)  as city ,addr.postal_code  from staff as sf join address as addr on sf.address_id=addr.address_id;
#6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`

select sta.last_name ,sta.first_name ,t1.total from (select staff_id,sum(amount) as total from payment group by staff_id) as t1 join staff as sta on  t1.staff_id=sta.staff_id;
#6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

select f.title,fact.`number of actors` from (select film_id, count(actor_id) as `number of actors` from film_actor group by film_id) as fact inner join film as f on fact.film_id=f.film_id;

#* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

select tt1.title,tt1.`Number of copies` from (select film.title,inv.`Number of copies` from (select film_id,count(film_id)  as `Number of copies` from inventory group by film_id) as inv join film on inv.film_id=film.film_id) as tt1 where tt1.title='Hunchback Impossible';
# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name
select cus.last_name,cus.first_name,pp.`Total Paid` from (select customer_id,sum(amount) as `Total Paid` from payment group by customer_id) as pp join (select first_name,last_name,customer_id from customer) as cus on cus.customer_id=pp.customer_id order by cus.last_name asc;
# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` 
#have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select film.title from film where (film.title like'K%' or film.title like 'Q%' ) and film.language_id=(select language.language_id from language where language.name='English');
# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`
select actor.first_name,actor.last_name from actor where actor.actor_id in (select film_actor.actor_id from film_actor where film_actor.film_id=(select film.film_id from film where film.title='Alone Trip'));
#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
#Use joins to retrieve this information.

select first_name,last_name,email,country.country from ((customer join address on customer .address_id=address.address_id ) join city on address.city_id=city.city_id ) join country on city.country_id=country.country_id having country.country='Canada';

#7d. Sales have been lagging among young families, and you wish to target all family movies for 
#a promotion. Identify all movies categorized as family films.

select film.title from film where film.film_id in ( (select film_category.film_id from film_category where category_id=(select category_id  from category where name='Family')) );

#7e. Display the most frequently rented movies in descending order

select sf.title,ff.`Number of rentals` from (select film_id, count(film_id) as `Number of rentals` from inventory group by film_id order by `Number of rentals` desc) as ff join film as sf on ff.film_id=sf.film_id;

#7f. Write a query to display how much business, in dollars, each store brought in.

#select invs.store_id,join_tt.inventory_id ,join_tt.`Total Sales` from (select ren.inventory_id ,pp.`Total Sales` from rental as ren join (select rental_id,sum(amount) as `Total Sales` from payment group by rental_id) as pp on ren.rental_id=pp.rental_id)as join_tt join inventory as invs on join_tt.inventory_id=invs.inventory_id;
select invs.store_id,sum(join_tt.`Total Sales`) as `Total Sales Amount` from (select ren.inventory_id ,pp.`Total Sales` from rental as ren join (select rental_id,sum(amount) as `Total Sales` from payment group by rental_id) as pp on ren.rental_id=pp.rental_id)as join_tt join inventory as invs on join_tt.inventory_id=invs.inventory_id group by invs.store_id;
#* 7g. Write a query to display for each store its store ID, city, and country.

select finalt.store_id,finalt.address,finalt.city,country1.country from (select addrj.store_id,addrj.address ,cc.city,cc.country_id from ((select store.store_id,store.address_id,address.address,address.city_id from store join address on store.address_id=address.address_id) as addrj  join city as cc on addrj.city_id=cc.city_id)) as finalt join country as country1 on finalt.country_id=country1.country_id;
# 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: 
#category, film_category, inventory, payment, and rental.)

     
select test.name,sum(test.amount) as `gross revenue` from     (select cat3.film_id,cat3.`name`,cat3.inventory_id,cat3.rental_id ,payy.amount from (   select cat2.film_id,cat2.`name`,cat2.inventory_id,rentt.rental_id from 
( select cat1.film_id,cat1.`name`, invv.inventory_id from 
   (select film_category.film_id,category.`name` from film_category join category on film_category.category_id=category.category_id)  
    as cat1 join inventory as invv on cat1.film_id=invv.film_id) as cat2 join rental as rentt on cat2.inventory_id=rentt.inventory_id) as cat3 
     join payment as payy on cat3.rental_id=payy.rental_id) as test  group by test.name order by `gross revenue` desc limit 5; 
    
#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
#Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view view_top_5_rev as   (select test.name,sum(test.amount) as `gross revenue` from     (select cat3.film_id,cat3.`name`,cat3.inventory_id,cat3.rental_id ,payy.amount from (   select cat2.film_id,cat2.`name`,cat2.inventory_id,rentt.rental_id from 
( select cat1.film_id,cat1.`name`, invv.inventory_id from 
   (select film_category.film_id,category.`name` from film_category join category on film_category.category_id=category.category_id)  
    as cat1 join inventory as invv on cat1.film_id=invv.film_id) as cat2 join rental as rentt on cat2.inventory_id=rentt.inventory_id) as cat3 
     join payment as payy on cat3.rental_id=payy.rental_id) as test  group by test.name order by `gross revenue` desc limit 5);

#8b. How would you display the view that you created in 8a?
# it will display in sakila schema under Views and the name of the view would be "view_top_5_rev"
#8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view IF exists view_top_5_rev;









