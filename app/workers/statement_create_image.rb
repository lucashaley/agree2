require 'sidekiq'

class StatementCreateImage
  include Sidekiq::Worker
  # sidekiq_options retry:false

  # create image from statement text
  def perform(hashid, content)
    logger.debug "\n\n------- StatementWorker: perform start -------\n\n"
    logger.debug "#{content}\n\n"


    text_statement = "I agree that " + content.gsub("'", %q(\\\'))
    convert = MiniMagick::Tool::Convert.new
    # convert << "\("
    # convert << "app/assets/images/weagreethat.png"
    # convert << "-size"
    # convert << "900x880"
    # convert << "-extent"
    # convert << "900x880"
    # convert << "-font"
    # convert << "helvetica"
    # convert << "-weight"
    # convert << "900"
    # convert.gravity ("NorthWest")
    # convert << "caption:" + text_statement
    # convert << "-composite"
    # convert << "\)"
    # convert << "app/assets/images/weagreethat_text.png"
    # convert.gravity ("Center")
    # convert << "-composite"
    # convert << "public/assets/images/" + statement.hashid + ".png"

    # new version
    convert << '-page'
    convert << '0x0'
    convert << 'app/assets/images/weagreethat.png'
    convert << '-page'
    convert << '+12+10'
    convert << '-size'
    convert << '888x870'
    convert << '-font'
    convert << 'Nimbus-Sans-L-Bold'
    convert << "caption:#{text_statement}."
    convert << '-layers'
    convert << 'mosaic'
    convert << "#{Rails.root.join('tmp')}/#{hashid}.png"

    Rails.logger.debug convert.command
    convert.call #=> `convert input.jpg -resize 100x100 -negate output.jpg`

    # https://guides.rubyonrails.org/v5.2.0/active_storage_overview.html
    # statement.statement_image.attach("public/assets/images/" + statement.hashid + ".png")
    # https://blog.capsens.eu/how-to-use-activestorage-in-your-rails-5-2-application-cdf3a3ad8d7
    Statement.find(hashid).statement_image.attach(io: File.open("#{Rails.root.join('tmp')}/#{hashid}.png"), filename: "#{hashid}.png")
  end
end
