class StatementCreateFacebookImageWorker
  include Sidekiq::Worker
  include ImagesHelper

  def perform(hashid, content)
    logger.debug "\n\n------- StatementCreateFacebookImageWorker: perform start -------\n\n"

    filepath = "#{Rails.root.join('tmp')}/#{hashid}_facebook.png"

    convert = MiniMagick::Tool::Convert.new
    convert << '-page'
    convert << '0x0'
    convert << 'app/assets/images/weagreethat_facebook.png'
    convert << '-page'
    convert << '+18+15'
    convert << '-size'
    convert << '1200x630'
    convert << '-font'
    convert << "#{font}"
    convert << "caption:#{image_statement(content)}"
    convert << '-layers'
    convert << 'mosaic'
    convert << filepath
    convert.call

    # send it to Google
    Statement.find(hashid).image_facebook.attach(io: File.open(filepath), filename: "#{hashid}_facebook.png")

    # and delete the local copy
    File.delete(filepath) if File.exist?(filepath)

    logger.debug "\n\n------- StatementCreateFacebookImageWorker: perform start -------\n\n"
  end
end
