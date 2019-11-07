class StatementCreateTwoToOneImageWorker
  include Sidekiq::Worker
  include ImagesHelper

  def perform(hashid, content)
    logger.debug "\n\n------- StatementCreateTwoToOneImageWorker: perform start -------\n\n"

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
    convert << "#{Rails.root.join('tmp')}/#{hashid}_2to1.png"
    convert.call

    Statement.find(hashid).image_2to1.attach(io: File.open("#{Rails.root.join('tmp')}/#{hashid}_2to1.png"), filename: "#{hashid}_2to1.png")

    logger.debug "\n\n------- StatementCreateTwoToOneImageWorker: perform start -------\n\n"
  end
end
