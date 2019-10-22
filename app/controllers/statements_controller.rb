class StatementsController < ApplicationController
  before_action :set_statement, only: [:show, :edit, :update, :destroy, :agree, :disagree, :toggle_agree]
  before_action :set_parent, only: [:show, :update]
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_homepage

  def agree
    Rails.logger.debug "-------------"
    Rails.logger.debug "AGREE"
    Rails.logger.debug "-------------"
    Rails.logger.debug "-------------"
    Rails.logger.debug current_user
    Rails.logger.debug "-------------"
    begin
      current_user.vote_for(@statement)
      respond_to do |format|
        format.html {redirect_back fallback_location: root_path}
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
        format.html {redirect_to :back}
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
        format.html {redirect_to :back}
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
      Rails.logger.debug "-------------"
      Rails.logger.debug "VOTED: #{@agreed}"
      Rails.logger.debug "-------------"
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
    #! check for format here
    respond_to do |format|
      format.html {}
      format.png {
        redirect_to "https://assets.imgix.net/~text?fm=png&txtsize=36&w=600&txtfont=Helvetica,Bold&txt=I agree that " + @statement.content + "&txtpad=30&bg=fff&txtclr=000"
      }
    end

    # get the immediate parent for diff
    if @statement.parent
      @diff = Diffy::Diff.new(@statement.parent.content, @statement.content).to_s(:html).html_safe
      # @diff_left = Diffy::Diff.new(@statement.parent.content, @statement.content).to_s(:html).html_safe
      @diff_left = Diffy::SplitDiff.new(@statement.parent.content, @statement.content, :format => :html).left.html_safe
      @diff_right = Diffy::SplitDiff.new(@statement.parent.content, @statement.content, :format => :html).right.html_safe
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
      # Rails.logger.debug "-------------"
      # Rails.logger.debug "VOTED: #{@agreed}"
      # Rails.logger.debug "-------------"
    end

    # set the agree button css.
    #? is there a better way of doing this in the presentation layer?
    @css_string = "btn btn-success btn-lg"
    if @agreed
      @css_string += " active"
    end

    # GOOGLE NATURAL LANGUAGE
    # Imports the Google Cloud client library
    #? does this need to be here?
    require "google/cloud/language"
    # Instantiates a client
    language = Google::Cloud::Language.new
    # The text to analyze
    text = @statement.content
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

    # # Not sure if this works
    # # Probably won't work with Heroku
    # first_image = MiniMagick::Image.open "public/agree_00.png"
    # second_image = MiniMagick::Image.open "https://assets.imgix.net/~text?fm=png&txtsize=40&w=600&txtfont=Helvetica,Bold&txt=" + @statement.content + "&txtpad=30&bg=fff&txtclr=000"
    # result = first_image.composite(second_image) do |c|
    #   c.compose "Over" # OverCompositeOp
    #   c.geometry "+0+80" # copy second_image onto first_image from (20, 20)
    # end
    # result.write "output_" + @statement.id.to_s + ".png"
    #
    # # kit = IMGKit.new('http://google.com', :quality => 50)
    # @kit = IMGKit.new(@statement.content)
    # respond_to do |format|
    #   format.html
    #   format.png {
    #     # send_data(result, :type => "image/png", :disposition => 'inline')
    #     send_file "output_" + @statement.id.to_s + ".png", type: 'image/png', disposition: 'inline'
    #     # redirect_to "https://assets.imgix.net/~text?fm=png&txtsize=36&w=600&txtfont=Helvetica,Bold&txt=I agree that " + @statement.content + "&txtpad=30&bg=fff&txtclr=000"
    #   }
    # end
  end

  def create_child
    Rails.logger.debug "-------------"
    Rails.logger.debug "CREATE_CHILD"
    Rails.logger.debug "-------------"
    @parent = Statement.find(parent_params[:statement_parent_id])
    merged_params = statement_params.merge!(:author => current_user)
    @statement = Statement.new(merged_params)
    Rails.logger.debug "-------------"
    Rails.logger.debug "CHILD: " + @statement.inspect
    Rails.logger.debug "-------------"

    respond_to do |format|
      if @statement.save
        Rails.logger.debug "-------------"
        Rails.logger.debug "CREATE_CHILD: SAVE"
        Rails.logger.debug "-------------"
        @parent.add_child @statement
        current_user.vote_for(@statement)
        format.html { redirect_to @statement, notice: 'Statement was successfully created.' }
        format.json { render :show, status: :created, location: @statement }
      else
        Rails.logger.debug "-------------"
        Rails.logger.debug "CREATE_CHILD: NO SAVE"
        Rails.logger.debug "-------------"
        # Rails.logger.debug "-------------"
        # Rails.logger.debug @statement.inspect
        # Rails.logger.debug "-------------"
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
    # Rails.logger.debug "-------------"
    # Rails.logger.debug params.inspect
    # Rails.logger.debug "-------------"
    if (params[:statement_parent_id])
      # we are making a new version
      Rails.logger.debug "CREATE CHILD"
      @parent = Statement.find(params[:statement_parent_id])
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_statement
      @statement = Statement.find(params[:id])
    end

    def set_parent
      if (params[:statement_parent_id])
        @parent = Statement.find(params[:statement_parent_id])
      elsif (params[:statement_id])
        @parent = Statement.find(params[:statement_id]).parent
      # we need to include an else for a brand new one from index
      else
        # for show.html.erb
        @parent = @statement.parent
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def statement_params
      params.require(:statement).permit(:content, :author_id, :parent_id, :tag_list)
    end

    def parent_params
      params.require(:statement).permit(:statement_parent_id)
    end

    def root_params
      params.require(:statement).permit(:content, :tag_list)
    end

    def search_params
      params.permit(:utf8, :commit, q: [:content_cont]).to_h
    end
end
