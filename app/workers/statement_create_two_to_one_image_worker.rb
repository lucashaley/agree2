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
    convert << "caption:#{image_statement(content)}."
    convert << '-layers'
    convert << 'mosaic'
    convert << "#{Rails.root.join('tmp')}/#{hashid}.png"
    convert.call

    Statement.find(hashid).image_twotoone.attach(io: File.open("#{Rails.root.join('tmp')}/#{hashid}.png"), filename: "#{hashid}_twotoone.png")

    logger.debug "\n\n------- StatementCreateTwoToOneImageWorker: perform start -------\n\n"
  end
end
