# frozen_string_literal: true

class StatementsController < ApplicationController
  require "mini_magick"

  before_action :set_statement, only: [:show, :edit, :update, :destroy, :agree, :disagree, :toggle_agree, :image_square, :image_2to1]
  before_action :set_parent, only: [:show, :update, :create]
  before_action :set_parent_for_new, only: [:create_child]
  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_homepage

  def home
    @agreed = false
    # create a temporary child in case they want to make a variant
    @new = Statement.new
    # @child.parent_id = 1
    # get the first one
    @statement = Statement.find(1)
    @top_ten = Statement.top.limit(10)
    if current_user
      @agreed = current_user.voted_for?(@statement)
    end

    @css_string = 'btn btn-success btn-lg'
    if @agreed
      @css_string += ' active'
    end
  end

  # GET /statements
  # GET /statements.json
  def index
    @statements = Statement.all
    # @top_ten = Statement.tally.order(:votes_for)
    @tags = Statement.tag_counts_on(:tags)
    @top_ten = Statement.top.limit(10)
    @most_recent = Statement.recent.limit(10)
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

        @voted_ancestor = @statement.voted_ancestor(current_user)
        @voted_descendant = @statement.voted_descendant(current_user)

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
        if @statement.statement_image.attached?
          redirect_to polymorphic_url(@statement.statement_image)
        elsif @statement.image_square.attached?
          redirect_to polymorphic_url(@statement.image_square)
        elsif @statement.image_2to1.attached?
          redirect_to polymorphic_url(@statement.image_2to1)
        end

        # redirect_to "https://assets.imgix.net/~text?fm=png&txtsize=36&w=600&txtfont=Helvetica,Bold&txt=I agree that " + @statement.content + "&txtpad=30&bg=fff&txtclr=000"
      }
    end
  end

  def tag
    Rails.logger.debug "\n\n------------- tag start -------------\n\n"
    # Rails.logger.debug tag_params.inspect
    @tag = tag_params[:tag]
    @tagged_statements_top = Statement.tagged_with(@tag).top.limit(10)
    @tagged_statements_recent = Statement.tagged_with(@tag).recent.limit(10)
    # Rails.logger.debug @tagged_statements.inspect
    Rails.logger.debug "\n\n------------- tag end -------------\n\n"
  end
  #
  # def agree
  #   Rails.logger.debug "\n\n------------- agree start -------------\n\n"
  #
  #   begin
  #     # find next vote up ancestor tree
  #     @voted_ancestor = @statement.ancestors.voted_for?
  #     Rails.logger.debug @voted_ancestor.inspect
  #
  #     vote = current_user.vote_for(@statement)
  #     # Rails.logger.debug vote.inspect
  #
  #     @statement.update_vote_count
  #
  #     respond_to do |format|
  #       format.html { redirect_back fallback_location: root_path }
  #       format.js {}
  #     end
  #     # render :nothing => true, :status => 200
  #   rescue ActiveRecord::RecordInvalid
  #     render nothing: true, status: 404
  #   rescue ActiveRecord::RecordNotFound
  #     render nothing: true, status: 404
  #   end
  # end
  #
  # def disagree
  #   Rails.logger.debug "\n\n------------- disagree start -------------\n\n"
  #   begin
  #     current_user.unvote_for(@statement)
  #     respond_to do |format|
  #       format.html { redirect_to :back }
  #       format.js {}
  #     end
  #   rescue ActiveRecord::RecordInvalid
  #     render nothing: true, status: 404
  #   end
  # end

  def toggle_agree
    Rails.logger.debug '-------------'
    Rails.logger.debug 'TOGGLE_AGREE start'
    Rails.logger.debug '-------------'

    begin
      if current_user.voted_for?(@statement)
        current_user.unvote_for(@statement)
      else
        # find next vote up ancestor tree
        # get all ancestors
        @ancestors = @statement.ancestors
        Rails.logger.debug "\n\n--------- ancestors: #{@ancestors.inspect}\n\n"
        # traverse ancestors to find voted_for
        @voted_ancestor = @ancestors.find { |ancestor|
          current_user.voted_for?(ancestor)
        }
        Rails.logger.debug "\n\n--------- voted_ancestor: #{@voted_ancestor.inspect}\n\n"

        vote = current_user.vote_for(@statement)

        # this section adds the country to the vote
        # clearly not the best way or place to do this.
        if Rails.env.production?
          ip = request.remote_ip
        else
          ip = Net::HTTP.get(URI.parse('http://checkip.amazonaws.com/')).squish
        end
        country_code = HTTParty.get("http://ip-api.com/line/#{ip}?fields=countryCode").body.strip
        vote.update_column(:country, country_code)
      end

      @statement.update_vote_count

      respond_to do |format|
        format.html { redirect_to :back }
        format.js {}
      end
      # render :nothing => true, :status => 200
    rescue ActiveRecord::RecordInvalid
      render nothing: true, status: 404
    rescue ActiveRecord::RecordNotFound
      render nothing: true, status: 404
    end
  end

  # this is where the actual agreeing happens
  def agree
    Rails.logger.debug "\n\n--------- agree start --------\n\n"

    @ancestors = @statement.ancestors
    # traverse ancestors to find voted_for
    @voted_ancestor = @ancestors.find { |ancestor|
      current_user.voted_for?(ancestor)
    }

    vote = current_user.vote_for(@statement)

    # this section adds the country to the vote
    # clearly not the best way or place to do this.
    if Rails.env.production?
      ip = request.remote_ip
    else
      ip = Net::HTTP.get(URI.parse('http://checkip.amazonaws.com/')).squish
    end
    country_code = HTTParty.get("http://ip-api.com/line/#{ip}?fields=countryCode").body.strip
    vote.update_column(:country, country_code)

    Rails.logger.debug "\n\n--------- agree end --------\n\n"
  end

  def image_square
    respond_to :png
    Rails.logger.debug "\n\nIMAGE_SQUARE\n\n"
    redirect_to @statement.image_square if @statement.image_square.attached?
  end

  def image_2to1
    Rails.logger.debug "\n\nIMAGE_2to1\n\n"
    redirect_to @statement.image_2to1 if @statement.image_2to1.attached?
  end

  def create_child
    Rails.logger.debug '-------------'
    Rails.logger.debug 'CREATE_CHILD'
    Rails.logger.debug '-------------'

    # find the parent statement
    @parent = Statement.find(parent_params[:parent_id])

    # add the current user to the new statement
    merged_params = statement_params.merge!(author: current_user)

    # create the new statement
    @statement = Statement.new(merged_params)

    Rails.logger.debug '-------------'
    Rails.logger.debug "CHILD: #{@statement.inspect}" # + @statement.inspect
    Rails.logger.debug '-------------'

    Rails.logger.debug "\n\nCheck if unique\n\n"
    redirect_to Statement.find_by_content(@statement.content) and return if not @statement.valid?

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
        # parse statement
        parse_statement(@statement.content)

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

        # create images
        create_image(@statement)
        # parse statement
        parse_statement(@statement.content)

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

    Rails.logger.debug "\n\nCheck if unique\n\n"
    redirect_to Statement.find_by_content(@new_root.content) and return if not @new_root.valid?


    respond_to do |format|
      # save it to database
      if @new_root.save
        current_user.vote_for(@new_root)

        # create images
        create_image(@new_root)
        # parse statement
        parse_statement(@new_root.content)

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

    # StatementCreateImage.perform_async(statement.hashid, statement.content)
    StatementCreateSquareImageWorker.perform_async(statement.hashid, statement.content)
    StatementCreateTwoToOneImageWorker.perform_async(statement.hashid, statement.content)

    Rails.logger.debug "\n-------- create_image END --------\n"
  end

  def parse_statement(text)
    Rails.logger.debug "\n-------- PARSE_STATEMENT START --------"
    # # GOOGLE NATURAL LANGUAGE
    # # Imports the Google Cloud client library
    # # ? does this need to be here?
    # require 'google/cloud/language'
    # # Instantiates a client
    # language = Google::Cloud::Language.new
    # # Detects the sentiment of the text
    # sentiment_req = language.analyze_sentiment content: text, type: :PLAIN_TEXT
    # # Analyzes syntax
    # syntax_req = language.analyze_syntax content: text, type: :PLAIN_TEXT
    # # Get document sentiment from response
    # sentiment = sentiment_req.document_sentiment
    # puts "Text: #{text}"
    # puts "Score: #{sentiment.score}, #{sentiment.magnitude}"
    # # Get syntax details
    # sentences = syntax_req.sentences
    # tokens    = syntax_req.tokens
    #
    # puts "Sentences: #{sentences.count}"
    # puts "Tokens: #{tokens.count}"
    #
    # tokens.each do |token|
    #   puts "#{token.part_of_speech.tag} #{token.text.content} #{token.part_of_speech.proper}"
    # end
    #
    # puts tokens.first.part_of_speech
    #
    # if (tokens.first.part_of_speech.tag.eql? :NOUN) && (tokens.first.part_of_speech.proper.eql? :PROPER)
    #   Rails.logger.debug "\n-------- PARSE_STATEMENT STARTS WITH PROPER NOUN --------"
    # end
    # tokens

    # MeaningCloud
    meaning_cloud_sentiment = HTTParty.get("https://api.meaningcloud.com/sentiment-2.1?key=4935702876bc0158e849c1bf91e1f8d1&lang=en&verbose=y&txt=#{text}")
    Rails.logger.debug "\n\n\nSentiment Results: #{meaning_cloud_sentiment.parsed_response['score_tag']}\n\n\n"
    meaning_cloud_category = HTTParty.get("https://api.meaningcloud.com/deepcategorization-1.0?key=4935702876bc0158e849c1bf91e1f8d1&lang=en&verbose=y&model=IAB_2.0_en&txt=#{text}")
    Rails.logger.debug "\n\n\nCategory Results: #{meaning_cloud_category.parsed_response['score_tag']}\n\n\n"
    nutrino_swear = HTTParty.post('https://neutrinoapi.com/bad-word-filter',
      :body => { "user-id" => ENV['AGREE_NUTRINO_USER'],
               "api-key" => ENV['AGREE_NUTRINO_KEY'],
               "content" => text,
               }.to_json,
      :headers => { 'Content-Type' => 'application/json' })
    Rails.logger.debug "\n\n\nSwear Results: #{nutrino_swear.parsed_response['bad-words-total']}\n\n\n"
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

  # def top_ten
  #   Statement.plusminus_tally.limit(10)
  # end

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

  def tag_params
    params.permit(:tag)
  end
end
