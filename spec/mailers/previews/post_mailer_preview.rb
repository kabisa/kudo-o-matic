class PostMailerPreview < ActionMailer::Preview
  def new_post
    post = Post.last
    user = User.where.not(email: '').first

    PostMailer.post_email(user, post)
  end
end