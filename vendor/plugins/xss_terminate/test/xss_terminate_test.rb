require File.join(File.dirname(__FILE__), 'setup_test')

class XssTerminateTest < Test::Unit::TestCase
  def test_strip_tags_on_discovered_fields
    c = Comment.create!(:title => "<script>alert('xss in title')</script>",
                        :body => "<script>alert('xss in body')</script>")

    assert_equal "alert('xss in title')", c.title
    
    assert_equal "alert('xss in body')", c.body
  end
  
  def test_rails_sanitization_on_specified_fields
    e = Entry.create!(:title => "<script>alert('xss in title')</script>",
                      :body => "<script>alert('xss in body')</script>",
                      :extended => "<script>alert('xss in extended')</script>",
                      :person_id => 1)

    assert_equal [:body, :extended], e.xss_terminate_options[:sanitize]
    
    assert_equal "alert('xss in title')", e.title

    assert_equal "", e.body

    assert_equal "", e.extended
  end
  
  def test_excepting_specified_fields
    p = Person.create!(:name => "<strong>Mallory</strong>")
    
    assert_equal [:name], p.xss_terminate_options[:except]
    
    assert_equal "<strong>Mallory</strong>", p.name
  end
  
  def test_html5lib_sanitization_on_specified_fields
    r = Review.create!(:title => "<script>alert('xss in title')</script>",
                       :body => "<script>alert('xss in body')</script>",
                       :extended => "<script>alert('xss in extended')</script>",
                       :person_id => 1)
                       
    assert_equal [:body, :extended], r.xss_terminate_options[:html5lib_sanitize]

    assert_equal "alert('xss in title')", r.title
    
    assert_equal "&lt;script&gt;alert('xss in body')&lt;/script&gt;", r.body
    
    assert_equal "&lt;script&gt;alert('xss in extended')&lt;/script&gt;", r.extended
  end
  
  # issue reported by linojon
  def test_nil_attributes_should_be_allowed_with_html5
    review = Review.create!(:title => nil, :body => nil)
    
    assert_nil review.title
    assert_nil review.body
  end
  
  # issue reported by Garrett Dimon and jmcnevin
  def test_active_record_session_store_does_not_cause_nil_exception
    assert_nil CGI::Session::ActiveRecordStore::Session.xss_terminate_options

    session = CGI::Session::ActiveRecordStore::Session.new(:session_id => 'foo', :data => 'blah')
    assert session.save
  end

  def test_do_not_save_invalid_models_after_sanitizing
    c = Comment.new(:title => "<br />")
    assert !c.save
    assert_not_nil c.errors.on(:title)
  end
  
  def test_valid_work_with_serialize_fields
    g = Group.new(:title => "XSS Terminate group", :description => 'desc', :members => [1,2,3])
    assert g.save
  end
  
  def test_valid_work_with_number_fields
    g = Group.new(:title => "XSS Terminate group", :description => 123456, :members => {:hash => 'rocket'})
    assert g.save
  end

end
