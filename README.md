# binary_search_trees

I'm working on my binary search tree's level order method at the moment, and I feel like I'm having a simple mistake that I can't seem to find the answer to.
I've made it so that if a block is not given, the method will return an array of values in level order. This is my solution.
```ruby
elsif !block_given?
      popped = queue.pop
      queue.unshift(popped.left_child) unless popped.left_child.nil?
      queue.unshift(popped.right_child) unless popped.right_child.nil?
      result << popped.data
      level_order(queue, result, true, popped)
```
However, whenever I try to pass a block in, it says no block given. My attempt was to use the same code from above but replace `result << popped.data` with `yield(popped)`. I then call the method outside of the classes with `test.level_order{|popped| puts (popped.data + 1)}` but it keeps saying that I'm not yielding a block. I've tried using explicit blocks as well, but I can't seem to figure out what's going wrong. I have a feeling it has something to do with scope? Can someone point me in the right direction?
Here is a link to the repo! (lines 167-197)
https://github.com/BrentBarnes/binary_search_trees/blob/main/script.rb