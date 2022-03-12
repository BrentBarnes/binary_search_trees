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

  def recursive_compare(root, data)
    return root if data == root.data
    # return if root.nil?

    if data < root.data
      return root if root.left_child.nil?
      p "Root: #{root.data}"
      root = root.left_child
      root = recursive_compare(root, data)
      root
    elsif data > root.data
      return root if root.right_child.nil?
      p "Root: #{root.data}"
      root = root.right_child
      root = recursive_compare(root, data)
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
    closest_node = recursive_compare(root, value).data
    return puts 'Node does not exist' if closest_node != value

      closest_node
  end

end

test = Tree.new(array)

p test.insert(array, 2)
p test.find(2)

