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

class Cluster
    attr_reader :nodes
    def initialize(nodes)
      @nodes = nodes 
    end
    def add_node(node)
      @nodes[node.name] = node
    end
    def min_edge
        edges = []
        @nodes.each do |key,node|
            edges = edges + node.successors.select {|edge|
                !@nodes.include?(edge.successor_name)   
            }
        end

        edges.min_by do |edge|
            edge.weight
        end
    end

    def include?(name)
        @nodes.include?(name)
    end

    def merge(cluster)
        Cluster.new(@nodes.merge(cluster.nodes))
    end
    def to_s
      "(Cluster:  #{@nodes} )"
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

class ClusteringAlgorithm
  attr_accessor :maximum_spacing
  def initialize
    @maximum_spacing = -1
  end
  def execute(graph,target_size)
    
    clusters = []

    graph.nodes.each do |key,node|
        cluster = Cluster.new({})
        cluster.add_node(node)
        clusters.push(cluster)
    end

    while(clusters.size > target_size)
      edge = min_edge(clusters)

      # find the two clusters that edge belongs 
      one_cluster = find_cluster(clusters, edge.successor_name)
      another_cluster = find_cluster(clusters, edge.predecessor_name)
      clusters.delete(one_cluster)
      clusters.delete(another_cluster)

      # merge clusters
      clusters.push(one_cluster.merge(another_cluster))
    end

    @maximum_spacing = min_edge(clusters).weight
  end

private
  def min_edge clusters
    candidates = []
    clusters.each do |cluster|
      candidate = cluster.min_edge()
      candidates.push(candidate) if (candidate != nil)    
    end
    return candidates.min_by do |edge|
       edge.weight
    end
  end

  def find_cluster(clusters, node_name)
    clusters.each do |cluster|
      return cluster if cluster.include?(node_name)
    end
    return nil
  end
end

class GraphLoader
  include Singleton
  def read_graph
    graph = Graph.new
    File.open("clustering_basic.txt", "r") do |f|
        f.each_line do |line|
          edge = line.split(/\s/).reject(&:empty?)
          if edge.size < 2
            next
          end
          node_name = edge[0]
          other_node_name = edge[1]
          weigth = edge[2]
          graph.add_node(Node.new(node_name))
          graph.add_node(Node.new(other_node_name))
          graph.add_edge(Edge.new(node_name, other_node_name, weigth.to_f))
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
  puts "Starting clustering algorithm"
  clustering = ClusteringAlgorithm.new
  number_of_clusters = 4
  clustering.execute(graph, number_of_clusters) 
  puts "Clustering took " +  (Time.now - start).to_s
  puts "Clustering result for #{number_of_clusters}"
  puts clustering.maximum_spacing
end

main