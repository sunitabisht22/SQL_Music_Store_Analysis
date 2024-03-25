/* Q1: Who is the senior most employee based on job title? */
select * from employee
order by levels DESC
Limit 1;

/* Q2: Which countries have the most Invoices? (Group by use kiya hai kyunki multiple states repeat ho rahe hai) */
select Count(*) as c , billing_country
from invoice
group by billing_country
order by c DESC;  

/* Q3: What are top 3 values of total invoice? */
select total from invoice
order by total DESC
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money 
Write a query that returns one city that has the highest sum of invoice totals */

select billing_city, sum(total) as InvoiceTotal
from invoice
group by billing_city
order by InvoiceTotal DESC
limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money*/


select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from invoice
inner Join customer on customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by total DESC
limit 1;

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct emaiL, first_name, last_name 
from customer join invoice on customer.customer_id= invoice.customer_id
join invoice_line on invoice_line.invoice_line_id= invoice.invoice_id
where track_id IN(
select track_id from track 
join genre on track.genre_id = genre.genre_id
where genre.name= 'Rock'
)
order by email ;

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from artist
join album2 on artist.artist_id=album2.artist_id
join track on track.album_id=album2.album_id
join genre on genre.genre_id=track.genre_id
where genre.name LIKE 'Rock'
group by artist.artist_id,artist.name
order by number_of_songs DESC
Limit 10;

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name, milliseconds from track 
where milliseconds >  ( select avg(milliseconds) as avg_track_length 
from track)
order by milliseconds DESC;

/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

With best_selling_artist as (
select artist.artist_id as artist_id, artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id= invoice_line.track_id
join album2 on album2.album_id=track.album_id
join artist on artist.artist_id=album2.artist_id
group by 1,2
order by total_sales DESC
limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price* il.quantity) as amount_spent
from invoice i 
join customer c on c.customer_id= i.customer_id
join invoice_line as il on il.invoice_id= i.invoice_id
join track t on t.track_id= il.track_id
join album2 as alb on alb.album_id= t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by amount_spent DESC;

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level */

with popular_genre as (

select count(invoice_line.quantity) as purchases, customer.country, genre.genre_id, genre.name,
ROW_NUMBER() over (partition by customer.country order by count(invoice_line.quantity) DESC) as RowNo
from invoice_line 
join invoice on invoice_line.invoice_id= invoice.invoice_id
join customer on customer.customer_id= invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.name = track.name 
group by 2,3,4
order by 2 asc, 1 desc
)

select * from popular_genre where RowNo<=1

/* Q11. Write a query that determines the customer that has spent the most in music for each country. 
Write a query that returns the country along with the top customer and how much they spent.
For countries where the top amount spent is shared, provide all customers who spent this amount */

with recursive customer_with_country as (
select customer.customer_id , first_name, last_name, billing_country, sum(total) as total_spending 
from invoice 
join customer on customer.customer_id = invoice.customer_id 
group by 1,2,3,4 
order by 1,5 DESC), 

country_max_spending as (
select billing_country, max(total_spending) as max_spending 
from customer_with_country 
group by billing_country )

select cc.billing_country, cc.customer_id, cc.first_name, cc.last_name, cc.total_spending
from customer_with_country as cc
join country_max_spending as ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending 
order by 1;



