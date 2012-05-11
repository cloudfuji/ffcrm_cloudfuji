# Mail routes
Cloudfuji::Mailroute.map do |m|
  m.route("mail.new_comment") do
    m.subject('{:project_title}: {:mock_title} #{:mock_version} comment {:parent_comment_id}',
              :project_title     => m.words_and_spaces,
              :mock_title        => m.words_and_spaces,
              :mock_version      => m.number,
              :parent_comment_id => m.number)


    # Must be replying to send a new comment via email
    m.add_constraint(:reply, :required)
  end

  m.route("mail.new_project") do
    m.subject("{:project_title}: {:mock_title}",
              :project_title => m.words_and_spaces,
              :mock_title    => m.words_and_spaces)
  end

  m.route("mail.simple") do
    m.subject("hello")
  end
end
