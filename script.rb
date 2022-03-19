array = (Array.new(15) {rand(1..100)})

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

    if !root.left_child.nil? && root.left_child.data == value && parent ||
      !root.right_child.nil? && root.right_child.data == value && parent
        
      root
    elsif value < root.data
      return root if root.left_child.nil?
      root = root.left_child
      root = recursive_compare(root, value, parent)
      root
    elsif value > root.data
      return root if root.right_child.nil?
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

  def insert(new_data) 
    leaf = recursive_compare(root, new_data)
    greater_than_leaf = compare_one(leaf, new_data)

    if greater_than_leaf
      leaf.right_child = Node.new(new_data)
    elsif !greater_than_leaf
      leaf.left_child = Node.new(new_data)
    end
  end

  def find(value)
    closest_node = recursive_compare(root, value)
    return puts 'Node does not exist' if closest_node.data != value

      closest_node
  end

  def find?(value)
    closest_node = recursive_compare(root, value)
    if closest_node.data != value then false else true end
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
    parent = find_parent(value)
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

  def level_order(queue=[], result =[], started=false, popped=root, &block)
    show_queue = []

    if queue.empty? && started
      puts "Basecase hit"
      return
    elsif !started
      queue << popped
      level_order(queue, result, true, &block)
    elsif !block_given?
      popped = queue.pop
      queue.unshift(popped.left_child) unless popped.left_child.nil?
      queue.unshift(popped.right_child) unless popped.right_child.nil?
      result << popped.data
      level_order(queue, result, true, popped, &block)
    elsif block_given?
      popped = queue.pop
      queue.unshift(popped.left_child) unless popped.left_child.nil?
      queue.unshift(popped.right_child) unless popped.right_child.nil?
      result << block.call(popped)
      level_order(queue, result, true, popped, &block)
    end
    result
  end

  def preorder(value=root.data, result=[], &block)
    node = find(value)

    if !block_given?
      result << node.data
      preorder(node.left_child.data, result) unless node.left_child.nil?
      preorder(node.right_child.data, result) unless node.right_child.nil?
    elsif block_given?
      result << block.call(node)
      preorder(node.left_child.data, result) unless node.left_child.nil?
      preorder(node.right_child.data, result) unless node.right_child.nil?
    end
    result
  end

  def inorder(value=root.data, result=[], &block)
    node = find(value)


    if !block_given?
      inorder(node.left_child.data, result) unless node.left_child.nil?
      result << node.data
      inorder(node.right_child.data, result) unless node.right_child.nil?
    elsif block_given?
      inorder(node.left_child.data, result, &block) unless node.left_child.nil?
      result << block.call(node)
      inorder(node.right_child.data, result, &block) unless node.right_child.nil?
    end
    return result
  end

  def postorder(value=root.data, result=[], &block)
    node = find(value)


    if !block_given?
      postorder(node.left_child.data, result) unless node.left_child.nil?
      postorder(node.right_child.data, result) unless node.right_child.nil?
      result << node.data
    elsif block_given?
      postorder(node.left_child.data, result, &block) unless node.left_child.nil?
      postorder(node.right_child.data, result, &block) unless node.right_child.nil?
      result << block.call(node)
    end
    result
  end

  def height(value, counter=-1, hash={}, leafs=[])
    node = find(value)
    counter += 1
    hash[counter] = node.data

    if node.left_child.nil? && node.right_child.nil?
      leafs << hash.max_by{|k, v| k}[0]
    end
      height(node.left_child.data, counter, hash, leafs) unless node.left_child.nil?
      height(node.right_child.data, counter, hash, leafs) unless node.right_child.nil?
      hash.delete(counter)
      leafs.max
  end

  def depth(value, base=root, counter=0)
    return counter if value == base.data
    return if !find(value)

    if value < base.data
      return base if base.left_child.nil?
      base = base.left_child
      counter += 1
      base = depth(value, base, counter)
    elsif value > base.data
      return base if base.right_child.nil?
      base = base.right_child
      counter += 1
      base = depth(value, base, counter)
    end
  end

  def balanced?(node=root, counter=0, hash={}, leafs=[])
    counter += 1
    hash[counter] = node.data

    if node.left_child.nil? && node.right_child.nil?
      leafs << hash.max_by{|k, v| k}[0]
    end
    height(node.left_child.data, counter, hash, leafs) unless node.left_child.nil?
    height(node.right_child.data, counter, hash, leafs) unless node.right_child.nil?
    hash.delete(counter)

    if (leafs.max - leafs.min) <= 1 then true else false end
  end

  def rebalance
    @array = inorder(root.data)
    @root = @root = build_tree(array, 0, array.uniq.length - 1)
    return
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right_child, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right_child
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left_child, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left_child
  end
end

test = Tree.new(array)

puts "Random array:"
p test.array
p test.pretty_print
puts "Is the tree balanced?"
p test.balanced?
puts "Pre, in, and post order"
p test.preorder
p test.inorder
p test.postorder
test.insert(150)
test.insert(200)
test.insert(250)
test.insert(300)
p test.pretty_print
puts "Is the tree balanced?"
p test.balanced?
p test.rebalance
puts "Is the tree balanced?"
p test.balanced?
p test.pretty_print
puts "Pre, in, and post order"
p test.preorder
p test.inorder
p test.postorder


