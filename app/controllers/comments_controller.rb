class CommentsController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.create(params[:comment].permit(:commenter, :body))
    redirect_to post_path(@post)
  end

  def destroy
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find(params[:id])
    @comment.destroy
    redirect_to post_path(@post)
  end

  #######################
  #######################
  def update_db(hash)
    puts '#############################################'
    puts 'inside comments update_db(hash)'

    posts = query(hash)
    # If found any records, update the dependents
    # If not, raise exception
    raise Exception if !posts.any?
    update_dependent_db(posts, hash)
  end

  def update_dependent_db(posts, hash)
    puts 'inside comments update_dependent_db(posts, hash)'
    # If multipal records found in here, change/add the dependent record(s)
    if posts.many?
      posts.each do |p|
        puts p.class
        ( p.comments.any? ) ? renew(p,hash) : add(p,hash)
      end
    else
      # If only one record found, change/add the dependent record(s)
      ( posts.first.comments.any? ) ? renew(posts.first,hash) : add(posts.first,hash)
    end
  end

  def add(post, hash)
    puts 'inside comments add(post, hash)'
    # To-do: indicate what to add in what columns
    post.comments.create({ commenter: 'Add' ,body: 'In add' })
  end

  def renew(post, hash)
    puts 'inside comments renew(post, hash)'

    target_comments = post.comments
    if target_comments.many?
      target_comments.each do |comment|
        # To-do: indicate what to update in what columns
        comment.update({ commenter: 'Renew' ,body: 'In renew => many' })
      end
    else
      # To-do: indicate what to update in what columns
      Comment.update( target_comments, { commenter: 'Renew' ,body: 'In renew => one' } )
    end
  end

  def query(hash)
    puts 'inside comments query(hash)'

    posts = Post.where(title: hash[:title])
  end
  #######################
  #######################
end
