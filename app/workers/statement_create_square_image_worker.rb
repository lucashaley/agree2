class StatementCreateSquareImageWorker
  include Sidekiq::Worker
  include ImagesHelper

  def perform(hashid, content)
    logger.debug "\n\n------- StatementCreateSquareImageWorker: perform start -------\n\n"

    filepath = "#{Rails.root.join('tmp')}/#{hashid}_square.png"

    convert = MiniMagick::Tool::Convert.new
    convert << '-page'
    convert << '0x0'
    convert << 'app/assets/images/weagreethat_square.png'
    convert << '-page'
    convert << '+12+10'
    convert << '-size'
    convert << '880x880'
    convert << '-font'
    convert << "#{font}"
    convert << "caption:#{image_statement(content)}"
    convert << '-layers'
    convert << 'mosaic'
    # convert << "#{Rails.root.join('tmp')}/#{hashid}_square.png"
    convert << filepath
    convert.call

    # send it to Google
    # Statement.find(hashid).image_square.attach(io: File.open("#{Rails.root.join('tmp')}/#{hashid}_square.png"), filename: "#{hashid}_square.png")
    Statement.find(hashid).image_square.attach(io: File.open(filepath), filename: "#{hashid}_square.png")

    # and delete the local copy
    File.delete(filepath) if File.exist?(filepath)

    logger.debug "\n\n------- StatementCreateSquareImageWorker: perform start -------\n\n"
  end
end
