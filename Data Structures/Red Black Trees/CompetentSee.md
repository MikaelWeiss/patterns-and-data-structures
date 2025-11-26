In your editor, implement the following functions for a **Red-Black Tree** using the structure `{color, value, next_left, next_right}` where `color` is either `red` or `black`:

### Functional Requirements:

1. **`empty(rbt)`**

   * Input: A Red-Black Tree
   * Output: `true` if the tree is empty, `false` otherwise

2. **`add(rbt, element)`**

   * Input: A Red-Black Tree and an element
   * Output: A new Red-Black Tree with the element added

3. **`contains(rbt, element)`**

   * Input: A Red-Black Tree and a value
   * Output: `true` if the value is found, `false` otherwise

4. **`remove(rbt, element)`**

   * Input: A Red-Black Tree and an element
   * Output: A new Red-Black Tree with the element removed

5. **`min(rbt)`**

   * Input: A Red-Black Tree
   * Output: The smallest element or `nil` if the tree is empty

6. **`max(rbt)`**

   * Input: A Red-Black Tree
   * Output: The largest element or `nil` if the tree is empty

7. **`toList(rbt)`**

   * Input: A Red-Black Tree
   * Output: A list of elements in sorted order

8. **`fromList(list)`**

   * Input: A list of elements
   * Output: A Red-Black Tree

---

### Task Instructions:

* Implement all the above functions using functional programming principles.
* Use recursive definitions wherever appropriate.
* Write tests to validate the correctness of each function and ensure that tree properties are preserved.
* Handle edge cases such as:

  * Adding to an empty tree.
  * Adding duplicate elements.
  * Removing nodes with one or two children.
  * Rebalancing and recoloring during `add` and `remove`.

---

### Challenge Extension (Optional):

1. **`map(rbt, function)`** – Apply a function to each element and return a new tree.
2. **`merge(rbt1, rbt2)`** – Combine two Red-Black Trees into one.
3. **`blackHeight(rbt)`** – Return the black-height of the tree.
4. **`validateRBT(rbt)`** – Ensure all Red-Black Tree rules are satisfied.

Please test your code to see if it works.

