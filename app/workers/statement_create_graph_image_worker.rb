class StatementCreateGraphImageWorker
  include Sidekiq::Worker
  # include ImagesHelper

  require 'ruby-graphviz'

  def perform(hashid)
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} START ------\n").green

    @statement = Statement.find_by_hashid(hashid)

    graph_filepath = "#{Rails.root.join('tmp')}/#{hashid}_graph.dot"
    image_filepath = "#{Rails.root.join('tmp')}/#{hashid}_image_graph.png"

    # create the dot file
    File.open(graph_filepath, "w") { |f| f.write(
      @statement.root? ? @statement.to_dot_digraph : @statement.root.to_dot_digraph
      ) }

      # create the image file
    GraphViz.parse( graph_filepath, :path => "/usr/local/bin" ).output(:png => image_filepath)

    # send dot file to Google and delete
    Statement.find(hashid).graph.attach(io: File.open(graph_filepath), filename: "#{hashid}_graph.dot")
    File.delete(graph_filepath) if File.exist?(graph_filepath)

    # send image to Google and delete
    Statement.find(hashid).image_graph.attach(io: File.open(image_filepath), filename: "#{hashid}_image_graph.png")
    File.delete(image_filepath) if File.exist?(image_filepath)

    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} STOP ------\n").indianred
  end
end
