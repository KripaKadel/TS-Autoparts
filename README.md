# Business Rules
## 1. Users
* A user has a name, email, phone number, password, and role.
* The role column can have one of three enum values: admin, customer, or mechanic.
* **Uniqueness:** Each user must have a unique email and phone number.
* **Mandatory:** name, email, phone number, password, role.
* **Optional:** Profile image.
## 2. Admin
* An admin has a name, email, phone number, and password.
* An admin manages car part listings, orders, inventory, and garage service appointments.
* An admin can add, edit, or remove car parts from the product list and manage stock availability.
* An admin manages mechanics and oversees their appointment schedules.
* **Uniqueness:** Each admin must have a unique email and phone number.
* **Mandatory:** name, email, phone number, password.
* **Optional:** Profile image.
## 3. Customers
* A customer has a full name, email, password, and phone number.
* A customer can browse products, add products to the cart, place orders, book garage services, and leave reviews for products and mechanics.
* A customer can book appointments for garage services by selecting an available time slot.
* A customer can give ratings and reviews for both products they have purchased and mechanics who provided services.
* **Uniqueness:** Each customer must have a unique email and phone number.
* **Mandatory:** name, email, phone number, password.
* **Optional:** Profile image.
## 4. Mechanic
* A mechanic has a name, email, phone number, and password.
* A mechanic can manage their availability for appointments.
* A mechanic can view and respond to appointments booked by users.
* A mechanic can receive ratings and reviews from customers who have used their services.
* **Uniqueness:** Each mechanic must have a unique email and phone number.
* **Mandatory:** name, email, phone number, password.
* **Optional:** Profile image.
## 5. Product
* A product has a name, brand, category, price, model, stock, image, and description.
* A product can be added to the cart by users and purchased after completing the order process.
* A product can be filtered by brand, category, and model for easy browsing by users.
* Users can give ratings and reviews for products after purchasing them.
* **Uniqueness:** Each product must have a unique name and model.
* **Mandatory:** name, brand, category_id, price, model, stock, image.
* **Optional:** description.
## 6. Cart
* A cart is associated with a single user and can contain multiple products.
* A user can add, update, or remove products from the cart before placing an order.
* A cart must calculate the total price based on the products added.
* A user can view their cart at any time to review the products selected.
* **Uniqueness:** Each cart is unique to a user_id.
* **Mandatory:** user_id, product_id, quantity, total_price.
## 7. Orders
* An order has an order_id, user_id, order_date, status, and total_amount.
* An order is created when a user checks out the items in their cart.
* An order goes through various statuses: Pending, Processing, Shipped, Delivered, Cancelled.
* An order can only be canceled by a user if the status is still Pending.
* **Uniqueness:** Each order must have a unique order_id.
* **Mandatory:** user_id, order_date, status, total_amount.
## 8. Order_Items
* The Order_Items entity tracks individual products that are part of an order.
* Each order can have multiple items (products) associated with it.
* An order item includes the order_id, product_id, quantity, and price of each product.
* The total order amount is calculated by summing the prices of all Order_Items.
* **Uniqueness:** Each order item must be unique order_items_id.
* **Mandatory:** order_id, product_id, quantity, price.
## 9. Appointment
* An appointment has a user_id, mechanic_id, service_description, appointment_date, time, and status.
* A user can book an appointment with a mechanic by selecting a time slot based on the mechanic's availability.
* The appointment status can be Pending, Confirmed, Completed, or Cancelled.
* **Uniqueness:** Each appointment must have a unique combination of user_id, mechanic_id, and appointment_date.
* **Mandatory:** user_id, mechanic_id, service_description, appointment_date, status, time.
## 10. Review
* A review has a user_id, rating, comment, and can be associated with either a product_id or mechanic_id.
* A user can give a rating and leave a comment for products they have purchased and mechanics they have received services from.
* A review can only be submitted once the product has been purchased or the service has been completed.
* **Uniqueness:** Each review must be unique to a combination of user_id and product_id or mechanic_id.
* **Mandatory:** user_id, rating, comment, product_id or mechanic_id.
## 11. Payment
* Payments are made by users during the checkout process for car parts or after confirming garage service appointments.
* Payment methods include Khalti or Cash.
* Payment status can be Paid, Pending, or Failed.
* **Uniqueness:** Each payment must be linked to a unique order_id or appointment_id.
* **Mandatory:** user_id, order_id or appointment_id, payment_method, status.
## 12. Categories
* A category has a name and description.
* Products are assigned to a specific category for easier filtering and browsing by users.
* Categories help users narrow down their search based on the type of car parts they need.
* **Uniqueness:** Each category must have a unique name.
* **Mandatory:** name.
* **Optional:** description









