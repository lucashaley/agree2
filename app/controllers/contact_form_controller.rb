class ContactFormController < ApplicationController
  def index
    @contact = ContactForm.new(params[:contact_form])
  end

  def create
    @contact = ContactForm.new(params[:contact_form])
    @contact.request = request
    respond_to do |format|
      if @contact.deliver
        # re-initialize Home object for cleared form
        @contact = ContactForm.new
        format.html { render 'index'}
        format.js   { flash.now[:success] = @message = "Thank you for your message. I'll get back to you soon!" }
      else
        format.html { render 'index' }
        format.js   { flash.now[:error] = @message = "Message did not send." }
      end
    end
  end
end
