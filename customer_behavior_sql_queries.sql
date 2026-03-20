select * from customer;

-- Q1.¿Cuáles son los ingresos totales generados por clientes masculinos vs femeninos?
select gender, SUM(purchase_amount) as revenue
from customer
group by gender;

-- Q2.¿Qué clientes utilizaron un descuento pero aun así gastaron más que el importe medio de compra?
select customer_id, purchase_amount
from customer
where discount_applied = 'Yes' and purchase_amount >= (select AVG(purchase_amount) from customer);

-- Q3.¿Cuáles son los 5 productos con el promedio de calificación más alto en las reseñas?
select item_purchased, ROUND(AVG(review_rating::numeric), 2) as "Average Product Rating"
from customer
group by item_purchased
order by AVG(review_rating) desc
limit 5;

-- Q4.Compara los importes promedio de compra entre el envío estándar y el envío exprés.
select shipping_type, ROUND(AVG(purchase_amount), 2) as "Average Shipping Type Spend"
from customer
where shipping_type in ('Standard','Express')
group by shipping_type;

-- Q5.¿Los clientes suscritos gastan más? Compara el gasto promedio y los ingresos totales entre suscriptores y no suscriptores.
select subscription_status,
COUNT(customer_id) as total_customers,
ROUND(AVG(purchase_amount), 2) as avg_spend, 
ROUND(SUM(purchase_amount), 2) as total_revenue
from customer
group by subscription_status
order by total_revenue, avg_spend desc;

-- Q6.¿Cuáles son los 5 productos con mayor porcentaje de compras con descuentos aplicados?
select item_purchased,
ROUND(100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*), 2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5;	

-- Q7.Segmenta a los clientes en 'New', 'Returning' y 'Loyal' según su número total de compras anteriores
-- muestra el recuento de cada segmento.
with customer_type as (
select customer_id, previous_purchases,
CASE 
	WHEN previous_purchases = 1 THEN 'New'
	WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
	ELSE 'Loyal'
	END AS customer_segment
from customer
)

select customer_segment, COUNT(*) as "Number of Customers"
from customer_type
group by customer_segment;

-- Q8.¿Cuáles son los 3 productos más comprados dentro de cada categoría?
with item_counts as (
select category, 
item_purchased,
COUNT(customer_id) as total_orders,
ROW_NUMBER() over(partition by category order by count(customer_id) desc) as item_rank
from customer
group by category, item_purchased
)

select item_rank, category, item_purchased, total_orders
from item_counts
where item_rank <= 3;

-- Q9.¿Es probable que los clientes que realizan compras frecuentes (más de 5 compras previas) se suscriban?
select subscription_status, COUNT(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status;

-- Q10.¿Cuál es la contribución de ingresos de cada grupo de edad?
select age_group,
SUM(purchase_amount) as age_group_total_revenue
from customer
group by age_group
order by age_group_total_revenue desc;
