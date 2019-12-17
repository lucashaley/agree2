class StatementCreateGraphImageWorker
  include Sidekiq::Worker
  # include ImagesHelper

  def perform(hashid)
    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} START ------\n").green

    @statement = Statement.find_by_hashid(hashid)

    File.open("source/graphs/#{@statement.hashid}.dot", "w") { |f| f.write(
      @statement.root? ? @statement.to_dot_digraph : @statement.root.to_dot_digraph
      ) }

    Rails.logger.debug Rainbow("\n\n-- #{self.class}:#{(__method__)} STOP ------\n").indianred
  end
end
