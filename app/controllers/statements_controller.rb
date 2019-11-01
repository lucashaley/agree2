# frozen_string_literal: true

class StatementsController < ApplicationController
  require "mini_magick"

  before_action :set_statement, only: [:show, :edit, :update, :destroy, :agree, :disagree, :toggle_agree]
  before_action :set_parent, only: [:show, :update, :create]
  before_action :set_parent_for_new, only: [:create_child]
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_homepage

  def agree
    Rails.logger.debug '-------------'
    Rails.logger.debug 'AGREE'
    Rails.logger.debug '-------------'
    Rails.logger.debug '-------------'
    Rails.logger.debug current_user
    Rails.logger.debug '-------------'
    begin
      current_user.vote_for(@statement)
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        format.js {}
      end
      # render :nothing => true, :status => 200
    rescue ActiveRecord::RecordInvalid
      render :nothing => true, :status => 404
    rescue ActiveRecord::RecordNotFound
      render :nothing => true, :status => 404
    end
  end

  def disagree
    begin
      current_user.unvote_for(@statement)
      respond_to do |format|
        format.html { redirect_to :back }
        format.js {}
      end
    rescue ActiveRecord::RecordInvalid
      render :nothing => true, :status => 404
    end
  end

  def toggle_agree
    begin
      if current_user.voted_for?(@statement)
        current_user.unvote_for(@statement)
      else
        current_user.vote_for(@statement)
      end
      respond_to do |format|
        format.html { redirect_to :back }
        format.js {}
      end
      # render :nothing => true, :status => 200
    rescue ActiveRecord::RecordInvalid
      render :nothing => true, :status => 404
    rescue ActiveRecord::RecordNotFound
      render :nothing => true, :status => 404
    end
  end

  def home
    @agreed = false
    # create a temporary child in case they want to make a variant
    @new = Statement.new
    # @child.parent_id = 1
    # get the first one
    @statement = Statement.find(1)
    @top_ten = Statement.tally({
                                 :at_least => 1,
                                 :limit => 10,
                                 :order => 'vote_count desc'
                               })
    if current_user
      @agreed = current_user.voted_for?(@statement)
      Rails.logger.debug '-------------'
      Rails.logger.debug "VOTED: #{@agreed}"
      Rails.logger.debug '-------------'
    end
  end

  # GET /statements
  # GET /statements.json
  def index
    @statements = Statement.all
    # @top_ten = Statement.tally.order(:votes_for)
    @tags = Statement.tag_counts_on(:tags)
    @top_ten = Statement.tally({
                                 :at_least => 1,
                                 :limit => 10,
                                 :order => 'vote_count desc'
                               })
    @most_recent = Statement.order('created_at desc').limit(10)
  end

  # GET /statements/1
  # GET /statements/1.json
  def show
    # ! check for format here
    respond_to do |format|
      format.html {
        @reports = @statement.reports

        if @parent
          @diff = Diffy::Diff.new(@parent.content, @statement.content).to_s(:html).html_safe
          @diff_left = Diffy::SplitDiff.new(@parent.content, @statement.content, :format => :html).left.html_safe
          @diff_right = Diffy::SplitDiff.new(@parent.content, @statement.content, :format => :html).right.html_safe
        end

        # create a temporary child in case they want to make a variant
        @child = Statement.new
        @child.tag_list = @statement.tag_list
        @child.author = current_user
        @child.parent = @statement

        # get the agreement of the current user for this statement
        @agreed = false
        if current_user
          @agreed = current_user.voted_for?(@statement)
        end

        # set the agree button css.
        # ? is there a better way of doing this in the presentation layer?
        @css_string = 'btn btn-success btn-lg'
        if @agreed
          @css_string += ' active'
        end

        # test refactor
        # parse_statement(@statement.content)
      }
      format.png {
        # this will change once we get cloud storage going on
        # redirect_to "/assets/images/" + @statement.hashid + ".png"
        redirect_to @statement.statement_image

        # redirect_to "https://assets.imgix.net/~text?fm=png&txtsize=36&w=600&txtfont=Helvetica,Bold&txt=I agree that " + @statement.content + "&txtpad=30&bg=fff&txtclr=000"
      }
    end
  end

  def create_child
    Rails.logger.debug '-------------'
    Rails.logger.debug 'CREATE_CHILD'
    Rails.logger.debug '-------------'

    # find the parent statement
    @parent = Statement.find(parent_params[:parent_id])

    # add the current user to the new statement
    merged_params = statement_params.merge!(:author => current_user)

    # create the new statement
    @statement = Statement.new(merged_params)

    Rails.logger.debug '-------------'
    Rails.logger.debug "CHILD: #{@statement.inspect}" # + @statement.inspect
    Rails.logger.debug '-------------'

    respond_to do |format|
      if @statement.save
        Rails.logger.debug '-------------'
        Rails.logger.debug 'CREATE_CHILD: SAVE'
        Rails.logger.debug '-------------'
        @parent.add_child @statement
        current_user.vote_for(@statement)
        # create the image
        # ? is this the best place for this?
        create_image(@statement)
        format.html { redirect_to @statement, notice: 'Statement was successfully created.' }
        format.json { render :show, status: :created, location: @statement }
      else
        Rails.logger.debug '-------------'
        Rails.logger.debug 'CREATE_CHILD: NO SAVE'
        Rails.logger.debug '-------------'
        # Rails.logger.debug '-------------'
        # Rails.logger.debug @statement.inspect
        # Rails.logger.debug '-------------'
        format.html { render :home }
        format.json { render json: @statement.errors, status: :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    print e
  end

  # GET /statements/new
  def new
    @statement = Statement.new
  end

  # GET /statements/1/edit
  def edit
  end

  # POST /statements
  # POST /statements.json
  def create
    # Rails.logger.debug '-------------'
    # Rails.logger.debug params.inspect
    # Rails.logger.debug '-------------'
    if (params[:statement_parent_id])
      # we are making a new version
      Rails.logger.debug 'CREATE CHILD'

      # in callbacks now
      # @parent = Statement.find(params[:statement_parent_id])

      Rails.logger.debug "PARENT: " + @parent.inspect
      @statement = @parent.children.create(statement_params)
      Rails.logger.debug @statement.inspect
      current_user.vote_exclusively_for(@statement)
    else
      # we are making a brand new content
      Rails.logger.debug "CREATE ROOT"
      @statement = Statement.new(statement_params)
    end
    if current_user
      @statement.author_id = current_user
    end

    respond_to do |format|
      if @statement.save
        # create the image
        # ? is this the best place for this?
        create_image(@statement)
        format.html { redirect_to @statement, notice: 'Statement was successfully created.' }
        format.json { render :show, status: :created, location: @statement }
      else
        Rails.logger.debug @statement.inspect
        format.html { render :home }
        format.json { render json: @statement.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_root
    Rails.logger.debug "\n-------- CREATE ROOT START --------"
    Rails.logger.debug "\nparams: " + root_params.inspect
    # create the basic statement
    @new_root = Statement.new(root_params)
    # add user author
    if current_user
      # Rails.logger.debug "\ncurrent_user: " + current_user.inspect
      @new_root.author = current_user
    else
      @new_root.author_id = 1
    end
    # Rails.logger.debug "\nnew_root: " + @new_root.inspect

    respond_to do |format|
      # save it to database
      if @new_root.save
        format.html { redirect_to @new_root, notice: 'Statement was successfully created. Share with your friends.' }
        format.json { render :show, status: :ok, location: @author }
        Rails.logger.debug "\n-------- CREATE ROOT SUCCESS --------"
      else
        Rails.logger.debug "\n-------- CREATE ROOT ERROR --------"
        # Rails.logger.debug @new_root.inspect
      end
    end
    Rails.logger.debug "\n-------- CREATE ROOT END --------"
  end

  # PATCH/PUT /statements/1
  # PATCH/PUT /statements/1.json
  def update
    respond_to do |format|
      if @statement.update(statement_params)
        format.html { redirect_to @statement, notice: 'Statement was successfully updated.' }
        format.json { render :show, status: :ok, location: @statement }
      else
        format.html { render :edit }
        format.json { render json: @statement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statements/1
  # DELETE /statements/1.json
  def destroy
    @statement.destroy
    respond_to do |format|
      format.html { redirect_to statements_url, notice: 'Statement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def tag_cloud
    @tags = Statement.tag_counts_on(:tags)
  end

  def search
    # I can't get ransack to return any results.
    @q = Statement.ransack(search_params[:q])
    @result = @q.result(distinct: true)

    # so this is a hard code version
    @raw = Statement.where('content LIKE ?', "%#{@q.content_cont}%")
    # Rails.logger.debug @raw.inspect
  end

  protected

  def redirect_to_homepage
    redirect_to :root, alert: 'User not found'
  end

  def create_image(statement)
    Rails.logger.debug "\n-------- create_image START --------\n"

    image_statement = "I agree that " + statement.content.gsub("'", %q(\\\'))
    convert = MiniMagick::Tool::Convert.new
    convert << "app/assets/images/weagreethat.png"
    convert << "-size"
    convert << "992x960"
    convert << "-extent"
    convert << "1024x"
    convert << "-font"
    convert << "helvetica"
    convert << "-weight"
    convert << "900"
    convert.gravity ("NorthWest")
    convert << "caption:" + image_statement
    convert << "-composite"
    convert << "public/assets/images/" + statement.hashid + ".png"
    Rails.logger.debug convert.command
    convert.call #=> `convert input.jpg -resize 100x100 -negate output.jpg`

    # https://guides.rubyonrails.org/v5.2.0/active_storage_overview.html
    # statement.statement_image.attach("public/assets/images/" + statement.hashid + ".png")
    # https://blog.capsens.eu/how-to-use-activestorage-in-your-rails-5-2-application-cdf3a3ad8d7
    statement.statement_image.attach(io: File.open("public/assets/images/#{statement.hashid}.png"), filename: "#{statement.hashid}.png")
    Rails.logger.debug "\n-------- create_image END --------\n"
  end

  def parse_statement(text)
    Rails.logger.debug "\n-------- PARSE_STATEMENT START --------"
    # GOOGLE NATURAL LANGUAGE
    # Imports the Google Cloud client library
    # ? does this need to be here?
    require 'google/cloud/language'
    # Instantiates a client
    language = Google::Cloud::Language.new
    # Detects the sentiment of the text
    sentiment_req = language.analyze_sentiment content: text, type: :PLAIN_TEXT
    # Analyzes syntax
    syntax_req = language.analyze_syntax content: text, type: :PLAIN_TEXT
    # Get document sentiment from response
    sentiment = sentiment_req.document_sentiment
    puts "Text: #{text}"
    puts "Score: #{sentiment.score}, #{sentiment.magnitude}"
    # Get syntax details
    sentences = syntax_req.sentences
    tokens    = syntax_req.tokens

    puts "Sentences: #{sentences.count}"
    puts "Tokens: #{tokens.count}"

    tokens.each do |token|
      puts "#{token.part_of_speech.tag} #{token.text.content} #{token.part_of_speech.proper}"
    end

    puts tokens.first.part_of_speech

    if (tokens.first.part_of_speech.tag.eql? :NOUN) && (tokens.first.part_of_speech.proper.eql? :PROPER)
      Rails.logger.debug "\n-------- PARSE_STATEMENT STARTS WITH PROPER NOUN --------"
    end
    tokens
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_statement
    Rails.logger.debug "\n\n-------- SET_STATEMENT start --------\n\n"
    @statement = Statement.find(params[:id])
    Rails.logger.debug "\n\n-------- SET_STATEMENT end --------\n\n"
  end

  def set_parent_for_new
    Rails.logger.debug "\n\n-------- SET_PARENT_FOR_NEW start --------\n\n"
    if params[:statement][:parent_id]
      @parent = Statement.find(params[:statement][:parent_id])
    end
    Rails.logger.debug "\n\n-------- SET_PARENT_FOR_NEW end --------\n\n"
  end

  def set_parent
    Rails.logger.debug "\n\n-------- SET_PARENT start --------\n\n"

    if params[:parent_id]
      Rails.logger.debug "\n\n-------- SET_PARENT parent_id --------\n\n"
      @parent = Statement.find(params[:parent_id])
    elsif params[:id]
      Rails.logger.debug "\n\n-------- SET_PARENT id --------\n\n"

      # this is an extra db call
      # @parent = Statement.find(params[:id]).parent
      @parent = @statement.parent
    # we need to include an else for a brand new one from index
    else
      # for show.html.erb
      Rails.logger.debug "\n\n-------- SET_PARENT none --------\n\n"
      @parent = @statement.parent
    end
    Rails.logger.debug "\n\n-------- SET_PARENT end --------\n\n"
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def statement_params_new
    params.permit(:id)
  end

  def statement_params
    params.require(:statement).permit(:content, :author_id, :parent_id, :tag_list, reports: [ ])
  end

  def parent_params
    params.require(:statement).permit(:parent_id, :id)
  end

  def root_params
    params.require(:statement).permit(:content, :tag_list)
  end

  def search_params
    params.permit(:utf8, :commit, q: [:content_cont]).to_h
  end
end
