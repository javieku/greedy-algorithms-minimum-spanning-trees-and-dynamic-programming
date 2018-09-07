require 'singleton'

class Node
    attr_accessor :left
    attr_accessor :right
    attr_accessor :data
    def initialize(data, left = nil, right = nil)
        @left = left
        @right = right
        @data = data
    end
end

class HuffmanTree
    attr_accessor :root
    def initialize()
        @root = nil
    end

    def find letters
        find_impl(root,letters)
    end

    def max_code_length 
        max_height_impl(root) - 1
    end
    def min_code_length 
        min_height_impl(root) - 1
    end
private
    def find_impl(node, value)

        if(node == nil)
            return nil
        end

        if (node.data == value)
            return node
        end

        result = find_impl(node.left,value);
        return result if (result != nil)
        result = find_impl(node.right,value)
        return result 
    end

    def max_height_impl node
        if(node == nil)
            return 0
        end
        return [max_height_impl(node.left),max_height_impl(node.right)].max + 1
    end
    def min_height_impl node
        if(node == nil)
            return 0
        end
        return [min_height_impl(node.left),min_height_impl(node.right)].min + 1
    end
end

class HuffmanCodingAlgorithm
    attr_accessor :ht
    def initialize
      @ht = HuffmanTree.new()
    end
    def execute(alphabet)
        @ht = impl(alphabet)
    end
private
    def impl(alphabet)
        if(alphabet.length == 2)
            ht = HuffmanTree.new()
            a = alphabet.to_a[0]
            b = alphabet.to_a[1]        
            ht.root = Node.new("root",Node.new(b.first),Node.new(a.first))
            return ht
        end

        a = alphabet.min_by { |key, value| value }
        alphabet.delete(a.first)
        b = alphabet.min_by { |key, value| value }
        alphabet.delete(b.first)

        alphabet[a.first + "," +b.first] = a[1] + b[1];

        ht = impl(alphabet)

        parent = ht.find(a.first + "," + b.first)
        parent.left = Node.new(a.first)  
        parent.right = Node.new(b.first)

        return ht
    end
 end

class Loader
    include Singleton
    def read_input
      weights = {}
      File.open("huffman.txt", "r") do |f|
          f.each_with_index do |line,index|
            next if index == 0
            weights[index.to_s] = line.to_i
          end
      end
      return weights
    end
end

def main 
    alphabet = Loader.instance.read_input
    algorithm = HuffmanCodingAlgorithm.new
    algorithm.execute(alphabet)
    puts "Max code length: " + algorithm.ht.max_code_length.to_s
    puts "Max code length: " + algorithm.ht.min_code_length.to_s
end

main