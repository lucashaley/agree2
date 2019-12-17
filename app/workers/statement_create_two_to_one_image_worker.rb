class StatementCreateTwoToOneImageWorker
  include Sidekiq::Worker
  include ImagesHelper

  def perform(hashid, content)
    logger.debug "\n\n------- StatementCreateTwoToOneImageWorker: perform start -------\n\n"

    filepath = "#{Rails.root.join('tmp')}/#{hashid}_2to1.png"

    convert = MiniMagick::Tool::Convert.new
    convert << '-page'
    convert << '0x0'
    convert << 'app/assets/images/weagreethat_twotoone.png'
    convert << '-page'
    convert << '+12+10'
    convert << '-size'
    convert << '880x440'
    convert << '-font'
    convert << "#{font}"
    convert << "caption:#{image_statement(content)}"
    convert << '-layers'
    convert << 'mosaic'
    convert << filepath
    convert.call

    # send it to Google
    Statement.find(hashid).image_2to1.attach(io: File.open(filepath), filename: "#{hashid}_2to1.png")

    # and delete the local copy
    File.delete(filepath) if File.exist?(filepath)

    logger.debug "\n\n------- StatementCreateTwoToOneImageWorker: perform start -------\n\n"
  end
end
