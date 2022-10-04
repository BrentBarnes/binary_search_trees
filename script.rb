array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

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

    if !root.left.nil? && root.left.data == value && parent ||
      !root.right.nil? && root.right.data == value && parent
        
      root
    elsif value < root.data
      return root if root.left.nil?
      root = root.left
      root = recursive_compare(root, value, parent)
      root
    elsif value > root.data
      return root if root.right.nil?
      root = root.right
      root = recursive_compare(root, value, parent)
      root
    end
  end
end

class Node
  include Comparable
  attr_accessor :data, :left, :right

  def initialize(data)
    @data = data
    @left = nil
    @right = nil
  end
end

class Tree
  include Comparable
  attr_accessor :array, :root

  def initialize(array)
    @array = array.sort.uniq
    @root = build_tree(array, 0, array.uniq.length - 1)
  end

  def build_tree(array, start, last)
    return if start > last

    mid = (start + last)/2
    root = Node.new(array[mid])

    root.left = build_tree(array, start, mid-1)
    root.right = build_tree(array, mid+1, last)

    return root
  end

  def insert(value, node=root) 
    return nil if value == node.data

    if value < node.data
      node.left.nil? ? node.left = Node.new(value) : insert(value, node.left)
    else
      node.right.nil? ? node.right = Node.new(value) : insert(value,node.right)
    end
  end

  def find(value)
    return node if node.nil? || node.data == value

    value < node.data ? find(value, node.left) : find(value, node.right)
  end

  def find?(value, node=root)
    return false if node.nil?
    return true if node.data == value

    value < node.data ? find?(value, node.left) : find?(value, node.right)
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
    next_largest_node = node.right
    next_largest_node = next_largest_node.left until next_largest_node.left.nil?

    next_largest_node
  end

  def delete(value, node=root)
    return node if node.nil?

    if value < node.data
      node.left = delete(value, node.left)
      puts "Left delete until: #{node.data}"
    elsif value > node.data
      node.right = delete(value, node.right)
      puts "Right delete until: #{node.data}"
    else
      # if node has one or no child
      # delete is called recursively until node.left or node.right == nil
      # this deletes the pointer to that node, thus deleting the node
      return node.right if node.left.nil?
      return node.left if node.right.nil?

      # if node has two children
      next_largest_node = find_next_largest_node(node)
      puts "Next largest node: #{next_largest_node}"
      node.data = next_largest_node.data
      node.right = delete(next_largest_node.data, node.right)
    end
    p "Node: #{node.data}"
    node
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
      queue.unshift(popped.left) unless popped.left.nil?
      queue.unshift(popped.right) unless popped.right.nil?
      result << popped.data
      level_order(queue, result, true, popped, &block)
    elsif block_given?
      popped = queue.pop
      queue.unshift(popped.left) unless popped.left.nil?
      queue.unshift(popped.right) unless popped.right.nil?
      result << block.call(popped)
      level_order(queue, result, true, popped, &block)
    end
    result
  end

  def preorder(value=root.data, result=[], &block)
    node = find(value)

    if !block_given?
      result << node.data
      preorder(node.left.data, result) unless node.left.nil?
      preorder(node.right.data, result) unless node.right.nil?
    elsif block_given?
      result << block.call(node)
      preorder(node.left.data, result) unless node.left.nil?
      preorder(node.right.data, result) unless node.right.nil?
    end
    result
  end

  def inorder(value=root.data, result=[], &block)
    node = find(value)


    if !block_given?
      inorder(node.left.data, result) unless node.left.nil?
      result << node.data
      inorder(node.right.data, result) unless node.right.nil?
    elsif block_given?
      inorder(node.left.data, result, &block) unless node.left.nil?
      result << block.call(node)
      inorder(node.right.data, result, &block) unless node.right.nil?
    end
    return result
  end

  def postorder(value=root.data, result=[], &block)
    node = find(value)


    if !block_given?
      postorder(node.left.data, result) unless node.left.nil?
      postorder(node.right.data, result) unless node.right.nil?
      result << node.data
    elsif block_given?
      postorder(node.left.data, result, &block) unless node.left.nil?
      postorder(node.right.data, result, &block) unless node.right.nil?
      result << block.call(node)
    end
    result
  end

  def height(value, counter=-1, hash={}, leafs=[])
    node = find(value)
    counter += 1
    hash[counter] = node.data

    if node.left.nil? && node.right.nil?
      leafs << hash.max_by{|k, v| k}[0]
    end
      height(node.left.data, counter, hash, leafs) unless node.left.nil?
      height(node.right.data, counter, hash, leafs) unless node.right.nil?
      hash.delete(counter)
      leafs.max
  end

  def depth(value, base=root, counter=0)
    return counter if value == base.data
    return if !find(value)

    if value < base.data
      return base if base.left.nil?
      base = base.left
      counter += 1
      base = depth(value, base, counter)
    elsif value > base.data
      return base if base.right.nil?
      base = base.right
      counter += 1
      base = depth(value, base, counter)
    end
  end

  def balanced?(node=root, counter=0, hash={}, leafs=[])
    counter += 1
    hash[counter] = node.data

    if node.left.nil? && node.right.nil?
      leafs << hash.max_by{|k, v| k}[0]
    end
    height(node.left.data, counter, hash, leafs) unless node.left.nil?
    height(node.right.data, counter, hash, leafs) unless node.right.nil?
    hash.delete(counter)

    if (leafs.max - leafs.min) <= 1 then true else false end
  end

  def rebalance
    @array = inorder(root.data)
    @root = @root = build_tree(array, 0, array.uniq.length - 1)
    return
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end
end

test = Tree.new(array)

p test.pretty_print
p test.delete(4)
p test.pretty_print


