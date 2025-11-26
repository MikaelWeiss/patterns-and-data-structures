Let's go!
Data CompetentSee said:

Great! What topic would you like to show competency in?

You said:
Deques

Data CompetentSee said:

In your editor, implement a functional deque (double-ended queue) using the structure `{list, list}`. The deque should consist of two lists: one for the front elements and another for the rear elements. Implement **all** of the following functions:

1. `empty(deque)`: Checks if the deque is empty.

   * Input: A deque.
   * Output: `true` if the deque is empty, `false` otherwise.

2. `enqueue(deque, element)`: Adds an element to the rear of the deque.

   * Input: A deque and an element.
   * Output: A new deque with the element added to the rear.

3. `enqueue_front(deque, element)`: Adds an element to the front of the deque.

   * Input: A deque and an element.
   * Output: A new deque with the element added to the front.

4. `dequeue(deque)`: Removes the first element from the deque.

   * Input: A deque.
   * Output: A new deque with the first element removed.

5. `dequeue_back(deque)`: Removes the last element from the deque.

   * Input: A deque.
   * Output: A new deque with the last element removed.

6. `head(deque)`: Retrieves the first element of the deque without removing it.

   * Input: A deque.
   * Output: The first element or `nil` if the deque is empty.

7. `tail(deque)`: Retrieves the last element of the deque without removing it.

   * Input: A deque.
   * Output: The last element or `nil` if the deque is empty.

8. `toList(deque)`: Converts the deque into a single list of elements.

   * Input: A deque.
   * Output: A list of elements in order.

9. `fromList(list)`: Converts a list of elements into a deque.

   * Input: A list of elements.
   * Output: A deque.

**Task Instructions**:

* Use functional programming principles to implement these functions.
* Write tests to validate the correctness of each function.
* Use recursive definitions wherever appropriate.
* Provide a test suite with multiple scenarios, including edge cases, such as:

  * Enqueuing and dequeuing elements from both ends in an empty deque.
  * Accessing the head and tail of the deque at various stages.
  * Converting between lists and deques.
  * Combining multiple operations, such as enqueue, dequeue, and enqueue_front, sequentially.

**Challenge Extension (Optional)**:

* Implement a `reverse(deque)` function that reverses the order of elements in the deque.
* Implement a `length(deque)` function to count the elements in the deque.
* Write a `merge(deque1, deque2)` function that combines two deques into one.

Please test your code to see if it works.

