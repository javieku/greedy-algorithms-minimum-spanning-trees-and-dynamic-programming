require 'singleton'

class Edge
  attr_reader :successor_name
  attr_reader :predecessor_name
  attr_reader :weight
  def initialize(predecessor_name, successor_name, weight)
    @predecessor_name = predecessor_name
    @successor_name = successor_name
    @weight = weight
  end
  def to_s
    "(N: " + @successor_name + " W: " + @weight.to_s + ")"
  end
end

class Node
    attr_reader :name
    attr_reader :successors
  
    def initialize(name)
      @name = name
      @successors = []
    end
  
    def add_edge(successor)
      @successors << successor
    end

    def remove_edge(name)
      @successors -= [name]
    end

    def n_of_edges
      @successors.length
    end

    def sample
      @successors.sample(1).first
    end

    def [](position)
      @successors[position]
    end

    def include?(name)
      @successors.include?(name)
    end

    def select_candidates(explored)
      return @successors.select {|item|
                  !explored.include?(item.successor_name)
             }
    end

    def to_s
      "#{@name} -> [#{@successors.join(' ')}]"
    end
end

class Graph
    attr_reader :nodes
    
    def initialize
      @nodes = {}
    end
  
    def add_node(node)
      @nodes[node.name] = node if !@nodes.include?(node.name)
    end

    def remove_node(node_name)
      @nodes.delete(node_name)
    end

    def add_edge(edge)
      @nodes[edge.predecessor_name].add_edge(edge)
    end
  
    def [](name)
      @nodes[name]
    end

    def empty?
      @nodes.length == 0
    end

    def n_of_nodes
      @nodes.length
    end

    def to_s
      "Graph"
    end
end

class PrimAlgorithm
  attr_accessor :mst_cost
  attr_accessor :mst
  def initialize
    @mst_cost = 0
    @mst = []
  end

  def execute graph, initial_node
    
    explored = [initial_node]
    while(explored.length != graph.nodes.size)
      # greedy criterion is mininum edge weight
      edge = select_minimun_edge(graph, explored)

      @mst_cost = @mst_cost + edge.weight
      @mst.push(edge)

      explored.push(edge.successor_name)
    end
  end

private
  def select_minimun_edge graph, explored
    candidates = []
    explored.each do |node|
      candidate = graph.nodes[node].select_candidates(explored)
      candidates.push(candidate) if (candidate != nil)    
    end

    candidates.flatten!
    
    return candidates.min_by do |edge|
       edge.weight
    end
  end
end

class GraphLoader
  include Singleton
  def read_graph
    graph = Graph.new
    File.open("edges.txt", "r") do |f|
        f.each_line do |line|
          edge = line.split(/\s/).reject(&:empty?)
          node_name = edge[0]
          other_node_name = edge[1]
          weigth = edge[2]
          graph.add_node(Node.new(node_name))
          graph.add_node(Node.new(other_node_name))
          graph.add_edge(Edge.new(node_name, other_node_name, weigth.to_f))
          graph.add_edge(Edge.new(other_node_name, node_name, weigth.to_f))
        end
      end
    return graph
  end
end

def main
  start = Time.now
  graph = GraphLoader.instance.read_graph
  puts "Graph loaded in memory " +  (Time.now - start).to_s
  start = Time.now
  puts "Starting Prim's algorithm"
  prim = PrimAlgorithm.new
  initial_node = "1"
  prim.execute(graph, initial_node) 
  puts "Prim's took " +  (Time.now - start).to_s
  puts "Prim's result from #{initial_node} to"
  puts prim.mst_cost
  puts prim.mst
end

main