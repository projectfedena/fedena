# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{translator}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Champion"]
  s.date = %q{2009-04-17}
  s.description = %q{Translator makes using Rails internationalization simpler}
  s.email = %q{mike@graysky.org}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/translator.rb",
    "test/fixtures/app/controllers/blog_posts_controller.rb",
    "test/fixtures/app/helpers/blog_posts_helper.rb",
    "test/fixtures/app/models/blog_comment_mailer.rb",
    "test/fixtures/app/models/blog_post.rb",
    "test/fixtures/app/views/blog_comment_mailer/comment_notification.rhtml",
    "test/fixtures/app/views/blog_posts/_footer.erb",
    "test/fixtures/app/views/blog_posts/about.erb",
    "test/fixtures/app/views/blog_posts/archives.erb",
    "test/fixtures/app/views/blog_posts/missing_translation.erb",
    "test/fixtures/app/views/blog_posts/show.erb",
    "test/fixtures/app/views/layouts/blog_layout.erb",
    "test/fixtures/app/views/shared/_header.erb",
    "test/fixtures/schema.rb",
    "test/locales/en.yml",
    "test/locales/es.yml",
    "test/test_helper.rb",
    "test/translator_test.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/graysky/translator}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Rails extentions to simplify internationalization}
  s.test_files = [
    "test/fixtures/app/controllers/blog_posts_controller.rb",
    "test/fixtures/app/helpers/blog_posts_helper.rb",
    "test/fixtures/app/models/blog_comment_mailer.rb",
    "test/fixtures/app/models/blog_post.rb",
    "test/fixtures/schema.rb",
    "test/test_helper.rb",
    "test/translator_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
