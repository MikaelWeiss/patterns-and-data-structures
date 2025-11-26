In your editor, implement all of the following functions for a Leftist Min-Heap:

1. `empty(heap)`:

   * Input: A Leftist Min-Heap.
   * Output: `true` if the heap is empty, `false` otherwise.

2. `insert(heap, element)`:

   * Input: A Leftist Min-Heap and an element.
   * Output: A new Leftist Min-Heap with the element inserted.

3. `findMin(heap)`:

   * Input: A Leftist Min-Heap.
   * Output: The minimum element (at the root) without modifying the heap.

4. `deleteMin(heap)`:

   * Input: A Leftist Min-Heap.
   * Output: A new Leftist Min-Heap with the minimum element removed.

5. `merge(heap1, heap2)`:

   * Input: Two Leftist Min-Heaps.
   * Output: A new Leftist Min-Heap that contains all elements from both input heaps.

6. `toList(heap)`:

   * Input: A Leftist Min-Heap.
   * Output: A list of elements sorted in ascending order.

7. `fromList(list)`:

   * Input: A standard list of elements.
   * Output: A Leftist Min-Heap containing all the elements.

**Task Instructions**:

* Implement all functions in a purely functional manner.
* Use recursive definitions where appropriate, especially for `merge`, `insert`, and `deleteMin`.
* Write comprehensive tests to validate the correctness of each function.
* Consider edge cases such as:

  * Inserting into or deleting from an empty heap.
  * Merging an empty heap with a non-empty heap.
  * Duplicate insertions.

**Challenge Extension (Optional)**:

1. `mergeAll(heaps)`:

   * Merge a list of Leftist Min-Heaps into a single heap.

2. `size(heap)`:

   * Compute and return the total number of elements in the heap.

Please test your code to see if it works.
