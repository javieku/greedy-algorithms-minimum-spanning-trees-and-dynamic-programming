require 'singleton'
require 'set'

def h2(a, b)
  (a^b).to_s(2).count("1")
end

class UnionFind
  def initialize(n)
      @leaders = 1.upto(n).inject([]) { |leaders, i| leaders[i] = i; leaders }
  end

  def connected?(id1,id2)
      @leaders[id1] == @leaders[id2]
  end

  def union(id1,id2)
      leader_1, leader_2 = @leaders[id1], @leaders[id2]
      @leaders.map! {|i| (i == leader_1) ? leader_2 : i }
  end

  def components
    @leaders.group_by{|e| e}.map{|k, v| [k, v.length]}.delete_if { |k, v| k.nil? }
  end

  def component(id)
    @leaders[id]
  end
end

def permute_impl(arr, pos, distance, alphabet)
   if (pos == arr.length)
    return [arr.join("")]
   end
   result = []
   # distance > 0 means we can change the current character,
   #   so go through the candidates
   if (distance > 0)
      temp = arr[pos]
      alphabet.each do |character|
        arr[pos] = character
        distanceOffset = 0
         # different character, thus decrement distance
         if (temp != arr[pos])
            distanceOffset = -1
            result += permute_impl(arr, pos+1, distance + distanceOffset, alphabet)
         end
        arr[pos] = temp
        end
   # otherwise just stick to the same character
   else 
    result += permute_impl(arr, pos+1, distance, alphabet)
   end
   return result
end

def permute(string, distance)
  result = []
  (0..string.length-1).each do |i|
    result += permute_impl(string.split(""),i,distance,"01".split(""))
  end
  return result;
end

def mutate(code)
  codes = Set.new 
  codes += permute(code,0)
  codes += permute(code,1)
  codes += permute(code,2)
  return codes.to_a;
end

def load_nodes(file_name)
  nodes = {}
  File.open(file_name, "r") do |f|
    id = 1
    f.each_line do |line|
      node_code = line.split(/\s/).reject(&:empty?)
      if node_code.length < 3
        next
      end
      nodes[line.strip().delete(' ')] = id;
      id += 1
    end
  end
  return nodes
end

def main
  start = Time.now
  #file_name = "clustering_with_hd_test_cases/dummy_5_sol_2.txt"
  file_name = "clustering_big.txt"
  nodes = load_nodes(file_name)
  puts "Nodes loaded in memory " +  (Time.now - start).to_s

  start = Time.now
  set = UnionFind.new nodes.length
  nodes.each do |code, id|
    codes = mutate(code)
    codes = codes.select { |mutated_code|  nodes.include?(mutated_code)  }
    codes.each do |valid_code|
      other_id = nodes[valid_code]
      if !set.connected?(id,other_id)
        set.union(id, other_id)
      end
    end
  end
  puts "Algorithm executed in " +  (Time.now - start).to_s
  puts "clusters -> #{set.components}"
  puts "Number of clusters -> #{set.components.size}"

end

main