array = [1,7,4,23,8,9,4,3,5,7,9,67,6345,324]

module Comparable

  def compare_one(root, data)
    return root if data == root
    return if root.nil?

    if data < root.data
      false
    elsif
      data > root.data
      true
    end
  end

  def recursive_compare(root, value, parent=false)
    return root if value == root.data
    # return if root.nil?

    # puts "Root: #{root.data}"
    if !root.left_child.nil? then puts "Left child: #{root.left_child.data}" end
    if !root.right_child.nil? then puts "Right child: #{root.right_child.data}" end

    if !root.left_child.nil? && root.left_child.data == value && parent ||
      !root.right_child.nil? && root.right_child.data == value && parent
        
      root
    elsif value < root.data
      return root if root.left_child.nil?
      # p "Root: #{root.data}"
      root = root.left_child
      root = recursive_compare(root, value, parent)
      root
    elsif value > root.data
      return root if root.right_child.nil?
      # p "Root: #{root.data}"
      root = root.right_child
      root = recursive_compare(root, value, parent)
      root
    end
  end
end

class Node
  include Comparable
  attr_accessor :data, :left_child, :right_child

  def initialize(data, left_child = nil, right_child = nil)
    @data = data
    @left_child = nil
    @right_child = nil
  end
end

class Tree
  include Comparable
  attr_accessor :array, :root

  def initialize(array)
    @array = array
    @root = build_tree(array, 0, array.uniq.length - 1)
  end

  def build_tree(array, start, last)
    array = array.sort.uniq
    return if start > last

    mid = (start + last)/2
    root = Node.new(array[mid])

    root.left_child = build_tree(array, start, mid-1)
    root.right_child = build_tree(array, mid+1, last)

    return root
  end

  def insert(array, new_data) 
    leaf = recursive_compare(root, new_data)
    p leaf.data
    greater_than_leaf = compare_one(leaf, new_data)

    if greater_than_leaf
      leaf.right_child = Node.new(new_data)
    elsif !greater_than_leaf
      leaf.left_child = Node.new(new_data)
    end
  end

  def find(value)
    closest_node = recursive_compare(root, value)
    # puts "Found Node: #{closest_node.data}"
    return puts 'Node does not exist' if closest_node.data != value

      closest_node
  end

  def find_parent(value)
    parent = recursive_compare(root, value, true)

    if parent.data == value
      nil
    else
      parent
    end
  end

  def find_next_largest_node(node)
    next_largest_node = node.right_child
    until next_largest_node.left_child.nil?
      next_largest_node = next_largest_node.left_child
    end
    puts "Next largest node is: #{next_largest_node.data}"
    next_largest_node
  end

  def delete(value)
    node = find(value)
    puts "Node: #{node.data}"
    parent = find_parent(value)
    # puts "Parent: #{parent.data}"
    left_or_right = compare_one(parent, node.data)
    children = 0
    if !node.left_child.nil? then children += 1 end
    if !node.right_child.nil? then children += 1 end

    if children == 0
      if compare_one(parent, node.data) 
        parent.right_child = nil
      else 
        parent.left_child = nil
      end
    end
    
    if children == 1 && !left_or_right
      if !node.left_child.nil?
        parent.left_child = node.left_child
      elsif !node.right_child.nil?
        parent.left_child = node.right_child
      end
    elsif children == 1 && left_or_right
      if !node.left_child.nil?
        parent.right_child = node.left_child
      elsif !node.right_child.nil?
        parent.right_child = node.right_child
      end
    end

    if children == 2
    replacement_node = find_next_largest_node(node)
    delete(replacement_node.data)
    replacement_node.left_child = node.left_child
    replacement_node.right_child = node.right_child
    node.left_child = nil
    node.right_child = nil

      if parent.nil?
        @root = replacement_node
      elsif !left_or_right
        parent.left_child = replacement_node
      elsif left_or_right
        parent.right_child = replacement_node
      end
    end
  end

  def level_order(queue=[], result =[], started=false, popped=root)
    # queue = queue
    show_queue = []
    # result = result
    queue.each {|item| show_queue << item.data}
    puts "Show Queue: #{show_queue}"
    puts "Popped: #{popped.data}"

    if queue.empty? && started
      # && popped.left_child.nil? && popped.right_child.nil?
      puts "Basecase hit"
      return
    elsif !started
      queue << popped
      level_order(queue, result, true)
    elsif !block_given?
      popped = queue.pop
      queue.unshift(popped.left_child) unless popped.left_child.nil?
      queue.unshift(popped.right_child) unless popped.right_child.nil?
      result << popped.data
      level_order(queue, result, true, popped)
    elsif block_given?
      popped = queue.pop
      queue.unshift(popped.left_child) unless popped.left_child.nil?
      queue.unshift(popped.right_child) unless popped.right_child.nil?
      result << yield(popped)
      level_order(queue, result, true, popped)

    end
    result
  end
end

test = Tree.new(array)

p test.level_order {|popped| puts popped.data}



