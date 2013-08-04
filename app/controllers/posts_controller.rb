class PostsController < ApplicationController
	def index
  		@posts = Post.all
	end

	def new
		@post = Post.new
    end

    def create
    	#render text: params[:post].inspect
    	@post = Post.new(post_params)

  		if @post.save
 			#redirect_to @post
 			#render 'show'
 			redirect_to posts_path
 		else
    		render 'new'
    	end
    end

	def show
	  	@post = Post.find(params[:id])
	end

	def edit
      	@post = Post.find(params[:id])
    end

	def update
	  	@post = Post.find(params[:id])

	  	if @post.update(post_params)
	    	redirect_to @post
	  	else
	    	render 'edit'
	  	end
	end

	def destroy
		@post = Post.find(params[:id])
		@post.destroy

		respond_to do |format|
          	format.html { redirect_to posts_url }
        	format.json { head :no_content }
        end
	end

  #######################
	#######################
  def update_db(hash)
    (query(hash).any?) ? renew(hash) : add(hash)
  end

	def add(hash)
		puts '#############################################'
		puts 'inside Post add(hash)'
		puts '#############################################'

    # To-do: indicate what to add in what columns
		# post = Post.new({ title: hash[:title], text: hash[:text].to_s })
		# post.save

    #########################
    hash[:text].each do |t|
      post = Post.new({ title: hash[:title], text: t.to_s })
      post.save
    end
    #########################
	end

	def renew(hash)
		puts '#############################################'
		puts 'inside Post renew(hash)'
		puts '#############################################'

    target_posts = query(hash)
    if target_posts.many?
      target_posts.each do |post|
        # To-do: indicate what to update in what columns
        post.update({ title: hash[:title], text: hash[:text].to_s+'[--]updated' })
      end
    else
      # To-do: indicate what to update in what columns
      Post.update( target_posts, { title: hash[:title], text: hash[:text].to_s+'[--]updated' })
    end
	end

	def query(hash)
    puts '#############################################'
    puts 'inside Post query(hash)'
    puts '#############################################'

    Post.where(title: hash[:title])
	end
	#######################
  #######################

  private
  	def post_params
  		params.require(:post).permit(:title, :text)
  	end
end
