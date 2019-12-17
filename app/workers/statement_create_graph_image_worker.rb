class StatementCreateGraphImageWorker
  include Sidekiq::Worker
  # include ImagesHelper

  require 'ruby-graphviz'

  def perform(hashid)
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} START ------\n").green

    @statement = Statement.find_by_hashid(hashid)

    File.open("#{Rails.root.join('tmp')}/#{hashid}_graph.dot", "w") { |f| f.write(
      @statement.root? ? @statement.to_dot_digraph : @statement.root.to_dot_digraph
      ) }

    GraphViz.parse( "#{Rails.root.join('tmp')}/#{hashid}_graph.dot", :path => "/usr/local/bin" ).output(:png => "#{Rails.root.join('tmp')}/#{hashid}_image_graph.png")

    Statement.find(hashid).graph.attach(io: File.open("#{Rails.root.join('tmp')}/#{hashid}_graph.dot"), filename: "#{hashid}_graph.dot")
    Statement.find(hashid).image_graph.attach(io: File.open("#{Rails.root.join('tmp')}/#{hashid}_image_graph.png"), filename: "#{hashid}_image_graph.png")

    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} STOP ------\n").indianred
  end
end
