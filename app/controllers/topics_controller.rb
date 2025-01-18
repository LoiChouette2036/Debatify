class TopicsController < ApplicationController
  def update_thermometer
    @topic = Topic.find(params[:id])
    total_votes = @topic.comments.where(status: %w[for against]).count
    max_votes = 100
    @thermometer_percentage = [(total_votes.to_f / max_votes * 100), 100].min

    respond_to do |format|
      format.turbo_stream # Render the Turbo Stream response
    end
  end



  def index
    if params[:query].present?
      @topics = Topic.search_topics(params[:query])
    else
      @topics = Topic.all
    end

    respond_to do |format|
      format.html
      format.text { render partial: "topics/card_topics", locals: { topics: @topics }, formats: [:html] }
    end
  end

  def show
    @topic = Topic.find(params[:id])
    @user = current_user

    @comments = @topic.comments
    @new_comment = Comment.new
    @main_comments = @comments.where(parent_id: nil)

    @for_votes = @main_comments.where(status: 'for').count
    @against_votes = @main_comments.where(status: 'against').count
    @neutral_votes = @main_comments.where(status: 'neutral').count

    total_votes = @for_votes + @against_votes
    max_votes = 100
    @thermometer_percentage = [total_votes.to_f / max_votes * 100, 100].min

    # client = OpenAI::Client.new
    # chatgpt_response = client.chat(parameters: {
    #   model: "gpt-4o-mini",
    #   messages: [{ role: "user", content: "give me a summary of how the users feel based on the comments: #{@main_comments.map(&:content).join(', ')}. If there are no comments,
    #   or less than 2 comments, write 'waiting for new comments'.  give an example of a comment on
    #   against and for side. For example you can say that someone felt this way about the topic, but dont give
    #   the exact comment, just a summary of the comment, and word it like 'for example, one user felt this way' etc. make your summary max 300 characters.
    #   if there is no comment, make just a phrase where say you re waiting comments to summarize. " }]
    # })
    # @content = chatgpt_response['choices'][0]['message']['content']
    @content = "No AI for now"
    @comment = @topic.comments.build
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(params_topics)
    @topic.user_id = current_user.id
    if @topic.save
      redirect_to topic_path(@topic)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def params_topics
    params.require(:topic).permit(:title, :description, :category)
  end
end
