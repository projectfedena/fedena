desc "Given MODELS=Foo,Bar,Baz find all instances in the DB and save to sanitize existing records"
task :xss_terminate => :environment do
  models = ENV['MODELS'].split(',')
  models.each do |model|
    model.constantize.find(:all).map(&:save)
  end
end
